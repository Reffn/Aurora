# Gerätedurchlauf 3.0.16 auf dem S24

**Datum:** 8. August 2026
**Gerät:** Samsung S24 (R3CX10FH1RP), Android 15, Systemsprache Italienisch
**Build:** 3.0.16+16, Release-APK, frische Installation (Vorgängerinstallation
mit abweichendem Schlüssel wurde nach Rückfrage entfernt)
**Profil:** „Testa", 25 Jahre, Katzen-Avatar, kein Passwort, Telemetrie
abgelehnt, Standort zweimal abgelehnt, Benachrichtigungen erlaubt

## Was belegt ist

**Die Berechtigungsumstellung trägt.** Im installierten Paket steht nur noch
`SCHEDULE_EXACT_ALARM`; `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO` und
`USE_EXACT_ALARM` sind weg. „Aus der Galerie wählen" öffnet
`com.google.android.photopicker` **ohne jeden Berechtigungsdialog**, mit
Googles eigenem Hinweis „Aurora will only have access to the photos and videos
that you select".

**Die Erinnerungen kommen im System an.** Das Anlegen des Medikaments bringt
**genau vier** neue Einträge in den Alarmspeicher — die vier angekündigten
Meldungen (30 min vorher, 10 min vorher, zur Zeit, 10 min später), alle als
`RTC_WAKEUP` mit `tag=*walarm*` über `ScheduledNotificationReceiver`. Alle drei
Empfänger sind im Release-Manifest registriert.

Zur Zählweise: `dumpsys alarm | grep -c` über die **ganze** Ausgabe zählt
Historie und Statistik mit und liefert dreistellig zu hohe Zahlen (hier 30 vor
und 34 nach dem Anlegen). Gezählt gehört nur der Bereich der anstehenden
Batches, zwischen „Next alarm clock information" und „LazyAlarmStore stats";
dort stehen für Aurora sechs Einträge — die vier neuen plus zwei, die schon
vorher da waren.

**Die Freigabe für genaue Alarme wird an der richtigen Stelle erfragt.** Beim
Anlegen eines Medikaments mit Erinnerung öffnet Aurora erst den
Benachrichtigungs-Dialog, dann den Systembildschirm „Alarms and reminders".
Genau der Weg, den `USE_EXACT_ALARM` ersetzt hätte.

**Der Doodle-Umbau greift.** Im Blättermodus steht rechts nur ein Pinsel; erst
beim Antippen erscheinen die sechs Werkzeuge und die Farbreihe.

## B1 — Bildwahl über das Bottom-Sheet kommt nie an

**Schwere: hoch.** Kein Absturz, keine Meldung, kein Bild.

Im Profil-Assistenten „Aus der Galerie wählen" → Photo-Picker öffnet → Bild
ausgewählt → zurück in Aurora → der Avatar zeigt weiter das Namenskürzel. Im
Log steht nichts.

**Ursache:** `image_picker_bottom_sheet.dart:252` (`_onGalleryPressed`, analog
`_onCameraPressed`) schließt das Sheet mit `Navigator.pop(context)` und reicht
**denselben** Context an `ImagePickerHandler.pickFromGallery`. Nach der
Rückkehr aus dem Picker ist dieser Context nicht mehr `mounted`, und
`image_picker_handler.dart:600` (`if (image != null && context.mounted)`)
überspringt `_handleImageSave` — der `else if (image == null)`-Zweig greift
ebenfalls nicht, also passiert schlicht nichts.

**Belegt, dass es der Context ist und nicht die Berechtigung:**
- Tier-Avatar (kein externer Picker, Context lebt) kommt an
- Tabletten-Foto im Medikamenten-Formular (direkter Aufruf, ohne Sheet) kommt an

**Betroffen sind alle vier Aufrufstellen des Sheets** — Profil
(`profile_identity_section.dart:60`), Kontakte
(`contact_form_screen.dart:284`), Finder (`finder_form_screen.dart:320`) —
und dort jeweils Kamera **und** Galerie.

## B2 — Standort wird ungefragt und wiederholt verlangt

