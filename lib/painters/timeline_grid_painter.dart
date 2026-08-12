import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Timeline Grid Painter - CustomPainter für Zeitstrahl-Visualisierung
///
/// Zeichnet:
/// - Horizontale Zeitachse
/// - Stunden/Tages-Raster
/// - "JETZT"-Marker (zentral fixiert)
/// - Zeit-Labels
class TimelineGridPainter extends CustomPainter {
  TimelineGridPainter({
    required this.centerTime,
    required this.timeWindow,
    required this.pixelsPerHour,
    this.showHourLines = true,
    this.showDayLines = true,
    this.showLabels = true,
  });

  final DateTime centerTime; // Jetzt-Zeitpunkt
  final Duration timeWindow; // Sichtbares Zeitfenster (z.B. 72h)
  final double pixelsPerHour; // Pixel pro Stunde (für Zoom)
  final bool showHourLines;
  final bool showDayLines;
  final bool showLabels;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Hintergrund-Gradient
    _drawBackground(canvas, size);

    // 2. Aktuelle Zeit-Anzeige (oben)
    _drawCurrentDateTime(canvas, size);

    // 3. Horizontaler Zeitstrahl
    _drawTimelineBeam(canvas, size);

    // 4. Tages-Marker (dezent)
    _drawTimeGrid(canvas, size);

    // 5. JETZT-Marker (dezent)
    _drawNowMarker(canvas, size);

