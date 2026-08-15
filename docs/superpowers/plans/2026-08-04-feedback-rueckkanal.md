# Feedback-Rückkanal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Feedback aus dem Release-Build erreicht nachweislich den Empfänger, Fehler sind für die Nutzerin sichtbar, und ein Build mit unkonfiguriertem Kanal schlägt fehl.

**Architecture:** Eine `FeedbackTransport`-Abstraktion mit zwei Implementierungen (`FirestoreTransport` über das Firebase-SDK, `MailtoTransport` über den bestehenden `mailto:`-Pfad). Jeder Übertragungsversuch wird in einer lokalen Hive-Box `transmission_log` protokolliert und ist über einen eigenen Screen einsehbar. Der GitHub-Sendeweg entfällt vollständig.

**Tech Stack:** Flutter 3.35.4, Dart, Hive CE, GetIt, `firebase_core`, `cloud_firestore`, `firebase_app_check`, `url_launcher`, `flutter_test`

**Spec:** `docs/superpowers/specs/2026-08-04-feedback-rueckkanal-design.md`

## Global Constraints

- Alle Datenoperationen laufen über `DataEntry` (`lib/core/data_entry.dart`) — Custom-Lint `prefer_data_entry_architecture` erzwingt das
- Services werden nie direkt mutiert — Custom-Lint `avoid_service_direct_mutation`
- Hive-Feldreihenfolge nicht nachträglich ändern — Custom-Lint `hive_field_order_check`
- Freie Hive `typeId`s: **32, 33 und 34**. Vergeben sind 0–26 sowie 30–31. Zuordnung: 32 = `TransmissionChannel`, 33 = `TransmissionStatus`, 34 = `TransmissionLogEntry`
- Box-Namen ausschließlich als Konstante in `lib/core/hive_box_names.dart`
- Strings über `runes` verarbeiten, nie per Index — UTF-16-Sicherheit bei Emoji
- Logging über `logger.info(LogCategory.x, ...)` aus `lib/core/logger.dart`
- Firestore-Region: **`europe-west3`** (Frankfurt), nicht `us-central1`
- Kein Standortfeld darf je Teil eines Payloads werden
- Nach Änderungen an Hive-Modellen: `dart run build_runner build --delete-conflicting-outputs`
- Alle Commits auf Branch `feature/feedback-rueckkanal`

---

## File Structure

**Neu:**

| Datei | Verantwortung |
|---|---|
| `lib/models/transmission_log_entry.dart` | Hive-Modell eines Übertragungsversuchs (typeId 32) + `TransmissionStatus` (typeId 33) |
| `lib/models/feedback_payload.dart` | Reiner Datentyp: was gesendet wird. Kein Hive |
| `lib/services/transport/feedback_transport.dart` | Interface + `TransportResult` |
| `lib/services/transport/mailto_transport.dart` | `mailto:`-Implementierung |
| `lib/services/transport/firestore_transport.dart` | Firestore-Implementierung |
| `lib/services/transmission_log_service.dart` | Schreiben/Lesen/Löschen der Log-Box |
| `lib/modules/feedback/widgets/feedback_form.dart` | Das eine Feedback-Formular, von allen drei Einstiegspunkten verwendet |
| `lib/modules/feedback/feedback_result_screen.dart` | Ein Ergebnis-Screen statt zwei Danke-Screens |
| `lib/modules/transparency/transparency_screen.dart` | Screen „Was Aurora sendet" |
| `firestore.rules` | Security Rules |
| `test/models/feedback_payload_test.dart` | Payload-Regeln |
| `test/services/transmission_log_service_test.dart` | Log-Verhalten |
| `test/services/transport/mailto_transport_test.dart` | Mailto-Aufbau |
| `test/services/transport/transport_config_test.dart` | CI-Gate: Transport ist konfiguriert |
| `test/utils/debug_report_privacy_test.dart` | Report enthält keine Identifikatoren |

**Geändert:**

| Datei | Änderung |
|---|---|
| `lib/core/hive_box_names.dart` | Konstante `transmissionLog` |
| `lib/core/di/injection.dart` | Box öffnen, Services registrieren |
| `lib/widgets/feedback_bottom_sheet.dart` | wird zur dünnen Hülle um `FeedbackForm` |
| `lib/modules/feedback/feedback_screen.dart` | wird zur dünnen Hülle um `FeedbackForm` |
| `lib/widgets/error_report_dialog.dart` | wird zur dünnen Hülle, reicht Crash-Kontext durch |
| `lib/utils/enhanced_debug_report_generator.dart` | Profil-ID und Bestandszahlen entfernen |
| `lib/utils/contact_config.dart` | GitHub-Konstanten entfernen |
| `lib/modules/settings/settings_screen.dart` | Eintrag zum Transparenz-Screen |
| `.github/workflows/test.yml` | Release-Gate |
| `pubspec.yaml` | Firebase-Pakete |

**Gelöscht:** `lib/services/github_error_report_service.dart`, `lib/models/github_submission_result.dart`, `lib/screens/feedback_thank_you_screen.dart`, `lib/screens/error_report_thank_you_screen.dart`

---

## Task 1: Ausgelieferten Stand festschreiben

Vorbedingung aus Spec 8.1. Im Store läuft 3.0.13, git kennt nur 3.0.11+11, der Bump liegt uncommitted im Arbeitsverzeichnis. Ohne diesen Schritt bauen alle folgenden Tasks auf einem Stand, der nirgends festgehalten ist.

**Files:**
- Modify: `pubspec.yaml` (Zeile mit `version:`)

**Interfaces:**
- Consumes: nichts
- Produces: Tag `v3.0.13` auf Commit `a72e9ac`

- [x] **Step 1: Aktuellen Zustand prüfen**

```bash
git status --short
git diff pubspec.yaml
```

Erwartet: `pubspec.yaml` zeigt `-version: 3.0.11+11` / `+version: 3.0.13+13`, dazu eine unabhängige Änderung an `lib/widgets/timeline_event_symbol.dart`.

- [x] **Step 2: Tag auf den ausgelieferten Commit setzen**

`a72e9ac` (29.11.2025 03:17) ist der Code-Stand, aus dem der Store-Build (Upload 03:27) entstand.

```bash
git tag -a v3.0.13 a72e9ac -m "Released to Play Store as versionCode 13 on 2025-11-29"
```

- [x] **Step 3: Versions-Bump committen**

Nur `pubspec.yaml` — die Timeline-Änderung gehört nicht dazu.

```bash
git add pubspec.yaml
git commit -m "chore: record shipped version 3.0.13+13"
```

- [x] **Step 4: Verifizieren**

```bash
git tag -l "v3.0.13"
git show v3.0.13 --stat | head -5
```

Erwartet: Tag existiert und zeigt auf `a72e9ac`.

---

## Task 2: TransmissionLogEntry-Modell

**Files:**
- Create: `lib/models/transmission_log_entry.dart`
- Modify: `lib/core/hive_box_names.dart`

**Interfaces:**
- Consumes: nichts
- Produces: `TransmissionLogEntry({required String id, required DateTime timestamp, required TransmissionChannel channel, required String payloadText, required TransmissionStatus status, String? errorMessage})`, `TransmissionStatus.{pending,sent,failed}`, `TransmissionChannel.{feedback,telemetry}`, `HiveBoxNames.transmissionLog`

- [x] **Step 1: Box-Namen ergänzen**

In `lib/core/hive_box_names.dart` nach `notificationQueue` einfügen:

```dart
  static const String transmissionLog = 'transmission_log';
```

- [x] **Step 2: Modell schreiben**

`lib/models/transmission_log_entry.dart`:

```dart
import 'package:hive_ce/hive.dart';

part 'transmission_log_entry.g.dart';

/// Status eines Übertragungsversuchs
@HiveType(typeId: 33)
enum TransmissionStatus {
  /// Vom SDK entgegengenommen, Zustellung ausstehend (z.B. offline)
  @HiveField(0)
  pending,

  /// Zustellung bestätigt
  @HiveField(1)
  sent,

  /// Endgültig fehlgeschlagen
  @HiveField(2)
  failed,
}

/// Kanal, über den übertragen wurde
@HiveType(typeId: 32)
enum TransmissionChannel {
  @HiveField(0)
  feedback,

  @HiveField(1)
  telemetry,
}

/// Ein Eintrag im lokalen Übertragungsprotokoll.
///
/// Liegt ausschließlich auf dem Gerät. Beleg für die Nutzerin,
/// keine Buchhaltung für die Entwickler.
///
/// Feldreihenfolge nach dem Anlegen nie ändern — der Custom-Lint
/// `hive_field_order_check` erzwingt das, weil sonst bestehende
/// Daten falsch gelesen würden.
@HiveType(typeId: 34)
class TransmissionLogEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final TransmissionChannel channel;

  /// Der vollständige Inhalt im Klartext, so wie er das Gerät verlassen hat.
  /// Wird nie gekürzt oder zusammengefasst.
  @HiveField(3)
  final String payloadText;

  @HiveField(4)
  TransmissionStatus status;

  @HiveField(5)
  String? errorMessage;

  TransmissionLogEntry({
    required this.id,
    required this.timestamp,
    required this.channel,
    required this.payloadText,
    required this.status,
    this.errorMessage,
  });
}
```

- [x] **Step 3: Adapter generieren**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Erwartet: `lib/models/transmission_log_entry.g.dart` entsteht ohne Fehler und enthält `TransmissionLogEntryAdapter`, `TransmissionStatusAdapter` und `TransmissionChannelAdapter`.

- [x] **Step 4: Analyse und Lints laufen lassen**

```bash
flutter analyze lib/models/transmission_log_entry.dart
dart run custom_lint
```

Erwartet: keine Fehler, insbesondere kein `hive_field_order_check`-Verstoß.

- [x] **Step 5: Commit**

```bash
git add lib/models/transmission_log_entry.dart lib/models/transmission_log_entry.g.dart lib/core/hive_box_names.dart
git commit -m "feat: add TransmissionLogEntry model for local transmission log"
```

---

## Task 3: FeedbackPayload mit Datenschutz-Regeln

Der Payload ist der Ort, an dem die Kanaltrennung aus Spec 4 durchgesetzt wird. Deshalb bekommt er eigene Tests.

**Files:**
- Create: `lib/models/feedback_payload.dart`
- Test: `test/models/feedback_payload_test.dart`

**Interfaces:**
- Consumes: nichts
- Produces: `FeedbackPayload({required String category, required String message, String? replyEmail, String? diagnostics})`, `String toPlainText()`, `Map<String, dynamic> toMap()`

- [x] **Step 1: Failing Test schreiben**

`test/models/feedback_payload_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dis_app/models/feedback_payload.dart';

void main() {
  group('FeedbackPayload', () {
    test('enthält ohne Diagnose-Schalter nur Text und Kategorie', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: 'Die Karte lädt nicht.',
      );

      final map = payload.toMap();

      expect(map['category'], 'Fehler');
      expect(map['message'], 'Die Karte lädt nicht.');
      expect(map.containsKey('diagnostics'), isFalse);
      expect(map.containsKey('replyEmail'), isFalse);
    });

    test('erlaubt kein Standortfeld im Schema', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: 'Test',
        diagnostics: 'Android 14',
      );

      final keys = payload.toMap().keys.map((k) => k.toLowerCase());

      for (final forbidden in ['location', 'latitude', 'longitude', 'lat', 'lon', 'position', 'gps', 'coordinates']) {
        expect(keys.contains(forbidden), isFalse,
            reason: 'Standortfeld "$forbidden" darf nie Teil eines Payloads sein (Spec 4, Kanal 3)');
      }
    });

    test('toPlainText gibt den Inhalt wörtlich wieder', () {
      final payload = FeedbackPayload(
        category: 'Wunsch',
        message: 'Mehr Tier-Avatare 🦎',
        replyEmail: 'jemand@example.org',
      );

      final text = payload.toPlainText();

      expect(text, contains('Wunsch'));
      expect(text, contains('Mehr Tier-Avatare 🦎'));
      expect(text, contains('jemand@example.org'));
    });

    test('leere Mail-Adresse wird nicht mitgesendet', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: 'Test',
        replyEmail: '',
      );

      expect(payload.toMap().containsKey('replyEmail'), isFalse);
    });
  });
}
```

- [x] **Step 2: Test laufen lassen, Fehlschlag prüfen**

```bash
flutter test test/models/feedback_payload_test.dart
```

Erwartet: FAIL — `Target of URI doesn't exist: 'package:dis_app/models/feedback_payload.dart'`

- [x] **Step 3: Implementierung schreiben**

`lib/models/feedback_payload.dart`:

```dart
/// Was beim Feedback das Gerät verlässt.
///
/// Bewusst ein eigener Typ statt einer freien Map: Das Schema ist die Stelle,
/// an der die Kanaltrennung aus der Spec durchgesetzt und getestet wird.
/// Standortdaten sind hier strukturell nicht vorgesehen.
class FeedbackPayload {
  final String category;
  final String message;

  /// Optionale Rückmeldeadresse. Nur gesetzt, wenn die Nutzerin sie einträgt.
  final String? replyEmail;

  /// Gerätediagnose. Nur gesetzt, wenn der Schalter aktiviert wurde.
  final String? diagnostics;

  const FeedbackPayload({
    required this.category,
    required this.message,
    this.replyEmail,
    this.diagnostics,
  });

  /// Serialisierung für den Versand. Leere Felder entfallen vollständig,
  /// damit keine leeren Schlüssel übertragen werden.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'category': category,
      'message': message,
    };

    if (replyEmail != null && replyEmail!.isNotEmpty) {
      map['replyEmail'] = replyEmail;
    }
    if (diagnostics != null && diagnostics!.isNotEmpty) {
      map['diagnostics'] = diagnostics;
    }

    return map;
  }

  /// Wörtliche Darstellung für Vorschau und Übertragungsprotokoll.
  /// Muss exakt das zeigen, was gesendet wird.
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln('Kategorie: $category');
    buffer.writeln();
    buffer.writeln(message);

    if (replyEmail != null && replyEmail!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Antwort an: $replyEmail');
    }
    if (diagnostics != null && diagnostics!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('--- Gerätediagnose ---');
      buffer.writeln(diagnostics);
    }

    return buffer.toString();
  }
}
```

- [x] **Step 4: Test laufen lassen**

```bash
flutter test test/models/feedback_payload_test.dart
```

Erwartet: alle 4 Tests PASS.

- [x] **Step 5: Commit**

```bash
git add lib/models/feedback_payload.dart test/models/feedback_payload_test.dart
git commit -m "feat: add FeedbackPayload with location-free schema guarantee"
```

---

## Task 4: FeedbackTransport-Interface

**Files:**
- Create: `lib/services/transport/feedback_transport.dart`

**Interfaces:**
- Consumes: `FeedbackPayload` aus Task 3
- Produces: `abstract class FeedbackTransport` mit `bool get isConfigured`, `String get displayName`, `Future<TransportResult> send(FeedbackPayload)`; `TransportResult.success()`, `TransportResult.pending()`, `TransportResult.failure(String reason)`; `TransportOutcome.{sent,pending,failed}`

- [x] **Step 1: Interface schreiben**

`lib/services/transport/feedback_transport.dart`:

