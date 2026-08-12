import 'package:flutter/material.dart';

/// Wiederverwendbares Status-Badge Widget
///
/// Zeigt einen kleinen farbigen Badge mit Text und optionalem Icon.
/// Verwendet für Status-Anzeigen wie "Genommen", "Verweigert", "Bald", etc.
///
/// **Standardisiert:**
/// - Border mit Farbe (opacity 0.5)
/// - Background mit Farbe (opacity 0.2)
/// - BorderRadius 8px
/// - Konsistente Paddings
///
/// Beispiele:
/// ```dart
/// StatusBadge.success("Genommen", icon: Icons.check_circle)
/// StatusBadge.error("Verweigert", icon: Icons.cancel)
/// StatusBadge.warning("Später", icon: Icons.schedule)
/// StatusBadge(text: "Custom", color: Colors.blue)
/// ```
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.text,
    required this.color,
    super.key,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
    this.fontSize = 12,
  });

  /// SUCCESS Badge (grün)
  const StatusBadge.success(
    this.text, {
    super.key,
    this.icon = Icons.check_circle,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
    this.fontSize = 12,
  }) : color = Colors.green;

  /// ERROR Badge (rot)
  const StatusBadge.error(
    this.text, {
    super.key,
    this.icon = Icons.cancel,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
    this.fontSize = 12,
  }) : color = Colors.red;

  /// WARNING Badge (orange)
  const StatusBadge.warning(
    this.text, {
    super.key,
    this.icon = Icons.warning,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
    this.fontSize = 12,
  }) : color = Colors.orange;

  /// INFO Badge (blau)
  const StatusBadge.info(
    this.text, {
    super.key,
    this.icon = Icons.info,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
    this.fontSize = 12,
  }) : color = Colors.blue;

  /// SCHEDULED Badge (orange mit clock icon)
  const StatusBadge.scheduled(
    this.text, {
    super.key,
    this.icon = Icons.schedule,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
    this.fontSize = 12,
  }) : color = Colors.orange;

  /// COMING SOON Badge (grau)
  const StatusBadge.comingSoon({
    super.key,
    this.text = 'Bald',
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
    this.fontSize = 12,
  }) : color = Colors.grey;

  /// Badge Text
  final String text;

  /// Badge Farbe (Background = opacity 0.2, Border = opacity 0.5)
  final Color color;

  /// Optionales Icon (links vom Text)
  final IconData? icon;

  /// Padding innerhalb des Badges
  final EdgeInsets padding;

  /// Border-Radius (default: 8)
  final double borderRadius;

  /// Font-Size des Texts (default: 12)
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2, // Icon etwas größer als Text
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
