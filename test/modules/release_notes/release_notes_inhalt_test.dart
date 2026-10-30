import 'dart:io';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/release_notes/release_notes_inhalt.dart';
import 'package:dis_app/modules/release_notes/release_notes_screen.dart';
import 'package:dis_app/services/release_notes_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';

/// Der Neuerungs-Schirm sagt, was *diese* Fassung bringt.
///
/// Bis 3.0.22 stand dort ein einziger fester Satz: „Aurora meldet sich ab
/// jetzt einmal nach einem Update …" — bei jedem Update derselbe. Wer ihn zum
/// zweiten Mal las, erfuhr nichts.
///
/// Der erste Test ist der Riegel für jedes Release: Wird die Fassung in
/// `pubspec.yaml` erhöht, schlägt er fehl, bis für sie Punkte in allen fünf
/// Sprachen hinterlegt sind.
void main() {
  String fassungAusPubspec() {
    final zeile = File(
      'pubspec.yaml',
    ).readAsLinesSync().firstWhere((z) => z.startsWith('version:'));
    return zeile.split(':').last.trim().split('+').first;
  }

  test('die Fassung aus pubspec.yaml hat Neuerungen in jeder Sprache', () {
    final fassung = fassungAusPubspec();

    for (final sprache in AppLocalizations.supportedLocales) {
      final text = releaseNotesFuerFassung(
        fassung,
        lookupAppLocalizations(sprache),
      );
      expect(
        text,
        isNotNull,
        reason:
            'Für $fassung fehlen die Neuerungen ($sprache). Eintrag in '
            'release_notes_inhalt.dart und in allen fünf ARB-Dateien anlegen.',
      );
      expect(text!.trim(), isNotEmpty);
    }
  });

  // Abnahme am Emulator, 3.0.25: Mit fünf langen Punkten rutschte „Und das
  // Wichtigere: Was fehlt dir?“ halb unter die Kante über dem Knopf „Sag
  // uns, was fehlt“. Die Neuigkeiten sind der Anlass, die Frage ist der
  // Zweck des Schirms — sie darf nicht hinter den Neuigkeiten verschwinden.
  test('die laufende Fassung hat höchstens vier Punkte', () {
    final fassung = fassungAusPubspec();

    for (final sprache in AppLocalizations.supportedLocales) {
      final text = releaseNotesFuerFassung(
        fassung,
        lookupAppLocalizations(sprache),
      )!;
      final punkte = '•'.allMatches(text).length;
      expect(punkte, inInclusiveRange(1, 4), reason: '$fassung, $sprache');

      // Je Punkt eine Zeile Sinn. Gemessen wird in Zeichen, nicht in
      // Pixeln: Die Testschrift ist etwa doppelt so breit wie die echte,
      // eine Aussage „passt ohne Rollen“ ließe sich hier nicht treffen.
      for (final zeile in text.split('\n')) {
        expect(
          zeile.length,
          lessThanOrEqualTo(72),
          reason: '$fassung, $sprache: „$zeile“',
        );
      }
    }
  });

  // Wird es doch länger — große Schrift, eine Sprache mit langen Wörtern —,
  // rollt die Fläche über den Knöpfen, und nichts liegt unter ihnen.
  testWidgets('bei 200 % rollt der Text, und nichts liegt unter den Knöpfen', (
    tester,
  ) async {
    final fassung = fassungAusPubspec();
    final l10n = lookupAppLocalizations(const Locale('de'));
    await pumpScaled(
      tester,
      ReleaseNotesScreen(
        gate: ReleaseNotesGate.inMemory(currentVersion: fassung),
        appVersion: fassung,
        onDismissed: () {},
      ),
      scale: 2,
      deviceSize: geraetA14.size,
      pixelRatio: geraetA14.ratio,
    );

    final letzter = find.text(l10n.releaseNotesWhatHappens);
    await tester.scrollUntilVisible(
      letzter,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    final knopf = tester.getRect(
      find.byKey(const Key('release_notes_feedback')),
    );
    expect(tester.getRect(letzter).bottom, lessThanOrEqualTo(knopf.top));
  });

  test('unbekannte oder fehlende Fassung: nichts Eigenes', () {
    final l10n = lookupAppLocalizations(const Locale('de'));

    expect(releaseNotesFuerFassung('9.9.9', l10n), isNull);
    expect(releaseNotesFuerFassung(null, l10n), isNull);
  });

  Future<void> pumpScreen(WidgetTester tester, String? fassung) {
    return tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReleaseNotesScreen(
          gate: ReleaseNotesGate.inMemory(currentVersion: '3.0.22'),
          appVersion: fassung,
          onDismissed: () {},
        ),
      ),
    );
  }

  testWidgets('der Schirm zeigt die Punkte der laufenden Fassung', (
    tester,
  ) async {
    await pumpScreen(tester, '3.0.22');
    final l10n = lookupAppLocalizations(const Locale('de'));

    expect(find.text(l10n.releaseNotesFassung3022), findsOneWidget);
    expect(find.text(l10n.releaseNotesAllgemein), findsNothing);
  });

  testWidgets('ohne Eintrag: der allgemeine Text, kein veralteter', (
    tester,
  ) async {
    await pumpScreen(tester, '9.9.9');
    final l10n = lookupAppLocalizations(const Locale('de'));

    expect(find.text(l10n.releaseNotesAllgemein), findsOneWidget);
  });
}
