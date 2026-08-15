# Emulatordurchlauf: die Kernfunktionen

Datum: 14.08.2026 · Emulator `sdk_gphone64_x86_64`, Android 16, Debug-Build
3.0.20 mit dem Stand von heute (neue Bereichsbilder, Avatare, korrigierte
Flächennamen).

Anlass: Bis heute wurde am Gerät vor allem der Erstkontakt geprüft. Was Aurora
ausmacht — Wege, Wechsel, Wiederfinden, Medikamente, der Chat zwischen den
Anteilen — ist am laufenden Gerät nie durchgespielt worden. 695 grüne Tests
haben am 11.08. schon einmal nichts gezeigt, was erst der Durchlauf fand.

## Warum der Emulator und nicht das Telefon

Am S24 liegen echte Daten. Beim Versuch dort zu prüfen habe ich blind getippt,
dabei vermutlich die Standortfreigabe erteilt und bin in einer fremden
Zeitachse gelandet. Der Emulator kostet nichts davon und kann mehr:

```
adb -s emulator-5554 shell pm grant com.disapp.dis_app android.permission.ACCESS_FINE_LOCATION
adb -s emulator-5554 emu geo fix <laenge> <breite>
```

Berechtigungen ohne Tippen, Standort per Befehl, Strecken ohne Laufen.

## Was geprüft wird

| | Funktion | Warum sie zählt |
|---|---|---|
| 1 | Zweites Profil anlegen | Voraussetzung für Wechsel und Chat |
| 2 | Chat zwischen Anteilen, mit Doodle und Bild | Die Funktion, die das System zusammenhält |
| 3 | Profilwechsel | Wer gerade da ist, muss ohne Umweg wechseln können |
| 4 | Ritrova: Ort und Gegenstand merken | Gegen die Lücke nach einer Dissoziation |
| 5 | Medikamente mit Erinnerung | Alarme feuerten schon einmal ins Leere |
| 6 | Wegaufzeichnung über eine gefahrene Strecke | „Wo war ich?" ist Kernnutzen |
| 7 | Zeitachse liest den Weg und die Wechsel | Der Ort, an dem beides zusammenkommt |

## Stand: alle sieben Punkte durch, sieben Funde behoben, drei offen

Die Kernfunktionen tragen — alle sieben. Was daneben lag, ist behoben und am
Gerät gegengeprüft:

| | Fund | Beleg nach dem Fix |
|---|---|---|
| 1.1 | Namen brachen im Wort | „Nachdenklich", „Sonnenbrille", „Daumen hoch" einzeilig |
| 2.1 | Malmodus blieb nach dem Senden an | Chat wieder klar, Zeichnung sichtbar |
| 2.2 | Zurück verließ den ganzen Chat | Zurück schließt nur noch die Malfläche |
| 3.1 | „zuletzt 6 minuti fa" | „zuletzt vor 56 Minuten", durchgehend deutsch |
| 5.1 | Leerer Ring in der Meldungsleiste | Chamäleon in beiden Meldungswegen |
| 5.2 | Release-Build warf das Symbol weg | `keep.xml`, am Paket nachgemessen |
| — | Finder-Knopf trug den Tagebuchtext | „+ Merken" statt „+ Eintrag" / „+ Voce" |

**5.2 ist der Fund, der ohne diesen Durchlauf live gegangen wäre.** Er stand
in keinem Test und in keiner Quelle — nur im gebauten Release-Paket.

Offen, weil es Entscheidungen sind und keine Fehler: **1.2** (Weiter-Knopf
unter der Tastatur), **2.3** (Foto ohne Vorschau, nicht löschbar) und **4.1**
(Startschirm-Karte fragt nicht nach den Kartendaten). Zu 4.1 kam beim
Gegentest ein zweiter Beleg: Der Einstellungsschirm sagt unter „Karten &
Standort" selbst, Kacheln würden „automatisch beim Betrachten
heruntergeladen" — während der Finder-Wähler dafür um Erlaubnis bittet.

## Funde

### 1. Zweites Profil anlegen

Trägt. Fünf Schritte: Einleitung, Name und Avatar, Farbe, Alter, Passwort.
Profil „Nino" angelegt, Avatar „Mit Herz" aus dem neuen Satz. In der runden
Profilfläche sitzt die Scheibe genau — der Kreishintergrund füllt sie aus,
und Nino ist neben Probe auf einen Blick zu unterscheiden. Genau dafür war er
gedacht.

**Befund 1.1 — der Avatar-Wähler bricht mitten im Wort.** „Nachdenkl-ich" und
„Sonnenbril-le". Ursache ist meine eigene Änderung von heute: die feste
Kachelbreite von 96 Pixeln ist für diese beiden Namen zu schmal. Auf dem S24
fiel es nicht auf, weil dort zwei je Reihe stehen und die Namen kürzer
wirkten; auf dem breiteren Emulator stehen drei je Reihe. Zu beheben:
Kachelbreite erhöhen, bis beide Namen einzeilig passen.

