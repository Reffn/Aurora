# UI-Testdurchlauf am Gerät — 4. August 2026

Vollständiger Durchlauf auf SM-S921B (Android 15, 1080×2340), Debug-Build,
frisch installiert. Weg: Sprachauswahl → Onboarding → Profil anlegen →
Profil wechseln → Hauptbildschirm → Kalender → Medikamente → Medikament
anlegen. Jeder Schritt per Screenshot geprüft.

## In diesem Durchlauf behoben

**Formularprüfung lief ins Leere (5 Formulare).** `Form` umschloss eine
`ListView`. Die baut nur sichtbare Kinder; ein ausgescrolltes
`TextFormField` meldet sich beim `Form` ab, sein `validator` läuft bei
`validate()` nicht mehr mit, und die Methode meldet Erfolg für ein leeres
Pflichtfeld. Da der Speichern-Knopf unten sitzt und die Pflichtfelder oben,
trat das immer auf, sobald ein Formular länger als ein Bildschirm war. Die
Eingabe rutschte durch bis in die Persistenzschicht, und statt der
Feldmeldung erschien `Invalid argument(s): Dosierung darf nicht leer sein`.
Betroffen: Kalender, Kontakte, Tagebuch, Finder, Medikamente. Ersetzt durch
`FormScrollView` (`lib/widgets/form_scroll_view.dart`), abgesichert durch
drei Tests — einer davon hält das `ListView`-Fehlverhalten fest, damit der
Grund für das Widget nachvollziehbar bleibt.

**Kein Hinweis, was fehlt.** `validate()` färbt das Feld rot, scrollt aber
nicht dorthin. Wer unten auf „Erstellen" tippte, sah gar keine Reaktion.
Der Fokus auf das erste leere Pflichtfeld zieht den Scrollbereich mit.

**Überlauf in der Foto-Zeile.** `RIGHT OVERFLOWED BY 8.5 PIXELS`. Bestand
vorher schon, wurde von der `ListView` nur stillschweigend abgeschnitten.
`Wrap` statt `Row` bricht stattdessen um und trägt auch große Schriftgrößen.

**Leerzustand wurde vom „+"-Knopf verdeckt.** „Tippe auf +, um einen Ort
hinzuzufügen" endete im Finder bei „einen Ort hi", im Medikamente-Tab
entsprechend. Ein leerer Zustand scrollt nicht, der verdeckte Teil war also
dauerhaft unerreichbar — ausgerechnet bei dem Satz, der auf den Knopf
verweist. `AnimatedEmptyState` hält den Platz jetzt selbst frei, das wirkt
für alle acht Aufrufer.

## Frühere Fixes am Gerät bestätigt

- Sprachauswahl: „Next" ist erkennbar gesperrt, bis eine Sprache gewählt ist
- Tastatur verdeckt die Namenszeile in der Profilerstellung nicht mehr
- „Profil wechseln" ist auf dem Regenbogenverlauf lesbar
- Kein Standortdialog mehr beim Blättern durch die Tabs
- Medikamentenliste: gescrollt liegen „Genommen/Verweigert/Später" frei

## Offen

### A — Die Profilfarbe färbt die gesamte App

Die gewählte Identitätsfarbe schlägt auf Kopfleiste, Chatrahmen, Icons,
Eingabefeld, Schalter und Knöpfe durch. Mit grünem Profil ist die App grün,
mit blauem blau. Damit bedeutet Grün nichts mehr — und ein rotes Profil
setzt die ganze Oberfläche in den Alarmton. Das widerspricht der Trennung
in `app_colors.dart`, wonach `go`/`wait`/`signal` allein für Handlungen
reserviert sind. **Schwerster Fund, betrifft das Farbkonzept im Kern.**

### B — Identitätsfarbe nicht gegen Handlungsfarben gesperrt

Das Farbrad nimmt Grün und Rot kommentarlos an. `isReservedForAction()`
existiert in `app_colors.dart`, wird im Farbwähler aber nicht angewandt.

### C — Ein Profil, vier Farben

Derselbe Avatar erscheint grün in der Kopfleiste, rot in der
Medikamentenkarte, blau in der Detailansicht und weiß nach einem Neustart.

### D — Abgeschnittene Beschriftungen

„Geno…", „Verwe…" (Medikamentenkarte), „Medika…" (Karussell),
„Medikament Det…" (Titel), „Bedarfsmediz|in" (Umbruch mitten im Wort).
Bei „Genommen" und „Verweigert" bleibt damit nur noch die Farbe zur
Unterscheidung — genau das, was die App laut Designvorgabe nicht tun soll.

### E — Farbrad unten abgeschnitten

Nur die obere Kreishälfte liegt im Container. Rot, Blau und Violett sind
nicht erreichbar.

### F — Profilerstellung schneidet Inhalte ab

Auf vier von fünf Seiten: Avatar-Knopf (S. 2), Farbrad (S. 3),
„Vollzugriff"-Karte (S. 4), Hinweiskarte (S. 5). Die Seiten sind nicht
scrollbar, der Inhalt wird stattdessen beschnitten.

### G — Regenbogenschrift auf farbigem Grund

Die Initiale im Avatar ist ein Regenbogenverlauf: auf Grün schwach lesbar,
auf Weiß praktisch unsichtbar. Dieselbe `ShaderMask`, die im
Profil-Dialog bereits entfernt wurde.

