# Medikamenten-Erinnerungen: Reconciler — Umsetzungsplan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Medikamenten-Erinnerungen werden aus dem Datenbestand berechnet und mit dem Betriebssystem abgeglichen, statt an jeder Ereignisstelle von Hand nachgeführt zu werden.

**Architecture:** Eine reine Funktion `desiredReminders()` erzeugt aus Medikamenten, Logs, Erlaubnis und Uhrzeit die Sollmenge. Ein `ReminderReconciler` holt den Ist-Zustand über `pendingNotificationRequests()` vom Betriebssystem, bildet die Differenz und meldet nur diese an bzw. ab. Jedes Ereignis ruft nur noch `reconcile()`. Neun handgeführte Planungs- und Abbruchmethoden entfallen.

**Tech Stack:** Dart/Flutter, `hive_ce ^2.8.0`, `flutter_local_notifications ^17.0.0`, `timezone ^0.9.4`, `get_it ^8.0.2`, `rxdart ^0.28.0`, `flutter_test`, `custom_lint` über `dis_app_lints/`.

**Spec:** `docs/superpowers/specs/2026-08-07-medikamenten-erinnerungen-reconciler-design.md`

## Global Constraints

- **Keine neuen Abhängigkeiten.** Stufe 1 kommt mit dem aus, was in `pubspec.yaml` steht.
- **Kommentare auf Deutsch**, im Ton des Bestands: sie erklären *warum*, nicht *was*. Englische Bezeichner, deutsche Prosa.
- **`logger` hat keinen `error:`-Parameter.** Ausnahmen gehen über `data: {'error': e.toString()}` und `stackTrace:`. Kategorien: `LogCategory.service`, `LogCategory.ui`, `LogCategory.dataEntry`, `LogCategory.storage`, `LogCategory.network`.
- **Kein `DateTime.now()` in `lib/services/reminders/reminder_rules.dart`.** Die Uhr ist immer Parameter. Ein Test dazu ist Teil von Task 9.
- **Zeichenketten mit `runes`**, nie mit `[0]` — Emoji in Medikamentennamen sind erlaubt.
- **Alle Schreibvorgänge auf Daten laufen weiter über `DataEntry`.** Dieser Plan ändert daran nichts; er ändert nur, wer beim Betriebssystem Meldungen anmeldet.
- **Datenschutz:** Es verlässt nichts das Gerät. Erinnerungstexte bleiben lokal. Der Schalter für diskrete Erinnerungen (`NotificationService.discreetReminders`) bleibt wirksam und wird in Task 11 übernommen.
- **Tests laufen mit `flutter test`.** Hive-Tests nutzen `test/helpers/temp_hive.dart` und registrieren Adapter einzeln mit echtem Typ (siehe `test/services/notification_reschedule_test.dart`).
- **Nach Modelländerungen:** `dart run build_runner build --delete-conflicting-outputs`. Dieser Plan ändert keine Hive-Modelle, der Schritt entfällt.
- **Lint:** `dart run custom_lint` muss vor jedem Commit sauber durchlaufen.
- **Branch:** `medizin-erinnerungen-reconciler` (existiert bereits, enthält den Spec-Commit `959f5fa`).

---

## Bereits erledigt

**Task 0 — Empfänger deklarieren** (`d80d524`, vor Beginn dieses Plans).

`android/app/src/main/AndroidManifest.xml` enthielt keinen einzigen Broadcast-Empfänger; `flutter_local_notifications` bringt seine eigenen nicht mit. Jeder Alarm feuerte gegen ein Bauteil, das nicht existiert (`disp=1970-01-01`). Damit kam bei geschlossener App nie eine Erinnerung an, und nach jedem Neustart war alles Geplante weg.

