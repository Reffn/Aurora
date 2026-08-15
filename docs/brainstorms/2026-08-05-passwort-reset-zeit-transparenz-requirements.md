---
date: 2026-08-05
topic: passwort-reset-zeit-transparenz
---

# Profil-Passwort-Reset: Zeit + Transparenz statt Wissensfaktoren

## Problem Frame

Aurora-Profile (Anteile) haben private Bereiche mit eigenem Passwort. Ein Mensch bedient alle Profile — Amnesie zwischen Anteilen ist bei DIS der erwartbare Normalfall, nicht die Ausnahme. Zugangsverlust ist damit ein Kernpfad, kein Edge-Case.

Das Threat Model ist einzigartig: Der „Angreifer" ist ein anderer Anteil im selben Körper — gleiche Biometrie, gleiche Dokumente, gleiche Biografie, gleicher Gerätebesitz. Alle klassischen Auth-Faktoren (Wissen, Besitz, Inhärenz) kollabieren. Wissensfaktoren sind doppelt untauglich: zu schwach (geteilte Biografie) und zu stark (Amnesie).

Der heutige Stack (Reset-Code + 3 Sicherheitsfragen + 24h-Pending-Timer + Aktivieren-Button, `lib/services/password_reset_service.dart`) ist für Nutzer zu kompliziert, schwer wartbar, und der Worst Case (alles vergessen) bleibt ungelöst.

**Entschieden:** Wissen wird als Faktor komplett gestrichen. Was trägt, ist Zeit + Transparenz — das Einspruchsfenster des heutigen Timers, zu Ende gedacht.

```
Reset gestartet (neues Wunsch-Passwort erfasst, keine Wissensprüfung)
        │
        ▼
Wartefrist läuft (Standard 24h, pro Anteil bis 7 Tage einstellbar)
        │  Banner für ALLE Anteile: Profilfarbe + Restzeit, piktografisch
        │
        ├── Login ins betroffene Profil gelingt ──► Reset automatisch abgebrochen
        ├── Neuer Reset-Start ──────────────────► Frist beginnt von vorn
        │
        ▼ Frist abgelaufen
Neues Passwort automatisch aktiv, altes ungültig
```

## Requirements

**Reset-Ablauf**
- R1. Ein Reset auf jedes passwortgeschützte Profil kann von jedem Bedienenden gestartet werden — ohne Wissensnachweis. Beim Start wird das neue Wunsch-Passwort erfasst und als pending gespeichert (bcrypt-Hash in `pendingPasswordHash`, wie heute).
- R2. Die Wartefrist beträgt standardmäßig 24 Stunden. Jeder Anteil kann für sein eigenes Profil eine längere Frist wählen (bis 7 Tage) — Schutz für selten frontende Anteile. Die Frist ist nur aus dem eingeloggten eigenen Profil änderbar und wirkt nicht auf bereits laufende Resets.
- R3. Ein laufender Reset ist während der gesamten Frist für alle Profile unübersehbar sichtbar: Profilfarbe des betroffenen Anteils + Restzeit, ohne Lesen erkennbar (gemäß `docs/oberflaechen-richtlinien.md`).
- R4. Erfolgreicher Login in das betroffene Profil während der Frist bricht den Reset automatisch ab; „erfolgreich" heißt korrekte Passworteingabe für dieses Profil (Biometrie oder App-Entsperrung zählen nicht — der Abbruch beweist Passwortwissen). Das alte Passwort bleibt während der gesamten Frist gültig. Es gibt keinen anderen Abbruchweg.
- R5. Nach Fristablauf wird das neue Passwort automatisch aktiv; das alte verliert seine Gültigkeit. Kein separater Aktivieren-Schritt — „automatisch" heißt ohne Nutzeraktion, spätestens wirksam bei der nächsten Passwortprüfung des Profils.
- R6. Ein erneuter Reset-Start während laufender Frist ersetzt das Pending-Passwort und startet die Frist neu. Eine Verkürzung ist ausgeschlossen.
- R7. Resets laufen pro Profil unabhängig; mehrere Profile können gleichzeitig einen laufenden Reset haben (heute: ein globaler Slot).

**Rückbau**
- R8. Reset-Code und Sicherheitsfragen (inkl. Antwort-Hashes) entfallen ersatzlos — UI, Erfassung und Prüf-Logik.
- R9. Die Debug-Verkürzung (20 Sekunden, nur im Flutter-Debug-Mode) bleibt erhalten.

**Verständlichkeit**
- R10. Der gesamte Ablauf ist piktografisch bedienbar (Uhr-/Sanduhr-Metapher); Text bestätigt nur.
- R11. Rückmeldungen nach Regel 10 der Oberflächen-Richtlinien: vor dem Reset-Start Warnung mit Folgen (Frist läuft, Banner für alle sichtbar); beim Auto-Abbruch durch Login sichtbare Bestätigung; nach Auto-Aktivierung sichtbarer Hinweis beim nächsten Öffnen des Profils.

## Success Criteria

