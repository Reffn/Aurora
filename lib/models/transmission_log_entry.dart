import 'package:hive_ce/hive.dart';

part 'transmission_log_entry.g.dart';

/// Status eines Übertragungsversuchs
@HiveType(typeId: 33)
enum TransmissionStatus {
  /// Vom SDK entgegengenommen, Zustellung ausstehend (z.B. offline)
  @HiveField(0)
  pending,

  /// Zustellung bestätigt
  @HiveField(1)
  sent,

  /// Endgültig fehlgeschlagen
  @HiveField(2)
  failed,
}

/// Kanal, über den übertragen wurde
@HiveType(typeId: 32)
enum TransmissionChannel {
  @HiveField(0)
  feedback,

  @HiveField(1)
  telemetry,
}

/// Ein Eintrag im lokalen Übertragungsprotokoll.
///
/// Liegt ausschließlich auf dem Gerät. Beleg für die Nutzerin,
/// keine Buchhaltung für die Entwickler.
///
/// Feldreihenfolge nach dem Anlegen nie ändern — der Custom-Lint
/// `hive_field_order_check` erzwingt das, weil sonst bestehende
/// Daten falsch gelesen würden.
@HiveType(typeId: 34)
class TransmissionLogEntry extends HiveObject {
  TransmissionLogEntry({
    required this.id,
    required this.timestamp,
    required this.channel,
    required this.payloadText,
    required this.status,
    this.errorMessage,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final TransmissionChannel channel;

  /// Der vollständige Inhalt im Klartext, so wie er das Gerät verlassen hat.
  /// Wird nie gekürzt oder zusammengefasst.
  @HiveField(3)
  final String payloadText;

  @HiveField(4)
  TransmissionStatus status;

  @HiveField(5)
  String? errorMessage;
}
