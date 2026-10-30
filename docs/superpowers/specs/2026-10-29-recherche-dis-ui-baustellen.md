# Recherche: Baustellen vom 29.10.2026 — UI und DIS

Grundlage für drei Baustellen: Profile löschen/deaktivieren (Feedback vom
27.10.), Erinnerungen zu gelöschten Medikamenten, Standortfehler. Ergänzt
`docs/oberflaechen-richtlinien.md` und wiederholt deren elf Regeln nicht.

Die Belege sind unterschiedlich stark: Standards und Plattformdokumentation,
Expertenkonsens (ISSTD), kleine qualitative Studien, Gepflogenheiten der
Community. Was davon abgeleitet ist, steht als Ableitung da.

## 1. Profil löschen oder ruhen lassen

**Belege**
- ISSTD-Leitlinien 2011 (Expertenkonsens, J Trauma Dissoc 12:115–187):
  - Es wirkt der Therapie entgegen, Anteile zu ignorieren oder „loszuwerden“.
  - Keinen Anteil bevorzugen.
  - Entscheidungen berücksichtigen die Wünsche aller Anteile.
  - <https://www.isst-d.org/wp-content/uploads/2025/12/GUIDELINES_REVISED2011.pdf>
- Mckie et al., PLOS ONE 2025 (n = 15, davon 4 mit DIS): Entscheidet ein
  Anteil allein, folgen Groll und Streit im System.
  <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0335714>
- Community:
  - Ruhende Anteile („dormant“) können zurückkommen
    (<https://pluralpedia.org/w/Dormancy>).
  - Viele fürchten bei Integration, Anteile zu „verlieren“ oder zu „töten“
    (<https://did-research.org/treatment/integration>).
- Andere Plural-Apps:
  - Simply Plural (eingestellt 07/2026) hatte „Archived“ mit optionalem Grund.
    Archivierte Mitglieder fehlten in Liste und Zählung, blieben aber über die
    Suche erreichbar.
  - PluralKit verlangt zum Löschen die ID des Mitglieds, gegen versehentliches
    Löschen (<https://pluralkit.me/guide/>).
- WCAG 2.2, 3.3.4: Das Löschen von Nutzerdaten muss umkehrbar sein, geprüft
  oder bestätigt werden.
  <https://www.w3.org/WAI/WCAG22/Understanding/error-prevention-legal-financial-data.html>
- NN/g, Bestätigungsdialoge: Die Knöpfe nennen die Handlung, nicht „Ja/Nein“.
  <https://www.nngroup.com/articles/confirmation-dialog/>
- Chen et al., „Trauma-Informed Computing“ (CHI 2022):
  - Unerwartete Veränderungen der Oberfläche können Angst machen.
  - Rot und Alarmwörter können triggern.
  - doi 10.1145/3491102.3517475

**Ableitung für Aurora** (noch nicht entschieden)
- **„Ruhen lassen“ ist die Haupthandlung, endgültiges Löschen der zweite,
  langsamere Schritt**, nur für schon ruhende Anteile.
- Ein ruhender Anteil verschwindet aus Auswahl und Zählung. Sein Verlauf bleibt.
- Beide Handlungen gehören ans Ende von „Profil bearbeiten“, nicht nur auf
  einen langen Druck. Heute ist Löschen nur dort erreichbar:
  `profile_selection_screen.dart:643`.
- Einen Bereich „Ruhende Anteile“ sehen alle Anteile, jeder Eintrag mit wer und
  wann, ohne Vorwurf, etwa: „Ruht seit 3. Mai · von Lina“.
- Die Löschbestätigung nennt Namen und Umfang und hat die Knöpfe
  „Endgültig löschen“ / „Behalten“.
- Vermeiden: „löschen“, „entfernen“ oder „deaktivieren“ für einen Anteil. Kein
  „integriert“/„fusioniert“ als vorgegebener Status, das ist eine klinische und
  persönliche Aussage.
- Vorschlag Wortlaut:
  - DE: „Ruhen lassen“ / „Ruht gerade“ / „Wieder aufnehmen“
  - EN: „Let rest“
  - FR: „Mettre en repos“

## 2. Erinnerungen zu gelöschten oder pausierten Medikamenten

- Android:
  - Veraltete Meldungen soll die App selbst wegräumen
    (<https://developer.android.com/design/ui/mobile/guides/home-screen/notifications>).
  - `cancel()` entfernt auch eine schon angezeigte Meldung, aber nur mit dem
    passenden Tag.
- **Korrektur zur Recherche:** `getActiveNotifications` liefert in
  flutter_local_notifications 18 auf Android **keine Payload**, nur id, tag,
  Titel und Text (`FlutterLocalNotificationsPlugin.java:1561–1573`). Am A14
  bestätigt.
- Umgesetzt am 29.10.2026:
  - Der Schlüssel des Ziels reist als Tag mit.
  - `isStillCurrent` entscheidet zeitlos, ob eine angezeigte Meldung noch gilt.
  - Sie verschwindet bei Löschen, Pausieren, Stummschalten, gestrichener Zeit
    und „Genommen“.
- Vertrauen: Fehlalarme beschädigen Befolgung und Verlass stärker als
  ausbleibende Meldungen (Dixon, Wickens & McCarley 2007, Luftfahrt; die
  Übertragung ist eine Ableitung). In einem System kann eine stehengebliebene
  Meldung zu einer doppelten Einnahme durch einen anderen Anteil führen.

## 3. Standort: fehlt die Erlaubnis oder (noch) die Position?

- Android und geolocator unterscheiden vier Zustände:
  - Erlaubnis fehlt
  - Standort am Gerät aus (`LocationServiceDisabledException`)
  - nur ungefähr freigegeben
  - noch keine Position (`TimeoutException`)
  - Quellen: <https://developer.android.com/develop/sensors-and-location/location/permissions>,
    <https://pub.dev/packages/geolocator>
- Behoben am 29.10.2026: `startTracking` schloss aus „keine Position“ auf „keine
  Erlaubnis“. Drinnen startete die Aufzeichnung deshalb nicht, auch beim
  Wiederanlauf nach dem App-Start nicht.
- **Offen:**
  - `gps_manager.dart` fasst alle vier Zustände zu `null` bzw.
    `fehler_gps_timeout` zusammen.
  - Für „noch keine Position“ die letzte bekannte Position mit ihrem Alter
    zeigen.
  - Nur „Erlaubnis fehlt“ und „Standort aus“ bekommen einen Handlungsknopf.
- Ton nach Google Tech Writing, Error Messages
  (<https://developers.google.com/tech-writing/error-messages/set-tone>):
  - nüchtern
  - ohne Vorwurf, kein „Fehler“, kein Ausrufezeichen, kein Rot
  - Beispiel: „Der Standort wird noch gesucht – drinnen dauert das manchmal.“

## 4. Allgemein für Dissoziation

Eine HCI-Studie zur Technik-Nutzung bei DIS fehlt. Übertragen aus COGA
(<https://www.w3.org/TR/coga-usable/>), Chen 2022 und NN/g:
- Nichts ändert sich still.
- Jede Zustandsänderung sagt, wer sie wann vorgenommen hat, als Tatsache und
  nicht als Vorwurf.
- Was sich nicht rückgängig machen lässt und alle betrifft, bekommt den
  langsamsten Weg.
