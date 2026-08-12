# Abgleich der drei Codex-Berichte vom 10. August 2026

**Stand:** 10. August 2026, abends
**Erstellt von:** Claude (Hauptsession), Einstufungen gegen HEAD durch drei
Fable-Prüfer
**Status:** Abgleichdokument. Keine Codeänderung, nichts committet.

Codex hat am 10. August drei Befundberichte geliefert. Dieses Dokument sagt,
was sie zusammen ergeben — was sich überschneidet, was sich widerspricht, und
was bereits erledigt ist.

## Die Lage in einem Absatz

Eine parallel laufende Claude-Session arbeitet seit 17:31 im Hauptbaum auf
`fix/codex-stress-a11y` an einem Umsetzungsplan
(`docs/superpowers/plans/2026-08-10-codex-stress-und-barrierefreiheit.md`,
1621 Zeilen, zehn Aufgaben). Dieser Plan deckt **ausschließlich den ersten
Bericht** ab. Die beiden anderen Berichte entstanden 17:46 und 17:48 — nach
dem Plan-Commit. Sie sind bis heute nicht einmal getrackt. Damit sind
**17 der 23 Befunde in keinem Plan.**

## Chronologie, die den Abgleich trägt

| Zeit | Ereignis |
|---|---|
| 17:04 | Bericht 1 (Stress/Barrierefreiheit) — **getrackt** in `212e7db` |
| 17:31 | Umsetzungsplan `70cc1ae` — beruht nur auf Bericht 1 |
| 17:46 | Bericht 3 (Krisenhilfe/Rechte) — **untracked** |
| 17:48 | Bericht 2 (Arbeitsflächen/Entwürfe) — **untracked** |
| 19:00–20:24 | Sieben Commits der Parallelsession, zuletzt `5df5a96` |

Die Parallelsession steht damit etwa bei Aufgabe 4 von 10.

## Befundstand an HEAD `5df5a96`

23 Befunde aus drei Berichten, jeder einzeln gegen den Code geprüft.
**Ergebnis: 1 behoben, 3 teilweise, 17 offen, 1 strittig, 1 entschieden.**

> **Diese Tabelle beschreibt den Stand vor den Nachträgen weiter unten.**
> Sieben ihrer Einträge sind inzwischen in `main`: A8, U2, A7, A3, A4 sowie
> **H1** und **H2** — letzteres nur zur Hälfte, die Notfall-Fläche fehlt noch.

