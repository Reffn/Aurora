# Aurora im Abgleich mit dem Forschungsstand zur DIS

**Stand:** 2026-08-04
**Zweck:** Vollständige Bestandsaufnahme. Was die App heute ist, was die Wissenschaft zur
Behandlung dissoziativer Identitätsstörungen sagt, wo beides zusammenpasst und wo nicht.
**Status:** Analyse, keine Entscheidung. Die Arbeit daran läuft über mehrere Sessions; dieses
Dokument ist der gemeinsame Nenner, auf den jede Session zurückgreift.
**Nicht enthalten:** Umsetzungsplanung. Jedes Teilprojekt in Teil IV bekommt seine eigene Spec.

---

# Teil I — Der Stand der App

## I.1 Architektur

Flutter-App, ausschließlich lokale Datenhaltung in Hive. Kein Cloud-Sync.

```
UI/Module → DataEntry → EventBus → Services → Hive
                ↓
          Validierung, Logging, Events
```

- `lib/core/data_entry.dart` — zentrale API für alle Lese- und Schreibvorgänge
- `lib/core/event_bus.dart` — RxDart-basierte Ereignisverteilung
- `lib/core/di/injection.dart` — GetIt, alle Services als Singletons
- 24 Services, u. a. `profile_service`, `chat_service`, `diary_service`,
  `medication_service`, `timeline_data_service`, `location_tracking_service`,
  `emergency_message_service`, `password_reset_service`, `transmission_log_service`
- Eigene Lint-Regeln in `dis_app_lints/` erzwingen das DataEntry-Muster

Navigation in vier Schichten: AppBar, ProfileSwitcherBar, CarouselTabNavigator, PageView.
Tabs werden anhand der Rechte des aktiven Profils gefiltert; der Chat-Tab ist immer sichtbar.

## I.2 Das zentrale Datenmodell: `Profile`

Ein Profil bildet einen Anteil ab. Felder:

| Feld | Bedeutung |
|---|---|
| `id`, `nameRaw`, `avatarPath` | Identität. Name ist UTF-16-normalisiert über `runes` |
| `preferredColorValue`, `colorPickerPositionX/Y` | Farbe als primäres Erkennungsmerkmal |
| `age` | steuert altersabhängige Rechte-Voreinstellungen |
| `description` | Freitext |
| `isAdmin` | **überschreibt jede Rechteprüfung**: `hasPermission` gibt für Admins immer `true` |
| `permissions` | Liste von Permission-Namen |
| `preferredLanguage` | für das Übersetzungs-Feature |
| `isActive` | deaktivierte Profile werden ausgeblendet |
| `passwordHash` | bcrypt, Cost 12, mit SHA-256-Legacy-Pfad |
| `resetCode`, `pendingPasswordHash`, `securityQuestions`, `securityAnswersHashed` | Passwort-Wiederherstellung über Sicherheitsfragen und 24-Stunden-Timer |
| `hasSeenPostLoginWelcome` | Onboarding-Stufe 3 |

**Wichtig für die Bewertung:** Ein Profil ist technisch ein vollwertiges Benutzerkonto mit
eigenem Passwort, eigenen Sicherheitsfragen, eigenem Wiederherstellungspfad und eigenen Rechten.

## I.3 Die Module

| Tab | Was es tut |
|---|---|
| **Chat** | Interner Chat zwischen Profilen. Text, Doodle, Sprachnachricht, Bild, Video. Immer sichtbar |
| **Kalender** | Termine mit Anhängen und Kommentaren |
| **Medikamente** | Medikationsliste, Einnahmezeiten, Einnahmebestätigung, Kommentare. Einnahmen sind körperbezogen, nicht profilbezogen |
| **Tagebuch** | Einträge mit Titel, Beschreibung, Bildern, Priorität (`low`…`critical`) und Stimmung (`veryHappy`, `happy`, `neutral`, `sad`, `verySad`, `anxious`, `angry`, `excited`). Kommentierbar, teilbar |
| **Kontakte** | Kontaktkartei mit Bewertungen und Kommentaren |
| **Finder** | Orte und Gegenstände wiederfinden. Kommentierbar |
| **Notfall** | Notfallkontakte und Hotlines. `EmergencyMessageService` erzeugt eine SMS im Format „Ich brauche Hilfe, hier ist [Profilname]. Ich befinde mich: [GPS + über Nominatim aufgelöste Adresse]. Kannst du mich bitte anrufen." Versand per SMS an einzelne oder alle Kontakte, alternativ über Share-Intent (WhatsApp, Telegram). Direktanruf für Kontakte und Hotlines |
| **Hilfe** | Ressourcen- und Linkliste |
| **Mantras** | Mantra-Sammlung |
| **Spiele** | Schiebepuzzle und Jigsaw-Puzzle |
| **Zeitachse** | Profilwechsel-Historie und GPS-Tracking-Daten. Recht ist als `dangerous` markiert |
| **Feedback** | Rückkanal an die Entwicklung. Zurzeit im Umbau (siehe I.6) |
| **Einstellungen / Mehr** | Konfiguration, „Was Aurora sendet" |

Weitere Modelle: `ProfileSwitchEvent` (id, fromProfileId, toProfileId, timestamp, latitude,
longitude), `LocationHistoryEntry`, `NotificationQueueEntry`, `TransmissionLogEntry`,
`Hotline`, `ContactRating`, diverse Kommentartypen.

## I.4 Das Rechtesystem

56 Permissions in neun Kategorien (`system`, `chat`, `calendar`, `medication`, `diary`,
`contacts`, `finder`, `emergency`, `security`). Zwölf davon sind als `dangerous` markiert.

Die systemkritischen: `createProfiles`, `deactivateProfiles`, `managePermissions`,
`accessSettings`.

Rechte, die auf Daten anderer Anteile wirken: `deleteAllMessages`, `editAllEvents`,
`deleteAllEvents`, `overrideMedicationLog`, `viewAllDiaries`, `editAllDiaryEntries`,
`deleteAllDiaryEntries`, `resetPasswords`, `viewTimelineTab`.

`Profile.hasPermission()` gibt für `isAdmin == true` immer `true` zurück — es gibt keine
Möglichkeit, einem Admin ein Recht zu entziehen.

## I.5 Die Privacy-Haltung

