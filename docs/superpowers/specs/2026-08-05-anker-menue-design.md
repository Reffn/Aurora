# Anker-Menü — Design

**Stand:** 5. August 2026
**Ersetzt:** `CarouselTabNavigator` und die PageView-Navigation in `main.dart`

## Ausgangslage

Aurora navigiert heute in vier Schichten: AppBar, Zeitstrahl, Karussell, PageView.
Das Karussell zeigt bei `viewportFraction: 0.20` etwa fünf von zwölf Bereichen
gleichzeitig, die übrigen liegen außerhalb des Schirms und werden durch Wischen
erreicht.

Für Menschen mit DIS ist das zu viel. Wischen setzt voraus, dass man weiß, dass
außerhalb des Sichtbaren noch etwas liegt, und dass man sich merkt, wo. Im
dissoziativen Zustand trifft beides nicht zu. Der Grounding-Spec hält denselben
Befund für die Erdungsübungen fest: *Auswählen ist selbst schon Überforderung.*
Was dort für fünf Übungen gilt, gilt für zwölf Bereiche erst recht.

Dazu zwei Funde aus dem Testdurchlauf vom 4. August
(`docs/2026-08-04-ui-testdurchlauf-funde.md`):

- **Befund K:** Der Bereichsname steht im Karussell und direkt darunter noch
  einmal als Titel.
