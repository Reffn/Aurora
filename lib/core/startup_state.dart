import 'package:flutter/foundation.dart';

/// Wie weit der Start gekommen ist.
enum StartupPhase {
  /// Dienste fahren hoch. Der Splash-Screen steht.
  loading,

  /// Alles bereit.
  ready,

  /// Ein Pflichtdienst ist ausgefallen. Der Start kommt nicht weiter.
  failed,

  /// Die App läuft, aber ein Dienst fehlt — Erinnerungen etwa.
  degraded,
}

/// Der Startzustand als eine Wahrheit.
///
/// Vorher gab es ihn nur implizit: zwei Completer, die im Fehlerfall nie
/// erfüllt wurden. Wirft ein Startdienst, blieb der Splash-Screen stehen —
/// ohne Meldung, ohne Ausweg, unbegrenzt lange. Für eine App, die jemand im
/// schlechtesten Moment öffnet, ist ein stehendes Logo die schlechteste aller
/// Antworten.
@immutable
class StartupState {
  const StartupState(
    this.phase, {
    this.failedStep,
    this.degradedServices = const [],
  });

  final StartupPhase phase;

  /// Woran es lag — ein Schrittname, keine Ausnahme und kein Pfad.
  final String? failedStep;

  /// Dienste, die fehlen, ohne den Start zu verhindern.
  final List<String> degradedServices;

  bool get isFailed => phase == StartupPhase.failed;
}

/// Der aktuelle Startzustand, für den Splash-Screen sichtbar.
final ValueNotifier<StartupState> startupState = ValueNotifier<StartupState>(
  const StartupState(StartupPhase.loading),
);
