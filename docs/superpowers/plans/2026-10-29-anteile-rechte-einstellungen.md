# Anteile, Rechte und Einstellungen aufräumen — Implementierungsplan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Profile lassen sich wirklich pausieren und zurückholen. Die
Rechteverwaltung schrumpft von 60 Kästchen auf 10 Schalter. Die Einstellungen
zeigen Zustand und Handlung statt vorauseilender Erklärungen.

**Architecture:**
- Das gespeicherte Modell bleibt: `Permission`-Enum und `Profile.permissions`
  (Liste von Zeichenketten). Es gibt keine Migration.
- 45 Rechte gelten künftig „für alle“ (`Permission.perPart == false`), und
  `Profile.hasPermission` gibt dafür immer `true` zurück.
- Die übrigen 15 bündelt ein neues Modell `PartRight` zu 10 Schaltern. Sie
  gelten wie bisher Recht für Recht, so wie sie gespeichert sind.
  Bestehende Anteile verlieren und gewinnen beim Update also nichts.
- Pausieren läuft künftig wirklich über `ProfileService`. Bisher hat
  `DataEntry.deactivateProfile` nur ein Ereignis veröffentlicht, auf das
  niemand reagierte: ein No-Op mit Erfolgsmeldung.

**Tech Stack:** Flutter, Hive CE, GetIt, flutter_test, ARB/gen-l10n
(de, en, es, fr, it).

**Spec:** Die Entscheidungen fielen im Chat vom 29.10.2026 und stehen unten
unter „Global Constraints“. Hintergrund liefern
`docs/superpowers/specs/2026-10-29-recherche-dis-ui-baustellen.md` und
`docs/oberflaechen-richtlinien.md`, letzteres vor jedem Schirm lesen.

## Global Constraints

**Rechte**
- **Pro Anteil** bleiben genau diese 15 Rechte (`perPart: true`):
  - `viewMedication`, `viewMedicationTab`, `manageMedication`,
    `overrideMedicationLog`
  - `deleteAllMessages`, `editAllEvents`, `deleteAllEvents`,
    `editAllDiaryEntries`, `deleteAllDiaryEntries`, `viewAllDiaries`
  - `createProfiles`, `deactivateProfiles`, `managePermissions`,
    `accessSettings`, `resetPasswords`
- Alle anderen 45 gelten **für alle**. Dazu gehören Finder, Kontakte, Chat,
  Kalender, eigenes Tagebuch, Medikamente eintragen, Zeitachse, Spiele,
  Mantras, Feedback, Hilfe, Notfall samt Anrufen und Ändern der
  Notfallkontakte, eigenes Passwort und Biometrie.
- Die 10 Schalter mit ihren Rechten:

  | Gruppe | Schalter | Rechte |
  |---|---|---|
  | Medikamente | Medikamente sehen | `viewMedication`, `viewMedicationTab` |
  | Medikamente | Medikamentenplan ändern | `manageMedication`, `overrideMedicationLog` |
  | Andere Anteile | Einträge anderer ändern | `editAllEvents`, `editAllDiaryEntries` |
| Andere Anteile | Einträge anderer löschen | `deleteAllMessages`, `deleteAllEvents`, `deleteAllDiaryEntries` |
  | Andere Anteile | Tagebücher anderer lesen | `viewAllDiaries` |
  | Verwaltung | Anteile anlegen | `createProfiles` |
  | Verwaltung | Anteile pausieren | `deactivateProfiles` |
  | Verwaltung | Rechte vergeben | `managePermissions` |
  | Verwaltung | Einstellungen ändern | `accessSettings` |
  | Verwaltung | Passwörter zurücksetzen | `resetPasswords` |

- „Medikamentenplan ändern“ setzt „Medikamente sehen“ voraus. Wer das eine
  einschaltet, schaltet das andere mit. Wer „sehen“ ausschaltet, schaltet
  „ändern“ mit aus.
- **Zehn statt der im Chat genannten neun, meine Entscheidung:** Die Vorlage
  `standard` erlaubt heute, Einträge anderer zu ändern, aber nicht, sie zu
  löschen. Ein gemeinsamer Schalter hätte allen bestehenden Anteilen mit
  Standardrechten still ein Recht genommen oder gegeben. Getrennt bleibt
  alles, wie es ist.

