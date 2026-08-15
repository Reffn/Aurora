# Telemetrie: zählen, ohne wiederzuerkennen

**Datum:** 2026-08-05
**Status:** Design, freigegeben
**Betrifft:** Aurora 3.1.x → 3.2.0
**Baut auf:** `2026-08-04-feedback-rueckkanal-design.md` (Kanal 2 wird hier eingelöst)

---

## 1. Problem

Aurora soll iteriert werden, aber niemand weiß, was benutzt wird. Der Feedback-Kanal ist seit 3.1.0 funktionsfähig und liefert Text von den wenigen, die schreiben. Was die anderen tun — welchen Bereich sie nie öffnen, an welchem Onboarding-Schritt sie aufgeben, welche Übung sie abbrechen — ist unbekannt.

Die Feedback-Spec hat für diesen Fall Kanal 2 vorgesehen, aber bewusst kein einziges Ereignis gesendet. Sie hat nur die Regeln festgehalten. Diese Spec setzt sie um.

### 1.1 Was die Daten hergeben — und was nicht

Ehrlich vorweg, damit die Erwartung stimmt:

- Rund 40 aktive Installationen. Bei realistischer Opt-in-Quote von 20–40 % sind das **8–16 Geräte**.
- Zahlen aus dieser Stichprobe geben **Richtung, nie Signifikanz**. Ein Mensch, der Aurora täglich öffnet, dominiert jede Kurve.
- Wer zustimmt, ist nicht der Durchschnitt. Die Auswahlverzerrung lässt sich nicht herausrechnen.

Daraus folgt eine Arbeitsregel: Telemetrie beantwortet **„wird das überhaupt angefasst"**, nicht „was ist besser". A/B-Vergleiche sind bei dieser Größe sinnlos und werden nicht gebaut.

### 1.2 Was schon gemessen wird

Die Play Console liefert ohne jede Telemetrie und ohne Einwilligungsproblem: Installationen, Deinstallationen, Retention, Abstürze, ANRs, Android-Versionen, Geräteklassen.

**Was der Store schon misst, misst Aurora nicht nochmal.** Diese Spec deckt ausschließlich das ab, was nur die App selbst wissen kann.

---

## 2. Ziel

Vier Fragen sollen beantwortbar werden:

1. An welchem Onboarding-Schritt brechen Menschen ab?
2. Welche Bereiche des Ankers werden nie geöffnet?
3. Welche Fehler treten auf, die keinen Absturz erzeugen?
4. Werden Übungen zu Ende gebracht?

**Erfolgskriterien**

1. Ohne Einwilligung entsteht auf dem Gerät kein einziges Ereignis
2. Kein gesendetes Ereignis lässt sich mit einem anderen zu einer Sitzung verketten
3. Jedes gesendete Ereignis ist in „Was Aurora sendet" im Klartext nachlesbar
4. Ein Release mit falscher Data-Safety-Angabe lässt sich nicht veröffentlichen
5. Frage 1 und 4 werden beantwortet, ohne dass je eine Reihenfolge das Gerät verlässt

---

## 3. Nicht-Ziele

- **Wirkung messen.** Ob eine Übung geholfen hat, wird nicht erfragt. Gemessen wird nur, ob sie tragbar war — Abschluss gegen Abbruch. Wirkung im engeren Sinn bleibt Sache von Feedback und Gesprächen.
- **A/B-Tests.** Siehe 1.1.
- **Nachbau von Play-Console-Metriken.** Siehe 1.2.
- **Kohorten, Trichter über Zeit, Wiederkehrraten.** Alles davon braucht Verkettung.
- **Standortdaten.** Kanal 3 der Feedback-Spec gilt unverändert: nie, nicht gerundet, nicht als Land.

---

## 4. Der Konflikt und seine Auflösung

Frage 1 („wo brechen Leute ab") ist ein Trichter. Trichter brauchen normalerweise die Reihenfolge innerhalb einer Sitzung — genau das verbietet die Feedback-Spec („keine Session-Kette").

**Auflösung: Der Abbruch ist selbst ein Ereignis.**

Statt eine Sequenz zu senden und daraus den Absprung abzuleiten, stellt das Gerät lokal fest, dass abgebrochen wurde, und sendet ein einzelnes, für sich stehendes Ereignis:

