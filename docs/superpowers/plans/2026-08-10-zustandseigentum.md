# Zustandseigentum — Umsetzungsplan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Die Settings-Box bekommt einen Eigentümer, der Aufzeichnungszustand wird ein Typ, und eine Lint hält beides — damit die vier Codex-Befunde als Klasse geschlossen sind, nicht als Einzelfälle.

**Architecture:** `AppSettings` kapselt die Hive-Settings-Box und gibt je Schlüssel einen typisierten Zugang plus `ValueListenable`. `LocationTrackingService` veröffentlicht `TrackingState` (Wunsch + Laufzustand) statt eines rohen Schlüssels. `DataEntry` reicht keine `Box<dynamic>` mehr durch; eine siebte custom_lint-Regel macht den Rückweg unmöglich.

**Tech Stack:** Flutter, Hive (`box.listenable()`), GetIt, `custom_lint_builder`, `package:meta` (`@useResult`), `flutter_test`.

## Global Constraints

- Projektsprache in Kommentaren, Dokumentation und Commit-Nachrichten ist Deutsch; Bezeichner im Code sind gemischt (bestehendem Umfeld folgen).
- Alle Datenoperationen der Oberfläche laufen über `DataEntry` (`no_direct_service_access`).
- Keine absoluten Pfade in der Datenbank; keine Standortdaten in gesendeten Nutzlasten.
- Zeichenketten der Oberfläche kommen aus `l10n`; neue Texte brauchen Einträge in `app_de.arb` und `app_en.arb` (die übrigen Sprachen ziehen im Sammellauf nach).
- `logger.error` nimmt `data` und `stackTrace`, **keinen** `error:`-Parameter.
- Prüfbefehle: `flutter analyze`, `dart run custom_lint`, `flutter test`.
- Keine Datenmigration: die Hive-Schlüssel bleiben unverändert.

---

### Task 1: Arbeitsbaum klären und `main` veröffentlichen

Der Baum trägt ~94 Dateien aus einem `dart fix`-Lauf und `main` hat 19 unveröffentlichte Commits. Solange das so bleibt, ist jeder Refactor-Diff mit Formatierungsrauschen vermischt und jedes Codex-Review wertlos. Aus der Projekterfahrung: derselbe `dart fix`-Lauf hat zweimal den Build gebrochen und dreimal bewusste Explizitheit entfernt — grüne Tests genügen als Beleg **nicht**.

**Files:**
- Modify: der gesamte Arbeitsbaum (keine inhaltliche Änderung durch diese Aufgabe)

**Interfaces:**
- Consumes: nichts
- Produces: sauberer Arbeitsbaum, `origin/main` auf Stand — Voraussetzung aller folgenden Tasks

- [ ] **Step 1: Entfernte Argumente sichten**

```bash
git diff -U0 -- lib/ test/ | grep -E "^-" | grep -vE "^---" | grep -E "ignore:|const |explicit|: true|: false" | head -40
```

Jede Zeile, in der `dart fix` ein **ausgeschriebenes** Argument entfernt hat, ist verdächtig: das Projekt schreibt Standardwerte absichtlich aus (siehe `location_tracking_service.dart:258`, `// ignore: avoid_redundant_argument_values`). Wo ein solcher Kommentar oder ein erklärender Kommentar direkt darüber steht, die Änderung mit `git checkout -- <datei>` zurücknehmen.

- [ ] **Step 2: Analyse und Tests**

Run: `flutter analyze`
Expected: keine Fehler

Run: `flutter test`
Expected: alle Tests grün

- [ ] **Step 3: Formatierungslauf als eigenen Commit ablegen**

```bash
git add -A
git commit -m "chore: dart-fix-Lauf uebernehmen

Reine Formatierung und Importsortierung. Getrennt committet, damit die
folgende Architekturarbeit einen lesbaren Diff hat. Zurueckgenommen wurden
die Stellen, an denen der Lauf ausgeschriebene Standardwerte entfernt hat --
die stehen dort absichtlich."
```

- [ ] **Step 4: `main` veröffentlichen**

```bash
git push origin main
```

- [ ] **Step 5: PR #28 prüfen**

Run: `gh pr view 28 --json files --jq '[.files[].path]|length'`
Expected: 2 (nur `AGENTS.md` und `CLAUDE.md`) — die Basis ist nachgerückt.

