# Feedback-Rückkanal: ehrlich und ausfallsicher

**Datum:** 2026-08-04
**Status:** Design, freigegeben
**Betrifft:** Aurora 3.0.13 → 3.1.0

---

## 1. Problem

Aurora hat seit dem Release am 29.11.2025 kein einziges Nutzer-Feedback empfangen. Bei rund 40 aktiven Installationen über acht Monate ist das kein Zufall, sondern ein Defekt.

### 1.1 Befund

Der Feedback-Kanal ist im ausgelieferten Build funktionslos. Belege:

**Binärscan des Store-Builds.** Das APK wurde vom Gerät gezogen (`installerPackageName=com.android.vending`, versionCode 13, versionName 3.0.13) und `lib/arm64-v8a/libapp.so` durchsucht:

| Suchmuster | Treffer |
|---|---|
| `ghp_…`, `github_pat_…`, `gho_…` | 0 |
| `api.github.com` | 0 |
| `Authorization` | 0 |
| Kontrolle: `Aurora` / `dis_app` / `Feedback` | 52 / 201 / 39 |

Die Kontrollproben schlagen an, die Token- und Endpunktsuche nicht. Der Header `Authorization` steht im Quelltext sieben Mal (`github_error_report_service.dart:204,507,560,592,623,702`), im Binary gar nicht.

**Ursache.** `ContactConfig.githubApiToken` ist ein `String.fromEnvironment('GITHUB_API_TOKEN', defaultValue: '')` (`contact_config.dart:30`). Ohne `--dart-define` beim Build ist der Wert eine leere Compile-Zeit-Konstante, `isGitHubReportingEnabled` damit konstant `false`, und der gesamte Sendepfad wird vom Compiler eliminiert. Im Repository setzt nichts dieses Define — kein Build-Script, kein CI-Workflow, nur Kommentare.

**Laufzeitbeleg.** Live-Log auf einem Gerät mit 3.0.11:

```
Send Feedback Button Clicked
Feedback copied to clipboard
```

Zwischen Klick und Zwischenablage kein HTTP-Request, kein Fehler.

**Zeitlicher Abgleich.** 14 GitHub-Issues, alle zwischen 14. und 18.11.2025 (Debug-Builds mit gesetztem Define). Release am 29.11.2025. Danach nichts.

### 1.2 Warum das schwerer wiegt als ein normaler Bug

Die App zeigt „Feedback kopiert" und wirkt damit wie eine Erfolgsmeldung. Es wird kein Ziel genannt, kein Mail-Client geöffnet, keine Adresse angezeigt. Menschen in einer Krisensituation haben Rückmeldungen geschrieben und durften annehmen, sie seien angekommen.

Zwei Nebenbefunde verschärfen das:

- Die Validierung schlägt still fehl. Ein Text unter 20 Zeichen (`messageError: too_short_<20`) führt dazu, dass der Absenden-Knopf scheinbar nichts tut.
- Das Ziel-Repository ist privat. Selbst mit gültigem Token hätte niemand seine Meldung wiedergefunden, und eine Antwort wäre unmöglich gewesen.

### 1.3 Was nicht das Problem ist

Erhoben aus der Play Console, damit die Spec nicht das Falsche repariert:

- **Stabilität:** 0 Abstürze, 0 ANRs über 60 Tage
- **App-Größe:** 21,2 MB gegen 46,9 MB Median vergleichbarer Apps
- **Nachfrage:** ~35 → ~40 aktive Installationen in 28 Tagen, ohne Marketing

Aurora hat kein technisches Problem, sondern ein Kommunikationsproblem in beide Richtungen.

---

## 2. Ziel

Ein Rückkanal, der funktioniert, ehrlich über sich Auskunft gibt und nicht erneut unbemerkt ausfallen kann.

**Erfolgskriterien**