| Befund | Stand | Beleg |
|---|---|---|
| **S1** Große Schrift zerstört die Orientierung | **behoben** | `profile_selection_screen.dart` skaliert das Budget über `MediaQuery.textScalerOf`; ab Faktor 1,3 rollt der ganze Schirm. `_LocationNotice` liegt jetzt **unter** der Karte statt im Stack. Test `profile_selection_text_scale_test.dart` prüft 1,0/1,5/2,0 auf beiden Gerätehöhen. **Mit Vorbehalt:** Die Tests lassen über `_expectOnlyTimeMapOverflow()` einen bekannten TimeMap-Überlauf ausdrücklich durch, und die Geräteabnahme steht als Aufgabe 10 noch aus |
| **S2** Berechtigung statt Hilfe | **teilweise** | `showUserLocation: false` **und** `showPermissionBanner: false` sind ausdrücklich gesetzt, die Reihenfolge stimmt. Offen: der Leerzustand trägt weiter nur Erklärtext ohne Knöpfe, und „von von gestern" ist unverändert |
| **S3** Rückkehr versteckt die Krisenwege | offen | `anchor_menu_screen.dart` ist unverändert eine `ListView` ohne Rückkehrstrategie |
| **A1** Semantik doppelt/leer | offen | `anchor_row.dart` setzt das Label, schließt die Kindsemantik aber nicht aus. `quick_timeline_band.dart` benennt die Handlung nicht. Info-Knopf ohne Tooltip |
| **A2** Dank doppelt, Ausgang unten | offen | Titel steht zweimal; „Zurück zur App" folgt erst hinter den Community-Links |
| **D1** Standortspur vor der Profilwahl | **entschieden** | „So lassen" — siehe unten |
| **H1** „24/7" gilt nicht für die Liste | offen | `hotline.dart` ist eine flache Liste ohne Gruppierung, mit den veralteten Zeiten des Info-Telefons und ohne Quelle oder Prüfdatum |
| **H2** Kein 112-Weg | offen | „112" kommt in `lib/` **nirgends** vor |
| **H3** Notfall und Hilfe entziehbar | offen | `viewEmergencyTab` und `viewHelpTab` stehen weiter im Rechtemodell, `main.dart` filtert beide |
| **D2** Löschweg nur im Debug-Build | offen | Der Eintrag liegt weiter hinter `if (kDebugMode)`, während `privacyDeletionBody` ihn zusagt |
| **D3** Löschdialog unvollständig | offen | Die Aufzählung endet auf „• Alle Doodle-Anhänge". Bilder, Sprachnachrichten, Avatare, Kartenkacheln, Standort- und Profilwechselverlauf, Übertragungsprotokoll und Telemetrie-Warteschlange fehlen — obwohl `AttachmentHelper.clearAll` sie löscht |
| **G1** Weiterblättern unsichtbar | teilweise | Der Zurückknopf ist inzwischen sichtbar; der Weiter-Hinweis und die Tooltips fehlen |
| **U2** Profiländerung geht verloren | offen | `profile_edit_screen.dart` hat kein `PopScope` |
| **R1** Rechte ohne Wirkung | offen | `viewMantrasTab` existiert, ein Mantra-Screen nicht (`lib/modules/mantras/` enthält nur `widgets/`). `viewChatTab` und `viewFeedbackTab` sind wirkungslos |
| **A7** Kartensteuerung ohne Namen | offen | Die drei `FloatingActionButton` in `overview_map.dart` haben keinen Tooltip |
| **A8** Puzzle hinter der Systemleiste | offen | `puzzle_selection_screen.dart` setzt weiter `EdgeInsets.all(24)` |
| **I1** Atemübungen als „Bald" | offen | `games_screen.dart` führt sie mit `isAvailable: false`, während Halt sie besitzt |
| **K1** Notfallkontakt ohne Kanal | offen | Der Schalter prüft nichts; validiert wird nur der Name |
| **U1** Chatentwurf verloren | offen | Der Controller entsteht lokal in `chat_input_field.dart` und wird beim Abbau verworfen |
| **A3** Chat-Eingaben unbeschriftet | offen | Plusknopf, Textfeld und Sendeknopf ohne Semantik-Label |
| **A4** Medienblatt unklar | teilweise | `SafeArea` ist da; die Überschrift heißt weiter `mediaFromGallery`, ein sichtbarer Ausgang fehlt |
| **A5** Profilkopf-Trefferfläche | **strittig** | Siehe unten |
| **A6** Einstellungen hinter der Systemleiste | offen | `AnimatedListView` mit festem `EdgeInsets.all(8)` |

Der bestehende Plan behandelt S1, S2, S3, A1, A2 und entscheidet D1.
Er lässt B12 und die Startdauer bewusst liegen. Alles aus den Berichten 2
und 3 ist ungeplant.

### A5 ist nicht belegt behoben

Eine Codeprüfung meldete A5 als behoben, weil `Semantics` in
`work_surface_scaffold.dart` das ganze `InkWell` umschließt. Das trägt nicht:
Die Datei ist seit dem **8. August** unverändert, Codex hat am **10. August**
gemessen. Der Befund stammt außerdem aus einer Laufzeitbeobachtung — zwei Taps
im angekündigten oberen Bereich öffneten nichts, erst der Tap auf die schmale
Zeile wirkte. Eine deckungsgleiche `Semantics`-Klammer im Quelltext widerlegt
das nicht, weil der Hit-Test kleiner sein kann als der Semantikknoten. **A5
bleibt offen, bis der von Codex geforderte Vergleich von Semantik-Rect und
Hit-Test-Rect vorliegt.**

### Ein brauchbares Muster liegt schon im Repo

Für A6 und A8 muss nichts erfunden werden: `lib/widgets/bottom_action_bar.dart`
verwendet bereits `SafeArea(top: false)` mit Abschlussabstand. Es wird auf
Einstellungen und Puzzle nur nicht angewendet.

## Der schärfste Kreuzbefund: der Rettungsweg führt ins Falsche

**Aufgabe 5 des laufenden Plans baut genau in die Fläche, die Bericht 3 als
sachlich falsch belegt.**

