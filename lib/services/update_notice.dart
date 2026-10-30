import 'dart:io';

import 'package:dis_app/core/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Hinterlegt die Worte, mit denen sich Aurora nach einem Update meldet.
///
/// **Warum eine Meldung.** Play installiert Updates still, und der
/// Neuerungs-Schirm erscheint erst, wenn jemand die App ohnehin öffnet. Wer
/// Aurora nur in schlechten Momenten aufmacht, erfährt dann erst mitten in
/// der Not, dass sich etwas verändert hat. Die Meldung sagt es vorher, einmal,
/// ohne Ton.
///
/// **Warum kein Push.** Ein FCM-Token ist eine stabile Gerätekennung (siehe
/// `ReleaseNotesGate`). Hier verlässt nichts das Gerät: Android selbst ruft
/// `MY_PACKAGE_REPLACED`, und der Empfänger `UpdateHinweisReceiver.kt` stellt
/// die Meldung hin.
///
/// **Warum eine Datei.** Der Empfänger startet keine Flutter-Maschine und
/// kennt die in Aurora gewählte Sprache nicht. Also legt Dart Titel und Text
/// bei jedem Start ab — dasselbe Muster wie `TrackingBootNotice`. Fehlt die
/// Datei (die Fassung, die den Empfänger einführt, findet keine vor), nimmt
/// der Empfänger die Texte aus `res/values-*/strings.xml` in der
/// Systemsprache.
///
/// Abschalten lässt sich die Meldung über ihren eigenen Kanal in den
/// Android-Einstellungen; einen eigenen Schalter in Aurora braucht es nicht.
class UpdateNotice {
  const UpdateNotice._();

  /// Dieselbe Datei wie `DATEINAME` in `UpdateHinweisReceiver.kt`.
  static const String dateiname = 'update_hinweis.txt';

  /// Dieselbe Kennung wie `MELDUNGS_ID` im Empfänger. `MainActivity` nimmt
  /// die Meldung damit beim Öffnen wieder weg.
  static const int meldungsId = 990002;

  @visibleForTesting
  static Directory? ordnerFuerTest;

  static Future<Directory> _ordner() async =>
      ordnerFuerTest ?? await getApplicationSupportDirectory();

  /// Legt Titel und Text in der Sprache ab, die Aurora gerade spricht.
  ///
  /// Wird bei jedem Start überschrieben: Wechselt die Sprache, spricht die
  /// nächste Meldung die neue.
  static Future<void> merken({
    required String titel,
    required String text,
  }) async {
    // Nur Android hat den Empfänger.
    if (!_istAndroid) return;

    try {
      final datei = File('${(await _ordner()).path}/$dateiname');
      await datei.writeAsString(
        '${_eineZeile(titel)}\n${_eineZeile(text)}\n',
      );
    } catch (e) {
      // Ohne die Datei spricht die Meldung die Systemsprache. Kein Grund,
      // irgendetwas anderes scheitern zu lassen.
      logger.warning(
        LogCategory.service,
        'Update-Hinweis konnte nicht hinterlegt werden',
        data: {'error': e.toString()},
      );
    }
  }

  static String _eineZeile(String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').trim();

  static bool get _istAndroid =>
      ordnerFuerTest != null || (!kIsWeb && Platform.isAndroid);
}
