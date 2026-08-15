import 'dart:io';
import 'dart:math' as math;

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/widgets/gradient_text.dart';
import 'package:flutter/material.dart';

/// Dreieckiges Avatar-Widget für Kontakte
///
/// Universell verwendbar in:
/// - Kontaktlisten (`ContactCard`)
/// - Kontakt-Detailansicht
/// - Emergency Contact Cards
/// - Map-Marker (via `MapMarkerContact`)
///
/// **Features:**
/// - Dreieckige Form (ClipPath mit TriangleClipper)
/// - ProfileImageWidget mit Rainbow-Initialen Fallback
/// - Grün Hintergrund als Fallback (anpassbar)
/// - White Border (anpassbar)
/// - Box Shadow
///
/// **Verwendung:**
/// ```dart
/// ContactAvatar(
///   imagePath: contact.imagePath,
///   name: contact.name,
///   size: 80,
///   fallbackColor: Colors.green.shade600,
/// )
/// ```
class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    required this.imagePath,
    required this.name,
    super.key,
    this.size = 50,
    this.borderColor = Colors.white,
    this.borderWidth = 3,
    this.fallbackColor,
    this.showShadow = true,
  });

  final String? imagePath;
  final String name;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Color? fallbackColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = fallbackColor ?? Colors.green.shade600;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Äußeres Dreieck (Border + Shadow)
          if (showShadow)
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: TriangleClipper(),
                child: Container(
                  width: size,
                  height: size,
                  color: borderColor,
                ),
              ),
            )
          else
            ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                width: size,
                height: size,
                color: borderColor,
              ),
            ),
          // Inneres Dreieck (Content)
          Padding(
            padding: EdgeInsets.all(borderWidth),
            child: ClipPath(
              clipper: TriangleClipper(),
              child: _buildTriangleContent(
                size - (borderWidth * 2),
                backgroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rendert Inhalt des Dreiecks: Bild oder Rainbow-Initialen
  Widget _buildTriangleContent(double contentSize, Color backgroundColor) {
    // Kein Bild-Pfad → Rainbow-Initialen anzeigen
    if (imagePath == null) {
      return _buildRainbowInitials(contentSize, backgroundColor);
    }

    // Asset-Pfad → Direkt Image.asset() verwenden
    if (_isAssetPath(imagePath)) {
      return Image.asset(
        imagePath!,
        width: contentSize,
        height: contentSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          logger.error(
            LogCategory.ui,
            '🔺 ContactAvatar: Asset load ERROR',
            data: {'path': imagePath, 'error': error.toString()},
          );
          return _buildRainbowInitials(contentSize, backgroundColor);
        },
      );
    }

    // File-Pfad ohne Warten, wenn der Ordner bekannt ist. Kontaktkarten
    // stehen in Listen — der FutureBuilder hier löste den Anhang-Ordner
    // beim Scrollen für jede sichtbare Karte neu auf.
    return ValueListenableBuilder<Directory?>(
      valueListenable: AttachmentHelper.directory,
      builder: (context, _, __) {
        final datei = AttachmentHelper.fileSync(imagePath!);
        if (datei == null) {
          return _buildRainbowInitials(contentSize, backgroundColor);
        }
        return _buildFileImage(datei, contentSize, backgroundColor);
      },
    );
  }

  /// Prüft ob ein Pfad ein Asset-Pfad ist
  static bool _isAssetPath(String? path) {
    if (path == null) return false;
    return path.startsWith('assets/');
  }

  /// Regenbogen-Initialen OHNE kreisförmigen Container (direkt im Dreieck)
  /// Das Bild aus einer Datei, mit demselben Rückfall bei Lesefehlern.
  Widget _buildFileImage(
    File datei,
    double contentSize,
    Color backgroundColor,
  ) => Image.file(
    datei,
    width: contentSize,
    height: contentSize,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      logger.error(
        LogCategory.ui,
        '🔺 ContactAvatar: Image.file() rendering ERROR',
        data: {'filePath': datei.path, 'error': error.toString()},
      );
      return _buildRainbowInitials(contentSize, backgroundColor);
    },
  );

  Widget _buildRainbowInitials(double contentSize, Color backgroundColor) {
    // UTF-16 safe: Verwende runes um vollständige Zeichen zu bekommen
    final runes = name.runes.toList();
    final initial = runes.isEmpty
        ? '?'
        : String.fromCharCode(runes.first).toUpperCase();

    final fontSize = contentSize * 0.45;
    // 2.0 statt 2: Mit einem Int-Literal wählt Dart math.min<num>, und ein num
    // lässt sich nicht an Paint.strokeWidth (double) zuweisen.
    final strokeWidth = math.min(2.0, contentSize * 0.08);

    return Container(
      width: contentSize,
      height: contentSize,
      color: backgroundColor, // Dreieck-Hintergrund (KEIN Circle!)
      child: Center(
        child: Stack(
          children: [
            // 1. Schwarzer Stroke für Kontrast auf allen Hintergründen
            Text(
              initial,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = Colors.black,
              ),
            ),
            // 2. Rainbow Gradient Fill
            ShaderMask(
              shaderCallback: (bounds) => kAuroraRainbowGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              blendMode: BlendMode.srcIn,
              child: Text(
                initial,
                style: TextStyle(
                  color: Colors.white, // Wird durch Gradient ersetzt
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Clipper für Dreieck-Form mit abgerundeten Ecken
///
/// Erstellt gleichschenkliges Dreieck mit Spitze nach oben:
/// - Top center: Spitze (abgerundet)
/// - Bottom left: Linke Ecke (abgerundet)
/// - Bottom right: Rechte Ecke (abgerundet)
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 5.0; // Radius für abgerundete Ecken

    final path = Path();

    // Start etwas unterhalb der oberen Spitze
    path.moveTo(size.width / 2 - radius, radius * 0.7);

    // Obere Spitze (abgerundet)
    path.arcToPoint(
      Offset(size.width / 2 + radius, radius * 0.7),
      radius: const Radius.circular(radius),
    );

    // Rechte Seite zur unteren rechten Ecke
    path.lineTo(size.width - radius, size.height - radius);

    // Untere rechte Ecke (abgerundet)
    path.arcToPoint(
      Offset(size.width - radius * 0.7, size.height),
      radius: const Radius.circular(radius),
    );

    // Untere Kante zur linken Ecke
    path.lineTo(radius * 0.7, size.height);

    // Untere linke Ecke (abgerundet)
    path.arcToPoint(
      Offset(radius, size.height - radius),
      radius: const Radius.circular(radius),
    );

    // Linke Seite zurück zur oberen Spitze
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