**Wortlaut**
- Für einen Anteil gelten nur diese Wörter: **Pausieren** (Handlung),
  **Pausiert** (Zustand), **Wieder aufnehmen** (Rückweg), **Pausierte Anteile**
  (Bereich). Nie „löschen“, „entfernen“ oder „deaktivieren“.
- Die anderen Sprachen nehmen dieselben Verben wie `medicationPause`,
  `medicationResume` und `medicationStatusPaused` in ihrer ARB.

**Gestaltung**
- Keine roten oder gesättigten Flächen und keine Warndreiecke in Rechte- und
  Anteilsschirmen. Kräftige Farbe gehört Halt, Notfall und Hilfe (Regel 4).
  Bereichsfarbe nur als Symbolfarbe.
- Keine Bedienung, die nur fehlschlagen kann („errorless“, Abgleich vom
  06.08.): Was nicht erlaubt ist, wird nicht angeboten.
- Jede Geste hat einen sichtbaren Knopf (Regel 8). Langdruck darf nie der
  einzige Weg sein.

**Technik**
- Die UI geht über `DataEntry` (Lint `no_direct_service_access`).
- `Permission` ist kein `@HiveType`, gespeichert werden Zeichenketten. Für
  diesen Umbau ist kein `build_runner` nötig.
- Alle fünf ARB-Dateien bekommen jeden neuen Schlüssel. Danach
  `flutter gen-l10n`. Die Datei für unübersetzte Texte (`l10n.yaml`) muss leer
  bleiben.
- Commits nur nach Freigabe durch den Nutzer, immer gezielt
  `git add <Dateien>`, nie `-A`. Im Baum liegen fremde Dateien:
  `marketing/`, `assets/images/cham_notfall_plastisch_v3.png`, `windows/`.
- `dart run custom_lint` bricht derzeit an `build/release_video_app/pubspec.yaml`
  ab. Den Ordner nicht löschen. Die Regeln für geänderte Dateien von Hand
  prüfen.

## Review Focus

1. **Ein neues Recht kommt ins Enum, und niemand ordnet es zu.** Dann muss ein
   Test rot werden, nicht die App still „für alle“ freigeben. Abgedeckt durch
   Task 1, Test `jedes Recht ist bewusst eingeordnet`.
2. **Pausieren des aktiven Anteils, des letzten Admins oder ohne Recht.**
   Der Dienst verweigert. Die Oberfläche bietet den Knopf gar nicht erst an
   (Task 3 und 4).
3. **Bestehende Profile mit alten Einzelrechten**, etwa nur `sendVideo` aus
   oder nur `manageMedication` ohne `viewMedication`. Sie dürfen danach alles,
   was „für alle“ ist. Bei den Rechten pro Anteil bleibt jedes Recht, wie es
   gespeichert ist. Ein halb gesetzter Schalter steht auf „aus“ und hat die
   Unterzeile „Teilweise erlaubt“. Einschalten setzt alle seine Rechte,
   Ausschalten nimmt alle weg (Task 1, `halb gesetzt bleibt, wie es war`;
   Task 5). Die Vorlagen `child` und
   `standard` bestehen heute schon nur aus ganzen Schaltern (Task 1,
   `Vorlagen enthalten nur ganze Schalter`). Bei Anteilen mit Standardrechten
   ändert sich also nichts.
4. **Wieder aufnehmen eines Anteils mit Passwort.** Der Anteil steht wieder in
   der Auswahl, das Passwort gilt weiter. Pausieren ändert sonst kein Feld des
   Profils (Task 3).
5. **Die Einstellungen am Gerät bis ganz unten scrollen.** Offen laut
   Gedächtnis: `settings_screen.dart` scrollte am Gerät nicht über den
   Kartencache hinaus. Ursache suchen in Task 6, prüfen am Gerät in Task 8.

## Bewusst draußen

- Der orange-grüne Info-Kasten in `profile_creation_screen.dart:686` und
  der direkte Zugriff dort auf `getIt<PermissionPresetService>()`. Beides
  kommt dran, wenn die Profilanlage überarbeitet wird.
- Ein Zeitlimit für `fehler_gps_timeout` und das Standortmodell mit vier
  Zuständen.

