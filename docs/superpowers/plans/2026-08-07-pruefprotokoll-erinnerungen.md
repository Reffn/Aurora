# Prüfprotokoll: Medikamenten-Erinnerungen auf dem Gerät

**Datum:** 2026-08-07
**Gerät:** Galaxy S24 (`R3CX10FH1RP`), Android 16, One UI, Debug-Build, am USB
**Paket:** `com.disapp.dis_app`, Profil „Lina" (Seed-Daten), Oberfläche Englisch
**Spec:** `docs/superpowers/specs/2026-08-07-medikamenten-erinnerungen-reconciler-design.md`

Alle Zeiten sind Gerätezeit. Nichts Auswärtsgerichtetes wurde ausgelöst: kein Anruf, keine Übertragung, keine Einwilligung umgeschaltet.

---

## 1. Ausgangslage, vor jeder Änderung

| Beobachtung | Wert |
|---|---|
| `POST_NOTIFICATIONS` | `granted=false` |
| `USE_EXACT_ALARM` | `granted=true` |
| Medikamente | 1 (Vitamin D, 15:00), Erinnerungen an |
| Alarme für den laufenden Tag | **0** |
| Alarme insgesamt | 10, sämtlich vom 05. und 06.08. |
| Hinweis in der Oberfläche | keiner; Weckersymbol an Karte und Kopfzeile |

Protokoll: `NotificationService: Nothing rescheduled — still no permission`.

**Befund 1 bestätigt.**

---

## 2. Zustellung ohne Empfänger

Vier Durchläufe mit nachweislich totem Prozess (`pidof` leer), Paket nicht gestoppt, Standby-Eimer 10.

```
enq=12:20:00.010  disp=1970-01-01
enq=12:40:00.008  disp=1970-01-01
enq=12:50:00.013  disp=1970-01-01
enq=13:13:00.012  disp=1970-01-01  fin=13:13:00.012
```

Alarm gefeuert, Broadcast eingereiht, in derselben Millisekunde beendet, **nie zugestellt**. Die Meldungen, die trotzdem erschienen, trugen die Zeitstempel des App-internen Minutentakts (12:20:**17**, 12:40:**31**).

**Befund 9 bestätigt.** Ursache: keine Broadcast-Empfänger im Manifest.

---

## 3. Nach dem Empfänger-Fix (`d80d524`)

Medikament „Beweis" auf 13:27 angelegt, App über „letzte Apps" geschlossen, Prozess verifiziert tot, Alarm verifiziert anstehend.

```
13:27:00.391  Zustelltest - 1 Tablette take now
13:27:00.599  Beweis - 1 Tablette take now
enq=13:27:58.313  disp=13:27:58.314  fin=13:27:58.316
```

Zweite unabhängige Bestätigung um 13:57:00.048 (dritte Wiederholung, ebenfalls alarmgetrieben).

**Zustellung bei geschlossener App: funktioniert.**

---

## 4. Nach dem Umbau auf den Abgleich

### 4.1 „Genommen" räumt ab (Befund 2)

Vitamin D war um 12:22 als genommen markiert. Vor dem Umbau standen 14:30, 14:50 und 15:00 unverändert im Alarmspeicher; um 14:30 wäre eine Erinnerung an eine erledigte Dosis gekommen.

Nach der Migration: **keine Alarme mehr für den 07.08.** Um 14:30 kam nichts.

### 4.2 Kein Anker-Artefakt mehr (Spec § 3.5)

Mit der täglich wiederkehrenden Grundmeldung stand trotz erledigter Dosis `07.08 15:00` im Speicher — `matchDateTimeComponents` schnappt auf die nächste passende Uhrzeit und ignoriert das Datum. Nach `5c832fb`: Eintrag verschwunden.

### 4.3 Endzustand

Bestand: nur Vitamin D, 15:00, heutige Dosis erledigt. Zwölf Alarme:

```
08.08  14:30  14:50  15:00  15:10  15:20  15:30     kurzer Horizont
09.08  15:00
10.08  15:00
11.08  15:00
12.08  15:00
13.08  15:00
14.08  15:00                                        tragende Ebene, sieben Tage
```

Zwei Vorwarnungen, eine Meldung zur Einnahmezeit, drei begrenzte Wiederholungen — und für die Folgetage je eine Meldung. Genau die Sollmenge aus `desiredReminders()`.

