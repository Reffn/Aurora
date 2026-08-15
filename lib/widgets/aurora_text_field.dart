import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Die Beschriftung über einem Bedienfeld.
///
/// Steht hier und nicht in `AuroraTextField`, weil sie nicht dem Textfeld
/// gehört, sondern der Fläche: Ein Auswahlfeld daneben braucht dieselbe
/// Beschriftung, sonst sieht man den Bruch. Genau das war am 12.08. im
/// Kontaktformular zu sehen — fünf Felder mit Beschriftung darüber, dazwischen
/// „Kategorie" mit einem Label, das in den Rahmen eingekerbt war.
///
/// Ein zweites Bauteil für den einen Dropdown wäre Überbau. Ein gemeinsamer
/// Rahmen für beide ist der kleinste Weg, der die Fläche zusammenhält.
class AuroraFeldRahmen extends StatelessWidget {
  const AuroraFeldRahmen({required this.child, super.key, this.label});

  /// `null` heißt: Diese Fläche beschriftet selbst.
  final String? label;
  final Widget child;

  /// Die Farbe der Beschriftung.
  static const Color akzent = AppColors.paper;

  @override
  Widget build(BuildContext context) {
    final beschriftung = label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (beschriftung != null) ...[
          Text(
            beschriftung,
            style: const TextStyle(
              color: akzent,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        child,
      ],
    );
  }
}

/// Das Eingabefeld der App — eine Stelle, an der Beschriftung, Rahmen,
/// Fehlertext und Bediengröße festgelegt sind.
///
/// **Warum es das gibt.** Vorher standen 44 Felder in 16 Dateien, jedes mit
/// eigenem `InputDecoration`: eigene Randfarben, eigene Schriftgrößen, eigene
/// Abstände. Es gab zwar `AppInputDecorations`, aber es benutzte **niemand** —
/// weil es eine schwebende Beschriftung im Feld vorsah, während die Flächen
/// die Beschriftung als eigene Zeile darüber setzen. Eine Abstraktion, die
/// nicht beschreibt, was die App tut, wird nicht angenommen; sie liegt nur
/// herum.
///
/// **Die Beschriftung steht über dem Feld und bleibt dort.** Ein Label, das
/// beim Tippen in den Rahmen wandert, verlangt, den Zusammenhang im Kopf zu
/// behalten — genau das, was bei kognitiver Belastung zuerst wegbricht
/// (W3C COGA). Wer den Faden verliert, findet die Frage sonst nicht wieder.
///
/// **Bild und Wort, nicht Wort allein** (Regel 5): Ein `icon` steht links im
/// Feld, wenn die Sache eines hat.
///
/// **Bediengröße.** WCAG 2.2 nennt 24×24 als Untergrenze und sagt
/// ausdrücklich „more for unsteady hands"; unruhige Hände sind hier der
/// Normalfall. Deshalb `minHoehe`.
///
/// ## Vier Felder benutzen dieses Bauteil bewusst nicht
///
/// Wer die Umstellung „zu Ende bringen" will, macht sie damit kaputt:
///
/// - **Chat-Zeile** (`chat_input_field.dart`) und **Kommentarleiste**
///   (`comment_input_bar.dart`) sind Verfasserleisten, keine Formularfelder.
///   Sie tragen keine Beschriftung, sitzen in einer abgerundeten Pille und
///   wachsen beim Schreiben mit. Eine Überschrift darüber wäre dort Lärm.
/// - **Die beiden Felder der Kartenauswahl** (`map_picker.dart`) liegen auf
///   der hellen Kartenfläche. Die weiße Schrift dieses Bauteils wäre dort
///   nicht zu lesen — sie sind hell gefüllt, weil ihr Untergrund es ist.
///
/// Der Unterschied ist also nicht Nachlässigkeit, sondern ein anderer
/// Untergrund und eine andere Aufgabe.
class AuroraTextField extends StatefulWidget {
  const AuroraTextField({
    required this.label,
    super.key,
    this.controller,
    this.initialValue,
    this.hint,
    this.obscure = false,
    this.errorText,
    this.helperText,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
  }) : assert(
         controller == null || initialValue == null,
         'Entweder ein Controller oder ein Startwert — beides zugleich '
         'streitet sich um denselben Inhalt.',
       );

