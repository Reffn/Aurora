# Codex-Gerätedurchlauf: Stress und Barrierefreiheit

**Stand:** 10. August 2026  
**Adressat:** Claude  
**Status:** Befundbericht, keine App-Implementierung durch Codex

## Prüfstand

- **Aktueller Arbeitsbaum:** Debug-APK direkt aus dem schmutzigen Arbeitsbaum
  gebaut und auf einem Samsung A14 installiert. Der Build lief mit
  `flutter build apk --debug` erfolgreich durch.
- **Vergleich:** installierter Release 3.0.18 auf einem Samsung S24.
- **Geräte:** A14, 1080×2408 bei 450 dpi; S24, 1080×2340 bei 480 dpi.
- **Zustände:** Schriftfaktor 1,0 / 1,5 / 2,0; Standort erteilt und entzogen;
  Profil mit und ohne Tageshinweis; Rückkehr aus einer tiefen Arbeitsfläche;
  leerer Notfallkontakt-Zustand.
- **Wiederhergestellt:** Beide Geräte stehen wieder auf Schriftfaktor 1,0. Die
  zuvor vorhandenen Standortrechte des A14 wurden wieder erteilt.
- **Laufzeit:** In den gefilterten Logs traten bei diesem Durchlauf weder
  `FATAL EXCEPTION` noch `E/flutter`, `RenderFlex` oder gemeldete Overflows auf.
  Das ist kein Gegenbeweis zu den unten sichtbaren Überlagerungen: Die
  betroffenen Flächen sind überwiegend `Stack`-/`Positioned`-Layouts und können
  einander verdecken, ohne einen Flutter-Overflow zu werfen.

Die lokalen Aufnahmen liegen unter `build/codex-audit-2026-08-10/`. **Nicht
committen:** Einzelne Bilder enthalten reale Profil- und Standortdaten. Die
Dateinamen unten dienen Claude nur zum lokalen Nachsehen.

## Priorität 0 — vor weiterer Oberflächenpolitur

### S1 — 200 % Schrift zerstört die Orientierungsfläche

**Belegt im aktuellen Arbeitsbaum auf dem A14.**

#### Nachstellen

1. Aktuelle Debug-APK installieren.
2. Android-Schriftgröße auf 200 % setzen.
3. Standortrecht entziehen.
4. Aurora kalt starten.

#### Beobachtung

- Datum, Uhrzeit, Ortsname und Standortbitte liegen auf der Zeitkarte
  übereinander.
- Auf der Profilauswahl werden der Profilname und „Neues Profil“ unten
  abgeschnitten. Die Rechtslinks belegen gleichzeitig den festgehaltenen
  unteren Raum.
- Nach der Profilwahl überlagern sich dieselben Inhalte auch auf dem Anker.
  „Halt“, „Notfall“ und „Hilfe“ bleiben in der getesteten Ein-Profil-Konfiguration
  erreichbar, aber die vorgeschaltete Antwort auf „Wann und wo bin ich?“ ist
  nicht mehr lesbar.
- Auf dem S24 war der Bruch mit Tageshinweis und fehlendem Standort schon bei
  150 % sichtbar: Die Profilnamen verschwanden und die Standortbitte kollidierte
  mit dem Kartenkopf.

Das ist für Aurora kein Randfall. Große Systemschrift ist gerade bei Stress,
Sehschwäche, Erschöpfung oder eingeschränkter Verarbeitung eine naheliegende
Selbsthilfe. Ausgerechnet Zeit, Ort und Identität werden dann unzuverlässig.

#### Ursache im aktuellen Aufbau

- `profile_selection_screen.dart:308-316` berechnet Karten- und Rasterhöhe mit
  festen Chrome-Zahlen und klemmt die Karte auf mindestens 150 dp. Der
  `MediaQuery.textScaler` geht nicht in die Rechnung ein.
- `time_map.dart:475-556` zeichnet Kartenkopf und Standortbitte als getrennte,
  absolut positionierte Stränge in dieselbe feste Höhe.
