# Reichweite: der Play-Eintrag findet seine Leute nicht

Datum: 13.08.2026 · Abgefragt über die Play Developer API (nur gelesen, nichts
veröffentlicht).

Ausgangslage: 92 Installationen, 24 monatlich aktive Geräte. Bevor irgendwo
getrommelt wird, muss die Stelle tragen, auf die getrommelt wird — jeder Beitrag
in einem Forum, jeder Hinweis einer Therapeutin endet im Play-Eintrag.

## Was schon da ist

**Der Eintrag ist vollständig fünfsprachig.** de-DE, en-US, es-ES, fr-FR,
it-IT, jeweils mit eigenem Titel, Kurz- und Langbeschreibung. Das ist keine
Selbstverständlichkeit und es ist bereits bezahlte Arbeit.

## Befund 1: Die App spricht die Sprache der Community, der Eintrag nicht

Aurora selbst schreibt **„Anteil"** — im Onboarding („Jeder Anteil bekommt ein
eigenes Profil"), im Datenmodell, in den Kommentaren.

Der deutsche Play-Eintrag schreibt durchgehend **„Persönlichkeiten"**. Das Wort
„Anteil" kommt in 3775 Zeichen **kein einziges Mal** vor.

Das ist die Trennlinie zwischen innen und außen: „Persönlichkeiten" ist das
Wort der Lehrbücher und der Boulevardpresse. „Anteile" ist das Wort, das
Betroffene über sich selbst benutzen — und damit das Wort, das sie in das
Suchfeld tippen. Wer im Eintrag „Persönlichkeiten" liest, hört jemanden über
sich reden. Wer „Anteile" liest, hört jemanden, der dazugehört.

## Befund 2: „Trauma" fehlt in allen fünf Sprachen

In keinem der fünf Texte steht das Wort. Es ist der am stärksten benachbarte
Suchbegriff überhaupt — die meisten Menschen finden zur Diagnose über das
Trauma, nicht umgekehrt, und die Selbsthilfelandschaft ist unter „Trauma"
organisiert, nicht unter „DIS".

## Befund 3: „plural" fehlt überall — und das ist die größte Lücke im Englischen

Die englischsprachige Community nennt sich **plural**. Die größte existierende
App heißt *Simply Plural*. Wer dort sucht, sucht mit diesem Wort.

Im englischen Eintrag fehlen außerdem: `alter`, `alters`, `headmate`,
`fronting`, `dissociation`, `CPTSD`. Vorhanden sind `DID`, `OSDD`, `system`,
`switch`, `grounding` — der Kern stimmt also, die Umgangssprache fehlt.

Das deckt sich mit einem Befund aus der Übersetzungsprüfung: auch die englische
Oberfläche schreibt 24-mal „part" und **null-mal „alter"**, während Spanisch,
Französisch und Italienisch durchgehend „alter" benutzen. Englisch ist innen wie
außen die Sprache, die den Community-Begriff nicht führt.

## Befund 4: Zwei Abkürzungen fehlen, und Abkürzungen sind das, was getippt wird

- **Spanisch** führt `TID`, nicht `TDI`. Beide Formen sind im Umlauf
  (*Trastorno de Identidad Disociativo* / *Trastorno Disociativo de la
  Identidad*). Wer die andere tippt, findet nichts.
