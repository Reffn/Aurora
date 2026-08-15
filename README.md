# Aurora

[![Tests](https://github.com/Reffn/Aurora/actions/workflows/test.yml/badge.svg)](https://github.com/Reffn/Aurora/actions)
[![codecov](https://codecov.io/gh/Reffn/Aurora/branch/main/graph/badge.svg)](https://codecov.io/gh/Reffn/Aurora)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-brightgreen.svg)](LICENSE)
[![Google Play](https://img.shields.io/badge/Google_Play-Aurora-34A853?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.disapp.dis_app)

A Flutter app for people living with Dissociative Identity Disorder (DID).

*[Deutsche Fassung: README.de.md](README.de.md)*

Aurora gives a system a private place to coordinate: to talk to each other, keep
a shared calendar, write things down, and reach help quickly. The app is in
German; the codebase and contribution process are in English.

## Privacy

Aurora is used by people whose diagnosis is sensitive information. In this
context every data point is health data — the mere fact that a device runs a DID
app reveals a suspected diagnosis. Three rules follow from that, without
exception:

1. **Nothing is sent without explicit consent.** All data lives on the device.
   Feedback is user-triggered and therefore needs no opt-in; telemetry would be
   automatic and therefore requires one (GDPR Art. 9).
2. **Everything sent is inspectable.** Settings → "Was Aurora sendet" shows every
   transmission verbatim, stored locally. An empty list is the proof that nothing
   left the device.
3. **Nothing permits re-identification.** No profile IDs, no installation IDs, no
   session chains, no entry counts.

**Location data never reaches the developers** — not in feedback, not in
telemetry, not rounded, not as a country. A test asserts the payload schema has
no location field. Coordinates go to OpenStreetMap for maps and geocoding only,
and the emergency feature shares location with contacts the user picks.

The Firestore security rules that back rule 1 are in [`firestore.rules`](firestore.rules)
and are verified against the live rules engine by
[`tool/test_firestore_rules.py`](tool/test_firestore_rules.py) — no read, no
update, no delete, ever, by anyone including us.

## Features

- **Chat** — internal communication between alters
- **Profiles** — individual picture and color per alter, with role-based permissions
- **Calendar** — shared scheduling and time management
- **Journal** — personal entries and shared thoughts
- **Emergency contacts** — quick access to important numbers
- **Support resources** — professional help and services
- **Mantras** — calming affirmations and grounding techniques
- **Games** — distraction and relaxation

## Tech stack

- **Framework**: Flutter / Dart
- **Persistence**: Hive (local NoSQL, no cloud sync)
- **State**: RxDart streams
- **Architecture**: all data flows through a central `DataEntry` API, which
  validates, logs, and publishes events on an `EventBus`; services subscribe and
  persist to Hive

```
UI / Modules → DataEntry → EventBus → Services → Hive
                   ↓
             validation, logging
```

See [`ARCHITECTURE.md`](ARCHITECTURE.md) and [`CLAUDE.md`](CLAUDE.md) for details.

## Getting started

Requires the [Flutter SDK](https://flutter.dev/docs/get-started/install).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Hive type adapters
flutter run
```

## Development

```bash
flutter test                    # run tests
flutter analyze                 # static analysis
dart run custom_lint            # project-specific lint rules
flutter build apk               # Android build
```

The repository ships custom lint rules in `dis_app_lints/` that enforce the
architecture: `prefer_data_entry_architecture`, `avoid_service_direct_mutation`,
and `hive_field_order_check`.

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Issues and
pull requests may be written in German or English.

Participation is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). Given who
this app is for, that is not a formality.

## License

[Mozilla Public License 2.0](LICENSE).

In short: Aurora may be used, modified, and redistributed freely, including
commercially. Changes to existing Aurora files must stay open under MPL-2.0;
new files of your own may carry any license.

So a fork cannot make its improvements disappear into a closed version.