- `_LocationNotice` in `time_map.dart:929-980` ist eine horizontale Zeile. Bei
  großer Schrift wird ihr Erklärungstext mehrzeilig und wächst nach oben in
  den Kartenkopf.
- Kopf und Rechtslinks bleiben fest; nur die Wahl in der Mitte scrollt. Das
  schützt bei Normalgröße die Profilnamen, verhindert aber bei großer Schrift,
  dass die gesamte Fläche natürlich wachsen kann.

#### Akzeptanz

- Auf beiden Gerätehöhen sind bei `TextScaler.linear(2)` Datum, Uhrzeit, Ort und
  Standortzustand ohne Überlagerung lesbar.
- Profilname und „Neues Profil“ sind vollständig lesbar und erreichbar.
- Dieselbe Prüfung läuft mit fehlendem Standort, einem Tageshinweis und langen
  deutschen sowie spanischen Texten.
- Widgettests prüfen nicht nur `takeException()`, sondern Semantik-Bounds auf
  Überschneidung und vollständige Sichtbarkeit der entscheidenden Texte.

Ein sinnvoller Zielweg ist ein durchgehend scrollbarer Schirm bei großer
Schrift oder eine echte kompakte Zeit-/Ort-Darstellung. Schrift künstlich zu
begrenzen wäre für diese Zielgruppe keine gleichwertige Lösung.

**Lokale Evidenz:**
`aurora-a14-current-font2-no-gps.png`,
`aurora-a14-current-font2-anchor.png`,
`aurora-s24-font15-start.png`, `aurora-s24-font2-start.png`.

### S2 — „Notfall“ zeigt zuerst eine Systemberechtigung statt Hilfe

**Belegt im frisch gebauten aktuellen Arbeitsbaum.** Die bereits im Arbeitsbaum
liegende Änderung in `emergency_screen.dart`, welche das explizite
`showUserLocation: true` entfernt, behebt den Befund nicht.

#### Nachstellen

1. Standortrecht entziehen.
2. Schrift auf 150 oder 200 % setzen.
3. Profil wählen und „Notfall“ öffnen.

#### Beobachtung

- Bei 200 % füllt die GPS-Berechtigungskarte nahezu den ganzen ersten
  Bildschirm. Notfallkontakte, der Leerzustand und jede andere Hilfe liegen
  darunter.
- Bei 150 % auf dem S24 war im ersten Bildschirm ebenfalls nur die
  Berechtigungskarte zu sehen.
- Sind keine Notfallkontakte angelegt, folgt nach dem Scrollen nur die Erklärung,
  man solle Kontakte mit Kategorie „Notfall“ hinzufügen. Es gibt dort keinen
  direkten Knopf zu „Kontakt hinzufügen“, zu „Kontakte“ oder zu den 24/7-
  Anlaufstellen unter „Hilfe“.
- Die Formulierung des Alters der letzten Position ist doppelt:
  „von vor 7 Minuten“ beziehungsweise „von von gestern“.

In einer Krise ist „Notfall“ eine Zusage. Die App darf dann nicht zuerst eine
Systemaufgabe verlangen und danach in einem leeren Zustand enden. Eine Person
ohne vorbereitete Kontakte braucht mehr Hilfe, nicht weniger.

#### Ursache

- `OverviewMap.showUserLocation` ist in `overview_map.dart:133` standardmäßig
  `true`. Das bloße Entfernen des Arguments in `emergency_screen.dart:76-85`
  lässt das Verhalten deshalb unverändert.
- Die Karte steht in `emergency_screen.dart:72-87` immer vor den Kontakten.
- Der Leerzustand verweist nur textlich auf einen anderen Bereich.
- `mapLastKnownPosition` enthält bereits „von {age}“, während
  `formatPositionAge` schon „vor …“ beziehungsweise „von gestern“ liefert.

#### Akzeptanz

- Ohne Standortrecht zeigt der erste Notfall-Bildschirm zuerst eine unmittelbar
  nutzbare Hilfe: vorhandene Kontakte oder, im Leerzustand, klare Knöpfe zum
  Anlegen und zu professionellen/24h-Anlaufstellen.
- Die Standortkarte folgt danach oder ist ruhig eingeklappt. Ein fehlendes
  Standortrecht verdeckt keine Hilfe.
