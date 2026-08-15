# Gegenprobe zur Übersetzungsprüfung

Datum: 13.08.2026 · Geprüft wird `docs/pruefung-uebersetzung-fable.md`
(25 Befunde, gemeldet von der Fable-Instanz).

Ein Bericht ist eine Behauptung. Diese Seite hält fest, was davon der
Nachmessung standhält — gemessen direkt gegen die fünf `.arb`-Dateien.

## Ergebnis in einem Satz

Von den drei als „kritisch" gemeldeten Befunden hält **einer** stand, einer
**halb**, einer **gar nicht** — und die tragende Zahl des Berichts („84 englische
Texte nicht übersetzt") ist um rund zwei Größenordnungen zu hoch.

---

## Was standhält

### 1. Englisch ist die einzige Sprache ohne den Community-Begriff

Gezählt in `app_en.arb`:

| Wort | Treffer |
|---|---|
| `alter` / `alters` | **0** |
| `part` / `parts` | **24** |
| `system` | 16 |
| `switch` | 3 |

Und im Vergleich derselbe Schlüssel `onboardingMultiProfileDescription`:

- de: „Jeder **Anteil** bekommt ein eigenes Profil …"
- en: „Every **part** gets its own profile …"
- es: „Cada **alter** puede tener su propio perfil …"
- fr: „Chaque **alter** peut avoir son propre profil …"
- it: „Ogni **alter** può avere il suo profilo …"

**Spanisch, Französisch und Italienisch benutzen bereits `alter` — nur das
Englische nicht.** Das ist keine Geschmacksfrage, sondern eine Inkonsistenz
innerhalb desselben Produkts: dieselbe Sache heißt in vier Sprachen gleich und
in der fünften anders.

Welcher Begriff der richtige ist, ist in den Betroffenen-Communities umstritten
(`alter` ist der verbreitetste, manche Systeme lehnen ihn als klinisch ab und
bevorzugen `part`). Die Entscheidung gehört dem Projekt. Die **Uneinheitlichkeit**
gehört behoben, egal wie sie ausfällt.

### 2. Französisch mischt die Anrede — halb bestätigt

Gezählt über alle 1560 Schlüssel in `app_fr.arb`:

- `tu` / `ton` / `ta` / `tes` → **183** Schlüssel
- `vous` / `votre` / `vos` → **55** Schlüssel

Die Mischung ist real und sie ist die Art Bruch, die auffällt, ohne dass man
sagen kann warum: dieselbe App duzt an einer Stelle und siezt an der nächsten.

**Das Beispiel des Berichts war allerdings falsch.** `appDescription` lautet auf
Französisch „Aurora **t'**accompagne pour organiser **ton** quotidien …" — das ist
die Du-Form, genau wie im Deutschen. Wer nach den 55 sucht, muss sie selbst
suchen; der Bericht zeigt nicht auf sie.

Spanisch ist unauffälliger (115 × `tú/tus` gegen 12 × `usted/su`), und die 12
sind unzuverlässig, weil `su` dort auch schlicht „sein/ihr" heißt.

---

## Was nicht standhält

### 3. „`tabContacts` FR zeigt Contacts statt Französisch"

| | |
|---|---|
| de | Kontakte |
| en | Contacts |
| es | **Contactos** |
| fr | **Contacts** |
| it | **Contatti** |

„Contacts" **ist** das französische Wort. Spanisch und Italienisch sind
ebenfalls korrekt übersetzt. Kein Befund.

### 4. „`tabMantras` ES/FR unübersetzt"

`Mantras` ist im Spanischen und Französischen dasselbe Wort — ein Lehnwort aus
dem Sanskrit, das in keiner der beiden Sprachen ersetzt wird. Das Italienische
schreibt sogar korrekt `Mantra` (dort ohne Plural-s). Kein Befund.

### 5. „84 englische Texte wurden nicht in die Zielsprachen übersetzt"

Nachgezählt — Werte, die wortgleich mit dem Englischen sind:

| Sprache | wortgleich | davon länger als 15 Zeichen |
|---|---|---|
| es | 28 | **1** |
| fr | 37 | **3** |
| it | 26 | **1** |

Und die verbliebenen sind keine Texte, sondern Platzhaltergerüste:

- `notificationMedicationBodyWithTime`: `{name} - {dosage} {time}` — enthält kein
  einziges Wort
- `eventReminderMinutes`: `{minutes, plural, =1{1 minute} other{{minutes} minutes}}`
  — „minute/minutes" ist im Französischen identisch
- `securityQuestionN`: `Question {number}` — „Question" ist französisch

Die kurzen Treffer sind `OK`, `Info`, `E-Mail`, Ziffern und Ähnliches.

**Echte unübersetzte Texte: praktisch keine.** Die Zahl 84 ist nicht belegt.

---

## Warum das hier steht

Die Vier-Augen-Regel des Busses ist keine Förmlichkeit. Von 25 gemeldeten
Befunden hätte ein Drittel Arbeit ausgelöst, die nichts repariert — und die zwei
Änderungen an `tabContacts` und `tabMantras` hätten korrekte Übersetzungen
kaputtgemacht. Ein Bericht, der nicht gegengeprüft wurde, ist eine Liste von
Vermutungen mit Tabellenformatierung.

Umgekehrt gilt dasselbe für diese Seite: die Zahlen oben sind mit
`tmp/verify_fable.py` gegen die `.arb`-Dateien gemessen und jederzeit
nachrechenbar.

## Was als Nächstes zu entscheiden ist

1. `alter` oder `part` im Englischen — und dann in allen fünf Sprachen dasselbe.
2. Die 55 französischen `vous`-Stellen einzeln durchgehen und auf `tu` ziehen,
   soweit sie nicht im Halt- und Notfallbereich stehen.
