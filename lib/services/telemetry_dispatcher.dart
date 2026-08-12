import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/feedback_sender.dart'
    show TransmissionRecorder;
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
  }) : _queue = queue,
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
      final name = TelemetryEventName.fromWireName(entry.eventName);

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
