import 'dart:async';
import 'dart:math' as math;

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/widgets/color_wheel_picker.dart';
import 'package:flutter/material.dart';

/// Color Picker mit Markierungen für bereits verwendete Farben
/// und Kollisionserkennung um zu ähnliche Farben zu verhindern
class UserMarkedColorPicker extends StatefulWidget {
  // Mindestabstand zwischen Farben

  const UserMarkedColorPicker({
    required this.initialColor,
    required this.existingProfiles,
    required this.onColorChanged,
    super.key,
    this.currentProfileId,
    this.collisionRadius = 20.0, // Standard: 20px Radius
  });
  final Color initialColor;
  final List<Profile> existingProfiles;
  final String? currentProfileId; // Falls Profil bearbeitet wird
  final void Function(Color color, Offset normalizedPosition) onColorChanged;
  final double collisionRadius;

  @override
  State<UserMarkedColorPicker> createState() => _UserMarkedColorPickerState();
}

class _UserMarkedColorPickerState extends State<UserMarkedColorPicker> {
  late Color _currentColor;
  String? _collisionWarning;
  Timer? _debounceTimer;
  Timer? _throttleTimer;
  Color? _pendingColor;
  Offset? _pendingNormalizedPosition;

  // Throttle-Dauer: ~30fps für flüssige Updates ohne Performance-Probleme
  static const _throttleDuration = Duration(milliseconds: 33);

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
    super.dispose();
  }

  /// Prüft ob die gewählte Position mit einer bereits verwendeten kollidiert
  /// Verwendet direkte 2D-Positions-Distanz statt Farb-Ähnlichkeit
  Profile? _checkCollision(Offset normalizedPosition) {
    // Ignoriere das eigene Profil bei der Bearbeitung
    final profilestoCheck = widget.existingProfiles
        .where((p) => p.id != widget.currentProfileId)
        .toList();

    // Picker-Größe für Berechnungen
    const pickerSize = 300.0;

    // Konvertiere normalisierte Position zu Pixel-Koordinaten
    final newPosition = Offset(
      normalizedPosition.dx * pickerSize,
      normalizedPosition.dy * pickerSize,
    );

    for (final profile in profilestoCheck) {
      // Hole gespeicherte normalisierte Position
      final profileNormalized = profile.colorPickerPositionNormalized;
      if (profileNormalized == null)
        continue; // Überspringe alte Profile ohne Position

      // Konvertiere zu Pixel-Koordinaten
      final profilePosition = Offset(
        profileNormalized.dx * pickerSize,
        profileNormalized.dy * pickerSize,
      );

      // Berechne 2D-Distanz
      final distance = math.sqrt(
        math.pow(newPosition.dx - profilePosition.dx, 2) +
            math.pow(newPosition.dy - profilePosition.dy, 2),
      );

      // Kollision wenn Distanz kleiner als 2x Radius
      if (distance < (widget.collisionRadius * 2)) {
        return profile; // Kollision mit diesem Profil
      }
    }

    return null; // Keine Kollision
  }

  void _handleColorChange(Color color, Offset normalizedPosition) {
    // Speichere wartende Farbe und Position
    _pendingColor = color;
    _pendingNormalizedPosition = normalizedPosition;

    // Throttle: Wenn bereits ein Update läuft, warte
    if (_throttleTimer?.isActive ?? false) return;

    // Starte Throttle-Timer: Update alle 33ms (~30fps)
    _throttleTimer = Timer(_throttleDuration, () {
      if (!mounted ||
          _pendingColor == null ||
          _pendingNormalizedPosition == null)
        return;

      final colorToUpdate = _pendingColor!;
      final positionToUpdate = _pendingNormalizedPosition!;

      // DEBUG: Log throttled color changes
      final hsv = HSVColor.fromColor(colorToUpdate);
      logger.info(
        LogCategory.ui,
        'ColorPicker: Color changed (throttled)',
        data: {
          'hue': hsv.hue.toStringAsFixed(1),
          'saturation': hsv.saturation.toStringAsFixed(3),
          'value': hsv.value.toStringAsFixed(3),
          'hex':
              '#${colorToUpdate.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
          'normalized_x': positionToUpdate.dx.toStringAsFixed(3),
          'normalized_y': positionToUpdate.dy.toStringAsFixed(3),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Visuelles Update
      setState(() {
        _currentColor = colorToUpdate;
      });

      // Callback ans Parent mit Farbe und Position
      widget.onColorChanged(colorToUpdate, positionToUpdate);

      // Debounced Kollisionsprüfung (Position-basiert)
      _performDebouncedCollisionCheck(positionToUpdate);
    });
  }

  /// Prüft Positionskollisionen mit Debouncing (wartet bis User aufhört)
  void _performDebouncedCollisionCheck(Offset normalizedPosition) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;

      final collidingProfile = _checkCollision(normalizedPosition);
      setState(() {
        if (collidingProfile != null) {
          _collisionWarning = "Zu ähnlich zu ${collidingProfile.name}'s Farbe";
        } else {
          _collisionWarning = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtere eigenes Profil bei Bearbeitung
    final displayProfiles = widget.existingProfiles
        .where((p) => p.id != widget.currentProfileId)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color Wheel Picker mit Overlay
        Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              children: [
                // Custom Color Wheel Picker
                ColorWheelPicker(
                  initialColor: _currentColor,
                  onColorChanged: _handleColorChange,
                ),

                // Overlay mit Benutzer-Markierungen
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _UserMarkersPainter(
                        profiles: displayProfiles,
                        markerRadius: widget.collisionRadius,
                        pickerSize: 300, // Feste Größe des ColorWheelPicker
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Kompakte Farb-Preview
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '#${_currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        // Kollisions-Warnung (kompakt)
        if (_collisionWarning != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[700],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _collisionWarning!,
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// CustomPainter für Benutzer-Markierungen auf dem Color Wheel
/// Verwendet gespeicherte normalisierte Positionen statt Farb-Berechnung
class _UserMarkersPainter extends CustomPainter {
  _UserMarkersPainter({
    required this.profiles,
    required this.markerRadius,
    required this.pickerSize,
  });

  final List<Profile> profiles;
  final double markerRadius;
  final double pickerSize;

  /// De-normalisiert gespeicherte Position (0.0-1.0) zu tatsächlichen Pixel-Koordinaten
  Offset? _denormalizePosition(Profile profile) {
    final normalizedPos = profile.colorPickerPositionNormalized;
    if (normalizedPos == null) return null;

    return Offset(
      normalizedPos.dx * pickerSize,
      normalizedPos.dy * pickerSize,
    );
  }

  /// Extrahiert Initialen aus einem Namen (1-2 Buchstaben)
  /// UTF-16 safe: Verwendet runes statt substring für Emoji-Support
  String _getInitials(String name) {
    final trimmedName = name.trim();
    final runes = trimmedName.runes.toList();
    final parts = trimmedName.split(' ');

    // Zwei Wörter: Erste Buchstaben von jedem
    if (parts.length >= 2) {
      final part1Runes = parts[0].runes.toList();
      final part2Runes = parts[1].runes.toList();
      if (part1Runes.isNotEmpty && part2Runes.isNotEmpty) {
        return '${String.fromCharCode(part1Runes.first)}${String.fromCharCode(part2Runes.first)}'
            .toUpperCase();
      }
    }

    // Ein Wort: Erste zwei Zeichen
    if (runes.length >= 2) {
      return '${String.fromCharCode(runes[0])}${String.fromCharCode(runes[1])}'
          .toUpperCase();
    } else if (runes.length == 1) {
      return String.fromCharCode(runes[0]).toUpperCase();
    }

    return '?';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (final profile in profiles) {
      // Verwende gespeicherte Position (de-normalisiert)
      final position = _denormalizePosition(profile);
      if (position == null)
        continue; // Überspringe Profile ohne Position (alte Daten)

      // Überspringe Markierungen außerhalb des Farbrad-Radius
      final distanceFromCenter = math.sqrt(
        math.pow(position.dx - center.dx, 2) +
            math.pow(position.dy - center.dy, 2),
      );
      if (distanceFromCenter > radius) continue;

      // Feste Marker-Größe und Opacity (keine dynamische Skalierung mehr)
      final opacity = 0.85;

      // Äußerer Kreis (weiß mit Schatten)
      canvas.drawCircle(
        position,
        markerRadius,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Innerer Kreis (Profilfarbe mit Border)
      canvas.drawCircle(
        position,
        markerRadius - 2,
        Paint()
          ..color = profile.preferredColor.withValues(alpha: opacity)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        position,
        markerRadius - 2,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Initialen zeichnen (immer anzeigen)
      final initials = _getInitials(profile.name);
      final textPainter = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            color: _getContrastColor(
              profile.preferredColor,
            ).withValues(alpha: opacity),
            fontSize: markerRadius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Zentriere Text im Kreis
      final offset = Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  /// Berechnet Kontrastfarbe (weiß oder schwarz) für Text auf farbigem Hintergrund
  Color _getContrastColor(Color background) {
    // Berechne Relative Luminanz
    final r = (background.r * 255.0).round() & 0xff;
    final g = (background.g * 255.0).round() & 0xff;
    final b = (background.b * 255.0).round() & 0xff;
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(_UserMarkersPainter oldDelegate) {
    return oldDelegate.profiles != profiles ||
        oldDelegate.markerRadius != markerRadius ||
        oldDelegate.pickerSize != pickerSize;
  }
}