- Wenn die Karte hier nicht die aktuelle Position benötigt, muss
  `showUserLocation: false` ausdrücklich gesetzt und am Gerät geprüft werden.
- 150 und 200 % Schrift, null Kontakte, null Standortrecht sind eigene
  Regressionstests.
- Altersangaben lauten genau einmal „vor 7 Minuten“ beziehungsweise
  „von gestern“.

**Lokale Evidenz:**
`aurora-a14-current-font2-emergency2.png`,
`aurora-s24-font15-emergency2.png`,
`aurora-s24-font15-emergency-scroll.png`.

### S3 — Rückkehr zum Anker versteckt die drei Krisenwege

**Auf Release und aktuellem Arbeitsbaum reproduziert.**

#### Nachstellen

1. Im Anker bis „Feedback“ nach unten scrollen.
2. Feedback öffnen.
3. Den sichtbaren Anker-Knopf oben links betätigen.

#### Beobachtung

Der Anker kehrt an seine alte Scrollposition am Listenende zurück. Sichtbar sind
Kontakte, Finder, Spiele, Zeitachse und Feedback. „Halt“, „Notfall“ und „Hilfe“
liegen vollständig außerhalb des Bildes.

Das widerspricht der eigenen Zusage, dass der angebotene Schnellweg im
schlechtesten Zustand mit einem Griff auffindbar ist. Ein Mensch kann Feedback
im ruhigen Zustand öffnen und Sekunden später in einem anderen Zustand
zurückkehren; der Anker darf dann nicht voraussetzen, dass der alte Listenort
noch verstanden wird.

#### Ursache und Entscheidung

`AnchorMenu` ist in `anchor_menu_screen.dart:103-128` eine normale `ListView`
ohne explizite Rückkehrstrategie. Flutter erhält ihre Scrollposition im
bestehenden Navigationsbaum.

Claude sollte die Produktentscheidung ausdrücklich treffen:

- beim Eintritt in den Anker immer nach oben springen, **oder**
- die drei Krisenwege dauerhaft angeheftet und sichtbar halten.

Das bloße Beibehalten der Position ist für eine normale Inhaltsliste bequem,
für den zentralen Krisenanker aber die falsche Priorität.

#### Akzeptanz

Von jeder Arbeitsfläche ist „Halt“, „Notfall“ oder „Hilfe“ nach genau einem
sichtbaren Rückgriff unmittelbar erkennbar, auch wenn der Anker vorher am Ende
stand.

**Lokale Evidenz:**
`aurora-a14-current-anchor-bottom2.png`,
`aurora-a14-current-anchor-return2.png`,
`aurora-s24-anchor.png`.

## Priorität 1 — Barrierefreiheit der Bedienstruktur

### A1 — TalkBack-Semantik doppelt, leer oder ohne Zweck

Die Android-Semantik des aktuellen Builds zeigt systematische Probleme:

- Ankerzeilen heißen „Halt, Halt“, „Notfall, Notfall“, „Hilfe, Hilfe“ und ebenso
  „Finder, Finder“ usw.
- Der Info-Knopf auf der Profilauswahl ist ein klickbarer Button mit leerer
  Beschriftung.
- Die Zeitkarte auf der Profilauswahl ist als große klickbare Fläche ohne
  Beschriftung vorhanden.
- Das antippbare schnelle Zeitband auf Arbeitsflächen bildet einen leeren
  klickbaren Knoten; seine Inhalte liegen als getrennte, nicht klickbare Knoten
  daneben.
- Profilzeilen kombinieren teils Bereichstitel, Profilbeschreibung und den
  Profilnamen noch einmal. Das ergibt lange, doppelte Ansagen.

Bei kognitiver Last kostet jede Wiederholung Arbeitsgedächtnis. Ein leerer
„Button“ zwingt zum Probieren. Beides ist bei einer App für wechselnde
kognitive Zustände besonders teuer.

