import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Wer beim Betriebssystem anmeldet und abmeldet.
///
/// Die Schnittstelle existiert, damit die Regeln und der Abgleich ohne
/// Plattform prüfbar sind — und damit es genau einen Ort gibt, an dem
/// `flutter_local_notifications` benutzt wird. Eine Lint-Regel hält das
/// durch.
abstract class ReminderScheduler {
  /// Was das Betriebssystem gerade vorgemerkt hat — beide Namensräume
  /// des Abgleichs. Fremdes bleibt unangetastet.
  Future<Set<int>> pendingOwnIds();

  Future<void> schedule(
    Reminder reminder, {
    required String title,
    required String body,
  });

  Future<void> cancel(int id);

  /// Alles abmelden. Nur für die einmalige Migration gedacht.
  ///
  /// Heißt bewusst nicht `cancelAll` — diesen Namen trägt die Methode des
  /// Plugins, und die Lint-Regel erkennt Planungsaufrufe am Namen. Zwei
  /// gleich benannte Methoden auf verschiedenen Empfängern hätte sie nicht
  /// auseinanderhalten können.
  Future<void> cancelEverything();

  /// Sofort anzeigen, ohne Alarm. Für die Testmeldung in den Einstellungen.
  Future<void> showNow({required String title, required String body});
}

class PluginReminderScheduler implements ReminderScheduler {
  PluginReminderScheduler(
    this._plugin, {
    required this.channelId,
    required this.channelName,
  });

  /// Für die Verdrahtung: baut sich das Plugin selbst.
  ///
  /// `FlutterLocalNotificationsPlugin()` ist ein Fabrik-Konstruktor auf eine
  /// gemeinsame Instanz — es entsteht kein zweites Plugin. Der Umweg
  /// existiert, damit `injection.dart` das Paket nicht importieren muss und
  /// die Lint-Regel sauber durchläuft.
  PluginReminderScheduler.forApp({
    required this.channelId,
    required this.channelName,
  }) : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final String channelId;
  final String channelName;

  NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  @override
  Future<Set<int>> pendingOwnIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((p) => p.id).where(isOwnId).toSet();
  }

  @override
  Future<void> schedule(
    Reminder reminder, {
    required String title,
    required String body,
  }) async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Ohne die Freigabe für genaue Alarme wirft Android die Planung
    // zurück. Ungenau geplant kommt die Meldung ein paar Minuten später —
    // besser als gar nicht.
    final exact = await android?.canScheduleExactNotifications() ?? false;

    await _plugin.zonedSchedule(
      reminderId(reminder),
      title,
      body,
      tz.TZDateTime.from(reminder.fireAt, tz.local),
      _details,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      // Kein `matchDateTimeComponents`.
      //
      // Der Entwurf sah dafür eine täglich wiederkehrende Grundmeldung vor.
      // Auf dem Gerät zeigte sich, dass die Option das übergebene Datum
      // schlicht ignoriert und auf die nächste passende Uhrzeit schnappt:
      // Vitamin D war um 12:22 als genommen markiert, der Anker stand auf
      // morgen 15:00, und im Alarmspeicher lag heute 15:00. „Heute
      // überspringen" lässt sich damit nicht ausdrücken. Deshalb sind alle
      // Meldungen Einzeltermine; die Meldung zur Einnahmezeit wird dafür
      // sieben Tage im Voraus vorgemerkt.
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: reminder.target.seed,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelEverything() => _plugin.cancelAll();

  @override
  Future<void> showNow({required String title, required String body}) =>
      _plugin.show(999999, title, body, _details);
}
