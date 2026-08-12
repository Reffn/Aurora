import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Splash liegt vor jeder anderen Oberflaeche. Faellt er aus, startet die
/// App nicht — und weil die CrashBoundary ueber der MaterialApp haengt, sieht
/// die Nutzerin nur Schwarz. Deshalb steht er hier unter Test.
void main() {
  group('SplashMaterialApp', () {
    testWidgets('loest AppLocalizations im Baum darunter auf', (tester) async {
      await tester.pumpWidget(const SplashMaterialApp());

      final context = tester.element(find.byType(Scaffold));
      expect(
        Localizations.of<AppLocalizations>(context, AppLocalizations),
        isNotNull,
        reason: 'AppLocalizations.of(context) wirft sonst beim Start',
      );

      // Splash abraeumen, sonst bleibt sein 3s-Timer offen
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('kennt dieselben Sprachen wie die Haupt-App', (tester) async {
      await tester.pumpWidget(const SplashMaterialApp());

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.localizationsDelegates, contains(AppLocalizations.delegate));
      expect(
        app.supportedLocales,
        containsAll(const [
          Locale('de'),
          Locale('en'),
          Locale('fr'),
          Locale('es'),
          Locale('it'),
        ]),
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