---

### Task 2: Ergebnisse, die man nicht ignorieren darf

**Files:**
- Modify: `pubspec.yaml` (meta als direkte Abhängigkeit)
- Modify: `analysis_options.yaml`
- Modify: `lib/core/delete_all_data.dart:67`
- Modify: `lib/widgets/startup_failure_screen.dart:69-77`
- Modify: `lib/l10n/app_de.arb`, `lib/l10n/app_en.arb`
- Test: `test/widgets/startup_failure_screen_test.dart`

**Interfaces:**
- Consumes: `DeleteAllResult` aus `lib/core/delete_all_data.dart` (Felder: `List<String> failedSteps`, `bool get isComplete`)
- Produces: `@useResult Future<DeleteAllResult> deleteAllLocalData()`

- [ ] **Step 1: Ausmaß messen, bevor die Regel greift**

```bash
dart analyze --fatal-infos 2>&1 | grep -c unused_result || true
```

Notiere die Zahl. Sind es mehr als fünf Stellen außerhalb des Löschpfads, wird `unused_result` in diesem Task **nicht** auf `error` gehoben, sondern nur `@useResult` gesetzt; das Heben bekommt dann einen eigenen Task. Alles andere zieht diesen Task ins Unabsehbare.

- [ ] **Step 2: Fehlschlagenden Test schreiben**

```dart
// test/widgets/startup_failure_screen_test.dart
testWidgets('unvollstaendiges Loeschen startet nicht still neu', (tester) async {
  var retryAufgerufen = false;
  await tester.pumpWidget(
    StartupFailureApp(
      onRetry: () async {
        retryAufgerufen = true;
      },
      deleteAllData: () async => const DeleteAllResult(['reminders']),
    ),
  );

  await tester.tap(find.text('Alle Daten löschen'));
  await tester.pumpAndSettle();

  expect(retryAufgerufen, isFalse,
      reason: 'Ein Teilerfolg darf nicht wie ein Erfolg aussehen');
  expect(find.text('Nicht alles konnte gelöscht werden'), findsOneWidget);
});
```

- [ ] **Step 3: Test laufen lassen, Fehlschlag bestätigen**

Run: `flutter test test/widgets/startup_failure_screen_test.dart`
Expected: FAIL — `StartupFailureApp` kennt den Parameter `deleteAllData` nicht

- [ ] **Step 4: `@useResult` setzen**

```dart
// lib/core/delete_all_data.dart
import 'package:meta/meta.dart';

@useResult
Future<DeleteAllResult> deleteAllLocalData() async {
```

`pubspec.yaml`, Abschnitt `dependencies`:

```yaml
  meta: ^1.15.0
```

- [ ] **Step 5: Aufrufstelle reparieren**

```dart
// lib/widgets/startup_failure_screen.dart
TextButton(
  onPressed: _busy
      ? null
      : () => _run(() async {
            final ergebnis = await widget.deleteAllData();
            if (!ergebnis.isComplete) {
              setState(() => _unvollstaendig = true);
              return;
            }
            await widget.onRetry();
          }),
  child: Text(l10n.startupDeleteAll),
),
```

Das Feld `_unvollstaendig` blendet über den Knöpfen einen Hinweis ein:

```dart
if (_unvollstaendig) ...[
  Text(
    l10n.startupDeleteIncomplete,
    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
    textAlign: TextAlign.center,
  ),
  const SizedBox(height: 16),
],
```

`StartupFailureScreen` und `StartupFailureApp` bekommen beide den Parameter
`Future<DeleteAllResult> Function() deleteAllData` mit `deleteAllLocalData` als
Vorgabe — sonst ist die Fläche nicht testbar, ohne echte Boxen zu löschen.

- [ ] **Step 6: Texte ergänzen**

`lib/l10n/app_de.arb`: `"startupDeleteIncomplete": "Nicht alles konnte gelöscht werden"`
`lib/l10n/app_en.arb`: `"startupDeleteIncomplete": "Some data could not be deleted"`

Run: `flutter gen-l10n`

- [ ] **Step 7: `unused_result` heben** (nur wenn Step 1 höchstens fünf Fundstellen zeigte)

