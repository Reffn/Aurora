# Schnittstellen-Notiz: Feedback-Rückkanal

Stand 2026-08-04, Branch `feature/feedback-rueckkanal`.
Für die Session, die Tasks 10b, 11 und 12 übernimmt (Oberfläche und Bedienung).

Der technische Unterbau steht. Diese Notiz beschreibt, was da ist und wie es
benutzt wird — damit niemand die Dateien lesen muss, um loszulegen.

## Was fertig ist

| Task | Was |
|---|---|
| 3 | `FeedbackPayload` — das, was gesendet wird |
| 4 | `FeedbackTransport` — die Abstraktion |
| 5 | `MailtoTransport` — öffnet die E-Mail-App |
| 6 | `TransmissionLogService` — lokales Protokoll jeder Übertragung |
| 7 | Debug-Report enthält keine Profil-IDs und keine Bestandszahlen mehr |
| 8 | `FirestoreTransport` — schreibt direkt nach Firestore |
| 9 | CI-Tor: kein Release-Artefakt ohne konfigurierten Transport |
| 10 | GitHub-Sendeweg vollständig entfernt |

## Die Schnittstelle

`lib/services/transport/feedback_transport.dart`

```dart
abstract class FeedbackTransport {
  bool get isConfigured;
  String get displayName;
  Future<TransportResult> send(FeedbackPayload payload);
}
```

`TransportResult` hat `outcome` (`TransportOutcome.sent` / `.pending` / `.failed`)
und `reason` (String, bei Fehlschlag gefüllt). Konstruktoren:
`TransportResult.success()`, `.pending()`, `.failure(String reason)`.

`pending` heißt: Firestore hat den Schreibvorgang lokal übernommen und stellt
ihn zu, sobald wieder Verbindung besteht. Für die Nutzerin ist das kein Fehler,
aber auch keine Bestätigung — der Ergebnis-Screen braucht dafür einen eigenen
Zustand, nicht denselben wie `sent`.

## Die beiden Transporte

| | `FirestoreTransport` | `MailtoTransport` |
|---|---|---|
| Datei | `lib/services/transport/firestore_transport.dart` | `lib/services/transport/mailto_transport.dart` |
| `displayName` | `'Direkt an die Entwickler'` | `'E-Mail'` |
| `isConfigured` | `false`, wenn Firebase nicht bereitsteht (wirft nicht) | immer `true` |
| Fehlerfall | `failure` mit lesbarer Begründung | `failure`, wenn keine E-Mail-App reagiert |

**Beide sind nicht in der DI registriert.** `lib/core/di/injection.dart` kennt
nur `TransmissionLogService` (Zeile 418). Wenn ihr sie über GetIt beziehen
wollt statt sie zu instanziieren, sagt Bescheid — das gehört zum technischen
Teil und ist in fünf Minuten gemacht. Ich greife nicht vor, weil Task 11
entscheidet, wie das Formular an seinen Transport kommt.

## Das Protokoll

`TransmissionLogService` (in der DI vorhanden) hält jede Übertragung lokal
fest: Zeitpunkt, Kanal, vollständiger Payload-Text, Status, Fehlermeldung.
Das ist die Grundlage für Task 12, den Screen „Was Aurora sendet". Der Screen
zeigt, was tatsächlich gesendet wurde — wörtlich, nicht zusammengefasst.

## Was beim Bauen zählt

Der ursprüngliche Schaden war nicht der tote Kanal, sondern die Lüge darüber.
`feedback_screen.dart` prüfte ehrlich, ob der Sendeweg konfiguriert war, setzte
eine ehrliche Meldung — und überschrieb sie eine Zeile später mit „Feedback
kopiert".

Daraus für die Oberfläche:

- Keine Erfolgsmeldung, wo nichts gesendet wurde. Kopieren in die Zwischenablage
  ist kein Senden und darf nicht so aussehen.
- `result.reason` gehört angezeigt, nicht verschluckt.
- Bei Fehlschlag muss der geschriebene Text erhalten bleiben. Aurora-Nutzerinnen
  schreiben teils in belastenden Momenten; ein verlorener Text ist ein echter
  Schaden.
- Keine Meldung darf eine spätere überschreiben.

## Was noch in euren Dateien liegt

Die CI war seit mindestens 16.11.2025 durchgehend rot — auch am 29.11.2025, dem
Tag des Releases mit dem toten Feedback-Kanal. Ursache war kein echter Fehler:
`custom_lint` bricht bei jeder Ausgabe ab, `flutter analyze` behandelt Infos als
fatal. Dahinter standen Analyse und Testlauf, die dadurch monatelang nie liefen.

Das ist repariert, und der committete Stand ist sauber: 137 Analyzer-Warnungen
sind auf 0 gefallen, `custom_lint` von 65 auf 0, die Testsuite läuft in CI
wieder durch. Eure Dateien habe ich mitgenommen, sobald ihr sie committet
hattet — bis dahin blieben sie unangetastet.

**Zwei Dinge in eurem noch nicht committeten Grounding-Modul** wird die CI
melden, sobald ihr es einbucht:

| Datei | Art |
|---|---|
| `lib/modules/grounding/widgets/exercise_done_sheet.dart:23` | überflüssiges `!` |
| `lib/modules/grounding/widgets/step_view.dart:28` | überflüssiges `!` |

