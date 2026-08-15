import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Rahmen für die Onboarding-Schirme mit dem Ausgang „Nicht mehr anzeigen".
///
/// Der Knopf steht in einer **eigenen Zeile über** dem Inhalt, nicht darüber
/// gelegt. Vorher war das ein `Stack` mit `Positioned` — auf der ersten Seite
/// lag „Nicht mehr anzeigen" damit auf „Willkommen bei". Ab Seite zwei fiel es
/// nicht auf, weil dort keine Überschrift so weit oben steht; der Fehler war
/// also nicht die Seite, sondern der Rahmen.
///
/// Eine reservierte Zeile kostet etwas Höhe auf jeder Seite. Das ist der
/// richtige Tausch: Der Ausgang steht damit auf allen Seiten an derselben
/// Stelle (Richtlinie 7 — Reihenfolge ist eine Zusage), und er verdeckt nie
/// etwas (Turk & Hutchings, CHI 2023: Überlagerungen dürfen kritische
/// Handlungen nicht verdecken).
class DismissableOnboardingWrapper extends StatelessWidget {
  const DismissableOnboardingWrapper({
    required this.child,
    required this.onDismiss,
    this.showDismissButton = true,
    this.background = AppColors.ink,
    super.key,
  });

  final Widget child;
  final VoidCallback onDismiss;
  final bool showDismissButton;

  /// Der Grund hinter der Knopfzeile. Beide Aufrufer legen ihre Seiten auf
  /// denselben dunklen Ton; ohne ihn stünde die Zeile auf dem Scaffold-Grund
  /// und risse einen hellen Streifen über den Schirm.
  final Color background;

  @override
  Widget build(BuildContext context) {
    if (!showDismissButton) return child;

    return ColoredBox(
      color: background,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: TextButton(
                  onPressed: onDismiss,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).onboardingDismiss,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
          // Der obere Systemabstand ist oben schon verbraucht. Ohne dieses
          // Entfernen legten die Seiten ihn ein zweites Mal an — sie tragen
          // ihre eigene `SafeArea`, weil sie auch ohne diesen Rahmen richtig
          // stehen müssen.
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
