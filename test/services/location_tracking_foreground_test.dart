import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Die Wegaufzeichnung darf nicht wieder in den App-Prozess zurückfallen.
///
/// Bis zum 8. August 2026 lief sie an einem `Timer.periodic`. Der stirbt mit
/// dem Prozess — weggewischt, Speicherdruck, Doze —, während die Einstellungen
/// „funktioniert auch im Hintergrund" versprachen. Wer nach einer Dissoziation
/// wissen wollte, wo er war, fand ein Loch und erfuhr nie, warum.
///
/// Am Gerät ist das prüfbar, im Testlauf nicht: Kein Widget-Test hält einen
/// Android-Vordergrunddienst am Leben. Was hier steht, sind deshalb die drei
/// Bedingungen, unter denen der Dienst überhaupt laufen **kann** — jede
/// einzelne war schon einmal die, die fehlte.
void main() {
  String lies(String pfad) {
    final datei = File(pfad);
    expect(
      datei.existsSync(),
      isTrue,
      reason: 'Datei nicht gefunden: $pfad — wurde sie verschoben?',
    );
    return datei.readAsStringSync();
  }

  /// Ohne Kommentarzeilen.
  ///
  /// Sonst schlägt der Test an der Erklärung an, warum der Timer weg musste —
  /// und die Erklärung ist das, was ihn beim nächsten Mal verhindert.
  String nurCode(String quelle) => quelle
      .split('\n')
      .where((zeile) {
        final t = zeile.trimLeft();
        return !t.startsWith('//');
      })
      .join('\n');

  test('die Aufzeichnung hängt nicht an einem Timer im App-Prozess', () {
    final quelle = nurCode(lies('lib/services/location_tracking_service.dart'));

    expect(
      quelle.contains('Timer.periodic'),
      isFalse,
      reason: 'Ein Timer im App-Prozess stirbt mit der App. '
          'Die Aufzeichnung gehört an den Positionsstrom.',
    );
    expect(
      quelle.contains('positionStream('),
      isTrue,
      reason: 'Ohne den Strom des GpsManager gibt es keinen '
          'Vordergrunddienst und damit keine Aufzeichnung im Hintergrund.',
    );
  });

  test('der Strom trägt die Vordergrund-Benachrichtigung', () {
    final quelle = lies('lib/services/gps_manager.dart');

    expect(
      quelle.contains('foregroundNotificationConfig'),
      isTrue,
      reason: 'Ohne diese Angabe startet geolocator keinen Dienst, und '
          'Android beendet den Prozess wie jeden anderen.',
    );
    expect(
      quelle.contains('notificationTitle:'),
      isTrue,
      reason: 'Die Benachrichtigung ist die sichtbare Zusage — '
          'aufgezeichnet wird nur, solange sie steht.',
    );
  });

  test('die Einstellungen fragen den Laufzustand, nicht den Wunsch', () {
    // Der vierte Weg, auf dem die Aufzeichnung schon stillstand: Die
    // Einstellungen lasen `gps_tracking_enabled` — den Wunsch. Der bleibt
    // absichtlich `true`, wenn der Positionsstrom abbricht, damit beim
    // nächsten Start wieder angelaufen wird. Wer danach „immer aufzeichnen"
    // bestätigte, traf auf einen Wunsch, der schon stand, und es passierte
    // nichts.
    //
    // Am Gerät ist das prüfbar, im Testlauf nicht: Der Dienst hat keine
    // Testvorrichtung, er braucht drei Hive-Boxen, den EventBus, die
    // Geokodierung und echtes GPS. Deshalb steht hier die strukturelle
    // Bedingung — dieselbe Form wie die drei Tests darüber.
    final quelle = nurCode(lies('lib/modules/settings/settings_screen.dart'));

    expect(
      quelle.contains('gps_tracking_enabled'),
      isFalse,
      reason: 'Der Wunsch gehört dem LocationTrackingService. Wer ihn hier '
          'liest, verwechselt ihn früher oder später mit dem Laufzustand.',
    );
    expect(
      quelle.contains('isTrackingRunning.value'),
      isTrue,
      reason: 'Vor dem Starten muss die Frage lauten: läuft es gerade? '
          'Nicht: ist es gewünscht?',
    );
  });

  test('das Manifest erlaubt den Dienst', () {
    final manifest = lies('android/app/src/main/AndroidManifest.xml');

    // geolocator_android deklariert den Dienst selbst, aber keine
    // Berechtigung dafür. Ohne die zweite Zeile wirft Android 14 beim
    // Starten eine SecurityException — und zwar erst am Gerät.
    expect(
      manifest.contains('android.permission.FOREGROUND_SERVICE"'),
      isTrue,
      reason: 'FOREGROUND_SERVICE fehlt im Manifest',
    );
    expect(
      manifest.contains('android.permission.FOREGROUND_SERVICE_LOCATION'),
      isTrue,
      reason: 'FOREGROUND_SERVICE_LOCATION fehlt — auf Android 14 Pflicht',
    );
  });

  test('der Schalter haengt nicht mehr an „Immer erlauben"', () {
    // Am Geraet gefunden, nachdem der Vordergrunddienst stand: Die
    // Einstellungen zeigten „Nur waehrend der Nutzung" als gelbe Warnung, der
    // Schalter blieb gesperrt und verlangte eine Freigabe, die es seit dem
    // Umbau gar nicht mehr zu erteilen gibt. Die Aufzeichnung war damit
    // unerreichbar — genau die Funktion, um die es bei dem Umbau ging.
    final einstellungen = nurCode(lies('lib/modules/settings/settings_screen.dart'));

    // Anzeigen darf die Flaeche den echten Systemstand — „Immer erlaubt" und
    // „Bei Nutzung erlaubt" sind zwei verschiedene Dinge, und es waere gelogen,
    // beide gleich zu nennen. Verboten ist, eine Entscheidung daran zu
    // haengen: der Schalter, der Erfolgszustand, die Auffrischung vor dem
    // Start.
    for (final verboten in [
      'hasAlwaysPermission &&',
      '&& _gpsManager.hasAlwaysPermission',
      'refreshAndCheckAlwaysPermission',
    ]) {
      expect(
        einstellungen.contains(verboten),
        isFalse,
        reason: 'Die Einstellungen entscheiden wieder ueber '
            '„$verboten". Der Vordergrunddienst laeuft mit „Bei Nutzung '
            'erlauben" — ACCESS_BACKGROUND_LOCATION ist aus dem Manifest, '
            'die Freigabe kann niemand mehr erteilen, und der Schalter '
            'bliebe fuer immer gesperrt.',
      );
    }
    expect(einstellungen, contains('hasTrackingPermission'));
  });

  test('hasTrackingPermission laesst „Bei Nutzung" gelten', () {
    final manager = nurCode(lies('lib/services/gps_manager.dart'));

    expect(manager, contains('bool get hasTrackingPermission'));
    expect(
      manager,
      contains('hasAlwaysPermission || hasWhileInUsePermission'),
      reason: 'Wuerde hier nur „always" gelten, waere der Schalter wieder '
          'fuer immer gesperrt.',
    );
  });

  test('die Benachrichtigung steht in allen fünf Sprachen', () {
    for (final sprache in ['de', 'en', 'es', 'fr', 'it']) {
      final arb = lies('lib/l10n/app_$sprache.arb');
      for (final schluessel in [
        'locationTrackingNotificationTitle',
        'locationTrackingNotificationBody',
      ]) {
        expect(
          arb.contains('"$schluessel"'),
          isTrue,
          reason: 'Für $sprache fehlt $schluessel. Eine Benachrichtigung, '
              'die dauerhaft in der Leiste steht, in der falschen Sprache '
              'ist schlimmer als keine.',
        );
      }
    }
  });
}
