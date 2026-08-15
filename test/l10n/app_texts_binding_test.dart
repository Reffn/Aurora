import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// [AppTexts] versorgt alles, was keinen BuildContext hat — allen voran die
/// Benachrichtigungen. Wechselt jemand die Sprache aus den Einstellungen
/// heraus, also aus einer Route über dem Anker, muss die Bindung mitziehen:
/// sonst tragen Erinnerungen weiter die alte Sprache, während die Oberfläche
/// schon umgestellt ist.
class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  Locale _locale = const Locale('es');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AppTextsBinding(
        child: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            // Die Einstellungen liegen als Route über dem Anker — von dort
            // aus wird die Sprache gewechselt.
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () =>
                        setState(() => _locale = const Locale('de')),
                    child: const Text('auf Deutsch'),
                  ),
                ),
              ),
            ),
            child: const Text('zu den Einstellungen'),
          ),
        ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('AppTexts folgt dem Sprachwechsel auch unter einer Route',
      (tester) async {
    await tester.pumpWidget(const _App());
    expect(AppTexts.current.localeName, 'es');

    await tester.tap(find.text('zu den Einstellungen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('auf Deutsch'));
    await tester.pumpAndSettle();

    expect(
      AppTexts.current.localeName,
      'de',
      reason: 'Sonst sprechen Benachrichtigungen die alte Sprache weiter',
    );
  });
}
