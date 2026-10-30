# Die Aurora-Website

Der Quelltext von <https://auroa-7f66b.web.app>. React, Vite, Tailwind.

## Warum das hier liegt

Diese Seite spricht Aurora's Datenschutzversprechen aus — wörtlich: *„Kein
Tracking, keine Analytics, absolut keine Werbung."* Ein Versprechen, dessen
Quelltext niemand lesen kann, ist eine Behauptung.

Es war schon einmal anders. Am 12.08.2026 lud die Live-Seite bei jedem Aufruf
Google Analytics — Client-ID, Sitzungsverkettung, IP an Google, ohne
Einwilligung, auf der Seite, auf der „Maximal privat" steht. Gefunden hat das
nur eine Messung des Netzverkehrs: Im Repository lag zu dem Zeitpunkt bloß das
minifizierte Bündel, der Quelltext war Monate zuvor entfernt worden
(*„die Gemini-Vorlage entfernen, 54 Sicherheitswarnungen ohne App-Bezug"*).
Das gebaute Ergebnis blieb online, die Möglichkeit es zu prüfen ging.

Deshalb liegt die Quelle wieder hier, und deshalb steht in `index.html` und
`index.css`, was früher nach außen ging und warum es weg ist.

## Bauen

```bash
npm install
npm run build      # erzeugt dist/
```

Das Ergebnis gehört nach `../docs/`, dem Wurzelverzeichnis von Firebase
Hosting (siehe `firebase.json`):

```bash
rm -f ../docs/assets/index-*.js ../docs/assets/index-*.css
cp dist/index.html            ../docs/index.html
cp dist/assets/index-*.js     ../docs/assets/
cp dist/assets/index-*.css    ../docs/assets/
cp dist/fonts/*               ../docs/fonts/
```

Die Bilder unter `../docs/assets/` (Logos, App-Aufnahmen) sind **nicht** Teil
des Vite-Builds; sie liegen dort statisch und werden über absolute Pfade
(`/assets/screenshots/...`) geladen. Nicht mit dem Build löschen.

## Was diese Seite nach außen ruft

Nichts. Kein CDN, keine Schrift von Google, kein Firebase, keine Messung.
Wer das nachprüfen will: Seite laden, Netzwerk-Tab öffnen, Fremd-Hosts zählen.
Es müssen null sein.

Das ist keine Nebensache, sondern die Abnahme. Vor dem Ausliefern:

```bash
grep -ohE 'https?://[a-zA-Z0-9.-]+\.[a-z]{2,}' dist/index.html dist/assets/*.css
```

Diese Zeile muss leer bleiben.
