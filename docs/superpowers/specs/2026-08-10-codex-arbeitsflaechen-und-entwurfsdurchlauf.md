# Codex-Gerätedurchlauf: Arbeitsflächen, Entwürfe und Einstellungen

**Stand:** 10. August 2026  
**Adressat:** Claude  
**Status:** Befundbericht, keine App-Implementierung durch Codex

## Prüfstand und Abgrenzung

- **Gerät:** Samsung A14, 1080×2408 bei 450 dpi.
- **Laufzeitstand:** Debug-APK aus dem damaligen Arbeitsbaum, gebaut am
  10. August um 16:49 und vor diesem Durchlauf installiert. Spätere parallele
  Fixes sind darin noch nicht enthalten.
- **Zustände:** leere und begonnene Formulare, Verlassen über Zurück und Anker,
  Medienauswahl, Profilmenü, Einstellungen bei 100 % und 150 % Systemschrift.
- **Keine Testdaten gespeichert:** Alle begonnenen Medikament-, Tagebuch- und
  Finder-Einträge wurden über „Verwerfen“ beendet. Es wurde kein Kontakt und
  keine Chatnachricht angelegt.
- **Wiederhergestellt:** Systemschrift steht wieder auf 100 %, die zuvor
  vorhandenen Standortrechte blieben erteilt.
- **Laufzeit:** Im gefilterten Log traten weder `FATAL EXCEPTION`, `E/flutter`
  noch ein gemeldeter `RenderFlex`-Overflow auf.

Die lokalen Aufnahmen liegen unter `build/codex-audit-2026-08-10/`. **Nicht
committen:** Darin können reale Profilinformationen sichtbar sein.

## Priorität 0 — Krisenfluss darf keine unerreichbaren Kontakte versprechen

### K1 — Ein Notfallkontakt kann ohne erreichbaren Kanal gespeichert werden

Das Kontaktformular bietet „Als Notfallkontakt markieren“ prominent an.
Telefon und E-Mail sind anschließend beide optional. Nur der Name besitzt
einen Validator. Damit kann ein Eintrag als Notfallkontakt gespeichert werden,
obwohl Aurora ihn weder anrufen noch per SMS erreichen kann.

Auf der Notfallfläche wird ein solcher Eintrag dennoch geführt. Seine Anruf-
und SMS-Aktionen sind deaktiviert. Die Nachrichtenlogik wirft bei einem
einzelnen Kontakt ohne Telefonnummer „Kontakt hat keine Telefonnummer“ oder
filtert solche Kontakte beim Sammelversand vollständig heraus.

#### Quellbeleg des geprüften Stands

- `contact_form_screen.dart:305-309` validiert nur den Namen.
- `contact_form_screen.dart:372-419` erlaubt die Notfallmarkierung unabhängig
  vom ausdrücklich optionalen Telefonfeld.
- `contact_form_screen.dart:166-186` speichert `phone: null` und
  `isEmergencyContact: true` unabhängig voneinander.
- `emergency_contact_card.dart:24-110` deaktiviert Anruf und SMS ohne Telefon.
- `emergency_message_service.dart:111-138` verwirft beziehungsweise beanstandet
  Kontakte ohne Telefonnummer.

#### Akzeptanz

- Beim Aktivieren von „Notfallkontakt“ verlangt Aurora mindestens einen in der
  Notfallfläche wirklich nutzbaren Kontaktweg.
- Wenn ein rein informativer Kontakt zulässig bleiben soll, muss die
  Oberfläche klar sagen, wofür er im Notfall nutzbar ist und wofür nicht.
- Validierung erfolgt vor dem Speichern direkt am Feld.
- Regressionstests decken Name-only + Notfallmarkierung, das Löschen einer
  bestehenden Nummer und gemischte Sammelversände ab.

**Lokale Evidenz:** `aurora-r2-contact-form.png`.

## Priorität 1 — Unterbrechung und Wiederaufnahme

### U1 — Ein ungesendeter Chatentwurf geht beim Ankerwechsel lautlos verloren

#### Nachstellen

