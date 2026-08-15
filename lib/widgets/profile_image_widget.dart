import 'dart:io';
import 'dart:math' as math;
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/widgets/gradient_text.dart';
import 'package:flutter/material.dart';

/// Wiederverwendbares Widget für Profil-Avatare
/// Unterstützt sowohl Asset-Pfade (z.B. "assets/images/Hund.png")
/// als auch File-Pfade (z.B. "avatar_123.jpg" im attachments-Verzeichnis)
///
/// **Smart Fallback:** Falls kein Bild vorhanden, zeigt automatisch Regenbogen-Initialen
/// basierend auf profileName und profileColor
class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({
    required this.avatarPath,
    required this.size,
    super.key,
    this.profileName,
    this.profileColor,
    this.placeholderIcon,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.circle,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.maxInitialChars = 1,
  });

  final String? avatarPath;
  final double size;

  /// Name für Regenbogen-Initialen Fallback (wenn kein Bild)
  final String? profileName;

  /// Farbe für Hintergrund der Regenbogen-Initialen
  final Color? profileColor;

  /// Sinnbild für Dinge, die keine Initialen haben — ein Fundstück etwa.
  ///
  /// Hier stand ein `Widget? fallbackWidget`. Sieben von achtzehn
  /// Aufrufstellen reichten darüber ihren eigenen Rückfall herein, und drei
  /// davon schrieben `Colors.white` auf die Profilfarbe. Bei einem hellen
  /// Profil stand damit Weiß auf Weiß — eine leere Fläche, wo ein Gesicht
  /// hingehört.
  ///
  /// Ein `IconData` statt eines `Widget`: ein Widget wäre dieselbe Hintertür
  /// unter neuem Namen. Wer Initialen will, gibt `profileName` und
  /// `profileColor` — dann trägt der Rückfall seine Kontur, wie überall.
  final IconData? placeholderIcon;

  final BoxFit fit;
  final BoxShape shape;

  /// Optional: Border-Farbe (wenn gesetzt, wird Border gerendert)
  final Color? borderColor;

  /// Optional: Border-Breite (Standard: 2.0 wenn borderColor gesetzt)
  final double? borderWidth;

  /// Optional: Box-Shadow für Border-Container
  final List<BoxShadow>? boxShadow;

  /// Maximale Anzahl an Zeichen für Initialen (Standard: 1 für Profile, 3 für Medikamente)
  final int maxInitialChars;

  /// Prüft ob ein Pfad ein Asset-Pfad ist
  static bool _isAssetPath(String? path) {
    if (path == null) return false;
    return path.startsWith('assets/');
  }

  @override
  Widget build(BuildContext context) {
    // Border vorhanden? Dann wrappen wir das Image in einen Border-Container
    final hasBorder = borderColor != null;
    final effectiveBorderWidth = hasBorder ? (borderWidth ?? 2.0) : 0.0;
    final imageSize = hasBorder ? size - (effectiveBorderWidth * 2) : size;

    // Rendere das eigentliche Image/Fallback
    final imageWidget = _buildImageWidget(imageSize);

    // Wenn Border: Wrappen in Container mit Border
    if (hasBorder) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: shape,
          border: Border.all(
            color: borderColor!,
            width: effectiveBorderWidth,
          ),
          boxShadow: boxShadow,
        ),
        child: Center(child: imageWidget),
      );
    }

    // Ohne Border: Direkt zurückgeben
    return imageWidget;
  }

  /// Rendert das eigentliche Image oder Fallback (ohne Border)
  Widget _buildImageWidget(double imageSize) {
    // Kein Avatar-Pfad → Smart Fallback anzeigen
    if (avatarPath == null) {
      return _buildSmartFallback(imageSize);
    }

    // Asset-Pfad → Direkt Image.asset() verwenden
    if (_isAssetPath(avatarPath)) {
      return ClipOval(
        child: Image.asset(
          avatarPath!,
          width: imageSize,
          height: imageSize,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            logger.error(
              LogCategory.ui,
              '🖼️ ProfileImageWidget: Asset load ERROR',
              data: {'path': avatarPath, 'error': error.toString()},
            );
            return _buildSmartFallback(imageSize);
          },
        ),
      );
    }

    // File-Pfad ohne Warten, wenn der Ordner bekannt ist.
    //
    // Hier stand ein FutureBuilder, dessen Future im `build` entstand. Jeder
    // Neuaufbau löste damit den Anhang-Ordner neu auf — ein Plattform-Kanal
    // und eine Dateisystem-Abfrage, pro Avatar. Dieses Widget hängt in der
    // Kopfzeile und der Profilleiste, also auf jedem Bildschirm; ein Tap,
    // der irgendwo `setState` auslöst, kostete das mehrfach. Nebenbei fiel
    // `snapshot` bei jedem Neuaufbau kurz auf „keine Daten" zurück — daher
    // das Flackern auf die Initialen und zurück.
    return ValueListenableBuilder<Directory?>(
      valueListenable: AttachmentHelper.directory,
      builder: (context, _, __) {
        final datei = AttachmentHelper.fileSync(avatarPath!);
        if (datei == null) {
          // Der Ordner ist noch nicht da. Kein Log: das ist der normale
          // Zustand in den ersten Augenblicken nach dem Start.
          return _buildSmartFallback(imageSize);
        }
        return ClipOval(child: _buildFileImage(datei, imageSize));
      },
    );
  }

  /// Das Bild aus einer Datei, mit demselben Rückfall bei Lesefehlern.
  Widget _buildFileImage(File datei, double imageSize) => Image.file(
    datei,
    width: imageSize,
    height: imageSize,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      logger.error(
        LogCategory.ui,
        '🖼️ ProfileImageWidget: Image.file() rendering ERROR',
        data: {
          'path': avatarPath,
          'filePath': datei.path,
          'error': error.toString(),
        },
      );
      return _buildSmartFallback(imageSize);
    },
  );

  /// Der Rückfall: Regenbogen-Initialen, Sinnbild, oder "?"
  Widget _buildSmartFallback(double imageSize) {
    // 1. Regenbogen-Initialen (falls Name + Farbe vorhanden)
    //
    // Zuerst, nicht zuletzt: Wer beides angibt, meint die Initialen. Stünde
    // das Sinnbild davor, wäre die Reihenfolge eine Falle.
    if (profileName != null && profileColor != null) {
      return _buildRainbowInitials(imageSize);
    }

    // 2. Sinnbild für alles ohne Namen
    if (placeholderIcon != null) {
      return Center(
        child: Icon(
          placeholderIcon,
          size: imageSize,
          color: Colors.white,
        ),
      );
    }

    // 3. Letzter Fallback: Einfaches "?"
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: imageSize * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Regenbogen-Initialen mit schwarzem Stroke (wie ProfileAvatar)
  Widget _buildRainbowInitials(double imageSize) {
    // UTF-16 safe: Verwende runes um vollständige Zeichen zu bekommen
    final runes = profileName!.runes.toList();

    // Hole ersten 1-N Buchstaben (basierend auf maxInitialChars)
    String initial;
    if (runes.isEmpty) {
      initial = '?';
    } else {
      final charCount = math.min(maxInitialChars, runes.length);
      initial = String.fromCharCodes(
        runes.take(charCount),
      ).toUpperCase();
    }

    // Dynamische Schriftgröße: Bei mehreren Zeichen kleiner
    final baseFontSize = imageSize * 0.4;
    final fontSize = maxInitialChars > 1
        ? baseFontSize * (1.0 / math.sqrt(initial.length))
        : baseFontSize;
    final strokeWidth = math.min(2.0, imageSize * 0.08);

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: profileColor,
        shape: BoxShape.circle,
      ),
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
