import 'dart:io';
import 'dart:math' as math;

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/widgets/gradient_text.dart';
import 'package:flutter/material.dart';

/// Avatar-Widget für Profilwechsel (diagonales Rechteck)
///
/// Universell verwendbar in:
/// - Timeline (`TimelineEventSymbol`)
/// - Timeline Cards
/// - Map-Marker (via `MapMarkerProfileSwitch`)
///
/// **Features:**
/// - Rechteck mit diagonaler Teilung
/// - FROM-Profil: Unteres linkes Dreieck
/// - TO-Profil: Oberes rechtes Dreieck
/// - Diagonal von unten-links nach oben-rechts
/// - Rainbow-Initialen Fallback für beide Profile
///
/// **Verwendung:**
/// ```dart
/// ProfileSwitchAvatar(
///   fromAvatarPath: fromProfile.avatarPath,
///   fromProfileName: fromProfile.name,
///   fromProfileColor: fromProfile.preferredColor,
///   toAvatarPath: toProfile.avatarPath,
///   toProfileName: toProfile.name,
///   toProfileColor: toProfile.preferredColor,
///   size: 50,
/// )
/// ```
class ProfileSwitchAvatar extends StatelessWidget {
  const ProfileSwitchAvatar({
    required this.fromAvatarPath,
    required this.fromProfileName,
    required this.fromProfileColor,
    required this.toAvatarPath,
    required this.toProfileName,
    required this.toProfileColor,
    super.key,
    this.size = 50,
    this.width,
    this.borderWidth = 2,
    this.borderColor = Colors.white,
    this.showShadow = true,
  });

  /// Named constructor für kleine Variante (Timeline Cards)
  const ProfileSwitchAvatar.small({
    required this.fromAvatarPath,
    required this.fromProfileName,
    required this.fromProfileColor,
    required this.toAvatarPath,
    required this.toProfileName,
    required this.toProfileColor,
    super.key,
    this.size = 40,
    this.width = 60,
    this.borderWidth = 2,
    this.borderColor = Colors.white,
    this.showShadow = true,
  });

  /// FROM Profile (altes Profil - unteres linkes Dreieck)
  final String? fromAvatarPath;
  final String fromProfileName;
  final Color fromProfileColor;

  /// TO Profile (neues Profil - oberes rechtes Dreieck)
  final String? toAvatarPath;
  final String toProfileName;
  final Color toProfileColor;

  /// Größe des Rechtecks (Höhe)
  final double size;

  /// Breite des Rechtecks (optional, default: size * 1.5 für 3:2 Verhältnis)
  final double? width;

  final double borderWidth;
  final Color borderColor;
  final bool showShadow;

  /// Rendert Inhalt eines Dreiecks: Bild oder Rainbow-Initialen
  Widget _buildTriangleContent({
    required String? avatarPath,
    required String profileName,
    required Color profileColor,
    required Alignment alignment,
  }) {
    // Kein Bild-Pfad → Rainbow-Initialen anzeigen
    if (avatarPath == null) {
      return _buildRainbowInitials(profileName, profileColor, alignment);
    }

    // Asset-Pfad → Direkt Image.asset() verwenden
    if (_isAssetPath(avatarPath)) {
      return Image.asset(
        avatarPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          logger.error(
            LogCategory.ui,
            '🔄 ProfileSwitchAvatar: Asset load ERROR',
            data: {'path': avatarPath, 'error': error.toString()},
          );
          return _buildRainbowInitials(profileName, profileColor, alignment);
        },
      );
    }

    // File-Pfad ohne Warten, wenn der Ordner bekannt ist.
    //
    // Dieses Widget sitzt in der Profilleiste, also auf jedem Bildschirm und
    // einmal je Anteil. Der FutureBuilder, der hier stand, löste bei jedem
    // Neuaufbau den Anhang-Ordner neu auf — Plattform-Kanal plus
    // Dateisystem, mal Anzahl der Anteile.
    return ValueListenableBuilder<Directory?>(
      valueListenable: AttachmentHelper.directory,
      builder: (context, _, __) {
        final datei = AttachmentHelper.fileSync(avatarPath);
        if (datei == null) {
          return _buildRainbowInitials(profileName, profileColor, alignment);
        }
        return _buildFileImage(datei, profileName, profileColor, alignment);
      },
    );
  }

  /// Prüft ob ein Pfad ein Asset-Pfad ist
  static bool _isAssetPath(String? path) {
    if (path == null) return false;
    return path.startsWith('assets/');
  }

  /// Regenbogen-Initialen mit Fallback-Farbe als Hintergrund
  /// Das Bild aus einer Datei, mit demselben Rückfall bei Lesefehlern.
  Widget _buildFileImage(
    File datei,
    String profileName,
    Color profileColor,
    Alignment alignment,
  ) => Image.file(
    datei,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      logger.error(
        LogCategory.ui,
        '🔄 ProfileSwitchAvatar: Image.file() rendering ERROR',
        data: {'filePath': datei.path, 'error': error.toString()},
      );
      return _buildRainbowInitials(profileName, profileColor, alignment);
    },
  );

  Widget _buildRainbowInitials(
    String profileName,
    Color profileColor,
    Alignment alignment,
  ) {
    // UTF-16 safe: Verwende runes um vollständige Zeichen zu bekommen
    final runes = profileName.runes.toList();
    final initial = runes.isEmpty
        ? '?'
        : String.fromCharCode(runes.first).toUpperCase();

    final fontSize = size * 0.45;
    final strokeWidth = math.min(2.0, size * 0.08);

    return Container(
      color: profileColor, // Hintergrund in Profilfarbe
      alignment: alignment, // Positionierung im jeweiligen Dreieck
      padding: EdgeInsets.all(size * 0.1), // Abstand zum Rand
      child: Stack(
        children: [
          // 1. Schwarzer Stroke für Kontrast
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Effektive Breite: width wenn gesetzt, sonst size * 1.5 (3:2 Verhältnis)
    final effectiveWidth = width ?? size * 1.5;

    return Container(
      width: effectiveWidth,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            // FROM Profile (unteres linkes Dreieck)
            ClipPath(
              clipper: DiagonalLeftClipper(),
              child: SizedBox(
                width: effectiveWidth,
                height: size,
                child: _buildTriangleContent(
                  avatarPath: fromAvatarPath,
                  profileName: fromProfileName,
                  profileColor: fromProfileColor,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ),
            // TO Profile (oberes rechtes Dreieck)
            ClipPath(
              clipper: DiagonalRightClipper(),
              child: SizedBox(
                width: effectiveWidth,
                height: size,
                child: _buildTriangleContent(
                  avatarPath: toAvatarPath,
                  profileName: toProfileName,
                  profileColor: toProfileColor,
                  alignment: Alignment.topRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Clipper für linkes Dreieck (FROM Profile)
/// Diagonal von unten-links nach oben-rechts
class DiagonalLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, size.height) // Bottom-left corner
      ..lineTo(size.width, 0) // Top-right corner
      ..lineTo(0, 0) // Top-left corner
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Custom Clipper für rechtes Dreieck (TO Profile)
/// Diagonal von unten-links nach oben-rechts
class DiagonalRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, size.height) // Bottom-left corner
      ..lineTo(size.width, size.height) // Bottom-right corner
      ..lineTo(size.width, 0) // Top-right corner
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