## File Structure

| Datei | Zuständigkeit |
|---|---|
| `lib/models/permission.dart` | Feld `perPart` |
| `lib/models/profile.dart` | `hasPermission` beachtet `perPart` |
| `lib/models/part_right.dart` (neu) | die 10 Schalter, ihre Rechte, Abhängigkeit |
| `lib/services/profile_service.dart` | Pausieren, Wiederaufnehmen und Rechte setzen mit Schutzregeln |
| `lib/core/data_entry.dart` | `pauseProfile`, `resumeProfile`, `canPauseProfile`, `getPausedProfiles`, `setPartRight` |
| `lib/modules/profile/widgets/pause_profile_dialog.dart` (neu) | Bestätigung und Rückgängig, geteilt |
| `lib/modules/profile/widgets/paused_parts_sheet.dart` (neu) | Liste „Pausierte Anteile“ mit „Wieder aufnehmen“ |
| `lib/modules/profile/profile_selection_screen.dart` | Langdruck-Blatt, Zeile „Pausierte Anteile“ |
| `lib/widgets/profile_actions_dialog.dart` | Knopf „Pausieren“ im Antippen-Blatt |
| `lib/modules/permissions/permissions_manager_screen.dart` | wird zum Schirm „Anteile & Rechte“ |
| `lib/modules/permissions/permission_detail_screen.dart` | 10 Schalter bzw. Admin-Karte |
| `lib/modules/settings/settings_screen.dart` | nur noch Komposition |
| `lib/modules/settings/sections/*.dart` (neu) | ein Abschnitt je Datei |
| `lib/modules/settings/screens/offline_maps_screen.dart`, `diagnostics_screen.dart` (neu) | Unterseiten |
| `lib/modules/settings/widgets/settings_info_sheet.dart` (neu) | Erklärungen auf Abruf (ⓘ) |
| `lib/l10n/app_{de,en,es,fr,it}.arb` | Texte |

---

### Task 1: Rechte für alle, zehn Schalter pro Anteil

**Files:**
- Create: `lib/models/part_right.dart`
- Modify: `lib/models/permission.dart`, `lib/models/profile.dart:284-298`,
  `lib/modules/onboarding/post_login_welcome_screen.dart:238-405`
- Test: `test/models/part_right_test.dart`

**Interfaces:**
- Produces:
  - `Permission.perPart`: `bool`, benannter Konstruktorparameter mit
    Standard `false`.
  - `enum PartRightGroup { medication, others, management }`
  - `enum PartRight { seeMedication, changeMedicationPlan,
    changeOthersEntries, deleteOthersEntries, readOthersDiaries, createParts,
    pauseParts, grantRights, changeSettings, resetPasswords }` mit
    `PartRightGroup get group`, `Set<Permission> get permissions`,
    `PartRight? get requires` (nur `changeMedicationPlan` → `seeMedication`)
    und `IconData get icon`.
  - `enum PartRightState { on, partly, off }` und
    `PartRightState stateFor(Profile p)`: für Admins immer `on`. Sonst `on`,
    wenn alle eigenen Rechte gespeichert sind, `partly` bei einem Teil davon
    und `off` bei keinem.
  - `Set<Permission> applyTo(Set<Permission> granted, {required bool on})`:
    - an: setzt die eigenen Rechte und die von `requires`.
    - aus: nimmt die eigenen Rechte weg und dazu die aller Schalter, die
      diesen Schalter als `requires` haben.
  - `Profile.hasPermission(p)`: `true` bei Admin oder `!p.perPart`, sonst wie
    bisher der gespeicherte Wert. `hasAllPermissions` und `hasAnyPermission`
    laufen über `hasPermission`.

