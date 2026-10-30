import 'dart:io';

import 'package:flutter/services.dart';

/// Lädt Roboto aus `test/support/fonts/` als Familie „Roboto“.
///
/// In Widgettests ist jedes Zeichen der Testschrift so breit wie hoch; ein
/// Satz läuft dort etwa doppelt so breit wie am Gerät, und schon „Musik“
/// bricht um. Wo eine Prüfung von Zeilenumbrüchen abhängt — wie viele Zeilen
/// das Zeitband bei 200 % braucht —, misst sie mit der Testschrift einen
/// Schirm, den es nicht gibt.
///
/// Das Material-Theme setzt seine Texte in „Roboto“. Ist die Familie
/// geladen, rechnen diese Texte mit den echten Glyphenbreiten. Symbole
/// bleiben Platzhalter, ihre Größe stimmt trotzdem.
///
/// Die Schnitte liegen im Repository (Apache-2.0, Lizenz daneben), nicht im
/// Flutter-Cache: Auf dem CI-Runner fehlt `material_fonts` im Cache, der
/// Test war dort rot, während er lokal durchlief.
///
/// Einmal je Testdatei in `setUpAll` aufrufen.
Future<void> ladeEchteSchrift() async {
  const ordner = 'test/support/fonts';
  final loader = FontLoader('Roboto');
  for (final schnitt in [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
  ]) {
    final datei = File('$ordner/$schnitt');
    if (!datei.existsSync()) {
      throw StateError('Roboto fehlt: ${datei.absolute.path}');
    }
    final bytes = datei.readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}
