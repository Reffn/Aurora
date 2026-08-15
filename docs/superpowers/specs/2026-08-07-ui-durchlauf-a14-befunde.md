# UI-Durchlauf am Gerät: Samsung A14, 7. August 2026

**Gerät:** SM-A145F (`RF8W90CT0NN`), 1080×2408, Debug-Build.
**Installiert:** 3.0.14. Repo steht auf 3.0.15 — die Zeitkarten-Arbeit vom
6. August ist nur teilweise auf dem Gerät.
**Profil:** „Prueba", Sprache Spanisch. Das war kein geplanter Testfall, hat
aber die Lokalisierung mitgeprüft und dabei mehr gefunden als der deutsche
Durchlauf gefunden hätte.

Geprüft gegen `docs/oberflaechen-richtlinien.md`. Regelnummern beziehen sich
darauf. Nichts Auswärtsgerichtetes wurde ausgelöst: kein Anruf, kein
Absenden, keine Einwilligung umgeschaltet.

**Nachtrag, gleicher Tag:** Nach dem ersten Durchlauf wurde 3.0.15 auf das
A14 gebaut und installiert, alles gegengeprüft und die sicheren Punkte
behoben. Was sich dadurch geändert hat, steht unten unter „Stand nach dem
Nachbau". Befunde, die sich als Sache des alten Builds erwiesen haben, sind
dort ausdrücklich zurückgenommen.

---

## Was trägt

Damit die Liste darunter nicht wie ein Verriss liest — das hier hält:

- Der Anker als Wahlfläche: Zeilen, drei Gruppen nach Zustand sortiert, feste
  Reihenfolge, nichts versteckt. Regel 1, 2, 3 und 7 sind erfüllt.