```
gesendet:      onboarding_begonnen
gesendet:      onboarding_abgebrochen_profil
nie gesendet:  [schritt_1, schritt_2, schritt_3, abbruch]  ← die Sequenz
```

Die Abbruchquote ergibt sich aus dem Verhältnis der Zählerstände über alle Geräte. Die Verkettung bleibt dort, wo sie ohnehin liegt: auf dem Gerät.

Dasselbe Muster trägt Frage 4: `uebung_beendet_<name>` gegen `uebung_abgebrochen_<name>`.

**Was dabei verloren geht, bewusst in Kauf genommen:** Man erfährt nicht, ob dieselbe Person mehrfach abbricht oder ob zehn Personen je einmal abbrechen. Bei 8–16 Geräten wäre diese Unterscheidung ohnehin keine belastbare Aussage.

---

## 5. Datenform

### 5.1 Ein Ereignis, ein Dokument, drei Felder

| Feld | Typ | Inhalt |
|---|---|---|
| `event` | String | Name aus fester Whitelist |
| `day` | String | `2026-08-05` — **ohne Uhrzeitanteil** |
| `appVersion` | String | z. B. `3.2.0` |

Mehr nicht. Kein Zähler, kein Wert, keine Parameter, keine Geräteangabe, keine Kennung jeder Art.

**Warum die Uhrzeit fehlt.** Mit Sekundengenauigkeit ließen sich Ereignisse desselben Geräts über Zeitnähe wieder zu einer Sitzung zusammenfügen — die Uhr täte dann die Verkettung, die das Schema verweigert. Tagesgenauigkeit reicht für jede Frage aus Abschnitt 2.

**Warum `appVersion` trotzdem mitgeht.** Ohne sie ist Telemetrie wertlos: Man sieht eine Zahl, aber nicht, ob eine Änderung sie bewegt hat. Das Risiko wird benannt statt weggelassen: Eine seltene Version ist bei zehn Geräten ein Merkmal. Deshalb nur die Release-Version (`3.2.0`), nie Build-Nummer, nie Git-Hash.

### 5.2 Ereignisnamen sind stabile Schlüssel, keine Beschriftungen

Der Name wird **nicht** aus `tab.tabItem.label` abgeleitet. Anzeigetexte ändern sich, Ereignisnamen dürfen es nicht — sonst bricht jede Zeitreihe bei der nächsten Umbenennung.

Die Whitelist steht an **zwei Orten**: als Dart-Enum im Client und als Liste in `firestore.rules`. Ein Tippfehler oder ein neu erfundener Name wird serverseitig abgewiesen, nicht stillschweigend gespeichert.

### 5.3 Ereignisliste v1

**Onboarding**
- `onboarding_begonnen`
- `onboarding_beendet`
- `onboarding_abgebrochen_<schritt>` — `<schritt>` aus einer festen, im Code definierten Schrittliste

**Anker-Bereiche**
- `bereich_geoeffnet_<schluessel>` — ein Eintrag pro Anker-Bereich, **einschließlich Halt, Notfall und Hilfe**

  Entscheidung: Die Krisenbereiche werden wie alle anderen gezählt. Ob der Notfallweg gefunden wird, ist die wichtigste Einzelinformation der ganzen Erhebung — ihn auszunehmen würde ausgerechnet dort blind machen, wo ein Fehler am teuersten ist. Aggregiert, ohne Kennung und ohne Uhrzeit ist die Angabe nicht auf einen Menschen zurückführbar.

  **Abgrenzung:** Gezählt wird ausschließlich das **Öffnen** des Bereichs. Das Auslösen eines Notrufs, das Alarmieren von Kontakten und jede Aktion innerhalb der Krisenbereiche erzeugen **kein** Ereignis.

**Übungen**
- `uebung_beendet_<name>`
- `uebung_abgebrochen_<name>`

**Fehler**
- `fehler_speichern`
- `fehler_anhang`
- `fehler_gps_timeout`

  Nur der Name. Kein Stacktrace, kein Dateiname, keine Fehlermeldung. Details bleiben lokal und verlassen das Gerät ausschließlich über den Feedback-Kanal, wenn die Nutzerin sie ausdrücklich mitschickt.

---

## 6. Einwilligung

### 6.1 Rechtsgrundlage

DSGVO Art. 9. Bei Aurora ist jeder Datenpunkt kontextbedingt ein Gesundheitsdatum — allein die Information, dass ein Gerät eine DIS-App nutzt, offenbart eine Verdachtsdiagnose. Ausdrückliche Einwilligung ist zwingend, Opt-out unzulässig.