Aufgabe 5 (S2b) gibt dem leeren Notfallzustand zwei Knöpfe. Der zweite heißt
„Hilfe und Notrufnummern" und öffnet `HelpResourcesScreen`. Der Test dazu
steht schon im Plan geschrieben.

**Diese Warnung kommt rechtzeitig:** Die Prüfung an HEAD zeigt, dass der
Leerzustand noch unverändert ist — Aufgabe 5 ist geschrieben, aber nicht
gebaut. Es kostet jetzt nichts, die Reihenfolge zu ändern.

Bericht 3 sagt über eben diese Fläche:

- **H1** — Sie überschreibt die ganze Liste mit „24/7" und „jederzeit
  erreichbar". „Nummer gegen Kummer" ist aber Mo–Sa 14–20 Uhr erreichbar, und
  Aurora nennt dort gar keine Zeiten. Die Zeiten des Info-Telefons Depression
  sind veraltet.
- **H2** — Auf dieser Fläche steht kein sichtbarer 112-Weg, obwohl sie sich
  „Notfall-Hotlines" nennt.

Zusammengenommen: Eine Person ohne Notfallkontakte, in Krise, bekommt nach
Aufgabe 5 einen ruhigen Knopf angeboten, der auf eine Liste mit einem
Erreichbarkeitsversprechen führt, das für einen Teil der Einträge nicht gilt —
und ohne die Eskalationsstufe für unmittelbare Gefahr. Ein erfolgloser Anruf
ist in dieser Lage keine neutrale Sackgasse; die Person kann daraus schließen,
Hilfe sei grundsätzlich nicht erreichbar.

**Folgerung:** H1 und H2 gehören **vor** Aufgabe 5, nicht danach. Sonst ist
der neu gebaute Knopf ab dem ersten Tag ein Versprechen, das die Zielfläche
nicht hält.

## Weitere Überschneidungen: fünf Cluster, nicht 23 Einzelfixes

### Cluster 1 — Die Notfallfläche (S2, H2, H3, K1)

Vier Befunde aus drei Berichten treffen dieselbe Fläche:

- **S2** — Die Standortberechtigung steht vor der Hilfe. *Halb erledigt in
  `5df5a96`: Reihenfolge und `showUserLocation: false` sitzen, der Leerzustand
  fehlt noch.*
- **H2** — Kein sichtbarer 112-Weg für unmittelbare Gefahr.
- **H3** — `viewEmergencyTab` und `viewHelpTab` sind pro Profil entziehbar;
  dann ist öffentliche Hilfe nur noch indirekt hinter einer vollständig
  durchlaufenen Halt-Übung erreichbar.
- **K1** — Ein Notfallkontakt lässt sich ohne Telefon und ohne E-Mail
  speichern. Auf der Notfallfläche erscheint er dann mit toten Knöpfen.

Wer S2 löst, ohne H3 zu kennen, baut eine Hilfe-vor-Karte-Reihenfolge in eine
Fläche, die eine andere Rolle komplett ausblenden kann. Wer den Leerzustand
mit Kontakt-Knöpfen füllt, ohne K1 zu kennen, führt auf ein Formular, das
unerreichbare Kontakte zulässt.

### Cluster 2 — Untere Systemleiste (A6, A8)

Bericht 3 stuft das selbst als gemeinsamen Layoutfehler ein. `settings_screen`
(A6) und `puzzle_selection_screen` (A8) setzen beide festes Padding ohne
`MediaQuery.viewPadding.bottom`. **Ein wiederverwendbares Muster, nicht zwei
Korrekturen** — und danach ein Regressionstest über alle rollbaren Vollseiten.

### Cluster 3 — Semantikpass (A1, A3, A4, A5, A7, G1, U2)

Sieben Befunde, ein Durchgang über gemeinsame Bausteine. Der Plan behandelt
davon nur A1 (Anker, Zeitband, Info-Knopf). Offen bleiben: Chat-Eingaben (A3),
Medienblatt (A4), Profilkopf-Trefferfläche (A5), Kartensteuerung (A7),
Halt-Zurückknöpfe (G1), Profilbearbeitungsfelder (U2).

`OverviewMap` (A7) wird von Zeitachse **und** Notfall genutzt — der Fix wirkt
doppelt.

### Cluster 4 — Entwurfsschutz (U1, U2)

