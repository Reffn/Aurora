import 'package:dis_app/services/release_notes_gate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/temp_hive.dart';

void main() {
  late Box<dynamic> settingsBox;

  setUp(() async {
    settingsBox = await openTempBox<dynamic>('settings_release_notes_test');
  });

  tearDown(() async {
    await settingsBox.deleteFromDisk();
  });

  group('ReleaseNotesGate', () {
    test('zeigt beim ersten Start nichts — dort spricht die Vorstellung', () {
      final gate = ReleaseNotesGate.inMemory(
        currentVersion: '3.0.20',
        hasCompletedOnboarding: false,
      );

      expect(gate.needsShowing, isFalse);
    });

    test(
      'zeigt bei Bestandsnutzern ohne Eintrag — sonst käme die Neuerung erst '
      'eine Fassung später bei denen an, für die sie gebaut wurde',
      () {
        final gate = ReleaseNotesGate.inMemory(
          currentVersion: '3.0.20',
          hasCompletedOnboarding: true,
        );

        expect(gate.needsShowing, isTrue);
      },
    );

    test('zeigt nach einem Update', () {
      final gate = ReleaseNotesGate.inMemory(
        currentVersion: '3.0.20',
        seenVersion: '3.0.19',
        hasCompletedOnboarding: true,
      );

      expect(gate.needsShowing, isTrue);
    });

    test('schweigt bei derselben Fassung', () {
      final gate = ReleaseNotesGate.inMemory(
        currentVersion: '3.0.20',
        seenVersion: '3.0.20',
        hasCompletedOnboarding: true,
      );

      expect(gate.needsShowing, isFalse);
    });

    test('vergleicht auf Ungleichheit, nicht auf Reihenfolge', () {
      // Ein Vergleich nach Zeichenkette hielte "3.0.9" für größer als
      // "3.0.20" und bliebe stumm. Beide Richtungen werden geprüft.
      final nachVorn = ReleaseNotesGate.inMemory(
        currentVersion: '3.0.20',
        seenVersion: '3.0.9',
        hasCompletedOnboarding: true,
      );
      final nachHinten = ReleaseNotesGate.inMemory(
        currentVersion: '3.0.9',
        seenVersion: '3.0.20',
        hasCompletedOnboarding: true,
      );

      expect(nachVorn.needsShowing, isTrue);
      expect(nachHinten.needsShowing, isTrue);
    });

    test('markSeen beendet das Zeigen für diese Fassung', () async {
      final gate = ReleaseNotesGate.inMemory(
        currentVersion: '3.0.20',
        seenVersion: '3.0.19',
        hasCompletedOnboarding: true,
      );

      await gate.markSeen();

      expect(gate.needsShowing, isFalse);
    });

    test('fromBox liest und schreibt in der settings-Box', () async {
      await settingsBox.put('pre_onboarding_dismissed', true);
      await settingsBox.put(ReleaseNotesGate.storageKey, '3.0.19');

      final gate = ReleaseNotesGate.fromBox(
        settingsBox,
        currentVersion: '3.0.20',
      );
      expect(gate.needsShowing, isTrue);

      await gate.markSeen();

      expect(settingsBox.get(ReleaseNotesGate.storageKey), '3.0.20');
      expect(gate.needsShowing, isFalse);
    });

    test(
      'fromBox ohne abgeschlossene Vorstellung schweigt',
      () {
        final gate = ReleaseNotesGate.fromBox(
          settingsBox,
          currentVersion: '3.0.20',
        );

        expect(gate.needsShowing, isFalse);
      },
    );

    test('eine unbekannte Fassung wird nicht zum Anlass', () {
      // Kommt die Version nicht durch (`PackageInfo` fällt in `injection.dart`
      // auf 'unbekannt' zurück), darf daraus kein Schirm entstehen — sonst
      // erschiene er bei jedem Start, weil nie eine echte Fassung
      // gespeichert wird.
      final gate = ReleaseNotesGate.inMemory(
        currentVersion: 'unbekannt',
        seenVersion: '3.0.19',
        hasCompletedOnboarding: true,
      );

      expect(gate.needsShowing, isFalse);
    });
  });
}