```yaml
# analysis_options.yaml, im Block analyzer:
  errors:
    unused_result: error
```

- [ ] **Step 8: Prüfen**

Run: `flutter test test/widgets/startup_failure_screen_test.dart`
Expected: PASS

Run: `flutter analyze`
Expected: keine Fehler

- [ ] **Step 9: Commit**

```bash
git add pubspec.yaml analysis_options.yaml lib/core/delete_all_data.dart lib/widgets/startup_failure_screen.dart lib/l10n/ test/widgets/startup_failure_screen_test.dart
git commit -m "fix(loeschen): ein Teilerfolg startet nicht mehr still neu"
```

---

### Task 3: Der Start wird wiederholbar

**Files:**
- Modify: `lib/core/di/injection.dart:92-99` (und alle weiteren `registerAdapter`-Zeilen darunter)
- Test: `test/core/injection_idempotent_test.dart`

**Interfaces:**
- Consumes: nichts
- Produces: `setupEssentialDependencies()` ist mehrfach aufrufbar

- [ ] **Step 1: Fehlschlagenden Test schreiben**

```dart
// test/core/injection_idempotent_test.dart
test('zweiter Startanlauf stolpert nicht ueber den ersten', () async {
  await setupEssentialDependencies();
  await getIt.reset();

  // Vor der Korrektur wirft der zweite Lauf:
  // "There is already a TypeAdapter for typeId 0"
  await expectLater(setupEssentialDependencies(), completes);
});
```

- [ ] **Step 2: Test laufen lassen, Fehlschlag bestätigen**

Run: `flutter test test/core/injection_idempotent_test.dart`
Expected: FAIL mit `HiveError: There is already a TypeAdapter for typeId ...`

- [ ] **Step 3: Registrierung guarden**

```dart
// lib/core/di/injection.dart
void _registerAdapter<T>(TypeAdapter<T> adapter) {
  if (Hive.isAdapterRegistered(adapter.typeId)) return;
  Hive.registerAdapter(adapter);
}
```

Alle `Hive.registerAdapter(XAdapter());`-Zeilen werden zu
`_registerAdapter(XAdapter());`. Die globale Adapterregistratur überlebt
`getIt.reset()` — sie gehört nicht der DI, deshalb muss der Start sie selbst
prüfen.

- [ ] **Step 4: Test laufen lassen**

Run: `flutter test test/core/injection_idempotent_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/di/injection.dart test/core/injection_idempotent_test.dart
git commit -m "fix(start): der zweite Anlauf stolpert nicht mehr ueber den ersten"
```

---

### Task 4: Ein Kalendertag ist keine Zeitspanne

**Files:**
- Modify: `lib/modules/calendar/calendar_view_logic.dart:67`
- Test: `test/modules/calendar/calendar_view_logic_test.dart`

**Interfaces:**
- Consumes: `CalendarAgenda.fromEvents(Iterable<CalendarEvent>, {required DateTime today})`
- Produces: unverändertes API, korrektes Verhalten an Umstellungstagen

- [ ] **Step 1: Fehlschlagenden Test schreiben**

Deutschland stellt am 29. März 2026 um 02:00 auf Sommerzeit um. `Duration(days: 1)`
auf Mitternacht ergibt dort **01:00 des Folgetags** — ein Termin um 00:30 fällt
danach weder unter „heute" noch unter „kommend".

```dart
// test/modules/calendar/calendar_view_logic_test.dart
test('Termin nach Mitternacht verschwindet an der Zeitumstellung nicht', () {
  final termin = CalendarEvent(
    id: 'dst',
    title: 'Nachtschicht',
    startTime: DateTime(2026, 3, 29, 0, 30),
  );

  final agenda = CalendarAgenda.fromEvents(
    [termin],
    today: DateTime(2026, 3, 28, 12),
  );

  expect(agenda.upcoming, contains(termin));
});
```

- [ ] **Step 2: Test laufen lassen**

Run: `flutter test test/modules/calendar/calendar_view_logic_test.dart`
Expected: FAIL in einer Zeitzone mit Sommerzeit — `upcoming` ist leer

- [ ] **Step 3: Kalenderarithmetik verwenden**

```dart
// lib/modules/calendar/calendar_view_logic.dart
final startOfTomorrow = DateTime(
  startOfToday.year,
  startOfToday.month,
  startOfToday.day + 1,
);
```