```dart
import 'package:dis_app/models/feedback_payload.dart';

/// Ergebnis eines Übertragungsversuchs.
enum TransportOutcome {
  /// Zustellung bestätigt
  sent,

  /// Entgegengenommen, Zustellung folgt (z.B. offline)
  pending,

  /// Endgültig fehlgeschlagen
  failed,
}

class TransportResult {
  final TransportOutcome outcome;

  /// Für die Nutzerin lesbarer Grund. Nur bei [TransportOutcome.failed] gesetzt.
  final String? reason;

  const TransportResult._(this.outcome, this.reason);

  const TransportResult.success() : this._(TransportOutcome.sent, null);
  const TransportResult.pending() : this._(TransportOutcome.pending, null);
  const TransportResult.failure(String reason)
      : this._(TransportOutcome.failed, reason);

  bool get isSuccess => outcome == TransportOutcome.sent;
}

/// Ein Weg, auf dem Feedback das Gerät verlässt.
///
/// Wichtig: [isConfigured] darf keine Compile-Zeit-Konstante auswerten.
/// Genau das war die Ursache des ursprünglichen Ausfalls — ein konstant
/// leerer Token führte dazu, dass der Compiler den gesamten Sendepfad
/// entfernte, ohne dass es zur Laufzeit bemerkbar war.
abstract class FeedbackTransport {
  /// Ist ein Ziel hinterlegt? Wird vom CI-Gate geprüft.
  bool get isConfigured;

  /// Name für die Anzeige in der Oberfläche.
  String get displayName;

  Future<TransportResult> send(FeedbackPayload payload);
}
```

- [x] **Step 2: Analyse laufen lassen**

```bash
flutter analyze lib/services/transport/feedback_transport.dart
```

Erwartet: keine Fehler.

- [x] **Step 3: Commit**

```bash
git add lib/services/transport/feedback_transport.dart
git commit -m "feat: add FeedbackTransport abstraction"
```

---

## Task 5: MailtoTransport

Baut auf dem bereits funktionierenden `mailto:`-Pfad auf (`feedback_bottom_sheet.dart:408-452`) und macht ihn zu einem eigenständigen, testbaren Transport.

**Files:**
- Create: `lib/services/transport/mailto_transport.dart`
- Test: `test/services/transport/mailto_transport_test.dart`

**Interfaces:**
- Consumes: `FeedbackTransport`, `TransportResult` (Task 4), `FeedbackPayload` (Task 3), `ContactConfig.supportEmail`
- Produces: `MailtoTransport({UrlLauncher? launcher})`, `Uri buildUri(FeedbackPayload)`, `typedef UrlLauncher = Future<bool> Function(Uri)`

- [x] **Step 1: Failing Test schreiben**

`test/services/transport/mailto_transport_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/mailto_transport.dart';

void main() {
  group('MailtoTransport', () {
    test('ist immer konfiguriert', () {
      expect(MailtoTransport().isConfigured, isTrue);
    });

    test('baut eine mailto-URI mit dem vollen Text', () {
      final transport = MailtoTransport();
      final uri = transport.buildUri(const FeedbackPayload(
        category: 'Fehler',
        message: 'Die Karte lädt nicht.',
      ));

      expect(uri.scheme, 'mailto');
      expect(uri.queryParameters['body'], contains('Die Karte lädt nicht.'));
    });

    test('meldet Erfolg, wenn der Mail-Client geöffnet wurde', () async {
      final transport = MailtoTransport(launcher: (_) async => true);
      final result = await transport.send(
        const FeedbackPayload(category: 'Fehler', message: 'Test'),
      );

      expect(result.outcome, TransportOutcome.sent);
    });

    test('meldet Fehler mit Grund, wenn kein Mail-Client vorhanden ist', () async {
      final transport = MailtoTransport(launcher: (_) async => false);
      final result = await transport.send(
        const FeedbackPayload(category: 'Fehler', message: 'Test'),
      );

      expect(result.outcome, TransportOutcome.failed);
      expect(result.reason, isNotNull);
      expect(result.reason, isNotEmpty);
    });
  });
}
```

- [x] **Step 2: Test laufen lassen, Fehlschlag prüfen**

```bash
flutter test test/services/transport/mailto_transport_test.dart
```

Erwartet: FAIL — `mailto_transport.dart` existiert nicht.

- [x] **Step 3: Implementierung schreiben**

`lib/services/transport/mailto_transport.dart`:

```dart
import 'package:url_launcher/url_launcher.dart';

import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/utils/contact_config.dart';

/// Injizierbar, damit der Versand ohne Plattformkanal testbar bleibt.
typedef UrlLauncher = Future<bool> Function(Uri uri);

/// Öffnet den Mail-Client mit vorausgefülltem Text.
///
/// Gleichwertige Alternative zum Firestore-Weg, nicht bloß ein Notfall-Fallback:
/// Wer selbst per Mail schickt, sieht den vollen Inhalt und behält eine Kopie.
class MailtoTransport implements FeedbackTransport {
  final UrlLauncher _launcher;

  MailtoTransport({UrlLauncher? launcher})
      : _launcher = launcher ?? _defaultLauncher;

  static Future<bool> _defaultLauncher(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  /// Immer verfügbar — es gibt nichts zu konfigurieren.
  @override
  bool get isConfigured => true;

  @override
  String get displayName => 'E-Mail';

  Uri buildUri(FeedbackPayload payload) {
    return Uri(
      scheme: 'mailto',
      path: ContactConfig.supportEmail,
      queryParameters: {
        'subject': '${ContactConfig.appName} Feedback: ${payload.category}',
        'body': payload.toPlainText(),
      },
    );
  }

  @override
  Future<TransportResult> send(FeedbackPayload payload) async {
    final opened = await _launcher(buildUri(payload));

    if (opened) {
      return const TransportResult.success();
    }
    return const TransportResult.failure(
      'Es konnte keine E-Mail-App geöffnet werden. '
      'Du kannst den Text kopieren und manuell senden.',
    );
  }
}
```

- [x] **Step 4: Test laufen lassen**

```bash
flutter test test/services/transport/mailto_transport_test.dart
```

Erwartet: alle 4 Tests PASS.

- [x] **Step 5: Commit**

```bash
git add lib/services/transport/mailto_transport.dart test/services/transport/mailto_transport_test.dart
git commit -m "feat: add MailtoTransport as first transport implementation"
```

---

## Task 6: TransmissionLogService

**Files:**
- Create: `lib/services/transmission_log_service.dart`
- Test: `test/services/transmission_log_service_test.dart`
- Modify: `lib/core/di/injection.dart`

**Interfaces:**
- Consumes: `TransmissionLogEntry`, `TransmissionStatus`, `TransmissionChannel` (Task 2), `HiveBoxNames.transmissionLog`
- Produces: `TransmissionLogService({required Box<TransmissionLogEntry> box})` mit `Future<String> record({required TransmissionChannel channel, required String payloadText, required TransmissionStatus status, String? errorMessage})`, `Future<void> updateStatus(String id, TransmissionStatus status, {String? errorMessage})`, `List<TransmissionLogEntry> all()`, `Future<void> delete(String id)`, `Future<void> clear()`

- [x] **Step 1: Failing Test schreiben**

