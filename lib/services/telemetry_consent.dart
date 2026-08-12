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
  /// Liest und schreibt über Funktionen statt über die Box selbst.
  ///
  /// Dasselbe Muster wie bei `TransmissionRecorder` und den Transporten: Hive
  /// schreibt echte Dateien, und echte Datei-Ein-/Ausgabe blockiert in einem
  /// Widget-Test. Wer den Einwilligungsschalter prüfen will, soll nicht erst
  /// eine Datenbank aufsetzen müssen.
  TelemetryConsent({
    required String? Function() read,
    required Future<void> Function(String value) write,
  }) : _read = read,
       _write = write;

  /// Der Weg für die App: liest und schreibt in der `settings`-Box.
  factory TelemetryConsent.fromBox(Box<dynamic> settingsBox) {
    return TelemetryConsent(
      read: () => settingsBox.get(storageKey) as String?,
      write: (value) => settingsBox.put(storageKey, value),
    );
  }

  /// Nur für Tests: hält den Zustand im Arbeitsspeicher.
  factory TelemetryConsent.inMemory([String? initial]) {
    var value = initial;
    return TelemetryConsent(
      read: () => value,
      write: (next) async => value = next,
    );
  }

  static const String storageKey = 'telemetry_consent';

  final String? Function() _read;
  final Future<void> Function(String value) _write;

  TelemetryConsentState get state {
    final stored = _read();
    return switch (stored) {
      'zugestimmt' => TelemetryConsentState.zugestimmt,
      'abgelehnt' => TelemetryConsentState.abgelehnt,
      // Fehlender oder unbekannter Wert: nicht raten, sondern fragen.
      _ => TelemetryConsentState.ungefragt,
    };
  }

  bool get allowsRecording => state == TelemetryConsentState.zugestimmt;

  bool get needsAsking => state == TelemetryConsentState.ungefragt;

  Future<void> grant() => _store(TelemetryConsentState.zugestimmt);

  /// „Weiter ohne". Gilt als beantwortet — es wird nicht erneut gefragt.
  Future<void> deny() => _store(TelemetryConsentState.abgelehnt);

  /// Widerruf aus den Einstellungen. Fuehrt in denselben Zustand wie [deny].
  Future<void> revoke() => _store(TelemetryConsentState.abgelehnt);

  Future<void> _store(TelemetryConsentState next) async {
    await _write(next.name);
    logger.info(
      LogCategory.service,
      'Telemetrie-Einwilligung geaendert',
      data: {'state': next.name},
    );
  }
}
