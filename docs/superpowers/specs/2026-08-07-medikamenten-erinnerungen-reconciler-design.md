# Medikamenten-Erinnerungen: ein berechneter Soll-Zustand statt handgeführter Alarme

**Datum:** 2026-08-07
**Status:** Umgesetzt einschließlich Stufe 3 (Termine). Stufe 2 offen.
**Betrifft:** Aurora 3.0.15 → 3.1.0

---

## 1. Problem

Die Medikamenten-Erinnerung ist die Funktion, bei der ein Fehler am teuersten ist. Eine verpasste Dosis kann bei diesem Krankheitsbild einen Tag kosten, eine doppelte Dosis mehr. Ein Gerätetest am 07.08.2026 auf einem Galaxy S24 (Android 16, `com.disapp.dis_app` 3.0.15, Debug-Build) hat sieben Fehlverhalten belegt. Sie haben eine gemeinsame Ursache.

### 1.1 Befunde

Alle Belege stammen aus demselben Durchlauf: Profil „Lina", Bestand ein Medikament (Vitamin D, 15:00), im Test angelegt ein zweites (Testmed, 12:50).

**Befund 1 — Stille Erlaubnislücke.** Vor dem Test:

```
android.permission.POST_NOTIFICATIONS: granted=false
android.permission.USE_EXACT_ALARM: granted=true
```

`dumpsys alarm | grep disapp` zeigte zehn Einträge, sämtlich mit `OW=2026-08-05` und `OW=2026-08-06` — kein einziger für den laufenden Tag. Das Startprotokoll:

```
NotificationService: Boxes opened  {queueEntries: 0, medications: 1}
NotificationService: Queue synced
NotificationService: Nothing rescheduled — still no permission
```

Die Oberfläche zeigte gleichzeitig ein Weckersymbol an der Medikamentenkarte und in der Kopfzeile. Der Schalter „Aurora erinnert dich" stand auf an. Es gab keinen Hinweis darauf, dass nichts geplant war. Wer nach der Installation einmal „Nicht zulassen" tippt oder die Erlaubnis später entzieht, bekommt nie wieder eine Erinnerung und erfährt es nie.

**Befund 2 — „Genommen" räumt die Vorwarnungen nicht ab.** Vitamin D (15:00) wurde um 12:22 als genommen markiert. Die Oberfläche reagierte korrekt (Durchstreichung, „Taken by Lina"). Der Alarmspeicher danach:

```
OW=2026-08-07 14:30:00
OW=2026-08-07 14:50:00
OW=2026-08-07 15:00:00
```

Unverändert. `_onMedicationTaken` ruft nur `cancelRepeatReminders()`, also ausschließlich die +10-Minuten-Wiederholungen. Die drei geplanten Erinnerungen für eine erledigte Dosis bleiben stehen.

**Befund 3 — „Später" ist beim Betriebssystem nicht angemeldet.** Testmed (12:50) wurde um 12:21 auf „Später" gesetzt. Protokoll:

```
logMedicationTaken {status: snoozed, snoozedUntil: 2026-08-07T13:21:37, scheduledTime: 12:50}
NotificationService: Cancelled repeat reminders
```

Im Alarmspeicher steht kein Eintrag für 13:21. Die Snooze-Erinnerung existiert nur als Warteschlangeneintrag in der App. Ist die App geschlossen, kommt sie nie. Ist die App offen, kommen zusätzlich die unveränderten Vorwarnungen um 12:40 und 12:50 — also drei Meldungen für eine Dosis, die gerade verschoben wurde.

**Befund 4 — Snooze rechnet ab Tippzeitpunkt.** Getippt wurde auf die Vorwarnung „in 30 Minuten" um 12:21. `snoozedUntil` wurde 13:21. Die Dosis war für 12:50 vorgesehen. Der Aufschub schiebt die Erinnerung hinter die Einnahmezeit.

**Befund 5 — Kein Zurück.** Nach „Später" und nach „Genommen" verschwindet die Knopfreihe der Karte. Ein Fehlgriff ist nicht korrigierbar, ohne den Eintrag über Umwege zu suchen. In einem System mit Wechseln und Erinnerungslücken ist das die falsche Richtung: Korrigieren muss billiger sein als Festlegen.

**Befund 6 — Meldung ohne Handlungen.** `dumpsys notification --noredact` für die um 12:20 zugestellte Meldung:

```
NotificationRecord(... pkg=com.disapp.dis_app ... flags=AUTO_CANCEL ...)
    android.title=String (Medication Reminder)
    android.text=String (Testmed - 1 Tablette in 30 minutes)
```

Kein `actions=`-Feld (eine parallel anliegende Fremdmeldung zeigt zum Vergleich `actions=2`). Es gibt keinen Weg, vom Sperrbildschirm „genommen" zu sagen. Der Weg führt über App öffnen, Profil wählen, Bereich suchen, Karte finden.

**Befund 7 — Zwei Zustellwege nebeneinander.** Die Meldung um 12:20 wurde nicht vom Betriebssystem-Alarm ausgelöst, sondern vom App-internen Minutentakt:

```
12:20:17  NotificationService: Processing due notifications
12:20:17  NotificationService: Sending notification {platformId: 2039229278}
```

Der Zeitstempel 12:20:**17** entspricht dem Start des `Timer.periodic` um 12:08:17. Parallel stand ein Betriebssystem-Alarm auf 12:20:00. Zwei Wege, dieselbe Meldung, dieselbe Plattform-ID — die Verdopplung fällt nur deshalb nicht auf, weil Android bei gleicher ID ersetzt. Welcher Weg trägt, wenn die App tot ist, war bis zum Abschluss dieses Designs nicht abschließend belegt (siehe § 11).

**Befund 8 — Kleinigkeiten mit derselben Handschrift.** Die Überschriften des Zeitwählers stehen auf Deutsch („Stunden", „Minuten") in einer englischsprachigen Oberfläche. Die Snooze-Anzeige nennt „1:21 PM", die Dosiszeit darüber „12:50" — zwei Zeitformate auf einer Karte. Ein neu angelegtes Medikament wird ungefragt allen Profilen zugeordnet (`profileIds: [seed-profile-lina, seed-profile-mina]`), ohne dass das Formular danach fragt oder es anzeigt. Nach dem Schließen des Zeitwählers springt der Eingabefokus zurück ins Dosisfeld und die Tastatur öffnet sich — eine Wischgeste über die Seite schreibt dann Ziffern in die Dosis.

**Befund 9 — Kein Alarm hat je zugestellt.** Der schwerste, und er lag unter allen anderen.

Vier Durchläufe, jeweils Alarm gefeuert, App-Prozess nachweislich tot (`pidof` leer), Paket nicht im Stopp-Zustand (`stopped=false`), Standby-Eimer 10 (aktiv), Erlaubnis erteilt. Aus dem Broadcast-Protokoll des Systems:

```
enq=2026-08-07 12:20:00.010  disp=1970-01-01 01:00:00.000
enq=2026-08-07 12:40:00.008  disp=1970-01-01 01:00:00.000
enq=2026-08-07 12:50:00.013  disp=1970-01-01 01:00:00.000
enq=2026-08-07 13:13:00.012  disp=1970-01-01 01:00:00.000  fin=13:13:00.012
```

Eingereiht, in derselben Millisekunde beendet, **nie zugestellt**. Kein Empfänger lief.

Ursache: `flutter_local_notifications` bringt seine Broadcast-Empfänger nicht mit. Sein eigenes Manifest (`flutter_local_notifications-17.2.4/android/src/main/AndroidManifest.xml`) enthält ausschließlich zwei `uses-permission`-Zeilen. Die Empfänger muss die App deklarieren — Auroras `android/app/src/main/AndroidManifest.xml` enthielt keinen einzigen. `zonedSchedule` legt trotzdem brav einen Alarm an, der Alarm feuert pünktlich, und der Broadcast geht an ein Bauteil, das im Paket nicht existiert. Ohne Fehlermeldung, ohne Protokollzeile, ohne jeden Hinweis.

Damit erklärt sich Befund 7 rückwirkend: **jede Erinnerung, die je ankam, kam vom App-internen Minutentakt.** Bei geschlossener App gab es seit dem ersten Release keine einzige Medikamenten-Erinnerung. Und weil der `ScheduledNotificationBootReceiver` ebenfalls fehlte, verschwand nach jedem Neustart alles Geplante — `RECEIVE_BOOT_COMPLETED` stand im Manifest, nur horchte niemand darauf.

**Behoben** in `d80d524`: drei Empfänger deklariert. Gegenprobe auf demselben Gerät, App-Prozess tot:

```
13:27:00.391  Zustelltest - 1 Tablette take now
13:27:00.599  Beweis - 1 Tablette take now
enq=13:27:58.313  disp=13:27:58.314  fin=13:27:58.316
```