Dasselbe Muster steht zwei Funktionen weiter oben bereits richtig in
`durationUntilNextDay` (Zeile 48). `DateTime` normalisiert einen überlaufenden
Tageswert selbst und rechnet dabei über die Umstellung hinweg.

- [ ] **Step 4: Test laufen lassen**

Run: `flutter test test/modules/calendar/calendar_view_logic_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/modules/calendar/calendar_view_logic.dart test/modules/calendar/calendar_view_logic_test.dart
git commit -m "fix(kalender): der naechste Tag ist ein Datum, keine 24 Stunden"
```

---

### Task 5: `AppSettings` bekommt die Box

**Files:**
- Create: `lib/core/settings/app_settings.dart`
- Test: `test/core/settings/app_settings_test.dart`

**Interfaces:**
- Consumes: `Box<dynamic>` der Einstellungen aus `ProfileService`
- Produces:
  - `class AppSettings { AppSettings(Box<dynamic> box); }`
  - `String? get activeProfileId` / `Future<void> setActiveProfileId(String?)`
  - `String? get selectedLocale` / `Future<void> setSelectedLocale(String?)`
  - `bool get globalTrackingAlwaysOn` / `Future<void> setGlobalTrackingAlwaysOn(bool)`
  - `bool get preOnboardingDismissed` / `Future<void> setPreOnboardingDismissed(bool)`
  - `int get currentPageIndex` / `Future<void> setCurrentPageIndex(int)`
  - `String get timeFormatPreference` / `Future<void> setTimeFormatPreference(String)`
  - `bool get debugModeEnabled` / `Future<void> setDebugModeEnabled(bool)`
  - `bool postLoginWelcomeDismissed(String profileId)` / `Future<void> setPostLoginWelcomeDismissed(String profileId, bool)`
  - `ValueListenable<Box<dynamic>> listenableFor(List<String> keys)`

`gps_tracking_enabled` fehlt in dieser Liste **mit Absicht** — der Schlüssel
gehört ab Task 6 dem Aufzeichnungsdienst.

- [ ] **Step 1: Fehlschlagenden Test schreiben**

```dart
// test/core/settings/app_settings_test.dart
late Box<dynamic> box;
late AppSettings settings;

setUp(() async {
  box = await Hive.openBox<dynamic>('settings_test');
  settings = AppSettings(box);
});

tearDown(() async => box.deleteFromDisk());

test('liefert typisierte Vorgaben ohne Wert in der Box', () {
  expect(settings.globalTrackingAlwaysOn, isFalse);
  expect(settings.currentPageIndex, 0);
  expect(settings.activeProfileId, isNull);
});

test('schreibt und liest je Profil getrennt', () async {
  await settings.setPostLoginWelcomeDismissed('p1', true);

  expect(settings.postLoginWelcomeDismissed('p1'), isTrue);
  expect(settings.postLoginWelcomeDismissed('p2'), isFalse);
});

test('meldet nur die genannten Schluessel', () async {
  final listenable = settings.listenableFor([AppSettings.keyCurrentPageIndex]);
  var rufe = 0;
  listenable.addListener(() => rufe++);

  await settings.setDebugModeEnabled(true);
  expect(rufe, 0, reason: 'ein fremder Schluessel darf nicht wecken');

  await settings.setCurrentPageIndex(2);
  expect(rufe, 1);
});
```

- [ ] **Step 2: Test laufen lassen**

Run: `flutter test test/core/settings/app_settings_test.dart`
Expected: FAIL — `AppSettings` gibt es nicht

- [ ] **Step 3: `AppSettings` schreiben**

