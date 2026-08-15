import 'package:dis_app/core/event_bus.dart';

/// Abstrakte Basisklasse für alle Services
/// Definiert gemeinsame Lifecycle-Methoden und Event-Bus-Zugriff
///
/// Implementierung (Template Method Pattern):
/// 1. Constructor erhält EventBus via DI
/// 2. initialize() ruft openBoxes() und subscribeToEvents() auf
/// 3. dispose() ruft closeBoxes() auf
///
/// Subclasses müssen nur die 3 abstrakten Methoden implementieren:
/// - openBoxes(): Hive Boxes öffnen
/// - subscribeToEvents(): EventBus-Subscriptions registrieren
/// - closeBoxes(): Hive Boxes schließen
abstract class BaseService {
  BaseService(this.eventBus);

  /// EventBus für Event-basierte Kommunikation
  /// Protected - nur für Subclasses sichtbar
  final EventBus eventBus;

  /// Service initialisieren
  /// Template Method: Ruft openBoxes(), postInitialize() und subscribeToEvents() in korrekter Reihenfolge auf
  Future<void> initialize() async {
    await openBoxes();
    await postInitialize();
    subscribeToEvents();
  }

  /// Hive Boxes öffnen
  /// Muss von Subclass implementiert werden
  Future<void> openBoxes();

  /// Custom-Initialisierung nach Box-Opening
  /// Optional - nur überschreiben wenn zusätzliche Initialisierung nötig ist
  /// (z.B. Plugin-Setup, das auf geöffnete Boxes zugreift)
  Future<void> postInitialize() async {}

  /// Event-Subscriptions registrieren
  /// Muss von Subclass implementiert werden
  void subscribeToEvents();

  /// Hive Boxes schließen
  /// Muss von Subclass implementiert werden
  Future<void> closeBoxes();

  /// Service aufräumen
  /// Template Method: Ruft closeBoxes() auf
  Future<void> dispose() async {
    await closeBoxes();
  }
}
