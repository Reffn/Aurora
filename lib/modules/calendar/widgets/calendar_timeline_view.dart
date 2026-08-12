import 'dart:async';
import 'dart:ui';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/calendar_events.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/calendar/calendar_view_logic.dart';
import 'package:dis_app/modules/calendar/event_detail_screen.dart';
import 'package:dis_app/modules/calendar/event_form_screen.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Ruhige Kalender-Arbeitsflaeche: heute zuerst, danach alle kommenden
/// Termine. Ein beliebiger Tag bleibt ueber die sichtbare Datumsauswahl
/// erreichbar.
class CalendarTimelineView extends StatefulWidget {
  const CalendarTimelineView({super.key});

  @override
  State<CalendarTimelineView> createState() => _CalendarTimelineViewState();
}

class _CalendarTimelineViewState extends State<CalendarTimelineView> {
  final _dataEntry = getIt<DataEntry>();
  final _eventBus = getIt<EventBus>();
  final _buttonAreaKey = GlobalKey();
  final _scrollController = ScrollController();

  StreamSubscription<CalendarEventCreatedEvent>? _createdSub;
  StreamSubscription<CalendarEventUpdatedEvent>? _updatedSub;
  StreamSubscription<CalendarEventDeletedEvent>? _deletedSub;
  Timer? _dayRolloverTimer;
  DateTime? _selectedDay;
  double _buttonAreaHeight = 88;

  @override
  void initState() {
    super.initState();
    _createdSub = _eventBus.on<CalendarEventCreatedEvent>().listen(
      (_) => _refresh(),
    );
    _updatedSub = _eventBus.on<CalendarEventUpdatedEvent>().listen(
      (_) => _refresh(),
    );
    _deletedSub = _eventBus.on<CalendarEventDeletedEvent>().listen(
      (_) => _refresh(),
    );
    _scheduleDayRollover();
    _measureButtonArea();
  }