```dart
// lib/core/settings/app_settings.dart
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Eigentümer der Einstellungs-Box.
///
/// Die Box bleibt privat. Wer eine Einstellung braucht, bekommt einen Namen
/// und einen Typ — nicht einen Schlüssel und ein `as bool`. Ein falsch
/// gelesener Schlüssel ist in dieser App kein Schönheitsfehler: derselbe
/// Fehler hat die Wegaufzeichnung stillgelegt, während die Oberfläche
/// „läuft" anzeigte.
class AppSettings {
  const AppSettings(this._box);

  final Box<dynamic> _box;

  static const keyActiveProfileId = 'active_profile_id';
  static const keySelectedLocale = 'selected_locale';
  static const keyGlobalTrackingAlwaysOn = 'global_tracking_always_on';
  static const keyPreOnboardingDismissed = 'pre_onboarding_dismissed';
  static const keyCurrentPageIndex = 'current_page_index';
  static const keyTimeFormatPreference = 'time_format_preference';
  static const keyDebugModeEnabled = 'debug_mode_enabled';

  String? get activeProfileId => _box.get(keyActiveProfileId) as String?;
  Future<void> setActiveProfileId(String? wert) =>
      _box.put(keyActiveProfileId, wert);

  String? get selectedLocale => _box.get(keySelectedLocale) as String?;
  Future<void> setSelectedLocale(String? wert) =>
      _box.put(keySelectedLocale, wert);

  bool get globalTrackingAlwaysOn =>
      _box.get(keyGlobalTrackingAlwaysOn, defaultValue: false) as bool;
  Future<void> setGlobalTrackingAlwaysOn(bool wert) =>
      _box.put(keyGlobalTrackingAlwaysOn, wert);

  bool get preOnboardingDismissed =>
      _box.get(keyPreOnboardingDismissed, defaultValue: false) as bool;
  Future<void> setPreOnboardingDismissed(bool wert) =>
      _box.put(keyPreOnboardingDismissed, wert);

  int get currentPageIndex =>
      _box.get(keyCurrentPageIndex, defaultValue: 0) as int;
  Future<void> setCurrentPageIndex(int wert) =>
      _box.put(keyCurrentPageIndex, wert);

  String get timeFormatPreference =>
      _box.get(keyTimeFormatPreference, defaultValue: 'system') as String;
  Future<void> setTimeFormatPreference(String wert) =>
      _box.put(keyTimeFormatPreference, wert);

  bool get debugModeEnabled =>
      _box.get(keyDebugModeEnabled, defaultValue: false) as bool;
  Future<void> setDebugModeEnabled(bool wert) =>
      _box.put(keyDebugModeEnabled, wert);

  static String keyPostLoginWelcomeDismissed(String profileId) =>
      'post_login_welcome_dismissed_$profileId';

  bool postLoginWelcomeDismissed(String profileId) => _box.get(
        keyPostLoginWelcomeDismissed(profileId),
        defaultValue: false,
      ) as bool;

  Future<void> setPostLoginWelcomeDismissed(String profileId, bool wert) =>
      _box.put(keyPostLoginWelcomeDismissed(profileId), wert);

  /// Reaktiver Zugang für `ValueListenableBuilder`.
  ///
  /// Nimmt die Schlüssel entgegen, auf die es ankommt. Ohne diese Einengung
  /// baut jede Oberfläche bei jeder fremden Einstellung neu.
  ValueListenable<Box<dynamic>> listenableFor(List<String> keys) =>
      _box.listenable(keys: keys);
}
```

- [ ] **Step 4: Test laufen lassen**

Run: `flutter test test/core/settings/app_settings_test.dart`
Expected: PASS

- [ ] **Step 5: In der DI registrieren**

```dart
// lib/core/di/injection.dart, nach der Registrierung von ProfileService
getIt.registerLazySingleton<AppSettings>(
  () => AppSettings(getIt<ProfileService>().settingsBox),
);
```

- [ ] **Step 6: Commit**

```bash
git add lib/core/settings/ lib/core/di/injection.dart test/core/settings/
git commit -m "feat(einstellungen): die Box bekommt einen Eigentuemer"
```

---

### Task 6: Der Aufzeichnungszustand wird ein Typ

Das ist der Beweisfall der ganzen Arbeit: `settings_screen.dart:591` liest heute
den **Wunsch** und schließt daraus, die Aufzeichnung **laufe**. Nach einem
Stromabbruch steht der Wunsch auf `true`, es läuft nichts, und weil der Wunsch
`true` ist, wird nicht gestartet.

**Files:**
- Create: `lib/services/tracking_state.dart`
- Modify: `lib/services/location_tracking_service.dart` (Felder, `_autoStartIfWanted` bei :147, `startTracking`, `_stopTracking`, `onError` bei :264)
- Modify: `lib/modules/settings/settings_screen.dart:591`
- Test: `test/services/location_tracking_state_test.dart`

