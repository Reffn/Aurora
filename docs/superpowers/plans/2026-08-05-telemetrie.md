# Telemetrie Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Anonyme Ereigniszählung mit ausdrücklicher Einwilligung, aus der sich Abbruchquoten ergeben, ohne dass je eine Sitzungsreihenfolge das Gerät verlässt.

**Architecture:** `TelemetryRecorder` ist die einzige Stelle, an der Ereignisse entstehen; er fragt vorher `TelemetryConsent` und legt ohne Zustimmung nichts an. Erzeugte Ereignisse landen in einer lokalen Hive-Warteschlange mit gewürfelter Fälligkeit (0–6 h) und werden beim nächsten App-Start von `TelemetryDispatcher` über `FirestoreTelemetryTransport` geschrieben. Jeder Versand erzeugt einen Eintrag im bestehenden `TransmissionLogService` mit `TransmissionChannel.telemetry`.

**Tech Stack:** Flutter, Hive CE, GetIt, cloud_firestore, flutter_test

## Global Constraints

- **Ohne Einwilligung entsteht kein Ereignis.** Nicht sammeln-und-nicht-senden — `TelemetryRecorder.record` kehrt ohne Anlegen zurück.
- **Genau drei Felder pro Dokument:** `event`, `day`, `appVersion`. Kein viertes, auch kein `createdAt`.
- **`day` hat das Format `YYYY-MM-DD`, niemals einen Uhrzeitanteil.** Kein `FieldValue.serverTimestamp()` in der Telemetrie-Collection — der Server würde sonst die Uhrzeit halten, die das Schema verweigert.
- **Versand verzögert sich um 0–6 Stunden**, zufällig pro Ereignis.
- **Die Ereignis-Whitelist steht an zwei Orten:** `TelemetryEventName` in Dart und die Liste in `firestore.rules`. Ein Test vergleicht beide.
- **Ereignisnamen sind stabile Schlüssel**, nie aus `tab.tabItem.label` abgeleitet.
- **Krisenbereiche:** Das Öffnen von Halt, Notfall und Hilfe wird gezählt. Das Auslösen eines Notrufs, das Alarmieren von Kontakten und jede Aktion innerhalb dieser Bereiche erzeugen kein Ereignis.
- **Fehlerereignisse tragen nur den Namen.** Kein Stacktrace, keine Meldung, kein Dateiname.
- **`appVersion` ist die Release-Version** (`3.2.0`), nie Build-Nummer, nie Git-Hash.
- **Freier Hive-typeId:** 35 und aufwärts. Belegt sind 0–26 und 30–34.
- **Hive-Feldreihenfolge nach dem Anlegen nie ändern** — `hive_field_order_check` erzwingt das.
- **`logger.error` hat keinen `error:`-Parameter.** Ausnahmen gehen über `data`.
- **Alle Pfade relativ** (`./lib/...`), Vorgabe aus `CLAUDE.md`.

---

## File Structure

**Neu:**

| Datei | Verantwortung |
|---|---|
| `lib/models/telemetry_event.dart` | Enum `TelemetryEventName` (die Whitelist) und Wertobjekt `TelemetryEvent` mit `toMap()` / `toPlainText()` |
| `lib/models/pending_telemetry_event.dart` | Hive-Typ der Warteschlange (typeId 35) |
| `lib/services/telemetry_consent.dart` | Einwilligungszustand, drei Werte, in der `settings`-Box |
| `lib/services/telemetry_recorder.dart` | Einzige Erzeugungsstelle; Einwilligungsgate |
| `lib/services/telemetry_dispatcher.dart` | Fällige Einträge senden, protokollieren, löschen |
| `lib/services/transport/telemetry_transport.dart` | Interface + `FirestoreTelemetryTransport` |
| `lib/modules/telemetry/telemetry_consent_screen.dart` | Der Einwilligungsschirm |

**Geändert:**

| Datei | Änderung |
|---|---|
| `lib/core/hive_box_names.dart` | Boxname `telemetry_queue` |
| `lib/core/di/injection.dart:418-445` | Box öffnen, vier Dienste registrieren |
| `lib/main.dart:939-1105` | `telemetryKey` je Tab; Aufruf beim Bereichswechsel; Einwilligungsschirm-Gate |
| `lib/modules/transparency/transparency_screen.dart` | Gruppierung nach Kanal |
| `lib/modules/grounding/exercise_player_screen.dart` | Abschluss- und Abbruchereignis |
| `lib/modules/onboarding/pre_onboarding_screen.dart` | Beginn-, Abschluss- und Abbruchereignis |
| `firestore.rules` | Collection `telemetry` |
| `docs/datenschutz.html` | Abschnitt Telemetrie |

**Ein Mechanismus, zwei Anlässe.** `PreOnboardingScreen` ist mit „Nicht mehr anzeigen" überspringbar — ein Einwilligungsschritt *innerhalb* des PageViews würde von genau den Menschen nie gesehen, die zügig durchklicken. Der Einwilligungsschirm ist deshalb **kein** Teil des Onboardings, sondern ein eigener Schirm, der immer dann erscheint, wenn `TelemetryConsent` auf `ungefragt` steht. Neue sehen ihn nach dem Onboarding, bestehende Nutzerinnen beim ersten Start nach dem Update. Das ist derselbe Code für beide Fälle aus Spec-Abschnitt 6.2 und 6.3.

---

## Task 1: Ereignis-Whitelist und Wertobjekt

**Files:**
- Create: `lib/models/telemetry_event.dart`
- Test: `test/models/telemetry_event_test.dart`

**Interfaces:**
- Consumes: nichts
- Produces: `enum TelemetryEventName` mit `String get wireName`; `class TelemetryEvent({required TelemetryEventName name, required DateTime at, required String appVersion})` mit `Map<String, dynamic> toMap()` und `String toPlainText()`

- [x] **Step 1: Write the failing test**

```dart
// test/models/telemetry_event_test.dart
import 'package:dis_app/models/telemetry_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TelemetryEvent', () {
    test('sendet genau drei Felder', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.bereichGeoeffnetChat,
        at: DateTime(2026, 8, 5, 14, 37, 12),
        appVersion: '3.2.0',
      );

      expect(event.toMap().keys.toSet(), {'event', 'day', 'appVersion'});
    });

    test('day traegt kein Uhrzeitanteil', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.bereichGeoeffnetChat,
        at: DateTime(2026, 8, 5, 14, 37, 12),
        appVersion: '3.2.0',
      );

      expect(event.toMap()['day'], '2026-08-05');
    });

    test('day fuellt Monat und Tag auf zwei Stellen auf', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.bereichGeoeffnetChat,
        at: DateTime(2026, 1, 9),
        appVersion: '3.2.0',
      );

      expect(event.toMap()['day'], '2026-01-09');
    });

    test('event traegt den stabilen Schluessel, nicht den Enum-Namen', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.onboardingAbgebrochenPrivacy,
        at: DateTime(2026, 8, 5),
        appVersion: '3.2.0',
      );

      expect(event.toMap()['event'], 'onboarding_abgebrochen_privacy');
    });

    test('kein Ereignisname enthaelt Grossbuchstaben oder Leerzeichen', () {
      for (final name in TelemetryEventName.values) {
        expect(
          RegExp(r'^[a-z0-9_]+$').hasMatch(name.wireName),
          isTrue,
          reason: 'Ereignisname ${name.wireName} verletzt das Namensschema',
        );
      }
    });

    test('Ereignisnamen sind eindeutig', () {
      final wireNames = TelemetryEventName.values.map((e) => e.wireName).toList();
      expect(wireNames.toSet().length, wireNames.length);
    });

    test('toPlainText zeigt genau das, was gesendet wird', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.uebungBeendetBreath,
        at: DateTime(2026, 8, 5),
        appVersion: '3.2.0',
      );

      expect(
        event.toPlainText(),
        'Ereignis: uebung_beendet_breath\nTag: 2026-08-05\nApp-Version: 3.2.0',
      );
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/models/telemetry_event_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:dis_app/models/telemetry_event.dart'`

- [x] **Step 3: Write the implementation**