- [ ] **Step 1: Write the failing tests** in `test/models/part_right_test.dart`
  - `jedes Recht ist bewusst eingeordnet`: Die Namen mit `perPart` ergeben
    genau die 15 aus „Global Constraints“, als ausgeschriebene Liste im Test.
    So wird ein neues Recht im Enum rot statt still „für alle“.
  - `die zehn Schalter decken genau die Rechte pro Anteil ab`: Die
    Vereinigung aller `permissions` ist gleich
    `Permission.values.where((p) => p.perPart).toSet()`, und die Summe der
    Größen ist 15. Damit gibt es keine Überschneidung.
  - `Finder gilt für alle`: Ein Profil mit `permissions: []` gibt für
    `viewFinderTab`, `manageFinder`, `callEmergencyContacts`,
    `editEmergencyContacts` und `viewTimelineTab` `true` zurück.
  - `Medikamente sehen bleibt pro Anteil`: Dasselbe Profil gibt für
    `viewMedicationTab` `false` zurück.
  - `halb gesetzt bleibt, wie es war`: Nur `manageMedication` ist
    gespeichert → `changeMedicationPlan.stateFor` ist `partly`,
    `hasPermission(Permission.manageMedication)` ist `true` und
    `hasPermission(Permission.overrideMedicationLog)` ist `false`.
  - `Plan ändern zieht sehen mit`: `applyTo({}, on: true)` für
    `changeMedicationPlan` enthält alle vier Medikamentenrechte.
  - `sehen aus nimmt ändern mit`: `applyTo` mit allen vier Rechten und
    `on: false` für `seeMedication` ergibt die leere Menge.
  - `Vorlagen enthalten nur ganze Schalter`: Die Vorlagen `child` und
    `standard` aus `assets/config/permission_presets.json` (per `File`
    gelesen) ergeben für keinen Schalter `partly`. Erwartet wird
    `child` → {seeMedication} und `standard` → {seeMedication,
    changeOthersEntries, readOthersDiaries, changeSettings}.
- [ ] **Step 2:** `flutter test test/models/part_right_test.dart` → FAIL (`part_right.dart` fehlt)
- [ ] **Step 3:** Umsetzen.
  - In `permission.dart` bekommen die 15 Einträge `perPart: true`.
  - In `post_login_welcome_screen.dart` bekommt `_getFeatureList` statt
    `List<Permission> permissions` das `Profile`. Jede Abfrage
    `permissions.contains(Permission.x)` wird zu `profile.hasPermission(Permission.x)`.
    `parsedPermissions` wird dort nicht mehr gelesen. Das ist die einzige
    Stelle in `lib/`, die an `hasPermission` vorbei liest (geprüft am 29.10.).
- [ ] **Step 4:** `flutter test test/models/ test/modules/onboarding/` → PASS
- [ ] **Step 5:** Commit (nach Freigabe): `feat(rechte): 45 Rechte für alle, zehn Schalter pro Anteil`

### Task 2: Schalter setzen

**Files:**
- Modify: `lib/services/profile_service.dart:340-470`, `lib/core/data_entry.dart:322-360`
- Test: `test/services/part_right_service_test.dart`

**Interfaces:**
- Consumes: `PartRight.applyTo` (Task 1).
- Produces: `DataEntry.setPartRight(String profileId, PartRight right, bool on) → Future<bool>`,
  umgesetzt über `ProfileService.updateProfilePermissions` mit
  `applyTo(profile.parsedPermissions.toSet(), on: on).toList()`.

- [ ] **Step 1: Write the failing tests.** Hive-Muster wie
  `test/services/password_reset_service_test.dart`
  (`ProfileService(eventBus)` und `openBoxes()`).
  - `Nicht-Admin mit Rechte vergeben darf schalten`
  - `ohne Rechte vergeben bleibt alles, wie es war`: Ergebnis `false`, das
    Profil ist unverändert.
  - `Schalter an setzt alle seine Rechte`: `deleteOthersEntries` an → alle
    drei `deleteAll*` sind gespeichert.
- [ ] **Step 2:** Tests → FAIL
- [ ] **Step 3:** Umsetzen. Die Wache in `updateProfilePermissions` und
  `togglePermission` prüft
  `activeProfile?.hasPermission(Permission.managePermissions) != true` statt
  `isAdmin`. Heute bietet der Schirm Rechte an, deren Änderung für Nicht-Admins
  scheitert. `makeAdmin` und `revokeAdmin` bleiben nur für Admins.
- [ ] **Step 4:** Tests → PASS
- [ ] **Step 5:** Commit (nach Freigabe): `feat(rechte): Schalter pro Anteil setzen`

### Task 3: Pausieren wirkt wirklich