**Interfaces:**
- Consumes: `AppSettings` aus Task 5
- Produces:
  - `class TrackingState { const TrackingState({required bool gewuenscht, required bool laeuft}); final bool gewuenscht; final bool laeuft; }`
  - `ValueListenable<TrackingState> get trackingState` auf `LocationTrackingService`

- [ ] **Step 1: Fehlschlagenden Test schreiben**

Der Dienst wird mit sechs benannten Pflichtparametern gebaut
(`locationHistoryBox`, `switchEventsBox`, `settingsBox`, `eventBus`,
`geocodingService`, `gpsManager`) und bekommt in diesem Task einen siebten:
`required AppSettings settings`. Den Aufbau der Testfixtures **eins zu eins aus
`test/services/location_tracking_foreground_test.dart` übernehmen** — dort steht
er bereits mit Fake-GPS und Wegwerf-Boxen. Unten steht nur, was neu ist; der
Platzhalter `dienstBauen()` steht für genau diesen übernommenen Aufbau.

```dart
// test/services/location_tracking_state_test.dart
test('nach Stromabbruch bleibt der Wunsch, der Lauf faellt', () async {
  final dienst = dienstBauen();
  await dienst.startTracking();

  expect(dienst.trackingState.value.laeuft, isTrue);
  expect(dienst.trackingState.value.gewuenscht, isTrue);

  fakeGpsManager.emitError(Exception('GPS aus'));
  await Future<void>.delayed(Duration.zero);

  expect(dienst.trackingState.value.laeuft, isFalse,
      reason: 'der Lauf ist zu Ende');
  expect(dienst.trackingState.value.gewuenscht, isTrue,
      reason: 'niemand hat aufgehoert, es zu wollen');
});

test('globales Einschalten startet auch bei stehendem Wunsch', () async {
  final dienst = dienstBauen();
  await dienst.startTracking();
  fakeGpsManager.emitError(Exception('GPS aus'));
  await Future<void>.delayed(Duration.zero);

  // Genau der Fall aus settings_screen.dart:591
  if (!dienst.trackingState.value.laeuft) {
    await dienst.toggleTracking();
  }

  expect(dienst.trackingState.value.laeuft, isTrue);
});
```

- [ ] **Step 2: Test laufen lassen**

Run: `flutter test test/services/location_tracking_state_test.dart`
Expected: FAIL — `trackingState` gibt es nicht

- [ ] **Step 3: `TrackingState` schreiben**

```dart
// lib/services/tracking_state.dart
import 'package:flutter/foundation.dart';

/// Wunsch und Lauf sind zwei Dinge.
///
/// Der Wunsch überlebt den Neustart; der Lauf kippt, sobald das System die
/// Positionen nicht mehr liefert. Sie in einem `bool` zusammenzufassen hat
/// die Aufzeichnung stillgelegt, während die Oberfläche „läuft" meinte.
@immutable
class TrackingState {
  const TrackingState({required this.gewuenscht, required this.laeuft});

  final bool gewuenscht;
  final bool laeuft;

  TrackingState copyWith({bool? gewuenscht, bool? laeuft}) => TrackingState(
        gewuenscht: gewuenscht ?? this.gewuenscht,
        laeuft: laeuft ?? this.laeuft,
      );

  @override
  bool operator ==(Object other) =>
      other is TrackingState &&
      other.gewuenscht == gewuenscht &&
      other.laeuft == laeuft;

  @override
  int get hashCode => Object.hash(gewuenscht, laeuft);
}
```

- [ ] **Step 4: Dienst umstellen**

Im `LocationTrackingService`:

```dart
final ValueNotifier<TrackingState> _trackingState =
    ValueNotifier(const TrackingState(gewuenscht: false, laeuft: false));

ValueListenable<TrackingState> get trackingState => _trackingState;
```

- `startTracking()` setzt `laeuft: true`, schreibt den Wunsch über
  `_settings` und setzt `gewuenscht: true`.
- `_stopTracking()` setzt beides auf `false`.
- Der `onError`-Zweig bei Zeile 264 setzt **nur** `laeuft: false`; der
  erklärende Kommentar bleibt, er beschreibt jetzt den Typ statt eine
  Vereinbarung.
