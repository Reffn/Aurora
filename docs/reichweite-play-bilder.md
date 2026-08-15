# Reichweite: die Bilder im Play-Eintrag

Datum: 13.08.2026 · Über die Play Developer API gelesen und heruntergeladen.
Nichts geändert — Bilder sind Gestaltung, und die gehört nicht nebenbei
umgeworfen.

Auf Play entscheidet der erste Bildschirmschnitt darüber, ob der Text überhaupt
gelesen wird. Er steht direkt unter dem Titel, ist das größte Element, und die
meisten Menschen wischen genau einmal.

## Was schon da ist

**Die Bildschirmschnitte sind je Sprache eigene Dateien** — de, en, es, fr, it
haben jeweils vier eigene. Auch das war schon gemacht.

**Die Feature-Grafik trägt keinen Text**, deshalb schadet es nicht, dass sie nur
unter `de-DE` hinterlegt ist: die anderen Sprachen erben sie, und es gibt nichts
zu übersetzen.

## Befund 1: Der erste Schnitt zeigt das Einstellungsmenü

Bild 1 in allen Sprachen ist **„Was Aurora sendet"** — das Übertragungsprotokoll
aus den Einstellungen. Zu sehen sind: eine Überschrift, drei Absätze Fließtext,
ein Schalter, ein Datum vom 05.08.2026 und der Satz **„Es wurde noch nichts
gesendet."**

Das ist die beste Idee der App, aber es ist das falsche erste Bild. Niemand
installiert eine App wegen ihres Telemetrie-Protokolls. Menschen installieren
sie, weil sie an einem schlechten Tag hilft.

Wer auf Play vorbeiscrollt, sieht: eine dunkle Fläche voller Absätze über
Datenübertragung. Nichts über DIS, nichts über Systeme, nichts über Halt.

**Bild 2 wäre das richtige Bild 1.** Es zeigt „Halt": „Hier und Jetzt" als große
Wahlfläche, darunter vier farbcodierte Wege — Sehen/hören/spüren, Körper spüren,
Wegschließen, Atem. Jede mit eigenem Symbol, eigener Farbe, eigenem Rahmen. Das
ist die App an ihrer stärksten Stelle, und es ist ohne ein Wort verständlich.

## Befund 2: „Testprofil" steht im öffentlichen Schaufenster

Im Kopf von Bild 2 steht neben dem Avatar **„Testprofil"**. Das ist seit
Wochen im Store zu sehen.

Es ist eine Kleinigkeit und es ist genau die Sorte Kleinigkeit, die
Professionalität kostet: wer „Testprofil" liest, denkt nicht „sorgfältig
gebaut".

## Befund 3: Ein Satelliten-Symbol im Schaufenster einer Datenschutz-App

Oben rechts in Bild 2 sitzt ein grünes Satelliten-/GPS-Symbol. Es zeigt an,
dass die Standortaufzeichnung läuft — im laufenden Betrieb richtig und wichtig.

Im Store ist es das erste, was ein datenschutzsensibler Mensch sieht, und es
sagt das Gegenteil dessen, was der Text daneben verspricht. Die Zielgruppe ist
überdurchschnittlich wachsam bei genau diesem Symbol.

## Befund 4: Kein einziger Schnitt trägt eine Bildunterschrift

Alle vier sind rohe Bildschirmabzüge — kein Rahmen, keine Kopfzeile, kein Satz.
Übliche Store-Schnitte tragen eine kurze Zeile über dem Bild („Halt in fünf
Schritten", „Jeder Anteil, ein Profil"), weil die meisten Menschen die Bilder
ansehen und den Text nicht.

Aurora hat den Text jetzt in Ordnung. Die Bilder erzählen ihn nicht mit.

## Befund 5: Vier von acht Plätzen genutzt

Play erlaubt acht Telefon-Schnitte. Belegt sind vier. Der Eintrag beschreibt
elf Bereiche — Anker, Halt, Notfall, Hilfe, Profile, Chat, Kalender,
Medikamente, Tagebuch, Finder, Zeitstrahl — und zeigt vier.

## Zur Feature-Grafik

Kein Text, siehe oben — das ist in Ordnung. Drei andere Dinge fallen auf:

- **Weißer Grund**, während die App durchgehend dunkel ist. Das Schaufenster
  verspricht eine helle App.
- **Blau-Violett-Türkis**, während das Symbol der App ein Regenbogen ist. Zwei
  Farbwelten für dasselbe Tier.
- **Der Schwanz ist unten abgeschnitten.** Bei 1024×500 sitzt das Tier
  angeschnitten am unteren Rand; das liest sich als Versehen, nicht als Absicht.

## Vorschlag, in dieser Reihenfolge

1. **Reihenfolge tauschen** — „Halt" nach vorn, „Was Aurora sendet" nach hinten.
   Kostet nichts, kein neues Bild, sofort wirksam.
2. **Neue Abzüge ohne „Testprofil" und ohne laufende Standortaufzeichnung.**
   Der Emulator läuft und kann das liefern.
3. **Bildunterschriften** in allen fünf Sprachen — die Sätze stehen bereits im
   neuen Store-Text.
4. **Auf acht auffüllen**: Anker, Halt, Profilauswahl, Chat, Kalender,
   Medikamente, Finder, Zeitstrahl.
5. **Feature-Grafik** neu, mit dem Regenbogen-Chamäleon, vollständig im Bild,
   auf dunklem Grund. Dafür gibt es die Blender-Strecke bereits.

Punkt 1 ist ein Tausch von zwei Bildern und kann heute passieren. Punkt 5 ist
Gestaltungsarbeit und gehört nicht nebenbei entschieden.
