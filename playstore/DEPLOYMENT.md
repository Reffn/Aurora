# Aurora Website & Play Store - Deployment-Anleitung

## Übersicht

Dieses Dokument beschreibt, wie die Aurora-Website auf 3ofus.app hochgeladen und die Play Store Einträge aktualisiert werden.

---

## 1. Website-Deployment auf 3ofus.app

### Dateien zum Upload

Alle Files im `docs/` Verzeichnis müssen nach `3ofus.app/aurora/` hochgeladen werden:

```
docs/
├── index.html                → 3ofus.app/aurora/index.html
├── datenschutz.html         → 3ofus.app/aurora/datenschutz.html
├── impressum.html           → 3ofus.app/aurora/impressum.html
├── css/
│   └── style.css           → 3ofus.app/aurora/css/style.css
└── assets/
    ├── logo-icon.png       → 3ofus.app/aurora/assets/logo-icon.png
    ├── logo-text.png       → 3ofus.app/aurora/assets/logo-text.png
    └── google-play-badge.png → 3ofus.app/aurora/assets/google-play-badge.png
```

### Upload-Methoden

**Option 1: FTP/SFTP** (falls verfügbar)
```bash
# Beispiel mit SFTP
sftp user@3ofus.app
cd /var/www/3ofus.app/aurora/
put -r docs/* .
```

**Option 2: cPanel File Manager**
1. Einloggen in cPanel
2. File Manager öffnen
3. Verzeichnis `/public_html/aurora/` erstellen (falls nicht vorhanden)
4. Files hochladen

**Option 3: Git Deploy** (falls konfiguriert)
- Git Hook auf Server einrichten
- Push zu Repository triggert automatischen Deploy

### URLs nach Deployment

- **Landing Page**: `https://3ofus.app/aurora/` oder `https://3ofus.app/aurora/index.html`
- **Datenschutz**: `https://3ofus.app/aurora/datenschutz.html`
- **Impressum**: `https://3ofus.app/aurora/impressum.html`

### Testing nach Upload

- [ ] Landing Page öffnet korrekt
- [ ] CSS lädt (keine kaputten Styles)
- [ ] Logo-Bilder werden angezeigt
- [ ] Navigation funktioniert (Links zu Datenschutz/Impressum)
- [ ] Responsive Design auf Mobile testen
- [ ] Datenschutzerklärung vollständig sichtbar
- [ ] Impressum vollständig sichtbar
- [ ] Externe Links funktionieren (Play Store Badge, Email-Links)

---

## 2. Play Store Assets

### Noch fehlende Assets (am Hauptrechner erstellen)

**Screenshots (6-8 Stück benötigt)**:
1. Chat-Screen (interne Kommunikation)
2. Calendar-Screen (Terminplanung)
3. Profile-Selection (Multi-Profile System)
4. Medication-Screen (Medikamentenplan)
5. Diary-Screen (Tagebuch)
6. Finder-Screen (Karte mit Orten)
7. Emergency-Screen (Notfall-Hotlines)
8. Permissions-Screen (RBAC-System)

**Screenshot-Spezifikationen**:
- Format: PNG oder JPG
- Größe: 1080x1920px (Hochformat) oder 1920x1080px (Querformat)
- Mindestens 2, maximal 8 Screenshots
- Empfohlen: 6 Screenshots in einheitlichem Design

**Feature Graphic**:
- Größe: 1024x500px
- Format: PNG oder JPG
- Zeigt App-Logo + Slogan "Aurora - Sichere Begleitung bei DIS"
- Aurora-Farben: #9D84B7 (Lila), #E8A0BF (Rosa)

**Hi-Res App Icon**:
- Größe: 512x512px
- Format: PNG (transparenter Hintergrund)
- Bereits vorhanden: `assets/images/logo_icon_transparent.png`

### Screenshot-Anleitung (Hauptrechner)

```bash
# App im Emulator starten
flutter run

# Pro Screen:
1. Zu gewünschtem Screen navigieren
2. Screenshot machen (Emulator Screenshot-Funktion)
3. Auf 1080x1920px zuschneiden/skalieren
4. Als PNG speichern mit sinnvollem Namen:
   - 01_chat_screen.png
   - 02_calendar_screen.png
   - 03_profile_selection.png
   - etc.
```

**Screenshot-Bearbeitung** (optional):
- Rahmen hinzufügen (Device-Frame)
- Text-Overlays für Features ("Interner Chat", "Medikamentenplan", etc.)
- Einheitlicher Hintergrund

---

## 3. Google Play Console Update

### Schritt 1: Privacy Policy URL aktualisieren