Chat (U1) und Profilbearbeitung (U2) verlieren Eingaben lautlos.
Medikament, Tagebuch, Kontakte, Finder und Kalender haben das
Drei-Wege-Muster bereits. **Es ist vorhanden und muss nur angelegt werden.**

### Cluster 5 — Versprechen ohne Deckung (D2, R1, I1)

Drei Stellen, an denen Aurora etwas anbietet, das nicht existiert:

- **D2** — Die Datenschutzerklärung nennt „Alle Daten löschen" in den
  Einstellungen; der Eintrag liegt hinter `kDebugMode` und fehlt im Release.
- **R1** — `viewMantrasTab` ist ein Recht ohne Bereich; `viewChatTab` und
  `viewFeedbackTab` sind Rechte ohne Wirkung, weil beide Tabs
  `requiredPermission: null` tragen.
- **I1** — „Spiele" zeigt Atemübungen als „Bald", während Halt sie bereits
  besitzt.

D2 ist davon der ernsteste: Es ist die einzige Stelle, an der ein
**Datenschutzversprechen** nicht durch das Release-Verhalten gedeckt ist.

## Produktentscheidungen

### D1 — bereits entschieden

Der Plan entscheidet D1 mit **„so lassen"**: Die genaue Standortspur bleibt vor
der Profilwahl sichtbar, weil Orientierung nach einem Blackout schwerer wiegt
als lokale Vertraulichkeit auf dem entsperrten Gerät. Die Entscheidung ist
begründet und wird in Aufgabe 10 dokumentiert. Sie deckt sich mit der
bisherigen Linie, Standortaufzeichnung als Kernnutzen zu behandeln.

Codex' Vorschlag einer Abstufung (grober Ort vor der Wahl, genaue Spur
danach) bleibt damit bewusst unbenutzt.

### Offen und nur vom Nutzer zu entscheiden

- **H2 — Formulierung des 112-Wegs.** Codex verlangt fachliche und
  rechtliche Prüfung. Der Weg darf keinen stillen Direktanruf auslösen.
- **H3 — Welche Hilfe ist unentziehbar?** Private Kontakte dürfen aus
  Schutzgründen berechtigt sein. Ob dasselbe für öffentliche Beratung und 112
  gelten darf, ist eine Grundsatzfrage am Rechtemodell.
- **K1 — Darf ein rein informativer Notfallkontakt existieren?** Entweder
  Pflichtfeld oder klare Aussage, wofür er im Notfall taugt.
- **D2 — Löschweg im Release.** Entweder der Weg kommt in den Release oder
  die Datenschutzerklärung wird geändert. Beides zusammen, nie einzeln.

## Empfohlene Reihenfolge

Die drei Berichte schlagen je eine eigene Reihenfolge vor. Zusammengeführt und
nach Cluster geordnet:

1. **H1 und H2 vorziehen** — bevor Aufgabe 5 einen Knopf auf die Hilfefläche
   legt. Zeiten korrigieren, Gruppen trennen, 112 abgrenzen, Quelle und
   Prüfdatum ins Repo.
2. **Plan zu Ende führen** (Aufgaben 5–10): S2b, doppeltes „von", S3, A1, A2.
3. **Notfall-Cluster schließen**: H3 als Invariante, K1 als Formularregel.
4. **D2** — Löschweg und Datenschutzerklärung gemeinsam in Deckung bringen.
5. **Semantikpass über die Reste** (A3, A4, A5, A7, G1, U2) — als ein
   Durchgang über gemeinsame Bausteine.
6. **Untere Insets** (A6, A8) als ein geteiltes Muster.
7. **Entwurfsschutz** (U1) mit dem vorhandenen Drei-Wege-Dialog.
8. **Aufräumen**: R1 (Rechtekatalog), I1 (Atemübungen), D3 (Löschdialogtext).

## Was dieser Abgleich nicht leistet

- Keine Codeänderung, kein Commit. Der Arbeitsbaum gehört gerade der
  Parallelsession.
- Die lokalen Aufnahmen unter `build/codex-audit-2026-08-10/` wurden nicht
  angesehen; sie enthalten reale Profil- und Standortdaten und bleiben
  außerhalb des Repos.
- Die Erreichbarkeitszeiten aus H1 sind Codex' Recherche vom 10. August. Vor
  der Umsetzung müssen sie erneut an der Quelle geprüft werden — genau das ist
  der von H1 geforderte Prozess.
