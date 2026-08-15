# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

---

## [Unreleased]

### Geplant für v3.1 - Finder mit Karte
- 🗺️ **Finder Screen** mit zwei Tabs: Orte & Dinge
- 🗺️ Interaktive Karte für Orte (flutter_map + OpenStreetMap)
- 📍 GPS-Koordinaten speichern und anzeigen
- 📷 Fotos zu Orten/Gegenständen hinzufügen
- 🏷️ Tags und Suche für Finder-Items
- 🔍 "In Maps öffnen"-Funktion für Navigation

### Geplant für v3.2 - Notfall mit Standort
- 🚨 **Notfall-Button** mit schnellem Zugriff
- 📱 Vorgefertigte Notfall-Nachrichten mit Standort
- 📍 "Wo bin ich?"-Funktion nach Dissoziation
- 👥 Automatisches Senden an Notfallkontakte

### Geplant für v3.3 - Zeitachse
- 📊 **Timeline** für Standortverlauf (opt-in)
- 🔍 "Wo war ich?"-Suche für Blackout-Tracking
- 🗺️ Route auf Karte anzeigen
- 🔒 Privacy-fokussiert: Lokale Speicherung, jederzeit löschbar

### Geplant für v3.4+ - Weitere Features
- 🌐 ML Kit Translation für Chat-Übersetzungen
- 📖 Erweitertes Tagebuch mit Mood-Tracking
- 💾 Backup & Sync-Funktionen
- 🔔 Intelligente Erinnerungen

Siehe [ROADMAP.md](ROADMAP.md) und [FEATURES_BACKLOG.md](FEATURES_BACKLOG.md) für Details.

---
## [Unveröffentlicht]

---
## [3.0.18] - 2026-08-09

Der Weg zurück nach einem Blackout trägt jetzt: die Aufzeichnung läuft
weiter, wenn Aurora zu ist, und der Kalender verschweigt nichts mehr.

### Behoben
- 📅 **Ein Termin erinnert von sich aus.** Wer einen Termin eintrug und
  die Erinnerung nicht eigens einschaltete, bekam lautlos keine — auch
  für alle schon gespeicherten Termine galt das. Ohne eigene Wahl steht
  die Erinnerung jetzt eine halbe Stunde vorher
- 📆 **Der Kalender blendet weit entfernte Termine nicht mehr aus.** Er
  zeigte nur ein Zeitfenster und sagte das nirgends; was dahinter lag,
  war unsichtbar. Jetzt steht heute oben und danach alles Kommende
- 🕛 **Ein neuer Termin kurz vor Mitternacht landet auf dem richtigen
  Tag.** Beginn und Ende liefen getrennt: Die Uhrzeit sprang über den
  Tageswechsel, das Enddatum blieb am Vortag stehen
- 🧭 **„Wo war ich?" funktioniert jetzt wirklich.** Die Wegaufzeichnung
  versprach, auch bei geschlossener App weiterzulaufen — konnte das aber
  nicht: Sie hing an einem Takt im App-Prozess und endete mit ihm. Jetzt
  trägt sie ein eigener Dienst, der weitermisst, wenn Aurora im
  Hintergrund ist oder das Gerät schläft
- 🔌 **Nach einem Geräteneustart fällt die Aufzeichnung nicht mehr
  lautlos aus.** Sie kann dort nicht von allein anlaufen. Statt still zu
  schweigen steht jetzt eine Meldung da: ein Tippen, und es geht weiter
- 💊 **Das Tablettenfoto ist endlich zu sehen.** Es wurde gespeichert und
  nirgends gezeigt — in der Liste und auf der Detailseite stand das
  Namenskürzel, ausgerechnet dort, wo das Foto vor Verwechslungen
  schützen soll. Auch schon gespeicherte Fotos tauchen wieder auf
- 🔤 **Im Profil-Onboarding bleibt der Knopftext im Knopf**, und
  „Nicht mehr anzeigen" liegt nicht mehr auf „Willkommen bei"
- 🔍 **Das Beispiel auf der Telemetrie-Frage zeigt echte Werte.** Es nannte
  eine Version, die es nicht gab, und lag unter der Bildkante, während
  beide Antwortknöpfe ohne Scrollen erreichbar waren — man konnte
  zustimmen, ohne je gesehen zu haben, wozu

### Geändert
- 🔔 **Solange aufgezeichnet wird, steht eine Benachrichtigung in der
  Leiste.** Sie ist die Zusage in sichtbarer Form: Verschwindet sie,
  wird nicht aufgezeichnet
- 🚨 **Die Notfall-Fläche beginnt nicht mehr mit einer Berechtigungsfrage.**
  Sie war orange umrandet und das Auffälligste auf dem Schirm. Kräftige
  Farbe gehört dem, was im schlechtesten Zustand gefunden werden muss
- 👤 **„Weiter als Mina" statt „Profil wechseln".** Beim ersten Start gab
  es nichts zu wechseln. Und aus „Wie die App" wurde „Sprache der App"

