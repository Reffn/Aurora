import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Die Erinnerungsregeln haben keine Uhr.
///
/// `desiredReminders()` bekommt `now` als Parameter. Genau das macht jede
/// Regel mit einer festen Uhr prüfbar — und deshalb ließen sich die Befunde
/// vom 07.08.2026 überhaupt als Test festhalten: Aufschub über Mitternacht,
/// Sommerzeitende, „genommen räumt die Vorwarnungen ab".
///
/// Greift jemand hier zu `DateTime.now()`, hängt das Ergebnis wieder an der
/// Wanduhr, und der Test, der den Fall beschreibt, kann nicht geschrieben
/// werden. Bisher hielt das nur ein `grep` im Umsetzungsplan zusammen.
///
/// ❌ Verboten in `lib/services/reminders/`:
/// ```dart
/// final jetzt = DateTime.now();
/// ```
///
/// ✅ Erlaubt: die Uhr als Wert weitergeben.
/// ```dart
/// Set<Reminder> desiredReminders({required DateTime now, …})
/// ReminderReconciler({DateTime Function() clock = DateTime.now})
/// ```
/// Der zweite Fall ist ein Verweis auf die Funktion, kein Aufruf — er bleibt
/// erlaubt, weil er die Uhr genau dort einsetzbar macht, wo ein Test sie
/// austauschen will.
class NoClockInReminderRules extends DartLintRule {
  const NoClockInReminderRules() : super(code: _code);

  static const _code = LintCode(
    name: 'no_clock_in_reminder_rules',
    problemMessage:
        'Die Erinnerungsregeln duerfen die Uhr nicht selbst lesen -- sonst '
        'laesst sich ihr Verhalten nicht mit fester Zeit pruefen.',
    correctionMessage:
        'Die Zeit als Parameter hereingeben (now) oder als austauschbare '
        'Funktion (clock).',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path.replaceAll(r'\', '/');
    if (!path.contains('/lib/services/reminders/')) return;

    // `DateTime.now()` ist ein benannter Konstruktor, kein statischer
    // Methodenaufruf — der erste Versuch dieser Regel suchte im falschen
    // Knotentyp und schlug deshalb nie an. Eine Regel, die nie anschlaegt,
    // ist schlimmer als keine: sie gibt Sicherheit, die nicht besteht.
    context.registry.addInstanceCreationExpression((node) {
      final name = node.constructorName;
      if (name.type.name.lexeme != 'DateTime') return;
      if (name.name?.name != 'now') return;
      reporter.atNode(node, _code);
    });
  }
}
