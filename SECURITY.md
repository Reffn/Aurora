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
- Bypassing a profile password by any route other than the documented 24-hour
  reset — that one is designed, and described below
- Weaknesses in what leaves the device: the feedback channel and the opt-in
  telemetry, including anything that would make a payload re-identifiable
- Firestore rules that permit more than create-only writes to `feedback` and
  `telemetry`
- Dependency vulnerabilities that are actually reachable from Aurora's code

## The unlocked device, named instead of excluded

Most policies here exclude "the attacker already has your unlocked phone".
This one used to as well. For Aurora that exclusion is wrong: the person
holding the unlocked phone is not an exotic attacker in this app's life —
often enough they are *the* attacker, and everyone using Aurora knows it.

So instead of excluding it, here is what is true today:

- **Data at rest is not encrypted by Aurora.** The Hive boxes are plaintext
  and so are attachments. The per-profile password is a gate in the interface;
  no key is derived from it. What protects the files is Android's own device
  encryption — which works while the phone is locked and does nothing once it
  is open.
- **Screen content is protected** with `FLAG_SECURE`, including the preview
  image in the app switcher.
- **A password-protected profile opens for anyone who has the phone for 24
  hours.** Starting a reset and waiting out the deadline activates a new
  password. This is deliberate — an alter permanently locked out of their own
  phone is the worse failure — but it is a bypass, and you should know it is
  there before you rely on the password.

All three are known. Telling me that a rooted phone or a forensic extraction
can read the data is correct and does not need a mail. Showing me a way to
read it **without** either — from another app, over the network, or past
`FLAG_SECURE` — very much does, and it is in scope above.

## Out of scope

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
   no session chains, no entry counts. This holds for the payload *and* for
   the transport underneath it — see the note below.
4. **Location never reaches us.** Not in feedback, not in telemetry, not
   rounded, not as a country. Coordinates go to OpenStreetMap for maps and
   geocoding, and to emergency contacts the user picks — nowhere else. The
   User-Agent on those requests names the operator, not the condition.

### Where these three were broken, and since when they hold

Until 16.08.2026, commitments 1–3 were false, and the reason is worth writing
down: Firebase was initialised in the app's startup path, unconditionally. On
every cold start of every install — including one belonging to someone who
had declined telemetry and never opened the feedback form — the app
registered a Firebase Installation ID with Google and exchanged a Play
Integrity attestation. The transmission log knew neither, so *What Aurora
sends* said "nothing has been sent yet" while the connection was up.

No profile data, no message, no counter was ever part of it. It was still
three broken promises, made on a screen whose entire purpose is being
checkable.

Firebase now starts inside the first actual send, so the handshake is part of
a transmission that gets logged. Guarded by
`test/core/keine_stille_verbindung_test.dart`. The full write-up, including
what the fix does *not* clean up, is in
`docs/befund-stiller-firebase-start.md`.

Found because someone read the code and said so publicly. That is the
process working.

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
Standortverlauf nach außen trägt; das Umgehen eines Profilpassworts auf einem
anderen Weg als über den beschriebenen 24-Stunden-Reset; Schwächen im
Rückkanal; zu weite Firestore-Regeln. Nicht im Umfang: die öffentlichen
Firebase-Client-Keys, Scanner-Ausgaben ohne belegte Wirkung.

**Das entsperrte Gerät in fremder Hand steht hier bewusst nicht unter „nicht
im Umfang".** In dieser App ist das nicht der ausgefallene Angreifer, sondern
oft genug der eigentliche. Was heute gilt: Aurora verschlüsselt die Daten
**nicht** selbst — die Boxen liegen im Klartext, und das Profilpasswort ist
eine Sperre in der Oberfläche, aus der kein Schlüssel abgeleitet wird. Es
schützt die Geräteverschlüsselung von Android, und die wirkt nur, solange das
Gerät gesperrt ist. Der Bildschirminhalt ist mit `FLAG_SECURE` geschützt, auch
das Vorschaubild im App-Wechsler. Und ein passwortgeschützter Anteil öffnet
sich für jeden, der das Gerät 24 Stunden hat — der Reset ist Absicht, aber er
ist eine Umgehung, und wer sich auf das Passwort verlässt, soll das wissen.

Alle drei sind bekannt. Dass ein gerootetes Gerät oder eine forensische
Auslesung an die Daten kommt, stimmt und braucht keine Mail. Ein Weg dorthin
**ohne** beides — aus einer anderen App, über das Netz oder an `FLAG_SECURE`
vorbei — sehr wohl.

Die vier Zusagen oben (Einwilligung, Einsehbarkeit, keine Re-Identifikation,
kein Standort) sind Eigenschaften der App. Ist eine davon gebrochen, ist das
ein Sicherheitsfehler. Die ersten drei waren es bis zum 16.08.2026, weil
Firebase im Startpfad lief — siehe `docs/befund-stiller-firebase-start.md`.
