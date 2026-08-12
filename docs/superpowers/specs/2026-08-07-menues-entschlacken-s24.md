# Menüs entschlacken: Durchlauf am Samsung S24, 7. August 2026

**Gerät:** SM-S921B (`R3CX10FH1RP`), 1080×2340, Debug-Build aus dem
Arbeitsbaum (Branch `ui/aufraeumen-a14`, nicht committet).
**Profil:** „Lina", Sprache Englisch — die Profilsprache greift, der Anker
stand durchgehend englisch da.

Anlass: die Menüs fühlten sich sperrig an. Geprüft gegen
`docs/oberflaechen-richtlinien.md`; die Befundnummern (A2, A4, …) sind die aus
`2026-08-07-ui-durchlauf-a14-befunde.md`. Punkt 1 der dortigen Vorschlagsliste
ist damit abgearbeitet.

Nichts Auswärtsgerichtetes ausgelöst: kein Anruf, kein Absenden, keine
Einwilligung umgeschaltet.

---

## Was gebaut wurde

### A2 — der Anteil stand zweimal untereinander

Kopfzeile: Avatar mit Farbring und Name. Direkt darunter im Markenband
dieselbe Auskunft noch einmal, als Pille mit Rand: „Lina (Du)".

`_DuMarke` in `quick_timeline_band.dart` trägt jetzt nur noch den Avatar mit
Farbring — er bleibt der Drehpunkt zwischen Vergangenheit und Zukunft, aber er
wiederholt den Namen nicht. Der Name steht einmal, oben, und bleibt beim
Scrollen sichtbar. Für Vorlesehilfen trägt der Avatar „Lina (Du)" als
Semantik-Beschriftung weiter; der Test prüft genau das.

### A3 + A9 — die Zeile sah aus wie ein Knopf und war keiner

Die Anteilszeile trug Umrandung und Profilfarbe, reagierte aber nicht. Wer im
schlechten Zustand den Weg zum Profil oder zu den Einstellungen suchte, griff
genau dorthin ins Leere.

`WorkSurfaceScaffold` hat einen neuen `onProfileTap`. Die Anteilszeile führt
jetzt ins Profilmenü (Profil bearbeiten / Einstellungen / Ausloggen) — von
**jeder** Arbeitsfläche aus, nicht mehr nur vom Anker. Damit ist „Was Aurora
sendet" erreichbar, ohne den Weg über den Anker zu kennen; die
Transparenz-Zusage hängt nicht länger an einem einzigen versteckten Griff.

Zwei Dinge dazu:

- **Das ⇄ ist weg.** Es hieß „wechseln", dahinter lagen drei Dinge, von denen
  keines den Anteil wechselt. Anker und Arbeitsfläche tragen jetzt beide ein
  Zahnrad in Profilfarbe, direkt neben dem Namen — nie ein Symbol allein
  (Regel 5).
- **Das Bottom-Sheet sagt jetzt, was es ist.** Kopfzeile „Profil und
  Einstellungen" (`profileMenuTitle`, in allen fünf Sprachen). Vorher standen
  dort drei Einträge ohne Überschrift.

Ohne `onProfileTap` bleibt die Zeile reine Auskunft und trägt kein Zahnrad —
ein Test hält beide Fälle fest.

### A4 — zwei Kopfzeilen, zwei Rückwege

Der Befund war systemisch, aber kleiner als er aussah: `StandardAppBar` baut
ohne Titel nur die 1-px-Profilfarblinie (Höhe 0). Nur zwei Flächen gaben einen
Titel mit — und genau die hatten die doppelte Kopfzeile:

- `grounding_screen.dart` → `StandardAppBar()` ohne Titel.
- `contacts_screen.dart` baute eine eigene `AppBar` mit Titel und
  112 px Höhe → ersetzt durch `StandardAppBar(bottom: Filterreihe)`.

Am Gerät nachgeprüft: Ground und Contacts tragen jetzt genau eine Kopfzeile
und genau einen Rückweg (Prüffrage 5).

`settings_screen.dart` und `transparency_screen.dart` behalten ihren Titel —
sie werden als eigene Route geöffnet und liegen nicht unter dem
`WorkSurfaceScaffold`.

### Nebenbefund, mitbehoben: das Markenband führte nirgendwohin

Der eigene Kommentar des Bandes sagte „wer mehr wissen will, tippt das Band an
und landet dort" — der `onTap` wurde in `main.dart` nie gesetzt. Der `InkWell`
lag also über dem Band und tat nichts. Er führt jetzt zur Chronologie.

