import 'package:dis_app/modules/calendar/widgets/calendar_timeline_view.dart';
import 'package:flutter/material.dart';

/// Kalender-Screen mit Timeline-Ansicht
/// Zeigt Event-Timeline mit "Event erstellen" Button am unteren Rand
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalendarTimelineView();
  }
}