**Files:**
- Modify: `lib/services/profile_service.dart:295-320, 545-610`, `lib/core/data_entry.dart:183-202, 660-690`
- Test: `test/services/profile_pause_test.dart`

**Interfaces:**
- Produces auf `DataEntry` (ersetzt `deactivateProfile` und `reactivateProfile`):
  - `bool canPauseProfile(String profileId)`
  - `Future<bool> pauseProfile(String profileId)`
  - `Future<bool> resumeProfile(String profileId)`
  - `List<Profile> getPausedProfiles()`: `!isActive`, nach `name` sortiert
  - `bool canResumeProfiles()`: Das aktive Profil hat `deactivateProfiles`.
- In `ProfileService` gelten die Regeln an genau einer Stelle,
  `bool canPause(String profileId)`:
  - Das aktive Profil hat `deactivateProfiles`.
  - Das Ziel ist nicht das aktive Profil.
  - Das Ziel ist nicht der letzte aktive Admin.
  - Das Ziel existiert und ist aktiv.
- `resumeProfile` braucht dasselbe Recht wie Pausieren (`deactivateProfiles`)
  statt wie heute Admin. **Offen zur Durchsicht durch den Nutzer:** Ohne
  Recht zurückholen hieße, die Zeile „Pausierte Anteile“ stünde für jeden
  sichtbar vor dem Login, auch für Außenstehende mit dem Handy in der Hand.
  Symmetrisch ist die vorsichtigere Wahl.

- [ ] **Step 1: Write the failing tests**
  - `pausieren versteckt den Anteil`: Danach ist er nicht in `getProfiles()`,
    aber in `getPausedProfiles()` und in `getAllProfiles()`.
  - `pausieren über DataEntry ändert den Zustand`: Regression gegen das No-Op.
    `DataEntry.pauseProfile` aufrufen, danach `isActive == false`. Das
    DataEntry-Muster steht in `test/modules/profile/profile_edit_unsaved_changes_test.dart`.
  - `das eigene Profil lässt sich nicht pausieren`
  - `der letzte Admin lässt sich nicht pausieren`
  - `ohne Recht kein Pausieren`
  - `pausieren ändert nur isActive`: Name, Passwort-Hash, Rechte und Sprache
    bleiben gleich.
  - `wieder aufnehmen braucht dasselbe Recht wie pausieren`
- [ ] **Step 2:** Tests → FAIL
- [ ] **Step 3:** Umsetzen. `DataEntry.pauseProfile` ruft
  `_profileService.deactivateProfile` direkt auf und veröffentlicht danach
  weiter `ProfileDeactivatedEvent`. Der Handler wechselt bei Bedarf das aktive
  Profil. `resumeProfile` macht es entsprechend. Den einzigen Aufrufer
  (`profile_selection_screen.dart:923`) anpassen.
- [ ] **Step 4:** Tests → PASS
- [ ] **Step 5:** Commit (nach Freigabe): `fix(profile): Pausieren war wirkungslos`

### Task 4: Pausieren und Zurückholen in der Profilauswahl

**Files:**
- Create: `lib/modules/profile/widgets/pause_profile_dialog.dart`, `lib/modules/profile/widgets/paused_parts_sheet.dart`
- Modify: `lib/modules/profile/profile_selection_screen.dart:855-950` (Langdruck-Blatt, Dialog), Bereich unter dem Profilraster; `lib/widgets/profile_actions_dialog.dart`; ARB ×5
- Test: `test/modules/profile/pause_profile_flow_test.dart`

**Interfaces:**
- Consumes: Task 3 auf `DataEntry`.
- Produces: `Future<void> showPauseProfileDialog(BuildContext context, Profile profile)`,
  `Future<void> showPausedPartsSheet(BuildContext context)`.

**Texte** (DE und EN vorgegeben; FR, ES, IT mit den Verben von `medicationPause`
und `medicationResume`):

