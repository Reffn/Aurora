# Sprachprüfung am Gerät

Datum: 13.08.2026 · Emulator `Medium_Phone_API_36.0` (Android 16), Debug-Build
`com.disapp.dis_app`, installiert und gestartet.

Anlass: die fünf Sprachen sind in den `.arb`-Dateien vollständig (1560 Schlüssel
je Sprache, null Lücken — gemessen). Die Frage war, ob sie am Gerät ankommen.

> **Zusammenfassung vorweg:** Die Messung stimmt, die erste Deutung war falsch.
> Aurora ignoriert die Android-Sprachwahl absichtlich, weil die Sprache am
> Anteil hängt und nicht am Gerät. Siehe „Berichtigung" weiter unten. Zu
> ändern bleibt nur `android:allowBackup`.

## Die Messung

**Die Android-Sprachwahl je App greift bei Aurora nicht.**

Nachgemessen, viermal hintereinander:

```
adb shell cmd locale set-app-locales com.disapp.dis_app --user current --locales de
adb shell cmd locale get-app-locales com.disapp.dis_app
  → Locales for com.disapp.dis_app for user 0 are [de]
adb shell am force-stop com.disapp.dis_app     # danach neu gestartet
```

Android bestätigt `[de]`, `[en]`, `[es]`, `[it]` — die Oberfläche bleibt in
**allen vier Fällen** unverändert französisch: „Qui est là en ce moment ?",
„jeu. 13 août 2026", „dernière fois il y a 7 jours", „Mentions légales".

Das ist kein Anzeigefehler eines einzelnen Schirms. Die eingestellte Sprache
erreicht die App überhaupt nicht.

## Berichtigung: das ist kein Fehler, das ist der Entwurf

Die erste Fassung dieser Seite hat den Befund als Mangel geführt. Das war
falsch, und der Grund steht im Quelltext, den ich hätte lesen müssen, bevor ich
die Messung gedeutet habe.

`lib/models/profile.dart:185-195`

```dart
/// Die Sprache dieses Anteils, z. B. `de` oder `es` (ISO 639-1).
///
/// Nicht jeder im System spricht dieselbe Sprache — bei DIS ist das der
/// Normalfall, nicht die Ausnahme. Deshalb hängt die Sprache am Anteil und
/// nicht an der App: wer sich anmeldet, findet seine Sprache vor, ohne sie
/// [zu wählen].
final String? preferredLanguage;
```

Dazu `copyWith(clearPreferredLanguage: true)` mit der ausdrücklichen Bedeutung
„der App folgen". Der Nullzustand ist also vorgesehen, nicht vergessen.

**In einem System sprechen die Anteile verschiedene Sprachen.** Die Sprache
gehört deshalb an den Anteil, nicht an das Gerät — und `main.dart:756` tut
genau das Richtige, wenn es die eigene Wahl über die Systemsprache stellt.

Damit dreht sich auch die Bewertung von `android:localeConfig` um: Androids
Sprachwahl je App kennt **einen** Wert für die ganze App. Sie kann „Mika liest
Französisch, Lina liest Deutsch" nicht ausdrücken. Sie zu deklarieren hieße,
eine Einstellung anzubieten, die dem Modell der App widerspricht — der Nutzer
stellte dort etwas ein, das eine Ebene tiefer sofort wieder überschrieben wird.
**Sie nicht zu deklarieren ist die richtige Entscheidung.**

Was von der Messung bleibt, ist klein: wer die App-Sprache trotzdem über
Android setzt (per `adb` geht es, in den Systemeinstellungen je nach Hersteller
auch), bekommt keine Rückmeldung, dass die Einstellung wirkungslos ist. Das ist
eine Randunschärfe, kein Defekt — und der Preis für ein Modell, das den
richtigen Fall trifft.

## Nebenbefund

`android:allowBackup` steht weiterhin **nirgends** im Manifest. Der Standard
ist `true`, also sichert Android das gesamte Datenverzeichnis in die Google
Drive des Kontos. Für eine App, in der jeder Datenpunkt kontextbedingt
Gesundheitsdatum ist, ist die Abwesenheit dieser Zeile die eigentliche Aussage —
ein Grep findet dazu nichts, weil nichts dasteht.

## Die Prüfung, die etwas belegt — nachgeholt und bestanden

Am Emulator durchgespielt, Schritt für Schritt:

1. App-Sprache stand auf Französisch, Profil **Lina** auf „der App folgen"
   (grüner Haken bei *Langue de l'application*).
2. Für Lina **Deutsch** gewählt. Der Knopf im Profildialog wechselte sofort von
   „Langue de l'application" auf „🌐 Deutsch" — die Wahl sitzt am Anteil, nicht
   an der App.
3. „Continuer en tant que Lina" getippt.
4. **Die gesamte Oberfläche steht auf Deutsch**: „Was sich geändert hat",
   „Sag uns, was fehlt", „Weiter zu Aurora" — während die Profilauswahl davor
   französisch blieb.

Bildschirmfotos: `tmp/lang.png`, `tmp/lina_de.png`, `tmp/als_lina.png`.

**Das Modell trägt.** Die Sprache hängt am Anteil, der Wechsel greift sofort,
und die Ebene davor — wo noch kein Anteil da ist — bleibt bei der App-Sprache.
Genau so, wie es gebaut wurde.

## Was offen bleibt

1. `android:allowBackup="false"` setzen. Das ist der einzige Punkt dieser
   Prüfung, der eine Änderung verlangt.
2. Kleinigkeit aus derselben Sitzung: der Sprachdialog trägt nur den Titel
   „Langue" / „Sprache". Er stellt aber die Sprache **eines bestimmten Anteils**
   ein — und genau das ist die Eigenschaft, die Aurora von jeder anderen App
   unterscheidet. Der Name des Anteils gehört in den Titel.
3. Der Emulator steht nach dieser Prüfung mit Lina auf Deutsch. Nicht
   zurückgesetzt, weil es Testdaten sind.

## Was diese Seite gelernt hat

Eine Messung ist noch keine Deutung. Vier bestätigte `adb`-Läufe zeigten
zuverlässig, dass die Systemsprache nicht durchschlägt — und die naheliegende
Deutung („kommt nicht an") war trotzdem falsch, weil sie eine Annahme über den
Entwurf mitbrachte, die zwei Bildschirmseiten weiter im Quelltext widerlegt
steht. Der Fehler lag nicht im Messen, sondern darin, das Modell der App nicht
gelesen zu haben, bevor ich es beurteilt habe.

## Was am Gerät gut aussah

Französisch trägt sauber: Datum, Tageszeit („l'après-midi"), relative Zeiten
(„il y a 7 jours"), Rechtstexte. Kein abgeschnittener Text, kein Überlauf, kein
deutscher Rest. Zwei Oberflächenpunkte auf demselben Schirm:

- Die weißen Profilkreise (Dev2, Mika) tragen Pastellbuchstaben auf Weiß und
  sind kaum zu lesen; Lina (Türkis) und Mina (Violett) lesen sich sofort. Deckt
  sich mit Befund 3 der Codex-Prüfung (freie Profilfarben, feste weiße Schrift).
- „Nouveau …" unter dem Plus sagt nicht, was danach kommt.
