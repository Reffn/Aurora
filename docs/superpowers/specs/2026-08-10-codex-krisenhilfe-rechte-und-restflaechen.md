# Codex-Gerätedurchlauf: Krisenhilfe, Rechte und Restflächen

**Stand:** 10. August 2026  
**Adressat:** Claude  
**Status:** Befundbericht, keine App-Implementierung durch Codex

## Prüfstand

- **Gerät:** Samsung A14, 1080×2408 bei 450 dpi, Systemschrift 100 %.
- **Laufzeitstand:** bereits installierte Debug-APK aus dem Arbeitsbaum vom
  10. August, 16:49 Uhr.
- **Bereiche:** Kalender, Zeitachse, Halt, Hilfe, Spiele/Puzzle,
  Rechteverwaltung, Profilbearbeitung und Datenlöschdialog.
- **Keine Nutzdaten verändert:** Der Kalenderentwurf wurde verworfen, die
  Profiländerung ging beim Verlassen verloren und der Löschdialog wurde mit
  „Abbrechen“ geschlossen. Keine Hotline wurde angerufen.
- **Externer Abgleich:** Erreichbarkeiten wurden am selben Tag ausschließlich
  auf den offiziellen Seiten der Anbieter geprüft.
- **Laufzeit:** Keine `FATAL EXCEPTION`, kein `E/flutter` und kein gemeldeter
  `RenderFlex`-Overflow im gefilterten Log.

Lokale Aufnahmen liegen unter `build/codex-audit-2026-08-10/` und dürfen wegen
möglicher Profil-/Standortdaten nicht committed werden.

## Priorität 0 — Krisenhilfe muss zeitlich und inhaltlich stimmen

### H1 — „24/7“ gilt nicht für die gesamte angezeigte Liste

Die Hilfefläche überschreibt die vollständige Liste mit „24/7
Notfall-Hotlines“ und „Professionelle Unterstützung – jederzeit erreichbar“.
Darunter stehen aber auch Angebote mit begrenzten Zeiten:

- Die beiden Nummern der Telefonseelsorge sind laut Anbieter tatsächlich rund
  um die Uhr erreichbar.
- „Nummer gegen Kummer“ ist laut Anbieter montags bis samstags von 14 bis
  20 Uhr erreichbar. Aurora nennt gar keine Zeiten.
- Aurora nennt für das Info-Telefon Depression „Mo–Do 13–17 Uhr, Di+Do
  19–21 Uhr“. Der Anbieter nennt aktuell Mo, Di, Do 13–17 Uhr sowie Mi, Fr
  8:30–12:30 Uhr. Er sagt außerdem ausdrücklich, dass das Angebot keine
  individuelle Akuthilfe ersetzt.