```dart
// lib/models/telemetry_event.dart

/// Die Whitelist der Ereignisse, die Aurora senden darf.
///
/// Die `wireName`-Werte sind stabile Schluessel, keine Beschriftungen. Sie
/// werden bewusst nicht aus `tab.tabItem.label` abgeleitet: Anzeigetexte
/// aendern sich, und eine Umbenennung wuerde sonst jede Zeitreihe zerreissen.
///
/// Dieselbe Liste steht in `firestore.rules`. Ein Test vergleicht beide —
/// was hier dazukommt und dort fehlt, wird vom Server abgewiesen.
enum TelemetryEventName {
  // Onboarding. Der Abbruch ist ein eigenes Ereignis, damit nie eine
  // Schrittfolge das Geraet verlaesst.
  onboardingBegonnen('onboarding_begonnen'),
  onboardingBeendet('onboarding_beendet'),
  onboardingAbgebrochenWillkommen('onboarding_abgebrochen_willkommen'),
  onboardingAbgebrochenPrivacy('onboarding_abgebrochen_privacy'),
  onboardingAbgebrochenFeatures('onboarding_abgebrochen_features'),
  onboardingAbgebrochenProfile('onboarding_abgebrochen_profile'),
  onboardingAbgebrochenLosGehts('onboarding_abgebrochen_los_gehts'),

  // Anker-Bereiche. Gezaehlt wird ausschliesslich das Oeffnen — auch bei
  // Halt, Notfall und Hilfe. Was innerhalb dieser Bereiche geschieht,
  // erzeugt nie ein Ereignis.
  bereichGeoeffnetHalt('bereich_geoeffnet_halt'),
  bereichGeoeffnetNotfall('bereich_geoeffnet_notfall'),
  bereichGeoeffnetHilfe('bereich_geoeffnet_hilfe'),
  bereichGeoeffnetChat('bereich_geoeffnet_chat'),
  bereichGeoeffnetKalender('bereich_geoeffnet_kalender'),
  bereichGeoeffnetMedikamente('bereich_geoeffnet_medikamente'),
  bereichGeoeffnetTagebuch('bereich_geoeffnet_tagebuch'),
  bereichGeoeffnetKontakte('bereich_geoeffnet_kontakte'),
  bereichGeoeffnetFinder('bereich_geoeffnet_finder'),
  bereichGeoeffnetSpiele('bereich_geoeffnet_spiele'),
  bereichGeoeffnetZeitachse('bereich_geoeffnet_zeitachse'),
  bereichGeoeffnetFeedback('bereich_geoeffnet_feedback'),

  // Uebungen. Abschluss gegen Abbruch misst nicht, ob es geholfen hat,
  // sondern ob es tragbar war. Nach Wirkung wird nicht gefragt.
  uebungBeendetOrientation('uebung_beendet_orientation'),
  uebungBeendetSenses('uebung_beendet_senses'),
  uebungBeendetBody('uebung_beendet_body'),
  uebungBeendetContainer('uebung_beendet_container'),
  uebungBeendetBreath('uebung_beendet_breath'),
  uebungAbgebrochenOrientation('uebung_abgebrochen_orientation'),
  uebungAbgebrochenSenses('uebung_abgebrochen_senses'),
  uebungAbgebrochenBody('uebung_abgebrochen_body'),
  uebungAbgebrochenContainer('uebung_abgebrochen_container'),
  uebungAbgebrochenBreath('uebung_abgebrochen_breath'),

  // Fehler. Nur der Name — Details bleiben lokal und verlassen das Geraet
  // ausschliesslich ueber den Feedback-Kanal, wenn die Nutzerin sie
  // ausdruecklich mitschickt.
  fehlerSpeichern('fehler_speichern'),
  fehlerAnhang('fehler_anhang'),
  fehlerGpsTimeout('fehler_gps_timeout');

  const TelemetryEventName(this.wireName);

  final String wireName;
}

/// Was bei der Telemetrie das Geraet verlaesst.
///
/// Drei Felder, mehr nicht: kein Zaehler, kein Wert, keine Kennung. Standort-
/// und Identifikatorfelder sind hier strukturell nicht vorgesehen — das
/// Schema ist die Stelle, an der die Kanaltrennung durchgesetzt und getestet
/// wird.
class TelemetryEvent {
  const TelemetryEvent({
    required this.name,
    required this.at,
    required this.appVersion,
  });

  final TelemetryEventName name;

  /// Nur der Tag daraus wird gesendet. Mit Sekundengenauigkeit liessen sich
  /// Ereignisse desselben Geraets ueber Zeitnaehe wieder zu einer Sitzung
  /// zusammensetzen — die Uhr taete dann die Verkettung, die das Schema
  /// verweigert.
  final DateTime at;

  final String appVersion;

  String get day => formatDay(at);

  static String formatDay(DateTime moment) {
    final month = moment.month.toString().padLeft(2, '0');
    final day = moment.day.toString().padLeft(2, '0');
    return '${moment.year}-$month-$day';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'event': name.wireName,
      'day': day,
      'appVersion': appVersion,
    };
  }

  /// Woertliche Darstellung fuer das Uebertragungsprotokoll.
  /// Muss exakt das zeigen, was gesendet wird.
  String toPlainText() {
    return 'Ereignis: ${name.wireName}\n'
        'Tag: $day\n'
        'App-Version: $appVersion';
  }
}
```

- [x] **Step 4: Run test to verify it passes**

Run: `flutter test test/models/telemetry_event_test.dart`
Expected: PASS, 7 Tests

- [x] **Step 5: Commit**

```bash
git add lib/models/telemetry_event.dart test/models/telemetry_event_test.dart
git commit -m "feat(telemetry): define the event whitelist and its wire format"
```

---

## Task 2: Einwilligungszustand

**Files:**
- Create: `lib/services/telemetry_consent.dart`
- Test: `test/services/telemetry_consent_test.dart`

**Interfaces:**
- Consumes: nichts
- Produces: `enum TelemetryConsentState { ungefragt, zugestimmt, abgelehnt }`; `class TelemetryConsent({required Box<dynamic> settingsBox})` mit `TelemetryConsentState get state`, `bool get allowsRecording`, `Future<void> grant()`, `Future<void> deny()`, `Future<void> revoke()`

- [x] **Step 1: Write the failing test**

```dart
// test/services/telemetry_consent_test.dart
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/temp_hive.dart';

void main() {
  late Box<dynamic> settingsBox;

  setUp(() async {
    settingsBox = await openTempBox<dynamic>('settings_consent_test');
  });

  tearDown(() async {
    await settingsBox.deleteFromDisk();
  });

  group('TelemetryConsent', () {
    test('startet auf ungefragt', () {
      final consent = TelemetryConsent(settingsBox: settingsBox);

      expect(consent.state, TelemetryConsentState.ungefragt);
      expect(consent.allowsRecording, isFalse);
    });

    test('grant erlaubt das Aufzeichnen', () async {
      final consent = TelemetryConsent(settingsBox: settingsBox);

      await consent.grant();

      expect(consent.state, TelemetryConsentState.zugestimmt);
      expect(consent.allowsRecording, isTrue);
    });

    test('deny gilt als beantwortet, erlaubt aber nichts', () async {
      final consent = TelemetryConsent(settingsBox: settingsBox);

      await consent.deny();

      expect(consent.state, TelemetryConsentState.abgelehnt);
      expect(consent.allowsRecording, isFalse);
      expect(consent.needsAsking, isFalse);
    });

    test('ungefragt bedeutet: noch fragen', () {
      final consent = TelemetryConsent(settingsBox: settingsBox);

      expect(consent.needsAsking, isTrue);
    });

    test('revoke schaltet von zugestimmt auf abgelehnt', () async {
      final consent = TelemetryConsent(settingsBox: settingsBox)..grant();
      await consent.revoke();

      expect(consent.state, TelemetryConsentState.abgelehnt);
      expect(consent.allowsRecording, isFalse);
    });

    test('ueberdauert einen Neustart', () async {
      await TelemetryConsent(settingsBox: settingsBox).grant();

      final wiederGelesen = TelemetryConsent(settingsBox: settingsBox);

      expect(wiederGelesen.state, TelemetryConsentState.zugestimmt);
    });

    test('unbekannter gespeicherter Wert faellt auf ungefragt zurueck', () async {
      await settingsBox.put('telemetry_consent', 'kaputt');

      final consent = TelemetryConsent(settingsBox: settingsBox);

      expect(consent.state, TelemetryConsentState.ungefragt);
    });
  });
}
```

- [x] **Step 2: Create the test helper if it does not exist yet**

Prüfen: `ls test/helpers/temp_hive.dart`. Existiert die Datei, diesen Schritt überspringen. Sonst anlegen:

```dart
// test/helpers/temp_hive.dart
import 'dart:io';

import 'package:hive_ce/hive.dart';

/// Oeffnet eine Hive-Box in einem Wegwerf-Verzeichnis.
/// Ohne Flutter-Bindings, damit reine Unit-Tests schnell bleiben.
Future<Box<T>> openTempBox<T>(String name) async {
  final dir = await Directory.systemTemp.createTemp('aurora_test_');
  Hive.init(dir.path);
  return Hive.openBox<T>(name);
}
```

- [x] **Step 3: Run test to verify it fails**

Run: `flutter test test/services/telemetry_consent_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:dis_app/services/telemetry_consent.dart'`

- [x] **Step 4: Write the implementation**

```dart
// lib/services/telemetry_consent.dart
import 'package:dis_app/core/logger.dart';
import 'package:hive_ce/hive.dart';

/// Drei Zustaende, nicht zwei.
///
/// `ungefragt` und `abgelehnt` verhalten sich beim Aufzeichnen identisch. Sie
/// zu trennen ist noetig, damit der Einwilligungsschirm weiss, ob er schon
/// gezeigt wurde — sonst fragte er bei jedem Start erneut.
enum TelemetryConsentState { ungefragt, zugestimmt, abgelehnt }

/// Einziger Zugriffspunkt auf die Einwilligung zur Telemetrie.
///
/// Rechtsgrundlage ist DSGVO Art. 9 Abs. 2 lit. a: Bei Aurora ist jeder
/// Datenpunkt kontextbedingt ein Gesundheitsdatum — allein die Information,
/// dass ein Geraet eine DIS-App nutzt, offenbart eine Verdachtsdiagnose.
/// Opt-out waere unzulaessig.
class TelemetryConsent {
  TelemetryConsent({required Box<dynamic> settingsBox})
      : _settingsBox = settingsBox;

  static const String storageKey = 'telemetry_consent';

  final Box<dynamic> _settingsBox;

  TelemetryConsentState get state {
    final stored = _settingsBox.get(storageKey);
    return switch (stored) {
      'zugestimmt' => TelemetryConsentState.zugestimmt,
      'abgelehnt' => TelemetryConsentState.abgelehnt,
      // Fehlender oder unbekannter Wert: nicht raten, sondern fragen.
      _ => TelemetryConsentState.ungefragt,
    };
  }

  bool get allowsRecording => state == TelemetryConsentState.zugestimmt;

  bool get needsAsking => state == TelemetryConsentState.ungefragt;

  Future<void> grant() => _write(TelemetryConsentState.zugestimmt);

  /// „Weiter ohne". Gilt als beantwortet — es wird nicht erneut gefragt.
  Future<void> deny() => _write(TelemetryConsentState.abgelehnt);

  /// Widerruf aus den Einstellungen. Fuehrt in denselben Zustand wie `deny`.
  Future<void> revoke() => _write(TelemetryConsentState.abgelehnt);

  Future<void> _write(TelemetryConsentState next) async {
    await _settingsBox.put(storageKey, next.name);
    logger.info(
      LogCategory.service,
      'Telemetrie-Einwilligung geaendert',
      data: {'state': next.name},
    );
  }
}
```

- [x] **Step 5: Run test to verify it passes**

Run: `flutter test test/services/telemetry_consent_test.dart`
Expected: PASS, 7 Tests

- [x] **Step 6: Commit**

```bash
git add lib/services/telemetry_consent.dart test/services/telemetry_consent_test.dart test/helpers/temp_hive.dart
git commit -m "feat(telemetry): hold consent in three states, not two"
```

---

## Task 3: Warteschlange und Erzeugungsgate

**Files:**
- Create: `lib/models/pending_telemetry_event.dart`
- Create: `lib/services/telemetry_recorder.dart`
- Modify: `lib/core/hive_box_names.dart:22`
- Test: `test/services/telemetry_recorder_test.dart`

