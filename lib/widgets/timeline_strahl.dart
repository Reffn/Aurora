import 'dart:async';
import 'dart:math';

import 'package:dis_app/controllers/timeline_controller.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/calendar_events.dart';
import 'package:dis_app/core/events/medication_events.dart';
import 'package:dis_app/core/events/profile_events.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/painters/timeline_grid_painter.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/timeline_event_symbol.dart';
import 'package:flutter/material.dart';

/// Timeline Strahl - Interaktiver Zeitstrahl mit fließender Zeitachse
///
/// Features:
/// - 72h Standard-Fenster (3 Tage)
/// - JETZT-Marker immer zentral
/// - Auto-Update jede Minute (Zeit-Tick)
/// - Reaktiv auf Events (EventBus): Profile, Medikamente, Kalender
/// - Pinch-to-Zoom (24h bis 14 Tage)
/// - Event-Symbole auf Zeitachse
/// - Tap auf Event → Navigation zu Detail
class TimelineStrahl extends StatefulWidget {
  const TimelineStrahl({super.key});

  @override
  State<TimelineStrahl> createState() => _TimelineStrahlState();
}

class _TimelineStrahlState extends State<TimelineStrahl> {
  late TimelineController _controller;
  late TimelineDataService _dataService;
  late EventBus _eventBus;

  // Gesture-Tracking
  double _lastScaleFactor = 1;
  Offset? _lastFocalPoint;

  // Event Overlay
  OverlayEntry? _activeOverlay;

  // EventBus Subscriptions
  StreamSubscription<ActiveProfileChangedEvent>? _profileChangedSub;
  StreamSubscription<MedicationTakenEvent>? _medicationTakenSub;
  StreamSubscription<MedicationLogUpdatedEvent>? _medicationLogUpdatedSub;
  StreamSubscription<MedicationLogDeletedEvent>? _medicationLogDeletedSub;
  StreamSubscription<CalendarEventCreatedEvent>? _calendarCreatedSub;
  StreamSubscription<CalendarEventUpdatedEvent>? _calendarUpdatedSub;
  StreamSubscription<CalendarEventDeletedEvent>? _calendarDeletedSub;

