import 'package:flutter/material.dart';

/// Avatar Widget mit automatischem Fallback auf Initialen
///
/// Zeigt entweder das Profilbild oder Initial-Buchstaben an.
/// **UTF-16 SAFE**: Verwendet `runes` statt Subscript-Zugriff
/// um Emoji-Crashes zu vermeiden.
///
/// Features:
/// - Unterstützt Emojis im Namen (z.B. "🐶 Rex")
/// - Automatischer Fallback auf Initials
/// - Anpassbare Größe und Farben
/// - Optional: Border (z.B. für aktive Profile)
///
/// Beispiel:
/// ```dart
/// AvatarWithInitials(
///   name: "Max Mustermann",
///   size: 50,
///   backgroundColor: Colors.blue,
/// )
/// ```
class AvatarWithInitials extends StatelessWidget {
  const AvatarWithInitials({
    required this.name,
    super.key,
    this.size = 50,
    this.fontSize,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.maxInitials = 2,
    this.borderColor,
    this.borderWidth = 0,
  });

  /// Name für Initials-Extraktion
  final String name;

  /// Größe des Avatars (width & height)
  final double size;

  /// Font-Größe der Initialen (default: size * 0.4)
  final double? fontSize;

  /// Hintergrund-Farbe (default: Theme primary mit 0.3 alpha)
  final Color? backgroundColor;

  /// Text-Farbe der Initialen
  final Color textColor;

  /// Maximale Anzahl Initialen (1-2)
  final int maxInitials;

  /// Optional: Border-Farbe
  final Color? borderColor;

  /// Border-Breite (default: 0 = kein Border)
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.3);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: borderWidth > 0 && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize ?? size * 0.4,
          ),
        ),
      ),
    );
  }

  /// Extrahiert Initialen aus dem Namen (UTF-16 SAFE!)
  ///
  /// Beispiele:
  /// - "Max Mustermann" → "MM"
  /// - "🐶 Rex" → "🐶R"
  /// - "Alex" → "A" (bei maxInitials=1)
  /// - "" → "?"
  String _getInitials() {
    if (name.trim().isEmpty) return '?';

    // Split name by spaces and get first letter of each word
    final words = name.trim().split(RegExp(r'\s+'));

    // Sammle Initialen von den ersten X Wörtern
    final initials = <int>[];

    for (var i = 0; i < words.length && initials.length < maxInitials; i++) {
      final word = words[i];
      if (word.isEmpty) continue;

      // UTF-16 SAFE: Verwende runes statt subscript
      // Bei Emojis wie "🐶" besteht der String aus mehreren code units,
      // aber runes.first gibt das vollständige Zeichen zurück
      final runes = word.runes.toList();
      if (runes.isNotEmpty) {
        initials.add(runes.first);
      }
    }

    // Wenn keine Initialen gefunden, return '?'
    if (initials.isEmpty) return '?';

    // Convert runes back to String und uppercase
    return String.fromCharCodes(initials).toUpperCase();
  }
}
