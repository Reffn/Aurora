import 'package:flutter/material.dart';

/// Wiederverwendbarer Icon-Container
///
/// Quadratischer/Runder Container mit farbigem Hintergrund und zentriertem Icon.
/// Verwendet für konsistente Icon-Darstellung in Cards, Listen, etc.
///
/// **Standardisiert:**
/// - Größe (small: 40px, medium: 56px, large: 60px, custom)
/// - Form (Kreis oder abgerundetes Quadrat)
/// - Farben (automatisch aus Theme oder custom)
///
/// Beispiele:
/// ```dart
/// IconContainer(icon: Icons.person)
/// IconContainer.small(icon: Icons.star, circle: true)
/// IconContainer.large(icon: Icons.settings, backgroundColor: Colors.blue)
/// ```
class IconContainer extends StatelessWidget {
  const IconContainer({
    required this.icon,
    super.key,
    this.size = 56,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 12,
    this.circle = false,
  });

  /// SMALL Icon-Container (40x40)
  const IconContainer.small({
    required this.icon,
    super.key,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 8,
    this.circle = false,
  }) : size = 40;

  /// MEDIUM Icon-Container (56x56) - Default
  const IconContainer.medium({
    required this.icon,
    super.key,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 12,
    this.circle = false,
  }) : size = 56;

  /// LARGE Icon-Container (60x60)
  const IconContainer.large({
    required this.icon,
    super.key,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 12,
    this.circle = false,
  }) : size = 60;

  /// CIRCLE Icon-Container (automatische borderRadius = size/2)
  const IconContainer.circle({
    required this.icon,
    super.key,
    this.size = 56,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
  }) : borderRadius = 0,
       circle = true;

  /// Das Icon
  final IconData icon;

  /// Container-Größe (width & height)
  final double size;

  /// Icon-Größe (default: size * 0.55)
  final double? iconSize;

  /// Hintergrund-Farbe (default: Theme.of(context).colorScheme.primaryContainer)
  final Color? backgroundColor;

  /// Icon-Farbe (default: Theme.of(context).colorScheme.primary)
  final Color? iconColor;

  /// Border-Radius (ignored wenn circle=true)
  final double borderRadius;

  /// Kreis-Form? (überschreibt borderRadius)
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? Theme.of(context).colorScheme.primaryContainer;
    final icColor = iconColor ?? Theme.of(context).colorScheme.primary;
    final icSize = iconSize ?? size * 0.55;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          icon,
          size: icSize,
          color: icColor,
        ),
      ),
    );
  }
}
