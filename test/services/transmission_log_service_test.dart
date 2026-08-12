import 'dart:io';

import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/transmission_log_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDir;
  late Box<TransmissionLogEntry> box;
  late TransmissionLogService service;

  setUpAll(() {
    Hive
      ..registerAdapter(TransmissionLogEntryAdapter())
      ..registerAdapter(TransmissionStatusAdapter())
      ..registerAdapter(TransmissionChannelAdapter());
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('transmission_log_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<TransmissionLogEntry>('transmission_log_test');
    service = TransmissionLogService(box: box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
    await tempDir.delete(recursive: true);
  });

  group('TransmissionLogService', () {
    test('startet leer', () {
      expect(service.all(), isEmpty);
    });

    test('speichert einen Eintrag mit vollem Payload', () async {
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'Kategorie: Fehler\n\nDie Karte lädt nicht.',
        status: TransmissionStatus.sent,
      );

      final entries = service.all();
      expect(entries, hasLength(1));
      expect(entries.first.payloadText, contains('Die Karte lädt nicht.'));
      expect(entries.first.status, TransmissionStatus.sent);
    });

    test('erzeugt eindeutige Ids auch ohne Verzögerung', () async {
      final id1 = await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'erster',
        status: TransmissionStatus.sent,
      );
      final id2 = await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'zweiter',
        status: TransmissionStatus.sent,
      );

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(id2));
      expect(service.all(), hasLength(2));
    });

    test('gibt Einträge neueste zuerst zurück', () async {
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'erster',
        status: TransmissionStatus.sent,
      );
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'zweiter',
        status: TransmissionStatus.sent,
      );

      expect(service.all().first.payloadText, 'zweiter');
    });

    test('aktualisiert den Status von pending auf sent', () async {
      final id = await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'wartet',
        status: TransmissionStatus.pending,
      );

      await service.updateStatus(id, TransmissionStatus.sent);

      expect(service.all().first.status, TransmissionStatus.sent);
    });

    test('speichert den Fehlergrund bei failed', () async {
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'kaputt',
        status: TransmissionStatus.failed,
        errorMessage: 'Keine Verbindung zum Server',
      );

      expect(service.all().first.errorMessage, 'Keine Verbindung zum Server');
    });

    test('löscht einen einzelnen Eintrag', () async {
      final id = await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'weg damit',
        status: TransmissionStatus.sent,
      );

      await service.delete(id);

      expect(service.all(), isEmpty);
    });

    test('clear() leert alle Einträge', () async {
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'erste',
        status: TransmissionStatus.sent,
      );
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'zweite',
        status: TransmissionStatus.sent,
      );
      await service.record(
        channel: TransmissionChannel.feedback,
        payloadText: 'dritte',
        status: TransmissionStatus.sent,
      );

      expect(service.all(), hasLength(3));

      await service.clear();

      expect(service.all(), isEmpty);
    });
  });
}
