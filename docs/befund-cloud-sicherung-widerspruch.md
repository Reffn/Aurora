# Die App verspricht etwas, das das Manifest nicht hält

Datum: 13.08.2026 · Gefunden beim Nachlaufen des Erstkontakts am Emulator
(frische Installation, Daten gelöscht, Onboarding von vorn).

## Der Widerspruch

**Zweiter Schirm des Onboardings**, unter der Überschrift „Deine Daten gehören
DIR", vier Zusagen mit Häkchen:

> ✓ Alle Daten bleiben lokal auf deinem Gerät
> ✓ **Keine Cloud-Sicherung**, kein Tracking, keine Werbung
> ✓ Du hast die volle Kontrolle
> ✓ Transparent und sicher

**Im gebauten APK steht kein `android:allowBackup`.** Geprüft nicht am
Quelltext, sondern am Auslieferungsgegenstand:

```
aapt2 dump xmltree app-debug.apk --file AndroidManifest.xml
  → kein allowBackup
  → kein dataExtractionRules
  → kein fullBackupContent
```

Androids Vorgabe für `allowBackup` ist **`true`**. Ohne
`dataExtractionRules` sind ab Android 12 sowohl die Cloud-Sicherung als auch
die Geräte-zu-Gerät-Übertragung erlaubt. Das System sichert damit das
**gesamte Datenverzeichnis** der App in die Google Drive des angemeldeten
Kontos: Hive-Boxen mit Profilen, Chatverläufen, Tagebucheinträgen,
Medikamenten, Notfallkontakten.

Die App sagt auf ihrem zweiten Schirm das Gegenteil dessen, was sie tut.

## Warum das schwerer wiegt als ein fehlendes Attribut

1. **Es ist eine Aussage, keine Unterlassung.** Ein fehlendes Attribut ist ein
   Versäumnis. Ein Häkchen neben „Keine Cloud-Sicherung" ist eine Zusage — und
   sie wird genau der Person gegeben, deren Entscheidung für diese App auf
   dieser Zusage beruht.
2. **Es ist die Kernzusage.** Aurora hat keinen anderen Vorteil gegenüber
   Simply Plural oder einem Notizbuch als diesen. „Alles bleibt lokal" ist das
   Produkt.
3. **Es sind Gesundheitsdaten.** In einer DIS-App ist jeder Datenpunkt
   kontextbedingt ein Gesundheitsdatum (DSGVO Art. 9). Die Zahl der Anteile,
   ihre Namen, Chatverläufe zwischen ihnen, Medikamente.
4. **Niemand sieht es.** Der Nutzer nicht, ein Grep nicht, ein Test nicht. Bei
   Plattform-Voreinstellungen ist die Abwesenheit die Aussage.

## Was zu tun ist

```xml
<application
    android:label="Aurora"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:allowBackup="false"
    android:fullBackupContent="false"
    android:dataExtractionRules="@xml/data_extraction_rules">
```

Mit `res/xml/data_extraction_rules.xml`, das Cloud-Sicherung **und**
Gerätewechsel ausschließt — `allowBackup="false"` allein deckt ab Android 12
nicht beide Wege.

Die Alternative wäre, den Satz im Onboarding zu ändern. Das ist die schlechtere
Wahl: die Zusage ist richtig, sie ist der Grund für die App, und sie ist
einzuhalten statt zurückzunehmen.

## Zwei Einschränkungen, ehrlich benannt

- Die Google-Sicherung ist mit der Gerätesperre verschlüsselt; Google gibt an,
  den Inhalt nicht lesen zu können. **Das ändert nichts an der Zusage** — sie
  sagt nicht „niemand liest mit", sie sagt „bleibt auf deinem Gerät". Die Daten
  verlassen das Gerät.
- Auroras Datenverzeichnis war auf dem Prüfgerät **211 MB** groß. Androids
  automatische Sicherung hat eine Größengrenze, oberhalb derer sie eine App
  überspringt. Bei einem gut gefüllten Installationsstand könnte die Sicherung
  also gar nicht laufen — das ist aber Zufall, kein Schutz, und für eine frische
  oder schlanke Installation gilt es nicht.

## Erledigt am 14.08.2026

Umgesetzt wie oben beschrieben, dazu `res/xml/data_extraction_rules.xml` mit
beiden Abschnitten und allen neun Bereichen — auch denen, in denen Aurora heute
nichts ablegt. Jeder nicht genannte Bereich fällt auf die Voreinstellung
zurück, und die heißt: alles mitnehmen.

