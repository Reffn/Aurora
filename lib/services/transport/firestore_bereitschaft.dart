import 'package:cloud_firestore/cloud_firestore.dart';

/// Ob Firestore überhaupt ein Ziel hat — die eine Prüfung für beide Kanäle.
///
/// **Warum das eine Funktion ist und keine zwei.** Feedback und Telemetrie
/// haben bewusst getrennte Sendewege: Ihre Nutzlasten sind gegenläufig — der
/// Feedback-Kanal *muss* einen Server-Zeitstempel tragen
/// (`firestore.rules`: `data.createdAt == request.time`), die Telemetrie darf
/// *keinen* haben, weil sich mehrere Eingänge derselben Minute sonst zu einer
/// Sitzung zusammenfassen ließen. Diese Trennung schützt eine Zusage und
/// bleibt.
///
/// Die Bereitschaftsprüfung schützt nichts davon. Sie stand trotzdem zweimal
/// da, Zeichen für Zeichen gleich — und ausgerechnet sie ist die
/// Schutzvorrichtung: Eine Compile-Zeit-Konstante an dieser Stelle lässt den
/// Compiler den gesamten Sendepfad entfernen, ohne dass es zur Laufzeit
/// auffällt. Genau das hat den Feedback-Kanal acht Monate stillgelegt
/// (`docs/superpowers/specs/2026-08-04-feedback-rueckkanal-design.md`).
///
/// Zweimal gepflegt heißt: Wer eine Hälfte repariert, lässt die andere kaputt
/// — und beide versagen still. Deshalb steht sie jetzt einmal hier.
///
/// Bleibt eine **Laufzeit**-Prüfung: `FirebaseFirestore.instance` wird erst
/// beim Aufruf berührt, nie zur Übersetzungszeit ausgewertet.
bool firestoreHatZiel() {
  try {
    return FirebaseFirestore.instance.app.options.projectId.isNotEmpty;
  } catch (_) {
    // Firebase nicht initialisiert oder Zugriff fehlgeschlagen.
    return false;
  }
}