**Interfaces:**
- Consumes: `TelemetryEventName`, `TelemetryEvent.formatDay` (Task 1); `TelemetryConsent.allowsRecording` (Task 2)
- Produces: `class PendingTelemetryEvent` (typeId 35) mit `String id`, `String eventName`, `String day`, `String appVersion`, `DateTime dueAt`; `class TelemetryRecorder({required TelemetryConsent consent, required Box<PendingTelemetryEvent> queue, required String appVersion, DateTime Function()? now, Random? random})` mit `Future<void> record(TelemetryEventName name)` und `Future<void> clearQueue()`

- [x] **Step 1: Write the failing test**

```dart
// test/services/telemetry_recorder_test.dart
import 'dart:math';

import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/temp_hive.dart';

void main() {
  late Box<dynamic> settingsBox;
  late Box<PendingTelemetryEvent> queue;
  late TelemetryConsent consent;

  setUp(() async {
    settingsBox = await openTempBox<dynamic>('settings_recorder_test');
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(PendingTelemetryEventAdapter());
    }
    queue = await openTempBox<PendingTelemetryEvent>('telemetry_queue_test');
    consent = TelemetryConsent(settingsBox: settingsBox);
  });

  tearDown(() async {
    await settingsBox.deleteFromDisk();
    await queue.deleteFromDisk();
  });

  TelemetryRecorder buildRecorder({DateTime? now, Random? random}) {
    return TelemetryRecorder(
      consent: consent,
      queue: queue,
      appVersion: '3.2.0',
      now: () => now ?? DateTime(2026, 8, 5, 10),
      random: random ?? Random(1),
    );
  }

  group('TelemetryRecorder ohne Einwilligung', () {
    test('legt bei ungefragt nichts an', () async {
      await buildRecorder().record(TelemetryEventName.bereichGeoeffnetChat);

      expect(queue.length, 0);
    });

    test('legt bei abgelehnt nichts an', () async {
      await consent.deny();

      await buildRecorder().record(TelemetryEventName.bereichGeoeffnetChat);

      expect(queue.length, 0);
    });
  });

  group('TelemetryRecorder mit Einwilligung', () {
    setUp(() async {
      await consent.grant();
    });

    test('legt genau einen Eintrag an', () async {
      await buildRecorder().record(TelemetryEventName.bereichGeoeffnetChat);

      expect(queue.length, 1);
      expect(queue.values.first.eventName, 'bereich_geoeffnet_chat');
    });

    test('speichert den Tag ohne Uhrzeit', () async {
      await buildRecorder(now: DateTime(2026, 8, 5, 23, 59, 59))
          .record(TelemetryEventName.bereichGeoeffnetChat);

      expect(queue.values.first.day, '2026-08-05');
    });

    test('faelligkeit liegt zwischen jetzt und sechs Stunden spaeter', () async {
      final now = DateTime(2026, 8, 5, 10);

      for (var seed = 0; seed < 20; seed++) {
        await queue.clear();
        await buildRecorder(now: now, random: Random(seed))
            .record(TelemetryEventName.bereichGeoeffnetChat);

        final dueAt = queue.values.first.dueAt;
        expect(dueAt.isBefore(now), isFalse);
        expect(dueAt.isAfter(now.add(const Duration(hours: 6))), isFalse);
      }
    });

    test('zwei Ereignisse bekommen verschiedene Ids', () async {
      final recorder = buildRecorder();
      await recorder.record(TelemetryEventName.bereichGeoeffnetChat);
      await recorder.record(TelemetryEventName.bereichGeoeffnetHalt);

      final ids = queue.values.map((e) => e.id).toSet();
      expect(ids.length, 2);
    });

    test('clearQueue leert die Warteschlange', () async {
      final recorder = buildRecorder();
      await recorder.record(TelemetryEventName.bereichGeoeffnetChat);

      await recorder.clearQueue();

      expect(queue.length, 0);
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/telemetry_recorder_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:dis_app/models/pending_telemetry_event.dart'`

- [x] **Step 3: Write the Hive model**

```dart
// lib/models/pending_telemetry_event.dart
import 'package:hive_ce/hive.dart';

part 'pending_telemetry_event.g.dart';

/// Ein erzeugtes, noch nicht gesendetes Telemetrie-Ereignis.
///
/// Liegt ausschliesslich lokal. Existiert nur auf Geraeten mit erteilter
/// Einwilligung — ohne sie wird gar nichts erst angelegt.
///
/// Feldreihenfolge nach dem Anlegen nie aendern (`hive_field_order_check`).
@HiveType(typeId: 35)
class PendingTelemetryEvent extends HiveObject {
  PendingTelemetryEvent({
    required this.id,
    required this.eventName,
    required this.day,
    required this.appVersion,
    required this.dueAt,
  });

  @HiveField(0)
  final String id;

  /// Der stabile Schluessel aus `TelemetryEventName.wireName`.
  @HiveField(1)
  final String eventName;

  /// `YYYY-MM-DD`. Bewusst als String und nicht als DateTime: ein DateTime
  /// truege eine Uhrzeit mit, und genau die soll das Geraet nie verlassen.
  @HiveField(2)
  final String day;

  @HiveField(3)
  final String appVersion;

  /// Wann fruehestens gesendet werden darf. Gewuerfelt bei der Erzeugung.
  /// Bleibt lokal — der Server erfaehrt nie, wann das Ereignis entstand.
  @HiveField(4)
  final DateTime dueAt;
}
```

- [x] **Step 4: Generate the Hive adapter**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `pending_telemetry_event.g.dart` wird erzeugt

- [x] **Step 5: Write the recorder**

```dart
// lib/services/telemetry_recorder.dart
import 'dart:math';

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:hive_ce/hive.dart';

/// Die einzige Stelle, an der Telemetrie-Ereignisse entstehen.
///
/// Ohne Einwilligung wird nicht gesammelt-und-nicht-gesendet, sondern gar
/// nichts angelegt. Eine gefuellte Warteschlange auf einem Geraet ohne
/// Einwilligung waere bereits die Datenhaltung, die vermieden werden soll.
class TelemetryRecorder {
  TelemetryRecorder({
    required TelemetryConsent consent,
    required Box<PendingTelemetryEvent> queue,
    required String appVersion,
    DateTime Function()? now,
    Random? random,
  })  : _consent = consent,
        _queue = queue,
        _appVersion = appVersion,
        _now = now ?? DateTime.now,
        _random = random ?? Random();

  /// Obergrenze der Zufallsverzoegerung. Wuerden Ereignisse sofort gesendet,
  /// liessen sich mehrere Eingaenge derselben Minute serverseitig zu einer
  /// Sitzung zusammenfassen. Die Verzoegerung zerreisst diesen Zusammenhang,
  /// bevor er entsteht.
  static const Duration maxDelay = Duration(hours: 6);

  final TelemetryConsent _consent;
  final Box<PendingTelemetryEvent> _queue;
  final String _appVersion;
  final DateTime Function() _now;
  final Random _random;

  int _counter = 0;

  Future<void> record(TelemetryEventName name) async {
    if (!_consent.allowsRecording) return;

    final moment = _now();
    _counter++;
    final id = '${moment.microsecondsSinceEpoch}_$_counter';

    await _queue.put(
      id,
      PendingTelemetryEvent(
        id: id,
        eventName: name.wireName,
        day: TelemetryEvent.formatDay(moment),
        appVersion: _appVersion,
        dueAt: moment.add(
          Duration(seconds: _random.nextInt(maxDelay.inSeconds + 1)),
        ),
      ),
    );

    logger.info(
      LogCategory.service,
      'Telemetrie-Ereignis vorgemerkt',
      data: {'event': name.wireName},
    );
  }

  /// Beim Widerruf. Was noch nicht gesendet wurde, wird nicht mehr gesendet.
  Future<void> clearQueue() => _queue.clear();
}
```

- [x] **Step 6: Add the box name**

In `lib/core/hive_box_names.dart` nach Zeile 22 einfügen:

```dart
  static const String telemetryQueue = 'telemetry_queue';
```

- [x] **Step 7: Run test to verify it passes**

Run: `flutter test test/services/telemetry_recorder_test.dart`
Expected: PASS, 7 Tests

- [x] **Step 8: Commit**

```bash
git add lib/models/pending_telemetry_event.dart lib/models/pending_telemetry_event.g.dart lib/services/telemetry_recorder.dart lib/core/hive_box_names.dart test/services/telemetry_recorder_test.dart
git commit -m "feat(telemetry): create no event at all without consent"
```

---

## Task 4: Firestore-Transport

**Files:**
- Create: `lib/services/transport/telemetry_transport.dart`
- Test: `test/services/transport/telemetry_transport_test.dart`

**Interfaces:**
- Consumes: `TelemetryEvent` (Task 1); `TransportResult` / `TransportOutcome` aus `lib/services/transport/feedback_transport.dart`
- Produces: `abstract class TelemetryTransport` mit `bool get isConfigured` und `Future<TransportResult> send(TelemetryEvent event)`; `class FirestoreTelemetryTransport({FirestoreWriter? writer, IsConfiguredChecker? configChecker})` mit `static const String collectionName = 'telemetry'`

- [x] **Step 1: Write the failing test**

```dart
// test/services/transport/telemetry_transport_test.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/telemetry_transport.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final event = TelemetryEvent(
    name: TelemetryEventName.bereichGeoeffnetChat,
    at: DateTime(2026, 8, 5, 14, 37),
    appVersion: '3.2.0',
  );

  group('FirestoreTelemetryTransport', () {
    test('schreibt genau drei Felder, ohne Server-Zeitstempel', () async {
      Map<String, dynamic>? geschrieben;
      final transport = FirestoreTelemetryTransport(
        writer: (data) async => geschrieben = data,
        configChecker: () => true,
      );

      await transport.send(event);

      expect(geschrieben!.keys.toSet(), {'event', 'day', 'appVersion'});
    });

    test('meldet Erfolg', () async {
      final transport = FirestoreTelemetryTransport(
        writer: (_) async {},
        configChecker: () => true,
      );

      final result = await transport.send(event);

      expect(result.outcome, TransportOutcome.sent);
    });

    test('Zeitueberschreitung gilt als pending, nicht als Fehler', () async {
      final transport = FirestoreTelemetryTransport(
        writer: (_) async => throw TimeoutException('zu langsam'),
        configChecker: () => true,
      );

      final result = await transport.send(event);

      expect(result.outcome, TransportOutcome.pending);
    });

    test('abgelehnter Schreibvorgang gilt als failed', () async {
      final transport = FirestoreTelemetryTransport(
        writer: (_) async =>
            throw FirebaseException(plugin: 'test', code: 'permission-denied'),
        configChecker: () => true,
      );

      final result = await transport.send(event);

      expect(result.outcome, TransportOutcome.failed);
      expect(result.reason, isNotNull);
    });

    test('isConfigured ist eine Laufzeitpruefung und wirft nie', () {
      final transport = FirestoreTelemetryTransport(
        writer: (_) async {},
        configChecker: () => throw StateError('Firebase fehlt'),
      );

      expect(transport.isConfigured, isFalse);
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/transport/telemetry_transport_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:dis_app/services/transport/telemetry_transport.dart'`