### Nachtrag: das weiße Medaillon der drei farbigen Zeilen ist weg

Aufgefallen beim Gegenblick aufs A14: Halt, Notfall und Hilfe trugen ihre
Figur auf einem weißen, abgerundeten Feld, die neun anderen Zeilen nicht. Die
Begründung im Code lautete, die gelb-grüne Mitte der Figur verschwände sonst
auf der Farbfläche.

Am Gerät stimmt das nicht mehr: Romys Figuren haben eine eigene dunkle Kontur
und stehen auch auf Grün, Rot und Orange. Die Begründung stammte aus der Zeit
der flachen Schablonen. Was das Feld tatsächlich tat, war ein aufgeklebtes
Rechteck in drei von zwölf Zeilen — dieselbe Handlung in zwei Bauformen
(Regel 7).

`anchor_row.dart` baut jetzt für alle Zeilen dieselbe Figur ohne Feld. Der
Unterschied zwischen laut und leise bleibt, wo er hingehört: volle Farbfläche
gegen dunkle Karte mit Farbstreifen. Auf beiden Geräten nachgesehen.

---

## Geprüft

- `flutter analyze` — keine Fehler oder Warnungen in den berührten Dateien.
- `dart run custom_lint` — „No issues found".
- `flutter test` — **421 Tests grün** (die zwanzig zusätzlichen kommen aus der
  parallelen Erinnerungs-Arbeit), darunter zwei neue in
  `work_surface_scaffold_test.dart` (Zeile führt ins Menü / ohne Rückruf kein
  Zahnrad) und die angepasste Erwartung in `quick_timeline_band_test.dart`.
- Am S24 durchgespielt: Profilauswahl → Anker → Profilmenü → Emergency →
  Profilmenü von der Arbeitsfläche → Contacts → Ground. Der ganze Weg bis zum
  Ziel: Ground → Anteilszeile → „Settings" → Einstellungen offen → zurück
  landet wieder auf Ground. Damit ist A9 nicht nur bis zur Tür geprüft.

Nicht geöffnet und damit ungeprüft: Chat, Calendar, Diary, Medication, Finder,
Games, Timeline, Feedback.

---

## Neue Befunde vom S24

1. **Die Profilnamen werden unten abgeschnitten.** Auf der Profilauswahl steht
   „Lina" und „Mina" halb im Bild, der Rest liegt unter der Kante; darunter
   folgen Impressum und Datenschutzerklärung. Erreichbar ist der Name durch
   Scrollen (Prüffrage 6 ist also nicht verletzt), aber die eine Angabe, die
   man auf dieser Fläche lesen muss, ist die erste, die verschwindet. Ursache
   ist die Höhensumme aus Zeitkarte (280), Tageszeile und Überschrift. Das ist
   eine Abwägung — Kartenhöhe gegen Namen —, deshalb hier notiert und nicht
   nebenbei entschieden.
2. **Im Band steht eine Wechselmarke „⇄ Lina" unmittelbar vor dem
   Jetzt-Avatar desselben Anteils.** Zweimal dieselbe Person in
   Nachbarschaft — die letzte Wechselmarke auf den aktiven Anteil sagt nichts,
   was der Drehpunkt nicht schon sagt.
3. **„Wer war da?" ist die Überschrift der Zeitkarte** und liest sich wie eine
   Frage nach Personen, während die Karte zuerst Orte zeigt. Kein Fehler, aber
   Wort und Fläche zielen auseinander.
4. **Der Aurora-Schriftzug klebt weiter an der Unterkante der Kopfzeile**
   (C4 aus dem A14-Durchlauf, weiterhin nur gemildert).
5. **Gute Nachricht zu B1:** Am S24 tragen Chat, Calendar, Medication, Diary,
   Contacts, Finder, Ground, Emergency und Help durchweg einzeln gezeichnete
   Chamäleons in Romys Stil. Der Zwei-Stile-Bruch aus dem A14-Durchlauf ist
   auf diesem Stand nicht mehr zu sehen — vor dem Abhaken sollte jemand die
   restlichen Bereiche (Games, Timeline, Feedback) gegenprüfen.

## Runde 2, gleicher Tag

### Die Profilnamen standen halb unter der Kante — behoben

Die Zeitkarte hatte auf der Profilauswahl feste 260 dp. Zusammen mit Kopf,
Tageszeile, beiden Überschriften und einer Rasterreihe war das mehr, als der
Schirm hergibt; abgeschnitten wurde als Erstes der Name, also genau die
Angabe, für die die Fläche existiert.

