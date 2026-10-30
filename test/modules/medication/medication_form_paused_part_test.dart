import 'dart:async';
import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/medication/medication_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Ein Medikament gehört dem Körper, also allen Anteilen.
///
/// Das Formular baute `profileIds` beim Speichern aus `getProfiles()` neu,
/// und das kennt nur aktive Anteile. Ein pausierter Anteil verlor so beim
/// nächsten Speichern seinen Eintrag und sah das Medikament nach dem
/// Wiederaufnehmen nicht mehr in seiner Zeitachse.
class _FakeDataEntry implements DataEntry {
  _FakeDataEntry(this._alle, this.settingsBox);

  final List<Profile> _alle;
  final List<Medication> gespeichert = [];

  // Das Formular fragt über `ActiveProfilePermission` nach Rechten.
  @override
  final Box<dynamic> settingsBox;

  @override
  Profile? getActiveProfile() => _alle.first;

  @override
  List<Profile> getProfiles() => _alle.where((p) => p.isActive).toList();

  @override
  List<Profile> getAllProfiles() => _alle;

  @override
  Future<void> updateMedication(Medication medication) async {
    gespeichert.add(medication);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Profile _profil(String id, {bool isActive = true}) => Profile(
  id: id,
  nameRaw: id,
  preferredColorValue: 0xFF3366CC,
  createdAt: DateTime(2026, 10, 29),
  isActive: isActive,
);

void main() {
  late Directory tempDir;
  late _FakeDataEntry dataEntry;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('medikament_anteile_');
    Hive.init(tempDir.path);
    await getIt.reset();
    dataEntry = _FakeDataEntry(
      [_profil('lou'), _profil('mira', isActive: false)],
      await Hive.openBox<dynamic>('einstellungen'),
    );
    getIt.registerSingleton<DataEntry>(dataEntry);
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } on FileSystemException {
      // Windows hält Hive-Dateien gelegentlich noch kurz fest.
    }
  });

  testWidgets('ein pausierter Anteil bleibt beim Speichern eingetragen', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));
    final medikament = Medication(
      id: 'ibu',
      name: 'Ibuprofen',
      dosage: '400 mg',
      timesOfDay: const ['08:00'],
      profileIds: const ['lou', 'mira'],
      createdAt: DateTime(2026, 10, 1),
      // Sonst fragt das Formular vor dem Speichern nach der Erlaubnis.
      remindersEnabled: false,
    );

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(),
      ),
    );
    // Darunter eine Seite, damit das Formular nach dem Speichern zurück kann.
    unawaited(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  MedicationFormScreen(existingMedication: medikament),
            ),
          ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final speichern = find.text(l10n.actionSave);
    await tester.scrollUntilVisible(
      speichern,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(speichern);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(dataEntry.gespeichert, hasLength(1));
    expect(
      dataEntry.gespeichert.single.profileIds,
      unorderedEquals(['lou', 'mira']),
    );
  });
}