- `_autoStartIfWanted()` (Zeile 147) liest den Wunsch aus dem eigenen Zustand
  und `globalTrackingAlwaysOn` aus `AppSettings` statt zweimal roh aus der Box.
- Der Schlüssel `gps_tracking_enabled` wird ausschließlich hier gelesen und
  geschrieben; er bekommt eine private Konstante im Dienst.

- [ ] **Step 5: Aufrufstelle in den Einstellungen umstellen**

```dart
// lib/modules/settings/settings_screen.dart, statt Zeile 591-594
if (!_trackingService.trackingState.value.laeuft) {
  await _trackingService.toggleTracking();
}
```

- [ ] **Step 6: Tests laufen lassen**

Run: `flutter test test/services/`
Expected: PASS, einschließlich der bestehenden `location_tracking_foreground_test.dart`

- [ ] **Step 7: Commit**

```bash
git add lib/services/tracking_state.dart lib/services/location_tracking_service.dart lib/modules/settings/settings_screen.dart test/services/location_tracking_state_test.dart
git commit -m "fix(aufzeichnung): Wunsch und Lauf sind zwei Dinge"
```

---

### Task 7: Die übrigen Aufrufstellen umziehen

**Files:**
- Modify: die verbleibenden Dateien mit `settingsBox`-Zugriff außerhalb von `lib/core` und `lib/services` (23 Stellen, davon 7 schreibend — `git grep -n "settingsBox\."` zeigt sie)
- Modify: `lib/core/data_entry.dart:640-642` (Durchgriff entfernen)

**Interfaces:**
- Consumes: `AppSettings` aus Task 5
- Produces: `DataEntry` gibt keine `Box<dynamic>` mehr nach außen

- [ ] **Step 1: Bestandsaufnahme**

```bash
git grep -n "settingsBox\." -- lib/ | grep -v "lib/core\|lib/services"
```

- [ ] **Step 2: Schreibende Stellen zuerst umstellen**

Jede `settingsBox.put(...)`-Stelle wird zum passenden `set…`-Aufruf auf
`AppSettings` — bezogen über `DataEntry`, nicht über `getIt` (sonst schlägt
`no_direct_service_access` zu). `DataEntry` bekommt dafür:

```dart
// lib/core/data_entry.dart, an Stelle des alten Durchgriffs
AppSettings get settings => _settings;
```

- [ ] **Step 3: Lesende Stellen umstellen**

`settingsBox.get('x', defaultValue: y) as T` wird zu `dataEntry.settings.x`.
`ValueListenableBuilder(valueListenable: settingsBox.listenable())` wird zu
`dataEntry.settings.listenableFor([AppSettings.keyX])`.

- [ ] **Step 4: Durchgriff entfernen**

Die Zeilen 640–642 in `lib/core/data_entry.dart` entfallen ersatzlos.
`profilesBox` bleibt — sie ist typisiert (`Box<Profile>`) und steht außerhalb
dieses Vorhabens.

- [ ] **Step 5: Prüfen**

Run: `flutter analyze`
Expected: keine Fehler

Run: `flutter test`
Expected: alle Tests grün

- [ ] **Step 6: Commit**

```bash
git add lib/
git commit -m "refactor(einstellungen): kein roher Boxzugriff mehr in der Oberflaeche"
```

---

### Task 8: Die Regel, die es hält

**Files:**
- Create: `dis_app_lints/lib/src/no_raw_settings_box.dart`
- Modify: `dis_app_lints/lib/dis_app_lints.dart`
- Test: `dis_app_lints/test/no_raw_settings_box_test.dart`

**Interfaces:**
- Consumes: `custom_lint_builder`, Muster aus `no_saved_events_listener.dart`
- Produces: Lint `no_raw_settings_box`

- [ ] **Step 1: Regel schreiben**

```dart
// dis_app_lints/lib/src/no_raw_settings_box.dart
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Die Einstellungs-Box gehört [AppSettings].
///
/// ❌ Verboten außerhalb von lib/core/settings/ und lib/services/:
/// ```dart
/// settingsBox.get('gps_tracking_enabled', defaultValue: false) as bool;
/// ```
///
/// ✅ Stattdessen:
/// ```dart
/// dataEntry.settings.globalTrackingAlwaysOn;
/// ```
class NoRawSettingsBox extends DartLintRule {
  const NoRawSettingsBox() : super(code: _code);