1. Feedback aus dem Release-Build erreicht nachweislich den Empfänger
2. Schlägt das Senden fehl, erfährt die Nutzerin das mitsamt Grund und Alternative
3. Ein Release mit nicht konfiguriertem Kanal lässt sich nicht bauen
4. Die Nutzerin kann jederzeit einsehen, was ihr Gerät verlassen hat
5. Standortdaten erreichen die Entwickler nie — durch einen Test abgesichert

---

## 3. Nicht-Ziele

Bewusst ausgeschlossen, um die Spec umsetzbar zu halten. Alle Punkte sind real und bekommen eigene Zuschnitte:

- Übersetzungslücke (IT/FR/ES: 318 von 602 Strings identisch mit dem deutschen Text)
- Ausbau der Telemetrie über das Grundgerüst hinaus
- Store-Listing, Screenshots, Review-Prompt
- Datenschutzerklärung um OpenStreetMap ergänzen (siehe 8.2)
- Nachträgliche Versionierung des ausgelieferten Stands (siehe 8.1)

---

## 4. Architektur: drei Kanäle, strikt getrennt

Der Kern des Entwurfs ist nicht die Übertragungstechnik, sondern die Trennung. Drei Wege mit unterschiedlichen Regeln, ohne gemeinsamen Identifikator.

### Kanal 1 — Feedback

Von der Nutzerin ausgelöst, deshalb keine Einwilligung nötig.

- Sie schreibt, sieht eine **wörtliche Vorschau des vollständigen Payloads**, schickt ab
- Diagnosedaten (Gerät, Zählerstände) sind optional, per Schalter, **standardmäßig aus**
- Ohne Schalter verlässt nur der Text plus optionale Kontaktadresse das Gerät

Der bestehende `EnhancedDebugReportGenerator` bleibt und ist bereits sauber gebaut: Profilnamen anonymisiert, keine Nachrichten, keine Tagebucheinträge, keine Koordinaten. Zwei Felder werden entfernt, weil sie verketten:

