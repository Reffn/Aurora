# AGENTS.md

Aurora ist eine Flutter-App für Menschen mit Dissoziativer Identitätsstörung.
Sie verwaltet Anteile, innere Kommunikation, Termine, Medikamente und einen
Notfallbereich. Alle Daten liegen lokal in Hive.

Diese Datei richtet sich an automatische Prüfer. Die vollständigen
Entwicklungsregeln stehen in `CLAUDE.md`, die Oberflächenregeln in
`docs/oberflaechen-richtlinien.md`.

## Code Review Rules

Der Reviewer prüft in dieser Reihenfolge. Was weiter oben steht, wiegt schwerer.

### 1. Datenschutz — jeder Verstoß ist blockierend

In dieser App ist **jeder Datenpunkt ein Gesundheitsdatum**, allein durch den
Kontext (DSGVO Art. 9). Drei Regeln ohne Ausnahme:

- **Nichts verlässt das Gerät ohne ausdrückliche Zustimmung.** Feedback löst der
  Mensch aus und braucht deshalb kein Opt-in; Telemetrie läuft automatisch und
  braucht es zwingend.
- **Alles Gesendete ist einsehbar** unter Einstellungen → „Was Aurora sendet",
  wörtlich und lokal gespeichert.
- **Nichts erlaubt Wiedererkennung**: keine Profil-IDs, keine Installations-IDs,
  keine Sitzungsketten, keine Eintragszahlen.

