import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/medication/widgets/reminder_permission_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Befund 1 des Gerätetests: die Erlaubnis fehlte, der Schalter stand auf
/// an, die Karte trug ein Weckersymbol — und geplant war nichts. Kein
/// Hinweis, nirgends.
Widget _rahmen(Widget child) => MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('Ohne offene Versprechen zeigt das Band nichts', (tester) async {
    await tester.pumpWidget(
      _rahmen(
        ReminderPermissionBanner(
          hasPermission: false,
          openPromises: 0,
          onRequest: () {},
        ),
      ),
    );
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('Mit Erlaubnis zeigt das Band nichts', (tester) async {
    await tester.pumpWidget(
      _rahmen(
        ReminderPermissionBanner(
          hasPermission: true,
          openPromises: 3,
          onRequest: () {},
        ),
      ),
    );
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('Ohne Erlaubnis und mit Versprechen erscheint das Band',
      (tester) async {
    var getippt = false;
    await tester.pumpWidget(
      _rahmen(
        ReminderPermissionBanner(
          hasPermission: false,
          openPromises: 3,
          onRequest: () => getippt = true,
        ),
      ),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));

    expect(find.byType(Card), findsOneWidget);
    expect(find.text(l10n.reminderPermissionMissingTitle), findsOneWidget);
    expect(find.textContaining('3'), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    expect(getippt, isTrue);
  });

  testWidgets('Das Band nennt die Zahl der offenen Einnahmezeiten',
      (tester) async {
    await tester.pumpWidget(
      _rahmen(
        ReminderPermissionBanner(
          hasPermission: false,
          openPromises: 7,
          onRequest: () {},
        ),
      ),
    );
    expect(find.textContaining('7'), findsOneWidget);
  });
}
