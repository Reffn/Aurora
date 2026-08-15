import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:dis_app/widgets/medication_avatar.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Timeline Event Symbol - Visuelles Symbol für Events auf Zeitstrahl
///
/// Zeigt Event-Typ-spezifische Icons und Farben
/// Größe passt sich an Zoom-Level an
/// Gesture-Handling erfolgt durch Parent Widget
class TimelineEventSymbol extends StatefulWidget {
  const TimelineEventSymbol({
    required this.event,
    required this.size,
    super.key,
  });

  final TimelineEvent event;
  final double size; // Pixel-Größe des Symbols

  @override
  State<TimelineEventSymbol> createState() => _TimelineEventSymbolState();
}

class _TimelineEventSymbolState extends State<TimelineEventSymbol> {
  late DataEntry _dataEntry;

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();
  }

  @override
  Widget build(BuildContext context) {
    // Spezialfall: Profil-Wechsel mit Avatar
    if (widget.event.type == TimelineEventType.profileSwitch) {
      return _buildProfileSwitchSymbol();
    }

    // Standard: Icon-basierte Symbole
    return _buildIconSymbol();
  }

  /// Zeigt Avatar des Ziel-Profils für Profil-Wechsel
  Widget _buildProfileSwitchSymbol() {
    final toProfileId = widget.event.data?['toProfileId'] as String?;

    // Fallback zu Icon wenn keine Profil-ID
    if (toProfileId == null) {
      logger.warning(
        LogCategory.ui,
        '⚠️ TimelineEventSymbol: Profile switch missing toProfileId',
        data: {'eventId': widget.event.id},
      );
      return _buildIconSymbol();
    }

    try {
      final toProfile = _dataEntry.profilesBox.get(toProfileId);

      // Fallback zu Icon wenn Profil nicht gefunden
      if (toProfile == null) {
        logger.warning(
          LogCategory.ui,
          '⚠️ TimelineEventSymbol: Target profile not found',
          data: {'toProfileId': toProfileId, 'eventId': widget.event.id},
        );
        return _buildIconSymbol();
      }

      // Border-Parameter basierend auf Größe
      final borderWidth = widget.size > 20 ? 2.0 : 1.0;

      // Avatar mit Border in Profilfarbe - ProfileImageWidget handled alles
      return ClipOval(
        child: ProfileImageWidget(
          avatarPath: toProfile.avatarPath,
          size: widget.size,
          profileName: toProfile.name,
          profileColor: toProfile.preferredColor,
          borderColor: toProfile.preferredColor,
          borderWidth: borderWidth,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: widget.size > 20 ? 4 : 2,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    } catch (e) {
      // Fallback zu Icon bei Fehler
      logger.error(
        LogCategory.ui,
        '❌ TimelineEventSymbol: Error loading profile avatar',
        data: {'toProfileId': toProfileId, 'error': e.toString()},
      );
      return _buildIconSymbol();
    }
  }

  /// Icon-basierte Symbole für andere Event-Typen
  Widget _buildIconSymbol() {
    // Medication Events: MedicationAvatar statt Icon
    if (widget.event.type == TimelineEventType.medication) {
      return _buildMedicationSymbol();
    }

    // Andere Events: Icon wie bisher
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getBorderColor(),
          width: widget.size > 20 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: widget.size > 20 ? 4 : 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getIcon(),
          color: _getIconColor(),
          size: widget.size * 0.6, // Icon ist 60% der Container-Größe
        ),
      ),
    );
  }

  /// Medication-spezifisches Symbol (Pillenform)
  Widget _buildMedicationSymbol() {
    final status = widget.event.data?['status'] as String?;
    final medicationName =
        widget.event.data?['medicationName'] as String? ??
        widget.event.title ??
        'Medikament';
    final medicationImagePath =
        widget.event.data?['medicationImagePath'] as String?;

    // MedicationAvatar hat 2:1 ratio (width:height)
    // Verdopple width damit height = widget.size (gleiche Höhe wie Events/Profile)
    return MedicationAvatar(
      imagePath: medicationImagePath,
      name: medicationName,
      width: widget.size * 2, // 2x width für gleiche Höhe wie andere Events
      statusColor: getMedicationStatusColor(status),
      borderWidth: widget.size > 20 ? 2 : 1,
    );
  }

  /// Icon basierend auf Event-Typ
  IconData _getIcon() {
    switch (widget.event.type) {
      case TimelineEventType.profileSwitch:
        return Icons.swap_horiz; // 🔄 Profil-Wechsel

      case TimelineEventType.medication:
        // Unterscheide nach Status
        final status = widget.event.data?['status'] as String?;
        if (status == null) return Icons.medication;

        if (status.contains('taken')) {
          return Icons.check_circle; // ✓ Genommen
        } else if (status.contains('refused')) {
          return Icons.cancel; // ✗ Verweigert
        } else if (status.contains('snoozed')) {
          return Icons.alarm; // ⏰ Verschoben
        } else if (status.contains('skipped')) {
          return Icons.block; // ⊘ Übersprungen
        } else if (status == 'scheduled') {
          return Icons.alarm_on; // 🔔 Geplant
        } else if (status == 'missed') {
          return Icons.warning; // ⚠️ Verpasst
        }
        return Icons.medication; // Default

      case TimelineEventType.calendarEvent:
        // Unterscheide Vergangenheit/Zukunft
        if (widget.event.isFuture) {
          return Icons.notifications_active; // 🔔 Kommendes Event
        }
        return Icons.event; // 📅 Vergangenes Event
    }
  }

  /// Hintergrundfarbe basierend auf Event-Typ
  Color _getBackgroundColor() {
    switch (widget.event.type) {
      case TimelineEventType.profileSwitch:
        // Verwende Profil-Farbe wenn vorhanden
        if (widget.event.color != null) {
          return Color(widget.event.color!).withValues(alpha: 0.3);
        }
        return Colors.purple.withValues(alpha: 0.3);

      case TimelineEventType.medication:
        final status = widget.event.data?['status'] as String?;
        if (status == null) return Colors.blue.withValues(alpha: 0.3);

        if (status.contains('taken')) {
          return Colors.green.withValues(alpha: 0.3); // Grün für genommen
        } else if (status.contains('refused')) {
          return Colors.red.withValues(alpha: 0.3); // Rot für verweigert
        } else if (status.contains('snoozed')) {
          return Colors.orange.withValues(alpha: 0.3); // Orange für verschoben
        } else if (status.contains('skipped')) {
          return Colors.grey.withValues(alpha: 0.3); // Grau für übersprungen
        } else if (status == 'scheduled') {
          return Colors.blue.withValues(alpha: 0.3); // Blau für geplant
        } else if (status == 'missed') {
          return Colors.red.withValues(alpha: 0.3); // Rot für verpasst
        }
        return Colors.blue.withValues(alpha: 0.3);

      case TimelineEventType.calendarEvent:
        if (widget.event.isFuture) {
          return Colors.green.withValues(alpha: 0.3); // Grün für kommend
        }
        return Colors.blue.withValues(alpha: 0.3); // Blau für vergangen
    }
  }

  /// Border-Farbe (intensiver als Background)
  Color _getBorderColor() {
    switch (widget.event.type) {
      case TimelineEventType.profileSwitch:
        if (widget.event.color != null) {
          return Color(widget.event.color!);
        }
        return Colors.purple;

      case TimelineEventType.medication:
        final status = widget.event.data?['status'] as String?;
        if (status == null) return Colors.blue;

        if (status.contains('taken')) {
          return Colors.green;
        } else if (status.contains('refused')) {
          return Colors.red;
        } else if (status.contains('snoozed')) {
          return Colors.orange;
        } else if (status.contains('skipped')) {
          return Colors.grey;
        } else if (status == 'scheduled') {
          return Colors.blue;
        } else if (status == 'missed') {
          return Colors.red;
        }
        return Colors.blue;

      case TimelineEventType.calendarEvent:
        if (widget.event.isFuture) {
          return Colors.green;
        }
        return Colors.blue;
    }
  }

  /// Icon-Farbe (kontrastreich für Lesbarkeit)
  Color _getIconColor() {
    switch (widget.event.type) {
      case TimelineEventType.profileSwitch:
        return Colors.white;

      case TimelineEventType.medication:
        final status = widget.event.data?['status'] as String?;
        if (status == null) return Colors.white;

        if (status.contains('taken')) {
          return Colors.white;
        } else if (status.contains('refused')) {
          return Colors.white;
        } else if (status.contains('snoozed')) {
          return Colors.white;
        } else if (status.contains('skipped')) {
          return Colors.white;
        }
        return Colors.white;

      case TimelineEventType.calendarEvent:
        return Colors.white;
    }
  }
}