Drei Regeln, in `CLAUDE.md` festgeschrieben:

1. Nichts wird ohne ausdrückliche Zustimmung gesendet. Feedback ist nutzerausgelöst und braucht
   deshalb kein Opt-in; Telemetrie wäre automatisch und braucht daher eines
2. Alles Gesendete ist in den Einstellungen unter „Was Aurora sendet" wortgleich einsehbar und
   wird lokal protokolliert
3. Nichts erlaubt eine Re-Identifikation: keine Profil-IDs, keine Installations-IDs, keine
   Sitzungsketten, keine Eintragszahlen

Standortdaten erreichen die Entwicklung nie — weder im Feedback noch gerundet noch als Land.
Koordinaten gehen ausschließlich an OpenStreetMap für Karten und Geokodierung; die
Notfallfunktion teilt den Standort mit selbst gewählten Kontakten. Ein Test prüft, dass das
Payload-Schema kein Standortfeld enthält.

Zusätzlich festgehalten: keine Compile-Zeit-Konstanten für Transportziele. Ein leerer
`const` löscht den Codepfad still — das hat den Feedbackkanal einmal acht Monate lang tot
liegen lassen. Der CI-Release-Build schlägt fehl, wenn kein Transport konfiguriert ist.

## I.6 Was gerade im Bau ist

Branch `feature/feedback-rueckkanal`. Der GitHub-Meldepfad wurde vollständig entfernt, der
Rückkanal läuft jetzt über E-Mail-Transport. Offene Arbeitsstände: `bottom_action_bar.dart`
(neu, noch nicht versioniert), Änderungen an `profile_creation_screen`,
`profile_identity_section`, `timeline_event_symbol`.

---

# Teil II — Der Forschungsstand

## II.1 Der Behandlungsrahmen

Konsens ist die **phasenorientierte Behandlung**, formuliert in den ISSTD-Leitlinien und 2025
erstmals systematisch reviewt:

1. **Sicherheit, Stabilisierung, Symptomreduktion**
2. **Bearbeitung traumatischer Erinnerungen**
3. **Integration und Rehabilitation**

Die Reihenfolge ist nicht dekorativ. Traumakonfrontation vor ausreichender Stabilisierung
destabilisiert. Für eine App ohne therapeutische Begleitung ist ausschließlich Phase 1
vertretbar.

Neben der phasenorientierten Behandlung gelten als vielversprechend: kognitive
Verhaltenstherapie, dialektisch-behaviorale Therapie, Schematherapie und das Unified Protocol.
Die Evidenzbasis insgesamt ist dünn — acht Studien mit auswertbaren Ergebnisdaten zeigen
Symptomreduktion bei Depression, Angst und dissoziativen Symptomen.

## II.2 Die digitale Evidenz

Der mit Abstand relevanteste Befund für ein Projekt wie Aurora:

**TOP DD Network** (Brand et al.) — ein web-basiertes psychoedukatives Programm für 111
Betroffene mit DIS oder anderen komplexen dissoziativen Störungen, international rekrutiert.
Bestandteile: Videos, Texte, Verhaltensübungen. Inhalte: Emotionsregulation, Umgang mit
Sicherheitsproblemen, Symptomreduktion.

Ergebnisse nach ein und zwei Jahren:

- Rückgang von Dissoziation und PTBS-Symptomen
- Verbesserte Emotionsregulation
- Höhere Anpassungsfähigkeit
- Effektstärken von 0,44 bis 0,90
- Deutlicher Rückgang nicht-suizidaler Selbstverletzung, **am stärksten bei den zuvor am
  stärksten selbstverletzenden Teilnehmenden**
- Stärker dissoziierte Personen verbesserten sich **schneller**, nicht langsamer

Die qualitative Nachuntersuchung von 2024 fragte, was aus Sicht der Teilnehmenden gewirkt hat.
Drei Themen: Programmbestandteile (Inhalt und Struktur), veränderungsfördernde Prozesse
(erlebte menschliche Verbundenheit, äußeres Mitgefühl, „zu etwas Größerem beitragen",
verbesserte therapeutische Arbeit und Beziehung) und Ergebnisse (Einsicht, Hoffnung,
Selbstmitgefühl, Sicherheit, Funktionsfähigkeit).

**Der Wirkmechanismus war Psychoedukation und Schamreduktion, nicht Datenerfassung.** Das ist
für Aurora die wichtigste einzelne Aussage dieses Berichts.

Das Nachfolgeprogramm **Finding Solid Ground** (Brand, Lanius u. a.) hat in einer randomisierten
kontrollierten Studie Einzeltherapie allein übertroffen, mit großen Effektstärken nach einem
Jahr. Aufbau:

- **Grounding zuerst** — ausdrücklich als notwendige erste Stufe, bevor der Rest des Programms
  überhaupt greifen kann
- Fertigkeitenbasiert: praktische Bewältigungs- und Erdungswerkzeuge zur Krisenreduktion und
  Verbesserung der Alltagsfunktion
- Psychoedukation zu Dissoziation, Triggern und Nervensystem — reduziert Scham, erhöht
  Selbstwahrnehmung
- Anteile-informiert: nutzt die Theorie der strukturellen Dissoziation und normalisiert die
  innere Trennung als Überlebensanpassung
- Ziel: Sicherheit, Selbstregulation und **kooperatives Funktionieren zwischen den Anteilen**,
  bevor Erinnerungsarbeit beginnt

Berichtete Ergebnisse: bessere Alltagsfunktion, weniger Krisenereignisse, stärkere
Therapiebeteiligung, mehr Nutzung von Erdungsfertigkeiten, geringere Inanspruchnahme von
Notfalldiensten.

## II.3 Die Risikolage

- Bis zu **86 %** der Betroffenen berichten eine Vorgeschichte nicht-suizidaler Selbstverletzung
- Bis zu **72 %** unternehmen im Lebensverlauf einen Suizidversuch
- **1 bis 2,1 %** versterben durch Suizid
- Die Raten liegen höher als bei den meisten anderen psychiatrischen Patientengruppen

