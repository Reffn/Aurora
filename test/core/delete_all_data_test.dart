import 'dart:io';

import 'package:dis_app/core/delete_all_data.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Der Löschweg muss vollständig sein, nicht ungefähr.
///
/// Die Lücke, die diese Tests bewachen, gab es wirklich: `switch_events`
/// wurde unter diesem Namen geöffnet, aber unter `profile_switches`
/// gelöscht — die Profilwechsel-Historie überlebte beide Löschwege. Und
/// `location_history`, `transmission_log` und `telemetry_queue` hatten gar
/// keinen. Wer „Alle Daten löschen" antippt, bekam ein grünes Häkchen und
/// behielt seinen Standortverlauf.
///
/// Deshalb wird hier nicht Verhalten geprüft, sondern Vollständigkeit: Jede
/// Box, die es gibt, hat einen Löschweg — und jeder Boxname, der irgendwo
/// geöffnet wird, ist ein deklarierter Name.
void main() {
  group('Vollständigkeit des Löschumfangs', () {
    test('jede Konstante in HiveBoxNames hat einen Löschweg', () {
      final quelle = File('lib/core/hive_box_names.dart').readAsStringSync();
      final konstanten = RegExp(r"static const String \w+ = '([^']+)';")
          .allMatches(quelle)
          .map((treffer) => treffer.group(1)!)
          .toSet();

      expect(
        konstanten,
        isNotEmpty,
        reason: 'Die Datei wurde nicht gefunden oder ihr Aufbau hat sich '
            'geändert — dann prüft dieser Test nichts mehr.',
      );

      final ohneLoeschweg = konstanten.difference(deletableBoxNames.toSet());
      expect(
        ohneLoeschweg,
        isEmpty,
        reason: 'Diese Boxen überleben "Alle Daten löschen". Entweder in '
            'deletableBoxNames aufnehmen oder dort begründet ausnehmen.',
      );
    });

    test('jeder geöffnete Boxname ist ein deklarierter Name', () {
      final deklariert = RegExp(r"static const String \w+ = '([^']+)';")
          .allMatches(File('lib/core/hive_box_names.dart').readAsStringSync())
          .map((treffer) => treffer.group(1)!)
          .toSet();

      final freieNamen = <String>{};
      final muster = RegExp(r"openBox(?:<[^>]*>)?\(\s*'([^']+)'");
      for (final datei in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((datei) => datei.path.endsWith('.dart'))) {
        for (final treffer in muster.allMatches(datei.readAsStringSync())) {
          final name = treffer.group(1)!;
          if (!deklariert.contains(name)) freieNamen.add(name);
        }
      }

      expect(
        freieNamen,
        isEmpty,
        reason: 'Diese Boxnamen stehen als Text im Code und kennt '
            'HiveBoxNames nicht. Genau so ist "switch_events" am Löschweg '
            'vorbeigelaufen.',
      );
    });
  });

  group('deleteAllLocalData', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('aurora_delete_all');
      Hive.init(tempDir.path);
      final anhaenge = Directory('${tempDir.path}/attachments');
      await anhaenge.create(recursive: true);
      AttachmentHelper.setCacheForTest(anhaenge);
    });

    tearDown(() async {
      await Hive.close();
      AttachmentHelper.resetCacheForTest();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('nimmt eine Box mit, die keinem Dienst gehört', () async {
      // Ein Dienst, der diese Box leert, ist nicht angemeldet. Ohne
      // Sweep bliebe sie stehen.
      final box = await Hive.openBox<String>(HiveBoxNames.locationHistory);
      await box.put('gestern', 'Musterstraße 1');

      final ergebnis = await deleteAllLocalData();

      expect(ergebnis.isComplete, isTrue, reason: '${ergebnis.failedSteps}');
      expect(Hive.isBoxOpen(HiveBoxNames.locationHistory), isFalse);
      final wiederGeoeffnet =
          await Hive.openBox<String>(HiveBoxNames.locationHistory);
      expect(wiederGeoeffnet.isEmpty, isTrue);
    });

    test('nimmt auch geschlossene Boxen von der Platte', () async {
      final box = await Hive.openBox<String>(HiveBoxNames.transmissionLog);
      await box.put('eintrag', 'gesendet am 8.8.');
      await box.close();

      final ergebnis = await deleteAllLocalData();

      expect(ergebnis.isComplete, isTrue, reason: '${ergebnis.failedSteps}');
      final wiederGeoeffnet =
          await Hive.openBox<String>(HiveBoxNames.transmissionLog);
      expect(wiederGeoeffnet.isEmpty, isTrue);
    });

    test('räumt den Anhang-Ordner und lässt ihn benutzbar', () async {
      final datei = File('${AttachmentHelper.directory.value!.path}/bild.jpg');
      await datei.writeAsBytes([1, 2, 3]);

      final ergebnis = await deleteAllLocalData();

      expect(ergebnis.isComplete, isTrue, reason: '${ergebnis.failedSteps}');
      expect(datei.existsSync(), isFalse);

      // Der Ordner muss danach sofort wieder beschreibbar sein — sonst
      // zeigt der nächste Speichervorgang auf einen Elternordner, den es
      // nicht mehr gibt.
      expect(AttachmentHelper.isWarm, isTrue);
      final neu = AttachmentHelper.fileSync('neu.jpg')!;
      await neu.writeAsBytes([4]);
      expect(neu.existsSync(), isTrue);
    });

    test('ist wiederholbar, ohne zu scheitern', () async {
      final ersterLauf = await deleteAllLocalData();
      expect(ersterLauf.isComplete, isTrue, reason: '${ersterLauf.failedSteps}');
      final zweiterLauf = await deleteAllLocalData();
      expect(zweiterLauf.isComplete, isTrue,
          reason: '${zweiterLauf.failedSteps}');
    });
  });
}
