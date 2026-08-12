# Oberflächen-Richtlinien

**Gilt für die ganze App. Stand: 5. August 2026.**

Aurora wird von Menschen mit Dissoziativer Identitätsstörung benutzt — oft in
Zuständen, in denen Lesen, Auswählen und Erinnern schwerfallen. Diese Regeln
sind aus veröffentlichter Forschung abgeleitet, nicht aus Geschmack. Jede
nennt ihre Quelle. Wer eine Regel bricht, soll das begründen können.

---

## 1. Zwei Orte, nie beide gleichzeitig

Es gibt den **Anker** (Auswahl) und eine **Arbeitsfläche** (Inhalt). Man ist
entweder hier oder dort.

Kein Karussell, keine Wischgeste ins Unsichtbare, keine dritte Ebene über dem
Inhalt. Der Weg zurück ist immer dasselbe Ankersymbol links in der Kopfzeile,
und die Zurück-Taste des Geräts tut dasselbe.

> „Hidden navigation menus that rely on non-standard swipes turn simple tasks
> into puzzles." — Smashing Magazine, 2026

## 2. Wahlfläche ist nicht Arbeitsfläche

Die großen Zeilen des Ankers gelten für **Wahlflächen**: eine feste,
überschaubare Menge gleichrangiger Ziele.

Sie gelten **nicht** für Inhalt: Chat, Kalender, Tagebuch, Medikamente,
Zeitachse, Finder zeigen Daten, keine Auswahl. Und sie gelten nicht für
unbegrenzte Listen — fünfzig Kontakte in 110-dp-Zeilen sind zwei Meter
Scrollstrecke.

Prüffrage: *Ist die Menge fest und überschaubar?* Nur dann Zeilen.

## 3. Gruppen statt flacher Listen

Mehr als etwa fünf Einträge werden gruppiert: Überschrift, Abstand, sichtbare
Trennung.

Nichts wird dabei versteckt. COGA empfiehlt zwar, über fünf Optionen hinaus
ein „Mehr"-Fach anzubieten — für uns ist das der Rückfall ins
Karussell-Problem: Unsichtbar ist unauffindbar. Wir gruppieren, statt zu
verbergen.

> „A web page with chunks of content run together in a *flat design* can be
> challenging for users with cognitive disabilities … losing all the benefits
> of chunking content." — W3C COGA

## 4. Sättigung hat eine Aufgabe

Kräftige Farbflächen sind für das reserviert, was im schlechtesten Zustand
gefunden werden muss. Alles andere ist ruhig: dunkle Fläche, Farbe nur als
Streifen oder im Symbol.

Ein Schirm voller gesättigter Flächen zeigt nichts mehr an, weil alles
gleich laut ist — und er widerspricht der Stimmung, in der er geöffnet wird.

> „Users in distress show a strong preference for subtlety … cheerful, bright
> colours … can create a jarring, even physically uncomfortable conflict with
> their current mood." — Health Informatics Journal, 2024

Im Anker heißt das: **Halt, Notfall, Hilfe** tragen volle Farbe. Die neun
anderen Bereiche tragen ihre Farbe als Marke.

## 5. Das Bild trägt, das Wort bestätigt

Jede Handlung ist ohne Lesen erkennbar. Symbol links, groß; Wort daneben.
Nie ein Symbol allein, nie ein Wort allein.

Gezeichnete, halbabstrakte Darstellungen schlagen reduzierte Strichsymbole,
und beide schlagen Fotos (Medhi u. a., Microsoft Research India). Vertraute
Symbole werden nicht neu erfunden — neue Bedienlogik kann oft nicht erlernt
werden (W3C COGA).

> „Abstract, unlabeled icons force users to guess rather than recognise."
> — Smashing Magazine, 2026

## 6. Größen und Kontrast sind Untergrenzen, keine Ziele

