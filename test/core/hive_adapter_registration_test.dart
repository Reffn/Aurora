import 'dart:io';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Die Adapterliste in `injection.dart` ist von Hand gepflegt, die in
/// `hive_registrar.g.dart` wird erzeugt. Fehlt in der ersten einer, nimmt Hive
/// den Typ zur Laufzeit nicht an: die Telemetrie-Warteschlange blieb so leer
/// und meldete nur `HiveError: Cannot write, unknown type` ins Log — auf dem
/// Gerät sichtbar, in keinem Test.
void main() {
  test('injection.dart registriert jeden erzeugten Hive-Adapter', () {
    final pattern = RegExp(r'registerAdapter\((\w+)\(\)\)');

    Set<String> adaptersIn(String path) => pattern
        .allMatches(File(path).readAsStringSync())
        .map((m) => m.group(1)!)
        .toSet();

    final generated = adaptersIn('lib/hive_registrar.g.dart');
    final registered = adaptersIn('lib/core/di/injection.dart');

    expect(generated, isNotEmpty, reason: 'Registrar-Datei nicht gefunden');
    expect(
      generated.difference(registered),
      isEmpty,
      reason: 'Diese Adapter fehlen in injection.dart',
    );
  });

  test('ein zweiter Startanlauf registriert nicht doppelt', () {
    // Die Fehlerfläche beim Start bietet „noch einmal versuchen" an. Dahinter
    // steht `getIt.reset()` — das räumt die DI, nicht aber Hives globale
    // Adapterregistratur. Ungeprüft warf der zweite Anlauf deshalb
    // `HiveError: There is already a TypeAdapter for typeId ...`, und aus dem
    // Ausweg wurde eine Sackgasse. Genau dort steht jemand, der nicht
    // weiterkommt.
    registerHiveAdapters();
    expect(Hive.isAdapterRegistered(ProfileAdapter().typeId), isTrue);

    // Der ungesicherte Weg — festgehalten, damit sichtbar bleibt, wovor die
    // Prüfung schützt und dass sie nicht nur Zierde ist.
    expect(
      () => Hive.registerAdapter(ProfileAdapter()),
      throwsA(isA<HiveError>()),
    );

    expect(registerHiveAdapters, returnsNormally);
  });
}
