import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/part_right.dart';

/// Die Wörter für die zehn Schalter und ihre drei Gruppen.
///
/// Wie bei `PermissionText` stehen sie neben dem Enum statt darin: Die
/// Sprache kann wechseln, das Enum nicht.
extension PartRightText on PartRight {
  String label(AppLocalizations l10n) => switch (this) {
    PartRight.seeMedication => l10n.rightSeeMedication,
    PartRight.changeMedicationPlan => l10n.rightChangeMedicationPlan,
    PartRight.changeOthersEntries => l10n.rightChangeOthersEntries,
    PartRight.deleteOthersEntries => l10n.rightDeleteOthersEntries,
    PartRight.readOthersDiaries => l10n.rightReadOthersDiaries,
    PartRight.createParts => l10n.rightCreateParts,
    PartRight.pauseParts => l10n.rightPauseParts,
    PartRight.grantRights => l10n.rightGrantRights,
    PartRight.changeSettings => l10n.rightChangeSettings,
    PartRight.resetPasswords => l10n.rightResetPasswords,
  };
}

extension PartRightGroupText on PartRightGroup {
  String label(AppLocalizations l10n) => switch (this) {
    PartRightGroup.medication => l10n.rightsGroupMedication,
    PartRightGroup.others => l10n.rightsGroupOthers,
    PartRightGroup.management => l10n.rightsGroupManagement,
  };
}