**Befund 1.2 — der Weiter-Knopf wandert unter die Tastatur.** Steht die
Tastatur, rutscht „Weiter" nach oben. Ein Tipp auf die vorherige Stelle landet
auf der Tastatur und schreibt ein Zeichen in den Namen. Bei mir wurde daraus
„Nino " mit Leerzeichen am Ende.

Die naheliegende Sorge — ein unsichtbares Leerzeichen wandert in die Datenbank
und schlägt später beim Vergleichen zu — hält nicht: `profile_creation_screen.dart:144`
speichert `.trim()`, `profile_edit_screen.dart:168` ebenso, und die
Doppelnamensprüfung in Zeile 111 vergleicht ebenfalls beschnitten. Bleibt eine
Unbequemlichkeit der Oberfläche, kein Datenfehler.

### 2. Chat mit Doodle und Bild

Trägt in der Sache. Text, Zeichnung und Foto kommen alle drei an, jede
Nachricht mit Name, Avatar, Uhrzeit und Tagestrenner. Der Malmodus zeigt
seinen Zustand ehrlich: solange nichts gemalt ist, sind Senden, Rückgängig
und Löschen grau; mit dem ersten Strich werden sie hell. Nach dem Senden ist
die Fläche wieder leer.

Drei Dinge um die Funktion herum stimmen nicht.

**Befund 2.1 — der Malmodus bleibt nach dem Senden an.** `onSend` in
`chat_screen.dart:460` setzt `_drawing` nicht zurück. Die Nachrichtenliste
liegt währenddessen auf Deckkraft 0,3 (`chat_screen.dart:443`) — man sieht
also ausgerechnet das gerade abgeschickte Bild nur verdunkelt. Der Ausstieg
existiert und ist sichtbar: der zweite Knopf der rechten Leiste wechselt
zwischen Pinsel und Hand (`doodle_canvas.dart:647`). Er muss nur gefunden
werden, während der Bildschirm dunkel ist.

**Befund 2.2 — Zurück verlässt den ganzen Chat.** Im Malmodus die
Zurück-Geste zu benutzen ist das Naheliegendste der Welt, und sie führt bis
auf den Startschirm. `chat_screen.dart` hat kein `PopScope`, das erst den
Malmodus schließt. Eine angefangene, nicht gesendete Zeichnung ist damit weg,
ohne Nachfrage.

**Befund 2.3 — das Foto geht ohne Vorschau sofort raus.** „Bild" öffnet die
Kamera, und der Auslöser schickt das Bild unmittelbar in den Chat. Keine
Bestätigung, keine Möglichkeit zu verwerfen. Zurücknehmen geht auch danach
nicht: langes Tippen auf eine Nachricht markiert sie nur als gelesen
(`chat_screen.dart:319`), und im `DataEntry` gibt es kein Löschen einzelner
Nachrichten. Für eine App, in der Anteile einander Persönliches schicken,
ist ein versehentliches Foto damit endgültig.

### 3. Profilwechsel

Trägt, und zwar gründlicher als erwartet. Die Sprache hängt am Anteil, nicht
am Gerät: als Probe ist die ganze Oberfläche italienisch, samt Datum
(„venerdì 14 agosto 2026 · di pomeriggio") und Flächennamen („Farmaci",
„Ritrova", „Radicamento"). Im Chat kippen Ninos Nachrichten von rechts nach
links, sobald Probe liest, und der Kopf zeigt den Wechsel selbst an: „⇄ Nino ›".
Wer nach einem Wechsel hochkommt, sieht also ohne Suchen, wer vorher da war.

**Befund 3.1 — die Auswahlfläche mischt zwei Sprachen in einem Satz.** Unter
Nino stand „zuletzt 6 minuti fa". Der Rahmen kommt aus
`presenceLastFront` über `AppLocalizations.of(context)`, die Zeitangabe darin
aus `formatPositionAge` (`position_age.dart:10`), und das greift auf
`AppTexts.current` zu — eine globale Referenz, die die Oberfläche beim Bauen
setzt. Zwei Sprachquellen an einer Textzeile; welche in der Globalen gerade
steht, hängt davon ab, wer zuletzt vorn war. Auf einem einsprachigen System
fällt das nie auf, in einem mehrsprachigen bei jedem Wechsel. `AppTexts` ist
für Dienste ohne `BuildContext` gedacht — hier gibt es einen.

### 4. Ritrova

