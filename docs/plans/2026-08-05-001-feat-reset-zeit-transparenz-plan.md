---
title: "feat: Profil-Passwort-Reset auf Zeit + Transparenz umbauen"
type: feat
status: done
date: 2026-08-05
origin: docs/brainstorms/2026-08-05-passwort-reset-zeit-transparenz-requirements.md
---

# feat: Profil-Passwort-Reset auf Zeit + Transparenz umbauen

## Overview

Der Profil-Passwort-Reset verliert alle Wissensfaktoren (Reset-Code, 3 Sicherheitsfragen) und wird zum reinen Zeit-Transparenz-Mechanismus: Jeder kann einen Reset starten, eine pro Profil einstellbare Wartefrist läuft sichtbar für alle, erfolgreicher Login bricht ab, nach Ablauf aktiviert sich das neue Passwort automatisch (lazy). Der Reset-Zustand wandert vom globalen Settings-Slot an das Profil.

## Problem Frame

Amnesie zwischen Anteilen ist bei DIS der Normalfall — Zugangsverlust ist Kernpfad, kein Edge-Case. Wissensfaktoren sind im Selber-Körper-Threat-Model doppelt untauglich (zu schwach gegen geteilte Biografie, zu stark gegen Amnesie). Details und Entscheidungen: siehe Origin-Doc (`docs/brainstorms/2026-08-05-passwort-reset-zeit-transparenz-requirements.md`).

## Requirements Trace

- R1: Reset auf jedes passwortgeschützte Profil ohne Wissensnachweis; Pending als bcrypt-Hash → Units 2, 4
- R2: Frist 24h Standard, pro Anteil bis 7 Tage, nur selbst änderbar, wirkt nicht auf laufende Resets → Units 1, 5
- R3: Unübersehbares piktografisches Banner für alle während der Frist → Unit 5
- R4: Erfolgreiche Passworteingabe des betroffenen Profils = einziger Abbruchweg; altes Passwort bleibt während Frist gültig → Unit 3
- R5: Auto-Aktivierung nach Ablauf, spätestens bei nächster Passwortprüfung → Units 2, 3
- R6: Neustart ersetzt Pending und startet Frist neu → Unit 2
- R7: Resets pro Profil unabhängig, mehrere parallel → Units 1, 2
- R8: Reset-Code + Sicherheitsfragen ersatzlos raus (UI, Erfassung, Prüf-Logik) → Unit 4
- R9: Debug-Verkürzung (20s, nur kDebugMode) bleibt → Unit 2
- R10/R11: Piktografische Bedienbarkeit; Warnung vor Start, Bestätigung bei Abbruch, Hinweis nach Aktivierung → Units 4, 5

## Scope Boundaries

- Kein Quorum/Council, kein Siegel-Modus, kein App-Einstieg/Krisenzugang (siehe Origin-Doc)
- Passwort-Hashing unverändert (bcrypt + Legacy-SHA256-Migration)
- Attribution „wer hat gestartet" bewusst nicht hier (wartet auf Aktions-Audit, Ideation #2)

### Deferred to Separate Tasks

- Aktions-Audit-Kopplung (Reset-Attribution): eigenes Vorhaben nach `docs/ideation/2026-08-05-dis-forschung-ideation.md` #2

## Context & Research

### Relevant Code and Patterns

- `lib/services/password_reset_service.dart` — heutiger Service (globaler Slot `password_reset_timer`/`password_reset_profile_id` in settingsBox, 24h/20s-Debug, pending→aktiv)
- `lib/models/profile.dart` — @HiveField(12) `resetCode`, (13) `pendingPasswordHash`, (14) `securityQuestions`, (15) `securityAnswersHashed`; höchstes Feld: 18 → neue Felder 19/20
- `lib/widgets/profile_actions_dialog.dart` — `_switchToProfile()` (Z~82: `verifyPassword`, Z~107: `_dataEntry.changeActiveProfile`) und `_showPasswordResetDialog()`-Familie (Z~151ff) = Entry-Point und Integrationsstelle
- `lib/services/profile_service.dart` — `_migrateProfilesToPermissions()` in `openBoxes()` = Migrations-Muster; copyWith-Muster
- `lib/core/events/profile_events.dart` — ProfileUpdatedEvent, ActiveProfileChangedEvent; Banner reagiert reaktiv (`profilesBox.watch()` bzw. ValueListenable wie ProfileSwitcherBar)
- `docs/oberflaechen-richtlinien.md` — Regel 1 (Anker/Arbeitsfläche), Regel 4 (Sättigung nur Halt/Notfall/Hilfe; Worst-State-Funde), Regel 10 (warnen vor Folgen, sagen was passiert, kein Zeitdruck, kein Ablauf ohne Ausgang)
- Custom Lints: `prefer_data_entry_architecture` (Datenoperationen über DataEntry), `hive_field_order_check` (Feldnummern nie wiederverwenden)