Treiber sind schlechte Funktionsfähigkeit, schwere dissoziative Symptomatik, traumabedingt
verzerrte Kognitionen und komplexe Posttraumasymptomatik. Sicherheitsplanung gilt als Best
Practice; die Fachliteratur bezeichnet Kompetenz im Umgang mit Sicherheitsproblemen als
Voraussetzung für die Arbeit mit dieser Gruppe.

**Grounding-Techniken** dienen ausdrücklich dazu, Dissoziation, Flashbacks, **Switching**,
Panikattacken und Selbstverletzung zu verhindern, abzuschwächen oder umzulenken — durch
Sinnesansprache und nicht-destruktive Beschäftigung des Denkens. Körperbezogene Verfahren wie
Eis halten, kaltes Wasser oder festes Aufsetzen der Füße erzeugen unmittelbare Gegenwärtigkeit.

## II.4 Das Prinzip der ganzen Person

Die ISSTD-Leitlinien sind an dieser Stelle ungewöhnlich deutlich:

> Die behandelnde Person muss im Blick behalten, dass die Klientin oder der Klient **ein Mensch
> mit vielen Anteilen** ist, und darf nicht mit der Dissoziation kollaborieren, indem sie
> unnötige Ausarbeitung oder Autonomie von Anteilen fördert.

Und wörtlich als kontratherapeutisch bezeichnet:

> Es ist kontratherapeutisch, der Person nahezulegen, zusätzliche Anteile zu erschaffen, Anteile
> zu benennen, die keine Namen haben (obwohl die Person selbst Namen wählen darf, wenn sie
> möchte), oder nahezulegen, dass Anteile eigenständiger und ausgearbeiteter funktionieren, als
> sie es ohnehin schon tun.

Zur Sprache: Die Begriffe der betroffenen Person sollen übernommen werden — es sei denn, ein
Begriff verstärkt die Überzeugung, die Anteile seien **getrennte Personen** statt eines
Menschen mit subjektiv geteilter Identität.

Das ist kein Argument gegen Respekt vor der inneren Erfahrung. Es ist ein Argument gegen
Werkzeuge, die Trennung härter machen, als sie ohnehin ist.

## II.5 Diagnostik: was sich geändert hat

**ICD-11** hat *partielle dissoziative Identitätsstörung* (6B65) eingeführt: nicht-dominante
Persönlichkeitszustände treten nur gelegentlich und vorübergehend hervor, etwa bei erhöhter
Belastung oder im Zusammenhang mit selbstverletzendem Verhalten, ohne wiederkehrend die
Kontrolle über Bewusstsein und Funktionsfähigkeit zu übernehmen.

**Amnesie ist in ICD-11 typisch, aber nicht mehr zwingend** — eine konzeptuelle Abkehr von
ICD-10 und DSM-5, wo Amnesie notwendiges Kriterium ist.

Prävalenz der Vollform: die meisten Studien zwischen 0,1 % und 2 %, einzelne Schätzungen bis
3–5 %. DSM-5-TR nennt eine 12-Monats-Prävalenz von 1,5 % in einer kleinen US-Stichprobe.

Praktische Folge: Die Mehrheit der Betroffenen liegt im unscharfen Bereich — partielle DIS,
OSDD-1, wenig ausdifferenzierte oder unbenannte Anteile, Co-Fronting, Blending. Nicht bei klar
getrennten, benannten, voneinander amnestischen Anteilen.

## II.6 Wie Systeme sich selbst organisieren

PLOS One 2025, gemeinschaftsbasiertes partizipatives Design, 15 interviewte transgender und
plurale Systeme, ausdrücklich nicht-pathologisierender Blick. Drei Themen: der Kontext des
Konflikts, kollektive Entscheidungsprozesse, Lösungen die systemweite Harmonie fördern.

Beschriebene Praxis: **interne Treffen** als bewusst geschaffener Raum, in dem widersprüchliche
Sichtweisen ausgesprochen werden. Manche Systeme frei und formlos, andere strukturiert mit
festen Rollen. Ein Zitat aus der Studie:

> „Wir haben sehr intensive Treffen, bevor wir eine Entscheidung über den Körper treffen. Wir
> haben Verantwortliche für verschiedene Bereiche, die herumgehen und die Leute in ihrem
> Bereich fragen … und dann kommen alle Verantwortlichen zusammen und teilen, was sie gesammelt
> haben."

Beteiligung war unterschiedlich stark, aber Einbeziehung war den Systemen wichtig — sie
bemühten sich, so viele Mitglieder wie möglich zu beteiligen.

Der für Aurora entscheidende Befund steht in der Diskussion:

> Ungleiche Entscheidungsfindung sollte nicht dadurch verstärkt werden, dass ein einzelnes
> Systemmitglied bevorzugt oder mit unilateralen Entscheidungen betraut wird. Wenn von außen
> einem Systemmitglied Macht über die übrigen gegeben wird, entmachtet das alle anderen
> Mitglieder und das System als Ganzes. Ressentiment und Negativität gegenüber anderen
> Mitgliedern sind die Folge und können die inneren Beziehungen beschädigen und weiteren
> Streit auslösen.

Die Studie zieht die Parallele zur Familientherapie: Behandelnde sollen nicht Partei für ein
Familienmitglied ergreifen, sondern die Beziehungsgesundheit des ganzen Systems als
Behandlungsgegenstand betrachten.

Grenze der Studie: Die Stichprobe war online rekrutiert und daher wahrscheinlich überrepräsentativ
für Systeme, die interne Kommunikation bereits gut hinbekommen.

---

# Teil III — Der Abgleich

## III.A Was trägt

**Der Phase-1-Fokus stimmt.** Kein Modul rührt an Traumaerinnerungen. Es gibt keine
Expositionsübung, keine Erinnerungsarbeit, keinen Traumafragebogen. Für eine App ohne
therapeutische Begleitung ist das die einzig vertretbare Position, und sie ist eingehalten.

**Der interne Chat trifft ins Zentrum.** „Kooperatives Funktionieren zwischen den Anteilen"
ist das erklärte Ziel von Phase 1 und der Kern von Finding Solid Ground. Aurora hat dafür
einen vollwertigen Kanal mit Text, Zeichnung, Sprache, Bild und Video. Zeichnung und
Sprachnachricht sind besonders wertvoll: Anteile, die nicht schreiben können oder wollen —
Kinderanteile, präverbale Anteile — bekommen einen Ausdrucksweg.

