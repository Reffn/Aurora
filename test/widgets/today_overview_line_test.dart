import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/widgets/today_overview_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profil(List<Permission> permissions) {
  return Profile(
    id: 'p1',
    nameRaw: 'Sofia',
    preferredColorValue: 0xFFAA66CC,
    createdAt: DateTime(2026),
    permissions: permissions.map((p) => p.persistedValue).toList(),
  );
}

Widget _app({
  required Profile? profile,
  int events = 0,
  int medications = 0,
}) {
  return MaterialApp(
    locale: const Locale('de'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: TodayOverviewLine(
        profile: profile,
        countEventsForDay: (_) => events,
        countMedicationsToday: () => medications,
        nowProvider: () => DateTime(2026, 8, 6, 9),
      ),
    ),
  );
}

void main() {
  // Die Inhalts-Rechte, nicht die Tab-Rechte: Die Zeile zeigt Inhalte, und
  // das Tab-Recht steuert nur die Navigation. Der Test stand allein auf den
  // Tab-Rechten und zählte deshalb nichts mehr.
  const alleRechte = [
    Permission.viewCalendarTab,
    Permission.viewCalendar,
    Permission.viewMedicationTab,
    Permission.viewMedication,
  ];

  group('TodayOverviewLine', () {
    testWidgets('zeigt Termine und Medikamente des Tages', (tester) async {
      await tester.pumpWidget(
        _app(profile: _profil(alleRechte), events: 2, medications: 1),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('2 Termine heute'), findsOneWidget);
      expect(find.textContaining('1 Medikament heute'), findsOneWidget);
    });

    // Nichts anzukündigen ist keine Information, die Platz verdient.
    testWidgets('ein leerer Tag erzeugt Stille, nicht „0 Termine"',
        (tester) async {
      await tester.pumpWidget(_app(profile: _profil(alleRechte)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.event_note), findsNothing);
    });

    // Die Zeile steht nach der Profilwahl und gehorcht deren Rechten —
    // wer den Medikamenten-Bereich nicht sehen darf, sieht auch die Zahl nicht.
    testWidgets('ohne Medikamenten-Recht bleibt die Medikamenten-Zahl weg',
        (tester) async {
      await tester.pumpWidget(
        _app(
          profile: _profil(const [
            Permission.viewCalendarTab,
            Permission.viewCalendar,
          ]),
          events: 2,
          medications: 3,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('2 Termine heute'), findsOneWidget);
      expect(find.textContaining('Medikamente'), findsNothing);
    });

    // Auf der Profilauswahl gibt es noch kein Profil — Termine und
    // Medikamente gelten dem Körper, die Zahlen gehören dort allen.
    testWidgets('vor der Profilwahl zeigen die Zahlen sich ohne Rechte',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TodayOverviewLine(
              profile: null,
              gateByPermissions: false,
              countEventsForDay: (_) => 1,
              countMedicationsToday: () => 2,
              nowProvider: () => DateTime(2026, 8, 6, 9),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('1 Termin heute'), findsOneWidget);
      expect(find.textContaining('2 Medikamente heute'), findsOneWidget);
    });

    testWidgets('ohne jedes Recht erscheint nichts', (tester) async {
      await tester.pumpWidget(
        _app(profile: _profil(const []), events: 5, medications: 5),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.event_note), findsNothing);
    });
  });
}