### Institutional Learnings

- Kein `docs/solutions/` im Repo — entfällt.

### External References

- Keine (bewusst übersprungen: Threat Model ist DIS-spezifisch, lokale Patterns stark; Forschungsgrundlage steckt im Origin-Doc).

## Key Technical Decisions

- **Reset-Zustand am Profil** (drei neue Felder: `resetStartedAt` @HiveField(19), `resetEndsAt` @HiveField(20) als beim Start eingefrorener Endzeitpunkt, `resetDurationHours` @HiveField(21) als Einstellung des Anteils): erfüllt R7, löst den globalen Slot ab. Der Ende-Snapshot macht „Friständerung wirkt nicht auf laufende Resets" trivial implementierbar, vereinfacht den Uhr-Guard (Enden verschieben) und trägt die Debug-Verkürzung (kurzes Ende beim Start unter kDebugMode).
- **Lazy Activation statt Background-Task:** Zustandsänderung (Aktivieren/Abbrechen) passiert ausschließlich im Login-Pfad über eine atomare Methode (löst die Fristende-Race-Frage, verhindert Doppel-Aktivierung). Das Banner ist strikt read-only: eigener 1-Minuten-Tick im Widget für Restzeit und Selbst-Ausblenden — `profilesBox`-Beobachtung allein feuert nicht durch Zeitablauf. Kein System-Timer/Alarm nötig, robust gegen App-Kills.
- **Reset-Operationen über DataEntry** (Lint `prefer_data_entry_architecture`): DataEntry bekommt `startPasswordReset(...)` und `checkAndHandleLogin(profile, enteredPassword)` als öffentliche API (delegiert an den Service, publiziert Events). Rückgabe als Enum `ResetLoginOutcome { none, wrongPassword, cancelled, activated }` — die UI verzweigt eindeutig und ruft `verifyPassword` nicht mehr direkt (die Methode übernimmt die komplette Prüfung inkl. Legacy-Hash-Pfad).
- **Deprecated Hive-Felder bleiben im Adapter** (12/14/15): Feldnummern nie wiederverwenden; Altprofile lesen die Felder weiter ein, Code ignoriert sie; kein Datenverlust-Risiko beim Downgrade.
- **Migration:** In `openBoxes()` nach dem Muster `_migrateProfilesToPermissions`: laufenden Alt-Reset (globale Keys) löschen, einmaliges Hinweis-Flag setzen (entschieden im Origin-Doc: abbrechen + Hinweis).
- **Uhr-Manipulation:** Rückwärtssprung-Guard (letzten gesehenen Zeitstempel in settingsBox pflegen; springt `now` dahinter zurück, friert die Restzeit ein statt sie zu verlängern). Vorwärtsstellen der Systemuhr verkürzt die Frist — akzeptierte Grenze: wer die Systemuhr stellt, hat Gerätevollzugriff; Banner bleibt bis zum Ablauf sichtbar.
- **Entry-Point bleibt der Passwort-Dialog des Profils** (heutige `_showPasswordResetDialog`-Stelle). Die Flow-Analyse-Empfehlung „nur aus eingeloggtem eigenem Profil" wurde verworfen — sie widerspricht R1 und dem Amnesie-Kernfall.
- **Frist-Semantik:** `resetDurationHours` ist die Einstellung des Ziel-Profils (Standard 24). Beim Reset-Start zählt der Wert des betroffenen Profils, nicht der des Startenden. Änderungen wirken nur auf künftige Resets.

## Open Questions

### Resolved During Planning