  @override
  void initState() {
    super.initState();

    // Controller initialisieren
    _controller = TimelineController();

    // DataService aus DI
    _dataService = getIt<TimelineDataService>();

    // EventBus aus DI
    _eventBus = getIt<EventBus>();

    logger.debug(
      LogCategory.ui,
      'Timeline Widget Init',
      data: {
        'initialZoomLevel': _controller.zoomLevel,
        'centerTime': _controller.centerTime.toString(),
      },
    );

    // Listen to controller changes
    _controller.addListener(_onControllerUpdate);

    // Subscribe to timeline events
    _subscribeToEvents();

    // Force rebuild after first frame to ensure historical events load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        logger.debug(LogCategory.ui, 'Timeline Post-Frame Rebuild');
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();

    // Cancel EventBus subscriptions
    _profileChangedSub?.cancel();
    _medicationTakenSub?.cancel();
    _medicationLogUpdatedSub?.cancel();
    _medicationLogDeletedSub?.cancel();
    _calendarCreatedSub?.cancel();
    _calendarUpdatedSub?.cancel();
    _calendarDeletedSub?.cancel();

    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {
      // Rebuild wenn Controller sich ändert
    });
  }

  /// Subscribe to EventBus for automatic timeline updates
  void _subscribeToEvents() {
    // Profile Switch Events
    _profileChangedSub = _eventBus.on<ActiveProfileChangedEvent>().listen(
      (_) => _onTimelineEventChanged(),
    );

    // Medication Events
    _medicationTakenSub = _eventBus.on<MedicationTakenEvent>().listen(
      (_) => _onTimelineEventChanged(),
    );

    _medicationLogUpdatedSub = _eventBus.on<MedicationLogUpdatedEvent>().listen(
      (_) => _onTimelineEventChanged(),
    );

    _medicationLogDeletedSub = _eventBus.on<MedicationLogDeletedEvent>().listen(
      (_) => _onTimelineEventChanged(),
    );

    // Calendar Events
    _calendarCreatedSub = _eventBus.on<CalendarEventCreatedEvent>().listen(
      (_) => _onTimelineEventChanged(),
    );

    _calendarUpdatedSub = _eventBus.on<CalendarEventUpdatedEvent>().listen(
      (_) => _onTimelineEventChanged(),
    );

    _calendarDeletedSub = _eventBus.on<CalendarEventDeletedEvent>().listen(
      (_) => _onTimelineEventChanged(),
    );
  }

  /// Called when timeline data changes - triggers rebuild
  void _onTimelineEventChanged() {
    if (mounted) {
      setState(() {
        // Rebuild to load new events
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72, // Gleiche Höhe wie ProfileSwitcherBar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF28272C),
            const Color(0xFF28272C).withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            // ===== OUTER GESTURE DETECTOR (für gesamten Stack) =====
            behavior: HitTestBehavior.translucent,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: (details) =>
                _handleScaleUpdate(details, constraints.maxWidth),
            onScaleEnd: _handleScaleEnd,
            child: Stack(
              children: [
                // Timeline Grid (Hintergrund mit Strahl)
                _buildTimelineGrid(constraints),

                // Events (darüber)
                _buildEvents(constraints),

                // "Zurück zu Jetzt"-Button (falls weit gescrollt)
                if (_controller.isScrolledAwayFromNow) _buildBackToNowButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Baut Timeline Grid (CustomPaint)
  Widget _buildTimelineGrid(BoxConstraints constraints) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: TimelineGridPainter(
        centerTime: _controller.centerTime,
        timeWindow: _controller.timeWindow,
        pixelsPerHour: _controller.getPixelsPerHour(constraints.maxWidth),
        showHourLines: _controller.zoomLevel < 2.0, // Nur bei Zoom In
      ),
    );
  }

  /// Baut Event-Symbole mit Tap-Handling
  Widget _buildEvents(BoxConstraints constraints) {
    // Hole Events aus DataService
    final allEvents = _dataService.getStandardTimelineEvents(
      centerTime: _controller.centerTime,
      timeWindow: _controller.timeWindow,
    );

    // Filtere sichtbare Events
    final visibleEvents = _controller.getVisibleEvents(allEvents);

    logger.debug(
      LogCategory.ui,
      'Timeline Events Render',
      data: {
        'totalEvents': allEvents.length,
        'visibleEvents': visibleEvents.length,
        'screenWidth': constraints.maxWidth,
        'zoomLevel': _controller.zoomLevel,
        'centerTime': _controller.centerTime.toString(),
      },
    );

    return Stack(
      children: visibleEvents.map((event) {
        final xPos = _controller.getEventPosition(
          eventTime: event.timestamp,
          screenWidth: constraints.maxWidth,
        );

        // Event-Größe basierend auf Zoom
        final eventSize = _getEventSize();

        return Positioned(
          left: xPos - eventSize / 2, // Zentriert auf Position
          top: constraints.maxHeight / 2 - eventSize / 2, // Vertikal zentriert
          child: Builder(
            builder: (context) => GestureDetector(
              // Event-Tap: translucent fängt Tap ab, lässt aber Drag/Pinch durch
              behavior: HitTestBehavior.translucent,
              onTap: () => _onEventTap(event, context),
              child: TimelineEventSymbol(
                event: event,
                size: eventSize,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Baut "Zurück zu Jetzt"-Button
  Widget _buildBackToNowButton() {
    return Positioned(
      top: 8,
      right: 60, // Links von Zoom-Controls
      child: ElevatedButton.icon(
        onPressed: _controller.jumpToNow,
        icon: const Icon(Icons.access_time, size: 16),
        label: const Text('Jetzt', style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  // ===== GESTURE HANDLING =====

  void _handleScaleStart(ScaleStartDetails details) {
    _lastScaleFactor = 1.0;
    _lastFocalPoint = details.focalPoint;

    logger.debug(
      LogCategory.ui,
      'Timeline Scale Start',
      data: {
        'pointerCount': details.pointerCount,
        'focalPoint': details.focalPoint.toString(),
      },
    );
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, double screenWidth) {
    // Zoom (Pinch) - Nur bei 2+ Fingern
    if (details.pointerCount >= 2 && details.scale != 1.0) {
      // Scale Factor = Änderung seit letztem Update
      final scaleFactor = details.scale / _lastScaleFactor;
      _lastScaleFactor = details.scale;

      logger.debug(
        LogCategory.ui,
        'Timeline Scale Update',
        data: {
          'scale': details.scale,
          'pointerCount': details.pointerCount,
          'scaleFactor': scaleFactor,
          'scaleFactorAbs': (scaleFactor - 1.0).abs(),
          'currentZoom': _controller.zoomLevel,
        },
      );

      // Schwellwert: Nur bei signifikanter Änderung
      if ((scaleFactor - 1.0).abs() > 0.01) {
        // Pinch In (scaleFactor < 1.0) = Zoom In (größerer zoomLevel)
        // Pinch Out (scaleFactor > 1.0) = Zoom Out (kleinerer zoomLevel)
        // Beschleunigungsfaktor 1.5 für schnelleres Zoomen
        final acceleratedScaleFactor = pow(scaleFactor, 1.5);
        final newZoom = _controller.zoomLevel * acceleratedScaleFactor;
        logger.debug(
          LogCategory.ui,
          'Timeline Zoom Trigger',
          data: {
            'oldZoom': _controller.zoomLevel,
            'scaleFactor': scaleFactor,
            'acceleratedScaleFactor': acceleratedScaleFactor,
            'newZoom': newZoom,
          },
        );
        _controller.setZoom(newZoom);
      }
    } else if (details.pointerCount == 1) {
      // Single-Finger: Update lastScaleFactor für nächsten Pinch
      _lastScaleFactor = details.scale;
    }

    // Scroll (Horizontal Drag)
    if (_lastFocalPoint != null) {
      final delta = details.focalPoint.dx - _lastFocalPoint!.dx;
      if (delta.abs() > 1) {
        _controller.scroll(delta, screenWidth);
        _lastFocalPoint = details.focalPoint;
      }
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _lastScaleFactor = 1.0;
    _lastFocalPoint = null;
  }

  // ===== HELPERS =====

  /// Event-Größe basierend auf Zoom-Level
  double _getEventSize() {
    if (_controller.zoomLevel < 0.5) {
      return 48; // Max Zoom In (+20%)
    } else if (_controller.zoomLevel < 1.0) {
      return 40; // Zoom In (+25%)
    } else if (_controller.zoomLevel < 2.0) {
      return 32; // Standard (+33%)
    } else {
      return 20; // Zoom Out (+25%)
    }
  }

  /// Entfernt aktives Event-Overlay
  void _removeOverlay() {
    _activeOverlay?.remove();
    _activeOverlay = null;
  }

  /// Event-Tap Handler - Zeigt Floating Overlay
  void _onEventTap(TimelineEvent event, BuildContext context) {
    // Entferne vorheriges Overlay falls vorhanden
    _removeOverlay();

    // Finde Position des Event-Symbols
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final eventPosition = renderBox.localToGlobal(Offset.zero);
    final eventSize = renderBox.size;

    // Erstelle Overlay
    _activeOverlay = OverlayEntry(
      builder: (overlayContext) => _EventPreviewOverlay(
        event: event,
        eventPosition: eventPosition,
        eventSize: eventSize,
        onDismiss: _removeOverlay,
      ),
    );

    // Zeige Overlay
    Overlay.of(context).insert(_activeOverlay!);
  }
}

/// Event Preview Overlay - Floating Card über Event-Symbol
class _EventPreviewOverlay extends StatefulWidget {
  const _EventPreviewOverlay({
    required this.event,
    required this.eventPosition,
    required this.eventSize,
    required this.onDismiss,
  });

  final TimelineEvent event;
  final Offset eventPosition;
  final Size eventSize;
  final VoidCallback onDismiss;

  @override
  State<_EventPreviewOverlay> createState() => _EventPreviewOverlayState();
}

class _EventPreviewOverlayState extends State<_EventPreviewOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Berechnet optimale Position (Smart-Positioning)
  Offset _calculatePosition(Size screenSize, Size overlaySize) {
    const double margin = 16;
    const double arrowHeight = 12;

    // Standard: Über dem Event-Symbol
    var left =
        widget.eventPosition.dx -
        (overlaySize.width / 2) +
        (widget.eventSize.width / 2);
    var top =
        widget.eventPosition.dy - overlaySize.height - arrowHeight - margin;

    // Horizontal Bounds Check
    if (left < margin) {
      left = margin;
    } else if (left + overlaySize.width > screenSize.width - margin) {
      left = screenSize.width - overlaySize.width - margin;
    }

    // Vertical Bounds Check (wenn oben kein Platz → unten anzeigen)
    if (top < margin) {
      top =
          widget.eventPosition.dy +
          widget.eventSize.height +
          arrowHeight +
          margin;
    }

    return Offset(left, top);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const overlayWidth = 300.0;
    const overlayMaxHeight = 400.0;

    // Berechne Position
    final position = _calculatePosition(
      screenSize,
      const Size(overlayWidth, overlayMaxHeight),
    );

    return Stack(
      children: [
        // Fullscreen Tap-Barriere (dismiss on tap outside)
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Overlay Card
        Positioned(
          left: position.dx,
          top: position.dy,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: overlayWidth,
                  constraints: const BoxConstraints(
                    maxHeight: overlayMaxHeight,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getEventTypeColor(widget.event.type),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header mit Close-Button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Event-Typ Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getEventTypeColor(widget.event.type),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getEventTypeName(widget.event.type),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Close Button
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.paper,
                                size: 20,
                              ),
                              onPressed: widget.onDismiss,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFF3A3A3A)),

                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titel
                              if (widget.event.title != null)
                                Text(
                                  widget.event.title!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.paper,
                                  ),
                                ),

                              const SizedBox(height: 8),

                              // Beschreibung
                              if (widget.event.description != null)
                                Text(
                                  widget.event.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.paper.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 12),

                              // Zeitpunkt
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppColors.paper,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTimestamp(widget.event.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.paper.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFF3A3A3A)),

                      // Action-Buttons
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: widget.onDismiss,
                              child: Text(AppTexts.current.actionClose),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                widget.onDismiss();
                                // TODO: Navigate to detail screen
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getEventTypeColor(
                                  widget.event.type,
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context).actionDetails,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getEventTypeColor(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.profileSwitch:
        return Colors.purple;
      case TimelineEventType.medication:
        return Colors.blue;
      case TimelineEventType.calendarEvent:
        return Colors.green;
    }
  }

  String _getEventTypeName(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.profileSwitch:
        return 'PROFIL-WECHSEL';
      case TimelineEventType.medication:
        return 'MEDIKAMENT';
      case TimelineEventType.calendarEvent:
        return 'TERMIN';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    final isFuture = diff.isNegative;
    final absDiff = diff.abs();

    final texts = AppTexts.current;
    if (absDiff.inMinutes < 60) {
      return isFuture
          ? texts.timeInMinutes(absDiff.inMinutes)
          : texts.timeMinutesAgo(absDiff.inMinutes);
    } else if (absDiff.inHours < 24) {
      return isFuture
          ? texts.timeInHours(absDiff.inHours)
          : texts.timeHoursAgo(absDiff.inHours);
    } else if (absDiff.inDays < 7) {
      return isFuture
          ? texts.timeInDays(absDiff.inDays)
          : texts.timeDaysAgo(absDiff.inDays);
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