1. Chat öffnen.
2. Text eingeben, aber nicht senden.
3. Den sichtbaren Ankerweg verwenden.
4. Chat erneut öffnen.

Das Eingabefeld ist leer. Es gibt weder eine Rückfrage noch einen
wiederhergestellten Entwurf oder einen Hinweis auf den Verlust.

Das ist für Aurora besonders teuer: Ein Anteil kann einen Satz beginnen,
unterbrochen werden und später nicht wissen, ob er gesendet, verworfen oder nie
geschrieben wurde. Medikament-, Tagebuch-, Kontakt- und Finder-Formulare
besitzen bereits das passende Gegenmuster mit „Abbrechen“, „Verwerfen“ und
„Speichern“.

`chat_input_field.dart:43` erzeugt den Controller lokal und
`chat_input_field.dart:201-203` verwirft ihn beim Abbau. Im geprüften Stand gab
es weder Entwurfszustand außerhalb des Widgets noch Verlassensschutz.

#### Akzeptanz

- Bevorzugt bleibt ungesendeter Text pro Profil als gekennzeichneter Entwurf
  nach Ankerwechsel, Profilauswahl und kurzer App-Unterbrechung erhalten.
- Minimal erscheint beim Verlassen mit Inhalt das vorhandene
  Änderungen-Dialogmuster.
- Tests decken Anker, Android-Zurück, Profilwechsel, Hintergrund, Senden und
  das korrekte Entfernen eines gesendeten Entwurfs ab.

**Lokale Evidenz:** `aurora-r2-chat.png`, `aurora-r2-chat-return.xml`,
`aurora-r2-med-form-back.png`, `aurora-r2-diary-form-back.png`,
`aurora-r2-finder-form-back.png`.

## Priorität 1 — Assistive Bedienung und verlässliche Trefferflächen

### A3 — Die drei wichtigsten Chat-Eingaben sind unbeschriftet

Im Android-Semantikbaum besitzen Plusknopf, leeres Texteingabefeld und
Sendeknopf keinen Namen. Der sichtbare Platzhalter wird nicht als Feldname oder
Hinweis exportiert. Bild, Sprechen und Malen sind dagegen sinnvoll benannt.

#### Akzeptanz

- Plus: „Weitere Medien hinzufügen“.
- Eingabe: stabiler Feldname „Nachricht“, optional mit Hinweis; der Name bleibt
  auch nach Texteingabe bestehen.
- Senden: „Nachricht senden“ inklusive verständlichem deaktiviertem Zustand.
- Semantiktest prüft Namen, Rolle, Zustand, Leserichtung und mindestens 48×48
  dp verlässliche Trefferfläche.

**Lokale Evidenz:** `aurora-r2-chat.xml`.

### A4 — Das Medienblatt benennt nur die Galerie und besitzt keinen klaren Ausgang

Der Plusknopf öffnet ein Blatt mit dem Titel „Aus der Galerie“. Darunter stehen
aber Bild aus Galerie, **neues Video aufnehmen** und Video aus Galerie. Es gibt
keinen sichtbaren Schließen-/Abbrechen-Knopf. Der schließende Hintergrund wird
assistiven Diensten als „Gitter“ angekündigt.

- `media_options_sheet.dart:127` verwendet `mediaFromGallery` als Überschrift,
  obwohl `media_options_sheet.dart:158-188` auch die Kamera anbietet.
- `chat_input_field.dart:71-81` öffnet das Modalblatt ohne eigenen
  Barrieretext oder sichtbare Abbruchaktion.

#### Akzeptanz

- Neutrale Überschrift wie „Medien hinzufügen“.
- Sichtbarer, beschrifteter Ausgang „Schließen“ oder „Abbrechen“.
- Der modale Hintergrund wird sinnvoll angekündigt oder aus der Fokusfolge
  genommen.
- Zurück und TalkBack kehren zum unveränderten Chatentwurf zurück.

**Lokale Evidenz:** `aurora-r2-chat-media.png`,
`aurora-r2-chat-media.xml`.

### A5 — Der Profilkopf verspricht eine größere Trefferfläche, als wirklich reagiert

