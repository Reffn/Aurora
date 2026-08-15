import 'package:dis_app/services/app_update_nudge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime jetzt;
  late int gefragt;
  late int gestartet;
  late int abgeschlossen;

  setUp(() {
    jetzt = DateTime(2026, 8, 13, 10);
    gefragt = 0;
    gestartet = 0;
    abgeschlossen = 0;
  });

  AppUpdateNudge baue({
    String? letzteFrage,
    bool hatUpdate = true,
    bool wirft = false,
    bool hatGeladenes = false,
    bool wirftBeimAbschluss = false,
  }) {
    var gespeichert = letzteFrage;
    return AppUpdateNudge(
      hasUpdate: () async {
        gefragt++;
        if (wirft) throw StateError('Play nicht erreichbar');
        return hatUpdate;
      },
      startUpdate: () async => gestartet++,
      hasDownloadedUpdate: () async {
        if (wirftBeimAbschluss) throw StateError('Play nicht erreichbar');
        return hatGeladenes;
      },
      completeUpdate: () async => abgeschlossen++,
      readLastAsked: () => gespeichert,
      writeLastAsked: (wert) async => gespeichert = wert,
      now: () => jetzt,
    );
  }

  group('AppUpdateNudge', () {
    test('fragt beim ersten Mal', () async {
      final nudge = baue();

      expect(await nudge.maybePrompt(), isTrue);
      expect(gestartet, 1);
    });

    test('schweigt innerhalb der Frist', () async {
      final nudge = baue(
        letzteFrage: DateTime(2026, 8, 10).toIso8601String(),
      );

      expect(await nudge.maybePrompt(), isFalse);
      expect(gefragt, 0, reason: 'Play wird gar nicht erst befragt');
    });

    test('fragt wieder, wenn die Frist um ist', () async {
      final nudge = baue(
        letzteFrage: DateTime(2026, 8, 1).toIso8601String(),
      );

      expect(await nudge.maybePrompt(), isTrue);
      expect(gestartet, 1);
    });

    test('startet nichts, wenn nichts bereitliegt', () async {
      final nudge = baue(hatUpdate: false);

      expect(await nudge.maybePrompt(), isFalse);
      expect(gestartet, 0);
    });

    test('ein Fehler bleibt ein Fehler und kein Absturz', () async {
      // Der seitlich geladene Bau ist der Normalfall auf den eigenen
      // Testgeräten: Play kennt das Paket nicht und die Abfrage wirft. Das
      // darf den Start nicht mitnehmen.
      final nudge = baue(wirft: true);

      expect(await nudge.maybePrompt(), isFalse);
      expect(gestartet, 0);
    });

    test('ein unlesbares Datum wird wie „noch nie" behandelt', () async {
      final nudge = baue(letzteFrage: 'kaputt');

      expect(await nudge.maybePrompt(), isTrue);
    });

    test('die Frage wird auch dann vermerkt, wenn sie fehlschlägt', () async {
      // Sonst liefe bei jedem Start eine Abfrage ins Leere.
      var gespeichert = <String>[];
      final nudge = AppUpdateNudge(
        hasUpdate: () async => throw StateError('kein Play'),
        startUpdate: () async {},
        hasDownloadedUpdate: () async => false,
        completeUpdate: () async {},
        readLastAsked: () => gespeichert.isEmpty ? null : gespeichert.last,
        writeLastAsked: (wert) async => gespeichert = [...gespeichert, wert],
        now: () => jetzt,
      );

      await nudge.maybePrompt();

      expect(gespeichert, hasLength(1));
      expect(DateTime.parse(gespeichert.single), jetzt);
    });
  });

  group('AppUpdateNudge.completeIfDownloaded', () {
    test('schließt ein geladenes Update ab', () async {
      // Ohne diesen Schritt bleibt das Update auf DOWNLOADED liegen — Play
      // installiert von selbst nichts.
      final nudge = baue(hatGeladenes: true);

      expect(await nudge.completeIfDownloaded(), isTrue);
      expect(abgeschlossen, 1);
    });

    test('tut nichts, wenn nichts geladen ist', () async {
      final nudge = baue();

      expect(await nudge.completeIfDownloaded(), isFalse);
      expect(abgeschlossen, 0);
    });

    test('ein Fehler bleibt ein Fehler und kein Absturz', () async {
      final nudge = baue(wirftBeimAbschluss: true);

      expect(await nudge.completeIfDownloaded(), isFalse);
      expect(abgeschlossen, 0);
    });

    test('die Frist gilt hier nicht', () async {
      // Der Abschluss hängt nicht am Wochenrhythmus: Was geladen ist, soll
      // beim nächsten Verlassen der App fertig werden, nicht erst in sieben
      // Tagen.
      final nudge = baue(
        letzteFrage: jetzt.toIso8601String(),
        hatGeladenes: true,
      );

      expect(await nudge.completeIfDownloaded(), isTrue);
    });
  });
}