| Schlüssel | de | en |
|---|---|---|
| `profilePauseAction` | Pausieren | Pause |
| `profilePauseTitle(name)` | {name} pausieren? | Pause {name}? |
| `profilePauseMessage(name)` | {name} verschwindet aus der Auswahl. Nachrichten, Tagebuch und alles andere bleiben erhalten. Zurückholen geht jederzeit über „Pausierte Anteile“. | {name} leaves the selection. Messages, diary and everything else stay. You can bring {name} back any time under “Paused parts”. |
| `profilePausedSnack(name)` | {name} ist pausiert. | {name} is paused. |
| `profilePausedSection(count)` | Pausierte Anteile · {count} | Paused parts · {count} |
| `profileResumeAction` | Wieder aufnehmen | Bring back |
| `profileResumedSnack(name)` | {name} ist wieder da. | {name} is back. |
| `actionUndo` (falls nicht vorhanden) | Rückgängig | Undo |

`profileDeactivate`, `profileDeactivateTitle`, `profileDeactivateMessage` und
`profileDeactivated` werden in allen fünf ARB-Dateien entfernt.

**Verhalten**
- Antippen-Blatt (`ProfileActionsDialog`) und Langdruck-Blatt zeigen
  „Pausieren“ nur, wenn `canPauseProfile(profile.id)` gilt.
- Bestätigungsknöpfe: „Pausieren“ und „Abbrechen“, keine rote Farbe.
- Danach ein Snackbar mit „Rückgängig“, der `resumeProfile` aufruft.
- Unter dem Profilraster steht die Zeile „Pausierte Anteile · N“ (Pause-Symbol
  plus Wort) nur, wenn N > 0 und `canResumeProfiles()` gilt. Sonst steht
  nichts da.
- Antippen der Zeile öffnet das Blatt: je Anteil Avatar, Name und der Knopf
  „Wieder aufnehmen“, danach ein Snackbar `profileResumedSnack`.

- [ ] **Step 1: Write the failing widget tests**
  - `ohne Recht kein Pausieren-Knopf`
  - `mit Recht: Pausieren, bestätigen, Anteil weg, Zeile „Pausierte Anteile · 1“ da`
  - `Rückgängig holt ihn zurück`
  - `keine Zeile, wenn niemand pausiert ist`
  - `ohne Recht keine Zeile Pausierte Anteile`
  - `Wieder aufnehmen im Blatt`
  - `der Bestätigungsknopf heißt Pausieren, nicht Löschen`
- [ ] **Step 2:** Tests → FAIL
- [ ] **Step 3:** Umsetzen, ARB ×5, `flutter gen-l10n`.
- [ ] **Step 4:** Tests → PASS, `flutter analyze` ohne neue Befunde
- [ ] **Step 5:** Commit (nach Freigabe): `feat(profile): Anteile pausieren und zurückholen`

### Task 5: Schirm „Anteile & Rechte“

**Files:**
- Modify (umschreiben): `lib/modules/permissions/permissions_manager_screen.dart`, `lib/modules/permissions/permission_detail_screen.dart`; Eintrag in `lib/modules/settings/settings_screen.dart:1113-1166`; ARB ×5
- Test: `test/modules/permissions/parts_and_rights_test.dart`

**Interfaces:**
- Consumes: `PartRight` (Task 1), `DataEntry.setPartRight` (Task 2),
  `showPauseProfileDialog`, `showPausedPartsSheet` (Task 4).

**Aufbau**

*Liste:*
- Titel „Anteile & Rechte“. Kein Info-Kasten.
- Gruppe „Aktiv“: je Anteil Avatar, Name und eine Zeile:
  - Admin: „Administrator · darf alles“
  - sonst die Symbole der eingeschalteten Schalter, gedämpft
- Gruppe „Pausiert“, nur wenn es welche gibt: je Anteil „Wieder aufnehmen“.

*Detail:*
- Kopf mit Avatar, Name und Alter.
- **Admin:**
  - Eine ruhige Karte „Administrator · darf alles“.
  - Darunter „Admin-Rolle abgeben“, wenn erlaubt (bestehende Logik
    `_isFirstProfile`, `revokeAdmin`).
  - **Keine** Liste.
- **Kein Admin:**
  - Drei Gruppen mit Überschrift (Medikamente, Andere Anteile, Verwaltung).
  - Je Schalter ein `SwitchListTile` mit Symbol und Wort, ohne
    Beschreibungstext. Ein Schalter im Zustand `partly` steht auf aus und
    trägt die Unterzeile `rightsPartly` („Teilweise erlaubt“ bzw.
    „Partly allowed“).
  - Am Ende der Gruppe Verwaltung die Zeile „Zum Administrator machen“
    (bestehender Bestätigungsdialog).
