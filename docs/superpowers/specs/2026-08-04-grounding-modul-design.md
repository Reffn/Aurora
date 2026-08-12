# Grounding-Modul — Design

**Stand:** 2026-08-04
**Teilprojekt:** TP1 aus `docs/superpowers/research/2026-08-04-dis-abgleich-bericht.md`
**Status:** Design freigegeben, Umsetzungsplan folgt

---

## 1. Warum

Erdungsfertigkeiten sind der Baustein mit der besten Evidenz im gesamten Feld und fehlen in
Aurora vollständig. Das Programm *Finding Solid Ground* nennt Grounding ausdrücklich als
notwendige erste Stufe, ohne die der Rest der Stabilisierungsarbeit nicht greift; in der
zugehörigen RCT übertraf es Einzeltherapie allein mit großen Effektstärken nach einem Jahr. Im
TOP-DD-Network-Programm (web-basiert, Video und Übungen) sank die nicht-suizidale
Selbstverletzung gerade bei den zuvor am stärksten betroffenen Teilnehmenden.

Aurora hat heute Mantras und Spiele. Beides ersetzt Grounding nicht: Spiele wirken über
Absorption, und Absorption ist der Mechanismus der Dissoziation, nicht ihr Gegenmittel.

Belege im Bericht, Abschnitt II.2 und III.B1.

## 2. Ziel

Fünf Erdungsübungen, die ohne Lesen und ohne Ton funktionieren, für jeden Anteil jederzeit
erreichbar, ohne dass etwas gespeichert wird.

## 3. Nicht-Ziele

- **Keine Traumaarbeit.** Ausschließlich Phase 1. Keine Erinnerungsübung, keine Exposition.
- **Kein Tracking.** Keine Historie, keine Zählung, keine Auswertung. Siehe Entscheidung 4.
- **Keine Diagnostik.** Kein Fragebogen, kein Schweregrad, keine Einordnung.
- **Keine eigenen Übungen.** Anlegen und Bearbeiten kommt später, wenn überhaupt.
- **Keine Mantras-Funktion.** Der bisherige Platzhalter-Screen wird durch die Erdungsübersicht
  ersetzt (siehe Abschnitt 8), aber Mantras als Inhalt entstehen hier nicht. Sie werden später
  eine weitere Kachel im selben Bereich.

## 4. Entscheidungen

| # | Frage | Entscheidung | Begründung |
|---|---|---|---|
| 1 | Wodurch führt eine Übung? | Gezeichnete Bildfolge, ein Bild je Schritt, Tippen geht weiter | Funktioniert ohne Ton und ohne Lesen — also nachts, unterwegs, mit stummem Gerät. Text bestätigt nur |
| 2 | Woher kommen die Bilder? | Frei lizenzierter Satz als erste Füllung, über Schlüssel referenziert und später austauschbar | Repo soll MPL-2.0 werden. Verbreitete AAC-Sätze wie ARASAAC stehen unter CC BY-NC-SA und sind damit unbrauchbar. Die Entkopplung verhindert, dass die Bildfrage das Modul blockiert |
| 3 | Wie kommt man zur Übung? | Ein großer Anker startet sofort die Orientierungsübung, darunter fünf Kacheln | Im dissoziativen Zustand ist Auswählen selbst schon Überforderung. Wer wählen kann, kann trotzdem wählen |
| 4 | Was passiert am Ende? | Drei gleichwertige Wege: nochmal, was anderes, jemanden anrufen. Keine Bewertung | Eine Frage „hat es geholfen?" lässt sich mit Nein beantworten, und ein Misserfolgserlebnis genau dort schadet. Zugleich liegt der Weg zur Notfallhilfe damit im Ablauf statt in einem anderen Tab |

## 5. Die fünf Übungen

Abgeleitet aus *Finding Solid Ground* und den ISSTD-Leitlinien zu Phase 1.

