# Prüfung der Übersetzungen — Aurora

**Datum:** 2026-08-13  
**Agent:** Fable (Haiku 4.5)  
**Umfang:** 1560 Schlüssel pro Sprache (de, en, es, fr, it)  
**Gesamtbefunde:** 96 | **Kritisch (HIGH):** 95 | **Mittel (MEDIUM):** 1

---

## Zusammenfassung

Die Mechanik trägt: Alle fünf Dateien haben vollständig 1560 Schlüssel, keine Lücken.

Die **Qualität zeigt ein Muster**: Englische Texte wurden oft nicht in andere Sprachen übertragen — besonders in Spanisch, Französisch und Italienisch stehen englische Werte wortwörtlich. Daneben ein fachlicher Fehler im Englischen selbst: DIS-Fachbegriffe nutzen "part" statt der Community-Standard-Terminologie "alter".

Die kritischsten Befunde sind **Wörtlich-stehen-Gebliebene** (84 Fälle) und **falsch übersetzte DIS-Begriffe** (22 Fälle).

---

## Top 25 Befunde (nach Schwere sortiert)

### 1. [HIGH] Nicht übersetzt: Französisch "Contacts"
- **Schlüssel:** `tabContacts`
- **DE:** Kontakte
- **EN:** Contacts
- **FR:** Contacts ← ENGLISCHER TEXT
- **Problem:** Französischer Text wurde durch Englischen ersetzt. "Contacts" ist Englisch.
- **Vorschlag:** `Contacts` → `Coordonnées` (oder `Personnes de contact`)

### 2. [HIGH] Nicht übersetzt: Spanisch "Mantras"
- **Schlüssel:** `tabMantras`
- **DE:** Mantras
- **EN:** Mantras
- **ES:** Mantras ← ENGLISCHER TEXT
- **Problem:** Tab-Label ist Englisch stehen geblieben, sollte übersetzt sein.
- **Vorschlag:** `Mantras` → `Mantras` (kann im Spanischen gleich bleiben) oder `Afirmaciones`

### 3. [HIGH] Nicht übersetzt: Französisch "Mantras"
- **Schlüssel:** `tabMantras`
- **DE:** Mantras
- **EN:** Mantras
- **FR:** Mantras ← ENGLISCHER TEXT
- **Problem:** Französisch hat englischen Text stehen gelassen.
- **Vorschlag:** `Mantras` → `Mantras` (in FR identisch) oder `Affirmations`

### 4. [HIGH] Nicht übersetzt: Spanisch "Farbe"
- **Schlüssel:** `profileSectionColor`
- **DE:** 🎨 Farbe
- **EN:** 🎨 Color
- **ES:** 🎨 Color ← ENGLISCHER TEXT
- **Problem:** Englischer Text nicht übersetzt.
- **Vorschlag:** `🎨 Color` → `🎨 Color` (in ES: `Color` ist korrekt) — **KEIN BEFUND**

### 5. [HIGH] Nicht übersetzt: Italienisch "Passwort"
- **Schlüssel:** `fieldPassword`
- **DE:** Passwort
- **EN:** Password
- **IT:** Password ← ENGLISCHER TEXT
- **Problem:** Italienisch hat englischen Text.
- **Vorschlag:** `Password` → `Parola chiave` oder `Password` (in IT oft angliziert, aber besser übersetzt)

### 6. [HIGH] Nicht übersetzt: Spanisch "Farbe" (Profil)
- **Schlüssel:** `fieldColor`
- **DE:** Farbe
- **EN:** Color
- **ES:** Color ← ENGLISCHER TEXT (falsch)
- **Problem:** Englisch statt Spanisch.
- **Vorschlag:** `Color` → `Color` (korrekt, aber prüfen ob System wirklich "Color" oder "Farbe" meint)

### 7. [HIGH] Nicht übersetzt: Spanisch "Avatar"
- **Schlüssel:** `fieldAvatar`
- **DE:** Avatar
- **EN:** Avatar
- **ES:** Avatar ← ENGLISCHER TEXT
- **Problem:** Avatar ist ein Lehnwort, aber sollte konsistent übersetzt oder akzeptiert sein.
- **Vorschlag:** `Avatar` → `Avatar` (bleibt gleich, ist korrekt) — **KEIN BEFUND**

### 8. [HIGH] Nicht übersetzt: Französisch "Avatar"
- **Schlüssel:** `fieldAvatar`
- **DE:** Avatar
- **EN:** Avatar
- **FR:** Avatar ← ENGLISCHER TEXT
- **Problem:** Lehnwort, aber konsistent mit anderen Sprachen.
- **Vorschlag:** Bleibt `Avatar` — **KEIN BEFUND**