- **Befund L:** Der Zeitstrahl über dem Inhalt („20 05 14 23 08 17 02" mit
  „Di./Mi./Do." darunter) ist ohne Erklärung nicht lesbar und für junge Anteile
  unbrauchbar.

Beide verschwinden mit dieser Änderung, ohne dass sie einzeln behandelt werden
müssten.

## Grundgedanke

**Zwei Orte, nie beide gleichzeitig.** Es gibt den *Anker* und es gibt eine
*Arbeitsfläche*. Man ist entweder hier oder dort, und der Weg dazwischen ist in
beide Richtungen derselbe Handgriff.

Damit sinkt die Zahl der Navigationsschichten von vier auf zwei: Kopfzeile und
Inhalt.

## Entscheidungen

| # | Frage | Entscheidung | Warum |
|---|---|---|---|
| 1 | Wie verhalten sich Anker und Arbeitsfläche zueinander? | Zwei Vollbilder, immer genau eines sichtbar | Klarste Trennung. Kein Zustand, in dem beides halb da ist |
| 2 | Raster oder Liste? | Senkrechte Liste, ein Element unter dem nächsten | Groß, ohne Zielgenauigkeit bedienbar, lässt Raum für Bild und Farbe |
| 3 | Was trägt eine Zeile? | Farbfläche über die volle Breite, großes Symbol, Wort daneben | Das Symbol trägt, das Wort bestätigt nur. Wer nicht liest, kommt trotzdem an |
| 4 | Wie kommt man zurück? | Ankersymbol links in der Kopfzeile, dazu die Android-Zurück-Taste | Kein Platzverlust im Inhalt, keine Kollision mit dem Plus-Knopf unten rechts |
| 5 | Wohin gehört der Profilwechsel? | Profilkarte oben auf dem Anker | Ein Ort für jedes Wechseln. Die Arbeitsflächen werden frei |
| 6 | Wo landet man nach der Profilauswahl? | Immer auf dem Anker | Jeder Start beginnt gleich. Nie ein Inhalt, der Fragen aufwirft |
| 7 | Was tut die Zurück-Taste auf dem Anker? | Sie verlässt Aurora (Android-Standard) | Nicht zur Profilauswahl: Sonst wirft ein zu häufiges Tippen jemanden aus seinem Profil |
| 8 | Reihenfolge der Zeilen? | Fest, nie nach Nutzung sortiert. Halt und Notfall oben | Was gestern an dritter Stelle stand, steht morgen an dritter Stelle. Im schlechtesten Zustand scrollt niemand |
| 10 | Alle zwölf Zeilen hintereinander? | Nein — drei Gruppen mit Überschrift: „Wenn es schwer ist", „Alltag", „Wenn Ruhe ist" | W3C COGA nennt eine Fläche ohne Trennung ausdrücklich schwer benutzbar. Versteckt wird trotzdem nichts |
| 11 | Alle Zeilen farbig? | Nein — volle Farbe nur für „Wenn es schwer ist". Der Rest: dunkle Fläche, Farbe als Streifen | Belastete Menschen bevorzugen Zurückhaltung; kräftige Farben stehen im Widerspruch zur eigenen Stimmung (Health Informatics Journal 2024). Sättigung bekommt eine Aufgabe statt eines Dekors |
| 9 | Zustand einer Arbeitsfläche beim Verlassen? | Wird verworfen; die Fläche entsteht beim Betreten neu | Bewusste Vereinfachung. Nachrüstbar, aber nur dort, wo es am Gerät weh tut |

## Aufbau

```
ANKER                          ARBEITSFLÄCHE
┌───────────────────────┐      ┌───────────────────────┐
│  ⚓ Aurora         ⚙  │      │  ⚓   Kalender     ⚙  │
│  ┌─────────────────┐  │      │───────────────────────│
│  │   (🐱)   Mia    │  │      │  ┌─────────────────┐  │
│  └─────────────────┘  │      │  │  Termin 14:00   │  │
│ █████████████████████ │ tap  │  └─────────────────┘  │
│ █  💬     Chat     █ │ ───► │  ┌─────────────────┐  │
│ █████████████████████ │      │  │  Termin 16:30   │  │
│ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ │ ◄─── │  └─────────────────┘  │
│ ▒  📅   Kalender   ▒ │  ⚓  │                       │
│ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ │      │                 ╭───╮ │
│ ░░░░░░░░░░░░░░░░░░░░░ │      │                 │ + │ │
│ ░  💊 Medikamente  ░ │      │                 ╰───╯ │
│ ░░░░░░░░░░░░░░░░░░░░░ │      └───────────────────────┘
└───────────────────────┘
  ~5 Zeilen sichtbar,           Voller Platz für Inhalt
  Rest beim Scrollen
```

### Die Profilkarte

Bild, Name, Profilfarbe, volle Breite, oben. Antippen führt zur Profilauswahl.

Sie ist bewusst anders geformt als die Zeilen darunter: Sie ist kein Bereich,
sondern die Antwort auf „wer bin ich gerade". Gleiche Form würde sie
gleichrangig neben Chat und Kalender stellen, und das ist sie nicht.

### Die Zeilen

- Volle Breite abzüglich Seitenrand, rund 110 dp hoch, abgerundete Ecken
- Eine feste Farbe je Bereich, unabhängig vom Profil
- Symbol links, groß; Wort daneben, groß
- Etwa fünf gleichzeitig sichtbar, senkrechtes Scrollen für den Rest

Zwei Betonungsstufen:

| Stufe | Aussehen | Für |
|---|---|---|
| `solid` | Volle Farbfläche, weiße Schrift, farbiger Schatten | Nur „Wenn es schwer ist" |
| `quiet` | Dunkle Fläche, 8 dp Farbstreifen links, Symbol in aufgehellter Bereichsfarbe | Alles andere |

Auf dunklem Grund wird die Bereichsfarbe auf mindestens 0,62 Helligkeit
angehoben (`AnchorRow.onDark`); Braun oder Dunkelblau verschwänden sonst.

**Reihenfolge — drei Gruppen, jede mit Überschrift:**

| Gruppe | Bereiche |
|---|---|
| Wenn es schwer ist | `Halt` · `Notfall` · `Hilfe` |
| Alltag | `Chat` · `Kalender` · `Medikamente` · `Tagebuch` · `Kontakte` · `Finder` |
| Wenn Ruhe ist | `Spiele` · `Zeitachse` · `Feedback` |

Eine Gruppe, in der das aktive Profil nichts sehen darf, entfällt vollständig
— eine Überschrift ohne Zeilen wäre eine Frage ohne Antwort.

### Die Kopfzeile

Auf beiden Orten gleich aufgebaut: links das Ankersymbol (auf dem Anker selbst
das Aurora-Logo), Mitte der Name des Ortes, rechts das Zahnrad für die
Einstellungen.

## Dateien

**Neu:**

| Datei | Verantwortung |
|---|---|
| `lib/modules/anchor/anchor_menu_screen.dart` | Der Anker: Profilkarte, gefilterte Zeilenliste |
| `lib/modules/anchor/anchor_row.dart` | Eine Zeile: Farbe, Symbol, Wort, Druckfeedback |
| `lib/widgets/work_surface_scaffold.dart` | Gemeinsames Gerüst der Arbeitsflächen: Kopfzeile mit Ankersymbol, Zurück-Behandlung, Platz für den Plus-Knopf |

**Geändert:**

| Datei | Änderung |
|---|---|
| `lib/main.dart` | `PageController`, Blockberechnung, Karussell-Synchronisierung und die FAB-Verteilung nach Seitenindex fallen weg. `TabDefinition` bekommt eine Bereichsfarbe |
| `lib/services/navigation_service.dart` | Merkt sich statt eines Seitenindex, welcher Bereich offen ist — oder keiner |

**Entfällt:**

| Datei | Grund |
|---|---|
| `lib/widgets/carousel_tab_navigator.dart` (486 Zeilen) | Ersetzt |

Der Zeitstrahl über dem Inhalt entfällt an dieser Stelle. Der Bereich
*Zeitachse* bleibt als eigene Zeile erhalten — dort gehört er hin, mit einem
ganzen Schirm statt eines Streifens.

## Zustand und Datenfluss

`TabDefinition` bleibt die einzige Quelle der Wahrheit: dieselbe Liste,
dieselben Rechte, ergänzt um die Bereichsfarbe. Kein zweites Verzeichnis, das
auseinanderlaufen kann.

```
ProfileSelectionScreen
        │  Profil gewählt
        ▼
AnchorMenuScreen ──── visibleTabsFor(_allTabDefinitions, activeProfile)
        │  Zeile angetippt
        │  Navigator.push(WorkSurfaceScaffold(tab))
        ▼
Arbeitsfläche ──── Ankersymbol / Zurück-Taste ──► pop ──► Anker
```

`NavigationService` hält weiterhin den Navigationszustand und wird beim
vollständigen Löschen der Daten mit geleert — das bleibt wie bisher.

## Rechte

Unverändert `visibleTabsFor`. Ein Profil ohne Kalenderrecht sieht die Zeile
nicht. Kein ausgegrauter Eintrag, der Fragen aufwirft.

Chat und Feedback haben `requiredPermission == null` und sind damit immer
sichtbar. Der Anker ist also nie leer.

## Fehlerfälle

| Fall | Verhalten |
|---|---|
| Kein aktives Profil | Anker wird nicht gezeigt; die Profilauswahl steht davor |
| Profil verliert das Recht, während der Bereich offen ist | Beim nächsten Aufbau des Ankers fehlt die Zeile. Die offene Fläche bleibt bis zum Verlassen bestehen — ein Rauswurf mitten in einer Eingabe wäre schlimmer als der verspätete Entzug |
| Profilwechsel aus einer offenen Arbeitsfläche heraus | Nicht möglich: Der Wechsel liegt auf dem Anker, die Fläche ist zu diesem Zeitpunkt bereits verlassen |
| Bereich wirft beim Aufbau | `CrashBoundary` greift wie bisher; der Anker bleibt erreichbar |

## Prüfung

| Test | Sichert |
|---|---|
| Anker zeigt nur Zeilen, die das aktive Profil sehen darf | Rechtefilter überlebt den Umbau |
| Anker zeigt Chat und Feedback auch ohne jedes Zusatzrecht | Der Anker ist nie leer |
| Zeile antippen öffnet den zugehörigen Bereich | Der Weg hinein |
| Ankersymbol führt zurück zum Anker | Der Weg heraus |
| Zurück-Taste verhält sich wie das Ankersymbol | Ein Weg, zwei Auslöser |
| Nach der Profilauswahl steht der Anker | Startort |
| Profilkarte zeigt das aktive Profil und führt zur Auswahl | Profilwechsel hat seinen Ort |
| Reihenfolge der Zeilen ist unabhängig von der Nutzung stabil | Keine Sortierung nach Häufigkeit |
| Kein Bereichsname erscheint zweimal auf einem Schirm | Befund K bleibt behoben |

## Nicht Teil dieser Arbeit

- **Zustand der Arbeitsflächen erhalten.** Wer den Anker antippt, während im
  Tagebuch ein halber Satz steht, kommt zu einem leeren Formular zurück. Das
  ist die bewusste Vereinfachung aus Entscheidung 9 und wird nachgerüstet, wo
  es am Gerät wirklich stört — nicht vorsorglich überall.
- **Neue Symbole.** Die Zeilen übernehmen zunächst die Symbole aus den
  bestehenden `TabItem`-Einträgen. Ob gezeichnete Bilder besser tragen als
  Material-Symbole, ist eine eigene Frage mit eigener Vorarbeit
  (`docs/superpowers/research/`, Piktogramm-Grundlagen).
- **Inhalt der Bereiche.** Diese Arbeit ändert, wie man hinkommt, nicht was
  dort steht.

## Offene Punkte

Die zwölf Bereichsfarben sind noch nicht als Werte festgelegt. Der Plan pinnt
sie, gebunden an drei Bedingungen:

- Kontrast der Beschriftung gegen die Fläche mindestens 4,5:1 (WCAG AA)
- benachbarte Zeilen bleiben bei Rot-Grün-Schwäche unterscheidbar
- keine Bereichsfarbe darf einer Profilfarbe so nahe kommen, dass eine Zeile
  wie ein Profil wirkt

Die Farbe ist Zugabe, nicht Träger: Sie unterstützt das Wiedererkennen, aber
kein Bereich ist ausschließlich an seiner Farbe zu erkennen — das Symbol trägt.
Deshalb blockiert dieser Punkt die Umsetzung nicht.
