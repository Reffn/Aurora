import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/calendar/event_form_screen.dart';
import 'package:dis_app/widgets/comments/comment_section.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/// Event Detail Screen - Zeigt Event-Details mit Kommentaren
class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _dataEntry = getIt<DataEntry>();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder(
      valueListenable: _dataEntry.calendarEventsBox.listenable(),
      builder: (context, box, _) {
        final event = _dataEntry.getEventById(widget.eventId);

        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.eventNotFound)),
            body: Center(child: Text(l10n.eventNotFoundMessage)),
          );
        }

        final canEdit = _canEdit(event);
        final canDelete = _canDelete(event);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.eventDetailTitle),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
          ),
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _EventDetailCard(event: event),
              if (canEdit || canDelete) ...[
                const SizedBox(height: 16),
                _buildActions(event, canEdit: canEdit, canDelete: canDelete),
              ],
              const SizedBox(height: 24),
              CommentSection(
                type: CommentableType.calendar,
                parentId: event.id,
                permission: Permission.commentOnCalendarEvents,
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canEdit(CalendarEvent event) {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return false;

    return activeProfile.isAdmin ||
        activeProfile.hasPermission(Permission.editAllEvents) ||
        event.profileIds.contains(activeProfile.id);
  }

  bool _canDelete(CalendarEvent event) {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return false;

    return activeProfile.isAdmin ||
        activeProfile.hasPermission(Permission.deleteAllEvents) ||
        (activeProfile.hasPermission(Permission.deleteOwnEvents) &&
            event.profileIds.contains(activeProfile.id));
  }

  Widget _buildActions(
    CalendarEvent event, {
    required bool canEdit,
    required bool canDelete,
  }) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (canEdit)
          FilledButton.tonalIcon(
            onPressed: () => _editEvent(event),
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.actionEdit),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 58),
            ),
          ),
        if (canEdit && canDelete) const SizedBox(height: 8),
        if (canDelete)
          TextButton.icon(
            onPressed: _deleteEvent,
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.actionDelete),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    );
  }

  void _editEvent(CalendarEvent event) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EventFormScreen(existingEvent: event),
      ),
    );
  }

  Future<void> _deleteEvent() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: l10n.eventDeleteTitle,
      message: l10n.eventDeleteConfirmMessage,
      actionText: l10n.actionDelete,
    );

    if (confirmed) {
      await _dataEntry.deleteCalendarEvent(widget.eventId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.eventDeleted)));
      }
    }
  }
}

/// Event Detail Card - Zeigt Event-Info
class _EventDetailCard extends StatelessWidget {
  const _EventDetailCard({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.yMMMMEEEEd(locale);
    final timeFormat = DateFormat.Hm(locale);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titel
            Text(
              event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Start-Zeit
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(event.startTime)} • ${timeFormat.format(event.startTime)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // End-Zeit
            Row(
              children: [
                const Icon(Icons.access_time_filled, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(event.endTime)} • ${timeFormat.format(event.endTime)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            // Ort — für einen Termin außer Haus die eine Angabe, die vor Ort
            // zählt. Sie stand bisher nur im Formular; wer den Termin ansah,
            // erfuhr Zeit und Titel, aber nicht, wohin er muss.
            if (event.locationName != null &&
                event.locationName!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.locationName!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
            if (event.latitude != null && event.longitude != null) ...[
              const SizedBox(height: 12),
              OverviewMap(
                height: 180,
                showUserLocation: false,
                initialCenter: LatLng(event.latitude!, event.longitude!),
                initialZoom: 15,
                customMarkers: [
                  Marker(
                    point: LatLng(event.latitude!, event.longitude!),
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.place,
                      size: 44,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
            ],

            // Kategorie
            if (event.category != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  event.category!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            // Beschreibung
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.commonDescription,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],

            // Notizen
            if (event.notes != null && event.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.commonNotes,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],

            // Erinnerung
            if (event.notificationEnabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.notifications_active, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.eventReminderBefore(event.reminderMinutesBefore ?? 0),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
