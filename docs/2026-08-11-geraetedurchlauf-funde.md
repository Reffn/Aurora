# Gerätedurchlauf 11.08.2026 — Befunde

Samsung S24 (1080×2340, ×3.0), Release-APK aus `e0c2846`, per
`adb install -r` über die laufende Fassung installiert. Alle vierzehn
Flächen geöffnet, kein Absturz, kein ANR.

**Stand:** Die erste Kachelreihe auf dem Anker ist behoben (`e0c2846`),
Befund 1 und 2 ebenfalls (`5cc3159`). Befund 4 war ein Messfehler und ist
zurückgenommen. Befund 5 ist behoben und am Gerät nachgewiesen
(`8dcb68d`). **Offen bleibt allein Befund 3** — die feste Zahl im
Kopfblock des Ankers.

---

## 1. Der Chat zeigt kein Datum — behoben in `5cc3159`

`chat_message_bubble.dart:43` formatiert mit `DateFormat('HH:mm')`. Sonst
steht an keiner Blase ein Tag, und es gibt keinen Tagestrenner.

Am Gerät sah das so aus: „Hallo Testa · 22:07" über „Testnachricht ·
13:50". Die obere Nachricht ist von **gestern**, die untere von heute —
zu sehen ist das nirgends. Ich selbst habe daraus zuerst einen
Sortierfehler gelesen, und ich hatte die Kiste vor mir.

Das wiegt in dieser App schwerer als anderswo. Die ganze Ankerfläche ist
um „wann bin ich" herum gebaut, weil Zeitverlust zum Krankheitsbild
gehört — der Kommentar dazu steht in `main.dart` über der Zeitkarte. Der
Chat ist der Ort, an dem Anteile einander Nachrichten hinterlassen, und
ausgerechnet dort fehlt der Tag.

Der Rest der App kann es: Kalender zeigt „Heute · Dienstag, 11. August
2026", die Zeitachse „Heute, 22:36 Uhr". Der Chat ist der Ausreißer.

**Vorschlag:** Tagestrenner zwischen den Gruppen („Heute", „Gestern",
sonst das ausgeschriebene Datum). Ein Datum an jeder einzelnen Blase
wäre Lärm; der Trenner beantwortet dieselbe Frage einmal pro Tag.

### Die stille Schwester dieses Befunds

Die Reihenfolge im Verlauf hängt an der **Einfügereihenfolge der
Hive-Kiste**, nicht am Zeitstempel: `chat_service.dart:37` gibt
`_messageBox.values` unsortiert zurück, `_handleMessageCreated` hängt mit
`add` an. Solange nur laufend geschrieben wird, stimmt das Ergebnis. Es
kippt lautlos, sobald etwas nachgetragen, importiert oder
wiederhergestellt wird — und ohne Datum an der Blase sieht das dann
niemand.

---

## 2. Feedback-Kategorien stehen auf Englisch — behoben in `5cc3159`

`feedback_category.dart:8` liefert fest verdrahtet „Bug Report",
„Feature Request", „Allgemeines Feedback". Auf einer deutschen
Oberfläche stehen damit zwei von drei Wahlmöglichkeiten in einer
Fremdsprache, und es sind Fachwörter — genau das, was die
Zielgruppen-Leitlinien (W3C COGA, `docs/oberflaechen-richtlinien.md`)
ausschließen. In den anderen vier Sprachen steht dasselbe Englisch.

Dazu ein zweiter Punkt, der die Lösung bestimmt: dasselbe `displayName`
geht als `category` in die Übertragung (`feedback_screen.dart:431`).
Würde man es einfach übersetzen, käme Feedback aus Frankreich mit
französischer Kategorie an, und die Auswertung zerfiele nach Sprache.

**Vorschlag:** Die beiden Rollen trennen. Ein stabiler Wert für die
Leitung (`bug_report`, `feature_request`, `general`), unabhängig von der
Sprache, und ein Beschriftungstext aus dem l10n-Bestand für die Anzeige.
Die drei bestehenden Firestore-Dokumente sind eigene Testläufe, es geht
kein Bestand verloren.

---

## 3. `_bannerNebenDerZeitkarte` bleibt zerbrechlich

`main.dart:901` steht eine feste `60` für alles, was neben der Zeitkarte
im Kopfblock des Ankers liegt. Wer dort ein Element ergänzt, ändert die
Höhe und nicht die Zahl — dann fällt die erste Kachelreihe aus dem Bild.

Genau das ist heute zum vierten Mal passiert. `e0c2846` hat die Instanz
behoben, indem das hinzugekommene Element wieder verschwand. Die Bauform
steht unverändert.

Der vorhandene Test (`anchor_erste_reihe_test.dart`) kann das nicht
sehen: Er pumpt einen erfundenen Banner und prüft damit, ob die Fläche
ein Versprechen einhält, das der Test selbst gibt. Die fünfte
Wiederholung wird er genauso wenig bemerken wie die vierte.

**Vorschlag:** Die Zeitkarte ihre Höhe aus der eingehenden Beschränkung
lesen lassen, statt sie ihr auszurechnen — dann schrumpft sie
automatisch, wenn daneben etwas dazukommt. Voraussetzung dafür ist ein
Test, der die **echte** Zusammensetzung des Banners pumpt; dafür müsste
sie aus `main.dart` heraus in ein eigenes Widget wandern.

Achtung bei der Umsetzung: Ohne Standortberechtigung misst sich die
Zeitkarte selbst (Kopfstrang + Hinweisband, keine Kartenfläche). In
diesem Zustand gibt es nichts zu schrumpfen — ein harter Deckel würde
dort das unterste Element abschneiden.