- **Italienisch** führt `DID` (die englische Abkürzung), nicht `DDI`
  (*Disturbo Dissociativo dell'Identità*). Ein italienischer Suchender tippt
  `DDI`.
- **Deutsch** führt `DIS`, aber nicht `DDNOS` und nicht die Nomenform
  `Dissoziation` — nur das Adjektiv „dissoziativ".

## Befund 5: Vier Einträge verschenken je 1500 bis 1900 Zeichen

| Sprache | Zeichen gesamt | Play erlaubt | ungenutzt |
|---|---|---|---|
| de-DE | 3775 | 4000+ | ~200 |
| fr-FR | 2474 | | ~1500 |
| it-IT | 2327 | | ~1650 |
| es-ES | 2319 | | ~1650 |
| en-US | **2147** | | **~1850** |

Die vier nicht-deutschen Einträge sind gekürzte Fassungen. Play durchsucht die
gesamte Langbeschreibung — der ungenutzte Platz ist genau der Ort, an dem die
fehlenden Begriffe stehen könnten, ohne dass irgendwo gestopft werden müsste.

**Am wenigsten Text hat ausgerechnet Englisch** — die Sprache mit der mit
Abstand größten Community.

## Was zu tun ist

Keine Schlagwortliste anhängen. Play straft das ab, und es liest sich, wie es
gemeint ist. Stattdessen die vier kurzen Einträge auf die Länge des deutschen
bringen und dabei die fehlenden Begriffe dort unterbringen, wo sie ohnehin
hingehören — in Sätzen, die etwas sagen.

**Deutsch**, ein Satz, der drei Lücken auf einmal schließt:

> Aurora ist für Systeme gemacht — für alle Anteile, die sich einen Alltag
> teilen. Ob die Diagnose DIS heißt, DDNOS, oder ob bisher nur feststeht, dass
> nach einem Trauma Zeit fehlt: die App fragt nicht nach einem Befund.

**Englisch**, derselbe Gedanke in der Sprache der Community:

> Aurora is built for plural systems — for every alter sharing one life. DID,
> OSDD, or no diagnosis at all: the app never asks for a label. Track fronting
> and switches, keep notes between headmates, and find your way back after
> dissociation or a gap in time.

Für Spanisch, Französisch und Italienisch dasselbe Muster, jeweils mit **beiden**
umlaufenden Abkürzungen (`TID`/`TDI`, `DDI`/`DID`).

## Erledigt am 13.08.2026 — alle fünf Einträge neu

Über die Play Developer API geschrieben und zurückgelesen. Sicherung der alten
Fassungen liegt vor der Änderung als JSON und als fünf Textdateien.

**Ein Befund kam erst beim Umschreiben ans Licht:** der deutsche Eintrag war
eine Generation älter als der englische. Er beschrieb Emoji-Abschnitte,
„Persönlichkeiten" und eine **Kamera-/Galerie-Berechtigung, die Aurora seit der
Ablehnung von 3.0.15 nicht mehr anfordert**. Anker, Halt, Notfall, Hilfe,
Rechte je Profil und Zeitstrahl fehlten vollständig. Der englische Text war die
gute Vorlage — er wurde zur Grundlage für alle fünf.

Neue Titel und Kurzbeschreibungen:

| | Titel | Kurz |
|---|---|---|
| de | Aurora – Alltag mit DIS | Für Systeme und ihre Anteile: Halt, Tagebuch, Erinnerungen, interner Chat. |
| en | Aurora – Plural, with DID | For plural systems and their alters: grounding, diary, reminders, inner chat. |
| es | Aurora – Plural, con TID | Para sistemas plurales y sus alters: anclaje, diario, recordatorios, chat. |
| fr | Aurora – Pluriel, avec un TDI | Pour les systèmes pluriels et leurs alters : ancrage, journal, rappels, chat. |
| it | Aurora – Plurale, con il DDI | Per i sistemi plurali e i loro alter: radicamento, diario, promemoria, chat. |

Die Begriffsprobe läuft jetzt in allen fünf Sprachen ohne Lücke durch.

**Ein Rückschritt, den die Probe gefunden hat**, bevor er live ging: die erste
Fassung führte nur noch die Abkürzungen und hatte die **ausgeschriebenen
Krankheitsnamen** fallen gelassen. Wer „dissoziative Identitätsstörung" oder
„trouble dissociatif de l'identité" eintippt, hätte nichts mehr gefunden.
Nachgetragen in allen fünf.

**Was ich bewusst nicht getan habe:** die Texte auf 4000 Zeichen aufblasen. Sie
liegen jetzt bei 2376 bis 2740. Der freie Platz ist kein Ziel — er wäre nur mit
Füllung zu schließen, und das ist genau das Schlagwortstopfen, vor dem oben
gewarnt wird. Relevanz schlägt Länge.

**Was ein Mensch nachlesen sollte:** die spanische, französische und
italienische Fassung sind von mir geschrieben, nicht von Muttersprachlern
geprüft. Die Begriffe stimmen, der Klang gehört gegengelesen.

## Warum das der erste Hebel ist

Es kostet keinen Code, keinen Release und keine Freigabe. Es wirkt auf jeden
Kanal gleichzeitig — auf die Suche in Play genauso wie auf jeden Menschen, den
ein Forumsbeitrag hierher schickt. Und es ist das einzige Stück Reichweite, das
sich ohne Rückkanal messen lässt: Play zeigt Suchbegriffe und Conversion.

Ein Forumsbeitrag erreicht einmal ein paar Dutzend Menschen. Der Eintrag steht
jeden Tag da.
