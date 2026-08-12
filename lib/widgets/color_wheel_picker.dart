import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom Color Wheel Picker mit Pixel-Sampling
/// Verwendet ein Farbrad-Bild und extrahiert die Farbe an der Tap-Position
/// Callback gibt Farbe UND normalisierte Position (0.0-1.0) zurück
class ColorWheelPicker extends StatefulWidget {
  const ColorWheelPicker({
    required this.onColorChanged,
    required this.initialColor,
    super.key,
    this.size = 300,
  });

  final void Function(Color color, Offset normalizedPosition) onColorChanged;
  final Color initialColor;
  final double size;

  @override
  State<ColorWheelPicker> createState() => _ColorWheelPickerState();
}

class _ColorWheelPickerState extends State<ColorWheelPicker> {
  ui.Image? _wheelImage;
  ByteData? _imageBytes;
  Offset? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// Lädt das Farbrad-Bild und extrahiert Pixel-Daten
  Future<void> _loadImage() async {
    final data = await rootBundle.load(
      'assets/images/Color-wheel-light-color-spectrum.webp',
    );
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData();

    if (mounted) {
      setState(() {
        _wheelImage = image;
        _imageBytes = byteData;
      });
    }
  }

  /// Extrahiert Farbe an gegebener Position im Bild
  Color? _getColorAtPosition(Offset localPosition) {
    if (_wheelImage == null || _imageBytes == null) return null;

    final imageWidth = _wheelImage!.width;
    final imageHeight = _wheelImage!.height;

    // Konvertiere Widget-Koordinaten zu Bild-Koordinaten
    final x = (localPosition.dx / widget.size * imageWidth).round();
    final y = (localPosition.dy / widget.size * imageHeight).round();

    // Bounds-Check
    if (x < 0 || x >= imageWidth || y < 0 || y >= imageHeight) {
      return null;
    }

    // Pixel-Index berechnen (4 Bytes pro Pixel: RGBA)
    final pixelIndex = (y * imageWidth + x) * 4;

    final buffer = _imageBytes!.buffer.asUint8List();
    if (pixelIndex + 3 >= buffer.length) return null;

    final r = buffer[pixelIndex];
    final g = buffer[pixelIndex + 1];
    final b = buffer[pixelIndex + 2];
    final a = buffer[pixelIndex + 3];

    // Ignoriere transparente/schwarze Pixel (außerhalb des Farbrades)
    if (a < 128) return null; // Zu transparent
    if (r < 10 && g < 10 && b < 10) return null; // Zu dunkel (Hintergrund)

    return Color.fromARGB(255, r, g, b);
  }

  void _handleTap(Offset localPosition) {
    final color = _getColorAtPosition(localPosition);
    if (color != null) {
      setState(() {
        _selectedPosition = localPosition;
      });

      // Berechne normalisierte Position (0.0-1.0)
      final normalizedPosition = Offset(
        localPosition.dx / widget.size,
        localPosition.dy / widget.size,
      );

      widget.onColorChanged(color, normalizedPosition);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _handleTap(details.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    if (_wheelImage == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTapDown: (details) => _handleTap(details.localPosition),
      onPanUpdate: _handlePanUpdate,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          children: [
            // Farbrad-Bild
            Image.asset(
              'assets/images/Color-wheel-light-color-spectrum.webp',
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            ),

            // Ausgewählte Position Marker
            if (_selectedPosition != null)
              Positioned(
                left: _selectedPosition!.dx - 10,
                top: _selectedPosition!.dy - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
