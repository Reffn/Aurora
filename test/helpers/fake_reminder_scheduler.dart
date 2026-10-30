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

  /// Was schon in der Leiste steht: Kennung → Schlüssel (auf Android der Tag).
  ///
  /// Verhält sich wie Android: Ein `cancel` ohne Tag lässt eine getaggte
  /// Meldung stehen, nur [dismiss] mit dem richtigen Schlüssel räumt sie ab.
  /// Die erste Fassung dieser Attrappe lieferte eine Payload, die das echte
  /// Plugin auf Android nie liefert — die Tests waren grün, am A14 blieb die
  /// Meldung stehen.
  final Map<int, String?> shown = {};
  final List<int> dismissed = [];

  /// Vorbelegung für den Ist-Zustand, etwa um Karteileichen zu prüfen.
  void seed(int id) => scheduled[id] = null;

  /// Eine Meldung, die schon gefeuert hat und angezeigt wird.
  void show(int id, String? key) => shown[id] = key;

  @override
  Future<Set<int>> pendingOwnIds() async =>
      scheduled.keys.where(isOwnId).toSet();

  @override
  Future<Map<int, String?>> shownOwn() async => {
    for (final entry in shown.entries)
      if (isOwnId(entry.key)) entry.key: entry.value,
  };

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
  Future<void> dismiss(int id, {required String key}) async {
    if (shown[id] != key) return;
    dismissed.add(id);
    shown.remove(id);
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
