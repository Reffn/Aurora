import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Verhindert direkten GPS-Zugriff außerhalb des GpsManagers
///
/// Standortdaten sind in Aurora der heikelste Datentyp: Wenige grobe
/// Orts-Zeit-Punkte identifizieren eine Person eindeutig. Je weniger Stellen
/// den Sensor anfassen, desto belastbarer ist die Zusage, dass Standort das
/// Gerät nur auf den drei erlaubten Wegen verlässt.
///
/// ❌ Verboten (außerhalb lib/services/gps_manager.dart):
/// ```dart
/// Geolocator.getCurrentPosition();
/// Geolocator.checkPermission();
/// ```
///
/// ✅ Erlaubt:
/// ```dart
/// gpsManager.getUserPosition();
/// gpsManager.getContactPosition(id);
/// gpsManager.getDistanceBetween(...);
/// ```
///
/// Die Regel zielt auf den **Sensorzugriff**, nicht auf das Paket. Ein Import
/// von `package:geolocator/geolocator.dart` allein wurde früher ebenfalls
/// gemeldet — das traf auch Dateien, die daraus nur den Typ
/// `LocationPermission` brauchen, den der GpsManager selbst herausgibt.
/// Ebenso wurde jeder Aufruf an `LocationHelper` gemeldet; dort liegen seit
/// dem Umbau nur noch Formatierhilfen ohne Sensorzugriff.
///
/// Beides waren Fehlalarme, und eine Regel, die grundlos anschlägt, erzieht
/// dazu, sie zu übersehen.
class NoDirectGpsAccess extends DartLintRule {
  const NoDirectGpsAccess() : super(code: _code);

  static const _code = LintCode(
    name: 'no_direct_gps_access',
    problemMessage:
        'Direct GPS access is not allowed. Use GpsManager instead.',
    correctionMessage:
        'Replace {0} with appropriate GpsManager method (getUserPosition, getContactPosition, etc.)',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path.replaceAll('\\', '/');

    // Whitelist: GPS Manager selbst darf Geolocator nutzen
    if (path.contains('/services/gps_manager.dart')) {
      return;
    }

    // Geolocator.methodName() — der eigentliche Sensorzugriff
    context.registry.addMethodInvocation((node) {
      final target = node.target;

      if (target is SimpleIdentifier && target.name == 'Geolocator') {
        reporter.atNode(node, _code);
      }
    });
  }
}
