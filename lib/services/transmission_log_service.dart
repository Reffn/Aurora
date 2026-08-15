import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:hive_ce/hive.dart';

/// Lokales Protokoll aller Übertragungsversuche.
///
/// Liegt ausschließlich auf dem Gerät und wird nie übertragen.
/// Es ist Beleg für die Nutzerin, nicht Buchhaltung für die Entwickler.
class TransmissionLogService {
  TransmissionLogService({required Box<TransmissionLogEntry> box}) : _box = box;
  final Box<TransmissionLogEntry> _box;
  int _recordCounter = 0;

  /// Legt einen Eintrag an und gibt dessen Id zurück.
  Future<String> record({
    required TransmissionChannel channel,
    required String payloadText,
    required TransmissionStatus status,
    String? errorMessage,
  }) async {
    final timestamp = DateTime.now();
    _recordCounter++;
    final id = '${timestamp.microsecondsSinceEpoch}_$_recordCounter';

    await _box.put(
      id,
      TransmissionLogEntry(
        id: id,
        timestamp: timestamp,
        channel: channel,
        payloadText: payloadText,
        status: status,
        errorMessage: errorMessage,
      ),
    );

    logger.info(
      LogCategory.service,
      'Übertragung protokolliert',
      data: {'id': id, 'channel': channel.name, 'status': status.name},
    );

    return id;
  }

  Future<void> updateStatus(
    String id,
    TransmissionStatus status, {
    String? errorMessage,
  }) async {
    final entry = _box.get(id);
    if (entry == null) return;

    entry.status = status;
    entry.errorMessage = errorMessage;
    await entry.save();
  }

  /// Alle Einträge, neueste zuerst.
  List<TransmissionLogEntry> all() {
    final entries = _box.values.toList()
      ..sort((a, b) {
        final timestampCmp = b.timestamp.compareTo(a.timestamp);
        if (timestampCmp != 0) return timestampCmp;
        // Tiebreaker: Id (enthält monotonen Counter)
        return b.id.compareTo(a.id);
      });
    return entries;
  }

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();
}
