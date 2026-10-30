import 'dart:io';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/medication_events.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/comment_service.dart';
import 'package:dis_app/services/medication_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

class _StillerKommentarDienst implements CommentService {
  @override
  Future<void> deleteCommentsForParent(
    CommentableType type,
    String parentId,
  ) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

MedicationLog _eintrag({
  required String id,
  required String medicationId,
  required MedicationStatus status,
  required DateTime um,
  String slot = '08:00',
}) => MedicationLog(
  id: id,
  medicationId: medicationId,
  takenAt: um,
  profileId: 'lina',
  status: status,
  confirmedAt: um,
  scheduledTime: slot,
);

void main() {
  late Directory tempDir;
  late EventBus eventBus;
  late MedicationService dienst;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('medikament_verlauf_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(MedicationAdapter());
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(MedicationLogAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(MedicationStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(MedicationTypeAdapter());
    }

    await getIt.reset();
    getIt.registerSingleton<CommentService>(_StillerKommentarDienst());

    eventBus = EventBus();
    dienst = MedicationService(eventBus);
    await dienst.openBoxes();
    dienst.subscribeToEvents();
  });

  tearDown(() async {
    await Hive.close();
    await getIt.reset();
    await tempDir.delete(recursive: true);
  });

  // Jeder Tipp auf „Genommen", „Abgelehnt" oder „Später" legt einen neuen
  // Eintrag an. Die Box liefert sie nach Schlüssel sortiert, und die
  // Schlüssel sind Zufallskennungen. Ohne Vorrang des Jüngsten zeigte die
  // Karte nach „Später, dann Genommen" je nach Kennung noch „Später".
  test('der zuletzt gesetzte Stand gilt, nicht der erste in der Box', () async {
    final heute = DateTime.now();
    final frueh = DateTime(heute.year, heute.month, heute.day, 0, 10);
    final spaeter = frueh.add(const Duration(minutes: 5));

    await dienst.logsBox.put(
      'aaa',
      _eintrag(
        id: 'aaa',
        medicationId: 'm1',
        status: MedicationStatus.snoozed,
        um: frueh,
      ),
    );
    await dienst.logsBox.put(
      'zzz',
      _eintrag(
        id: 'zzz',
        medicationId: 'm1',
        status: MedicationStatus.taken,
        um: spaeter,
      ),
    );

    expect(dienst.getTodaysLog('m1', '08:00')?.status, MedicationStatus.taken);
  });

  test('der Stand eines vergangenen Tages ist abfragbar', () async {
    final gestern = DateTime.now().subtract(const Duration(days: 1));
    final abends = DateTime(gestern.year, gestern.month, gestern.day, 20, 3);
    await dienst.logsBox.put(
      'g1',
      _eintrag(
        id: 'g1',
        medicationId: 'm1',
        status: MedicationStatus.taken,
        um: abends,
        slot: '20:00',
      ),
    );

    expect(
      dienst.getLogFor('m1', '20:00', gestern)?.status,
      MedicationStatus.taken,
    );
    expect(dienst.getTodaysLog('m1', '20:00'), isNull);
  });

  // Gelöscht heißt gelöscht: Die Einträge eines entfernten Medikaments
  // blieben bisher verwaist in der Box liegen — Gesundheitsdaten zu etwas,
  // das es in der App nicht mehr gibt.
  test('Löschen nimmt die Einträge des Medikaments mit, nur seine', () async {
    final jetzt = DateTime.now();
    await dienst.logsBox.put(
      'a',
      _eintrag(
        id: 'a',
        medicationId: 'weg',
        status: MedicationStatus.taken,
        um: jetzt,
      ),
    );
    await dienst.logsBox.put(
      'b',
      _eintrag(
        id: 'b',
        medicationId: 'bleibt',
        status: MedicationStatus.taken,
        um: jetzt,
      ),
    );

    eventBus.publish(MedicationDeletedEvent('weg'));
    await pumpEventQueue();

    expect(dienst.logsBox.keys, ['b']);
  });
}
