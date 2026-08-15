import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:dis_app/widgets/quick_timeline_band.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _marie(List<Permission> permissions) {
  return Profile(
    id: 'marie',
    nameRaw: 'Marie',
    preferredColorValue: 0xFFAA66CC,
    createdAt: DateTime(2026),
    permissions: permissions.map((p) => p.persistedValue).toList(),
  );
}

TimelineEvent _wechselZu(String id, String hour) {
  return TimelineEvent(
    id: 'sw_$id$hour',
    timestamp: DateTime.parse('2026-08-06 $hour:00:00'),
    type: TimelineEventType.profileSwitch,
    data: {'toProfileId': id},
  );
}

TimelineEvent _medikament(String name, String hour) {
  return TimelineEvent(
    id: 'med_$hour',
    timestamp: DateTime.parse('2026-08-06 $hour:00:00'),
    type: TimelineEventType.medication,
    title: '✓ $name',
  );
}

TimelineEvent _termin(String titel, String hour) {
  return TimelineEvent(
    id: 'cal_$hour',
    timestamp: DateTime.parse('2026-08-06 $hour:00:00'),
    type: TimelineEventType.calendarEvent,
    title: titel,
  );
}

Widget _app(Widget band) {
  return MaterialApp(
    locale: const Locale('de'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: band),
  );
}

void main() {
  // Die Inhalts-Rechte, nicht nur die Tab-Rechte: Das Band zeigt Inhalte, und
  // wer „Kalender ansehen" nicht hat, soll den Termin auch hier nicht sehen.
  // Der Test stand allein auf den Tab-Rechten und ging deshalb leer aus,
  // nachdem das Band auf die Inhalts-Rechte umgestellt wurde.
  const alleRechte = [
    Permission.viewCalendarTab,
    Permission.viewCalendar,
    Permission.viewMedicationTab,
    Permission.viewMedication,
  ];
  String? nameOf(String id) => {'sofie': 'Sofie', 'marie': 'Marie'}[id];

  group('QuickTimelineBand', () {
    testWidgets('zeigt wer war, wer da ist und was kommt', (tester) async {
      await tester.pumpWidget(_app(QuickTimelineBand(
        profile: _marie(alleRechte),
        pastEvents: [
          _wechselZu('sofie', '08'),
          _medikament('Ibuprofen', '09'),
        ],
        upcomingEvents: [_termin('Frau Müller', '15')],
        profileNameOf: nameOf,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Sofie'), findsOneWidget);
      expect(find.text('✓ Ibuprofen'), findsOneWidget);
      // Der Name steht nicht mehr im Band — er steht in der Kopfzeile
      // darüber, und zweimal war einmal zu viel. Der Drehpunkt zwischen
      // Vergangenheit und Zukunft ist der Avatar; für Vorlesehilfen trägt
      // er den Namen weiter.
      expect(find.text('Marie (Du)'), findsNothing);
      final semantik = tester.ensureSemantics();
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp(r'Marie \(Du\)')), findsOneWidget);
      semantik.dispose();
      expect(find.text('15:00 Frau Müller'), findsOneWidget);
    });

    // Medikamente und Termine gehorchen den Rechten des Profils;
    // Wechsel gelten dem Körper und bleiben.
    testWidgets('ohne Rechte verschwinden Medikamente und Termine, Wechsel nicht',
        (tester) async {
      await tester.pumpWidget(_app(QuickTimelineBand(
        profile: _marie(const []),
        pastEvents: [
          _wechselZu('sofie', '08'),
          _medikament('Ibuprofen', '09'),
        ],
        upcomingEvents: [_termin('Frau Müller', '15')],
        profileNameOf: nameOf,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Sofie'), findsOneWidget);
      expect(find.textContaining('Ibuprofen'), findsNothing);
      expect(find.textContaining('Frau Müller'), findsNothing);
    });

    // „Dev › Dev › Dev" beantwortet nichts — eine Episode, eine Marke.
    testWidgets('fasst Wechsel zum selben Anteil zu einer Marke zusammen',
        (tester) async {
      await tester.pumpWidget(_app(QuickTimelineBand(
        profile: _marie(alleRechte),
        pastEvents: [
          _wechselZu('sofie', '07'),
          _wechselZu('sofie', '08'),
          _wechselZu('sofie', '09'),
        ],
        upcomingEvents: const [],
        profileNameOf: nameOf,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Sofie'), findsOneWidget);
    });

    // Mehr Marken beantworten keine Frage besser — sie verstecken das Jetzt.
    testWidgets('kappt die Vergangenheit auf die jüngsten drei Marken',
        (tester) async {
      await tester.pumpWidget(_app(QuickTimelineBand(
        profile: _marie(alleRechte),
        pastEvents: [
          _termin('Uralt', '01'),
          _termin('Alt', '02'),
          _termin('Drei', '03'),
          _termin('Zwei', '04'),
          _termin('Eins', '05'),
        ],
        upcomingEvents: const [],
        profileNameOf: nameOf,
      )));
      await tester.pumpAndSettle();

      expect(find.textContaining('Uralt'), findsNothing);
      expect(find.textContaining('Alt'), findsNothing);
      expect(find.textContaining('Drei'), findsOneWidget);
      expect(find.textContaining('Eins'), findsOneWidget);
    });
  });
}
