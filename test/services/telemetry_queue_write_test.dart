import 'dart:io';

import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Der Gegenbeweis zum Fehler auf dem Gerät: ohne registrierten Adapter
/// lehnt Hive den Typ beim Schreiben ab („Cannot write, unknown type“), die
/// Warteschlange bleibt leer und die Meldungen sind still verloren.
///
/// Dass der Adapter in `injection.dart` steht, prüft
/// `test/core/hive_adapter_registration_test.dart`. Hier geht es darum, dass
/// er auch trägt.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('aurora_telemetry_queue');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(PendingTelemetryEventAdapter().typeId)) {
      Hive.registerAdapter(PendingTelemetryEventAdapter());
    }
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('ein Telemetrie-Ereignis überlebt Schreiben und Lesen', () async {
    final box = await Hive.openBox<PendingTelemetryEvent>('telemetry_queue');

    await box.add(
      PendingTelemetryEvent(
        id: 'ereignis-1',
        eventName: 'bereich_geoeffnet_chat',
        day: '2026-08-06',
        appVersion: '3.0.14',
        dueAt: DateTime(2026, 8, 6, 12),
      ),
    );

    expect(box.length, 1);
    final stored = box.getAt(0)!;
    expect(stored.eventName, 'bereich_geoeffnet_chat');
    expect(stored.day, '2026-08-06');
    expect(stored.appVersion, '3.0.14');
  });
}
