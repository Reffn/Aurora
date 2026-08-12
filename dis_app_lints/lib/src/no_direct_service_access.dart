import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Verhindert direkten Service-Zugriff in UI-Code
///
/// ❌ Verboten in lib/modules/ und lib/widgets/:
/// ```dart
/// final service = getIt<ChatService>();
/// final data = service.messages;
/// ```
///
/// ✅ Erlaubt:
/// ```dart
/// final data = dataEntry.getChatMessages();
/// ```
class NoDirectServiceAccess extends DartLintRule {
  const NoDirectServiceAccess() : super(code: _code);

  static const _code = LintCode(
    name: 'no_direct_service_access',
    problemMessage:
        'Direct service access is not allowed in UI code. Use DataEntry instead.',
    correctionMessage:
        'Replace getIt<{0}>() with appropriate DataEntry query method.',
  );

  /// Liste der verbotenen Services (alle außer NavigationService)
  static const _forbiddenServices = {
    'ProfileService',
    'ChatService',
    'CalendarService',
    'MedicationService',
    'ContactService',
    'FinderService',
    'EmergencyDiaryService',
    'TranslationService',
  };

  /// Was `main.dart` weiterhin darf — namentlich und begründet.
  ///
  /// Die App-Schale besitzt den Profilwechsel: Sie baut die Auswahl, hält den
  /// aktiven Anteil und filtert danach die Bereiche. Das ist keine Abfrage
  /// von Inhalten, sondern der Zustand der Schale selbst. Alles andere geht
  /// auch dort durch DataEntry.
  static const _shellExceptions = {'ProfileService'};

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    // Alle Einstiegspunkte der Oberfläche, nicht nur zwei Ordner.
    //
    // `main.dart` fehlte hier, und genau dort las die Tagesübersicht die
    // Hive-Boxen zweier Dienste direkt. Die Regel griff nicht, weil der
    // Geltungsbereich nach Ordnern ging und die größte UI-Datei des Projekts
    // in keinem davon liegt.
    final path = resolver.path.replaceAll('\\', '/'); // Windows-Pfade normalisieren
    final isShell = path.endsWith('/lib/main.dart');
    if (!path.contains('/modules/') && !path.contains('/widgets/') && !isShell) {
      return;
    }

    context.registry.addFunctionExpressionInvocation((node) {
      // Prüfe ob getIt<T>() Call
      final function = node.function;
      if (function is! SimpleIdentifier || function.name != 'getIt') {
        return;
      }

      final typeArgs = node.typeArguments?.arguments;
      if (typeArgs == null || typeArgs.isEmpty) {
        return;
      }

      final typeName = typeArgs.first.toString();

      // Prüfe ob es ein verbotener Service ist
      if (!_forbiddenServices.contains(typeName)) return;
      if (isShell && _shellExceptions.contains(typeName)) return;
      reporter.atNode(node, code);
    });
  }
}
