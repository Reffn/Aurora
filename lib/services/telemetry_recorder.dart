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
  }) : _consent = consent,
       _queue = queue,
       _appVersion = appVersion,
       _now = now ?? DateTime.now,
       _random = random ?? Random();

  /// Ereignisse gehen sofort raus.
  ///
  /// Hier stand bis zum 11. August 2026 eine Zufallsverzoegerung von bis zu
  /// sechs Stunden. Ihr Zweck: Mehrere Eingaenge derselben Minute liessen
  /// sich serverseitig zu einer Sitzung zusammenfassen, und die Verzoegerung
  /// zerriss diesen Zusammenhang, bevor er entstand.
  ///
  /// Sie ist gefallen, und zwar als Abwaegung, nicht aus Versehen. Der Preis
  /// war, dass praktisch nichts ankam: In vier Monaten Produktion lagen
  /// sieben Ereignisse vor, alle aus einem einzigen Testlauf. Eine Telemetrie,
  /// die nie eintrifft, verbessert nichts — und dann ist sie nur noch eine
  /// Einwilligung, die man abfragt, ohne etwas dafuer zu geben.
  ///
  /// **Was damit aufgegeben wurde:** Der Eingangszeitpunkt in Firestore
  /// (`createTime`, serverseitig gesetzt und nicht abschaltbar) ist jetzt der
  /// Zeitpunkt der Nutzung. Mehrere Ereignisse derselben Minute gehoeren
  /// erkennbar zusammen. Es gibt weiterhin keine Installations-Kennung, kein
  /// Profil und keine Zaehlung — eine Sitzung laesst sich also erkennen, aber
  /// keiner Person zuordnen und nicht mit der Sitzung von gestern verbinden.
  /// Der Einwilligungstext nennt das ausdruecklich.
  static const Duration maxDelay = Duration.zero;

  final TelemetryConsent _consent;
  final Box<PendingTelemetryEvent> _queue;
  final String _appVersion;
  final DateTime Function() _now;
  final Random _random;

  int _counter = 0;

  /// Die Version, die mitgesendet wird.
  ///
  /// Die Einwilligungsfläche zeigt ein Beispiel dessen, was das Gerät
  /// verlässt. Sie liest die Version hier, statt eine eigene hinzuschreiben —
  /// dort stand „3.2.0", während die App 3.0.16 war. Ein Beispiel, das etwas
  /// anderes zeigt als den Versand, ist keine Auskunft, sondern eine
  /// Behauptung.
  String get appVersion => _appVersion;

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
        dueAt: maxDelay == Duration.zero
            ? moment
            : moment.add(
                Duration(seconds: _random.nextInt(maxDelay.inSeconds + 1)),
              ),
      ),
    );

    logger.info(
      LogCategory.service,
      'Telemetrie-Ereignis vorgemerkt',
      data: {'event': name.wireName},
    );

    // Und gleich weg damit.
    //
    // Die Warteschlange bleibt trotzdem: Ohne Netz muss das Ereignis liegen
    // bleiben duerfen, statt verloren zu gehen. Sie ist jetzt ein Ausfallnetz
    // und kein Wartezimmer.
    onRecorded?.call();
  }

  /// Wird gerufen, sobald ein Ereignis in der Warteschlange liegt.
  ///
  /// Der Recorder kennt den Versand nicht — das bleibt getrennt. Er sagt nur
  /// Bescheid, dass es etwas zu tun gibt; die Verdrahtung steht in
  /// `injection.dart`.
  void Function()? onRecorded;

  /// Beim Widerruf. Was noch nicht gesendet wurde, wird nicht mehr gesendet.
  Future<void> clearQueue() => _queue.clear();
}
