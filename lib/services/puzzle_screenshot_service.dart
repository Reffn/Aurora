import 'dart:io';
import 'dart:ui' as ui;

import 'package:dis_app/models/puzzle_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service für Puzzle-Screenshot und Social Sharing
class PuzzleScreenshotService {
  /// Google Play Store Link der App
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.disapp.dis_app';

  /// Erstellt einen Screenshot vom gelösten Puzzle und teilt ihn
  Future<void> shareCompletedPuzzle({
    required GlobalKey screenshotKey,
    required PuzzleConfig config,
    required int moveCount,
  }) async {
    try {
      // Screenshot erstellen
      final imageFile = await _captureScreenshot(screenshotKey);

      if (imageFile == null) {
        throw Exception('Screenshot konnte nicht erstellt werden');
      }

      // Share-Text generieren
      final shareText = _generateShareText(config, moveCount);

      // Teilen mit nativen Share-Sheet
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: shareText,
      );
    } catch (e) {
      throw Exception('Fehler beim Teilen: $e');
    }
  }

  /// Erstellt Screenshot vom Widget
  Future<File?> _captureScreenshot(GlobalKey screenshotKey) async {
    try {
      final boundary =
          screenshotKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;

      // Screenshot als Bild erstellen
      final image = await boundary.toImage(pixelRatio: 2);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();

      // Temporäre Datei im Cache erstellen
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/puzzle_$timestamp.png');

      // Datei schreiben
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      return null;
    }
  }

  /// Generiert Share-Text für soziale Medien
  String _generateShareText(PuzzleConfig config, int moveCount) {
    final puzzleTypeEmoji = config.type == PuzzleType.jigsaw ? '🧩' : '🔢';
    final difficultyText = config.difficulty.label.toLowerCase();

    return '''
$puzzleTypeEmoji Ich habe gerade ein $difficultyText ${config.type.label} in Aurora gelöst!
✨ $moveCount Züge

Aurora ist eine App zur Unterstützung von Menschen mit Dissoziativer Identitätsstörung (DIS).

📱 Hol dir die App:
$_playStoreUrl
''';
  }

  /// Teilt nur Text (ohne Screenshot)
  Future<void> shareTextOnly({
    required PuzzleConfig config,
    required int moveCount,
  }) async {
    try {
      final shareText = _generateShareText(config, moveCount);
      await Share.share(shareText);
    } catch (e) {
      throw Exception('Fehler beim Teilen: $e');
    }
  }

  /// Überprüft ob Share-Funktion verfügbar ist
  static Future<bool> isShareAvailable() async {
    // Share ist auf allen Plattformen verfügbar
    return true;
  }
}