`test/services/transmission_log_service_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/transmission_log_service.dart';

void main() {
  late Directory tempDir;
  late Box<TransmissionLogEntry> box;
  late TransmissionLogService service;

  setUpAll(() {
    Hive.registerAdapter(TransmissionLogEntryAdapter());
    Hive.registerAdapter(TransmissionStatusAdapter());
    Hive.registerAdapter(TransmissionChannelAdapter());
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('transmission_log_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<TransmissionLogEntry>('transmission_log_test');
    service = TransmissionLogService(box: box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
    await tempDir.delete(recursive: true);
  });

  group('TransmissionLogService', () {
    test('startet leer', () {
      expect(service.all(), isEmpty);
    });

    test('speichert einen Eintrag mit vollem Payload', () async {
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'Kategorie: Fehler\n\nDie Karte lädt nicht.',
        status: TransmissionStatus.sent,
      );

      final entries = service.all();
      expect(entries, hasLength(1));
      expect(entries.first.payloadText, contains('Die Karte lädt nicht.'));
      expect(entries.first.status, TransmissionStatus.sent);
    });

    test('gibt Einträge neueste zuerst zurück', () async {
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'erster',
        status: TransmissionStatus.sent,
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'zweiter',
        status: TransmissionStatus.sent,
      );

      expect(service.all().first.payloadText, 'zweiter');
    });

    test('aktualisiert den Status von pending auf sent', () async {
      final id = await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'wartet',
        status: TransmissionStatus.pending,
      );

      await service.updateStatus(id, TransmissionStatus.sent);

      expect(service.all().first.status, TransmissionStatus.sent);
    });

    test('speichert den Fehlergrund bei failed', () async {
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'kaputt',
        status: TransmissionStatus.failed,
        errorMessage: 'Keine Verbindung zum Server',
      );

      expect(service.all().first.errorMessage, 'Keine Verbindung zum Server');
    });

    test('löscht einen einzelnen Eintrag', () async {
      final id = await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'weg damit',
        status: TransmissionStatus.sent,
      );

      await service.delete(id);

      expect(service.all(), isEmpty);
    });
  });
}
```

- [x] **Step 2: Test laufen lassen, Fehlschlag prüfen**

```bash
flutter test test/services/transmission_log_service_test.dart
```

Erwartet: FAIL — `transmission_log_service.dart` existiert nicht.

- [x] **Step 3: Implementierung schreiben**

`lib/services/transmission_log_service.dart`:

```dart
import 'package:hive_ce/hive.dart';

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/transmission_log_entry.dart';

/// Lokales Protokoll aller Übertragungsversuche.
///
/// Liegt ausschließlich auf dem Gerät und wird nie übertragen.
/// Es ist Beleg für die Nutzerin, nicht Buchhaltung für die Entwickler.
class TransmissionLogService {
  final Box<TransmissionLogEntry> _box;

  TransmissionLogService({required Box<TransmissionLogEntry> box}) : _box = box;

  /// Legt einen Eintrag an und gibt dessen Id zurück.
  Future<String> record({
    required TransmissionChannel channel,
    required String payloadText,
    required TransmissionStatus status,
    String? errorMessage,
  }) async {
    final timestamp = DateTime.now();
    final id = '${timestamp.microsecondsSinceEpoch}';

    await _box.put(
      id,
      TransmissionLogEntry(
        id: id,
        timestamp: timestamp,
        channel: channel,
        payloadText: payloadText,
        status: status,
        errorMessage: errorMessage,
      ),
    );

    logger.info(
      LogCategory.service,
      'Übertragung protokolliert',
      data: {'id': id, 'channel': channel.name, 'status': status.name},
    );

    return id;
  }

  Future<void> updateStatus(
    String id,
    TransmissionStatus status, {
    String? errorMessage,
  }) async {
    final entry = _box.get(id);
    if (entry == null) return;

    entry.status = status;
    entry.errorMessage = errorMessage;
    await entry.save();
  }

  /// Alle Einträge, neueste zuerst.
  List<TransmissionLogEntry> all() {
    final entries = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();
}
```

- [x] **Step 4: Test laufen lassen**

```bash
flutter test test/services/transmission_log_service_test.dart
```

Erwartet: alle 6 Tests PASS.

- [x] **Step 5: In DI registrieren**

In `lib/core/di/injection.dart`, im Muster der bestehenden Registrierungen (siehe `LocationTrackingService` um Zeile 358), vor der `DataEntry`-Registrierung einfügen:

```dart
  final transmissionLogBox = await Hive.openBox<TransmissionLogEntry>(
    HiveBoxNames.transmissionLog,
  );
  getIt.registerSingleton<TransmissionLogService>(
    TransmissionLogService(box: transmissionLogBox),
  );
```

Passende Imports oben ergänzen:

```dart
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/transmission_log_service.dart';
```

Adapter-Registrierung dort ergänzen, wo die übrigen Adapter registriert werden:

```dart
  Hive.registerAdapter(TransmissionLogEntryAdapter());
  Hive.registerAdapter(TransmissionStatusAdapter());
  Hive.registerAdapter(TransmissionChannelAdapter());
```

- [x] **Step 6: Analyse und Lints**

```bash
flutter analyze
dart run custom_lint
```

Erwartet: keine neuen Fehler.

- [x] **Step 7: Commit**

```bash
git add lib/services/transmission_log_service.dart test/services/transmission_log_service_test.dart lib/core/di/injection.dart
git commit -m "feat: add TransmissionLogService with local-only transmission log"
```

---

## Task 7: Debug-Report von Identifikatoren befreien

Spec 5.1: Profil-ID und Bestandszahlen entfernen. Beide erlauben Verkettung bzw. Wiedererkennung — bei rund 40 Nutzern ist „7 Profile, 1432 Nachrichten, 3 Medikamente" praktisch eindeutig.

**Files:**
- Modify: `lib/utils/enhanced_debug_report_generator.dart`
- Test: `test/utils/debug_report_privacy_test.dart`

**Interfaces:**
- Consumes: bestehende `EnhancedDebugReportGenerator`
- Produces: unveränderte öffentliche Signatur, verändertes Ausgabeformat

- [x] **Step 1: Failing Test schreiben**

`test/utils/debug_report_privacy_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

/// Diese Prüfung arbeitet auf dem Quelltext statt auf der Laufzeitausgabe,
/// weil der Generator Hive-Boxen und GetIt benötigt. Sie verhindert
/// zuverlässig, dass die entfernten Felder unbemerkt zurückkehren.
import 'dart:io';

void main() {
  group('EnhancedDebugReportGenerator', () {
    late String source;

    setUpAll(() {
      source = File('lib/utils/enhanced_debug_report_generator.dart')
          .readAsStringSync();
    });

    test('gibt keine Profil-ID aus', () {
      expect(source.contains("Profile ID:"), isFalse,
          reason: 'Die Profil-ID ist ein stabiler Identifikator und '
              'verkettet mehrere Meldungen derselben Person (Spec 5.1)');
    });

    test('gibt keine Bestandszahlen aus', () {
      for (final forbidden in [
        'Total Profiles:',
        '• Messages:',
        '• Profiles:',
      ]) {
        expect(source.contains(forbidden), isFalse,
            reason: 'Bestandszahlen sind bei ~40 Nutzern quasi eindeutig (Spec 5.1)');
      }
    });

    test('enthält kein Standortfeld', () {
      for (final forbidden in ['latitude', 'longitude', 'Position(', 'getCurrentPosition']) {
        expect(source.contains(forbidden), isFalse,
            reason: 'Standort verlässt das Gerät nie Richtung Entwickler (Spec 4, Kanal 3)');
      }
    });
  });
}
```

- [x] **Step 2: Test laufen lassen, Fehlschlag prüfen**

```bash
flutter test test/utils/debug_report_privacy_test.dart
```

Erwartet: FAIL bei „gibt keine Profil-ID aus" und „gibt keine Bestandszahlen aus". Der Standort-Test sollte bereits PASS sein.

- [x] **Step 3: Felder entfernen**

In `lib/utils/enhanced_debug_report_generator.dart`:

Zeile 204 entfernen:
```dart
        buffer.writeln('Profile ID: ${activeProfile.id}');
```

Den Block mit den Bestandszahlen entfernen (um Zeile 213–231) — betrifft `Total Profiles:`, `• Messages:`, `• Profiles:` und die zugehörigen Box-Zugriffe. Der anonymisierte Profilname, `Has Password` und `Profile Created` bleiben erhalten.

Den Hinweis im Kopf des Reports (Zeile 66–67) erweitern:

```dart
    buffer.writeln('Profile names are anonymized (only IDs shown).');
    buffer.writeln('No chat messages, diary entries, or personal notes included.');
    buffer.writeln('No profile IDs, entry counts, or location data included.');
```

- [x] **Step 4: Test laufen lassen**

```bash
flutter test test/utils/debug_report_privacy_test.dart
flutter analyze lib/utils/enhanced_debug_report_generator.dart
```

Erwartet: alle 3 Tests PASS, keine Analyse-Fehler (ungenutzte Imports entfernen, falls durch das Löschen entstanden).

- [x] **Step 5: Commit**

```bash
git add lib/utils/enhanced_debug_report_generator.dart test/utils/debug_report_privacy_test.dart
git commit -m "fix: remove profile ID and entry counts from debug report"
```

---

## Task 8: Firebase einrichten und FirestoreTransport

**Files:**
- Modify: `pubspec.yaml`
- Create: `android/app/google-services.json` (aus Firebase Console)
- Modify: `android/build.gradle.kts`, `android/app/build.gradle.kts`
- Modify: `lib/main.dart`
- Create: `lib/services/transport/firestore_transport.dart`
- Create: `firestore.rules`

**Interfaces:**
- Consumes: `FeedbackTransport`, `TransportResult` (Task 4), `FeedbackPayload` (Task 3)
- Produces: `FirestoreTransport({FirebaseFirestore? firestore})` mit `isConfigured`, `send()`

**Vorbereitung außerhalb des Codes** (Firebase Console, Projekt `auroa-7f66b`):

1. Firestore-Datenbank anlegen — **Region `europe-west3`**, Modus „Production"
2. Android-App `com.disapp.dis_app` im Projekt registrieren, `google-services.json` herunterladen
3. App Check aktivieren, Play Integrity als Anbieter
4. Budget-Alarm auf dem Projekt einrichten

- [x] **Step 1: Pakete ergänzen**

In `pubspec.yaml` unter `dependencies`:

```yaml
  firebase_core: ^3.8.0
  cloud_firestore: ^5.5.0
  firebase_app_check: ^0.3.1
```

```bash
flutter pub get
```

- [x] **Step 2: Gradle konfigurieren**

In `android/build.gradle.kts` im `plugins`-Block:

```kotlin
    id("com.google.gms.google-services") version "4.4.2" apply false
```

In `android/app/build.gradle.kts` im `plugins`-Block:

```kotlin
    id("com.google.gms.google-services")
```

- [x] **Step 3: Security Rules schreiben**

`firestore.rules`:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Feedback: ausschliesslich anlegen, niemals lesen oder aendern.
    // Ohne Cloud Function davor sind diese Regeln die einzige Verteidigung —
    // der API-Key ist aus jedem APK auslesbar.
    match /feedback/{docId} {
      allow read, update, delete: if false;

      allow create: if request.resource.data.keys().hasOnly(
                         ['category', 'message', 'replyEmail', 'diagnostics', 'createdAt'])
                    && request.resource.data.category is string
                    && request.resource.data.category.size() <= 50
                    && request.resource.data.message is string
                    && request.resource.data.message.size() >= 20
                    && request.resource.data.message.size() <= 5000
                    && (!request.resource.data.keys().hasAny(['replyEmail'])
                        || request.resource.data.replyEmail.size() <= 200)
                    && (!request.resource.data.keys().hasAny(['diagnostics'])
                        || request.resource.data.diagnostics.size() <= 10000);
    }

    // Alles Uebrige ist gesperrt.
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

- [x] **Step 4: Firebase in main.dart initialisieren**

In `lib/main.dart`, vor der bestehenden DI-Initialisierung:

```dart
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
```

Imports:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
```

- [x] **Step 5: FirestoreTransport schreiben**

`lib/services/transport/firestore_transport.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';

/// Schreibt Feedback direkt in die Firestore-Collection `feedback`.
///
/// Bewusst ohne Cloud Function davor: Firestore puffert Schreibvorgaenge
/// offline und stellt sie selbstaendig zu, sobald wieder Verbindung besteht.
/// Eine eigene Retry-Logik entfaellt damit — und genau eine solche
/// selbstgebaute Zustandsmaschine war die Ursache des urspruenglichen Ausfalls.
class FirestoreTransport implements FeedbackTransport {
  static const String collectionName = 'feedback';

  /// Wie lange auf die Server-Bestaetigung gewartet wird, bevor der Versand
  /// als `pending` gilt. Firestore stellt danach im Hintergrund weiter zu.
  static const Duration confirmationTimeout = Duration(seconds: 8);

  final FirebaseFirestore _firestore;

  FirestoreTransport({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Laufzeitpruefung, keine Compile-Zeit-Konstante.
  @override
  bool get isConfigured => _firestore.app.options.projectId.isNotEmpty;

  @override
  String get displayName => 'Direkt an die Entwickler';

  @override
  Future<TransportResult> send(FeedbackPayload payload) async {
    final data = payload.toMap()..['createdAt'] = FieldValue.serverTimestamp();

    try {
      await _firestore
          .collection(collectionName)
          .add(data)
          .timeout(confirmationTimeout);

      logger.info(LogCategory.service, 'Feedback zugestellt');
      return const TransportResult.success();
    } on FirebaseException catch (e) {
      logger.error(LogCategory.service, 'Feedback abgelehnt', error: e);
      return TransportResult.failure(_readableReason(e));
    } catch (_) {
      // Zeitueberschreitung: Firestore hat den Schreibvorgang lokal
      // uebernommen und stellt ihn spaeter zu.
      logger.info(LogCategory.service, 'Feedback wartet auf Verbindung');
      return const TransportResult.pending();
    }
  }

  String _readableReason(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Der Server hat die Nachricht abgelehnt. '
            'Bitte sende sie stattdessen per E-Mail.';
      case 'unavailable':
        return 'Der Server ist gerade nicht erreichbar. '
            'Versuche es später noch einmal oder sende per E-Mail.';
      default:
        return 'Senden fehlgeschlagen (${e.code}). '
            'Du kannst dein Feedback stattdessen per E-Mail schicken.';
    }
  }
}
```

- [x] **Step 6: Rules deployen**

```bash
firebase deploy --only firestore:rules --project auroa-7f66b
```

- [x] **Step 7: Bauen und analysieren**

```bash
flutter analyze
flutter build apk --debug
```

Erwartet: Build läuft durch, keine Analyse-Fehler.

- [x] **Step 8: Commit**

```bash
git add pubspec.yaml pubspec.lock android/ lib/main.dart lib/services/transport/firestore_transport.dart firestore.rules
git commit -m "feat: add Firestore transport with create-only rules and App Check"
```

---

## Task 9: CI-Gate gegen unkonfigurierten Transport

Der eigentliche Fix. Ohne diesen Task behebt der Plan nur den Einzelfall.

**Files:**
- Create: `test/services/transport/transport_config_test.dart`
- Modify: `.github/workflows/test.yml`

**Interfaces:**
- Consumes: `MailtoTransport` (Task 5), `FirestoreTransport` (Task 8)
- Produces: CI-Job `release-gate`

- [x] **Step 1: Gate-Test schreiben**

`test/services/transport/transport_config_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dis_app/services/transport/mailto_transport.dart';

void main() {
  group('Transport-Konfiguration (Release-Gate)', () {
    test('MailtoTransport ist konfiguriert', () {
      expect(MailtoTransport().isConfigured, isTrue,
          reason: 'Ohne funktionierenden Transport darf kein Release entstehen');
    });

    test('google-services.json ist vorhanden', () {
      final file = File('android/app/google-services.json');
      expect(file.existsSync(), isTrue,
          reason: 'Ohne google-services.json initialisiert Firebase nicht — '
              'der Firestore-Transport wäre im Release still funktionslos');
    });

    test('google-services.json nennt das richtige Paket', () {
      final content = File('android/app/google-services.json').readAsStringSync();
      expect(content, contains('com.disapp.dis_app'),
          reason: 'Falsches Paket bedeutet, Firebase initialisiert zur Laufzeit nicht');
    });

    test('kein GitHub-Sendeweg mehr im Quelltext', () {
      final configSource = File('lib/utils/contact_config.dart').readAsStringSync();
      expect(configSource.contains('githubApiToken'), isFalse,
          reason: 'Ein Token als Compile-Zeit-Konstante war die Ursache des '
              'ursprünglichen Ausfalls (siehe Spec 1.1)');
      expect(File('lib/services/github_error_report_service.dart').existsSync(), isFalse);
    });
  });
}
```

- [x] **Step 2: Test laufen lassen**

```bash
flutter test test/services/transport/transport_config_test.dart
```

Erwartet: die ersten drei PASS, der vierte FAIL — der GitHub-Weg existiert noch. Er wird in Task 10 entfernt. Notiere das; der Test ist bewusst vorab geschrieben.

- [x] **Step 3: CI-Job ergänzen**

In `.github/workflows/test.yml` nach dem bestehenden `test`-Job anfügen:

```yaml
  release-gate:
    runs-on: ubuntu-latest
    needs: test
    timeout-minutes: 20

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.4'
        channel: 'stable'

