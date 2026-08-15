# Zustandseigentum: die Settings-Box bekommt einen Eigentümer

**Stand:** 10. August 2026
**Auslöser:** vier Befunde aus dem ersten Codex-Review (PR #28)

## Das Problem

Vier Befunde, ein Prinzip. Wichtige Begriffe der App sind keine Typen, sondern
verstreute Primitive, und nichts erzwingt, wer sie besitzt.

Der Beweis steht in `lib/core/data_entry.dart:642`:

```dart
/// Zugriff auf Settings-Box für ValueListenableBuilder (reaktiv)
Box<dynamic> get settingsBox => _profileService.settingsBox;
```

Die Architektur verbietet der Oberfläche den direkten Dienstzugriff
(`no_direct_service_access`) und reicht ihr dann die rohe Hive-Box durch.
Gezählt: **23 Zugriffe auf `settingsBox` außerhalb von `lib/core` und
`lib/services`, davon 7 schreibend.** Die Oberfläche schreibt in die Datenbank.

So entsteht der gefährlichste der vier Befunde.
`lib/services/location_tracking_service.dart:264` trennt absichtlich und
kommentiert zwei Dinge — „der Laufzustand kippt, der Wunsch bleibt".
`lib/modules/settings/settings_screen.dart:591` liest den **Wunsch** und schließt
daraus, die Aufzeichnung **laufe**:

```dart
final isTrackingEnabled = settingsBox.get('gps_tracking_enabled', defaultValue: false) as bool;
if (!isTrackingEnabled) { await _trackingService.toggleTracking(); }
```

Ist der Positions-Strom vorher abgebrochen (GPS aus, Berechtigung entzogen,
Dienst gestorben), steht der Wunsch auf `true` und es läuft nichts. Weil der
Wunsch `true` ist, wird **nicht** gestartet. Der Mensch bestätigt „immer an" und
bekommt Stille — bei einer Funktion, deren Kernnutzen „wo war ich?" nach einem
Blackout ist.

Dasselbe Muster in den anderen drei Befunden:

| Befund | Ort | Wurzel |
|---|---|---|
| Löschen unvollständig, trotzdem Neustart | `lib/widgets/startup_failure_screen.dart:73` | `DeleteAllResult` trägt die fehlgeschlagenen Schritte; zwei von drei Aufrufern werten es aus, nichts zwingt den dritten |
| Startwiederholung nicht idempotent | `lib/main.dart:567` | `getIt.reset()` räumt die DI, nicht die globale Hive-Adapterregistratur |
| Termine verschwinden bei Zeitumstellung | `lib/modules/calendar/calendar_view_logic.dart:67` | Ein Kalendertag wird als `Duration(hours: 24)` gerechnet |

Regeln leben in Kommentaren und Disziplin. Aurora hat aber bereits den
Kreislauf, der das löst: sechs eigene Lints, jede aus einem echten Schaden
geboren. Der Kreislauf hat zwei blinde Flecken — **Zustandseigentum** und
**Ergebnisse, die man nicht ignorieren darf**.

## Was wir nicht tun

Kein Wechsel der Zustandsverwaltung, keine Repository-Schicht über alle Boxen,
kein Umbau von `DataEntry`, keine Migration der Profil- oder Nachrichtenboxen.
Die Evidenz zeigt Löcher in der Erzwingung, nicht im Entwurf. Nur die
Settings-Box wird angefasst, weil nur dort der Durchgriff nachgewiesen ist.

## Der Entwurf

### 1. `AppSettings` besitzt die Box

Neu unter `lib/core/settings/`. Hält die Hive-Box **privat** und bietet je
Schlüssel einen benannten, typisierten Zugang statt `get('...') as bool`.

Inventar aus dem Code, 15 Schlüssel:

| Schlüssel | Stellen | Art |
|---|---|---|
| `active_profile_id` | 5 | String? |
| `gps_tracking_enabled` | 4 | wandert in `TrackingState`, siehe unten |
| `selected_locale` | 3 | String? |
| `global_tracking_always_on` | 3 | bool |
| `pre_onboarding_dismissed` | 2 | bool |
| `current_page_index` | 2 | int |
| `time_format_preference` | 1 | String |
| `debug_mode_enabled` | 1 | bool |
| `post_login_welcome_dismissed_<profilId>` | 1 | bool, je Profil |
| Migrations- und Hinweismarken (`kMigrationKey`, `_resetMigrationNoticeKey`, `kDiscreetRemindersKey`, `kReminderPermissionAskedKey`, `_lastSeenTimestampKey`, `storageKey`) | je 1–2 | bereits als Konstanten, wandern mit |

`DataEntry.settingsBox` entfällt. `DataEntry` delegiert an `AppSettings`; der Weg
der Oberfläche bleibt derselbe, nur ohne rohen Durchgriff.

**Reaktivität ist der kritische Punkt.** Heute bekommt die Oberfläche die Box
für `ValueListenableBuilder`. Ersatz: `AppSettings` gibt je Schlüssel ein
`ValueListenable<T>`. Ohne das bricht die Umstellung genau dort, wo sie die
meisten Stellen berührt.

### 2. Der Aufzeichnungszustand ist kein Schlüssel, sondern ein Objekt

```dart
class TrackingState {
  const TrackingState({required this.gewuenscht, required this.laeuft});
  final bool gewuenscht;  // persistent, überlebt den Neustart
  final bool laeuft;      // Laufzeit, kippt beim Stromabbruch
}
```

Eigentümer ist `LocationTrackingService`. Der Wunsch bleibt persistent in der
Box, der Laufzustand ist Laufzeit. `global_tracking_always_on` wandert
**nicht** mit hinein: es ist eine Voreinstellung des Menschen („immer
aufzeichnen"), kein Zustand der Aufzeichnung, und bleibt ein typisierter
Schlüssel in `AppSettings`. Konsumenten sehen ausschließlich
`ValueListenable<TrackingState>`; `gps_tracking_enabled` ist außerhalb des
Dienstes nicht mehr lesbar.

Damit ist `settings_screen.dart:591` nicht mehr reparaturbedürftig, sondern
unmöglich: es gibt kein Feld mehr, das „gewünscht" heißt und „läuft" bedeuten
könnte. Die richtige Frage an dieser Stelle ist `state.laeuft`.

### 3. Die Erzwingung

**Neue Lint `no_raw_settings_box`** in `dis_app_lints/`: `get`, `put` und
`listenable` auf der Settings-Box außerhalb von `lib/core/settings/` und
`lib/services/` sind ein Fehler. Zusätzlich darf `DataEntry` keinen `Box`-Typ
mehr nach außen geben. Ohne diese Regel wandert der Durchgriff in drei Monaten
zurück.

**Ergebnisse, die man nicht ignorieren darf:** `@useResult` auf
`deleteAllLocalData()`; `unused_result` in `analysis_options.yaml` auf `error`.
`meta` liegt bisher nur transitiv im Lock und wird direkte Abhängigkeit.

**Start als Transaktion:** Adapterregistrierung guarden
(`Hive.isAdapterRegistered`), damit ein zweiter Anlauf nicht über die
Nebenwirkungen des ersten stolpert.

**Kalendertag statt Zeitspanne:** `DateUtils.addDaysToDate` / `DateUtils.dateOnly`
statt 24 Stunden zu addieren.

### 4. Fehlerbehandlung

Typisierte Zugänge tragen ihren Vorgabewert selbst; `as bool` in der Oberfläche
entfällt ersatzlos. Beim Aufzeichnungszustand bleibt das Verhalten wie heute
kommentiert — Stromabbruch setzt `laeuft` auf `false`, der Wunsch bleibt
bestehen —, nur ist die Trennung jetzt sichtbar statt vereinbart.

Der Löschpfad wertet das `DeleteAllResult` aus: bleiben Schritte übrig, wird
**nicht** stillschweigend neu gestartet, sondern gesagt, was nicht gelöscht
werden konnte.

### 5. Tests

Jede Regel bekommt ihren Beweisfall im selben PR:

- Wunsch `true`, Lauf `false` → der Pfad in `settings_screen` startet die
  Aufzeichnung (heute nicht)
- Start zweimal durchlaufen lassen
- Löschen mit einem fehlgeschlagenen Schritt → kein stiller Neustart
- Kalenderansicht am Tag der Zeitumstellung, Termin um 00:30
- je neuer Lint ein Regeltest

Keine Datenmigration: die Schlüssel bleiben unverändert, nur ihre Tür ändert
sich.

## Reihenfolge

| PR | Inhalt | Warum getrennt |
|---|---|---|
| **0** | Arbeitsbaum klären (94 Dateien aus dem `dart fix`-Lauf prüfen), `main` pushen | Sonst ist jeder Refactor-Diff mit Formatierungsrauschen vermischt und jedes Review wertlos |
| **1** | `@useResult`, Start-Guard, Kalendertag — samt Beweisfällen | Klein, unstrittig, prüft nebenbei das frisch eingerichtete Codex-Review |
| **2** | `AppSettings`, `TrackingState`, 23 Aufrufstellen, Lint `no_raw_settings_box` | Breiter Diff, braucht ein sauberes Fundament |

Danach gehören die neuen Regeln in `AGENTS.md`, damit der automatische Reviewer
sie kennt.

## Risiken

- **Breiter Diff in PR 2.** 23 Aufrufstellen in Oberflächendateien. Gegenmittel:
  PR 0 zuerst, und die Umstellung schlüsselweise committen statt in einem Rutsch.
- **Reaktivität.** Wenn `ValueListenable` je Schlüssel nicht sauber trägt,
  flackern Oberflächen oder aktualisieren nicht mehr. Das ist der Teil, der
  zuerst gebaut und zuerst getestet wird.
- **`unused_result: error` schlägt breiter zu als erwartet.** Möglich, dass
  weitere Stellen im Bestand Ergebnisse verwerfen. Das ist kein Schaden, aber
  Arbeit — vor dem Heben einmal messen.

## Beim Bauen geändert: kein `TrackingState`

Der Entwurf oben verlangt ein `TrackingState`-Objekt. Beim Umsetzen zeigte das
Nachzählen, dass die Trennung im Code bereits existiert:

- `_isTrackingEnabled` im Dienst ist der **Laufzustand** und wird von sechs
  Dateien gelesen — überall richtig
- `gps_tracking_enabled` in der Box ist der **Wunsch** und wurde nur im Dienst
  geschrieben
- **genau eine** Stelle las das Falsche: `settings_screen.dart:591`

Ein `TrackingState`-Objekt hätte sechs korrekte Aufrufstellen umgebaut, um einen
Fehler an einer einzigen zu beheben. Gebaut wurde stattdessen:

1. die falsche Stelle fragt jetzt den Laufzustand
2. `isTrackingEnabled` heißt `isTrackingRunning` — der alte Name klang nach dem
   Wunsch und lud zur Verwechslung ein
3. der Schlüssel liegt als private Konstante im Dienst
4. die Lint `no_raw_tracking_flag` verbietet ihn außerhalb von `lib/services/`

Das schließt dieselbe Klasse. Käme später ein dritter Zustand dazu — etwa
„pausiert, weil der Akku schwach ist" —, wäre `TrackingState` wieder die
richtige Antwort. Heute wäre es Zeremonie.

Die Aufgaben 5 und 7 des Plans (`AppSettings` für die übrigen 14 Schlüssel)
bleiben offen und sinnvoll, sind aber Vorsorge, kein Fehler: von den 15
Schlüsseln hatte nur dieser eine zwei Bedeutungen.
