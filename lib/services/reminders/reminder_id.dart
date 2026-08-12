import 'package:dis_app/services/reminders/reminder.dart';

const int _payloadBits = 27;
const int _payloadMask = (1 << _payloadBits) - 1;

/// Kennung aus Namensraum und einem beliebigen Schlüssel.
int namespacedId(int namespace, String seed) {
  var hash = 0;
  for (var i = 0; i < seed.length; i++) {
    hash = seed.codeUnitAt(i) + ((hash << 5) - hash);
    hash &= 0x7FFFFFFF;
  }
  return (namespace << _payloadBits) | (hash & _payloadMask);
}

/// Kennung einer Erinnerung — vollständig aus ihrem Inhalt abgeleitet.
///
/// Der Vorgänger `_generateNotificationId` kannte kein Datum. Die
/// Erinnerung von heute und die von morgen trugen damit dieselbe Kennung,
/// und die zweite überschrieb die erste. Ohne Datum lässt sich auch kein
/// Ist gegen Soll vergleichen, ohne eine Merkliste zu führen — und genau
/// diese Merkliste war die dritte Kopie der Wahrheit.
///
/// Der Zielpunkt liefert Namensraum und Schlüssel selbst; diese Funktion
/// hängt Art, Wiederholung **und den Zeitpunkt** an. Damit kann kein neuer
/// Zielpunkt-Typ vergessen werden.
///
/// Warum die Feuerzeit dazugehört: sie ist nicht immer aus dem Ziel
/// ableitbar. Zwei Fälle, beide auf dem Gerät belegt —
///
/// * Ein Termin behält Kennung und Startzeit, aber sein Vorlauf wechselt
///   von 30 auf 15 Minuten. Ohne Zeit in der Kennung sieht der Abgleich
///   keine Differenz, und die Meldung bleibt auf der alten Zeit stehen.
/// * Wer zweimal „später" tippt, meint das zweite Mal. Dosis und Art sind
///   dieselben, das Ziel ist es nicht.
///
/// Mit der Zeit in der Kennung bezeichnet sie genau das, was das
/// Betriebssystem hält: diese Meldung zu diesem Zeitpunkt. Jede
/// Verschiebung wird dadurch zu einem Abmelden und einem Anmelden — was
/// sie ist.
int reminderId(Reminder reminder) => namespacedId(
  reminder.target.namespace,
  '${reminder.target.seed}|${reminder.kind.name}'
  '|${reminder.repeatIndex ?? 0}|${reminder.fireAt.toIso8601String()}',
);

/// In welchem Namensraum liegt diese Kennung?
int namespaceOf(int id) => id >> _payloadBits;

/// Gehört diese Kennung zu einer Medikamenten-Erinnerung?
bool isMedicationId(int id) => namespaceOf(id) == kNamespaceMedication;

/// Gehört diese Kennung zu einer Termin-Erinnerung?
bool isEventId(int id) => namespaceOf(id) == kNamespaceEvent;

/// Gehört diese Kennung überhaupt dem Abgleich?
///
/// Alles andere lässt er unangetastet — es könnte von einem Teil der App
/// stammen, den er nicht kennt.
bool isOwnId(int id) => isMedicationId(id) || isEventId(id);