- Banner-Platzierung: feste Zeile im Hauptlayout (`lib/main.dart`) direkt unter der ProfileSwitcherBar — gehört zur Arbeitsfläche, verletzt nicht Regel 1; gesättigte Profilfarbe zulässig (Worst-State-Fund, Regel 4).
- Fristen-Stufen: drei Tasten 24h / 3 Tage / 7 Tage (Choice-Surface, kein Slider).
- Login-Integrationspunkt: `_switchToProfile()` in `profile_actions_dialog.dart`; Verification enthält Grep-Schritt auf weitere `verifyPassword`-Aufrufer.
- Hive-Adapter-Verhalten: deprecated Felder bleiben deklariert, Altdaten lesen sauber ein.
- Fristende-Serialisierung: eine atomare Methode `checkAndHandleLogin()` erledigt Aktivieren-oder-Abbrechen deterministisch vor der Passwortprüfung.

### Deferred to Implementation

- Exakte Piktogramme (Sanduhr vs. Ring) und Animationsdetails: entscheidet sich am Gerät gegen `docs/oberflaechen-richtlinien.md`.
- Ob zusätzlich zu Box-Beobachtung + Widget-Tick ein dediziertes Reset-Event fürs Banner nötig ist: hängt vom bestehenden Rebuild-Verhalten der ProfileSwitcherBar ab.

## Implementation Units

- [x] **Unit 1: Datenmodell — Reset-Zustand ans Profil**

**Goal:** Profile trägt seinen eigenen Reset-Zustand; Altfelder sind stillgelegt.

**Requirements:** R2, R7

**Dependencies:** Keine

**Files:**
- Modify: `lib/models/profile.dart` (+ generierter Adapter via build_runner)
- Test: `test/models/profile_reset_state_test.dart`

