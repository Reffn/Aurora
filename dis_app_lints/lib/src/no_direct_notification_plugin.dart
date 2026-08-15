import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Erinnerungen plant nur der Abgleich.
///
/// Sieben Fehlverhalten der Medikamenten-Erinnerung hatten am 07.08.2026
/// dieselbe Ursache: mehrere Stellen meldeten Meldungen an und ab, und
/// keine wusste vom Zustand der anderen. „Genommen" räumte nur die
/// Wiederholungen weg, „später" meldete gar nichts an, und der Bestand
/// beim Betriebssystem wurde nie gegen den Soll-Zustand geprüft.
///
/// Seit dem Umbau gibt es genau einen Schreiber: `ReminderReconciler`
/// über `ReminderScheduler`. Diese Regel hält das durch.
///
/// Sie zielt auf die **Planungsaufrufe**, nicht auf den Import. Zuerst
/// verbot sie das Paket ganz und brauchte dafür eine Ausnahme für den
/// `NotificationService` — der fasst das Plugin an, aber nur, um es beim
/// Start einzurichten und nach Erlaubnissen zu fragen. Ein Verbot mit
/// Ausnahme erzieht dazu, die Ausnahme zu erweitern; ein Verbot ohne
/// Ausnahme nicht. Die drei Namen unten gibt es nur in diesem Plugin,
/// Fehlalarme sind damit ausgeschlossen.
///
/// ❌ Verboten (außerhalb `lib/services/reminders/`):
/// ```dart
/// plugin.zonedSchedule(...);
/// plugin.cancelAll();
/// ```
///
/// ✅ Erlaubt:
/// ```dart
/// await getIt<ReminderReconciler>().reconcile();
/// ```
class NoDirectNotificationPlugin extends DartLintRule {
  const NoDirectNotificationPlugin() : super(code: _code);

  static const _verboten = {'zonedSchedule', 'periodicallyShow', 'cancelAll'};

  static const _code = LintCode(
    name: 'no_direct_notification_plugin',
    problemMessage:
        'Erinnerungen werden nur in lib/services/reminders/ angemeldet und '
        'abgemeldet.',
    correctionMessage: 'Nutze ReminderScheduler, oder loese den Abgleich '
        'ueber ReminderReconciler.reconcile() aus.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path.replaceAll(r'\', '/');

    // Der Abgleich selbst ist der eine erlaubte Ort.
    if (path.contains('/lib/services/reminders/')) return;

    context.registry.addMethodInvocation((node) {
      if (_verboten.contains(node.methodName.name)) {
        reporter.atNode(node, _code);
      }
    });
  }
}