### 6.2 Neue Nutzerinnen: eigener Onboarding-Schirm

Kein Kästchen in einem Sammelbildschirm, sondern ein eigener Schritt.

- Symbol und Wort, nach Richtlinie 5
- Zwei Knöpfe **gleicher Größe**: „Ja, gerne" und „Weiter ohne". Keine visuelle Bevorzugung, kein Vorabhaken
- Die Einrichtung läuft bei beiden Antworten **identisch** weiter — sonst wäre die Einwilligung nicht freiwillig im Sinne von Art. 9
- Nach Richtlinie 10 steht dort, was passiert: welche Art von Ereignissen, wohin, und dass man es jederzeit ändern kann
- Beispielereignisse werden im Klartext gezeigt, nicht umschrieben

### 6.3 Bestehende Nutzerinnen: einmalige Karte

Onboarding läuft nur bei Neuinstallation. Die rund 40 heutigen Nutzerinnen sähen die Frage nie — die Erhebung begänne bei Nutzerin 41 und wäre monatelang leer.

Deshalb: nach dem Update **einmal** eine Karte auf der Arbeitsfläche, mit demselben Inhalt wie der Onboarding-Schirm. Danach nie wieder, unabhängig von der Antwort. Auch „Weiter ohne" gilt als beantwortet.

Bewusst **kein** dauerhaftes Symbol in der Kopfzeile: Dort sitzen bereits `GpsStatusAction` und die Einstellungen; ein drittes Werkzeugsymbol wäre vom Zahnrad nicht unterscheidbar (Richtlinie 5) und würde als dritte Ebene über dem Inhalt liegen (Richtlinie 1).

### 6.4 Widerruf

Einstellungen → „Was Aurora sendet". Gleicher Ort wie das Übertragungsprotokoll, damit die Wirkung unmittelbar sichtbar ist.

Der Widerruf wirkt **sofort** auf die Erzeugung, nicht erst auf den Versand: Ab dem Umschalten entsteht kein Ereignis mehr, und die lokale Warteschlange wird geleert.

Ein Satz muss dort ehrlich stehen:

> Was bereits gesendet wurde, kann nicht zurückgeholt werden. Es ist dir nicht zugeordnet — deshalb lässt es sich auch nicht finden und löschen.

Das ist der Preis der Anonymität. Er wird genannt, nicht verschwiegen.

---

## 7. Komponenten

### 7.1 `TelemetryEvent` (neu)

Wertobjekt analog zu `FeedbackPayload`. Das Schema ist die Stelle, an der die Kanaltrennung durchgesetzt und getestet wird. Standort- und Kennungsfelder sind strukturell nicht vorgesehen.

Konstruktor nimmt ausschließlich einen Enum-Wert entgegen, keinen freien String.

### 7.2 `TelemetryConsent` (neu)

Einziger Zugriffspunkt auf den Einwilligungszustand. Drei Zustände, nicht zwei:

| Zustand | Bedeutung |
|---|---|
| `ungefragt` | Karte bzw. Onboarding-Schirm steht noch aus |
| `zugestimmt` | Ereignisse werden erzeugt |
| `abgelehnt` | keine Ereignisse; nicht erneut fragen |

`ungefragt` und `abgelehnt` verhalten sich beim Erzeugen identisch. Sie zu trennen ist nötig, damit die einmalige Karte weiß, ob sie schon gezeigt wurde.

### 7.3 `TelemetryRecorder` (neu)

Die einzige Stelle, an der Ereignisse entstehen.

```
TelemetryRecorder.record(TelemetryEventName name)
  → fragt TelemetryConsent
  → bei !zugestimmt: kehrt sofort zurück, ohne etwas anzulegen
  → sonst: legt Eintrag in lokaler Warteschlange an
```

**Entscheidend:** Ohne Einwilligung wird nicht gesammelt-und-nicht-gesendet, sondern gar nichts erzeugt. Eine gefüllte Warteschlange auf einem Gerät ohne Einwilligung wäre bereits die Datenhaltung, die vermieden werden soll.

### 7.4 `TelemetryTransport` (neu)

Folgt `FeedbackTransport` (`lib/services/transport/feedback_transport.dart`), inklusive der dort begründeten Regel: **`isConfigured` wertet keine Compile-Zeit-Konstante aus.** Genau das hat den Feedback-Kanal acht Monate lang stillgelegt.