    - name: Install dependencies
      run: flutter pub get

    - name: Restore google-services.json
      env:
        GOOGLE_SERVICES_JSON: ${{ secrets.GOOGLE_SERVICES_JSON }}
      run: echo "$GOOGLE_SERVICES_JSON" > android/app/google-services.json

    - name: Generate code
      run: dart run build_runner build --delete-conflicting-outputs

    # Ohne konfigurierten Transport entsteht kein Artefakt.
    # Genau dieser Schritt fehlte beim Release am 29.11.2025.
    - name: Verify transport configuration
      run: flutter test test/services/transport/transport_config_test.dart

    - name: Build release bundle
      run: flutter build appbundle --release
```

Hinweis: Das Secret `GOOGLE_SERVICES_JSON` muss in den Repository-Einstellungen hinterlegt werden (Inhalt der Datei als Text).

- [x] **Step 4: Commit**

```bash
git add test/services/transport/transport_config_test.dart .github/workflows/test.yml
git commit -m "ci: fail release build when no transport is configured"
```

---

## Task 10: GitHub-Sendeweg entfernen

**Files:**
- Delete: `lib/services/github_error_report_service.dart`, `lib/models/github_submission_result.dart`
- Modify: `lib/utils/contact_config.dart`, `lib/widgets/error_report_dialog.dart`

**Interfaces:**
- Consumes: `TransportResult` (Task 4) als Ersatz für `GitHubSubmissionResult`
- Produces: nichts Neues

- [x] **Step 1: Alle Verwendungsstellen finden**

```bash
grep -rn "GitHubErrorReportService\|GitHubSubmissionResult\|githubApiToken\|isGitHubReportingEnabled" lib/ --include="*.dart"
```

Notiere jede Fundstelle — sie müssen alle ersetzt oder entfernt werden.

- [x] **Step 2: Konstanten entfernen**

In `lib/utils/contact_config.dart` den Block um Zeile 17–36 löschen (`githubApiToken` samt Kommentaren und `isGitHubReportingEnabled`). `supportEmail`, `appName` und `auroraPurple` bleiben — sie werden von `MailtoTransport` und der Oberfläche gebraucht.

- [x] **Step 3: Dateien löschen**

```bash
git rm lib/services/github_error_report_service.dart lib/models/github_submission_result.dart
```

- [x] **Step 4: error_report_dialog.dart anpassen**

Die Meldungen um Zeile 514 und 569 („GitHub ist nicht konfiguriert. Report wurde in Zwischenablage kopiert.") verweisen auf den entfallenden Weg. Ersetze den Sendepfad durch `MailtoTransport` und die Meldungen durch dessen `TransportResult.reason`.

- [x] **Step 5: Analyse bis grün**

```bash
flutter analyze
```

Erwartet: zunächst Fehler an allen Fundstellen aus Step 1. Jede einzeln beheben, bis die Analyse sauber ist.

- [x] **Step 6: Gate-Test läuft jetzt durch**

```bash
flutter test test/services/transport/transport_config_test.dart
```

Erwartet: alle 4 Tests PASS — inklusive des in Task 9 bewusst rot gelassenen.

- [x] **Step 7: Commit**

```bash
git add -A
git commit -m "refactor: remove GitHub reporting path entirely"
```

---

## Task 10b: Drei Feedback-Formulare zu einem zusammenführen

Ohne diesen Task lässt Task 10 zwei verwaiste Formulare zurück, die noch erreichbar sind, aber ins Leere laufen — schlechter als der Ausgangszustand.

**Ausgangslage:** Drei aktive Wege mit derselben Aufgabe.

```
ContactDeveloperFab  → FeedbackBottomSheet (496)  → mailto (funktioniert)
main.dart:882        → FeedbackScreen (722)       → GitHub (tot)
CrashBoundary:205    → ErrorReportDialog (626)    → GitHub (tot)
                     → zwei Danke-Screens (285 + 411)
```

Zusammen 2540 Zeilen. Jede Verbesserung — Vorschau, Validierung, Fehleranzeige — müsste sonst dreimal gebaut und dreimal getestet werden.

**Ziel:**

```
FeedbackForm (~250 Zeilen)
   ├── als Bottom Sheet   (FAB)
   ├── als Vollbild       (Tab)
   └── mit Crash-Kontext  (CrashBoundary)
          ↓
   FeedbackTransport → TransmissionLog
          ↓
   FeedbackResultScreen (ein Screen, parametrisiert)
```

**Files:**
- Create: `lib/modules/feedback/widgets/feedback_form.dart`
- Create: `lib/modules/feedback/feedback_result_screen.dart`
- Modify: `lib/widgets/feedback_bottom_sheet.dart` (wird zur dünnen Hülle)
- Modify: `lib/modules/feedback/feedback_screen.dart` (wird zur dünnen Hülle)
- Modify: `lib/widgets/error_report_dialog.dart` (wird zur dünnen Hülle mit Crash-Kontext)
- Delete: `lib/screens/feedback_thank_you_screen.dart`, `lib/screens/error_report_thank_you_screen.dart`

**Interfaces:**
- Consumes: `FeedbackPayload` (Task 3), `FeedbackTransport` (Task 4)
- Produces: `FeedbackForm({FeedbackCategory? initialCategory, String? crashContext, required void Function(FeedbackPayload) onSubmit})`, `FeedbackResultScreen({required TransportResult result, required String payloadText})`

- [x] **Step 1: Gemeinsames Formular herausziehen**

`lib/modules/feedback/widgets/feedback_form.dart`. Enthält Kategorie-Auswahl, Nachrichtenfeld, optionales E-Mail-Feld, Diagnose-Schalter und den Absende-Knopf — die Logik, die bisher in allen drei Dateien parallel steht.

```dart
class FeedbackForm extends StatefulWidget {
  /// Vorbelegte Kategorie, z.B. „Fehler" beim Aufruf aus der CrashBoundary.
  final FeedbackCategory? initialCategory;

  /// Absturzdaten, falls aus der CrashBoundary aufgerufen.
  /// Wird der Diagnose an den Payload angehängt, nie automatisch gesendet.
  final String? crashContext;

  final void Function(FeedbackPayload payload) onSubmit;

  const FeedbackForm({
    super.key,
    this.initialCategory,
    this.crashContext,
    required this.onSubmit,
  });