| id | Übung | Zweck |
|---|---|---|
| `orientation` | Hier und Jetzt | Datum, Uhrzeit, Ort, Alter des Körpers, „es ist vorbei". Der wichtigste Skill nach einem Zeitverlust |
| `senses` | 5-4-3-2-1 | Sinnesansprache, der am breitesten belegte Ablauf |
| `body` | Körper spüren | Füße auf dem Boden, Eis, kaltes Wasser, Druck |
| `container` | Wegschließen | Belastendes kontrolliert und reversibel verstauen |
| `breath` | Atem | Länger aus- als einatmen |

Rund sechs Schritte je Übung, also etwa 30 Bilder.

`orientation` ist die Übung hinter dem Anker. Ihr erster Schritt zeigt echtes Datum und echte
Uhrzeit — der einzige dynamische Inhalt im ganzen Modul.

## 6. Architektur

```
lib/modules/grounding/
  grounding_screen.dart            Übersicht: Anker + fünf Kacheln
  exercise_player_screen.dart      Schritt-für-Schritt-Ablauf
  data/
    grounding_exercises.dart       die fünf Übungen als const
    grounding_images.dart          imageKey → Assetpfad
  models/
    grounding_exercise.dart        GroundingExercise + GroundingStep
  widgets/
    anchor_button.dart             der große Anker
    exercise_tile.dart             eine Kachel
    step_view.dart                 Bild + Text + Fortschritt eines Schritts
    exercise_done_sheet.dart       die Leiter am Ende
```

**Kein Service, kein Hive-Adapter, keine DataEntry-Erweiterung.** Das Modul liest keinen
Zustand und schreibt keinen. Der Ablauf lebt ausschließlich im State von
`ExercisePlayerScreen`. Damit entfällt auch jede Frage nach Rechten auf gespeicherte Daten.

Das Muster für statische Inhalte existiert bereits in `lib/utils/did_you_know_facts.dart` —
`grounding_exercises.dart` folgt ihm, statt eine zweite Konvention einzuführen.

### Datenmodell

```dart
class GroundingExercise {
  final String id;                 // 'orientation', 'senses', …
  final String titleKey;           // l10n-Schlüssel
  final IconData icon;
  final Color color;
  final List<GroundingStep> steps;
}

class GroundingStep {
  final String imageKey;           // Schlüssel, nie ein Pfad
  final String textKey;            // l10n, bestätigt nur
  final Duration? hold;            // optional, blockiert nie
}
```

Reines Dart, keine Hive-Annotationen, keine Generierung.

### Bildauflösung

`GroundingImages.resolve(String imageKey)` ist die einzige Stelle im Modul, die Assetpfade
kennt. Ein Wechsel des Bildersatzes ändert genau diese Map — keine Übung, kein Widget, kein
Test.

Bewusst getrennt von `AttachmentHelper` und `ProfileImageWidget`: die lösen nutzergenerierte
Dateien im Dokumentenverzeichnis auf und unterscheiden Datei- von Assetpfaden. Grounding-Bilder
sind ausschließlich gebündelte Assets. Die beiden Fälle zusammenzulegen würde beide Seiten
komplizierter machen, nicht einfacher.

## 7. Wiederverwendung statt Neubau

Der Bestand deckt einen großen Teil ab. Was genutzt wird:

| Vorhanden | Wofür |
|---|---|
| `StandardAppBar` | Kopfzeile der Übersicht |
| `AnimatedTapCard` | Anker und Kacheln, inklusive Druckfeedback |
| `IconContainer.circle` | Grundform aller runden Symbole |
| `SectionHeader` | Überschrift über den Kacheln |
| `AnimatedEmptyState` | Fallback, falls kein Bildersatz vorhanden ist |
| `did_you_know_facts.dart` | Muster für statische Inhaltslisten |

Zwei Widgets werden aus dem Rechte-Bereich hochgezogen, weil dieses Modul sie identisch
braucht. Sie entstanden dort am 2026-08-04 als private Klassen; sie jetzt zu kopieren wäre
genau die Redundanz, die vermieden werden soll.

**`lib/widgets/progress_dots.dart`** — aus `_PermissionDots`. Punktereihe, gefüllt und offen.
Verwender: Kategoriezeile im Rechte-Detail, Schrittanzeige im Player. Parameter: `active`,
`total`, `color`, `maxDots` (darüber wird nichts gezeichnet).

