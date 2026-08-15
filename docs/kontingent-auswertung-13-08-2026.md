# Kontingent: was der Tag gekostet hat und was er wert war

Datum: 13.08.2026 · Ein Arbeitstag mit drei Modellen an Aurora — Claude
(Steuerung und Abnahme), Codex auf `xhigh` (Prüfung und Umbau), Fable
(Sprachprüfung).

Die Frage war: lohnt die hohe Denkstufe, und wo geht das Kontingent hin.

## Was gemessen ist

| | Fable | Codex `xhigh` (Prüfung) | Codex `xhigh` (Umbau) |
|---|---|---|---|
| Laufzeit | 4 min | ~20 min | ~35 min |
| Protokoll | — | 3,5 MB | 6,7 MB |
| Ergebnis | 25 Befunde | 15 Befunde | 10 Dateien + 1 Testdatei |
| Stichprobe hielt | **1 von 3** | **2 von 2** | 699 von 701 Tests |
| Rückfragen | keine | keine | **2** |

Der Tokenverbrauch von Codex ist von hier aus nicht sichtbar — er läuft über ein
anderes Kontingent. Vergleichbar sind Trefferquote, Rückfragen und die Frage,
ob eine Behauptung der Nachmessung standhält.

## Der Befund

**Das billige Modell war die teurere Wahl.**

Fable lieferte 25 Befunde in vier Minuten. Nachgemessen hielt davon einer
(Englisch benutzt „part" statt „alter", während es/fr/it „alter" schreiben),
einer halb (Französisch mischt `tu` und `vous` — 183 gegen 55 Schlüssel, aber
das genannte Beispiel war falsch), und der Rest nicht:

- „`tabContacts` FR zeigt Contacts statt Französisch" — *Contacts* **ist**
  Französisch.
- „`tabMantras` unübersetzt" — dasselbe Lehnwort in ES und FR.
- „**84** unübersetzte englische Texte" — nachgezählt 1 bis 3 je Sprache, und
  die sind reine Platzhalter wie `{name} - {dosage} {time}` ohne ein Wort.

**Zwei der Vorschläge hätten korrekte Übersetzungen kaputtgemacht.** Der
Zeitgewinn von vier Minuten wurde von der Nachmessung mehrfach aufgefressen.

Codex auf `xhigh` lieferte weniger und langsamer, aber jeder Stichprobenbefund
hielt. Wichtiger noch: er **fragte zweimal zurück, statt zu raten** — und eine
dieser Rückfragen deckte einen Fehler in *meinem* Auftrag auf (ich hatte eine
doppelte Kopfzeile als „am Gerät gesehen" ausgegeben; sie stammte aus einem
alten Store-Bild). Und als seine Umgebung die Prüfgates nicht ausführen konnte,
**meldete er das, statt grün zu behaupten**.

## Der teuerste Posten war keiner der Modelle

Vier Vermutungen von mir, jede mit einer Messrunde bezahlt, jede falsch:

| Vermutung | Wirklichkeit |
|---|---|
| Übersetzungen sind lückenhaft | 1560 Schlüssel, **alle fünf Sprachen vollständig** |
| Viele hartkodierte Strings | **13**, davon die Hälfte Beispielwerte |
| Play-Eintrag nur deutsch | **fünfsprachig**, seit langem |
| Store-Bilder nicht lokalisiert | **je Sprache eigene Dateien** |

Dazu zwei eigene Fehlzuschreibungen: die doppelte Kopfzeile (siehe oben) und
„die Android-Sprachwahl greift nicht" — was sich als **richtiger Entwurf**
herausstellte, weil die Sprache in einer DIS-App an den Anteil gehört und nicht
ans Gerät.

**Sechsmal Messung vor Deutung wäre billiger gewesen als sechsmal Deutung vor
Messung.** Das ist der eigentliche Kontingentposten, nicht die Denkstufe.

## Was daraus folgt

1. **Für Prüfarbeit die hohe Denkstufe nehmen.** Ein Befund, der nicht hält,
   kostet die Prüfung, die Nachmessung und im schlimmsten Fall eine Änderung,
   die etwas Richtiges kaputtmacht.
2. **Zwei Anbieter, nicht zwei Schreiber.** Der Gewinn kam nicht daraus, dass
   zwei Modelle gleichzeitig schrieben, sondern daraus, dass der eine prüfte,
   was der andere behauptete — über die Anbietergrenze hinweg. Zweimal hat das
   heute einen echten Fehler abgefangen, einmal in jede Richtung.
3. **Erst zählen, dann bauen.** Der häufigste Fund war nicht die fehlende
   Sache, sondern die vorhandene, die niemand nachgesehen hatte.
4. **Die Vier-Augen-Regel des Busses ist kein Formalismus.** Von 40 gemeldeten
   Befunden hätte gut ein Viertel Arbeit ausgelöst, die nichts repariert.

## Wofür sich die Denkstufe nicht lohnt

Für das Ausführen fester Abläufe — Bilder abrufen, Texte hochladen, Tests
starten, Bildschirmschnitte machen. Das ist heute alles über Werkzeuge gelaufen
und hat nichts von einem Modell gebraucht, das lange nachdenkt.
