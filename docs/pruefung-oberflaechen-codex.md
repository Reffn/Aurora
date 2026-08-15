# Prüfung der Oberflächen-Richtlinien — Codex

**Stand:** 13. August 2026  
**Prüfumfang:** `lib/modules/**/*.dart` und `lib/widgets/**/*.dart`  
**Maßstab:** `docs/oberflaechen-richtlinien.md`, insbesondere zuerst Regel 2
(Wahlfläche ≠ Arbeitsfläche) und Regel 4 (Sättigung hat eine Aufgabe).

Statische Prüfung des aktuellen Quellstands. Es wurden keine App-Builds,
Widgettests oder Emulatorläufe ausgeführt. Tote, nachweislich nicht verwendete
Widgets wurden nicht als Oberflächenbefund gewertet. Die Schwere beschreibt
die Auswirkung auf Orientierung und Bedienbarkeit unter kognitiver Last.

## Hoch

### 1. Die Erdungsanweisungen haben im Auslieferungsstand keine tragenden Bilder

- **Fundstelle:** `lib/modules/grounding/data/grounding_images.dart:14-17`;
  `lib/modules/grounding/widgets/step_view.dart:31-48` und `:143-153`
- **Regel:** 5 — Das Bild trägt, das Wort bestätigt.
- **Warum es hier zählt:** `_paths` ist leer. Deshalb liefert `resolve()` für
  jeden Schritt `null`, und `StepView` zeigt statt des schrittspezifischen
  Bildes immer nur `_FallbackSymbol(exercise.icon)`. Alle Schritte derselben
  Übung haben damit dasselbe abstrakte Material-Symbol; die wechselnde
  Anweisung steckt ausschließlich im Text. Wer im belasteten Zustand nicht
  lesen kann, kann die Erdungsübung nicht aus dem Bild ausführen.

### 2. Die gesamte Anweisung ist zugleich ein unsichtbarer „Weiter“-Knopf

- **Fundstelle:** `lib/modules/grounding/exercise_player_screen.dart:137-160`
- **Regeln:** 2 — Wahlfläche ist nicht Arbeitsfläche; 5 — Bild und Wort; 8 —
  jede Geste hat einen sichtbaren Knopf.
- **Warum es hier zählt:** Ein `GestureDetector` legt `onTap: _next` über die
  ganze `StepView`. Die Fläche sieht wie reine Anleitung aus, ist aber zugleich
  die einzige Vorwärtsbedienung; ein sichtbarer Knopf mit Symbol und Wort fehlt.
  Ohne Vorwissen bleibt eine Person auf Schritt 1 stehen, gerade in dem Bereich,
  der im schlechtesten Zustand funktionieren soll.

### 3. Frei wählbare Profilfarben werden als volle Fläche mit festem Weiß benutzt

- **Fundstelle:** `lib/widgets/reset_banner.dart:88-111`;
  `lib/widgets/profile_actions_dialog.dart:245-250`, `:290-295`, `:462-466`
  und `:571-575`
- **Regeln:** 4 — Sättigung hat eine Aufgabe; 6 — Kontrast ist Untergrenze.
- **Warum es hier zählt:** Das Reset-Band und mehrere Reset-Knöpfe übernehmen
  `preferredColor` roh als Hintergrund, während Symbol und Schrift immer weiß
  bleiben. Profilfarben dürfen bis Weiß reichen: Bei einem weißen oder sehr
  hellen Profil verschwinden Sanduhr, Restzeit beziehungsweise Knopftext. Bei
  kräftigen Profilfarben entstehen zudem über allen Arbeitsflächen gesättigte
  Bänder und gewöhnliche Dialogknöpfe, obwohl volle Farbe Halt, Notfall und
  Hilfe vorbehalten ist.

### 4. Listen, Details und Formulare bilden eine dritte und vierte Navigationsebene

- **Fundstelle:** `lib/modules/contacts/contacts_screen.dart:119-126` und
  `lib/modules/contacts/contact_detail_screen.dart:64-85`;
  entsprechend `lib/modules/finder/finder_screen.dart:118-123` und
  `lib/modules/finder/finder_detail_screen.dart:32-64` sowie
  `lib/modules/diary/diary_screen.dart:76-81` und
  `lib/modules/diary/entry_detail_screen.dart:100-109`
