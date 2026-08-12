import 'package:flutter/material.dart';

/// Wiederverwendbares Widget für Text mit Gradient/Regenbogen-Farben
/// Verwendet ShaderMask für performante Gradient-Darstellung
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
    this.textAlign,
    super.key,
  });

  final String text;
  final Gradient gradient;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style:
            style?.copyWith(color: Colors.white) ??
            const TextStyle(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

/// Vordefinierter warmer Pastell-Regenbogen-Gradient für "Aurora"
const kAuroraRainbowGradient = LinearGradient(
  colors: [
    Color(0xFFFFB6C1), // Pastel Pink
    Color(0xFFFFDAB9), // Peach
    Color(0xFFFFF4A3), // Pastel Yellow
    Color(0xFFB4E7CE), // Mint Green
    Color(0xFF87CEEB), // Sky Blue
    Color(0xFFDDA0DD), // Lavender
  ],
);

/// Invertierter warmer Pastell-Regenbogen-Gradient (für Kontrast auf kAuroraRainbowGradient)
const kAuroraRainbowGradientInverted = LinearGradient(
  colors: [
    Color(0xFFDDA0DD), // Lavender (reversed)
    Color(0xFF87CEEB), // Sky Blue
    Color(0xFFB4E7CE), // Mint Green
    Color(0xFFFFF4A3), // Pastel Yellow
    Color(0xFFFFDAB9), // Peach
    Color(0xFFFFB6C1), // Pastel Pink (reversed)
  ],
);
