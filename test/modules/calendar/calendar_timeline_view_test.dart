import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/modules/calendar/widgets/calendar_timeline_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('der ganze Termin oeffnet Details ohne Verwaltungsleiste', (
    tester,
  ) async {
    var opened = false;
    final event = CalendarEvent(
      id: 'arzt',
      title: 'Arzttermin',
      startTime: DateTime(2026, 8, 10, 10),
      endTime: DateTime(2026, 8, 10, 11),
      profileIds: const ['p1'],
      locationName: 'Praxis Dr. Berg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarEventTile(
            event: event,
            accentColor: Colors.teal,
            onTap: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('Arzttermin'), findsOneWidget);
    expect(find.text('Praxis Dr. Berg'), findsOneWidget);
    expect(find.text('Bearbeiten'), findsNothing);
    expect(find.text('Löschen'), findsNothing);
    expect(find.text('Kommentare'), findsNothing);

    await tester.tap(find.text('Arzttermin'));
    expect(opened, isTrue);
  });
}
