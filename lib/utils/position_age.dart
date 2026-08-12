import 'package:dis_app/l10n/app_texts.dart';

/// Alter einer gespeicherten Position in Worten.
///
/// Grob gerundet: Wer im Notfall auf die Karte sieht, braucht „vor zwei
/// Tagen", nicht „vor 51 Stunden und 12 Minuten". Die Zahl soll die
/// Entscheidung tragen, ob man sich auf den Punkt verlassen kann — nicht
/// Genauigkeit vortäuschen, die eine alte Messung nicht hat.
String formatPositionAge(Duration age) {
  final texts = AppTexts.current;
  if (age.inMinutes < 2) return texts.timeJustNow;
  if (age.inMinutes < 60) return texts.timeMinutesAgo(age.inMinutes);

  // Bis sechs Stunden zurück auch die Minuten.
  //
  // „Vor einer Stunde" galt vorher von sechzig bis hundertneunzehn Minuten —
  // eine halbe Stunde Unschärfe. Für den Blick auf eine tagealte Position ist
  // das die richtige Rundung; für die Frage „wie lange war ich weg" ist es zu
  // grob, und genau die stellt sich beim Hochkommen. Auf fünf Minuten
  // gerundet, weil eine Position auf die Minute genau eine Genauigkeit
  // vortäuschte, die eine GPS-Messung im Zwei-Minuten-Takt nicht hat.
  if (age.inHours < 6) {
    final minutes = (age.inMinutes % 60 / 5).round() * 5;
    // Volle Stunde nach dem Runden: dann trägt der Stundensatz allein.
    if (minutes == 0 || minutes == 60) {
      return texts.timeHoursAgo(age.inHours + (minutes == 60 ? 1 : 0));
    }
    return texts.timeHoursMinutesAgo(age.inHours, minutes);
  }

  if (age.inHours < 24) return texts.timeHoursAgo(age.inHours);
  return age.inDays == 1
      ? texts.positionAgeYesterday
      : texts.timeDaysAgo(age.inDays);
}
