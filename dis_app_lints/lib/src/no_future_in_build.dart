import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// `FutureBuilder` und `StreamBuilder` bekommen ihr Future fertig übergeben.
///
/// Wird es im Argument erst erzeugt, entsteht bei **jedem** Neuaufbau ein
/// neues — und die Arbeit läuft von vorn. Am 08.08.2026 hing daran, dass sich
/// die App bei Taps schwer anfühlte:
///
/// `AttachmentHelper.getAttachmentFile()` fragte `getApplicationDocumentsDirectory()`
/// (Plattform-Kanal) und prüfte den Ordner (Dateisystem). Genau das stand im
/// `build` von `ProfileImageWidget` und `ProfileSwitchAvatar` — und die hängen
/// in Kopfzeile und Profilleiste, also auf jedem Bildschirm. Ein Tap, der
/// irgendwo `setState` auslöste, kostete einen Umlauf je sichtbarem Avatar.
/// Die Kontaktkarte rief sogar `getUserPosition()` pro Karte beim Scrollen.
///
/// Der zweite Schaden ist sichtbar: weil das Future neu ist, fällt `snapshot`
/// bei jedem Neuaufbau kurz auf „keine Daten" — daher flackerten die Avatare
/// auf die Initialen und zurück.
///
/// ❌ Verboten:
/// ```dart
/// FutureBuilder(future: helper.load(id), …)
/// FutureBuilder(future: Future.wait([a(), b()]), …)
/// FutureBuilder(future: Future.value(x), …)
/// ```
///
/// ✅ Erlaubt — ein Feld, das einmal entsteht:
/// ```dart
/// late final Future<int> _zahl = service.load();
/// …
/// FutureBuilder(future: _zahl, …)
/// ```
///
/// ✅ Besser, wenn der Wert sich ändern kann: gar kein Future, sondern ein
/// `ValueListenable`. Wer etwas anzeigt, soll ihm zuhören statt danach zu
/// fragen — so lösen es `AttachmentHelper.directory` und
/// `GpsManager.userPosition`.
class NoFutureInBuild extends DartLintRule {
  const NoFutureInBuild() : super(code: _code);

  static const _betroffen = {'FutureBuilder', 'StreamBuilder'};
  static const _argumente = {'future', 'stream'};

  static const _code = LintCode(
    name: 'no_future_in_build',
    problemMessage:
        'Das Future/Stream entsteht hier bei jedem Neuaufbau neu. Damit '
        'laeuft die Arbeit von vorn und der Builder faellt kurz auf '
        '"keine Daten" zurueck.',
    correctionMessage:
        'Einmal in ein Feld legen (late final … = …) oder besser ein '
        'ValueListenable anbieten und ihm zuhoeren.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typ = node.constructorName.type.name.lexeme;
      if (!_betroffen.contains(typ)) return;

      for (final argument in node.argumentList.arguments) {
        if (argument is! NamedExpression) continue;
        if (!_argumente.contains(argument.name.label.name)) continue;

        if (!_istFertig(argument.expression)) {
          reporter.atNode(argument, _code);
        }
      }
    });
  }

  /// Ist der Ausdruck ein bereits vorhandener Wert — oder wird er hier erst
  /// gebaut?
  ///
  /// Erlaubt sind Namen und Zugriffe darauf: `_zahl`, `widget.future`,
  /// `this.daten`. Alles andere — Methodenaufruf, Konstruktor, `await`,
  /// bedingter Ausdruck — erzeugt bei jedem Neuaufbau etwas Neues.
  static bool _istFertig(Expression ausdruck) {
    if (ausdruck is SimpleIdentifier) return true;
    if (ausdruck is PrefixedIdentifier) return true;
    if (ausdruck is PropertyAccess) return true;
    // Ein `x!` oder `(x)` ändert nichts an der Herkunft.
    if (ausdruck is PostfixExpression) return _istFertig(ausdruck.operand);
    if (ausdruck is ParenthesizedExpression) {
      return _istFertig(ausdruck.expression);
    }
    return false;
  }
}