- Bedienziele mindestens **24×24 px** (WCAG 2.2). Wir nehmen **110 dp** Höhe,
  weil die Norm ausdrücklich „more for unsteady hands" sagt und unruhige
  Hände hier der Normalfall sind.
- Fließtext **4,5:1**, große Schrift und Bedienelemente **3:1**.
- Farbe auf dunklem Grund wird angehoben, bis sie trägt
  (`AnchorRow.onDark`) — nicht in Originalsättigung übernommen.

## 7. Reihenfolge ist eine Zusage

Nichts wird nach Häufigkeit umsortiert. Was gestern an dritter Stelle stand,
steht morgen an dritter Stelle. Wer sich an Orte statt an Namen erinnert,
verliert sonst den Ort.

> „Mental health often relies on routine and predictability … a novel
> interaction pattern … asks the user to learn something before they can act."
> — Smashing Magazine, 2026

## 8. Jede Geste hat einen sichtbaren Knopf

Wischen, Ziehen, langes Drücken dürfen Abkürzungen sein, nie der einzige Weg.

## 9. Zustände werden angeboten, nicht erkannt

Kein automatisches Vereinfachen nach vermutetem Zustand. Das widerspricht der
Vorhersehbarkeit — und bei uns zusätzlich der Zusage, nichts über den Menschen
zu sammeln.

Die richtige Form ist der **angebotene Schnellweg**: „Halt" steht oben und ist
mit einem Griff erreichbar, weil die Person ihn wählt, nicht weil die App
etwas über sie zu wissen glaubt.

## 10. Formulare sagen, was passiert

Aus den Postern des UK Home Office für Menschen mit Angst:

- Nach dem Absenden sagen, **was jetzt passiert** und wie lange es dauert
- Vor Folgen **warnen, bevor** die Handlung ausgelöst wird
- **Prüfen lassen**, bevor abgeschickt wird
- **Keine Zeitdruck-Grenzen**
- Hilfe leicht erreichbar halten

