import 'dart:convert';
import 'dart:io';

import 'package:dis_app/models/part_right.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profile(List<String> permissions) => Profile(
  id: 'anteil-1',
  nameRaw: 'Test Anteil',
  preferredColorValue: Colors.blue.toARGB32(),
  createdAt: DateTime(2026, 10, 29),
  permissions: permissions,
);

const Set<Permission> _medicationRights = {
  Permission.viewMedication,
  Permission.viewMedicationTab,
  Permission.manageMedication,
  Permission.overrideMedicationLog,
};

/// Liest eine Vorlage so, wie sie in der Datei steht: als Zeichenketten.
/// Namen, die das Enum nicht kennt, bleiben drin und stören nicht.
List<String> _presetPermissions(String key) {
  final json =
      jsonDecode(
            File('assets/config/permission_presets.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  final presets = json['presets'] as Map<String, dynamic>;
  final preset = presets[key] as Map<String, dynamic>;
  return (preset['permissions'] as List).cast<String>();
}

void main() {
  group('Rechte pro Anteil', () {
    test('jedes Recht ist bewusst eingeordnet', () {
      // Ausgeschrieben statt abgeleitet: Ein neues Recht im Enum soll hier
      // rot werden, statt still für alle zu gelten.
      const expected = {
        'viewMedication',
        'viewMedicationTab',
        'manageMedication',
        'overrideMedicationLog',
        'deleteAllMessages',
        'editAllEvents',
        'deleteAllEvents',
        'editAllDiaryEntries',
        'deleteAllDiaryEntries',
        'viewAllDiaries',
        'createProfiles',
        'deactivateProfiles',
        'managePermissions',
        'accessSettings',
        'resetPasswords',
      };

      final perPart = Permission.values
          .where((p) => p.perPart)
          .map((p) => p.name)
          .toSet();

      expect(perPart, expected);
      expect(Permission.values.length - perPart.length, 45);
    });

    test('die zehn Schalter decken genau die Rechte pro Anteil ab', () {
      final union = PartRight.values.expand((r) => r.permissions).toSet();
      final sizeSum = PartRight.values.fold<int>(
        0,
        (sum, r) => sum + r.permissions.length,
      );

      expect(PartRight.values.length, 10);
      expect(union, Permission.values.where((p) => p.perPart).toSet());
      expect(sizeSum, 15);
    });

    test('Finder gilt für alle', () {
      final profile = _profile(const []);

      expect(profile.hasPermission(Permission.viewFinderTab), isTrue);
      expect(profile.hasPermission(Permission.manageFinder), isTrue);
      expect(profile.hasPermission(Permission.callEmergencyContacts), isTrue);
      expect(profile.hasPermission(Permission.editEmergencyContacts), isTrue);
      expect(profile.hasPermission(Permission.viewTimelineTab), isTrue);
    });

    test('Medikamente sehen bleibt pro Anteil', () {
      final profile = _profile(const []);

      expect(profile.hasPermission(Permission.viewMedicationTab), isFalse);
    });

    test('halb gesetzt bleibt, wie es war', () {
      final profile = _profile([Permission.manageMedication.persistedValue]);

      expect(
        PartRight.changeMedicationPlan.stateFor(profile),
        PartRightState.partly,
      );
      expect(profile.hasPermission(Permission.manageMedication), isTrue);
      expect(profile.hasPermission(Permission.overrideMedicationLog), isFalse);
    });

    test('Plan ändern zieht sehen mit', () {
      final result = PartRight.changeMedicationPlan.applyTo({}, on: true);

      expect(result, containsAll(_medicationRights));
    });

    test('sehen aus nimmt ändern mit', () {
      final result = PartRight.seeMedication.applyTo(
        {..._medicationRights},
        on: false,
      );

      expect(result, isEmpty);
    });

    test('Vorlagen enthalten nur ganze Schalter', () {
      Set<PartRight> onFor(String preset) {
        final profile = _profile(_presetPermissions(preset));
        for (final right in PartRight.values) {
          expect(
            right.stateFor(profile),
            isNot(PartRightState.partly),
            reason: 'Vorlage $preset setzt ${right.name} nur zum Teil',
          );
        }
        return PartRight.values
            .where((r) => r.stateFor(profile) == PartRightState.on)
            .toSet();
      }

      expect(onFor('child'), {PartRight.seeMedication});
      expect(onFor('standard'), {
        PartRight.seeMedication,
        PartRight.changeOthersEntries,
        PartRight.readOthersDiaries,
        PartRight.changeSettings,
      });
    });
  });
}