`AnchorRow` setzt in `anchor_row.dart:105-108` ein eigenes Semantiklabel, schließt
die Kindsemantik aber nicht aus; der sichtbare Text wird daher erneut
eingesammelt. Der Info-`IconButton` in
`profile_selection_screen.dart:567-579` hat weder `tooltip` noch eigenes
Semantiklabel. `QuickTimelineBand` macht in
`quick_timeline_band.dart:132-136` das gesamte Band per `InkWell` klickbar, gibt
dieser Handlung aber keinen Namen.

#### Akzeptanz

- Jede Ankerzeile wird genau einmal als „<Bereich>, Schaltfläche“ angesagt.
- Info heißt beispielsweise „Über Aurora“.
- Zeitkarte und Zeitband sagen sowohl Inhalt als auch Handlung, zum Beispiel
  „Zeitachse öffnen: Wechsel …“.
- Ein Semantiktest inventarisiert alle klickbaren Knoten der fünf zentralen
  Flächen und schlägt bei leerem Label fehl.
- Ein echter TalkBack-Durchgang prüft Fokusreihenfolge und Ansagen; XML allein
  ist nur der Vorfilter.

### A2 — Die Feedback-Bestätigung wiederholt sich und versteckt den Ausgang

Auf dem S24 zeigt die Bestätigungsfläche Titel und Danktext zweimal: einmal groß
und unmittelbar darunter noch einmal in einer Karte. Danach folgen
Community-Links; erst am Ende der Scrollfläche steht „Zurück zur App“. Es gibt
keinen sichtbaren Anker oder oberen Zurückknopf. Android-Zurück funktioniert,
aber dieser unsichtbare Ausweg darf nicht das erforderliche Wissen sein.

Der aktuelle Quellstand enthält die Dopplung unverändert in
`feedback_thank_you_screen.dart:47-80`; der sichtbare Rückknopf folgt erst in
`feedback_thank_you_screen.dart:132-155` hinter allen Kontaktlinks.

Nach potenziell persönlichem Feedback braucht die Person eine ruhige, eindeutige
Bestätigung und einen sofortigen Ausgang. Community-Werbung und eine doppelte
Erfolgsmeldung erhöhen hier nur die Last.

#### Akzeptanz

- Bestätigung genau einmal.
- „Zurück zu Aurora“ im ersten Bildschirm und in der normalen
  Navigationssprache der App.
- Optionale Kontaktlinks stehen danach und sind visuell nachrangig.
- Der Schirm bleibt bei 200 % les- und verlassbar.

**Lokale Evidenz:** `aurora-R3CX10FH1RP.png`.

## Produkt-/Sicherheitsentscheidung, nicht still nebenbei ändern

### D1 — Exakte Standortspur steht vor jeder Profilwahl

Bei vorhandenem Standortrecht zeigt die Profilauswahl vor jeder Anmeldung eine
präzise Karte mit Weg, aktuellem Marker und benanntem Ort. Das hilft einer
desorientierten Person unmittelbar. Gleichzeitig kann jede Person mit dem
entsperrten Gerät diese Gesundheits-/Aufenthaltsinformation sehen, bevor ein
Profil oder Passwort gewählt wurde.

Das ist ein echter Zielkonflikt zwischen Orientierung und lokaler Vertraulichkeit.
Er sollte nicht durch ein beiläufiges UI-Fix entschieden werden. Denkbare
Abstufung: Zeit und grober aktueller Ort vor der Wahl; genaue Spur erst nach
Profilwahl oder hinter „Weg anzeigen“. Passwortgeschützte Profile aus der Spur
zu entfernen genügt nicht, wenn schon die verbleibende Route sensible Orte
offenlegt.

Die zugehörigen Screenshots enthalten reale Standortdaten und bleiben deshalb
bewusst außerhalb dieses Dokuments.

## Bestätigt offen aus älteren Berichten

- „Halt“ verwendet auf der Arbeitsfläche weiter generische Material-Symbole;
  „Körper spüren“ trägt das Android-Barrierefreiheitssymbol. Der bereits als B12
  geführte Bildsprachbruch ist im aktuellen A14-Build weiterhin sichtbar.
- Die großen Flächen selbst blieben in diesem Durchlauf bei 100 % stabil und
  erzeugten keine gefilterten Laufzeitfehler.

