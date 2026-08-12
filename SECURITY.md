# Security Policy

Aurora holds some of the most sensitive data a person can have: who they are,
who else lives in their system, what they take, where they were, and what they
wrote down on a bad day. All of it stays on the device. A security bug here
does not leak a shopping history — it can out someone.

Please treat that as the standard when you decide whether something is worth
reporting.

*[Deutsche Fassung weiter unten](#sicherheitshinweise-deutsch)*

## Reporting a vulnerability

**Do not open a public issue.** Send the report to **info@3ofus.app**, or use
GitHub's *Report a vulnerability* button under the Security tab if it is
available to you.

Include what you need to make the problem reproducible: affected version, the
steps, and what an attacker gains. A proof of concept helps. If you are unsure
whether something counts, report it — a false alarm costs an email.

This is a small project, not a company with a security desk. Realistically:

| | |
|---|---|
| First reply | within 7 days |
| Assessment | within 14 days |
| Fix for a confirmed serious issue | in the next release, and I will say when that is |

If you get no reply within 14 days, assume the mail was lost and write again.

Please give me a chance to ship a fix before you publish. There is no bounty
programme — I have no budget for one. Credit in the release notes if you want
it, silence if you prefer.

## Supported versions

Only the current release on Google Play receives fixes. Older versions are not
patched; the update path is the fix.

## In scope

- Anything that exposes profile data, messages, journal entries, medication
  records or location history to another app, another user of the device, or
  the network
- Bypassing the app lock or password reset
- Weaknesses in what leaves the device: the feedback channel and the opt-in
  telemetry, including anything that would make a payload re-identifiable
- Firestore rules that permit more than create-only writes to `feedback` and
  `telemetry`
- Dependency vulnerabilities that are actually reachable from Aurora's code

## Out of scope

- Attacks that require an unlocked device already in the attacker's hands, or
  a rooted device
- The Firebase Web API keys in `google-services.json` and the web bundle.
  These are client identifiers by design and are meant to be public; the
  security boundary is the Firestore rules, not their secrecy. If you can get
  past the rules, that is in scope and I want to hear about it
- Reports from automated scanners with no demonstrated impact

## Design commitments you can hold me to

These are properties of the app, not aspirations. If you find one broken, it
is a security bug:

1. **Nothing is sent without explicit consent.** Feedback is user-triggered;
   telemetry requires opt-in.
2. **Everything sent is inspectable** in Settings → *Was Aurora sendet*, in
   full, stored locally.
3. **Nothing permits re-identification.** No profile IDs, no installation IDs,
   no session chains, no entry counts.
4. **Location never reaches us.** Not in feedback, not in telemetry, not
   rounded, not as a country. Coordinates go to OpenStreetMap for maps and
   geocoding, and to emergency contacts the user picks — nowhere else.

---

## Sicherheitshinweise (deutsch)

Aurora hält Daten, mit denen sich ein Mensch outen lässt. Alles bleibt auf dem
Gerät. Bitte lege diesen Maßstab an, wenn du überlegst, ob ein Fund eine
Meldung wert ist — im Zweifel ja.

**Bitte kein öffentliches Issue.** Melde an **info@3ofus.app** oder über
*Report a vulnerability* im Security-Tab.

Erste Antwort binnen 7 Tagen, Einschätzung binnen 14. Kommt nach 14 Tagen
nichts, ging die Mail verloren — schreib nochmal. Ein Fix für ein bestätigtes
ernstes Problem kommt in die nächste Version, und ich sage dir, wann die
kommt.

Gepflegt wird nur die aktuelle Version bei Google Play. Ein Bounty-Programm
gibt es nicht. Nennung in den Release Notes, wenn du magst.

Im Umfang: alles, was Profildaten, Nachrichten, Tagebuch, Medikamente oder
Standortverlauf nach außen trägt; das Umgehen der App-Sperre; Schwächen im
Rückkanal; zu weite Firestore-Regeln. Nicht im Umfang: entsperrtes Gerät in
fremder Hand, gerootete Geräte, die öffentlichen Firebase-Client-Keys,
Scanner-Ausgaben ohne belegte Wirkung.

Die vier Zusagen oben (Einwilligung, Einsehbarkeit, keine Re-Identifikation,
kein Standort) sind Eigenschaften der App. Ist eine davon gebrochen, ist das
ein Sicherheitsfehler.
