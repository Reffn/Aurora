import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Verhindert das Lauschen auf nutzlose *SavedEvents
///
/// Diese Events sind überflüssig, da Hive ValueListenable
/// automatisch UI-Updates triggert.
///
/// ❌ Verboten:
/// ```dart
/// eventBus.on<ChatMessageSavedEvent>().listen(...);
/// eventBus.on<ProfileSavedEvent>().listen(...);
/// ```
///
/// ✅ Stattdessen:
/// ```dart
/// ValueListenableBuilder(
///   valueListenable: service.box.listenable(),
///   builder: (context, box, _) => ...
/// )
/// ```
class NoSavedEventsListener extends DartLintRule {
  const NoSavedEventsListener() : super(code: _code);

  static const _code = LintCode(
    name: 'no_saved_events_listener',
    problemMessage:
        'Listening to *SavedEvent is unnecessary. Use Hive ValueListenable instead.',
    correctionMessage:
        'Remove this listener and use ValueListenableBuilder with service.box.listenable().',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      // Prüfe ob .on<T>() Call
      if (node.methodName.name != 'on') {
        return;
      }

      final typeArgs = node.typeArguments?.arguments;
      if (typeArgs == null || typeArgs.isEmpty) {
        return;
      }

      final typeName = typeArgs.first.toString();

      // Prüfe ob es ein SavedEvent ist
      if (typeName.endsWith('SavedEvent')) {
        reporter.atNode(node, code);
      }
    });
  }
}
