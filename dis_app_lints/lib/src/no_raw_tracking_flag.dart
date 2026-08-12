import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Der Aufzeichnungs-Wunsch gehört dem LocationTrackingService.
///
/// Der Schlüssel `gps_tracking_enabled` trägt den **Wunsch** — „ich möchte,
/// dass aufgezeichnet wird". Er überlebt den Neustart und bleibt absichtlich
/// stehen, wenn der Positionsstrom abbricht. Der **Laufzustand** ist etwas
/// anderes und heißt `isTrackingRunning`.
///
/// Die Verwechslung ist teuer bezahlt: Die Einstellungen lasen den Wunsch,
/// fanden ihn auf `true` und starteten deshalb nicht — während nichts lief.
/// Wer „immer aufzeichnen" bestätigte, bekam Stille. Bei einer Funktion, deren
/// Zweck „wo war ich?" nach einem Blackout ist.
///
/// ❌ Verboten außerhalb von `lib/services/`:
/// ```dart
/// settingsBox.get('gps_tracking_enabled', defaultValue: false) as bool;
/// ```
///
/// ✅ Stattdessen:
/// ```dart
/// trackingService.isTrackingRunning.value;   // läuft gerade?
/// ```
class NoRawTrackingFlag extends DartLintRule {
  const NoRawTrackingFlag() : super(code: _code);

  static const _schluessel = 'gps_tracking_enabled';

  static const _code = LintCode(
    name: 'no_raw_tracking_flag',
    problemMessage:
        'Roher Zugriff auf den Aufzeichnungs-Wunsch. Der Schluessel sagt, was '
        'gewuenscht ist -- nicht, was laeuft.',
    correctionMessage:
        'Frag den Laufzustand ueber LocationTrackingService.isTrackingRunning, '
        'oder aendere den Wunsch ueber startTracking/toggleTracking.',
    // ERROR, nicht INFO. Die CI-Schwelle in `.github/workflows/test.yml` bricht
    // den Lauf nur bei ERROR oder WARNING; INFO wird gezaehlt und angezeigt.
    // Eine Regel, die nichts blockiert, ist Zierde — und genau die Sorte, die
    // in einem halben Jahr niemand mehr liest.
    errorSeverity: ErrorSeverity.ERROR,
  );

  /// Der eine Eigentümer — und die Tests.
  ///
  /// Genau **eine** Datei, nicht `lib/services/` als Ganzes: sonst darf jeder
  /// künftige Dienst den Schlüssel roh lesen, und die Verwechslung zwischen
  /// Wunsch und Lauf kommt durch die Hintertür zurück, die diese Regel
  /// zumachen soll.
  ///
  /// Tests dürfen ihn nennen, weil einer von ihnen genau das prüft: dass er in
  /// `settings_screen.dart` nicht mehr vorkommt. Eine Regel, die ihren eigenen
  /// Beweis verbietet, schafft sich den Beweis ab.
  static bool _darfDenSchluesselNennen(String pfad) {
    final p = pfad.replaceAll(r'\', '/');
    return p.endsWith('/lib/services/location_tracking_service.dart') ||
        p.contains('/test/');
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (_darfDenSchluesselNennen(resolver.path)) return;

    context.registry.addSimpleStringLiteral((node) {
      if (node.value == _schluessel) {
        reporter.atNode(node, code);
      }
    });
  }
}
