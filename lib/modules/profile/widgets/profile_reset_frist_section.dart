import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Wahl der eigenen Wartefrist für den Passwort-Reset.
///
/// Die Frist ist der Schutz eines Anteils, der selten vorne ist: Sie
/// bestimmt, wie lange er Zeit hat, einen fremd gestarteten Reset per
/// Login abzubrechen. Deshalb entscheidet jeder Anteil sie selbst, und
/// eine Änderung wirkt nur auf künftige Resets.
class ProfileResetFristSection extends StatelessWidget {
  const ProfileResetFristSection({
    required this.gewaehlteStunden,
    required this.profilFarbe,
    required this.onFristChanged,
    super.key,
  });

  /// Null bedeutet: Standard von 24 Stunden.
  final int? gewaehlteStunden;
  final Color profilFarbe;
  final ValueChanged<int> onFristChanged;

  // Die Beschriftung entsteht erst beim Bauen aus `tage`, in der Sprache
  // der Oberfläche; vorher stand hier fest „3 Tage", auch auf Italienisch.
  static const List<({int stunden, int tage, IconData zeichen})> stufen = [
    (stunden: 24, tage: 1, zeichen: Icons.brightness_5),
    (stunden: 72, tage: 3, zeichen: Icons.brightness_6),
    (stunden: 168, tage: 7, zeichen: Icons.brightness_2),
  ];

  @override
  Widget build(BuildContext context) {
    final aktuell = gewaehlteStunden ?? 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.hourglass_top, color: AppColors.paper, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context).profileResetFristExplanation,
                style: TextStyle(
                  color: AppColors.paper.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final stufe in stufen) ...[
              Expanded(
                child: _Stufe(
                  stufe: stufe,
                  gewaehlt: aktuell == stufe.stunden,
                  farbe: profilFarbe,
                  onTap: () => onFristChanged(stufe.stunden),
                ),
              ),
              if (stufe != stufen.last) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _Stufe extends StatelessWidget {
  const _Stufe({
    required this.stufe,
    required this.gewaehlt,
    required this.farbe,
    required this.onTap,
  });

  final ({int stunden, int tage, IconData zeichen}) stufe;
  final bool gewaehlt;
  final Color farbe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: gewaehlt ? farbe : Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(
                stufe.zeichen,
                size: 28,
                color: gewaehlt
                    ? Colors.white
                    : AppColors.paper.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context).profileResetFristDays(stufe.tage),
                style: TextStyle(
                  color: gewaehlt
                      ? Colors.white
                      : AppColors.paper.withValues(alpha: 0.7),
                  fontWeight: gewaehlt ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