  @override
  State<FeedbackForm> createState() => FeedbackFormState();
}
```

Der Zustand (`_messageError`, `_includeDiagnostics`) lebt genau hier — einmal statt dreimal.

- [x] **Step 2: Ein Ergebnis-Screen statt zwei Danke-Screens**

`lib/modules/feedback/feedback_result_screen.dart` ersetzt beide bisherigen Screens:

```dart
class FeedbackResultScreen extends StatelessWidget {
  final TransportResult result;

  /// Wird bei Fehlschlag angezeigt, damit der Text nicht verloren geht.
  final String payloadText;

  const FeedbackResultScreen({
    super.key,
    required this.result,
    required this.payloadText,
  });

  @override
  Widget build(BuildContext context) {
    return switch (result.outcome) {
      TransportOutcome.sent => _buildSent(context),
      TransportOutcome.pending => _buildPending(context),
      TransportOutcome.failed => _buildFailed(context),
    };
  }
}
```

`_buildFailed` zeigt `result.reason` im Klartext, den vollständigen Text zum Kopieren und eine Schaltfläche „Stattdessen per E-Mail senden".

- [x] **Step 3: Die drei Aufrufer auf Hüllen reduzieren**

`FeedbackBottomSheet` wird zu einem `showModalBottomSheet`-Rahmen um `FeedbackForm`. `FeedbackScreen` zu einem `Scaffold` mit `StandardAppBar` um dasselbe Widget. `ErrorReportDialog` zu einem `Dialog`, der zusätzlich `crashContext` durchreicht.

Ziel je Datei: unter 100 Zeilen.

- [x] **Step 4: Alte Danke-Screens entfernen**

```bash
git rm lib/screens/feedback_thank_you_screen.dart lib/screens/error_report_thank_you_screen.dart
```

Die Referenzen in `feedback_screen.dart:527` und `error_report_dialog.dart:540` zeigen dann auf `FeedbackResultScreen`.

- [x] **Step 5: Zeilenzahl prüfen**

```bash
wc -l lib/modules/feedback/widgets/feedback_form.dart lib/modules/feedback/feedback_result_screen.dart lib/widgets/feedback_bottom_sheet.dart lib/modules/feedback/feedback_screen.dart lib/widgets/error_report_dialog.dart
```

Erwartet: zusammen deutlich unter 1000 Zeilen gegenüber 2540 vorher. Weicht das stark ab, ist Logik dupliziert geblieben.

- [x] **Step 6: Alle drei Wege auf dem Gerät prüfen**

```bash
flutter run -d R3CX10FH1RP
```

Durchspielen: FAB öffnen und absenden, Feedback-Tab öffnen und absenden, einen Absturz auslösen und aus der CrashBoundary absenden. Alle drei müssen dasselbe Formular zeigen und im selben Ergebnis-Screen enden.

- [x] **Step 7: Analyse und Lints**

```bash
flutter analyze
dart run custom_lint
```

- [x] **Step 8: Commit**

```bash
git add -A
git commit -m "refactor: unify three feedback forms into one shared widget"
```

---

## Task 11: Formular auf Transport und Protokoll umstellen

Setzt auf dem konsolidierten `FeedbackForm` aus Task 10b auf — die folgenden Änderungen wirken dadurch für alle drei Einstiegspunkte gleichzeitig.

**Files:**
- Modify: `lib/modules/feedback/widgets/feedback_form.dart`

**Interfaces:**
- Consumes: `FeedbackForm` (Task 10b), `FeedbackPayload` (Task 3), `FeedbackTransport`/`TransportResult` (Task 4), `MailtoTransport` (Task 5), `FirestoreTransport` (Task 8), `TransmissionLogService` (Task 6)
- Produces: nichts für spätere Tasks

- [x] **Step 1: Validierung sichtbar machen**

Aktuell schlägt die Mindestlänge von 20 Zeichen still fehl — der Knopf reagiert scheinbar nicht (belegt im Live-Log der Spec: `messageValid: false, messageError: too_short_<20`, gefolgt von acht weiteren Klickversuchen).

State-Feld ergänzen:

```dart
  String? _messageError;
```

Im `TextField` für die Nachricht:

```dart
  TextField(
    controller: _messageController,
    maxLines: 5,
    decoration: InputDecoration(
      labelText: 'Deine Nachricht',
      errorText: _messageError,
    ),
    onChanged: (_) {
      if (_messageError != null) {
        setState(() => _messageError = null);
      }
    },
  ),
```

Im Absende-Handler zuoberst:

```dart
    final message = _messageController.text.trim();

    if (message.runes.length < 20) {
      setState(() {
        _messageError =
            'Bitte schreibe mindestens 20 Zeichen, damit wir das Problem verstehen '
            '(aktuell ${message.runes.length}).';
      });
      return;
    }
```

`runes.length` statt `length`, damit Emoji korrekt gezählt werden.

- [x] **Step 2: Vorschau vor dem Senden einbauen**

Zeigt wörtlich, was das Gerät verlässt — kein Auszug, keine Zusammenfassung:

```dart
  Future<bool> _confirmSend(FeedbackPayload payload) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Das wird gesendet'),
        content: SingleChildScrollView(
          child: SelectableText(payload.toPlainText()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Zurück'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Senden'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
```

`SelectableText` bewusst gewählt: Wer möchte, kann den Text markieren und selbst aufbewahren.

- [x] **Step 3: Payload bauen und Transport wählen**

Der Diagnose-Schalter ist standardmäßig aus:

```dart
  bool _includeDiagnostics = false;
```

```dart
  SwitchListTile(
    value: _includeDiagnostics,
    onChanged: (v) => setState(() => _includeDiagnostics = v),
    title: const Text('Gerätedaten mitsenden'),
    subtitle: const Text(
      'Android-Version und App-Version. Keine Inhalte, keine Namen, kein Standort.',
    ),
  ),
```

Payload zusammenbauen:

```dart
    final payload = FeedbackPayload(
      category: _selectedCategory.displayName,
      message: message,
      replyEmail: _emailController.text.trim(),
      diagnostics: _includeDiagnostics
          ? await EnhancedDebugReportGenerator.generate()
          : null,
    );
```

Beide Wege gleichwertig anbieten, nicht als Haupt- und Notweg. Die Nutzerin wählt vor dem Senden:

```dart
    final transports = <FeedbackTransport>[
      FirestoreTransport(),
      MailtoTransport(),
    ];
```

- [x] **Step 4: Ergebnis protokollieren und anzeigen**

```dart
final result = await transport.send(payload);

await getIt<TransmissionLogService>().record(
  channel: TransmissionChannel.feedback,
  payloadText: payload.toPlainText(),
  status: switch (result.outcome) {
    TransportOutcome.sent => TransmissionStatus.sent,
    TransportOutcome.pending => TransmissionStatus.pending,
    TransportOutcome.failed => TransmissionStatus.failed,
  },
  errorMessage: result.reason,
);
```

Anzeige je Ausgang:

| Ausgang | Anzeige |
|---|---|
| `sent` | „Angekommen. Danke dir." mit Zeitpunkt |
| `pending` | „Wird gesendet, sobald wieder Verbindung besteht." |
| `failed` | `result.reason` im Klartext, daneben die Schaltfläche „Stattdessen per E-Mail senden" |

Die Zwischenablage bleibt als **zusätzliche** Möglichkeit erhalten, ist aber nie die alleinige Reaktion auf einen Fehlschlag. Die Meldung „Feedback kopiert" ohne Zielangabe entfällt.

- [x] **Step 5: Analyse und Lints**

```bash
flutter analyze
dart run custom_lint
```

- [x] **Step 6: Commit**

```bash
git add lib/modules/feedback/widgets/feedback_form.dart
git commit -m "feat: preview payload, surface errors, log every attempt"
```

---

## Task 12: Screen „Was Aurora sendet"

**Files:**
- Create: `lib/modules/transparency/transparency_screen.dart`
- Modify: `lib/modules/settings/settings_screen.dart`

**Interfaces:**
- Consumes: `TransmissionLogService` (Task 6), `TransmissionLogEntry` (Task 2)
- Produces: `TransparencyScreen` (StatefulWidget, kein Konstruktor-Argument)

- [x] **Step 1: Screen anlegen**

`lib/modules/transparency/transparency_screen.dart` — `StandardAppBar` wie in den übrigen Screens (CHANGELOG 3.0.10, 13 Screens sind bereits migriert):

```dart
import 'package:flutter/material.dart';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/transmission_log_service.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';

class TransparencyScreen extends StatefulWidget {
  const TransparencyScreen({super.key});

  @override
  State<TransparencyScreen> createState() => _TransparencyScreenState();
}

class _TransparencyScreenState extends State<TransparencyScreen> {
  late List<TransmissionLogEntry> _entries;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _entries = getIt<TransmissionLogService>().all());
  }

  Future<void> _delete(String id) async {
    await getIt<TransmissionLogService>().delete(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StandardAppBar(title: 'Was Aurora sendet'),
      body: _entries.isEmpty ? const _EmptyState() : _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Hier siehst du jede Übertragung, die dein Gerät verlassen hat — '
              'vollständig und im Wortlaut.',
            ),
          );
        }

