import 'dart:io';

import 'package:hive_ce/hive.dart';

Directory? _testDir;

/// Oeffnet eine Hive-Box in einem Wegwerf-Verzeichnis.
///
/// Ohne Flutter-Bindings, damit reine Unit-Tests schnell bleiben. Das
/// Verzeichnis wird pro Testlauf einmal angelegt: `Hive.init` mehrfach mit
/// wechselnden Pfaden aufzurufen wuerde bereits offene Boxen von ihrem
/// Speicherort abschneiden.
Future<Box<T>> openTempBox<T>(String name) async {
  if (_testDir == null) {
    _testDir = await Directory.systemTemp.createTemp('aurora_test_');
    Hive.init(_testDir!.path);
  }
  return Hive.openBox<T>(name);
}
