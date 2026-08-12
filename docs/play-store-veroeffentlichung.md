# Veröffentlichung im Play Store

Aurora wird über die Google Play Developer API hochgeladen, nicht per Hand in
der Console. Das Skript liegt in `tool/play_upload.py`, Paketname
`com.disapp.dis_app`.

## Einmalige Einrichtung: Service-Account

Diese Schritte laufen in deinem Google-Konto und musst du selbst klicken —
sie legen einen Schlüssel an und vergeben Rechte auf dein Entwicklerkonto.

1. **Play Console → Einstellungen → API-Zugriff**
   Falls noch kein Google-Cloud-Projekt verknüpft ist: eines verknüpfen oder
   neu anlegen lassen.

2. **Service-Account erstellen** (Link führt in die Google Cloud Console)
   - Name z. B. `aurora-play-upload`
   - Keine Projektrollen nötig — die Rechte kommen aus der Play Console
   - Danach: **Schlüssel → Schlüssel hinzufügen → JSON erstellen**.
     Die JSON-Datei wird einmal heruntergeladen und ist nicht wiederherstellbar.

3. **Rechte in der Play Console vergeben**
   Zurück unter API-Zugriff erscheint der Service-Account. Dort
   **Zugriff gewähren** und mindestens erlauben:
   - App-Informationen ansehen
   - Releases in Test-Spuren verwalten
   - Releases in der Produktionsspur verwalten (nur wenn direkt produktiv
     veröffentlicht werden soll)

4. **Schlüssel ablegen — außerhalb des Repos.**
   Empfohlen: `C:\Users\<du>\.aurora\play-service-account.json`
   Dann dauerhaft in der Umgebung setzen:

   ```powershell
   [Environment]::SetEnvironmentVariable('PLAY_SERVICE_ACCOUNT_JSON', "$env:USERPROFILE\.aurora\play-service-account.json", 'User')
   ```

   Der Schlüssel darf nie in Git landen. `.gitignore` deckt `*.json` nicht
   pauschal ab, deshalb: nicht im Projektordner speichern.

5. **Abhängigkeiten installieren** (einmalig):

   ```powershell
   pip install google-api-python-client google-auth
   ```

## Release veröffentlichen

```powershell
flutter analyze
flutter test
flutter build appbundle --release
python tool/play_upload.py --track internal --dry-run   # prüft alles, veröffentlicht nichts
python tool/play_upload.py --track internal             # interner Test
```

Wenn der interne Test sauber läuft, weiter in die Produktion. Das Bundle
liegt dann schon oben — Play lehnt einen zweiten Upload desselben
versionCode mit `Version code N has already been used` ab. Deshalb
**promoten statt neu hochladen**:

```powershell
python tool/play_upload.py --track production --promote 15
python tool/play_upload.py --track production --promote 15 --rollout 0.1   # stufenweise
```

Ohne `--rollout` geht der Release nach Googles Prüfung an alle.

## Vor jedem Release

- `version:` in `pubspec.yaml` erhöhen — Play lehnt einen bereits benutzten
  versionCode ab
- Abschnitt in `CHANGELOG.md` ergänzen
- Release-Notes für den Store in `docs/play-release-notes-<version>.txt`
  schreiben, höchstens 500 Zeichen; Pfad per `--notes` übergeben
- `flutter test` grün, `flutter analyze` ohne Fehler

## Grenzen des Skripts

Es lädt das Bundle hoch und setzt die Spur. Alles andere — Store-Eintrag,
Screenshots, Datenschutzerklärung, Datensicherheits-Formular, Content-Rating —
bleibt Handarbeit in der Console und muss ohnehin nur bei Änderungen angefasst
werden.

## Wenn eine Berechtigung eine Ablehnung ausgelöst hat

Am 7. August 2026 lehnte Google 3.0.15 wegen `READ_MEDIA_IMAGES` und
`READ_MEDIA_VIDEO` ab. Der Fix im Manifest genügt dafür **nicht**. Googles
eigener Weg (Play Console → Richtlinienstatus → Problemdetails) lautet:

1. Die Berechtigungen aus **allen Versionscodes** entfernen — ausdrücklich
   „einschließlich Produktions- und Test-Tracks"
2. Die Android-Bildauswahl einbauen
3. Die App über *Veröffentlichungen – Übersicht* erneut einreichen

Punkt 1 ist der, den man übersieht. Unter *App-Inhalte → Berechtigungen für
Fotos und Videos → App Bundles und APKs ansehen* steht, welche Bundles die
Berechtigung noch tragen. Am 8.8.2026 waren das zwei: 15 (3.0.15, Produktion)
und 12 (3.0.12, Offener Test vom November 2025). Solange eine alte Spur ein
solches Bundle ausliefert, bleibt die Deklaration offen — egal wie sauber die
neue Version ist.

**Das Erklärungsformular ist nicht der Weg.** Es hat nur zwei Freitextfelder,
in denen man begründet, warum man die Berechtigung *braucht*. Wer sie nicht
mehr braucht, schreibt dort nichts hinein — die Deklaration löst sich auf,
sobald kein aktives Bundle sie mehr trägt. Eine neue Begründung einzutragen
ist derselbe Zweig, der die Ablehnung eingebracht hat.

Ungenutzte Test-Tracks deshalb pausieren, statt sie liegen zu lassen. Die
Console rät von sich aus dazu, sobald ein Track länger als 90 Tage von einem
Produktionsrelease überholt ist.