- die **Profil-ID** (`enhanced_debug_report_generator.dart:204`) — ein stabiler Identifikator über mehrere Meldungen hinweg
- die **Bestandszahlen** („7 Profile, 1432 Nachrichten, 3 Medikamente") — bei 40 Nutzern praktisch eindeutig

### Kanal 2 — Telemetrie

Automatisch, deshalb strenger. **In dieser Spec wird kein einziges Telemetrie-Ereignis gesendet.** Festgehalten werden nur die Regeln, an die sich eine spätere Umsetzung halten muss, und `TransmissionLog` bekommt den Kanaltyp bereits mitmodelliert, damit er später nicht nachgerüstet werden muss.

Regeln für die spätere Umsetzung:

- Ausschließlich nach **ausdrücklicher Einwilligung** (Opt-in, nicht im Onboarding weggeklickt)
- Nur Ereigniszähler ohne Verkettung: keine Profil-ID, keine Firebase-Installations-ID, keine Session-Kette, keine Bestandszahlen
- „Screen X geöffnet" ist zulässig, „7 Profile vorhanden" nicht

Der Einwilligungsschalter entsteht zusammen mit den Ereignissen, nicht vorher. Ein Schalter, der nichts schaltet, wäre irreführend.

**Rechtliche Begründung für Opt-in:** Bei Aurora ist jeder Datenpunkt kontextbedingt ein Gesundheitsdatum — allein die Information, dass ein Gerät eine DIS-App nutzt, offenbart eine Verdachtsdiagnose. Damit greift DSGVO Art. 9, der ausdrückliche Einwilligung verlangt.

### Kanal 3 — Standort

Geht **nie an die Entwickler**, weder in Feedback noch in Telemetrie. Nicht gerundet, nicht als Land, gar nicht.

Standortdaten sind nicht anonymisierbar: Wenige grobe Orts-Zeit-Punkte genügen zur eindeutigen Identifikation. Bei Aurora käme hinzu, dass der Kontext die Diagnose mitliefert und die Timeline Blackout-Phasen markiert.

**Klarstellung, was bereits passiert:** Die App überträgt Koordinaten an Dritte, technisch unvermeidbar bei Online-Karten:

- `geocoding_service.dart:13` → `https://nominatim.openstreetmap.org`
- `overview_map.dart:1264` → `https://tile.openstreetmap.org/{z}/{x}/{y}.png`

Beides OpenStreetMap Foundation — gemeinnützig, europäisch, nicht werbefinanziert. `flutter_map_tile_caching` ist seit 3.0.6 aktiv und reduziert die Anzahl der Anfragen. Diese Übermittlung ist nicht Gegenstand dieser Spec, muss aber in der Datenschutzerklärung stehen (siehe 8.2).

Die Notfallfunktion teilt Standort direkt mit den von der Nutzerin gewählten Kontakten — nie mit den Entwicklern.

---

## 5. Komponenten

### 5.1 `FeedbackTransport` (neu)

Interface mit zwei Implementierungen. Ersetzt `GitHubErrorReportService` als Sendeweg.

```
FeedbackTransport
  ├── bool get isConfigured
  ├── String get displayName
  └── Future<TransportResult> send(FeedbackPayload payload)

FirestoreTransport  → schreibt via Firebase-SDK in die Feedback-Collection
MailtoTransport     → öffnet Mail-Client mit vorausgefülltem Text
```

**Entscheidend:** Der Endpoint ist **keine Compile-Zeit-Konstante**. Damit kann kein Zweig wegoptimiert werden — genau das war die Ursache des ursprünglichen Fehlers.

`MailtoTransport` ist eine **gleichwertig sichtbare Alternative**, kein Notfall-Fallback. Manche Nutzerinnen wollen bewusst nicht über ein Google-Backend schreiben; wer selbst per Mail schickt, sieht den vollen Inhalt und behält eine Kopie.

### 5.2 Firebase-Anbindung (neu)

Die App hat aktuell **kein Firebase**: kein `google-services.json`, keine Pakete in `pubspec.yaml`, keine Gradle-Einträge. Das Projekt `auroa-7f66b` wird bislang nur für die Website verwendet.

**Entscheidung: Firestore-SDK direkt im Client, keine Cloud Function.**

Der zunächst erwogene Weg — HTTPS-`POST` an eine Cloud Function, um das SDK zu sparen — wurde verworfen. Er hätte die Client-Abhängigkeit eingespart, aber die Cloud Function trotzdem gebraucht und zusätzlich eine selbstgebaute Retry-Logik erfordert:

```
verworfen:   App → HTTP-POST → Cloud Function → Firestore   (3 Teile)
gewählt:     App → Firestore-SDK → Firestore                (2 Teile)
```

Ausschlaggebend: **Firestore puffert Schreibvorgänge offline und sendet sie selbständig nach.** Der `pending`-Zustand aus Abschnitt 6 wird damit vom SDK erledigt statt von eigener Zustandslogik — und genau eine solche still ausfallende Eigenlösung war die Ursache des Ausgangsproblems.

Was das kostet, bewusst in Kauf genommen:
- 2–3 MB zusätzliche App-Größe (Ausgangswert 21,2 MB, Median vergleichbarer Apps 46,9 MB)
- Eine Firebase-Installations-ID auf dem Gerät. Sie geht an Google, landet **nicht** in den Feedback-Dokumenten, gehört aber in die Datenschutzerklärung
- `google-services.json` und Gradle-Plugin im Build

Serverseitig:
- Firestore-Datenbank anlegen — **existiert noch nicht** (`database '(default)' does not exist`)
- **Region `europe-west3`** (Frankfurt), nicht der Default `us-central1`

**Security Rules sind ohne Cloud Function die einzige Verteidigung.** Der API-Key ist aus jedem APK auslesbar, jeder kann damit schreiben. Deshalb zwingend:

- `create`-only auf der Feedback-Collection, **kein** `read`, kein `update`, kein `delete`
- Feld-Whitelist und Größenbegrenzung pro Dokument
- **App Check ist Pflicht**, nicht optional. Ohne ihn kann die Collection vollgeschrieben werden, was auf Google Cloud unmittelbar Kosten verursacht. Im Projekt noch nicht aktiviert (`appcheck.googleapis.com` fehlt)
- Budget-Alarm auf dem Projekt als zweite Absicherung

### 5.3 `TransmissionLog` (neu)

Lokale Hive-Box. Ein Eintrag pro Übertragungsversuch.

| Feld | Inhalt |
|---|---|
| `timestamp` | Zeitpunkt |
| `channel` | `feedback` \| `telemetry` |
| `payload` | vollständiger Inhalt im Klartext |
| `status` | `sent` \| `failed` \| `pending` |
| `error` | Fehlergrund, falls vorhanden |

Liegt **ausschließlich lokal**. Es ist Beleg für die Nutzerin, keine Buchhaltung für die Entwickler. Anbindung über `DataEntry` wie jedes andere Modul.

### 5.4 Screen „Was Aurora sendet" (neu)

Einstellungen → eigener Screen, nicht in einem Untermenü vergraben.

- Chronologische Liste aller Übertragungen mit vollständigem Payload im Klartext
- Status je Eintrag, Fehler mit Grund
- Einträge einzeln löschbar

Dieser Screen ist auch der vorgesehene Ort für den späteren Telemetrie-Schalter — dort, wo seine Wirkung unmittelbar sichtbar wird. Er entsteht aber erst mit den Ereignissen (siehe Kanal 2).

**Der leere Zustand ist der wichtigste.** Wer nie Feedback geschickt und Telemetrie nie aktiviert hat, sieht eine leere Liste. Das ist keine Fehlermeldung, sondern der Nachweis, dass nichts das Gerät verlassen hat.

### 5.5 Änderungen an bestehendem Code

| Datei | Änderung |
|---|---|
| `widgets/feedback_bottom_sheet.dart` | Vorschau vor dem Senden; echte Fehlermeldungen; Validierungsfehler sichtbar machen |
| `utils/enhanced_debug_report_generator.dart` | Profil-ID und Bestandszahlen entfernen |
| `utils/contact_config.dart` | `githubApiToken` und `isGitHubReportingEnabled` entfernen |
| `services/github_error_report_service.dart` | entfällt |
| `models/github_submission_result.dart` | ersetzt durch `TransportResult` |

---

## 6. Fehlerbehandlung

Leitsatz: **Kein stiller Fehler.** Jeder Ausgang ist für die Nutzerin sichtbar.

| Situation | Verhalten |
|---|---|
| Senden erfolgreich | Bestätigung mit Zeitpunkt, Eintrag im Log als `sent` |
| Kein Netz | Eintrag als `pending` mit Hinweis „wird gesendet, sobald wieder Verbindung besteht". Die Zustellung übernimmt die Offline-Persistenz des Firestore-SDK, keine eigene Retry-Logik. Der Log-Eintrag wechselt auf `sent`, sobald der Schreibvorgang bestätigt ist |
| Schreibvorgang abgelehnt (Rules, App Check) | Fehler mit Grund, `mailto:` direkt daneben angeboten, Eintrag als `failed` |
| Kein Transport konfiguriert | Kann nicht auftreten — der Build wäre gescheitert (siehe 7) |
| Text zu kurz | Meldung direkt am Eingabefeld, bevor der Absenden-Knopf reagiert |

Die Zwischenablage bleibt als **zusätzliche** Möglichkeit erhalten, ist aber nie die alleinige Reaktion auf einen Fehlschlag.

---

## 7. Tests

Der eigentliche Fix ist nicht der neue Kanal, sondern die Absicherung dagegen, dass er wieder unbemerkt ausfällt.

**Unit**
- `transport.isConfigured` ist `true` — schlägt fehl, wenn kein Ziel gesetzt ist
- Payload-Schema enthält **kein** Standortfeld (hält Kanal 3 auch bei späteren Erweiterungen ein)
- `EnhancedDebugReportGenerator` liefert weder Profil-ID noch Bestandszahlen
- Payload ohne aktivierten Diagnose-Schalter enthält ausschließlich Text und optionale Kontaktadresse

**Integration**
- Erfolgreicher Versand erzeugt genau einen Log-Eintrag mit Status `sent`
- Abgelehnter Versand erzeugt `failed` mit Grund und bietet `mailto:` an
- Versand ohne Netz erzeugt `pending` und wechselt nach Wiederverbindung auf `sent`
- Security Rules verweigern `read`, `update` und `delete` sowie Dokumente außerhalb der Feld-Whitelist (gegen die Regeln getestet, nicht nur behauptet)

**CI-Gate**
Die Tests laufen mit denselben Parametern wie der Release-Build. Schlagen sie fehl, entsteht kein Artefakt. Der Workflow existiert seit 16.11.2025 unter `.github/workflows` und muss den Release-Pfad abdecken.

**Manuelle Abnahme**
Release-Build auf ein Gerät installieren, Feedback abschicken, Eingang serverseitig bestätigen. Genau dieser Schritt fehlte am 29.11.2025.

---

## 8. Offene Punkte

### 8.1 Versionierung des ausgelieferten Stands

Im Store läuft 3.0.13 (versionCode 13), auf GitHub steht 3.0.11+11. Der Versions-Bump liegt bis heute uncommitted im Arbeitsverzeichnis. Der Code selbst stimmt überein — Commit `a72e9ac` (03:17) liegt vor dem Store-Upload (03:27) — aber es gibt weder Commit noch Tag für das, was ausgeliefert wurde.

Vor Beginn der Umsetzung nachzuholen, sonst baut die Arbeit auf einem nicht reproduzierbaren Stand auf.

### 8.2 Datenschutzerklärung und Play Data Safety

Beide müssen vor Veröffentlichung angepasst werden:

- Übermittlung an OpenStreetMap (Nominatim, Tile-Server) nennen — vermutlich bislang nicht deklariert
- Feedback-Übermittlung und deren Empfänger nennen
- Telemetrie beschreiben, sobald aktiv
- Data-Safety-Angabe steht derzeit auf „keine Datenerhebung". Bleibt sie falsch, ist das ein Policy-Verstoß mit Entfernungsrisiko

Die Store-Kurzbeschreibung verspricht „Alle Daten bleiben auf deinem Gerät". Diese Aussage muss präzisiert werden, sobald ein Rückkanal existiert.

### 8.3 Ungeprüft

`services/location_tracking_service.dart` wurde nicht daraufhin untersucht, ob im Hintergrund dauerhaft aufgezeichnet wird oder nur auf Anforderung. Für diese Spec nicht entscheidend, für die Datenschutzerklärung sehr wohl.

### 8.4 Datengrundlage unvollständig

Der Zugriff auf die Play-Console-Bulk-Reports (`gs://pubsite_prod_6785276662525223500/`) ist eingerichtet, liefert aber noch 403 — Google nennt bis zu 24 Stunden Vorlauf. Retention und Deinstallationszahlen fehlen daher. Sie ändern nichts an der Richtung dieser Spec, sind aber für die Priorisierung danach relevant.

---

## 9. Abgrenzung zum bisherigen Ansatz

GitHub Issues entfallen vollständig. Drei Gründe, aufsteigend nach Gewicht:

1. Der Token muss in den Client und wäre aus jedem APK auslesbar
2. Das Repository ist privat — Meldungen sind für Nutzerinnen unsichtbar, eine Antwort unmöglich
3. Die Roadmap sieht Open Source vor. Beim Öffnen des Repositories würden **alle bisherigen und künftigen Feedback-Issues rückwirkend öffentlich**. Bei einer DIS-App enthält Feedback Diagnosen, Krisenschilderungen, teils Klarnamen. Die Entscheidung, das Repository zu öffnen, darf nicht davon abhängen, was jemand ins Feedback-Formular geschrieben hat.
