import 'package:dis_app/models/medication.dart';

/// Ein Einnahmezeitpunkt an einem Tag und was dazu eingetragen ist.
///
/// [log] ist `null`, wenn niemand etwas eingetragen hat. Das ist eine
/// Auskunft, kein Versäumnis: Nach einem Zeitverlust ist „steht da nichts"
/// genau die Antwort auf „hab ich gestern Abend genommen?".
class VerlaufEintrag {
  const VerlaufEintrag({required this.medication, this.slot, this.log});

  final Medication medication;

  /// Die geplante Uhrzeit („20:00"); bei Bedarfsmedizin `null`.
  final String? slot;
  final MedicationLog? log;

  /// Wonach innerhalb eines Tages sortiert wird.
  String get sortierschluessel {
    if (slot != null) return slot!;
    final t = log!.takenAt;
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }
}

class VerlaufTag {
  const VerlaufTag({required this.tag, required this.eintraege});

  /// Mitternacht des Tages.
  final DateTime tag;
  final List<VerlaufEintrag> eintraege;
}

/// Die letzten [tage] Tage, jüngster zuerst; Tage ohne Einträge fallen weg.
///
/// Tagesmedikamente stehen mit jedem geplanten Zeitpunkt da — auch ohne
/// Eintrag, weil gerade die Lücke gefragt ist. Ausnahmen, damit keine Lücke
/// erfunden wird:
/// - vor dem Tag, an dem das Medikament angelegt wurde;
/// - heute vor der geplanten Uhrzeit;
/// - bei pausierten Medikamenten — wann sie pausiert wurden, weiß die App
///   nicht; sie erscheinen nur mit dem, was wirklich eingetragen ist.
///
/// Gilt mehr als ein Eintrag für denselben Zeitpunkt, zählt der zuletzt
/// bestätigte — wie auf der Tageskarte.
List<VerlaufTag> verlaufBerechnen({
  required List<Medication> medikamente,
  required Iterable<MedicationLog> eintraege,
  required DateTime jetzt,
  int tage = 14,
}) {
  final heute = DateTime(jetzt.year, jetzt.month, jetzt.day);
  final ergebnis = <VerlaufTag>[];

  for (var i = 0; i < tage; i++) {
    final tag = DateTime(heute.year, heute.month, heute.day - i);
    final tagEnde = DateTime(tag.year, tag.month, tag.day + 1);
    final amTag = eintraege
        .where((l) => !l.takenAt.isBefore(tag) && l.takenAt.isBefore(tagEnde))
        .toList();

    final zeilen = <VerlaufEintrag>[];
    for (final med in medikamente) {
      final vonMed = amTag.where((l) => l.medicationId == med.id).toList();

      if (med.type == MedicationType.asNeeded) {
        for (final log in vonMed) {
          if (log.status == MedicationStatus.taken) {
            zeilen.add(VerlaufEintrag(medication: med, log: log));
          }
        }
        continue;
      }

      final angelegt = DateTime(
        med.createdAt.year,
        med.createdAt.month,
        med.createdAt.day,
      );
      final slots = {
        ...med.timesOfDay,
        ...vonMed.map((l) => l.scheduledTime).whereType<String>(),
      };
      for (final slot in slots) {
        final log = _juengster(vonMed.where((l) => l.scheduledTime == slot));
        if (log == null) {
          if (!med.isActive || tag.isBefore(angelegt)) continue;
          if (!med.timesOfDay.contains(slot)) continue;
          if (i == 0 && !_vorbei(slot, jetzt)) continue;
        }
        zeilen.add(VerlaufEintrag(medication: med, slot: slot, log: log));
      }
    }

    if (zeilen.isEmpty) continue;
    zeilen.sort((a, b) {
      final zeit = a.sortierschluessel.compareTo(b.sortierschluessel);
      return zeit != 0 ? zeit : a.medication.name.compareTo(b.medication.name);
    });
    ergebnis.add(VerlaufTag(tag: tag, eintraege: zeilen));
  }
  return ergebnis;
}

MedicationLog? _juengster(Iterable<MedicationLog> logs) {
  MedicationLog? juengster;
  for (final log in logs) {
    final zeit = log.confirmedAt ?? log.takenAt;
    if (juengster == null ||
        zeit.isAfter(juengster.confirmedAt ?? juengster.takenAt)) {
      juengster = log;
    }
  }
  return juengster;
}

bool _vorbei(String slot, DateTime jetzt) {
  final teile = slot.split(':');
  if (teile.length != 2) return true;
  final stunde = int.tryParse(teile[0]);
  final minute = int.tryParse(teile[1]);
  if (stunde == null || minute == null) return true;
  return !DateTime(
    jetzt.year,
    jetzt.month,
    jetzt.day,
    stunde,
    minute,
  ).isAfter(jetzt);
}
