// Nach einem Update erfuhr niemand, dass Aurora neu ist: Play installiert
// still, und der Neuerungs-Schirm erscheint erst, wenn die App ohnehin
// geöffnet wird. Jetzt meldet sich die neue Fassung einmal selbst.
//
// Android ruft dafür `MY_PACKAGE_REPLACED` — an einen Empfänger, der keine
// Flutter-Maschine startet und die gewählte Sprache nicht kennt. Also legt
// Dart Titel und Text in der Sprache der App in einer Datei ab, wie bei der
// Wegaufzeichnung.
//
// Die zweite Hälfte prüft den Vertrag zwischen Dart, Kotlin und Manifest. Die
// drei können auseinanderlaufen, ohne dass irgendetwas rot wird — dieselbe
// Falle wie bei den Erinnerungs-Empfängern, die acht Monate lang ins Leere
// feuerten.

import 'dart:io';

import 'package:dis_app/services/update_notice.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kommentarzeilen raus, damit die Belege im Fließtext nicht als Fund gelten.
String nurCode(String quelle) => quelle
    .split('\n')
    .where((z) {
      final t = z.trimLeft();
      return !t.startsWith('//') &&
          !t.startsWith('*') &&
          !t.startsWith('/*') &&
          !t.startsWith('<!--');
    })
    .join('\n');

const String kotlinOrdner = 'android/app/src/main/kotlin/com/disapp/dis_app';

void main() {
  group('UpdateNotice', () {
    late Directory ordner;

    setUp(() {
      ordner = Directory.systemTemp.createTempSync('aurora_update_test');
      UpdateNotice.ordnerFuerTest = ordner;
    });

    tearDown(() {
      UpdateNotice.ordnerFuerTest = null;
      ordner.deleteSync(recursive: true);
    });

    File datei() => File('${ordner.path}/${UpdateNotice.dateiname}');

    test('merken legt Titel und Text in getrennten Zeilen ab', () async {
      await UpdateNotice.merken(
        titel: 'Aurora ist aktualisiert',
        text: 'Schau kurz rein.',
      );

      final zeilen = datei().readAsLinesSync();
      expect(zeilen.first, 'Aurora ist aktualisiert');
      expect(zeilen[1], 'Schau kurz rein.');
    });

    test('ein mehrzeiliger Text bleibt eine Zeile', () async {
      await UpdateNotice.merken(
        titel: 'Aurora\nist aktualisiert',
        text: 'Schau\n\nkurz rein.',
      );

      final zeilen = datei().readAsLinesSync();
      expect(zeilen, hasLength(2));
      expect(zeilen.first, 'Aurora ist aktualisiert');
      expect(zeilen[1], 'Schau kurz rein.');
    });

    test('ein Sprachwechsel überschreibt die Datei', () async {
      await UpdateNotice.merken(titel: 'Aurora ist aktualisiert', text: 'a');
      await UpdateNotice.merken(titel: 'Aurora has been updated', text: 'b');

      expect(datei().readAsLinesSync().first, 'Aurora has been updated');
    });
  });

  group('Vertrag zwischen Dart, Kotlin und Manifest', () {
    String empfaenger() => nurCode(
      File('$kotlinOrdner/UpdateHinweisReceiver.kt').readAsStringSync(),
    );

    String manifest() => nurCode(
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
    );

    test('beide Seiten meinen dieselbe Datei', () {
      expect(empfaenger(), contains('"${UpdateNotice.dateiname}"'));
    });

    test('beide Seiten meinen dieselbe Kennung', () {
      final id = UpdateNotice.meldungsId.toString();
      final mitTrenner =
          '${id.substring(0, id.length - 3)}_${id.substring(id.length - 3)}';
      expect(
        empfaenger().contains(id) || empfaenger().contains(mitTrenner),
        isTrue,
        reason: 'MELDUNGS_ID im Empfänger muss $id sein',
      );
    });

    test('die Kennung kollidiert nicht mit der Wegaufzeichnung', () {
      expect(UpdateNotice.meldungsId, isNot(990001));
    });

    test('das Manifest trägt den Empfänger für MY_PACKAGE_REPLACED', () {
      final m = manifest();
      final start = m.indexOf('.UpdateHinweisReceiver');
      expect(start, greaterThan(-1));
      final ende = m.indexOf('</receiver>', start);
      final eintrag = m.substring(start, ende);

      expect(eintrag, contains('android.intent.action.MY_PACKAGE_REPLACED'));
      // Der Broadcast kommt vom System — ohne exported kommt er nie an.
      expect(eintrag, contains('android:exported="true"'));
    });

    test('MainActivity nimmt die Meldung beim Öffnen wieder weg', () {
      final aktivitaet = nurCode(
        File('$kotlinOrdner/MainActivity.kt').readAsStringSync(),
      );
      expect(aktivitaet, contains('UpdateHinweisReceiver.MELDUNGS_ID'));
    });

    test('der Rückfalltext liegt in allen fünf Sprachen vor', () {
      // Die Fassung, die den Empfänger einführt, findet keine Datei vor: Die
      // alte hat keine geschrieben. Ohne Rückfall bliebe genau das erste
      // Update stumm.
      for (final ordner in const [
        'values',
        'values-de',
        'values-fr',
        'values-es',
        'values-it',
      ]) {
        final datei = File('android/app/src/main/res/$ordner/strings.xml');
        expect(datei.existsSync(), isTrue, reason: '$ordner/strings.xml');
        final inhalt = datei.readAsStringSync();
        for (final name in const [
          'update_hinweis_titel',
          'update_hinweis_text',
          'update_hinweis_kanal',
        ]) {
          expect(inhalt, contains('name="$name"'), reason: '$ordner: $name');
        }
      }
    });
  });
}
