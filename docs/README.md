# Aurora Website

Offizielle Website für die Aurora DIS Support App.

## Struktur

```
docs/
├── index.html           # Landing Page
├── datenschutz.html     # Privacy Policy (DSGVO-konform)
├── impressum.html       # Legal Notice
├── css/
│   └── style.css       # Aurora Branding & Responsive Design
└── assets/
    ├── logo-icon.png   # Aurora Logo (Icon)
    ├── logo-text.png   # Aurora Logo (Text)
    └── google-play-badge.png # Google Play Download Badge
```

## Deployment

Diese Website sollte nach `https://3ofus.app/aurora/` deployed werden.

Siehe `../playstore/DEPLOYMENT.md` für vollständige Deployment-Anleitung.

## Features

- **Privacy-First Design**: Fokus auf Datenschutz und Transparenz
- **Responsive**: Mobile-First Design, funktioniert auf allen Geräten
- **DSGVO-konform**: Vollständige Datenschutzerklärung
- **Accessibility**: WCAG-Richtlinien berücksichtigt
- **Aurora Branding**: Lila (#9D84B7) & Rosa (#E8A0BF) Farbschema

## URLs (nach Deployment)

- Landing Page: `https://3ofus.app/aurora/`
- Datenschutz: `https://3ofus.app/aurora/datenschutz.html`
- Impressum: `https://3ofus.app/aurora/impressum.html`

## Play Store

Die Privacy Policy URL für Google Play Store:
```
https://3ofus.app/aurora/datenschutz.html
```

Diese URL muss in der Play Console unter "App-Inhalte" → "Datenschutzerklärung" eingetragen werden.

## Entwicklung

**Lokaler Test**:
```bash
# Mit Python Simple HTTP Server
cd docs/
python3 -m http.server 8000

# Dann öffnen: http://localhost:8000
```

**Oder mit Live Server** (VS Code Extension):
1. Install "Live Server" Extension
2. Rechtsklick auf `index.html`
3. "Open with Live Server"

## Lizenz

© 2025 3ofus - Alle Rechte vorbehalten

Entwickelt mit Respekt für Vielfalt und Privatsphäre.