- Totalverlust (alle Zugangsdaten vergessen) führt ohne Admin-Eingriff und ohne Datenverlust zurück in jedes Profil — maximale Wartezeit ist die eingestellte Frist.
- Ein Anteil, der sein Passwort kennt, kann eine Übernahme verhindern, sofern er innerhalb der Frist einmal einloggt (Login = Abbruch); genau dafür ist die Frist pro Anteil einstellbar.
- Konzeptlast sinkt von vier Mechanismen (Passwort, Code, Fragen, Timer) auf zwei (Passwort, Frist).
- Sicherheitsfragen- und Reset-Code-Pfade sind aus dem Code entfernt.

## Scope Boundaries

- Kein Quorum-/Council-Beschleuniger (Ausbaustufe B) — wartet auf das Machtmodell (Ideation #6, `docs/ideation/2026-08-05-dis-forschung-ideation.md`).
- Kein Siegel-Modus (Zugriff sichtbar statt verschlossen, Ansatz C) — nur mit Betroffenen-Feedback.
- App-Einstieg/Krisenzugang (B7, Ideation #1) ist ein separates Vorhaben; hier geht es nur um Profil-Passwörter.
- Keine Änderung am Passwort-Hashing (bcrypt + Legacy-Migration bleibt wie ist).

## Key Decisions

- **Wissen gestrichen:** Amnesie macht Wissensfaktoren prinzipiell untauglich, das Selber-Körper-Threat-Model macht sie zugleich wertlos. Zeit + Transparenz ist der einzige tragfähige Faktor.
- **Login = Abbruch:** Wer das Passwort noch weiß, ist geschützt; wer es vergessen hat, kommt garantiert wieder rein. Selbstregulierend, kein Sonderfall-UI.
- **Frist pro Anteil einstellbar:** Selbstbestimmung des Anteils über den eigenen Bereich (trauma-informed: Choice); Standard bleibt 24h.
- **Auto-Aktivierung statt Button:** Ein Konzept weniger; der Timer selbst ist die einzige Hürde.
- **Bewusste Tradeoffs:** Eine lange eigene Frist bedeutet im eigenen Amnesiefall auch lange eigene Wartezeit (Selbstbestimmung schlägt Komfort). Externe Personen mit dauerhaftem Gerätezugriff sind Sache der Geräte-/App-Sperre, nicht der Profil-Passwörter — Frist + Banner wirken aber auch gegen sie.
- **Bekannte Grenze (akzeptiert):** Zwei Anteile können sich per R6 endlos gegenseitig den Reset ersetzen (Tauziehen). Das bleibt per Banner sichtbar, konvergiert aber technisch nicht — die saubere Lösung kommt erst mit dem Council-Machtmodell (Ideation #6). Bewusst nicht technisch begrenzt, um keine neuen Sperr-Vektoren gegen legitime Vergesser zu schaffen.

## Dependencies / Assumptions

- Hive-Felder (`resetCode`, `securityQuestions`, `securityAnswersHashed`) werden deprecated, Feldnummern nicht wiederverwendet (`hive_field_order_check`-Lint); Migration bestehender Profile in Planung klären.
- Banner ist ein „Worst-State-Fund" im Sinne der Oberflächen-Richtlinien — gesättigte Farbe dafür zulässig.
- Profile ohne Passwort brauchen keinen Reset (Login ist frei); Reset-Start auf solche Profile bleibt wie heute blockiert.
- Der Reset-Zustand wandert vom globalen Settings-Slot an das Profil: Startzeit und Frist werden pro Profil gespeichert (neue Hive-Felder); `pendingPasswordHash` existiert bereits.
- Migration: Ein zur Migrationszeit laufender Alt-Reset wird abgebrochen; der Betroffene sieht einen Hinweis und startet bei Bedarf neu (entschieden, kein offener Punkt).

## Outstanding Questions

### Deferred to Planning
- [Affects R3][Technical] Banner-Platzierung und Verhalten (App-Start, Profilwechsel, Dauerbanner?) gemäß Oberflächen-Richtlinien.
- [Affects R2][Technical] Fristen-Stufen im UI (z.B. 24h / 3 Tage / 7 Tage statt freiem Slider).
- [Affects R3][Needs research] Soll angezeigt werden, welches Profil den Reset gestartet hat? Attribution kann nach einem Switch falsch sein; ggf. an Aktions-Audit (Ideation #2) koppeln statt jetzt lösen.
- [Affects R4][Technical] Integrationspunkt des Auto-Abbruchs im Login-Pfad (alle Stellen, an denen `verifyPassword` für Profil-Zugang läuft).
- [Affects R5, R6][Technical] Serialisierung am Fristende: Auto-Aktivierung vs. gleichzeitiger Neustart — wer gewinnt.
- [Affects R5][Technical] Uhr-Manipulation: Rückwärtssprung der Systemzeit erkennen (zuletzt gesehene Zeit speichern, Frist einfrieren statt verlängern).
- [Affects R8][Technical] Hive-Adapter-Verhalten beim Lesen von Altprofilen mit gesetzten deprecated Feldern.
- [Affects R3][Technical] Banner bei mehreren gleichzeitigen Resets (Stapelung ohne Sättigungs-Overload, Regel 4) und Zeitdarstellung ohne Lesen (Ring/Sanduhr statt Ziffern als Träger).

## Next Steps

-> `/ce-plan` für strukturierte Implementierungsplanung
