---
date: 2026-08-05
topic: dis-forschung-app-luecken
focus: Krankheitsbild + aktuelle DIS-Forschung → was Aurora noch anpassen oder einbauen sollte
mode: repo-grounded
---

# Ideation: Aurora im Licht der aktuellen DIS-Forschung

## Grounding Context

**Codebase:** Flutter/Dart, alles lokal (Hive), kein Cloud-Sync. Module: Chat, Kalender, Medikamente, Tagebuch, Kontakte, Finder, Notfall, Hilfe, Mantras, Spiele, Zeitachse, Feedback, Einstellungen. Multi-Profil (1 Profil = 1 Anteil), Admin-Rolle mit RBAC, DataEntry-Architektur mit EventBus. Designregeln: „Text trägt nicht", Farbtrennung, Anker-Menü, Privacy first.

**Interner Forschungsabgleich** (`docs/superpowers/research/2026-08-04-dis-abgleich-bericht.md`): Lücken B1 (Grounding — TP1 in Umsetzung), B2 (kein Sicherheitsplan/Krisenpfad), B3 (Triggererkennung aus vorhandenen Daten), B4 (keine Wir-Ebene), B7 (Login sperrt im Krisenmoment), B8 (Namenszwang); gegen das Therapieziel: C1 (unilaterale Admin-Macht), C2 (maximale Trennung als Default).