**Standort erreicht uns nie.** Nicht im Feedback, nicht in der Telemetrie, nicht
gerundet, nicht als Land. Ein neues Feld in einer Nutzlast, das direkt oder
mittelbar einen Ort trägt (`lat`, `lon`, `coords`, `place`, `city`, `country`,
`geo`, `address`, `plz`), ist ein Befund — auch wenn es optional ist. Der Test
`test/models/feedback_payload_test.dart` („erlaubt kein Standortfeld im Schema")
hält das fest; wer ihn lockert, muss das im PR begründen.

Koordinaten dürfen **nur** an OpenStreetMap gehen, für Karte und Geokodierung
(`geocoding_service.dart`, `overview_map.dart`), und an Kontakte, die der Mensch
im Notfallbereich selbst auswählt.

Neue Netzwerkziele, neue Felder in gesendeten Nutzlasten und Änderungen an
`firestore.rules` sind immer ein Prüfpunkt, nie eine Nebensache.

### 2. Keine Geheimnisse und keine Schalter zur Übersetzungszeit

Eine leere `const`-Konstante lässt den Compiler den ganzen Codepfad löschen —
lautlos, zur Laufzeit unsichtbar. Das ist einmal passiert und hat den
Feedback-Rückkanal acht Monate tot gelegt
(`docs/superpowers/specs/2026-08-04-feedback-rueckkanal-design.md`).

Transportziele sind **Laufzeitkonfiguration**. Ein `const X = String.fromEnvironment(...)`,
das als Bedingung über einem Codepfad steht, ist ein Befund. CI muss den
Release-Build brechen, wenn kein Ziel konfiguriert ist.

### 3. Architektur

- **Alle Datenoperationen laufen über `DataEntry`** (`lib/core/data_entry.dart`).
  Kein direkter Service-Zugriff aus der Oberfläche (Lint `no_direct_service_access`).
- **GPS nur über den Standortdienst**, nie direkt über das Plugin (`no_direct_gps_access`).
- **Benachrichtigungen nur über den eigenen Dienst** (`no_direct_notification_plugin`).
  `flutter_local_notifications` bringt keine Broadcast-Receiver mit; wer daran
  vorbeigeht, baut Alarme, die lautlos ins Leere feuern.
- **Erinnerungsregeln fragen keine Uhr ab** (`no_clock_in_reminder_rules`) —
  sonst ist das Verhalten nicht testbar.
- **Kein `Future` in `build()`** (`no_future_in_build`).
- **Kein Listener auf `*SavedEvent`** (`no_saved_events_listener`). Stattdessen
  `ValueListenableBuilder` mit `service.box.listenable()`.
- **Wunsch und Lauf sind zwei Dinge** (`no_raw_tracking_flag`). Der Schlüssel
  `gps_tracking_enabled` trägt den **Wunsch** und gehört ausschließlich dem
  `LocationTrackingService`. Wer wissen will, ob gerade aufgezeichnet wird,
  fragt `isTrackingRunning` — nie den Wunsch. Die Verwechslung hat die
  Aufzeichnung stillgelegt, während die Oberfläche „aktiv" anzeigte.

Prüfen mit `dart run custom_lint`.

**Die Identitätsfarbe ist frei wählbar — von fast Schwarz bis Weiß.** Drei
Werkzeuge, drei Fragen:

- `AppColors.onColor(hintergrund)` — was **auf** einer Farbe lesbar bleibt.
  Nie `Colors.white` fest auf eine Profilfarbe schreiben.
- `AppColors.onDarkSurface(farbe)` — die Farbe als **gefüllte Fläche** auf
  dunklem Grund. Deckelt bei Helligkeit 0.62, weil die Halt-Fläche
  (`AppColors.go`) bei 0.66 liegt: „wer bin ich gerade" darf nie lauter sein
  als „wo ist Hilfe" (Regel 4 der Oberflächen-Richtlinien).
- `AnchorRow.onDark(farbe)` — hebt eine zu **dunkle** Farbe als Akzent an.

Gilt für Flächen, **nicht** für Ränder und Schrift: die Chat-Blase trägt die
rohe Farbe als 3-px-Rand, und ein Rand schreit nicht. Kein Befund ist weiße
Schrift auf einer **festen** dunklen Fläche — davon lebt die ganze App.

Gefunden wurde das dreimal am selben Profil mit der Farbe Weiß: unsichtbare
Initialen, ein weißes Reset-Band mit weißer Schrift, und ein reinweißer
60-px-Pinselknopf als lautestes Element des Schirms.

**Ergebnisse mit `@useResult` dürfen nicht verworfen werden.** Betrifft
`deleteAllLocalData()`: ein Teilerfolg beim Löschen ist kein Erfolg, und ein
Neustart darüber hinweg behauptet das Gegenteil. `unused_result` gilt als
`error`.

### 4. Fallen, die diese App schon getroffen haben

- **UTF-16:** Bei nutzererzeugten Zeichenketten (Namen, Nachrichten) niemals
  `name[0]`. Emojis zerlegen das. Immer `name.runes`.
- **Relative Pfade:** In der Datenbank stehen relative Dateinamen
  (`avatar_123.jpg`), nie absolute. Auflösung zur Laufzeit über
  `AttachmentHelper.getAttachmentFile()`.
- **Hive:** Feldnummern werden nie neu vergeben oder umsortiert. Nach jeder
  Modelländerung `build_runner`.
- **R8 wirft generische Signaturen weg.** Im Android-Teil verliert Gson bei
  aktivem R8 die Typparameter — der Absturz zeigt sich **nur** nach einem Update
  (`adb install -r`), nie bei Erstinstallation. Neue Datenklassen im
  Erinnerungs-Empfänger brauchen ihre Keep-Regel.
- **Kennungen tragen den Zeitpunkt.** Wird eine geplante Meldung verschoben, muss
  die Kennung alles enthalten, was das System hält — sonst bleibt die alte
  Meldung lautlos auf der alten Zeit stehen.
- **Berechtigungs-Umbauten sind nie lokal.** Wird eine Berechtigung geändert,
  muss **jede** Stelle mitgezogen werden, die den alten Zustand abfragt. Grüne
  Tests belegen die Technik, nicht die Erreichbarkeit der Funktion.
- **`logger.error` hat keinen `error:`-Parameter.** Nur `data` und `stackTrace`;
  die Ausnahme geht durch `data`.

### 5. Oberfläche

Vor jedem Schirm gilt `docs/oberflaechen-richtlinien.md` — elf Regeln, jede mit
ihrer Quelle (W3C COGA, WCAG 2.2, UK Home Office, mHealth-Farbstudien). Am
häufigsten gebrochen:

- **Regel 2 — Wahlfläche ist nicht Arbeitsfläche.** Wo gewählt wird, wird nicht
  gearbeitet.
- **Regel 4 — Sättigung hat eine Aufgabe.** Kräftige Farbe ist dem vorbehalten,
  was im schlechtesten Zustand gefunden werden muss. Sie ist kein Schmuck.
- **Regel 5 — das Bild trägt, das Wort bestätigt.** Jede Handlung muss ohne
  Lesen bedienbar sein.

Ton: die App ist ein Freund, warm und zugewandt. Nüchtern bleibt nur der Halt-
und Notfallbereich.

Berechtigungen (`lib/models/permission.dart`) werden vor jeder Aktion in der
Oberfläche geprüft, nicht danach.

### 6. Was kein Befund ist

- Deutsche Bezeichner in Kommentaren, Dokumentation und Commit-Nachrichten. Das
  ist die Projektsprache.
- Deutsche Zeichenketten in der Oberfläche ohne `l10n`-Schlüssel, sofern die
  Datei noch nicht übersetzt ist — das ist bekannt und wird gebündelt erledigt.
- Formatierung, die `dart format` durchgehen lässt.
- Vorschläge, Abstraktionen einzuziehen, die es noch nicht braucht.

## Prüfen

```
flutter analyze
dart run custom_lint
flutter test
```

Ein Befund gehört an die Zeile, die ihn auslöst, mit dem Fehlerfall in einem
Satz: welche Eingabe, welches falsche Ergebnis. Vermutungen werden als solche
benannt.
