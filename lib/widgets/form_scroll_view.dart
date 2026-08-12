import 'package:flutter/material.dart';

/// Scrollbereich für Formulare. Ersatz für [ListView] innerhalb eines [Form].
///
/// **In einem [Form] niemals [ListView] verwenden.** Eine [ListView] baut nur
/// die gerade sichtbaren Kinder. Ein [TextFormField], das aus dem Sichtbereich
/// gescrollt ist, wird ausgehängt und meldet sich beim [Form] ab — sein
/// `validator` läuft dann bei `validate()` nicht mehr mit, und die Methode
/// liefert `true`, obwohl das Feld leer ist.
///
/// Das fällt in kurzen Formularen nie auf und in langen immer: Wer unten auf
/// „Speichern" tippt, hat die Pflichtfelder oben längst ausgescrollt. Die
/// fehlende Eingabe rutscht durch bis in die Persistenzschicht, und statt der
/// Feldmeldung sieht die Person eine rohe Exception —
/// `Invalid argument(s): Dosierung darf nicht leer sein`.
///
/// Dieses Widget baut alle Kinder auf einmal, also bleiben alle Felder beim
/// [Form] registriert. Der Preis ist ein größerer Aufbau; für Formulare mit
/// einigen Dutzend Feldern ist das nicht messbar.
///
/// ```dart
/// Form(
///   key: _formKey,
///   child: FormScrollView(
///     padding: const EdgeInsets.all(16),
///     children: [ ... ],
///   ),
/// )
/// ```
class FormScrollView extends StatelessWidget {
  const FormScrollView({
    required this.children,
    this.padding,
    this.controller,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      padding: padding,
      child: Column(
        // ListView streckt seine Kinder auf die volle Breite, Column zentriert
        // sie. Ohne stretch würde jedes Feld auf seine Wunschbreite schrumpfen.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
