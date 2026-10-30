import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Zeigt eine Erklärung als Blatt von unten.
///
/// Die Einstellungen zeigen Zustand und Handlung; was eine Sache ist und wie
/// sie arbeitet, steht hier und kommt nur, wenn jemand danach fragt. Wer
/// gerade nur einen Schalter umlegen will, muss sich nicht durch Absätze
/// lesen.
///
/// [action] steht unter dem Text, weil Schritt-Texte auf „unten“ verweisen.
/// Geschlossen wird über einen sichtbaren Knopf, Wischen ist nur Abkürzung
/// (Regel 8).
Future<void> showSettingsInfoSheet(
  BuildContext context, {
  required String title,
  required List<Widget> children,
  IconData icon = Icons.info_outline,
  Widget? action,
}) {
  return showModalBottomSheet<void>(
    context: context,
    // Lange Erklärungen und große Schrift brauchen mehr als die halbe Höhe.
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF1F1F1F),
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
              if (action != null) ...[
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: action),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.settingsUnderstood),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Der ⓘ-Knopf, der eine Erklärung öffnet.
///
/// Ein Symbol ohne Wort, gegen Regel 5. Der Kreis mit „i“ ist aber das
/// vertraute Zeichen für „mehr dazu“, und Regel 5 verbietet ausdrücklich,
/// Vertrautes neu zu erfinden. Das Wort steht im Tooltip und im
/// Vorleser.
class SettingsInfoButton extends StatelessWidget {
  const SettingsInfoButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: AppLocalizations.of(context).settingsInfoTooltip,
      onPressed: onPressed,
    );
  }
}

/// Ein Absatz im Erklärblatt.
class SettingsInfoParagraph extends StatelessWidget {
  const SettingsInfoParagraph(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.9),
          height: 1.5,
        ),
      ),
    );
  }
}

/// Ein Hinweis mit Symbol im Erklärblatt: ruhig, ohne Signalfarbe.
class SettingsInfoNote extends StatelessWidget {
  const SettingsInfoNote({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