- **Regel:** 1 — Zwei Orte, nie beide gleichzeitig.
- **Warum es hier zählt:** Von einer Arbeitsfläche wird eine Detailseite per
  `Navigator.push` geöffnet, von dort wiederum ein Bearbeitungsformular. Diese
  Seiten erhalten den normalen Material-Zurückpfeil statt des zugesagten
  Ankers. Damit ist der Rückweg je nach Tiefe „Formular → Detail → Liste →
  Anker“ und nicht überall derselbe sichtbare Weg zum Anker; bei Amnesie muss
  die Person erst herausfinden, auf welcher Ebene sie ist.

### 5. Inhaltskarten sind ohne sichtbare Kennzeichnung gleichzeitig Navigation

- **Fundstelle:** `lib/modules/contacts/widgets/contact_card.dart:41-47`;
  `lib/modules/finder/widgets/finder_item_card.dart:20-26`;
  `lib/modules/diary/widgets/entry_card.dart:33-39`;
  `lib/modules/medication/widgets/medication_card.dart:86-96`
- **Regel:** 2 — Wahlfläche ist nicht Arbeitsfläche.
- **Warum es hier zählt:** Name, Beschreibung, Status, Uhrzeit und weitere
  Daten werden als normale `Card` gezeigt; dieselbe Inhaltsfläche ist durch
  ein umschließendes `InkWell` antippbar. Vor dem ersten Tippen gibt es weder
  ein Wort wie „Details“ noch einen Pfeil oder eine abgesetzte Wahlfläche.
  Dadurch ist nicht erkennbar, welche Information nur angezeigt wird und
  welche Karte in eine weitere Ansicht führt.

### 6. „Feedback senden“ überträgt sofort, ohne die Sendung vorher prüfen zu lassen

- **Fundstelle:** `lib/modules/feedback/feedback_screen.dart:286-293` und
  `:411-420`
- **Regel:** 10 — Formulare sagen, was passiert; vor dem Abschicken prüfen
  lassen.
- **Warum es hier zählt:** Der sichtbare Knopf ruft unmittelbar
  `_sendFeedback()` auf; nach der Validierung wird aus Titel, Nachricht und
  optionaler E-Mail die Nutzlast gebaut und an `FeedbackSender.send()`
  übergeben. Es gibt davor weder Vorschau noch Bestätigung des wörtlichen
  Inhalts. Ein Fehlgriff sendet damit Gesundheitsdaten außerhalb des Geräts,
  bevor die Person sie noch einmal ansehen kann.

### 7. Fünf lange Formulare bieten beim Verlassen nur Speichern, Verwerfen oder Bleiben

- **Fundstelle:** `lib/widgets/dialogs/confirmation_dialog.dart:163-178`;
  Aufrufe in `lib/modules/calendar/event_form_screen.dart:122-130`,
  `lib/modules/contacts/contact_form_screen.dart:100-113`,
  `lib/modules/diary/entry_form_screen.dart:68-81`,
  `lib/modules/finder/finder_form_screen.dart:80-93` und
  `lib/modules/medication/medication_form_screen.dart:96-109`
- **Regel:** 10 — Kein Ablauf ohne sanften Ausgang („Später weiter“).
- **Warum es hier zählt:** `showUnsavedChanges()` kennt nur `cancel` (im
  Formular bleiben), `discard` (Eingabe verlieren) und `confirm` (jetzt
  speichern). Einen Ausgang mit erhaltenem Entwurf gibt es nicht. Muss ein
  anderer Anteil mitten in Termin, Kontakt, Tagebuch, Finder oder Medikament
  übernehmen, erzwingt die Oberfläche entweder einen unfertigen Datensatz oder
  den Verlust der begonnenen Arbeit.

### 8. Die Zeichenwerkzeuge bestehen aus sechs unbeschrifteten Symbolknöpfen

- **Fundstelle:** `lib/modules/chat/widgets/doodle_canvas.dart:636-681` und
  `:732-776`
- **Regeln:** 3 — Mehr als etwa fünf Einträge gruppieren; 5 — nie ein Symbol
  allein.