### H — Benachrichtigungsdialog ohne Vorwarnung

Beim Speichern eines Medikaments springt der Systemdialog auf, ohne dass
die App vorher erklärt, wofür. Dasselbe Muster wie beim Standort.

### I — Willkommensbildschirm nach der Anmeldung

Der Knopf umschließt nur seinen Text, statt wie im Onboarding die volle
Breite zu nehmen; weißer Text auf Pastellverlauf; großer Leerraum in der
Mitte. (`post_login_welcome_screen.dart`)

### J — Chat-Eingabezeile

Weißer Balken im ansonsten dunklen Design. Der Senden-Pfeil ist grau auf
hellgrau und wirkt dauerhaft deaktiviert.

### K — Doppelte Überschrift

Der Tabname steht im Karussell und direkt darunter noch einmal als Titel.

### L — Zeitstrahl unverständlich

„20 05 14 23 08 17 02" mit „Di./Mi./Do." darunter. Ohne Erklärung nicht
lesbar, für junge Anteile unbrauchbar.

### O — Schwacher Kontrast auf hellen Knöpfen

Weißer Text auf Hellgrün beziehungsweise Hellblau („Erstellen").

## Chat-Tab — eigener Durchgang (5. August)

Geprüft wurde der Weg, den eine Person ohne Schriftsprache nimmt: zeichnen,
senden, betrachten, und ob sich Nachrichten zwischen Profilen unterscheiden
lassen. Behoben in `721377b`, jeder Punkt am Gerät nachgestellt.

### Behoben

Unsichtbarer Eingabetext (weiß auf weiß, seit v3.0.1), Anhänge nur in
Bubble-Größe betrachtbar, Fotos beschnitten ohne Höhengrenze, Doodle-Fläche
wuchs mitten in den ersten Strich, Tippen setzte keinen Punkt, Sticker
landeten außerhalb und sprangen beim Ziehen, Radiergummi ohne Wirkung auf
Sticker, Senden-Knopf unterhalb des sichtbaren Bereichs, Export der ganzen
statt der bemalten Fläche, keine Rückmeldung nach dem Senden, zwei von acht
Farben außerhalb des Bildes, weiße Symbole auf heller Profilfarbe
unsichtbar, eingefrorene Absenderfarbe, Überlauf des leeren Zustands bei
offener Tastatur. Entfernt: zwei tote Widgets samt zweier Pakete.

### Offen

**P — Bubble-Kopf beim Nachscrollen verdeckt.** Der Verlauf springt ans
Ende und schiebt dabei den Namen der letzten Nachricht über den oberen Rand.
Wer die Zeichnung sieht, sieht nicht, von wem sie ist.

**Q — Aufnahme ohne Lebenszeichen.** Während einer Sprachnachricht steht ein
unbewegtes Mikrofon-Symbol; keine Dauer, kein Pegel. Ohne Text ist nicht
erkennbar, ob aufgenommen wird.

**R — Schwarz zeichnet fast unsichtbar.** Die Zeichenfläche ist
`0xFF28272C`. Schwarz ist als Farbkreis wählbar, hinterlässt darauf aber
kaum eine Spur.

**S — „Zum Chat wechseln" bleibt angeschnitten.** Die Werkzeugleiste trägt
acht Einträge; der unterste liegt weiter am Rand des sichtbaren Bereichs.
Betroffen ist der Ausstieg aus dem Zeichenmodus.

**T — Die beiden Video-Einträge sehen gleich aus.** „Video aufnehmen" und
„Video auswählen" unterscheiden sich nur durch `videocam` gegen
`video_library` — für eine Auswahl ohne Lesen zu ähnlich.

**U — Sticker in fester Größe.** 48 px, nicht skalierbar. Auf einer großen
Fläche bleibt ein Sticker damit sehr klein.

**V — Unterster Eintrag der Werkzeugleiste bleibt angeschnitten.** Die Leiste
scrollt, aber der Balken ist auf dem Gerät kaum zu sehen; der letzte Eintrag
steht halb am unteren Rand und wirkt wie ein Darstellungsfehler. Betroffen
sind Radieren und Löschen. (P–U stammen aus dem Durchgang vom 5. August,
V aus dem Umbau danach.)

**W — Berechtigungsdialog vor der ersten Aufnahme.** Beim ersten Tippen auf
„Bild" oder „Sprechen" erscheint Androids eigener Dialog, auf diesem Gerät
englisch und mit drei beschrifteten Auswahlzeilen. Aurora sollte vorher in
eigener, bildhafter Form zeigen, was gleich passiert — dasselbe Muster wie
bei Standort (H) und Benachrichtigungen.

## Geprüft und verworfen

**Kalender: „Event erstellen" verdeckt die Tageskarte.** Kein Fehler. Der
Kalender hat ein Bottom-Padding, und zwar ein genaueres als die übrigen
Screens — er misst die tatsächliche Buttonhöhe zur Laufzeit
(`calendar_timeline_view.dart:163`). Dass eine schwebende Leiste im
ungescrollten Zustand über dem Inhalt liegt, ist ihr gewolltes Verhalten;
entscheidend ist, dass gescrollt alles frei liegt. Dasselbe galt für den
FAB in der Medikamentenliste — auch dort war der erste Befund voreilig.