`AppLocalizations.of(context)` liefert längst einen nicht-nullbaren Wert, das
`!` dahinter ist wirkungslos:

```
dart fix --apply --code=unnecessary_non_null_assertion <datei>
```

**Zwei Warnungen genügen, um die CI rot zu machen** — und dann läuft
`release-gate` nicht, also auch die Prüfung nicht, ob die Sendewege den
Compiler überlebt haben. Genau dieser Zustand hat den Ausfall vom 29.11.2025
durchgelassen.

## Was die lokale Analyse nicht sieht

`flutter analyze` auf dem Entwicklungsrechner ist keine verlässliche Abnahme.
Zwei Beispiele aus einem einzigen Tag:

- Ein Aufräumlauf entfernte eine Typangabe; der Compiler leitete `Object` ab
  und ein Methodenaufruf ging ins Leere. Die Analyse meldete null Fehler,
  erst `flutter test` brachte es.
- `orElse: () => null as dynamic` in `medication_detail_screen.dart` meldete
  lokal null Fehler, derselbe Aufruf auf dem CI-Runner meldete
  `return_of_invalid_type_from_closure`.

Verlasst euch auf `flutter test` und die CI, nicht auf die lokale Analyse
allein.

## Zwei Bitten

**Dateien einzeln stagen, kein `git add -A`.** Commit `be03a9b` hat
Dateilöschungen aus einer laufenden Aufgabe der anderen Session mitgenommen.
Diesmal harmlos — beim nächsten Mal landet halbfertiger Code in einem fremden
Commit, der grün aussieht und es nicht ist.

**Die beiden Marker im CI-Tor nicht verschieben.** `.github/workflows/test.yml`
sucht im gebauten Artefakt nach zwei Zeichenketten, die belegen, dass die
Sendewege den Compiler überlebt haben:

- `Feedback wartet auf Verbindung` — `firestore_transport.dart:58`
- `Du kannst den Text kopieren und manuell senden.` — `mailto_transport.dart:49`

Wandern diese Texte in die Übersetzungsdateien, stehen sie außerhalb der
Transport-Klassen und beweisen nichts mehr. Wenn ihr sie übersetzen wollt,
sagt vorher Bescheid — dann suchen wir zwei neue Marker, bevor das Tor
stillschweigend wertlos wird.

## Nachtrag 05.08.2026 - ein Sendeweg fuer alle drei Formulare

`getIt<FeedbackSender>().send(payload)` ist ab sofort der einzige Aufruf,
den ein Formular zum Senden braucht. Er waehlt den Weg (Firestore, sonst
E-Mail) und schreibt jeden Versuch ins Uebertragungsprotokoll. Baut den Ablauf
bitte nicht wieder von Hand nach - genau daran ist das Bottom-Sheet vorbei
gelaufen: Es hat seine mailto-Adresse selbst gebaut und tauchte deshalb nie in
"Was Aurora sendet" auf.

Was das fuer Task 10b heisst:

- Alle drei Formulare rufen jetzt denselben Sender. Was noch dreifach da ist,
  ist die Oberflaeche, nicht die Technik.
- Die Snackbar-Texte im Bottom-Sheet nach dem Senden habe ich nur sachlich
  richtig gestellt (vorher stand dort "E-Mail-Client geoeffnet", auch wenn der
  Text zu Firestore ging). Gestaltet sind sie nicht - das gehoert euch.
- `FeedbackPayload` ist keine const-Klasse mehr, sondern eine Factory: Sie
  kuerzt jedes Feld auf die Grenzen aus firestore.rules. `const
  FeedbackPayload(...)` kompiliert nicht mehr, `FeedbackPayload(...)` schon.
- Ein Fehlerbericht gehoert in `diagnostics`, nicht in `message`. In
  `message` passen 5000 Zeichen, ein Absturzbericht ist groesser.

Wenn ihr Formulartexte anfasst: Die Aussage "keine Cloud, keine Server, keine
Uebertragung" ist seit a9685b2 aus dem Onboarding, dem Berechtigungsdialog,
dem GPS-Hinweis und dem Tipp-Karussell raus. Sie stimmt nicht mehr, sobald
jemand Feedback abschickt. Bitte nicht versehentlich wieder einfuehren.

## Nachtrag 05.08.2026 (2) - zwei Steuerelemente ohne Wirkung

Beim Nachziehen der Datenschutzangaben aufgefallen, gehoert in Task 10b:

- `feedback_screen.dart` laesst ein Bild anhaengen (`_attachedImagePath`).
- `error_report_dialog.dart` zeigt einen Haken "Screenshot beifuegen"
  (`_includeScreenshot`).

Beides wird nie gesendet. Firestore hat kein Bildfeld in der Whitelist, und
mailto kann nichts anhaengen. Die Bilder werden erzeugt, angezeigt, und
bleiben liegen. Das ist dieselbe Sorte Zusage wie der tote Kanal: Die
Oberflaeche sagt, sie tue etwas, und tut es nicht.

Drei Wege, alle drei eure Entscheidung: weg damit, ehrlich beschriften
("bleibt auf deinem Geraet"), oder Bilder wirklich mitschicken - Letzteres
braucht Cloud Storage plus Regel und einen neuen Eintrag in
docs/play-data-safety.md.