- Ganz unten „{name} pausieren“ als ruhiger Textknopf, nur wenn
  `canPauseProfile`.

*Texte* (DE und EN, die anderen sinngemäß):

| Schlüssel | de | en |
|---|---|---|
| `partsAndRightsTitle` | Anteile & Rechte | Parts & rights |
| `partsActiveHeader` | Aktiv | Active |
| `partsPausedHeader` | Pausiert | Paused |
| `rightsAdminSummary` | Administrator · darf alles | Administrator · may do everything |
| Gruppen | Medikamente · Andere Anteile · Verwaltung | Medication · Other parts · Management |
| die 10 Schalter | wie in der Tabelle in „Global Constraints“ | See medication · Change medication plan · Change others' entries · Delete others' entries · Read others' diaries · Create parts · Pause parts · Grant rights · Change settings · Reset passwords |

Der Einstellungseintrag heißt ebenfalls „Anteile & Rechte“. Nicht mehr benutzte
`permissions*`-Schlüssel kommen aus allen ARB-Dateien, aber nur nach einem
`grep` auf andere Verwender.

- [ ] **Step 1: Write the failing widget tests**
  - `Admin sieht keine Schalter` (kein `SwitchListTile`, kein `Checkbox`)
  - `Nicht-Admin sieht genau zehn Schalter in drei Gruppen`
  - `Schalter Medikamente sehen schreibt die Rechte`
  - `halb gesetzter Schalter zeigt Teilweise erlaubt`
  - `Pausiert-Gruppe nur mit pausierten Anteilen`
  - `kein Warndreieck` (`Icons.warning` nicht im Baum)
- [ ] **Step 2:** Tests → FAIL
- [ ] **Step 3:** Umsetzen.
- [ ] **Step 4:** Tests → PASS
- [ ] **Step 5:** Commit (nach Freigabe): `feat(rechte): Anteile & Rechte statt sechzig Kästchen`

### Task 6: Einstellungen zerlegen, ohne etwas zu ändern

**Files:**
- Modify: `lib/modules/settings/settings_screen.dart`
- Create: `lib/modules/settings/sections/*.dart`, ein Widget je heutigem
  Abschnitt (Debug, Verwaltung, Global, Rechtliches, Diagnose,
  Benachrichtigungen, Karten, App)
- Test: `test/modules/settings/settings_layout_test.dart`

**Interfaces:**
- Produces: je Abschnitt ein Widget mit eigenem Zustand.
  `settings_screen.dart` setzt sie nur noch zusammen.

- [ ] **Step 1:** Vor dem Verschieben die Ursache des Scroll-Stopps suchen
  (offen laut Gedächtnis: am Gerät endet das Scrollen am Kartencache). Zu
  prüfen sind `PageStorageKey`, verschachtelte Scrollables, `shrinkWrap` und
  `AnimatedListView` (`settings_screen.dart:2348`). Hintergrund steht in der
  Gedächtnisnotiz „PageStorageKey kollidiert“. Den Befund als Kommentar im
  Test festhalten.
- [ ] **Step 2:** Sicherungstest `Abschnitte in heutiger Reihenfolge` schreiben.
  Er ist vor und nach dem Zerlegen grün, denn hier ändert sich kein Verhalten.
  DI-Muster aus `test/modules/profile/profile_selection_test_setup.dart`.
- [ ] **Step 3:** Die Abschnitte Datei für Datei herausziehen und den
  gefundenen Scroll-Fehler beheben.
- [ ] **Step 4:** `flutter test test/modules/settings/` → PASS, `flutter analyze` ohne neue Befunde
- [ ] **Step 5:** Commit (nach Freigabe): `refactor(einstellungen): Abschnitte in eigene Dateien`

### Task 7: Einstellungen aufräumen

**Files:**
- Modify: `lib/modules/settings/settings_screen.dart` und die Abschnitte aus
  Task 6, zusammengelegt zu
  `sections/{personal,notifications,location,about}_section.dart`