Auf die Millisekunde zum Alarmzeitpunkt, `disp` gesetzt, der Empfänger hat die App geweckt.

### 1.2 Ursache

Es gibt keinen berechneten Soll-Zustand. Was erinnert werden soll, wird an jeder Ereignisstelle einzeln und von Hand nachgezogen:

| Ereignis | Was passiert | Was fehlt |
|---|---|---|
| `MedicationCreatedEvent` | `scheduleMedicationReminders()` | — |
| `MedicationUpdatedEvent` | `scheduleMedicationReminders()` | — |
| `MedicationTakenEvent` | `cancelRepeatReminders()` | Vorwarnungen der erledigten Dosis |
| Snooze (Log mit `snoozedUntil`) | nichts über `MedicationTakenEvent` hinaus | Anmeldung beim OS, Abräumen der Vorwarnungen |
| Erlaubnis erteilt | `rescheduleMissingReminders()` | — |
| Tageswechsel ohne App-Start | nichts | alles |

Jeder neue Fall braucht eine neue handgeschriebene Abbruchzeile. Wird eine vergessen, bleibt ein Alarm als Karteileiche stehen. Befund 2, 3 und 4 sind genau das.

Dazu kommen drei Kopien derselben Wahrheit, die von Hand synchron gehalten werden:

1. **Hive** (`Medication`, `MedicationLog`) — was gelten soll
2. **`notificationQueue`-Box** — was geplant sein soll
3. **Alarmtabelle des Betriebssystems** — was tatsächlich geplant ist

`syncQueueWithPlatform()` trägt „sync" im Namen, vergleicht aber nur Warteschlange gegen Uhrzeit und markiert Vergangenes als `assumedShown`. Das Betriebssystem wird nie gefragt. Damit sind Befund 3 (Snooze nur in Kopie 2) und Befund 7 (zwei Zustellwege aus zwei Kopien) strukturell unvermeidbar.

---

## 2. Ziel

Erinnerungen, die aus dem Datenbestand **abgeleitet** werden statt nachgeführt. Nach jeder Änderung — Medikament, Log, Erlaubnis, Tageswechsel — gilt: was beim Betriebssystem angemeldet ist, entspricht genau dem, was die Regeln vorsehen. Nicht ungefähr, sondern als Mengengleichheit, die sich in einem Test prüfen lässt.

Die Fehlerklasse „jemand hat eine Abbruchzeile vergessen" soll nicht mehr existieren können, weil es keine Abbruchzeilen mehr gibt.

---

## 3. Entwurf

Ein neues Modul `lib/services/reminders/` mit drei Teilen und einer Richtung:

```
Hive: Medication, MedicationLog ─┐
Erlaubnis (bool)                 ├─► desiredReminders() ─► Set<Reminder>
Uhrzeit (injiziert)              ─┘                            │
                                                               ▼
        OS: pendingNotificationRequests() ──────────► reconcile() ──► schedule / cancel
```

### 3.1 `reminder_rules.dart` — die Regeln, an einem Ort

Eine pure Funktion. Kein Plugin, keine Uhr, kein Hive-Zugriff, keine Nebenwirkung:

```dart
Set<Reminder> desiredReminders({
  required List<Medication> medications,
  required List<MedicationLog> logs,
  required bool notificationsAllowed,
  required DateTime now,
  Duration horizon = const Duration(hours: 36),
  int budget = 56,
});
```

`Reminder` ist ein Wertobjekt:

```dart
class Reminder {
  final String medicationId;
  final DateTime fireAt;
  final ReminderKind kind;     // before30, before10, due, repeat, snooze, available
  final DateDose dose;         // (medicationId, date, scheduledTime) — siehe 3.3
  final int? repeatIndex;
  final bool daily;            // true ⇒ täglich wiederkehrend (siehe 3.5)
}
```

Die Regeln vollständig:

**R1 — Keine Erlaubnis, keine Planung.** `notificationsAllowed == false` ⇒ leere Menge. Kein Sonderpfad, kein stilles `return` mitten im Code. Die Oberfläche liest denselben Zustand und zeigt ihn an (§ 5.1).

**R2 — Tagesmedizin.** Für jedes aktive Medikament mit `type == daily`, `remindersEnabled == true` und Datum innerhalb `startDate`/`endDate`: für jede Zeit in `timesOfDay` und jeden Tag im Horizont eine Dosis. Je Dosis als Einzelmeldung (`daily: false`):

