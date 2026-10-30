import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/profile/widgets/profile_reset_frist_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Die Stufen der Wartefrist sprechen die Sprache der Oberfläche.
///
/// Bis zum 06.10.2026 stand in den Kacheln fest „1 Tag / 3 Tage / 7 Tage" —
/// auch in der italienischen App, mitten zwischen italienischen Sätzen.
void main() {
  Future<void> zeigen(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ProfileResetFristSection(
            gewaehlteStunden: null,
            profilFarbe: Colors.teal,
            onFristChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('auf Italienisch heißen die Stufen giorno und giorni', (
    tester,
  ) async {
    await zeigen(tester, const Locale('it'));

    expect(find.text('1 giorno'), findsOneWidget);
    expect(find.text('3 giorni'), findsOneWidget);
    expect(find.text('7 giorni'), findsOneWidget);
    expect(find.text('3 Tage'), findsNothing);
  });

  testWidgets('auf Deutsch bleibt es bei Tag und Tagen', (tester) async {
    await zeigen(tester, const Locale('de'));

    expect(find.text('1 Tag'), findsOneWidget);
    expect(find.text('3 Tage'), findsOneWidget);
    expect(find.text('7 Tage'), findsOneWidget);
  });
}
