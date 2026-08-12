# Play Data Safety — was im Formular steht

Google fragt im Play-Console-Formular „Datensicherheit" nicht, was auf dem
Gerät passiert, sondern was das Gerät **verlässt**. Für Aurora sind das zwei
Wege: abgesendetes Feedback und — nach ausdrücklicher Zustimmung — Telemetrie.
Alles andere bleibt lokal.

Diese Datei ist die Vorlage zum Ausfüllen. Sie ist aus dem Code abgeleitet,
nicht aus Erinnerung: Was gesendet wird, steht in
`lib/models/feedback_payload.dart` und `lib/models/telemetry_event.dart`, und
was der Server annimmt, in `firestore.rules`. Ändert sich eines davon, gehört
diese Datei mit geändert.

## Sammelt oder teilt die App Nutzerdaten?

**Ja.** Nicht automatisch, aber die Frage unterscheidet das nicht: Sobald ein
Mensch das Feedback-Formular absendet, verlassen Daten das Gerät.

## Telemetrie (seit 3.0.14)

Telemetrie ist **Opt-in**: Ohne ausdrückliche Zustimmung wird nichts
aufgezeichnet und nichts gesendet. Der Ausgangszustand ist `ungefragt`, und
nur `zugestimmt` erlaubt das Aufzeichnen
(`lib/services/telemetry_consent.dart`). Das ist keine Höflichkeit, sondern
Pflicht: In einer App für Menschen mit DIS ist jeder Datenpunkt
kontextbedingt ein Gesundheitsdatum (DSGVO Art. 9), und automatische
Erhebung braucht deshalb eine Einwilligung.

Ein Ereignis trägt genau drei Felder — Ereignisname, **Tag** (nicht Uhrzeit)
und App-Version. Die Uhrzeit fehlt bewusst: Mit Sekundengenauigkeit ließen
sich Ereignisse desselben Geräts über Zeitnähe wieder zu einer Sitzung
verketten. Keine Kennung, kein Zähler, keine Sitzung, kein Standort.

Fürs Formular ändert das **keine Kategorie**: Ereignisname und App-Version
fallen unter „App-Info und Leistung → Diagnose", das bereits als „Ja,
optional, Fehleranalyse" gemeldet ist. Neue Datentypen entstehen nicht.
Was sich ändert, ist die Begründung: Diagnose wird jetzt auch ohne
Feedback-Formular gesendet — nach Zustimmung.

## Datentypen

| Kategorie | Typ | Erhoben | Geteilt | Pflicht? | Zweck |
|---|---|---|---|---|---|
| Personenbezogene Daten | E-Mail-Adresse | Ja | Nein | Optional | Support, Rückfrage zum Feedback |
| App-Aktivität | Andere Aktionen (Feedbacktext) | Ja | Nein | Optional | Support, App-Funktionalität |
| App-Info und Leistung | Absturzprotokolle | Ja | Nein | Optional | Support, Fehleranalyse |
| App-Info und Leistung | Diagnose | Ja | Nein | Optional | Support, Fehleranalyse |

„Optional" ist hier wörtlich zu nehmen: Ohne abgesendetes Formular wird
nichts davon erhoben. Die E-Mail-Adresse ist auch innerhalb des Formulars
freiwillig.

**Geteilt: nirgends Ja.** Google Firebase ist Auftragsverarbeiter, kein
Empfänger im Sinne des Formulars — Google zählt eigene Infrastruktur-Dienste
ausdrücklich nicht als „geteilt".

## Was ausdrücklich NICHT anzugeben ist

- **Standort.** Nicht grob, nicht genau. Koordinaten gehen ausschließlich an
  OpenStreetMap für Kartenkacheln und Adresssuche; im Notfallmodul an
  Kontakte, die die Nutzerin selbst auswählt. Nichts davon erreicht uns, und
  ein Test hält die Zusage im Schema fest.
- **Fotos und Videos.** Kein Sendeweg trägt Bilder: Die Feld-Whitelist kennt
  kein Bildfeld, und mailto kann nichts anhängen. Die beiden Steuerelemente,
  die das versprachen, sind entfernt. Sollen Bilder mitgehen, braucht es Cloud
  Storage und eine Regel dafür — und dann muss diese Zeile mit.
- **Geräte- oder andere IDs.** Der Payload trägt keine Profil-ID, keine
  Installations-ID und keine Sitzungskennung. Absichtlich: In einer App für
  Menschen mit DIS ist jeder Datenpunkt kontextbedingt ein Gesundheitsdatum,
  und ohne Kennung lässt sich keine Kette bilden.
- **Gesundheit und Fitness.** Nichts aus Tagebuch, Chat, Kalender oder
  Medikamenten verlässt das Gerät.
- **Kontakte, Kalender, Dateien, Audio.** Bleiben lokal.

## Sicherheitsangaben

- **Verschlüsselung bei der Übertragung:** Ja. Das Firestore-SDK spricht
  ausschließlich TLS; der E-Mail-Weg übergibt an die Mail-App des Systems.
- **Löschung auf Anfrage:** Ja, per E-Mail an die im Impressum genannte
  Adresse. Abgesendetes Feedback trägt keine Kennung, deshalb ist eine
  Zuordnung nur möglich, wenn eine Antwortadresse angegeben wurde — das
  gehört so in die Antwort.
- **Unabhängige Sicherheitsprüfung:** Nein.

## Erledigt

Das Feedback-Formular bot „Bild anhängen", der Fehlerdialog einen Haken
„Screenshot mitsenden". Beide landeten in keinem Sendeweg. Entfernt in
`33fc4c3` — ein Steuerelement, das etwas verspricht und nicht hält, ist die
Sorte Fehler, die diesen ganzen Umbau ausgelöst hat.