## Noch nicht als Bug einstufen

- Der Debug-Build blieb auf dem A14 bei Kaltstarts sichtbar mehrere Sekunden im
  nativen Splash. Einmal war der Splash nach sechs Sekunden noch sichtbar und
  die Profilauswahl spätestens nach vierzehn Sekunden da. Debug-Start, GPS und
  Initialisierung verfälschen das. Vor einer Einstufung bitte in einem
  Profile-/Release-Build `time-to-first-interaction` mehrfach messen.

## Empfohlene Reihenfolge für Claude

1. S1 als responsive Grundkorrektur samt 150-/200-%-Regressionstests.
2. S2 so umbauen, dass menschliche/professionelle Hilfe vor GPS steht; dabei
   den wirkungslosen Default-Parameter-Fix korrigieren.
3. S3 entscheiden und mit einem Navigationstest absichern.
4. A1 als Semantikpass über gemeinsame Komponenten beheben, nicht pro Schirm.
5. A2 vereinfachen.
6. D1 mit dem Nutzer als bewusste Produktentscheidung klären.

## Status

**Umsetzung:** S1, S2, S3, A1, A2 behoben — siehe
`docs/superpowers/plans/2026-08-10-codex-stress-und-barrierefreiheit.md`.
D1 am 10. August 2026 bewusst entschieden: Die Spur bleibt vor der
Profilwahl stehen; Begründung in `docs/oberflaechen-richtlinien.md`.
Offen aus älteren Berichten: B12 (Bildsprachbruch bei „Halt"), Startdauer im
Release-Build messen.

## Nebenbefunde aus der Umsetzung

Während der Behebung der fünf Befunde S1–A2 kamen drei zusätzliche Mängel zutage,
die nicht in der ursprünglichen Audit enthalten waren:

### 1. OverviewMap: Überlauf bei 150 % Systemschrift

**Nachweis:** A14 bei 150 % Systemschrift und 200 dp Kartenhöhe: ca. 2 px Überlauf.
S24 vergleichbar. Der Kartenkopf und die `LocationNotice` (Standortbitte) 
wachsen über die verfügbare Höhe hinaus.

**Betroffene Komponente:** `lib/modules/grounding/widgets/map_view.dart` bzw. 
`OverviewMap` als generisch genutzter Kartenpanel.

**Auswirkung:** Auf Orientierungsflächen und in der Notfall-Anzeige werden 
wichtige Inhalte überlagert, wenn die Nutzerin große Schrift wählt.

**Status:** Nicht behoben.

### 2. ContactFormScreen: Überlauf bereits bei 100 % Systemschrift

**Nachweis:** Viewport 360 dp bei Normalgröße. RenderFlex-Überläufe in 
`contact_form_screen.dart:379` (262 px) und `:463` (31 px). Zusätzlich: 
Farbkontrast-Warnung für eine ListTile.

**Betroffene Komponente:** `lib/modules/contacts/contact_form_screen.dart`

**Auswirkung:** Dies ist die Fläche, auf der jemand Notfallkontakte eingibt — 
eine sicherheitskritische Handlung wird durch Layout-Probleme blockiert. Der 
Überlauf tritt bereits ohne Systemschrift-Vergrößerung auf.

**Status:** Nicht behoben.

### 3. OverviewMap: Architektur-Verletzung (behoben)

**Nachweis:** `OverviewMap` las in `lib/modules/grounding/widgets/map_view.dart` 
Hive-Boxen direkt in der `build()`-Methode, um Kontakte und Finder-Orte zu laden.
Dies umging die `DataEntry`-Architektur völlig und ignorierte die von Aufrufern
übergebenen Parameter `contacts` und `finderLocations`.

**Auswirkung:** Jede Oberfläche, die eine Karte enthält, wurde unten nur mit
den globalen, nicht mit den gefilterten Daten testbar, und die Komponente
verleugnete den Dependency-Injection-Ansatz des Projekts.

**Status:** **Behoben** während der Umsetzung von S2/S3, weil die Fehlerlosigkeit
der Oberflächen-Tests davon abhing.

