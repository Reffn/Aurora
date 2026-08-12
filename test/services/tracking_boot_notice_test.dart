// Nach einem Geraeteneustart lief die Wegaufzeichnung nicht weiter — und
// niemand erfuhr es. Das Loch im Weg fiel erst auf, wenn jemand nach einer
// Dissoziation wissen wollte, wo er war, also genau dann, wenn es zu spaet ist.
//
// Der Dienst kann nicht von allein anlaufen: Ein Foreground-Service vom Typ
// `location` darf mit „Bei Nutzung erlauben" nur weitermessen, wenn er
// gestartet wurde, waehrend die App sichtbar war. `BOOT_COMPLETED` ist
// Hintergrund. Also steht dort jetzt eine Meldung, und ein Griff genuegt.
//
// Die zweite Haelfte dieser Tests prueft den Vertrag zwischen Dart und Kotlin:
// dieselbe Datei, dieselbe Kennung, derselbe Empfaenger im Manifest. Die drei
// koennen auseinanderlaufen, ohne dass irgendetwas rot wird — dieselbe Falle
// wie bei den Erinnerungs-Empfaengern, die acht Monate lang ins Leere feuerten.

import 'dart:io';

import 'package:dis_app/services/tracking_boot_notice.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kommentarzeilen raus, damit die Belege im Fliesstext nicht als Fund gelten.
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

void main() {
  group('TrackingBootNotice', () {
    late Directory ordner;

    setUp(() {
      ordner = Directory.systemTemp.createTempSync('aurora_boot_test');
      TrackingBootNotice.ordnerFuerTest = ordner;
    });

    tearDown(() {
      TrackingBootNotice.ordnerFuerTest = null;
      if (ordner.existsSync()) ordner.deleteSync(recursive: true);
    });

    File _datei() =>
        File('${ordner.path}/${TrackingBootNotice.dateiname}');

    test('merken legt Titel und Text in getrennten Zeilen ab', () async {
      await TrackingBootNotice.merken(
        titel: 'Aufzeichnung pausiert',
        text: 'Tippe hier.',
      );

      final zeilen = _datei().readAsLinesSync();
      expect(zeilen.first, 'Aufzeichnung pausiert');
      expect(zeilen[1], 'Tippe hier.');
    });

    test('ein mehrzeiliger Text bleibt eine Zeile', () async {
      // Der Empfaenger liest Zeile eins als Titel und den Rest als Text.
      // Ein Umbruch mitten im Titel wuerde die Form zerreissen.
      await TrackingBootNotice.merken(
        titel: 'Aufzeichnung\npausiert',
        text: 'Nach dem Neustart\nzeichnet Aurora erst wieder auf.',
      );

      final zeilen = _datei().readAsLinesSync()
        ..removeWhere((z) => z.isEmpty);
      expect(zeilen, hasLength(2));
      expect(zeilen.first, 'Aufzeichnung pausiert');
    });

    test('vergessen entfernt die Datei', () async {
      await TrackingBootNotice.merken(titel: 'A', text: 'B');
      expect(await TrackingBootNotice.istHinterlegt(), isTrue);

      await TrackingBootNotice.vergessen();
      expect(await TrackingBootNotice.istHinterlegt(), isFalse);
    });

    test('vergessen ohne Datei wirft nicht', () async {
      await TrackingBootNotice.vergessen();
      expect(await TrackingBootNotice.istHinterlegt(), isFalse);
    });
  });

  group('Vertrag zwischen Dart und Kotlin', () {
    final empfaenger = nurCode(
      File('android/app/src/main/kotlin/com/disapp/dis_app/'
              'WegaufzeichnungBootReceiver.kt')
          .readAsStringSync(),
    );

    test('beide Seiten meinen dieselbe Datei', () {
      expect(
        empfaenger,
        contains('"${TrackingBootNotice.dateiname}"'),
        reason: 'Der Empfaenger liest einen anderen Dateinamen als Dart '
            'schreibt. Es wuerde nie etwas gemeldet, ohne einen Fehler.',
      );
    });

    test('beide Seiten meinen dieselbe Kennung', () {
      // Kotlin schreibt sie mit Unterstrichen als Tausendertrennung.
      final kennung = TrackingBootNotice.meldungsId.toString();
      final mitUnterstrich =
          '${kennung.substring(0, kennung.length - 3)}_'
          '${kennung.substring(kennung.length - 3)}';

      expect(
        empfaenger.contains(kennung) || empfaenger.contains(mitUnterstrich),
        isTrue,
        reason: 'Die App nimmt die Meldung beim Start ueber diese Kennung '
            'wieder weg. Weichen sie ab, bleibt sie stehen und behauptet '
            'etwas Falsches.',
      );
    });

    test('der Empfaenger startet den Dienst nicht', () {
      // Der ganze Sinn: kein Start aus dem Hintergrund, also bleibt
      // ACCESS_BACKGROUND_LOCATION draussen.
      expect(empfaenger, isNot(contains('startForegroundService')));
      expect(empfaenger, isNot(contains('startService')));
    });

    test('das Manifest traegt den Empfaenger und BOOT_COMPLETED', () {
      final manifest =
          nurCode(File('android/app/src/main/AndroidManifest.xml')
              .readAsStringSync());

      expect(manifest, contains('.WegaufzeichnungBootReceiver'));
      expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
      // Ohne exported="true" kommt der System-Broadcast nicht an — und zwar
      // lautlos, wie bei den Erinnerungs-Empfaengern.
      expect(manifest, contains('android:exported="true"'));
    });

    test('ACCESS_BACKGROUND_LOCATION bleibt draussen', () {
      final manifest =
          nurCode(File('android/app/src/main/AndroidManifest.xml')
              .readAsStringSync());

      // Sie darf nur mit tools:node="remove" vorkommen. Steht sie ohne da,
      // ist der ganze Umbau umsonst: Play verlangt dann wieder Deklaration
      // und Demo-Video.
      final stelle = manifest.indexOf('ACCESS_BACKGROUND_LOCATION');
      expect(stelle, isNot(-1));
      expect(
        manifest.substring(stelle, stelle + 200),
        contains('tools:node="remove"'),
      );
    });
  });
}
