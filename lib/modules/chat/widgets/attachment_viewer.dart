import 'dart:io';

import 'package:flutter/material.dart';

/// Zeigt ein Bild oder Doodle aus dem Chat formatfüllend an.
///
/// In der Bubble ist ein Anhang höchstens etwa ein Viertel der Bildschirmbreite
/// breit. Für alle, die nicht über Text kommunizieren, ist das Gezeichnete aber
/// die ganze Nachricht — und in Briefmarkengröße nicht zu erkennen. Antippen
/// öffnet es hier groß und zoombar.
///
/// Bedienbar ohne ein Wort zu lesen: Tippen daneben schließt, das Kreuz oben
/// schließt, Wischen nach unten schließt.
class AttachmentViewer extends StatelessWidget {
  const AttachmentViewer({required this.file, super.key});

  final File file;

  /// Öffnet den Betrachter über dem Chat.
  static Future<void> show(BuildContext context, File file) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, _, _) => AttachmentViewer(file: file),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Tippen neben das Bild schließt.
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              // Wischen nach unten schließt ebenfalls — die Geste, die auf
              // Telefonen überall „weg damit" bedeutet.
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 300) {
                  Navigator.of(context).pop();
                }
              },
              behavior: HitTestBehavior.opaque,
            ),
          ),

          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.file(
                file,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_outlined,
                  size: 96,
                  color: Colors.white54,
                ),
              ),
            ),
          ),

          // Schließen-Kreuz, groß genug für ungenaue Motorik.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