`profile_selection_screen.dart` rechnet die Kartenhöhe jetzt aus dem, was nach
der Wahl übrig bleibt (`clamp(150, 260)`), und zählt dabei die tatsächliche
Zahl der Rasterreihen mit. Am S24 stehen „Lina" und „Mina" vollständig da,
darunter „zuletzt vor 17 Minuten". Die Reihenfolge ist damit festgelegt: erst
die Wahl vollständig, dann so viel Karte, wie danach hineinpasst.

### Zwei Bandbefunde — behoben

- **Wechselmarke auf sich selbst.** Endete die Vergangenheit mit einem Wechsel
  auf den Anteil, der gerade hier ist, stand derselbe Mensch zweimal
  nebeneinander („⇄ Lina › [Lina]"). Die Marke fällt jetzt weg — aber nur am
  Ende: mitten in der Kette sagt sie etwas und bleibt. Am Gerät bestätigt:
  „✓ Vitamin D › ⇄ Lina › ⚠ Vitamin D › [L]".
- **Band ohne Marken.** Blieb nur der Avatar übrig, stand er allein auf einer
  leeren Leiste — dieselbe Auskunft, die einen Zentimeter höher schon steht.
  `QuickTimelineBand.hasContent` entscheidet das jetzt vor dem Einhängen; ohne
  Inhalt trägt die Kopfzeile keine zweite Zeile.

### Der Chat startete im Malmodus, ohne dass jemand das gewählt hatte

Der schwerste Fund dieser Runde. `chat_screen.dart` setzte
`_drawing = age == null || age <= 8` — **`null` hieß dasselbe wie „acht Jahre
alt"**. Das Alter ist keine Pflichtangabe; wer keines hinterlegt hat, fand den
Chat mit abgeblendetem Verlauf (Deckkraft 0,3), aktiver Zeichenfläche, sechs
Werkzeugknöpfen und neun Farbkreisen vor. Die einzige Nachricht im Verlauf war
grau und sah aus wie deaktiviert.

Jetzt: `age != null && age <= 8`. Unbekannt ist nicht Kind, und der lautere
von zwei Zuständen darf nicht der geratene sein — Regel 9 sagt, Zustände
werden angeboten, nicht erkannt. Am Gerät: Nachricht voll lesbar, der
Pinselknopf steht daneben und lädt ein.

Für junge Anteile ändert sich nichts.

### Zurückgenommen: der Zurück-Tasten-Befund

Ich hatte notiert, ein Druck aus einer Arbeitsfläche lande auf dem Anker *und*
werfe „App beenden?" hinterher. Sauber nachgestellt (Ground → einmal zurück):
Anker, kein Dialog. Am A14 hatte ich vorher schon einmal gedrückt und falsch
gezählt.

### Noch offen aus dieser Runde

- ~~Die Zeichenwerkzeuge und die Farbreihe stehen weiterhin dauerhaft über dem
  Chat, alle nur Symbol, und zwei identische Sende-Pfeile liegen gleichzeitig
  auf dem Schirm (B7 unverändert).~~ *Runde 3.*
- ~~Bei 150 dp Kartenhöhe füllen Datum, Uhrzeit und Adresse fast die halbe
  Karte. Der Kopf der Zeitkarte skaliert nicht mit ihrer Höhe.~~ *Runde 3.*

## Runde 3, 8. August

### Die Werkzeuge stehen hinter dem Pinsel — behoben

Sechs Werkzeugknöpfe am rechten Rand und dreizehn Punkte der Materialleiste
darunter standen dauerhaft über dem Nachrichtenverlauf, auch für jemanden, der
gerade blätterte. Neunzehn Bedienelemente ohne ein einziges Wort, für eine
Handlung, die niemand gewählt hatte.

`DoodleCanvas` zeigt beides jetzt nur noch, solange gemalt wird. Im
Blättermodus bleibt ein Pinsel in Profilfarbe stehen und sonst nichts
(`_FoldedRail`). Er steht dabei **nicht** zuoberst, sondern an der Stelle, an
der im aufgeklappten Zustand der Umschalter sitzt — läge er ganz oben, erschiene
nach dem Tippen der Sende-Knopf genau dort, wo der Finger eben war. Die Spalte
behält ihre 60 dp Breite, damit unter ihr nichts springt.

Ausnahme: Ohne Umschalter (`showModeToggle: false`, das gemalte Profilbild)
bleiben die Werkzeuge stehen. Dort gibt es keinen Weg zurück in sie hinein.

### Zwei gleiche Sende-Pfeile — behoben

Der Pfeil der Zeichenfläche und der Pfeil der Textzeile lagen gleichzeitig auf
dem Schirm: dasselbe Symbol, dasselbe Wort, zwei verschiedene Inhalte. Die
Textzeile tritt jetzt zurück, solange gemalt wird; der Pinsel holt sie zurück.
In jedem Zustand steht genau ein Sende-Pfeil.

**Verborgen, nicht entfernt.** Der erste Versuch nahm die Zeile per
`if (!_drawing)` aus dem Baum — und damit ihren `TextEditingController`. Ein
halb getippter Satz wäre nach einem Griff auf den Pinsel weg gewesen, lautlos
und ohne Weg zurück; und gerade in dieser App wird ein Knopf auch ungewollt
getroffen. Jetzt steht ein `Visibility(maintainState: true)` darum. Beim
Umschalten geht außerdem der Fokus weg, sonst bliebe die Tastatur über der
Zeichenfläche stehen.

Kamera und Mikrofon (`CaptureBar`) bleiben in beiden Fällen stehen. Sie sind
die Wege für alle, die nicht schreiben — und genau die beginnen im Malmodus.

Mitbehoben: Die leere Chatfläche rückte immer um die Breite der Werkzeugleiste
nach links, auch wo gar keine Leiste stand (fehlende Zeichenberechtigung).
`_buildMessageList` bekommt jetzt gesagt, ob rechts etwas liegt.

### Der Kopf der Zeitkarte richtet sich nach der Karte — behoben

Der Kopf war absolut gemessen, die Karte nicht: bei 260 dp ein Viertel der
Fläche, bei 150 dp fast die Hälfte. Unterhalb von `TimeMap.compactBelowHeight`
(200 dp) wird er kleiner gesetzt — 12/12/11 statt 15/15/13, engere Ränder — und
das Datum kürzer formatiert: „Sa., 8. Aug. 2026" statt „Samstag, 8. August
2026".

Gekürzt wird die Schrift, nicht der Inhalt. Alle drei Zeilen bleiben, und das
Datum wird nie zu Ziffern: Wer nach Monaten wieder vorn ist, braucht Wochentag,
Monat und Jahr; wer an einem fremden Ort hochkommt, den Ort; und 6:00 gegen
18:00 ist die Frage, für die die Zeitzeile da ist.

### Nicht angefasst: Anlagen an zwei Orten

Kamera und Mikrofon liegen oben als Kacheln, Galerie und Video hinter dem „+"
der Textzeile. Das ist eine bewusste Trennung — die häufigen Wege bildhaft und
groß, die selteneren hinter einem Griff, damit nicht zu viele Möglichkeiten
gleichzeitig dastehen. Wer sie zusammenlegen will, entscheidet neu; in diesem
Durchlauf wurde sie nicht umgeworfen.

### Geprüft

`flutter analyze` ohne Fehler und Warnungen, `dart run custom_lint` sauber,
**431 Tests grün** (drei neue in `test/widgets/doodle_canvas_folded_test.dart`:
im Blättermodus bleibt nur der Pinsel, beim Malen stehen die Werkzeuge wieder
da, ohne Umschalter bleiben sie stehen).

Am S24 nachgesehen: Chat im Blättermodus zeigt einen Pinsel und einen
Sende-Pfeil, die Nachricht von Mina ist voll lesbar. Ein Griff auf den Pinsel
klappt Werkzeuge und Farben auf, die Handfläche steht auf demselben Punkt wie
vorher der Pinsel, die Textzeile ist weg. Ein Griff zurück stellt alles wieder
her. Die Profilauswahl trägt „Sa., 8. Aug. 2026 / 10:21 · morgens /
Kirchstraße 3" klein über der Karte, der Anker bei voller Höhe weiter
„Saturday, August 8, 2026".

Der Entwurfsschutz ist am Gerät geprüft, nicht im Test: „Entwurf test" getippt,
Pinsel, Handfläche — der Satz steht unverändert da und der Sende-Knopf ist
weiter hell. Ein Widget-Test dafür bräuchte den vollen DI- und Hive-Aufbau des
Chats; das Gerät ist hier der ehrlichere Prüfstand.

## Unverändert offen

Sostén benutzt weiter Material-Icons statt gezeichneter Bilder, und „Feel the
body" trägt weiter das Android-Symbol für Barrierefreiheit (B2). Ayuda (B6),
die Stimme der leeren Flächen (A8) und die Lokalisierung (C6/C7) sind nicht
angefasst.