**Die Amnesie-Brücken sind konzeptionell stark.** Tagebuch, Kalender, Kommentare und
insbesondere der Finder arbeiten direkt gegen Zeitverlust und Erinnerungslücken. Das ist die
funktionell schwerste Alltagsbelastung bei DIS, und sie ist in der App ernstgenommen. Der
Finder — „wo habe ich das hingelegt, wo war ich" — ist eine Funktion, die man nur baut, wenn
man das Problem verstanden hat.

**Die Medikation ist körperbezogen gelöst.** Ein Einnahmelog, das über Anteilsgrenzen hinweg
gilt, verhindert Doppeleinnahme. Das ist ein real dokumentiertes Sicherheitsproblem bei DIS
und hier sauber adressiert.

**Stimmungserfassung im Tagebuch** existiert bereits (acht Stimmungen plus vierstufige
Priorität). Das ist die Rohform dessen, was in Teil III.B unter Triggererkennung fehlt.

**Notfallkontakte und Hotlines** sind angesichts der Zahlen aus II.3 keine Zusatzfunktion,
sondern notwendige Grundausstattung. Vorhanden, mit Direktanruf und vorbereiteter Nachricht.

**Die lokale Datenhaltung ist angemessen.** DIS-Daten sind gleichzeitig Gesundheitsdaten,
Traumadaten und Identitätsdaten. Die drei Privacy-Regeln sind strenger als das, was rechtlich
verlangt wäre, und das ist hier richtig.

**Der Ton ist nicht-pathologisierend.** Das deckt sich mit der Richtung der partizipativen
Forschung und mit dem, was Betroffene an digitalen Werkzeugen schätzen.

## III.B Was fehlt

Sortiert nach Stärke der zugrundeliegenden Evidenz.

---

### B1 — Grounding und Stabilisierungsfertigkeiten

**Befund:** Nicht vorhanden.

**Beleg:** Der Baustein mit der besten Evidenz im gesamten Feld. Finding Solid Ground nennt
Grounding ausdrücklich als notwendige erste Stufe, ohne die der Rest nicht greift. Die RCT
zeigt große Effektstärken. Grounding wirkt laut Literatur unter anderem **gegen Switching
selbst**, nicht nur gegen dessen Folgen.

**App-Stand:** Es gibt Mantras und Spiele. Beides ist kein Ersatz. Spiele sind Ablenkung durch
Absorption — Absorption ist der Mechanismus der Dissoziation, nicht ihr Gegenmittel. Ob
Puzzles erdend oder dissoziogen wirken, ist nicht untersucht. Mantras sind statischer Text,
ohne Übungsführung, ohne Körperbezug, ohne Orientierungsanteil.