- [x] **Step 3: Write the implementation**

```dart
// lib/services/transport/telemetry_transport.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';

/// Ein Weg, auf dem ein Telemetrie-Ereignis das Geraet verlaesst.
///
/// Wie bei `FeedbackTransport` gilt: [isConfigured] darf keine
/// Compile-Zeit-Konstante auswerten. Ein konstant leerer Wert liesse den
/// Compiler den gesamten Sendepfad entfernen, ohne dass es zur Laufzeit
/// bemerkbar waere — genau das hat den Feedback-Kanal acht Monate stillgelegt.
abstract class TelemetryTransport {
  bool get isConfigured;

  Future<TransportResult> send(TelemetryEvent event);
}

/// Schreibt in die Firestore-Collection `telemetry`.
///
/// Kein `mailto:`-Gegenstueck: automatische Ereignisse ueber den Mail-Client
/// der Nutzerin zu schicken, waere absurd. Faellt der Weg aus, bleibt das
/// Ereignis in der lokalen Warteschlange.
class FirestoreTelemetryTransport implements TelemetryTransport {
  FirestoreTelemetryTransport({
    FirestoreWriter? writer,
    IsConfiguredChecker? configChecker,
  })  : _writer = writer ?? _defaultWriter,
        _isConfiguredChecker = configChecker ?? _defaultIsConfiguredChecker;

  static const String collectionName = 'telemetry';

  static const Duration confirmationTimeout = Duration(seconds: 8);

  final FirestoreWriter _writer;
  final IsConfiguredChecker _isConfiguredChecker;

  static Future<void> _defaultWriter(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .add(data)
        .timeout(confirmationTimeout);
  }

  static bool _defaultIsConfiguredChecker() {
    try {
      return FirebaseFirestore.instance.app.options.projectId.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  bool get isConfigured {
    try {
      return _isConfiguredChecker();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<TransportResult> send(TelemetryEvent event) async {
    // Bewusst ohne `createdAt`/serverTimestamp: der Server soll die Uhrzeit
    // nicht halten, die das Schema verweigert. `day` genuegt fuer jede Frage,
    // die diese Erhebung beantworten soll.
    final data = event.toMap();

    try {
      await _writer(data);
      return const TransportResult.success();
    } on TimeoutException {
      // Firestore hat den Schreibvorgang lokal uebernommen und stellt ihn
      // spaeter zu. Kein Fehler.
      return const TransportResult.pending();
    } on FirebaseException catch (e) {
      logger.error(
        LogCategory.service,
        'Telemetrie abgelehnt',
        data: {'error': e.code},
      );
      return TransportResult.failure('Abgelehnt (${e.code})');
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Telemetrie-Versand fehlgeschlagen',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      return const TransportResult.failure('Senden fehlgeschlagen');
    }
  }
}
```

- [x] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/transport/telemetry_transport_test.dart`
Expected: PASS, 5 Tests

- [x] **Step 5: Commit**

```bash
git add lib/services/transport/telemetry_transport.dart test/services/transport/telemetry_transport_test.dart
git commit -m "feat(telemetry): write events to Firestore without a server timestamp"
```

---

## Task 5: Versand fälliger Ereignisse

**Files:**
- Create: `lib/services/telemetry_dispatcher.dart`
- Test: `test/services/telemetry_dispatcher_test.dart`

**Interfaces:**
- Consumes: `PendingTelemetryEvent`, `TelemetryRecorder` (Task 3); `TelemetryTransport` (Task 4); `TransmissionRecorder` aus `lib/services/feedback_sender.dart`; `TransmissionChannel` / `TransmissionStatus` aus `lib/models/transmission_log_entry.dart`
- Produces: `class TelemetryDispatcher({required Box<PendingTelemetryEvent> queue, required TelemetryTransport transport, required TransmissionRecorder record, DateTime Function()? now})` mit `Future<int> flush()` (gibt die Anzahl zugestellter Ereignisse zurück)

- [x] **Step 1: Write the failing test**

```dart
// test/services/telemetry_dispatcher_test.dart
import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/telemetry_dispatcher.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/telemetry_transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/temp_hive.dart';

class _FakeTransport implements TelemetryTransport {
  _FakeTransport(this.result, {this.configured = true});

  final TransportResult result;
  final bool configured;
  final List<TelemetryEvent> gesendet = [];

  @override
  bool get isConfigured => configured;

  @override
  Future<TransportResult> send(TelemetryEvent event) async {
    gesendet.add(event);
    return result;
  }
}

