import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Der zweite Onboarding-Schirm sagt „Keine Cloud-Sicherung". Hier steht,
/// was das Manifest dafür halten muss.
///
/// Am 13.08.2026 hielt es nichts davon. Im gebauten APK stand weder
/// `allowBackup` noch `dataExtractionRules` — und Androids Vorgabe ist
/// `true`. Das System sicherte damit das gesamte Datenverzeichnis in die
/// Google Drive des angemeldeten Kontos: Profile, Chatverläufe,
/// Tagebucheinträge, Medikamente, Notfallkontakte. In einer DIS-App ist
/// jeder dieser Punkte kontextbedingt ein Gesundheitsdatum (DSGVO Art. 9).
///
/// Gefunden wurde das nicht durch Lesen des Manifests — dort stand nichts,
/// und wonach man nicht sucht, findet man nicht. Bei
/// Plattform-Voreinstellungen ist die Abwesenheit die Aussage, und weder
/// ein Grep noch ein Test noch die Nutzerin sieht sie.
///
/// Deshalb dieser Test: Er sucht nach dem, was fehlen kann.
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

  /// Ohne Kommentarzeilen — sonst schlägt der Test an der Erklärung an,
  /// warum die Attribute dort stehen, und die Erklärung ist das, was den
  /// Rückfall beim nächsten Mal verhindert.
  String ohneKommentare(String quelle) =>
      quelle.replaceAll(RegExp('<!--.*?-->', dotAll: true), '');

  test('das Manifest schließt die Cloud-Sicherung aus', () {
    final manifest =
        ohneKommentare(lies('android/app/src/main/AndroidManifest.xml'));

    expect(
      manifest.contains('android:allowBackup="false"'),
      isTrue,
      reason: 'Ohne dieses Attribut gilt Androids Vorgabe `true`, und das '
          'gesamte Datenverzeichnis geht in die Google Drive. Der zweite '
          'Onboarding-Schirm verspricht das Gegenteil.',
    );
    expect(
      manifest.contains('android:fullBackupContent="false"'),
      isTrue,
      reason: 'Deckt die Geräte vor Android 12 mit ab.',
    );
  });

  test('das Manifest schließt auch den Gerätewechsel aus', () {
    final manifest =
        ohneKommentare(lies('android/app/src/main/AndroidManifest.xml'));

    expect(
      manifest.contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      isTrue,
      reason: '`allowBackup="false"` allein deckt ab Android 12 nur die '
          'Cloud-Sicherung. Die Gerät-zu-Gerät-Übertragung bleibt erlaubt, '
          'bis sie in den Extraktionsregeln ausgeschlossen wird.',
    );
  });

  test('die Extraktionsregeln schließen beide Wege für alle Bereiche aus', () {
    final regeln = ohneKommentare(
      lies('android/app/src/main/res/xml/data_extraction_rules.xml'),
    );

    for (final weg in ['cloud-backup', 'device-transfer']) {
      expect(
        regeln.contains('<$weg>'),
        isTrue,
        reason: 'Ohne den Abschnitt <$weg> gilt für diesen Weg die '
            'Voreinstellung, und die heißt: alles mitnehmen.',
      );
    }

    // `domain="root"` deckt das Datenverzeichnis nicht vollständig ab —
    // Hive-Boxen, Einstellungen und die Anhänge liegen in eigenen Bereichen,
    // und jeder nicht genannte Bereich fällt auf die Voreinstellung zurück.
    for (final bereich in [
      'root',
      'database',
      'sharedpref',
      'file',
      'external',
    ]) {
      expect(
        RegExp('<exclude\\s+domain="$bereich"').allMatches(regeln).length,
        2,
        reason: 'Der Bereich "$bereich" muss in beiden Wegen ausgeschlossen '
            'sein — einmal für die Cloud, einmal für den Gerätewechsel.',
      );
    }
  });

  test('die Zusage steht in allen fünf Sprachen und meint dasselbe', () {
    // Wenn dieser Test rot wird, weil der Satz umformuliert wurde: Die
    // Zusage ist richtig und ist der Grund für die App. Sie ist einzuhalten,
    // nicht zurückzunehmen.
    for (final sprache in ['de', 'en', 'es', 'fr', 'it']) {
      final arb = lies('lib/l10n/app_$sprache.arb');
      for (final schluessel in [
        'onboardingPrivacyBullet2',
        'onboardingPrivacyPoint2',
      ]) {
        expect(
          arb.contains('"$schluessel"'),
          isTrue,
          reason: 'Für $sprache fehlt $schluessel — die Zusage, an der die '
              'Manifest-Attribute in dieser Datei hängen.',
        );
      }
    }
  });
}
