/// Zentrale Konstanten für alle Hive Box-Namen
/// Verhindert Magic Strings und Tippfehler
class HiveBoxNames {
  // Private Constructor - nur static members
  HiveBoxNames._();

  // Data Boxes
  static const String chatMessages = 'chat_messages';
  static const String profiles = 'profiles';
  static const String calendarEvents = 'calendar_events';
  static const String medications = 'medications';
  static const String medicationLogs = 'medication_logs';
  static const String contacts = 'contacts';
  static const String contactRatings = 'contact_ratings';
  static const String contactComments = 'contact_comments';
  static const String finderItems = 'finder_items';
  static const String diaryEntries = 'diary_entries';
  static const String diaryComments = 'diary_comments';
  static const String locationHistory = 'location_history';

  /// Profilwechsel-Ereignisse.
  ///
  /// Der Name lautete hier einmal `profile_switches`, geöffnet wurde die Box
  /// aber als `switch_events`. Diese Konstante zeigte damit auf eine Box, die
  /// es nie gab — und der Notfall-Reset löschte genau diese. Die
  /// Wechselhistorie überlebte jedes „Alle Daten löschen". Der alte Name
  /// steht unten weiter, damit Geräte aus dieser Zeit ihn trotzdem loswerden.
  static const String profileSwitches = 'switch_events';
  static const String notificationQueue = 'notification_queue';
  static const String transmissionLog = 'transmission_log';
  static const String telemetryQueue = 'telemetry_queue';

  // Unified Comment System (replaces diaryComments, contactComments)
  static const String comments = 'comments';

  // Settings Box (untyped)
  static const String settings = 'settings';

  /// Namen, die die App nicht mehr benutzt, die auf Geräten aber noch
  /// liegen können. Sie werden nur noch gelöscht, nie geöffnet.
  static const List<String> legacy = <String>['profile_switches'];
}