- **Warum es hier zählt:** Senden, Moduswechsel, Sticker, Radierer,
  Rückgängig und Löschen stehen als gleichartige `_RailButton`s untereinander.
  `_RailButton` rendert nur ein Icon; das Wort steckt ausschließlich in einem
  `Tooltip` und ist im normalen Bild nicht sichtbar. Gerade der Zeichenweg ist
  für Menschen gedacht, die nicht lesen oder schreiben können; ähnliche
  abstrakte Symbole müssen hier erraten werden, und sechs gleichrangige
  Werkzeuge bleiben ungegliedert.

### 9. Drei Funktionen sind ausschließlich über verborgene Gesten erreichbar

- **Fundstelle:** `lib/modules/chat/chat_screen.dart:315-323`;
  `lib/modules/profile/profile_selection_screen.dart:618-633`;
  `lib/modules/transparency/transparency_screen.dart:190-215`
- **Regel:** 8 — Jede Geste hat einen sichtbaren Knopf.
- **Warum es hier zählt:** „Als gelesen markieren“ hängt nur am langen Druck
  auf eine Chatblase, Profiloptionen nur am langen Druck auf einen Avatar, und
  das Löschen eines Übertragungsprotokolls nur am Wischen nach links. In keiner
  der drei Flächen existiert ein sichtbarer Knopf für dieselbe Handlung. Die
  Funktionen bleiben deshalb für Menschen unsichtbar, die die jeweilige Geste
  nicht kennen oder motorisch nicht ausführen können.

### 10. Kartenkacheln werden auf Wahl- und Notfallfläche ungedämpft übernommen

- **Fundstelle:** `lib/widgets/overview_map.dart:1834-1864`; verwendet von
  `lib/widgets/time_map.dart:592-600` /
  `lib/modules/profile/profile_selection_screen.dart:368-371` und von
  `lib/modules/emergency/emergency_screen.dart:168-184`
- **Regel:** 4 — Sättigung hat eine Aufgabe.
- **Warum es hier zählt:** Der `tileBuilder` gibt das farbige OSM-`tileWidget`
  unverändert zurück. Damit belegt eine vollfarbige, detailreiche Karte einen
  großen Teil der Profilauswahl und der Notfallfläche. Auf der Wahlfläche
  konkurriert sie mit der eigentlichen Profilwahl; im Notfall konkurriert sie
  mit Kontakten und Sendehandlungen, obwohl dort nur Hilfehandlungen laut sein
  dürfen. Der Befund betrifft die ungedämpfte Darstellung, nicht den fachlich
  begründeten Standortinhalt.

## Mittel

### 11. Bearbeiten und Löschen stehen auf vier Detailflächen nur als Symbole

- **Fundstelle:** `lib/modules/contacts/contact_detail_screen.dart:64-85`;
  `lib/modules/finder/finder_detail_screen.dart:32-64`;
  `lib/modules/diary/entry_detail_screen.dart:100-127`;
  `lib/modules/medication/medication_detail_screen.dart:108-136`
- **Regel:** 5 — Das Bild trägt, das Wort bestätigt.
- **Warum es hier zählt:** Die `IconButton`s zeigen Stift beziehungsweise
  Papierkorb ohne sichtbare Wörter und ohne Tooltip. Besonders beim Löschen
  muss die Bedeutung vor dem Griff eindeutig sein; der nachgeschaltete
  Bestätigungsdialog ersetzt keine erkennbare Handlung auf der Detailfläche.
  Der Kalender zeigt das richtige Gegenbeispiel bereits als
  `FilledButton.tonalIcon` beziehungsweise `TextButton.icon` mit Beschriftung.

### 12. Der Kontaktfilter versteckt sechs Wahlmöglichkeiten in horizontalem Wischen

- **Fundstelle:** `lib/modules/contacts/contacts_screen.dart:39-69`
- **Regeln:** 1 — keine Wischgeste ins Unsichtbare; 3 — über etwa fünf
  Einträge gruppieren; 8 — Geste braucht sichtbare Alternative.
