<!--
Thanks for the contribution. Keep this short — the diff says what changed,
this says why, and what you checked.
-->

## What this changes

<!-- One or two sentences. Why, not how. -->

## Why

<!-- What was broken or missing? Link the issue if there is one: Fixes #123 -->

## How I checked it

<!-- Tick what applies. Delete what does not. -->

- [ ] `flutter test` passes
- [ ] `flutter analyze` shows no new errors or warnings
- [ ] `dart run custom_lint` shows no new ERROR or WARNING
- [ ] Tried it on a real device, not only in tests
- [ ] Screenshot or recording attached (for anything visible)

## For changes to the interface

<!-- Delete this section if the PR touches no UI. -->

Checked against `docs/oberflaechen-richtlinien.md`:

- [ ] Usable without reading — the words only confirm what the shape and
      colour already say
- [ ] Saturated colour is reserved for what must be found in the worst state
- [ ] Choice surfaces and content surfaces are kept apart

## For changes that send data

<!-- Delete this section if nothing leaves the device. -->

- [ ] Nothing is sent without explicit consent
- [ ] Everything sent is visible in Settings → *Was Aurora sendet*
- [ ] Nothing added permits re-identification — no IDs, no session chains,
      no counts
- [ ] No location data, in any form, at any precision
