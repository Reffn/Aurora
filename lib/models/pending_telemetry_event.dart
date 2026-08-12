import 'package:hive_ce/hive.dart';

part 'pending_telemetry_event.g.dart';

/// Ein erzeugtes, noch nicht gesendetes Telemetrie-Ereignis.
///
/// Liegt ausschliesslich lokal. Existiert nur auf Geraeten mit erteilter
/// Einwilligung — ohne sie wird gar nichts erst angelegt.
///
/// Feldreihenfolge nach dem Anlegen nie aendern — der Custom-Lint
/// `hive_field_order_check` erzwingt das, weil sonst bestehende Daten falsch
/// gelesen wuerden.
@HiveType(typeId: 35)
class PendingTelemetryEvent extends HiveObject {
  PendingTelemetryEvent({
    required this.id,
    required this.eventName,
    required this.day,
    required this.appVersion,
    required this.dueAt,
  });

  @HiveField(0)
  final String id;

  /// Der stabile Schluessel aus `TelemetryEventName.wireName`.
  @HiveField(1)
  final String eventName;

  /// `YYYY-MM-DD`. Bewusst als String und nicht als DateTime: ein DateTime
  /// truege eine Uhrzeit mit, und genau die soll das Geraet nie verlassen.
  @HiveField(2)
  final String day;

  @HiveField(3)
  final String appVersion;

  /// Wann fruehestens gesendet werden darf. Gewuerfelt bei der Erzeugung.
  /// Bleibt lokal — der Server erfaehrt nie, wann das Ereignis entstand.
  @HiveField(4)
  final DateTime dueAt;
}