1. Einloggen in [Google Play Console](https://play.google.com/console/)
2. App auswählen: **Aurora (com.aurora.dis_app)**
3. Links: **App-Inhalte** → **Datenschutzerklärung**
4. **Alte URL löschen**: `https://3ofus.app/legal/datenschutz.html`
5. **Neue URL eintragen**: `https://3ofus.app/aurora/datenschutz.html`
6. Speichern

### Schritt 2: Store-Listing aktualisieren

**Sprache**: Deutsch (Deutschland)

1. **Kurzbeschreibung** (80 Zeichen):
   ```
   Sichere, private App für Menschen mit DIS. Alle Daten bleiben auf deinem Gerät.
   ```

2. **Vollständige Beschreibung**:
   - Kopieren aus `playstore/description-de.txt`
   - Maximale Länge: 4000 Zeichen (aktuell: ~3800 Zeichen)

3. **Screenshots hochladen**:
   - Handy-Screenshots (1080x1920px)
   - Mindestens 2, empfohlen 6-8
   - In logischer Reihenfolge (Chat → Calendar → Profile → etc.)

4. **Feature Graphic** (falls erstellt):
   - 1024x500px PNG/JPG
   - Wird ganz oben im Store-Listing angezeigt

5. **App-Symbol** (Hi-Res):
   - 512x512px PNG
   - Upload: `assets/images/logo_icon_transparent.png`

### Schritt 3: App-Kategorie & Tags

- **Kategorie**: Medizinisch ODER Gesundheit & Fitness
- **Tags/Keywords**:
  - DIS
  - Dissoziative Identitätsstörung
  - Mental Health
  - Trauma
  - Selbsthilfe
  - Datenschutz
  - Offline

### Schritt 4: Altersfreigabe

- **Empfohlen**: USK 0 oder PEGI 3
- **Begründung**: Keine sensiblen Inhalte für Minderjährige
- **Achtung**: App richtet sich primär an Erwachsene (18+), aber einige Alters können minderjährig sein

### Schritt 5: Überprüfung & Veröffentlichung

1. **Vorschau anzeigen**: Wie sieht Store-Listing aus?
2. **Alle Felder ausgefüllt?**:
   - [ ] Kurzbeschreibung
   - [ ] Lange Beschreibung
   - [ ] Screenshots (min. 2)
   - [ ] App-Symbol (512x512px)
   - [ ] Feature Graphic (optional)
   - [ ] Privacy Policy URL
   - [ ] Kategorie
3. **"Überprüfung senden"** klicken
4. **Wartezeit**: 1-7 Tage bis Google Review abgeschlossen ist

---

## 4. Nach Veröffentlichung

### Marketing-Kanäle (optional)

**Discord Community** (geplant):
- Discord-Server erstellen: "Aurora DIS Support Community"
- Invite-Link generieren (nie ablaufend)
- In App integrieren (Contact Developer Feature)
- Auf Website verlinken

**Social Media** (optional):
- Mastodon/Fediverse (Privacy-freundlich)
- Reddit r/DID (Vorsicht: Regeln beachten, kein Spam)
- DIS-Foren (DIS-kussion.de, etc.)

**Therapeuten-Netzwerk**:
- DEGPT Therapeuten informieren
- Flyer für Wartezimmer (optional)
- Selbsthilfegruppen kontaktieren

### Monitoring

**Was NICHT gemacht wird** (Privacy-First):
- ❌ Keine Analytics
- ❌ Keine Download-Zahlen tracken
- ❌ Keine User-Daten sammeln

**Was gemacht werden kann**:
- ✅ Play Store Bewertungen lesen
- ✅ E-Mail-Feedback (info@3ofus.app)
- ✅ Discord-Community Feedback (wenn erstellt)
- ✅ GitHub Issues (wenn Repository öffentlich)

---

## 5. Checkliste: Kompletter Deployment

### Website-Deployment
- [ ] Alle HTML-Files nach `3ofus.app/aurora/` hochgeladen
- [ ] CSS-File hochgeladen
- [ ] Logo-Assets hochgeladen
- [ ] Google Play Badge hochgeladen (optional)
- [ ] URLs getestet (Landing Page, Datenschutz, Impressum)
- [ ] Responsive Design auf Mobile getestet
- [ ] Alle Links funktionieren

### Play Store Update
- [ ] Screenshots erstellt (6-8 Stück)
- [ ] Feature Graphic erstellt (1024x500px)
- [ ] Privacy Policy URL aktualisiert: `3ofus.app/aurora/datenschutz.html`
- [ ] Kurzbeschreibung eingefügt (80 Zeichen)
- [ ] Lange Beschreibung eingefügt (aus `playstore/description-de.txt`)
- [ ] Screenshots hochgeladen
- [ ] Feature Graphic hochgeladen (optional)
- [ ] App-Symbol (Hi-Res) hochgeladen
- [ ] Kategorie gesetzt
- [ ] Tags/Keywords gesetzt
- [ ] Altersfreigabe überprüft
- [ ] "Überprüfung senden" geklickt
- [ ] Google Review abwarten (1-7 Tage)

### Optional (später)
- [ ] Discord-Server erstellt
- [ ] Invite-Link auf Website eingefügt
- [ ] Contact Developer Feature implementiert
- [ ] Feedback-Kanäle überwachen (E-Mail, Discord)

---

## 6. Troubleshooting

### Problem: Website zeigt kaputtes Layout

**Lösung**:
- CSS-Pfad prüfen: `<link rel="stylesheet" href="css/style.css">`
- Relative Pfade verwenden (nicht absolute)
- Browser-Cache leeren (Strg+F5)

### Problem: Bilder werden nicht angezeigt

**Lösung**:
- Bildpfade prüfen: `src="assets/logo-icon.png"`
- Dateinamen case-sensitive (Linux Server!)
- `onerror` Fallback eingebaut (zeigt nichts an wenn Bild fehlt)

### Problem: Play Store lehnt Privacy Policy ab

**Lösung**:
- URL muss öffentlich erreichbar sein (kein Login)
- HTTPS erforderlich (nicht HTTP)
- URL darf nicht redirecten
- Inhalt muss auf Deutsch ODER Englisch sein

### Problem: Google Review dauert länger als 7 Tage

**Lösung**:
- Play Console Support kontaktieren
- Status prüfen: "In Überprüfung" oder "Abgelehnt"?
- Bei Ablehnung: Gründe lesen, beheben, erneut einreichen

---

## 7. Kontakt & Support

**Bei Fragen zum Deployment**:
- E-Mail: info@3ofus.app
- GitHub Issues (wenn öffentlich)
- Discord (wenn Community erstellt)

**Technischer Support**:
- Nico Wojtera (3ofus)
- E-Mail: info@3ofus.app

---

**Version**: 1.0 (Januar 2025)
**Erstellt**: Für Aurora 3.0.6 Website-Deployment
**Letztes Update**: 2025-01-02
