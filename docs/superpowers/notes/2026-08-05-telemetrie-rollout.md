# Telemetrie-Rollout: Checkliste

**Vor dem Store-Upload abzuhaken.** Kein Punkt ist optional — die ersten drei
verhindern Kosten, die letzten drei verhindern einen Policy-Verstoß, und der
letzte verhindert eine Wiederholung des 29.11.2025.

## Firebase

- [ ] **App Check serverseitig erzwingen.** *(Stand 05.08.: vorbereitet — die
      Android-App ist zur Registrierung geöffnet, der SHA-256 des Upload-Keys
      eingetragen. Es fehlt die Play-Integrity-ToS-Checkbox — bewusst dem
      Menschen überlassen — und danach das Erzwingen selbst. Erst nach der
      Geräte-Abnahme erzwingen, sonst testet man gegen die eigene Sperre.)*
      Im Client ist er bereits aktiv:
      `main.dart` ruft `FirebaseAppCheck.instance.activate` mit
      `AndroidProvider.playIntegrity`. Das allein schützt aber nichts — solange
      die Erzwingung („Enforcement") in der Firebase-Konsole für Firestore nicht
      eingeschaltet ist, werden Anfragen ohne gültiges Attest weiterhin
      angenommen. Ohne Erzwingung kann jeder die Collection vollschreiben: Der
      API-Key ist aus jedem APK auslesbar, und auf Google Cloud verursacht das
      unmittelbar Kosten. Bei Telemetrie wiegt das schwerer als bei Feedback,
      weil der Schreibpfad ohne Nutzerhandlung läuft.
- [ ] Play-Integrity-Schlüssel in der Play Console mit dem Firebase-Projekt
      verknüpft — sonst schlägt das Attest im Release-Build fehl und **jeder**
      Schreibvorgang wird abgewiesen, sobald die Erzwingung an ist.
- [x] Regeln veröffentlicht (05.08., 22:56, über den Rules-Editor der Console —
      die CLI war blockiert). Feedback- und Telemetrie-Whitelist sind live,
      alles Übrige bleibt gesperrt. Die Regeln sind ohne Cloud Function die
      einzige Verteidigung.
- [ ] Budget-Alarm auf dem Projekt gesetzt. *(Stand 05.08.: auf dem Spark-Tarif
      gibt es kein Billing-Konto und damit kein Budget — der Punkt wird erst
      mit einem Blaze-Upgrade möglich und nötig.)*
- [x] Datenbank `(default)` liegt in `europe-west3` (Frankfurt), Typ
      FIRESTORE_NATIVE — bestätigt per `firestore:databases:get` am 05.08.

## Store und Recht

- [ ] **Play Data Safety umgestellt:** App-Aktivität, anonym, nicht geteilt,
      optional. Die Angabe steht derzeit auf „keine Datenerhebung". Bleibt sie
      falsch, ist das ein Policy-Verstoß mit Entfernungsrisiko.
- [x] **Datenschutzerklärung veröffentlicht** (06.08., `firebase deploy
      --only hosting`): Stand August 2026 mit dem Abschnitt „Anonyme
      Nutzungsdaten" liegt auf auroa-7f66b.web.app. Die neue Schutzliste in
      `firebase.json` hält die interne Doku (superpowers/, plans/, alle
      Markdown-Dateien) aus dem Deploy heraus — geprüft: .md-Pfade liefern
      nur die SPA.
- [ ] **Store-Kurzbeschreibung geprüft.** „Alle Daten bleiben auf deinem Gerät"
      ist mit Telemetrie nicht mehr haltbar.

## Abnahme auf einem Gerät

Mit einem **Release-Build**, nicht im Debug-Modus. Genau dieser Schritt fehlte
am 29.11.2025 und hat den Feedback-Kanal acht Monate unbemerkt tot gelassen —
dort war der Sendepfad vom Compiler entfernt worden, was nur im Release-Build
sichtbar gewesen wäre.

**Achtung, die Liste unterschätzte das eigene Design:** `TelemetryRecorder.
maxDelay` verzögert jedes Ereignis um 0–6 Stunden Zufall, damit sich Eingänge
derselben Minute nicht zu einer Sitzung verketten lassen. Ein Ereignis ist
nach „App beenden, neu starten" fast nie schon fällig — der Eingang in der
Konsole zeigt sich erst bei einem App-Start **nach Ablauf der Verzögerung**.
Sofort prüfbar ist stattdessen der Feedback-Kanal, der denselben Transport
ohne Verzögerung nutzt.

Stand der Abnahme vom 05.08. (Release-Mode-Build 3.0.14+14 auf einem S24;
wegen des Signaturwechsels als Update mit Debug-Keystore signiert — Release-
Verhalten des Compilers bleibt davon unberührt):

- [ ] Einwilligungsschirm erscheint beim ersten Start nach dem Update
      *(nicht prüfbar: Consent auf dem Testgerät war schon beantwortet; braucht
      eine frische Installation)*
- [x] Beantworteter Consent → Schirm erscheint beim Start **nicht** erneut
- [x] Einwilligung erteilen über den Schalter unter „Was Aurora sendet";
      überlebt einen Neustart
- [x] Einen Bereich öffnen, App beenden, neu starten (Halt, 23:32)
- [ ] Eingang in der Firestore-Konsole bestätigen: genau drei Felder, `day`
      ohne Uhrzeit *(steht aus: Ereignis wird wegen maxDelay erst binnen 6 h
      fällig; am Folgetag nach einem App-Start prüfen)*
- [ ] Eintrag steht unter Einstellungen → „Was Aurora sendet" im Telemetrie-Abschnitt
      *(folgt mit dem ersten tatsächlichen Versand)*
- [ ] Widerrufen → Bereiche öffnen → nach einem Neustart entsteht kein neuer Eintrag
- [x] **Feedback-Kanal Ende-zu-Ende bestätigt:** Testfeedback vom Gerät kam
      um 23:39 als Dokument in der `feedback`-Collection an — drei Felder,
      `createdAt` als Server-Zeit. Firebase-Init, Transport und Rules
      funktionieren im Release-Build.

## Bekannte Lücken

Kein Blocker, aber beim Auswerten mitzudenken:

- **`fehler_speichern` und `fehler_anhang` sind nicht verdrahtet.** Beide stehen
  in der Whitelist, aber es gibt keine zentrale Stelle, an der Speicher- oder
  Anhangfehler zusammenlaufen. Sie an einer von fünf Stellen aufzuhängen wäre
  irreführend — der Zähler sähe vollständig aus, wäre es aber nicht. Verdrahtet
  ist nur `fehler_gps_timeout`.
- **Onboarding-Abbrüche der Vorstellungsseiten sind kaum messbar.** Der
  Einwilligungsschirm steht nach dem Vorstellungs-Onboarding; wer dort schon
  abbricht, wurde nie gefragt und erzeugt korrekterweise nichts. Messbar sind
  Abbrüche ab der Profilerstellung.
- **Stichprobe.** Bei rund 40 Installationen und realistischer Opt-in-Quote
  bleiben 8–16 Geräte. Das gibt Richtung, nie Signifikanz. Ein Mensch, der
  Aurora täglich öffnet, dominiert jede Kurve.
