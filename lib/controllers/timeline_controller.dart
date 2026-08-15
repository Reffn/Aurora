import 'dart:async';

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:flutter/material.dart';

/// Timeline Controller - State-Management für Zeitstrahl
///
/// Verwaltet:
/// - Zoom-Level (24h bis 14 Tage)
/// - Scroll-Position
/// - Auto-Update (jede Minute)
/// - Event-Positionierung
class TimelineController extends ChangeNotifier {
  TimelineController({
    this.initialZoomLevel = 1.0,
    this.autoUpdate = true,
  }) {
    _startAutoUpdate();
  }

  // ===== STATE =====

  /// Zoom-Faktor (1.0 = 72h Standard)
  /// 0.5 = 36h (Zoom In)
  /// 2.0 = 144h (Zoom Out)
  double _zoomLevel = 1.0;
  double get zoomLevel => _zoomLevel;

  final double initialZoomLevel;
  final bool autoUpdate;

  /// Zentraler Zeitpunkt (Default: jetzt)
  /// Updated sich automatisch jede Minute oder durch User-Scroll
  /// Single Source of Truth für Timeline-Position
  DateTime _centerTime = DateTime.now();
  DateTime get centerTime => _centerTime;

  /// Zeitfenster (abhängig von Zoom-Level)
  Duration get timeWindow {
    const baseWindow = Duration(hours: 72); // 3 Tage Standard
    final hours = (baseWindow.inHours / _zoomLevel).round();
    return Duration(hours: hours);
  }

  /// Pixel pro Stunde (für Event-Positionierung)
  double getPixelsPerHour(double screenWidth) {
    return screenWidth / timeWindow.inHours;
  }

  Timer? _updateTimer;

  // ===== ZOOM =====

  /// Setzt Zoom-Level
  ///
  /// level: 1.0 (72h) bis 24.0 (3h)
  void setZoom(double level) {
    final oldZoom = _zoomLevel;
    _zoomLevel = level.clamp(1.0, 24.0);

    logger.debug(
      LogCategory.service,
      'Timeline Zoom Changed',
      data: {
        'oldZoom': oldZoom,
        'requestedLevel': level,
        'newZoom': _zoomLevel,
        'clamped': level != _zoomLevel,
        'timeWindowHours': timeWindow.inHours,
      },
    );

    notifyListeners();
  }

  /// Zoom In (näher ran)
  void zoomIn() {
    setZoom(_zoomLevel * 0.8); // 20% näher
  }

  /// Zoom Out (weiter weg)
  void zoomOut() {
    setZoom(_zoomLevel * 1.25); // 25% weiter
  }

  /// Reset zu Standard-Zoom (72h)
  void resetZoom() {
    setZoom(1.0);
  }

  // ===== SCROLL =====

  /// Scrollt Timeline (horizontal)
  ///
  /// Konvertiert Pixel-Delta direkt zu Zeit-Offset
  /// delta: Pixel-Offset (positiv = rechts/Zukunft, negativ = links/Vergangenheit)
  /// screenWidth: Benötigt für Pixel→Time Konvertierung
  void scroll(double pixelDelta, double screenWidth) {
    final pixelsPerHour = getPixelsPerHour(screenWidth);
    final hoursDelta = pixelDelta / pixelsPerHour;

    // Rechts-Scroll (positiv) = Vergangenheit sehen = centerTime zurück
    _centerTime = _centerTime.subtract(
      Duration(minutes: (hoursDelta * 60).round()),
    );

    notifyListeners();
  }

  /// Springt zu einem Zeitpunkt
  void jumpToTime(DateTime time) {
    _centerTime = time;
    notifyListeners();
  }

  /// Springt zurück zu "Jetzt"
  void jumpToNow() {
    jumpToTime(DateTime.now());
  }

  /// Ist Timeline weit von "Jetzt" entfernt gescrollt?
  bool get isScrolledAwayFromNow {
    final now = DateTime.now();
    final diff = _centerTime.difference(now).abs();
    return diff.inMinutes > 30; // >30 Minuten entfernt
  }

