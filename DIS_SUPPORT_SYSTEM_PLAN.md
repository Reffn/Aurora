# Aurora - "Du bist nicht allein" - DIS Education & Support System

## Implementierungs-Plan & Dokumentation

**Erstellt:** 2025-01-02
**Status:** Geplant, noch nicht implementiert
**Priorität:** SEHR HOCH (Kritisch für User Acquisition & Retention)
**Geschätzter Aufwand:** 10-13 Tage (~2-2,5 Wochen)

---

## 📋 INHALTSVERZEICHNIS

1. [Vision & Konzept](#vision--konzept)
2. [Aktuelle Situation](#aktuelle-situation)
3. [DIS Education Content](#dis-education-content)
4. [Coping Strategies & Grounding](#coping-strategies--grounding)
5. [Community & Support Resources](#community--support-resources)
6. [UI/UX Design](#uiux-design)
7. [Content Organization](#content-organization)
8. [Privacy & Offline-First](#privacy--offline-first)
9. [Implementierungs-Plan](#implementierungs-plan)
10. [Testing-Szenarien](#testing-szenarien)
11. [Aufwandsschätzung](#aufwandsschätzung)

---

## VISION & KONZEPT

### Kernidee: "Du bist nicht allein"

Viele Menschen mit DIS fühlen sich:
- **Isoliert** - "Niemand versteht mich"
- **Überfordert** - "Was bedeutet diese Diagnose?"
- **Verloren** - "Wo finde ich Hilfe?"
- **Stigmatisiert** - "Bin ich verrückt?"

**Aurora's Antwort:** Ein umfassendes, offline-first Support-System mit:
1. ✅ **DIS-Aufklärung** - Was ist DIS wirklich?
2. ✅ **Krisenmanagement** - Grounding, Hotlines, Notfallpläne
3. ✅ **Community-Ressourcen** - Selbsthilfegruppen, Foren, Therapeuten
4. ✅ **Coping-Strategien** - Praktische Techniken für den Alltag
5. ✅ **Mythen entlarven** - Wissenschaftliche Fakten vs. Medien-Klischees
6. ✅ **Prominenter Zugang** - "Du bist nicht allein" Banner überall sichtbar

### Warum das wichtig ist

**User Acquisition:**
- Alleinstellungsmerkmal: Keine andere DIS-App bietet so umfassende Education
- SEO: "DIS Informationen", "DIS Hilfe", "Selbsthilfegruppe DIS"
- Word-of-Mouth: Nutzer empfehlen App wegen hilfreicher Ressourcen

**User Retention:**
- Nutzer kehren zurück für Grounding-Übungen
- Community-Ressourcen geben Hoffnung
- Education reduziert Angst

**App Store Success:**
- Positive Reviews: "Diese App hat mir geholfen zu verstehen..."
- Featured Potential: Mental Health Education Category
- Therapeuten-Empfehlungen: "Zeigen Sie Ihren Patienten Aurora"

---

## AKTUELLE SITUATION

### Was existiert bereits

**Location:** `lib/modules/help/help_resources_screen.dart`

**Aktueller Stand:**
- ✅ Help Tab existiert (Tab #7 in Main Navigation)
- ✅ Emergency Hotlines implementiert (5 Hotlines):
  - Telefonseelsorge: 0800 111 0 111 / 0800 111 0 222
  - Nummer gegen Kummer: 116 111
  - Info-Telefon Depression: 0800 33 44 533
  - Krisenchat: https://krisenchat.de
- ✅ Call/Open Funktionalität via `EmergencyMessageService`
- ✅ Permission-based Access: `Permission.viewHelpTab`
- ✅ Accessible from "More" screen

**Was FEHLT:**
- ❌ DIS-spezifische Informationen (Was ist DIS?)
- ❌ Coping-Strategien & Grounding Techniques
- ❌ Community-Ressourcen (Selbsthilfegruppen, Foren)
- ❌ Therapeuten-Verzeichnis
- ❌ Mythen-Aufklärung
- ❌ Self-Care Guidance
- ❌ "Du bist nicht allein" Messaging
- ❌ Offline-first Content (nur externe Links)

### Bestehender Code

**HelpResourcesScreen (aktuell):**
```dart
// Simplified current structure
class HelpResourcesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hilfsangebote')),
      body: ListView(
        children: [
          // Emergency hotlines (5 cards)
          ...germanEmergencyHotlines.map((hotline) =>
            EmergencyHotlineCard(hotline: hotline)
          ),

          // Placeholder
          Text('Weitere Ressourcen folgen'),
        ],
      ),
    );
  }
}
```

---

## DIS EDUCATION CONTENT

### 1. Was ist DIS? (Basics)

#### 1.1 Definition & Häufigkeit

**Content (Markdown):**
```markdown
# Was ist eine Dissoziative Identitätsstörung (DIS)?

Die Dissoziative Identitätsstörung (DIS) ist eine psychische Erkrankung,
bei der eine Person zwei oder mehr unterschiedliche Identitätszustände
(oft "Persönlichkeiten" oder "Alters" genannt) entwickelt.

## Häufigkeit
- **1-2% der Bevölkerung** sind betroffen
- **Häufiger als Schizophrenie** (~1%)
- Oft **nicht diagnostiziert** (durchschnittlich 7 Jahre bis zur Diagnose)
- **Keine "seltene" Störung** - viele leben unerkannt damit

## Wie entsteht DIS?

DIS entsteht als **Schutzreaktion** auf schwere, wiederholte Traumata
im **frühen Kindesalter** (typisch: 4-9 Jahre).

Die Psyche "teilt" Erinnerungen und Identität auf, um:
- Unerträgliche Erfahrungen zu "compartmentalisieren"
- Das Überleben zu sichern
- Das Funktionieren im Alltag zu ermöglichen

**DIS ist keine Schwäche** - es ist ein **Überlebensmechanismus**.

## Diagnose

**DSM-5 Kriterien:**
1. Zwei oder mehr unterscheidbare Identitätszustände
2. Gedächtnislücken (Amnesie) für Alltagsereignisse
3. Erhebliches Leiden oder Beeinträchtigung
4. Nicht durch Substanzen oder andere Erkrankungen erklärbar

**Wichtig:** Nur ein qualifizierter Therapeut kann DIS diagnostizieren.
```

---

#### 1.2 Häufige Symptome & Erfahrungen

**Content:**
```markdown
# Häufige Symptome bei DIS

## Gedächtnislücken (Amnesie)
- **"Wo war ich die letzte Stunde?"**
- Verlust von Zeit (Minuten bis Tage)
- Finden von Gegenständen, die man nicht erinnert gekauft zu haben
- Nicht erinnern an wichtige Ereignisse
- "Wie bin ich hierher gekommen?"

## Identitätswechsel (Switches)
- Plötzliche Veränderung in Verhalten, Sprache, Vorlieben
- Andere Handschrift
- Verschiedene Fähigkeiten (z.B. Sprachen, Talente)
- Alter wechselt zwischen erwachsen und kindlich

## Dissoziative Episoden
- Gefühl von "Unwirklichkeit" (Derealisation)
- Beobachten des eigenen Körpers von außen (Depersonalisation)
- "Wie in einem Film" oder "hinter Glas"
- Taubheit, emotionale Betäubung

## Ko-Bewusstsein vs. Amnesie
- **Ko-Bewusstsein:** Mehrere Alters sind gleichzeitig bewusst
- **Amnesie:** Kompletter Erinnerungsverlust zwischen Alters
- Viele Systeme haben beides

## Innere Kommunikation
- "Stimmen hören" (aber KEINE Halluzinationen wie bei Schizophrenie)
- Innere Dialoge zwischen Alters
- Gedanken, die "nicht die eigenen" sind
- Manchmal laut, manchmal nur als Gefühl

## Wichtig zu wissen:
✅ Diese Symptome sind bei DIS **normal**
✅ Du bist **nicht verrückt**
✅ Viele Menschen haben ähnliche Erfahrungen
✅ Mit Therapie und Support wird es besser
```

---

#### 1.3 DIS-Terminologie (System-Wörterbuch)

**Content:**
```markdown
# DIS-Terminologie: Wichtige Begriffe erklärt

## Alters / Innenpersonen / Anteile
**Was sind Alters?**
- Unterschiedliche Identitätszustände im System
- Jeder Alter hat eigene Persönlichkeit, Erinnerungen, Vorlieben
- Können unterschiedliche Alter, Geschlechter, Namen haben

**Verschiedene Rollen:**
- **Host:** Der Alter, der am häufigsten "vorne" ist
- **Beschützer:** Schützen das System vor Gefahren
- **Trauma-Holder:** Halten schmerzhafte Erinnerungen
- **Kinder-Alters:** Repräsentieren Kindheitserfahrungen
- **Gatekeeper:** Steuern, wer wann "vorne" sein darf

**Wichtig:** Jeder Alter ist **real** und **wichtig**.

---

## Switches / Wechsel
**Was ist ein Switch?**
Ein Switch ist der Wechsel von einem Alter zu einem anderen.

**Arten von Switches:**
- **Langsamer Switch:** Allmählicher Übergang (Minuten)
- **Schneller Switch:** Blitzartiger Wechsel (Sekunden)
- **Consent Switch:** Bewusst geplanter Wechsel
- **Triggered Switch:** Durch Trigger ausgelöster Wechsel

**Auslöser (Trigger):**
- Stress, Angst, Überforderung
- Bestimmte Situationen, Orte, Personen
- Positive Triggers (z.B. Musik, die ein Alter mag)

---

## Ko-Bewusstsein (Co-consciousness)
**Definition:**
Mehrere Alters sind gleichzeitig bewusst und nehmen wahr, was passiert.

**Vorteile:**
- Weniger Gedächtnislücken
- Bessere Zusammenarbeit
- Innere Kommunikation einfacher

**Nicht jedes System hat Ko-Bewusstsein** - und das ist okay!

---

## Fronting / "Vorne sein"
**Wer ist vorne?**
Der Alter, der aktuell den Körper kontrolliert und mit der Außenwelt interagiert.

**Co-Fronting:**
Zwei (oder mehr) Alters sind gleichzeitig vorne und teilen sich die Kontrolle.

---

## System
**Definition:**
Alle Innenpersonen zusammen bilden das **System**.

**System-Verantwortung:**
- Was einer tut, betrifft alle
- Gemeinsame Entscheidungen wichtig
- Gegenseitige Rücksichtnahme

---

## Integration vs. Kooperation
**Zwei verschiedene Therapieziele:**

**Integration/Fusion:**
- Alters verschmelzen zu einer Identität
- Nicht für alle das richtige Ziel

**Kooperation/Funktionale Multiplizität:**
- Alters bleiben getrennt
- Arbeiten zusammen als Team
- Viele finden das erfüllender

**Es gibt keinen "richtigen" Weg!**
Therapeut und System entscheiden gemeinsam.

---

## Gatekeeper
**Rolle:**
- "Verwalter" des Systems
- Entscheidet, wer wann switchen darf
- Schützt vor überwältigenden Situationen
- Hilft bei innerer Ordnung

Nicht jedes System hat einen Gatekeeper.

---

## Innere Welt / Headspace
**Was ist das?**
Ein mentaler "Raum", wo Alters sich treffen können.

**Kann sein:**
- Ein Haus, ein Wald, eine Landschaft
- Sehr detailliert oder vage
- Manche Systeme haben keine innere Welt

**Funktion:**
- Sichere Kommunikation
- Rückzugsort für Alters
- Innere Meetings
```

---

#### 1.4 Mythen über DIS entlarven

**Content:**
```markdown
# Mythen über DIS - Die Wahrheit

## ❌ Mythos 1: "DIS ist extrem selten"
### ✅ WAHRHEIT:
**1-2% der Bevölkerung** haben DIS - das ist **häufiger als Schizophrenie** (~1%).

Viele bleiben undiagnostiziert, weil:
- Symptome werden als Depression/Angst fehldiagnostiziert
- Scham verhindert Hilfe suchen
- Therapeuten nicht ausreichend ausgebildet

---

## ❌ Mythos 2: "DIS ist wie Schizophrenie"
### ✅ WAHRHEIT:
**Völlig unterschiedliche Störungen!**

| DIS | Schizophrenie |
|-----|---------------|
| Dissoziative Störung | Psychotische Störung |
| Verschiedene Identitäten | Eine Identität |
| Innere "Stimmen" (Gedanken) | Echte Halluzinationen |
| Trauma-basiert | Neurobiologisch |
| Gedächtnislücken | Kein Identitätswechsel |

DIS wird **NICHT** mit Antipsychotika behandelt!

---

## ❌ Mythos 3: "Menschen mit DIS sind gefährlich"
### ✅ WAHRHEIT:
Menschen mit DIS sind **statistisch eher Opfer als Täter**.

- DIS entsteht durch **erlebte Gewalt**
- Viele haben Angst **vor** Gewalt, nicht umgekehrt
- Hollywood-Filme (z.B. "Split") sind **FIKTION**
- Echte Menschen mit DIS sind oft **empathisch** und **friedlich**

---

## ❌ Mythos 4: "DIS ist nicht real / wird eingeredet"
### ✅ WAHRHEIT:
DIS ist eine **wissenschaftlich validierte** Diagnose.

- Im DSM-5 (Diagnostic and Statistical Manual)
- Im ICD-11 (Internationale Klassifikation der Krankheiten)
- Tausende Forschungsartikel
- Neuroimaging zeigt Unterschiede im Gehirn

**Keine Beweise** für "iatrogene" (therapeut-verursachte) DIS.

---

## ❌ Mythos 5: "Man sieht Switches immer"
### ✅ WAHRHEIT:
Viele Switches sind **völlig unsichtbar** für Außenstehende.

- Innere Wechsel können subtil sein
- Co-Fronting verhält sich "normal"
- System lernt, Switches zu maskieren (Selbstschutz)
- Nur enge Vertraute bemerken oft Details

---

## ❌ Mythos 6: "Alle Alters sind extrem unterschiedlich"
### ✅ WAHRHEIT:
Hollywood übertreibt!

- Viele Alters sind sich **ähnlich**
- Unterschiede oft subtil (Stimmung, Interessen)
- Extreme Unterschiede (Kind vs. Erwachsener) kommen vor, aber nicht immer
- Systeme können 2 oder 200+ Alters haben

---

## ❌ Mythos 7: "DIS ist eine Persönlichkeitsstörung"
### ✅ WAHRHEIT:
**NEIN!** DIS ist eine **dissoziative Störung**.

- Nicht im Cluster-B (Borderline, Narzisstisch, etc.)
- Eigene Kategorie: Dissoziative Störungen
- Behandlung völlig anders als Persönlichkeitsstörungen

---

## ❌ Mythos 8: "DIS kann nicht geheilt werden"
### ✅ WAHRHEIT:
Mit **Trauma-Therapie** verbessern sich Symptome erheblich.

**Therapie-Ansätze:**
- EMDR (Eye Movement Desensitization and Reprocessing)
- DBT (Dialectical Behavior Therapy)
- Psychodynamische Therapie
- Trauma-fokussierte KVT

**Ziele:**
- Reduktion von Amnesie
- Ko-Bewusstsein fördern
- Trauma verarbeiten
- Alltagsfunktionen verbessern

Viele Menschen mit DIS führen erfüllte Leben!
```

---

## COPING STRATEGIES & GROUNDING

### 2.1 Grounding Techniques (Erdungsübungen)

**Content:**
```markdown
# Grounding Techniques - Zurück ins Hier und Jetzt

Grounding hilft, bei **Dissoziation**, **Flashbacks** oder **Überwältigung**
wieder im **Hier und Jetzt** anzukommen.

---

## 🌟 5-4-3-2-1 Methode (Beliebteste Technik!)

Diese Übung nutzt deine **5 Sinne**, um dich zu erden.

### Schritt-für-Schritt:

**5 Dinge SEHEN:**
Benenne 5 Dinge, die du siehst.
- "Ich sehe einen blauen Stift"
- "Ich sehe ein Fenster"
- "Ich sehe meine Hände"
- "Ich sehe eine Pflanze"
- "Ich sehe eine Lampe"

**4 Dinge HÖREN:**
Benenne 4 Dinge, die du hörst.
- "Ich höre Vogelzwitschern"
- "Ich höre das Ticken der Uhr"
- "Ich höre meinen Atem"
- "Ich höre Verkehr draußen"

**3 Dinge BERÜHREN:**
Berühre 3 Dinge und beschreibe die Textur.
- "Ich berühre den Stuhl - er ist glatt und kühl"
- "Ich berühre meine Kleidung - weich und warm"
- "Ich berühre den Tisch - hart und kalt"

**2 Dinge RIECHEN:**
Benenne 2 Gerüche (oder erinnere dich an angenehme Gerüche).
- "Ich rieche Kaffee"
- "Ich erinnere mich an Lavendel"

**1 Ding SCHMECKEN:**
Schmecke etwas (oder erinnere dich an einen Geschmack).
- "Ich schmecke Minze" (Kaugummi)
- "Ich erinnere mich an Schokolade"

**Warum das funktioniert:**
Sinneswahrnehmungen bringen dich **aus dem Kopf** in den **Körper** zurück.

---

## 👣 Füße fest auf den Boden

**Anleitung:**
1. Setze oder stelle dich hin
2. Spüre bewusst deine Füße auf dem Boden
3. Drücke sie fest in den Boden
4. Sage laut: **"Ich bin hier. Ich bin jetzt. Ich bin sicher."**
5. Atme tief ein und aus

**Warum:** Physische Verankerung gibt Stabilität.

---

## 🧊 Eiswürfel halten

**Anleitung:**
1. Nimm einen Eiswürfel in die Hand
2. Spüre die Kälte intensiv
3. Beobachte, wie er schmilzt
4. Konzentriere dich **nur** auf diese Sensation

**Warum:** Intensive physische Sensation "überschreibt" Dissoziation.

**Alternativen:**
- Kaltes Wasser über Handgelenke laufen lassen
- Gesicht mit kaltem Wasser waschen
- Kühlpack auf Nacken

---

## 🍃 Starke Gerüche

**Anleitung:**
Rieche an etwas mit **starkem Geruch**:
- Pfefferminzöl
- Zitrone
- Lavendel
- Kaffee
- Eukalyptus

**Warum:** Geruchssinn ist direkt mit dem Gehirn verbunden und sehr kraftvoll.

---

## 🎵 Laute Musik

**Anleitung:**
1. Setze Kopfhörer auf
2. Spiele **laute** Musik (nicht beängstigend, sondern energetisierend)
3. Konzentriere dich auf Rhythmus, Text, Instrumente

**Empfohlen:**
- Musik, die **Energie** gibt
- Vertraute Lieder (Sicherheit)

---

## 🏃 Körperliche Bewegung

**Anleitung:**
- Gehe spazieren (bewusst jeden Schritt spüren)
- Mache Hampelmänner
- Springe auf der Stelle
- Tanze
- Dehne dich

**Warum:** Bewegung aktiviert den Körper und unterbricht Dissoziation.

---

## 🌬️ 4-7-8 Atemmethode

**Anleitung:**
1. **4 Sekunden** einatmen (durch die Nase)
2. **7 Sekunden** Atem anhalten
3. **8 Sekunden** ausatmen (durch den Mund)
4. Wiederhole 4 Mal

**Warum:** Reguliert Nervensystem, reduziert Panik.

---

## 💬 Selbst-Affirm

**Sage laut:**
- "Ich bin [Name]"
- "Heute ist [Datum]"
- "Ich bin in [Ort]"
- "Ich bin sicher"
- "Das Trauma ist vorbei"

**Warum:** Verbale Verankerung in Gegenwart.

---

## 🛁 Sensorische Box

**Erstelle eine "Grounding Box":**
- Weicher Stoff (Plüschtier)
- Starker Geruch (ätherisches Öl)
- Saures Bonbon
- Lieblingsfoto
- Kleine Puzzles oder Fidget Toys

**Nutze sie bei Bedarf!**

---

## ⚠️ Was tun, wenn Grounding nicht funktioniert?

**Manchmal hilft Grounding nicht sofort - das ist NORMAL!**

**Alternative Strategien:**
1. **Raus aus der Situation** - Gehe in einen anderen Raum
2. **Anrufen** - Telefonseelsorge 0800 111 0 111
3. **Ablenkung** - Spiele, Serien, Rätsel
4. **Schlafen** - Manchmal ist Pause das Beste
5. **Warten** - Dissoziation geht meist von selbst vorbei

**Wichtig:** Sei **geduldig** mit dir selbst. Recovery ist keine gerade Linie.
```

---

### 2.2 Crisis Management (Krisenmanagement)

**Content:**
```markdown
# Krisenmanagement - "Ich brauche JETZT Hilfe"

## 🚨 Akute Krise - Schritt-für-Schritt

### Schritt 1: Bist du sicher?
**Frage dich:**
- Bin ich in **akuter Gefahr**?
- Droht **Selbstverletzung** oder Suizid?

**Wenn JA:**
- **112 anrufen** (Notarzt/Polizei)
- Zu einer **sicheren Person** gehen
- **Notfallkontakt** anrufen (aus deiner Liste)

**Wenn NEIN, aber sehr überfordert:**
→ Weiter zu Schritt 2

---

### Schritt 2: Grounding (5 Minuten)
**Probiere die 5-4-3-2-1 Methode:**
- 5 Dinge sehen
- 4 Dinge hören
- 3 Dinge berühren
- 2 Dinge riechen
- 1 Ding schmecken

**Alternative:**
- Eiswürfel halten
- Kaltes Wasser über Handgelenke
- Füße fest auf Boden drücken

**→ Fühlst du dich etwas besser?**
- **JA:** Weiter zu Schritt 4 (Ablenkung)
- **NEIN:** Weiter zu Schritt 3 (Hotline)

---

### Schritt 3: Hotline anrufen
**Du bist nicht allein. Ruf an!**

**Telefonseelsorge (24/7, kostenlos, anonym):**
- ☎️ 0800 111 0 111
- ☎️ 0800 111 0 222
- 🌐 Online-Chat: https://online.telefonseelsorge.de

**Nummer gegen Kummer (für jüngere Alters):**
- ☎️ 116 111 (Mo-Sa 14-20 Uhr)

**Info-Telefon Depression:**
- ☎️ 0800 33 44 533 (Mo-Do 13-17 Uhr, Di/Do auch 17-20 Uhr)

**Krisenchat (SMS/WhatsApp für jüngere):**
- 🌐 https://krisenchat.de

**→ Sprich mit jemandem!** Es hilft.

---

### Schritt 4: Ablenkung & Sicherheit
**Jetzt geht es darum, dich zu **beruhigen**.**

**Ablenkungsstrategien:**
- **Spiele spielen** (Puzzle, Tetris, Candy Crush)
- **Serie schauen** (etwas Vertrautes, Beruhigendes)
- **Musik hören** (deine Lieblingssongs)
- **Malen / Doodlen** (in Aurora's Doodle-Funktion!)
- **Lesen** (leichte Lektüre, keine Trigger)
- **Mit Haustier kuscheln** (falls vorhanden)
- **Warme Dusche / Bad** (beruhigend)

**Schreibe auf, was du fühlst** (Aurora Tagebuch):
- Manchmal hilft es, Gedanken rauszuschreiben
- Niemand muss es lesen

**→ Nimm dir **Zeit**. Krisen gehen vorbei.**

---

### Schritt 5: Selbstfürsorge danach
**Nach einer Krise:**
- **Sei sanft zu dir selbst** - Du hast es geschafft!
- **Trinke Wasser** / Iss etwas Leichtes
- **Schlafe**, wenn möglich
- **Sprich mit jemandem** (Therapeut, Freund, Selbsthilfegruppe)

**Notiere Trigger** (optional):
- Was hat die Krise ausgelöst?
- Kann ich das in Zukunft vermeiden?
- Was hat geholfen?

**→ Jede Krise ist eine Lernmöglichkeit.**

---

## 🆘 Notfallplan erstellen

**Schreibe JETZT einen Notfallplan** (bevor die nächste Krise kommt):

### Mein Notfallplan:

**1. Anzeichen einer Krise bei mir:**
- [ ] _________________
- [ ] _________________
- [ ] _________________

**2. Was mir hilft (Grounding):**
- [ ] _________________
- [ ] _________________

**3. Wen ich anrufen kann:**
- [ ] Name: _________ Tel: _________
- [ ] Telefonseelsorge: 0800 111 0 111

**4. Sichere Orte:**
- [ ] _________________
- [ ] _________________

**5. Ablenkungen, die funktionieren:**
- [ ] _________________
- [ ] _________________

**→ Speichere das in Aurora's Notfall-Tab!**

---

## ⚠️ Wann SOFORT 112 anrufen:

- Akute **Suizidgedanken mit Plan**
- **Schwere Selbstverletzung**
- **Psychotischer Zustand** (Realitätsverlust)
- **Gefahr für andere**
- **Medizinischer Notfall**

**→ Keine Scham! Lieber einmal zu viel anrufen.**

---

## 💙 Nach der Krise

**Erinnere dich:**
- Du hast **überlebt** - das ist Stärke
- Krisen kommen und gehen - **sie sind temporär**
- Jedes Mal lernst du mehr über deine Trigger
- **Du bist nicht allein** - Millionen durchleben Ähnliches

**Belohne dich:**
- Gönn dir etwas Schönes (Lieblingsessen, Film, etc.)
- Sei **stolz** auf dich
```

---

### 2.3 Self-Care for DIS Systems

**Content:**
```markdown
# Self-Care für DIS-Systeme - Alltägliche Strategien

## 🌅 Morgendliche Routine

**Check-in mit dem System:**
- "Wer ist heute vorne?"
- "Wie fühlen wir uns?"
- "Was steht heute an?"

**Kalender checken:**
- Gemeinsamer Kalender in Aurora
- Niemand wird von Terminen überrascht

**Grundbedürfnisse:**
- Frühstück (alle Alters brauchen Nahrung!)
- Medikamente (falls vorhanden)
- Hygiene

---

## 📅 Gemeinsamer Kalender = Lebensretter

**Problem:** Verschiedene Alters machen Zusagen, ohne andere zu fragen.

**Lösung:**
- **Alle** nutzen Aurora's Kalender
- **Vor** Zusagen → Kalender checken
- **Nach** Zusagen → Eintrag erstellen

**Verhindert:**
- Doppelbuchungen
- Überforderung
- Chaos

---

## 🗣️ Innere Kommunikation fördern

**Methoden:**
- **Tagebuch/Journal** (Aurora's Diary!)
  - Jeder Alter kann schreiben
  - Andere können lesen
- **Innere Meetings**
  - Regelmäßig (z.B. jeden Sonntag)
  - Besprecht wichtige Entscheidungen
- **Notizen hinterlassen**
  - Post-its, Handy-Notizen
  - "Hey, ich hab X gemacht, damit ihr Bescheid wisst"

**Ziel:** Weniger Amnesie, mehr Zusammenarbeit

---

## 🛌 Pausen sind wichtig!

**DIS ist anstrengend:**
- Switches kosten Energie
- Ko-Bewusstsein ist mental fordernd
- Trauma-Verarbeitung ist Arbeit

**Erlaube dir:**
- **Powernaps** (20-30 Minuten)
- **"Nichts tun"** Tage
- **Nein sagen** zu Überforderung

**→ Ruhe ist keine Schwäche, sondern Selbstfürsorge!**

---

## 🎭 Jeder Alter darf eigene Bedürfnisse haben

**Beispiel:**
- Alter A liebt laute Musik
- Alter B braucht Stille
- **Lösung:** Beide bekommen ihre Zeit!

**Kompromisse finden:**
- Musik mit Kopfhörern (A)
- Stille Zeit am Abend (B)

**Wichtig:** **Niemand** wird ignoriert oder unterdrückt.

---

## 🍽️ Ernährung & Gesundheit

**Problem:** Manche Alters essen nicht genug.

**Lösung:**
- **Mindestens 3 Mahlzeiten/Tag** (Regel für alle)
- Erinnerungen in Aurora setzen
- Snacks bereithalten

**Medikamente:**
- Gemeinsamer Plan (wer nimmt wann was?)
- Aurora's Medication Tracker nutzen

**Sport/Bewegung:**
- Finde Aktivitäten, die **allen** (oder vielen) Spaß machen
- Spazieren gehen = fast immer okay

---

## 😴 Schlaf-Hygiene

**DIS kann Schlaf stören:**
- Alpträume (Trauma-Erinnerungen)
- Verschiedene Schlafbedürfnisse der Alters

**Tipps:**
- **Routine:** Jeden Tag zur gleichen Zeit schlafen gehen
- **Kein Bildschirm 1h vor Schlaf**
- **Beruhigende Rituale:** Lesen, Tee, Entspannungsmusik
- **Sichere Umgebung:** Nachtlicht, Kuscheltier, etc.

**Falls Albträume:**
- Grounding vor dem Schlafen
- Imagery Rehearsal Therapy (mit Therapeut)

---

## 📝 Notizen bei Amnesie

**"Was ist passiert, während ich weg war?"**

**Strategie:**
- **Tagebuch** nach jedem Tag
- **Fotos** von wichtigen Momenten
- **Kalender** mit Details ("Treffen mit X - war schön")
- **Sprachnachrizen** an dich selbst (in Aurora's Voice Messages!)

**→ Hilft, Zusammenhänge zu verstehen**

---

## 🧘 Regelmäßiges Grounding

**Nicht nur in Krisen!**

**Täglich 5 Minuten:**
- Morgens: 5-4-3-2-1 Übung
- Abends: Atem-Meditation

**Warum:** **Prävention** ist besser als Reaktion.

---

## 🤝 Soziale Kontakte

**DIS kann isolierend sein.**

**Empfehlung:**
- **Mindestens 1x/Woche** Kontakt zu Freunden/Familie
- **Selbsthilfegruppe** besuchen (siehe Community-Tab!)
- **Online-Communities** (Reddit r/DID, DIS-kussion.de)

**Wichtig:** Nicht alle müssen von DIS wissen!
- **Sichere Personen** einweihen
- **Grenzen** setzen

---

## 🎨 Kreative Outlets

**Viele Alters sind kreativ:**
- Malen, Zeichnen (Aurora's Doodle!)
- Schreiben (Tagebuch, Gedichte)
- Musik machen
- Handwerk, Stricken, etc.

**Warum:** Kreativität ist therapeutisch und gibt jedem Alter eine Stimme.

---

## 🎯 Realistische Erwartungen

**DIS-Recovery ist keine gerade Linie:**

**Gute Tage:** ✅ Ko-Bewusstsein, Produktivität, Freude
**Schlechte Tage:** ❌ Amnesie, Trigger, Dissoziation

**→ BEIDE sind normal!**

**Sei geduldig:**
- Fortschritt ist oft **unsichtbar**
- **Rückschläge** sind Teil des Prozesses
- **Jeder kleine Schritt** zählt

---

## 💚 Selbstmitgefühl üben

**Sprich zu dir selbst wie zu einem Freund:**

**Statt:**
- "Ich bin so kaputt"
- "Warum kann ich nicht normal sein?"

**Sage:**
- "Ich tue mein Bestes"
- "Ich überlebe jeden Tag - das ist Stärke"
- "DIS ist nicht meine Schuld"

**→ Du verdienst Freundlichkeit - auch von dir selbst!**
```

---

## COMMUNITY & SUPPORT RESOURCES

### 3.1 Deutsche Selbsthilfegruppen (vor Ort)

**Content:**
```markdown
# Selbsthilfegruppen in Deutschland

## 🇩🇪 Regionale Gruppen

### Dresden
**TD-SHG - Traumadissoziations-Selbsthilfegruppe**
- 🌐 https://www.td-shg.de/
- 📧 Kontakt über Website
- 📍 Dresden, Sachsen

---

### Dortmund
**DIS-Selbsthilfegruppe Dortmund**
- 📅 Jeden 3. Sonntag, 11:30-13:30 Uhr
- 📧 Kontakt über KISS Dortmund
- 📍 Dortmund, NRW

---

### Osnabrück
**DIS-Selbsthilfegruppe-OS**
- 📧 Kontakt über KISS Osnabrück
- 📍 Osnabrück, Niedersachsen

---

### Nürnberg
**DIS United**
- 📞 KISS Nürnberg: 0911 234 94 49
- 📧 Kontakt über KISS
- 📍 Nürnberg, Bayern

---

### Hamburg
**KISS Selbsthilfe Hamburg**
- 📞 040-395767
- 🕐 Mo-Do 11-17 Uhr
- 📍 Hamburg

---

### Weitere Städte mit Gruppen:
- Frankfurt am Main
- Hannover
- Kassel
- Bielefeld
- Darmstadt
- Köln
- Berlin

**Finde deine Stadt:**
🌐 **NAKOS.de** - Nationale Kontakt- und Informationsstelle zur Anregung und Unterstützung von Selbsthilfegruppen

➡️ https://www.nakos.de
📞 030-31018960

**Suche:** "DIS + Selbsthilfe + [deine Stadt]"

---

## 📝 Wie finde ich eine Gruppe?

1. **NAKOS Datenbank durchsuchen:**
   - https://www.nakos.de
   - Suchbegriffe: "DIS", "Dissoziation", "Trauma"

2. **Lokale KISS kontaktieren:**
   - KISS = Kontakt- und Informationsstelle für Selbsthilfe
   - Fast jede Stadt hat eine
   - Google: "KISS [deine Stadt]"

3. **Therapeuten fragen:**
   - Trauma-Therapeuten kennen oft lokale Gruppen

4. **Online-Foren fragen:**
   - DIS-kussion.de
   - Reddit r/DID (deutsche Posts)

---

## ✅ Vorteile von Selbsthilfegruppen

- **Du bist nicht allein** - andere verstehen dich
- **Erfahrungsaustausch** - Tipps von Menschen, die es durchleben
- **Sicherer Raum** - keine Stigmatisierung
- **Kostenlos** - keine Therapiekosten
- **Regelmäßigkeit** - feste Struktur

---

## ⚠️ Was tun, wenn keine Gruppe in meiner Stadt ist?

**Alternative 1: Online-Gruppen**
- Zoom/Skype Selbsthilfegruppen
- Einige bieten virtuelle Treffen an

**Alternative 2: Eigene Gruppe gründen!**
- KISS berät dich dabei
- NAKOS bietet Unterstützung

**Alternative 3: Online-Communities** (siehe nächste Sektion)
```

---

### 3.2 Online-Communities & Foren

**Content:**
```markdown
# Online-Communities für DIS

## 🇩🇪 Deutschsprachige Communities

### DIS-kussion.de
**Hauptforum für DIS in Deutschland**
- 🌐 https://www.dis-kussion.de / https://dissoziation-forum.de
- 📊 Größte deutsche DIS-Community
- 💬 Themen: Alltag, Therapie, Trigger-Warnung-Bereiche, Austausch
- ✅ Moderiert, sicherer Raum
- ⚠️ Registrierung erforderlich

**Was du findest:**
- Erfahrungsberichte
- Fragen & Antworten
- Therapie-Tipps
- Trigger-Management
- Alltags-Herausforderungen

---

### Vielfalt-info.de
**Viele-Treff - Community für Vielfältige**
- 🌐 https://www.vielfalt-info.de
- 💬 Forum + Ressourcen
- 📚 Informationen zu DIS, OSDD, etc.
- ✅ Inklusiv, respektvoll

**Besonderheit:**
- Auch für OSDD (Other Specified Dissociative Disorder)
- Fokus auf "Vielfalt" statt "Störung"

---

### DEGPT - Deutsche Gesellschaft für Psychotraumatologie
**Fachgesellschaft mit Patient:innen-Ressourcen**
- 🌐 https://www.degpt.de
- 📚 Wissenschaftliche Infos
- 🩺 Therapeutensuche
- 📅 Veranstaltungen

**Nicht direkt Forum, aber:**
- Seriöse Informationen
- Therapeutenverzeichnis
- Weiterbildungen

---

## 🌍 Internationale Communities (Englisch)

### Reddit - r/DID
**Größte englischsprachige DIS-Community**
- 🌐 https://www.reddit.com/r/DID/
- 👥 100,000+ Mitglieder
- 💬 Täglich aktiv
- ✅ Gut moderiert
- ⚠️ Englisch

**Was du findest:**
- Daily Discussions
- Success Stories
- Memes & Humor
- Advice & Support

**Regeln:**
- Respektvoll
- Keine Fakeclaiming (niemand wird angezweifelt)
- Trigger Warnings

---

### Reddit - r/OSDD
**Für OSDD (Other Specified Dissociative Disorder)**
- 🌐 https://www.reddit.com/r/OSDD/
- 👥 Kleinere, aber aktive Community
- ✅ Für Systeme, die nicht "klassisch" DIS sind

---

### DID-Research.org
**Umfassende Informationsseite**
- 🌐 https://did-research.org/
- 📚 Wissenschaftliche Artikel
- 📖 Erklärungen zu DIS
- 🎓 Für Betroffene UND Fachkräfte
- ✅ Evidenz-basiert

**Besonders gut für:**
- Neu diagnostizierte
- Angehörige, die DIS verstehen wollen
- Therapeuten in Ausbildung

---

### Beauty After Bruises (Blog)
**Persönlicher Blog über Leben mit DIS**
- 🌐 https://www.beautyafterbruises.org
- 📝 Erfahrungsberichte
- 💡 Coping-Strategien
- ✅ Hoffnungsvoll, empowernd

---

### HealthyPlace DID Community
**Forum + Ressourcen**
- 🌐 https://www.healthyplace.com/abuse/dissociative-identity-disorder
- 💬 Forum für Diskussionen
- 📚 Artikel zu Symptomen, Behandlung
- ✅ Professionell moderiert

---

## 🎥 YouTube Channels (Education & Awareness)

### DissociaDID (Englisch)
- 🎬 Education über DIS
- 💬 Persönliche Erfahrungen
- ⚠️ Kontrovers in Community (aber informativ)

### MultiplicityAndMe (Englisch)
- 🎬 Alltag mit DIS
- 💬 System-Dynamiken
- ✅ Authentisch, nahbar

### The Entropy System (Englisch)
- 🎬 DIS + Autismus
- 💬 Intersektionalität
- ✅ Wissenschaftlich fundiert

---

## ⚠️ Online-Sicherheit

**Tipps für sichere Online-Teilnahme:**

✅ **Nutze Pseudonym** - schütze deine Identität
✅ **Setze Grenzen** - du musst nichts teilen
✅ **Trigger Warnings beachten** - schütze dich
✅ **Blockiere toxische User** - keine Toleranz für Missbrauch
✅ **Keine persönlichen Details** - Adresse, Telefon, Arbeitsplatz privat halten

❌ **Vermeide:**
- Fakeclaiming (andere anzweifeln)
- Trauma-Wettbewerbe ("meins war schlimmer")
- Ungebetene Ratschläge
- Überidentifikation (Online ≠ Realität)

---

## 💙 Du bist nicht allein

**Millionen Menschen weltweit haben DIS.**

Diese Communities zeigen:
- **Du bist nicht kaputt**
- **Andere verstehen dich**
- **Recovery ist möglich**
- **Du verdienst Support**

**→ Wähle eine Plattform und versuche es!**
```

---

### 3.3 Therapeuten-Verzeichnis & Therapie finden

**Content:**
```markdown
# Therapie finden - Wie & Wo?

## 🩺 Warum Therapie wichtig ist

DIS ist **behandelbar** - aber meist nicht ohne professionelle Hilfe.

**Therapie kann helfen bei:**
- Trauma-Verarbeitung
- Reduzierung von Amnesie
- Ko-Bewusstsein fördern
- Alltags-Funktionen verbessern
- Innere Kommunikation stärken
- Symptome managen

**→ Therapie ist KEIN Zeichen von Schwäche!**

---

## 🔍 Schritt 1: Den richtigen Therapeuten finden

### Was du brauchst:

**Spezialisierung:**
- **Trauma-Therapie** (essentiell!)
- **Dissoziative Störungen** (ideal)
- Erfahrung mit DIS (sehr hilfreich)

**Therapieformen, die helfen:**
- **EMDR** (Eye Movement Desensitization and Reprocessing)
- **DBT** (Dialectical Behavior Therapy) - Emotionsregulation
- **Trauma-fokussierte KVT** (Kognitive Verhaltenstherapie)
- **Psychodynamische Therapie**
- **Ego-State-Therapie** (speziell für dissoziative Störungen)

**❌ NICHT geeignet:**
- Therapeuten ohne Trauma-Ausbildung
- "Klassische" Psychoanalyse ohne Trauma-Fokus
- Therapeuten, die DIS nicht anerkennen

---

## 📍 Wo finde ich Trauma-Therapeuten?

### Option 1: DEGPT Therapeutensuche
**Deutsche Gesellschaft für Psychotraumatologie**

- 🌐 https://www.degpt.de
- 📂 Menü: "Therapeutensuche" oder "Fachkräfte finden"
- 🔎 Filter: Postleitzahl, Spezialisierung
- ✅ Alle gelisteten Therapeuten haben **Trauma-Zertifizierung**

**Vorteile:**
- Qualitätsgesichert
- Trauma-Spezialisierung garantiert
- Nach Postleitzahl suchbar

**Nachteil:**
- Nicht alle nehmen Kassenpatienten

---

### Option 2: Therapie.de
**Therapeutensuche für ganz Deutschland**

- 🌐 https://www.therapie.de/psychotherapie/
- 🔎 Filter: PLZ, Störungsbild ("Dissoziation", "Trauma")
- ✅ Große Datenbank

**Vorteil:**
- Viele Therapeuten
- Detaillierte Profile

**Nachteil:**
- Qualität variiert (nicht alle spezialisiert)

---

### Option 3: Krankenkasse
**Kassensitz-Therapeuten über Krankenkasse finden**

- 📞 Ruf deine Krankenkasse an
- 📝 Frage nach: "Trauma-Therapeut mit Kassensitz in [Stadt]"
- 🩺 Krankenkasse hat Listen

**Vorteil:**
- Kosten übernommen (bei Kassensitz)

**Nachteil:**
- Lange Wartezeiten (oft 6-12 Monate)

---

### Option 4: Selbsthilfegruppen fragen
**Persönliche Empfehlungen sind Gold wert!**

- 💬 In Selbsthilfegruppen nachfragen
- 📧 In Online-Foren (DIS-kussion.de) fragen
- 🗣️ Andere Betroffene haben oft Insider-Tipps

**Vorteil:**
- Echte Erfahrungen
- "Geheimtipps"

---

## 💰 Kosten & Kassensitz

### Kassensitz (gesetzlich versichert)
**Therapie wird von Krankenkasse bezahlt**

- ✅ **Keine Kosten** für dich
- ✅ Bis zu 80 Stunden (Langzeittherapie)
- ❌ **Lange Wartezeiten** (6-12 Monate)
- ❌ Nicht alle Trauma-Therapeuten haben Kassensitz

**Wie beantragen?**
1. Therapeut mit Kassensitz finden
2. Probatorische Sitzungen (5 Sitzungen zum Kennenlernen)
3. Therapeut stellt Antrag bei Krankenkasse
4. Genehmigung (meist problemlos bei DIS-Diagnose)

---

### Privatversichert
**Therapie über private Krankenversicherung**

- ✅ Kürzere Wartezeiten
- ✅ Mehr Therapeuten verfügbar
- ❌ Kosten werden teils/ganz erstattet (je nach Vertrag)

**Prüfe deinen Vertrag:**
- Wie viele Sitzungen pro Jahr?
- Welcher Prozentsatz wird erstattet?

---

### Selbstzahler
**Therapie selbst bezahlen**

- ✅ **Sofort** verfügbar (keine Wartezeit)
- ✅ Freie Therapeutenwahl
- ❌ **Teuer:** 80-150€ pro Sitzung

**Wann sinnvoll?**
- Akute Krise, keine Zeit zu warten
- Kein Kassensitz verfügbar
- Finanzielle Möglichkeiten vorhanden

**Tipp:** Manche Therapeuten bieten **Sozialstaffel** (reduzierte Preise)

---

## 📞 Terminservicestelle (TSS)

**Bundesweite Hotline für Therapieplätze**

- 📞 **116 117**
- 🕐 24/7 erreichbar
- ✅ Vermitteln innerhalb von **4 Wochen** einen Termin

**Wie funktioniert's?**
1. Anrufen: 116 117
2. Situation schildern ("DIS-Diagnose, brauche Trauma-Therapie")
3. TSS sucht Therapeuten in deiner Nähe
4. Du bekommst Termin (meist Erstgespräch)

**Vorteil:**
- Schneller als eigene Suche
- Kostenlos

**Nachteil:**
- Nicht immer DIS-Spezialist
- Kann weiter weg sein

---

## 🤝 Erstes Gespräch - Was fragen?

**Bringe diese Fragen mit:**

1. **"Haben Sie Erfahrung mit DIS?"**
   - ✅ JA: Gut!
   - ❌ NEIN, aber mit Trauma: Kann funktionieren
   - ❌ NEIN, gar nicht: Weitersuchen

2. **"Welche Therapieform nutzen Sie?"**
   - ✅ EMDR, DBT, Ego-State: Gut!
   - ❌ "Klassische Analyse": Eher nicht

3. **"Wie gehen Sie mit Dissoziation in Sitzungen um?"**
   - ✅ Therapeut kennt Grounding-Techniken: Gut!
   - ❌ "Was ist Dissoziation?": Red Flag

4. **"Ist das Ziel Integration oder Kooperation?"**
   - ✅ "Das entscheiden Sie!": Gut!
   - ❌ "Integration ist das einzige Ziel": Red Flag

**→ Du darfst wählerisch sein! Therapeut muss zu DIR passen.**

---

## 🚩 Red Flags - Wann Therapeut wechseln

**Warnsignale:**
- ❌ Zweifelt deine DIS-Diagnose an ("Das ist nur Einbildung")
- ❌ Drängt auf Integration, obwohl du das nicht willst
- ❌ Überschreitet Grenzen (unangemessener Körperkontakt, etc.)
- ❌ Triggert dich absichtlich ohne Consent
- ❌ Keine Trauma-Ausbildung
- ❌ "DIS gibt es nicht"

**→ Therapeut wechseln ist OKAY und manchmal nötig!**

---

## 💡 Was du in Therapie erwarten kannst

**Phasen der Trauma-Therapie:**

### Phase 1: Stabilisierung (Monate bis Jahre)
- Sicherheit schaffen
- Grounding lernen
- Emotionsregulation
- Innere Kommunikation fördern

### Phase 2: Trauma-Bearbeitung (Jahre)
- EMDR, Konfrontation (sanft!)
- Traumatische Erinnerungen verarbeiten
- Neubewertung von Ereignissen

### Phase 3: Integration/Kooperation (offen)
- Systeme entscheiden: Zusammenführung oder Koexistenz?
- Alltagsfunktionen optimieren
- Zukunftsplanung

**→ Recovery ist ein Marathon, kein Sprint!**

---

## 📚 Buchtipps (zum Verstehen von Therapie)

- "Leben mit Dissoziativer Identitätsstörung" (Deutsch)
- "The Body Keeps the Score" - Bessel van der Kolk (Trauma-Bibel)
- "Got Parts?" - ATW (DIS-spezifisch)
- "Traumatherapie bei dissoziativen Störungen" - Michaela Huber

---

## 💙 Du verdienst Hilfe

**Therapie zu suchen ist mutig.**

- Es ist KEIN Zeichen von Schwäche
- Viele Therapeuten verstehen DIS
- Recovery ist möglich
- Du bist es wert

**→ Fang heute an - der erste Anruf ist der schwerste!**
```

---

## UI/UX DESIGN

### 4.1 "Du bist nicht allein" Banner Design

**Visual Mockup:**
```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│            💜 Du bist nicht allein 💜                    │
│                                                          │
│   Viele Menschen leben erfolgreich mit DIS. Hier        │
│   findest du Unterstützung, Informationen und eine      │
│   Community, die dich versteht.                         │
│                                                          │
│   ┌──────────────────┐    ┌──────────────────┐          │
│   │ 🚨 Notfall       │    │ 🧘 Grounding     │          │
│   │    Hilfe jetzt   │    │    starten       │          │
│   └──────────────────┘    └──────────────────┘          │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Design Specs:**
```dart
Container(
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF9D84B7), // Soft purple
        Color(0xFFE8A0BF), // Soft pink
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.purple.withOpacity(0.2),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    children: [
      // Icon
      Icon(
        Icons.favorite,
        color: Colors.white,
        size: 40,
      ),
      SizedBox(height: 12),

      // Headline
      Text(
        'Du bist nicht allein',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      SizedBox(height: 8),

      // Body text
      Text(
        'Viele Menschen leben erfolgreich mit DIS. Hier findest du '
        'Unterstützung, Informationen und eine Community, die dich versteht.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.95),
        ),
      ),
      SizedBox(height: 16),

      // Action Buttons
      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.emergency),
              label: Text('Notfall\nHilfe jetzt'),
              onPressed: () {/* Navigate to Emergency Tab */},
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.self_improvement),
              label: Text('Grounding\nstarten'),
              onPressed: () {/* Navigate to Coping Tab */},
            ),
          ),
        ],
      ),
    ],
  ),
)
```

---

### 4.2 Tab Navigation Design

**Tab Bar Structure:**
```
┌────────────────────────────────────────────────────────┐
│  [Banner: Du bist nicht allein]                       │
├────────────────────────────────────────────────────────┤
│  🚨 Notfall  │ 📚 Was ist DIS?  │ 🧘 Coping          │
│  🤝 Community │ 🩺 Therapie     │ ❓ Mythen          │
├────────────────────────────────────────────────────────┤
│                                                        │
│  [Tab Content Area]                                    │
│                                                        │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Implementation:**
```dart
DefaultTabController(
  length: 6,
  child: Scaffold(
    appBar: AppBar(
      title: Text('Hilfsangebote'),
      bottom: TabBar(
        isScrollable: true,
        tabs: [
          Tab(icon: Icon(Icons.emergency), text: 'Notfall'),
          Tab(icon: Icon(Icons.menu_book), text: 'Was ist DIS?'),
          Tab(icon: Icon(Icons.self_improvement), text: 'Coping'),
          Tab(icon: Icon(Icons.groups), text: 'Community'),
          Tab(icon: Icon(Icons.medical_services), text: 'Therapie'),
          Tab(icon: Icon(Icons.help_outline), text: 'Mythen'),
        ],
      ),
    ),
    body: Column(
      children: [
        // Banner (persistent at top)
        NotAloneBanner(),

        // Tab content
        Expanded(
          child: TabBarView(
            children: [
              EmergencyTab(),
              WhatIsDISTab(),
              CopingTab(),
              CommunityTab(),
              TherapyTab(),
              MythsTab(),
            ],
          ),
        ),
      ],
    ),
  ),
)
```

---

## CONTENT ORGANIZATION

### Content Storage: Markdown Files

**Directory Structure:**
```
assets/help_content/
├── de/
│   ├── what_is_dis.md
│   ├── symptoms.md
│   ├── terminology.md
│   ├── myths.md
│   ├── grounding_5-4-3-2-1.md
│   ├── grounding_ice.md
│   ├── grounding_breathing.md
│   ├── crisis_management.md
│   ├── self_care.md
│   ├── support_groups.md
│   ├── online_communities.md
│   └── therapy_guide.md
└── en/ (future)
    └── ...
```

**Loading Content:**
```dart
class HelpContentLoader {
  static Future<String> loadContent(String filename) async {
    return await rootBundle.loadString('assets/help_content/de/$filename');
  }
}

// Usage
String whatIsDIS = await HelpContentLoader.loadContent('what_is_dis.md');
```

**Rendering Markdown:**
```dart
// pubspec.yaml
dependencies:
  flutter_markdown: ^0.7.0

// Widget
import 'package:flutter_markdown/flutter_markdown.dart';

Markdown(
  data: contentString,
  styleSheet: MarkdownStyleSheet(
    h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    p: TextStyle(fontSize: 16),
  ),
)
```

---

## PRIVACY & OFFLINE-FIRST

### 1. All Content Embedded

**Strategy:**
- ✅ ALL education content in `assets/` (bundled with app)
- ✅ NO network requests for core content
- ✅ Works completely offline

**Only External Links:**
- Hotlines (phone numbers)
- Websites (community forums, therapist directories)
- → User warned before opening

---

### 2. External Link Warning

**Implementation:**
```dart
Future<void> _openExternalLink(String url) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.open_in_new, color: Colors.orange),
      title: Text('Externe Website öffnen?'),
      content: Text(
        'Du verlässt Aurora und öffnest eine externe Website:\n\n'
        '$url\n\n'
        'Aurora hat keine Kontrolle über deren Datenschutz.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Öffnen'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication, // User's browser
    );
  }
}
```

---

### 3. No Tracking

**Privacy Guarantees:**
- ❌ NO analytics when viewing help content
- ❌ NO tracking which articles are read
- ❌ NO personalized recommendations (privacy risk)
- ✅ User can favorite articles (stored locally in Hive)
- ✅ User controls ALL data

---

## IMPLEMENTIERUNGS-PLAN

### Phase 1: Content Creation & Models (3-4 Tage)

#### Tag 1-2: Content Writing
**Aufgabe:** Alle Markdown-Dateien schreiben

- [ ] `what_is_dis.md` (~800 Wörter)
- [ ] `symptoms.md` (~600 Wörter)
- [ ] `terminology.md` (~1000 Wörter)
- [ ] `myths.md` (~1200 Wörter)
- [ ] `grounding_*.md` (5 Dateien, je ~200 Wörter)
- [ ] `crisis_management.md` (~600 Wörter)
- [ ] `self_care.md` (~700 Wörter)
- [ ] `support_groups.md` (~900 Wörter)
- [ ] `online_communities.md` (~500 Wörter)
- [ ] `therapy_guide.md` (~800 Wörter)

**Total:** ~7,400 Wörter (10-12 Stunden Schreibarbeit)

---

#### Tag 3: Data Models

**Files to Create:**
```
lib/models/
├── help_resource.dart
├── help_resource.g.dart (generated)
└── grounding_technique.dart
```

**HelpResource Model:**
```dart
@HiveType(typeId: 20) // Adjust as needed
class HelpResource extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final HelpResourceType type;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String? contentFile; // Markdown filename

  @HiveField(5)
  final String? url; // External link

  @HiveField(6)
  final String? phone; // Hotline number

  @HiveField(7)
  final List<String> tags;

  @HiveField(8)
  bool isFavorite; // User can favorite

  HelpResource({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.contentFile,
    this.url,
    this.phone,
    this.tags = const [],
    this.isFavorite = false,
  });
}

@HiveType(typeId: 21)
enum HelpResourceType {
  @HiveField(0)
  hotline,

  @HiveField(1)
  article,

  @HiveField(2)
  technique,

  @HiveField(3)
  supportGroup,

  @HiveField(4)
  therapistDirectory,

  @HiveField(5)
  myth,
}
```

**After model creation:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

#### Tag 4: Help Resources Service

**File:** `lib/services/help_resources_service.dart`

```dart
class HelpResourcesService extends BaseService {
  HelpResourcesService(super.eventBus);

  late Box<HelpResource> _resourcesBox;

  @override
  Future<void> openBoxes() async {
    _resourcesBox = await Hive.openBox<HelpResource>('help_resources');

    // Populate initial resources if empty
    if (_resourcesBox.isEmpty) {
      await _populateDefaultResources();
    }
  }

  Future<void> _populateDefaultResources() async {
    // Emergency Hotlines
    await _resourcesBox.put('hotline_telefonseelsorge_1', HelpResource(
      id: 'hotline_telefonseelsorge_1',
      type: HelpResourceType.hotline,
      title: 'Telefonseelsorge',
      description: '24/7 kostenlos, anonym',
      phone: '0800 111 0 111',
      tags: ['notfall', 'krise', '24/7'],
    ));

    // Articles
    await _resourcesBox.put('article_what_is_dis', HelpResource(
      id: 'article_what_is_dis',
      type: HelpResourceType.article,
      title: 'Was ist DIS?',
      description: 'Grundlagen zur Dissoziativen Identitätsstörung',
      contentFile: 'what_is_dis.md',
      tags: ['bildung', 'grundlagen'],
    ));

    // Grounding Techniques
    await _resourcesBox.put('technique_5-4-3-2-1', HelpResource(
      id: 'technique_5-4-3-2-1',
      type: HelpResourceType.technique,
      title: '5-4-3-2-1 Methode',
      description: 'Grounding durch 5 Sinne',
      contentFile: 'grounding_5-4-3-2-1.md',
      tags: ['grounding', 'übung', 'krise'],
    ));

    // ... more resources
  }

  List<HelpResource> getResourcesByType(HelpResourceType type) {
    return _resourcesBox.values
        .where((r) => r.type == type)
        .toList();
  }

  List<HelpResource> getFavorites() {
    return _resourcesBox.values
        .where((r) => r.isFavorite)
        .toList();
  }

  Future<void> toggleFavorite(String resourceId) async {
    final resource = _resourcesBox.get(resourceId);
    if (resource != null) {
      resource.isFavorite = !resource.isFavorite;
      await resource.save();
    }
  }

  Future<String> loadContent(String filename) async {
    return await rootBundle.loadString('assets/help_content/de/$filename');
  }

  @override
  Future<void> closeBoxes() async {
    await _resourcesBox.close();
  }
}
```

---

### Phase 2: UI Components (3-4 Tage)

#### Tag 5: Help Tab Bar & Screen Refactor

**File:** `lib/modules/help/help_resources_screen.dart` (REFACTOR)

**Current:** Simple ListView with hotlines
**New:** TabBar with 6 tabs

```dart
class HelpResourcesScreen extends StatefulWidget {
  const HelpResourcesScreen({super.key});

  @override
  State<HelpResourcesScreen> createState() => _HelpResourcesScreenState();
}

class _HelpResourcesScreenState extends State<HelpResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hilfsangebote'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.emergency), text: 'Notfall'),
            Tab(icon: Icon(Icons.menu_book), text: 'Was ist DIS?'),
            Tab(icon: Icon(Icons.self_improvement), text: 'Coping'),
            Tab(icon: Icon(Icons.groups), text: 'Community'),
            Tab(icon: Icon(Icons.medical_services), text: 'Therapie'),
            Tab(icon: Icon(Icons.help_outline), text: 'Mythen'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner: Du bist nicht allein (persistent)
          const NotAloneBanner(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                EmergencyTab(),
                WhatIsDISTab(),
                CopingTab(),
                CommunityTab(),
                TherapyTab(),
                MythsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

#### Tag 6: Banner & Tab Widgets

**Files to Create:**
```
lib/modules/help/widgets/
├── not_alone_banner.dart
├── emergency_tab.dart
├── what_is_dis_tab.dart
├── coping_tab.dart
├── community_tab.dart
├── therapy_tab.dart
└── myths_tab.dart
```

**NotAloneBanner Widget:**
```dart
// lib/modules/help/widgets/not_alone_banner.dart
class NotAloneBanner extends StatelessWidget {
  const NotAloneBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9D84B7), Color(0xFFE8A0BF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Du bist nicht allein',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Viele Menschen leben erfolgreich mit DIS. Hier findest du '
            'Unterstützung, Informationen und eine Community, die dich versteht.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.emergency),
                  label: const Text('Notfall\nHilfe jetzt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9D84B7),
                  ),
                  onPressed: () {
                    // Switch to Emergency tab (index 0)
                    DefaultTabController.of(context).animateTo(0);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.self_improvement),
                  label: const Text('Grounding\nstarten'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9D84B7),
                  ),
                  onPressed: () {
                    // Switch to Coping tab (index 2)
                    DefaultTabController.of(context).animateTo(2);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

#### Tag 7-8: Individual Tab Screens

**Example: WhatIsDISTab**
```dart
class WhatIsDISTab extends StatelessWidget {
  const WhatIsDISTab({super.key});

  @override
  Widget build(BuildContext context) {
    final service = getIt<HelpResourcesService>();

    return FutureBuilder<List<HelpResource>>(
      future: Future.value(
        service.getResourcesByType(HelpResourceType.article)
            .where((r) => r.tags.contains('grundlagen'))
            .toList(),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final articles = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return ResourceCard(
              resource: article,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleViewerScreen(resource: article),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
```

**ResourceCard Widget:**
```dart
class ResourceCard extends StatelessWidget {
  final HelpResource resource;
  final VoidCallback onTap;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _getIcon(),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(resource.description),
        trailing: IconButton(
          icon: Icon(
            resource.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: resource.isFavorite ? Colors.purple : null,
          ),
          onPressed: () {
            getIt<HelpResourcesService>().toggleFavorite(resource.id);
          },
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _getIcon() {
    switch (resource.type) {
      case HelpResourceType.hotline:
        return const Icon(Icons.phone, color: Colors.red);
      case HelpResourceType.article:
        return const Icon(Icons.article, color: Colors.blue);
      case HelpResourceType.technique:
        return const Icon(Icons.self_improvement, color: Colors.green);
      case HelpResourceType.supportGroup:
        return const Icon(Icons.groups, color: Colors.orange);
      case HelpResourceType.therapistDirectory:
        return const Icon(Icons.medical_services, color: Colors.purple);
      case HelpResourceType.myth:
        return const Icon(Icons.help_outline, color: Colors.amber);
    }
  }
}
```

**ArticleViewerScreen:**
```dart
class ArticleViewerScreen extends StatelessWidget {
  final HelpResource resource;

  const ArticleViewerScreen({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    final service = getIt<HelpResourcesService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(resource.title),
        actions: [
          IconButton(
            icon: Icon(
              resource.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              service.toggleFavorite(resource.id);
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: service.loadContent(resource.contentFile!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Markdown(
            data: snapshot.data!,
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              p: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
```

---

### Phase 3: Interactive Features (1-2 Tage)

#### Tag 9: Interactive Grounding Exercise

**File:** `lib/modules/help/widgets/interactive_grounding_widget.dart`

```dart
class InteractiveGroundingWidget extends StatefulWidget {
  const InteractiveGroundingWidget({super.key});

  @override
  State<InteractiveGroundingWidget> createState() =>
      _InteractiveGroundingWidgetState();
}

class _InteractiveGroundingWidgetState
    extends State<InteractiveGroundingWidget> {
  int _currentStep = 0;

  final List<GroundingStep> _steps = [
    GroundingStep(
      title: '5 Dinge SEHEN',
      description: 'Benenne 5 Dinge, die du um dich herum siehst.',
      icon: Icons.visibility,
    ),
    GroundingStep(
      title: '4 Dinge HÖREN',
      description: 'Benenne 4 Dinge, die du hörst.',
      icon: Icons.hearing,
    ),
    GroundingStep(
      title: '3 Dinge BERÜHREN',
      description: 'Berühre 3 Dinge und beschreibe die Textur.',
      icon: Icons.touch_app,
    ),
    GroundingStep(
      title: '2 Dinge RIECHEN',
      description: 'Benenne 2 Gerüche (oder erinnere dich an angenehme).',
      icon: Icons.local_florist,
    ),
    GroundingStep(
      title: '1 Ding SCHMECKEN',
      description: 'Schmecke etwas oder erinnere dich an einen Geschmack.',
      icon: Icons.restaurant,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      // Completed!
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: const Text('Gut gemacht!'),
        content: const Text(
          'Du hast die Grounding-Übung abgeschlossen. '
          'Fühlst du dich etwas besser?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
            ),
            const SizedBox(height: 20),

            // Icon
            Icon(step.icon, size: 80, color: Colors.purple),
            const SizedBox(height: 16),

            // Title
            Text(
              step.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              step.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Next Button
            ElevatedButton(
              onPressed: _nextStep,
              child: Text(
                _currentStep < _steps.length - 1 ? 'Weiter' : 'Fertig',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroundingStep {
  final String title;
  final String description;
  final IconData icon;

  GroundingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
```

---

### Phase 4: Integration & Testing (1-2 Tage)

#### Tag 10-11: Testing & Bug Fixes

**Testing Checklist:**
- [ ] All tabs load correctly
- [ ] Markdown content renders
- [ ] External links show warning
- [ ] Hotline "Call" buttons work
- [ ] Favorites toggle persists
- [ ] Interactive grounding works
- [ ] Offline mode works (no network)
- [ ] "Du bist nicht allein" banner visible
- [ ] Navigation smooth
- [ ] German translations correct
- [ ] No privacy leaks
- [ ] Accessibility (screen readers)

---

## TESTING-SZENARIEN

### Scenario 1: Neue Diagnose - Informationen suchen

**User Story:**
"Ich wurde gerade mit DIS diagnostiziert und weiß nicht, was das bedeutet."

**Steps:**
1. User öffnet Aurora
2. Navigiert zu Help Tab
3. Sieht "Du bist nicht allein" Banner → fühlt sich beruhigt
4. Tippt auf "Was ist DIS?" Tab
5. Liest Artikel "Was ist DIS?"
6. Versteht: 1-2% betroffen, nicht selten, Schutzreaktion
7. Favorited Artikel für später

**Expected Result:**
- ✅ User fühlt sich informiert
- ✅ User versteht DIS besser
- ✅ User fühlt sich weniger allein

---

### Scenario 2: Akute Krise - Grounding brauchen

**User Story:**
"Ich dissoziiere gerade stark und brauche JETZT Hilfe."

**Steps:**
1. User öffnet Aurora
2. Navigiert zu Help Tab (oder sieht Quick Access in Emergency)
3. Tippt "Grounding starten" im Banner
4. Wird zu Coping Tab geleitet
5. Sieht Interactive Grounding Exercise
6. Startet 5-4-3-2-1 Übung
7. Folgt Schritt-für-Schritt Anleitung
8. Fühlt sich danach etwas geerdet

**Expected Result:**
- ✅ Schneller Zugang zu Grounding
- ✅ Klare, einfache Anleitung
- ✅ User kommt zurück ins Hier und Jetzt

---

### Scenario 3: Selbsthilfegruppe finden

**User Story:**
"Ich möchte andere Menschen mit DIS treffen."

**Steps:**
1. User öffnet Help Tab
2. Navigiert zu "Community" Tab
3. Liest Artikel über Selbsthilfegruppen
4. Findet Gruppe in eigener Stadt (z.B. Dresden)
5. Notiert Kontaktdaten
6. Favorited Artikel

**Expected Result:**
- ✅ User findet lokale Ressourcen
- ✅ User hat Kontaktdaten
- ✅ User fühlt sich ermutigt, Hilfe zu suchen

---

### Scenario 4: Mythen aufklären

**User Story:**
"Meine Familie denkt, DIS ist wie Schizophrenie und ich bin gefährlich."

**Steps:**
1. User navigiert zu "Mythen" Tab
2. Liest Mythen-Aufklärung
3. Findet: "DIS ≠ Schizophrenie"
4. Findet: "Menschen mit DIS sind nicht gefährlich"
5. Teilt Informationen mit Familie (optional)

**Expected Result:**
- ✅ User hat wissenschaftliche Fakten
- ✅ User kann Familie aufklären
- ✅ Stigma reduziert

---

## AUFWANDSSCHÄTZUNG

### Gesamt: 10-13 Tage (~2-2,5 Wochen)

| Phase | Aufgaben | Tage |
|-------|----------|------|
| **Phase 1: Content & Models** | | 3-4 |
| - Content Writing (Markdown) | 9 Artikel, ~7400 Wörter | 1.5-2 |
| - Data Models (HelpResource) | Hive models + generation | 0.5 |
| - HelpResourcesService | Service layer | 1 |
| **Phase 2: UI Components** | | 3-4 |
| - HelpResourcesScreen Refactor | Tab structure | 1 |
| - NotAloneBanner Widget | Banner design | 0.5 |
| - 6 Tab Screens | Content tabs | 2-2.5 |
| **Phase 3: Interactive Features** | | 1-2 |
| - Interactive Grounding | Step-by-step exercise | 1 |
| - Favorites System | Toggle + persistence | 0.5 |
| - External Link Warning | Dialog | 0.5 |
| **Phase 4: Integration & Testing** | | 1-2 |
| - Emergency Screen Integration | Footer banner | 0.5 |
| - End-to-End Testing | All scenarios | 1 |
| - Bug Fixes | Issues found | 0.5 |
| - Polish & Docs | Final touches | 0.5 |

---

## NÄCHSTE SCHRITTE

### Sofort umsetzbar:
1. **Content schreiben** (kann parallel erfolgen)
2. **Markdown-Dateien erstellen** (`assets/help_content/de/`)
3. **HelpResource Model** erstellen
4. **HelpResourcesService** implementieren

### Später:
5. UI Components (Tabs, Banner)
6. Interactive Features (Grounding)
7. Testing & Polish

---

## ZUSAMMENFASSUNG

**"Du bist nicht allein"** verwandelt Aurora von einer reinen Tool-App in eine **umfassende Support-Plattform** für Menschen mit DIS.

### Was es bietet:
1. ✅ **Education** - Was ist DIS wirklich?
2. ✅ **Crisis Support** - Hotlines, Grounding, Notfallpläne
3. ✅ **Community** - Selbsthilfegruppen, Foren, Therapeuten
4. ✅ **Coping Tools** - Praktische Techniken für den Alltag
5. ✅ **Myth-Busting** - Wissenschaft vs. Hollywood
6. ✅ **Prominent Messaging** - "Du bist nicht allein" überall sichtbar

### Warum das wichtig ist:
- **User Acquisition:** Alleinstellungsmerkmal vs. Konkurrenz
- **User Retention:** Nutzer kehren für Ressourcen zurück
- **Impact:** Echte Hilfe für isolierte, überforderte Menschen
- **App Store Success:** Positive Reviews, Featured Potential

**Aufwand:** 10-13 Tage
**Priorität:** SEHR HOCH
**Impact:** GAME-CHANGER für Aurora

---

**Dokument-Ende**
