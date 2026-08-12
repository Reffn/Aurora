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

/// Injizierbar fuer Tests: Schreiboperation mit Timeout.
///
/// Bewusst eigene Typen statt der gleichnamigen aus `firestore_transport.dart`:
/// Die Telemetrie soll nicht am Feedback-Sendeweg haengen. Wird einer der
/// beiden Wege umgebaut, bleibt der andere unberuehrt.
typedef TelemetryWriter = Future<void> Function(Map<String, dynamic> data);

/// Injizierbar fuer Tests: Konfigurationspruefung.
typedef TelemetryConfigChecker = bool Function();

/// Schreibt in die Firestore-Collection `telemetry`.
///
/// Kein `mailto:`-Gegenstueck: automatische Ereignisse ueber den Mail-Client
/// der Nutzerin zu schicken, waere absurd. Faellt der Weg aus, bleibt das
/// Ereignis in der lokalen Warteschlange.
class FirestoreTelemetryTransport implements TelemetryTransport {
  FirestoreTelemetryTransport({
    TelemetryWriter? writer,
    TelemetryConfigChecker? configChecker,
  }) : _writer = writer ?? _defaultWriter,
       _isConfiguredChecker = configChecker ?? _defaultIsConfiguredChecker;

  static const String collectionName = 'telemetry';

  /// Wie lange auf die Server-Bestaetigung gewartet wird, bevor der Versand
  /// als `pending` gilt. Firestore stellt danach im Hintergrund weiter zu.
  static const Duration confirmationTimeout = Duration(seconds: 8);

  final TelemetryWriter _writer;
  final TelemetryConfigChecker _isConfiguredChecker;

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
      // Firebase nicht initialisiert oder Zugriff fehlgeschlagen
      return false;
    }
  }

  /// Laufzeitpruefung, keine Compile-Zeit-Konstante.
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
