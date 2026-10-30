import 'dart:io';
import 'dart:typed_data';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/onboarding/pre_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/temp_hive.dart';
import '../support/text_scale_harness.dart';

/// Die Willkommensseite vor dem ersten Profil sagt „Keine Cloud-Sicherung".
/// Hier steht, was das Manifest dafür halten muss — und dass der Satz dort
/// auch wirklich steht.
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
    final manifest = ohneKommentare(
      lies('android/app/src/main/AndroidManifest.xml'),
    );

    expect(
      manifest.contains('android:allowBackup="false"'),
      isTrue,
      reason:
          'Ohne dieses Attribut gilt Androids Vorgabe `true`, und das '
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
    final manifest = ohneKommentare(
      lies('android/app/src/main/AndroidManifest.xml'),
    );

    expect(
      manifest.contains(
        'android:dataExtractionRules="@xml/data_extraction_rules"',
      ),
      isTrue,
      reason:
          '`allowBackup="false"` allein deckt ab Android 12 nur die '
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
        reason:
            'Ohne den Abschnitt <$weg> gilt für diesen Weg die '
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
        reason:
            'Der Bereich "$bereich" muss in beiden Wegen ausgeschlossen '
            'sein — einmal für die Cloud, einmal für den Gerätewechsel.',
      );
    }
  });

  // Die Zusage muss man lesen können, nicht nur übersetzt haben. Bis 3.0.24
  // prüfte dieser Test nur, dass der Satz in den ARB-Dateien steht — als die
  // Datenschutzseite mit dem kurzen Einstieg entfiel, blieb er grün, während
  // der Satz nirgends mehr angezeigt wurde. Jetzt muss er auf der
  // Willkommensseite vor dem ersten Profil stehen, in jeder Sprache, ohne
  // Scrollen.
  //
  // Wenn dieser Test rot wird, weil der Satz umformuliert wurde: Die Zusage
  // ist richtig und ist der Grund für die App. Sie ist einzuhalten, nicht
  // zurückzunehmen.
  group('Willkommensseite', () {
    late Box<dynamic> settings;

    // Im Arbeitsspeicher und außerhalb der Testzone geöffnet: Echte
    // Datei-Ein-/Ausgabe kommt in `testWidgets` nicht zurück. Der Schirm
    // öffnet `settings` selbst und bekommt so diese Box.
    setUp(() async {
      await openTempBox<dynamic>('hive_init_cloud');
      settings = await Hive.openBox<dynamic>('settings', bytes: Uint8List(0));
    });

    tearDown(() async {
      await settings.close();
    });

    for (final sprache in ['de', 'en', 'es', 'fr', 'it']) {
      testWidgets(
        'die Zusage steht sichtbar auf der Willkommensseite ($sprache)',
        (
          tester,
        ) async {
          final l10n = await AppLocalizations.delegate.load(Locale(sprache));

          await pumpScaled(
            tester,
            Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: const PreOnboardingScreen(),
              ),
            ),
            locale: Locale(sprache),
            deviceSize: geraetA14.size,
            pixelRatio: geraetA14.ratio,
            settle: false,
          );
          await tester.pump(const Duration(milliseconds: 100));

          final zusage = find.text(l10n.onboardingPrivacyBullet2);
          expect(
            zusage,
            findsOneWidget,
            reason:
                'Für $sprache steht die Zusage nicht auf der Willkommensseite '
                '— an ihr hängen die Manifest-Attribute in dieser Datei.',
          );
          expectFullyVisible(tester, zusage);
        },
      );
    }
  });
}