  static const _code = LintCode(
    name: 'no_raw_settings_box',
    problemMessage:
        'Roher Zugriff auf die Einstellungs-Box. Ein Schluessel traegt keinen '
        'Typ und keine Bedeutung -- so wurde aus "gewuenscht" schon einmal '
        '"laeuft".',
    correctionMessage:
        'Nimm den benannten Zugang auf AppSettings ueber DataEntry.settings.',
  );

  static const _erlaubt = ['/lib/core/settings/', '/lib/services/'];

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final pfad = resolver.path.replaceAll(r'\', '/');
    if (_erlaubt.any(pfad.contains)) return;

    context.registry.addMethodInvocation((node) {
      final ziel = node.realTarget?.toString() ?? '';
      if (!ziel.endsWith('settingsBox')) return;

      const verboten = {'get', 'put', 'delete', 'listenable'};
      if (verboten.contains(node.methodName.name)) {
        reporter.atNode(node, code);
      }
    });
  }
}
```

- [ ] **Step 2: Regel registrieren**

In `dis_app_lints/lib/dis_app_lints.dart` den Import
`import 'src/no_raw_settings_box.dart';` ergänzen und `const NoRawSettingsBox(),`
in die Liste in `getLintRules` aufnehmen.

- [ ] **Step 3: Regel prüfen**

Run: `dart run custom_lint`
Expected: keine Treffer mehr (Task 7 hat alle Stellen umgezogen)

Zur Gegenprobe eine Zeile `dataEntry.settingsBox.get('x');` in eine
Oberflächendatei schreiben, `dart run custom_lint` erneut laufen lassen —
Expected: `no_raw_settings_box` meldet genau diese Zeile — und die Zeile wieder
entfernen.

- [ ] **Step 4: Commit**

```bash
git add dis_app_lints/
git commit -m "feat(lint): die Einstellungs-Box gehoert ihrem Eigentuemer"
```

---

### Task 9: Regeln nachziehen und aufräumen

**Files:**
- Modify: `AGENTS.md` (Abschnitt „3. Architektur")
- Modify: `CLAUDE.md` (Abschnitt „Custom Lint Rules")

**Interfaces:**
- Consumes: alles Vorherige
- Produces: der automatische Reviewer kennt die neuen Regeln

- [ ] **Step 1: `AGENTS.md` ergänzen**

Unter „3. Architektur" aufnehmen:

```markdown
- **Die Einstellungs-Box gehört `AppSettings`** (`no_raw_settings_box`). Kein
  `settingsBox.get/put` außerhalb von `lib/core/settings/` und `lib/services/`.
- **Der Aufzeichnungszustand ist `TrackingState`**, nicht ein `bool`. Wer
  wissen will, ob aufgezeichnet wird, fragt `laeuft` — nicht `gewuenscht`.
- **Ergebnisse mit `@useResult` dürfen nicht verworfen werden.** Betrifft
  `deleteAllLocalData()`: ein Teilerfolg ist kein Erfolg.
```

- [ ] **Step 2: `CLAUDE.md` ergänzen**

Die Liste der custom lints um `no_raw_settings_box` erweitern.

- [ ] **Step 3: Commit und Pull Request**

```bash
git add AGENTS.md CLAUDE.md
git commit -m "docs: die neuen Regeln in die Pruefanweisung aufnehmen"
git push -u origin <branch>
gh pr create --title "Zustandseigentum: die Settings-Box bekommt einen Eigentümer" --body-file docs/superpowers/specs/2026-08-10-zustandseigentum-design.md
```

- [ ] **Step 4: Codex prüfen lassen**

Der PR wird durch „Auto review" automatisch geprüft. Die Befunde gegen
`AGENTS.md` gegenlesen: meldet Codex die neuen Regeln korrekt, trägt die
Anweisung. Meldet er Rauschen, gehört das in den Abschnitt „Was kein Befund ist".

- [ ] **Step 5: Arbeitsbaum aufräumen**

```bash
git branch --merged main | grep -v "^\*\|main" | xargs -r git branch -d
git worktree prune
git status --porcelain
```

Expected: leere Ausgabe.