Nur eine Implementierung: `FirestoreTelemetryTransport`. Ein `mailto:`-Gegenstück gibt es nicht — automatische Ereignisse über den Mail-Client der Nutzerin zu schicken, wäre absurd.

### 7.5 Warteschlange und Versand

Lokale Hive-Box. Versand mit **zufälliger Verzögerung zwischen 0 und 6 Stunden**.

Der Grund ist derselbe wie beim fehlenden Uhrzeitfeld: Würden Ereignisse sofort gesendet, ließen sich mehrere Eingänge derselben Minute serverseitig zu einer Sitzung zusammenfassen. Die Verzögerung zerreißt diesen Zusammenhang, bevor er entsteht.

Offline-Pufferung übernimmt das Firestore-SDK, wie beim Feedback-Kanal. Keine eigene Retry-Logik.

### 7.6 Anbindung an `TransmissionLog`

Der Kanaltyp `telemetry` ist in `transmission_log_entry.dart` bereits modelliert. Jedes gesendete Ereignis erzeugt einen Eintrag mit vollständigem Inhalt im Klartext.

**Folge für den Screen „Was Aurora sendet":** Er füllt sich damit erheblich. Drei Feedbacks würden in vierhundert Telemetriezeilen untergehen. Der Screen bekommt deshalb eine Trennung nach Kanal — zwei Abschnitte mit Überschrift, nach Richtlinie 3 gruppiert statt gefiltert-und-versteckt.

Der leere Zustand behält seine Bedeutung: Wer nicht zugestimmt hat, sieht im Telemetrie-Abschnitt nichts. Das ist der Beleg, nicht ein Fehler.

### 7.7 Aufrufstellen

`TelemetryRecorder.record(...)` wird an den Stellen aufgerufen, die die Ereignisliste vorgibt. Die Aufrufe gehen über `DataEntry`, wie jede andere Datenoperation (siehe `prefer_data_entry_architecture`).

---

## 8. Server

### 8.1 Firestore

Neue Collection `telemetry`, getrennt von `feedback`. Region `europe-west3`, wie bestehend.

**Security Rules sind die einzige Verteidigung** — der API-Key ist aus jedem APK auslesbar:

- `create`-only. Kein `read`, kein `update`, kein `delete`
- Feld-Whitelist: exakt `event`, `day`, `appVersion`. Ein viertes Feld führt zur Ablehnung
- `event` muss in der serverseitigen Namensliste stehen
- `day` muss dem Muster `YYYY-MM-DD` entsprechen — eine Uhrzeit wird abgewiesen
- Größenbegrenzung pro Dokument

### 8.2 App Check ist Vorbedingung, nicht Zubehör

Laut Feedback-Spec Pflicht, im Projekt aber **noch nicht aktiviert** (`appcheck.googleapis.com` fehlt). Bei Telemetrie wiegt das schwerer als bei Feedback: Der Schreibpfad läuft ohne Nutzerhandlung und ist damit ein bequemes Ziel, um die Collection vollzuschreiben — auf Google Cloud unmittelbar Kosten.

**Ohne aktiven App Check wird kein Telemetrie-Ereignis ausgeliefert.**

### 8.3 Kosten

Free Tier: 20 000 Schreibvorgänge pro Tag. Erwartung: 10 Geräte × etwa 30 Ereignisse = ~300 pro Tag. Unkritisch. Budget-Alarm bleibt als zweite Absicherung.

---

## 9. Rechtliches und Store

Beides ist **Freigabeblocker**, nicht Nacharbeit:

- **Play Data Safety** steht derzeit auf „keine Datenerhebung". Mit aktiver Telemetrie ist das falsch und ein Policy-Verstoß mit Entfernungsrisiko. Muss vor Rollout umgestellt sein: App-Aktivität, anonym, nicht geteilt, optional
- **Datenschutzerklärung** ergänzen: welche Ereignisse, welche Felder, Empfänger, Rechtsgrundlage Art. 9 Abs. 2 lit. a, Widerrufsweg, Hinweis auf die Unmöglichkeit nachträglicher Löschung
- **Store-Kurzbeschreibung** („Alle Daten bleiben auf deinem Gerät") ist mit Telemetrie nicht mehr haltbar und muss präzisiert werden

---

## 10. Tests

**Unit**
- Ohne Einwilligung erzeugt `TelemetryRecorder.record` **keinen** Warteschlangeneintrag
- Widerruf leert die Warteschlange und stoppt weitere Erzeugung
- `TelemetryEvent.toMap()` enthält genau drei Schlüssel
- Das Schema hat kein Standortfeld — erweitert den bestehenden Test aus der Feedback-Spec
- `day` enthält keinen Uhrzeitanteil
- Ereignisname stammt aus dem Enum; ein freier String ist nicht konstruierbar
- Client-Whitelist und Rules-Whitelist stimmen überein (Test liest beide Listen)

**Integration**
- Erfolgreicher Versand erzeugt genau einen `TransmissionLog`-Eintrag mit `channel: telemetry`
- Rules weisen ab: `read`, `update`, `delete`, ein viertes Feld, ein unbekannter Ereignisname, ein `day` mit Uhrzeit — gegen die Rules getestet, nicht behauptet
- Versand ohne Netz landet als `pending` und wechselt nach Wiederverbindung auf `sent`

**CI-Gate**
- Tests laufen mit den Parametern des Release-Builds. Schlagen sie fehl, entsteht kein Artefakt
- Build schlägt fehl, wenn kein Telemetrie-Ziel konfiguriert ist

**Manuelle Abnahme**
Release-Build auf ein Gerät, Einwilligung erteilen, ein Ereignis auslösen, Eingang in Firestore bestätigen, Eintrag im Screen „Was Aurora sendet" prüfen, widerrufen, prüfen dass nichts mehr entsteht.

Genau dieser Schritt fehlte am 29.11.2025 und hat den Feedback-Kanal acht Monate lang unbemerkt tot gelassen.

---

## 11. Offene Punkte

### 11.1 Schrittliste des Onboardings

Die feste Liste der Onboarding-Schritte für `onboarding_abgebrochen_<schritt>` ist noch nicht festgelegt. Sie ergibt sich aus dem bestehenden Einrichtungsablauf und wird im Umsetzungsplan bestimmt.

### 11.2 Schlüssel der Anker-Bereiche

Die Anker-Einträge tragen bislang nur Anzeigelabels (`tab.tabItem.label`). Für `bereich_geoeffnet_<schluessel>` braucht jeder Bereich einen stabilen technischen Schlüssel. Der wird im Zuge der Umsetzung ergänzt — er ist ohnehin nützlich, sobald Bereiche umbenannt werden.

### 11.3 Onboarding-Abbrüche sind nur teilweise messbar

Beim Umsetzen aufgefallen: Mit Einwilligung **nach** der Einrichtung wäre Ziel 1
aus Abschnitt 2 unerfüllbar. Wer beim Onboarding abbricht, erreicht die Frage
nie, und der Recorder legt ohne Zustimmung korrekterweise nichts an — die
Ereignisse wären toter Code gewesen.

Der Einwilligungsschirm steht deshalb **direkt nach dem Vorstellungs-Onboarding
und vor der Profilerstellung**. Damit sind Abbrüche ab der Profilerstellung
messbar. Die Abbrüche innerhalb der fünf Vorstellungsseiten bleiben es nicht —
dort ist noch niemand gefragt worden.

Das ist kein Fehler der Umsetzung, sondern eine Grenze des Opt-in-Modells. Die
Alternative wäre, vor der Einwilligung zu sammeln und später nachzureichen — das
ist Datenhaltung ohne Rechtsgrundlage und kommt nicht in Frage.

### 11.4 Zwei Fehlerereignisse ohne Aufrufstelle

`fehler_speichern` und `fehler_anhang` stehen in der Whitelist, sind aber nicht
verdrahtet. Es gibt in der Codebasis keine zentrale Stelle, an der Speicher-
oder Anhangfehler zusammenlaufen; sie an einer von mehreren Stellen aufzuhängen
hätte einen Zähler ergeben, der vollständig aussieht und es nicht ist.

Verdrahtet ist `fehler_gps_timeout` — über einen Callback `onPositionFailed` am
`GpsManager`, damit der Dienst nichts von der Telemetrie weiß.

### 11.5 Auswertung

Wie die Zählerstände tatsächlich gelesen werden — Firestore-Konsole, Export, kleine Abfrage — ist nicht Teil dieser Spec. Bei einigen hundert Dokumenten pro Woche genügt die Konsole zunächst.
