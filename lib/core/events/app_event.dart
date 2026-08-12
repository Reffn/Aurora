/// Basis-Klasse für alle Events in der App
abstract class AppEvent {
  AppEvent() : timestamp = DateTime.now();
  final DateTime timestamp;
}
