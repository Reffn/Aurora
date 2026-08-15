# Refactoring Plan - DIS App

**Projekt:** Aurora - DIS-Hilfe App
**Datum:** 2024-10-15
**Gesamtaufwand:** ~25-32 Stunden
**Status:** In Progress

---

## Übersicht

Dieses Dokument beschreibt den kompletten Plan zur Standardisierung und Qualitätsverbesserung der DIS-App.

### Hauptziele

1. ✅ **Strukturiertes Logging-System** einführen (Level + Category)
2. ✅ **very_good_analysis** aktivieren (200+ strikte Lint-Regeln)
3. ✅ **Datenzugriff vereinheitlichen** (CQRS-Pattern konsistent)
4. ✅ **Custom Lint Rules** zur Pattern-Durchsetzung
5. ✅ **Git Hooks + CI/CD** für automatische Qualitätschecks
6. ✅ **Dokumentation** aktualisieren

---

## Phase 1: Setup & Logger (2-3h)

### 1.1 Logger-System implementieren (1h)

**Datei:** `lib/core/logger.dart`

**Features:**
- **Log-Levels:** Debug, Info, Warning, Error, Critical
- **Kategorien:** UI, Service, DataEntry, EventBus, Hive, Network, Permission, Navigation
- **Strukturiertes Format:** `[Timestamp] Icon [Level] [Category] Message`
- **Console-Output:** Mit Farben und Icons
- **Performance-Tracking:** Execution-Time messen
- **Production-Mode:** Nur Warning+ loggen

**Logger-Interface:**
```dart
// Haupt-Methoden
logger.debug(LogCategory.ui, 'Message', data: {...});
logger.info(LogCategory.dataEntry, 'Message', data: {...});
logger.warning(LogCategory.service, 'Message', data: {...});
logger.error(LogCategory.service, 'Message', data: {...}, stackTrace: trace);
logger.critical(LogCategory.hive, 'Message', data: {...}, stackTrace: trace);

// Performance-Tracking
await logger.track('operationName', LogCategory.dataEntry, () async {
  // Code hier
});
```

**Beispiel-Output:**
```
[2024-10-15T14:23:45.123Z] ℹ️ [INFO] [DATAENTRY] createChatMessage
  └─ Data: {source: UI, messageId: abc123, contentLength: 15}
```

### 1.2 very_good_analysis Setup (1h)

**pubspec.yaml ändern:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^6.0.0  # ← Ersetzt flutter_lints
  hive_ce_generator: ^1.6.0
  build_runner: ^2.4.13
```

**analysis_options.yaml konfigurieren:**
```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"

linter:
  rules:
    # 80-Zeichen-Limit deaktivieren (unrealistisch für Flutter)
    lines_longer_than_80_chars: false

    # Dokumentation erstmal optional (später aktivieren)
    public_member_api_docs: false
```

**Erste Analyse:**
```bash
flutter pub get
flutter analyze        # → ~500-700 Warnings erwartet
dart fix --apply       # → Fixd ~40% automatisch
flutter analyze        # → ~300-400 Warnings übrig
```

### 1.3 Logger in DI registrieren (30 Min)

**Datei:** `lib/core/di/injection.dart`

```dart
// Logger als Singleton registrieren
getIt.registerSingleton<AppLogger>(AppLogger());
```

### 1.4 Logger in main.dart konfigurieren (30 Min)

**Datei:** `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logger konfigurieren
  final isProduction = const bool.fromEnvironment('dart.vm.product');
  logger.setProduction(isProduction);

  logger.info(LogCategory.ui, 'App starting...', data: {
    'isProduction': isProduction,
    'platform': Platform.operatingSystem,
  });

  await setupDependencyInjection();

  runApp(const MyApp());
}
```

---

## Phase 2: Logging integrieren (4-5h)

### 2.1 print() durch Logger ersetzen (2h)

**Betroffen:** ~15 Stellen

**Finden:**
```bash
grep -rn "print(" lib/ | grep -v "debugPrint"
```

**Ersetzungsmuster:**
```dart
// Vorher:
print('✓ Migration: First profile set as admin');
print('Error: $e');