    // 6. Zeit-Labels (optional)
    if (showLabels) {
      _drawTimeLabels(canvas, size);
    }
  }

  /// Zeichnet Hintergrund-Gradient
  void _drawBackground(Canvas canvas, Size size) {
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, size.height),
      [
        const Color(0xFF1A1A1A), // Dunkel oben
        const Color(0xFF0D0D0D), // Dunkler unten
      ],
    );

    final paint = Paint()..shader = gradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// Zeichnet aktuelle Datum/Zeit-Anzeige (Split-Layout in Gelb)
  void _drawCurrentDateTime(Canvas canvas, Size size) {
    final now = DateTime.now(); // Immer aktuelle Zeit anzeigen
    final centerX = size.width / 2;
    final topY = 6.0; // 6px vom oberen Rand

    // Formatter
    final timeFormatter = DateFormat('HH:mm:ss');
    final weekdayFormatter = DateFormat('EEEE'); // Montag, Dienstag...
    final dateFormatter = DateFormat.yMMMMd(); // 15. November 2025

    final timeString = timeFormatter.format(now);
    final weekdayString = weekdayFormatter.format(now);
    final dateString = dateFormatter.format(now);
    final fullDateString = '$weekdayString $dateString';

    // Style: Gelb wie JETZT-Marker
    final textStyle = TextStyle(
      color: Colors.amber.withValues(alpha: 0.9),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    // LINKS: Uhrzeit (HH:MM:SS)
    final timePainter = TextPainter(
      text: TextSpan(text: timeString, style: textStyle),
      textAlign: TextAlign.left,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    timePainter.paint(
      canvas,
      Offset(8, topY), // 8px vom linken Rand
    );

    // MITTE: Vertikaler Strich/Pfeil
    final separatorPainter = TextPainter(
      text: TextSpan(
        text: '↓',
        style: textStyle.copyWith(fontSize: 14),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    separatorPainter.paint(
      canvas,
      Offset(
        centerX - separatorPainter.width / 2,
        topY - 2, // Leicht höher wegen Pfeil-Symbol
      ),
    );

    // RECHTS: Datum (Wochentag TT. Monat YYYY)
    final datePainter = TextPainter(
      text: TextSpan(text: fullDateString, style: textStyle),
      textAlign: TextAlign.right,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    datePainter.paint(
      canvas,
      Offset(
        size.width - datePainter.width - 8, // 8px vom rechten Rand
        topY,
      ),
    );
  }

  /// Zeichnet horizontalen Zeitstrahl
  void _drawTimelineBeam(Canvas canvas, Size size) {
    final beamY = size.height / 2; // Mittig horizontal

    // Hauptstrahl (durchgehende Linie)
    final beamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, beamY),
      Offset(size.width, beamY),
      beamPaint,
    );
  }

  /// Zeichnet Zeitraster (nur noch dezente Tages-Marker)
  void _drawTimeGrid(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Berechne Start- und End-Zeit des sichtbaren Fensters
    final halfWindow = Duration(milliseconds: timeWindow.inMilliseconds ~/ 2);
    final startTime = centerTime.subtract(halfWindow);
    final endTime = centerTime.add(halfWindow);

    // NUR Tages-Marker zeichnen (keine Stunden-Linien mehr!)
    if (showDayLines) {
      _drawDayMarkers(canvas, size, startTime, endTime, centerX);
    }
  }

  /// Zeichnet dezente Tages-Marker (statt große Striche)
  void _drawDayMarkers(
    Canvas canvas,
    Size size,
    DateTime startTime,
    DateTime endTime,
    double centerX,
  ) {
    final beamY = size.height / 2; // Mittig (wo der Strahl ist)

    // Start bei Mitternacht des ersten Tages
    var currentDay = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
    );

    while (currentDay.isBefore(endTime)) {
      final xPos = _getXPositionForTime(currentDay, centerX);

      if (xPos >= 0 && xPos <= size.width) {
        // Dezente vertikale Linie (dünn, transparent)
        final linePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..strokeWidth = 1;

        canvas.drawLine(
          Offset(xPos, beamY - 20), // 20px über Strahl
          Offset(xPos, beamY + 20), // 20px unter Strahl
          linePaint,
        );

        // Kleines Tages-Label über der Linie
        _drawDayLabel(canvas, currentDay, xPos, size);
      }

      currentDay = currentDay.add(const Duration(days: 1));
    }
  }

  /// Zeichnet dezentes Tages-Label (nur Wochentag-Kürzel)
  void _drawDayLabel(Canvas canvas, DateTime day, double xPos, Size size) {
    final beamY = size.height / 2;
    final weekdayFormatter = DateFormat('EEE'); // Mo, Di, Mi...
    final weekday = weekdayFormatter.format(day);

    // Dezentes Label unter dem Strahl
    final textPainter = TextPainter(
      text: TextSpan(
        text: weekday,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        xPos - textPainter.width / 2,
        beamY + 25, // 25px unter dem Strahl
      ),
    );
  }

  /// Zeichnet dezenten JETZT-Marker (nur Linie, keine Box)
  void _drawNowMarker(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final beamY = size.height / 2;

    // Dünne vertikale Linie (amber/gelb)
    final linePaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX, beamY - 25), // 25px über Strahl
      Offset(centerX, beamY + 25), // 25px unter Strahl
      linePaint,
    );

    // Kleines "↓" Label über dem Strahl
    final textPainter = TextPainter(
      text: TextSpan(
        text: '↓',
        style: TextStyle(
          color: Colors.amber.withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        beamY - 35, // 35px über Strahl
      ),
    );
  }

  /// Zeichnet 9 fixe Zeit-Labels mit zoom-adaptiven Abständen
  void _drawTimeLabels(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Berechne Abstand zwischen Labels (8 Intervalle für 9 Labels)
    final labelInterval = Duration(
      milliseconds: timeWindow.inMilliseconds ~/ 8,
    );

    // Wähle Format basierend auf Zoom-Level
    late DateFormat timeFormatter;
    if (timeWindow.inHours > 48) {
      timeFormatter = DateFormat('HH'); // Nur Stunde: "06", "15"
    } else {
      timeFormatter = DateFormat('HH:mm'); // Stunde:Minute: "06:30"
    }

    // Start bei Label #1 (4 Labels links vom Zentrum)
    final startTime = centerTime.subtract(
      Duration(milliseconds: labelInterval.inMilliseconds * 4),
    );

    // Zeichne 9 Labels
    for (var i = 0; i < 9; i++) {
      final labelTime = startTime.add(
        Duration(milliseconds: labelInterval.inMilliseconds * i),
      );

      final xPos = _getXPositionForTime(labelTime, centerX);

      // Nur Labels zeichnen die sichtbar sind
      if (xPos >= 20 && xPos <= size.width - 20) {
        final timeString = timeFormatter.format(labelTime);

        // Label #5 (Zentrum) hervorheben
        final isCenter = i == 4;

        final textPainter = TextPainter(
          text: TextSpan(
            text: timeString,
            style: TextStyle(
              color: isCenter
                  ? Colors.amber.withValues(alpha: 0.9) // Gelb wie JETZT-Marker
                  : Colors.white.withValues(alpha: 0.6),
              fontSize: isCenter ? 11 : 10,
              fontWeight: isCenter ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: ui.TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            xPos - textPainter.width / 2,
            size.height * 0.72, // Unten auf Timeline
          ),
        );
      }
    }
  }

  /// Berechnet X-Position für einen Zeitpunkt
  ///
  /// centerX = Position des "JETZT"-Markers
  /// Zeitpunkte links davon = Vergangenheit (negativ)
  /// Zeitpunkte rechts davon = Zukunft (positiv)
  double _getXPositionForTime(DateTime time, double centerX) {
    final timeDiff = time.difference(centerTime);
    final hoursFromCenter = timeDiff.inMinutes / 60.0;

    return centerX + (hoursFromCenter * pixelsPerHour);
  }

  @override
  bool shouldRepaint(TimelineGridPainter oldDelegate) {
    return oldDelegate.centerTime != centerTime ||
        oldDelegate.timeWindow != timeWindow ||
        oldDelegate.pixelsPerHour != pixelsPerHour ||
        oldDelegate.showHourLines != showHourLines ||
        oldDelegate.showDayLines != showDayLines ||
        oldDelegate.showLabels != showLabels;
  }
}