**Approach:**
- Neue Felder: `resetStartedAt` (DateTime?, @HiveField(19)), `resetEndsAt` (DateTime?, @HiveField(20), beim Start eingefrorener Endzeitpunkt), `resetDurationHours` (int?, @HiveField(21), Einstellung, null ⇒ 24)
- Getter: `hasActiveReset` (Start + Ende gesetzt), `isResetExpired` (now ≥ gespeichertes `resetEndsAt`) — das Modell rechnet nicht mit der Einstellung; die Frist friert der Service beim Start ein
- `hasPendingPassword` muss leeren String wie null behandeln (Altlast: heutiger Code schreibt `''` als „null")
- `copyWith`/`toMap`/`fromMap` erweitern; Felder 12/14/15 als `@Deprecated` markieren, aus keiner Logik mehr lesen
- `hive_field_order_check`-Lint beachten; danach `dart run build_runner build --delete-conflicting-outputs`

**Execution note:** Test-first für die Getter-Logik.

**Patterns to follow:** bestehendes copyWith-/fromMap-Muster in `lib/models/profile.dart`

**Test scenarios:**
- Happy path: Profil ohne Reset → `hasActiveReset == false`; mit gesetztem Start + Ende in der Zukunft → aktiv
- Edge case: exakt am Fristende (`now == resetEndsAt`) → `isResetExpired == true`
- Edge case: `pendingPasswordHash == ''` (Altlast) ⇒ `hasPendingPassword == false`
- Edge case: Altprofil-Map mit gesetzten `reset_code`/`security_questions`-Einträgen lädt fehlerfrei und ignoriert sie
- Happy path: Serialisierungs-Roundtrip (toMap → fromMap) erhält alle drei neuen Felder

**Verification:** `flutter test test/models/`, `dart run custom_lint` und `flutter analyze` sauber; Adapter generiert.

- [x] **Unit 2: PasswordResetService neu + DataEntry-API + Migration**

**Goal:** Service arbeitet pro Profil, aktiviert lazy, bricht bei Login ab; Alt-Reset wird migriert.

**Requirements:** R1, R5, R6, R7, R9

**Dependencies:** Unit 1

**Files:**
- Modify: `lib/services/password_reset_service.dart`, `lib/core/data_entry.dart`, `lib/core/events/profile_events.dart`, `lib/services/profile_service.dart` (nur falls Migration dort andockt)
- Test: `test/services/password_reset_service_test.dart` (neu)

**Approach:**
- `startReset(profileId, newPassword)`: nur bei `hasPassword`; liegt ein ABGELAUFENER Reset vor ⇒ erst aktivieren, dann neuen Reset gegen das nun aktive Passwort starten (gleiche atomare Ordnung wie im Login-Pfad); schreibt `pendingPasswordHash` (bcrypt) + `resetStartedAt = now` + `resetEndsAt = now + Frist` (Frist = `resetDurationHours` des Ziel-Profils, null ⇒ 24h; unter kDebugMode 20s); erneuter Aufruf ersetzt Pending und friert ein neues Ende ein (R6). Spätere Einstellungsänderungen berühren `resetEndsAt` nicht
- `checkAndHandleLogin(profile, enteredPassword)`: atomar — erst prüfen ob Frist abgelaufen ⇒ pending → aktiv (`activated`), sonst bei korrektem altem Passwort ⇒ Reset-Felder auf `null` setzen (`cancelled`); sonst `wrongPassword`/`none`. Reset-Felder immer echt auf null — niemals `''` als Null-Ersatz (dedizierte Clear-Methode statt copyWith-Sentinel). Einziger Ort, der Reset-Zustand mutiert
- Debug: 20s-Frist beim Start unter kDebugMode; `skipToLastTwentySeconds`-Ersatz setzt `resetEndsAt = now + 20s` am jeweiligen Profil (funktioniert für jede Fristlänge)
- Uhr-Guard: `last_seen_timestamp` in settingsBox bei jedem Check aktualisieren; Rückwärtssprung ⇒ `resetEndsAt` aller laufenden Resets um die Differenz nach hinten verschieben (Restzeit friert ein, pro Profil korrekt)
- Migration in `openBoxes()`: globale Keys `password_reset_timer`/`password_reset_profile_id` vorhanden ⇒ löschen + einmaliges Hinweis-Flag (z.B. `reset_migration_notice`) setzen; zusätzlich `pendingPasswordHash` aller Profile ohne neuen laufenden Reset auf null (räumt verwaiste Altlasten mit auf)
- Logging: niemals `passwordHash`/`pendingPasswordHash` in Logger-Data — nur Profilname, Zeiten, Zustände
- DataEntry: `startPasswordReset(...)` als öffentliche API, publiziert neues Event (z.B. `PasswordResetStartedEvent`); Abbruch/Aktivierung publizieren ebenfalls (fürs Banner und Logging); Logging via `logger` (kein `error:`-Parameter)

**Execution note:** Test-first — die Zustandsmaschine (start/replace/cancel/activate/expired) zuerst als Tests formulieren.

**Patterns to follow:** BaseService-Struktur des heutigen Service; Migrations-Muster `_migrateProfilesToPermissions()`; Event-Muster in `lib/core/events/profile_events.dart`

**Test scenarios:**
- Happy path: startReset setzt Pending+Startzeit; Profil B parallel resetten ⇒ beide unabhängig aktiv (R7)
- Happy path: nach Fristablauf liefert `checkAndHandleLogin` mit neuem Passwort `activated`, `passwordHash` == vorheriger Pending-Hash, Reset-Felder genullt
- Happy path: während Frist mit korrektem altem Passwort ⇒ `cancelled`, Pending weg, Login erfolgreich
- Edge case: startReset auf Profil ohne Passwort ⇒ abgelehnt
- Edge case: erneuter startReset während Frist ⇒ Pending ersetzt, Startzeit neu (R6); Frist des Ziel-Profils (7-Tage-Profil behält 7 Tage)
- Edge case: falsches Passwort während Frist ⇒ kein Abbruch, kein Login
- Edge case: Fristablauf + Eingabe des ALTEN Passworts ⇒ Aktivierung greift zuerst, altes Passwort scheitert
- Error path: Rückwärtsgestellte Uhr ⇒ Restzeit wächst nicht (eingefroren)
- Integration: Migration mit laufendem Alt-Reset ⇒ globale Keys weg, Pending genullt, Hinweis-Flag gesetzt; ohne Alt-Reset ⇒ no-op
- Edge case: Debug-Modus 20s nur unter kDebugMode
- Happy path: `resetDurationHours == null` ⇒ Ende = Start + 24h
- Edge case: startReset auf Profil mit abgelaufenem Reset ⇒ alter Pending wird erst aktiviert, dann neuer Reset gegen das neue Passwort
- Edge case: Frist-Einstellung während laufendem Reset geändert ⇒ `resetEndsAt` unverändert

**Verification:** Alle Service-Tests grün; `dart run custom_lint` meldet keine DataEntry-Verstöße.

- [x] **Unit 3: Login-Integration — Abbruch, Aktivierung, Rückmeldungen**

**Goal:** Der Login-Pfad ist der einzige Abbruch-/Aktivierungspunkt und meldet beides sichtbar zurück.

**Requirements:** R4, R5, R11

**Dependencies:** Unit 2. Koordination: Unit 4 ändert dieselbe Datei — Unit 3 vor Unit 4 umsetzen.

**Files:**
- Modify: `lib/widgets/profile_actions_dialog.dart`
- Test: `test/widgets/profile_actions_dialog_test.dart` (neu oder erweitern, falls vorhanden)

**Approach:**
- `_switchToProfile()`: statt direktem `verifyPassword` → `checkAndHandleLogin` der Unit 2; bei `cancelled` piktografische Bestätigung zeigen (Reset-Symbol durchgestrichen + Profilfarbe), bei `activated` Hinweis „neues Passwort ist jetzt aktiv" beim ersten erfolgreichen Login; danach unverändert `_dataEntry.changeActiveProfile`
- Nutzer bleibt nach Abbruch normal eingeloggt (kein erzwungener Passwortwechsel)
- Rückmeldungen als kurzer Vollflächen-Zustand im Dialogfluss (kein Toast): Piktogramm + Profilfarbe, manuell bestätigbar — kein Auto-Dismiss (keine Zeitdruck-Grenzen)
- Migrations-Hinweis-Flag aus Unit 2 hier einmalig anzeigen und löschen

**Test scenarios:**
- Happy path: Login während Frist mit richtigem Passwort ⇒ Bestätigung sichtbar, Reset weg, Profil aktiv
- Happy path: erster Login nach Ablauf mit neuem Passwort ⇒ Aktivierungshinweis sichtbar
- Edge case: Login ohne laufenden Reset ⇒ keinerlei Reset-UI
- Error path: falsches Passwort während Frist ⇒ normale Fehlermeldung, Reset unangetastet
- Integration: kompletter Widget-Flow Login→Abbruch→ProfileSwitch feuert `ActiveProfileChangedEvent`

**Verification:** Widget-Tests grün; manueller Durchlauf im Debug-Modus (20s-Frist) zeigt beide Rückmeldungen. Grep-Check: keine weiteren `verifyPassword`-Aufrufer für Profil-Zugang außerhalb des angepassten Pfads (sonst dort ebenfalls `checkAndHandleLogin` einsetzen).

- [x] **Unit 4: Rückbau Wissensfaktoren + neuer Start-Dialog**

**Goal:** Sicherheitsfragen und Reset-Code sind vollständig raus; der Reset-Start ist ein einziger piktografischer Dialog mit Warnung.

**Requirements:** R1, R8, R10, R11

**Dependencies:** Units 2, 3 (gleiche Datei wie Unit 3 — sequenziell nach Unit 3)

**Files:**
- Modify: `lib/widgets/profile_actions_dialog.dart` (Dialog-Familie ersetzen), `lib/modules/profile/profile_edit_screen.dart` (Sicherheitsfragen-Erfassung entfernen), `lib/models/profile.dart` (`verifySecurityAnswers`, `hashSecurityAnswer`, Legacy-Antwort-Hash entfernen)
- Test: bestehende betroffene Tests anpassen; `test/widgets/reset_start_dialog_test.dart` (neu)

**Approach:**
- `_showPasswordResetDialog`-Familie (Combined/NewPassword/Activate/PendingExplanation) ersetzen durch: einen Start-Dialog mit Reihenfolge Warnung ZUERST (Folgen piktografisch: Sanduhr + Auge = „läuft sichtbar für alle", Frist des Ziel-Profils), dann neues Passwort 2× (Mismatch inline am Feld, piktografisch), dann explizite Bestätigung (Regel 10: warnen vor Folgen, prüfen vor Absenden — Abbruch hier jederzeit = sanfter Ausgang vor dem Start) und einen Zustand „Reset läuft" (Restzeit, kein Abbruch-Button — Abbruch nur via Login, R4)
- Pending wird erst nach expliziter Bestätigung geschrieben (Dialog-Abbruch = kein Reset)
- Auf Profilen ohne Passwort: Startweg gar nicht anbieten
- Alle Verweise auf `resetCode`/`securityQuestions` in UI und Logik entfernen (Felder selbst bleiben deprecated im Modell)

**Test scenarios:**
- Happy path: Start-Dialog bestätigt ⇒ Reset läuft, Banner-Zustand beginnt
- Happy path: Dialog abgebrochen ⇒ kein Pending geschrieben
- Edge case: Passwort-Wiederholung stimmt nicht überein ⇒ kein Start, verständliche Rückmeldung
- Edge case: Profil ohne Passwort ⇒ kein Reset-Einstieg sichtbar
- Error path: laufender Reset + erneuter Start ⇒ Warnung zeigt, dass Frist neu beginnt (R6), erst nach Bestätigung ersetzt

**Verification:** `grep -r "securityQuestion\|resetCode"` in `lib/` liefert nur noch die deprecated Modell-Felder; alle Tests grün; `flutter analyze` sauber.

- [x] **Unit 5: Banner + Fristwahl-Einstellung**

**Goal:** Laufende Resets sind app-weit ohne Lesen erkennbar; jeder Anteil stellt seine Frist selbst ein.

**Requirements:** R2, R3, R10, R11

**Dependencies:** Units 1–4 (gleiche Datei wie Unit 4: `profile_edit_screen.dart` — sequenziell nach Unit 4)

**Files:**
- Create: `lib/widgets/reset_banner.dart`
- Modify: `lib/main.dart` (Banner-Zeile unter ProfileSwitcherBar), `lib/modules/profile/profile_edit_screen.dart` (Fristwahl)
- Test: `test/widgets/reset_banner_test.dart`

**Approach:**
- Banner reaktiv über `profilesBox`-Beobachtung (Muster ProfileSwitcherBar) PLUS eigenem 1-Minuten-Tick im Widget für Restzeit und Selbst-Ausblenden bei Ablauf (Box-Events feuern nicht durch Zeitablauf); Banner mutiert nie Zustand (read-only)
- Darstellung pro Reset: gesättigte Profilfarbe + Fortschrittsring, Zahl + Einheit als Bestätigung (Bild trägt, Wort bestätigt)
- Stapelung: bis 3 Banner untereinander; ab 4 ein aggregiertes Banner mit Farbpunkten aller betroffenen Profile, tappbar ⇒ Liste aller laufenden Resets (je Zeile Farbe + Restzeit, Tap ⇒ Login des Profils) — jeder Reset bleibt erreichbar, kein Sättigungs-Overload (Regel 4)
- Tap auf Banner öffnet den Login des betroffenen Profils (= direkter Einspruchsweg)
- Fristablauf während App offen: Banner verschwindet mit Ablauf (Aktivierung selbst bleibt lazy in Unit 2/3)
- Debug-Modus: Banner mit deutlicher Debug-Markierung
- Fristwahl in `profile_edit_screen`: drei Tasten 24h / 3 Tage / 7 Tage, nur im eigenen (eingeloggten) Profil sichtbar/änderbar; Änderung wirkt nur auf künftige Resets

**Test scenarios:**
- Happy path: laufender Reset ⇒ Banner sichtbar mit Farbe des betroffenen Profils; kein Reset ⇒ kein Banner
- Happy path: Tap ⇒ öffnet Passwort-Dialog des betroffenen Profils
- Edge case: 4+ parallele Resets ⇒ aggregierte Darstellung, keine 4 gesättigten Flächen
- Edge case: Fristablauf während App offen ⇒ Banner verschwindet ohne Neustart
- Happy path: Fristwahl speichert `resetDurationHours`; laufender Reset bleibt von Änderung unberührt
- Edge case: fremdes Profil bearbeitet ⇒ Fristwahl nicht sichtbar

**Verification:** Widget-Tests grün; Sichtprüfung gegen `docs/oberflaechen-richtlinien.md` (Regeln 1, 4, 5, 10) im Debug-Durchlauf.

- [x] **Unit 6: Integrations-Durchstich + Aufräumen**

**Goal:** Der komplette Lebenszyklus ist end-to-end belegt; tote Pfade sind weg.

**Requirements:** alle

**Dependencies:** Units 1–5

**Files:**
- Test: `test/integration/password_reset_flow_test.dart` (neu)
- Modify: Aufräumreste (ungenutzte Strings/Assets der alten Dialoge)

**Approach:**
- Integrationstest über echte Hive-Boxen (Testmuster der Service-Tests): Start → Banner-Zustand → Neustart (R6) → Abbruch per Login → erneuter Start → Ablauf (Debug-Frist) → Aktivierung beim Login
- Migrationstest vom Alt-Zustand (globale Keys gesetzt) einmal komplett

**Test scenarios:**
- Integration: voller Lebenszyklus wie oben in einem Durchlauf
- Integration: zwei Profile mit unterschiedlichen Fristen parallel — gegenseitig unbeeinflusst
- Integration: App-„Neustart" (Boxen schließen/öffnen) mitten in der Frist ⇒ Zustand und Restzeit korrekt

**Verification:** `flutter test` komplett grün; `dart run custom_lint` und `flutter analyze` sauber.

## System-Wide Impact

- **Interaction graph:** Login-Pfad (`profile_actions_dialog`) bekommt Vorschaltlogik; ProfileSwitcherBar/Hauptlayout erhält Banner-Zeile; DataEntry-API wächst um Reset-Operationen (+ Events).
- **Error propagation:** Service-Fehler bleiben Rückgabewerte + Logger (Muster heute); UI zeigt piktografische Zustände, keine Exceptions nach oben.
- **State lifecycle risks:** Aktivierung/Abbruch atomar in einer Methode; Migration löscht globale Keys idempotent; deprecated Felder bleiben lesbar (kein Crash bei Altdaten).
- **API surface parity:** Alle `verifyPassword`-Aufrufer für Profil-Zugang müssen den neuen Pfad nutzen (Grep-Check in Unit 3).
- **Integration coverage:** Unit 6 deckt den Lebenszyklus inkl. Box-Neustart und Migration ab.
- **Unchanged invariants:** Passwort-Hashing (bcrypt + Legacy-Upgrade), RBAC/Permissions, App-Level-Sperre, Feedback-Kanal — unverändert.

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| Vergessener `verifyPassword`-Aufrufer umgeht Abbruch/Aktivierung | Grep-Verification in Unit 3; Integrationstest Unit 6 |
| Hive-Migration bricht Altprofile | Felder nur ergänzen/deprecaten, nie umnummerieren; Roundtrip-Test in Unit 1; Migrationstest in Unit 6 |
| Banner nervt oder überlädt (Sättigung) | Aggregation ab 4 Resets; Sichtprüfung gegen Regel 4; Betroffenen-Feedback nach Release |
| Uhr-Vorwärtsstellen verkürzt Frist | Akzeptierte Grenze (dokumentiert im Origin-Doc); Banner bleibt bis Ablauf sichtbar |
| R6-Tauziehen zwischen Anteilen | Akzeptierte Grenze bis Council-Machtmodell (Origin-Doc, Key Decisions) |

## Documentation / Operational Notes

- `CLAUDE.md`-Abschnitt „Password Reset System" nach Umsetzung aktualisieren (beschreibt heute Reset-Codes + Sicherheitsfragen).
- Play-Store-Datenerklärung unberührt (alles lokal).

## Sources & References

- **Origin document:** [docs/brainstorms/2026-08-05-passwort-reset-zeit-transparenz-requirements.md](../brainstorms/2026-08-05-passwort-reset-zeit-transparenz-requirements.md)
- Related: `docs/ideation/2026-08-05-dis-forschung-ideation.md` (#1 Krisenpfad, #2 Aktions-Audit, #6 Machtmodell)
- Code: `lib/services/password_reset_service.dart`, `lib/models/profile.dart`, `lib/widgets/profile_actions_dialog.dart`