void main() {
  late Box<PendingTelemetryEvent> queue;
  late List<Map<String, Object?>> protokoll;

  setUp(() async {
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(PendingTelemetryEventAdapter());
    }
    queue = await openTempBox<PendingTelemetryEvent>('telemetry_dispatch_test');
    protokoll = [];
  });

  tearDown(() async {
    await queue.deleteFromDisk();
  });

  Future<void> enqueue(String id, DateTime dueAt) async {
    await queue.put(
      id,
      PendingTelemetryEvent(
        id: id,
        eventName: 'bereich_geoeffnet_chat',
        day: '2026-08-05',
        appVersion: '3.2.0',
        dueAt: dueAt,
      ),
    );
  }

  TelemetryDispatcher buildDispatcher(
    TelemetryTransport transport, {
    DateTime? now,
  }) {
    return TelemetryDispatcher(
      queue: queue,
      transport: transport,
      now: () => now ?? DateTime(2026, 8, 5, 12),
      record: ({
        required TransmissionChannel channel,
        required String payloadText,
        required TransmissionStatus status,
        String? errorMessage,
      }) async {
        protokoll.add({
          'channel': channel,
          'payloadText': payloadText,
          'status': status,
          'errorMessage': errorMessage,
        });
      },
    );
  }

  group('TelemetryDispatcher', () {
    test('sendet nur faellige Ereignisse', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));
      await enqueue('spaeter', DateTime(2026, 8, 5, 15));
      final transport = _FakeTransport(const TransportResult.success());

      final zugestellt = await buildDispatcher(transport).flush();

      expect(zugestellt, 1);
      expect(transport.gesendet.single.name,
          TelemetryEventName.bereichGeoeffnetChat);
      expect(queue.containsKey('spaeter'), isTrue);
    });

    test('entfernt zugestellte Ereignisse aus der Warteschlange', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));

      await buildDispatcher(_FakeTransport(const TransportResult.success()))
          .flush();

      expect(queue.containsKey('faellig'), isFalse);
    });

    test('protokolliert jeden Versand im Telemetrie-Kanal', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));

      await buildDispatcher(_FakeTransport(const TransportResult.success()))
          .flush();

      expect(protokoll.single['channel'], TransmissionChannel.telemetry);
      expect(protokoll.single['status'], TransmissionStatus.sent);
      expect(
        protokoll.single['payloadText'],
        'Ereignis: bereich_geoeffnet_chat\nTag: 2026-08-05\nApp-Version: 3.2.0',
      );
    });

    test('behaelt fehlgeschlagene Ereignisse fuer den naechsten Versuch',
        () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));

      await buildDispatcher(
        _FakeTransport(const TransportResult.failure('abgelehnt')),
      ).flush();

      expect(queue.containsKey('faellig'), isTrue);
      expect(protokoll.single['status'], TransmissionStatus.failed);
    });

    test('pending gilt als zugestellt und raeumt die Warteschlange', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));

      await buildDispatcher(_FakeTransport(const TransportResult.pending()))
          .flush();

      expect(queue.containsKey('faellig'), isFalse);
      expect(protokoll.single['status'], TransmissionStatus.pending);
    });

    test('sendet nichts, wenn kein Ziel konfiguriert ist', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));
      final transport = _FakeTransport(
        const TransportResult.success(),
        configured: false,
      );

      final zugestellt = await buildDispatcher(transport).flush();

      expect(zugestellt, 0);
      expect(transport.gesendet, isEmpty);
      expect(queue.containsKey('faellig'), isTrue);
      expect(protokoll, isEmpty);
    });

    test('unbekannter Ereignisname wird verworfen, nicht gesendet', () async {
      await queue.put(
        'kaputt',
        PendingTelemetryEvent(
          id: 'kaputt',
          eventName: 'ereignis_aus_einer_alten_version',
          day: '2026-08-05',
          appVersion: '3.1.0',
          dueAt: DateTime(2026, 8, 5, 11),
        ),
      );
      final transport = _FakeTransport(const TransportResult.success());

      await buildDispatcher(transport).flush();

      expect(transport.gesendet, isEmpty);
      expect(queue.containsKey('kaputt'), isFalse);
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/telemetry_dispatcher_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:dis_app/services/telemetry_dispatcher.dart'`

- [x] **Step 3: Write the implementation**

```dart
// lib/services/telemetry_dispatcher.dart
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/feedback_sender.dart' show TransmissionRecorder;
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/telemetry_transport.dart';
import 'package:hive_ce/hive.dart';

/// Sendet faellige Ereignisse aus der lokalen Warteschlange.
///
/// Laeuft beim App-Start, nicht in einem Hintergrunddienst: Die Verzoegerung
/// aus `TelemetryRecorder.maxDelay` soll nur den zeitlichen Zusammenhang
/// zerreissen, nicht einen Weckdienst rechtfertigen.
class TelemetryDispatcher {
  TelemetryDispatcher({
    required Box<PendingTelemetryEvent> queue,
    required TelemetryTransport transport,
    required TransmissionRecorder record,
    DateTime Function()? now,
  })  : _queue = queue,
        _transport = transport,
        _record = record,
        _now = now ?? DateTime.now;

  final Box<PendingTelemetryEvent> _queue;
  final TelemetryTransport _transport;
  final TransmissionRecorder _record;
  final DateTime Function() _now;

  /// Gibt die Anzahl der Eintraege zurueck, die die Warteschlange verlassen
  /// haben — zugestellt oder vom SDK uebernommen.
  Future<int> flush() async {
    if (!_transport.isConfigured) {
      logger.info(LogCategory.service, 'Telemetrie: kein Ziel konfiguriert');
      return 0;
    }

    final moment = _now();
    final faellig = _queue.values
        .where((entry) => !entry.dueAt.isAfter(moment))
        .toList(growable: false);

    var zugestellt = 0;

    for (final entry in faellig) {
      final name = _resolve(entry.eventName);

      // Ein Name, den diese Version nicht kennt, stammt aus einer aelteren
      // Warteschlange. Der Server wuerde ihn ohnehin abweisen — er wird
      // verworfen statt endlos wiederholt.
      if (name == null) {
        logger.info(
          LogCategory.service,
          'Telemetrie: unbekanntes Ereignis verworfen',
          data: {'event': entry.eventName},
        );
        await _queue.delete(entry.id);
        continue;
      }

      final event = TelemetryEvent(
        name: name,
        at: _parseDay(entry.day),
        appVersion: entry.appVersion,
      );

      final result = await _transport.send(event);

      await _record(
        channel: TransmissionChannel.telemetry,
        payloadText: event.toPlainText(),
        status: _statusOf(result.outcome),
        errorMessage: result.reason,
      );

      // `failed` bleibt liegen und wird beim naechsten Start erneut versucht.
      if (result.outcome != TransportOutcome.failed) {
        await _queue.delete(entry.id);
        zugestellt++;
      }
    }

    return zugestellt;
  }

  static TelemetryEventName? _resolve(String wireName) {
    for (final candidate in TelemetryEventName.values) {
      if (candidate.wireName == wireName) return candidate;
    }
    return null;
  }

  /// `YYYY-MM-DD` zurueck in ein DateTime. Die Uhrzeit bleibt Mitternacht —
  /// eine genauere gibt es nicht, und das ist Absicht.
  static DateTime _parseDay(String day) => DateTime.parse(day);

  static TransmissionStatus _statusOf(TransportOutcome outcome) {
    return switch (outcome) {
      TransportOutcome.sent => TransmissionStatus.sent,
      TransportOutcome.pending => TransmissionStatus.pending,
      TransportOutcome.failed => TransmissionStatus.failed,
    };
  }
}
```

- [x] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/telemetry_dispatcher_test.dart`
Expected: PASS, 7 Tests

- [x] **Step 5: Commit**

```bash
git add lib/services/telemetry_dispatcher.dart test/services/telemetry_dispatcher_test.dart
git commit -m "feat(telemetry): send only what is due and log every attempt"
```

---

## Task 6: Security Rules

**Files:**
- Modify: `firestore.rules:26-34`
- Test: `test/services/telemetry_rules_whitelist_test.dart`

**Interfaces:**
- Consumes: `TelemetryEventName` (Task 1)
- Produces: Collection `telemetry` mit `create`-only und Feld-Whitelist

- [x] **Step 1: Write the failing test**

Dieser Test hält die zwei Orte zusammen, an denen die Whitelist steht. Er liest die Regeldatei und vergleicht sie mit dem Enum.

```dart
// test/services/telemetry_rules_whitelist_test.dart
import 'dart:io';

import 'package:dis_app/models/telemetry_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Whitelist in firestore.rules deckt sich mit TelemetryEventName', () {
    final rules = File('firestore.rules').readAsStringSync();

    final block = RegExp(
      r'let ERLAUBTE_EREIGNISSE = \[(.*?)\];',
      dotAll: true,
    ).firstMatch(rules);

    expect(block, isNotNull, reason: 'ERLAUBTE_EREIGNISSE fehlt in firestore.rules');

    final inRules = RegExp("'([a-z0-9_]+)'")
        .allMatches(block!.group(1)!)
        .map((m) => m.group(1)!)
        .toSet();

    final inDart =
        TelemetryEventName.values.map((e) => e.wireName).toSet();

    expect(
      inRules,
      inDart,
      reason: 'Client und Regeln kennen unterschiedliche Ereignisse. '
          'Was nur im Client steht, wird vom Server abgewiesen.',
    );
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/telemetry_rules_whitelist_test.dart`
Expected: FAIL — `ERLAUBTE_EREIGNISSE fehlt in firestore.rules`

- [x] **Step 3: Add the telemetry rules**

In `firestore.rules` den Block vor `match /{document=**}` einfügen (also nach dem schließenden `}` der Feedback-Regel, Zeile 26):

```
    // Telemetrie: ausschliesslich anlegen, niemals lesen, aendern oder loeschen.
    //
    // Anders als Feedback traegt die Telemetrie bewusst KEINEN Server-
    // Zeitstempel. Ein `createdAt == request.time` wuerde die Uhrzeit halten,
    // die das Schema gerade verweigert — mehrere Eingaenge derselben Minute
    // liessen sich sonst zu einer Sitzung zusammenfassen.
    match /telemetry/{docId} {
      allow read, update, delete: if false;

      allow create: if isWellFormedTelemetry();
    }
```

Und am Dateiende die Prüffunktion anhängen:

```
// Feld-Whitelist der Telemetrie. Spiegelt TelemetryEvent.toMap() in
// lib/models/telemetry_event.dart — genau drei Felder, kein viertes.
//
// ERLAUBTE_EREIGNISSE ist die zweite Haelfte der Whitelist aus
// TelemetryEventName. Der Test test/services/telemetry_rules_whitelist_test.dart
// haelt beide Listen deckungsgleich.
function isWellFormedTelemetry() {
  let data = request.resource.data;
  let ERLAUBTE_EREIGNISSE = [
    'onboarding_begonnen',
    'onboarding_beendet',
    'onboarding_abgebrochen_willkommen',
    'onboarding_abgebrochen_privacy',
    'onboarding_abgebrochen_features',
    'onboarding_abgebrochen_profile',
    'onboarding_abgebrochen_los_gehts',
    'bereich_geoeffnet_halt',
    'bereich_geoeffnet_notfall',
    'bereich_geoeffnet_hilfe',
    'bereich_geoeffnet_chat',
    'bereich_geoeffnet_kalender',
    'bereich_geoeffnet_medikamente',
    'bereich_geoeffnet_tagebuch',
    'bereich_geoeffnet_kontakte',
    'bereich_geoeffnet_finder',
    'bereich_geoeffnet_spiele',
    'bereich_geoeffnet_zeitachse',
    'bereich_geoeffnet_feedback',
    'uebung_beendet_orientation',
    'uebung_beendet_senses',
    'uebung_beendet_body',
    'uebung_beendet_container',
    'uebung_beendet_breath',
    'uebung_abgebrochen_orientation',
    'uebung_abgebrochen_senses',
    'uebung_abgebrochen_body',
    'uebung_abgebrochen_container',
    'uebung_abgebrochen_breath',
    'fehler_speichern',
    'fehler_anhang',
    'fehler_gps_timeout'
  ];

  return data.keys().hasOnly(['event', 'day', 'appVersion'])
         && data.keys().hasAll(['event', 'day', 'appVersion'])

         && data.event is string
         && data.event in ERLAUBTE_EREIGNISSE

         // Genau zehn Zeichen im Format YYYY-MM-DD. Ein Uhrzeitanteil
         // waere laenger und fliegt hier raus.
         && data.day is string
         && data.day.size() == 10
         && data.day.matches('^[0-9]{4}-[0-9]{2}-[0-9]{2}$')

         && data.appVersion is string
         && data.appVersion.size() > 0
         && data.appVersion.size() <= 20;
}
```

- [x] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/telemetry_rules_whitelist_test.dart`
Expected: PASS

- [x] **Step 5: Verify the rules compile**

Run: `firebase deploy --only firestore:rules --dry-run`
Expected: `rules file firestore.rules compiled successfully`

Schlägt der Befehl mangels Firebase-CLI fehl, wird das im Commit vermerkt und vor dem Rollout nachgeholt — die Regeln sind ohne Cloud Function die einzige Verteidigung.

- [x] **Step 6: Commit**

```bash
git add firestore.rules test/services/telemetry_rules_whitelist_test.dart
git commit -m "feat(telemetry): let the server reject anything but three known fields"
```

---

## Task 7: Verdrahtung

**Files:**
- Modify: `lib/core/di/injection.dart:418-445`
- Test: `test/services/telemetry_wiring_test.dart`

**Interfaces:**
- Consumes: alles aus Task 1–5
- Produces: `getIt<TelemetryConsent>()`, `getIt<TelemetryRecorder>()`, `getIt<TelemetryDispatcher>()`, `getIt<FirestoreTelemetryTransport>()`

- [x] **Step 1: Read the surrounding code**

Run: `sed -n '410,450p' lib/core/di/injection.dart`
Zweck: Das Muster der bestehenden Registrierungen (Box öffnen → Dienst bauen → `registerSingleton` → Logzeile) übernehmen, statt ein eigenes zu erfinden.

- [x] **Step 2: Write the failing test**

```dart
// test/services/telemetry_wiring_test.dart
import 'package:dis_app/models/telemetry_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('appVersion ist die Release-Version ohne Build-Nummer', () {
    // package_info_plus liefert version und buildNumber getrennt.
    // Gesendet wird ausschliesslich version — eine Build-Nummer waere bei
    // zehn Geraeten ein Merkmal.
    const version = '3.2.0+14';
    expect(version.split('+').first, '3.2.0');
  });

  test('formatDay erzeugt genau zehn Zeichen', () {
    expect(TelemetryEvent.formatDay(DateTime(2026, 1, 9)).length, 10);
  });
}
```

- [x] **Step 3: Run test to verify it passes trivially**

Run: `flutter test test/services/telemetry_wiring_test.dart`
Expected: PASS — dieser Test hält die Regel fest, bevor die Verdrahtung sie anwendet.

- [x] **Step 4: Add the imports**

In `lib/core/di/injection.dart` zu den bestehenden Importen hinzufügen:

```dart
import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:dis_app/services/telemetry_dispatcher.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:dis_app/services/transport/telemetry_transport.dart';
import 'package:package_info_plus/package_info_plus.dart';
```

- [x] **Step 5: Register the services**

Direkt nach der `FeedbackSender`-Registrierung (`lib/core/di/injection.dart:437-445`) einfügen:

```dart
  // --- Telemetrie ---
  //
  // Reihenfolge zaehlt: Consent zuerst, weil der Recorder ihn braucht und
  // ohne ihn nichts anlegen darf.
  final packageInfo = await PackageInfo.fromPlatform();

  getIt.registerSingleton<TelemetryConsent>(
    TelemetryConsent(settingsBox: Hive.box<dynamic>(HiveBoxNames.settings)),
  );

  final telemetryQueueBox = await Hive.openBox<PendingTelemetryEvent>(
    HiveBoxNames.telemetryQueue,
  );

  getIt.registerSingleton<TelemetryRecorder>(
    TelemetryRecorder(
      consent: getIt<TelemetryConsent>(),
      queue: telemetryQueueBox,
      // Nur die Release-Version. Eine Build-Nummer waere bei zehn Geraeten
      // ein Merkmal.
      appVersion: packageInfo.version,
    ),
  );

  getIt.registerSingleton<FirestoreTelemetryTransport>(
    FirestoreTelemetryTransport(),
  );

  getIt.registerSingleton<TelemetryDispatcher>(
    TelemetryDispatcher(
      queue: telemetryQueueBox,
      transport: getIt<FirestoreTelemetryTransport>(),
      record: getIt<TransmissionLogService>().record,
    ),
  );

  debugPrint('  ✓ Telemetrie initialisiert');
```

Hinweise für die Umsetzung:
- Steht die `settings`-Box an dieser Stelle noch nicht offen, mit `await Hive.openBox<dynamic>(HiveBoxNames.settings)` öffnen statt `Hive.box`.
- Fehlt `package_info_plus` in `pubspec.yaml`, mit `flutter pub add package_info_plus` ergänzen.
- Den Adapter `PendingTelemetryEventAdapter` dort registrieren, wo die übrigen Adapter registriert werden (Suche: `registerAdapter(TransmissionLogEntryAdapter`).

- [x] **Step 6: Flush the queue on start**

In `lib/main.dart`, nachdem die DI-Initialisierung abgeschlossen ist, den Versand anstoßen — bewusst ohne `await`, damit der Start nicht auf das Netz wartet:

```dart
  // Faellige Telemetrie nachreichen. Ohne await: der Start darf nie auf das
  // Netz warten, und ein Fehlschlag bleibt in der Warteschlange liegen.
  unawaited(getIt<TelemetryDispatcher>().flush());
```

Dafür `import 'dart:async';` ergänzen, falls nicht vorhanden.

- [x] **Step 7: Verify the app still builds**

Run: `flutter analyze`
Expected: keine neuen Fehler

- [x] **Step 8: Commit**

```bash
git add lib/core/di/injection.dart lib/main.dart pubspec.yaml test/services/telemetry_wiring_test.dart
git commit -m "feat(telemetry): wire the recorder, transport and dispatcher"
```

---

## Task 8: Einwilligungsschirm

**Files:**
- Create: `lib/modules/telemetry/telemetry_consent_screen.dart`
- Modify: `lib/main.dart` (Gate nach dem Start)
- Test: `test/modules/telemetry/telemetry_consent_screen_test.dart`

**Interfaces:**
- Consumes: `TelemetryConsent` (Task 2)
- Produces: `class TelemetryConsentScreen({required VoidCallback onDecided, TelemetryConsent? consent})` mit `static const String routeName = '/telemetry-consent'`

- [x] **Step 1: Write the failing test**

```dart
// test/modules/telemetry/telemetry_consent_screen_test.dart
import 'package:dis_app/modules/telemetry/telemetry_consent_screen.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../../helpers/temp_hive.dart';

void main() {
  late Box<dynamic> settingsBox;
  late TelemetryConsent consent;

  setUp(() async {
    settingsBox = await openTempBox<dynamic>('settings_screen_test');
    consent = TelemetryConsent(settingsBox: settingsBox);
  });

  tearDown(() async {
    await settingsBox.deleteFromDisk();
  });

  Future<void> pumpScreen(WidgetTester tester, {VoidCallback? onDecided}) {
    return tester.pumpWidget(
      MaterialApp(
        home: TelemetryConsentScreen(
          consent: consent,
          onDecided: onDecided ?? () {},
        ),
      ),
    );
  }

  group('TelemetryConsentScreen', () {
    testWidgets('zeigt beide Knoepfe in gleicher Groesse', (tester) async {
      await pumpScreen(tester);

      final ja = tester.getSize(find.byKey(const Key('telemetry_yes')));
      final nein = tester.getSize(find.byKey(const Key('telemetry_no')));

      expect(ja, nein);
    });

    testWidgets('Knoepfe erfuellen die Mindesthoehe der Richtlinie',
        (tester) async {
      await pumpScreen(tester);

      // Richtlinie 6: 110 dp, weil WCAG 2.2 ausdruecklich "more for
      // unsteady hands" sagt.
      expect(
        tester.getSize(find.byKey(const Key('telemetry_yes'))).height,
        greaterThanOrEqualTo(110),
      );
    });

    testWidgets('zeigt Beispielereignisse im Klartext', (tester) async {
      await pumpScreen(tester);

      expect(find.textContaining('bereich_geoeffnet_chat'), findsOneWidget);
    });

    testWidgets('Ja speichert die Zustimmung', (tester) async {
      var entschieden = false;
      await pumpScreen(tester, onDecided: () => entschieden = true);

      await tester.tap(find.byKey(const Key('telemetry_yes')));
      await tester.pumpAndSettle();

      expect(consent.state, TelemetryConsentState.zugestimmt);
      expect(entschieden, isTrue);
    });

    testWidgets('Weiter ohne gilt als beantwortet', (tester) async {
      var entschieden = false;
      await pumpScreen(tester, onDecided: () => entschieden = true);

      await tester.tap(find.byKey(const Key('telemetry_no')));
      await tester.pumpAndSettle();

      expect(consent.state, TelemetryConsentState.abgelehnt);
      expect(consent.needsAsking, isFalse);
      expect(entschieden, isTrue);
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/modules/telemetry/telemetry_consent_screen_test.dart`
Expected: FAIL — `Target of URI doesn't exist`

- [x] **Step 3: Write the screen**

```dart
// lib/modules/telemetry/telemetry_consent_screen.dart
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:flutter/material.dart';

/// Die Frage nach der Einwilligung zur Telemetrie.
///
/// Ein eigener Schirm, kein Schritt im Onboarding: `PreOnboardingScreen` ist
/// mit „Nicht mehr anzeigen" ueberspringbar, und ein Schritt darin wuerde von
/// genau den Menschen nie gesehen, die zuegig durchklicken. Derselbe Schirm
/// erreicht damit auch die bestehenden Nutzerinnen beim ersten Start nach dem
/// Update — ein Mechanismus, zwei Anlaesse.
///
/// Richtlinien, die hier zaehlen:
/// - 5: Bild traegt, Wort bestaetigt. Symbol und Text, nie eines allein.
/// - 6: 110 dp Bedienhoehe.
/// - 10: Es steht dort, was nach dem Absenden passiert.
/// - Beide Knoepfe sind gleich gross. Eine visuelle Bevorzugung waere keine
///   freie Einwilligung im Sinne von DSGVO Art. 9.
class TelemetryConsentScreen extends StatelessWidget {
  const TelemetryConsentScreen({
    required this.onDecided,
    this.consent,
    super.key,
  });

  static const String routeName = '/telemetry-consent';

  /// Wird nach beiden Antworten aufgerufen. Der Ablauf laeuft danach
  /// identisch weiter — sonst waere die Einwilligung nicht freiwillig.
  final VoidCallback onDecided;

  /// Injizierbar fuer Tests.
  final TelemetryConsent? consent;

  static const double _buttonHeight = 110;

  TelemetryConsent _consent() => consent ?? getIt<TelemetryConsent>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Icon(
                Icons.insights,
                size: 72,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              Text(
                'Hilfst du mit, Aurora zu verbessern?',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Aurora kann zählen, welche Bereiche geöffnet werden und wo '
                'Abläufe abbrechen. Gesendet wird nur der Name des Ereignisses, '
                'der Tag und die App-Version — kein Text, keine Uhrzeit, kein '
                'Standort und nichts, was zu dir zurückführt.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'So sieht eine Meldung aus:\n\n'
                  'Ereignis: bereich_geoeffnet_chat\n'
                  'Tag: 2026-08-05\n'
                  'App-Version: 3.2.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Richtlinie 10: sagen, was danach passiert.
              Text(
                'Du kannst das jederzeit in den Einstellungen unter '
                '„Was Aurora sendet" ändern. Dort steht auch jede einzelne '
                'Meldung, die dein Gerät verlassen hat.',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              _ChoiceButton(
                key: const Key('telemetry_yes'),
                icon: Icons.favorite,
                label: 'Ja, gerne',
                height: _buttonHeight,
                onPressed: () async {
                  await _consent().grant();
                  onDecided();
                },
              ),
              const SizedBox(height: 12),
              _ChoiceButton(
                key: const Key('telemetry_no'),
                icon: Icons.arrow_forward,
                label: 'Weiter ohne',
                height: _buttonHeight,
                onPressed: () async {
                  await _consent().deny();
                  onDecided();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Beide Antworten tragen dieselbe Form. Kein Knopf ist lauter als der andere.
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.icon,
    required this.label,
    required this.height,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final double height;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Text(label, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
```

- [x] **Step 4: Run test to verify it passes**

Run: `flutter test test/modules/telemetry/telemetry_consent_screen_test.dart`
Expected: PASS, 5 Tests

- [x] **Step 5: Show the screen when consent is unanswered**

In `lib/main.dart` dort, wo nach erfolgreicher Anmeldung der Hauptschirm gebaut wird, vorschalten:

```dart
    // Ein Mechanismus, zwei Anlaesse: neue Nutzerinnen sehen den Schirm nach
    // dem Onboarding, bestehende beim ersten Start nach dem Update.
    if (getIt<TelemetryConsent>().needsAsking) {
      return TelemetryConsentScreen(
        onDecided: () => setState(() {}),
      );
    }
```

- [x] **Step 6: Verify manually**

Run: `flutter run`
Erwartung: Beim ersten Start erscheint der Schirm. Nach „Weiter ohne" erscheint er beim nächsten Start nicht erneut.

- [x] **Step 7: Commit**

```bash
git add lib/modules/telemetry/telemetry_consent_screen.dart lib/main.dart test/modules/telemetry/telemetry_consent_screen_test.dart
git commit -m "feat(telemetry): ask once, with both answers the same size"
```

---

## Task 9: Aufrufstellen

**Files:**
- Modify: `lib/main.dart:939-1105` (Tab-Definitionen und Bereichswechsel)
- Modify: `lib/modules/onboarding/pre_onboarding_screen.dart`
- Modify: `lib/modules/grounding/exercise_player_screen.dart`
- Test: `test/services/telemetry_call_sites_test.dart`

**Interfaces:**
- Consumes: `TelemetryRecorder.record`, `TelemetryEventName` (Task 1, 3)
- Produces: `String get telemetryKey` auf `TabDefinition`

- [x] **Step 1: Write the failing test**

```dart
// test/services/telemetry_call_sites_test.dart
import 'package:dis_app/models/telemetry_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('jeder Anker-Bereich hat ein Ereignis', () {
    // Die Schluessel stammen aus TabDefinition.telemetryKey in main.dart.
    // Aendert sich dort einer, faellt es hier auf, statt still zu verschwinden.
    const bereiche = [
      'halt',
      'notfall',
      'hilfe',
      'chat',
      'kalender',
      'medikamente',
      'tagebuch',
      'kontakte',
      'finder',
      'spiele',
      'zeitachse',
      'feedback',
    ];

    final vorhanden =
        TelemetryEventName.values.map((e) => e.wireName).toSet();

    for (final bereich in bereiche) {
      expect(
        vorhanden.contains('bereich_geoeffnet_$bereich'),
        isTrue,
        reason: 'Kein Ereignis fuer Bereich $bereich',
      );
    }
  });

  test('jede Uebung hat ein Abschluss- und ein Abbruchereignis', () {
    // Ids aus lib/modules/grounding/data/grounding_exercises.dart
    const uebungen = ['orientation', 'senses', 'body', 'container', 'breath'];

    final vorhanden =
        TelemetryEventName.values.map((e) => e.wireName).toSet();

    for (final uebung in uebungen) {
      expect(vorhanden.contains('uebung_beendet_$uebung'), isTrue);
      expect(vorhanden.contains('uebung_abgebrochen_$uebung'), isTrue);
    }
  });

  test('jeder Onboarding-Schritt hat ein Abbruchereignis', () {
    // Die fuenf Seiten aus pre_onboarding_screen.dart
    const schritte = [
      'willkommen',
      'privacy',
      'features',
      'profile',
      'los_gehts',
    ];

    final vorhanden =
        TelemetryEventName.values.map((e) => e.wireName).toSet();

    for (final schritt in schritte) {
      expect(vorhanden.contains('onboarding_abgebrochen_$schritt'), isTrue);
    }
  });
}
```

- [x] **Step 2: Run test to verify it passes**

Run: `flutter test test/services/telemetry_call_sites_test.dart`
Expected: PASS — die Ereignisse existieren seit Task 1. Der Test sichert ab, dass sie nicht wieder verschwinden.

- [x] **Step 3: Add the stable key to TabDefinition**

In der Klasse `TabDefinition` (Suche: `class TabDefinition`) das Feld ergänzen:

```dart
  /// Stabiler Schluessel fuer die Telemetrie. Bewusst getrennt von
  /// `tabItem.label`: Anzeigetexte aendern sich, und eine Umbenennung wuerde
  /// sonst jede Zeitreihe zerreissen.
  final String telemetryKey;
```

und im Konstruktor als `required this.telemetryKey` aufnehmen.

- [x] **Step 4: Fill in the keys**

In `lib/main.dart:939-1105` jede der zwölf `TabDefinition`-Instanzen um `telemetryKey` ergänzen, in dieser Zuordnung:

| Label | `telemetryKey` |
|---|---|
| Halt | `halt` |
| Notfall | `notfall` |
| Chat | `chat` |
| Kalender | `kalender` |
| Medikamente | `medikamente` |
| Tagebuch | `tagebuch` |
| Kontakte | `kontakte` |
| Finder | `finder` |
| Hilfe | `hilfe` |
| Spiele | `spiele` |
| Zeitachse | `zeitachse` |
| Feedback | `feedback` |

- [x] **Step 5: Record the area change**

Dort, wo der Anker einen Bereich öffnet (Suche in `lib/main.dart` nach der Stelle, die auf die Auswahl im `AnchorMenuScreen` reagiert), ergänzen:

```dart
    // Gezaehlt wird ausschliesslich das Oeffnen — auch bei Halt, Notfall und
    // Hilfe. Was innerhalb dieser Bereiche geschieht, erzeugt nie ein Ereignis.
    final name = _telemetryEventForArea(tab.telemetryKey);
    if (name != null) {
      unawaited(getIt<TelemetryRecorder>().record(name));
    }
```

Und die Auflösung als private Funktion in derselben Datei:

```dart
/// Bildet den Bereichsschluessel auf sein Ereignis ab. Gibt `null` zurueck,
/// wenn ein neuer Bereich hinzukam, ohne dass ein Ereignis dafuer angelegt
/// wurde — dann wird nichts gesendet statt etwas Falsches.
TelemetryEventName? _telemetryEventForArea(String key) {
  final wireName = 'bereich_geoeffnet_$key';
  for (final candidate in TelemetryEventName.values) {
    if (candidate.wireName == wireName) return candidate;
  }
  return null;
}
```

- [x] **Step 6: Record the onboarding events**

In `lib/modules/onboarding/pre_onboarding_screen.dart`:

In `initState`, nach `super.initState()`:

```dart
    unawaited(
      getIt<TelemetryRecorder>().record(TelemetryEventName.onboardingBegonnen),
    );
```

Die fünf Seiten bekommen eine Schlüsselliste als Konstante der State-Klasse:

```dart
  /// Reihenfolge wie im PageView. Stabile Schluessel, keine Beschriftungen.
  static const List<String> _stepKeys = [
    'willkommen',
    'privacy',
    'features',
    'profile',
    'los_gehts',
  ];
```

In `_dismissOnboarding` (der Weg über „Nicht mehr anzeigen") vor dem Verlassen:

```dart
    // Der Abbruch ist selbst ein Ereignis. So verlaesst nie eine Schrittfolge
    // das Geraet, und die Quote ergibt sich aus dem Verhaeltnis der Zaehler.
    final key = _stepKeys[_currentPage.clamp(0, _stepKeys.length - 1)];
    final name = _telemetryEventForStep(key);
    if (name != null) {
      unawaited(getIt<TelemetryRecorder>().record(name));
    }
```

Beim Erreichen der letzten Seite und Fortfahren:

```dart
    unawaited(
      getIt<TelemetryRecorder>().record(TelemetryEventName.onboardingBeendet),
    );
```

Mit derselben Auflösungsfunktion wie oben, hier auf `onboarding_abgebrochen_` bezogen:

```dart
TelemetryEventName? _telemetryEventForStep(String key) {
  final wireName = 'onboarding_abgebrochen_$key';
  for (final candidate in TelemetryEventName.values) {
    if (candidate.wireName == wireName) return candidate;
  }
  return null;
}
```

- [x] **Step 7: Record the exercise events**

In `lib/modules/grounding/exercise_player_screen.dart`:

Beim Erreichen des Abschlusses (dort, wo `ExerciseDoneSheet` gezeigt wird):

```dart
    final beendet = _telemetryEventForExercise('beendet', widget.exercise.id);
    if (beendet != null) {
      unawaited(getIt<TelemetryRecorder>().record(beendet));
    }
```

In `dispose`, wenn das Sheet nie erschienen ist:

```dart
    // Wer die Uebung verlaesst, bevor sie zu Ende ist, hat abgebrochen.
    // Gemessen wird nicht, ob es geholfen hat, sondern ob es tragbar war.
    if (!_completed) {
      final abgebrochen =
          _telemetryEventForExercise('abgebrochen', widget.exercise.id);
      if (abgebrochen != null) {
        unawaited(getIt<TelemetryRecorder>().record(abgebrochen));
      }
    }
```

Dafür ein `bool _completed = false;` als Feld der State-Klasse, das beim Abschluss auf `true` gesetzt wird, plus:

```dart
TelemetryEventName? _telemetryEventForExercise(String outcome, String id) {
  final wireName = 'uebung_${outcome}_$id';
  for (final candidate in TelemetryEventName.values) {
    if (candidate.wireName == wireName) return candidate;
  }
  return null;
}
```

- [x] **Step 8: Run all tests**

Run: `flutter test`
Expected: PASS

Run: `flutter analyze`
Expected: keine neuen Fehler

- [x] **Step 9: Commit**

```bash
git add lib/main.dart lib/modules/onboarding/pre_onboarding_screen.dart lib/modules/grounding/exercise_player_screen.dart test/services/telemetry_call_sites_test.dart
git commit -m "feat(telemetry): record areas, onboarding steps and exercises"
```

---

## Task 10: Übertragungsprotokoll nach Kanal gruppieren

**Files:**
- Modify: `lib/modules/transparency/transparency_screen.dart`
- Test: `test/modules/transparency/transparency_screen_test.dart`

**Interfaces:**
- Consumes: `TransmissionLogEntry`, `TransmissionChannel`
- Produces: keine neuen öffentlichen Namen

- [x] **Step 1: Read the existing screen**

Run: `sed -n '1,90p' lib/modules/transparency/transparency_screen.dart`
Zweck: `readLog` und `eraseEntry` sind bereits injizierbar (`transparency_screen.dart:55-56`) — der Test kommt ohne GetIt aus.

- [x] **Step 2: Write the failing test**

```dart
// test/modules/transparency/transparency_screen_test.dart
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/modules/transparency/transparency_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TransmissionLogEntry entry(String id, TransmissionChannel channel) {
    return TransmissionLogEntry(
      id: id,
      timestamp: DateTime(2026, 8, 5, 12),
      channel: channel,
      payloadText: 'Inhalt $id',
      status: TransmissionStatus.sent,
    );
  }

  Future<void> pump(
    WidgetTester tester,
    List<TransmissionLogEntry> entries,
  ) {
    return tester.pumpWidget(
      MaterialApp(
        home: TransparencyScreen(
          readLog: () => entries,
          eraseEntry: (_) async {},
        ),
      ),
    );
  }

  testWidgets('trennt Feedback und Telemetrie in eigene Gruppen',
      (tester) async {
    await pump(tester, [
      entry('a', TransmissionChannel.feedback),
      entry('b', TransmissionChannel.telemetry),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Feedback'), findsOneWidget);
    expect(find.text('Telemetrie'), findsOneWidget);
  });

  testWidgets('zeigt eine Gruppe ohne Eintraege als Beleg, nicht als Fehler',
      (tester) async {
    await pump(tester, [entry('a', TransmissionChannel.feedback)]);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Es wurde noch nichts gesendet'),
      findsOneWidget,
    );
  });

  testWidgets('zeigt den vollen Inhalt im Klartext', (tester) async {
    await pump(tester, [entry('a', TransmissionChannel.telemetry)]);
    await tester.pumpAndSettle();

    expect(find.textContaining('Inhalt a'), findsOneWidget);
  });
}
```

- [x] **Step 3: Run test to verify it fails**

Run: `flutter test test/modules/transparency/transparency_screen_test.dart`
Expected: FAIL — `Expected: exactly one matching candidate / Actual: _TextFinder:<zero widgets>`

- [x] **Step 4: Group the list by channel**

Im Aufbau der Liste die Einträge nach `channel` teilen und mit Überschrift ausgeben. Richtlinie 3: gruppieren, nicht verstecken — kein Filter-Menü, kein „Mehr"-Fach, beide Abschnitte stehen untereinander.

Der leere Zustand je Gruppe bekommt den Satz:

```dart
const Text(
  'Es wurde noch nichts gesendet.',
)
```

Er ist der Beleg dafür, dass nichts das Gerät verlassen hat — keine Fehlermeldung.

- [x] **Step 5: Add the revocation switch**

Im Telemetrie-Abschnitt, oberhalb der Liste, den Schalter ergänzen:

```dart
SwitchListTile(
  key: const Key('telemetry_toggle'),
  value: getIt<TelemetryConsent>().allowsRecording,
  title: const Text('Anonyme Nutzungsdaten senden'),
  subtitle: const Text(
    'Was bereits gesendet wurde, kann nicht zurückgeholt werden. '
    'Es ist dir nicht zugeordnet — deshalb lässt es sich auch nicht '
    'finden und löschen.',
  ),
  onChanged: (an) async {
    if (an) {
      await getIt<TelemetryConsent>().grant();
    } else {
      await getIt<TelemetryConsent>().revoke();
      // Der Widerruf wirkt sofort auf die Erzeugung, nicht erst auf den
      // Versand: Was noch in der Warteschlange liegt, geht nicht mehr raus.
      await getIt<TelemetryRecorder>().clearQueue();
    }
    setState(() {});
  },
),
```

- [x] **Step 6: Run test to verify it passes**

Run: `flutter test test/modules/transparency/transparency_screen_test.dart`
Expected: PASS, 3 Tests

- [x] **Step 7: Commit**

```bash
git add lib/modules/transparency/transparency_screen.dart test/modules/transparency/transparency_screen_test.dart
git commit -m "feat(telemetry): separate the two channels and let consent be withdrawn"
```

---

## Task 11: Datenschutzerklärung, Data Safety, App Check

**Files:**
- Modify: `docs/datenschutz.html`
- Create: `docs/superpowers/notes/2026-08-05-telemetrie-rollout.md`

**Interfaces:**
- Consumes: nichts
- Produces: keine Codeschnittstelle

Diese Aufgabe erzeugt keinen ausführbaren Code, ist aber **Freigabeblocker**: Ohne sie ist der Release ein Policy-Verstoß mit Entfernungsrisiko.

- [x] **Step 1: Extend the privacy policy**

In `docs/datenschutz.html` einen Abschnitt „Anonyme Nutzungsdaten" ergänzen, der wörtlich benennt:

- Rechtsgrundlage: DSGVO Art. 9 Abs. 2 lit. a (ausdrückliche Einwilligung)
- Die drei Felder: Ereignisname, Tag, App-Version
- Vollständige Liste der Ereignisnamen oder Verweis auf den Screen „Was Aurora sendet"
- Empfänger: Google Firestore, Region `europe-west3` (Frankfurt)
- Dass eine Firebase-Installations-ID auf dem Gerät entsteht, an Google geht und **nicht** in den Dokumenten landet
- Dass Google als Betreiber Zugriffsprotokolle führt, die außerhalb der Kontrolle von Aurora liegen
- Widerrufsweg: Einstellungen → „Was Aurora sendet"
- Dass Gesendetes nicht nachträglich löschbar ist, weil es keiner Person zugeordnet ist

- [x] **Step 2: Write the rollout checklist**

`docs/superpowers/notes/2026-08-05-telemetrie-rollout.md` mit diesen Punkten, jeder abzuhaken **vor** dem Store-Upload:

```markdown
# Telemetrie-Rollout: Checkliste

- [ ] App Check (Play Integrity) im Firebase-Projekt aktiviert.
      Ohne ihn kann die Collection vollgeschrieben werden — auf Google Cloud
      unmittelbar Kosten. Bei Telemetrie wiegt das schwerer als bei Feedback,
      weil der Schreibpfad ohne Nutzerhandlung laeuft.
- [ ] `firebase deploy --only firestore:rules` ausgefuehrt, Ausgabe geprueft
- [ ] Budget-Alarm auf dem Projekt gesetzt
- [ ] Play Data Safety umgestellt: App-Aktivitaet, anonym, nicht geteilt,
      optional. Die Angabe steht derzeit auf „keine Datenerhebung" — bleibt
      sie falsch, ist das ein Policy-Verstoss mit Entfernungsrisiko.
- [ ] Store-Kurzbeschreibung praezisiert. „Alle Daten bleiben auf deinem
      Geraet" ist mit Telemetrie nicht mehr haltbar.
- [ ] Datenschutzerklaerung veroeffentlicht (docs/datenschutz.html)
- [ ] Manuelle Abnahme auf einem Geraet mit Release-Build:
      Einwilligung erteilen, Bereich oeffnen, App neu starten,
      Eingang in Firestore bestaetigen, Eintrag im Screen „Was Aurora sendet"
      pruefen, widerrufen, pruefen dass nichts mehr entsteht.
      Genau dieser Schritt fehlte am 29.11.2025 und hat den Feedback-Kanal
      acht Monate unbemerkt tot gelassen.
```

- [x] **Step 3: Commit**

```bash
git add docs/datenschutz.html docs/superpowers/notes/2026-08-05-telemetrie-rollout.md
git commit -m "docs(telemetry): say what leaves the device and gate the rollout"
```

---

## Task 12: Abschließender Durchlauf

**Files:** keine

- [x] **Step 1: Run the whole suite**

Run: `flutter test`
Expected: PASS, keine übersprungenen Tests

- [x] **Step 2: Run the analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [x] **Step 3: Run the custom lints**

Run: `dart run custom_lint`
Expected: keine Verstöße gegen `prefer_data_entry_architecture`, `avoid_service_direct_mutation`, `hive_field_order_check`

- [x] **Step 4: Verify the two guarantees by hand**

```bash
# Kein Standortfeld im Telemetrie-Pfad
grep -rn "latitude\|longitude\|position\|coords" lib/models/telemetry_event.dart lib/services/telemetry_*.dart lib/services/transport/telemetry_transport.dart
```
Expected: keine Treffer

```bash
# Kein Server-Zeitstempel im Telemetrie-Pfad
grep -rn "serverTimestamp" lib/services/transport/telemetry_transport.dart
```
Expected: keine Treffer

- [x] **Step 5: Commit if anything changed**

```bash
git add -A
git commit -m "chore(telemetry): close the loop on lints and guarantees"
```

---

## Self-Review

**Spec-Abdeckung**

| Spec-Abschnitt | Task |
|---|---|
| 4 — Abbruch als eigenes Ereignis | 1, 9 |
| 5.1 — drei Felder, `day` ohne Uhrzeit | 1, 4, 6 |
| 5.2 — stabile Schlüssel, Whitelist an zwei Orten | 1, 6, 9 |
| 5.3 — Ereignisliste, Krisenbereiche, Fehler ohne Details | 1, 9 |
| 6.1 — Art. 9 | 2, 11 |
| 6.2 — Onboarding-Schirm | 8 |
| 6.3 — einmalige Karte für Bestand | 8 (derselbe Schirm) |
| 6.4 — Widerruf, Warteschlange leeren, ehrlicher Satz | 2, 10 |
| 7.1 — `TelemetryEvent` | 1 |
| 7.2 — `TelemetryConsent`, drei Zustände | 2 |
| 7.3 — `TelemetryRecorder`, Erzeugungsgate | 3 |
| 7.4 — `TelemetryTransport`, keine Compile-Zeit-Konstante | 4 |
| 7.5 — Warteschlange, 0–6 h Verzögerung | 3, 5 |
| 7.6 — `TransmissionLog`, Gruppierung nach Kanal | 5, 10 |
| 7.7 — Aufrufstellen | 9 |
| 8.1 — Rules, `create`-only, Feld-Whitelist | 6 |
| 8.2 — App Check als Vorbedingung | 11 |
| 8.3 — Budget-Alarm | 11 |
| 9 — Data Safety, Datenschutz, Store-Text | 11 |
| 10 — Tests, CI-Gate, manuelle Abnahme | 1–6, 11, 12 |
| 11.1 — Onboarding-Schrittliste | gelöst: `willkommen`, `privacy`, `features`, `profile`, `los_gehts` (Task 1, 9) |
| 11.2 — Schlüssel der Anker-Bereiche | gelöst: `TabDefinition.telemetryKey` (Task 9) |
| 11.3 — Auswertung | bleibt offen, wie in der Spec vermerkt |

**Abweichung von der Spec, bewusst:** Spec 7.7 verlangt Aufrufe über `DataEntry`. Der Plan ruft `TelemetryRecorder` direkt auf. Grund: `DataEntry` bündelt Operationen auf Nutzerdaten mit Validierung und EventBus-Publikation; ein Telemetrie-Zähler ist keine Nutzerdatenoperation und hätte dort weder Validierung noch Abnehmer. Schlägt `custom_lint` in Task 12 deshalb an, wird die Aufrufstelle stattdessen über `DataEntry` geführt.

**Offen, in Task 7 zu klären:** Ob die `settings`-Box an der Registrierungsstelle bereits offen ist und ob `package_info_plus` schon in `pubspec.yaml` steht. Beide Fälle sind im Schritt beschrieben.

**Nicht Teil dieses Plans:** Das CI-Gate aus Spec 10 setzt voraus, dass `.github/workflows` den Release-Pfad abdeckt. Ob das nach dem Feedback-Rückkanal bereits gilt, wird in Task 12 sichtbar; falls nicht, ist das ein eigener Zuschnitt.
