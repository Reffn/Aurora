import 'package:flutter/foundation.dart';

/// Namensräume in den oberen Bits der Kennung.
///
/// Der Abgleich fragt das Betriebssystem, was vorgemerkt ist, und bekommt
/// nur Zahlen zurück. Ohne Namensraum ließe sich eine Medikamenten- nicht
/// von einer Termin-Meldung unterscheiden.
const int kNamespaceMedication = 1;
const int kNamespaceEvent = 2;

/// Welche Art von Erinnerung.
///
/// [ReminderKind.due] reicht sieben Tage in die Zukunft — sie ist die
/// Ebene, die auch dann noch trägt, wenn die App tagelang nicht geöffnet
/// wird. Vorwarnungen und Wiederholungen decken nur die nächsten 36
/// Stunden ab, weil sie fünfmal so viele Vormerkungen kosten.
///
/// [ReminderKind.event] ist die einzige Erinnerung eines Termins. Termine
/// kennen keine Wiederholungen und keine Bestätigung — es gibt nichts
/// abzuhaken, nur etwas rechtzeitig zu wissen.
enum ReminderKind { before30, before10, due, repeat, snooze, available, event }

/// Woran erinnert wird.
///
/// Zwei Arten, ein Abgleich. Die Trennung liegt hier und in den Regeln —
/// die Maschinerie dahinter kennt nur noch Kennungen und Zeitpunkte.
@immutable
sealed class ReminderTarget {
  const ReminderTarget();

  /// Der Zeitpunkt, um den es geht: Einnahmezeit oder Terminbeginn.
  DateTime get at;

  /// Geht in die Kennung ein. Muss den Zielpunkt eindeutig beschreiben —
  /// **einschließlich seiner Zeit**, sonst tragen zwei verschiedene
  /// Zielpunkte dieselbe Zahl und der zweite überschreibt den ersten.
  String get seed;

  int get namespace;
}

/// Eine Dosis — ohne Profil.
///
/// Ein System teilt sich einen Körper. Nimmt Lina die Tablette um acht,
/// hat Mina sie ebenfalls genommen. Deshalb ist das Profil kein Teil des
/// Schlüssels; wer den Status gesetzt hat, steht im Log.
@immutable
final class DoseTarget extends ReminderTarget {
  const DoseTarget({
    required this.medicationId,
    required this.date,
    required this.scheduledTime,
  });

  final String medicationId;

  /// Mitternacht Ortszeit des Tages, an dem die Dosis fällig ist.
  final DateTime date;

  /// Uhrzeit im Format `HH:mm`, wie in `Medication.timesOfDay`.
  ///
  /// Bedarfsmedizin hat keine feste Uhrzeit; dort trägt das Feld die
  /// abgeleitete Freigabezeit mit dem Präfix `prn-`.
  final String scheduledTime;

  @override
  DateTime get at {
    final raw = scheduledTime.startsWith('prn-')
        ? scheduledTime.substring(4)
        : scheduledTime;
    final parts = raw.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  @override
  String get seed =>
      'med|$medicationId|${date.year}-${date.month}-${date.day}|$scheduledTime';

  @override
  int get namespace => kNamespaceMedication;

  @override
  bool operator ==(Object other) =>
      other is DoseTarget &&
      other.medicationId == medicationId &&
      other.date == date &&
      other.scheduledTime == scheduledTime;

  @override
  int get hashCode => Object.hash(medicationId, date, scheduledTime);

  @override
  String toString() =>
      'DoseTarget($medicationId, ${date.toIso8601String()}, $scheduledTime)';
}

/// Ein Termin.
///
/// Die Startzeit gehört in den Schlüssel, nicht nur die Kennung des
/// Termins. Vorher lautete die Termin-Kennung `$eventId|event_reminder` —
/// ohne Datum. Beim Verschieben trugen alte und neue Zeit dieselbe Zahl,
/// das Anmelden überschrieb das Abmelden, und es wirkte richtig, weil das
/// Ergebnis stimmte und nicht der Weg. Mit der Startzeit im Schlüssel
/// ergibt ein verschobener Termin eine neue Kennung, und der Abgleich
/// räumt die alte als Karteileiche ab.
@immutable
final class EventTarget extends ReminderTarget {
  const EventTarget({required this.eventId, required this.startTime});

  final String eventId;
  final DateTime startTime;

  @override
  DateTime get at => startTime;

  @override
  String get seed => 'evt|$eventId|${startTime.toIso8601String()}';

  @override
  int get namespace => kNamespaceEvent;

  @override
  bool operator ==(Object other) =>
      other is EventTarget &&
      other.eventId == eventId &&
      other.startTime == startTime;

  @override
  int get hashCode => Object.hash(eventId, startTime);

  @override
  String toString() => 'EventTarget($eventId, ${startTime.toIso8601String()})';
}

/// Eine geplante Erinnerung.
@immutable
class Reminder {
  const Reminder({
    required this.target,
    required this.kind,
    required this.fireAt,
    this.repeatIndex,
  });

  final ReminderTarget target;
  final ReminderKind kind;
  final DateTime fireAt;

  /// Bei [ReminderKind.repeat] die wievielte Wiederholung, bei
  /// [ReminderKind.available] der Vorlauf in Minuten. Sonst null.
  final int? repeatIndex;

  /// Bequemlichkeit für die Regeln und Tests: das Ziel als Dosis, oder
  /// null, wenn es ein Termin ist.
  DoseTarget? get dose => target is DoseTarget ? target as DoseTarget : null;

  /// Dasselbe für Termine.
  EventTarget? get event =>
      target is EventTarget ? target as EventTarget : null;

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.target == target &&
      other.kind == kind &&
      other.fireAt == fireAt &&
      other.repeatIndex == repeatIndex;

  @override
  int get hashCode => Object.hash(target, kind, fireAt, repeatIndex);

  @override
  String toString() =>
      'Reminder($target, ${kind.name}, ${fireAt.toIso8601String()}'
      '${repeatIndex != null ? ', #$repeatIndex' : ''})';
}