---

## 4. ~~Verdeckte Felder nehmen jeden Anschlag dreifach~~ — **war ein Messfehler**

Hier stand ein Befund, den es nicht gibt. Er ist am 12.08. widerlegt und
bleibt als Warnung vor der Messmethode stehen.

**Was ich gemessen hatte:** Ein Tastendruck ins Passwortfeld, danach meldete
`uiautomator dump` drei Zeichen. Aus acht getippten Zeichen wurden 24. Das
Namensfeld daneben blieb sauber, Autofill schied als Ursache aus — die
Beweiskette wirkte geschlossen.

**Was tatsächlich passiert:** Der Bedienbaum meldet die Länge eines
*verdeckten* Feldes falsch, solange es den Fokus hat. Der Nachweis war ein
Griff auf den Auge-Schalter: Mit sichtbarem Text steht im Feld `'a'` — ein
Zeichen, genau das getippte. Unfokussiert meldet der Baum ebenfalls eines.

**Die Lehre gilt weiter, nur umgekehrt:** Ich habe einer Messung geglaubt,
statt sie gegen eine zweite zu halten. Drei Bestätigungen derselben Methode
sind keine drei Belege — sie sind derselbe Beleg dreimal. Bei verdeckten
Feldern ist der Bedienbaum keine Quelle für Inhalt; sichtbar schalten oder
den Fokus wegnehmen.

Aus demselben Irrtum stammte die Behauptung, der Fehler verhindere seinen
eigenen Reproduktionsaufbau. Auch die ist hinfällig: Ein Passwort ließ sich
die ganze Zeit setzen.

## 5. Im Passwort-Reset lässt sich nichts eintippen — **behoben**

**Nachgewiesen am 12.08.2026 am S24**, mit einem Profil, dem eigens ein
Passwort gesetzt wurde:

| | vorher (A14, 3.0.19) | nachher (S24, `8dcb68d`) |
|---|---|---|
| `EditText` im Dialog | **0** | **2** |
| Tastatur beim Griff | `mInputShown=false` | `mInputShown=true` |
| Eingabe | unmöglich | neun Zeichen angekommen |

Behoben hat es die Umstellung auf `AuroraTextField` (`8146e0e`) — **ohne
dass die Ursache je gefunden wurde.** Das ist ein schwacher Beweis: Es
funktioniert, aber niemand kann sagen, warum es vorher nicht ging. Sollte
es wiederkommen, ist der Unterschied zwischen alter und neuer Fassung der
erste Ort zum Nachsehen; der alte Aufbau steht in der Historie von
`profile_actions_dialog.dart`.

Der Reset wurde bei der Probe **nicht** gestartet, nur der Dialog geöffnet
und wieder abgebrochen.

---

## 5a. Der ursprüngliche Befund (zur Nachvollziehbarkeit)

Am 12.08. am A14 (Store-Fassung 3.0.19) gemeldet und nachgestellt:

- Berührungen erreichen den Dialog — „Abbrechen" schließt ihn.
- Die beiden Passwortfelder nehmen keinen Fokus (`mServedView=null`,
  `mInputShown=false`), und im Bedienbaum stehen 24 Knoten **ohne ein
  einziges `EditText`**. Gezeichnet werden sie, für das System gibt es sie
  nicht.
- Die Anmelde-Abfrage unmittelbar dahinter hat ein `EditText`. Es liegt
  also nicht am Gerät und nicht an einer Überlagerung (nur Systemfenster im
  Stapel), sondern an diesem Dialog.
- In der Testumgebung ist das Widget gesund: `isTextField, hasEnabledState,
  isEnabled, isObscured, isFocusable`, Beschriftung „Passwort eingeben".
  **Die Testumgebung stellt den Fehler nicht nach.**

Der Dialog ist seit `8146e0e` auf `AuroraTextField` umgestellt; ob das
genügt, ist **ungeprüft**.

**Achtung bei der Probe:** Der Bedienbaum meldet verdeckte Felder falsch,
solange sie den Fokus haben (siehe Befund 4). Für „nimmt das Feld Eingaben
an?" ist deshalb nicht die gemeldete Länge maßgeblich, sondern
`mServedView`/`mInputShown` aus `dumpsys input_method` — oder der
Auge-Schalter, der den Text sichtbar macht.

## Was in Ordnung war

Chat, Kalender, Medikamente, Tagebuch, Kontakte, Finder, Spiele,
Zeitachse, Halt, Hilfe, Feedback, Einstellungen, Transparenzfläche,
Profilauswahl. Dazu:

- **Kaltstart:** Eine Sekunde nach `am start` ist der Ladebildschirm
  schon durch. Der schwarze Schirm mit weißem Text taucht nicht mehr auf.
- **Aktualisierung über die laufende Fassung:** kein Absturz nach
  `install -r` und Neustart — das ist der Weg, auf dem R8 einmal die
  Signaturen weggeworfen hat.
- **Erste Kachelreihe:** trägt Bild und Wort, mit und ohne
  Standortberechtigung. Die zweite Reihe lugt an und zeigt damit selbst,
  dass die Liste weitergeht.
- **Berechtigungswiderruf:** kommt in der Oberfläche an; nach `pm revoke`
  steht in den Einstellungen „Berechtigung verweigert".
- **Zurück auf dem Anker** fragt „App beenden?" statt still zu schließen.
- **Transparenzprotokoll:** jede Fläche, die ich geöffnet habe, steht
  darin mit Zeitpunkt und „Angekommen" — 22:42, 22:45, 22:59.

Nicht geöffnet: die Notfall-Fläche. Sie löst echte Handlungen aus.