Trägt vollständig, beide Reiter. Ein Ort („Bici parcheggiata") über die Karte
gesetzt: Antippen liefert GPS 51.1377/13.5882, und die Rückwärtssuche trägt
„69, Moritzburger Straße, Coswig, Meißen, Sachsen" ein — in der Liste
verkürzt auf „Moritzburger Straße 69", also das, was man beim Suchen liest.
Ein Gegenstand („Chiavi di casa") mit Aufbewahrungsort; der Platzhalter dort
zeigt genau die richtige Genauigkeit vor: „ad es. cucina, secondo cassetto".

Die Kartendaten sind nicht von selbst an. Der Wähler fragt vorher, nennt
OpenStreetMap beim Namen und sagt, dass einmal eine Verbindung nötig ist.
Genau so soll es sein — und darum fällt der nächste Befund auf.

**Befund 4.1 — die Startschirm-Karte fragt nicht.** Auf dem Startschirm liegt
die Übersichtskarte mit geladenen OSM-Kacheln, bevor irgendjemand zugestimmt
hat; dieselbe Zustimmung wird im Ritrova-Wähler ausdrücklich eingeholt.
`overview_map.dart:251` holt sich den `MapService` in ein Feld und fragt ihn
danach **kein einziges Mal** — der Verweis ist tot, `areTilesDownloaded` wird
nur in `map_picker.dart` und `map_view.dart` geprüft. Ein Kachelabruf sagt
OpenStreetMap die IP und den Ausschnitt, also ungefähr den Aufenthaltsort.
Das steht so im Play-Eintrag und ist kein verstecktes Senden; es ist aber
eine Entscheidung, die die App an einer Stelle einholt und an der anderen
übergeht. Zwei mögliche Wege: die Übersichtskarte an dieselbe Zustimmung
binden, oder — falls sie als Grundfunktion gelten soll — die Abfrage im
Finder streichen, damit nicht zwei verschiedene Versprechen nebeneinander
stehen. Das ist eine Produktentscheidung, kein Fehler mit einer richtigen
Lösung.

**Randnotiz.** Der Knopf zum Anlegen heißt auf Italienisch „+ Voce". Als
Wort für einen Listeneintrag ist das richtig, aber „voce" heißt auch
„Stimme", und der Knopf steht in einer App, die Sprachnachrichten kann. Auf
dem Reiter „Luoghi" wäre „+ Luogo" eindeutig, der Hinweistext darüber sagt
selbst „Tocca + per aggiungere un luogo".

### 5. Medikamente

Trägt, und der wichtigste Teil davon ist zum ersten Mal am laufenden Gerät
belegt: **die Erinnerung feuert wirklich.** „Sertralina, 1 compressa, 50 mg"
auf 14:44 gelegt, App in den Hintergrund, gewartet. Um 14:44 stand die
Meldung oben in der Leiste, nicht im stillen Teil:

```
Aurora • now
Assumere il farmaco adesso!
Sertralina - 1 compressa, 50 mg assumere ora
```

`dumpsys` zeigt sie als `pkg=com.disapp.dis_app channel=aurora_notifications
importance=4`, und 58 Alarme sind über den
`ScheduledNotificationReceiver` registriert. Das ist der Empfänger, der im
Juni gefehlt hat und die Alarme lautlos ins Leere laufen ließ. Er ist da und
er trägt.

Bemerkenswert daran: die Meldung kam auf Italienisch. Der Wortlaut wird
geplant, wenn der Anteil ihn anlegt, und ein Dienst ohne `BuildContext`
schreibt ihn — genau dafür gibt es `AppTexts`. Hier funktioniert die
Konstruktion; in Befund 3.1 stolpert sie.

Das Formular selbst ist auf der Höhe der Oberflächenregeln: die Einnahmezeit
wird über vier Kacheln mit Sonne, Mittagssonne, Mond und Bett gewählt, nicht
über eine Liste; nach dem Speichern stehen unter dem Medikament drei
farbgetrennte Knöpfe — grün „Preso", rot „Rifiutato", gelb „Più tardi".

**Befund 5.2 — der Release-Build warf das neue Symbol wieder weg.** Gefunden
beim Nachprüfen des Fixes zu 5.1, und zwar nur, weil das gebaute Paket
angesehen wurde statt der Quelle:

```
aapt2 dump resources app-debug.apk   | grep -c ic_notification   →  6
aapt2 dump resources app-release.apk | grep -c ic_notification   →  0
```

`ic_notification` wird ausschließlich aus Dart heraus benannt — als
Zeichenkette in `notification_service.dart`, als `AndroidResource` in
`gps_manager.dart`. Der Resource-Shrinker liest Dart nicht; er sah eine
Zeichnung, auf die im Android-Teil niemand zeigt, und entfernte sie.
`ic_launcher`, das im Manifest steht, blieb erwartungsgemäß drin.

Das wäre nicht bloß ein fehlendes Bild geblieben:
`flutter_local_notifications` löst das Symbol beim Einrichten auf. Fehlt es,
steht die Einrichtung — und mit ihr jede Erinnerung. Dieselbe Bauart hat den
Rückkanal schon einmal acht Monate lang lautlos totgelegt.

Behoben mit `android/app/src/main/res/raw/keep.xml`. Am neu gebauten
Release-Paket nachgeprüft: alle fünf Auflösungsstufen sind wieder da (die
Dateinamen sind dort verschleiert, `res/hQ.png` statt
`drawable-mdpi/ic_notification.png` — deshalb zählt derselbe Grep im Release
anders).

**Befund 5.1 — Aurora ist in der Meldungsleiste nicht zu erkennen.** Neben
der Erinnerung steht ein leerer weißer Ring. Ursache:
`notification_service.dart:245` gibt `@mipmap/ic_launcher` als Meldungssymbol
an. Android benutzt bei Meldungssymbolen nur den Alphakanal und färbt alles
Übrige weiß — ein volldeckendes, buntes Startsymbol wird dabei zwangsläufig
zum Klecks, hier zum Umriss des runden Rahmens. Ein eigenes
`drawable/ic_notification` gibt es nicht; im `res`-Ordner liegen nur
`ic_launcher_foreground` und `launch_background`. Zu beheben mit einer
einfarbigen Silhouette — der Chamäleon-Umriss reicht — auf die diese Zeile
dann zeigt. Wer drei Meldungen übereinander hat, sieht sonst nicht, welche
von Aurora kommt.

**Beobachtung.** „Un altro orario" legt keine fünfte Zeit an, sondern
schreibt die gewählte in die nächstliegende der vier Kacheln: 14:44 landete
unter „A mezzogiorno", samt Mittagssonne. Die Zeit stimmt, die Beschriftung
darüber nicht mehr. Ob das stört, hängt davon ab, wie weit die eigene Zeit
von der Vorgabe abliegt — bei 14:44 unter „mittags" ist es noch tragbar,
bei 03:00 unter „abends" nicht mehr.

### 6. Wegaufzeichnung

Der Dienst läuft und schreibt. Eingeschaltet über „Tracciamento sempre
attivo"; der Bestätigungsdialog davor nennt, was die Betriebsart tut, dass
die Daten auf dem Gerät bleiben, dass der Akku mehr zieht, und zeigt den
Android-Status. `dumpsys` bestätigt den Vordergrunddienst:

```
GeolocatorLocationService  isForeground=true  types=0x00000008
foregroundNoti=Notification(channel=geolocator_channel_01 ... NO_CLEAR|FOREGROUND_SERVICE)
```

Die Dauermeldung ist eigener Text, kein Plugin-Standard, und steht in der
Sprache des Anteils: „Aurora ricorda il tuo percorso — Così potrai ritrovare
i tuoi luoghi. Resta sul dispositivo." Genau das, was der Schirm vorher
zugesagt hat: ohne Meldung keine Aufzeichnung.

Eine Fahrt über sieben Punkte simuliert (13.5789/51.1319 nach
13.5950/51.1400, alle 45 Sekunden ein Punkt). Nach dem Neustart stand auf
dem Startschirm der Endpunkt der Strecke — „Förderzentrum Peter Rosegger"
statt der Anfangsadresse. Die Kette Standort → Speicher → Karte trägt also.

### 7. Zeitachse

Trägt, und hier kommt zusammen, wofür die App gebaut ist. Die Karte oben
zeichnet den gefahrenen Weg als durchgehende Linie vom Startpunkt („vor einer
Stunde") bis zur aktuellen Stelle, mit der gemerkten Ortsmarke „Bici
parcheggiata" daneben. Darunter sieben Einträge in einer Liste, farblich nach
Anteil getrennt:

```
Nino aktiv       App gestartet                   15:51
Nino aktiv       App gestartet                   15:26
Probe            Förderzentrum Peter Rosegger    14:56
Probe            Fichtestraße 1a                 14:51
Nino → Probe     Profil gewechselt               14:28
Probe → Nino     Profil gewechselt               14:20
Probe            Fichtestraße 1a                 14:05
```

Die Wechsel tragen beide Avatare nebeneinander — wer nach einem Zeitverlust
hochkommt, sieht ohne Lesen, wer abgelöst hat. Standorte, Wechsel und
App-Starts stehen in derselben Achse; genau das war die Absicht.

Die Standorte sind zusammengefasst: sieben gesetzte Punkte ergaben drei
Einträge, während die Linie auf der Karte durchgehend ist. Die Liste zeigt
also Aufenthalte, nicht Messpunkte. Für „wo war ich?" ist das die richtige
Verdichtung.

## Stand des Emulators

- Profil „Probe", 25 Jahre, seit heute auf Italienisch gestellt
- Standort gesetzt auf 13.5789 / 51.1319 (Coswig bei Dresden)
- Standortrecht erteilt, Wegaufzeichnung noch nicht eingeschaltet