- Der Rückweg trägt Symbol **und** Wort („⚓ Ancla"), an derselben Stelle auf
  jeder Arbeitsfläche. Regel 1 und 5.
- Volle Farbe tragen genau Sostén, Emergencia, Ayuda. Regel 4, richtig.
- Die Systemschrift auf 1,5 gesetzt: Anker und Sostén wachsen sauber mit,
  nichts bricht. Der offene Prüfpunkt „respektiert jeder Schirm `textScaler`"
  ist für diese Flächen beantwortet — ja. Eine Ausnahme steht unter C.
- Die Bauform der leeren Flächen (Symbol im Lichtkreis, Titel, Untertitel) ist
  überall dieselbe.

---

## A. Was mehrfach gebaut ist

Das war die Frage im Auftrag, und sie hat mehr Substanz als erwartet.

### A1. Sieben Bedienmuster für dieselbe Sache

| Muster | Wo |
|---|---|
| Zeilen (Wahlfläche) | Anker |
| Reiter oben | Buscador, Medicación |
| Schwebeknopf unten rechts | Buscador, Diario, Medicación |
| Kachelraster 2×2 | Sostén |
| Eingabeleiste unten | Chat |
| Bottom-Sheet | Profilmenü (Bearbeiten / Einstellungen / Abmelden) |
| Dialog über der Fläche | Profilauswahl |

Regel 7 verlangt Vorhersehbarkeit. Sieben Muster heißt: jede Fläche muss neu
gelernt werden. Der Anker führt das Zeilenmuster vor und keine einzige
Arbeitsfläche nimmt es auf.

### A2. Der aktive Anteil steht bis zu viermal gleichzeitig

Auf **jeder** Arbeitsfläche: Avatar mit Namen unter dem Titel **und** darunter
ein Chip „Prueba (Tú)". Zwei Antworten auf dieselbe Frage, direkt
untereinander, in derselben Kopfzeile.

Auf dem Anker zusätzlich die Profilkarte mit Namen und der Kartenmarker mit
Namen — vier Nennungen auf einem Schirm.

### A3. Der Chip sieht antippbar aus und ist es nicht

„Prueba (Tú)" trägt Umrandung, Pillenform und Profilfarbe — die Form eines
Knopfes. Antippen bewirkt nichts. Das ist kein Schönheitsfehler: Wer im
schlechten Zustand den Weg zum Profilwechsel sucht, greift genau dorthin.

### A4. Sostén hat zwei Kopfzeilen und zwei Rückwege

Erst die Kopfzeile mit „⚓ Ancla · Sostén · Prueba", darunter eine zweite
Leiste mit „← Sostén". Der Bereichsname steht zweimal, der Rückweg zweimal,
und der zweite ist ein Pfeil ohne Wort.

Prüffrage 5 lautet „Gibt es **genau einen** sichtbaren Rückweg?" Hier zwei.
Das sieht nach einem alten Scaffold aus, der unter dem `WorkSurfaceScaffold`
liegen geblieben ist.

### A5. Zwei Zeichenflächen, ein totes Modul, ein toter Zwilling

- `lib/modules/chat/widgets/doodle_canvas.dart` (928 Zeilen) und
  `lib/widgets/doodle_avatar_screen.dart` (64 Zeilen) — zwei Zeichenwege.
- `lib/modules/more/more_screen.dart` wird nirgends aufgerufen. Das Modul
  enthält einen eigenen Weg zu den Einstellungen, den niemand erreicht.
- **Die Profilkarte war wörtlich zweimal gebaut.** `Icons.swap_horiz` mit
  Profilfarbe stand in `main.dart:1783` *und* in `anchor_menu_screen.dart:216`.
  `AnchorMenu.build` baute `_ProfileCard` nie — die sichtbare Karte kommt aus
  `main.dart`, die Fassung im Anker-Modul war ein toter Zwilling mit eigener
  Symbolgröße (28 statt 24). *Behoben, siehe unten.*

  Eine eigene Korrektur dazu: Ich hatte geschrieben, der Kommentar („Er steht
  jetzt in der Titelzeile") beschreibe einen Zustand ohne Entsprechung. Das
  galt für 3.0.14. In 3.0.15 stimmt er — die Profilzeile ist tatsächlich in
  die Kopfzeile gewandert.

### A6. Sprache an zwei Orten

Der Profildialog auf der Startfläche trägt einen eigenen Sprachumschalter
(„🌐 Español") neben „Profil wechseln". Sprache ist eine Einstellung und
gehört nicht in die Profilwahl.

### A7. Derselbe Knopf, drei Benennungslogiken

- Buscador: Knopf heißt „+ Entrada", der leere Schirm darüber sagt
  „Toca + para añadir un **lugar**". Der Text nennt die Handlung anders als
  der Knopf, der sie ausführt.
- Diario: „+ Entrada" — dasselbe Wort für etwas ganz anderes.
- Medicación: „+ Medicamento" — richtig benannt.

Eine Handlung behält ihren Namen durch den ganzen Weg. Hier tut sie es nicht.

### A8. Vier Tonlagen auf leeren Flächen

- Chat: „Todavía no hay mensajes" — Systemton
- Buscador: „Todavía no hay lugares" — Systemton
- Diario: „¡Tu diario te espera! ✨" — jubelnd
- Medicación: „Sin medicación 💊" — knapp mit Emoji

**Die Richtung ist entschieden:** Die App soll ein Freund sein, warm und
zugewandt. Das ist bei diesem Krankheitsbild richtig — Depression gehört
oft dazu, und ein Formularton hilft dort niemandem. Der Befund ist deshalb
nicht „zu freundlich", sondern **vier Stimmen statt einer**. Chat und
Buscador klingen heute wie eine Fehlermeldung und müssen nach oben, nicht das
Tagebuch nach unten.

Eine Grenze bleibt, und sie kommt aus der Forschung, nicht aus Geschmack:
Im Halt- und Notfallbereich bleibt dieselbe warme Stimme, aber **ruhig**.
„Users in distress show a strong preference for subtlety … cheerful, bright
colours can create a jarring conflict with their current mood" (Health
Informatics Journal 2024). Ein Freund wird nicht laut, wenn es einem schlecht
geht — er bleibt da. Regel 11 sagt dasselbe für Bewegung.

### A9. Einstellungen sind nur hinter einem Symbol erreichbar, das etwas anderes verspricht

Es gibt keinen Zahnrad-Knopf, keinen Anker-Eintrag, keinen Weg von einer
Arbeitsfläche aus. Der einzige Weg: Anker → Profilzeile antippen → das
⇄-Symbol führt zu einem Bottom-Sheet mit „Profil bearbeiten / Einstellungen /
Abmelden".

⇄ heißt „wechseln". Dahinter liegen drei Dinge, von denen zwei nicht
wechseln. Damit ist auch **„Was Aurora sendet" praktisch unauffindbar** —
die Transparenz-Zusage der App hängt an einem Symbol, das sie nicht ankündigt.

---

## B. Brüche gegen die eigenen Richtlinien

### B1. Zwei Chamäleon-Stile in einer Liste (Regel 5, Regel 7)

Der schwerste optische Befund — aber die Richtung ist geklärt, und sie war
andersherum als beim ersten Hinsehen.

- **die gemalten Fünf** (`assets/images/`, 6. August, Commit `406a460`):
  Medicación, Buscador, Juegos, Cronología, Comentarios. Jedes einzeln
  gezeichnet, eigene Pose, eigene Haltung. **Das ist das Ziel.**
- **Die Schablonen-Sieben** (5. August, noch auf dem Ur-Commit `3b82fd5`):
  Sostén, Emergencia, Ayuda, Chat, Calendario, Diario, Contactos. Dasselbe
  Bild mit getauschtem Requisit.

Wer sich Orte statt Namen merkt, verliert den Ort, solange beide Welten
nebeneinander stehen. Die Auflösung ist nicht, die gemalten Fünf anzugleichen,
sondern die restlichen sieben nachzuziehen — Handarbeit, kein Aufräumfix.

### B2. Das Bild trägt nicht, wo es tragen müsste (Regel 5)

- Die drei Notfallzeilen zeigen **dasselbe Chamäleon**. Unterschieden werden
  sie durch ein Requisit von etwa 15 % der Bildhöhe (Anker, Warndreieck,
  Kreuz). Das ist genau die Fläche, die im schlechtesten Zustand ohne Lesen
  funktionieren muss.
- Calendario, Diario und Contactos tragen alle ein **kleines weißes Rechteck**
  — auf Armlänge nicht zu unterscheiden.
- Sostén benutzt statt gezeichneter Bilder **Material-Icons**. Regel 5 sagt:
  gezeichnet schlägt Strichsymbol. Der Anker macht es richtig, die Fläche
  dahinter fällt zurück.
- Das Piktogramm für „Sentir el cuerpo" ist das **Android-Symbol für
  Barrierefreiheit**. Vertraute Symbole werden nicht umgewidmet (W3C COGA).

### B3. Sättigung ohne Aufgabe (Regel 4)

- **Die Karte auf der Profilauswahl** läuft in voller OSM-Standardsättigung
  (Grün, Rosa, Gelb) und nimmt ein Drittel der Höhe. Das lauteste Element der
  Fläche ist nicht die Wahl, sondern der Hintergrund. Auf dem Anker
  dasselbe.
- **Die Kopfzeile trägt auf jeder Fläche die volle Profilfarbe.** Ein
  Farbband über dem ganzen Schirm, dauerhaft.
- Sostén bringt vier weitere Farben mit (Blau, Grün, Magenta, Grau) zusätzlich
  zu den zwölf Bereichsfarben.
- Grün ist doppelt belegt: Bereichsfarbe von Contactos **und** Farbe der
  Anrufknöpfe in Ayuda.
- Chat und Calendario tragen im Anker fast dasselbe Blau.
- **Der Regenbogen signalisiert.** Der Primärknopf „Profil wechseln" im
  Startdialog trägt einen Regenbogenverlauf als Fläche. Festgehalten war: der
  Regenbogen ist konstant und signalisiert nie. Hier ist er die lauteste
  Fläche des Dialogs.
- „Respiración" ist die einzige Kachel in Sostén ohne Farbe — ausgerechnet
  die, für die die PTSD-Coach-Evidenz am deutlichsten ist.

### B3a. Dasselbe Symbol für Verschiedenes

- **Das Kreuz ist dreifach belegt**: Requisit des Ayuda-Chamäleons,
  Medikamentendose in Medicación, und noch einmal als Bereichssymbol.
- **Das Kalenderblatt ist doppelt belegt**: Es ist das Symbol des leeren
  Tagebuchs *und* das Requisit des Calendario-Chamäleons. Zwei Bereiche, ein
  Bild.
- **Der GPS-Satellit** steht rechts oben auf jeder Fläche — Symbol ohne Wort
  (Regel 5). In einer App, deren Versprechen die Datensparsamkeit ist, ist
  ausgerechnet der Standort-Anzeiger der unbeschriftete Knopf.

### B4. Die Karte vor der Anmeldung — entschieden, sie bleibt

Die Profilauswahl zeigt die Karte mit dem Ort. Das Richtlinien-Dokument
schrieb dagegen: *„Ein Ort auf der Profilauswahl bleibt draußen."*

**Entschieden am 7. August: die Karte bleibt.** Wer gerade frisch hochkommt,
muss sich zuerst orientieren, und das geht nicht erst nach der Anmeldung —
Reorientierung arbeitet mit Zeit, Ort und Person, und zwei davon lägen sonst
hinter einer Hürde. Die Regel im Richtlinien-Dokument ist entsprechend
nachgezogen (Abgleich-Punkt 6); das Dokument verlangt selbst, dass ein
Regelbruch begründet dasteht.

Nicht mitentschieden und weiter offen: das Alter („25 Jahre" im
Profildialog) und die automatische Standortabfrage beim Betreten des Ankers
(„Cargando la posición…") ohne vorherigen Griff.

### B5. Die Tagesphase ist verlorengegangen — und zwar in HEAD, nicht nur im alten Build

Das ist keine fehlende Umsetzung. Es ist eine Regression, und sie ist im Code
nachweisbar:

- `lib/widgets/time_orientation_line.dart` existiert, mit dem Kommentar
  *„die Tagesphase steht als Wort, weil 6:00 und 18:00 auf einer Uhr
  verwechselbar sind"*, und `app_de.arb` trägt `timePhaseMorning: "morgens"`.
- **`TimeOrientationLine` wird nirgends in `lib/` gebaut.** Das Widget ist
  verwaist.
- Die Zeitkarte baut stattdessen ihren eigenen Kopf:
  `time_map.dart:507` setzt `DateFormat.yMMMMEEEEd` + `DateFormat.Hm` — also
  Datum plus **Uhrzeit**. Genau die Angabe, die das Dokument als
  verwechselbar verworfen hatte.

Die Zeitkarte hat die Zeitzeile ersetzt und dabei ihren Zweck weggeworfen.
Der Eintrag „Behoben am 06.08." im Richtlinien-Dokument beschreibt einen
Zustand, den der Code nicht mehr hat.

„Zuletzt vorn vor X" liegt dagegen in `profile_selection_screen.dart` und ist
vermutlich nur im alten Build nicht sichtbar. „Was dieser Tag trägt"
(Termine, Medikamente als Zahlen) habe ich auf der Profilauswahl nicht
gefunden.

Dazu: Die Frage „Wer war da?" wird mit einem Marker „Unbekannt" beantwortet.

### B6. Ayuda: die Fläche, die im Notfall funktionieren muss

- **Die Telefonnummern haben den schwächsten Kontrast des Schirms** (grau auf
  dunkel), obwohl sie die Information sind, die man abliest, wenn man von
  einem anderen Gerät wählt. Regel 6.
- **Kein Hinweis, ob gerade jemand rangeht.** „Info-Telefon Depression,
  Mo-Do 13-17 Uhr" um drei Uhr nachts führt ins Leere. Regel 10 verlangt zu
  sagen, was passiert.
- Der Anrufknopf warnt nicht vor. Gewählt wird dabei **nicht**: die App
  benutzt `Uri(scheme: 'tel')` (`emergency_message_service.dart:177`), das
  öffnet nur die Telefon-App mit vorgetragener Nummer. Der Befund schrumpft
  damit auf einen Sprung in eine fremde App ohne Ankündigung — Regel 10 sagt,
  was passiert, soll vorher dastehen.
- Die Einträge sind **Karten mit einem Knopf darin**, nicht Zeilen. Ob die
  Karte selbst reagiert, habe ich nicht ausgelöst (der Griff hätte gewählt);
  im Aufbau spricht nichts dafür. Falls nicht, ist es ein Fehlerpfad, den es
  nicht geben müsste (Errorless Learning).
- Drei Einträge tragen **dasselbe Telefonsymbol**.

### B7. Die Zeichenwerkzeuge liegen dauerhaft über dem leeren Chat

Sechs Werkzeugknöpfe (Senden, Pinsel, Emoji, Zauberstab, Rückgängig, Löschen)
stehen rechts über der leeren Chatfläche, **alle nur Symbol, kein Wort**
(Regel 5), und sie sind sechs gleichzeitige Wahlmöglichkeiten (Hick, im
Abgleich vom 6. August schon vermerkt). Der Zeichenmodus wirkt aktiv, ohne
gewählt worden zu sein.

Dazu stehen **zwei identische Sende-Pfeile** gleichzeitig auf dem Schirm — der
eine schickt eine Zeichnung, der andere eine Nachricht.

Und die Anlagen gibt es an zwei Orten: oben zwei große Knöpfe „Foto" und
„Hablar", unten im Eingabefeld ein „+", das dasselbe anbietet. Zwei Wege zur
selben Sache auf einem Schirm.

### B8. Gruppenüberschriften in Versalien

`anchor_menu_screen.dart:148` setzt `label.toUpperCase()` mit
`letterSpacing: 1.4`. Durchgehende Großbuchstaben sind schlechter lesbar; die
COGA-Empfehlung ist Normalschreibung. Der Abstand allein trägt die Gruppe
bereits.

---

## C. Fehler, die am Gerät sichtbar sind

### C1. Layout-Überlauf im Chat: „RIGHT OVERFLOWED BY 53 PIXELS"

Gelb-schwarzer Warnstreifen an der Farbreihe der Zeichenfläche.

**Erledigt — und zwar nicht von mir.** Der `SingleChildScrollView` um die
Farbreihe kam in Commit `7102fbf`, also in 3.0.15. Das Gerät zeigte den
Zustand davor. Nach dem Nachbau ist der Warnstreifen weg und die Farbreihe
rollt sauber (letzter Kreis angeschnitten als Rollhinweis). Am Gerät
bestätigt.

Damit ist auch die Frage nach dem S24 beantwortet: Dort lief schlicht ein
neuerer Build. Kein Geräteunterschied.

### C2. Bei 1,5-facher Schrift fällt die Uhrzeit weg

„viernes, 7 de agosto de 2026 · …" — abgeschnitten. Ausgerechnet die
Zeitangabe, für die die Zeile existiert, ist das Erste, was verschwindet.
Wer große Schrift braucht, verliert die Reorientierung.

### C3. Reitertitel abgeschnitten

Medicación: „Medicación según necesi…" läuft aus dem Bild.

### C4. Der Aurora-Schriftzug ragt aus der Kopfzeile

Links oben wird „Aurora" an der Unterkante der Leiste beschnitten. Bei 1,5
deutlicher.

### C5. Gruppenüberschrift schiebt sich unter die Kopfzeile

Beim Scrollen verschwindet „DÍA A DÍA" halb hinter der Leiste, statt daran
anzustoßen.

### C6. Die Hilfe-Seite ist halb übersetzt

Überschriften und Knöpfe spanisch, Inhalte deutsch: „24/7 kostenlos &
anonym", „Mo-Do 13-17 Uhr, Di+Do 19-21 Uhr". Bei „Nummer gegen Kummer" ist die
Beschreibung spanisch, bei den anderen deutsch — inkonsistent innerhalb einer
Liste. Inhaltlich schwerer: Es sind **deutsche Hotlines für eine spanische
Oberfläche**, ohne Hinweis darauf.

### C7. Die Startfläche bleibt deutsch

„Wer bist du?", „Neues Profil", „Impressum" — obwohl das einzige Profil
Spanisch spricht. Erst nach der Wahl wechselt die Sprache. Wer nur Spanisch
liest, kommt an der Anmeldung nicht vorbei.

### C8. Der Splash ist weiß

Die App ist dunkel. Der Start blendet, jedes Mal.

---

---

## Play-Ablehnung von 3.0.15 — Ursache und Fix

Am selben Abend kam heraus, warum Google das Update abgelehnt hat. Es ist
kein UI-Befund, gehört aber hierher, weil es dieselbe Version betrifft.

**Der Vorwurf:** „Richtlinie für Berechtigungen für Fotos und Videos".
Aurora forderte `READ_MEDIA_IMAGES` und `READ_MEDIA_VIDEO` an. Ab Android 13
sind diese Berechtigungen nur erlaubt, wenn der System-Photo-Picker die
Hauptfunktion nicht abdeckt. Durchgesetzt am 7. August; die Vorversion bleibt
im Store.

**Warum es zu Recht abgelehnt wurde:** Aurora liest die Galerie nirgends aus.
Keine Spur von `photo_manager`, MediaStore oder einem Zugriff auf
`/storage`. Alle fünf Stellen, die Bilder holen — Chat, Puzzle,
**Tablettenfoto**, Profilbild, Doodle-Avatar — gehen über
`image_picker.pickImage()` und legen das Ergebnis über `AttachmentHelper` im
app-eigenen Ordner ab. Die App fragte also nach Zugriff auf *alle* Bilder des
Geräts und benutzte ihn nie.

**Was geändert wurde:**

| Datei | Änderung |
|---|---|
| `AndroidManifest.xml` | Beide Berechtigungen mit `tools:node="remove"`. Bloßes Weglassen genügt nicht — `permission_handler` bringt sie über sein eigenes Manifest mit, und geprüft wird das zusammengeführte. |
| `AndroidManifest.xml` | `READ_EXTERNAL_STORAGE` bekam `maxSdkVersion="32"`. Ein Plugin zog sie ohne Obergrenze ein; ab Android 13 ist sie wirkungslos, las sich in einer Prüfung aber wie ein zweiter Anlauf auf denselben Zugriff. |
| `image_picker_handler.dart` | `pickFromGallery` fragt auf Android nichts mehr ab. `_checkPhotosPermission` bleibt für iOS. |
| `puzzle_image_service.dart` | Dieselbe Trennung in `pickImageFromGallery`; dazu vier nie aufgerufene Permission-Hilfsmethoden entfernt, von denen zwei genau die strittige Berechtigung anforderten. |

**Am Gerät nachgemessen (A14, Android 14):**

- Im installierten Paket sind **keine Medien-Berechtigungen mehr** —
  `dumpsys package` liefert dazu nichts.
- Im zusammengeführten Manifest: `READ_MEDIA_IMAGES` weg,
  `READ_MEDIA_VIDEO` weg, `READ_EXTERNAL_STORAGE` mit Deckel.
- **Tablettenfoto:** „Galerie" öffnet
  `com.google.android.photopicker/PhotopickerGetContentActivity` — **ohne
  Berechtigungsdialog**. Bild ausgewählt, es steht vollständig im Formular.
  Danach über „Verwerfen" verlassen, nichts gespeichert.
- **Puzzle** (anderer Code-Pfad): derselbe Picker, kein Fehler im Log.
- `flutter analyze` ohne Fehler und Warnungen, `dart run custom_lint`
  „No issues found", **389 Tests grün**.

Für die Nutzerin ändert sich ein Dialog weniger: Statt „Aurora möchte auf
deine Fotos zugreifen" öffnet sich direkt die Systemauswahl. Aurora bekommt
das eine gewählte Bild statt Zugriff auf alles — für eine App mit diesem
Datenschutzversprechen die richtigere Antwort.

**Vor der nächsten Einreichung noch offen** (Hinweis aus der parallelen
Sitzung): `USE_EXACT_ALARM` gegenprüfen. Play beschränkt sie auf Apps, deren
Kernfunktion Wecker oder Kalender ist; ob eine Medikamenten-App darunter
fällt, ist Auslegungssache. Das gehört zum Erinnerungs-Umbau, nicht hierher.

---

## Stand nach dem Nachbau

3.0.15 gebaut, auf dem A14 installiert, Durchlauf wiederholt. Branch
`ui/aufraeumen-a14`, nicht committet.

### Behoben und am Gerät nachgeprüft

| Befund | Was geändert wurde |
|---|---|
| **B5** Tagesphase fehlt | `timePhaseOf` nach `lib/utils/time_phase.dart` gezogen (eine Quelle für die Grenzen, statt zwei); die Zeitkarte setzt jetzt Datum in Zeile eins, „13:34 · mittags" in Zeile zwei. Spanisch trägt mit: „13:35 · al mediodía". |
| **C2** Uhrzeit fällt bei 1,5 weg | Ursache war `maxLines: 1` auf einer Zeile, die Datum **und** Uhrzeit trug — die Ellipse fraß das Hintere. Zwei kurze Zeilen halten, wo eine lange bricht. Bei 1,5 steht jetzt beides vollständig. |
| **B8** Versalien | `toUpperCase()` raus, Sperrung von 1,4 auf 0,2, Schriftgrad 13 → 14. Am Gerät: „Cuando cuesta", „Día a día". Der zugehörige Test prüfte die Versalien und wurde mitgezogen. |
| **A5** toter Zwilling | `_ProfileCard` aus `anchor_menu_screen.dart` entfernt, dazu die beiden Importe, die nur sie brauchte. |
| **A5** totes Modul | `lib/modules/more/` gelöscht — `MoreScreen` hatte weder Aufruf noch Route und enthielt einen zweiten, unerreichbaren Weg zu den Einstellungen. |
| **C4** Aurora-Schriftzug | `MainAxisSize.min`, Zeilenhöhe 1,1, Bildmarke 28 → 26, und die Wortmarke skaliert nicht mehr mit der Systemschrift. Sie liegt weiterhin dicht an der Kante — besser, nicht schön. |

Geprüft: `flutter analyze` wirft für die berührten Dateien keine Fehler,
`dart run custom_lint` meldet „No issues found", `flutter test` läuft mit 341
Tests grün, dazu drei neue in `test/utils/time_phase_test.dart`
(Phasengrenzen, besonders 6:00 gegen 18:00).

Nicht behoben, nur gemildert: **C4**. Der Aurora-Schriftzug wird nicht mehr
angeschnitten und sprengt bei 1,5 die Leiste nicht mehr, klebt aber weiter
dicht an der Unterkante.

### Zurückgenommen

- **C1** (Chat-Overflow) war in 3.0.15 bereits behoben. Siehe oben.
- **C8** (weißer Splash) war der alte native Ladeschirm. 3.0.15 zeigt einen
  dunklen Flutter-Ladeschirm.
- **A5**, Teilkorrektur: Der Kommentar zur Profilkarte stimmt in 3.0.15.

### Nicht angefasst, mit Absicht

- **A7** (FAB-Benennung) hat eine Designgabel: Der Finder-Knopf borgt sich
  `fabDiaryEntry` vom Tagebuch, und `_openFinderForm` weiß bereits, ob gerade
  Orte oder Dinge dran sind. Ein reiterabhängiges Wort wäre richtig, kann aber
  veralten, wenn der Knopf beim Reiterwechsel nicht neu baut. Das ist kein
  sicherer Fix, sondern eine Entscheidung.
- Alles unter A1, A8, B1, B6 — Muster, Stimme, Chamäleons, Ayuda.

### Der eigentliche Fund des Nachbaus: verwaiste Orientierung — aufgelöst

Der Analyzer zeigte gleich mehrere Bausteine als importiert, aber nirgends
gebaut. Nach Durchsicht wurde entschieden: **das Gute bleibt und wird sauber
wieder eingebaut, das Verwaiste geht.**

**Wieder angeschlossen — `TodayOverviewLine`.** Sie trägt etwas, das sonst
nirgends steht: **Medikamente kommen auf der Zeitkarte überhaupt nicht vor.**
Dazu prüft sie Inhalts-Rechte (`viewCalendar`, `viewMedication`) getrennt von
Tab-Rechten — diese Unterscheidung gibt es an keiner anderen Stelle. Sie
steht jetzt an beiden Orten, wie im Abgleich vom 6. August vorgesehen:

- **Anker**, unter der Zeitkarte, mit Rechteprüfung und Inhalten.
- **Profilauswahl**, mittig unter dem Kopf, `gateByPermissions: false` — als
  bloße Zahlen. Termine und Medikamente gelten dem Körper, nicht dem Anteil,
  also stehen sie vor der Wahl für alle da; Titel, Uhrzeiten und Präparate
  erst danach.

Sie hatte längst fünf Tests, die genau dieses Verhalten abdecken — sie war
geprüft, nur nicht angeschlossen.

Gezählt wird über `DataEntry` (`getCalendarEventsForDay`,
`getTodaysMedications`), nicht über die Dienste. Der erste Anlauf griff
direkt auf `CalendarService` und `MedicationService` zu; `dart run
custom_lint` hat das mit der projekteigenen Regel `no_direct_service_access`
abgefangen. Der Weg aus der Oberfläche geht durch die eine Tür.

**Gelöscht — die Anwesenheits-Kette.** `RecentPresenceBand`,
`presenceEntriesFrom`, dazu `_recentPresence`, `_recentSwitches`,
`_isPrivate` und `_placeNear` aus `profile_selection_screen.dart`, plus der
zugehörige Test. Die Zeitkarte gibt dieselbe Auskunft besser — der Kommentar
im gelöschten Code sagt es selbst: „Die Linie zeigt den Weg, der Name nur den
Endpunkt." **Die Datenschutzregel ist dabei nicht verlorengegangen:** Anteile
mit Passwort bleiben draußen, das erledigt
`TimeMap.fromServices(hidePasswordProtected: true)` — `_isPrivate` war eine
zweite Kopie derselben Regel.

**Gelöscht — `TimeOrientationLine`** samt Test. Ihr Inhalt liegt seit heute
in der Zeitkarte, ihre Phasengrenzen in `lib/utils/time_phase.dart`.

**Gerettet, bevor die Kette fiel: `shortPlace`.** Die Funktion wohnte in
`recent_presence_band.dart`, hat mit dem Band aber nichts zu tun — vier
lebende Flächen kürzen mit ihr Adressen (Kontaktkarte, Finder-Karte,
Ortsauswahl im Kalender, Zeitachse) und die Zeitkarte selbst. Sie steht jetzt
in `lib/utils/short_place.dart`, ihre fünf Tests in
`test/utils/short_place_test.dart`. Ohne diesen Zwischenschritt hätte das
Aufräumen vier Schirme zerlegt.

**Korrektur an einem früheren Satz dieses Berichts:** Ich hatte
`_recentPresence` als „zuletzt vorn vor drei Tagen unter jedem Namen"
beschrieben und später behauptet, diese Zeile gebe es im Code gar nicht.
Beides falsch. `_recentPresence` speiste das Anwesenheitsband **über** der
Wahl. Die Zeile unter jedem Namen ist `_lastFront()` in
`profile_selection_screen.dart` — sie lebt, ist angeschlossen und schweigt
nur deshalb am Testgerät, weil „Prueba" keine Wechsel-Historie hat und weil
sie für Anteile mit Passwort absichtlich nichts sagt.

### Neue Befunde aus den Flächen, die ich zuerst ausgelassen hatte

- **Emergencia:** Die Karte steht in voller OSM-Sättigung ganz oben auf dem
  Schirm, den man im schlechtesten Zustand öffnet. Die weißen Zoom- und
  Standortknöpfe sind die hellsten Flächen darauf und bedienen die Karte,
  nicht den Notfall. Der Hinweistext läuft unten unter die Systemleiste.
- **Contactos:** dieselbe doppelte Kopfzeile wie Sostén — der Bereichsname
  steht zweimal. A4 ist damit systemisch, nicht der Einzelfall eines Schirms.
- **Contactos:** Die Filterreihe („Todos / Familia / Amigos / Terapeutas …")
  läuft rechts aus dem Bild, ohne dass etwas darauf hinweist. Fünftes
  Bedienmuster.
- **Ladeschirm:** trägt einen „Wusstest du?"-Tipp und eine Liste von sieben
  Übersetzungen von „Aurora lädt". Hübsch, aber es ist Lesestoff genau in dem
  Moment, in dem jemand in die App will.

## Was ich als Nächstes vorschlagen würde

Stand nach dem Nachbau, in dieser Reihenfolge:

1. ~~**A2 + A3 + A4**~~ — *erledigt am 7. August am S24, samt A9. Was genau
   geändert wurde und was dabei neu auffiel, steht in
   `2026-08-07-menues-entschlacken-s24.md`.* Ursprünglicher Wortlaut:
   doppelter Anteil (Titel-Avatar *und* Chip „(Tú)"),
   doppelte Kopfzeile in Sostén und Contactos. Eine Arbeit im
   `WorkSurfaceScaffold`, räumt drei Befunde ab. Wenn der Chip dabei ans
   Profil-Bottom-Sheet gehängt wird, fällt **A9** mit: Einstellungen wären
   von jeder Fläche erreichbar statt nur vom Anker.
3. **A9** — falls nicht über Punkt 2 miterledigt: ein sichtbarer Weg zu den
   Einstellungen. Solange er fehlt, ist „Was Aurora sendet" unauffindbar und
   die Transparenz-Zusage nicht einlösbar.
4. **B1** — die sieben Schablonen-Chamäleons in dem gemalten Stil nachziehen.
   Handarbeit, größter sichtbarer Ertrag. **Nicht** andersherum: die gemalten Fünf
   sind das Ziel.
5. **B6** — Ayuda: Nummern-Kontrast, „ist gerade jemand da?", Karte statt
   Zeile, dreimal dasselbe Telefonsymbol.
6. **A8** — eine Stimme festlegen und die vier leeren Flächen angleichen; die
   warme Richtung ist entschieden, ruhig bleibt sie nur im Halt-Bereich.
7. **Kleinkram, jederzeit machbar:** C3 (Reitertitel „Medicación según
   necesi…", in 3.0.15 bestätigt), C5 (Gruppenüberschrift schiebt sich unter
   die Kopfzeile), Emergencia-Hinweistext unter der Systemleiste,
   Filterreihe in Contactos läuft aus dem Bild, A7 (FAB-Benennung, nach der
   Reiter-Entscheidung).
8. **C6 / C7** — Lokalisierung: deutsche Hotline-Inhalte in spanischer
   Oberfläche, deutsche Startfläche vor der Profilwahl. Beides hat einen
   Produktanteil (welche Nummern für welche Sprache? welche Sprache, bevor
   ein Anteil gewählt ist?) und ist deshalb kein reiner Textfix.

## Offene Fragen

- **Sprache je Anteil wirkt wackelig.** Vor dem letzten Neubau war „Prueba"
  durchgehend spanisch, danach steht der Anker deutsch da. Kann an der
  Neuinstallation liegen, kann aber auch heißen, dass die Profilsprache nicht
  überall greift. Gezielt nachstellen?
- **A7:** Soll der Finder-Knopf reiterabhängig „Ort" bzw. „Ding" heißen, oder
  bleibt ein gemeinsames Wort? Ersteres ist richtiger, kann aber veralten,
  wenn der Knopf beim Reiterwechsel nicht neu baut.
- Der Durchlauf hat Calendario, Juegos, Cronología und Comentarios **nicht**
  geöffnet, und Einstellungen samt „Was Aurora sendet" nur bis zur Tür.
  Nachholen?
- Der Branch `ui/aufraeumen-a14` ist **nicht committet**. Die andere Sitzung
  arbeitet im selben Arbeitsverzeichnis und sieht diese Änderungen — ein
  Wechsel zurück auf `main` oder ein Merge sollte abgesprochen sein.
