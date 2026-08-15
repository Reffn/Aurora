import 'package:dis_app/core/startup_locale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Die gewählte Sprache muss den Ladebildschirm erreichen.
///
/// Sie liegt in der Einstellungs-Kiste, und die öffnet erst mit den Diensten
/// — also nach dem Ladebildschirm. Der sprach deshalb die Systemsprache: Auf
/// einem englischen Gerät stand dort „Aurora is loading", während die App
/// danach auf Deutsch weiterlief. Am 11. August 2026 am S24 gesehen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ohne gemerkte Wahl bleibt es bei der Systemsprache', () async {
    SharedPreferences.setMockInitialValues({});

    await StartupLocale.laden();

    expect(
      StartupLocale.locale,
      isNull,
      reason: 'Ohne Wahl darf keine Sprache vorgetäuscht werden.',
    );
  });

  test('die gemerkte Wahl steht beim nächsten Start bereit', () async {
    SharedPreferences.setMockInitialValues({});

    await StartupLocale.merken('es');
    // Ein neuer Start: nichts im Speicher, alles von der Platte.
    await StartupLocale.laden();

    expect(StartupLocale.locale, const Locale('es'));
  });

  test('eine spätere Wahl ersetzt die frühere', () async {
    SharedPreferences.setMockInitialValues({'selected_locale': 'de'});

    await StartupLocale.laden();
    expect(StartupLocale.locale, const Locale('de'));

    await StartupLocale.merken('fr');
    await StartupLocale.laden();

    expect(StartupLocale.locale, const Locale('fr'));
  });
}