Android meldete den gesamten mittleren Kopfbereich ungefähr von `[420,96]` bis
`[660,237]` als Profil-/Einstellungsbutton. Zwei Taps im oberen semantisch
zugesagten Teil bei y≈165 öffneten nichts. Erst ein Tap auf die schmale
Profilzeile bei y≈210 öffnete das Menü.

Im geprüften `work_surface_scaffold.dart:91-99` umgibt `Semantics` die
antippbare Profilzeile und wird durch die Titelstruktur zu einer größeren
Ansage zusammengeführt; der tatsächliche `InkWell` umfasst nur die untere
Zeile.

#### Akzeptanz

- Die vollständige semantische Buttonfläche ist tatsächlich klickbar, oder
  der semantische Knoten umfasst exakt die visuelle Profilzeile.
- Bereichstitel und Profilaktion bleiben eindeutig.
- Ein Test vergleicht Semantik-Rect und Hit-Test-Rect und tippt mehrere Punkte
  innerhalb der angekündigten Fläche.

**Lokale Evidenz:** `aurora-r2-profile-menu.xml`,
`aurora-r2-profile-menu2.xml`.

### A6 — Der letzte Einstellungseintrag liegt hinter der Systemnavigation

Am Listenende bleibt die Sprachkarte teilweise hinter der Android-
Navigationsleiste. Weitere Aufwärtsgesten verändern die Position nicht. Das
trat bei 100 % und deutlicher bei 150 % Schrift auf. Bei 150 % reicht der
semantische Knoten bis y=2386, die Systemnavigation beginnt ungefähr bei
y=2273.

Der geprüfte Stand verwendet in `settings_screen.dart:2179-2181` eine
`AnimatedListView` mit festem `EdgeInsets.all(8)`. Damit wird das automatische
ListView-Padding ersetzt, ohne ausreichenden unteren Systemabstand.

#### Akzeptanz

- Letzter Eintrag ist bei 100/150/200 % vollständig über die Systemfläche
  scrollbar.
- Unteres Padding berücksichtigt `MediaQuery.viewPadding.bottom` oder eine
  `SafeArea` plus komfortablen Abschluss.
- Tests decken Drei-Tasten- und Gestennavigation ab.

**Lokale Evidenz:** `aurora-r2-settings-end.png`,
`aurora-r2-settings-font150-end.png` und die gleichnamigen XML-Dateien.

## Erneut bestätigt, bereits im ersten Bericht enthalten

- Kontaktkategorien sind bei 100 % horizontal abgeschnitten; weitere
  Kategorien werden erst durch eine nicht erklärte horizontale Geste entdeckt.
- Der Finder-FAB heißt in beiden Tabs nur „Eintrag“ statt „Ort“ oder „Ding“.
- Doppelte Semantik wie „Finder, Finder“ bleibt auf Ankerzeilen bestehen.

## Positives Muster

- Medikament-, Tagebuch-, Kontakt-, Finder- und Kalenderformulare schützen
  Änderungen konsistent über denselben Drei-Wege-Dialog.
- Leere Zustände erklären ruhig, was fehlt, und bieten einen sichtbaren FAB.
- Chat zeigt Bild und Sprechen als große, beschriftete Wege offen an.
- Die Einstellungen erklären GPS, Benachrichtigungen und Datenübertragung in
  Alltagssprache; der Befund betrifft das Listenende, nicht diese inhaltliche
  Grundstruktur.

## Empfohlene Reihenfolge für Claude

1. Notfallkontakt-Invariante und bestehende unerreichbare Kontakte behandeln.
2. Chatentwurf mit dem vorhandenen Änderungen-Schutzmuster absichern.
3. Chat-Semantik und Medienblatt gemeinsam korrigieren.
4. Profilkopf-Hitbox und untere SafeArea reparieren.
5. Bekannte Kontaktfilter- und Finder-Beschriftungsbefunde schließen.

Danach am Gerät erneut mit 100 %, 150 % und 200 % Schrift sowie TalkBack
prüfen; ein reiner Widgettest reicht für Trefferflächen und Systemleisten nicht.
