import 'dart:io';

import 'package:dis_app/core/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Hinterlegt für den Boot-Empfänger, dass die Wegaufzeichnung gewünscht ist.
///
/// Nach einem Geräteneustart läuft sie nicht von allein weiter: Der
/// Positionsdienst ist ein Foreground-Service vom Typ `location`, und der darf
/// mit „Bei Nutzung erlauben" nur weitermessen, wenn er gestartet wurde,
/// **während die App sichtbar war**. Ein Start aus `BOOT_COMPLETED` wäre ein
/// Start aus dem Hintergrund und verlangte `ACCESS_BACKGROUND_LOCATION` — die
/// Berechtigung, die bei Google Play eine eigene Deklaration samt Demo-Video
/// kostet und die Nutzerin in fremde Systemmenüs schickt.
///
/// Deshalb ein Griff statt einer Berechtigung: Der native Empfänger stellt eine
/// Meldung hin, ein Tippen öffnet Aurora, und der schon vorhandene Auto-Start
/// aus dem gespeicherten Wunsch übernimmt.
///
/// Warum die Texte in der Datei stehen: Ein `BroadcastReceiver` startet keine
/// Flutter-Maschine. Er kennt weder die gewählte Sprache noch die
/// Übersetzungen — also schreibt Dart sie hin, solange es sie kennt.
class TrackingBootNotice {
  const TrackingBootNotice._();

  /// Derselbe Name wie in `WegaufzeichnungBootReceiver.DATEINAME`.
  static const String dateiname = 'wegaufzeichnung_wunsch.txt';

  /// Dieselbe Kennung wie in `WegaufzeichnungBootReceiver.MELDUNGS_ID`.
  static const int meldungsId = 990001;

  /// Nur für Tests: schreibt in dieses Verzeichnis statt in das der App.
  @visibleForTesting
  static Directory? ordnerFuerTest;

  static Future<Directory> _ordner() async =>
      ordnerFuerTest ?? await getApplicationSupportDirectory();

  /// Merkt den Wunsch vor. Die Texte gelten für die Meldung nach dem Neustart.
  static Future<void> merken({
    required String titel,
    required String text,
  }) async {
    // Nur Android hat den Empfänger. Auf allen anderen Plattformen wäre die
    // Datei ein Stück Müll ohne Leser.
    if (!_istAndroid) return;

    try {
      final datei = File('${(await _ordner()).path}/$dateiname');
      // Erste Zeile Titel, zweite Zeile Text. Zeilenumbrüche im Text würden
      // die Form zerreißen, also fallen sie zu Leerzeichen zusammen.
      await datei.writeAsString(
        '${_eineZeile(titel)}\n${_eineZeile(text)}\n',
      );
    } catch (e) {
      // Ohne die Datei entfällt nur die Meldung nach dem Neustart. Die
      // Aufzeichnung selbst hängt nicht daran — also kein Grund, den Start
      // der Aufzeichnung scheitern zu lassen.
      logger.warning(
        LogCategory.service,
        'Neustart-Hinweis konnte nicht hinterlegt werden',
        data: {'error': e.toString()},
      );
    }
  }

  /// Nimmt den Wunsch zurück. Nach einem bewussten Aus soll nach dem Neustart
  /// nichts dastehen.
  static Future<void> vergessen() async {
    if (!_istAndroid) return;

    try {
      final datei = File('${(await _ordner()).path}/$dateiname');
      if (datei.existsSync()) await datei.delete();
    } catch (e) {
      logger.warning(
        LogCategory.service,
        'Neustart-Hinweis konnte nicht entfernt werden',
        data: {'error': e.toString()},
      );
    }
  }

  /// Steht der Wunsch hinterlegt? Für Tests und zur Fehlersuche.
  static Future<bool> istHinterlegt() async {
    if (!_istAndroid) return false;
    return File('${(await _ordner()).path}/$dateiname').existsSync();
  }

  static String _eineZeile(String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// In Tests gilt Android, damit das Verhalten prüfbar bleibt — dort setzt
  /// [ordnerFuerTest] das Ziel.
  static bool get _istAndroid =>
      ordnerFuerTest != null || (!kIsWeb && Platform.isAndroid);
}
