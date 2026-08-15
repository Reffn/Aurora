import 'package:flutter/material.dart';

/// Section Header Widget
///
/// Zeigt einen Header mit Icon + Title + optional Description.
/// Verwendet für Abschnitts-Überschriften in Screens und Forms.
///
/// **Standardisiert:**
/// - Row-Layout: Icon → SizedBox → Title+Description
/// - Spacing: 12px zwischen Icon und Text
/// - Title: Fett, fontSize 18
/// - Description: Normal, fontSize 14, opacity 0.7
///
/// Beispiele:
/// ```dart
/// SectionHeader(
///   icon: Icons.phone,
///   title: "24/7 Notfall-Hotlines",
///   description: "Immer erreichbar in Krisensituationen",
/// )
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.icon,
    required this.title,
    super.key,
    this.description,
    this.iconColor,
    this.iconSize = 28,
    this.titleSize = 18,
    this.descriptionSize = 14,
    this.spacing = 12,
  });

  /// Icon links
  final IconData icon;

  /// Haupt-Titel
  final String title;

  /// Optional: Beschreibung unter dem Titel
  final String? description;

  /// Icon-Farbe (default: Theme primary)
  final Color? iconColor;

  /// Icon-Größe (default: 28)
  final double iconSize;

  /// Title Font-Size (default: 18)
  final double titleSize;

  /// Description Font-Size (default: 14)
  final double descriptionSize;

  /// Spacing zwischen Icon und Text (default: 12)
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final icColor = iconColor ?? Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: icColor,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: descriptionSize,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
