/// Macht aus einer vollen Adresse den Teil, den man auf einer Zeile erkennt.
///
/// „Kirchstraße 3, 01640 Coswig, Deutschland" wird zu „Kirchstraße 3". Die
/// Zeile soll erkannt werden, nicht gelesen — Postleitzahl und Land tragen
/// dazu nichts bei.
///
/// Der erste Teil allein genügt nicht: Nominatim stellt die Hausnummer als
/// eigene Komponente voran, sodass dabei „37" herauskommt — eine Zahl ohne
/// Ort. Sieht der erste Teil nach einer Hausnummer aus, gehört die Straße
/// dahinter dazu.
///
/// „Sieht nach Hausnummer aus" heißt nicht „besteht nur aus Ziffern":
/// „244a", „90D" und „12-14" sind Hausnummern. Die frühere Regel verlangte,
/// dass kein Buchstabe vorkommt — auf der Kontaktkarte stand deshalb „244a"
/// als ganze Ortsangabe.
///
/// Stand bis zum 7. August 2026 in `recent_presence_band.dart`. Das
/// Anwesenheitsband wurde von der Zeitkarte abgelöst und entfernt; diese
/// Funktion hatte damit nie etwas zu tun — vier Flächen benutzen sie
/// (Kontaktkarte, Finder-Karte, Ortsauswahl im Kalender, Zeitkarte).
String? shortPlace(String? address) {
  if (address == null) return null;

  final parts = address
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return null;

  final head = parts.first;
  final looksLikeHouseNumber = RegExp(
    r'^\d+\s*[a-zA-Z]?([-/]\s*\d+\s*[a-zA-Z]?)*$',
  ).hasMatch(head);
  if (looksLikeHouseNumber && parts.length > 1) {
    return '${parts[1]} $head';
  }
  return head;
}
