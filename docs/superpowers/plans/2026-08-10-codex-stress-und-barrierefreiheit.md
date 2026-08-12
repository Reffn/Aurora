# Codex-Durchlauf 10.08.2026 — Stress und Barrierefreiheit: Umsetzungsplan

> **Für agentische Arbeiter:** ERFORDERLICHE UNTER-SKILL: `superpowers:subagent-driven-development` (empfohlen) oder `superpowers:executing-plans`, um diesen Plan Aufgabe für Aufgabe umzusetzen. Die Schritte nutzen Checkbox-Syntax (`- [ ]`) zur Verfolgung.

**Ziel:** Die fünf bestätigten Befunde aus `docs/superpowers/specs/2026-08-10-codex-stress-und-barrierefreiheitsdurchlauf.md` beheben, sodass Zeit, Ort, Identität und die drei Krisenwege auch bei 200 % Systemschrift, ohne Standortrecht und ohne angelegte Notfallkontakte lesbar und erreichbar bleiben.

**Architektur:** Drei Eingriffsarten. Erstens Layout: feste dp-Höhen fallen dort weg, wo Text sie sprengt — die Zeitkarte gibt den Standorthinweis aus dem `Stack` frei, die Profilauswahl wird oberhalb einer Schriftschwelle als Ganzes rollbar. Zweitens Reihenfolge: im Notfall steht menschliche Hilfe vor der Systemberechtigung, im Anker bleiben die `solid`-Gruppen angeheftet. Drittens Semantik: die Doppelansagen werden an den gemeinsamen Bausteinen behoben (`AnchorRow`, `QuickTimelineBand`, Info-Knopf), nicht pro Schirm. Alle drei Arten bekommen ein gemeinsames Testfundament (Aufgabe 1), damit „bei 200 % ohne Überlagerung" prüfbar wird statt behauptet.

**Tech-Stack:** Flutter (Material 3), `flutter_test`, `flutter gen-l10n` (ARB in `lib/l10n/`), Hive, GetIt, `flutter_map` über `OverviewMap`.

## Globale Randbedingungen

- **Paketname:** Das Dart-Paket heißt `dis_app`, nicht `aurora`. Jeder Import lautet `package:dis_app/…`.
- **Oberflächenregeln:** `docs/oberflaechen-richtlinien.md` gilt für jede sichtbare Änderung. Vor Aufgabe 2 einmal ganz lesen. Besonders: Wahlflächen und Inhaltsflächen sind nicht dasselbe; gesättigte Farbe bleibt dem vorbehalten, was im schlechtesten Zustand gefunden werden muss.
- **Schrift nie begrenzen:** Kein `MediaQuery.withNoTextScaling`, kein `textScaler`-Clamp, kein fester `fontSize`-Ersatz für Systemschrift. Große Systemschrift ist bei dieser Zielgruppe Selbsthilfe.
- **API:** `MediaQuery.textScalerOf(context)` und `TextScaler` verwenden. `textScaleFactor` ist abgekündigt und wird nicht neu eingeführt.
- **Sprachen:** Jede neue oder geänderte Zeichenkette wandert in **alle fünf** ARB-Dateien: `lib/l10n/app_de.arb`, `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_it.arb`. Danach `flutter gen-l10n`. Die generierten `lib/l10n/app_localizations*.dart` werden nie von Hand bearbeitet.
- **Testschwellen:** Jeder neue Layouttest läuft bei `TextScaler.linear(1.0)`, `1.5` und `2.0` auf beiden Gerätehöhen: A14 `Size(1080, 2408)` bei `devicePixelRatio 2.4`, S24 `Size(1080, 2340)` bei `devicePixelRatio 3.0`.
- **Datenarchitektur:** Lesen und Schreiben nur über `DataEntry` (`lib/core/data_entry.dart`). Keine direkte Service-Mutation.
- **Protokoll:** `logger.error` kennt kein `error:`-Argument — Ausnahmen über `data:` durchreichen.
- **Beweise vor Behauptungen:** Kein Schritt gilt als fertig, bevor der genannte Befehl gelaufen ist und seine Ausgabe gesehen wurde.
- **Nicht committen:** `build/codex-audit-2026-08-10/` enthält reale Profil- und Standortdaten.

## Getroffene Produktentscheidungen