  /// Steht über dem Feld. `null` heißt: Diese Fläche beschriftet selbst —
  /// etwa die Chat-Zeile, die keine Überschrift verträgt.
  final String? label;

  /// Der Inhalt kommt entweder von hier oder von [initialValue].
  ///
  /// Formulare, die ihren Wert erst beim Absenden lesen, brauchen keinen
  /// Controller — die Medikamentenfelder für Höchstmenge und Mindestabstand
  /// sind so gebaut.
  final TextEditingController? controller;

  /// Startwert für Felder ohne Controller.
  final String? initialValue;

  final String? hint;
  final bool obscure;
  final String? errorText;
  final String? helperText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Prüfung beim Absenden eines `Form`.
  ///
  /// Deshalb liegt darunter ein `TextFormField` und kein `TextField`: Die
  /// Formulare der App prüfen ihre Pflichtfelder, die Dialoge nicht. Zwei
  /// Bauteile dafür wären wieder zwei Wahrheiten — `TextFormField`
  /// funktioniert auch außerhalb eines `Form`.
  final FormFieldValidator<String>? validator;

  final TextCapitalization textCapitalization;

  /// Zeigt an, statt zu erfragen — etwa die Adresse, die aus der Karte kommt.
  ///
  /// Anders als `enabled: false`: Das Feld bleibt lesbar und ansteuerbar, man
  /// kann nur nichts hineinschreiben. Ein abgeblendetes Feld sähe aus wie ein
  /// gesperrtes, und gesperrt ist es nicht.
  final bool readOnly;

  /// Untergrenze der Bedienfläche.
  static const double minHoehe = 56;

  /// Die Farbe der Beschriftung und des Rahmens im Fokus.
  static const Color akzent = AppColors.paper;

  @override
  State<AuroraTextField> createState() => _AuroraTextFieldState();
}

class _AuroraTextFieldState extends State<AuroraTextField> {
  /// Ob der Inhalt gerade verdeckt ist.
  ///
  /// Der Schalter dafür liegt hier und nicht bei den Aufrufern. Vorher trug
  /// jede Stelle mit einem Passwortfeld ihr eigenes Flag und ihren eigenen
  /// `IconButton` — vier Kopien in drei Dateien. Wer eine davon übersah,
  /// hatte ein Passwortfeld ohne Weg, das Getippte zu prüfen.
  late bool _verdeckt = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuroraFeldRahmen(
      label: widget.label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AuroraTextField.minHoehe,
        ),
        child: TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: widget.focusNode,
          obscureText: _verdeckt,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          textCapitalization: widget.textCapitalization,
          readOnly: widget.readOnly,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AuroraTextField.akzent.withValues(alpha: 0.4),
            ),
            errorText: widget.errorText,
            helperText: widget.helperText,
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 20),
            // Nur bei verdeckten Feldern, und dann immer: Wer nicht sieht,
            // was er tippt, kann einen Tippfehler nicht finden.
            suffixIcon: !widget.obscure
                ? null
                : IconButton(
                    icon: Icon(
                      _verdeckt ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    tooltip: _verdeckt
                        ? l10n.fieldPasswordShow
                        : l10n.fieldPasswordHide,
                    onPressed: () => setState(() => _verdeckt = !_verdeckt),
                  ),
            border: _rand(Colors.white.withValues(alpha: 0.2)),
            enabledBorder: _rand(Colors.white.withValues(alpha: 0.2)),
            focusedBorder: _rand(AuroraTextField.akzent, breite: 2),
            errorBorder: _rand(Colors.red.shade300),
            focusedErrorBorder: _rand(Colors.red.shade300, breite: 2),
            disabledBorder: _rand(Colors.white.withValues(alpha: 0.08)),
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _rand(Color farbe, {double breite = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: farbe, width: breite),
    );
  }
}