**Schwere: hoch**, sowohl fürs Vertrauen als auch für die nächste
Play-Prüfung.

Direkt nach dem Anlegen des ersten Profils, noch auf der Profilwahl, fragt
Aurora nach dem Gerätestandort — bevor jemand eine Karte geöffnet hat. Nach
„Don't allow" kommt derselbe Dialog beim Betreten des Profils **erneut**.

Dazu liegen drei Aufforderungen zur selben Sache übereinander und
überschreiben sich gegenseitig: die Kartenfläche („GPS-Berechtigung
erforderlich" mit dem Knopf „Berechtigung erteilen") und darüber die Zeile
„Aurora braucht den Standort für diese Karte. Er bleibt auf dem Gerät.
[Erlauben]". Der Text der einen läuft mitten durch den Knopf der anderen.

Anmerkung fürs Release: `ACCESS_BACKGROUND_LOCATION` steht im Manifest. Das
ist bei Play eine eigens zu deklarierende Berechtigung.

## Stand vom 9. August 2026: B3 bis B11 abgearbeitet

Alles darunter ist der Befundstand vom 8. August. Was inzwischen behoben ist,
trägt einen Vermerk. Offen bleiben **B12** (blockiert, siehe dort) und die
Punkte unter „Kleineres".

Nachgemessen wurde mit einem Release-Build über die vorhandene Installation —
ein Debug-Build hätte eine Deinstallation und damit den Verlust der Daten
verlangt.

## B3 — Das Tabletten-Foto wird nirgends gezeigt — **behoben**

Das Foto wird gespeichert (es steht beim Bearbeiten wieder da), erscheint aber
weder in der Tagesliste noch auf der Detailseite; dort steht das
Namenskürzel. Die Begründung im Formular lautet „Foto hilft bei der
Identifikation und vermeidet Verwechslungen" — genau dort, wo das gelten
müsste, ist es nicht zu sehen.

*Behoben am 09.08.:* Das Formular legte einen **absoluten** Pfad in der
Datenbank ab. Die Anzeige setzt relative Namen hinter den Anhang-Ordner, also
wurde daraus `attachments//data/…` — nichts. Gefunden hat das Bild nur das
Formular selbst, weil es die Datei direkt öffnet. Drei Teile: Das Formular
speichert über `AttachmentHelper` und legt den relativen Namen ab; `fileSync`
gibt einen absoluten Pfad unverändert zurück und holt damit die schon
gespeicherten Bilder wieder her; `MedicationAvatar` zeichnet das Foto über die
ganze Pille, statt es als Kreis von Höhe mal Höhe darin liegen zu lassen.
Fünf Tests.

## B4 — Das Telemetrie-Beispiel liegt unter der Falz — **behoben**