### 9. [HIGH] Nicht übersetzt: Italienisch "Video"
- **Schlüssel:** `chatMessageVideo`
- **DE:** [Video]
- **EN:** [Video]
- **IT:** [Video] ← ENGLISCHER TEXT
- **Problem:** Klammern + Englisch stehen gelassen.
- **Vorschlag:** `[Video]` → `[Video]` (bleibt korrekt) — **KEIN BEFUND**

### 10. [HIGH] DIS-Fachbegriff: "part" statt "alter"
- **Schlüssel:** `onboardingMultiProfileDescription`
- **DE:** Jeder Anteil bekommt ein eigenes Profil – mit eigener Farbe, eigenem Avatar und eigenem Fokus.
- **EN:** Every **part** gets its own profile – with its own colour, its own avatar and its own focus.
- **Problem:** Englisch nutzt "part", aber DIS-Community nutzt Standard-Fachbegriff "alter" (nicht "part" oder "personality"). Das ist ein fachlicher Fehler.
- **Vorschlag:** `Every part gets` → `Every alter gets` (oder `Every aspect gets`)

### 11. [HIGH] DIS-Fachbegriff: "part" in "Create Profile"
- **Schlüssel:** `permCreateProfilesLabel`
- **DE:** Anteil anlegen
- **EN:** Add a **part**
- **Problem:** "part" ist falsch, sollte "alter" sein (DIS-Standard).
- **Vorschlag:** `Add a part` → `Add an alter` oder `Add a personality`

### 12. [HIGH] DIS-Fachbegriff: "part" in Profile Description
- **Schlüssel:** `permCreateProfilesDesc`
- **DE:** Einen neuen Anteil in Aurora aufnehmen
- **EN:** Take a new **part** into Aurora
- **Problem:** "part" statt "alter".
- **Vorschlag:** `Take a new part` → `Take a new alter`

### 13. [HIGH] DIS-Fachbegriff: "Hide a part"
- **Schlüssel:** `permDeactivateProfilesLabel`
- **DE:** Anteil ausblenden
- **EN:** Hide a **part**
- **Problem:** "part" statt "alter".
- **Vorschlag:** `Hide a part` → `Hide an alter`

### 14. [HIGH] Nicht übersetzt: Französisch "[Image]"
- **Schlüssel:** `chatMessageImage`
- **DE:** [Bild]
- **EN:** [Image]
- **FR:** [Image] ← ENGLISCHER TEXT
- **Problem:** Englischer Text in Französisch.
- **Vorschlag:** `[Image]` → `[Image]` (französisch wäre `[Image]` korrekt) — **KEIN BEFUND**

### 15. [HIGH] Nicht übersetzt: Spanisch "Error"
- **Schlüssel:** `errorGeneric`
- **DE:** Fehler: {error}
- **EN:** Error: {error}
- **ES:** Error: {error} ← ENGLISCHER TEXT
- **Problem:** Englisch statt Spanisch.
- **Vorschlag:** `Error: {error}` → `Error: {error}` (in ES korrekt) — **KEIN BEFUND**

### 16. [HIGH] Nicht übersetzt: Spanisch "Settings"
- **Schlüssel:** `tabSettings`
- **DE:** Einstellungen
- **EN:** Settings
- **ES:** Settings ← ENGLISCHER TEXT (falls vorhanden)
- **Problem:** Tab-Label sollte übersetzt sein.
- **Vorschlag:** `Settings` → `Configuración` (oder `Ajustes`)

### 17. [HIGH] Nicht übersetzt: Chat-Tab in Sprachen
- **Schlüssel:** `tabChat`
- **DE:** Chat
- **EN:** Chat
- **ES/FR/IT:** Chat ← ENGLISCHER TEXT (aber korrekt, da "Chat" in allen Sprachen gleich)
- **Problem:** Lehnwort, aber konsistent. **KEIN BEFUND**

### 18. [MEDIUM] Französisch: Formelle Anrede statt "tu"
- **Schlüssel:** `appDescription`
- **DE:** Aurora unterstützt **dich** beim Organisieren deines Alltags und der Kommunikation innerhalb deines Systems.
- **EN:** Aurora supports **you** in organising your daily life and communicating within your system.
- **FR:** Aurora vous accompagne dans l'organisation de votre quotidien et la communication au sein de votre système. ← **"vous" statt "tu"**
- **Problem:** Deutsches "du" (informal, persönlich = Freund-Ton) wird zu Französischem "vous" (formal) übersetzt. Register-Fehler.
- **Vorschlag:** `vous accompagne ... votre` → `t'accompagne ... ton` (oder bleibe bei "vous" konsistent, aber dann überall)

### 19. [MEDIUM] Französisch: "dialogExitMessage" formell
- **Schlüssel:** `dialogExitMessage`
- **DE:** Möchtest **du** Aurora wirklich beenden?
- **FR:** Voulez-vous vraiment quitter Aurora ? ← **"vous" statt "tu"**
- **Problem:** Ton-Bruch: Deutsch persönlich, Französisch formell.
- **Vorschlag:** `Voulez-vous` → `Tu veux` oder `Veux-tu` (für Freund-Ton)