### 4.4 Löschen wirkt sofort

Löschen von „Testmed" ließ die Alarmzahl von 28 auf 23 fallen, ohne dass irgendwo eine Abbruchzeile steht. Nach allen drei Testeinträgen: 12.

---

## 5. Oberfläche

| Prüfung | Ergebnis |
|---|---|
| Knopfreihe nach „Später" (Befund 5) | alle drei Knöpfe erreichbar, „Später" gefüllt, andere Umriss |
| Zeitformat auf der Karte (Befund 8) | `13:21`, nicht mehr `1:21 PM` |
| Erlaubnisband (Befund 1) | live geprüft, siehe § 5.1 |
| Zeitwähler-Überschriften (Befund 8) | aus den Sprachdateien |

### 5.1 Erlaubnisband unter echten Bedingungen

`pm revoke android.permission.POST_NOTIFICATIONS`, App geöffnet, Medizinbereich aufgerufen:

- Band erscheint über der Tagesübersicht: „Aurora is not allowed to remind you right now"
- nennt die Zahl der versprochenen Einnahmezeiten
- „Grant permission" öffnet den Systemdialog
- nach „Allow": Band verschwindet, **zwölf Alarme sofort wieder da**

Dabei zwei Fehler gefunden und behoben (`f44fc89`): der Zähler las die
Warteschlange, die der Abgleich nicht mehr füllt, und der Text stand ohne
Plural da („for 1 intake times").

---

## 6. Zweites Gerät: Galaxy A14

**Gerät:** SM-A145F (`RF8W90CT0NN`), Android 15, 1080×2408, Debug-Build, am USB
**Profil:** „Prueba", Oberfläche Deutsch — prüft damit zugleich die deutschen Zeichenketten.

| Prüfung | Ergebnis |
|---|---|
| Empfänger im Paket | vorhanden |
| `POST_NOTIFICATIONS` / `USE_EXACT_ALARM` | beide erteilt |
| Bestand vor dem Test | keine Medikamente, **kein Erlaubnisband** — korrekt, es gibt kein offenes Versprechen |
| Zeitwähler | „Zeit wählen / Stunden : Minuten", keine Tastatur im Hintergrund |
| Knopfreihe ohne Status | alle drei sichtbar, „Genommen" gefüllt |

Medikament „A14Test" auf 15:07 angelegt (Anlage um 15:07:46, die Dosiszeit war damit knapp vorbei). Geplant wurde:

```
07.08  15:17  15:27  15:37                          nur die Wiederholungen
08.08  14:37  14:57  15:07  15:17  15:27  15:37     voller Satz
09.–14.08  15:07 je Tag                             tragende Ebene
```

Genau die Sollmenge: für die vergangene Dosiszeit keine Vorwarnung mehr, für morgen alles, danach je eine Meldung.

**Zustellung bei totem Prozess.** App über „letzte Apps" geschlossen, Prozess mit `am kill` verifiziert beendet, Alarm verifiziert anstehend:

```
15:17:01.565  A14Test - 1 Tablette jetzt einnehmen - Noch nicht eingenommen!
enq=15:17:44.543  disp=15:17:44.544  fin=15:17:44.546
```

1,5 Sekunden nach dem Alarmzeitpunkt, der Empfänger hat die App geweckt.

**Aufräumen.** „A14Test" gelöscht, danach **null** Alarme für das Paket. Der Abgleich räumt vollständig ab, ohne dass irgendwo eine Abbruchzeile steht.

---

## 7. Termine, Ist-Zustand vor Stufe 3

Erhoben am 07.08.2026 auf dem S24, Ausgangslage zwölf Alarme (nur Vitamin D).

**Gemessen:**

| Prüfung | Ergebnis |
|---|---|
| Termin anlegen | funktioniert, protokolliert: `createCalendarEvent`, `NotificationService: Event created` |
| Erinnerungszeit liegt in der Vergangenheit | **kein Alarm**, und der Dienst sagt es: `NotificationService: Event reminder time has passed`. Alarmzahl blieb bei 12 — korrekt |
| Voreinstellung im Formular | „Remind me" ist **an**, 30 Minuten vorgewählt. Der alte Fehler (`notificationEnabled` nie gesetzt) ist behoben |
| Startzeit-Voreinstellung | 15:00 des laufenden Tages — bei einem Aufruf um 15:50 also Vergangenheit, und damit jede Erinnerung ebenfalls |
| Profilzuordnung | das Terminformular **fragt** („Which profiles this belongs to"), das Medikamentenformular nicht |

**Nicht gemessen, und warum:** Ein Termin mit Erinnerungszeit in der Zukunft, und der Verschiebefall. Das Fahren der Oberfläche über `adb` wurde unzuverlässig — die App meldet sich zwischen den Schritten ab, und Taps auf den Speichern-Knopf wurden nach dem Scrollen verschluckt. Nach mehreren Anläufen landete ein blinder Tap auf dem Profilbildschirm mit Passwortfeldern; an dieser Stelle wurde abgebrochen. Beide Fälle deckt der Endzustandstest (§ 8 des Plans), wo der Abgleich seine Differenz ohnehin protokolliert.

**Aus dem Quelltext, nicht gemessen:** Die Termin-Kennung lautet
`namespacedId(kNamespaceEvent, '$eventId|event_reminder')` — **ohne Datum**.
Beim Verschieben tragen alte und neue Zeit dieselbe Zahl; das Schedule
überschreibt das Cancel. Es wirkt richtig, weil das Ergebnis stimmt, nicht
weil der Weg stimmt.

**Offen auf dem Gerät:** ein Testtermin „Logtest" (07.08., 15:00) steht noch im Kalender und gehört gelöscht.

---

## 8. Termine im Abgleich, Endzustand

Nach Stufe 3, gemessen am 07.08.2026 auf dem S24.

**Kennungswechsel.** Der Abgleich hat die geänderte Kennungsbildung selbst
bemerkt und sauber getauscht:

```
ReminderReconciler: abgeglichen {added: 13, removed: 13, kept: 0}
```

Dreizehn abgemeldet, dreizehn angemeldet, inhaltlich derselbe Bestand.
Niemand musste die Migration von Hand nachziehen.

**Termin mit Erinnerung.** „Endtest" auf 20:00, Vorlauf 15 Minuten:

```
ReminderReconciler: abgeglichen {added: 1, removed: 0, kept: 12}
Alarm: 07.08 19:45
```

**Termin gelöscht.**

```
ReminderReconciler: abgeglichen {added: 0, removed: 1, kept: 12}
```

Genau die eine Vormerkung weg, die zwölf Medikamenten-Alarme unberührt.

**Endzustand:** dreizehn Alarme in zwei Namensräumen aus einer Regelmenge —
einer für den Termin, sechs für die nächsten 36 Stunden Medikament, sechs
für die Folgetage.

### 8.1 Zwei Fehler, die dieser Durchlauf gefunden hat

**Die Feuerzeit fehlte in der Kennung.** Ändert sich nur der Vorlauf eines
Termins von 30 auf 15 Minuten, bleiben Ziel, Art und Wiederholung gleich —
der Abgleich sah keine Differenz und ließ die Meldung auf der alten Zeit
stehen. Dasselbe galt für den zweiten Aufschub eines Medikaments: wer
zweimal „später" tippt, blieb bei der ersten Zeit. Beides seit `d96093f`
behoben und als Test festgehalten.

**Und einer, der keiner war.** Mehrere Speicherversuche blieben wirkungslos,
bis sich zeigte: `_saveEvent` prüft `endDateTime.isBefore(startDateTime)` und
bricht mit einer Meldung ab. Ich hatte den Start verschoben und das Ende
stehen lassen. Die App hatte recht; die Meldung war nach meinen Wartezeiten
nur schon wieder verschwunden.

---

## 9. Offen

- **Akkusparen.** Das Testgerät hing am USB und lud, also griff kein Doze. Ob die Zustellung im Tiefschlaf und unter Samsungs „nicht genutzte Apps schlafen legen" trägt, ist ungeprüft. Falls nicht, braucht es einen Hinweis an den Menschen, Aurora von der Akkuoptimierung auszunehmen.
- **Neustart.** Der `ScheduledNotificationBootReceiver` ist deklariert, aber ein Neustart wurde nicht durchgeführt.
- **Nebenbefund.** Der Detailbildschirm zeigt „Kommentare (0)" auf Deutsch in englischer Oberfläche — dieselbe Klasse wie Befund 8, nicht Teil dieses Umbaus.