        final entry = _entries[index - 1];
        return Dismissible(
          key: ValueKey(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Icon(Icons.delete_outline),
          ),
          onDismissed: (_) => _delete(entry.id),
          child: Card(
            child: ExpansionTile(
              leading: _statusIcon(entry.status),
              title: Text(_formatTimestamp(entry.timestamp)),
              subtitle: Text(_statusLabel(entry)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(entry.payloadText),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Icon _statusIcon(TransmissionStatus status) => switch (status) {
        TransmissionStatus.sent => const Icon(Icons.check_circle_outline),
        TransmissionStatus.pending => const Icon(Icons.schedule),
        TransmissionStatus.failed => const Icon(Icons.error_outline),
      };

  String _statusLabel(TransmissionLogEntry entry) => switch (entry.status) {
        TransmissionStatus.sent => 'Angekommen',
        TransmissionStatus.pending => 'Wartet auf Verbindung',
        TransmissionStatus.failed =>
          'Nicht gesendet: ${entry.errorMessage ?? "Grund unbekannt"}',
      };

  String _formatTimestamp(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}.${t.month.toString().padLeft(2, '0')}.${t.year}, '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} Uhr';
}
```

- [x] **Step 2: Leerzustand gestalten**

Der wichtigste Zustand des Screens. Bewusst als ruhige Bestätigung, nicht als Fehlermeldung oder Aufforderung — für die Zielgruppe ist genau diese Aussage der eigentliche Wert:

```dart
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              'Nichts gesendet.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Aurora hat noch keine Daten an uns übertragen.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [x] **Step 3: In Einstellungen verlinken**

In `lib/modules/settings/settings_screen.dart`, auf oberster Ebene und nicht in einem Untermenü:

```dart
  ListTile(
    leading: const Icon(Icons.outbox_outlined),
    title: const Text('Was Aurora sendet'),
    subtitle: const Text('Jede Übertragung im Wortlaut einsehen'),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TransparencyScreen()),
    ),
  ),
```

- [x] **Step 4: Auf dem Gerät prüfen**

```bash
flutter run -d R3CX10FH1RP
```

Durchspielen: leerer Zustand → Feedback senden → Eintrag erscheint mit vollem Text → Eintrag löschen → wieder leer.

- [x] **Step 5: Analyse und Lints**

```bash
flutter analyze
dart run custom_lint
```

- [x] **Step 6: Commit**

```bash
git add lib/modules/transparency/ lib/modules/settings/settings_screen.dart
git commit -m "feat: add transparency screen showing every transmission"
```

---

## Task 13: Abnahme am Release-Build

Genau dieser Schritt fehlte am 29.11.2025 und ist der Grund, warum der Ausfall acht Monate unbemerkt blieb.

**Files:** keine

**Interfaces:**
- Consumes: alle vorherigen Tasks
- Produces: bestätigter Nachweis der Zustellung

- [x] **Step 1: Volle Testsuite**

```bash
flutter test
dart run custom_lint
flutter analyze
```

Erwartet: alles grün.

- [x] **Step 2: Release-Build erzeugen**

```bash
flutter build apk --release
```

Wichtig: **Release**, nicht Debug. Der ursprüngliche Fehler trat ausschließlich im Release-Build auf, weil der Compiler dort toten Code entfernt.

- [x] **Step 3: Binärscan gegenprobe**

```bash
unzip -p build/app/outputs/flutter-apk/app-release.apk lib/arm64-v8a/libapp.so > /tmp/libapp.so
grep -c "firestore.googleapis.com" /tmp/libapp.so || echo "NICHT GEFUNDEN"
grep -c "Aurora" /tmp/libapp.so
```

Erwartet: Der Firestore-Endpunkt ist vorhanden, die Kontrollprobe `Aurora` ebenfalls. Fehlt der Endpunkt bei vorhandener Kontrollprobe, wurde der Sendepfad erneut wegoptimiert — dann ist der Fehler nicht behoben.

- [x] **Step 4: Auf dem Gerät installieren**

```bash
adb -s R3CX10FH1RP install -r build/app/outputs/flutter-apk/app-release.apk
```

- [x] **Step 5: Zustellung bestätigen**

Feedback in der App absenden, dann serverseitig prüfen:

```bash
gcloud firestore documents list --collection-ids=feedback --project=auroa-7f66b --limit=5
```

Erwartet: Das Dokument ist da, mit dem gesendeten Text.

- [x] **Step 6: Fehlerfall prüfen**

Flugmodus einschalten, Feedback absenden. Erwartet: Meldung „Wird gesendet, sobald wieder Verbindung besteht", Eintrag im Transparenz-Screen als `pending`. Flugmodus aus, App neu starten — der Eintrag wechselt auf `sent`, das Dokument erscheint in Firestore.

- [x] **Step 7: Abschluss-Commit**

```bash
git commit --allow-empty -m "test: verify feedback delivery from release build"
```

---

## Selbstprüfung gegen die Spec

| Spec-Anforderung | Task |
|---|---|
| 2.1 Feedback aus Release-Build erreicht Empfänger | 13 |
| 2.2 Fehler mit Grund und Alternative sichtbar | 11 |
| 2.3 Release mit unkonfiguriertem Kanal nicht baubar | 9 |
| 2.4 Einsicht in Übertragungen | 12 |
| 2.5 Standort erreicht Entwickler nie, per Test gesichert | 3, 7 |
| 4 Kanal 1: Vorschau, Diagnose optional und aus | 3, 11 |
| 4 Kanal 2: nur Regeln, kein Schalter | Modell in 2, keine Umsetzung — wie vorgesehen |
| 4 Kanal 3: kein Standort im Payload | 3, 7 |
| 5.1 Profil-ID und Bestandszahlen entfernt | 7 |
| 5.2 Firestore-SDK, `europe-west3`, Rules, App Check | 8 |
| 5.3 TransmissionLog lokal | 2, 6 |
| 5.4 Screen mit Leerzustand | 12 |
| 5.5 GitHub-Weg entfällt | 10 |
| 5.5 Drei Formulare auf eines zusammenführen | 10b |
| 6 Fehlerbehandlung ohne stille Ausfälle | 11 |
| 7 Tests und CI-Gate | 3, 5, 6, 7, 9 |
| 8.1 Ausgelieferten Stand festschreiben | 1 |

**Nicht in diesem Plan** (Spec 3 und 8.2/8.3/8.4): Übersetzungslücke, Telemetrie-Ereignisse, Store-Listing, Datenschutzerklärung um OpenStreetMap ergänzen, `location_tracking_service.dart` prüfen, Retention-Auswertung aus dem Report-Bucket.
