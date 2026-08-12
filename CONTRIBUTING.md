# Contributing to Aurora

Thanks for considering a contribution. Aurora is used by people living with
Dissociative Identity Disorder, often in crisis situations. That shapes what a
good contribution looks like here more than any style guide could.

**Language:** Issues and pull requests may be written in German or English. The
app's user interface is German; code, comments, and commit messages are English.

## Before you start

For anything beyond a small fix, open an issue first. It saves you from building
something that conflicts with a design decision you couldn't have known about —
several are documented in `docs/superpowers/specs/`.

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Hive type adapters
flutter test
```

## The three privacy rules

These are not preferences. A pull request that breaks one of them will not be
merged, however good the feature is:

1. **Nothing is sent without explicit consent.** User-triggered actions like
   feedback need no opt-in; anything automatic does (GDPR Art. 9 — in a DID app
   every data point is health data by context).
2. **Everything sent is inspectable** in Settings → "Was Aurora sendet", verbatim
   and stored locally.
3. **Nothing permits re-identification.** No profile IDs, no installation IDs, no
   session chains, no entry counts. With roughly 40 installations, "7 profiles,
   1432 messages" identifies a person.

**Location data never reaches the developers.** Not in feedback, not in
telemetry, not rounded, not as a country. Location is not anonymizable — a few
coarse place-time points identify someone uniquely, and here the context supplies
the diagnosis along with it. A test asserts the payload schema has no location
field; do not weaken it.

No analytics SDKs, no crash reporters that phone home, no third-party trackers.

## Architecture rules

The repository enforces these with custom lint rules (`dart run custom_lint`):

- **All data operations go through `DataEntry`** (`lib/core/data_entry.dart`).
  Do not mutate service state directly.
- **Hive field order is append-only.** Reordering `@HiveField` numbers corrupts
  existing user data — and users cannot restore from a cloud backup, because
  there is none.
- **Relative paths in the database.** Attachments are stored as `avatar_123.jpg`,
  resolved at runtime via `AttachmentHelper`.

Two more that lints cannot catch:

- **UTF-16 safety.** Use `runes` for user-generated strings, never `name[0]` —
  the latter crashes on emoji, and profile names contain them constantly.

  ```dart
  final runes = name.runes.toList();
  final initial = String.fromCharCode(runes.first);
  ```

- **No secrets as compile-time constants.** `String.fromEnvironment` with an
  empty default makes the compiler delete the entire code path — silently, and
  invisibly at runtime. This shipped once and left the feedback channel dead for
  eight months. Transport targets are runtime configuration.

## Before opening a pull request

```bash
flutter test
flutter analyze
dart run custom_lint
```

New behavior needs a test. Bug fixes need a test that fails without the fix.

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/):
`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`.

## Reporting bugs

Include the app version, the device and Android version, and what you expected
to happen instead.

**Do not paste real user content into an issue** — no messages, no journal
entries, no profile names, no screenshots containing them. Reduce it to what
reproduces the bug. If you cannot, say so and we will find another way.

## Security issues

Do not open a public issue for a vulnerability, especially one that could expose
user data. Write to `info@3ofus.app` instead.

The Firestore rules are the entire defense for the feedback channel — there is no
Cloud Function in front of it, and the API key is readable from any APK. If you
find a way around them, that is a security report, not a bug report. You can
check your reasoning against the live rules engine with
`python tool/test_firestore_rules.py`.

## Code of Conduct

Participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md). Given who
this app is for, that is not a formality — dismissive or clinical-sounding talk
about plurality is not acceptable here.

## License

Contributions are licensed under the [Mozilla Public License 2.0](LICENSE), the
same license as the project.