**Bewacht von `test/core/keine_cloud_sicherung_test.dart`** (vier Prüfungen,
vor dem Umbau rot gesehen). Der Test prüft die Attribute, beide Abschnitte der
Regeldatei, jeden Bereich zweimal — und dass die Zusage in allen fünf Sprachen
noch dasteht. Wer den Satz umformuliert, kommt an dieser Wache vorbei; wer die
Attribute wieder verliert, nicht.

**Nachgemessen am Auslieferungsgegenstand**, mit demselben Werkzeug, das den
Befund gefunden hat:

```
aapt2 dump xmltree app-debug.apk --file AndroidManifest.xml
  → android:allowBackup=false
  → android:fullBackupContent=false
  → android:dataExtractionRules=@0x7f110000

aapt2 dump resources app-debug.apk
  → 0x7f110000 = xml/data_extraction_rules

aapt2 dump xmltree app-debug.apk --file res/xml/data_extraction_rules.xml
  → E: cloud-backup     — neun exclude-domains
  → E: device-transfer  — neun exclude-domains
```

Die Ressourcennummer im Manifest wurde eigens aufgelöst: ein Verweis, der ins
Leere zeigt, sähe an dieser Stelle genauso aus wie einer, der trägt.

`src/debug` und `src/profile` setzen die Attribute nicht, es gibt also nichts,
was die Zusammenführung anders ausgehen ließe.

**Am Gerät gegengeprüft** (Galaxy S24, `SM_S921B`, Release-Build 3.0.20 über
`adb install -r` — Daten blieben erhalten). Der Vorher-Wert ist der Beweis,
dass der Befund kein Papierbefund war:

```
vorher   pkgFlags=[ HAS_CODE ALLOW_CLEAR_USER_DATA ALLOW_BACKUP KILL_AFTER_RESTORE ]
nachher  pkgFlags=[ HAS_CODE ALLOW_CLEAR_USER_DATA ]

dumpsys backup | grep -c disapp  →  0
```

`ALLOW_BACKUP` und `KILL_AFTER_RESTORE` sind weg, und der Sicherungsdienst
führt Aurora nicht mehr als Teilnehmer. Kalt- und Warmstart ohne Absturz,
Logcat ohne einen einzigen Eintrag aus dem App-Prozess — nur Samsung-eigenes
Rauschen. Der Absturzpuffer ist leer. Das war die eigentliche Frage bei
`install -r`: auf diesem Weg gingen am 09.08.2026 schon einmal die
Gson-Signaturen im Erinnerungs-Empfänger verloren, sichtbar ausschließlich
beim Update über eine bestehende Installation.

## Drei offene Punkte, ehrlich benannt

- **Wirksam wird der Fix erst mit dem nächsten Release.** Bis dahin gilt auf
  jedem installierten Gerät weiter die Voreinstellung.
- **Was mit den bereits hochgeladenen Sicherungen geschieht, ist ungeklärt.**
  Aurora läuft seit rund einem Jahr; auf den aktiven Geräten liegen
  wahrscheinlich Snapshots in fremden Google-Drive-Konten. Ob und wann Android
  sie nach `allowBackup="false"` verwirft, ist von hier aus nicht nachgemessen.
  Der Fix stoppt Künftiges — er räumt nicht auf.
- **Der Gerätewechsel kostet jetzt die Daten.** `device-transfer`
  ausgeschlossen heißt: neues Telefon, leere App. Das ist die gewollte Seite
  derselben Zusage, und `privacySecurityBody` sagt sie bereits wörtlich
  („Geht das Gerät verloren oder kaputt, sind die Daten weg"). Ein Ausweg wäre
  ein Export in der App — bewusst, sichtbar, vom Menschen ausgelöst. Solange
  es den nicht gibt, ist der Preis unverändert der beschriebene.

## Wie es gefunden wurde

Nicht durch Lesen des Manifests — dort steht nichts, und wonach man nicht
sucht, findet man nicht. Sondern dadurch, dass die App beim Erstkontakt eine
Zusage **aussprach**, die man gegen das Gebaute halten konnte. Der Weg war:
Onboarding von vorn ansehen → Satz lesen → prüfen, ob er stimmt.