- **Die Einstufungen entstanden durch Codelesen, nicht am Gerät.** Codex hat
  gemessen; hier wurde gegengelesen. Wo beides auseinanderfällt, gilt die
  Gerätemessung, bis ein Test die Sache entscheidet — A5 ist genau dieser Fall
  und die Erinnerung daran, dass ein Widgettest für Trefferflächen und
  Systemleisten nicht genügt.

## Nachtrag: fünf Befunde erledigt

Im eigenen Arbeitsbaum `F:/aurora-a11y` auf dem Zweig
`fix/codex-semantik-und-insets` (Basis: aktuelles `main`, 7f476b5):

| Befund | Commit | Prüfung |
|---|---|---|
| **A8** Puzzle-Knopf unter der Systemleiste | `caf76b9` | 2 Tests, Geometrie statt Overflow. Vorher belegt: Knopf endet bei 576, Systemleiste beginnt bei 552 |
| **U2** Profiländerung geht verloren | `15ceca8` | 4 Tests, **beide** Rückwege |
| **A7** Kartenknöpfe ohne Namen | `a76bc65` | kein Widgettest — Begründung unten |
| **A3** Chat-Eingaben ohne Namen | `074e242` | 4 Tests, inklusive Zustandswechsel des Sendeknopfs |
| **A4** Medienblatt ohne Ausgang | `074e242` | im selben Commit, gleiche Fläche |

**512 Tests grün**, keiner rot (Ausgangsstand 504).

Ausgewählt wurde nach zwei Regeln: keine Datei, an der eine der beiden
laufenden Sessions gerade arbeitet, und keine offene Produktentscheidung.
Deshalb blieben A6 und D2 liegen — beide sitzen in `settings_screen.dart`,
das im Zweig `feat/zustandseigentum` geändert wird.

Drei Dinge, die dabei auffielen:

- **Das Muster für A8 lag schon im Repo.** `lib/utils/safe_area_extensions.dart`
  bietet `safeBottomPaddingWithMargin`. Für A6 ist damit ebenfalls nichts zu
  erfinden, sobald `settings_screen.dart` wieder frei ist.
- **Für U2 waren keine neuen Texte nötig** — `ConfirmationDialog.showUnsavedChanges`
  und `actionBack` gab es bereits. Der sichtbare Zurückpfeil rief allerdings
  unmittelbar `Navigator.pop` und lief damit an jedem `PopScope` vorbei. Eine
  Prüfung nur für Android-Zurück hätte das nicht bemerkt.
- **A7 blieb ohne Widgettest.** `OverviewMap` zieht vier Dienste über `getIt`.
  Ein MapService-Mock entsteht bereits im Zweig `fix/codex-stress-a11y`
  (`9fb9256`); der Semantiktest dockt nach dem Zusammenführen dort an. Der
  Nachweis am Gerät steht damit noch aus. Aus demselben Befund offen: die
  Ansage der Kartenfläche selbst — ihr Zweck hängt vom Einsatzort ab, und eine
  erfundene Beschriftung wäre schlechter als keine.

Beim Prüfen von U2 fiel nebenbei auf: **Im Bearbeitungsbaum des Profils läuft
eine Animation, die nie zur Ruhe kommt.** `pumpAndSettle` läuft dort in einen
Zeitablauf; der Test behilft sich mit getakteten Pumps. Welche Animation es
ist, wurde nicht ermittelt — sie verbrennt aber dauerhaft Bilder, solange der
Bildschirm offen ist. Eigener Befund, noch niemandem zugeordnet.

**Zusammenführen in dieser Reihenfolge:** erst `fix/codex-stress-a11y` nach
`main`, danach dieser Zweig. Beide fassen alle fünf ARB-Dateien an. Die neuen
Schlüssel liegen bewusst fern der Stelle, an der der andere Zweig anfügt — das
ist eine begründete Erwartung, kein Beweis. Der ARB-Bereich gehört beim
Zusammenführen angesehen.

Neue Texte in allen fünf Sprachen: `mapZoomIn`, `mapZoomOut`,
`mapToMyLocation`, `chatMessageFieldLabel`, `chatAddMedia`,
`chatSendMessage`, `chatMediaSheetTitle`. Sie stehen bewusst bei ihren
thematischen Nachbarn und nicht am Dateiende — dort fügt der Hauptbaum-Plan
seine eigenen an, und genau da kollidieren Zusammenführungen.