  @override
  void dispose() {
    _createdSub?.cancel();
    _updatedSub?.cancel();
    _deletedSub?.cancel();
    _dayRolloverTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _scheduleDayRollover() {
    _dayRolloverTimer?.cancel();
    final now = DateTime.now();
    _dayRolloverTimer = Timer(durationUntilNextDay(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleDayRollover();
    });
  }

  void _measureButtonArea() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _buttonAreaKey.currentContext?.findRenderObject();
      if (!mounted || box is! RenderBox || box.size.height <= 0) return;
      if (box.size.height != _buttonAreaHeight) {
        setState(() => _buttonAreaHeight = box.size.height);
      }
    });
  }

  Future<void> _chooseDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedDay = picked);
    if (_scrollController.hasClients) {
      unawaited(
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  Future<void> _createEvent() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EventFormScreen(selectedDate: _selectedDay),
      ),
    );
  }

  void _openEvent(CalendarEvent event) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(eventId: event.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = _dataEntry.getActiveProfile();
    final canCreate =
        profile != null &&
        (profile.isAdmin || profile.hasPermission(Permission.createEvents));
    final accent =
        profile?.preferredColor ?? Theme.of(context).colorScheme.primary;
    final now = DateTime.now();
    final agenda = CalendarAgenda.fromEvents(
      _dataEntry.getCalendarEvents(),
      today: now,
    );
    final selected = _selectedDay;
    final showSelectedDay =
        selected != null && !DateUtils.isSameDay(selected, now);
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            _buttonAreaHeight + bottomPadding + 20,
          ),
          children: [
            if (showSelectedDay)
              _SelectedDayView(
                day: selected,
                events: agenda.eventsOn(selected),
                accentColor: accent,
                onToday: () => setState(() => _selectedDay = null),
                onEventTap: _openEvent,
              )
            else ...[
              _TodayView(
                day: now,
                events: agenda.today,
                accentColor: accent,
                onEventTap: _openEvent,
              ),
              if (agenda.upcoming.isNotEmpty) ...[
                const SizedBox(height: 28),
                _SectionHeading(
                  icon: Icons.upcoming_outlined,
                  label: l10n.calendarUpcomingTitle,
                ),
                const SizedBox(height: 12),
                _UpcomingEvents(
                  events: agenda.upcoming,
                  accentColor: accent,
                  onEventTap: _openEvent,
                ),
              ],
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _chooseDay,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(l10n.calendarChooseDay),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 58),
                foregroundColor: AppColors.paper,
                side: BorderSide(color: accent.withValues(alpha: 0.55)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          key: _buttonAreaKey,
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(28, 27, 31, 0.88),
                  border: Border(
                    top: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.1)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: FilledButton.icon(
                      onPressed: canCreate ? _createEvent : null,
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(l10n.eventCreate),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 62),
                        backgroundColor: accent.withValues(alpha: 0.22),
                        foregroundColor: AppColors.paper,
                        disabledBackgroundColor: Colors.white10,
                        disabledForegroundColor: Colors.white38,
                        side: BorderSide(
                          color: canCreate
                              ? accent.withValues(alpha: 0.75)
                              : Colors.white12,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayView extends StatelessWidget {
  const _TodayView({
    required this.day,
    required this.events,
    required this.accentColor,
    required this.onEventTap,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final Color accentColor;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DayHeading(
          eyebrow: l10n.miscToday,
          day: DateFormat.yMMMMEEEEd(locale).format(day),
          icon: Icons.today_outlined,
          accentColor: accentColor,
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          _EmptyDayMessage(
            message: l10n.calendarNothingPlannedToday,
            accentColor: accentColor,
          )
        else
          _EventList(
            events: events,
            accentColor: accentColor,
            onEventTap: onEventTap,
          ),
      ],
    );
  }
}

class _SelectedDayView extends StatelessWidget {
  const _SelectedDayView({
    required this.day,
    required this.events,
    required this.accentColor,
    required this.onToday,
    required this.onEventTap,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final Color accentColor;
  final VoidCallback onToday;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onToday,
            icon: const Icon(Icons.arrow_back),
            label: Text(l10n.miscToday),
          ),
        ),
        const SizedBox(height: 4),
        _DayHeading(
          day: DateFormat.yMMMMEEEEd(locale).format(day),
          icon: Icons.calendar_month_outlined,
          accentColor: accentColor,
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          _EmptyDayMessage(
            message: l10n.calendarNothingPlannedOnDay,
            accentColor: accentColor,
          )
        else
          _EventList(
            events: events,
            accentColor: accentColor,
            onEventTap: onEventTap,
          ),
      ],
    );
  }
}

class _DayHeading extends StatelessWidget {
  const _DayHeading({
    required this.day,
    required this.icon,
    required this.accentColor,
    this.eyebrow,
  });

  final String day;
  final String? eyebrow;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withValues(alpha: 0.14),
            border: Border.all(color: accentColor.withValues(alpha: 0.55)),
          ),
          child: Icon(icon, color: AppColors.paper, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Text(
                  eyebrow!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.paper,
                  ),
                ),
              Text(
                day,
                style: TextStyle(
                  fontSize: eyebrow == null ? 20 : 15,
                  height: 1.35,
                  color: AppColors.paper.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.paper, size: 26),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.paper,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyDayMessage extends StatelessWidget {
  const _EmptyDayMessage({required this.message, required this.accentColor});

  final String message;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF28272C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available_outlined,
            color: AppColors.paper.withValues(alpha: 0.68),
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 17,
                height: 1.4,
                color: AppColors.paper.withValues(alpha: 0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEvents extends StatelessWidget {
  const _UpcomingEvents({
    required this.events,
    required this.accentColor,
    required this.onEventTap,
  });

  final List<CalendarEvent> events;
  final Color accentColor;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final children = <Widget>[];
    DateTime? previousDay;

    for (final event in events) {
      if (!DateUtils.isSameDay(previousDay, event.startTime)) {
        if (children.isNotEmpty) children.add(const SizedBox(height: 18));
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              DateFormat.MMMMEEEEd(locale).format(event.startTime),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.paper.withValues(alpha: 0.78),
              ),
            ),
          ),
        );
        previousDay = event.startTime;
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CalendarEventTile(
            event: event,
            accentColor: accentColor,
            onTap: () => onEventTap(event),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({
    required this.events,
    required this.accentColor,
    required this.onEventTap,
  });

  final List<CalendarEvent> events;
  final Color accentColor;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < events.length; index++) ...[
          CalendarEventTile(
            event: events[index],
            accentColor: accentColor,
            onTap: () => onEventTap(events[index]),
          ),
          if (index != events.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Ein Termin ist Inhalt, keine Wahlleiste. Die ganze ruhige Karte fuehrt zu
/// Details; Bearbeiten und Loeschen stehen erst dort, wo ihr Ziel klar ist.
class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile({
    required this.event,
    required this.accentColor,
    required this.onTap,
    super.key,
  });

  final CalendarEvent event;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final time = DateFormat.Hm(locale).format(event.startTime);

    return Semantics(
      button: true,
      label: '$time, ${event.title}',
      child: Card(
        margin: EdgeInsets.zero,
        color: const Color(0xFF28272C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: accentColor.withValues(alpha: 0.38)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 84),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.14),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.55),
                      ),
                    ),
                    child: const Icon(
                      Icons.event_outlined,
                      color: AppColors.paper,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: accentColor.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.paper,
                          ),
                        ),
                        if (event.locationName?.trim().isNotEmpty ?? false) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 17,
                                color: AppColors.paper.withValues(alpha: 0.65),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.locationName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.paper.withValues(
                                      alpha: 0.72,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.paper,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
