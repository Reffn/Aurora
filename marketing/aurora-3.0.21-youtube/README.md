# Aurora 3.0.21 – YouTube-Releasevideo

Dieses Paket produziert einen ruhigen deutschsprachigen YouTube-Trailer für
Aurora 3.0.21. Die App-Aufnahmen stammen ausschließlich aus einem isolierten
Aufnahme-Build mit synthetischen Profilen und Beispieldaten.

## Fertige Ausgaben

- `output/aurora-3.0.21-youtube-de.mp4` – 16:9, 1080p, H.264/AAC
- `output/aurora-3.0.21-de.srt` – deutsche UTF-8-Untertitel
- `output/thumbnail-*.png` – drei YouTube-Thumbnails in 3840 × 2160
- `output/play-store-de/phone-01.png` bis `phone-08.png` – acht
  Store-Screenshots in 1080 × 1920
- `output/play-store-en/phone-01.png` bis `phone-08.png` – derselbe
  Funktionsdurchlauf mit vollständig englischer Oberfläche und englischen
  Store-Texten
- `youtube-upload.md` – Titelvarianten, Beschreibung und Kapitel
- `play-store-austausch.md` – Live-Befund und empfohlene Bildreihenfolge

## Verifikation

- Video: 1920 × 1080, 30 fps, H.264, AAC 48 kHz, 86,6 Sekunden.
- Ton: −15,6 LUFS integriert, −1,0 dBFS True Peak, keine unbeabsichtigte
  Stille von mindestens 1,5 Sekunden.
- Untertitel: als SRT erkannt, UTF-8 geprüft, letzter Cue endet vor dem Video.
- Store-Bilder: je acht verschiedene deutsche und englische Motive, jeweils
  1080 × 1920.
- Sichtbare Ortsangaben der öffentlichen Debug-Fixture werden beim Rendern
  neutral zu „Beispielort“ ersetzt.
- Der englische Aufnahme-Build verwendet ausschließlich „Example place“ und
  enthält auch bei Termin und Medikament nur englische Beispieldaten.

## Produktionsregeln

- Echte App-Oberfläche für jede Funktionsaussage.
- Keine echten Profile, Kontakte, Nachrichten, Termine oder Standorte.
- Keine Diagnose- oder Heilungsversprechen.
- Keine dramatisierten „gespaltenen Gesichter“ oder Krisenbilder.
- Bewegung erklärt etwas; sie ist keine Belohnungs- oder Effektschleife.
- Ein optionaler Seedance-Clip darf nur den sechssekündigen Einstieg ersetzen.
  Der Trailer bleibt ohne ihn vollständig.

## Arbeitsverzeichnis

`work/` enthält Rohaufnahmen und Zwischenstände. Die fertigen Dateien liegen in
`output/`. Der reproduzierbare Schnitt wird über `render.ps1` ausgeführt.