### Entfernt
- 📍 **Keine Berechtigung „Standort immer erlauben" mehr.** Der neue
  Dienst kommt mit „Bei Nutzung erlauben" aus. Die Anleitung in den
  Einstellungen, wie man „Immer erlauben" einschaltet, entfällt damit
  ersatzlos

---
## [3.0.17] - 2026-08-08

Ein Gerätedurchlauf durch alle Bereiche hat zwei Dinge gefunden, die
lautlos danebengingen.

### Behoben
- 💥 **Aurora stürzte nach jedem Update und nach jedem Geräteneustart
  ab** — und die Erinnerungen wurden dabei nicht wiederhergestellt.
  Betroffen war ausgerechnet der Teil, der die geplanten Meldungen nach
  einem Neustart zurückholt: Der Release-Build entfernte
  Typinformationen, die er zum Einlesen braucht. Bei der
  Erstinstallation fiel das nie auf, weil dieser Teil dort gar nicht
  läuft
- 📷 **Kein Bild aus Kamera oder Galerie kam an.** Man suchte eines aus
  und bekam nichts — keine Meldung, kein Fehler. Betroffen waren
  Profilbild, Kontaktbild und Finder-Einträge. Der Auswahl-Dialog
  reichte seinen eigenen, bereits geschlossenen Zustand weiter; nach der
  Rückkehr aus der Systemauswahl war er weg und der Vorgang brach ab
- 📍 **Aurora fragte ungefragt nach dem Standort** — direkt nach dem
  ersten Profil, bevor jemand eine Karte geöffnet hatte, und nach dem
  Ablehnen gleich wieder. Gefragt wird jetzt nur noch, wenn jemand den
  Standort-Knopf drückt oder „Berechtigung erteilen" wählt
- 🗺️ Auf der Zeitkarte lagen zwei Aufforderungen zum Standort
  übereinander und überschrieben sich; und der Knopf „Erlauben" fragte
  gar nicht, sondern sprang in die Systemeinstellungen

### Geändert
- 🧹 Tote Reste im Meldungsdienst entfernt: zwei Methoden entschieden
  dort noch einmal über Titel und Inhalt einer Erinnerung, obwohl das
  längst der Abgleich tut

---
## [3.0.16] - 2026-08-08

Diese Version bringt die Erinnerungen zum Klingeln. Sie taten es vorher
nicht — lautlos, ohne Fehlermeldung, auf jedem geschlossenen Gerät.

### Behoben
- 🔔 **Erinnerungen kamen gar nicht an, wenn die App zu war.**
  `flutter_local_notifications` bringt seine Empfänger nicht selbst mit;
  ohne die Deklaration im Manifest feuerten geplante Alarme ins Leere.
  Jede Meldung, die bisher ankam, kam vom App-Takt — also nur, während
  jemand die App offen hatte
- ⏰ **Verschobene Erinnerungen blieben auf der alten Zeit liegen.** Die
  Kennung einer Meldung trägt jetzt ihre Feuerzeit; vorher überschrieb
  ein Aufschub den Alarm nicht, er legte einen zweiten daneben
- 📅 Ein Aufschub über Mitternacht hinweg überlebt den Tageswechsel
- 💊 Ein gesetzter Einnahme-Status bleibt korrigierbar
- 🌍 Zeitwähler übersetzt, kein Fokussprung beim Öffnen mehr
- 🔢 Das Erlaubnisband nennt die tatsächliche Zahl, Plural repariert

### Geändert
- ⚙️ **Erinnerungen werden abgeglichen statt handgeführt.** Neun
  einzelne Planungsmethoden sind durch eine Regelfunktion und einen
  Abgleich gegen das Betriebssystem ersetzt: Aurora rechnet aus, welche
  Meldungen stehen sollen, vergleicht mit dem Alarmspeicher und setzt
  die Differenz. Termine laufen durch dieselbe Funktion. Eine Lint-Regel
  hält den Weg frei — nur der Abgleich darf Erinnerungen anmelden
- 🖌️ **Zeichenwerkzeuge zeigen sich nur beim Malen.** Neunzehn
  Bedienelemente standen dauerhaft über dem Nachrichtenverlauf; im
  Blättermodus bleibt jetzt ein Pinsel in Profilfarbe