**Offizielle Quellen:**
[Telefonseelsorge](https://www.telefonseelsorge.de/telefon/),
[Nummer gegen Kummer](https://www.nummergegenkummer.de/kinder-und-jugendberatung/),
[Info-Telefon Depression](https://www.deutsche-depressionshilfe.de/hilfe/info-telefon).

#### Quellursache

- `app_de.arb:2841-2845` verspricht pauschal 24/7 und jederzeit.
- `hotline.dart:31-58` ist eine statische, ungruppierte Liste.
- `hotline.dart:53` enthält die veralteten Zeiten des Info-Telefons.
- „Nummer gegen Kummer“ trägt nur die Zielgruppenbeschreibung, keine
  Erreichbarkeit.

In einer Krise ist ein erfolgloser Anruf keine neutrale Sackgasse. Die Person
kann daraus schließen, Hilfe sei gerade grundsätzlich nicht erreichbar.

#### Akzeptanz

- Nur wirklich rund um die Uhr erreichbare Angebote stehen unter einem
  24/7-Kopf.
- Zeitlich begrenzte Angebote stehen in einer eigenen Gruppe mit vollständigen,
  aktuellen Zeiten direkt auf der Karte.
- Außerhalb der Sprechzeit ist mindestens ein tatsächlich erreichbarer
  Alternativweg sichtbar, ohne dass Aurora dafür aktuelle Uhrzeit erraten muss.
- Anbieterangaben besitzen Quelle und Prüfdatum im Repo sowie einen
  regelmäßigen Verifikationsprozess; sie sind keine ungeprüften Stringliterale.

**Lokale Evidenz:** `aurora-r3-help.png`, `aurora-r3-help.xml`,
`aurora-r3-help-bottom.xml`.

### H2 — Akute Lebensgefahr besitzt keinen sichtbaren 112-Weg

Weder „Notfall“ noch „Hilfe“ zeigt einen sichtbaren Rettungsdienst-/112-Weg.
Die Hilfefläche nennt sich trotzdem „Notfall-Hotlines“. Der offizielle Hinweis
des Info-Telefons Depression verweist bei akuten Krisen ausdrücklich auf Arzt,
psychiatrische Klinik oder 112; „Nummer gegen Kummer“ nennt bei akuter
Lebensgefahr 112 beziehungsweise 110.

Das bedeutet nicht, dass jede seelische Krise ein Rettungsdiensteinsatz ist.
Aber Aurora braucht eine klar abgegrenzte Eskalationsstufe, wenn unmittelbare
Gefahr besteht. Derzeit erscheinen Beratungsangebote und Notfallhilfe als eine
einzige Liste, während der eigentliche Notruf fehlt.

#### Akzeptanz

- Sichtbare, ruhig formulierte Trennung: „Wenn unmittelbar jemand in Gefahr
  ist: 112“ versus „Wenn du reden oder Beratung brauchst“.
- Ein Antippen der 112-Aktion öffnet erst die Telefon-App mit klarer Nummer; die
  App löst keinen stillen Direktanruf aus.
- Der Weg ist ohne Standortrecht, ohne angelegte Kontakte und unabhängig von
  Profilrechten sichtbar.
- Inhalt und Formulierung werden fachlich/rechtlich geprüft; Widget- und
  Gerätetest decken den Null-Kontakt-Krisenzustand ab.

### H3 — „Notfall“ und öffentliche Hilfe können beide pro Profil verschwinden

Das Rechte-Modell erlaubt `viewEmergencyTab` und `viewHelpTab` zu entziehen.
`main.dart:1184` beziehungsweise `main.dart:1295` filtern dann beide Wege aus
dem Anker. „Halt“ bleibt als Kernfunktion sichtbar, aber die öffentliche Hilfe
ist dort erst nach dem vollständigen Durchlaufen einer Übung hinter
„Jemanden anrufen“ indirekt erreichbar.

Das ist eine gefährliche Invariante: Private Notfallkontakte dürfen aus
Schutzgründen berechtigt sein. Öffentliche, profilunabhängige Beratungs- und
Notrufwege sollten jedoch nicht von einer anderen Rolle entziehbar sein.

#### Akzeptanz

- Mindestens ein klar benannter professioneller Krisenweg bleibt für jedes
  aktive Profil immer im Anker sichtbar.
- Rechte dürfen private Kontakte, Standortfreigabe und Bearbeitung steuern,
  nicht den Zugang zu neutralen öffentlichen Hilfen oder 112.
- Eine Invariantenprüfung erzeugt alle zulässigen Berechtigungskombinationen und
  beweist: Halt plus professionelle Hilfe bleiben direkt erreichbar.

## Priorität 0 — Datenschutzversprechen stimmt nicht mit Release-Verhalten überein

### D2 — Datenschutzerklärung verspricht einen Löschknopf, der nur im Debug-Build existiert

`privacyDeletionBody` sagt: „In den Einstellungen gibt es ‚Alle Daten
löschen‘.“ Der Eintrag liegt in `settings_screen.dart:952-1074` jedoch komplett
hinter `if (kDebugMode)`. In einem Release-Build ist der in der Erklärung
versprochene Einstellungsweg deshalb nicht vorhanden.

Ein versteckter Notfall-Reset auf dem Startlogo ist kein gleichwertiger,
auffindbarer Ersatz für den ausdrücklich genannten Einstellungsweg.

#### Akzeptanz

- Der Release-Build besitzt den angekündigten, auffindbaren Löschweg, geschützt
  durch eine klare destruktive Bestätigung.
- Ein Release-/Profile-Test beweist die Sichtbarkeit für die berechtigte Person
  und die vollständige Löschung.
- Datenschutzerklärung und tatsächlicher Weg werden gemeinsam geändert und
  getestet; kein Debug-only-Verhalten wird Nutzenden versprochen.

### D3 — Der Löschdialog beschreibt den tatsächlichen Umfang unvollständig

Der Dialog nennt unter Anhängen nur „Doodle-Anhänge“. Der Löschkern entfernt
über `AttachmentHelper.clearAll` aber Bilder, Sprachnachrichten, Doodles und
Avatare; zusätzlich werden Kartenkacheln, Standort-/Profilwechselverlauf,
Übertragungsprotokoll und Telemetrie-Warteschlange entfernt. Nicht alle davon
sind im Dialog verständlich benannt.

Die Löschung selbst ist im aktuellen Kern erfreulich defensiv und verifiziert
Teilfehler. Die Bestätigung sollte dieselbe Wahrheit erzählen: Menschen müssen
vor einer unumkehrbaren Handlung wissen, was verschwindet.

#### Akzeptanz

- Bestätigung nennt verständliche Kategorien statt einer lückenhaften
  technischen Auswahl: Profile und Einstellungen; Kommunikation samt allen
  Medien; Kalender/Medikamente/Kontakte/Notizen; Standort- und
  Profilwechselverlauf; Diagnose-/Übertragungsdaten; Offline-Karten.
- Der Text wird aus derselben fachlichen Löschumfangsdefinition gepflegt oder
  durch einen Test gegen sie abgesichert.

**Lokale Evidenz:** `aurora-r3-delete-dialog.png`,
`aurora-r3-delete-dialog.xml`.

## Priorität 1 — Halt muss ohne Entdeckungsarbeit funktionieren

### G1 — Weiterblättern ist eine unsichtbare Ganzflächen-Geste

Die Halt-Übersicht ist visuell ruhig, besitzt große Ziele und sinnvolle
Bezeichnungen. In einer Übung zeigt die App aber nur Bild, Fortschrittspunkte
und den aktuellen Satz. Es gibt keinen sichtbaren Hinweis „Tippen zum
Weitergehen“ und keinen sichtbaren Weiter-Knopf. Erst ein zufälliger Tap irgendwo
auf den Bildschirm wechselt zum nächsten Schritt.

`exercise_player_screen.dart:141-145` macht die ganze Fläche per
`GestureDetector` zum Ziel. Das ist motorisch großzügig, aber kognitiv
unsichtbar. Zudem besitzen die Zurück-IconButtons in
`exercise_player_screen.dart:124` und `:156` keinen Tooltip; Android exportiert
sie als leere Buttons.

#### Akzeptanz

- Der erste Schritt erklärt einmal knapp „Tippe irgendwo für den nächsten
  Schritt“ oder bietet einen großen, ruhigen „Weiter“-Knopf.
- TalkBack kündigt „Schritt 1 von 6“, den Schritttext und die Weiter-Aktion an.
- Zurück heißt hörbar „Vorheriger Schritt“; beim ersten Schritt „Übung
  verlassen“.
- Der letzte Schritt kündigt den Abschluss an, bevor „Nochmal“, „Was anderes“
  und „Jemanden anrufen“ fokussiert werden.

**Lokale Evidenz:** `aurora-r3-halt-now.png`,
`aurora-r3-halt-now.xml`, `aurora-r3-halt-now2.xml`,
`aurora-r3-halt-now-final.xml`.

## Priorität 1 — Formulare und Rechte müssen dasselbe bedeuten, was sie zeigen

### U2 — Profiländerungen gehen ohne Rückfrage verloren

Im Profil „Name“ ändern und zweimal Zurück drücken: Die App kehrt direkt zur
vorigen Arbeitsfläche zurück. Der alte Name bleibt bestehen, es erscheint kein
Dialog. Das unterscheidet sich von Kalender, Medikamente, Tagebuch, Kontakte
und Finder, die ungespeicherte Änderungen schützen.

`profile_edit_screen.dart` besitzt Controller und einen expliziten
Speichern-Knopf, aber keinen `PopScope`. Zusätzlich sind Name, beide
Passwortfelder, beide Sichtbarkeitsschalter und der sichtbare Zurückknopf im
Android-Semantikbaum unbeschriftet.

#### Akzeptanz

- Vor dem Verlassen geänderter Profildaten erscheint das etablierte
  Abbrechen/Verwerfen/Speichern-Muster.
- Name, Passwort, Passwortbestätigung, Sichtbarkeit und Zurück besitzen
  eindeutige Namen, Rollen und Zustände.
- Tests decken Android-Zurück, sichtbaren Pfeil und erfolgreichen Save ab.

**Lokale Evidenz:** `aurora-r3-profile-edit.png`,
`aurora-r3-profile-edit.xml`, `aurora-r3-profile-edit-back.xml`.

### R1 — Die Rechteverwaltung enthält wirkungslose oder nicht vorhandene Bereiche

Das Modell bietet `viewChatTab`, `viewFeedbackTab` und `viewMantrasTab` an.
Gleichzeitig sind Chat und Feedback in `main.dart` als immer sichtbare
Kernfunktionen mit `requiredPermission: null` definiert. Für Mantras existiert
keine Tabdefinition beziehungsweise kein Mantra-Screen, obwohl die
Rechteverwaltung „Mantras-Bereich – Die Mantras überhaupt sehen“ anbietet.

So kann eine verwaltende Person eine Einstellung ändern und eine Wirkung
erwarten, die nicht eintritt. Umgekehrt kann sie mit Hilfe/Notfall genau die
beiden riskanten Sichtbarkeiten tatsächlich entziehen.

#### Akzeptanz

- Jede sichtbare Berechtigung besitzt genau einen aktuellen Verbraucher und
  einen automatisierten Wirkungstest.
- Kernfunktionen erscheinen nicht als entziehbare Rechte.
- Nicht implementierte Bereiche erscheinen weder in Rechteverwaltung noch
  Willkommenszusammenfassung.
- „System-Berechtigungen“ wird so benannt, dass es nicht mit Android-Kamera-,
  Standort- oder Mikrofonrechten verwechselt wird, beispielsweise
  „Aurora-Bereiche und Verwaltung“.

**Lokale Evidenz:** `aurora-r3-permissions-detail.png`,
`aurora-r3-permissions-detail.xml`.

## Priorität 2 — systemische Barrierefreiheit und falsche Angebote

### A7 — Kartensteuerung besteht aus leeren Buttons

Auf der Zeitachse exportiert die Karte Zoom plus, Zoom minus und „meine
Position“ als klickbare Android-Knoten ohne Namen. Die Kartenfläche selbst ist
ebenfalls ein leerer großer Knoten. `overview_map.dart:1397-1453` baut die drei
FloatingActionButtons ohne Tooltip oder Semantics.

Das betrifft nicht nur die Zeitachse, weil `OverviewMap` geteilt wird.

#### Akzeptanz

- „Vergrößern“, „Verkleinern“, „Zu meiner Position“ samt deaktiviertem/fehlendem
  Standortzustand.
- Die Karte erhält einen kurzen Zweck und darf nicht als leerer Button
  erscheinen.
- Semantiktests laufen für Zeitachse, Notfall und weitere Map-Nutzer.

**Lokale Evidenz:** `aurora-r3-timeline.xml`.

### A8 — Untere Systemleiste verdeckt weitere letzte Aktionen

Der zweite Bericht hat dies für die Sprachkarte der Einstellungen belegt. Der
Puzzle-Auswahlschirm reproduziert dasselbe Muster: Am maximalen Scrollende reicht
„Bild auswählen & starten“ bis y=2341, die Android-Navigationsleiste beginnt
ungefähr bei y=2273. `puzzle_selection_screen.dart:32-33` setzt nur
`EdgeInsets.all(24)` und berücksichtigt die untere Systemfläche nicht.

Das ist damit ein gemeinsamer Layoutfehler, keine einzelne Settings-Korrektur.

#### Akzeptanz

- Ein wiederverwendbares Seiten-/Listenmuster fügt sichere untere Insets plus
  komfortablen Abschlussabstand hinzu.
- Regressionstest für alle scrollbaren Vollseiten bei Drei-Tasten- und
  Gestennavigation sowie 100/150/200 % Schrift.

**Lokale Evidenz:** `aurora-r3-puzzle-bottom.xml`.

### I1 — Spiele verspricht Atemübungen als „Bald“, obwohl Halt sie schon besitzt

In „Spiele & Entspannung“ sind vier große Angebote sichtbar, aber nur Puzzle ist
nutzbar; Atemübungen, Memory und Zeichnen sind „Bald“. Gleichzeitig bietet
„Halt“ bereits eine funktionierende Atemübung. Wer unter Stress genau den
naheliegenden Eintrag „Atemübungen“ wählt, findet eine Sackgasse statt des
vorhandenen Wegs.

#### Akzeptanz

- Atemübungen führt zur vorhandenen Halt-Atemübung oder wird nicht als tote
  Karte gezeigt.
- Nicht verfügbare Zukunftsfunktionen verdrängen keine nutzbaren Wege auf der
  produktiven Oberfläche.

**Lokale Evidenz:** `aurora-r3-games.png`, `aurora-r3-games.xml`.

## Positive Befunde

- Kalenderentwürfe verwenden das gemeinsame Dialogmuster für ungespeicherte
  Änderungen.
- Kalenderstart und Halt-Übersicht sind bei 100 % visuell ruhig, klar gruppiert
  und mit großen Zielen ausgestattet.
- Der Abschluss einer Halt-Übung bietet drei wertungsfreie Wege: wiederholen,
  etwas anderes und jemanden anrufen.
- Der Datenlöschkern behandelt Teilerfolge als Fehler, löscht auch
  Standort-/Übertragungsreste und prüft verbliebene Anhänge.
- Die Hilfe-Karten zeigen Nummer, Zweck und einen großen Anrufknopf offen an;
  nach Korrektur von Gruppierung, Zeiten und Notrufstufe ist das ein gutes
  Grundmuster.

## Empfohlene Reihenfolge für Claude

1. Krisenliste fachlich korrigieren: 112-Abgrenzung, Gruppen, aktuelle Zeiten,
   Quellen-/Prüfprozess.
2. Öffentliche Hilfe als nicht entziehbare Invariante festlegen.
3. Release-Löschweg und Datenschutzerklärung in Übereinstimmung bringen.
4. Halt-Weiteraktion und Back-Semantik reparieren.
5. Profil-Entwurfsschutz und Rechtekatalog bereinigen.
6. Gemeinsame Karten-Semantik und systemweite untere SafeArea schließen.