**`lib/widgets/state_symbol.dart`** — aus `_PermissionSymbol`. Rundes Symbol, dessen Zustand
doppelt kodiert ist: Farbe **und** Füllung, nie nur eines von beidem. Optionales Abzeichen in
der Ecke. Setzt intern auf `IconContainer.circle` auf statt einen eigenen Kreis zu bauen.
Verwender: Rechteliste (erlaubt / nicht erlaubt, Schloss als Abzeichen), Grounding-Kacheln.

Beide Umbauten gehören in die Umsetzung dieses Teilprojekts, nicht in einen späteren
Aufräumschritt.

## 8. Verhalten

### Übersicht

Ein großer Knopf oben startet `orientation` mit einem Tippen und trägt deren Namen
„Hier und Jetzt". Darunter die **vier übrigen** Übungen als Kacheln, je zwei pro Reihe.

**Korrektur vom 2026-08-05, nach dem Test am Gerät:** Ursprünglich hieß der Knopf „Anker" und
darunter standen alle fünf Übungen. Beides war falsch.

„Anker" ist eine Metapher — der Begriff existiert in der Traumatherapie, meint dort aber das
Verknüpfen eines Reizes mit einem Zustand, nicht Erdung. Vor allem verlangt eine Metapher
Lesen und Deuten, und das Symbol ⚓ zeigt ein Schiff. Wer nicht liest, sieht kein „hier finde
ich Halt". Die W3C-COGA-Leitlinien raten von Metaphern ab; der Knopf trägt jetzt schlicht den
Namen der Übung, die er startet.

Die fünf Kacheln enthielten die Ankerübung ein zweites Mal — zwei Wege mit demselben Symbol
direkt untereinander. Die Übersicht zeigt deshalb nur noch `GroundingExercises.others`.

### Ablauf einer Übung

- Tippen irgendwo auf die Fläche geht einen Schritt weiter. Kein kleines Ziel.
- Zurück ist auf jedem Schritt erreichbar.
- `hold` zeichnet einen Ring, blockiert aber nichts. Kein Timer läuft weg, während jemand weg
  ist.
- Abbrechen jederzeit, ohne Rückfrage.
- Wer die App mitten in der Übung verlässt, landet beim nächsten Start auf der Übersicht. Ein
  „willst du weitermachen?" wäre in dem Zustand eine Zumutung.

Diese Regeln kommen aus Abschnitt III.B9 des Berichts und gelten hier zum ersten Mal
verbindlich.

### Abschluss

Drei Wege, gleich gewichtet, ohne Bewertung: **nochmal**, **was anderes**, **jemanden
anrufen**.

### Erreichbarkeit und Rechte

**Erdung ist nicht rechtegesteuert.** Wie der Chat immer sichtbar ist, muss Erdung für jeden
Anteil jederzeit erreichbar sein. Ein Anteil, dem ein anderer die Erdungsübungen entziehen
kann, ist genau die Machtdynamik aus Abschnitt III.C1.

Der Weg „jemanden anrufen" führt in den Notfallbereich. Fehlt dem Anteil das Recht
`callEmergencyContacts`, führt er stattdessen zu den Hotlines — die gehören keinem Profil und
brauchen kein Recht. Der Knopf zeigt nie ins Leere.

### Änderungen am Bestand

- Der Mantras-Tab wird zum Erdungs-Tab: Beschriftung **„Halt"**, Symbol Anker. Er ist ab jetzt
  immer sichtbar, unabhängig von `viewMantrasTab` — genau wie der Chat-Tab.
- `viewMantrasTab` bleibt als Recht bestehen und steuert später die Mantras-Kachel innerhalb
  des Bereichs, nicht mehr den Zugang zum Bereich.
- `MantrasScreen` wird durch `GroundingScreen` ersetzt. Der bisherige Platzhalter entfällt.

## 9. Fehlerfälle

