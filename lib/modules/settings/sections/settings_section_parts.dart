import 'package:flutter/material.dart';

/// Überschrift eines Abschnitts der Einstellungen.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader(
    this.text, {
    this.color,
    this.trailing,
    super.key,
  });

  final String text;

  /// Nur der Debug-Abschnitt setzt eine eigene Farbe.
  final Color? color;

  /// Steht direkt hinter der Überschrift, etwa das ⓘ einer Gruppe.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titel = Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: trailing == null
          ? titel
          : Row(
              children: [
                Flexible(child: titel),
                trailing!,
              ],
            ),
    );
  }
}

/// Graue Unterzeile direkt unter einer Abschnittsüberschrift.
class SettingsSectionNote extends StatelessWidget {
  const SettingsSectionNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/// Aufzählungspunkt in Erklärkästen und Dialogen der Einstellungen.
class SettingsBulletPoint extends StatelessWidget {
  const SettingsBulletPoint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
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
