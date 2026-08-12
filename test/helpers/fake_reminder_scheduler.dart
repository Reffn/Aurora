import 'dart:async';

import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:dis_app/services/reminders/reminder_scheduler.dart';

/// Merkt sich, was angemeldet und abgemeldet wurde — ohne Plattform.
class FakeReminderScheduler implements ReminderScheduler {
  final Map<int, Reminder?> scheduled = {};
  final List<int> cancelled = [];
  final List<String> bodies = [];
  final List<String> titles = [];
  bool cancelAllCalled = false;
  int shownNow = 0;

  /// Wirft ab dieser Anzahl erfolgreicher Anmeldungen — für Teilausfälle.
  int? failAfter;

  /// Hält die erste Anmeldung an, bis jemand das Tor öffnet.
  ///
  /// So lässt sich ein zweiter Aufruf mitten in einem laufenden Abgleich
  /// platzieren, ohne auf Zeitverhalten zu bauen.
  Completer<void>? gate;

  /// Wird erfüllt, sobald der Abgleich am Tor wartet.
  final Completer<void> gateReached = Completer<void>();

  int scheduleCalls = 0;

  /// Vorbelegung für den Ist-Zustand, etwa um Karteileichen zu prüfen.
  void seed(int id) => scheduled[id] = null;

  @override
  Future<Set<int>> pendingOwnIds() async =>
      scheduled.keys.where(isOwnId).toSet();

  @override
  Future<void> schedule(
    Reminder reminder, {
    required String title,
    required String body,
  }) async {
    final tor = gate;
    if (tor != null && !tor.isCompleted) {
      if (!gateReached.isCompleted) gateReached.complete();
      await tor.future;
    }
    if (failAfter != null && scheduleCalls >= failAfter!) {
      throw StateError('Scheduler-Ausfall im Test');
    }
    scheduleCalls++;
    scheduled[reminderId(reminder)] = reminder;
    titles.add(title);
    bodies.add(body);
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<void> cancelEverything() async {
    cancelAllCalled = true;
    cancelled.addAll(scheduled.keys);
    scheduled.clear();
  }

  @override
  Future<void> showNow({required String title, required String body}) async {
    shownNow++;
  }
}