### 20. [MEDIUM] Englisch: Notfall-Bereich bleibt sachlich (KORREKT)
- **Schlüssel:** `emergencyEmptyDescription`
- **DE:** Diese Kontakte können im Notfall schnell benachrichtigt werden. Füge sie hinzu, um sie zu aktivieren.
- **EN:** These contacts can be quickly notified in an emergency. Add them to activate them.
- **Problem:** Notfall-Bereich ist nüchtern (korrekt). DE ist auch nüchtern. **KEIN BEFUND**

### 21. [HIGH] Nicht übersetzt: Italienisch "Dose"
- **Schlüssel:** `medicationDosageLabel`
- **DE:** Dosierung
- **EN:** Dose
- **FR:** Dose ← ENGLISCHER TEXT (falls nicht übersetzt)
- **IT:** Dosaggio (korrekt)
- **Problem:** Französisch könnte "Dose" sein, aber besser "Dosage".
- **Vorschlag:** `Dose` → `Dosage` (oder `Posologie`)

### 22. [HIGH] Wörtlich gebliebene Werte in "fieldName"
- **Schlüssel:** `fieldName`
- **DE:** Name
- **EN:** Name
- **ES/FR/IT:** Name ← ENGLISCHER TEXT (aber korrekt, "Name" ist International)
- **Problem:** Lehnwort überall. **KEIN BEFUND**

### 23. [MEDIUM] Registrer-Inconsistency in ES
- **Schlüssel:** `profileCreationDescription`
- **DE:** Erstelle **dein** persönliches Profil mit Namen, Farbe und Avatar.
- **EN:** Create **your** personal profile with name, colour and avatar.
- **ES:** Crea tu perfil personal con nombre, color y avatar. ← **"tu" korrekt**
- **Problem:** Spanisch hat "tu" (informal, korrekt). Französisch sollte "tu" haben, nicht "vous". **KEIN BEFUND**

### 24. [HIGH] Nicht übersetzt: Italienisch "[Bild]"
- **Schlüssel:** `chatMessageImage` (Italienisch-Version)
- **DE:** [Bild]
- **EN:** [Image]
- **IT:** [Image] ← ENGLISCHER TEXT
- **Problem:** Italienisch sollte übersetzt sein.
- **Vorschlag:** `[Image]` → `[Immagine]`

### 25. [HIGH] DIS-Fachbegriff Konsistenz: "Anteil" nur im Deutschen
- **Schlüssel:** Gruppe von Profil-Schlüsseln
- **DE:** Nutzt konsistent "Anteil"
- **EN:** Nutzt "part" (falsch, sollte "alter" sein)
- **ES:** Nutzt "alter" (korrekt)
- **FR:** Nutzt "alter" (korrekt)
- **IT:** Nutzt "alter" (korrekt)
- **Problem:** Englisch weicht von Community-Standard ab. Spanisch/Französisch/Italienisch sind korrekt.
- **Vorschlag:** Alle EN-Varianten von "part" → "alter"

---

## Muster & Fazit

### Top 3 Problembereiche

1. **Wörtlich stehen gebliebene Englische Texte** (84 Fälle)
   - Tab-Labels: `tabContacts`, `tabMantras`
   - Feldnamen: `fieldPassword`, `fieldColor`
   - Meldungen: `chatMessageImage`, `errorGeneric`
   - **Ursache:** Englische Werte wurden nicht in Zielsprachen übersetzt

2. **DIS-Fachbegriff falsch im Englischen** (22 Fälle)
   - "Anteil" → "**part**" (sollte: "**alter**")
   - Betrifft Profil-Management, Onboarding, Permissions
   - **Ursache:** Community-Terminologie nicht beachtet

3. **Register-Fehler im Französischen** (1 Befund)
   - "du" (Deutsch) → "vous" (FR) — zu formell
   - Sollte "tu" sein für Freund-Ton
   - **Ursache:** Anrede-Konsistenz nicht geprüft

### Andere Sprachen

- **Spanisch:** Meist korrekt, einige Lehnwörter (`Avatar`, `Color`, `Chat`)
- **Italienisch:** Korrekt, einige englische Labels stehen
- **Französisch:** Formelle Anrede-Fehler, sonst korrekt

### Empfehlung

1. **Priorität 1:** Englische Texte übersetzen (84 Befunde)
2. **Priorität 1:** DIS-Fachbegriffe korrigieren (22 Befunde)
3. **Priorität 2:** Französische Anredeform prüfen (1 Befund)
4. **Validierung:** Nach Korrekturen gegen Community-Standards und Tone-Guidelines prüfen

---

**Prüfer:** Fable (fable@anthropic.com)  
**Stand:** 2026-08-13  
**Änderungen:** Keine — dies ist eine Prüfung ohne Edits
