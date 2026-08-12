import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/anchor/anchor_header.dart';
import 'package:dis_app/modules/anchor/anchor_menu_screen.dart';
import 'package:dis_app/modules/anchor/anchor_row.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profil() => Profile(
  id: 'p1',
  nameRaw: 'Jo',
  preferredColorValue: Colors.teal.toARGB32(),
  createdAt: DateTime(2026, 8, 10),
);

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('de'),
  home: Scaffold(body: child),
);

AnchorEntry _entry(String label) => AnchorEntry(
  icon: Icons.circle,
  label: label,
  color: Colors.teal,
  onTap: () {},
);

void main() {
  group('AnchorHeader', () {
    testWidgets('trägt Gruß, Name und den Weg zum Anteilswechsel', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(AnchorHeader(profile: _profil(), onSwitchProfile: () {})),
      );

      // Gruß und Name stehen in einer Zeile, also in einem `Text.rich` —
      // `find.text` sucht nur nach ganzen Texten und fände keinen von beiden.
      expect(find.textContaining('Jo', findRichText: true), findsOneWidget);
      expect(find.text('Das bin ich nicht'), findsOneWidget);

      // Der Gruß hängt an der Stunde, also wird nicht auf einen festen Text
      // geprüft — sondern darauf, dass einer der vier dasteht.
      const moegliche = ['Guten Morgen', 'Guten Tag', 'Guten Abend', 'Hallo'];
      expect(
        moegliche
            .where(
              (g) => find
                  .textContaining(g, findRichText: true)
                  .evaluate()
                  .isNotEmpty,
            )
            .length,
        1,
        reason: 'Genau ein Gruß, nie zwei und nie keiner.',
      );
    });

    // Der Punkt beantwortet „wer ist gerade da?" ohne ein Wort. Stünde er
    // zweimal — einmal an der Namenszeile, einmal am Wechsel-Weg —, suchte
    // man einen Unterschied zwischen beiden, den es nicht gibt.
    testWidgets('der Anteilspunkt steht genau einmal, an der Namenszeile', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(AnchorHeader(profile: _profil(), onSwitchProfile: () {})),
      );

      expect(find.byType(ProfileImageWidget), findsOneWidget);

      final punkt = tester.getRect(find.byType(ProfileImageWidget));
      final zeile = tester.getRect(
        find.textContaining('Jo', findRichText: true),
      );

      expect(
        punkt.center.dy,
        closeTo(zeile.center.dy, 12),
        reason: 'Der Punkt steht auf Höhe des Namens, nicht darunter.',
      );
      expect(
        punkt.right,
        lessThanOrEqualTo(zeile.left),
        reason: 'Und links davon.',
      );
    });

    // Eine senkrechte Kante durch den Block, nicht zwei: Der Weg steht unter
    // dem Gruß, nicht unter dem Punkt.
    testWidgets('der Weg zurück fluchtet mit dem Gruß darüber', (tester) async {
      await tester.pumpWidget(
        _wrap(AnchorHeader(profile: _profil(), onSwitchProfile: () {})),
      );

      final zeile = tester.getRect(
        find.textContaining('Jo', findRichText: true),
      );
      final weg = tester.getRect(find.text('Das bin ich nicht'));

      expect(weg.left, closeTo(zeile.left, 2));
    });

    testWidgets('der Wechsel-Weg ruft seine Handlung', (tester) async {
      var gewechselt = false;

      await tester.pumpWidget(
        _wrap(
          AnchorHeader(
            profile: _profil(),
            onSwitchProfile: () => gewechselt = true,
          ),
        ),
      );

      await tester.tap(find.text('Das bin ich nicht'));
      await tester.pumpAndSettle();

      expect(gewechselt, isTrue);
    });

    // Dieselbe Figur trägt unten den Halt-Knopf. Oben ist sie Begleiter und
    // sonst nichts — wäre sie antippbar, gäbe es zwei Wege mit demselben
    // Bild auf einem Schirm, und wer das sieht, sucht einen Unterschied, den
    // es nicht gibt.
    testWidgets('der Begleiter ist kein Bedienelement', (tester) async {
      await tester.pumpWidget(
        _wrap(AnchorHeader(profile: _profil(), onSwitchProfile: () {})),
      );

      final semantik = tester.getSemantics(
        find.byType(AnchorHeader),
      );

      // Genau ein Knopf im Kopfblock: der Wechsel-Weg.
      var knoepfe = 0;
      void zaehle(SemanticsNode node) {
        if (node.hasFlag(SemanticsFlag.isButton)) knoepfe++;
        node.visitChildren((kind) {
          zaehle(kind);
          return true;
        });
      }

      zaehle(semantik);
      expect(knoepfe, 1);
    });
  });

  group('AnchorMenu mit Kopfblock', () {
    testWidgets('der Kopf bleibt stehen, wenn die Liste scrollt', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            header: AnchorHeader(profile: _profil(), onSwitchProfile: () {}),
            groups: [
              AnchorGroup(
                label: 'Wenn es schwer ist',
                emphasis: AnchorEmphasis.solid,
                entries: [_entry('Halt'), _entry('Notfall'), _entry('Hilfe')],
              ),
              AnchorGroup(
                label: 'Alltag',
                entries: [
                  for (final n in [
                    'Chat',
                    'Kalender',
                    'Tagebuch',
                    'Kontakte',
                    'Medikamente',
                    'Finder',
                  ])
                    _entry(n),
                ],
              ),
            ],
          ),
        ),
      );

      final name = find.textContaining('Jo', findRichText: true);
      final vorher = tester.getRect(name);

      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      expect(
        name,
        findsOneWidget,
        reason: '„Wer bin ich gerade" darf nicht wegscrollen.',
      );
      expect(tester.getRect(name), vorher);
    });
  });
}
