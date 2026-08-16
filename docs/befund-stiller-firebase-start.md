# Der Schirm sagt „noch nichts gesendet", während die Verbindung steht

Datum: 16.08.2026 · Gefunden beim Nachlesen des Codes nach der
Rückmeldung von u/VagabondTruffle auf r/plural

## Der Widerspruch

**Einstellungen → „Was Aurora sendet"**, erster Satz:

> Hier siehst du jede Übertragung, die dein Gerät verlassen hat —
> vollständig und wörtlich.

Und darunter, für die meisten Menschen:

> Es wurde noch nichts gesendet.

**In `lib/main.dart` stand im Startpfad, ohne Bedingung:**

```dart
await Firebase.initializeApp();
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
);
```

Kein Blick auf die Einwilligung, kein Blick darauf, ob jemals ein Formular
geöffnet wurde. Bei jedem Kaltstart jeder Installation. Damit geht hinaus:

- **Firebase Installations** meldet die Installation bei Google an und holt
  eine **Installations-ID** — eine dauerhafte Kennung je Installation, dazu
  Paketname, App-Version, Plattform und unvermeidlich die IP-Adresse.
- **App Check** tauscht ein Play-Integrity-Urteil gegen ein Token, also eine
  von Google ausgestellte Gerätebescheinigung.

Keines von beidem kannte `TransmissionLogService`. Der Dienst hängt an genau
zwei Stellen (`lib/core/di/injection.dart`, beim `FeedbackSender` und beim
`TelemetryDispatcher`). Was daran vorbeigeht, steht in keinem Protokoll — und
„jede Übertragung" hieß in Wahrheit „jede Übertragung auf den beiden Wegen,
die wir verdrahtet haben".

## Was gleichzeitig falsch dastand

Die drei Regeln aus `AGENTS.md`, Abschnitt „Datenschutz — jeder Verstoß ist
blockierend":

1. **„Nichts verlässt das Gerät ohne ausdrückliche Zustimmung."** Der
   Handschlag lief vor jeder Zustimmung — auch bei jemandem, der die
   Telemetrie ausdrücklich abgelehnt hatte.
2. **„Alles Gesendete ist einsehbar."** Nicht dieser Weg.
3. **„Nichts erlaubt Wiedererkennung: … keine Installations-IDs."** Für die
   Nutzlast stimmte der Satz, und `test/models/feedback_payload_test.dart`
   hält ihn dort fest. Der Transport eine Schicht darunter trug die Kennung.