  // ===== AUTO-UPDATE =====

  /// Startet Auto-Update Timer
  ///
  /// Updated centerTime jede Minute, wenn nahe bei "Jetzt"
  void _startAutoUpdate() {
    if (!autoUpdate) return;

    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final now = DateTime.now();
      final diff = _centerTime.difference(now).abs();

      // Nur updaten wenn nahe bei "Jetzt" (<5 Min entfernt)
      if (diff.inMinutes < 5) {
        _centerTime = now;
        notifyListeners();
      }
    });
  }

  /// Stoppt Auto-Update
  void stopAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // ===== EVENT POSITIONING =====

  /// Berechnet X-Position für Event
  ///
  /// Gibt Pixel-Position relativ zu Screen-Mitte zurück
  /// Nutzt nur centerTime (Single Source of Truth)
  double getEventPosition({
    required DateTime eventTime,
    required double screenWidth,
  }) {
    final centerX = screenWidth / 2;
    final timeDiff = eventTime.difference(_centerTime);
    final hoursFromCenter = timeDiff.inMinutes / 60.0;
    final pixelsPerHour = getPixelsPerHour(screenWidth);

    return centerX + (hoursFromCenter * pixelsPerHour);
  }

  /// Prüft ob Event sichtbar im aktuellen Fenster
  bool isEventVisible({
    required DateTime eventTime,
    required double screenWidth,
  }) {
    final xPos = getEventPosition(
      eventTime: eventTime,
      screenWidth: screenWidth,
    );

    return xPos >= 0 && xPos <= screenWidth;
  }

  /// Holt sichtbare Events (filtert nach Zeitfenster)
  List<TimelineEvent> getVisibleEvents(List<TimelineEvent> allEvents) {
    final halfWindow = Duration(milliseconds: timeWindow.inMilliseconds ~/ 2);
    final start = _centerTime.subtract(halfWindow);
    final end = _centerTime.add(halfWindow);

    return allEvents.where((event) {
      return event.timestamp.isAfter(start) && event.timestamp.isBefore(end);
    }).toList();
  }

  // ===== ZOOM PRESETS =====

  /// Zoom-Level-Konstanten
  static const zoomLevel24h = 0.33; // 24 Stunden
  static const zoomLevel48h = 0.66; // 48 Stunden
  static const zoomLevel72h = 1.0; // 72 Stunden (Standard)
  static const zoomLevel7d = 2.33; // 7 Tage
  static const zoomLevel14d = 4.67; // 14 Tage

  /// Setzt auf Preset
  void setZoomPreset(double preset) {
    setZoom(preset);
  }

  // ===== DISPOSE =====

  @override
  void dispose() {
    stopAutoUpdate();
    super.dispose();
  }
}

/// Zoom-Level Helper
class ZoomLevel {
  const ZoomLevel({
    required this.name,
    required this.factor,
    required this.hours,
  });

  final String name;
  final double factor;
  final int hours;

  static const zoom24h = ZoomLevel(
    name: '24 Stunden',
    factor: TimelineController.zoomLevel24h,
    hours: 24,
  );

  static const zoom48h = ZoomLevel(
    name: '48 Stunden',
    factor: TimelineController.zoomLevel48h,
    hours: 48,
  );

  static const zoom72h = ZoomLevel(
    name: '3 Tage',
    factor: TimelineController.zoomLevel72h,
    hours: 72,
  );

  static const zoom7d = ZoomLevel(
    name: '7 Tage',
    factor: TimelineController.zoomLevel7d,
    hours: 168,
  );

  static const zoom14d = ZoomLevel(
    name: '14 Tage',
    factor: TimelineController.zoomLevel14d,
    hours: 336,
  );

  static const all = [
    zoom24h,
    zoom48h,
    zoom72h,
    zoom7d,
    zoom14d,
  ];
}
