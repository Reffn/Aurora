/// Die zehn Schalter pro Anteil
///
/// 45 der 60 Rechte gelten für alle. Die übrigen 15 (`Permission.perPart`)
/// bündeln diese Schalter, damit ein Anteil mit einem Blick sieht, was er
/// darf. Gespeichert werden weiter die einzelnen Rechte: Alte Profile mit
/// halb gesetzten Schaltern behalten genau das, was sie hatten.
library;

import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:flutter/material.dart';

enum PartRightGroup { medication, others, management }

enum PartRightState { on, partly, off }

enum PartRight {
  seeMedication(PartRightGroup.medication, Icons.medication, {
    Permission.viewMedication,
    Permission.viewMedicationTab,
  }),
  changeMedicationPlan(PartRightGroup.medication, Icons.medical_services, {
    Permission.manageMedication,
    Permission.overrideMedicationLog,
  }),
  changeOthersEntries(PartRightGroup.others, Icons.edit_document, {
    Permission.editAllEvents,
    Permission.editAllDiaryEntries,
  }),
  // Getrennt von „ändern“, weil die Vorlage `standard` ändern erlaubt, aber
  // nicht löschen. Ein gemeinsamer Schalter hätte bestehenden Anteilen still
  // ein Recht genommen oder gegeben.
  deleteOthersEntries(PartRightGroup.others, Icons.delete_outline, {
    Permission.deleteAllMessages,
    Permission.deleteAllEvents,
    Permission.deleteAllDiaryEntries,
  }),
  readOthersDiaries(PartRightGroup.others, Icons.library_books, {
    Permission.viewAllDiaries,
  }),
  createParts(PartRightGroup.management, Icons.person_add, {
    Permission.createProfiles,
  }),
  pauseParts(PartRightGroup.management, Icons.pause_circle_outline, {
    Permission.deactivateProfiles,
  }),
  grantRights(PartRightGroup.management, Icons.key, {
    Permission.managePermissions,
  }),
  changeSettings(PartRightGroup.management, Icons.settings, {
    Permission.accessSettings,
  }),
  resetPasswords(PartRightGroup.management, Icons.lock_reset, {
    Permission.resetPasswords,
  });

  const PartRight(this.group, this.icon, this.permissions);

  final PartRightGroup group;

  /// Symbol für die Darstellung ohne Lesen
  final IconData icon;

  final Set<Permission> permissions;

  /// Ob der Schalter heute etwas bewirkt. Nur dann steht er in „Anteile &
  /// Rechte“, als Schalter und als Symbol (Regel 32).
  ///
  /// Ein Schalter, den keine Stelle der App prüft, ist eine Bedienung, die
  /// nur scheitern kann („errorless“): Ausschalten nähme nichts, Einschalten
  /// gäbe nichts. Steht bewusst als feste Liste da und wird nicht zur
  /// Laufzeit ermittelt. Wer eine Prüfung einbaut, nimmt den Schalter hier
  /// auf. Die Rechte selbst bleiben gespeichert, in Profilen und Vorlagen.
  bool get hasEffect => _withEffect.contains(this);

  /// Die Schalter, von denen mindestens ein Recht in der App geprüft wird
  /// (Abgleich vom 29.10.2026). Ohne Wirkung und deshalb ausgeblendet:
  /// - `readOthersDiaries`: `viewAllDiaries` fragt keine Stelle ab.
  /// - `createParts`: „Neues Profil“ steht schon vor der Anmeldung offen.
  /// - `changeSettings`: Die Einstellungen öffnet jeder Anteil.
  /// - `resetPasswords`: Einen Reset darf jeder beginnen, so gewollt
  ///   (`.claude/rules/passwort-reset.md`).
  static const Set<PartRight> _withEffect = {
    // Zeitachse, Tageszeile, Medikamenten-Tab
    seeMedication,
    // Medikamente anlegen und ändern über `manageMedication`
    changeMedicationPlan,
    // Termine und Tagebucheinträge anderer bearbeiten
    changeOthersEntries,
    // Termine anderer löschen über `deleteAllEvents`
    deleteOthersEntries,
    // `ProfileService.canPause` und `canResume`
    pauseParts,
    // Einstellungen → Verwaltung und `ProfileService` beim Setzen von Rechten
    grantRights,
  };

  /// Den Plan ändern, ohne ihn zu sehen, ergibt keinen Sinn
  PartRight? get requires => switch (this) {
    PartRight.changeMedicationPlan => PartRight.seeMedication,
    _ => null,
  };

  /// Liest die gespeicherten Rechte statt `hasPermission`, damit der Schalter
  /// genau das zeigt, was im Profil steht.
  PartRightState stateFor(Profile profile) {
    if (profile.isAdmin) return PartRightState.on;

    final stored = permissions
        .where((p) => profile.permissions.contains(p.persistedValue))
        .length;
    if (stored == permissions.length) return PartRightState.on;
    if (stored == 0) return PartRightState.off;
    return PartRightState.partly;
  }

  /// Gibt eine neue Menge zurück und lässt `granted` unverändert.
  /// Rechte, die nicht zu diesem Schalter gehören, bleiben, wie sie sind.
  Set<Permission> applyTo(Set<Permission> granted, {required bool on}) {
    final result = {...granted};
    if (on) {
      result.addAll(permissions);
      final required = requires;
      if (required != null) result.addAll(required.permissions);
    } else {
      result.removeAll(permissions);
      for (final dependent in PartRight.values) {
        if (dependent.requires == this) {
          result.removeAll(dependent.permissions);
        }
      }
    }
    return result;
  }
}