Dazu `SECURITY.md` („Design commitments you can hold me to", Punkte 1–3) und
`docs/play-data-safety.md` („Der Payload trägt … keine Installations-ID" —
richtig, nur fragt das Play-Formular nicht nach der Nutzlast, sondern nach
der App).

Und der Satz aus der Ankündigung auf r/plural: „The only thing that ever gets
sent is feedback you write yourself."

## Wie schwer das wiegt, ehrlich in beide Richtungen

Was hinausging, ist eine pseudonyme Installationskennung und eine
Gerätebescheinigung. **Kein Anteilsname, keine Nachricht, kein Zähler, nichts
aus irgendeiner Box.** Google ist hier Auftragsverarbeiter. Niemand wird durch
eine Installations-ID geoutet, und wer diesen Befund als „die App sendet deine
Daten an Google" wiedergibt, gibt ihn falsch wieder.

Trotzdem ist es derselbe Fehler wie am 13.08.2026, und aus demselben Grund
schwer:

- **Es ist eine Aussage, keine Unterlassung.** Der Schirm behauptet aktiv, es
  sei nichts gesendet worden. Er ist genau dafür gebaut, nachprüfbar zu sein.
- **Es ist die Kernzusage.** „Alles bleibt lokal" ist das Produkt.
- **Der zweite Schaden ist die Verkettung.** Das Telemetrie-Schema kürzt den
  Zeitstempel bewusst auf den Tag, damit sich mehrere Eingänge derselben
  Minute nicht zu einer Sitzung zusammensetzen lassen. Jede Telemetrie-
  Übertragung wird aber von einem App-Check-Token derselben Installation
  begleitet, und die trägt eine sekundengenaue Uhrzeit in fremden
  Protokollen. Die sorgfältige Entkettung im Schema wird eine Schicht tiefer
  wieder aufgehoben — an der Schicht, die niemand angesehen hat.
- **Niemand sieht es.** Nicht die Nutzerin, nicht ein Grep nach `send`, nicht
  ein Schema-Test. Bei Plattform-Vorgängen ist die Abwesenheit die Aussage.

## Was getan wurde

**Der Start wandert in den Sendeweg.** Neu:
`lib/services/transport/firebase_start.dart`. `FeedbackSender` und
`TelemetryDispatcher` rufen ihn selbst, bevor sie den Firestore-Weg
versuchen.

Das ist bewusst nicht „den Handschlag ins Protokoll schreiben". Findet er erst
beim Senden statt, ist er Teil einer Übertragung, die ohnehin protokolliert
wird — und der Schirm stimmt wieder wörtlich, ohne einen neuen Kanal, den fünf
Sprachen erklären müssten.

**Der Dispatcher sieht zuerst in die Warteschlange.** Steht nichts an, wird
das Netz nicht angefasst. Das ist die halbe Wirkung: Wer die Telemetrie
abgelehnt hat, zeichnet nichts auf, hat nie etwas Fälliges — und für den
ändert sich damit gar nichts mehr, nie.

**Die Reihenfolge in `FeedbackSender` ist zwingend.**
`primary.isConfigured` fragt über `firestoreHatZiel()` die laufende
Firebase-App ab und ist vor dem Start immer `false`. Ohne den Startaufruf
davor ginge jedes Feedback still über die Mail-App, obwohl Firestore
erreichbar wäre — dieselbe Sorte stiller Ausfall wie die acht Monate am
Rückkanal.

**Das Manifest schaltet die Sammlung ab.**
`firebase_data_collection_default_enabled=false` deckt ab, was geschieht,
*nachdem* Firebase gestartet wurde.

**Bewacht von `test/core/keine_stille_verbindung_test.dart`.** Der Test prüft,
dass `main.dart` weder `Firebase.initializeApp` noch `FirebaseAppCheck` noch
den `firebase_core`-Import enthält, dass beide Sendewege den Starter wirklich
rufen, und dass das Manifest-Attribut auf `false` steht — nicht bloß dasteht.
Drei neue Fälle in `test/services/telemetry_dispatcher_test.dart` halten fest,
dass eine leere oder noch nicht fällige Warteschlange keinen Handschlag
auslöst.

## Zwei weitere Funde aus demselben Durchgang

**Der Bildschirminhalt war ungeschützt.** `FLAG_SECURE` stand nirgends. Der
Weg, an den niemand denkt, ist nicht das Bildschirmfoto, sondern das
Vorschaubild im App-Wechsler: Android hält den letzten Schirm fest und legt
ihn auf die Platte. Wer die Übersichtstaste drückt, sieht die Anteilsliste
mit Namen — ohne die App zu öffnen, ohne Passwort. Gesetzt in
`MainActivity.onCreate`. Preis: Abfotografieren aus der App heraus geht nicht
mehr, und Android sagt das beim Versuch. Ein Schalter in den Einstellungen
wäre die vollständige Antwort und fehlt noch.

**Die Kennung nannte die Diagnose.** Aurora stellte sich fremden Servern als
`Aurora DIS App` und `com.aurora.dis_app` vor — bei der Adresssuche, bei den
Kartenkacheln und bei der Rückwärtssuche im Notfallbereich, dort zusammen mit
den genauen Koordinaten. Nominatim verlangt eine identifizierende Kennung, das
war also kein Versehen; die Wirkung war trotzdem, einem fremden Protokoll
mitzuteilen, dass unter dieser IP-Adresse ein Mensch mit dieser
Verdachtsdiagnose sitzt. Jetzt eine gemeinsame Kennung in
`lib/constants/netz_kennung.dart`, die den Betreiber nennt und die Diagnose
verschweigt.

## Offene Punkte, ehrlich benannt

- **Nicht am Gerät nachgemessen.** Anders als beim Cloud-Sicherungs-Befund,
  der gegen das gebaute APK und ein Galaxy S24 geprüft wurde, steht dieser
  Befund bisher nur auf dem Quelltext und dem dokumentierten Verhalten von
  `firebase_core` und `firebase_app_check`. **Vor der Veröffentlichung mit
  einem Netzmitschnitt gegenprüfen** — erst der Mitschnitt macht aus der
  Herleitung einen Befund, und der Vorher-Wert ist der Beleg, dass es kein
  Papierbefund war.
- **Wirksam wird es erst mit dem nächsten Release.** Bis dahin gilt auf jedem
  installierten Gerät weiter der alte Startpfad — genau wie bei der
  Cloud-Sicherung.
- **Was bei Google liegt, räumt der Fix nicht auf.** Aurora läuft seit rund
  einem Jahr. Welche Installationskennungen dort in welchen Protokollen
  stehen und wie lange, ist von hier aus nicht nachgemessen.
- **Der erste Feedback-Versand dauert jetzt länger.** Der Handschlag liegt im
  Sendeweg statt im Start. Für ein Formular, das der Mensch bewusst absendet,
  ist das der richtige Ort — aber es ist eine spürbare Sekunde, und wenn sie
  zu lang wird, gehört sie in die Oberfläche gemeldet statt versteckt.
- **`puzzle_image_service.dart` bleibt vorerst.** Es holt Bilder von
  `source.unsplash.com`, einem 2023 abgeschalteten Dienst, aus einem Knopf im
  Puzzle-Bildwähler heraus. Ein dritter Netzweg in einer App, die „offline"
  sagt — aber ihn zu entfernen heißt, Bedienelemente und Übersetzungen zu
  entfernen, und das gehört nicht in einen Sicherheits-PR.

## Wie es gefunden wurde

Nicht durch Lesen von `main.dart` — dort stand es offen und war monatelang
niemandem aufgefallen. Sondern dadurch, dass jemand von außen die Zusagen
gegen das Gebaute gehalten hat und drei davon nicht hielten. Der Weg von dort
war: Welche Zusagen gibt es noch → welche Wege gibt es nach draußen →
decken sich beide Listen.

Sie decken sich nicht, sobald man die Wege nicht bei `send()` sucht.