| Befund | Entscheidung | Begründung |
|---|---|---|
| **S1** | Durchgehend rollbar bei großer Schrift | Robust gegen jede Schriftgröße und lange spanische Texte; nur ein Layout zu pflegen |
| **S3** | „Halt", „Notfall", „Hilfe" dauerhaft angeheftet | Der Schnellweg muss mit einem Griff auffindbar sein, unabhängig davon, wo die Liste zuletzt stand |
| **D1** | **So lassen** — genaue Standortspur bleibt vor der Profilwahl | Orientierung („wo war ich?" nach einem Blackout) wiegt hier schwerer als lokale Vertraulichkeit auf dem entsperrten Gerät. Bewusst entschieden am 10.08.2026, nicht beiläufig. Wird in Aufgabe 10 dokumentiert, damit die Abwägung auffindbar bleibt |

## Dateiübersicht

| Datei | Verantwortung nach dem Umbau |
|---|---|
| `test/support/text_scale_harness.dart` | **Neu.** Gerätegrößen, Schriftfaktoren, Überlappungs- und Sichtbarkeitszusicherungen, Semantik-Inventar |
| `lib/widgets/time_map.dart` | Karte mit Kopfstrang; der Standorthinweis liegt **unter** der Karte, nicht mehr darüber |
| `lib/modules/profile/profile_selection_screen.dart` | Profilauswahl; oberhalb der Schriftschwelle eine einzige Rollfläche. Info-Knopf mit Beschriftung |
| `lib/modules/emergency/emergency_screen.dart` | Notfall; Kontakte bzw. Leerzustand zuerst, Karte danach, `showUserLocation: false` ausdrücklich |
| `lib/modules/anchor/anchor_menu_screen.dart` | Anker; `solid`-Gruppen als fester Kopf, Rest rollt |
| `lib/modules/anchor/anchor_row.dart` | Zeile; ein Semantikknoten statt zwei |
| `lib/widgets/quick_timeline_band.dart` | Zeitband; die Handlung bekommt einen Namen |
| `lib/screens/feedback_thank_you_screen.dart` | Dank genau einmal, Ausgang oben |
| `lib/l10n/app_*.arb` | Neue Knöpfe im Notfall-Leerzustand, entdoppeltes `mapLastKnownPosition`, Semantiktexte |

---

### Aufgabe 1: Testfundament für Schriftfaktor und Semantik

**Dateien:**
- Anlegen: `test/support/text_scale_harness.dart`
- Anlegen: `test/support/text_scale_harness_test.dart`

**Schnittstellen:**
- Erzeugt: `pumpScaled(WidgetTester, Widget, {double scale, Size deviceSize, double pixelRatio, Locale locale})`, `rectOf(WidgetTester, Finder) → Rect`, `expectNoOverlap(WidgetTester, Finder, Finder)`, `expectFullyVisible(WidgetTester, Finder)`, `expectNoUnlabeledTapTargets(WidgetTester)`, `labelOfTapTarget(WidgetTester, String contains) → String`, sowie die Konstanten `geraetA14`, `geraetS24`.
- Alle folgenden Aufgaben nutzen ausschließlich diese Helfer für Schriftfaktor-Tests.

- [ ] **Schritt 1: Den fehlschlagenden Test schreiben**

`test/support/text_scale_harness_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'text_scale_harness.dart';

void main() {
  testWidgets('erkennt zwei uebereinanderliegende Texte', (tester) async {
    await pumpScaled(
      tester,
      const Stack(
        children: [
          Positioned(top: 0, left: 0, child: Text('oben', key: Key('a'))),
          Positioned(top: 0, left: 0, child: Text('auch oben', key: Key('b'))),
        ],
      ),
      scale: 1,
    );

    expect(
      () => expectNoOverlap(tester, find.byKey(const Key('a')), find.byKey(const Key('b'))),
      throwsA(isA<TestFailure>()),
    );
  });

  testWidgets('erkennt einen klickbaren Knoten ohne Beschriftung', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScaled(
      tester,
      InkWell(onTap: () {}, child: const SizedBox(width: 40, height: 40)),
      scale: 1,
    );

    expect(() => expectNoUnlabeledTapTargets(tester), throwsA(isA<TestFailure>()));
    handle.dispose();
  });

  testWidgets('erkennt einen abgeschnittenen Text', (tester) async {
    await pumpScaled(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(top: 4000),
          child: Text('weit unten', key: Key('c')),
        ),
      ),
      scale: 1,
    );

    expect(
      () => expectFullyVisible(tester, find.byKey(const Key('c'))),
      throwsA(isA<TestFailure>()),
    );
  });
}
```

- [ ] **Schritt 2: Test laufen lassen, Fehlschlag bestätigen**

Ausführen: `flutter test test/support/text_scale_harness_test.dart`
Erwartet: FEHLSCHLAG mit `Target of URI doesn't exist: 'text_scale_harness.dart'`.

- [ ] **Schritt 3: Den Helfer schreiben**

`test/support/text_scale_harness.dart`:

```dart
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Samsung A14: 1080x2408 bei 450 dpi.
const geraetA14 = (size: Size(1080, 2408), ratio: 2.4);

/// Samsung S24: 1080x2340 bei 480 dpi.
const geraetS24 = (size: Size(1080, 2340), ratio: 3.0);

/// Baut [kind] unter festem Schriftfaktor und fester Gerätegröße.
///
/// Der Schriftfaktor kommt über `MediaQuery`, nicht über einen Theme-Umweg:
/// Genau so setzt Android die Systemschrift, und genau dort ist der Bruch
/// vom 10. August 2026 entstanden.
Future<void> pumpScaled(
  WidgetTester tester,
  Widget kind, {
  double scale = 1.0,
  Size deviceSize = const Size(1080, 2340),
  double pixelRatio = 3.0,
  Locale locale = const Locale('de'),
}) async {
  tester.view.physicalSize = deviceSize;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, kern) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: kern!,
      ),
      home: kind,
    ),
  );
  await tester.pumpAndSettle();
}

/// Das Bildschirmrechteck eines Elements.
Rect rectOf(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Die sichtbare Fläche in logischen Pixeln.
Rect sichtbareFlaeche(WidgetTester tester) =>
    Offset.zero & (tester.view.physicalSize / tester.view.devicePixelRatio);

/// Zwei Elemente dürfen sich nicht überdecken.
///
/// `Stack`-Layouts werfen keinen Overflow, wenn sie einander verdecken. Nur
/// der Rechteckvergleich sieht das.
void expectNoOverlap(WidgetTester tester, Finder a, Finder b) {
  final ra = rectOf(tester, a);
  final rb = rectOf(tester, b);
  expect(
    ra.overlaps(rb),
    isFalse,
    reason: 'Ueberlagerung: $ra schneidet $rb',
  );
}

/// Das Element liegt vollständig innerhalb des Bildschirms.
void expectFullyVisible(WidgetTester tester, Finder finder) {
  final r = rectOf(tester, finder);
  final schirm = sichtbareFlaeche(tester);
  final drin = r.left >= schirm.left - 0.5 &&
      r.top >= schirm.top - 0.5 &&
      r.right <= schirm.right + 0.5 &&
      r.bottom <= schirm.bottom + 0.5;
  expect(drin, isTrue, reason: 'Abgeschnitten: $r liegt nicht ganz in $schirm');
}

void _walk(SemanticsNode node, void Function(SemanticsNode) besuch) {
  besuch(node);
  node.visitChildren((kind) {
    _walk(kind, besuch);
    return true;
  });
}

/// Jeder klickbare Knoten trägt eine Beschriftung.
///
/// Ein leerer „Button" zwingt Vorlesehilfen zum Probieren. Das ist bei
/// wechselnden kognitiven Zuständen besonders teuer.
void expectNoUnlabeledTapTargets(WidgetTester tester) {
  final wurzel = tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
  expect(wurzel, isNotNull, reason: 'Kein Semantikbaum — ensureSemantics() vergessen?');

  final fehler = <String>[];
  _walk(wurzel!, (node) {
    final daten = node.getSemanticsData();
    if (daten.hasAction(SemanticsAction.tap) && daten.label.trim().isEmpty) {
      fehler.add('Knoten ${node.id} bei ${node.rect}');
    }
  });

  expect(
    fehler,
    isEmpty,
    reason: 'Klickbare Knoten ohne Beschriftung:\n${fehler.join('\n')}',
  );
}

/// Die Beschriftung des einen klickbaren Knotens, der [teil] enthält.
///
/// Schlägt fehl, wenn keiner oder mehrere passen — dann ist die Ansage
/// doppelt und der Test soll das sehen.
String labelOfTapTarget(WidgetTester tester, String teil) {
  final wurzel = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
  final treffer = <String>[];
  _walk(wurzel, (node) {
    final daten = node.getSemanticsData();
    if (daten.hasAction(SemanticsAction.tap) && daten.label.contains(teil)) {
      treffer.add(daten.label);
    }
  });
  expect(treffer, hasLength(1), reason: 'Erwartet genau einen klickbaren Knoten mit "$teil", gefunden: $treffer');
  return treffer.single;
}
```

- [ ] **Schritt 4: Test laufen lassen, Erfolg bestätigen**

Ausführen: `flutter test test/support/text_scale_harness_test.dart`
Erwartet: BESTANDEN, 3 Tests.

- [ ] **Schritt 5: Festschreiben**

```bash
git add test/support/text_scale_harness.dart test/support/text_scale_harness_test.dart
git commit -m "test: Fundament fuer Schriftfaktor- und Semantikpruefungen"
```

---

### Aufgabe 2: S1a — Der Standorthinweis verlässt den Kartenstapel

**Dateien:**
- Ändern: `lib/widgets/time_map.dart:475-564` (Aufbau der Karte), `lib/widgets/time_map.dart:929-981` (`_LocationNotice`)
- Test: `test/widgets/time_map_text_scale_test.dart` (neu)

**Schnittstellen:**
- Verbraucht: `pumpScaled`, `expectNoOverlap`, `geraetA14`, `geraetS24` aus Aufgabe 1.
- Erzeugt: `TimeMap` behält seine öffentliche Signatur. `height` bedeutet ab jetzt ausdrücklich **die Höhe der Kartenfläche**, nicht die Gesamthöhe des Widgets — ohne Standortrecht wächst das Widget um die Höhe des Hinweises. Aufgabe 3 rechnet damit.

**Hintergrund:** `_LocationNotice` liegt in `time_map.dart:536-556` als `Positioned(bottom: 0)` im selben `Stack` wie der Kopfstrang bei `top: 0`. Bei großer Schrift wird der Erklärungstext mehrzeilig, wächst nach oben und läuft in den Kopf mit Datum, Uhrzeit und Ort. Ein `Stack` wirft dabei keinen Overflow — deshalb war in den Logs nichts zu sehen.

- [ ] **Schritt 1: Den fehlschlagenden Test schreiben**

`test/widgets/time_map_text_scale_test.dart`:

```dart
import 'package:dis_app/widgets/time_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/text_scale_harness.dart';

void main() {
  // Die Karte wird ohne Dienste gebaut: reine Anzeigelogik, keine Hive-Box.
  Widget karte() => const Scaffold(
        body: TimeMap(
          height: 200,
          spans: [],
          past: [],
          upcoming: [],
          switchEvents: [],
          hasGpsPermission: false,
          nowOverride: null,
        ),
      );

  for (final geraet in [geraetA14, geraetS24]) {
    for (final skala in [1.0, 1.5, 2.0]) {
      testWidgets('Kopf und Standortbitte ueberlagern sich nicht — $skala', (tester) async {
        await pumpScaled(
          tester,
          karte(),
          scale: skala,
          deviceSize: geraet.size,
          pixelRatio: geraet.ratio,
        );

        expectNoOverlap(
          tester,
          find.byKey(TimeMap.kopfSchluessel),
          find.byKey(TimeMap.standortHinweisSchluessel),
        );
      });
    }
  }
}
```

Falls `TimeMap` keinen dienstfreien Konstruktor hat: den Test stattdessen über `TimeMap.fromServices` bauen und die nötigen Dienste in `setUp` über `getIt` registrieren, wie es `test/widgets/` bereits für andere Kartenflächen tut. Die Zusicherung bleibt unverändert.

- [ ] **Schritt 2: Test laufen lassen, Fehlschlag bestätigen**

Ausführen: `flutter test test/widgets/time_map_text_scale_test.dart`
Erwartet: FEHLSCHLAG — `kopfSchluessel` und `standortHinweisSchluessel` sind nicht definiert.

- [ ] **Schritt 3: Umbauen**

In `lib/widgets/time_map.dart`, in der Klasse `TimeMap` zwei Schlüssel ergänzen:

```dart
  /// Der Kopfstrang mit Datum, Uhrzeit und Ort.
  static const kopfSchluessel = Key('time-map-kopf');

  /// Der Hinweis, dass der Standort fehlt.
  static const standortHinweisSchluessel = Key('time-map-standort-hinweis');
```

Den Aufbau ab `time_map.dart:475` so ändern, dass der Hinweis **unter** der Karte steht statt darin:

```dart
    final stapel = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            OverviewMap(
              // ... unverändert ...
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _Strand(
                key: TimeMap.kopfSchluessel,
                fromTop: true,
                // ... übrige Argumente unverändert ...
              ),
            ),
            // Der Zukunftsstrang bleibt im Stapel: Er trägt nur Marken, keine
            // wachsenden Erklärungstexte, und gehört optisch auf die Karte.
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: getIt<GpsManager>().hasGpsPermission,
                builder: (context, allowed, strand) =>
                    allowed ? strand! : const SizedBox.shrink(),
                child: _Strand(
                  fromTop: false,
                  // ... übrige Argumente unverändert ...
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Der Standorthinweis steht unter der Karte, nicht darin.
    //
    // Er lag als `Positioned(bottom: 0)` im selben Stapel wie der Kopf. Bei
    // großer Systemschrift wird sein Erklärungstext mehrzeilig, wächst nach
    // oben und deckt Datum, Uhrzeit und Ort zu — genau die Angaben, für die
    // diese Karte da ist. Ein Stapel wirft dabei keinen Overflow; in den
    // Logs vom 10. August 2026 war deshalb nichts zu sehen, am Gerät alles.
    final map = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        stapel,
        ValueListenableBuilder<bool>(
          valueListenable: getIt<GpsManager>().hasGpsPermission,
          builder: (context, allowed, _) => allowed
              ? const SizedBox.shrink()
              : const _LocationNotice(key: TimeMap.standortHinweisSchluessel),
        ),
      ],
    );

    if (onTap == null) return map;
    return GestureDetector(onTap: onTap, child: map);
```

`_LocationNotice` in `time_map.dart:929-981` auf umbruchfähiges Layout stellen und den Konstruktor um den Schlüssel erweitern:

```dart
class _LocationNotice extends StatelessWidget {
  const _LocationNotice({super.key});
```

und im `build` die `Row` durch ein `Wrap` ersetzen, damit der Knopf bei großer Schrift unter den Text rutscht statt ihn zu quetschen:

```dart
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                // Ohne Deckel wächst die Zeile ins Unendliche und schiebt den
                // Knopf aus dem Bild. Mit Deckel bricht sie um.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width - 80,
                  ),
                  child: Text(
                    l10n.mapLocationNeeded,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            TextButton(onPressed: _ask, child: Text(l10n.mapLocationAllow)),
          ],
        ),
      ),
```

Der Verlauf im `DecoratedBox` darüber bleibt: Er trennt den Hinweis weiterhin sichtbar von der Karte.

- [ ] **Schritt 4: Test laufen lassen, Erfolg bestätigen**

Ausführen: `flutter test test/widgets/time_map_text_scale_test.dart`
Erwartet: BESTANDEN, 6 Tests.

- [ ] **Schritt 5: Bestandstests der Karte laufen lassen**

Ausführen: `flutter test test/widgets/ test/modules/profile/`
Erwartet: BESTANDEN. Schlägt ein Test wegen der neuen Gesamthöhe fehl, ist das ein echter Treffer: Die Erwartung wird auf „Karte plus Hinweis" angepasst, nicht der Umbau zurückgenommen.

- [ ] **Schritt 6: Festschreiben**

```bash
git add lib/widgets/time_map.dart test/widgets/time_map_text_scale_test.dart
git commit -m "fix(zeitkarte): die Standortbitte legt sich nicht mehr ueber Datum und Ort"
```

---

### Aufgabe 3: S1b — Die Profilauswahl rollt als Ganzes bei großer Schrift

**Dateien:**
- Anlegen: `test/modules/profile/profile_selection_test_setup.dart`
- Ändern: `lib/modules/profile/profile_selection_screen.dart:308-321` (Höhenrechnung) und der `Column`-Aufbau darunter
- Test: `test/modules/profile/profile_selection_text_scale_test.dart` (neu)

**Schnittstellen:**
- Verbraucht: `pumpScaled`, `expectFullyVisible`, `expectNoOverlap`, `geraetA14`, `geraetS24` aus Aufgabe 1; das gewachsene `TimeMap` aus Aufgabe 2.
- Erzeugt: `_ProfileSelectionScreenState.rollschwelle` (`static const double rollschwelle = 1.3;`) — ab diesem Schriftfaktor rollt der ganze Schirm.
- Erzeugt: `profilAufbau({bool mitTageshinweis = false, bool mitStandortrecht = true})` in `test/modules/profile/profile_selection_test_setup.dart`. Aufgabe 8 nutzt denselben Aufbau.

- [ ] **Schritt 0: Den Testaufbau anlegen**

Ein solcher Helfer existiert im Baum noch nicht — `test/` enthält bisher keine Profil- oder Notfall-Aufbaudatei. Er wird hier angelegt:

`test/modules/profile/profile_selection_test_setup.dart`:

```dart
import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Zwei Anteile, „Lina" und „Mina" — dieselbe Lage, in der der Bruch am
/// S24 am 10. August 2026 auftrat.
Future<void> profilAufbau({
  bool mitTageshinweis = false,
  bool mitStandortrecht = true,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Hive in ein Testverzeichnis, damit keine echten Daten angefasst werden.
  final dir = await Directory.systemTemp.createTemp('aurora_test');
  Hive.init(dir.path);
  await setupDependencies();
  addTearDown(() async {
    await Hive.deleteFromDisk();
    await getIt.reset();
  });

  final dataEntry = getIt<DataEntry>();
  await dataEntry.createProfile(name: 'Lina');
  await dataEntry.createProfile(name: 'Mina');

  if (mitTageshinweis) {
    await dataEntry.createDailyHint('Heute ist Freitag. Du hast einen Termin.');
  }

  getIt<GpsManager>().hasGpsPermission.value = mitStandortrecht;
}
```

Die genauen Methodennamen von `DataEntry` (`createProfile`, Tageshinweis) vor dem Schreiben in `lib/core/data_entry.dart` nachsehen und einsetzen — geraten wird hier nichts. Existiert für den Tageshinweis keine Schreibmethode, den Hinweis über den zuständigen Service-Aufruf setzen, den `DataEntry` dafür anbietet.

Ausführen: `flutter test test/modules/profile/`
Erwartet: Der Aufbau übersetzt und bricht nicht ab.

**Hintergrund:** `profile_selection_screen.dart:310` rechnet `const chrome = 60.0 + 40.0 + 148.0 + 44.0;` mit gemessenen dp-Zahlen. Die Messungen stammen von Schriftfaktor 1,0. Bei 2,0 wachsen Kopf, Tageszeile, beide Überschriften und die Fußzeile mit, `chrome` bleibt gleich, und die Namen fallen unter die Kante. Kopf und Rechtslinks sind zusätzlich fest verankert; nur die Wahl in der Mitte rollt.

**Entscheidung:** Unterhalb der Schwelle bleibt das heutige Layout unverändert — es ist gemessen und getestet. Ab der Schwelle wird der ganze Schirm eine Rollfläche mit fester, bescheidener Kartenhöhe.

- [ ] **Schritt 1: Den fehlschlagenden Test schreiben**

`test/modules/profile/profile_selection_text_scale_test.dart`:

```dart
import 'package:dis_app/modules/profile/profile_selection_screen.dart';
import 'package:dis_app/widgets/time_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';
import 'profile_selection_test_setup.dart';

void main() {
  for (final geraet in [geraetA14, geraetS24]) {
    for (final skala in [1.0, 1.5, 2.0]) {
      for (final hinweis in [false, true]) {
        testWidgets('Profilname erreichbar — $skala, Tageshinweis $hinweis', (tester) async {
          await profilAufbau(mitTageshinweis: hinweis, mitStandortrecht: false);
          await pumpScaled(
            tester,
            const ProfileSelectionScreen(),
            scale: skala,
            deviceSize: geraet.size,
            pixelRatio: geraet.ratio,
          );

          if (skala == 1.0) {
            // Bei Normalschrift ist Rollen keine gültige Antwort: Die
            // gemessenen Chrome-Zahlen existieren genau dafür, dass die
            // Namen ohne Rollen dastehen — auch ohne Standortrecht, wenn
            // die Karte den Hinweis unter sich trägt.
            expectFullyVisible(tester, find.text('Lina'));
            expectFullyVisible(tester, find.text('Neues Profil'));
          } else {
            await tester.scrollUntilVisible(find.text('Lina'), 200);
            expectFullyVisible(tester, find.text('Lina'));
            await tester.scrollUntilVisible(find.text('Neues Profil'), 200);
            expectFullyVisible(tester, find.text('Neues Profil'));
          }
        });

        testWidgets('Datum und Standortbitte frei — $skala, Tageshinweis $hinweis', (tester) async {
          await profilAufbau(mitTageshinweis: hinweis, mitStandortrecht: false);
          await pumpScaled(
            tester,
            const ProfileSelectionScreen(),
            scale: skala,
            deviceSize: geraet.size,
            pixelRatio: geraet.ratio,
          );

          expectNoOverlap(
            tester,
            find.byKey(TimeMap.kopfSchluessel),
            find.byKey(TimeMap.standortHinweisSchluessel),
          );
        });
      }
    }
  }

  // Spanisch, weil dieselben Sätze dort deutlich länger laufen — der Bericht
  // verlangt die Prüfung ausdrücklich für lange deutsche und spanische Texte.
  testWidgets('Spanisch bei 200 % bleibt lesbar', (tester) async {
    await profilAufbau(mitTageshinweis: true, mitStandortrecht: false);
    await pumpScaled(
      tester,
      const ProfileSelectionScreen(),
      scale: 2,
      deviceSize: geraetA14.size,
      pixelRatio: geraetA14.ratio,
      locale: const Locale('es'),
    );

    expectNoOverlap(
      tester,
      find.byKey(TimeMap.kopfSchluessel),
      find.byKey(TimeMap.standortHinweisSchluessel),
    );
    await tester.scrollUntilVisible(find.text('Lina'), 200);
    expectFullyVisible(tester, find.text('Lina'));
  });
}
```

- [ ] **Schritt 2: Test laufen lassen, Fehlschlag bestätigen**

Ausführen: `flutter test test/modules/profile/profile_selection_text_scale_test.dart`
Erwartet: FEHLSCHLAG — „Lina" bzw. „Neues Profil" liegen außerhalb des Schirms und sind nicht durch Rollen erreichbar, weil nur das Raster in der Mitte rollt.

- [ ] **Schritt 3: Die Schwelle einführen und den Aufbau verzweigen**

In `_ProfileSelectionScreenState`:

```dart
  /// Ab diesem Schriftfaktor rollt der ganze Schirm.
  ///
  /// Die gemessenen Chrome-Zahlen unten gelten für Schriftfaktor 1,0. Wer
  /// größer stellt, bekommt kein gerechnetes Layout mehr, sondern eine
  /// Fläche, die einfach wächst. Schrift zu begrenzen wäre für diese
  /// Zielgruppe keine gleichwertige Lösung: Große Systemschrift ist bei
  /// Stress, Sehschwäche und Erschöpfung die naheliegende Selbsthilfe.
  static const double rollschwelle = 1.3;
```

Im `build`, direkt vor der Höhenrechnung bei Zeile 308:

```dart
                final skala = MediaQuery.textScalerOf(context).scale(14) / 14;
                final rollt = skala >= rollschwelle;
```

Die Kartenhöhe daran hängen:

```dart
                final profileCount = _dataEntry.getProfiles().length + 1;
                final rows = (profileCount / columns).ceil();
                const chrome = 60.0 + 40.0 + 148.0 + 44.0;
                final rasterHeight = rows * (avatarDiameter + 62);
                // Seit Aufgabe 2 trägt die Zeitkarte den Standorthinweis
                // unter sich, statt ihn in den Stapel zu legen. Ohne
                // Standortrecht wächst sie also — und zwar auch bei
                // Normalschrift. Wird das nicht vom Kartenbudget abgezogen,
                // fallen die Namen bei 100 % unter die Kante: derselbe
                // Fehler wie vorher, nur eine Ebene tiefer.
                final hinweisHoehe =
                    getIt<GpsManager>().hasGpsPermission.value ? 0.0 : 56.0 * skala;

                final mapHeight = rollt
                    // In der Rollfläche konkurriert die Karte nicht mehr mit
                    // der Wahl um dieselbe Höhe. Sie bekommt ein bescheidenes
                    // festes Maß und darf den Rest der Fläche wachsen lassen.
                    ? 180.0
                    : (constraints.maxHeight - chrome - rasterHeight - hinweisHoehe)
                        .clamp(150.0, 260.0);
```

Den Aufbau darunter verzweigen. Der bestehende `Column`-Zweig (Kopf fest, Wahl rollt, Fußzeile fest) bleibt unverändert für `!rollt`. Für `rollt` ein einziger Rollstrang:

```dart
                if (rollt) {
                  // Kopf, Karte, Wahl und Rechtslinks in einer Rollfläche:
                  // Bei 200 % passt keine Aufteilung mehr, die etwas fest
                  // hält. Wer rollt, findet alles; wer nichts rollen kann,
                  // sieht wenigstens nichts Abgeschnittenes.
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: context.safeBottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 8),
                        timeMap,
                        const SizedBox(height: 16),
                        profileGrid,          // dasselbe Raster wie im festen Zweig,
                                              // aber mit shrinkWrap: true und
                                              // NeverScrollableScrollPhysics
                        const SizedBox(height: 24),
                        _buildLegalLinks(context),
                      ],
                    ),
                  );
                }
```

Wichtig: Das Raster muss im Rollzweig `shrinkWrap: true` und `physics: const NeverScrollableScrollPhysics()` bekommen, sonst rollen zwei Flächen ineinander. Wird das Raster heute inline gebaut, es vorher in eine Methode `Widget _buildProfileGrid(BuildContext context, {required bool eigenesRollen})` herausziehen, damit beide Zweige dieselbe Quelle nutzen.

- [ ] **Schritt 4: Test laufen lassen, Erfolg bestätigen**

Ausführen: `flutter test test/modules/profile/profile_selection_text_scale_test.dart`
Erwartet: BESTANDEN, 25 Tests (2 Geräte × 3 Schriftfaktoren × 2 Tageshinweis-Zustände × 2 Zusicherungen, plus der spanische Fall).

- [ ] **Schritt 5: Prüfen, dass Schriftfaktor 1,0 unverändert bleibt**

Ausführen: `flutter test test/modules/profile/`
Erwartet: BESTANDEN, keine angepassten Erwartungen im festen Zweig.

- [ ] **Schritt 6: Festschreiben**

```bash
git add lib/modules/profile/profile_selection_screen.dart test/modules/profile/profile_selection_text_scale_test.dart
git commit -m "fix(profilauswahl): bei grosser Schrift rollt der ganze Schirm"
```

---

### Aufgabe 4: S2a — Im Notfall steht Hilfe vor der Systemberechtigung

**Dateien:**
- Anlegen: `test/modules/emergency/emergency_test_setup.dart`
- Ändern: `lib/modules/emergency/emergency_screen.dart:69-104` (Reihenfolge der Slivers), `:76-87` (`showUserLocation`)
- Test: `test/modules/emergency/emergency_order_test.dart` (neu)

**Schnittstellen:**
- Verbraucht: `pumpScaled`, `rectOf`, `geraetS24` aus Aufgabe 1.
- Erzeugt: `notfallAufbau({required int mitKontakten, bool mitStandortrecht = false})` in `test/modules/emergency/emergency_test_setup.dart`. Aufgaben 5 und 8 nutzen denselben Aufbau.
- Erzeugt sonst nichts nach außen. `OverviewMap` behält seinen Vorgabewert `showUserLocation = true` — nur die Notfall-Aufrufstelle setzt ausdrücklich `false`.

- [ ] **Schritt 0: Den Testaufbau anlegen**

`test/modules/emergency/emergency_test_setup.dart` — nach demselben Muster wie `profile_selection_test_setup.dart` aus Aufgabe 3:

```dart
/// Ein Profil und [mitKontakten] Notfallkontakte.
///
/// Standortrecht steht vorgabegemäß auf „entzogen": Das ist die Lage, in der
/// der Befund entstand.
Future<void> notfallAufbau({
  required int mitKontakten,
  bool mitStandortrecht = false,
}) async {
  await profilAufbau(mitStandortrecht: mitStandortrecht);

  final dataEntry = getIt<DataEntry>();
  for (var i = 0; i < mitKontakten; i++) {
    await dataEntry.createContact(
      name: 'Notfallkontakt $i',
      isEmergencyContact: true,
    );
  }
}
```

Die genaue Signatur von `createContact` und das Feld `isEmergencyContact` (aus `emergency_screen.dart:46`) in `lib/core/data_entry.dart` nachsehen und einsetzen.

Ausführen: `flutter test test/modules/emergency/`
Erwartet: Der Aufbau übersetzt.

**Hintergrund:** `emergency_screen.dart:77` steht heute unverändert auf `showUserLocation: true`; das im Bericht erwähnte Entfernen des Arguments wäre ohnehin wirkungslos gewesen, weil `overview_map.dart:133` denselben Wert als Vorgabe führt. Der Vorgabewert bleibt, weil `OverviewMap` sieben Aufrufer hat — ihn zu kippen ändert stillschweigend Kalender, Finder, Zeitachse und Zeitkarte mit.

- [ ] **Schritt 1: Den fehlschlagenden Test schreiben**

`test/modules/emergency/emergency_order_test.dart`:

```dart
import 'package:dis_app/modules/emergency/emergency_screen.dart';
import 'package:dis_app/modules/emergency/widgets/emergency_contact_card.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';
import 'emergency_test_setup.dart'; // legt Dienste und Kontakte an

void main() {
  testWidgets('Die Karte fragt hier nicht nach dem Standort', (tester) async {
    await notfallAufbau(mitKontakten: 2);
    await pumpScaled(tester, const EmergencyScreen(), scale: 1);

    final karte = tester.widget<OverviewMap>(find.byType(OverviewMap));
    expect(karte.showUserLocation, isFalse);
  });

  for (final skala in [1.5, 2.0]) {
    testWidgets('Kontakte stehen vor der Karte bei $skala', (tester) async {
      await notfallAufbau(mitKontakten: 2);
      await pumpScaled(
        tester,
        const EmergencyScreen(),
        scale: skala,
        deviceSize: geraetS24.size,
        pixelRatio: geraetS24.ratio,
      );

      final kontakt = rectOf(tester, find.byType(EmergencyContactCard).first);
      final karte = rectOf(tester, find.byType(OverviewMap));
      expect(kontakt.top, lessThan(karte.top),
          reason: 'Die Karte steht vor der Hilfe');
      expectFullyVisible(tester, find.byType(EmergencyContactCard).first);
    });
  }
}
```

- [ ] **Schritt 2: Test laufen lassen, Fehlschlag bestätigen**

Ausführen: `flutter test test/modules/emergency/emergency_order_test.dart`
Erwartet: FEHLSCHLAG — `showUserLocation` ist `true`, und die Karte liegt über den Kontakten.

- [ ] **Schritt 3: Reihenfolge drehen und den Standort abschalten**

In `emergency_screen.dart` den Kartenausschnitt `:72-96` **hinter** den Kontaktblock verschieben, sodass die Sliver-Reihenfolge lautet: Kontakte bzw. Leerzustand → „An ALLE senden" → Trenner → Karte. Am Kartenaufruf ausdrücklich:

```dart
                // Ohne Standortrecht drängt sich hier sonst die
                // Systemberechtigung vor jede Hilfe. „Notfall" ist eine
                // Zusage; sie darf nicht mit einer Systemaufgabe anfangen.
                // Der Vorgabewert von OverviewMap bleibt true — er trägt
                // sechs andere Aufrufstellen. Hier steht das Gegenteil
                // ausdrücklich.
                child: OverviewMap(
                  showUserLocation: false,
                  // `showPermissionBanner` steht in overview_map.dart:134
                  // ebenfalls auf true. Die bildschirmfüllende
                  // Berechtigungskarte aus dem Befund kann von dort stammen.
                  // Sie wird hier ausdrücklich abgeschaltet und nach dem
                  // Umbau am Gerät ohne Standortrecht nachgesehen.
                  showPermissionBanner: false,
                  showLocationButton: false,
                  showFinderLocations: true,
                  showContacts: true,
                  showZoomControls: true,
                  finderLocations: finderLocations,
                  contacts: contactsWithLocation,
                  historyPath: locationHistory,
                  switchEvents: switchEvents,
                ),
```

`SliverFillRemaining(hasScrollBody: false)` beim Leerzustand fällt weg — er steht jetzt oben und darf nicht mehr den Rest der Fläche beanspruchen. Stattdessen `SliverToBoxAdapter`.

- [ ] **Schritt 4: Test laufen lassen, Erfolg bestätigen**

Ausführen: `flutter test test/modules/emergency/`
Erwartet: BESTANDEN, 3 neue Tests plus Bestand.

- [ ] **Schritt 5: Festschreiben**

```bash
git add lib/modules/emergency/emergency_screen.dart test/modules/emergency/emergency_order_test.dart
git commit -m "fix(notfall): Hilfe steht vor der Standortberechtigung"
```

---

### Aufgabe 5: S2b — Der Notfall-Leerzustand bietet zwei Wege statt eines Hinweises

**Dateien:**
- Ändern: `lib/modules/emergency/emergency_screen.dart:188` ff. (`_buildEmptyState`)
- Ändern: `lib/l10n/app_de.arb`, `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_it.arb`
- Test: `test/modules/emergency/emergency_empty_state_test.dart` (neu)

**Schnittstellen:**
- Verbraucht: `notfallAufbau` aus Aufgabe 4, `pumpScaled` aus Aufgabe 1.
- Erzeugt: `l10n.emergencyEmptyAddContact`, `l10n.emergencyEmptyOpenHelp`.

**Hintergrund:** Der Leerzustand verweist nur textlich auf einen anderen Bereich. Eine Person ohne vorbereitete Kontakte braucht mehr Hilfe, nicht weniger. `lib/modules/help/help_resources_screen.dart` hält die 24/7-Anlaufstellen bereits; `lib/modules/contacts/contact_form_screen.dart` legt Kontakte an.

- [ ] **Schritt 1: Den fehlschlagenden Test schreiben**

`test/modules/emergency/emergency_empty_state_test.dart`:

```dart
import 'package:dis_app/modules/contacts/contact_form_screen.dart';
import 'package:dis_app/modules/emergency/emergency_screen.dart';
import 'package:dis_app/modules/help/help_resources_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';
import 'emergency_test_setup.dart';

void main() {
  testWidgets('Ohne Kontakte fuehren zwei Knoepfe weiter', (tester) async {
    await notfallAufbau(mitKontakten: 0);
    await pumpScaled(tester, const EmergencyScreen(), scale: 1);

    await tester.tap(find.text('Notfallkontakt anlegen'));
    await tester.pumpAndSettle();
    expect(find.byType(ContactFormScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hilfe und Notrufnummern'));
    await tester.pumpAndSettle();
    expect(find.byType(HelpResourcesScreen), findsOneWidget);
  });

  testWidgets('Beide Knoepfe bleiben bei 200 % erreichbar', (tester) async {
    await notfallAufbau(mitKontakten: 0);
    await pumpScaled(
      tester,
      const EmergencyScreen(),
      scale: 2,
      deviceSize: geraetA14.size,
      pixelRatio: geraetA14.ratio,
    );

    await tester.scrollUntilVisible(find.text('Hilfe und Notrufnummern'), 200);
    expectFullyVisible(tester, find.text('Hilfe und Notrufnummern'));
  });
}
```

- [ ] **Schritt 2: Test laufen lassen, Fehlschlag bestätigen**

Ausführen: `flutter test test/modules/emergency/emergency_empty_state_test.dart`
Erwartet: FEHLSCHLAG — die Texte gibt es nicht.

- [ ] **Schritt 3: Texte anlegen**

`lib/l10n/app_de.arb` neben `emergencyEmptyDescription` (Zeile 670):

```json
  "emergencyEmptyAddContact": "Notfallkontakt anlegen",
  "@emergencyEmptyAddContact": {
    "description": "Knopf im Notfall-Leerzustand, legt einen Kontakt an"
  },
  "emergencyEmptyOpenHelp": "Hilfe und Notrufnummern",
  "@emergencyEmptyOpenHelp": {
    "description": "Knopf im Notfall-Leerzustand, oeffnet die 24/7-Anlaufstellen"
  },
```

Dieselben Schlüssel in die vier weiteren Dateien (ohne `@`-Blöcke):

| Datei | `emergencyEmptyAddContact` | `emergencyEmptyOpenHelp` |
|---|---|---|
| `app_en.arb` | `Add emergency contact` | `Help and crisis lines` |
| `app_es.arb` | `Añadir contacto de emergencia` | `Ayuda y teléfonos de crisis` |
| `app_fr.arb` | `Ajouter un contact d'urgence` | `Aide et numéros d'urgence` |
| `app_it.arb` | `Aggiungi contatto di emergenza` | `Aiuto e numeri di emergenza` |

- [ ] **Schritt 4: Übersetzungen erzeugen**

Ausführen: `flutter gen-l10n`
Erwartet: kein Fehler; `lib/l10n/app_localizations.dart` enthält `emergencyEmptyAddContact`.

- [ ] **Schritt 5: Den Leerzustand umbauen**

In `emergency_screen.dart`, `_buildEmptyState`, unter Titel, Untertitel und Beschreibung:

```dart
          const SizedBox(height: 24),

          // Ein Leerzustand, der nur auf einen anderen Bereich zeigt, lässt
          // genau die Person allein, die am wenigsten vorbereitet ist. Beide
          // Wege stehen deshalb hier: einer legt vor, einer hilft sofort.
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ContactFormScreen()),
              ),
              icon: const Icon(Icons.person_add, size: 24),
              label: Text(l10n.emergencyEmptyAddContact),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const HelpResourcesScreen()),
              ),
              icon: const Icon(Icons.support_agent, size: 24),
              label: Text(l10n.emergencyEmptyOpenHelp),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
```

Beide Klassen importieren. Falls `HelpResourcesScreen` benannte Argumente verlangt, die Signatur in `lib/modules/help/help_resources_screen.dart` nachsehen und den Aufruf anpassen — kein `const`, wenn Argumente nötig sind.

- [ ] **Schritt 6: Test laufen lassen, Erfolg bestätigen**

Ausführen: `flutter test test/modules/emergency/`
Erwartet: BESTANDEN.

- [ ] **Schritt 7: Festschreiben**

```bash
git add lib/modules/emergency/emergency_screen.dart lib/l10n/ test/modules/emergency/emergency_empty_state_test.dart
git commit -m "feat(notfall): der Leerzustand fuehrt zu Kontakt und Notrufnummern"
```

---

### Aufgabe 6: Das doppelte „von" in der Altersangabe

**Dateien:**
- Ändern: `lib/l10n/app_de.arb:4022`, `app_en.arb:3658`, `app_es.arb:2481`, `app_fr.arb:2481`, `app_it.arb:2481`
- Test: `test/utils/position_age_test.dart` (erweitern)

**Schnittstellen:**
- Verbraucht: nichts.
- Erzeugt: nichts. `formatPositionAge` (`lib/utils/position_age.dart:8`) und `mapLastKnownPosition` behalten ihre Signaturen.

**Hintergrund:** `mapLastKnownPosition` lautet „… deine letzte bekannte Position **von** {age}.", während `formatPositionAge` bereits „vor 7 Minuten" bzw. „von gestern" liefert. Ergebnis: „von vor 7 Minuten" und „von von gestern". Verwendungsstellen von `mapLastKnownPosition`: nur `lib/widgets/overview_map.dart:1662`. `formatPositionAge` zusätzlich in `lib/widgets/overview_map.dart:1056` und `lib/modules/profile/profile_selection_screen.dart:70` — beide setzen den Text allein und bleiben unverändert.

- [ ] **Schritt 1: Den fehlschlagenden Test schreiben**

Am Ende von `test/utils/position_age_test.dart`, in `void main()`:

```dart
  group('mapLastKnownPosition traegt formatPositionAge ohne Dopplung', () {
    testWidgets('deutsch', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox();
          }),
        ),
      );

      final gestern = l10n.mapLastKnownPosition(
        formatPositionAge(const Duration(hours: 24)),
      );
      final minuten = l10n.mapLastKnownPosition(
        formatPositionAge(const Duration(minutes: 7)),
      );

      expect(gestern, isNot(contains('von von')));
      expect(minuten, isNot(contains('von vor')));
      expect(gestern, contains('von gestern'));
      expect(minuten, contains('vor 7 Minuten'));
    });
  });
```

Nötige Importe ergänzen: `package:flutter/material.dart`, `package:flutter_test/flutter_test.dart`, `package:dis_app/l10n/app_localizations.dart`.

- [ ] **Schritt 2: Test laufen lassen, Fehlschlag bestätigen**

Ausführen: `flutter test test/utils/position_age_test.dart`
Erwartet: FEHLSCHLAG mit „Expected: not contains 'von von'".

- [ ] **Schritt 3: Die fünf Sätze umformulieren**

Der Doppelpunkt trägt beide Formen — „vor 7 Minuten" wie „von gestern":

| Datei | neuer Wert von `mapLastKnownPosition` |
|---|---|
| `app_de.arb` | `Auf der Karte steht deine letzte bekannte Position: {age}.` |
| `app_en.arb` | `The map shows your last known position: {age}.` |
| `app_es.arb` | `El mapa muestra tu última posición conocida: {age}.` |
| `app_fr.arb` | `La carte montre ta dernière position connue : {age}.` |
| `app_it.arb` | `La mappa mostra la tua ultima posizione nota: {age}.` |

Die `@mapLastKnownPosition`-Blöcke mit ihrer Platzhalterbeschreibung bleiben unverändert.

- [ ] **Schritt 4: Erzeugen und prüfen**

Ausführen: `flutter gen-l10n && flutter test test/utils/position_age_test.dart`
Erwartet: BESTANDEN.

- [ ] **Schritt 5: Festschreiben**

```bash
git add lib/l10n/ test/utils/position_age_test.dart
git commit -m "fix(karte): die Altersangabe sagt nicht mehr 'von von gestern'"
```

---

### Aufgabe 7: S3 — Die drei Krisenwege bleiben im Anker angeheftet

**Dateien:**
- Ändern: `lib/modules/anchor/anchor_menu_screen.dart:103-129`
- Test: `test/modules/anchor/anchor_pinned_test.dart` (neu)

**Schnittstellen:**
- Verbraucht: `pumpScaled`, `expectFullyVisible`, `geraetA14` aus Aufgabe 1.
- Erzeugt: nichts nach außen. `AnchorMenu({required groups, banner})` bleibt unverändert; die Anheftung wird aus `AnchorGroup.emphasis == AnchorEmphasis.solid` abgeleitet. `main.dart:1895` baut die Gruppen unverändert weiter.

**Hintergrund:** `AnchorEmphasis.solid` ist laut `anchor_row.dart:15` „nur für die Bereiche, die im Notfall gefunden werden" — genau Halt, Notfall, Hilfe. Die Anheftung braucht deshalb keinen neuen Parameter: Die Datenlage sagt schon, was oben bleibt.

- [ ] **Schritt 1: Den fehlschlagenden Test schreiben**

`test/modules/anchor/anchor_pinned_test.dart`:

```dart
import 'package:dis_app/modules/anchor/anchor_menu_screen.dart';
import 'package:dis_app/modules/anchor/anchor_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';

AnchorEntry _eintrag(String label) => AnchorEntry(
      icon: Icons.circle,
      label: label,
      color: Colors.teal,
      onTap: () {},
    );

/// Der Prüfanker. Öffentlich, weil der Semantik-Inventartest aus Aufgabe 8
/// dieselbe Fläche verwendet.
Widget ankerFuerTest() => Scaffold(
      body: AnchorMenu(
        groups: [
          AnchorGroup(
            label: 'Sofort',
            emphasis: AnchorEmphasis.solid,
            entries: [_eintrag('Halt'), _eintrag('Notfall'), _eintrag('Hilfe')],
          ),
          AnchorGroup(
            label: 'Alltag',
            entries: [
              for (final l in ['Kontakte', 'Finder', 'Spiele', 'Zeitachse', 'Feedback'])
                _eintrag(l),
            ],
          ),
        ],
      ),
    );

void main() {
  testWidgets('Die drei Krisenwege bleiben nach dem Rollen sichtbar', (tester) async {
    await pumpScaled(tester, ankerFuerTest(), scale: 1,
        deviceSize: geraetA14.size, pixelRatio: geraetA14.ratio);

    await tester.scrollUntilVisible(find.text('Feedback'), 200);
    await tester.pumpAndSettle();

    expectFullyVisible(tester, find.text('Halt'));
    expectFullyVisible(tester, find.text('Notfall'));
    expectFullyVisible(tester, find.text('Hilfe'));
  });

  testWidgets('Der feste Kopf frisst bei 200 % nicht die Liste', (tester) async {
    await pumpScaled(tester, ankerFuerTest(), scale: 2,
        deviceSize: geraetA14.size, pixelRatio: geraetA14.ratio);

    expectFullyVisible(tester, find.text('Halt'));
    // Der Rest bleibt erreichbar, auch wenn der Kopf gewachsen ist.
    await tester.scrollUntilVisible(find.text('Feedback'), 200);
    expectFullyVisible(tester, find.text('Feedback'));
  });
}
```

- [ ] **Schritt 2: Test laufen lassen, Fehlschlag bestätigen**

Ausführen: `flutter test test/modules/anchor/anchor_pinned_test.dart`
Erwartet: FEHLSCHLAG — nach dem Rollen zu „Feedback" liegen „Halt", „Notfall" und „Hilfe" außerhalb des Bildes.

- [ ] **Schritt 3: Den Anker zweiteilen**

`anchor_menu_screen.dart`, `AnchorMenu.build`:

```dart
  @override
  Widget build(BuildContext context) {
    // `solid` heißt laut AnchorRow: „nur für die Bereiche, die im Notfall
    // gefunden werden". Diese Gruppen bleiben deshalb stehen, statt mit der
    // Liste wegzurollen.
    //
    // Der Anker behielt seine Rollposition. Wer Feedback im ruhigen Zustand
    // öffnete und Sekunden später in einem anderen Zustand zurückkam, fand
    // am 10. August 2026 eine Liste, die am Ende stand — Halt, Notfall und
    // Hilfe lagen vollständig außerhalb des Bildes. Die Position zu behalten
    // ist für eine Inhaltsliste bequem, für den Krisenanker die falsche
    // Priorität.
    final fest = groups.where((g) => g.emphasis == AnchorEmphasis.solid).toList();
    final rest = groups.where((g) => g.emphasis != AnchorEmphasis.solid).toList();

    return Column(
      children: [
        if (fest.isNotEmpty)
          // Bei großer Systemschrift darf der feste Kopf nicht die ganze
          // Fläche belegen. Er bekommt höchstens die halbe Höhe und rollt
          // notfalls in sich selbst.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final group in fest) ..._gruppe(group),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView(
            // Der untere Rand nimmt die Systemleiste mit: Ohne ihn lag die
            // letzte Zeile am Gerät hinter den Navigationsknöpfen und war
            // nicht antippbar.
            padding: EdgeInsets.only(
              top: fest.isEmpty ? 8 : 0,
              bottom: 24 + context.safeBottomPadding,
            ),
            children: [
              if (banner != null) banner!,
              for (final group in rest) ..._gruppe(group),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _gruppe(AnchorGroup group) => [
        _GroupHeading(group.label),
        for (final entry in group.entries)
          AnchorRow(
            icon: entry.icon,
            label: entry.label,
            color: entry.color,
            onTap: entry.onTap,
            emphasis: group.emphasis,
            imageAsset: entry.imageAsset,
          ),
        const SizedBox(height: 12),
      ];
```

Der Passwort-Reset-Hinweis (`banner`) bleibt im rollenden Teil: Er betrifft die ganze App, ist aber kein Krisenweg und darf den festen Kopf nicht verdrängen.

- [ ] **Schritt 4: Test laufen lassen, Erfolg bestätigen**

Ausführen: `flutter test test/modules/anchor/`
Erwartet: BESTANDEN, 2 neue Tests plus Bestand.

- [ ] **Schritt 5: Festschreiben**

```bash
git add lib/modules/anchor/anchor_menu_screen.dart test/modules/anchor/anchor_pinned_test.dart
git commit -m "fix(anker): Halt, Notfall und Hilfe bleiben stehen"
```

---

### Aufgabe 8: A1 — Ein Semantikpass über die gemeinsamen Bausteine

**Dateien:**
- Ändern: `lib/modules/anchor/anchor_row.dart:105-108`
- Ändern: `lib/modules/profile/profile_selection_screen.dart:567-579`
- Ändern: `lib/modules/profile/widgets/profile_card.dart` (Profilzeile)
- Ändern: `lib/widgets/quick_timeline_band.dart:134-136`
- Ändern: `lib/widgets/time_map.dart` (der `GestureDetector` bei `:562-563`)
- Ändern: `lib/l10n/app_*.arb` (drei neue Schlüssel)
- Test: `test/a11y/semantics_inventory_test.dart` (neu)

**Schnittstellen:**
- Verbraucht: `expectNoUnlabeledTapTargets`, `labelOfTapTarget`, `pumpScaled` aus Aufgabe 1; den Anker aus Aufgabe 7.
- Erzeugt: `l10n.aboutAuroraSemantics`, `l10n.openTimelineSemantics`, `l10n.timeMapSemantics`.

**Hintergrund:** `anchor_row.dart:105` setzt ein `Semantics(button: true, label: …)`, schließt die Kindsemantik aber nicht aus — der sichtbare Text wird zusätzlich eingesammelt, TalkBack sagt „Halt, Halt". Der Info-`IconButton` hat weder `tooltip` noch Label. `quick_timeline_band.dart:136` macht das ganze Band per `InkWell` klickbar, ohne der Handlung einen Namen zu geben. Die Zeitkarte auf der Profilauswahl ist per `GestureDetector` klickbar und ebenfalls namenlos. `profile_card.dart` trägt überhaupt keine eigene Semantik — der Baum sammelt Bereichstitel, Profilbeschreibung und den Namen ein und sagt sie hintereinander an.

- [ ] **Schritt 1: Den fehlschlagenden Test schreiben**

`test/a11y/semantics_inventory_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import '../modules/anchor/anchor_pinned_test.dart' show ankerFuerTest;
import '../support/text_scale_harness.dart';

void main() {
  testWidgets('Kein klickbarer Knoten im Anker ohne Beschriftung', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScaled(tester, ankerFuerTest(), scale: 1);

    expectNoUnlabeledTapTargets(tester);
    handle.dispose();
  });

  testWidgets('Jede Ankerzeile wird genau einmal angesagt', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScaled(tester, ankerFuerTest(), scale: 1);

    expect(labelOfTapTarget(tester, 'Halt'), 'Halt');
    expect(labelOfTapTarget(tester, 'Notfall'), 'Notfall');
    expect(labelOfTapTarget(tester, 'Hilfe'), 'Hilfe');
    handle.dispose();
  });
}
```

`ankerFuerTest()` stammt unverändert aus Aufgabe 7 und wird hier nur importiert.

Die Akzeptanz verlangt das Inventar für **fünf** zentrale Flächen. Nach demselben Muster je einen `expectNoUnlabeledTapTargets`-Test aufnehmen für:

1. **Anker** — `ankerFuerTest()` (oben).
2. **Profilauswahl** — `profilAufbau()` aus Aufgabe 3; zusätzlich `expect(labelOfTapTarget(tester, 'Lina'), 'Lina')` und `expect(labelOfTapTarget(tester, 'Über Aurora'), 'Über Aurora')`.
3. **Notfall** — `notfallAufbau(mitKontakten: 2)` aus Aufgabe 4.
4. **Arbeitsfläche mit Zeitband** — der Schirm, der `QuickTimelineBand` einbettet; zusätzlich `expect(labelOfTapTarget(tester, 'Zeitachse'), 'Zeitachse öffnen')`.
5. **Feedback-Dank** — `FeedbackThankYouScreen` aus Aufgabe 9.

Jeder dieser Tests klammert seinen Rumpf in `final handle = tester.ensureSemantics(); … handle.dispose();`.

- [ ] **Schritt 2: Test laufen lassen, Fehlschlag bestätigen**

Ausführen: `flutter test test/a11y/semantics_inventory_test.dart`
Erwartet: FEHLSCHLAG — `labelOfTapTarget(tester, 'Halt')` liefert `'Halt\nHalt'` oder findet mehrere Knoten.

- [ ] **Schritt 3: Die vier Bausteine benennen**

`anchor_row.dart:105`:

```dart
    return Semantics(
      button: true,
      label: widget.label,
      // Ohne diesen Ausschluss sammelt der Baum den sichtbaren Text zusätzlich
      // ein und TalkBack sagt „Halt, Halt". Jede Wiederholung kostet
      // Arbeitsgedächtnis — bei wechselnden kognitiven Zuständen teuer.
      excludeSemantics: true,
      child: GestureDetector(
```

`profile_selection_screen.dart:567`:

```dart
        IconButton(
          tooltip: l10n.aboutAuroraSemantics,
          icon: const Icon(
            Icons.info_outline,
            color: Color(0xFFE8DCC4),
            size: 28,
          ),
```

Dazu in `_buildHeader` `final l10n = AppLocalizations.of(context);` ergänzen.

`quick_timeline_band.dart:136`:

```dart
    // Ein klickbares Band ohne Namen zwingt Vorlesehilfen zum Probieren.
    // Der Name nennt beides: die Handlung und wohin sie führt.
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).openTimelineSemantics,
      child: InkWell(onTap: onTap, child: band),
    );
```

`time_map.dart:562`:

```dart
    if (onTap == null) return map;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).timeMapSemantics,
      child: GestureDetector(onTap: onTap, child: map),
    );
```

`profile_card.dart`, um die antippbare Karte herum:

```dart
    // Ohne eigene Semantik sammelt der Baum Bereichstitel, Beschreibung und
    // den Namen ein und sagt sie hintereinander an. Der Name genügt: Wer
    // wählt, sucht sich, nicht die Überschrift darüber.
    return Semantics(
      button: true,
      label: profile.name,
      excludeSemantics: true,
      child: /* der bisherige Aufbau, unverändert */,
    );
```

**Prüfmechanik:** `Semantics(button:, label:, child: GestureDetector(...))` legt Beschriftung und Tippfläche nicht in jedem Aufbau auf denselben Knoten. Schlägt `expectNoUnlabeledTapTargets` nach diesen Änderungen weiterhin fehl, den Aufbau in `MergeSemantics` fassen oder am `Semantics` zusätzlich `container: true` setzen, bis Beschriftung und Tipp-Handlung auf einem Knoten liegen. Der Test entscheidet, nicht die Vermutung.

- [ ] **Schritt 4: Die drei Texte anlegen**

`lib/l10n/app_de.arb`:

```json
  "aboutAuroraSemantics": "Über Aurora",
  "@aboutAuroraSemantics": {
    "description": "Beschriftung des Info-Knopfes auf der Profilauswahl"
  },
  "openTimelineSemantics": "Zeitachse öffnen",
  "@openTimelineSemantics": {
    "description": "Vorlese-Beschriftung des schnellen Zeitbands"
  },
  "timeMapSemantics": "Zeitachse öffnen: Karte mit Zeit und Ort",
  "@timeMapSemantics": {
    "description": "Vorlese-Beschriftung der klickbaren Zeitkarte"
  },
```

| Datei | `aboutAuroraSemantics` | `openTimelineSemantics` | `timeMapSemantics` |
|---|---|---|---|
| `app_en.arb` | `About Aurora` | `Open timeline` | `Open timeline: map with time and place` |
| `app_es.arb` | `Acerca de Aurora` | `Abrir línea de tiempo` | `Abrir línea de tiempo: mapa con hora y lugar` |
| `app_fr.arb` | `À propos d'Aurora` | `Ouvrir la chronologie` | `Ouvrir la chronologie : carte avec heure et lieu` |
| `app_it.arb` | `Informazioni su Aurora` | `Apri la cronologia` | `Apri la cronologia: mappa con ora e luogo` |

Ausführen: `flutter gen-l10n`

- [ ] **Schritt 5: Test laufen lassen, Erfolg bestätigen**

Ausführen: `flutter test test/a11y/ test/modules/anchor/`
Erwartet: BESTANDEN.

- [ ] **Schritt 6: Festschreiben**

```bash
git add lib/modules/anchor/anchor_row.dart lib/modules/profile/profile_selection_screen.dart lib/modules/profile/widgets/profile_card.dart lib/widgets/quick_timeline_band.dart lib/widgets/time_map.dart lib/l10n/ test/a11y/
git commit -m "fix(barrierefreiheit): jede klickbare Flaeche wird genau einmal angesagt"
```

---

### Aufgabe 9: A2 — Der Dank steht einmal, der Ausgang steht oben

**Dateien:**
- Ändern: `lib/screens/feedback_thank_you_screen.dart:47-157`
- Test: `test/screens/feedback_thank_you_test.dart` (neu)

**Schnittstellen:**
- Verbraucht: `pumpScaled`, `rectOf`, `expectFullyVisible`, `expectNoUnlabeledTapTargets` aus Aufgabe 1.
- Erzeugt: nichts.

**Hintergrund:** `:48-68` zeigt Titel und Danktext groß; `:73-80` zeigt beides als Karte gleich noch einmal. Der Rückweg steht bei `:135-155` hinter allen Kontaktlinks. Nach potenziell persönlichem Feedback braucht die Person eine ruhige, eindeutige Bestätigung und einen sofortigen Ausgang.

- [ ] **Schritt 1: Den fehlschlagenden Test schreiben**

`test/screens/feedback_thank_you_test.dart`:

```dart
import 'package:dis_app/screens/feedback_thank_you_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/text_scale_harness.dart';

void main() {
  testWidgets('Der Dank steht genau einmal', (tester) async {
    await pumpScaled(tester, const FeedbackThankYouScreen(), scale: 1);

    expect(find.text('Danke für dein Feedback!'), findsOneWidget);
  });

  testWidgets('Der Ausgang steht vor den Kontaktlinks', (tester) async {
    await pumpScaled(tester, const FeedbackThankYouScreen(), scale: 1);

    final ausgang = rectOf(tester, find.text('Zurück zu Aurora'));
    final links = rectOf(tester, find.textContaining('Discord'));
    expect(ausgang.top, lessThan(links.top));
    expectFullyVisible(tester, find.text('Zurück zu Aurora'));
  });

  testWidgets('Der Ausgang bleibt bei 200 % im ersten Bild', (tester) async {
    await pumpScaled(tester, const FeedbackThankYouScreen(), scale: 2,
        deviceSize: geraetS24.size, pixelRatio: geraetS24.ratio);

    expectFullyVisible(tester, find.text('Zurück zu Aurora'));
  });
}
```

Den exakten deutschen Titeltext vor dem Schreiben in `lib/l10n/app_de.arb` unter `feedbackThankYouTitle` nachsehen und im Test einsetzen. Lautet `thankYouBackToApp` heute nicht „Zurück zu Aurora", den ARB-Wert in allen fünf Sprachen darauf ändern — die Akzeptanz verlangt die normale Navigationssprache der App.

- [ ] **Schritt 2: Test laufen lassen, Fehlschlag bestätigen**

Ausführen: `flutter test test/screens/feedback_thank_you_test.dart`
Erwartet: FEHLSCHLAG — `findsOneWidget` findet zwei, und der Ausgang liegt hinter Discord.

- [ ] **Schritt 3: Umbauen**

In `feedback_thank_you_screen.dart` die Dopplung entfernen und den Ausgang vorziehen. Reihenfolge nach dem Umbau: Symbol → Titel → Danktext → **Zurück zu Aurora** → Abstand → „In Verbindung bleiben" → Kontaktlinks.

- Den `_buildInfoCard`-Aufruf bei `:73-80` ersatzlos streichen. Wenn eine Empfangsbestätigung bei hinterlegter E-Mail nötig ist, tritt sie an die Stelle des Danktexts:

```dart
              Text(
                userEmail != null && userEmail!.isNotEmpty
                    ? l10n.feedbackThankYouReceived
                    : l10n.feedbackThankYouMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
```

- Den `SizedBox`/`FilledButton`-Block von `:134-155` unverändert direkt hinter diesen Text setzen.
- Die Kontaktlinks folgen danach, visuell nachrangig: `feedbackStayInTouch` von `fontSize: 20, w600` auf `fontSize: 16, w500` mit `alpha: 0.7`.
- Bleibt `_buildInfoCard` danach ungenutzt, die Methode löschen — toter Code bleibt nicht stehen.

- [ ] **Schritt 4: Test laufen lassen, Erfolg bestätigen**

Ausführen: `flutter test test/screens/feedback_thank_you_test.dart`
Erwartet: BESTANDEN, 3 Tests.

- [ ] **Schritt 5: Festschreiben**

```bash
git add lib/screens/feedback_thank_you_screen.dart test/screens/feedback_thank_you_test.dart
git commit -m "fix(feedback): der Dank steht einmal, der Rueckweg oben"
```

---

### Aufgabe 10: Gesamtlauf, Geräteabnahme und Aktenlage

**Dateien:**
- Ändern: `docs/oberflaechen-richtlinien.md` (Abschnitt zur Standortdarstellung vor der Profilwahl)
- Ändern: `docs/superpowers/specs/2026-08-10-codex-stress-und-barrierefreiheitsdurchlauf.md` (Statuszeile)

**Schnittstellen:**
- Verbraucht: alles Vorhergehende.
- Erzeugt: nichts.

- [ ] **Schritt 1: Alle Tests und Lints laufen lassen**

Ausführen: `flutter analyze && flutter test`
Erwartet: BESTANDEN, keine neuen Warnungen.

- [ ] **Schritt 2: Eigene Lint-Regeln laufen lassen**

Ausführen: `dart run custom_lint`
Erwartet: keine Verstöße gegen `prefer_data_entry_architecture`, `avoid_service_direct_mutation`, `hive_field_order_check`.

- [ ] **Schritt 3: Debug-APK bauen und auf dem Gerät prüfen**

Ausführen: `flutter build apk --debug`

Am Gerät bei Systemschrift **100 %, 150 %, 200 %** und **entzogenem Standortrecht** durchgehen — XML allein ist nur der Vorfilter:

1. Kalt starten. Datum, Uhrzeit, Ort und Standortzustand sind ohne Überlagerung lesbar.
2. Profilname und „Neues Profil" sind vollständig lesbar und erreichbar.
3. Profil wählen, „Notfall" öffnen. Der erste Bildschirm zeigt Hilfe, nicht die Standortbitte.
4. Ohne Notfallkontakte: beide Knöpfe sichtbar, beide führen weiter.
5. Im Anker bis „Feedback" rollen, Feedback öffnen, zurückgehen. „Halt", „Notfall", „Hilfe" stehen oben.
6. Feedback absenden: Dank einmal, „Zurück zu Aurora" im ersten Bild.
7. **TalkBack einschalten** und durch Profilauswahl, Anker, Notfall, Arbeitsfläche und Feedback-Dank wischen. Fokusreihenfolge und Ansagen prüfen; kein „Halt, Halt", kein namenloser Knopf.
8. Danach Schriftgröße und Standortrecht am Gerät wiederherstellen.

- [ ] **Schritt 4: Die Standortentscheidung festhalten**

In `docs/oberflaechen-richtlinien.md`, beim Abschnitt zur Profilauswahl, ergänzen:

```markdown
**Abgleich 10. August 2026 — genaue Standortspur vor der Profilwahl.**
Der Codex-Durchlauf hat den Zielkonflikt benannt: Vor jeder Anmeldung zeigt
die Karte Weg, aktuellen Marker und benannten Ort; jede Person mit dem
entsperrten Gerät sieht das. `hidePasswordProtected` hilft dagegen nicht —
die verbleibende Route legt selbst sensible Orte offen.

Entschieden am 10. August 2026: Es bleibt, wie es ist. „Wo war ich?" nach
einem Blackout ist Kernnutzen und braucht die Spur, nicht nur den Punkt. Wer
das Gerät entsperrt hat, hat ohnehin Zugriff auf mehr. Die Abwägung ist
bewusst getroffen und nicht beiläufig durch ein Oberflächen-Fix entstanden.
```

- [ ] **Schritt 5: Den Befundbericht abschließen**

In `docs/superpowers/specs/2026-08-10-codex-stress-und-barrierefreiheitsdurchlauf.md` unter `**Status:**` ergänzen:

```markdown
**Umsetzung:** S1, S2, S3, A1, A2 behoben — siehe
`docs/superpowers/plans/2026-08-10-codex-stress-und-barrierefreiheit.md`.
D1 am 10. August 2026 bewusst entschieden: Die Spur bleibt vor der
Profilwahl stehen; Begründung in `docs/oberflaechen-richtlinien.md`.
Offen aus älteren Berichten: B12 (Bildsprachbruch bei „Halt"), Startdauer im
Release-Build messen.
```

- [ ] **Schritt 6: Festschreiben**

```bash
git add docs/
git commit -m "docs: Stand nach dem Codex-Durchlauf vom 10. August"
```

---

## Was dieser Plan nicht anfasst

- **D1** — bewusst entschieden, keine Codeänderung (Aufgabe 10, Schritt 4).
- **B12** — der Bildsprachbruch bei „Halt" und „Körper spüren" bleibt offen. Er gehört in den Chamäleon-/Bildsprachstrang, nicht in einen Stresslauf-Plan.
- **Startdauer** — der Bericht stuft sie ausdrücklich noch nicht als Fehler ein. Vor einer Einstufung `time-to-first-interaction` mehrfach im Release-Build messen.