| Fall | Verhalten |
|---|---|
| `imageKey` löst nicht auf | Kategoriesymbol der Übung springt ein, Ablauf läuft weiter |
| `textKey` fehlt | Schritt zeigt nur das Bild. Der Text bestätigt ohnehin nur |
| Übung ohne Schritte | Kachel wird nicht angezeigt; ein Test verhindert, dass dieser Fall überhaupt entsteht |
| Kein Bildersatz vorhanden | `AnimatedEmptyState` statt leerer Fläche |

Kein Zustand führt zu einem leeren Bildschirm oder einem Absturz.

## 10. Tests

**Inhaltliche Vollständigkeit** — verhindert die stille Lücke, die beim Feedbackkanal acht
Monate gekostet hat:

- jeder `imageKey` aller fünf Übungen löst über `GroundingImages` auf
- jeder `textKey` existiert in `app_de.arb`
- jede Übung hat mindestens einen Schritt

**Die Zusagen als Test** — analog zum bestehenden Test auf das Feedback-Payload-Schema:

- das Modul öffnet keine Hive-Box und schreibt in keinen Service
- `GroundingScreen` rendert für ein Profil ohne jedes Recht

**Verhalten:**

- Anker startet `orientation`, erster Schritt zeigt das heutige Datum
- Tippen auf die Fläche geht weiter; der letzte Schritt führt zur Abschluss-Leiter
- Zurück ist auf jedem Schritt erreichbar
- `hold` blockiert das Weitertippen nicht
- „jemanden anrufen" führt zu den Hotlines, wenn `callEmergencyContacts` fehlt

**Regression nach dem Hochziehen der Widgets:**

- `ProgressDots` und `StateSymbol` rendern in beiden Verwendern unverändert

## 11. Offene Punkte

1. **Welcher Bildersatz konkret?** — **offen, mit neuer Erkenntnis vom 2026-08-05.**

   Der ursprüngliche Kandidat OpenMoji (CC BY-SA 4.0) trägt weniger weit als angenommen:
   Emoji zeigen **Gegenstände, keine Handlungen**. Es gibt ✋ und 🧊 einzeln, aber kein Bild
   „eine Hand hält einen Eiswürfel". Für die Sinnes- und die Atemübung reicht ein
   Gegenstandssymbol; für „Stell beide Füße flach auf den Boden" oder „Leg hinein, was gerade
   zu viel ist" reicht es nicht — und das sind gerade die Schritte, bei denen das Bild am
   meisten tragen müsste.

   Damit stehen realistisch zur Wahl: Emoji kombinieren, wo es trägt; einen anderen frei
   lizenzierten Bestand suchen, der Handlungen zeigt (unter Ausschluss der NC-Lizenzen wie
   ARASAAC); oder Zeichnungen beauftragen. Ein uneinheitlicher Satz verwirrt im dissoziativen
   Zustand mehr, als er hilft — das bleibt das Ausschlusskriterium.

   **Entschieden am 2026-08-05:** Das Modul geht ohne Bildersatz in Betrieb. Es läuft mit dem
   Symbol der jeweiligen Übung, groß und farbig. Die Bildfrage bekommt damit die Zeit, die sie
   braucht, ohne fünf fertige Übungen aufzuhalten. Der Vollständigkeitstest wird von selbst
   scharf, sobald die Pfad-Map gefüllt ist.
2. **Braucht der Anker eine eigene Farbe** oder erbt er die der Orientierungsübung?
3. **Erreichbarkeit von außen.** Dieses Design macht Erdung im Tab erreichbar. Der Zugang vor
   dem Login und der Weg direkt aus einer Krise gehören zu TP2 und bleiben hier offen.

## 12. Verweise

- Bericht: `docs/superpowers/research/2026-08-04-dis-abgleich-bericht.md`, Abschnitte II.2,
  III.B1, III.B9, III.C1, TP1, TP12
- [Finding Solid Ground — Programmbeschreibung](https://www.findingsolidground.info/about)
- [Brand et al., TOP DD Network, 1- und 2-Jahres-Nachuntersuchung](https://onlinelibrary.wiley.com/doi/full/10.1002/jts.22370)
- [ISSTD Guidelines for Treating DID in Adults](https://www.isst-d.org/wp-content/uploads/2025/12/GUIDELINES_REVISED2011.pdf)