// Nachher:
logger.info(LogCategory.service, 'Migration: First profile set as admin');
logger.error(LogCategory.service, 'Error occurred', data: {'error': e.toString()});
```

**Betroffene Dateien:**
- `lib/services/profile_service.dart` (~5 prints)
- `lib/services/chat_service.dart` (~3 prints)
- `lib/core/event_bus.dart` (~2 prints)
- Weitere Services (~5 prints)

### 2.2 DataEntry mit Logger ausstatten (1h)

**Datei:** `lib/core/data_entry.dart`

**Pattern:**
```dart
Future<void> createChatMessage(ChatMessage message, {String source = 'UI'}) async {
  // Logging statt print
  logger.info(
    LogCategory.dataEntry,
    'createChatMessage',
    data: {
      'source': source,
      'messageId': message.id,
      'profileId': message.profileId,
      'contentLength': message.content.length,
    },
  );

  // Validierung mit Warning-Log
  if (message.content.trim().isEmpty) {
    logger.warning(
      LogCategory.dataEntry,
      'Validation failed: Empty message',
      data: {'messageId': message.id},
    );
    throw ArgumentError('Nachricht darf nicht leer sein');
  }

  // Event publishen
  _eventBus.publish(ChatMessageCreatedEvent(message));
}
```

### 2.3 Services mit Logger ausstatten (1-2h)

**Betroffen:** Alle 9 Service-Dateien

**Pattern:**
```dart
class ChatService extends BaseService {
  void _handleMessageCreated(ChatMessageCreatedEvent event) {
    logger.info(
      LogCategory.service,
      'Handling ChatMessageCreatedEvent',
      data: {'messageId': event.message.id},
    );

    try {
      _messageBox.add(event.message);

      logger.debug(
        LogCategory.hive,
        'Message saved to Hive',
        data: {
          'messageId': event.message.id,
          'boxSize': _messageBox.length,
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Failed to save message',
        data: {'messageId': event.message.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
```

---

## Phase 3: very_good Lints fixen (3-4h)

### 3.1 Auto-Fix anwenden (30 Min)

```bash
dart fix --apply
```

**Fixd automatisch (~40%):**
- `prefer_single_quotes`
- `prefer_const_constructors`
- `prefer_final_locals`
- `unnecessary_this`

### 3.2 `avoid_print` fixen (30 Min)

Bereits durch Logger ersetzt ✅

### 3.3 Fehlende Return-Types (1h)

**Pattern:**
```dart
// Vorher:
_getData() { return data; }

// Nachher:
List<Data> _getData() { return data; }
```

### 3.4 Restliche Warnings (1-2h)

- Constructor-Reihenfolge korrigieren
- Unnötige Nullable entfernen
- `sort_constructors_first`
- `avoid_dynamic_calls` (wo möglich)

**Ziel:** <50 Warnings übrig

---

## Phase 4: Datenzugriff vereinheitlichen (8-10h)

### 4.1 DataEntry um Queries erweitern (3h)

**Datei:** `lib/core/data_entry.dart`

**Neue Methoden:**

```dart
// ============ CHAT QUERIES ============

List<ChatMessage> getChatMessages({String source = 'UI'}) {
  logger.debug(LogCategory.dataEntry, 'getChatMessages', data: {'source': source});
  return getIt<ChatService>().messages;
}

int getUnreadChatCount({String source = 'UI'}) {
  logger.debug(LogCategory.dataEntry, 'getUnreadChatCount', data: {'source': source});
  return getIt<ChatService>().messages.where((m) => !m.isRead).length;
}

// ============ PROFILE QUERIES ============

List<Profile> getActiveProfiles({String source = 'UI'}) {
  logger.debug(LogCategory.dataEntry, 'getActiveProfiles', data: {'source': source});
  return getIt<ProfileService>().activeProfiles;
}

Profile? getActiveProfile({String source = 'UI'}) {
  logger.debug(LogCategory.dataEntry, 'getActiveProfile', data: {'source': source});
  return getIt<ProfileService>().activeProfile;
}

// ============ MEDICATION QUERIES ============

List<Medication> getTodaysMedications({String source = 'UI'}) {
  logger.debug(LogCategory.dataEntry, 'getTodaysMedications', data: {'source': source});
  return getIt<MedicationService>().getTodaysMedications();
}

MedicationStatus? getMedicationStatus(
  String medicationId,
  String timeOfDay,
  {String source = 'UI'}
) {
  logger.debug(
    LogCategory.dataEntry,
    'getMedicationStatus',
    data: {
      'source': source,
      'medicationId': medicationId,
      'timeOfDay': timeOfDay,
    },
  );
  return getIt<MedicationService>().getStatusToday(medicationId, timeOfDay);
}

// ============ CALENDAR QUERIES ============

List<CalendarEvent> getCalendarEvents({String source = 'UI'}) {
  logger.debug(LogCategory.dataEntry, 'getCalendarEvents', data: {'source': source});
  return getIt<CalendarService>().events;
}

List<CalendarEvent> getEventsForDate(DateTime date, {String source = 'UI'}) {
  logger.debug(
    LogCategory.dataEntry,
    'getEventsForDate',
    data: {'source': source, 'date': date.toIso8601String()},
  );
  return getIt<CalendarService>().getEventsForDate(date);
}

// ============ CONTACT QUERIES ============

List<Contact> getContacts({String source = 'UI'}) {
  logger.debug(LogCategory.dataEntry, 'getContacts', data: {'source': source});
  return getIt<ContactService>().contacts;
}

// ============ EMERGENCY DIARY QUERIES ============

List<EmergencyDiaryEntry> getEmergencyEntries({String source = 'UI'}) {
  logger.debug(LogCategory.dataEntry, 'getEmergencyEntries', data: {'source': source});
  return getIt<EmergencyDiaryService>().entries;
}
```

### 4.2 Services aufräumen (1h)

**Betroffen:** Alle `*_service.dart` (9 Dateien)

**Änderungen:**
1. Nutzlose *SavedEvent entfernen
2. Logger statt print()
3. Error-Handling verbessern

**Beispiel:**
```dart
// ENTFERNEN:
eventBus.publish(ChatMessageSavedEvent(message));
eventBus.publish(ProfileSavedEvent(profile));

// Diese Events werden nicht mehr gebraucht!
// UI nutzt Hive ValueListenable für Reaktivität
```

### 4.3 UI-Screens umstellen (4-5h)

**Betroffen:** 23 Screen-Dateien

**Pro Screen:** ~15-20 Min

**Änderungspattern:**
```dart
// VORHER:
class _ChatScreenState extends State<ChatScreen> {
  final _chatService = getIt<ChatService>();

  Widget build(BuildContext context) {
    final messages = _chatService.messages; // ❌ Direkter Zugriff

    return ValueListenableBuilder(
      valueListenable: _chatService.messagesBox.listenable(),
      builder: (context, box, _) {
        final messages = _chatService.messages; // ❌
        return ListView(...);
      }
    );
  }
}

// NACHHER:
class _ChatScreenState extends State<ChatScreen> {
  final _dataEntry = getIt<DataEntry>();
  final _chatService = getIt<ChatService>(); // Nur für Box!

  @override
  void initState() {
    super.initState();
    logger.debug(LogCategory.ui, 'ChatScreen initialized');
  }

  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _chatService.messagesBox.listenable(),
      builder: (context, box, _) {
        final messages = _dataEntry.getChatMessages(); // ✅ Über API
        return ListView(...);
      }
    );
  }
}
```

**Priorisierte Screen-Liste:**
1. `chat_screen.dart`
2. `profile_selection_screen.dart`
3. `medication_screen.dart`
4. `calendar_screen.dart`
5. `contacts_screen.dart`
6. `emergency_diary_screen.dart`
7. Restliche 17 Screens

### 4.4 Dokumentation (1h)

**Datei erstellen:** `CODING_STANDARDS.md`

**Inhalt:**
- Die 4 Golden Rules
- Logger-Usage-Patterns
- Code-Beispiele
- Anti-Patterns (was NICHT tun)

---

## Phase 5: Custom Lints + Automation (6-8h)

### 5.1 Custom Lint Package erstellen (3h)

**Struktur:**
```
tools/custom_lints/
├── pubspec.yaml
├── lib/
│   └── custom_lints.dart
└── analysis_options.yaml
```

**Rules implementieren:**
1. `NoDirectServiceAccess` - Erkennt `_chatService.messages`
2. `NoSavedEventsListener` - Erkennt `eventBus.on<*SavedEvent>()`

**Einbinden:**
```yaml
# Root pubspec.yaml
dev_dependencies:
  custom_lint: ^0.6.0
  custom_lints:
    path: tools/custom_lints/
```

**Testen:**
```bash
dart run custom_lint
```

### 5.2 Git Hooks Setup (2h)

**Package:** `lefthook: ^1.5.0`

**Datei:** `lefthook.yml`

```yaml
pre-commit:
  parallel: true
  commands:
    format:
      glob: "*.dart"
      run: dart format --set-exit-if-changed {staged_files}

    analyze:
      run: flutter analyze --fatal-warnings

    custom-lint:
      run: dart run custom_lint

    pattern-check:
      run: |
        echo "🔍 Pattern checks..."
        for file in {staged_files}; do
          if echo "$file" | grep -q "\.dart$"; then
            if grep -q "_chatService\.messages\|_profileService\.profiles" "$file"; then
              echo "❌ $file: Direct service access!"
              exit 1
            fi
          fi
        done
        echo "✅ Pattern checks passed"

pre-push:
  commands:
    test:
      run: flutter test
```

**Installieren:**
```bash
dart run lefthook install
```

### 5.3 CI/CD Integration (2-3h)

**Datei:** `.github/workflows/quality_checks.yml`

```yaml
name: Code Quality

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze --fatal-infos --fatal-warnings
      - run: dart run custom_lint --fatal-infos

      - name: Pattern checks
        run: |
          if grep -r "_chatService\.messages\|_profileService\.profiles" lib/ --include="*.dart"; then
            echo "❌ Direct service access found!"
            exit 1
          fi

          if grep -r "SavedEvent" lib/ --include="*.dart" | grep -v "class.*SavedEvent"; then
            echo "❌ SavedEvent listener found!"
            exit 1
          fi

  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
```

---

## Phase 6: Dokumentation (2h)

### 6.1 CODING_STANDARDS.md erstellen

**Inhalt:**
- Data Access Pattern (CQRS)
- Logger-Usage-Guide
- Service Rules
- UI Rules
- Code-Beispiele

### 6.2 ARCHITECTURE.md aktualisieren

**Änderungen:**
- Logging-System dokumentieren
- DataEntry als vollständiger API Layer
- Hive-Reaktivität (statt EventBus für UI)
- CQRS-Pattern erklären

---

## Zeitplan

| Phase | Aufwand | Start | Ende |
|-------|---------|-------|------|
| 1. Setup & Logger | 2-3h | KW 42 | KW 42 |
| 2. Logging integrieren | 4-5h | KW 42 | KW 42 |
| 3. Lints fixen | 3-4h | KW 42 | KW 43 |
| 4. DataEntry | 8-10h | KW 43 | KW 43 |
| 5. Automation | 6-8h | KW 43 | KW 44 |
| 6. Dokumentation | 2h | KW 44 | KW 44 |
| **TOTAL** | **25-32h** | **KW 42** | **KW 44** |

---

## Deliverables

- ✅ `lib/core/logger.dart` - Strukturiertes Logging-System
- ✅ `very_good_analysis` aktiv (<50 Warnings)
- ✅ `lib/core/data_entry.dart` - Commands + Queries + Logging
- ✅ Alle UI nutzt DataEntry konsistent
- ✅ `tools/custom_lints/` - Custom Lint Rules
- ✅ `lefthook.yml` - Git Hooks
- ✅ `.github/workflows/quality_checks.yml` - CI/CD
- ✅ `CODING_STANDARDS.md` - Dokumentation
- ✅ `REFACTORING_PLAN.md` - Dieser Plan
- ✅ `ARCHITECTURE.md` - Aktualisiert

---

## Erfolgskriterien

1. ✅ **<50 Lint-Warnings** übrig
2. ✅ **Alle print() ersetzt** durch Logger
3. ✅ **Alle UI-Screens** nutzen DataEntry
4. ✅ **Custom Lints** finden Pattern-Verstöße
5. ✅ **Git Hooks** blockieren fehlerhafte Commits
6. ✅ **CI/CD** blockiert fehlerhafte PRs
7. ✅ **Dokumentation** ist vollständig

---

## Nächste Schritte

**Aktuell:** Phase 1 - Setup & Logger
**Next:** Logger implementieren (`lib/core/logger.dart`)

---

*Dokument erstellt: 2024-10-15*
*Letzte Änderung: 2024-10-15*
