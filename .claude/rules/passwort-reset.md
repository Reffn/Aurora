---
paths:
  - "lib/**/*password*"
  - "lib/**/*reset*"
  - "lib/models/profile.dart"
  - "test/**/*password*"
  - "test/**/*reset*"
---

# Password Reset System

Time and visibility carry the reset — knowledge factors are gone. In a body
shared by several parts, a security question is both too weak (shared
biography) and too strong (amnesia is the normal case, not the edge case).
See `docs/brainstorms/2026-08-05-passwort-reset-zeit-transparenz-requirements.md`.

- Anyone can start a reset on any password-protected profile, no proof required
- A waiting period runs, visible to everyone (`ResetBanner`); each part sets
  its own length (1/3/7 days, default 24h) and a change never touches a
  running reset — the end time is frozen at start
- Entering the profile's password during the period aborts the reset. That is
  the only way to abort, and it is the whole protection
- After the period the pending password activates by itself — lazily, at the
  next password check. State changes only in `checkAndHandleLogin`, which
  returns `ResetLoginOutcome`; nothing else mutates reset state
- Reset state lives on the profile (`resetStartedAt`, `resetEndsAt`,
  `resetDurationHours`), not in a global settings slot
- Setting the system clock back does not extend a deadline; the service holds
  the last seen timestamp and shifts the end instead
- Service: `PasswordResetService` (own injectable clock, so tests can move time)