Auf der Consent-Fläche steht „So sieht eine Meldung aus:" — das Beispiel
selbst ist erst nach dem Scrollen sichtbar, während beide Knöpfe („Ja, gerne",
„Weiter ohne") ohne Scrollen erreichbar sind. Man kann zustimmen, ohne je
gesehen zu haben, wozu.

Das Beispiel nennt außerdem **App-Version 3.2.0** und den festen Tag
2026-08-05. Die App ist 3.0.16.

*Behoben am 09.08.:* Ereignisname und Tagesformat kommen jetzt aus dem Schema,
die Version aus dem `TelemetryRecorder` — also aus derselben Quelle wie der
echte Versand. Was dort driftet, driftet hier mit. Das Beispiel steht außerdem
**vor** der Erklärung: Die Erklärung ist Prosa, das Beispiel ist die Sache
selbst. Das Symbol schrumpfte von 72 auf 56, damit es nichts nachschiebt. Ein
Test misst gegen die Schirmgröße des S24, dass das Beispiel über den Knöpfen
liegt.

## B5 — Knopftext ragt über die Knopfkante — **behoben**

Im Profil-Onboarding („Weiter →", „Los geht's! →") steht der Text links und
rechts über die Fläche des Knopfes hinaus. Beim App-Onboarding, das dieselben
Worte über die volle Breite legt, tritt es nicht auf.

*Behoben am 09.08.:* Dem Verlaufs-Container fehlte `width: double.infinity`,
also schrumpfte er auf die Eigengröße des Knopfes — und
`EdgeInsets.symmetric(vertical: 16)` lässt waagerecht null. Beides angeglichen
an das Pre-Onboarding, wo dasselbe Wort korrekt steht.

## B6 — „Nicht mehr anzeigen" überlagert die Überschrift — **behoben**

Auf der ersten Onboarding-Seite liegt „Nicht mehr anzeigen" auf „Willkommen
bei". Ab Seite zwei nicht mehr, weil dort keine Überschrift so weit oben
steht.

*Behoben am 09.08.:* Der Ausgang lag als `Positioned` über dem Inhalt — der
Fehler steckte im Rahmen, nicht auf der Seite. Er steht jetzt in einer eigenen
Zeile darüber. Das kostet Höhe auf jeder Seite und ist der richtige Tausch:
gleiche Stelle auf allen Seiten (Richtlinie 7), und nichts wird verdeckt
(Turk & Hutchings, CHI 2023). Drei Tests, einer auf S24-Maßen.

## B7 — „Hilfe" liegt unter der Systemleiste — **war keiner**

Auf der Ankerfläche wird die unterste Karte von der Navigationsleiste
überdeckt. Betrifft ausgerechnet die Karte „Hilfe".

*Am 09.08. nachgemessen — der Befund war falsch.* „Hilfe" ist die dritte von
zwölf Zeilen, nicht die unterste; angeschaut wurde der ungescrollte Zustand,
und dort liegt die nächste Zeile naturgemäß unter der Kante. Ans Ende
gescrollt endet die unterste Karte („Feedback") deutlich über der Leiste. Der
Abstand dafür steht seit Längerem im Code — nur konnte ihn kein Test zeigen,
weil die Standard-Testfläche gar keine Systemleiste hat. Der Test misst jetzt
gegen die Maße des S24.

## B8 — Wortwahl auf der Profilwahl — **behoben**

Der Einstiegsknopf heißt „Profil wechseln", auch wenn man noch in keinem
Profil war. Und „Wie die App" als Bezeichnung für die Sprachwahl erschließt
sich nicht.

*Behoben am 09.08.:* „Weiter als Mina" — stimmt in beiden Fällen und sagt
zugleich, wohin man geht. Aus „Wie die App" wurde „Sprache der App". Fünf
Sprachen, am Gerät im Dialog bestätigt.

## B9 — Die Warteschlange zeigt 0, obwohl sechs Alarme stehen — **behoben**

Einstellungen → Benachrichtigungen → „Warteschlange · Geplante
Benachrichtigungen: **0**". Zur selben Zeit lagen sechs Einträge für Aurora im
Alarmspeicher, vier davon frisch vom angelegten Medikament.

Die Warteschlange wurde in `70a95da` als leere Kopie entfernt — die Anzeige in
den Einstellungen ist mitgegangen, aber nicht mit. Wer dort nachsieht, ob seine
Erinnerung sitzt, bekommt die falsche Antwort, und zwar die beunruhigende.
Entweder zählt die Anzeige den echten Alarmspeicher, oder sie muss weg.

*Behoben:* Sie fragt jetzt das Betriebssystem (`pendingNotificationRequests`)
statt die eigene Notiz. Die Zeile „nächste um …" ist entfallen — das System
gibt keinen Zeitpunkt zurück, und eine Zeit zu zeigen, die wir nicht kennen,
wäre genau die Art Zusage, um die es bei dem Umbau ging.

## B10 — Auf der Notfall-Fläche ist die GPS-Bitte das Auffälligste — **behoben**

Notfall öffnet mit einem orange umrandeten Block „GPS-Berechtigung
erforderlich" samt vollflächig orangem Knopf „Berechtigung erteilen". Erst
darunter kommt „Noch keine Notfallkontakte". Auf der Fläche, die im
schlechtesten Zustand tragen muss, führt der Blick zuerst auf eine
Berechtigungsfrage.

*Behoben am 09.08. an der Quelle, nicht auf der Fläche:* Richtlinie 4
reserviert gesättigte Farbe für das, was im schlechtesten Zustand gefunden
werden muss — eine Berechtigungsfrage ist das auf keinem Schirm. Das Band der
Karte ist ruhig, der Knopf umrissen statt vollflächig. Das Angebot bleibt mit
einem Griff erreichbar (Richtlinie 9). Orange bleibt allein an der Zeile, wie
alt eine gespeicherte Position ist — die einzige echte Warnung in dem Block.

## B11 — Die globalen Einstellungen beginnen mit Hintergrund-Tracking — **behoben**

Erster Block unter „Globale Einstellungen": „Was ist ‚Tracking dauerhaft an'?"
mit den Punkten „Die Position wird dauerhaft erfasst", „Funktioniert auch im
Hintergrund", „Alle Profile werden automatisch aufgezeichnet" — dazu eine
dreischrittige Anleitung zur Android-Berechtigung „Immer erlauben" und ein
blauer Knopf „Android-Einstellungen öffnen".

Das erklärt `ACCESS_BACKGROUND_LOCATION` im Manifest. Für die nächste
Einreichung heißt das: Hintergrund-Standort ist bei Play eine eigens zu
deklarierende Berechtigung, mit Begründung und Demo-Video. Zusammen mit B2
(ungefragte, wiederholte Standortabfrage) ist das der nächste
Ablehnungsvektor — dasselbe Muster wie bei `USE_EXACT_ALARM`.

*Behoben:* Mit dem Vordergrunddienst ist `ACCESS_BACKGROUND_LOCATION` aus dem
Manifest, und die dreischrittige Anleitung zu „Immer erlauben" ist ersatzlos
weg. An ihrer Stelle steht der Hinweis auf die Benachrichtigung.

**Nachtrag vom 09.08., am Gerät gefunden:** Die Umstellung hatte eine Hälfte
offen gelassen. Acht Entscheidungsstellen in den Einstellungen hingen weiter an
`hasAlwaysPermission`. Die Fläche zeigte „Nur während der Nutzung" als gelbe
Warnung, bot die Anleitung an und ließ den Schalter gesperrt — sie verlangte
eine Freigabe, die es seit dem Umbau nicht mehr zu erteilen gibt. **Die
Wegaufzeichnung war unerreichbar**, also genau die Funktion, um die es ging.
Neu ist `hasTrackingPermission` („immer" oder „bei Nutzung"); daran hängen
Schalter, Erfolgszustand und die Auffrischung vor dem Start. Der Status ist
grün statt gelb, weil „bei Nutzung" der Zielzustand ist und kein Mangel.

## B12 — Halt trägt weiter Material-Icons — **blockiert**

„Sehen, hören, spüren" (Auge), „Körper spüren" (**Android-Symbol für
Barrierefreiheit**), „Wegschließen" (Kiste), „Atem" (Windlinien). Bekannt aus
der A14-Spec als B2, unverändert.

*Blockiert, nicht vergessen:* Für die vier Übungen gibt es keine gezeichneten
Bilder. In `assets/images` liegen zwölf Chamäleon-Bilder, alle für
Anker-Bereiche, keines für eine Grounding-Übung. Das ist Arbeit an der
Blender-Pipeline, nicht am Code. Bewusst **nicht** behelfsweise durch andere
Material-Icons ersetzt — das wäre derselbe Fehler in neuer Farbe. Sobald die
vier Bilder da sind, ist es eine Zeile je Übung in
`lib/modules/grounding/data/grounding_exercises.dart`.

## Kleineres

- Der Dialog „Dauerhaftes Tracking aktivieren?" spricht noch vom alten
  Modell: „GPS läuft dauerhaft im Hintergrund" und „Background-GPS kann den
  Akku stärker belasten". Seit dem Vordergrunddienst ist beides schief —
  und „Background-GPS" ist ohnehin ein Wort, das niemand zerlegen sollte
  (gefunden am 09.08. am Gerät)
- Spiele: von drei Karten tragen zwei den Vermerk „Bald" (Atemübungen,
  Memory). In einer Fassung, die in den Store geht, sind das zwei Drittel
  leeres Versprechen
- Kontakte: der Filter „Therapeu…" ist abgeschnitten
- Der Pinsel im Chat ist in gesättigtem Blau der auffälligste Punkt der
  Fläche, obwohl er ein Nebenweg ist
- Das Kontakte-Bild im Ankermenü ist als gerahmtes Objekt gezeichnet, die
  übrigen Begleitbilder sind freigestellt
- „Was Aurora sendet" listet Feedback und Telemetrie; die Kartenanfragen an
  OpenStreetMap, die der Datenschutztext als dritte Sache nennt, fehlen dort

## Geöffnet und ohne Absturz

Onboarding, Telemetrie-Consent, Profil-Assistent, Profilwahl, Anker, Halt,
Notfall, Hilfe, Chat (samt Zeichenwerkzeugen), Kalender, Medikamente (anlegen,
bearbeiten, Detailseite), Tagebuch, Kontakte, Finder, Spiele, Zeitachse,
Einstellungen in voller Länge, „Was Aurora sendet". Über den gesamten
Durchlauf kein `FATAL`, kein `E/flutter`, keine `SecurityException`.

## B13 — Absturz nach jedem Update und jedem Geräteneustart

**Gefunden beim Nachtest von 3.0.17**, nicht im Durchlauf oben — weil erst
dabei zum ersten Mal ein Update **über** eine bestehende Installation lief.

```
java.lang.RuntimeException: Unable to start receiver
  com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
Caused by: java.lang.IllegalStateException: TypeToken must be created with a
  type argument ... make sure that generic signatures are preserved.
```

R8 wirft im Release-Build die generischen Signaturen weg. Der Empfänger, der
die geplanten Meldungen nach Neustart und Update zurückliest, tut das über
Gson — und stirbt beim Start. Aurora zeigt Samsungs „App wurde beendet",
und die Erinnerungen sind weg.

Das trifft **jede Nutzerin bei jedem Update** und nach jedem Neustart des
Geräts. Es überlebte alle bisherigen Testdurchläufe, weil wir immer frisch
installiert haben; bei der Erstinstallation feuert der Empfänger nicht.

Behoben mit `android/app/proguard-rules.pro` (Signaturen erhalten, Gson und
`com.dexterous.**` behalten), eingebunden in `build.gradle.kts`. Nachgeprüft:
`adb install -r` über die bestehende Installation, kein `FATAL EXCEPTION`,
der Empfänger startet den Prozess und läuft durch.

## Nachtest 3.0.17 am Gerät

| Befund | Beleg |
|---|---|
| **B13** Absturz beim Update | Update eingespielt, kein `FATAL`, Empfänger läuft |
| **B1** Bildwahl | Avatar stand auf Hund, nach der Galerie-Wahl steht das gewählte Bild da |
| **B2** Standort ungefragt | Neustart der App: kein Systemdialog mehr |
| **B2** Überlagerung | Auf der Zeitkarte steht nur noch das eine Band, ohne den orangen Block darunter |

## B14 — „Tracking dauerhaft an" läuft nicht im Hintergrund

`LocationTrackingService` zeichnet über `Timer.periodic` alle 2 min 30 s auf
(`location_tracking_service.dart:72,228`). Das ist ein Dart-Timer im
App-Prozess. Im Projekt gibt es **keinen** `<service>`-Eintrag im Manifest,
kein `foregroundServiceType`, keinen WorkManager und kein
Hintergrund-Standort-Plugin.

Damit endet die Aufzeichnung, sobald Android den Prozess beendet — weggewischt,
Speicherdruck, Doze. Die Einstellungen versprechen aber:

> Die Position wird dauerhaft erfasst · Funktioniert auch im Hintergrund ·
> Alle Profile werden automatisch aufgezeichnet

und verlangen dafür die Android-Berechtigung „Immer erlauben".
`ACCESS_BACKGROUND_LOCATION` steht im Manifest für eine Fähigkeit, die der
Code nicht hat.

Dieselbe Klasse wie die fehlenden Erinnerungs-Empfänger und die leere
Compile-Konstante im Feedback-Rückkanal: eine Zusage, die niemand nachgemessen
hat. Dazu kommt, dass genau diese Berechtigung bei Play deklarationspflichtig
ist — mit Begründung und Demo-Video. Ein Video für eine Funktion zu drehen,
die im Hintergrund nicht läuft, geht nicht.

**Behoben am 9. August 2026** — und zwar in die Richtung, die der Nutzerin
etwas gibt: Die Aufzeichnung hat einen echten Vordergrunddienst bekommen,
statt das Versprechen zurückzunehmen. „Wo war ich?" nach einer Dissoziation
ist kein Beiwerk.

`GpsManager.positionStream` trägt die `ForegroundNotificationConfig`,
`LocationTrackingService` hört nur noch zu. Der Dienst kommt von
`geolocator_android` (`GeolocatorLocationService`, `foregroundServiceType=
"location"`); die beiden `FOREGROUND_SERVICE`-Berechtigungen bringt es
**nicht** mit — dieselbe Falle wie bei den Erinnerungs-Empfängern.

### Der Nebeneffekt, der mehr wert ist als der Fix

**`ACCESS_BACKGROUND_LOCATION` konnte ganz entfallen.** Ein
Vordergrunddienst, der gestartet wird, während die App sichtbar ist, darf mit
bloßem „Bei Nutzung erlauben" weitermessen. Beide Startwege (Satellitenknopf,
Schalter in den Einstellungen) sind solche Starts.

