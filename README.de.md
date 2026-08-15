[![Google Play](https://img.shields.io/badge/Google_Play-Aurora-34A853?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.disapp.dis_app)

# Aurora

[![Tests](https://github.com/Reffn/Aurora/actions/workflows/test.yml/badge.svg)](https://github.com/Reffn/Aurora/actions)
[![codecov](https://codecov.io/gh/Reffn/Aurora/branch/main/graph/badge.svg)](https://codecov.io/gh/Reffn/Aurora)
[![Lizenz: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-brightgreen.svg)](LICENSE)

Eine Flutter-App für Menschen mit Dissoziativer Identitätsstörung (DIS).

*[English version: README.md](README.md)*

Aurora gibt einem System einen privaten Ort zum Koordinieren: miteinander reden,
gemeinsamer Kalender, Dinge festhalten, im Notfall schnell Hilfe erreichen.

## Privatsphäre

Aurora wird von Menschen genutzt, deren Diagnose eine sensible Information ist.
In diesem Kontext ist jeder Datenpunkt ein Gesundheitsdatum — allein die
Information, dass ein Gerät eine DIS-App nutzt, offenbart eine Verdachtsdiagnose.
Daraus folgen drei Regeln, ohne Ausnahme:

1. **Ohne ausdrückliche Einwilligung wird nichts gesendet.** Alle Daten liegen auf
   dem Gerät. Feedback löst die Nutzerin selbst aus und braucht deshalb kein
   Opt-in; Telemetrie liefe automatisch und braucht es deshalb sehr wohl
   (DSGVO Art. 9).
2. **Alles Gesendete ist einsehbar.** Einstellungen → „Was Aurora sendet" zeigt
   jede Übertragung wörtlich, lokal gespeichert. Eine leere Liste ist der
   Nachweis, dass nichts das Gerät verlassen hat.
3. **Nichts erlaubt Re-Identifikation.** Keine Profil-IDs, keine Installations-IDs,
   keine Session-Ketten, keine Bestandszahlen.

**Standortdaten erreichen die Entwickler nie** — nicht im Feedback, nicht in der
Telemetrie, nicht gerundet, nicht als Land. Ein Test sichert ab, dass das
Payload-Schema kein Standortfeld enthält. Koordinaten gehen ausschließlich für
Karten und Geocoding an OpenStreetMap; die Notfallfunktion teilt den Standort mit
den Kontakten, die die Nutzerin selbst wählt.

Die Firestore-Regeln hinter Regel 1 stehen in [`firestore.rules`](firestore.rules)
und werden von [`tool/test_firestore_rules.py`](tool/test_firestore_rules.py)
gegen die echte Rules-Engine geprüft — kein Lesen, kein Ändern, kein Löschen,
durch niemanden, auch nicht durch uns.

## Funktionen

- **Chat** — interne Kommunikation zwischen den Persönlichkeiten
- **Profile** — eigenes Bild und eigene Farbe je Persönlichkeit, mit Rechteverwaltung
- **Kalender** — gemeinsame Terminplanung und Zeitmanagement
- **Tagebuch** — persönliche Einträge und Gedankenaustausch
- **Notfallkontakte** — Schnellzugriff auf wichtige Telefonnummern
- **Hilfsangebote** — Ressourcen und professionelle Unterstützung
- **Mantras** — beruhigende Affirmationen und Entspannungstechniken
- **Spiele** — Ablenkung und Entspannung

## Technik

- **Framework**: Flutter / Dart
- **Persistenz**: Hive (lokale NoSQL-Datenbank, keine Cloud-Synchronisation)
- **State**: RxDart-Streams
- **Architektur**: Alle Daten laufen über eine zentrale `DataEntry`-API, die
  validiert, protokolliert und Events auf einem `EventBus` veröffentlicht;
  Services abonnieren diese und schreiben nach Hive

```
UI / Module → DataEntry → EventBus → Services → Hive
                  ↓
          Validierung, Logging
```

Details in [`ARCHITECTURE.md`](ARCHITECTURE.md) und [`CLAUDE.md`](CLAUDE.md).

## Installation

Voraussetzung ist das [Flutter SDK](https://flutter.dev/docs/get-started/install).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Hive-Type-Adapter
flutter run
```

## Entwicklung

```bash
flutter test                    # Tests ausführen
flutter analyze                 # statische Analyse
dart run custom_lint            # projekteigene Lint-Regeln
flutter build apk               # Android-Build
```

Das Repository enthält eigene Lint-Regeln in `dis_app_lints/`, die die
Architektur durchsetzen: `prefer_data_entry_architecture`,
`avoid_service_direct_mutation` und `hive_field_order_check`.

## Mitwirken

Beiträge sind willkommen — siehe [CONTRIBUTING.md](CONTRIBUTING.md). Issues und
Pull Requests dürfen auf Deutsch oder Englisch geschrieben werden.

Für die Mitarbeit gilt unser [Verhaltenskodex](CODE_OF_CONDUCT.md). Bei einer App
für diese Zielgruppe ist das keine Formalie.

## Lizenz

[Mozilla Public License 2.0](LICENSE)

Kurz: Aurora darf frei genutzt, verändert und weiterverbreitet werden — auch
kommerziell. Änderungen an bestehenden Aurora-Dateien müssen aber unter MPL-2.0
offen bleiben. Neue, eigene Dateien darf man beliebig lizenzieren.

Wer Aurora forkt, kann die Verbesserungen also nicht hinter einer geschlossenen
Version verschwinden lassen.
