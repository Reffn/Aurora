import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:flutter/material.dart';

/// Fragt nach, wie ein Medikament gewirkt hat.
///
/// Steht in einer eigenen Datei, damit ein Test ihn pumpen kann. Im
/// Medikamenten-Bildschirm war er privat und damit nur über den ganzen
/// Bildschirm samt Abhängigkeiten erreichbar — geprüft wurde er deshalb nie.
///
/// **Zur Höhe gibt es eine offene Frage, siehe `scrollable` unten.** Das Feld
/// nimmt fünf Zeilen, trägt einen Zeichenzähler und zieht wegen `autofocus`
/// die Tastatur sofort hoch. Auf 360×800 dp reicht der Platz — nachgemessen.
/// Für die 640-dp-Klasse ist es ungeklärt.
class MedicationFeedbackDialog extends StatefulWidget {
  const MedicationFeedbackDialog({required this.medicationName, super.key});

  final String medicationName;

  @override
  State<MedicationFeedbackDialog> createState() =>
      _MedicationFeedbackDialogState();
}

class _MedicationFeedbackDialogState extends State<MedicationFeedbackDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      // Vorsorge, kein nachgewiesen behobener Fehler.
      //
      // Auf 360×800 dp — den Maßen des A14, des kleinsten *uns bekannten*
      // Geräts — steht das Feld auch ohne dies frei über der Tastatur;
      // nachgemessen am 12.08.2026.
      //
      // Bei 360×640 dp bekam der Inhaltsbereich dagegen die Höhe null, und
      // ein `SingleChildScrollView` in `content` half nicht: Ein Scroller
      // ohne Höhe scrollt nicht. **Ob `scrollable: true` diesen Fall rettet,
      // ist offen** — der Zug im Test traf vermutlich den inneren Scroller
      // des Textfeldes statt den des Dialogs, die Messung taugt also nicht.
      //
      // 360×640 dp ist keine erfundene Größe: Galaxy S7 (1440×2560 @ 640) und
      // J5 (720×1280 @ 320) liegen genau darauf, und `minSdk 24` lässt sie
      // zu. Ob solche Geräte unter den Installationen sind, wissen wir nicht
      // — Aurora zählt nichts, was das verraten würde.
      scrollable: true,
      title: Text(l10n.medicationAddFeedback),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.medicationFeedbackQuestion(widget.medicationName)),
          const SizedBox(height: 16),
          AuroraTextField(
            label: l10n.medicationFeedbackYourExperience,
            controller: _controller,
            hint: l10n.medicationFeedbackHint,
            maxLines: 5,
            maxLength: 500,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        ElevatedButton(
          onPressed: () {
            final feedback = _controller.text.trim();
            if (feedback.isNotEmpty) {
              Navigator.pop(context, feedback);
            }
          },
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
