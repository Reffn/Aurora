import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Widget für Alters-Auswahl beim Profil erstellen/bearbeiten
class ProfileAgeSection extends StatelessWidget {
  const ProfileAgeSection({
    required this.selectedAge,
    required this.selectedColor,
    required this.onAgeChanged,
    super.key,
  });

  final double selectedAge;
  final Color selectedColor;
  final void Function(double age) onAgeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).profileAgeYears(selectedAge.toInt()),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.paper,
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: selectedColor,
            thumbColor: selectedColor,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            overlayColor: selectedColor.withValues(alpha: 0.3),
            valueIndicatorColor: selectedColor,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: selectedAge,
            min: 1,
            max: 99,
            divisions: 98,
            label: selectedAge.toInt().toString(),
            onChanged: onAgeChanged,
          ),
        ),
      ],
    );
  }
}