Am S24 nachgemessen, mit **verweigertem** Hintergrund-Standort:

Alle Messungen am **fertigen** Stand, also mit aus dem Manifest entferntem
`ACCESS_BACKGROUND_LOCATION`:

| Prüfung | Ergebnis |
|---|---|
| Dienst nach dem Einschalten | `GeolocatorLocationService`, `isForeground=true`, `types=0x00000008` |
| Erzwungenes Deep Idle (`deviceidle force-idle`, 75 s) | Dienst läuft weiter, Prozess lebt |
| App neu gestartet, nichts angetippt | Dienst läuft von allein wieder an — der gespeicherte Wunsch greift |
| App-Start **ohne** Standort-Berechtigung | kein `FATAL`, kein `E/flutter`; der Auto-Start scheitert still und richtig |
| Benachrichtigung | „Aurora merkt sich deinen Weg — Damit du später wiederfindest, wo du warst. Bleibt auf dem Gerät." |
| `ACCESS_BACKGROUND_LOCATION` im Paket | nicht vorhanden |
| Zeitkarte | zeigt Zeit, Ort und Adresse |

Das Gerät wurde danach in den Ausgangszustand zurückgesetzt: Aufzeichnung aus,
Standort-Berechtigungen entzogen.

Damit entfällt die Play-Deklaration samt Demo-Video, und die Anleitung „So
aktivierst du ‚Immer erlauben'" in den Einstellungen ist ersatzlos weg. Der
orange Warnkasten ist ein ruhiger Hinweis geworden: „Solange Aurora
aufzeichnet, steht eine Benachrichtigung in deiner Leiste. Verschwindet sie,
wird nicht aufgezeichnet."

**Nicht geprüft:** ob über eine gefahrene Strecke tatsächlich Punkte
entstehen. Bei 50 Metern Mindestabstand und einem Gerät auf dem Schreibtisch
ist das nicht herstellbar; geprüft ist stattdessen, dass der Prozess lebt und
misst — genau das, woran es vorher scheiterte. Ebenfalls offen: Nach einem
Geräteneustart läuft die Aufzeichnung erst wieder, wenn Aurora einmal geöffnet
wurde. Ein Boot-Empfänger dafür wäre ein eigener Schritt.

## Nicht geprüft

Ob eine Erinnerung zur Einnahmezeit tatsächlich als Meldung erscheint (dafür
müsste eine Einnahmezeit abgewartet werden), das Verhalten mit erteilter
Exact-Alarm-Freigabe, der Chat mit echten Nachrichten und Anhängen, das
Rückmeldungs-Formular, und alles, was mehr als ein Profil braucht — also
Profilwechsel, Rechtevergabe und das Verhalten geteilter Dosen.
