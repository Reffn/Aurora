import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/medication/widgets/intake_times_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rahmen mit deutscher Sprache, damit die Beschriftungen feststehen.
///
/// Der Picker holt seine Wörter seit der Lokalisierung aus AppLocalizations.
/// Ohne diesen Rahmen findet er keine und der Test bricht ab, bevor er
/// etwas prüfen kann.
Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  group('DaySection', () {
    test('jede Stunde des Tages gehört zu genau einem Abschnitt', () {
      // Die Zuordnung Uhrzeit → Abschnitt ist die einzige Wahrheit des
      // Widgets: Es speichert keinen eigenen Zustand, sondern liest ihn
      // jedes Mal aus der Liste der Uhrzeiten. Überlappen sich zwei Fenster
      // oder bleibt eine Stunde übrig, zeigt die Auswahl etwas anderes an
      // als gespeichert ist.
      for (var hour = 0; hour < 24; hour++) {
        final time = '${hour.toString().padLeft(2, '0')}:00';
        final matching =
            DaySection.values.where((s) => s.contains(time)).toList();

        expect(
          matching,
          hasLength(1),
          reason: '$time gehört zu ${matching.map((s) => s.name)}',
        );
      }
    });

    test('Nachts läuft über Mitternacht', () {
      expect(DaySection.night.contains('22:00'), isTrue);
      expect(DaySection.night.contains('23:59'), isTrue);
      expect(DaySection.night.contains('00:30'), isTrue);
      expect(DaySection.night.contains('04:59'), isTrue);
      expect(DaySection.night.contains('05:00'), isFalse);
    });

    test('die vorgeschlagene Uhrzeit liegt im eigenen Abschnitt', () {
      for (final section in DaySection.values) {
        expect(
          section.contains(section.defaultTime),
          isTrue,
          reason: '${section.name} schlägt ${section.defaultTime} vor',
        );
      }
    });

    test('unlesbare Uhrzeit gehört zu keinem Abschnitt statt zu krachen', () {
      for (final section in DaySection.values) {
        expect(section.contains('irgendwas'), isFalse);
      }
    });
  });

  group('IntakeTimesPicker', () {
    /// Baut den Picker und gibt zurück, was er zuletzt gemeldet hat.
    Future<List<String>> tapSection(
      WidgetTester tester, {
      required List<String> start,
      required String label,
    }) async {
      var current = start;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => IntakeTimesPicker(
              times: current,
              onChanged: (times) => setState(() => current = times),
            ),
          ),
        ),
      );

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      return current;
    }

    testWidgets('ein Tipp trägt die vorgeschlagene Uhrzeit ein',
        (tester) async {
      final result = await tapSection(tester, start: [], label: 'Morgens');
      expect(result, ['08:00']);
    });

    testWidgets('ein zweiter Tipp nimmt sie wieder heraus', (tester) async {
      final result =
          await tapSection(tester, start: ['08:00'], label: 'Morgens');
      expect(result, isEmpty);
    });

    testWidgets('Abschalten trifft nur den eigenen Abschnitt', (tester) async {
      final result = await tapSection(
        tester,
        start: ['08:00', '12:00', '18:00'],
        label: 'Mittags',
      );
      expect(result, ['08:00', '18:00']);
    });

    testWidgets('die Liste bleibt sortiert', (tester) async {
      final result = await tapSection(
        tester,
        start: ['18:00', '12:00'],
        label: 'Morgens',
      );
      expect(result, ['08:00', '12:00', '18:00']);
    });

    testWidgets('eine eigene Uhrzeit lässt ihren Abschnitt aufleuchten',
        (tester) async {
      // 07:15 liegt im Morgen-Fenster. Der Abschnitt muss sie anzeigen,
      // nicht seine eigene Voreinstellung 08:00.
      await tester.pumpWidget(
        _wrap(IntakeTimesPicker(times: const ['07:15'], onChanged: (_) {})),
      );

      expect(find.text('07:15'), findsOneWidget);
      expect(find.text('08:00'), findsNothing);
    });

    testWidgets('nicht gewählte Abschnitte zeigen ihren Vorschlag blass an',
        (tester) async {
      await tester.pumpWidget(
        _wrap(IntakeTimesPicker(times: const [], onChanged: (_) {})),
      );

      for (final label in ['Morgens', 'Mittags', 'Abends', 'Nachts']) {
        expect(find.text(label), findsOneWidget);
      }
      for (final section in DaySection.values) {
        expect(find.text(section.defaultTime), findsOneWidget);
      }
    });
  });
}
