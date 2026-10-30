import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Überschrift einer Gruppe in „Anteile & Rechte“.
///
/// Gruppen statt flacher Liste (Richtlinie 3). Gedämpft, weil sie ordnet
/// und nicht ruft.
class PartsGroupHeader extends StatelessWidget {
  const PartsGroupHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: AppColors.mist,
          ),
        ),
      ),
    );
  }
}
