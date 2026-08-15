import 'dart:io';

import 'package:dis_app/core/logger.dart';
import 'package:hive_ce/hive.dart';
import 'package:in_app_update/in_app_update.dart';

/// Fragt Play, ob eine neuere Fassung bereitliegt, und bietet sie an.
///
/// **Warum das überhaupt gebaut wird, obwohl die Messung dagegen spricht.**
/// Play verteilt zuverlässig: Am 7. August 2026 saßen 39 von 39 aktiven
/// Geräten auf derselben Fassung, keines auf einer älteren. Was bleibt, ist
/// die Lücke von Tagen zwischen dem Hochladen und dem Zeitpunkt, an dem Play
/// von selbst zieht. Bei einem Fehler, der Erinnerungen verschluckt oder die
/// App beim Update abstürzen lässt, ist genau diese Lücke der Unterschied.
///
/// **Nur der flexible Weg.** Der zwingende Fluss von Play blockiert die App
/// bis zum Abschluss. Bei einer Anwendung, die auch im dissoziativen Zustand
/// geöffnet wird, wäre ein Vollbild, aus dem man nicht herauskommt, die
/// falsche Antwort — Richtlinie 10 verlangt einen Ausgang aus jedem Ablauf.
///
/// **Der seitlich geladene Bau ist der Normalfall auf den eigenen Geräten.**
/// Play kennt das Paket dann nicht und die Abfrage wirft. Das wird geschluckt
/// und vermerkt, nicht weitergereicht: Der Start der App hängt nicht davon ab,
/// ob ein Store erreichbar ist.
class AppUpdateNudge {
  AppUpdateNudge({
    required Future<bool> Function() hasUpdate,
    required Future<void> Function() startUpdate,
    required Future<bool> Function() hasDownloadedUpdate,
    required Future<void> Function() completeUpdate,
    required String? Function() readLastAsked,
    required Future<void> Function(String value) writeLastAsked,
    required DateTime Function() now,
    bool Function()? isSupportedPlatform,
    Duration interval = const Duration(days: 7),
  }) : _isSupportedPlatform = isSupportedPlatform ?? _immer,
       _hasUpdate = hasUpdate,
       _startUpdate = startUpdate,
       _hasDownloadedUpdate = hasDownloadedUpdate,
       _completeUpdate = completeUpdate,
       _read = readLastAsked,
       _write = writeLastAsked,
       _now = now,
       _interval = interval;

  /// Der Weg für die App: Play über `in_app_update`, Merker in der
  /// `settings`-Box.
  factory AppUpdateNudge.fromBox(Box<dynamic> settingsBox) {
    return AppUpdateNudge(
      hasUpdate: () async {
        final info = await InAppUpdate.checkForUpdate();
        return info.updateAvailability == UpdateAvailability.updateAvailable;
      },
      startUpdate: InAppUpdate.startFlexibleUpdate,
      hasDownloadedUpdate: () async {
        final info = await InAppUpdate.checkForUpdate();
        return info.installStatus == InstallStatus.downloaded;
      },
      completeUpdate: InAppUpdate.completeFlexibleUpdate,
      readLastAsked: () => settingsBox.get(storageKey) as String?,
      writeLastAsked: (value) => settingsBox.put(storageKey, value),
      now: DateTime.now,
      // Play Core gibt es nur auf Android. Die Prüfung steht hier und nicht
      // in der Logik darunter: Sonst wäre die Klasse auf dem Rechner, auf dem
      // die Tests laufen, dauerhaft stumm — und die Tests bewiesen nur, dass
      // sie schweigt.
      isSupportedPlatform: () => Platform.isAndroid,
    );
  }

  static const String storageKey = 'update_nudge_last_asked';

  static bool _immer() => true;

  final bool Function() _isSupportedPlatform;
  final Future<bool> Function() _hasUpdate;
  final Future<void> Function() _startUpdate;
  final Future<bool> Function() _hasDownloadedUpdate;
  final Future<void> Function() _completeUpdate;
  final String? Function() _read;
  final Future<void> Function(String value) _write;
  final DateTime Function() _now;
  final Duration _interval;

  /// Prüft höchstens einmal je Frist und startet bei Bedarf den flexiblen
  /// Fluss.
  ///
  /// Gibt zurück, ob der Fluss gestartet wurde — für Tests und Protokoll, nicht
  /// für die Oberfläche.
  Future<bool> maybePrompt() async {
    if (!_istFrisch()) return false;

    final jetzt = _now();

    // Der Vermerk kommt vor der Abfrage, nicht danach. Sonst liefe bei jedem
    // Start eine Abfrage ins Leere, sobald sie einmal fehlschlägt.
    await _write(jetzt.toIso8601String());

    try {
      if (!await _hasUpdate()) return false;

      await _startUpdate();
      logger.info(LogCategory.service, 'Flexibles Update angeboten');
      return true;
    } catch (e) {
      // Kein `error`: Auf einem seitlich geladenen Bau ist das der erwartete
      // Ausgang, kein Fehler der App.
      logger.info(
        LogCategory.service,
        'Update-Abfrage nicht möglich',
        data: {'grund': e.toString()},
      );
      return false;
    }
  }

  /// Schließt ein bereits geladenes Update ab — nur aufzurufen, während die
  /// App im Hintergrund ist.
  ///
  /// Ohne diesen Schritt passiert nichts: Ein flexibles Update bleibt auf
  /// `DOWNLOADED` stehen, Play installiert es **nicht** von selbst. Die
  /// Anleitung von Google verlangt ausdrücklich, bei jedem Eintritt in die App
  /// nachzusehen und zum Neustart aufzufordern.
  ///
  /// Genau diese Aufforderung wird hier nicht gebaut. Im Vordergrund gerufen,
  /// zeigt die Plattform ein Vollbild und startet die App neu — bei einer
  /// Anwendung, die auch im dissoziativen Zustand offen ist, wäre das ein
  /// Abbruch mitten in der Handlung. Dieselbe Anleitung nennt den Ausweg:
  ///
  /// > „If you instead call `completeUpdate()` when your app is in the
  /// > background, the update is installed silently without obscuring the
  /// > device UI."
  ///
  /// Also wird im Moment des Verlassens abgeschlossen. Niemand wird
  /// unterbrochen, und beim nächsten Öffnen läuft die neue Fassung.
  Future<bool> completeIfDownloaded() async {
    if (!_isSupportedPlatform()) return false;

    try {
      if (!await _hasDownloadedUpdate()) return false;

      await _completeUpdate();
      logger.info(LogCategory.service, 'Geladenes Update still abgeschlossen');
      return true;
    } catch (e) {
      logger.info(
        LogCategory.service,
        'Update konnte nicht abgeschlossen werden',
        data: {'grund': e.toString()},
      );
      return false;
    }
  }

  bool _istFrisch() {
    if (!_isSupportedPlatform()) return false;

    final gespeichert = _read();
    if (gespeichert == null) return true;

    final zuletzt = DateTime.tryParse(gespeichert);
    // Unlesbar heißt „noch nie" — raten wäre schlimmer als einmal zu viel
    // fragen.
    if (zuletzt == null) return true;

    return _now().difference(zuletzt) >= _interval;
  }
}