**Externe Recherche (2022–2026):** TOP-DD RCT / Finding Solid Ground (Stabilisierung vor Traumaarbeit, große Effektstärken; Phasen zirkulär); Brand et al. 2019 (Web-Psychoedukation wirksam, 90 % Zufriedenheit); Zeitverlust-Log als empfohlene Kernfunktion; innere Kommunikation/Kooperation statt Fusion als Therapieziel („System Councils"); NSSI in DIS funktional → Stanley-Brown Safety Planning adaptieren; Schlaf↔Dissoziation bidirektional (Alpträume/REM); trauma-informed UX: Safety, Clarity, Choice, Predictability, Sensory Management; Cross-Domain-Vorbilder: PTSD Coach, Epilepsie-Anfallstagebücher, Bipolar-Tracker, SBAR-Schichtübergabe, Demenz-Realitätsanker.

## Ranked Ideas

### 1. Krisenpfad ohne Hürde
**Description:** Stanley-Brown-Sicherheitsplan als 1-Tap-Ablauf (Grounding-Übung → Plan-Schritte → Kontakte), erreichbar vor dem Login (Lockscreen-Widget / Krisenpass), plus Papier-QR-Backup und „Save-State" (stabilen Moment mit Musik/Bild/Mantra speichern, in der Krise wiederherstellen). Tarnmodus und Krisenzugang als ein Designproblem lösen: getarnter Lockscreen-Einstieg.
**Rationale:** Höchste Stakes (bis 72 % Suizidversuche bei DIS), beste Evidenz (Stanley-Brown SPI), adressiert B2 und B7 gleichzeitig; baut auf TP1-Grounding-Übungen auf.
**Downsides:** Sicherheits-/Privacy-Abwägung am Lockscreen; sorgfältige Abgrenzung, was ohne Login sichtbar sein darf.
**Confidence:** 90%
**Complexity:** Medium-High
**Status:** Unexplored

### 2. Switch-Event als First-Class-Datum + Aktions-Audit
**Description:** Switch (wer/wann/Dauer/Kontext) als zentrales Hive-Objekt über DataEntry; jede Aktion (Nachricht, Termin, Löschung) mit Anteil-Attribution geloggt („Git-Blame für den Körper").
**Rationale:** Eine Datenmodell-Entscheidung speist Übergabe (#3), Trigger-Engine (#4), Zeitachse und späteren Therapie-Export — größter Compounding-Hebel.
**Downsides:** Migration bestehender Daten; Anzeige muss amnesie-sensibel gestaltet werden (nicht beschämend).
**Confidence:** 85%
**Complexity:** Low-Medium
**Status:** Unexplored

### 3. Übergabe & Orientierung nach Switch
**Description:** Piktografische Ankunftskarte nach Wechsel (wer/wo/wann/was lief — analog SBAR-Schichtübergabe und Demenz-Realitätsankern: Uhr, Ort, aktiver Anteil, nächste Termine, nur Symbole), optional 10-Sekunden-Voice-Diktat statt Tippen, Übergabe-Ritual bei erwartetem Wechsel.
**Rationale:** Zeitverlust ist Kernsymptom; Desorientierung nach Switch der größte Alltagsschmerz; verbindet vorhandene Amnesie-Brücken (Tagebuch, Kalender, Finder, Zeitachse); passt exakt zu „Text trägt nicht". Entspricht TP3 des Berichts, geschärft.
**Downsides:** Informationsflut vermeiden (Sensory Management); Voice-Aufnahmen brauchen klare Consent-Regeln zwischen Anteilen.
**Confidence:** 85%
**Complexity:** Medium
**Status:** Unexplored

### 4. Trigger-Früherkennung lokal + Schlaf als Datenquelle
**Description:** Lokale Musteranalyse über Switch-Log, Stimmung, Kalender und neu: Schlaf-/Alptraum-Kurzlog (2-Tap-Erfassung). Bei erkanntem Risikomuster sanfte präventive Grounding-Einladung (Farbsignal, keine Alarm-Sprache).
**Rationale:** Bericht: „größter Hebel bei kleinstem Aufwand" (B3/TP7); Schlaf↔Dissoziation bidirektional belegt; Prävention schlägt Reaktion (Predictability).
**Downsides:** False-Positives können selbst triggern; Tonalität der Hinweise heikel; mit B11 verflochten (laut Bericht).
**Confidence:** 80%
**Complexity:** Medium
**Status:** Unexplored

### 5. Psychoedukation nach Finding Solid Ground
**Description:** Phase-1-Stabilisierungsinhalte (Logik des TOP-DD-Workbooks) piktografisch/audio-basiert ins vorhandene Hilfe-Modul; zirkulär statt linear, kein Fortschrittszwang.
**Rationale:** Brand et al. 2019: web-basierte Psychoedukation wirksam (Active Coping, Self-Efficacy ↑, Dissoziation ↓), 90 % Zufriedenheit. Additiv, sperrt nichts, kein Risiko fürs Machtmodell.
**Downsides:** Erhebliche Contentarbeit (Übersetzung in bildbasierte UI); Urheberrecht/Lizenz der Workbook-Inhalte prüfen — Konzepte nutzen, nicht Texte kopieren.
**Confidence:** 75%
**Complexity:** Medium
**Status:** Unexplored

### 6. Wir-Ebene + Council-Machtmodell
**Description:** Systemblick-Seite (geteilte Körper-Notizen, geteilte Alarme, Tagesplan des Systems) + Entscheidungen über Council/Quorum statt unilateralem Admin (Sperren/Löschen braucht Zustimmung mehrerer Anteile, Veto bei Eigenschutz); Trennung↔Teilen als Spektrum-Einstellung statt Maximal-Trennung als Default.
**Rationale:** Kooperation (nicht Fusion) ist das dokumentierte Therapieziel; adressiert B4, C1, C2; laut Recherche Marktlücke — keine App bildet innere Kooperation ab.
**Downsides:** Hochriskant (TP4/TP5 im Bericht), tiefer Eingriff in RBAC; vor dem Bau Betroffenen- und Behandelnden-Feedback einholen.
**Confidence:** 70%
**Complexity:** High
**Status:** Unexplored

### 7. Namenlose & fluide Anteile (Quick Win)
**Description:** Name beim Profil optional; Farbe + Avatar (+ optionales Tag wie „der Schnelle") genügt als Identität, überall UTF-16-sicher gerendert.
**Rationale:** ICD-11 erlaubt unbenannte Anteile (B8); senkt Onboarding-Blockade; kleinster Aufwand aller Ideen.
**Downsides:** Alle UI-Stellen mit Namensannahme (Initialen, Chat-Bubbles, Listen) durchforsten.
**Confidence:** 90%
**Complexity:** Low
**Status:** Unexplored

## Rejection Summary

| # | Idee | Grund |
|---|------|-------|
| 1 | Therapie-Export / Witness-Rolle | Wertvoll, aber Folge-Feature von #2 (erst Datenmodell); Live-Dashboard kollidiert mit Privacy-first |
| 2 | Trennungs-Spektrum (solo) | In #6 aufgegangen |
| 3 | Doodle-/Voice-Erfassung (solo) | Existiert bereits als Attachment-System; als Variante in #3 |
| 4 | Lebensqualitäts-Radar | Tracking-Last vs. dünnere Evidenz; Positiv-Elemente passen ins Tagebuch |
| 5 | Tarnmodus / Papier-Codex (solo) | In #1 aufgegangen |
| 6 | Sportteam-Playbook-Templates | Zu vage; überlappt #1 und #4 |
| 7 | Sensor-Krisenerkennung (Herzschlag/Schreie) | Übergriffig, False-Positive-Risiko, Privacy-Konflikt |
| 8 | Admin-Burnout-Cockpit | In #6 aufgegangen |
| 9 | Proaktive Notifications (solo) | In #4 aufgegangen (präventive Einladung) |

## Quellen (extern)

- TOP-DD Study Publications — https://topddstudy.com/publications.php
- ISSTD Treatment Guidelines (rev. 2011) — https://www.isst-d.org/wp-content/uploads/2025/12/GUIDELINES_REVISED2011.pdf
- Phase-Oriented Treatment Systematic Review (2025) — https://www.tandfonline.com/doi/full/10.1080/20008066.2025.2545734
- Inter-Identity Amnesia Meta-Analysis — https://www.sciencedirect.com/science/article/pii/S0272735824001351
- Finding Solid Ground Program Workbook (Brand et al.) — https://www.researchgate.net/publication/363004073
- Brand et al. 2019, Online-Psychoedukation bei DIS — https://onlinelibrary.wiley.com/doi/full/10.1002/jts.22370
- Sleep & Dissociation (2024) — https://www.sciencedirect.com/science/article/abs/pii/S1053810024000758
- Trauma-Informed Design Scoping Review (2025) — https://journals.sagepub.com/doi/10.1177/20552076251360925
- Stanley & Brown, Safety Planning Intervention (Adaption für NSSI/Suizidalität)
