import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/firestore_bereitschaft.dart';

/// Schreibt Feedback direkt in die Firestore-Collection `feedback`.
///
/// Bewusst ohne Cloud Function davor: Firestore puffert Schreibvorgaenge
/// offline und stellt sie selbstaendig zu, sobald wieder Verbindung besteht.
/// Eine eigene Retry-Logik entfaellt damit — und genau eine solche
/// selbstgebaute Zustandsmaschine war die Ursache des urspruenglichen Ausfalls.

/// Injizierbar für Tests: Schreiboperation mit Timeout.
typedef FirestoreWriter = Future<void> Function(Map<String, dynamic> data);

/// Injizierbar für Tests: Konfigurationsprüfung.
typedef IsConfiguredChecker = bool Function();

class FirestoreTransport implements FeedbackTransport {
  /// Konstruktor mit optionalen Injektionen für Tests.
  FirestoreTransport({
    FirestoreWriter? writer,
    IsConfiguredChecker? configChecker,
  }) : _writer = writer ?? _defaultWriter,
       _isConfiguredChecker = configChecker ?? _defaultIsConfiguredChecker;

  static const String collectionName = 'feedback';

  /// Wie lange auf die Server-Bestaetigung gewartet wird, bevor der Versand
  /// als `pending` gilt. Firestore stellt danach im Hintergrund weiter zu.
  static const Duration confirmationTimeout = Duration(seconds: 8);

  final FirestoreWriter _writer;
  final IsConfiguredChecker _isConfiguredChecker;

  /// Standardmäßige Schreibfunktion: Firestore-Collection + Timeout.
  static Future<void> _defaultWriter(
    Map<String, dynamic> data,
  ) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .add(data)
        .timeout(confirmationTimeout);
  }

  /// Standardmäßige Konfigurationsprüfung.
  ///
  /// Liegt in `firestore_bereitschaft.dart`, gemeinsam mit dem
  /// Telemetrie-Kanal: Die Nutzlasten der beiden Wege sind gegenläufig und
  /// bleiben getrennt — diese Prüfung war nur doppelt.
  static bool _defaultIsConfiguredChecker() => firestoreHatZiel();

  /// Laufzeitpruefung, keine Compile-Zeit-Konstante.
  /// Wirft nicht, wenn Firebase nicht bereitgestellt wurde.
  @override
  bool get isConfigured {
    try {
      return _isConfiguredChecker();
    } catch (_) {
      // Checker hat geworfen oder Firebase nicht initialisiert
      return false;
    }
  }

  @override
  String get displayName => AppTexts.current.transportDirectToDevelopers;

  @override
  Future<TransportResult> send(FeedbackPayload payload) async {
    final data = payload.toMap()..['createdAt'] = FieldValue.serverTimestamp();

    try {
      await _writer(data);

      logger.info(LogCategory.service, 'Feedback zugestellt');
      return const TransportResult.success();
    } on TimeoutException {
      // Zeitueberschreitung: Firestore hat den Schreibvorgang lokal
      // uebernommen und stellt ihn spaeter zu. (Kein Fehler.)
      logger.info(LogCategory.service, 'Feedback wartet auf Verbindung');
      return const TransportResult.pending();
    } on FirebaseException catch (e) {
      logger.error(
        LogCategory.service,
        'Feedback abgelehnt',
        data: {'error': e.code},
      );
      return TransportResult.failure(_readableReason(e));
    } catch (e, stackTrace) {
      // Unerwarteter Fehler (z.B. nicht serialisierbarer Payload)
      // darf NICHT als Warteschlange erscheinen.
      logger.error(
        LogCategory.service,
        'Feedback-Versand fehlgeschlagen (unerwarteter Fehler)',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      return TransportResult.failure(
        AppTexts.current.transportSendFailed,
      );
    }
  }

  String _readableReason(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return AppTexts.current.transportRejectedFull;
      case 'unavailable':
        return AppTexts.current.transportUnreachableFull;
      default:
        return AppTexts.current.transportFailedWithCode(e.code);
    }
  }
}