**Was fehlt konkret:** Orientierung im Hier und Jetzt (heutiges Datum, Ort, Alter des Körpers,
„es ist vorbei"), 5-4-3-2-1 über die Sinne, körperbezogenes Grounding, Container-Übungen,
geführte Notfall-Skills.

**Konsequenz:** Größte Lücke der App, gemessen an dem, was nachweislich hilft.

---

### B2 — Sicherheitsplan und Krisenpfad

**Befund:** Es gibt Notfallkontakte, aber keinen Sicherheitsplan.

**Beleg:** Bis 72 % Suizidversuche, bis 86 % Selbstverletzung im Lebensverlauf.
Sicherheitsplanung ist etablierte Best Practice.

**App-Stand:** Das Notfallmodul kann Kontakte anzeigen, anrufen und eine vorbereitete SMS mit
Standort verschicken. Das ist der letzte Schritt einer Eskalation — die Stufen davor fehlen
vollständig.

**Was fehlt konkret:** Ein strukturierter Plan nach dem etablierten Muster — Warnzeichen,
eigene Bewältigungsschritte, Ablenkung, Menschen ansprechen, Fachhilfe, Mittel sichern. Dazu
DIS-spezifisch: Der Plan muss von **dem Anteil** lesbar und nutzbar sein, der gerade fronted —
und der hat womöglich keine Erinnerung daran, ihn geschrieben zu haben. Ebenfalls
Phase-1-Standard und nicht abgebildet: **Sicherheitsabsprachen zwischen Anteilen**.

---

### B3 — Triggererkennung aus vorhandenen Daten

**Befund:** Die Rohdaten liegen bereits vor und werden nicht ausgewertet.

**Beleg:** Switching ist triggergesteuert. Triggeridentifikation ist Kern von Phase 1 und
expliziter Inhalt von Finding Solid Ground („Wissen über Dissoziation, Trigger und
Nervensystem reduziert Scham und erhöht Selbstwahrnehmung").

**App-Stand:** `ProfileSwitchEvent` speichert bei jedem Wechsel Vorgänger, Nachfolger,
Zeitstempel und GPS-Koordinaten. Das Tagebuch erfasst Stimmung und Priorität. Der Kalender
weiß, was an dem Tag anstand. Aus alldem entsteht nichts. Die Zeitachse zeigt die Ereignisse,
deutet sie aber nicht.

**Konsequenz:** Aktuell ist der Switch-Log ein Protokoll über die Person statt eines Werkzeugs
für sie. Größter Hebel bei kleinstem Aufwand — allerdings mit der Datenschutzfrage aus B11
verschränkt.

---

### B4 — Die Wir-Ebene

**Befund:** Es gibt keine Ebene, die den einen geteilten Körper abbildet.

**Beleg:** ISSTD-Prinzip der ganzen Person (II.4). Ziel von Phase 1 ist kooperatives
Funktionieren, nicht getrennte Verwaltung.

**App-Stand:** Aurora modelliert Anteile als vollständig getrennte Benutzerkonten — eigenes
Passwort, eigene Sicherheitsfragen, eigener Wiederherstellungspfad, eigene Rechte, eigenes
Tagebuch, das andere ohne Recht nicht lesen dürfen. Technisch ist das ein
Betriebssystem-Mehrbenutzermodell. Es kodiert maximale Trennung als Grundannahme.

**Was fehlt konkret:** Gemeinsames Wissen über den Körper, das keinem Anteil gehört —
Allergien, Diagnosen, Ausweisdokumente, Blutgruppe, laufende Behandlungen, Termine die dem
Körper gehören. Dazu: gemeinsame Vereinbarungen, gemeinsame Ziele, ein Ort für das, was alle
wissen sollen. Die Medikation ist bereits körperbezogen — aber als rechtegesteuertes Modul
getarnt statt als geteilte Realität benannt.

---

### B5 — Psychoedukation

**Befund:** Keine strukturierten Inhalte.

**Beleg:** Genau das war der Wirkmechanismus im TOP-DD-Programm. Die qualitative Auswertung
nennt Einsicht, Selbstmitgefühl und Hoffnung als Ergebnisse — erzeugt durch Wissen, nicht durch
Verwaltung.

**App-Stand:** Der Hilfe-Tab ist eine Ressourcen- und Linkliste.

**Was fehlt konkret:** Was ist Dissoziation. Warum gibt es Anteile — strukturelle Dissoziation
als Überlebensanpassung, normalisierend und schamreduzierend. Was passiert beim Switchen. Was
tun bei Zeitverlust. Was ist ein Trigger. Warum Erdung hilft. In einer Form, die im
dissoziativen Zustand konsumierbar ist, also nicht als Fließtext.

---

### B6 — Die Brücke zur Behandlung

**Befund:** Die App ist ein geschlossener Kreis.

**Beleg:** DIS-Behandlung ist Langzeitpsychotherapie. Das TOP-DD-Programm wirkte ausdrücklich
*zusammen mit* Behandelnden; „verbesserte therapeutische Arbeit und Beziehung" war eines der
benannten Wirkprinzipien.

**App-Stand:** Kein Sitzungsexport, keine Möglichkeit festzuhalten „das will jemand in der
Therapie ansprechen", keine Struktur für Übungen zwischen den Sitzungen, kein Weg, dass die
behandelnde Person etwas hineingibt.

**Konsequenz:** Verschenkter Multiplikator — und zugleich der sicherste Weg, auf dem eine App
überhaupt Wirkung entfalten kann, weil sie die Verantwortung nicht allein trägt.

---

### B7 — Der Einstieg setzt voraus, dass man weiß, wer man ist

**Befund:** Der Zugang läuft über Profilauswahl plus Passwort.

**Beleg:** Im dissoziativen Zustand weiß die Person häufig gerade **nicht**, wer fronted. Das
ist nicht ein Randfall, sondern die Kernerfahrung der Störung.

**App-Stand:** `profile_selection_screen` → Passwort → App. Die Passwortschranke blockiert
genau den Moment, in dem die App am dringendsten gebraucht wird. Wer nach einem Zeitverlust
aufwacht und nicht weiß, welcher Tag ist, muss zuerst wissen, wer er ist und wie sein Passwort
lautet.

**Was fehlt konkret:** Ein identitätsfreier Einstieg vor jeder Anmeldung — heutiges Datum,
Uhrzeit, was heute passiert ist, wer zuletzt aktiv war, Erdungsübung, Sicherheitsplan,
Notfallkontakte. Erreichbar ohne zu wissen, wer man ist.

---

### B8 — Kein Modell für Unschärfe

**Befund:** Aurora kennt nur diskrete, benannte, passwortgeschützte Profile.

**Beleg:** ICD-11 hat partielle DIS eingeführt, Amnesie ist nicht mehr zwingendes Kriterium.
Die Mehrheit der Betroffenen liegt im unscharfen Bereich.

**App-Stand:** Ein Profil anlegen erzwingt einen Namen. Es gibt genau einen aktiven Anteil zu
jedem Zeitpunkt. Nicht abbildbar: unbenannte Anteile, Fragmente, Co-Fronting, Blending, „ich
weiß nicht, wer das gerade ist", passiver Einfluss ohne Kontrollübernahme.

**Zusatzproblem:** Die ISSTD-Leitlinien nennen es kontratherapeutisch, Anteile zu benennen, die
keine Namen haben. Die App erzwingt genau das bei jedem Anlegen.

---

### B9 — Dissoziationsspezifische Bedienbarkeit ist nicht abgesichert

**Befund:** Problembewusstsein vorhanden, nichts davon verbindlich.

**Beleg:** Im dissoziativen Zustand: verschwommenes Sehen, verlangsamte Verarbeitung,
Leseschwierigkeit, Derealisation, Zeitverlust mitten in einer Handlung.

**App-Stand:** Die Designnotiz „Text trägt nicht — jede Handlung ohne Lesen bedienbar, Farbe
als Trennung" zeigt, dass das Problem erkannt ist. Verbindlich geprüft wird nichts: kein
maximaler Klickpfad zur Krise, keine Regel gegen zeitkritische Interaktionen, keine
Leseanforderungsgrenze, kein Zustand „Formular halb ausgefüllt, Person weg".

---

### B10 — Kein Umgang mit dem Übergang selbst

**Befund:** Ein Profilwechsel wird protokolliert, aber nicht begleitet.

**Beleg:** Der Moment des Switchens ist der Moment höchster Desorientierung.

**App-Stand:** `ProfileSwitchEvent` wird geschrieben, danach steht der neue Anteil auf dem
zuletzt genutzten Tab.

**Was fehlt konkret:** Eine Übergabe. Was war zuletzt los, was ist offen, was ist heute noch
zu tun, gibt es eine Nachricht für dich. Das ist die Stelle, an der die vorhandenen
Amnesie-Brücken zusammenlaufen müssten — und es gibt keine Stelle.

---

### B11 — GPS im Switch-Protokoll

**Befund:** Wechselhistorie plus Koordinaten ergibt eine Karte davon, wer wann wo war.

**Beleg:** Bei DIS besteht häufig fortdauernder Kontakt zu Personen aus dem Gewaltkontext, teils
mit Gerätezugriff.

**App-Stand:** `ProfileSwitchEvent.latitude/longitude`, dazu `LocationHistoryEntry` und
`location_tracking_service`. Die Privacy-Regel „Standort verlässt das Gerät nie" schützt gegen
Übertragung — nicht gegen Zugriff auf dem Gerät. `viewTimelineTab` ist zurecht als `dangerous`
markiert.

**Offene Frage:** Warum werden Wechselorte überhaupt gespeichert, und wer soll sie sehen? Der
Nutzen (Triggererkennung, siehe B3) und das Risiko liegen in derselben Datenspalte.

**Verwandt:** Die Notfall-SMS enthält den Namen des gerade frontenden Anteils. Der Kontakt
erfährt damit, wer gerade da ist — eine Offenlegung, die möglicherweise nicht immer gewollt ist.

---

### B12 — Kein Schutz gegen fremden Gerätezugriff

**Befund:** Profil-Passwörter schützen Anteile voreinander, nicht die Person vor Dritten.

**App-Stand:** Wer das Gerät entsperrt hat, sieht die Profilauswahl mit allen Namen und
Avataren. Die App heißt Aurora und beschreibt sich in der Notfall-SMS selbst als „Alltagsbegleiter
bei Dissoziativer Identitätsstörung".

**Offene Frage:** Braucht es einen Tarnmodus, eine unauffällige Darstellung, eine Ausblendung?
Das ist keine rein technische, sondern eine Sicherheitsentscheidung mit Abwägung gegen
Bedienbarkeit im Krisenfall (B7 will weniger Hürden, B12 will mehr).

---

## III.C Was gegen das Ziel arbeitet

Die drei Punkte in diesem Abschnitt sind keine Lücken, sondern vorhandene Entscheidungen, die
laut Forschungsstand in die falsche Richtung wirken.

---

### C1 — Unilaterale Admin-Macht

`Profile.hasPermission()` gibt für Admins bedingungslos `true` zurück. Ein Admin-Profil kann:

| Recht | Wirkung |
|---|---|
| `deactivateProfiles` | einen anderen Anteil ausblenden |
| `resetPasswords` | einen anderen Anteil aussperren oder sich Zugang verschaffen |
| `managePermissions` | anderen Anteilen Rechte entziehen |
| `viewAllDiaries` | alle Tagebücher lesen |
| `deleteAllDiaryEntries` | Tagebucheinträge anderer unwiderruflich löschen |
| `deleteAllMessages` | Nachrichten anderer löschen |
| `overrideMedicationLog` | Einnahmebestätigungen anderer zurücksetzen |
| `viewTimelineTab` | sehen, wann andere Anteile wo waren |

Die Studie von 2025 sagt dazu wörtlich, dass unilaterale Entscheidungsmacht eines
Systemmitglieds alle anderen und das System als Ganzes entmachtet und interne Beziehungen
beschädigt.

**Das ist kein Argument gegen Schutzrechte.** Kinderanteile vor Notrufen, Finanzen,
Löschfunktionen oder Kontaktaufnahme zu schützen ist klinisch sinnvoll und gehört zu dem, was
Systeme ohnehin selbst regeln. Es ist ein Argument gegen **unilaterale Durchsetzung ohne
Aushandlung, ohne Sichtbarkeit und ohne Widerruf** — und gegen unwiderrufliche Aktionen
gegen andere Anteile.

Besonders zu prüfen:

- **`deactivateProfiles`.** Anteile lassen sich nicht deaktivieren. Der Versuch, sie zu
  unterdrücken, ist ein bekannter Krisenauslöser. Die App bietet dafür einen Knopf.
- **`deleteAllDiaryEntries` und `deleteAllMessages`.** Erinnerungen anderer Anteile
  unwiderruflich zu löschen ist der Mechanismus der Störung selbst, nachgebaut als Feature.
- **`resetPasswords`.** Aussperren durch einen anderen Anteil.

Was der Forschungsstand stattdessen nahelegt: ausgehandelte, sichtbare, widerrufbare
Systemvereinbarungen mit Protokoll — nach dem Muster der internen Treffen aus II.6.

---

### C2 — Maximale Trennung als Grundannahme

Siehe B4. Getrennte Passwörter, getrennte Sicherheitsfragen, getrennte
Wiederherstellungspfade, getrennte Tagebücher und Rechte pro Anteil bauen mehr Autonomie
zwischen Anteilen auf, als die Leitlinien für vertretbar halten.

Die Gegenposition ist ernstzunehmen und muss in der Designentscheidung auftauchen: Privatsphäre
zwischen Anteilen ist ein realer Bedarf, gerade wenn ein Anteil etwas trägt, das andere noch
nicht wissen sollen. Die Frage ist nicht ob, sondern wie viel Trennung als Voreinstellung
gesetzt wird und ob die App die Zusammenführung genauso gut unterstützt wie die Trennung.
Derzeit unterstützt sie nur die Trennung.

---

### C3 — Die Begrifflichkeit — **umgesetzt am 2026-08-04**

Permission-Texte und Modell-Kommentare sagten durchgehend „Persönlichkeiten" —
`createProfiles`: „Neue Persönlichkeiten in der App anlegen", `overrideMedicationLog`:
„Bestätigungen anderer Persönlichkeiten ändern".

Klinisch etabliert im deutschsprachigen Raum ist *Anteile* oder *Persönlichkeitsanteile*.
„Persönlichkeiten" verstärkt genau die Lesart getrennter Personen, vor der die Leitlinien
warnen. Die App spricht bei jedem Anlegen mit — das ist keine Kosmetik.

Zugleich gilt die Leitlinienregel, die Begriffe der betroffenen Person zu übernehmen. Eine
mögliche Auflösung: die App fragt beim Onboarding, wie das System sich selbst nennt, und
verwendet diese Sprache durchgehend, mit *Anteile* als Voreinstellung statt *Persönlichkeiten*.

**Umgesetzt:** Alle 14 Fundstellen in `lib/` auf *Anteil* umgestellt — Onboarding-Texte in
`app_de.arb` und `app_en.arb` („personality" → „part"), sämtliche Permission-Beschreibungen,
Modell- und Screen-Kommentare. Die abfragbare Selbstbezeichnung beim Onboarding ist damit
**nicht** erledigt und bleibt offen.

---

# Teil IV — Teilprojekte

Jedes Teilprojekt bekommt seine eigene Spec. Diese Liste ist Landkarte, nicht Plan.

### TP1 — Grounding und Stabilisierung — **umgesetzt, 2026-08-05**
Neues Modul. Orientierung im Hier und Jetzt, sensorische Übungen, körperbezogenes Grounding,
Container, Atem. Gezeichnete Bildfolge, kein Ton nötig, kein Lesen nötig, nichts gespeichert.
*Deckt:* B1. *Abhängigkeiten:* keine. *Risiko:* niedrig, rein additiv.
*Berührt:* Umwidmung des leeren Mantras-Tabs zum Bereich „Halt", immer sichtbar.
*Design:* `docs/superpowers/specs/2026-08-04-grounding-modul-design.md`
*Plan:* `docs/superpowers/plans/2026-08-04-grounding-modul.md`
*Stand:* Fünf Übungen laufen auf Branch `feature/grounding-modul`, 87 Tests, Abschlussreview
sauber. Offen bleibt allein der Bildersatz — Emoji zeigen Gegenstände, keine Handlungen; das
Modul läuft solange mit dem Symbol der jeweiligen Übung. Damit ist **B1 geschlossen** und der
Weg zu TP2 frei, dem der Grounding-Inhalt bisher fehlte.

### TP2 — Krisenpfad und Sicherheitsplan
Strukturierter Sicherheitsplan, für jeden Anteil lesbar. Plus identitätsfreier Einstieg vor
dem Login mit Orientierung, Erdung, Plan und Notfallkontakten.
*Deckt:* B2, B7, teilweise B10. *Abhängigkeiten:* profitiert stark von TP1.
*Risiko:* hoch — greift in Auth und Notfallmodul ein, höchste Stakes.

### TP3 — Übergabe beim Wechsel
Der Moment nach dem Switch: was war los, was ist offen, gibt es eine Nachricht für dich.
*Deckt:* B10, verbindet die vorhandenen Amnesie-Brücken.
*Abhängigkeiten:* keine harten. *Risiko:* mittel.

### TP4 — Machtmodell und Systemvereinbarungen
Umbau von unilateraler Admin-Macht zu ausgehandelten, sichtbaren, widerrufbaren
Vereinbarungen. Entfernung unwiderruflicher Aktionen gegen andere Anteile.
*Deckt:* C1, teilweise C2. *Abhängigkeiten:* keine. *Risiko:* hoch — tiefer Eingriff in
bestehende Rechteprüfung, Migration bestehender Profile nötig.

### TP5 — Die Wir-Ebene
Körperbezogene, geteilte Daten als eigene Ebene: Allergien, Diagnosen, Dokumente,
Vereinbarungen, gemeinsames Wissen.
*Deckt:* B4, C2. *Abhängigkeiten:* konzeptionell eng mit TP4. *Risiko:* mittel.

### TP6 — Psychoedukation und Therapiebrücke
Strukturierte Inhalte zu Dissoziation, Anteilen, Switching, Triggern. Plus Sitzungsexport und
ein Ort für „das will jemand in der Therapie ansprechen".
*Deckt:* B5, B6. *Abhängigkeiten:* keine. *Risiko:* niedrig technisch, hoch inhaltlich —
braucht fachliche Prüfung.

### TP7 — Triggererkennung
Auswertung der vorhandenen Switch-, Stimmungs- und Kalenderdaten zu Mustern.
*Deckt:* B3. *Abhängigkeiten:* muss nach der Entscheidung zu B11 kommen.
*Risiko:* mittel — Fehlinterpretationen können schaden, Kausalitätssuggestion vermeiden.

### TP8 — Unschärfe im Anteilsmodell
Unbenannte Anteile, Fragmente, Co-Fronting, „ich weiß nicht wer". Namenszwang entfernen.
*Deckt:* B8. *Abhängigkeiten:* berührt fast jedes Modul, weil überall ein aktives Profil
vorausgesetzt wird. *Risiko:* hoch.

### TP9 — Datensicherheit gegen Dritte
Tarnmodus, Standortdaten-Entscheidung, Sichtbarkeit der Profilauswahl.
*Deckt:* B11, B12. *Abhängigkeiten:* Konflikt mit TP2 (weniger Hürden vs. mehr Schutz) muss
gemeinsam gelöst werden. *Risiko:* hoch.

### TP10 — Bedienbarkeit im dissoziativen Zustand
Verbindliche Regeln statt Absichtserklärung: maximaler Klickpfad zur Krise, keine
zeitkritischen Interaktionen, Leseanforderungsgrenze, Wiederaufnahme abgebrochener Eingaben.
*Deckt:* B9. *Abhängigkeiten:* wirkt als Querschnittsregel auf alle anderen TPs.
*Risiko:* niedrig, aber breit.

### TP11 — Sprache — **erledigt am 2026-08-04**
`Persönlichkeiten` → `Anteile`. Offen bleibt die frei wählbare Selbstbezeichnung beim
Onboarding.
*Deckt:* C3. *Abhängigkeiten:* keine. *Risiko:* niedrig, viele Fundstellen.

### TP12 — Bildsprache als Querschnitt — **begonnen am 2026-08-04**
Jede Handlung trägt ein Symbol, damit nicht lesende Anteile die App bedienen können. Zustände
werden doppelt kodiert (Farbe **und** Form/Füllung), nie über Text allein.
*Deckt:* Teil von B9. *Abhängigkeiten:* keine. *Risiko:* niedrig, wirkt auf alle Module.
*Erledigt:* Rechte-Bereich. *Offen:* Onboarding, Tagebuch, Kalender, Notfall, Einstellungen.

## Vorgeschlagene Reihenfolge

Nicht entschieden, nur begründet:

1. **TP1** — beste Evidenz, additiv, bricht nichts, macht TP2 erst sinnvoll
2. **TP2** — höchste Stakes, braucht TP1 als Inhalt
3. **TP11** — billig, wirkt sofort, kann jederzeit dazwischen
4. **TP3** — verbindet Vorhandenes, mittlerer Aufwand, hoher spürbarer Nutzen
5. **TP4 + TP5** — gemeinsam, weil dieselbe Frage
6. **TP6** — parallel möglich, hauptsächlich Inhaltsarbeit
7. **TP9 → TP7** — in dieser Reihenfolge, die Datenschutzentscheidung geht der Auswertung voraus
8. **TP8, TP10** — Querschnitt, laufend

---

# Teil V — Offene Fragen

Diese Fragen sind noch nicht entschieden und sollten es sein, bevor die betroffenen
Teilprojekte beginnen.

1. **Wie viel Trennung ist Voreinstellung?** Bleibt „jeder Anteil hat sein eigenes Passwort"
   der Standard, oder wird es zur Option? (betrifft C2, TP4, TP5)
2. **Was passiert mit `deactivateProfiles`?** Ersatzlos streichen, umbenennen, oder in etwas
   Reversibles umbauen? (C1, TP4)
3. **Bleiben unwiderrufliche Löschrechte gegen andere Anteile bestehen?** (C1, TP4)
4. **Werden Wechselorte weiterhin gespeichert?** Der Nutzen für TP7 und das Risiko aus B11
   liegen in derselben Datenspalte. (B11, TP7, TP9)
5. **Braucht die App einen Tarnmodus?** Und wie verträgt er sich mit dem hürdenfreien
   Krisenzugang aus TP2? (B12, TP9)
6. **Soll die Notfall-SMS den Namen des frontenden Anteils enthalten?** (B11)
7. **Werden Betroffene und Behandelnde einbezogen?** Siehe Teil VI.
8. **Bleibt der Spiele-Tab?** Wenn ja, mit welcher Begründung — Regulation ist nicht belegt,
   Freude allein wäre eine völlig ausreichende Begründung, aber sie sollte benannt sein.
9. **Wie geht die App mit Selbstdiagnose um?** Sie darf kein Diagnoseinstrument werden und
   keinen Druck erzeugen, sich in Anteilen zu organisieren, die vorher nicht als getrennt
   erlebt wurden. (berührt B8, C3)

---

# Teil VI — Grenzen dieses Berichts

**Kein klinisches Gutachten.** Dieser Bericht fasst öffentlich zugängliche Literatur zusammen.
Er ersetzt keine fachliche Prüfung durch Behandelnde mit DIS-Erfahrung.

**Die Evidenzbasis des Feldes ist dünn.** Acht Studien mit auswertbaren Ergebnisdaten für die
gesamte Behandlung dissoziativer Störungen. Das TOP-DD-Netzwerk ist die stärkste Einzelquelle
und hat 111 Teilnehmende. Aussagen über Effektstärken sind belastbarer als Aussagen darüber,
welches Feature wirkt.

**Die Perspektive der Betroffenen fehlt hier.** Die einzige einbezogene partizipative Studie
(PLOS One 2025) hat 15 Systeme interviewt, online rekrutiert, überwiegend zwischen 18 und 38,
mit überdurchschnittlich guter interner Kommunikation. Sie ist wertvoll und nicht
repräsentativ.

**Die Spannung zwischen klinischem und gemeinschaftlichem Rahmen ist real und ungelöst.** Die
ISSTD-Leitlinien warnen vor Werkzeugen, die Trennung verstärken. Die plurale Gemeinschaft
nutzt genau solche Werkzeuge (PluralKit, Simply Plural) und erlebt sie als hilfreich. Aurora
steht mitten in dieser Spannung. Dieser Bericht nimmt an keiner Stelle an, dass eine Seite
recht hat — er macht sichtbar, wo Aurora sich derzeit implizit positioniert hat, ohne dass die
Entscheidung je bewusst getroffen wurde.

**Empfehlung:** Vor TP4, TP5 und TP8 fachliche und betroffene Rückmeldung einholen. Diese drei
verändern, was die App über die Störung aussagt.

---

# Quellen

- [Effectiveness of phase-oriented treatment for trauma-related dissociative disorders: a systematic review (2025)](https://www.tandfonline.com/doi/full/10.1080/20008066.2025.2545734)
- [ISSTD Guidelines for Treating Dissociative Identity Disorder in Adults (Revised 2011)](https://www.isst-d.org/wp-content/uploads/2025/12/GUIDELINES_REVISED2011.pdf)
- [Brand et al., An Online Educational Program for Individuals With Dissociative Disorders and Their Clinicians: 1- and 2-Year Follow-Up (TOP DD Network)](https://onlinelibrary.wiley.com/doi/full/10.1002/jts.22370)
- [Helpful and meaningful aspects of a psychoeducational programme to treat complex dissociative disorders: a qualitative approach (2024)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10962306/)
- [Helpful aspects of a psychoeducational program for individuals with complex dissociation: an update for Finding Solid Ground (2025)](https://www.sciencedirect.com/science/article/abs/pii/S2468749925000687)
- [Finding Solid Ground — Programmbeschreibung](https://www.findingsolidground.info/about)
- [Reaching internal consensus: Decision-making by transgender and plural people (PLOS One 2025)](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0335714)
- [The reasons dissociative disorder patients self-injure](https://www.tandfonline.com/doi/full/10.1080/20008198.2022.2026738)
- [Establishing Safety with Patients with Dissociative Identity Disorder](https://pubmed.ncbi.nlm.nih.gov/29389297/)
- [ICD-11 6B65 Partial dissociative identity disorder](https://www.findacode.com/icd-11/code-988400777.html)
- [Young, Dissociative identity disorder: a review of the diagnosis that divides (2024)](https://onlinelibrary.wiley.com/doi/10.1002/pnp.834)
- [The online community: DID and plurality](https://www.sciencedirect.com/science/article/pii/S2468749921000570)
- [Carolyn Spring, Should I talk to parts?](https://www.carolynspring.com/blog/should-i-talk-to-parts/)

---

# Änderungsprotokoll

| Datum | Was | Wer |
|---|---|---|
| 2026-08-04 | Erstfassung. Recherche plus App-Stand-Aufnahme, Teilprojekte TP1–TP11 abgeleitet, neun offene Fragen festgehalten. Keine Entscheidung getroffen. | Session „DIS-Forschungsabgleich" |
| 2026-08-04 | Quickwins umgesetzt: TP11 (Sprache auf *Anteile*) erledigt, TP12 (Bildsprache) neu aufgenommen und im Rechte-Bereich umgesetzt, Doppelrendering der Tagebuch-Kategorie behoben. Ton der Rechtetexte auf professionell-freundlich umgestellt. | Session „DIS-Forschungsabgleich" |
| 2026-08-04 | TP1 als nächstes gewählt und durchbrainstormt. Vier Entscheidungen getroffen: gezeichnete Bildfolge, frei lizenzierter austauschbarer Bildersatz, Anker plus Kacheln, Abschluss ohne Bewertung. Erdung wird bewusst **nicht** rechtegesteuert. Design liegt als eigene Spec vor. | Session „DIS-Forschungsabgleich" |
