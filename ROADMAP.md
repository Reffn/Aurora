# 🗺️ Aurora Roadmap

## Vision

Aurora ist eine umfassende Offline-App zur Unterstützung von Menschen mit Dissoziativer Identitätsstörung (DIS). Unser Ziel ist es, ein sicheres, privates Tool zu schaffen, das alle Aspekte des Lebens mit DIS unterstützt - von der inneren Kommunikation über Medikamentenverwaltung bis hin zu Notfallfunktionen.

**Kernprinzipien:**
- 🔒 **Privacy First**: Alle Daten bleiben lokal auf dem Gerät
- 📴 **Offline-First**: Volle Funktionalität ohne Internetverbindung
- 🎨 **Personalisierung**: Jede Innenperson kann individuell gestaltet werden
- 🛡️ **Sicherheit**: Passwortschutz, Security Questions, Daten-Verschlüsselung

---

## Entwicklungsphasen

### ✅ Phase 1: Grundfunktionen (v1.0 - v3.0) - **Erledigt**

**Status:** Released (v3.0.1 - Oktober 2025)

**Features:**
- ✅ Multi-Profil-System mit Avataren (inkl. Tier-Avatare)
- ✅ Rollen-basierte Berechtigungen (RBAC)
- ✅ Interner Chat mit Doodles, Voice, Bilder, Videos
- ✅ Medikamentenverwaltung (Regulär + Bedarfsmedikation)
- ✅ Kalender für gemeinsame Events
- ✅ Kontakte-Verwaltung mit Ratings
- ✅ Passwort-Reset mit Security Questions
- ✅ DataEntry-Architektur (zentralisierte Datenoperationen)

**Technische Grundlagen:**
- Hive CE für lokale Datenspeicherung
- GetIt für Dependency Injection
- EventBus für reaktive Updates
- Flutter mit Material Design 3

---

### 🚧 Phase 2: Karten & Standort (v3.1 - v3.3) - **In Planung**

**Ziel:** Räumliche Orientierung und Sicherheit durch Standort-Features

#### v3.1: Finder Screen (Q4 2025)
**Fokus:** Orte und Gegenstände wiederfinden

- 🗺️ Finder mit zwei Tabs: **Orte** & **Dinge**
- 🗺️ Interaktive Karte für Orte (flutter_map + OpenStreetMap)
- 📍 GPS-Koordinaten speichern
- 📷 Fotos anhängen (optional)
- 🏷️ Tags (wichtig, notfall, täglich)
- 🔍 Suche nach Titel, Beschreibung, Tags
- 📴 Optional: Offline-Karten-Download

**Use Cases:**
- Wichtige Orte merken (Arzt, Therapie, Zuhause, Safe Places)
- Gegenstände zu Hause finden (Schlüssel, Dokumente)
- Route in externe Navi-App exportieren

#### v3.2: Notfall mit Standort (Q1 2026)
**Fokus:** Schnelle Hilfe im Notfall

- 🚨 Notfall-Button (prominent in App)
- 📱 Vorgefertigte Notfall-Nachrichten
- 📍 Aktueller Standort automatisch anhängen
- 👥 An ausgewählte Notfallkontakte senden (SMS/WhatsApp)
- 🗺️ "Wo bin ich?"-Funktion
- 🏠 Safe Places auf Karte markieren

**Use Cases:**
- Desorientierung nach Dissoziation
- Schnelle Hilfe anfordern
- Standort mit Vertrauenspersonen teilen

#### v3.3: Zeitachse/Timeline (Q2 2026)
**Fokus:** Standortverlauf für Blackout-Tracking

- 📊 Zeitachse-Ansicht (Tag/Woche/Monat)
- 📍 Standortverlauf aufzeichnen (opt-in, Privacy-bewusst)
- 🔍 "Wo war ich?"-Suche nach Zeitraum
- 🗺️ Route auf Karte anzeigen
- 🗑️ Verlauf jederzeit löschbar
- ⚙️ Granulare Privacy-Einstellungen

