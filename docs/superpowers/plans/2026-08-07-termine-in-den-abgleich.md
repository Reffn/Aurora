# Stufe 3: Termine in denselben Abgleich

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Kalendertermine laufen über dieselbe Regelfunktion und denselben Abgleich wie Medikamente. Danach gibt es genau eine Stelle, die Erinnerungen anmeldet, und keine Ausnahme mehr.

**Architektur:** `desiredReminders()` bekommt `events` als zweiten Eingang und liefert weiterhin **eine** Menge. Der Abgleich verwaltet beide Namensräume. Die Trennung liegt in den Regeln — rein und testbar —, nicht in der Maschinerie.

**Spec:** `docs/superpowers/specs/2026-08-07-medikamenten-erinnerungen-reconciler-design.md`, § 7 (Stufe 3). Diese Datei ist der Plan dazu, keine neue Spec.

**Umfang:** etwa ein Drittel des Medizin-Umbaus. Wertobjekte, Kennungen, Scheduler, Texte und Abgleich stehen bereits.

---

## Ausgangslage

Erhoben am 07.08.2026:

| Befund | Beleg |
|---|---|
| `CalendarEvent` kennt **keine Serien** | kein Wiederholungsfeld im Modell |
| Genau **eine** Erinnerung je Termin | `reminderMinutesBefore` (15 / 30 / 60 / 120 / 1440) |
| Keine dritte Erinnerungsquelle in der App | Timer-Treffer sonst nur Aufnahme, Kachel-Cache, Standortverfolgung |
| Termine liefen über denselben toten Pfad | `scheduleEventReminder` → `_scheduleViaPlatform`; vor `d80d524` kam auch hier bei geschlossener App nichts an |
| Drei handgeführte Stellen | `_onEventCreated`, `_onEventUpdated`, `_onEventDeleted` |
| Termin-Kennung ohne Datum | `namespacedId(kNamespaceEvent, '$eventId|event_reminder')` |

Dazu ein Muster, das sich wiederholt: laut Kommentar in `event_form_screen.dart:43-48` konnten Modell, Dienst und Detailansicht die Terminerinnerung von Anfang an — nur das Formular setzte `notificationEnabled` nie. Vorhanden und unerreichbar, dieselbe Klasse wie Befund 1.

---

## Die eine Designfrage

`Reminder.dose` ist heute ein `DoseKey` — Medikament, Datum, Uhrzeit. Für Termine passt das nicht.

**Entscheidung: sealed class.** Dart 3 ist im Projekt in Gebrauch.

```dart
sealed class ReminderTarget {
  DateTime get at;
  String get seed;      // geht in die Kennung
  int get namespace;    // kNamespaceMedication | kNamespaceEvent
}

final class DoseTarget extends ReminderTarget { ... }   // heutiger DoseKey
final class EventTarget extends ReminderTarget {
  final String eventId;
  final DateTime startTime;                              // im Seed, siehe unten
}
```

Warum `startTime` in den Seed gehört: heute trägt die Termin-Kennung kein Datum. Wird ein Termin verschoben, machen `cancel` und `schedule` dieselbe Zahl — das Schedule überschreibt das Cancel, und es *wirkt* richtig, obwohl der Mechanismus falsch ist. Mit `startTime` im Seed ergibt ein verschobener Termin eine neue Kennung, und der Abgleich räumt die alte als Karteileiche ab. Das ist der ehrliche Weg, und er ist erst durch den Abgleich überhaupt möglich.

Die Umbenennung `DoseKey` → `DoseTarget` berührt die bestehenden Tests. Sie ist mechanisch, aber sie ist der einzige Teil mit Designrisiko — deshalb Task 2 allein.

---

### Task 1: Ist-Zustand messen, bevor Code entsteht

Der Medizin-Umbau hat zweimal erlebt, dass eine Plugin-Annahme an der Wirklichkeit scheitert (`matchDateTimeComponents`, fehlende Empfänger). Deshalb steht die Messung vorn, nicht hinten.