- 🕒 Zeitkarte in zwei Zeilen — bei großer Systemschrift fiel vorher die
  Uhrzeit weg. Die Tagesphase steht dabei („13:34 · mittags")
- 🔤 Versalien raus, größerer Grad, engere Sperrung
- 🦎 Vier Begleitbilder auf den gemalten Stil nachgezogen

### Entfernt
- 🔐 **Keine Foto- und Video-Berechtigung mehr.** Aurora liest die
  Galerie nirgends aus — sie lässt einen Menschen ein Bild aussuchen.
  Dafür genügt ab Android 13 der System-Photo-Picker, der ohne
  Berechtigung auskommt. (Google hat 3.0.15 deswegen abgelehnt.)
- ⏱️ **Kein `USE_EXACT_ALARM`.** Diese Berechtigung ist Wecker- und
  Kalender-Apps vorbehalten. Aurora fragt stattdessen die widerrufbare
  Freigabe an; wird sie nicht erteilt, kommt die Meldung ein paar
  Minuten später statt gar nicht
- 🗑️ Der tote Bereich „Mehr" samt seinem unerreichbaren zweiten Weg in
  die Einstellungen

---
## [3.0.15] - 2026-08-06

### Neu
- 🧭 **Aktiver Anteil auf jeder Arbeitsfläche sichtbar** — wer gerade vorn ist, steht immer im Bild
- 🕒 **Orientierungsfläche**: Zeit-Zeile, Heute-Zeile und Quick-Timeline-Band zeigen den Tag ohne Suchen
- 🗺️ **Zeitkarte und Anwesenheitsband** — Weg und Zeit der letzten Stunden auf einen Blick
- 📍 **Ortswahl im Kalender** — Termine bekommen einen Ort über ein eigenes Auswahlblatt
- 🗣️ **Sprache je Anteil** — jeder Anteil kann die App in seiner eigenen Sprache bedienen
- 🎨 **Gemaltes Profilbild** — Profilbild direkt in der App zeichnen statt Foto oder Tier-Vorlage

### Geändert
- Consent-Hinweis auf der Orientierungsfläche sichtbar gemacht
- Oberflächen-Richtlinien um den Forschungsabgleich vom 06.08. ergänzt
- Datenschutztext und Übersetzungen (de/en/es/fr/it) nachgezogen

### Behoben
- Drei Schwächen aus dem Forschungsabgleich in der Oberfläche behoben
- Telemetrie- und Erinnerungs-Fixes

---

## [3.0.10] - 2025-11-06

### Added
- **StandardAppBar**: Neues konsistentes Design-System für alle Screens
  - Top-Linie (1px Theme-Farbe, 30% Alpha) über AppBar
  - Subtile Profil-Farbleiste (1px, 60% Alpha) unter TabBar/AppBar
  - PreferredSize-Wrapper für korrekte Layout-Constraints
  - Reaktive Profil-Updates via StreamBuilder
  - 13 Screens migriert (Chat, Calendar, Contacts, Diary, Emergency, Finder, Games, Help, Mantras, Medication, More, Settings, Timeline)
- **Timeline-Modul**: Horizontaler Zeitstrahl mit Event-Visualisierung
  - TimelineStrahl Custom-Widget (Canvas-Painting)
  - TimelineEventSymbol für Event-Visualisierung
  - TimelineDataService für Event-Aggregation
  - Timeline-Painter für optimiertes Rendering
  - Calendar-Integration mit CreateView & TimelineView
  - AppBarController für Tab-übergreifende Kommunikation

### Changed
- **UX**: Profil-Farben deutlich subtiler für professionelleres Design
- **Architektur**: Dependency Injection für TimelineDataService & AppBarController

### Removed
- **ProfileSwitcherBar**: Durch StandardAppBar ersetzt

---


## [3.0.6] - 2025-10-31

### Fixed
- **Tab-Navigation**: Optimierte Breiten-Berechnung - zeigt jetzt 5 Tabs gleichzeitig statt nur 3 für besseren Kontext
- **Map Cache**: Korrigierte Größenanzeige in Einstellungen (zeigte fälschlicherweise 0 MB bei 138 Kacheln)
- **Chat**: Passenderer Empty State Text - "Teile deine Gedanken mit dem System" statt "mit dir selbst" (besser für DIS-Kontext)
- **Einstellungen**: App-Version wird nun korrekt angezeigt (nicht mehr Platzhalter "1.0.0")
- **Impressum & Datenschutz**: Kontaktdaten und Firmeninformationen aktualisiert

### Changed
- **Dependencies**: flutter_map von v7 auf v8 aktualisiert
- **Dependencies**: flutter_map_tile_caching von v9 auf v10 aktualisiert (bessere Offline-Performance)
- **Code Quality**: Deprecation Warnings behoben (withOpacity → withValues)

---

## [3.0.1] - 2025-10-19

### Added
- **Medikation**: Neuer "Bedarfsmedikation"-Tab für As-Needed Medikamente mit separater Verwaltung
- **Profile**: Neue Tier-Avatare hinzugefügt (Giraffe, Hund, Katze) für mehr Auswahl bei Profilbildern

### Changed
- **Chat**: Doodle-Feld wird automatisch ausgeblendet wenn Tastatur offen ist (verbessert UX und gibt mehr Platz für Chat-Nachrichten)
- **Chat**: Textfarbe in Eingabefeld von schwarz auf weiß geändert für bessere Lesbarkeit auf dunklem Hintergrund

### Fixed
- **Android**: Native Splash Screen zurück zur Basis-Version (weißer Hintergrund) für Stabilität
- Diverse Layout-Verbesserungen und kleine UI-Fixes

---

## [3.0.0] - 2025-10-17

Erste stabile Release mit DataEntry-Architektur und vollständiger DIS-Unterstützung.