## Nachtrag 2: die Hilfefläche stimmt jetzt

Zweig `fix/codex-krisenhilfe`, Commits `fbe4ceb` und `b4a57ce`, in `main`.
**520 Tests grün.**

Alle Angaben am 10.08.2026 an den Anbieterseiten geprüft — nicht aus dem
Bericht übernommen. Dabei kamen zwei Dinge heraus, die auch Codex nicht
hatte:

- **Der Telefonseelsorge fehlte eine Nummer.** Der Anbieter nennt
  116 123 gleichrangig neben den beiden 0800er-Nummern. In Aurora stand sie
  nicht.
- **Der Krisenchat gilt nur für Menschen unter 25.** Diese Grenze stand
  nirgends.

Und eine eigene Fehleinstufung, die die Nachrecherche gekippt hat: Auf der
Startseite des Krisenchats steht keine Erreichbarkeit, woraus zunächst
„zeitlich begrenzt" wurde. Die Angebotsseite überschreibt ihren Abschnitt
aber wörtlich mit „24/7 Krisenberatung für junge Menschen". Er steht deshalb
unter „rund um die Uhr", mit der Altersgrenze sichtbar auf der Karte.

| Angebot | Erreichbarkeit | Aurora sagte vorher |
|---|---|---|
| Telefonseelsorge (3 Nummern) | rund um die Uhr | 2 Nummern |
| Krisenchat | rund um die Uhr, unter 25 | keine Angabe |
| Nummer gegen Kummer | Mo–Sa 14–20 Uhr | gar keine Zeiten |
| Info-Telefon Depression | Mo/Di/Do 13–17, Mi/Fr 8:30–12:30 | Mo–Do 13–17, Di+Do 19–21 |

Die Abendzeiten des Info-Telefons gibt es nicht mehr, die Vormittage fehlten.

**Der Notruf** steht jetzt als eigene Stufe über den Beratungsangeboten. Der
Knopf öffnet den Wähler mit vorgewählter Nummer; Aurora ruft nicht von selbst
an. Belegt ist auch die Zusage „auch ohne Guthaben": Mit gültiger SIM-Karte
funktioniert 112 ohne Guthaben — ohne Karte seit dem 01.07.2009 nicht mehr,
was der Text auch nicht behauptet.

Nach den Oberflächenrichtlinien: **nichts wird nach Uhrzeit ein- oder
ausgeblendet** (Regel 9 — Zustände werden angeboten, nicht erkannt; Regel 7 —
Reihenfolge ist eine Zusage). Gesättigte Farbe trägt allein der Notruf;
`AppColors.signal` ist im Farbmodell wörtlich dafür vorgesehen (Regel 4).

Jeder Eintrag trägt jetzt Quelle und Prüfdatum im Modell. Wer Zeiten ändert,
sieht an der verlinkten Seite nach, statt sie fortzuschreiben. Nebenbei
repariert: `germanEmergencyHotlines` war eine `final`-Liste und fror die
Sprache des ersten Zugriffs ein.

**Offen bleibt die zweite Hälfte von H2:** Die Notfall-Fläche braucht
denselben 112-Weg. Sie gehört der Sitzung, die an `fix/codex-stress-a11y`
arbeitet, und blieb deshalb unberührt.

## Notiz am Rande

Beim Abgleich fiel auf, dass `pubspec.yaml` wieder auf `firebase_core ^3.8.0`,
`cloud_firestore ^5.5.0` und `firebase_app_check ^0.3.1` steht. Das am
Nachmittag durchgeführte und am Gerät belegte Major-Upgrade — Anlass war die
kritische Play-Anmerkung zu `play-services-safetynet` — ist damit aus dem
Arbeitsbaum gefallen, ohne je committet worden zu sein.

**Verloren ist nur das Paket-Upgrade selbst.** Alles Übrige aus demselben
Nachmittag steht: die vier Chat-Anhang-Korrekturen in `chat_screen.dart`, der
ausgeschriebene `AndroidProvider.playIntegrity` in `main.dart` sowie
`SECURITY.md` und `.github/` (committet in `212e7db`). Die beiden Paketdateien
liegen als Sicherung vor und gehören in einen eigenen, sauberen Arbeitsbaum —
nicht hierher.