**Use Cases:**
- Blackout-Tracking: "Wo war mein Körper während Dissoziation?"
- Gedächtnislücken füllen
- Muster erkennen (regelmäßige Orte)

---

### 📋 Phase 3: Erweiterte Features (v3.4+) - **Backlog**

#### v3.4: Translation Service (TBD)
**Fokus:** Innere Kommunikation über Sprachbarrieren hinweg

- 🌐 ML Kit Translation Integration
- 🔄 Chat-Nachrichten übersetzen
- 📝 Notizen in verschiedenen Sprachen
- 📴 Offline-Modelle (nach Download)

**Use Cases:**
- Innenpersonen mit verschiedenen Erstsprachen
- Internationale Innensystem-Kommunikation

#### v3.5: Erweiterte Tagebuch-Funktionen (TBD)
**Fokus:** Emotionales Tracking und Reflexion

- 📖 Erweitertes Notfall-Tagebuch
- 😊 Mood Tracking
- 📊 Statistiken und Insights
- 🖼️ Bild-Anhänge in Tagebuch-Einträgen

#### v3.6: Backup & Sync (TBD)
**Fokus:** Datensicherheit ohne Cloud-Zwang

- 💾 Lokales Backup (verschlüsselt)
- 📤 Export/Import (zwischen Geräten)
- ☁️ Optional: Verschlüsseltes Cloud-Backup (User-kontrolliert)

#### v3.7: Weitere Ideen
- 🔔 Intelligente Erinnerungen (Medikamente, Termine)
- 📈 Fortschritts-Tracking (Therapie-Ziele)
- 🎨 Weitere Avatar-Optionen (Custom Avatare)
- 🌙 Erweiterte Theming-Optionen
- 🔊 Accessibility-Verbesserungen (TalkBack, VoiceOver)

---

## Technische Roadmap

### Dependencies-Updates
- **Geplant (Q4 2025):**
  - flutter_map (Karten)
  - latlong2 (GPS-Koordinaten)
  - geolocator (Standort-Services)

- **Überwacht:**
  - Hive CE Updates
  - Flutter SDK Updates
  - Deprecated APIs Migration

### Architektur-Verbesserungen
- **v3.x:**
  - BuildContext async gaps beheben
  - Deprecated `withOpacity()` → `withValues()`
  - Type Inference Improvements

### Performance
- **Kontinuierlich:**
  - Startup-Zeit optimieren
  - Memory Leaks vermeiden
  - Widget-Tree Optimierung

---

## Release-Strategie

**Versionierungs-Schema:** MAJOR.MINOR.PATCH

- **MAJOR (1.x → 2.x):** Breaking Changes, große neue Features
- **MINOR (3.1 → 3.2):** Neue Features, backward-compatible
- **PATCH (3.0.1 → 3.0.2):** Bug-Fixes, kleine Verbesserungen

**Release-Zyklus:**
- Minor Releases: ~2-3 Monate
- Patch Releases: Nach Bedarf (Bugs, kleine Verbesserungen)

---

## Community & Feedback

**Feedback-Kanäle:**
- GitHub Issues: https://github.com/Reffn/Aurora/issues
- Direkte Nutzer-Feedback-Sessions
- App-interne Feedback-Funktion (geplant für v3.6)

**Beitrag:**
- Code-Reviews willkommen
- Feature-Requests via GitHub Issues
- Übersetzungen (sobald Translation Service implementiert)

---

## Lizenz & Open Source

Aurora ist ein **Open Source Projekt** unter MIT Lizenz.

**Warum Open Source?**
- 🔍 Transparenz für Privacy-kritische App
- 🤝 Community-getriebene Entwicklung
- 🛡️ Sicherheit durch öffentliche Code-Reviews

---

*Letzte Aktualisierung: 2025-10-20*
*Version: 3.0.1*