- [ ] **Schritt 1: Termin anlegen** mit Erinnerung 15 Minuten vorher, Startzeit etwa eine Stunde in der Zukunft.
- [ ] **Schritt 2: Alarme festhalten**

```bash
adb -s <ID> shell dumpsys alarm | sed -n '1,1200p' | grep -A1 "com.disapp.dis_app}" \
  | grep -o "origWhen [0-9]*" | sort -u | awk '{print strftime("%d.%m %H:%M", $2/1000)}'
```

- [ ] **Schritt 3: Termin um zwei Stunden verschieben**, Alarme erneut festhalten. Erwartung nach heutigem Stand: die Zahl bleibt gleich, weil dieselbe Kennung überschrieben wird. **Genau das ist der Punkt, den der Umbau ändert.**
- [ ] **Schritt 4: Erinnerung abschalten**, Alarme festhalten.
- [ ] **Schritt 5: Termin löschen**, Alarme festhalten.
- [ ] **Schritt 6: Ergebnisse** in `docs/superpowers/plans/2026-08-07-pruefprotokoll-erinnerungen.md` als neuen Abschnitt „Termine, Ist-Zustand" eintragen und committen.

---

### Task 2: `ReminderTarget` als sealed class

**Files:** `lib/services/reminders/reminder.dart`, `reminder_id.dart`; alle Tests unter `test/services/reminders/`

- [ ] Sealed class einführen, `DoseKey` zu `DoseTarget` machen, `EventTarget` ergänzen.
- [ ] `reminderId()` liest `target.namespace` und `target.seed` — die Fallunterscheidung verschwindet aus der Kennungsfunktion.
- [ ] Kollisionstest erweitern: 500 Dosen **und** 500 Termine, alle Kennungen verschieden, kein Termin im Medikamenten-Namensraum.
- [ ] Test: derselbe Termin zu zwei Startzeiten ergibt zwei Kennungen.
- [ ] `flutter test test/services/reminders/` grün, dann committen.

---

### Task 3: Regeln für Termine

**Files:** `lib/services/reminders/reminder_rules.dart`, neu `test/services/reminders/reminder_rules_events_test.dart`

Signatur wird zu:

```dart
Set<Reminder> desiredReminders({
  required List<Medication> medications,
  required List<MedicationLog> logs,
  required List<CalendarEvent> events,
  ...
});
```

Regel, vollständig: für jeden Termin mit `notificationEnabled`, gesetztem `reminderMinutesBefore` und `startTime.isAfter(now)` entsteht **genau eine** Erinnerung bei `startTime - reminderMinutesBefore`. Liegt dieser Zeitpunkt in der Vergangenheit, entsteht keine — der Termin selbst ist dann noch nicht vorbei, die Vorwarnzeit aber schon.

- [ ] **Kein Sieben-Tage-Horizont für Termine.** Sie sind Einzeltermine, `dueHorizon` gilt für sie nicht. Ein Termin in drei Wochen bekommt seine Erinnerung sofort vorgemerkt.
- [ ] **Budget-Vorrang:** Termine kommen **nach** den Medikamenten-`due`, **vor** den Vorwarnungen. Ein Arzttermin schlägt eine 30-Minuten-Vorwarnung.
- [ ] Testfälle: Erinnerung aus, `reminderMinutesBefore` null, Termin in der Vergangenheit, Vorwarnzeit in der Vergangenheit bei künftigem Termin, 1440 Minuten (ein Tag vorher), Termin genau jetzt.
- [ ] Test: die Funktion bleibt rein — kein `DateTime.now()` im Modul.

---

### Task 4: Abgleich und Verdrahtung

**Files:** `reminder_reconciler.dart`, `reminder_texts.dart`, `lib/core/di/injection.dart`

