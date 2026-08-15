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
  const TransportResult._(this.outcome, this.reason);

  const TransportResult.success() : this._(TransportOutcome.sent, null);

  const TransportResult.pending() : this._(TransportOutcome.pending, null);

  const TransportResult.failure(String reason)
    : this._(TransportOutcome.failed, reason);

  final TransportOutcome outcome;

  /// Für die Nutzerin lesbarer Grund. Nur bei [TransportOutcome.failed] gesetzt.
  final String? reason;

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
