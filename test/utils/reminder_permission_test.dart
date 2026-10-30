import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:dis_app/utils/reminder_permission.dart';
import 'package:dis_app/widgets/reminder_permission_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sechs Ablehnungen auf acht geplante Erinnerungen: Der nackte Systemdialog
/// sprang mitten ins Speichern, ohne ein Wort davor. Seit dieser Änderung
/// erklärt Aurora zuerst selbst, und erst ein „Ja" ruft das System.
///
/// Der Dienst wird hier durch eine Attrappe ersetzt, die zählt, wie oft das
/// System gefragt wurde. Nie `setupDependencyInjection()` — der kehrt im
/// Test nicht zurück.
class _FakeNotificationService extends NotificationService {
  _FakeNotificationService({this.systemGrants = false}) : super(EventBus());

  final bool systemGrants;
  int requestCalls = 0;

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermissions() async {
    requestCalls++;
    return systemGrants;
  }

  @override
  Future<bool> canScheduleExactly() async => true;
}

Widget _app(Widget home) => MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

/// Ein Schirm mit einem Knopf, der die Erlaubnis einholt — wie der Schalter
/// im Medikamentenformular.
class _Ausloeser extends StatefulWidget {
  const _Ausloeser({this.uninvited = false});

  final bool uninvited;

  @override
  State<_Ausloeser> createState() => _AusloeserState();
}

class _AusloeserState extends State<_Ausloeser> {
  ReminderPermissionOutcome? outcome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const ValueKey('ausloeser'),
          onPressed: () async {
            final result = await askReminderPermission(
              context,
              uninvited: widget.uninvited,
            );
            setState(() => outcome = result);
          },
          child: Text(outcome?.name ?? 'offen'),
        ),
      ),
    );
  }
}

void main() {
  final de = lookupAppLocalizations(const Locale('de'));
  late _FakeNotificationService fake;

  setUp(() {
    fake = _FakeNotificationService();
    getIt.registerSingleton<NotificationService>(fake);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> ausloesen(WidgetTester tester, {bool uninvited = false}) async {
    await tester.pumpWidget(_app(_Ausloeser(uninvited: uninvited)));
    await tester.tap(find.byKey(const ValueKey('ausloeser')));
    await tester.pumpAndSettle();
  }

  testWidgets('Auroras Erklärung kommt vor dem Systemdialog', (tester) async {
    await ausloesen(tester);

    expect(find.text(de.reminderAskTitle), findsOneWidget);
    expect(
      fake.requestCalls,
      0,
      reason: 'Das System darf erst nach einem Ja gefragt werden',
    );
  });

  testWidgets('jede Wahl trägt Symbol und Wort', (tester) async {
    await ausloesen(tester);

    final ja = find.byKey(const ValueKey('reminder-sheet-yes'));
    final nein = find.byKey(const ValueKey('reminder-sheet-not-now'));
    expect(ja, findsOneWidget);
    expect(nein, findsOneWidget);
    expect(
      find.descendant(of: ja, matching: find.byType(Icon)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nein, matching: find.byType(Icon)),
      findsOneWidget,
    );
    // Bedienziel-Untergrenze aus den Oberflächen-Richtlinien (Regel 6).
    expect(tester.getSize(ja).height, greaterThanOrEqualTo(56));
    expect(tester.getSize(nein).height, greaterThanOrEqualTo(56));
  });

  testWidgets('„Jetzt nicht" fragt das System nicht', (tester) async {
    await ausloesen(tester);

    await tester.tap(find.byKey(const ValueKey('reminder-sheet-not-now')));
    await tester.pumpAndSettle();

    expect(fake.requestCalls, 0);
    expect(find.text(de.reminderAskTitle), findsNothing);
    expect(
      find.text(ReminderPermissionOutcome.declinedByPerson.name),
      findsOneWidget,
    );
  });

  testWidgets('„Ja" ruft den Systemdialog genau einmal', (tester) async {
    await getIt.reset();
    fake = _FakeNotificationService(systemGrants: true);
    getIt.registerSingleton<NotificationService>(fake);

    await ausloesen(tester);
    await tester.tap(find.byKey(const ValueKey('reminder-sheet-yes')));
    await tester.pumpAndSettle();

    expect(fake.requestCalls, 1);
    expect(
      find.text(ReminderPermissionOutcome.granted.name),
      findsOneWidget,
    );
  });

  testWidgets('nach einem Nein des Systems: ruhiges Blatt, kein Band',
      (tester) async {
    await ausloesen(tester);
    await tester.tap(find.byKey(const ValueKey('reminder-sheet-yes')));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
    expect(find.text(de.reminderDeniedBody), findsOneWidget);
    expect(find.byKey(const ValueKey('reminder-sheet-settings')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reminder-sheet-later')));
    await tester.pumpAndSettle();
    expect(
      find.text(ReminderPermissionOutcome.deniedBySystem.name),
      findsOneWidget,
    );
  });
  testWidgets('Detailseite: eigener Satz statt „Gespeichert wird trotzdem"',
      (tester) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: ReminderNotAllowedRow(
            message: 'Aurora darf gerade nicht erinnern',
            onRequest: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aurora darf gerade nicht erinnern'), findsOneWidget);
    expect(find.textContaining('Gespeichert wird trotzdem'), findsNothing);
    expect(find.byKey(const ValueKey('reminder-form-request')), findsOneWidget);
  });
}
