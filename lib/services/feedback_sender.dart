import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/firebase_start.dart';

/// Schreibt einen Protokolleintrag. Als Funktion injizierbar, damit der
/// Sendeweg ohne Hive-Box prüfbar bleibt.
typedef TransmissionRecorder =
    Future<void> Function({
      required TransmissionChannel channel,
      required String payloadText,
      required TransmissionStatus status,
      String? errorMessage,
    });

/// Der eine Weg, auf dem Feedback das Gerät verlässt.
///
/// Vorher stand diese Reihenfolge dreimal im Code — in jedem Formular einmal,
/// und im dritten gar nicht, weshalb dessen Feedback nie im Übertragungs-
/// protokoll auftauchte. Drei Kopien einer Regel sind drei Gelegenheiten,
/// eine davon zu vergessen.
///
/// Die Regel: Erst der bestätigte Weg, bei endgültigem Fehlschlag der zweite.
/// Jeder Versuch wird protokolliert, auch der gescheiterte — das Protokoll ist
/// der Beleg der Nutzerin darüber, was ihr Gerät verlassen hat.
class FeedbackSender {
  const FeedbackSender({
    required this.primary,
    required this.fallback,
    required this.record,
    required this.starteFirebase,
  });

  final FeedbackTransport primary;
  final FeedbackTransport fallback;
  final TransmissionRecorder record;

  /// Startet Firebase, falls es noch nicht läuft.
  ///
  /// Seit dem 16.08.2026 startet Firebase nicht mehr im App-Start, sondern
  /// hier: im ersten tatsächlichen Sendeversuch. Vorher meldete jede
  /// Installation bei jedem Kaltstart eine Installations-ID bei Google an —
  /// für einen Rückkanal, den die meisten Menschen nie benutzen. Siehe
  /// `FirebaseStart`.
  ///
  /// Die Reihenfolge ist zwingend: `primary.isConfigured` fragt über
  /// `firestoreHatZiel()` die laufende Firebase-App ab und ist vor dem Start
  /// immer `false`. Ohne diesen Aufruf davor ginge jedes Feedback still über
  /// die Mail-App, obwohl Firestore erreichbar wäre.
  final FirebaseStarter starteFirebase;

  Future<TransportResult> send(FeedbackPayload payload) async {
    if (await starteFirebase() && primary.isConfigured) {
      final result = await primary.send(payload);
      await _protocol(payload, result);

      // pending heißt: angenommen, Zustellung folgt. Ein zweiter Versuch über
      // den Fallback würde dieselbe Meldung ein zweites Mal verschicken.
      if (result.outcome != TransportOutcome.failed) {
        return result;
      }
    }

    final result = await fallback.send(payload);
    await _protocol(payload, result);
    return result;
  }

  Future<void> _protocol(FeedbackPayload payload, TransportResult result) {
    return record(
      channel: TransmissionChannel.feedback,
      payloadText: payload.toPlainText(),
      status: _statusOf(result.outcome),
      errorMessage: result.reason,
    );
  }

  static TransmissionStatus _statusOf(TransportOutcome outcome) {
    return switch (outcome) {
      TransportOutcome.sent => TransmissionStatus.sent,
      TransportOutcome.pending => TransmissionStatus.pending,
      TransportOutcome.failed => TransmissionStatus.failed,
    };
  }
}