- [ ] `pendingMedicationIds()` → `pendingOwnIds()`: beide Namensräume.
- [ ] `readEvents` als Parameter, in der DI aus `getIt<CalendarService>()`.
- [ ] `ReminderTexts` bekommt den Termin-Fall (`notificationEventReminder`, `notificationEventBody` — beide Schlüssel existieren bereits).
- [ ] Test: ein Termin und ein Medikament nebeneinander, beide werden angemeldet; Termin gelöscht, nur seine Kennung wird abgemeldet.
- [ ] Test: Idempotenz mit gemischtem Bestand.

---

### Task 5: Abbau

**Files:** `lib/services/notification_service.dart`

- [ ] `scheduleEventReminder`, `cancelEventReminders`, `_onEventCreated`, `_onEventUpdated`, `_onEventDeleted` entfernen; die drei Ereignisse auf `_reconcileOnEvent` legen.
- [ ] Schritt 3 in `migrateRemindersOnce` (Termine nachplanen) **entfällt ersatzlos** — der Abgleich deckt es.
- [ ] **Merker auf `reminders_migrated_v3` heben.** Auf beiden Testgeräten steht `v2` bereits; ohne neuen Merker bleibt der alte Bestand mit datumslosen Termin-Kennungen liegen. Hier schneidet man sich, wenn man es übersieht.
- [ ] Warteschlangen-Box: Termin-Einträge bleiben seit dem Wegfall von `syncQueueWithPlatform()` für immer auf `scheduled` stehen. Mit diesem Task wird die Box auch für Termine reines Protokoll; die Migration leert sie einmal.

---

### Task 6: Die letzte Lint-Ausnahme streichen

**Files:** `dis_app_lints/lib/src/no_direct_notification_plugin.dart`, `notification_service.dart`

- [ ] `sendTestNotification()` auf `ReminderScheduler.showNow()` umstellen — die Methode existiert bereits.
- [ ] Import von `flutter_local_notifications` aus `notification_service.dart` entfernen.
- [ ] Ausnahme in der Lint-Regel löschen. Danach gilt sie ohne Sonderfall.
- [ ] Prüfen, ob der Dienst überhaupt noch alle vier Hive-Boxen braucht.
- [ ] `dart run custom_lint` sauber.

---

### Task 7: Endzustand messen

- [ ] Dieselben fünf Schritte wie Task 1, auf demselben Gerät.
- [ ] Erwartung beim Verschieben: die alte Kennung verschwindet, eine neue entsteht — sichtbar als andere `origWhen`-Zeile, nicht als gleichbleibende Zahl.
- [ ] **Neustart-Test**, jetzt für beide Namensräume auf einmal: Gerät neu starten, danach `dumpsys alarm` — Medikamenten- und Termin-Alarme müssen wieder stehen. Das ist der letzte offene Punkt aus dem Medizin-Umbau; hier erledigt ihn ein Handgriff für beides.
- [ ] Ergebnisse ins Prüfprotokoll, committen.

---

## Nicht in diesem Plan

- **Handlungen an der Meldung** (Stufe 2 der Spec) — eigener Durchgang, eigene Hive-Fragen im Hintergrund-Isolate.
- **Serientermine.** `CalendarEvent` kennt sie nicht. Die Kennung mit `startTime` bereitet sie vor; die Regel dafür entsteht, wenn es das Feld gibt.
- **Akkusparen und Doze.** Gehört ins Prüfprotokoll, nicht in den Umbau.

## Randbedingungen

- Eine zweite Sitzung arbeitet im selben Arbeitsverzeichnis und hat am 07.08. mitten im Lauf Dateien gelöscht. Builds und die volle Testsuite können brechen, ohne dass es an diesem Umbau liegt. Commits klein halten, nach jedem Task `flutter analyze` auf die eigenen Pfade.
- Der Zweig `medizin-erinnerungen-reconciler` ist noch nicht in `main`. Reihenfolge von Merge und Release entscheidet der Mensch — der Ablehnungs-Fix für Play und der Empfänger-Fix müssen gemeinsam in 3.0.16.
