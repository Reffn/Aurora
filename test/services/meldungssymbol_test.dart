import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Das Symbol, mit dem Aurora in der Meldungsleiste steht.
///
/// Am 14.08.2026 stand neben der Medikamenten-Erinnerung ein leerer weißer
/// Ring. Ursache: als Meldungssymbol war `@mipmap/ic_launcher` angegeben —
/// das bunte Startsymbol. Android benutzt bei Meldungssymbolen nur den
/// Alphakanal und färbt alles Übrige weiß; ein volldeckendes Bild wird dabei
/// zwangsläufig zum Klecks, hier zum Umriss des runden Rahmens.
///
/// Wer drei Meldungen übereinander hat, sieht sonst nicht, welche von Aurora
/// kommt. Das ist kein Schönheitsfehler: Eine Erinnerung, die man nicht
/// zuordnen kann, wird weggewischt.
///
/// Die Prüfung auf alle fünf Auflösungsstufen steht hier, weil eine fehlende
/// Stufe lautlos ausfällt — Android zeigt dann gar kein Symbol, und im Test
/// am Schreibtisch fällt das nie auf.
void main() {
  const stufen = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

  test('das Meldungssymbol ist nicht das bunte Startsymbol', () {
    final quelle = File(
      'lib/services/notification_service.dart',
    ).readAsStringSync();

    expect(
      quelle,
      contains('@drawable/ic_notification'),
      reason: 'Meldungen brauchen eine einfarbige Silhouette',
    );
    expect(
      quelle,
      isNot(contains("AndroidInitializationSettings(\n        '@mipmap/")),
      reason: 'das Startsymbol wird in der Leiste zum weißen Klecks',
    );
  });

  // Die zweite Stelle, gefunden erst beim Gegentest am Gerät: Die
  // Testmeldung trug schon das Chamäleon, während die Dauermeldung der
  // Wegaufzeichnung darunter weiter den leeren Ring zeigte. Sie kommt aus
  // dem Vordergrunddienst des Geolocators und hat ihre eigene Icon-Angabe.
  test('auch die Dauermeldung der Wegaufzeichnung trägt die Silhouette', () {
    final quelle = File('lib/services/gps_manager.dart').readAsStringSync();

    expect(
      quelle,
      contains("name: 'ic_notification'"),
      reason: 'sonst steht neben dem laufenden Weg ein weißer Klecks',
    );
    expect(
      quelle,
      isNot(contains("name: 'ic_launcher'")),
      reason: 'das Startsymbol taugt nicht als Meldungssymbol',
    );
  });

  // Der Fund, den erst das gebaute Release-APK zeigte.
  //
  // `ic_notification` wird ausschließlich aus Dart heraus benannt — als
  // Zeichenkette in `notification_service.dart` und als `AndroidResource` in
  // `gps_manager.dart`. Der Resource-Shrinker liest Dart nicht. Er sah eine
  // Zeichnung, auf die im ganzen Android-Teil niemand zeigt, und warf sie
  // weg: im Debug-Paket lag sie sechsmal, im Release keinmal.
  //
  // Das ist nicht bloß ein fehlendes Bild. `flutter_local_notifications`
  // löst das Symbol beim Einrichten auf; fehlt es, steht die Einrichtung —
  // und mit ihr jede Erinnerung. Dieselbe Bauart hat schon einmal einen
  // Kanal acht Monate lang lautlos totgelegt.
  //
  // `keep.xml` ist die Stelle, an der man dem Shrinker sagt, was er nicht
  // sehen kann.
  test('der Shrinker weiß, dass er die Silhouette behalten muss', () {
    final keep = File('android/app/src/main/res/raw/keep.xml');

    expect(
      keep.existsSync(),
      isTrue,
      reason: 'ohne keep.xml wirft der Release-Build das Symbol weg',
    );
    expect(
      keep.readAsStringSync(),
      contains('@drawable/ic_notification'),
      reason: 'genau diese Zeichnung nennt im Android-Teil niemand sonst',
    );
  });

  test('die Silhouette liegt in jeder Auflösungsstufe', () {
    for (final stufe in stufen) {
      final datei = File(
        'android/app/src/main/res/drawable-$stufe/ic_notification.png',
      );
      expect(
        datei.existsSync(),
        isTrue,
        reason: 'ohne $stufe zeigt Android auf diesen Geräten kein Symbol',
      );
    }
  });
}