/// Timeline Event Cluster - Zeigt mehrere Events an einem Punkt
///
/// Bei vielen Events zur gleichen Zeit → Badge mit Anzahl
class TimelineEventCluster extends StatelessWidget {
  const TimelineEventCluster({
    required this.events,
    required this.size,
    this.onTap,
    super.key,
  });

  final List<TimelineEvent> events;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    if (events.length == 1) {
      // Single Event: Wrap in GestureDetector für onTap
      return GestureDetector(
        onTap: onTap,
        child: TimelineEventSymbol(
          event: events.first,
          size: size,
        ),
      );
    }

    // Cluster: Zeige Primary Event + Badge mit Anzahl
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Primary Event (erstes in Liste)
          TimelineEventSymbol(
            event: events.first,
            size: size,
          ),

          // Badge mit Anzahl (rechts oben)
          Positioned(
            right: -size * 0.2,
            top: -size * 0.2,
            child: Container(
              padding: EdgeInsets.all(size * 0.15),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: size > 20 ? 2 : 1,
                ),
              ),
              child: Text(
                '${events.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeline Event Label - Zeigt Titel/Beschreibung unter Symbol
///
/// Optional für größere Zoom-Levels
class TimelineEventLabel extends StatelessWidget {
  const TimelineEventLabel({
    required this.event,
    this.maxWidth = 100,
    super.key,
  });

  final TimelineEvent event;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.title != null)
            Text(
              event.title!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (event.description != null)
            Text(
              event.description!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}
