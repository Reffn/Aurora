import 'dart:io';

import 'package:flutter/services.dart';

/// Lädt Roboto aus dem Flutter-Cache als Familie „Roboto“.
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
/// Einmal je Testdatei in `setUpAll` aufrufen.
Future<void> ladeEchteSchrift() async {
  final wurzel = Platform.environment['FLUTTER_ROOT'];
  if (wurzel == null) {
    throw StateError('FLUTTER_ROOT fehlt — Roboto nicht auffindbar.');
  }
  final ordner = '$wurzel/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  for (final schnitt in [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
  ]) {
    final datei = File('$ordner/$schnitt');
    if (!datei.existsSync()) {
      throw StateError('Roboto fehlt: ${datei.path}');
    }
    final bytes = datei.readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}