- **Warum es hier zählt:** „Alle“ plus fünf Kategorien werden in einer
  horizontalen `SingleChildScrollView` ausgegeben. Auf schmalen Geräten liegen
  die rechten Chips außerhalb des Bildes; es gibt weder Gruppen noch Pfeil,
  Scrollbalken oder sichtbaren Knopf zum Erreichen der verborgenen Kategorien.
  Wer horizontales Wischen nicht ausprobiert, kann diese Filter nicht wählen.

### 13. Die Profilauswahl behandelt eine unbegrenzte Profilmenge als flaches Raster

- **Fundstelle:** `lib/modules/profile/profile_selection_screen.dart:324-327`
  und `:601-663`
- **Regel:** 3 — Mehr als etwa fünf Einträge gruppieren.
- **Warum es hier zählt:** Die Zahl kommt direkt aus `getProfiles().length`;
  alle Profile werden anschließend ohne Obergrenze oder Gruppierung in ein
  einziges `Wrap` gelegt. Ab sechs Anteilen ist die Auswahl eine flache,
  wachsende Menge. Gerade in einer DIS-App ist eine größere Zahl von Anteilen
  kein theoretischer Randfall; Namen und Orte gehen in einem langen Raster
  verloren.

### 14. Dekorative Dauerbewegung ignoriert die Systemeinstellung für reduzierte Bewegung

- **Fundstelle:** `lib/modules/onboarding/pre_onboarding_screen.dart:55-61`
  und `:559-573`; `lib/modules/profile/profile_creation_screen.dart:60-64`
  und `:389-414`; außerdem der gemeinsame Leerzustand
  `lib/widgets/animated_empty_state.dart:50-90`
- **Regeln:** 11 — Bewegung zeigt etwas oder entfällt; reduzierte Bewegung
  wird beachtet. Beim Leerzustand zusätzlich Regel 4.
- **Warum es hier zählt:** Onboarding und Profilerstellung lassen Glow und
  Kreise per `repeat(reverse: true)` dauerhaft pulsieren beziehungsweise
  rotieren, ohne dass die Bewegung einen Zustand erklärt. Der gemeinsame
  Leerzustand skaliert ein großes farbig leuchtendes Icon, obwohl „keine Daten“
  keine laute Handlung ist. Keine dieser Stellen fragt
  `MediaQuery.disableAnimationsOf(context)` ab; die Animationen laufen daher
  auch bei aktivierter Systemoption weiter.

### 15. In den Einstellungen sehen Inhalt und Navigation bis auf Deaktivierung gleich aus

- **Fundstelle:** `lib/modules/settings/settings_screen.dart:1678-1758` und
  `:1761-1780`
- **Regel:** 2 — Wahlfläche ist nicht Arbeitsfläche.
- **Warum es hier zählt:** Impressum, Datenschutz und „Was Aurora sendet“ sind
  antippbare `Card > ListTile`-Zeilen. Direkt darunter wird die reine Anzeige
  der App-Version mit derselben `Card > ListTile`-Bauform gerendert und nur
  `enabled: false` gesetzt. Eine Informationsfläche sieht dadurch wie eine
  deaktivierte Wahl aus; die Person muss aus dem fehlenden Pfeil ableiten,
  welche Karten öffnen und welche nur etwas zeigen.

## Abgrenzung und vollständiger Regelabgleich

- **Regeln 2 und 4 wurden zuerst geprüft.** Der Anker selbst trennt die ruhigen
  Bereichskacheln von den drei vollfarbigen Schnellwegen nachvollziehbar; die
  Befunde zu diesen Regeln liegen stattdessen in Arbeitsflächen, Karten,
  Reset-Hinweisen und Einstellungen.
- **Regeln 7 und 9:** Im geprüften Bestand fand sich kein weiterer Verstoß, der
  ohne Annahmen als Befund trägt. Die sichtbaren Hauptreihenfolgen sind fest;
  es wurde kein automatisches Vereinfachen nach einem vermuteten psychischen
  Zustand gefunden.
- **Prüffragen 5 bis 8:** Rückwege, verborgene horizontale Inhalte,
  nutzungsabhängige Reihenfolge und Formularfolgen sind in den Befunden 4, 6,
  7 und 12 konkret abgedeckt.

**Ergebnis:** 15 belegte Befunde — 10 hoch, 5 mittel. Jeder Befund nennt
Datei, Zeile, Regel und den konkreten Fehlerfall.