- `before30` bei Dosiszeit − 30 min
- `before10` bei Dosiszeit − 10 min
- `repeat` bei Dosiszeit + 10, + 20, + 30 min (drei Wiederholungen, harte Obergrenze)

Liegt ein Zeitpunkt in der Vergangenheit, entfällt er. Er wird nicht nachgeholt.

Die Erinnerung **zur** Dosiszeit (`due`) entsteht hier bewusst **nicht** als Einzelmeldung. Sie ist die Grundebene aus § 3.5: je `timesOfDay`-Zeit genau ein `Reminder` mit `daily: true`, dessen Ankertag die Regel setzt — der nächste Tag, an dem diese Dosis noch nicht erledigt ist. Damit gibt es keine zwei Meldungen für denselben Zeitpunkt.

**R3 — Eine erledigte Dosis erzeugt nichts mehr.** Existiert für eine Dosis ein Log mit `taken`, `refused` oder `skipped`, entfallen **alle** ihre Einzelmeldungen — Vorwarnungen und Wiederholungen. Die tägliche Grundmeldung dieser Zeit wird auf den nächsten unerledigten Tag verankert, also frühestens auf morgen. Das ist Befund 2 als Regel statt als Abbruchzeile.

**R4 — Aufschub verschiebt, statt zu stapeln.** Existiert für eine Dosis ein Log mit `snoozed`, entfallen alle ihre übrigen Erinnerungen und es entsteht genau eine vom Typ `snooze` bei:

```
snoozeUntil = tippzeitpunkt < dosiszeit
                ? dosiszeit
                : min(tippzeitpunkt + 30 min, nächste dosis desselben medikaments − 5 min)
```

Wer vor der Einnahmezeit „später" sagt, meint „nicht jetzt" — die Erinnerung rückt auf die Einnahmezeit, nicht dahinter. Wer danach „später" sagt, bekommt eine halbe Stunde Ruhe, aber nie über die nächste Dosis hinaus. Das erledigt Befund 3 und 4 in einer Regel.

