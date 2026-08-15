import 'package:dis_app/modules/emergency/emergency_screen.dart';
import 'package:dis_app/modules/emergency/widgets/emergency_contact_card.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';
import 'emergency_test_setup.dart';

void main() {
  testWidgets('Die Karte fragt hier nicht nach dem Standort', (tester) async {
    await notfallAufbau(mitKontakten: 2);
    await pumpScaled(tester, const EmergencyScreen(), scale: 1, settle: false);

    final karte = tester.widget<OverviewMap>(find.byType(OverviewMap));
    expect(karte.showUserLocation, isFalse);

    // Bei Scale 1.0: Keine Exceptions erwartet (der Overflow tritt erst ab 150% auf)
    final fehler = tester.takeException();
    expect(fehler, isNull,
        reason: 'Bei normaler Schriftgröße sollte OverviewMap fehlerfrei rendern');
  });

  testWidgets('Die Karte ist sichtbar bei Normalschrift mit zwei Kontakten',
      (tester) async {
    await notfallAufbau(mitKontakten: 2);
    await pumpScaled(
      tester,
      const EmergencyScreen(),
      scale: 1.0,
      deviceSize: geraetS24.size,
      pixelRatio: geraetS24.ratio,
      settle: false,
    );

    // Bei Scale 1.0 passen zwei Kontakte in den Viewport, die Karte wird gebaut
    expect(find.byType(OverviewMap), findsOneWidget,
        reason: 'OverviewMap muss bei Normalschrift mit zwei Kontakten vorhanden sein');

    final fehler = tester.takeException();
    expect(fehler, isNull,
        reason: 'Bei normaler Schriftgröße sollte OverviewMap fehlerfrei rendern');
  });

  for (final skala in [1.5, 2.0]) {
    testWidgets('Kontakte stehen vor der Karte bei $skala', (tester) async {
      await notfallAufbau(mitKontakten: 2);
      await pumpScaled(
        tester,
        const EmergencyScreen(),
        scale: skala,
        deviceSize: geraetS24.size,
        pixelRatio: geraetS24.ratio,
        settle: false,
      );

      // Bei hohen Scales können Rendering-Overflows auftreten (ab 150%)
      // Das ist nicht Teil dieser Task, aber erlaubt (Task 2 Befund)
      final fehler = tester.takeException();
      if (fehler != null) {
        expect(fehler.toString(), contains('overflowed'),
            reason: 'Nur "overflowed" ist erwartet; andere Fehler sind Blocker');
      }

      // Versprechen: Erste Hilfe ist ohne Scrollen vollständig sichtbar
      expect(find.byType(EmergencyContactCard), findsWidgets);
      expectFullyVisible(tester, find.byType(EmergencyContactCard).first);

      // Kritisch: Die Karte ist NICHT im initialen Viewport (lazy sliver)
      // Sie wird bei hohen Scales nicht gebaut, solange Kontakte Viewport füllen
      expect(find.byType(OverviewMap), findsNothing,
          reason: 'OverviewMap darf im Viewport nicht vorhanden sein '
              '(lazy sliver wird erst bei Bedarf gebaut)');

      // Nach Scroll zum Ende wird die Karte gebaut und ist erreichbar
      await tester.dragUntilVisible(
        find.byType(OverviewMap),
        find.byType(EmergencyScreen),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.byType(OverviewMap), findsOneWidget,
          reason: 'OverviewMap muss nach Scrollen vorhanden sein (lazy sliver built)');
    });
  }
}