Dazu: kein Ablauf ohne Ausgang. Wer eine Übung oder ein Formular nicht zu
Ende bringen kann, findet einen sanften Weg heraus („Später weiter"), nicht
nur „Abbrechen".

## 11. Bewegung zeigt etwas oder entfällt

Animation ist erlaubt, wenn sie die Sache selbst zeigt — eine Atemübung, die
vormacht, wann eingeatmet wird. Nicht erlaubt sind Belohnungsschleifen,
Konfetti und nicht überspringbare Feiermomente: Wer nur eine Sache erledigen
will, muss sich durch sie hindurcharbeiten.

`prefers-reduced-motion` beziehungsweise die Systemeinstellung wird beachtet.

---

## Prüffragen vor jedem neuen Schirm

1. Ist das eine Wahlfläche oder eine Arbeitsfläche?
2. Wie viele Einträge? Über fünf → gruppieren.
3. Was davon muss im schlechtesten Zustand gefunden werden? Nur das ist
   farbig.
4. Ist jede Handlung ohne Lesen erkennbar?
5. Gibt es genau einen sichtbaren Rückweg?
6. Liegt etwas außerhalb des Schirms, das man nicht durch Scrollen erreicht?
7. Ändert sich die Reihenfolge je nach Nutzung? Dann ist sie falsch.
8. Bei Formularen: Steht dort, was nach dem Absenden passiert?

---

## Quellen

- Kat Homan, „Designing For Distressed Users: Why Mental Health Apps
  Shouldn't Follow Every UI Fashion", Smashing Magazine, Juli 2026.
  https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/
- W3C, „Use a Clear and Understandable Page Structure", COGA Design Pattern.
  https://www.w3.org/WAI/WCAG2/supplemental/patterns/o2p03-page-structure/
- W3C, „Making Content Usable for People with Cognitive and Learning
  Disabilities". https://www.w3.org/TR/coga-usable/
- W3C, „Web Content Accessibility Guidelines 2.2".
  https://www.w3.org/TR/WCAG22/
- UK Home Office, „Designing for users with anxiety".
  https://ukhomeoffice.github.io/accessibility-posters/anxiety
- Farbe und Ästhetik in mHealth-Anwendungen, Health Informatics Journal 2024.
  https://journals.sagepub.com/doi/10.1177/14604582241295948
- Medhi u. a., „Text-Free User Interfaces for Illiterate and Semi-Literate
  Users", Microsoft Research India.
  https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/medhi_ictd2006.pdf
- SAMHSA, sechs Prinzipien trauma-informierter Versorgung.

---

## Abgleich vom 6. August 2026: neue Forschung gegen den Stand der App

Zwei Recherchen (Kognition/Stress; Trauma/DIS) wurden gegen die elf Regeln
und einen vollständigen Emulator-Durchlauf abgeglichen. Ergebnis in drei
Stufen; erledigte Punkte wandern hier raus.

### Neu erkannte Schwächen

1. **„Wer bin ich gerade?" fehlte auf den Arbeitsflächen.** Front-Status in
   ≤1 Griff, überall — de-facto-Standard der Plural-Apps (Simply Plural,
   Octocon) und Konsequenz aus Amnesie als Normalfall. *Behoben am 06.08.:
   `WorkSurfaceScaffold` zeigt Avatar mit Farbring und Namen unter dem
   Bereichstitel.*
2. **Telemetrie-Einwilligung ist systemweit, nicht anteilsbezogen.** Ein
   Anteil stimmt zu, andere erfahren es wegen Amnesie nie (Eggleston 2025;
   Consent-Forschung für kognitiv belastete Gruppen). Mindestens muss der
   Consent-Status für jeden Anteil ohne Suchen sichtbar sein.
3. **Rechte-Sperren sind „errorful" statt „errorless".** Deaktivierte
   Einträge, die bei Berührung eine Fehlermeldung werfen, widersprechen dem
   Errorless-Learning-Prinzip der Gedächtnisrehabilitation: richtige Handlung
   anbieten, Fehlerpfad gar nicht erst entstehen lassen.
4. **Entwürfe überleben das Verlassen nicht.** Session-Kontinuität
   (Demenz-Co-Design-Studien): Wer zurückkehrt, findet den Zustand von
   vorher — für Switches mitten in der Handlung fast Kernfunktion
   („dein ungesendeter Entwurf ist noch da, von Alex, 14:02").
5. **Kein Symbol wurde je auf Verständlichkeit getestet.** ISO 9186:
   ≥66,7 % einer Stichprobe müssen ein Piktogramm ohne Wort korrekt deuten.
   Prüfverfahren ist billig: 15 Personen, Symbol ohne Beschriftung zeigen.
6. **„Wann bin ich" war unbeantwortet.** Zeitverlust gehört zum
   Krankheitsbild: Ein Anteil kommt nach vorn und weiß nicht, welcher Tag
   ist. Die Systemleiste zeigt nur die Uhrzeit. Reorientierung arbeitet mit
   Zeit, Ort und Person — die App beantwortete nur die letzten beiden.
   *Behoben am 06.08.: Anker UND Profilauswahl tragen Wochentag, Datum und
   Tagesphase als Wort („Donnerstag, 6. August · morgens") — morgens und
   abends sind auf einer Uhr verwechselbar, als Wörter nicht. Darunter
   „was dieser Tag trägt": Termine und Medikamente gelten dem Körper,
   nicht dem Anteil — als bloße ZAHLEN stehen sie deshalb schon auf der
   Profilauswahl, für jeden Anteil, bevor jemand gewählt hat. Inhalte
   (Titel, Uhrzeiten, Präparate) erscheinen erst nach der Wahl und mit den
   Rechten des Profils: Die Profilauswahl sieht auch ein Dritter mit dem
   Gerät in der Hand, und der Medikamentenplan ist das sensibelste Datum
   der App. Ein leerer Tag erzeugt Stille, nicht „0 Termine".*
   Offen als nächste Stufe: „zuletzt warst du vor drei Tagen hier" je
   Anteil — angeboten, nicht aufgedrängt, weil die Antwort auch
   erschrecken kann.

   **Geändert am 7. August 2026: Der Ort steht auf der Profilauswahl.**
   Hier stand vorher das Gegenteil — Standortabfrage vor dem ersten Griff
   sei derselbe Fehler wie beim Notfall-Schirm. Die Regel fällt, und zwar
   aus dem Zweck der Fläche heraus: Wer gerade hochkommt, muss sich
   orientieren, *bevor* er wählt. Reorientierung arbeitet mit Zeit, Ort und
   Person; lägen zwei davon hinter der Anmeldung, käme die Antwort zu spät
   für die Frage. Die Karte ist deshalb keine Zutat vor der Wahl, sondern
   ihr Vorlauf.

   Was dadurch nicht erlaubt wird: Ortsdaten verlassen das Gerät weiterhin
   nicht (Koordinaten gehen ausschließlich für Karte und Geokodierung an
   OpenStreetMap), und Inhalte, die einen Anteil verraten — Termintitel,
   Präparate, Alter —, bleiben hinter der Wahl. Ein Dritter mit dem Gerät
   in der Hand sieht einen Ort und eine Uhrzeit, keine Krankengeschichte.

### Durch die Forschung bekräftigt (bereits bekannt)

- Farbe wird unter kognitiver Last schneller erkannt als jedes Symbol — der
  Farb-Token-Umbau (Signalfarben von Identitätsfarben trennen) bleibt der
  wichtigste strukturelle Schritt.
- Überlagerungen dürfen kritische Handlungen nie verdecken (Turk & Hutchings,
  CHI 2023) — der Standort-Systemdialog über dem Notfall-Schirm verletzt das.
- Wort + Symbol wird signifikant schneller erkannt als das Symbol allein
  (ebd.) — betrifft den Anker-Rückweg und die Doodle-Werkzeugleiste.
- Höchstens 5–7 gleichzeitige Wahlmöglichkeiten (Hick) — die Werkzeugleiste
  der Zeichenfläche liegt darüber, und ihr oberster Knopf wechselt die
  Bedeutung (verletzt Regel 7).
- Eine gut lesbare eigene Schrift (Atkinson Hyperlegible) ist weiterhin
  nicht eingebunden.

### Offene Prüfpunkte

- Grounding-Bereich: sensorisch und vormachend (PTSD-Coach-Evidenz:
  Atem-Animationen schlagen Anleitungstext) oder textlastig?
- Respektiert jeder Schirm die Systemschrift-Vergrößerung (`textScaler`)?
- Nirgends Schuld-Rahmung („nicht geschafft", „versäumt")?
- Tagebuch/Notizen: Sichtbarkeit pro Anteil steuerbar (Octocon-Vorbild)
  oder alles ungefragt geteilt?

### Neu aufgenommene Quellen

- Eggleston u. a., „A Scoping Review of Trauma-Informed Care Principles
  Applied in Design and Technology", Digital Health, 2025.
  https://journals.sagepub.com/doi/10.1177/20552076251360925
- Turk & Hutchings, „Click Here to Exit: An Evaluation of Quick Exit
  Buttons", ACM CHI 2023. https://dl.acm.org/doi/fullHtml/10.1145/3544548.3581078
- PTSD Coach: Machbarkeits- und Wirksamkeits-Metaanalyse, 2023.
  https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10215014/
- ISO 9186:2014, Verständlichkeitstest für graphische Symbole.
  https://www.iso.org/standard/59226.html
- „Inclusive Design of Pictograms for Intellectual Disabilities",
  Visible Language. https://journals.uc.edu/index.php/vl/article/view/5976
- Errorless Learning in der Gedächtnisrehabilitation (Übersicht, Springer
  2008; Anwendung JMIR/PMC10525938).
- NHS England, „Digital Accessibility Standards".
  https://www.england.nhs.uk/long-read/digital-accessibility/
- Trauma-Informed Design Society, Framework 2025. https://www.tidsociety.com/
- Simply Plural und Octocon als de-facto-Standards der Plural-Community
  (Front-Status, anteilsgenaue Privatsphäre, Amnesie-sicheres Protokoll).
- Einwilligungs-Forschung für kognitiv belastete Gruppen: PMC5911394;
  Captain Compliance, „Accessible Privacy", 2024.

## Zeitkarte: Durchlauf am Gerät, 6. August 2026

Szenario, am Emulator durchgespielt: Mina war drei Stunden vorn, ist von
zuhause zum Edeka und zurück gegangen; Lina kommt hoch und weiß nicht, wo sie
ist. In fünfzig Minuten ist ein Arzttermin.

### Was die Fläche jetzt beantwortet

Reorientierung arbeitet mit Zeit, Ort und Person. Alle drei stehen ohne einen
Schritt auf dem Anker:

- **Zeit** — Wochentag, Datum, Uhrzeit oben am Vergangenheitsstrang.
- **Ort als Bild** — die Lauflinie mit Zeiten daran („vor einer Stunde"). Sie
  beantwortet Befund 6 auch räumlich: nicht nur *wann* war ich, sondern *wo*.
- **Ort als Wort** — die Adresse der jüngsten Position unter dem Datum. Sie
  liegt ohnehin lokal vor, die Rückwärts-Geokodierung läuft beim Aufzeichnen.
  Ohne sie hinge alles an Kartenkacheln, und wer an einem fremden Ort
  hochkommt, ist mit einiger Sicherheit in einer Gegend, die noch nie geladen
  wurde.
- **Person** — der aktive Anteil steht in der Titelzeile, ständig sichtbar
  auch beim Scrollen (Befund 1). Der Weg trägt die Farbe dessen, der ihn
  gegangen ist.
- **Wer in der Nähe ist** — Kontakte mit hinterlegter Adresse stehen auf der
  Karte und führen zu Nummer, Notiz und Bewertung. Erst hinter der Anmeldung:
  Es ist die Adresse eines anderen Menschen.
- **Was als Nächstes** — der nächste Termin als Zeile am Zukunftsstrang, mit
  Uhrzeit und Weg zum Detailschirm.

### Was dabei aufgefallen ist und offen bleibt

1. ~~**Die Zeitangabe ist zu grob für ihren eigenen Zweck.**~~ *Behoben:*
   „Vor einer Stunde" galt von sechzig bis hundertneunzehn Minuten — eine
   halbe Stunde Unschärfe für die Frage „wie lange war ich weg", die sich
   beim Hochkommen als Erstes stellt. Bis sechs Stunden zurück stehen jetzt
   die Minuten dabei („vor 1 Std 35 Min"), auf fünf gerundet, weil eine
   Messung im Zwei-Minuten-Takt keine Minutengenauigkeit trägt. Darüber
   bleibt es grob: Bei einer tagealten Position ist die Rundung richtig.
2. ~~**Marker haben keinen Vorrang untereinander.**~~ *Behoben:* Der Stapel
   folgt jetzt der Dringlichkeit statt der Reihenfolge, in der die Blöcke
   geschrieben wurden — Wechsel zuunterst (wer wann vorn war, steht schon im
   Zeitstrang), darüber Orte, darüber Kontakte, darüber der Standort, zuoberst
   die Zeiten. Der Behelf, Wechselmarken auf kleinen Karten abzuschalten, ist
   damit entfallen.
3. ~~**Kein Weg zum Termin.**~~ *Behoben:* Der nächste Termin mit Ort steht
   als Punkt auf der Karte, und eine gestrichelte Luftlinie führt vom Standort
   dorthin. Gestrichelt, weil sie kein Weg ist, sondern Richtung. Keine Route:
   Die müsste einen fremden Dienst fragen, und dabei verließen Start *und*
   Ziel das Gerät — der ganze Weg eines Menschen. Nur hinter der Anmeldung,
   denn ein Termin trägt Titel und Adresse.

   Zwei Dinge kamen erst am Gerät heraus. Erstens: Den Kartenausschnitt so zu
   weiten, dass das Ziel hineinpasst, macht die Fläche unbrauchbar — bei fünf
   Kilometern Entfernung war keine Straße mehr zu lesen. Der Ausschnitt bleibt
   deshalb beim Nahbereich, die Linie läuft aus dem Bild, und wie weit es ist,
   steht als Entfernung an der Terminzeile („11:23 · Arzttermin · 4,4 km").
   Zweitens: Die helle Linie ging auf hellgrauen Straßenkacheln unter — sie
   hat jetzt dieselbe dunkle Fassung wie der zurückgelegte Weg.
4. **Wetter fehlt** — offen, und bewusst nicht nebenbei gebaut. Regen in zwei
   Stunden, Hitze, Kälte entscheiden mit, ob man jetzt losgeht. Aber Wetter
   ist automatischer Netzverkehr, der an Koordinaten hängt, und damit fällt es
   unter dieselbe Regel wie Telemetrie: **Einwilligung vorher, Vorgabe aus.**
   Was dazugehört, bevor eine Zeile Code entsteht:
   - Ein eigener `TransmissionChannel.weather` — jede Abfrage muss in „Was
     Aurora sendet" auftauchen, sonst gäbe es einen Kanal an der Transparenz
     vorbei.
   - Koordinaten auf zwei Nachkommastellen gerundet (rund ein Kilometer). Der
     Test dazu prüft die Nutzlast, nicht die Absicht.
   - Ein Schalter in den Einstellungen, aus als Vorgabe, mit demselben
     Wortlaut-Anspruch wie die Telemetrie-Einwilligung.
   - Open-Meteo braucht keine Anmeldung und kein Schlüsselwort — also keine
     Konstante, die im Release leer wäre.
5. **Keine Karte ohne Netz** — offen. Gecachte Kacheln decken die gewohnte
   Gegend ab, nicht die fremde; genau in der fremden kommt man hoch. Der Ort
   als Wort ist die Notlösung und steht. Die eigentliche wäre eine
   Vorab-Ladung: `CircleRegion` je gespeichertem Ort, Zoom 13–16, über die
   FMTC-Download-API, ausgelöst in den Einstellungen und nicht von selbst —
   sie kostet Netz und Speicher, also entscheidet das die Nutzerin. Ohne
   Fortschrittsanzeige und Abbruch wäre es eine Blackbox; deshalb ist es ein
   eigener Durchgang und kein Nebenher.
6. ~~**Kein „zuletzt warst du hier vor X" je Anteil.**~~ *Behoben:* Unter
   jedem Namen auf der Profilauswahl steht klein und farblos, wann dieser
   Anteil zuletzt vorn war. Angeboten, nicht aufgedrängt — die Antwort kann
   erschrecken. Für Anteile mit Passwort steht dort nichts: Diese Fläche sieht
   auch ein Dritter mit dem Gerät in der Hand.

   **Abgleich 10. August 2026 — genaue Standortspur vor der Profilwahl.**
   Der Codex-Durchlauf hat den Zielkonflikt benannt: Vor jeder Anmeldung zeigt
   die Karte Weg, aktuellen Marker und benannten Ort; jede Person mit dem
   entsperrten Gerät sieht das. `hidePasswordProtected` hilft dagegen nicht —
   die verbleibende Route legt selbst sensible Orte offen.

   Entschieden am 10. August 2026: Es bleibt, wie es ist. „Wo war ich?" nach
   einem Blackout ist Kernnutzen und braucht die Spur, nicht nur den Punkt. Wer
   das Gerät entsperrt hat, hat ohnehin Zugriff auf mehr. Die Abwägung ist
   bewusst getroffen und nicht beiläufig durch ein Oberflächen-Fix entstanden.