- Create:
  - `lib/modules/settings/screens/offline_maps_screen.dart`,
    `lib/modules/settings/screens/diagnostics_screen.dart`
  - `lib/modules/settings/widgets/settings_info_sheet.dart`
- Test: `test/modules/settings/settings_layout_test.dart`

**Reihenfolge und Inhalt des Hauptschirms**, jede Gruppe mit Überschrift,
höchstens fünf Zeilen:
1. **Für dich:** Sprache, Zeitformat. Die bestehenden Dialoge bleiben.
2. **Benachrichtigungen (ⓘ):** „Erinnerungen ohne Inhalt“ als Schalter,
   „Test-Benachrichtigung senden“.
3. **Karten & Standort:**
   - „Standort“: Zustandswort plus genau eine Handlung je Zustand
     (Freigeben, Einschalten, In Android öffnen). Bei „dauerhaft verweigert“
     öffnet die Handlung ein Blatt mit den bestehenden Schritt-Texten.
   - „Tracking dauerhaft an“ (ⓘ): Schalter mit einzeiliger Unterzeile, wie
     bisher geschützt.
   - „Karten offline“ → `OfflineMapsScreen`: Cache, Limit, Vorab-Laden, Leeren.
4. **Anteile & Rechte:** eine Zeile, Schutz wie bisher.
5. **Über Aurora:**
   - Was Aurora sendet, Datenschutzerklärung, Impressum
   - Diagnose → `DiagnosticsScreen`: Debug-Log sowie Warteschlange und
     geplante Benachrichtigungen
   - App-Version
6. Debug-Abschnitt (nur `kDebugMode`) unverändert am Ende.

**Vom Hauptschirm hinter ⓘ** (`showSettingsInfoSheet`), die Texte bleiben
erhalten:
- zu Benachrichtigungen: `settingsHowNotificationsWork` samt Aufzählung
- zu Tracking: `settingsWhatIsAlwaysOn`, `settingsAdminTrackingExplanation`,
  die vier Punkte, `settingsTrackingNotice`, `settingsLocationStaysOffline`

**Ganz weg:** `settingsMapsSubtitle`.

- [ ] **Step 1: Write the failing widget tests**
  - `Abschnitte in fester Reihenfolge`
  - `keine Erklärtexte auf dem Hauptschirm`: der Text zu
    `settingsWhatIsAlwaysOn` und `settingsHowNotificationsWork` nicht gefunden
  - `ⓘ zeigt die Erklärung`
  - `Diagnose enthält die Warteschlange`

  Für die DI das Muster aus `test/modules/profile/profile_selection_test_setup.dart`
  nehmen. Keine `pumpAndSettle` auf Kartenflächen, Gedächtnisnotiz
  „Widgettests hängen“.
- [ ] **Step 2:** Tests → FAIL
- [ ] **Step 3:** Umsetzen.
- [ ] **Step 4:** Tests → PASS
- [ ] **Step 5:** Commit (nach Freigabe): `refactor(einstellungen): Zustand und Handlung statt Erklärung`

### Task 8: Abnahme am Gerät

- [ ] `flutter gen-l10n`: Datei für unübersetzte Texte leer.
  `flutter analyze`: keine neuen Befunde. `flutter test`: alles grün.
- [ ] `flutter build apk --release --build-name=3.0.32 --build-number=32`
- [ ] Am A14, Profil Probe (Admin):
  - Guf pausieren → verschwindet, „Pausierte Anteile · 1“ steht da →
    „Wieder aufnehmen“ → Guf ist zurück.
  - Rückgängig im Snackbar prüfen.
  - Einstellungen: Reihenfolge, ⓘ, Karten offline, Diagnose, **bis ganz
    unten scrollen**.
  - Anteile & Rechte: Admin-Karte ohne Liste.
- [ ] Schalter eines Nicht-Admins **nur am Emulator `PA_A14_Emu`** prüfen,
  nicht am privaten A14. Dort einen Testanteil anlegen: „Medikamente sehen“
  aus → Kachel Medikamente weg, Finder weiter da.
- [ ] Antwortentwurf an die Person vom 27.10. neu schreiben: Pausieren über
  das Antippen-Blatt, Zurückholen über „Pausierte Anteile“. Der Nutzer
  verschickt ihn.