**R5 — Eine Dosis gehört dem Körper, nicht dem Profil.** Der Dosisschlüssel ist `(medicationId, datum, scheduledTime)` — ohne Profil. Ein Log von Lina schließt die Dosis auch für Mina. Zwei Innen können nicht dieselbe Dosis zweimal nehmen, weil die Karte für beide erledigt ist. Wer den Status gesetzt hat, bleibt im Log (`profileId`) und in der Anzeige („Taken by Lina") sichtbar.

**R6 — Bedarfsmedizin.** Für `type == asNeeded` mit `minIntervalHours`: nach der letzten Einnahme entstehen Erinnerungen vom Typ `available` bei Freigabezeitpunkt − 30, − 10, − 5 min und zum Freigabezeitpunkt. Ist das Tageslimit `maxDailyDoses` erreicht, entsteht nichts. Damit gilt für Bedarfsmedizin dieselbe Ableitung wie für Tagesmedizin.

**R7 — Budget.** Übersteigt die Menge `budget` Einträge, werden die zeitlich fernsten verworfen. iOS lässt höchstens 64 vorgemerkte Meldungen zu; 56 lässt Luft für Kalendererinnerungen. Was verworfen wurde, wird protokolliert — eine stillschweigende Kürzung liest sich sonst wie Vollständigkeit.

### 3.2 `reminder_reconciler.dart` — der einzige Schreiber

```dart
Future<ReconcileResult> reconcile();
```

Ablauf:

1. Soll berechnen (`desiredReminders`)
2. Ist holen: `_plugin.pendingNotificationRequests()` — **das Betriebssystem, nicht die Warteschlangen-Box**
3. Ist auf die von Aurora vergebenen Medikamenten-IDs einschränken (§ 3.3)
4. `cancel()` für alles im Ist, das nicht im Soll ist
5. `zonedSchedule()` für alles im Soll, das nicht im Ist ist
6. Ergebnis protokollieren: angelegt, entfernt, unverändert, verworfen

Die Funktion ist idempotent: zweimal hintereinander aufgerufen ändert der zweite Lauf nichts. Das ist zugleich ein Test (§ 8).

**Nur diese Klasse ruft `zonedSchedule` und `cancel`.** Durchgesetzt wird das mit einer Lint-Regel in `dis_app_lints/` nach dem Muster von `prefer_data_entry_architecture`: `flutter_local_notifications` darf außerhalb von `lib/services/reminders/` nicht importiert werden. Damit ist die Einschreiberegel strukturell, nicht disziplinarisch.

### 3.3 `reminder_id.dart` — ableitbare Kennungen

Der Abgleich Ist/Soll braucht Kennungen, die sich aus dem Inhalt errechnen lassen, statt in einer Liste geführt zu werden:

```
id = hash("aurora.med|$medicationId|$isoDate|$scheduledTime|$kind|$repeatIndex") % 2^31
```

Der heutige `_generateNotificationId` kann das fast; ihm fehlt das Datum, weshalb die Erinnerung von heute und die von morgen dieselbe Kennung tragen. Zusätzlich wird ein Namensraum-Präfix eingeführt, damit Schritt 3 des Abgleichs Medikamenten-Meldungen von Kalender-Meldungen unterscheiden kann, ohne eine Zuordnungstabelle zu führen. Umsetzung: die oberen Bits der Kennung tragen den Namensraum (`0x1` = Medikament, `0x2` = Termin), die unteren den Hash.

Kollisionen: bei 31 nutzbaren Bits und maximal ~60 gleichzeitigen Einträgen liegt die Kollisionswahrscheinlichkeit unter 10⁻⁶. Ein Test prüft für einen erzeugten Bestand aus 500 Dosen, dass alle Kennungen verschieden sind.

### 3.4 Ein Zustellweg

Der App-interne `Timer.periodic` verschwindet als **Sendepfad**. Betriebssystem-Alarme feuern auch, während die App im Vordergrund läuft; ein zweiter Weg bringt keinen Gewinn und erzeugt die Doppelwahrheit aus Befund 7. Ein Takt darf bleiben, wenn die Oberfläche eine laufende Anzeige braucht („nächste Dosis in …"), aber er stellt nichts mehr zu.

Diese Entscheidung stand und fiel mit Befund 9. Solange die Empfänger fehlten, war der Takt der **einzige** Weg, auf dem je eine Erinnerung ankam — ihn zu streichen hätte aus „manchmal falsch" ein „nie" gemacht. Seit `d80d524` ist der Betriebssystem-Weg belegt: Meldung um 13:27:00.391 bei totem Prozess. Erst dadurch ist das Streichen des Takts überhaupt vertretbar, und es ist die Reihenfolge, in der umgesetzt wird — Empfänger zuerst, Takt zuletzt.

### 3.5 Horizont, Tageswechsel und der Fall „App wochenlang nicht geöffnet"

Ein Horizont von 36 Stunden deckt den Normalfall. Wer die App zwei Tage nicht öffnet, fällt heraus — und das ist genau der Mensch, der die Erinnerung am nötigsten braucht. Deshalb zweistufig:

**Genaue Ebene (36 Stunden).** `before30`, `before10` und die drei `repeat` werden als Einzelmeldungen für die nächsten 36 Stunden vorgemerkt. Fünf Vormerkungen je Dosis — deshalb der kurze Horizont.

**Tragende Ebene (sieben Tage).** Die Meldung zur Einnahmezeit selbst (`due`) reicht sieben Tage weit. Eine Vormerkung je Dosis, und sie ist die eine, die zählt.

Hier stand zuerst etwas anderes, und die Messung hat es widerlegt. Der Entwurf sah eine **täglich wiederkehrende** Grundmeldung vor — `zonedSchedule(..., matchDateTimeComponents: DateTimeComponents.time)` —, deren Ankertag die Regel setzt: ist die heutige Dosis erledigt, wird auf morgen verankert. Auf dem Gerät:

```
Vitamin D um 12:22 als genommen markiert
Regel setzt den Anker auf   08.08. 15:00
im Alarmspeicher steht      07.08. 15:00
```

Die Option ignoriert das übergebene Datum und schnappt auf die nächste passende Uhrzeit. „Heute überspringen" lässt sich damit nicht ausdrücken — R3 wäre ausgerechnet für die wichtigste Meldung ausgehebelt gewesen, und die App hätte an eine bereits genommene Dosis erinnert. Deshalb: keine Wiederkehr, sondern ein längerer Vorlauf.

**Die ehrliche Grenze.** Wer die App länger als sieben Tage nicht öffnet, bekommt danach keine Erinnerung mehr. Das ist eine Verschlechterung gegenüber der gedachten Grundebene und wird hier benannt statt versteckt. Jede Meldung, die ankommt, führt beim Antippen in die App und damit zu einem Abgleich, der das Fenster wieder auf sieben Tage schiebt — die Kette reißt also erst, wenn eine ganze Woche lang keine einzige Erinnerung beachtet wurde. Wer dort ankommt, hat ein Problem, das keine Vormerkung löst.

**Budget-Vorrang.** Übersteigt die Menge das Budget, fallen zuerst Vorwarnungen weg, nie die Meldungen zur Einnahmezeit. Eine Vorwarnung zu verlieren kostet Vorlauf, die Meldung selbst zu verlieren kostet die Dosis.

Ein Tippen auf die Grundmeldung öffnet die App, der Abgleich läuft, und die genaue Ebene ist wieder für 36 Stunden gefüllt. Die Erinnerungskette kann damit nicht mehr abreißen.

**Auslöser für `reconcile()`** — vollständig:

- `postInitialize()` beim App-Start
- `AppLifecycleState.resumed`
- `MedicationCreated/Updated/Deleted`
- `MedicationTaken/LogUpdated/LogDeleted`
- Wechsel der Benachrichtigungserlaubnis (beim Zurückkommen aus dem Systemdialog **und** bei jedem Resume, weil sie in den Systemeinstellungen entzogen werden kann)
- Umschalten der diskreten Erinnerungen (der Wortlaut steckt in der vorgemerkten Meldung)
- Datumswechsel bei laufender App und Zeitzonenwechsel

### 3.6 Die Warteschlangen-Box wird zum Protokoll

`notificationQueue` **entfällt.**

Zuerst stand hier, die Box werde vom Planungsspeicher zum Protokoll: sie halte künftig, was Aurora auf den Bildschirm gebracht hat, für die Ansicht „Was Aurora sendet".

Beim Umbau zeigte sich, dass das nicht trägt. Zustellt das Betriebssystem, während die App tot ist, läuft kein Dart-Code — es gibt keinen Rückruf, an dem sich „gezeigt" festmachen ließe. Ein Protokoll, das beim *Vormerken* schreibt, protokolliert nicht, was geschah, sondern was vorgesehen war. Das ist eine zweite Kopie mit einem Namen, der etwas anderes verspricht — genau die Sorte Zusage, gegen die dieser Umbau angeht.

Mit Stufe 3 schrieb niemand mehr in die Box, während vier Stellen sie noch lasen; `countUnscheduledPromises()` lieferte dadurch eine Lüge. Die Box wird bei der Migration von der Platte gelöscht. Wer wissen will, was vorgemerkt ist, fragt das Betriebssystem (`pendingOwnIds`) — und wer wissen will, was gezeigt *wurde*, kann es heute nicht wissen; das steht hier, statt eine Zahl zu erfinden.

---

## 4. Was verschwindet

| Heute | Künftig |
|---|---|
| `scheduleMedicationReminders()` | `reconcile()` |
| `cancelMedicationReminders()` | entfällt |
| `cancelRepeatReminders()` | entfällt |
| `_scheduleRepeatReminder()` | Regel R2 |
| `rescheduleMissingReminders()` | entfällt (Erlaubnis ist Eingabe) |
| `syncQueueWithPlatform()` | entfällt |
| `_startQueueTimer()` / `_checkQueueAndSend()` | entfällt als Sendepfad |
| `scheduleAvailabilityReminders()` / `_cancelAvailabilityReminders()` | Regel R6 |

Neun Methoden, die einander hinterherliefen, werden zu einer Funktion und einem Abgleich. `notification_service.dart` schrumpft von 1670 Zeilen auf schätzungsweise 700; die Regeln liegen in einer Datei, die man an einem Stück lesen kann.

---

## 5. Oberfläche

Die Architektur nimmt drei Befunde auf, die keine Planungsfehler sind, sondern Anzeigefehler.

### 5.1 Sichtbarkeit der Erlaubnis (Befund 1)

Fehlt die Erlaubnis und existiert mindestens ein aktives Medikament mit `remindersEnabled`, trägt der Medikamentenbereich ein Band: was nicht passiert, und ein Knopf, der zu den Systemeinstellungen führt. Kein Rot, keine Aufregung — die Farbregel aus `docs/oberflaechen-richtlinien.md` reserviert Sättigung für das, was im schlechtesten Zustand gefunden werden muss. Ein ruhiger, aber nicht übersehbarer Hinweis.

Zweiter Ort: dasselbe Band im Formular, direkt unter dem Schalter „Aurora erinnert dich", wenn der Schalter an ist und die Erlaubnis fehlt. Ein Schalter, der ein Versprechen gibt, das das Gerät nicht hält, muss das sagen.

### 5.2 Korrigierbarkeit (Befund 5)

Die Knopfreihe verschwindet nach einer Entscheidung nicht. Sie zeigt danach den gesetzten Status hervorgehoben und die anderen Möglichkeiten weiterhin erreichbar. Ein zweites Tippen ändert den Status und schreibt ein neues Log; die Historie bleibt vollständig, die Karte zeigt den jüngsten Stand. Rückgängigmachen darf nie teurer sein als Festlegen.

### 5.3 Ein Zeitformat (Befund 8)

Alle Zeiten in der Medikamentenansicht folgen dem Gebietsschema der Oberfläche — durchgehend, auch die Snooze-Anzeige. Die Überschriften des Zeitwählers werden übersetzt.

Die Profilzuordnung beim Anlegen (heute stillschweigend alle) wird angezeigt und änderbar. Voreinstellung bleibt „alle", weil ein Körper ein Körper ist — aber sichtbar.

---

## 6. Stufe 2: Handlungen an der Meldung (Befund 6)

Getrennte Stufe, gleiche Architektur.

Jede Medikamenten-Meldung bekommt zwei Knöpfe: **Genommen** und **Später**. Der Rückruf `onDidReceiveBackgroundNotificationResponse` ist bereits registriert (`notification_service.dart:328`), läuft aber in einem eigenen Isolate ohne den Dienstbaum der App.

Vorgehen dort: Hive im Hintergrund-Isolate öffnen, Log schreiben, `reconcile()` laufen lassen. Der Abgleich ist genau dafür geeignet — er braucht nur Boxen, Erlaubnis und Uhr, keinen laufenden `EventBus`. Was er nicht kann, ist die Oberfläche benachrichtigen; das erledigt der nächste Resume, weil die Karten ohnehin über `ValueListenable` an den Boxen hängen.

Risiken, die diese Stufe zu einer eigenen machen: Hive-Adapter müssen im Isolate registriert werden, gleichzeitige Schreibzugriffe aus beiden Isolates brauchen eine Betrachtung, und iOS behandelt Meldungs-Handlungen anders als Android. Deshalb: erst Stufe 1 fertig und auf dem Gerät bestätigt, dann Stufe 2.

---

## 7. Migration

Beim ersten Start der neuen Fassung:

1. `cancelAll()` — der alte Bestand trägt Kennungen ohne Datum und ohne Namensraum und lässt sich nicht sauber zuordnen. Karteileichen wie die zehn Alarme vom 05./06.08. verschwinden damit ebenfalls.
2. `reconcile()` für Medikamente.
3. `notificationQueue` von der Platte löschen.

Ein Merker in der `settings`-Box sorgt dafür, dass das genau einmal läuft. Er steht seit Stufe 3 auf `reminders_migrated_v3`: Geräte, die schon `v2` trugen, hätten sonst den alten Bestand mit datumslosen Termin-Kennungen behalten.

Das Nachplanen der Termine, das in Stufe 1 hier stand, entfällt — der Abgleich deckt sie seit Stufe 3 mit ab.

---

## 8. Tests

Die eigentliche Zusicherung. Jeder Befund aus § 1.1 wird ein Testfall gegen `desiredReminders` mit fester Uhr — reine Funktion, kein Gerät, keine Wartezeit.

| Test | Erwartung | Befund |
|---|---|---|
| Keine Erlaubnis | leere Menge | 1 |
| Dosis genommen | keine Einzelmeldung mehr für diese Dosis, auch keine Vorwarnung | 2 |
| Dosis genommen | die nächste `due`-Meldung ist die von morgen | 2 |
| Dosis offen | die nächste `due`-Meldung ist die von heute | 3.5 |
| Zwei Horizonte | Vorwarnungen decken zwei Tage, `due` mindestens sieben | 3.5 |
| Snooze vor Dosiszeit | genau eine Erinnerung, bei Dosiszeit | 3, 4 |
| Snooze nach Dosiszeit | genau eine Erinnerung, +30 min, nie über die nächste Dosis | 3, 4 |
| Snooze kurz vor der nächsten Dosis | Erinnerung wird auf `nächste − 5 min` begrenzt | 4 |
| Dosis von Profil A erledigt | für Profil B ebenfalls erledigt | R5 |
| Zwei Medikamente, gleiche Zeit | je eigene Kennungen, keine Kollision | 3.3 |
| Tageswechsel über Mitternacht | Dosen des Folgetags im Horizont, gestrige nicht | 1 |
| Sommerzeitumstellung | Dosiszeit bleibt Ortszeit, keine doppelte oder fehlende Dosis | — |
| Bedarfsmedizin, Limit erreicht | keine Freigabe-Erinnerung | R6 |
| Bedarfsmedizin, Mindestabstand | Freigabe-Erinnerungen −30/−10/−5/0 | R6 |
| Budgetüberschreitung | die fernsten fallen weg, Protokolleintrag entsteht | R7 |
| Medikament inaktiv / `remindersEnabled` aus / außerhalb `startDate`–`endDate` | leere Menge für dieses Medikament | — |
| 500 Dosen | alle Kennungen verschieden | 3.3 |

Dazu für den Abgleich, gegen ein Attrappen-Plugin:

- Zweimal `reconcile()` hintereinander: der zweite Lauf meldet nichts an und nichts ab
- Ist enthält einen fremden Namensraum: bleibt unangetastet
- Soll leer, Ist gefüllt: alles wird abgemeldet

Und ein Prüfprotokoll auf dem Gerät, weil eine Attrappe nicht beweist, dass Android zustellt: Medikament anlegen, App über „letzte Apps" schließen, Zustellung zur Dosiszeit prüfen; anschließend genommen setzen und prüfen, dass `dumpsys alarm` die Vorwarnungen nicht mehr führt.

---

## 9. Abgrenzung

Nicht enthalten:

- Kalendertermine im Abgleich (Stufe 3)
- Handlungen an der Meldung (Stufe 2, § 6)
- Änderungen an `DataEntry`, am `EventBus` oder an den Hive-Modellen `Medication`/`MedicationLog`
- Neue Felder im Datenbestand. `MedicationLog` trägt bereits alles, was die Regeln brauchen: `status`, `snoozedUntil`, `scheduledTime`, `takenAt`
- Datenschutz-relevante Änderungen. Es verlässt weiterhin nichts das Gerät; die Erinnerungstexte bleiben lokal, der Schalter für diskrete Erinnerungen bleibt unverändert wirksam

---

## 10. Reihenfolge

1. `reminder_rules.dart` mit vollständiger Testtabelle aus § 8 — testgetrieben, ohne Gerät
2. `reminder_id.dart` mit Namensraum und Kollisionstest
3. `reminder_reconciler.dart` gegen ein Attrappen-Plugin
4. Anbindung: Auslöser aus § 3.5, Abbau der neun Methoden aus § 4
5. Migration (§ 7)
6. Oberfläche (§ 5)
7. Lint-Regel `reminders_single_writer` in `dis_app_lints/`
8. Prüfprotokoll auf beiden Testgeräten
9. Stufe 2 (§ 6) als eigener Durchgang

Schritt 1 bis 3 sind reiner Dart-Code ohne Plattformbezug und lassen sich vollständig in der Testumgebung abschließen.

---

## 11. Offene Punkte

**Zustellung bei toter App — geklärt.** Sie funktionierte nicht, weil die Empfänger fehlten (Befund 9). Seit `d80d524` funktioniert sie: belegt am 07.08.2026, 13:27:00.391, Prozess tot. § 3.4 bleibt damit wie beschrieben.

Offen bleibt eine Stufe darunter: das Testgerät hing am USB und lud, also griff kein Doze. Ob die Zustellung auch im Tiefschlaf und unter Samsungs „nicht genutzte Apps schlafen legen" trägt, gehört ins Prüfprotokoll — und falls nicht, braucht es einen Hinweis an den Menschen, Aurora von der Akkuoptimierung auszunehmen. Kein Blocker für die Umsetzung, aber vor dem Release zu messen.

**Snooze-Dauer.** 30 Minuten sind gesetzt, weil eine Stunde bei einem Vier-Stunden-Rhythmus zu lang ist. Ob das die richtige Zahl ist oder ob sie pro Medikament einstellbar sein sollte, ist eine Frage an die Betroffenen, nicht an den Code.

**Drei Wiederholungen.** Heute ist die Wiederholung unbegrenzt („alle 10 Minuten, bis markiert"). Unbegrenzt heißt: wer schläft, findet morgens vierzig Meldungen. Drei ist ein Vorschlag, keine Erkenntnis.