Drei Empfänger ergänzt: `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` (mit `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `QUICKBOOT_POWERON`), `ActionBroadcastReceiver`. Gegenprobe auf dem Galaxy S24 bei totem Prozess: Meldung um 13:27:00.391, `disp` gesetzt.

**Das ist die Voraussetzung für Task 13.** Ohne diesen Fix wäre das Entfernen des App-internen Minutentakts der Weg von „manchmal falsch" zu „nie".

---

## Dateistruktur

**Neu — `lib/services/reminders/`:**

| Datei | Verantwortung |
|---|---|
| `reminder.dart` | Wertobjekte `Reminder`, `ReminderKind`, `DoseKey`. Keine Logik außer Gleichheit. |
| `reminder_id.dart` | Ableitbare Kennungen mit Namensraum. Reine Funktionen. |
| `reminder_rules.dart` | `desiredReminders()`. Die einzige Stelle mit Regeln. Keine Plugins, keine Uhr, kein Hive. |
| `reminder_scheduler.dart` | Schnittstelle `ReminderScheduler` + `PluginReminderScheduler`. Der einzige Ort, an dem `flutter_local_notifications` importiert wird. |
| `reminder_texts.dart` | Titel und Text je `Reminder`, inklusive diskreter Fassung. |
| `reminder_reconciler.dart` | `reconcile()`. Soll gegen Ist, Differenz anwenden. |

**Geändert:**

| Datei | Änderung |
|---|---|
| `lib/services/notification_service.dart` | Neun Methoden entfernt, Ereignisbehandlung ruft `reconcile()`. Kalender-IDs bekommen Namensraum 2. |
| `lib/core/di/injection.dart` | `ReminderReconciler` registrieren. |
| `lib/main.dart:1274` | `didChangeAppLifecycleState` löst `reconcile()` aus. |
| `lib/modules/medication/medication_screen.dart` | Erlaubnisband. |
| `lib/modules/medication/widgets/medication_card.dart` | Knopfreihe bleibt nach der Entscheidung sichtbar. |
| `lib/modules/medication/medication_form_screen.dart` | Erlaubnisband unter dem Schalter, sichtbare Profilzuordnung. |
| `lib/modules/medication/widgets/intake_times_picker.dart` | Überschriften des Zeitwählers übersetzt. |
| `lib/l10n/app_*.arb` | Neue Schlüssel. |
| `dis_app_lints/lib/src/no_direct_notification_plugin.dart` | Neue Lint-Regel. |
| `dis_app_lints/lib/dis_app_lints.dart` | Regel registrieren. |

**Tests — neu:**

`test/services/reminders/reminder_id_test.dart`, `reminder_rules_permission_test.dart`, `reminder_rules_daily_test.dart`, `reminder_rules_settled_test.dart`, `reminder_rules_snooze_test.dart`, `reminder_rules_dose_key_test.dart`, `reminder_rules_as_needed_test.dart`, `reminder_rules_budget_test.dart`, `reminder_reconciler_test.dart`, `test/helpers/fake_reminder_scheduler.dart`.

---

### Task 1: Wertobjekte

**Files:**
- Create: `lib/services/reminders/reminder.dart`
- Test: `test/services/reminders/reminder_test.dart`

**Interfaces:**
- Consumes: nichts
- Produces: `enum ReminderKind { before30, before10, due, repeat, snooze, available }`; `class DoseKey { String medicationId; DateTime date; String scheduledTime; }` mit `DateTime get at`; `class Reminder { DoseKey dose; ReminderKind kind; DateTime fireAt; int? repeatIndex; bool daily; }`

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_test.dart
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DoseKey ist über Medikament, Tag und Uhrzeit gleich', () {
    const a = DoseKey(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '12:50',
    );
    const b = DoseKey(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '12:50',
    );
    expect(a, b);
    expect(<DoseKey>{a, b}.length, 1);
  });

  test('DoseKey.at setzt Datum und Uhrzeit zusammen', () {
    const dose = DoseKey(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '08:05',
    );
    expect(dose.at, DateTime(2026, 8, 7, 8, 5));
  });

  test('Zwei Reminder derselben Dosis und Art sind gleich', () {
    const dose = DoseKey(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '12:50',
    );
    final a = Reminder(
      dose: dose,
      kind: ReminderKind.before10,
      fireAt: DateTime(2026, 8, 7, 12, 40),
    );
    final b = Reminder(
      dose: dose,
      kind: ReminderKind.before10,
      fireAt: DateTime(2026, 8, 7, 12, 40),
    );
    expect(<Reminder>{a, b}.length, 1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:dis_app/services/reminders/reminder.dart'`

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/services/reminders/reminder.dart
import 'package:flutter/foundation.dart';

/// Welche Art von Erinnerung.
///
/// [ReminderKind.due] wird als einzige täglich wiederkehrend vorgemerkt —
/// sie ist die Grundebene, die auch dann trägt, wenn die App wochenlang
/// nicht geöffnet wird. Alles andere ist eine Einzelmeldung im Horizont.
enum ReminderKind { before30, before10, due, repeat, snooze, available }

/// Eine Dosis — ohne Profil.
///
/// Ein System teilt sich einen Körper. Nimmt Lina die Tablette um acht,
/// hat Mina sie ebenfalls genommen. Deshalb ist das Profil kein Teil des
/// Schlüssels; wer den Status gesetzt hat, steht im Log.
@immutable
class DoseKey {
  const DoseKey({
    required this.medicationId,
    required this.date,
    required this.scheduledTime,
  });

  final String medicationId;

  /// Mitternacht Ortszeit des Tages, an dem die Dosis fällig ist.
  final DateTime date;

  /// Uhrzeit im Format `HH:mm`, wie in [Medication.timesOfDay].
  final String scheduledTime;

  /// Datum und Uhrzeit zusammengesetzt.
  DateTime get at {
    final parts = scheduledTime.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DoseKey &&
      other.medicationId == medicationId &&
      other.date == date &&
      other.scheduledTime == scheduledTime;

  @override
  int get hashCode => Object.hash(medicationId, date, scheduledTime);

  @override
  String toString() => 'DoseKey($medicationId, ${date.toIso8601String()}, $scheduledTime)';
}

/// Eine geplante Erinnerung.
@immutable
class Reminder {
  const Reminder({
    required this.dose,
    required this.kind,
    required this.fireAt,
    this.repeatIndex,
    this.daily = false,
  });

  final DoseKey dose;
  final ReminderKind kind;
  final DateTime fireAt;

  /// Nur bei [ReminderKind.repeat]: die wievielte Wiederholung.
  final int? repeatIndex;

  /// Täglich wiederkehrend statt einmalig.
  final bool daily;

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.dose == dose &&
      other.kind == kind &&
      other.fireAt == fireAt &&
      other.repeatIndex == repeatIndex &&
      other.daily == daily;

  @override
  int get hashCode => Object.hash(dose, kind, fireAt, repeatIndex, daily);

  @override
  String toString() =>
      'Reminder(${dose.medicationId}, ${kind.name}, ${fireAt.toIso8601String()}'
      '${repeatIndex != null ? ', #$repeatIndex' : ''}${daily ? ', täglich' : ''})';
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/reminder_test.dart`
Expected: PASS (3 Tests)

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminders/reminder.dart test/services/reminders/reminder_test.dart
git commit -m "feat(erinnerungen): Wertobjekte fuer Dosis und Erinnerung"
```

---

### Task 2: Ableitbare Kennungen mit Namensraum

**Files:**
- Create: `lib/services/reminders/reminder_id.dart`
- Test: `test/services/reminders/reminder_id_test.dart`
- Modify: `lib/services/notification_service.dart` (Kalender-Kennungen in Namensraum 2)

**Interfaces:**
- Consumes: `Reminder`, `DoseKey` aus Task 1
- Produces: `const int kNamespaceMedication = 1;`, `const int kNamespaceEvent = 2;`, `int reminderId(Reminder reminder)`, `int namespacedId(int namespace, String seed)`, `bool isMedicationId(int id)`

Warum das nötig ist: der heutige `_generateNotificationId` kennt kein Datum, weshalb die Erinnerung von heute und die von morgen dieselbe Kennung tragen — die zweite überschreibt die erste. Und er kennt keinen Namensraum, weshalb der Abgleich Medikamenten- nicht von Termin-Meldungen unterscheiden könnte und Termine wegräumen würde.

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_id_test.dart
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Reminder r({
    String med = 'm1',
    int day = 7,
    String time = '12:50',
    ReminderKind kind = ReminderKind.before10,
    int? repeat,
  }) =>
      Reminder(
        dose: DoseKey(
          medicationId: med,
          date: DateTime(2026, 8, day),
          scheduledTime: time,
        ),
        kind: kind,
        fireAt: DateTime(2026, 8, day, 12, 40),
        repeatIndex: repeat,
      );

  test('Gleiche Erinnerung ergibt gleiche Kennung', () {
    expect(reminderId(r()), reminderId(r()));
  });

  test('Anderer Tag ergibt andere Kennung', () {
    expect(reminderId(r(day: 7)), isNot(reminderId(r(day: 8))));
  });

  test('Andere Art ergibt andere Kennung', () {
    expect(
      reminderId(r(kind: ReminderKind.before10)),
      isNot(reminderId(r(kind: ReminderKind.before30))),
    );
  });

  test('Andere Wiederholung ergibt andere Kennung', () {
    expect(
      reminderId(r(kind: ReminderKind.repeat, repeat: 1)),
      isNot(reminderId(r(kind: ReminderKind.repeat, repeat: 2))),
    );
  });

  test('Kennungen liegen im Namensraum Medikament', () {
    expect(isMedicationId(reminderId(r())), isTrue);
    expect(isMedicationId(namespacedId(kNamespaceEvent, 'termin-1')), isFalse);
  });

  test('Kennungen passen in Androids 32-Bit-Bereich', () {
    final id = reminderId(r());
    expect(id, greaterThan(0));
    expect(id, lessThan(2147483647));
  });

  test('500 Dosen ergeben 500 verschiedene Kennungen', () {
    final ids = <int>{};
    for (var med = 0; med < 10; med++) {
      for (var day = 1; day <= 10; day++) {
        for (final time in ['08:00', '12:00', '18:00', '22:00', '23:30']) {
          ids.add(reminderId(r(med: 'med-$med', day: day, time: time)));
        }
      }
    }
    expect(ids.length, 500);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_id_test.dart`
Expected: FAIL — Datei fehlt

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/services/reminders/reminder_id.dart
import 'package:dis_app/services/reminders/reminder.dart';

/// Namensräume in den oberen vier Bits der Kennung.
///
/// Der Abgleich fragt das Betriebssystem, was vorgemerkt ist, und bekommt
/// nur Zahlen zurück. Ohne Namensraum ließe sich eine Medikamenten- nicht
/// von einer Termin-Meldung unterscheiden — der Abgleich würde Termine als
/// Karteileichen wegräumen.
const int kNamespaceMedication = 1;
const int kNamespaceEvent = 2;

const int _payloadBits = 27;
const int _payloadMask = (1 << _payloadBits) - 1;

/// Kennung aus Namensraum und einem beliebigen Schlüssel.
int namespacedId(int namespace, String seed) {
  var hash = 0;
  for (var i = 0; i < seed.length; i++) {
    hash = seed.codeUnitAt(i) + ((hash << 5) - hash);
    hash &= 0x7FFFFFFF;
  }
  return (namespace << _payloadBits) | (hash & _payloadMask);
}

/// Kennung einer Erinnerung — vollständig aus ihrem Inhalt abgeleitet.
int reminderId(Reminder reminder) {
  final d = reminder.dose;
  final day = '${d.date.year}-${d.date.month}-${d.date.day}';
  final seed = 'aurora.med|${d.medicationId}|$day|${d.scheduledTime}'
      '|${reminder.kind.name}|${reminder.repeatIndex ?? 0}';
  return namespacedId(kNamespaceMedication, seed);
}

/// Gehört diese Kennung zu einer Medikamenten-Erinnerung?
bool isMedicationId(int id) => (id >> _payloadBits) == kNamespaceMedication;
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/reminder_id_test.dart`
Expected: PASS (7 Tests)

- [ ] **Step 5: Kalender-Kennungen in den zweiten Namensraum holen**

In `lib/services/notification_service.dart` alle Aufrufe von `_generateNotificationId(...)`, die zu Kalenderterminen gehören (Methode `scheduleEventReminder`, `cancelEventReminders`), auf `namespacedId(kNamespaceEvent, '$eventId|$suffix')` umstellen. Import ergänzen:

```dart
import 'package:dis_app/services/reminders/reminder_id.dart';
```

Die private Methode `_generateNotificationId` wird damit unbenutzt und gelöscht. Ohne diesen Schritt könnten alte Termin-Kennungen zufällig im Medikamenten-Namensraum landen und vom Abgleich abgemeldet werden.

- [ ] **Step 6: Bestehende Tests laufen lassen**

Run: `flutter test test/services/notification_reschedule_test.dart`
Expected: PASS — die Umstellung ändert nur Zahlen, kein Verhalten.

- [ ] **Step 7: Commit**

```bash
git add lib/services/reminders/reminder_id.dart test/services/reminders/reminder_id_test.dart lib/services/notification_service.dart
git commit -m "feat(erinnerungen): ableitbare Kennungen mit Namensraum"
```

---

### Task 3: Regeln — Gerüst und Erlaubnis (R1)

**Files:**
- Create: `lib/services/reminders/reminder_rules.dart`
- Test: `test/services/reminders/reminder_rules_permission_test.dart`

**Interfaces:**
- Consumes: `Reminder`, `DoseKey`, `ReminderKind`; `Medication`, `MedicationLog` aus `lib/models/medication.dart`
- Produces:
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

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_rules_permission_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

Medication tagesmedizin({
  String id = 'm1',
  List<String> zeiten = const ['12:50'],
  bool aktiv = true,
  bool erinnerungen = true,
}) =>
    Medication(
      id: id,
      name: 'Testmed',
      dosage: '1 Tablette',
      timesOfDay: zeiten,
      profileIds: const ['lina', 'mina'],
      createdAt: DateTime(2026, 8, 1),
      isActive: aktiv,
      remindersEnabled: erinnerungen,
    );

void main() {
  final jetzt = DateTime(2026, 8, 7, 12, 0);

  test('Ohne Erlaubnis entsteht keine einzige Erinnerung', () {
    final soll = desiredReminders(
      medications: [tagesmedizin()],
      logs: const [],
      notificationsAllowed: false,
      now: jetzt,
    );
    expect(soll, isEmpty);
  });

  test('Mit Erlaubnis entsteht mindestens eine Erinnerung', () {
    final soll = desiredReminders(
      medications: [tagesmedizin()],
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
    );
    expect(soll, isNotEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_rules_permission_test.dart`
Expected: FAIL — Datei fehlt

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/services/reminders/reminder_rules.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';

/// Wie viele Wiederholungen nach der Einnahmezeit, im Abstand von zehn
/// Minuten. Vorher war die Wiederholung unbegrenzt: wer schlief, fand
/// morgens vierzig Meldungen.
const int kMaxRepeats = 3;

/// Wie lange „später" aufschiebt, wenn die Einnahmezeit schon vorbei ist.
const Duration kSnoozeAfterDue = Duration(minutes: 30);

/// Abstand, den eine aufgeschobene Erinnerung zur nächsten Dosis hält.
const Duration kSnoozeGuard = Duration(minutes: 5);

/// Was erinnert werden soll — abgeleitet, nicht nachgeführt.
///
/// Rein: keine Uhr, kein Hive, kein Plugin. Alles, was die Antwort
/// beeinflusst, steht in der Signatur. Deshalb ist jede Regel mit einer
/// festen Uhr prüfbar, und deshalb kann keine Abbruchzeile mehr vergessen
/// werden — es gibt keine.
Set<Reminder> desiredReminders({
  required List<Medication> medications,
  required List<MedicationLog> logs,
  required bool notificationsAllowed,
  required DateTime now,
  Duration horizon = const Duration(hours: 36),
  int budget = 56,
}) {
  // R1: Ohne Erlaubnis gibt es nichts zu planen. Kein stilles `return`
  // mitten im Code — die Oberfläche liest denselben Zustand und sagt es.
  if (!notificationsAllowed) return const <Reminder>{};

  final result = <Reminder>{};

  for (final medication in medications) {
    if (!medication.isActive || !medication.remindersEnabled) continue;
    if (medication.type != MedicationType.daily) continue;
    for (final time in medication.timesOfDay) {
      result.add(
        Reminder(
          dose: DoseKey(
            medicationId: medication.id,
            date: DateTime(now.year, now.month, now.day),
            scheduledTime: time,
          ),
          kind: ReminderKind.due,
          fireAt: DoseKey(
            medicationId: medication.id,
            date: DateTime(now.year, now.month, now.day),
            scheduledTime: time,
          ).at,
          daily: true,
        ),
      );
    }
  }

  return result;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/reminder_rules_permission_test.dart`
Expected: PASS (2 Tests)

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminders/reminder_rules.dart test/services/reminders/reminder_rules_permission_test.dart
git commit -m "feat(erinnerungen): Regelfunktion mit Erlaubnis als Eingabe"
```

---

### Task 4: Regeln — Tagesmedizin, Vorwarnungen und Wiederholungen (R2)

**Files:**
- Modify: `lib/services/reminders/reminder_rules.dart`
- Test: `test/services/reminders/reminder_rules_daily_test.dart`

**Interfaces:**
- Consumes: `desiredReminders()` aus Task 3
- Produces: dieselbe Funktion, jetzt mit `before30`, `before10` und drei `repeat` je Dosis im Horizont. `due` bleibt ausschließlich täglich wiederkehrend.

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_rules_daily_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

Medication med({
  String id = 'm1',
  List<String> zeiten = const ['12:50'],
  DateTime? start,
  DateTime? ende,
  bool aktiv = true,
  bool erinnerungen = true,
  MedicationType typ = MedicationType.daily,
}) =>
    Medication(
      id: id,
      name: 'Testmed',
      dosage: '1 Tablette',
      timesOfDay: zeiten,
      profileIds: const ['lina'],
      createdAt: DateTime(2026, 8, 1),
      isActive: aktiv,
      remindersEnabled: erinnerungen,
      type: typ,
      startDate: start,
      endDate: ende,
    );

Set<Reminder> soll(
  List<Medication> meds, {
  List<MedicationLog> logs = const [],
  DateTime? jetzt,
}) =>
    desiredReminders(
      medications: meds,
      logs: logs,
      notificationsAllowed: true,
      now: jetzt ?? DateTime(2026, 8, 7, 12, 0),
    );

void main() {
  test('Je Dosis entstehen zwei Vorwarnungen und drei Wiederholungen', () {
    final einzeln = soll([med()]).where((r) => !r.daily).toList();
    expect(
      einzeln.where((r) => r.kind == ReminderKind.before30).length,
      1,
      reason: 'heute 12:20',
    );
    expect(einzeln.where((r) => r.kind == ReminderKind.before10).length, 1);
    expect(einzeln.where((r) => r.kind == ReminderKind.repeat).length, 3);
  });

  test('Die Vorwarnungen liegen 30 und 10 Minuten davor', () {
    final einzeln = soll([med()]).where((r) => !r.daily);
    final vor30 = einzeln.firstWhere((r) => r.kind == ReminderKind.before30);
    final vor10 = einzeln.firstWhere((r) => r.kind == ReminderKind.before10);
    expect(vor30.fireAt, DateTime(2026, 8, 7, 12, 20));
    expect(vor10.fireAt, DateTime(2026, 8, 7, 12, 40));
  });

  test('Die Wiederholungen liegen 10, 20 und 30 Minuten danach', () {
    final wdh = soll([med()])
        .where((r) => r.kind == ReminderKind.repeat)
        .map((r) => r.fireAt)
        .toList()
      ..sort();
    expect(wdh, [
      DateTime(2026, 8, 7, 13, 0),
      DateTime(2026, 8, 7, 13, 10),
      DateTime(2026, 8, 7, 13, 20),
    ]);
  });

  test('Vergangene Zeitpunkte entstehen nicht', () {
    // Jetzt 12:30 — die Vorwarnung um 12:20 ist vorbei.
    final einzeln = soll([med()], jetzt: DateTime(2026, 8, 7, 12, 30));
    expect(einzeln.where((r) => r.kind == ReminderKind.before30), isEmpty);
    expect(einzeln.where((r) => r.kind == ReminderKind.before10), hasLength(1));
  });

  test('Zur Dosiszeit entsteht keine Einzelmeldung', () {
    final einzeln = soll([med()]).where((r) => !r.daily);
    expect(
      einzeln.where((r) => r.kind == ReminderKind.due),
      isEmpty,
      reason: 'due ist die tägliche Grundebene, nicht eine Einzelmeldung',
    );
  });

  test('Inaktives Medikament erzeugt nichts', () {
    expect(soll([med(aktiv: false)]), isEmpty);
  });

  test('Abgeschaltete Erinnerungen erzeugen nichts', () {
    expect(soll([med(erinnerungen: false)]), isEmpty);
  });

  test('Bedarfsmedizin erzeugt hier nichts', () {
    expect(soll([med(typ: MedicationType.asNeeded)]), isEmpty);
  });

  test('Vor dem Startdatum entsteht nichts', () {
    expect(soll([med(start: DateTime(2026, 8, 10))]), isEmpty);
  });

  test('Nach dem Enddatum entsteht nichts', () {
    expect(soll([med(ende: DateTime(2026, 8, 5))]), isEmpty);
  });

  test('Zwei Zeiten ergeben zwei Dosen', () {
    final dosen = soll([med(zeiten: const ['12:50', '18:00'])])
        .map((r) => r.dose)
        .toSet();
    expect(dosen.map((d) => d.scheduledTime).toSet(), {'12:50', '18:00'});
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_rules_daily_test.dart`
Expected: FAIL — mehrere Tests, weil bisher nur die tägliche `due`-Meldung entsteht

- [ ] **Step 3: Write minimal implementation**

`desiredReminders` in `reminder_rules.dart` ersetzen durch:

```dart
Set<Reminder> desiredReminders({
  required List<Medication> medications,
  required List<MedicationLog> logs,
  required bool notificationsAllowed,
  required DateTime now,
  Duration horizon = const Duration(hours: 36),
  int budget = 56,
}) {
  if (!notificationsAllowed) return const <Reminder>{};

  final result = <Reminder>{};
  final until = now.add(horizon);

  for (final medication in medications) {
    if (!_isEligible(medication)) continue;
    for (final dose in _dosesInWindow(medication, now, until)) {
      result.addAll(_singleShotFor(dose, now));
    }
    for (final time in medication.timesOfDay) {
      final anchor = _dailyAnchor(medication, time, now);
      if (anchor != null) result.add(anchor);
    }
  }

  return result;
}

/// Kommt dieses Medikament überhaupt für Tageserinnerungen in Frage?
bool _isEligible(Medication medication) =>
    medication.isActive &&
    medication.remindersEnabled &&
    medication.type == MedicationType.daily;

/// Gilt das Medikament an diesem Tag?
bool _appliesOn(Medication medication, DateTime day) {
  final start = medication.startDate;
  final end = medication.endDate;
  if (start != null && day.isBefore(DateTime(start.year, start.month, start.day))) {
    return false;
  }
  if (end != null && day.isAfter(DateTime(end.year, end.month, end.day))) {
    return false;
  }
  return true;
}

/// Alle Dosen dieses Medikaments zwischen [from] und [until].
List<DoseKey> _dosesInWindow(Medication medication, DateTime from, DateTime until) {
  final doses = <DoseKey>[];
  var day = DateTime(from.year, from.month, from.day);
  final lastDay = DateTime(until.year, until.month, until.day);
  while (!day.isAfter(lastDay)) {
    if (_appliesOn(medication, day)) {
      for (final time in medication.timesOfDay) {
        doses.add(
          DoseKey(
            medicationId: medication.id,
            date: day,
            scheduledTime: time,
          ),
        );
      }
    }
    day = day.add(const Duration(days: 1));
  }
  return doses;
}

/// Die Einzelmeldungen einer Dosis: zwei Vorwarnungen, drei Wiederholungen.
///
/// Die Meldung zur Dosiszeit selbst fehlt hier mit Absicht — sie ist die
/// tägliche Grundmeldung aus [_dailyAnchor] und würde sich sonst
/// verdoppeln.
Set<Reminder> _singleShotFor(DoseKey dose, DateTime now) {
  final at = dose.at;
  final candidates = <Reminder>{
    Reminder(
      dose: dose,
      kind: ReminderKind.before30,
      fireAt: at.subtract(const Duration(minutes: 30)),
    ),
    Reminder(
      dose: dose,
      kind: ReminderKind.before10,
      fireAt: at.subtract(const Duration(minutes: 10)),
    ),
    for (var i = 1; i <= kMaxRepeats; i++)
      Reminder(
        dose: dose,
        kind: ReminderKind.repeat,
        fireAt: at.add(Duration(minutes: 10 * i)),
        repeatIndex: i,
      ),
  };
  return candidates.where((r) => r.fireAt.isAfter(now)).toSet();
}

/// Die täglich wiederkehrende Meldung zur Dosiszeit.
///
/// Ihr Ankertag ist der nächste Tag, an dem diese Dosis noch offen ist.
/// Ab Task 5 fließt der Erledigungsstand ein; bis dahin ist es schlicht
/// heute oder — wenn die Zeit heute schon vorbei ist — morgen.
Reminder? _dailyAnchor(Medication medication, String time, DateTime now) {
  var day = DateTime(now.year, now.month, now.day);
  for (var i = 0; i < 2; i++) {
    final dose = DoseKey(
      medicationId: medication.id,
      date: day,
      scheduledTime: time,
    );
    if (_appliesOn(medication, day) && dose.at.isAfter(now)) {
      return Reminder(
        dose: dose,
        kind: ReminderKind.due,
        fireAt: dose.at,
        daily: true,
      );
    }
    day = day.add(const Duration(days: 1));
  }
  return null;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/reminder_rules_daily_test.dart test/services/reminders/reminder_rules_permission_test.dart`
Expected: PASS (12 Tests)

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminders/reminder_rules.dart test/services/reminders/reminder_rules_daily_test.dart
git commit -m "feat(erinnerungen): Vorwarnungen und begrenzte Wiederholungen"
```

---

### Task 5: Regeln — erledigte Dosis räumt alles ab (R3)

**Files:**
- Modify: `lib/services/reminders/reminder_rules.dart`
- Test: `test/services/reminders/reminder_rules_settled_test.dart`

**Interfaces:**
- Consumes: `desiredReminders()` aus Task 4
- Produces: dieselbe Funktion; zusätzlich intern `Map<DoseKey, MedicationLog> _latestLogByDose(List<MedicationLog>)`

Dies ist Befund 2 aus der Spec: „Genommen" ließ 14:30, 14:50 und 15:00 stehen.

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_rules_settled_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

Medication med({List<String> zeiten = const ['15:00']}) => Medication(
      id: 'm1',
      name: 'Vitamin D',
      dosage: '1 Tablette',
      timesOfDay: zeiten,
      profileIds: const ['lina', 'mina'],
      createdAt: DateTime(2026, 8, 1),
    );

MedicationLog log({
  required MedicationStatus status,
  String zeit = '15:00',
  String profil = 'lina',
  DateTime? wann,
}) =>
    MedicationLog(
      id: 'l-${status.name}-$zeit-$profil',
      medicationId: 'm1',
      takenAt: wann ?? DateTime(2026, 8, 7, 12, 22),
      profileId: profil,
      status: status,
      confirmedAt: wann ?? DateTime(2026, 8, 7, 12, 22),
      scheduledTime: zeit,
    );

Set<Reminder> soll(List<MedicationLog> logs) => desiredReminders(
      medications: [med()],
      logs: logs,
      notificationsAllowed: true,
      now: DateTime(2026, 8, 7, 12, 0),
    );

void main() {
  for (final status in [
    MedicationStatus.taken,
    MedicationStatus.refused,
    MedicationStatus.skipped,
  ]) {
    test('Status ${status.name}: keine Einzelmeldung mehr für diese Dosis', () {
      final einzeln = soll([log(status: status)]).where((r) => !r.daily);
      expect(einzeln, isEmpty);
    });

    test('Status ${status.name}: Grundmeldung wird auf morgen verankert', () {
      final taeglich = soll([log(status: status)]).firstWhere((r) => r.daily);
      expect(taeglich.fireAt, DateTime(2026, 8, 8, 15, 0));
    });
  }

  test('Ohne Log bleibt die Grundmeldung auf heute', () {
    final taeglich = soll(const []).firstWhere((r) => r.daily);
    expect(taeglich.fireAt, DateTime(2026, 8, 7, 15, 0));
  });

  test('Ein Log von gestern räumt die heutige Dosis nicht ab', () {
    final einzeln = soll([
      log(status: MedicationStatus.taken, wann: DateTime(2026, 8, 6, 15, 1)),
    ]).where((r) => !r.daily);
    expect(einzeln, isNotEmpty);
  });

  test('Der jüngste Log gewinnt: erst genommen, dann korrigiert', () {
    final einzeln = soll([
      log(status: MedicationStatus.taken, wann: DateTime(2026, 8, 7, 12, 10)),
      log(status: MedicationStatus.snoozed, wann: DateTime(2026, 8, 7, 12, 20)),
    ]).where((r) => !r.daily);
    // Snooze ist keine Erledigung — Task 6 legt fest, was stattdessen
    // entsteht. Hier zählt nur: die Dosis gilt nicht mehr als erledigt.
    expect(einzeln, isNotEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_rules_settled_test.dart`
Expected: FAIL — Logs werden noch nicht ausgewertet

- [ ] **Step 3: Write minimal implementation**

In `reminder_rules.dart`:

```dart
/// Der jüngste Log je Dosis.
///
/// „Jünger" heißt: zuletzt bestätigt. Wer sich vertippt und korrigiert,
/// soll die Korrektur wirksam sehen — deshalb entscheidet [confirmedAt],
/// nicht die Reihenfolge in der Box.
Map<DoseKey, MedicationLog> _latestLogByDose(List<MedicationLog> logs) {
  final result = <DoseKey, MedicationLog>{};
  for (final log in logs) {
    final time = log.scheduledTime;
    if (time == null) continue; // Bedarfsmedizin, siehe R6
    final dose = DoseKey(
      medicationId: log.medicationId,
      date: DateTime(log.takenAt.year, log.takenAt.month, log.takenAt.day),
      scheduledTime: time,
    );
    final existing = result[dose];
    final stamp = log.confirmedAt ?? log.takenAt;
    final existingStamp = existing == null
        ? null
        : existing.confirmedAt ?? existing.takenAt;
    if (existingStamp == null || stamp.isAfter(existingStamp)) {
      result[dose] = log;
    }
  }
  return result;
}

/// Ist diese Dosis abgeschlossen? Aufschub zählt nicht dazu.
bool _isSettled(MedicationLog? log) =>
    log != null &&
    (log.status == MedicationStatus.taken ||
        log.status == MedicationStatus.refused ||
        log.status == MedicationStatus.skipped);
```

`desiredReminders` anpassen — die Schleife bekommt die Log-Karte und reicht sie durch:

```dart
Set<Reminder> desiredReminders({
  required List<Medication> medications,
  required List<MedicationLog> logs,
  required bool notificationsAllowed,
  required DateTime now,
  Duration horizon = const Duration(hours: 36),
  int budget = 56,
}) {
  if (!notificationsAllowed) return const <Reminder>{};

  final byDose = _latestLogByDose(logs);
  final result = <Reminder>{};
  final until = now.add(horizon);

  for (final medication in medications) {
    if (!_isEligible(medication)) continue;
    for (final dose in _dosesInWindow(medication, now, until)) {
      if (_isSettled(byDose[dose])) continue;
      result.addAll(_singleShotFor(dose, now));
    }
    for (final time in medication.timesOfDay) {
      final anchor = _dailyAnchor(medication, time, now, byDose);
      if (anchor != null) result.add(anchor);
    }
  }

  return result;
}
```

Und `_dailyAnchor` bekommt die Karte, überspringt erledigte Tage und schaut dafür einen Tag weiter:

```dart
Reminder? _dailyAnchor(
  Medication medication,
  String time,
  DateTime now,
  Map<DoseKey, MedicationLog> byDose,
) {
  var day = DateTime(now.year, now.month, now.day);
  for (var i = 0; i < 3; i++) {
    final dose = DoseKey(
      medicationId: medication.id,
      date: day,
      scheduledTime: time,
    );
    if (_appliesOn(medication, day) &&
        dose.at.isAfter(now) &&
        !_isSettled(byDose[dose])) {
      return Reminder(
        dose: dose,
        kind: ReminderKind.due,
        fireAt: dose.at,
        daily: true,
      );
    }
    day = day.add(const Duration(days: 1));
  }
  return null;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/`
Expected: PASS (alle bisherigen Tests)

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminders/reminder_rules.dart test/services/reminders/reminder_rules_settled_test.dart
git commit -m "feat(erinnerungen): erledigte Dosis raeumt ihre Erinnerungen ab"
```

---

### Task 6: Regeln — Aufschub verschiebt, statt zu stapeln (R4)

**Files:**
- Modify: `lib/services/reminders/reminder_rules.dart`
- Test: `test/services/reminders/reminder_rules_snooze_test.dart`

**Interfaces:**
- Consumes: `_latestLogByDose`, `_singleShotFor` aus Task 5
- Produces: `Reminder` mit `kind: ReminderKind.snooze` je aufgeschobener Dosis; keine anderen Erinnerungen für diese Dosis

Dies ist Befund 3 und 4: „Später" war beim Betriebssystem nicht angemeldet, ließ die Vorwarnungen stehen und rechnete ab Tippzeitpunkt.

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_rules_snooze_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

Medication med({List<String> zeiten = const ['12:50']}) => Medication(
      id: 'm1',
      name: 'Testmed',
      dosage: '1 Tablette',
      timesOfDay: zeiten,
      profileIds: const ['lina'],
      createdAt: DateTime(2026, 8, 1),
    );

MedicationLog aufgeschoben({
  required DateTime getippt,
  String zeit = '12:50',
}) =>
    MedicationLog(
      id: 'l1',
      medicationId: 'm1',
      takenAt: getippt,
      profileId: 'lina',
      status: MedicationStatus.snoozed,
      confirmedAt: getippt,
      snoozedUntil: getippt.add(const Duration(hours: 1)),
      scheduledTime: zeit,
    );

Set<Reminder> soll({
  required List<MedicationLog> logs,
  required DateTime jetzt,
  List<String> zeiten = const ['12:50'],
}) =>
    desiredReminders(
      medications: [med(zeiten: zeiten)],
      logs: logs,
      notificationsAllowed: true,
      now: jetzt,
    );

void main() {
  test('Aufschub vor der Dosiszeit rückt auf die Dosiszeit', () {
    final ergebnis = soll(
      logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 21))],
      jetzt: DateTime(2026, 8, 7, 12, 22),
    );
    final fuerHeute =
        ergebnis.where((r) => r.dose.date == DateTime(2026, 8, 7)).toList();
    expect(fuerHeute, hasLength(1));
    expect(fuerHeute.single.kind, ReminderKind.snooze);
    expect(fuerHeute.single.fireAt, DateTime(2026, 8, 7, 12, 50));
  });

  test('Aufschub vor der Dosiszeit löscht die Vorwarnungen', () {
    final ergebnis = soll(
      logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 21))],
      jetzt: DateTime(2026, 8, 7, 12, 22),
    );
    expect(
      ergebnis.where((r) => r.kind == ReminderKind.before10),
      isEmpty,
      reason: 'die 12:40-Vorwarnung darf nicht stehen bleiben',
    );
    expect(ergebnis.where((r) => r.kind == ReminderKind.repeat), isEmpty);
  });

  test('Aufschub nach der Dosiszeit gibt dreißig Minuten Ruhe', () {
    final ergebnis = soll(
      logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 55))],
      jetzt: DateTime(2026, 8, 7, 12, 56),
    );
    final auf = ergebnis.firstWhere((r) => r.kind == ReminderKind.snooze);
    expect(auf.fireAt, DateTime(2026, 8, 7, 13, 25));
  });

  test('Aufschub reicht nie über die nächste Dosis hinaus', () {
    final ergebnis = soll(
      zeiten: const ['12:50', '13:10'],
      logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 55))],
      jetzt: DateTime(2026, 8, 7, 12, 56),
    );
    final auf = ergebnis.firstWhere(
      (r) => r.kind == ReminderKind.snooze && r.dose.scheduledTime == '12:50',
    );
    expect(
      auf.fireAt,
      DateTime(2026, 8, 7, 13, 5),
      reason: 'nächste Dosis 13:10 minus fünf Minuten Abstand',
    );
  });

  test('Ein bereits verstrichener Aufschub erzeugt nichts mehr', () {
    final ergebnis = soll(
      logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 55))],
      jetzt: DateTime(2026, 8, 7, 14, 0),
    );
    expect(
      ergebnis.where((r) => r.dose.date == DateTime(2026, 8, 7)),
      isEmpty,
    );
  });

  test('Aufschub verankert die Grundmeldung auf morgen', () {
    final ergebnis = soll(
      logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 21))],
      jetzt: DateTime(2026, 8, 7, 12, 22),
    );
    final taeglich = ergebnis.firstWhere((r) => r.daily);
    expect(
      taeglich.fireAt,
      DateTime(2026, 8, 8, 12, 50),
      reason: 'die heutige Dosis hat ihre eigene Aufschub-Meldung',
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_rules_snooze_test.dart`
Expected: FAIL — Aufschub wird noch nicht ausgewertet

- [ ] **Step 3: Write minimal implementation**

In `reminder_rules.dart` ergänzen:

```dart
/// Wann erinnert Aurora nach einem „später"?
///
/// Wer **vor** der Einnahmezeit aufschiebt, meint „nicht jetzt" — und
/// nicht „nach der Einnahmezeit". Deshalb rückt die Erinnerung auf die
/// Dosiszeit, statt sich dahinter zu schieben. Auf dem Gerät war es
/// umgekehrt: Tippen um 12:21 auf die 30-Minuten-Vorwarnung ergab 13:21,
/// die Dosis war für 12:50 gedacht.
DateTime _snoozeTarget({
  required DoseKey dose,
  required DateTime tappedAt,
  required DateTime? nextDoseAt,
}) {
  final due = dose.at;
  if (tappedAt.isBefore(due)) return due;
  var target = tappedAt.add(kSnoozeAfterDue);
  if (nextDoseAt != null) {
    final guard = nextDoseAt.subtract(kSnoozeGuard);
    if (target.isAfter(guard)) target = guard;
  }
  return target;
}

/// Die nächste Dosiszeit desselben Medikaments nach [after].
DateTime? _nextDoseAfter(Medication medication, DateTime after) {
  DateTime? best;
  for (var dayOffset = 0; dayOffset <= 1; dayOffset++) {
    final day = DateTime(after.year, after.month, after.day)
        .add(Duration(days: dayOffset));
    if (!_appliesOn(medication, day)) continue;
    for (final time in medication.timesOfDay) {
      final at = DoseKey(
        medicationId: medication.id,
        date: day,
        scheduledTime: time,
      ).at;
      if (at.isAfter(after) && (best == null || at.isBefore(best))) {
        best = at;
      }
    }
  }
  return best;
}
```

Und die Dosis-Schleife in `desiredReminders` erweitern:

```dart
    for (final dose in _dosesInWindow(medication, now, until)) {
      final log = byDose[dose];
      if (_isSettled(log)) continue;

      // R4: Ein Aufschub ersetzt alle übrigen Erinnerungen dieser Dosis.
      if (log != null && log.status == MedicationStatus.snoozed) {
        final target = _snoozeTarget(
          dose: dose,
          tappedAt: log.confirmedAt ?? log.takenAt,
          nextDoseAt: _nextDoseAfter(medication, dose.at),
        );
        if (target.isAfter(now)) {
          result.add(
            Reminder(dose: dose, kind: ReminderKind.snooze, fireAt: target),
          );
        }
        continue;
      }

      result.addAll(_singleShotFor(dose, now));
    }
```

`_dailyAnchor` muss aufgeschobene Dosen ebenfalls überspringen — sie haben ihre eigene Meldung. Dazu die Bedingung erweitern:

```dart
    final log = byDose[dose];
    final handled = _isSettled(log) || log?.status == MedicationStatus.snoozed;
    if (_appliesOn(medication, day) && dose.at.isAfter(now) && !handled) {
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminders/reminder_rules.dart test/services/reminders/reminder_rules_snooze_test.dart
git commit -m "feat(erinnerungen): Aufschub verschiebt statt zu stapeln"
```

---

### Task 7: Regeln — eine Dosis gehört dem Körper (R5)

**Files:**
- Modify: keine (der Dosisschlüssel kennt bereits kein Profil)
- Test: `test/services/reminders/reminder_rules_dose_key_test.dart`

**Interfaces:**
- Consumes: `desiredReminders()` aus Task 6
- Produces: nichts Neues — dieser Task sichert eine Eigenschaft ab, die sonst still verloren gehen könnte

Warum das ein eigener Task ist: ein Körper, mehrere Innen. Würde jemand später ein Profil in den Dosisschlüssel aufnehmen, könnten zwei Innen dieselbe Dosis nehmen, weil die Karte für die zweite Person offen bliebe. Dieser Test ist der Riegel davor.

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_rules_dose_key_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final medikament = Medication(
    id: 'm1',
    name: 'Testmed',
    dosage: '1 Tablette',
    timesOfDay: const ['15:00'],
    profileIds: const ['lina', 'mina'],
    createdAt: DateTime(2026, 8, 1),
  );

  test('Lina nimmt, für Mina ist dieselbe Dosis erledigt', () {
    final ergebnis = desiredReminders(
      medications: [medikament],
      logs: [
        MedicationLog(
          id: 'l1',
          medicationId: 'm1',
          takenAt: DateTime(2026, 8, 7, 12, 22),
          profileId: 'lina',
          status: MedicationStatus.taken,
          confirmedAt: DateTime(2026, 8, 7, 12, 22),
          scheduledTime: '15:00',
        ),
      ],
      notificationsAllowed: true,
      now: DateTime(2026, 8, 7, 12, 0),
    );

    expect(
      ergebnis.where((r) => !r.daily && r.dose.date == DateTime(2026, 8, 7)),
      isEmpty,
      reason: 'ein Körper, eine Dosis — das Profil steht nicht im Schlüssel',
    );
  });

  test('Der Dosisschlüssel trägt kein Profil', () {
    const dose = DoseKey(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '15:00',
    );
    expect(dose.toString(), isNot(contains('lina')));
    expect(dose.toString(), isNot(contains('profile')));
  });
}
```

- [ ] **Step 2: Run test to verify it fails or passes**

Run: `flutter test test/services/reminders/reminder_rules_dose_key_test.dart`
Expected: PASS — die Eigenschaft ist bereits erfüllt. Falls FAIL, wurde in Task 5 oder 6 versehentlich ein Profil in den Schlüssel gezogen; dann dort korrigieren.

- [ ] **Step 3: Kommentar im Quelltext verankern**

In `lib/services/reminders/reminder.dart` über `class DoseKey` steht der Grund bereits (Task 1). Ergänze in `reminder_rules.dart` über `_latestLogByDose` eine Zeile:

```dart
// R5: Der Schlüssel enthält bewusst kein Profil. Siehe DoseKey.
```

- [ ] **Step 4: Commit**

```bash
git add test/services/reminders/reminder_rules_dose_key_test.dart lib/services/reminders/reminder_rules.dart
git commit -m "test(erinnerungen): eine Dosis gehoert dem Koerper, nicht dem Profil"
```

---

### Task 8: Regeln — Bedarfsmedizin (R6)

**Files:**
- Modify: `lib/services/reminders/reminder_rules.dart`
- Test: `test/services/reminders/reminder_rules_as_needed_test.dart`

**Interfaces:**
- Consumes: `desiredReminders()` aus Task 7
- Produces: `Reminder` mit `kind: ReminderKind.available` bei Freigabe − 30, − 10, − 5 min und zur Freigabezeit

Der Dosisschlüssel für Bedarfsmedizin nutzt `scheduledTime: 'prn'` und das Datum der letzten Einnahme — er muss nur eindeutig und ableitbar sein.

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_rules_as_needed_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

Medication bedarf({int? maxDosen = 4, int? abstand = 4}) => Medication(
      id: 'prn1',
      name: 'Bedarfsmittel',
      dosage: '1 Tablette',
      timesOfDay: const [],
      profileIds: const ['lina'],
      createdAt: DateTime(2026, 8, 1),
      type: MedicationType.asNeeded,
      maxDailyDoses: maxDosen,
      minIntervalHours: abstand,
    );

MedicationLog einnahme(DateTime wann) => MedicationLog(
      id: 'l-${wann.millisecondsSinceEpoch}',
      medicationId: 'prn1',
      takenAt: wann,
      profileId: 'lina',
      status: MedicationStatus.taken,
      confirmedAt: wann,
    );

Set<Reminder> soll({
  required List<MedicationLog> logs,
  Medication? medikament,
  DateTime? jetzt,
}) =>
    desiredReminders(
      medications: [medikament ?? bedarf()],
      logs: logs,
      notificationsAllowed: true,
      now: jetzt ?? DateTime(2026, 8, 7, 12, 0),
    );

void main() {
  test('Nach einer Einnahme entstehen vier Freigabe-Erinnerungen', () {
    final ergebnis = soll(logs: [einnahme(DateTime(2026, 8, 7, 11, 0))]);
    final freigabe =
        ergebnis.where((r) => r.kind == ReminderKind.available).toList();
    expect(freigabe, hasLength(4));
    expect(
      freigabe.map((r) => r.fireAt).toList()..sort(),
      [
        DateTime(2026, 8, 7, 14, 30),
        DateTime(2026, 8, 7, 14, 50),
        DateTime(2026, 8, 7, 14, 55),
        DateTime(2026, 8, 7, 15, 0),
      ],
    );
  });

  test('Ohne Mindestabstand entsteht keine Freigabe-Erinnerung', () {
    final ergebnis = soll(
      medikament: bedarf(abstand: null),
      logs: [einnahme(DateTime(2026, 8, 7, 11, 0))],
    );
    expect(ergebnis, isEmpty);
  });

  test('Bei erreichtem Tageslimit entsteht nichts', () {
    final ergebnis = soll(
      medikament: bedarf(maxDosen: 2),
      logs: [
        einnahme(DateTime(2026, 8, 7, 8, 0)),
        einnahme(DateTime(2026, 8, 7, 11, 0)),
      ],
    );
    expect(ergebnis, isEmpty);
  });

  test('Ohne Einnahme entsteht nichts', () {
    expect(soll(logs: const []), isEmpty);
  });

  test('Vergangene Freigabe erzeugt nichts', () {
    final ergebnis = soll(
      logs: [einnahme(DateTime(2026, 8, 7, 6, 0))],
      jetzt: DateTime(2026, 8, 7, 12, 0),
    );
    expect(ergebnis, isEmpty);
  });

  test('Nur die letzte Einnahme zählt', () {
    final ergebnis = soll(
      logs: [
        einnahme(DateTime(2026, 8, 7, 8, 0)),
        einnahme(DateTime(2026, 8, 7, 11, 0)),
      ],
    );
    final freigabe = ergebnis.where((r) => r.kind == ReminderKind.available);
    expect(freigabe.map((r) => r.fireAt).reduce((a, b) => a.isAfter(b) ? a : b),
        DateTime(2026, 8, 7, 15, 0));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_rules_as_needed_test.dart`
Expected: FAIL — Bedarfsmedizin wird noch übersprungen

- [ ] **Step 3: Write minimal implementation**

In `reminder_rules.dart` ergänzen:

```dart
/// Vorlaufzeiten der Freigabe-Erinnerung bei Bedarfsmedizin.
const List<Duration> kAvailabilityOffsets = [
  Duration(minutes: 30),
  Duration(minutes: 10),
  Duration(minutes: 5),
  Duration.zero,
];

/// Freigabe-Erinnerungen für ein Bedarfsmedikament.
///
/// Wer ein Mittel nur bei Bedarf nimmt, wartet zwischen zwei Dosen einen
/// Mindestabstand ab. Diese Erinnerungen sagen, wann er vorbei ist —
/// abgeleitet aus den Einnahmen, nicht beim Nehmen von Hand gesetzt.
Set<Reminder> _availabilityFor(
  Medication medication,
  List<MedicationLog> logs,
  DateTime now,
) {
  final interval = medication.minIntervalHours;
  if (interval == null || interval == 0) return const <Reminder>{};

  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final takenToday = logs
      .where((log) =>
          log.medicationId == medication.id &&
          log.status == MedicationStatus.taken &&
          log.takenAt.isAfter(today) &&
          log.takenAt.isBefore(tomorrow))
      .toList()
    ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

  if (takenToday.isEmpty) return const <Reminder>{};

  final max = medication.maxDailyDoses;
  if (max != null && takenToday.length >= max) return const <Reminder>{};

  final last = takenToday.last.takenAt;
  final free = last.add(Duration(hours: interval));
  final dose = DoseKey(
    medicationId: medication.id,
    date: DateTime(free.year, free.month, free.day),
    scheduledTime: 'prn-${free.hour.toString().padLeft(2, '0')}:'
        '${free.minute.toString().padLeft(2, '0')}',
  );

  return kAvailabilityOffsets
      .map(
        (offset) => Reminder(
          dose: dose,
          kind: ReminderKind.available,
          fireAt: free.subtract(offset),
          repeatIndex: offset.inMinutes,
        ),
      )
      .where((r) => r.fireAt.isAfter(now))
      .toSet();
}
```

Und in `desiredReminders` vor der Tagesmedizin-Prüfung einhängen:

```dart
  for (final medication in medications) {
    if (!medication.isActive || !medication.remindersEnabled) continue;

    if (medication.type == MedicationType.asNeeded) {
      result.addAll(_availabilityFor(medication, logs, now));
      continue;
    }

    if (!_isEligible(medication)) continue;
    // ... unverändert weiter
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminders/reminder_rules.dart test/services/reminders/reminder_rules_as_needed_test.dart
git commit -m "feat(erinnerungen): Freigabe-Erinnerungen fuer Bedarfsmedizin"
```

---

### Task 9: Regeln — Horizont, Budget, Zeitumstellung, reine Funktion (R7)

**Files:**
- Modify: `lib/services/reminders/reminder_rules.dart`
- Test: `test/services/reminders/reminder_rules_budget_test.dart`

**Interfaces:**
- Consumes: `desiredReminders()` aus Task 8
- Produces: `class ReminderBudgetReport { int dropped; }` — nein, kein neuer Typ. Stattdessen: die Funktion kürzt selbst und der Aufrufer erfährt die Zahl über `Set.length`. Der Reconciler protokolliert die Differenz zur ungekürzten Menge über den optionalen Rückgabeparameter `onDropped`:
```dart
Set<Reminder> desiredReminders({..., void Function(int count)? onDropped});
```

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_rules_budget_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

Medication med(String id, List<String> zeiten) => Medication(
      id: id,
      name: 'Med $id',
      dosage: '1 Tablette',
      timesOfDay: zeiten,
      profileIds: const ['lina'],
      createdAt: DateTime(2026, 8, 1),
    );

void main() {
  final jetzt = DateTime(2026, 8, 7, 0, 30);

  test('Der Horizont begrenzt auf 36 Stunden', () {
    final ergebnis = desiredReminders(
      medications: [med('m1', const ['12:00'])],
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
    );
    final tage = ergebnis.map((r) => r.dose.date).toSet();
    expect(tage, {DateTime(2026, 8, 7), DateTime(2026, 8, 8)});
  });

  test('Das Budget kürzt die zeitlich fernsten Einträge', () {
    var verworfen = 0;
    final ergebnis = desiredReminders(
      medications: [
        for (var i = 0; i < 6; i++)
          med('m$i', const ['08:00', '12:00', '18:00', '22:00']),
      ],
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
      budget: 20,
      onDropped: (count) => verworfen = count,
    );
    expect(ergebnis.length, 20);
    expect(verworfen, greaterThan(0));
  });

  test('Tägliche Grundmeldungen überleben die Kürzung', () {
    final ergebnis = desiredReminders(
      medications: [
        for (var i = 0; i < 6; i++)
          med('m$i', const ['08:00', '12:00', '18:00', '22:00']),
      ],
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
      budget: 24,
    );
    expect(
      ergebnis.where((r) => r.daily).length,
      24,
      reason: 'sechs Medikamente mit je vier Zeiten — die Grundebene zuerst',
    );
  });

  test('Die Funktion ist rein: gleiche Eingabe, gleiche Ausgabe', () {
    List<Medication> meds() => [med('m1', const ['12:00', '18:00'])];
    final a = desiredReminders(
      medications: meds(),
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
    );
    final b = desiredReminders(
      medications: meds(),
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
    );
    expect(a, b);
  });

  test('Sommerzeitende: die Dosiszeit bleibt Ortszeit', () {
    // 25.10.2026 ist der Umstellungssonntag in Europa.
    final ergebnis = desiredReminders(
      medications: [med('m1', const ['02:30'])],
      logs: const [],
      notificationsAllowed: true,
      now: DateTime(2026, 10, 25, 0, 0),
    );
    final zeiten = ergebnis.map((r) => r.dose.scheduledTime).toSet();
    expect(zeiten, {'02:30'});
    final tage = ergebnis.map((r) => r.dose.date).toSet();
    expect(tage.length, lessThanOrEqualTo(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_rules_budget_test.dart`
Expected: FAIL — `onDropped` gibt es nicht, das Budget greift nicht

- [ ] **Step 3: Write minimal implementation**

Signatur um `onDropped` erweitern und am Ende von `desiredReminders` kürzen:

```dart
  // R7: iOS merkt höchstens 64 Meldungen vor. Was darüber liegt, würde
  // stillschweigend verschwinden — deshalb kürzen wir selbst, nach Nähe,
  // und sagen es. Die täglichen Grundmeldungen bleiben immer: sie sind
  // die Ebene, die auch nach Wochen ohne App noch trägt.
  if (result.length <= budget) {
    onDropped?.call(0);
    return result;
  }

  final daily = result.where((r) => r.daily).toList()
    ..sort((a, b) => a.fireAt.compareTo(b.fireAt));
  final single = result.where((r) => !r.daily).toList()
    ..sort((a, b) => a.fireAt.compareTo(b.fireAt));

  final kept = <Reminder>{...daily.take(budget)};
  for (final reminder in single) {
    if (kept.length >= budget) break;
    kept.add(reminder);
  }
  onDropped?.call(result.length - kept.length);
  return kept;
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/`
Expected: PASS

- [ ] **Step 5: Prüfen, dass keine Uhr im Modul steckt**

Run: `grep -rn "DateTime.now()" lib/services/reminders/`
Expected: keine Treffer. Falls doch: durch den Parameter `now` ersetzen.

- [ ] **Step 6: Commit**

```bash
git add lib/services/reminders/reminder_rules.dart test/services/reminders/reminder_rules_budget_test.dart
git commit -m "feat(erinnerungen): Horizont und Budget mit sichtbarer Kuerzung"
```

---

### Task 10: Der einzige Schreiber — `ReminderScheduler`

**Files:**
- Create: `lib/services/reminders/reminder_scheduler.dart`
- Create: `test/helpers/fake_reminder_scheduler.dart`
- Test: (die Attrappe wird in Task 12 geprüft; hier nur ein Rauchtest)

**Interfaces:**
- Consumes: `Reminder`, `reminderId`, `isMedicationId`
- Produces:
```dart
abstract class ReminderScheduler {
  Future<Set<int>> pendingMedicationIds();
  Future<void> schedule(Reminder reminder, {required String title, required String body});
  Future<void> cancel(int id);
}
class PluginReminderScheduler implements ReminderScheduler { ... }
class FakeReminderScheduler implements ReminderScheduler { Map<int, Reminder> scheduled; List<int> cancelled; }
```

- [ ] **Step 1: Write the failing test**

```dart
// test/helpers/fake_reminder_scheduler.dart
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:dis_app/services/reminders/reminder_scheduler.dart';

/// Merkt sich, was angemeldet und abgemeldet wurde — ohne Plattform.
class FakeReminderScheduler implements ReminderScheduler {
  final Map<int, Reminder> scheduled = {};
  final List<int> cancelled = [];
  final List<String> bodies = [];

  /// Vorbelegung für den Ist-Zustand, etwa um Karteileichen zu prüfen.
  void seed(int id) => scheduled[id] = _placeholder;

  static final _placeholder = Reminder(
    dose: const DoseKey(
      medicationId: 'seed',
      date: DateTime(2000),
      scheduledTime: '00:00',
    ),
    kind: ReminderKind.due,
    fireAt: DateTime(2000),
  );

  @override
  Future<Set<int>> pendingMedicationIds() async =>
      scheduled.keys.where(isMedicationId).toSet();

  @override
  Future<void> schedule(
    Reminder reminder, {
    required String title,
    required String body,
  }) async {
    scheduled[reminderId(reminder)] = reminder;
    bodies.add(body);
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }
}
```

```dart
// test/services/reminders/reminder_scheduler_test.dart
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_reminder_scheduler.dart';

void main() {
  test('Die Attrappe meldet nur Medikamenten-Kennungen zurück', () async {
    final fake = FakeReminderScheduler()
      ..seed(namespacedId(kNamespaceEvent, 'termin-1'));
    await fake.schedule(
      Reminder(
        dose: const DoseKey(
          medicationId: 'm1',
          date: DateTime(2026, 8, 7),
          scheduledTime: '12:50',
        ),
        kind: ReminderKind.before10,
        fireAt: DateTime(2026, 8, 7, 12, 40),
      ),
      title: 'Titel',
      body: 'Text',
    );

    expect(await fake.pendingMedicationIds(), hasLength(1));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_scheduler_test.dart`
Expected: FAIL — `reminder_scheduler.dart` fehlt

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/services/reminders/reminder_scheduler.dart
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Wer beim Betriebssystem anmeldet und abmeldet.
///
/// Die Schnittstelle existiert, damit die Regeln und der Abgleich ohne
/// Plattform prüfbar sind — und damit es genau einen Ort gibt, an dem
/// `flutter_local_notifications` importiert wird. Eine Lint-Regel hält
/// das durch (siehe `dis_app_lints`).
abstract class ReminderScheduler {
  /// Was das Betriebssystem gerade vorgemerkt hat — nur Medikamente.
  Future<Set<int>> pendingMedicationIds();

  Future<void> schedule(
    Reminder reminder, {
    required String title,
    required String body,
  });

  Future<void> cancel(int id);
}

class PluginReminderScheduler implements ReminderScheduler {
  PluginReminderScheduler(this._plugin, {required this.channelId});

  final FlutterLocalNotificationsPlugin _plugin;
  final String channelId;

  @override
  Future<Set<int>> pendingMedicationIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((p) => p.id).where(isMedicationId).toSet();
  }

  @override
  Future<void> schedule(
    Reminder reminder, {
    required String title,
    required String body,
  }) async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    // Ohne die Freigabe für genaue Alarme wirft Android die Planung
    // zurück. Ungenau geplant kommt die Meldung ein paar Minuten später —
    // besser als gar nicht.
    final exact = await android?.canScheduleExactNotifications() ?? false;

    await _plugin.zonedSchedule(
      reminderId(reminder),
      title,
      body,
      tz.TZDateTime.from(reminder.fireAt, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          reminder.daily ? DateTimeComponents.time : null,
      payload: '${reminder.dose.medicationId}|${reminder.dose.scheduledTime}',
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/reminder_scheduler_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminders/reminder_scheduler.dart test/helpers/fake_reminder_scheduler.dart test/services/reminders/reminder_scheduler_test.dart
git commit -m "feat(erinnerungen): Schnittstelle zum Betriebssystem mit Attrappe"
```

---

### Task 11: Titel und Text, auch diskret

**Files:**
- Create: `lib/services/reminders/reminder_texts.dart`
- Test: `test/services/reminders/reminder_texts_test.dart`

**Interfaces:**
- Consumes: `Reminder`, `Medication`, `AppTexts.current` (bestehendes l10n-Bindeglied, siehe `lib/l10n/app_texts.dart`)
- Produces:
```dart
class ReminderTexts {
  ReminderTexts({required bool discreet});
  String title(Reminder reminder);
  String body(Reminder reminder, Medication medication);
}
```

Die Texte übernehmen wörtlich die bestehenden l10n-Schlüssel aus `notification_service.dart`: `notificationMedicationReminder`, `notificationMedicationBodyWithTime`, `notificationMedicationBodyNow`, `notificationMedicationAvailableSoon`, `notificationMedicationAvailableNow`, `notificationMedicationAvailableBody`, `notificationMedicationNotTakenYet`, `notificationDiscreetBody`.

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_texts_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_texts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final medikament = Medication(
    id: 'm1',
    name: 'Ritalin',
    dosage: '10mg',
    timesOfDay: const ['08:00'],
    profileIds: const ['lina'],
    createdAt: DateTime(2026, 8, 1),
  );

  final erinnerung = Reminder(
    dose: const DoseKey(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '08:00',
    ),
    kind: ReminderKind.before30,
    fireAt: DateTime(2026, 8, 7, 7, 30),
  );

  test('Im Klartext stehen Name und Dosis in der Meldung', () {
    final texte = ReminderTexts(discreet: false);
    expect(texte.body(erinnerung, medikament), contains('Ritalin'));
    expect(texte.body(erinnerung, medikament), contains('10mg'));
  });

  test('Diskret nennt weder Name noch Dosis', () {
    final texte = ReminderTexts(discreet: true);
    final text = texte.body(erinnerung, medikament);
    expect(text, isNot(contains('Ritalin')));
    expect(text, isNot(contains('10mg')));
    expect(texte.title(erinnerung), 'Aurora');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_texts_test.dart`
Expected: FAIL — Datei fehlt

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/services/reminders/reminder_texts.dart
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';

/// Was auf dem Bildschirm steht.
///
/// Eine Erinnerung erscheint auf dem Sperrbildschirm, also auch vor Augen,
/// die nicht dafür gedacht sind. „Ritalin 10mg jetzt nehmen" ist ein
/// Gesundheitsdatum. Der Schalter für diskrete Erinnerungen entscheidet
/// hier — und nur hier.
class ReminderTexts {
  ReminderTexts({required this.discreet});

  final bool discreet;

  String title(Reminder reminder) {
    if (discreet) return 'Aurora';
    final l10n = AppTexts.current;
    switch (reminder.kind) {
      case ReminderKind.available:
        return reminder.repeatIndex == 0
            ? l10n.notificationMedicationAvailableNow
            : l10n.notificationMedicationAvailableSoon;
      case ReminderKind.before30:
      case ReminderKind.before10:
      case ReminderKind.due:
      case ReminderKind.repeat:
      case ReminderKind.snooze:
        return l10n.notificationMedicationReminder;
    }
  }

  String body(Reminder reminder, Medication medication) {
    final l10n = AppTexts.current;
    if (discreet) return l10n.notificationDiscreetBody;

    switch (reminder.kind) {
      case ReminderKind.available:
        return l10n.notificationMedicationAvailableBody(medication.name);
      case ReminderKind.before30:
      case ReminderKind.before10:
        return l10n.notificationMedicationBodyWithTime(
          medication.name,
          medication.dosage,
          reminder.dose.scheduledTime,
        );
      case ReminderKind.due:
      case ReminderKind.snooze:
        return l10n.notificationMedicationBodyNow(
          medication.name,
          medication.dosage,
        );
      case ReminderKind.repeat:
        return '${l10n.notificationMedicationBodyNow(medication.name, medication.dosage)}'
            ' - ${l10n.notificationMedicationNotTakenYet}';
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/reminder_texts_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminders/reminder_texts.dart test/services/reminders/reminder_texts_test.dart
git commit -m "feat(erinnerungen): Meldungstexte inklusive diskreter Fassung"
```

---

### Task 12: Der Abgleich

**Files:**
- Create: `lib/services/reminders/reminder_reconciler.dart`
- Test: `test/services/reminders/reminder_reconciler_test.dart`

**Interfaces:**
- Consumes: `desiredReminders()`, `ReminderScheduler`, `ReminderTexts`, `reminderId`
- Produces:
```dart
class ReconcileResult {
  final int added, removed, kept, dropped;
}
class ReminderReconciler {
  ReminderReconciler({
    required ReminderScheduler scheduler,
    required List<Medication> Function() readMedications,
    required List<MedicationLog> Function() readLogs,
    required Future<bool> Function() readPermission,
    required bool Function() readDiscreet,
    DateTime Function() clock = DateTime.now,
  });
  Future<ReconcileResult> reconcile();
}
```

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_reconciler_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:dis_app/services/reminders/reminder_reconciler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_reminder_scheduler.dart';

void main() {
  late FakeReminderScheduler scheduler;
  final jetzt = DateTime(2026, 8, 7, 12, 0);

  final medikament = Medication(
    id: 'm1',
    name: 'Testmed',
    dosage: '1 Tablette',
    timesOfDay: const ['12:50'],
    profileIds: const ['lina'],
    createdAt: DateTime(2026, 8, 1),
  );

  ReminderReconciler baue({
    List<Medication> meds = const [],
    List<MedicationLog> logs = const [],
    bool erlaubt = true,
  }) =>
      ReminderReconciler(
        scheduler: scheduler,
        readMedications: () => meds,
        readLogs: () => logs,
        readPermission: () async => erlaubt,
        readDiscreet: () => false,
        clock: () => jetzt,
      );

  setUp(() => scheduler = FakeReminderScheduler());

  test('Der erste Lauf meldet die Sollmenge an', () async {
    final ergebnis = await baue(meds: [medikament]).reconcile();
    expect(ergebnis.added, greaterThan(0));
    expect(ergebnis.removed, 0);
    expect(scheduler.scheduled, isNotEmpty);
  });

  test('Der zweite Lauf ändert nichts', () async {
    final abgleich = baue(meds: [medikament]);
    await abgleich.reconcile();
    final zweiter = await abgleich.reconcile();
    expect(zweiter.added, 0);
    expect(zweiter.removed, 0);
    expect(zweiter.kept, greaterThan(0));
  });

  test('Karteileichen werden abgemeldet', () async {
    scheduler.seed(namespacedId(kNamespaceMedication, 'alt|irgendwas'));
    final ergebnis = await baue(meds: [medikament]).reconcile();
    expect(ergebnis.removed, 1);
  });

  test('Fremde Namensräume bleiben unangetastet', () async {
    final terminId = namespacedId(kNamespaceEvent, 'termin-1');
    scheduler.seed(terminId);
    await baue(meds: [medikament]).reconcile();
    expect(scheduler.cancelled, isNot(contains(terminId)));
    expect(scheduler.scheduled.containsKey(terminId), isTrue);
  });

  test('Ohne Erlaubnis wird alles abgemeldet', () async {
    await baue(meds: [medikament]).reconcile();
    final anzahl = scheduler.scheduled.length;
    expect(anzahl, greaterThan(0));

    final ergebnis = await baue(meds: [medikament], erlaubt: false).reconcile();
    expect(ergebnis.removed, anzahl);
    expect(await scheduler.pendingMedicationIds(), isEmpty);
  });

  test('Genommen räumt die Vorwarnungen ab — Befund 2', () async {
    await baue(meds: [medikament]).reconcile();
    final vorher = scheduler.scheduled.length;

    final ergebnis = await baue(
      meds: [medikament],
      logs: [
        MedicationLog(
          id: 'l1',
          medicationId: 'm1',
          takenAt: DateTime(2026, 8, 7, 12, 5),
          profileId: 'lina',
          status: MedicationStatus.taken,
          confirmedAt: DateTime(2026, 8, 7, 12, 5),
          scheduledTime: '12:50',
        ),
      ],
    ).reconcile();

    expect(ergebnis.removed, greaterThan(0));
    expect(scheduler.scheduled.length, lessThan(vorher));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/reminders/reminder_reconciler_test.dart`
Expected: FAIL — `reminder_reconciler.dart` fehlt

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/services/reminders/reminder_reconciler.dart
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:dis_app/services/reminders/reminder_scheduler.dart';
import 'package:dis_app/services/reminders/reminder_texts.dart';

/// Was ein Abgleich bewirkt hat.
class ReconcileResult {
  const ReconcileResult({
    required this.added,
    required this.removed,
    required this.kept,
    required this.dropped,
  });

  final int added;
  final int removed;
  final int kept;

  /// Wie viele Erinnerungen das Budget gekostet hat.
  final int dropped;
}

/// Bringt das Betriebssystem auf den berechneten Stand.
///
/// Die einzige Stelle, die Erinnerungen anmeldet oder abmeldet. Vorher war
/// das über neun Methoden verteilt, die einander nachliefen; wurde eine
/// Abbruchzeile vergessen, blieb ein Alarm als Karteileiche stehen. Hier
/// gibt es keine Abbruchzeile mehr, nur eine Differenz.
class ReminderReconciler {
  ReminderReconciler({
    required ReminderScheduler scheduler,
    required List<Medication> Function() readMedications,
    required List<MedicationLog> Function() readLogs,
    required Future<bool> Function() readPermission,
    required bool Function() readDiscreet,
    DateTime Function() clock = DateTime.now,
  })  : _scheduler = scheduler,
        _readMedications = readMedications,
        _readLogs = readLogs,
        _readPermission = readPermission,
        _readDiscreet = readDiscreet,
        _clock = clock;

  final ReminderScheduler _scheduler;
  final List<Medication> Function() _readMedications;
  final List<MedicationLog> Function() _readLogs;
  final Future<bool> Function() _readPermission;
  final bool Function() _readDiscreet;
  final DateTime Function() _clock;

  bool _running = false;

  Future<ReconcileResult> reconcile() async {
    // Zwei gleichzeitige Läufe würden einander die Differenz wegziehen.
    if (_running) {
      return const ReconcileResult(added: 0, removed: 0, kept: 0, dropped: 0);
    }
    _running = true;
    try {
      final medications = _readMedications();
      var dropped = 0;

      final desired = desiredReminders(
        medications: medications,
        logs: _readLogs(),
        notificationsAllowed: await _readPermission(),
        now: _clock(),
        onDropped: (count) => dropped = count,
      );

      final desiredById = {
        for (final reminder in desired) reminderId(reminder): reminder,
      };
      final pending = await _scheduler.pendingMedicationIds();

      final toRemove = pending.difference(desiredById.keys.toSet());
      final toAdd = desiredById.keys.toSet().difference(pending);

      for (final id in toRemove) {
        await _scheduler.cancel(id);
      }

      final texts = ReminderTexts(discreet: _readDiscreet());
      final byId = {for (final m in medications) m.id: m};
      for (final id in toAdd) {
        final reminder = desiredById[id]!;
        final medication = byId[reminder.dose.medicationId];
        if (medication == null) continue;
        await _scheduler.schedule(
          reminder,
          title: texts.title(reminder),
          body: texts.body(reminder, medication),
        );
      }

      final result = ReconcileResult(
        added: toAdd.length,
        removed: toRemove.length,
        kept: pending.length - toRemove.length,
        dropped: dropped,
      );

      logger.info(
        LogCategory.service,
        'ReminderReconciler: abgeglichen',
        data: {
          'added': result.added,
          'removed': result.removed,
          'kept': result.kept,
          'dropped': result.dropped,
        },
      );

      return result;
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'ReminderReconciler: Abgleich fehlgeschlagen',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      return const ReconcileResult(added: 0, removed: 0, kept: 0, dropped: 0);
    } finally {
      _running = false;
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/reminders/`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/reminders/reminder_reconciler.dart test/services/reminders/reminder_reconciler_test.dart
git commit -m "feat(erinnerungen): Abgleich gegen das Betriebssystem"
```

---

### Task 13: Anbindung — neun Methoden abbauen

**Files:**
- Modify: `lib/services/notification_service.dart`
- Modify: `lib/core/di/injection.dart`
- Test: `test/services/notification_reschedule_test.dart` (anpassen)

**Interfaces:**
- Consumes: `ReminderReconciler` aus Task 12
- Produces: `NotificationService.reconcileReminders()` als einziger Weg; `getIt<ReminderReconciler>()`

- [ ] **Step 1: `ReminderReconciler` registrieren**

In `lib/core/di/injection.dart`, nach der Registrierung von `NotificationService` und `MedicationService`:

```dart
  getIt.registerLazySingleton<ReminderScheduler>(
    () => PluginReminderScheduler(
      FlutterLocalNotificationsPlugin(),
      channelId: 'aurora_notifications',
    ),
  );

  getIt.registerLazySingleton<ReminderReconciler>(
    () => ReminderReconciler(
      scheduler: getIt<ReminderScheduler>(),
      readMedications: () => getIt<MedicationService>().allMedications,
      readLogs: () => getIt<MedicationService>().logsBox.values.toList(),
      readPermission: () => getIt<NotificationService>().hasPermission(),
      readDiscreet: () => getIt<NotificationService>().discreetReminders,
    ),
  );
```

- [ ] **Step 2: Ereignisbehandlung umstellen**

In `lib/services/notification_service.dart` die Rümpfe von `_onMedicationCreated`, `_onMedicationUpdated`, `_onMedicationDeleted`, `_onMedicationTaken`, `_handleLogUpdated`, `_handleLogDeleted` durch je einen Aufruf ersetzen:

```dart
  Future<void> _onMedicationCreated(MedicationCreatedEvent event) =>
      getIt<ReminderReconciler>().reconcile();
```

Für `MedicationLogUpdatedEvent` und `MedicationLogDeletedEvent` in `subscribeToEvents()` je eine Zeile ergänzen — heute hört der `NotificationService` auf beide nicht, weshalb eine Korrektur der Einnahme die Erinnerungen nicht berührte:

```dart
    eventBus.on<MedicationLogUpdatedEvent>().listen(
          (_) => getIt<ReminderReconciler>().reconcile(),
        );
    eventBus.on<MedicationLogDeletedEvent>().listen(
          (_) => getIt<ReminderReconciler>().reconcile(),
        );
```

- [ ] **Step 3: Neun Methoden löschen**

Ersatzlos entfernen: `scheduleMedicationReminders`, `cancelMedicationReminders`, `cancelRepeatReminders`, `_scheduleRepeatReminder`, `rescheduleMissingReminders`, `syncQueueWithPlatform`, `_startQueueTimer`, `_checkQueueAndSend`, `scheduleAvailabilityReminders`, `_cancelAvailabilityReminders`.

In `postInitialize()` die entsprechenden Aufrufe ersetzen:

```dart
      // Ein Abgleich statt drei Nachpflegeschritte.
      await getIt<ReminderReconciler>().reconcile();
```

`_queueCheckTimer` und `_isProcessingQueue` als Felder entfernen. `_sendNotification` bleibt für `sendTestNotification()` erhalten.

`countUnscheduledPromises()` bleibt — die Oberfläche nutzt es in Task 17.

- [ ] **Step 4: Bestehenden Test anpassen**

`test/services/notification_reschedule_test.dart` prüft `rescheduleMissingReminders()`, das es nicht mehr gibt. Der Test wird umgeschrieben auf `countUnscheduledPromises()`: er legt Medikamente mit `remindersEnabled` an, prüft, dass die Zahl stimmt, und dass sie nach einem Abgleich mit erteilter Erlaubnis auf null fällt. Der Abgleich läuft dabei gegen `FakeReminderScheduler`.

- [ ] **Step 5: Alle Tests laufen lassen**

Run: `flutter test`
Expected: PASS

- [ ] **Step 6: Lint**

Run: `dart run custom_lint`
Expected: keine neuen Meldungen

- [ ] **Step 7: Commit**

```bash
git add lib/services/notification_service.dart lib/core/di/injection.dart test/services/notification_reschedule_test.dart
git commit -m "refactor(erinnerungen): neun handgefuehrte Methoden durch einen Abgleich ersetzt"
```

---

### Task 14: Auslöser — Lebenszyklus und Erlaubniswechsel

**Files:**
- Modify: `lib/main.dart:1274` (`didChangeAppLifecycleState`)
- Modify: `lib/utils/reminder_permission.dart`
- Test: manuell (siehe Task 20); die Logik selbst ist eine Zeile je Stelle

**Interfaces:**
- Consumes: `getIt<ReminderReconciler>()`
- Produces: keine neuen Symbole

Die Erlaubnis kann in den Systemeinstellungen entzogen werden, ohne dass Aurora davon erfährt. Deshalb wird bei jedem Zurückkommen abgeglichen — nicht nur nach dem eigenen Dialog.

- [ ] **Step 1: Lebenszyklus**

In `lib/main.dart`, in `didChangeAppLifecycleState`:

```dart
    if (state == AppLifecycleState.resumed) {
      // Die Erlaubnis kann in den Systemeinstellungen entzogen worden
      // sein, der Tag kann gewechselt haben, die Zeitzone auch. Ein
      // Abgleich ist billig und idempotent.
      unawaited(getIt<ReminderReconciler>().reconcile());
    }
```

`import 'dart:async';` ergänzen, falls nicht vorhanden.

- [ ] **Step 2: Nach dem Erlaubnisdialog**

In `lib/utils/reminder_permission.dart` den Aufruf `service.rescheduleMissingReminders()` (Zeile 27) ersetzen:

```dart
  if (granted) {
    // Wer die Erlaubnis erst jetzt gibt, hat vorher womöglich schon
    // Medikamente angelegt. Der Abgleich holt sie nach.
    await getIt<ReminderReconciler>().reconcile();
    return true;
  }
```

- [ ] **Step 3: Nach dem Umschalten diskreter Erinnerungen**

In `lib/services/notification_service.dart`, in `setDiscreetReminders`, den Aufruf `syncQueueWithPlatform()` ersetzen durch:

```dart
    // Vorgemerkte Meldungen tragen ihren Wortlaut seit dem Vormerken mit
    // sich. Ohne neues Vormerken bliebe der alte Text stehen, und der
    // Schalter wäre ein Versprechen ohne Wirkung.
    await getIt<ReminderReconciler>().reconcile();
```

Damit der Abgleich den geänderten Wortlaut auch wirklich neu schreibt, muss er die Textfassung kennen. Erweitere `ReminderReconciler` um ein Feld, das die zuletzt verwendete Fassung hält, und erzwinge bei Wechsel ein vollständiges Neuschreiben:

```dart
  bool? _lastDiscreet;

  // in reconcile(), nach dem Lesen von desired:
  final discreet = _readDiscreet();
  final textsChanged = _lastDiscreet != null && _lastDiscreet != discreet;
  _lastDiscreet = discreet;

  // bei der Differenzbildung:
  final toAdd = textsChanged
      ? desiredById.keys.toSet()
      : desiredById.keys.toSet().difference(pending);
```

- [ ] **Step 4: Test für den Textwechsel**

```dart
// ergänzen in test/services/reminders/reminder_reconciler_test.dart
  test('Umschalten auf diskret schreibt die Texte neu', () async {
    var diskret = false;
    final abgleich = ReminderReconciler(
      scheduler: scheduler,
      readMedications: () => [medikament],
      readLogs: () => const [],
      readPermission: () async => true,
      readDiscreet: () => diskret,
      clock: () => jetzt,
    );

    await abgleich.reconcile();
    scheduler.bodies.clear();

    diskret = true;
    final ergebnis = await abgleich.reconcile();
    expect(ergebnis.added, greaterThan(0));
    expect(scheduler.bodies, isNotEmpty);
    expect(scheduler.bodies.every((b) => !b.contains('Testmed')), isTrue);
  });
```

- [ ] **Step 5: Run tests**

Run: `flutter test test/services/reminders/`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/main.dart lib/utils/reminder_permission.dart lib/services/notification_service.dart lib/services/reminders/reminder_reconciler.dart test/services/reminders/reminder_reconciler_test.dart
git commit -m "feat(erinnerungen): Abgleich bei Resume, Erlaubnis und Textwechsel"
```

---

### Task 15: Migration

**Files:**
- Modify: `lib/services/notification_service.dart`
- Test: `test/services/reminders/reminder_migration_test.dart`

**Interfaces:**
- Consumes: `ReminderScheduler`, `ReminderReconciler`
- Produces: `Future<void> migrateRemindersOnce()` in `NotificationService`

Der alte Bestand trägt Kennungen ohne Datum und ohne Namensraum. Karteileichen wie die zehn Alarme vom 05./06.08. würden sonst nie verschwinden, weil der Abgleich sie keinem Soll zuordnen kann.

- [ ] **Step 1: Write the failing test**

```dart
// test/services/reminders/reminder_migration_test.dart
import 'package:flutter_test/flutter_test.dart';

// Die Migration wird über einen Merker gesteuert; der Test prüft, dass
// sie genau einmal läuft. Aufbau analog zu
// test/services/notification_reschedule_test.dart (temporäres Hive,
// Adapter einzeln registrieren).
void main() {
  test('Die Migration läuft genau einmal', () async {
    // 1. settings-Box ohne Merker anlegen
    // 2. migrateRemindersOnce() aufrufen
    // 3. erwarten: cancelAll wurde aufgerufen, Merker steht
    // 4. migrateRemindersOnce() erneut aufrufen
    // 5. erwarten: cancelAll wurde kein zweites Mal aufgerufen
  }, skip: 'Rumpf in Schritt 3 dieses Tasks ausfüllen');
}
```

- [ ] **Step 2: Implementierung**

In `lib/services/notification_service.dart`:

```dart
  static const String kMigrationKey = 'reminders_migrated_v2';

  /// Einmaliges Aufräumen beim Umstieg auf den Abgleich.
  ///
  /// Der alte Bestand trägt Kennungen ohne Datum und ohne Namensraum. Der
  /// Abgleich könnte sie keinem Soll zuordnen und würde sie für immer
  /// stehen lassen — auf dem Testgerät waren das zehn Alarme aus zwei
  /// vergangenen Tagen.
  Future<void> migrateRemindersOnce() async {
    if (_settingsBox.get(kMigrationKey, defaultValue: false) as bool) return;

    await _notificationsPlugin.cancelAll();
    await _queueBox.clear();

    await getIt<ReminderReconciler>().reconcile();

    // Termine laufen in dieser Stufe noch über den alten Weg und wären
    // von cancelAll() mitgelöscht worden.
    final now = DateTime.now();
    for (final event in _eventsBox.values.where(
      (e) => e.startTime.isAfter(now) && e.notificationEnabled,
    )) {
      await scheduleEventReminder(event);
    }

    await _settingsBox.put(kMigrationKey, true);

    logger.info(
      LogCategory.service,
      'NotificationService: Erinnerungen auf den Abgleich umgestellt',
    );
  }
```

Aufruf in `postInitialize()`, vor dem ersten regulären Abgleich:

```dart
      await migrateRemindersOnce();
```

- [ ] **Step 3: Test ausfüllen und laufen lassen**

Den Rumpf aus Schritt 1 mit dem Aufbau aus `test/services/notification_reschedule_test.dart` füllen (temporäres Verzeichnis, `Hive.init`, Adapter einzeln registrieren, Boxen öffnen). Die Prüfung auf `cancelAll` läuft über `FakeReminderScheduler`, das dafür ein Feld `bool cancelAllCalled` und die Methode `Future<void> cancelAll()` bekommt; `ReminderScheduler` wird um diese Methode erweitert, `PluginReminderScheduler` reicht sie an `_plugin.cancelAll()` durch.

Run: `flutter test test/services/reminders/reminder_migration_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/services/notification_service.dart lib/services/reminders/reminder_scheduler.dart test/helpers/fake_reminder_scheduler.dart test/services/reminders/reminder_migration_test.dart
git commit -m "feat(erinnerungen): einmalige Migration raeumt alte Kennungen ab"
```

---

### Task 16: Lint-Regel — nur der Abgleich meldet an

**Files:**
- Create: `dis_app_lints/lib/src/no_direct_notification_plugin.dart`
- Modify: `dis_app_lints/lib/dis_app_lints.dart`

**Interfaces:**
- Consumes: nichts aus vorherigen Tasks
- Produces: Lint-Regel `no_direct_notification_plugin`

Ohne diese Regel ist die Einschreiberegel eine Bitte. Mit ihr ist sie eine Eigenschaft des Projekts.

- [ ] **Step 1: Bestehende Regel als Vorlage lesen**

Run: `cat dis_app_lints/lib/src/no_direct_gps_access.dart`

Die neue Regel folgt demselben Aufbau: `extends DartLintRule`, `LintCode` mit `problemMessage` und `correctionMessage`, `run()` registriert auf `addImportDirective`.

- [ ] **Step 2: Regel schreiben**

```dart
// dis_app_lints/lib/src/no_direct_notification_plugin.dart
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// `flutter_local_notifications` gehört in `lib/services/reminders/`.
///
/// Sieben Fehlverhalten der Medikamenten-Erinnerung hatten dieselbe
/// Ursache: mehrere Stellen meldeten Meldungen an und ab, und keine
/// wusste vom Zustand der anderen. Seit dem Abgleich gibt es genau einen
/// Schreiber. Diese Regel hält das durch.
class NoDirectNotificationPlugin extends DartLintRule {
  const NoDirectNotificationPlugin() : super(code: _code);

  static const _code = LintCode(
    name: 'no_direct_notification_plugin',
    problemMessage:
        'flutter_local_notifications darf nur in lib/services/reminders/ '
        'benutzt werden.',
    correctionMessage:
        'Nutze ReminderScheduler, oder loese den Abgleich ueber '
        'ReminderReconciler.reconcile() aus.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path.replaceAll(r'\', '/');
    if (path.contains('/lib/services/reminders/')) return;

    context.registry.addImportDirective((node) {
      final uri = node.uri.stringValue;
      if (uri == null) return;
      if (uri.startsWith('package:flutter_local_notifications')) {
        reporter.atNode(node, _code);
      }
    });
  }
}
```

- [ ] **Step 3: Registrieren**

In `dis_app_lints/lib/dis_app_lints.dart` die Regel der Liste in `getLintRules` hinzufügen, analog zu den drei bestehenden.

- [ ] **Step 4: Lint laufen lassen**

Run: `dart run custom_lint`
Expected: Meldungen nur dort, wo der Import noch übrig ist. In `notification_service.dart` bleibt er für `sendTestNotification()` und `cancelAll()` — beides wandert in Task 16b nach `ReminderScheduler`, damit die Regel sauber durchläuft.

- [ ] **Step 5: Restliche Aufrufe verschieben**

`sendTestNotification()` nutzt künftig `ReminderScheduler.showNow(title, body)`; die Methode wird zur Schnittstelle ergänzt und in `PluginReminderScheduler` mit `_plugin.show(...)` umgesetzt. Danach entfernt `notification_service.dart` den Import von `flutter_local_notifications` vollständig.

Run: `dart run custom_lint`
Expected: keine Meldungen

- [ ] **Step 6: Commit**

```bash
git add dis_app_lints/ lib/services/reminders/reminder_scheduler.dart lib/services/notification_service.dart
git commit -m "feat(lints): nur der Abgleich darf Meldungen anmelden"
```

---

### Task 17: Oberfläche — das Erlaubnisband

**Files:**
- Modify: `lib/modules/medication/medication_screen.dart`
- Modify: `lib/modules/medication/medication_form_screen.dart`
- Modify: `lib/l10n/app_de.arb`, `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_it.arb`
- Test: `test/modules/medication/reminder_permission_banner_test.dart`

**Interfaces:**
- Consumes: `NotificationService.hasPermission()`, `NotificationService.countUnscheduledPromises()`
- Produces: `class ReminderPermissionBanner extends StatelessWidget` in `lib/modules/medication/widgets/reminder_permission_banner.dart`

Befund 1: der Schalter stand auf an, die Karte trug ein Weckersymbol, und geplant war nichts.

- [ ] **Step 1: l10n-Schlüssel ergänzen**

In `lib/l10n/app_de.arb`:

```json
  "reminderPermissionMissingTitle": "Aurora darf gerade nicht erinnern",
  "@reminderPermissionMissingTitle": {
    "description": "Ueberschrift des Bandes, wenn POST_NOTIFICATIONS fehlt"
  },
  "reminderPermissionMissingBody": "Für {count} Einnahmezeiten sind Erinnerungen eingeschaltet. Ohne die Erlaubnis des Geräts kommt keine davon an.",
  "@reminderPermissionMissingBody": {
    "description": "Text des Bandes",
    "placeholders": { "count": { "type": "int" } }
  },
  "reminderPermissionMissingAction": "Erlaubnis geben",
  "@reminderPermissionMissingAction": {
    "description": "Knopf, der zum Systemdialog oder in die Einstellungen fuehrt"
  },
```

Dieselben drei Schlüssel in `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_it.arb` mit Übersetzung. `test/l10n/arb_completeness_test.dart` prüft die Vollständigkeit und schlägt sonst fehl.

Run: `flutter gen-l10n`

- [ ] **Step 2: Write the failing test**

```dart
// test/modules/medication/reminder_permission_banner_test.dart
import 'package:dis_app/modules/medication/widgets/reminder_permission_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget rahmen(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('Ohne offene Versprechen zeigt das Band nichts', (tester) async {
    await tester.pumpWidget(
      rahmen(
        ReminderPermissionBanner(
          hasPermission: false,
          openPromises: 0,
          onRequest: () {},
        ),
      ),
    );
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('Mit Erlaubnis zeigt das Band nichts', (tester) async {
    await tester.pumpWidget(
      rahmen(
        ReminderPermissionBanner(
          hasPermission: true,
          openPromises: 3,
          onRequest: () {},
        ),
      ),
    );
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('Ohne Erlaubnis und mit Versprechen erscheint das Band',
      (tester) async {
    var getippt = false;
    await tester.pumpWidget(
      rahmen(
        ReminderPermissionBanner(
          hasPermission: false,
          openPromises: 3,
          onRequest: () => getippt = true,
        ),
      ),
    );
    expect(find.byType(Card), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    expect(getippt, isTrue);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/modules/medication/reminder_permission_banner_test.dart`
Expected: FAIL — Datei fehlt

- [ ] **Step 4: Write minimal implementation**

```dart
// lib/modules/medication/widgets/reminder_permission_banner.dart
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Sagt, wenn Aurora ein Versprechen nicht halten kann.
///
/// Auf dem Testgerät stand der Schalter „Aurora erinnert dich" auf an, die
/// Karte trug ein Weckersymbol, und im Alarmspeicher war nichts. Im Log
/// eine Zeile: „Nothing rescheduled — still no permission". Was ein Mensch
/// nicht sehen kann, kann er nicht in Ordnung bringen.
///
/// Kein Rot: die Farbregel reserviert Sättigung für das, was im
/// schlechtesten Zustand gefunden werden muss. Ruhig, aber nicht zu
/// übersehen.
class ReminderPermissionBanner extends StatelessWidget {
  const ReminderPermissionBanner({
    required this.hasPermission,
    required this.openPromises,
    required this.onRequest,
    super.key,
  });

  final bool hasPermission;
  final int openPromises;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    if (hasPermission || openPromises == 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surfaceContainerHighest,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_off_outlined, color: scheme.onSurface),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.reminderPermissionMissingTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.reminderPermissionMissingBody(openPromises)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRequest,
                child: Text(l10n.reminderPermissionMissingAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/modules/medication/reminder_permission_banner_test.dart`
Expected: PASS (3 Tests)

- [ ] **Step 6: Einbauen**

In `lib/modules/medication/medication_screen.dart` das Band oberhalb der „Heute"-Karte einhängen. Zustand über einen `FutureBuilder<bool>` auf `getIt<NotificationService>().hasPermission()`, Zahl über `countUnscheduledPromises()`. `onRequest` ruft `ensureReminderPermission(context)` aus `lib/utils/reminder_permission.dart`.

In `lib/modules/medication/medication_form_screen.dart` dasselbe Band direkt unter dem Schalter „Aurora erinnert dich", sichtbar nur wenn der Schalter an ist.

- [ ] **Step 7: Alle Tests und Lint**

Run: `flutter test && dart run custom_lint`
Expected: PASS, keine Lint-Meldungen

- [ ] **Step 8: Commit**

```bash
git add lib/modules/medication/ lib/l10n/ test/modules/medication/reminder_permission_banner_test.dart
git commit -m "feat(medizin): Band zeigt fehlende Benachrichtigungserlaubnis"
```

---

### Task 18: Oberfläche — Korrigieren bleibt möglich

**Files:**
- Modify: `lib/modules/medication/widgets/medication_card.dart`
- Test: `test/modules/medication/medication_card_correction_test.dart`

**Interfaces:**
- Consumes: `MedicationStatus`, bestehende Rückrufe der Karte
- Produces: keine neuen Symbole; die Knopfreihe bleibt gerendert

Befund 5: nach „Später" und nach „Genommen" verschwand die Knopfreihe. Ein Fehlgriff war fest.

- [ ] **Step 1: Write the failing test**

```dart
// test/modules/medication/medication_card_correction_test.dart
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/modules/medication/widgets/medication_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final medikament = Medication(
    id: 'm1',
    name: 'Testmed',
    dosage: '1 Tablette',
    timesOfDay: const ['12:50'],
    profileIds: const ['lina'],
    createdAt: DateTime(2026, 8, 1),
  );

  MedicationLog log(MedicationStatus status) => MedicationLog(
        id: 'l1',
        medicationId: 'm1',
        takenAt: DateTime(2026, 8, 7, 12, 22),
        profileId: 'lina',
        status: status,
        confirmedAt: DateTime(2026, 8, 7, 12, 22),
        scheduledTime: '12:50',
      );

  for (final status in [
    MedicationStatus.taken,
    MedicationStatus.refused,
    MedicationStatus.snoozed,
  ]) {
    testWidgets('Nach ${status.name} bleiben alle drei Knöpfe erreichbar',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationCard(
              medication: medikament,
              scheduledTime: '12:50',
              log: log(status),
              onTaken: () {},
              onRefused: () {},
              onSnoozed: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('med-action-taken')), findsOneWidget);
      expect(find.byKey(const Key('med-action-refused')), findsOneWidget);
      expect(find.byKey(const Key('med-action-later')), findsOneWidget);
    });
  }
}
```

Die Parameter von `MedicationCard` sind an die tatsächliche Signatur in `lib/modules/medication/widgets/medication_card.dart` anzupassen — der Test wird gegen die vorhandene Schnittstelle geschrieben, nicht umgekehrt.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/modules/medication/medication_card_correction_test.dart`
Expected: FAIL — die Knopfreihe wird bei gesetztem Status nicht gerendert

- [ ] **Step 3: Write minimal implementation**

In `medication_card.dart` die Bedingung entfernen, die die Knopfreihe bei gesetztem Status ausblendet. Stattdessen:

- der gesetzte Status wird hervorgehoben (gefüllte Fläche, wie heute „Taken")
- die beiden anderen bleiben als Umriss sichtbar
- jeder Knopf bekommt einen `Key` (`med-action-taken`, `med-action-refused`, `med-action-later`)

Kommentar darüber:

```dart
    // Die Knöpfe bleiben nach der Entscheidung stehen.
    //
    // Vorher verschwanden sie: wer sich vertippte, kam ohne Umweg nicht
    // zurück. In einem System mit Wechseln und Erinnerungslücken muss
    // Korrigieren billiger sein als Festlegen.
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/modules/medication/`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/modules/medication/widgets/medication_card.dart test/modules/medication/medication_card_correction_test.dart
git commit -m "feat(medizin): gesetzter Status bleibt korrigierbar"
```

---

### Task 19: Oberfläche — ein Zeitformat, übersetzter Zeitwähler, sichtbare Profile

**Files:**
- Modify: `lib/modules/medication/widgets/medication_card.dart` (Snooze-Anzeige)
- Modify: `lib/modules/medication/widgets/intake_times_picker.dart` (Überschriften)
- Modify: `lib/modules/medication/medication_form_screen.dart` (Profilzuordnung)
- Modify: `lib/l10n/app_*.arb`
- Test: `test/modules/medication/intake_times_picker_test.dart` (erweitern)

**Interfaces:**
- Consumes: `AppLocalizations`
- Produces: l10n-Schlüssel `timePickerHours`, `timePickerMinutes`, `medicationAssignedProfiles`

Befund 8: „Stunden"/„Minuten" auf Deutsch in englischer Oberfläche, „1:21 PM" neben „12:50", stillschweigende Zuordnung zu allen Profilen.

- [ ] **Step 1: l10n-Schlüssel ergänzen**

In `lib/l10n/app_de.arb` und den vier weiteren Sprachdateien:

```json
  "timePickerHours": "Stunden",
  "@timePickerHours": { "description": "Spaltenueberschrift im Zeitwaehler" },
  "timePickerMinutes": "Minuten",
  "@timePickerMinutes": { "description": "Spaltenueberschrift im Zeitwaehler" },
  "medicationAssignedProfiles": "Gilt für: {names}",
  "@medicationAssignedProfiles": {
    "description": "Zeigt, welchen Profilen das Medikament zugeordnet ist",
    "placeholders": { "names": { "type": "String" } }
  },
```

Run: `flutter gen-l10n && flutter test test/l10n/arb_completeness_test.dart`

- [ ] **Step 2: Zeitwähler übersetzen**

In `lib/modules/medication/widgets/intake_times_picker.dart` die fest verdrahteten Zeichenketten `'Stunden'` und `'Minuten'` durch `l10n.timePickerHours` bzw. `l10n.timePickerMinutes` ersetzen.

Run: `grep -rn "'Stunden'\|'Minuten'" lib/`
Expected: keine Treffer mehr

- [ ] **Step 3: Ein Zeitformat**

In `medication_card.dart` die Snooze-Anzeige auf dieselbe Formatierung umstellen, die die Dosiszeit nutzt:

```dart
    // Ein Format je Oberfläche. Vorher stand „Reminder at 1:21 PM" über
    // „12:50" — zwei Uhren auf einer Karte.
    final zeit = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(snoozedUntil),
      alwaysUse24HourFormat:
          MediaQuery.of(context).alwaysUse24HourFormat,
    );
```

- [ ] **Step 4: Profilzuordnung sichtbar machen**

In `medication_form_screen.dart` unter dem Namensfeld eine Zeile ergänzen, die die zugeordneten Profile nennt, mit einem Knopf zum Ändern. Voreinstellung bleibt „alle Profile" — ein Körper ist ein Körper —, aber sichtbar.

- [ ] **Step 4b: Fokus nach dem Zeitwähler nicht zurückspringen lassen**

Nach `showDialog` des Zeitwählers landet der Eingabefokus wieder im Dosisfeld und die Tastatur öffnet sich. Wer danach scrollt, wischt über die Tastatur und schreibt Ziffern in die Dosis — im Gerätetest zweimal reproduziert („1 Tablette55"). Vor dem Öffnen des Wählers `FocusScope.of(context).unfocus()` aufrufen und nach dem Schließen den Fokus nicht wiederherstellen.

- [ ] **Step 5: Tests**

`test/modules/medication/intake_times_picker_test.dart` um eine Prüfung erweitern, dass die Überschriften aus `AppLocalizations` kommen (englischer Rahmen ⇒ „Hours"/„Minutes").

Run: `flutter test test/modules/medication/`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/modules/medication/ lib/l10n/ test/modules/medication/
git commit -m "fix(medizin): ein Zeitformat, uebersetzter Zeitwaehler, sichtbare Profile"
```

---

### Task 20: Prüfprotokoll auf dem Gerät

**Files:**
- Create: `docs/superpowers/plans/2026-08-07-pruefprotokoll-erinnerungen.md`
- Keine Quelltextänderung

Eine Attrappe beweist nicht, dass Android zustellt. Dieser Task ist der letzte vor der Freigabe und wird auf beiden Testgeräten gefahren: Galaxy S24 (`R3CX10FH1RP`, Android 16) und Galaxy A14 (`RF8W90CT0NN`, Android 15).

- [ ] **Step 1: Bauen und aufspielen**

```bash
flutter build apk --debug
adb -s R3CX10FH1RP install -r build/app/outputs/flutter-apk/app-debug.apk
```

- [ ] **Step 2: Ausgangslage festhalten**

```bash
adb -s R3CX10FH1RP shell dumpsys package com.disapp.dis_app | grep "POST_NOTIFICATIONS: granted"
adb -s R3CX10FH1RP shell dumpsys alarm | grep disapp | grep -o "OW=[0-9-]* [0-9:]*" | sort -u
```

Erwartet nach der Migration: keine Alarme aus vergangenen Tagen.

- [ ] **Step 3: Erlaubnis entziehen und Band prüfen**

```bash
adb -s R3CX10FH1RP shell pm revoke com.disapp.dis_app android.permission.POST_NOTIFICATIONS
```

App öffnen, Medizinbereich aufrufen. Erwartet: das Band aus Task 17 ist sichtbar und nennt die Zahl der offenen Einnahmezeiten. Erwartet in `dumpsys alarm`: keine Medikamenten-Alarme.

- [ ] **Step 4: Erlaubnis geben, Planung prüfen**

Über das Band die Erlaubnis erteilen. Erwartet: für jedes aktive Medikament erscheinen Vorwarnungen und eine täglich wiederkehrende Meldung.

- [ ] **Step 5: Genommen räumt ab — Befund 2**

Ein Medikament mit einer Zeit in etwa einer Stunde anlegen. Alarme notieren. „Genommen" tippen. Erneut prüfen:

```bash
adb -s R3CX10FH1RP shell dumpsys alarm | grep disapp | grep -o "OW=[0-9-]* [0-9:]*" | sort -u
```

Erwartet: die Vorwarnungen dieser Dosis sind weg, die tägliche Meldung ist auf morgen verankert.

- [ ] **Step 6: Später verschiebt — Befund 3 und 4**

Zweites Medikament mit einer Zeit in etwa 40 Minuten anlegen. Auf die 30-Minuten-Vorwarnung „Später" tippen. Erwartet: genau ein Alarm für diese Dosis, und zwar zur Dosiszeit. Die 10-Minuten-Vorwarnung ist weg.

- [ ] **Step 7: Zustellung bei geschlossener App — Befund 7**

```bash
adb -s R3CX10FH1RP shell input keyevent 187   # letzte Apps
# Aurora-Karte nach oben wischen
adb -s R3CX10FH1RP shell pidof com.disapp.dis_app   # erwartet: leer
```

Bis zur Dosiszeit warten, dann:

```bash
adb -s R3CX10FH1RP shell "dumpsys notification --noredact" | grep -A25 "pkg=com.disapp" | grep -E "android.title=|android.text="
```

Erwartet: die Meldung liegt an, der Prozess war vorher tot. **Kommt sie nicht, ist § 3.4 der Spec hinfällig** — dann braucht es eine Hintergrundausführung und einen Hinweis zur Akkuoptimierung; das wäre ein eigener Plan.

- [ ] **Step 8: Ergebnisse festhalten und Testdaten entfernen**

Beide Testmedikamente in der App löschen. Ergebnisse in `docs/superpowers/plans/2026-08-07-pruefprotokoll-erinnerungen.md` eintragen — je Schritt: erwartet, beobachtet, Gerät, Uhrzeit.

- [ ] **Step 9: Commit**

```bash
git add docs/superpowers/plans/2026-08-07-pruefprotokoll-erinnerungen.md
git commit -m "docs: Pruefprotokoll der Erinnerungen auf beiden Geraeten"
```

---

## Nicht in diesem Plan

- **Handlungen an der Meldung** („Genommen" vom Sperrbildschirm) — Stufe 2 der Spec, § 6. Eigener Plan, weil der Hintergrund-Isolate eigene Hive-Fragen aufwirft.
- **Kalendertermine im Abgleich** — Stufe 3 der Spec, § 7. Die Namensräume aus Task 2 bereiten es vor.
- **Einstellbare Aufschubdauer und Wiederholungszahl** — offene Punkte der Spec, § 11. Erst fragen, dann bauen.
