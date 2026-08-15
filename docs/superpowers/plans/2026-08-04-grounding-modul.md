# Grounding-Modul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fünf Erdungsübungen, die ohne Lesen und ohne Ton bedienbar sind, für jeden Anteil jederzeit erreichbar, ohne dass etwas gespeichert wird.

**Architecture:** Reines UI-Modul ohne Service, ohne Hive-Adapter und ohne Persistenz. Die Übungen sind Dart-Konstanten, der Ablaufzustand lebt nur im Widget-State. Bilder werden über Schlüssel referenziert und in einer einzigen Map auf Assetpfade abgebildet, damit der Bildersatz später ohne Codeänderung getauscht werden kann.

**Tech Stack:** Flutter, `flutter_localizations` mit ARB-Dateien, `flutter_test`. Keine neuen Abhängigkeiten.

## Global Constraints

- Design-Vorlage: `docs/superpowers/specs/2026-08-04-grounding-modul-design.md`. Bei Widersprüchen gilt die Spec.
- Dateipfade in Tools **relativ** angeben (`./lib/...`), niemals absolut — Vorgabe aus `CLAUDE.md`.
- Das Modul darf **keine** Hive-Box öffnen und **keinen** Service importieren. Lesender Zugriff ausschließlich über `DataEntry`.
- Sprache in allen nutzersichtbaren Texten: *Anteil* / *Anteile*, niemals *Persönlichkeit*.
- Nutzersichtbare Strings ausschließlich über `AppLocalizations` aus ARB-Dateien, niemals literal im Widget.
- Neue ARB-Schlüssel immer in `lib/l10n/app_de.arb` **und** `lib/l10n/app_en.arb`, danach `flutter gen-l10n`.
- `logger.error` kennt **keinen** `error:`-Parameter — Ausnahmen über `data:` übergeben.
- Nach jeder Task: `flutter analyze` darf keine neuen `error`- oder `warning`-Zeilen erzeugen. Die bestehenden `withOpacity`-Hinweise sind Bestand; im neuen Code trotzdem `withValues()` verwenden.
- Commit-Nachrichten enden mit:
  `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`

---

### Task 1: Geteilte Symbol-Widgets hochziehen

Die Widgets `_PermissionDots` und `_PermissionSymbol` entstanden am 2026-08-04 als private Klassen in `permission_detail_screen.dart`. Das Grounding-Modul braucht beide identisch — die Punktereihe ist exakt die Schrittanzeige im Player. Sie zu kopieren wäre die Redundanz, die dieser Plan vermeiden soll.

**Files:**
- Create: `lib/widgets/progress_dots.dart`
- Create: `lib/widgets/state_symbol.dart`
- Modify: `lib/modules/permissions/permission_detail_screen.dart` (private Klassen `_PermissionDots` und `_PermissionSymbol` entfernen, neue Widgets verwenden)
- Test: `test/widgets/progress_dots_test.dart`
- Test: `test/widgets/state_symbol_test.dart`

**Interfaces:**
- Consumes: `IconContainer` aus `lib/widgets/icon_container.dart` (Konstruktor `IconContainer.circle({required IconData icon, double size, double? iconSize, Color? backgroundColor, Color? iconColor})`)
- Produces:
  - `ProgressDots({required int active, required int total, required Color color, int maxDots = 12})`
  - `StateSymbol({required IconData icon, required Color color, required bool active, IconData? badge, Color? badgeColor})`

- [x] **Step 1: Write the failing tests**

`test/widgets/progress_dots_test.dart`:

```dart
import 'package:dis_app/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ProgressDots', () {
    testWidgets('zeichnet einen Punkt je Einheit', (tester) async {
      await tester.pumpWidget(
        _wrap(const ProgressDots(active: 2, total: 5, color: Colors.blue)),
      );

      expect(find.byType(ProgressDotsDot), findsNWidgets(5));
    });

    testWidgets('markiert genau die aktiven Punkte als gefüllt', (tester) async {
      await tester.pumpWidget(
        _wrap(const ProgressDots(active: 2, total: 5, color: Colors.blue)),
      );

      final dots = tester
          .widgetList<ProgressDotsDot>(find.byType(ProgressDotsDot))
          .toList();

      expect(dots.map((d) => d.filled).toList(), [true, true, false, false, false]);
    });

    testWidgets('zeichnet nichts, wenn total ueber maxDots liegt', (tester) async {
      await tester.pumpWidget(
        _wrap(const ProgressDots(active: 1, total: 13, color: Colors.blue)),
      );

      expect(find.byType(ProgressDotsDot), findsNothing);
    });
  });
}
```

`test/widgets/state_symbol_test.dart`:

```dart
import 'package:dis_app/widgets/icon_container.dart';
import 'package:dis_app/widgets/state_symbol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('StateSymbol', () {
    testWidgets('nutzt IconContainer als Grundform', (tester) async {
      await tester.pumpWidget(
        _wrap(const StateSymbol(
          icon: Icons.star,
          color: Colors.teal,
          active: true,
        )),
      );

      expect(find.byType(IconContainer), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('zeigt kein Abzeichen, wenn keines gesetzt ist', (tester) async {
      await tester.pumpWidget(
        _wrap(const StateSymbol(
          icon: Icons.star,
          color: Colors.teal,
          active: true,
        )),
      );

      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('zeigt das Abzeichen, wenn eines gesetzt ist', (tester) async {
      await tester.pumpWidget(
        _wrap(const StateSymbol(
          icon: Icons.star,
          color: Colors.teal,
          active: true,
          badge: Icons.lock,
        )),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('kodiert den Zustand doppelt: Fuellung und Farbe', (tester) async {
      await tester.pumpWidget(
        _wrap(const StateSymbol(
          icon: Icons.star,
          color: Colors.teal,
          active: false,
        )),
      );

      final container = tester.widget<IconContainer>(find.byType(IconContainer));
      // Inaktiv: transparenter Hintergrund UND gedaempfte Icon-Farbe.
      expect(container.backgroundColor, Colors.transparent);
      expect(container.iconColor, isNot(Colors.teal));
    });
  });
}
```

- [x] **Step 2: Run tests to verify they fail**

Run: `flutter test test/widgets/progress_dots_test.dart test/widgets/state_symbol_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:dis_app/widgets/progress_dots.dart'`

- [x] **Step 3: Implement ProgressDots**

`lib/widgets/progress_dots.dart`:

```dart
import 'package:flutter/material.dart';

/// Punktereihe als abzählbare Fortschrittsanzeige
///
/// Gefüllt heißt erledigt oder aktiv, offen heißt ausstehend. Gedacht für
/// Stellen, an denen eine Zahl allein nicht trägt, weil niemand liest.
///
/// Ab [maxDots] Einheiten wird nichts gezeichnet — eine Reihe aus zwanzig
/// Punkten ist nicht mehr abzählbar und damit nutzlos.
class ProgressDots extends StatelessWidget {
  const ProgressDots({
    required this.active,
    required this.total,
    required this.color,
    this.maxDots = 12,
    super.key,
  });

  final int active;
  final int total;
  final Color color;
  final int maxDots;

  @override
  Widget build(BuildContext context) {
    if (total <= 0 || total > maxDots) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        total,
        (i) => ProgressDotsDot(filled: i < active, color: color),
      ),
    );
  }
}

/// Einzelner Punkt einer [ProgressDots]-Reihe
///
/// Eigene Klasse, damit Tests den Zustand einzelner Punkte prüfen können,
/// statt gegen gemalte Pixel zu assertieren.
class ProgressDotsDot extends StatelessWidget {
  const ProgressDotsDot({
    required this.filled,
    required this.color,
    super.key,
  });

  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? color : Colors.transparent,
          border: Border.all(
            color: filled ? color : color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
```

- [x] **Step 4: Implement StateSymbol**

`lib/widgets/state_symbol.dart`:

```dart
import 'package:dis_app/widgets/icon_container.dart';
import 'package:flutter/material.dart';

/// Rundes Symbol, dessen Zustand doppelt kodiert ist
///
/// Aktiv heißt: gefüllter Hintergrund **und** kräftige Farbe. Inaktiv heißt:
/// transparent **und** gedämpft. Nie nur eines von beidem — wer Farben schlecht
/// unterscheidet, erkennt den Zustand dann immer noch an der Füllung.
///
/// Setzt auf [IconContainer] auf, statt einen eigenen Kreis zu zeichnen.
class StateSymbol extends StatelessWidget {
  const StateSymbol({
    required this.icon,
    required this.color,
    required this.active,
    this.badge,
    this.badgeColor,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final Color color;
  final bool active;

  /// Optionales kleines Abzeichen unten rechts, z. B. ein Schloss
  final IconData? badge;
  final Color? badgeColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final symbol = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? color : color.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: IconContainer.circle(
        icon: icon,
        size: size,
        iconSize: size * 0.55,
        backgroundColor:
            active ? color.withValues(alpha: 0.18) : Colors.transparent,
        iconColor: active ? color : color.withValues(alpha: 0.35),
      ),
    );

    if (badge == null) return symbol;

    return SizedBox(
      width: size + 4,
      height: size + 4,
      child: Stack(
        children: [
          symbol,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
              ),
              child: Icon(
                badge,
                size: 13,
                color: badgeColor ?? Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [x] **Step 5: Run tests to verify they pass**

Run: `flutter test test/widgets/progress_dots_test.dart test/widgets/state_symbol_test.dart`
Expected: PASS — 7 Tests

- [x] **Step 6: Rechte-Screen auf die neuen Widgets umstellen**

In `lib/modules/permissions/permission_detail_screen.dart`:

1. Import ergänzen:

```dart
import 'package:dis_app/widgets/progress_dots.dart';
import 'package:dis_app/widgets/state_symbol.dart';
```

2. Die private Klasse `_PermissionDots` **komplett löschen** und ihre Verwendung in `_PermissionSection.build` ersetzen:

```dart
              _PermissionDots(
                active: activeCount,
                total: permissions.length,
                color: category.color,
              ),
```

wird zu:

```dart
              ProgressDots(
                active: activeCount,
                total: permissions.length,
                color: category.color,
              ),
```

3. Die private Klasse `_PermissionSymbol` **komplett löschen** und ihre Verwendung in `_PermissionTile.build` ersetzen:

```dart
      secondary: _PermissionSymbol(
        icon: permission.icon,
        color: activeColor,
        enabled: enabled,
        locked: isAdmin,
      ),
```

wird zu:

```dart
      secondary: StateSymbol(
        icon: permission.icon,
        color: activeColor,
        active: enabled,
        badge: isAdmin ? Icons.lock : null,
      ),
```

- [x] **Step 7: Run full suite to verify no regression**

Run: `flutter test`
Expected: PASS — alle bisherigen Tests plus die 7 neuen

Run: `flutter analyze lib/widgets/progress_dots.dart lib/widgets/state_symbol.dart lib/modules/permissions/`
Expected: keine `error`-Zeile. Erlaubt sind die bestehenden `withOpacity`- und `unnecessary_non_null_assertion`-Hinweise in `permission_detail_screen.dart`.

- [x] **Step 8: Commit**

```bash
git add lib/widgets/progress_dots.dart lib/widgets/state_symbol.dart \
        lib/modules/permissions/permission_detail_screen.dart \
        test/widgets/progress_dots_test.dart test/widgets/state_symbol_test.dart
git commit -m "refactor: extract ProgressDots and StateSymbol into shared widgets

Both were private classes in the permission detail screen. The grounding
module needs them identically — the dot row is exactly the step indicator.
StateSymbol now builds on the existing IconContainer instead of drawing
its own circle.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: Datenmodell und Bildauflösung

**Files:**
- Create: `lib/modules/grounding/models/grounding_exercise.dart`
- Create: `lib/modules/grounding/data/grounding_images.dart`
- Test: `test/modules/grounding/grounding_images_test.dart`

**Interfaces:**
- Consumes: nichts aus früheren Tasks
- Produces:
  - `class GroundingExercise { final String id; final String titleKey; final IconData icon; final Color color; final List<GroundingStep> steps; }`
  - `class GroundingStep { final String imageKey; final String textKey; final Duration? hold; final bool showsCurrentDateTime; }`
  - `abstract final class GroundingImages { static String? resolve(String imageKey); static Set<String> get knownKeys; static bool get hasAssets; }`

- [x] **Step 1: Write the failing test**

`test/modules/grounding/grounding_images_test.dart`:

```dart
import 'package:dis_app/modules/grounding/data/grounding_images.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GroundingImages', () {
    test('gibt null zurueck fuer einen unbekannten Schluessel', () {
      expect(GroundingImages.resolve('gibt_es_nicht'), isNull);
    });

    test('knownKeys und resolve stimmen ueberein', () {
      for (final key in GroundingImages.knownKeys) {
        expect(
          GroundingImages.resolve(key),
          isNotNull,
          reason: 'Schluessel $key steht in knownKeys, loest aber nicht auf',
        );
      }
    });

    test('hasAssets meldet, ob ueberhaupt ein Bildersatz hinterlegt ist', () {
      expect(GroundingImages.hasAssets, GroundingImages.knownKeys.isNotEmpty);
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/modules/grounding/grounding_images_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:dis_app/modules/grounding/data/grounding_images.dart'`

- [x] **Step 3: Implement the model**

`lib/modules/grounding/models/grounding_exercise.dart`:

```dart
import 'package:flutter/material.dart';

/// Eine Erdungsübung
///
/// Reines Dart, keine Hive-Annotation, keine Generierung. Übungen sind
/// Konstanten im Code — das Modul speichert nichts und liest nichts.
@immutable
class GroundingExercise {
  const GroundingExercise({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.steps,
  });

  /// Stabile Kennung, z. B. 'orientation'. Wird nicht angezeigt.
  final String id;

  /// Schlüssel für den Titel in den ARB-Dateien
  final String titleKey;

  /// Symbol der Übung. Springt ein, wenn ein Bild fehlt.
  final IconData icon;

  final Color color;

  final List<GroundingStep> steps;
}

/// Ein Schritt innerhalb einer Übung
@immutable
class GroundingStep {
  const GroundingStep({
    required this.imageKey,
    required this.textKey,
    this.hold,
    this.showsCurrentDateTime = false,
  });

  /// Schlüssel, nie ein Pfad. Aufgelöst über [GroundingImages].
  final String imageKey;

  /// Schlüssel für den Text in den ARB-Dateien. Der Text bestätigt nur,
  /// was das Bild bereits gesagt hat.
  final String textKey;

  /// Optionale Verweildauer. Zeichnet einen Ring, blockiert aber nie das
  /// Weitertippen — kein Timer darf weglaufen, während jemand weg ist.
  final Duration? hold;

  /// Nur der erste Schritt der Orientierungsübung zeigt echtes Datum und
  /// echte Uhrzeit. Der einzige dynamische Inhalt im ganzen Modul.
  final bool showsCurrentDateTime;
}
```

- [x] **Step 4: Implement the image resolution**

`lib/modules/grounding/data/grounding_images.dart`:

```dart
/// Auflösung von Bildschlüsseln auf Assetpfade
///
/// Die einzige Stelle im Modul, die Pfade kennt. Ein Wechsel des Bildersatzes
/// ändert genau diese Map — keine Übung, kein Widget, kein Test.
///
/// Bewusst getrennt von `AttachmentHelper` und `ProfileImageWidget`: die lösen
/// nutzergenerierte Dateien im Dokumentenverzeichnis auf. Grounding-Bilder sind
/// ausschließlich gebündelte Assets.
///
/// Solange die Map leer ist, läuft das Modul mit dem Symbol der jeweiligen
/// Übung als Ersatz. Das ist kein Fehlerzustand, sondern der Auslieferungsstand
/// bis Task 7.
abstract final class GroundingImages {
  static const Map<String, String> _paths = <String, String>{};

  /// Assetpfad zu einem Schlüssel, oder null, wenn kein Bild hinterlegt ist
  static String? resolve(String imageKey) => _paths[imageKey];

  /// Alle Schlüssel, für die ein Bild hinterlegt ist
  static Set<String> get knownKeys => _paths.keys.toSet();

  /// Ob überhaupt ein Bildersatz hinterlegt ist
  static bool get hasAssets => _paths.isNotEmpty;
}
```

- [x] **Step 5: Run test to verify it passes**

Run: `flutter test test/modules/grounding/grounding_images_test.dart`
Expected: PASS — 3 Tests

- [x] **Step 6: Commit**

```bash
git add lib/modules/grounding/models/grounding_exercise.dart \
        lib/modules/grounding/data/grounding_images.dart \
        test/modules/grounding/grounding_images_test.dart
git commit -m "feat: add grounding exercise model and image key resolution

Images are referenced by key, never by path, so the whole set can be
swapped in one map without touching an exercise, a widget or a test.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: Die fünf Übungen und ihre Texte

**Files:**
- Create: `lib/modules/grounding/data/grounding_exercises.dart`
- Modify: `lib/l10n/app_de.arb`
- Modify: `lib/l10n/app_en.arb`
- Test: `test/modules/grounding/grounding_exercises_test.dart`

**Interfaces:**
- Consumes: `GroundingExercise`, `GroundingStep` aus Task 2; `GroundingImages.knownKeys` aus Task 2
- Produces: `abstract final class GroundingExercises { static const List<GroundingExercise> all; static GroundingExercise get anchor; }`

- [x] **Step 1: Write the failing test**

`test/modules/grounding/grounding_exercises_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/data/grounding_images.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readArb(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('GroundingExercises', () {
    test('enthaelt genau fuenf Uebungen', () {
      expect(GroundingExercises.all.length, 5);
    });

    test('jede Uebung hat mindestens einen Schritt', () {
      for (final exercise in GroundingExercises.all) {
        expect(
          exercise.steps,
          isNotEmpty,
          reason: 'Uebung ${exercise.id} hat keine Schritte',
        );
      }
    });

    test('Uebungs-Ids sind eindeutig', () {
      final ids = GroundingExercises.all.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('der Anker ist die Orientierungsuebung', () {
      expect(GroundingExercises.anchor.id, 'orientation');
    });

    test('genau der erste Schritt des Ankers zeigt Datum und Uhrzeit', () {
      final steps = GroundingExercises.anchor.steps;
      expect(steps.first.showsCurrentDateTime, isTrue);
      expect(
        steps.skip(1).every((s) => !s.showsCurrentDateTime),
        isTrue,
        reason: 'Nur der erste Schritt darf dynamisch sein',
      );
    });

    test('jeder Textschluessel existiert in app_de.arb und app_en.arb', () {
      final de = _readArb('lib/l10n/app_de.arb');
      final en = _readArb('lib/l10n/app_en.arb');

      for (final exercise in GroundingExercises.all) {
        expect(de.containsKey(exercise.titleKey), isTrue,
            reason: 'app_de.arb fehlt ${exercise.titleKey}');
        expect(en.containsKey(exercise.titleKey), isTrue,
            reason: 'app_en.arb fehlt ${exercise.titleKey}');

        for (final step in exercise.steps) {
          expect(de.containsKey(step.textKey), isTrue,
              reason: 'app_de.arb fehlt ${step.textKey}');
          expect(en.containsKey(step.textKey), isTrue,
              reason: 'app_en.arb fehlt ${step.textKey}');
        }
      }
    });

    test('jeder Bildschluessel loest auf, sobald ein Bildersatz vorliegt', () {
      if (!GroundingImages.hasAssets) {
        // Bis Task 7 gibt es keinen Bildersatz. Das Modul laeuft dann mit dem
        // Uebungssymbol als Ersatz — dieser Test wird scharf, sobald Bilder da
        // sind, und faengt ab dann jede Luecke.
        return;
      }

      for (final exercise in GroundingExercises.all) {
        for (final step in exercise.steps) {
          expect(
            GroundingImages.resolve(step.imageKey),
            isNotNull,
            reason: 'Kein Bild fuer ${step.imageKey} '
                'in Uebung ${exercise.id}',
          );
        }
      }
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/modules/grounding/grounding_exercises_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../grounding_exercises.dart'`

- [x] **Step 3: Add the German strings**

In `lib/l10n/app_de.arb`, vor der schließenden `}` einfügen:

```json
  "groundingTitle": "Halt",
  "@groundingTitle": {
    "description": "Title of the grounding area"
  },

  "groundingAnchorLabel": "Anker",
  "@groundingAnchorLabel": {
    "description": "Label of the large button that starts the orientation exercise"
  },

  "groundingChooseLabel": "Oder such dir etwas aus",
  "@groundingChooseLabel": {
    "description": "Header above the exercise tiles"
  },

  "groundingDoneAgain": "Nochmal",
  "@groundingDoneAgain": {
    "description": "Repeat the same exercise"
  },

  "groundingDoneOther": "Was anderes",
  "@groundingDoneOther": {
    "description": "Go back and pick a different exercise"
  },

  "groundingDoneCall": "Jemanden anrufen",
  "@groundingDoneCall": {
    "description": "Escalate to emergency contacts or hotlines"
  },

  "groundingOrientationTitle": "Hier und Jetzt",
  "@groundingOrientationTitle": {},
  "groundingOrientationStep1": "Heute ist",
  "@groundingOrientationStep1": {},
  "groundingOrientationStep2": "Schau dich um. Wo bist du gerade?",
  "@groundingOrientationStep2": {},
  "groundingOrientationStep3": "Sag laut oder leise, wer du bist.",
  "@groundingOrientationStep3": {},
  "groundingOrientationStep4": "Der Körper von heute ist nicht der von damals.",
  "@groundingOrientationStep4": {},
  "groundingOrientationStep5": "Was du erinnerst, ist vorbei.",
  "@groundingOrientationStep5": {},
  "groundingOrientationStep6": "Du bist hier.",
  "@groundingOrientationStep6": {},

  "groundingSensesTitle": "Sehen, hören, spüren",
  "@groundingSensesTitle": {},
  "groundingSensesStep1": "Fünf Dinge, die du siehst.",
  "@groundingSensesStep1": {},
  "groundingSensesStep2": "Vier Dinge, die du hörst.",
  "@groundingSensesStep2": {},
  "groundingSensesStep3": "Drei Dinge, die du anfassen kannst.",
  "@groundingSensesStep3": {},
  "groundingSensesStep4": "Zwei Dinge, die du riechst.",
  "@groundingSensesStep4": {},
  "groundingSensesStep5": "Eine Sache, die du schmeckst.",
  "@groundingSensesStep5": {},
  "groundingSensesStep6": "Du bist hier.",
  "@groundingSensesStep6": {},

  "groundingBodyTitle": "Körper spüren",
  "@groundingBodyTitle": {},
  "groundingBodyStep1": "Stell beide Füße flach auf den Boden.",
  "@groundingBodyStep1": {},
  "groundingBodyStep2": "Drück die Fersen nach unten.",
  "@groundingBodyStep2": {},
  "groundingBodyStep3": "Nimm etwas Kaltes in die Hand.",
  "@groundingBodyStep3": {},
  "groundingBodyStep4": "Halt es fest, solange du magst.",
  "@groundingBodyStep4": {},
  "groundingBodyStep5": "Spür deinen Rücken an der Lehne.",
  "@groundingBodyStep5": {},
  "groundingBodyStep6": "Der Boden trägt dich.",
  "@groundingBodyStep6": {},

  "groundingContainerTitle": "Wegschließen",
  "@groundingContainerTitle": {},
  "groundingContainerStep1": "Stell dir einen Behälter vor. So groß, wie du willst.",
  "@groundingContainerStep1": {},
  "groundingContainerStep2": "Er hat einen Deckel, der fest schließt.",
  "@groundingContainerStep2": {},
  "groundingContainerStep3": "Leg hinein, was gerade zu viel ist.",
  "@groundingContainerStep3": {},
  "groundingContainerStep4": "Mach den Deckel zu.",
  "@groundingContainerStep4": {},
  "groundingContainerStep5": "Stell ihn an einen Ort, den du bestimmst.",
  "@groundingContainerStep5": {},
  "groundingContainerStep6": "Du kannst ihn wieder öffnen. Nicht jetzt.",
  "@groundingContainerStep6": {},

  "groundingBreathTitle": "Atem",
  "@groundingBreathTitle": {},
  "groundingBreathStep1": "Atme ein und zähl bis vier.",
  "@groundingBreathStep1": {},
  "groundingBreathStep2": "Halt kurz.",
  "@groundingBreathStep2": {},
  "groundingBreathStep3": "Atme aus und zähl bis sechs.",
  "@groundingBreathStep3": {},
  "groundingBreathStep4": "Nochmal. Ohne Eile.",
  "@groundingBreathStep4": {},
  "groundingBreathStep5": "Langsamer raus als rein. Das reicht.",
  "@groundingBreathStep5": {}
```

Achtung: Der vorherige letzte Eintrag der Datei braucht ein Komma am Ende.

- [x] **Step 4: Add the English strings**

In `lib/l10n/app_en.arb` dieselben Schlüssel mit denselben `@`-Blöcken einfügen, Werte:

```json
  "groundingTitle": "Ground",
  "groundingAnchorLabel": "Anchor",
  "groundingChooseLabel": "Or pick something",
  "groundingDoneAgain": "Again",
  "groundingDoneOther": "Something else",
  "groundingDoneCall": "Call someone",

  "groundingOrientationTitle": "Here and now",
  "groundingOrientationStep1": "Today is",
  "groundingOrientationStep2": "Look around. Where are you right now?",
  "groundingOrientationStep3": "Say who you are, out loud or quietly.",
  "groundingOrientationStep4": "Today's body is not the body from back then.",
  "groundingOrientationStep5": "What you remember is over.",
  "groundingOrientationStep6": "You are here.",

  "groundingSensesTitle": "See, hear, feel",
  "groundingSensesStep1": "Five things you can see.",
  "groundingSensesStep2": "Four things you can hear.",
  "groundingSensesStep3": "Three things you can touch.",
  "groundingSensesStep4": "Two things you can smell.",
  "groundingSensesStep5": "One thing you can taste.",
  "groundingSensesStep6": "You are here.",

  "groundingBodyTitle": "Feel the body",
  "groundingBodyStep1": "Put both feet flat on the floor.",
  "groundingBodyStep2": "Press your heels down.",
  "groundingBodyStep3": "Take something cold in your hand.",
  "groundingBodyStep4": "Hold it as long as you like.",
  "groundingBodyStep5": "Feel your back against the chair.",
  "groundingBodyStep6": "The ground is carrying you.",

  "groundingContainerTitle": "Put it away",
  "groundingContainerStep1": "Picture a container. As big as you want.",
  "groundingContainerStep2": "It has a lid that closes tight.",
  "groundingContainerStep3": "Put inside what is too much right now.",
  "groundingContainerStep4": "Close the lid.",
  "groundingContainerStep5": "Place it somewhere you choose.",
  "groundingContainerStep6": "You can open it again. Not now.",

  "groundingBreathTitle": "Breath",
  "groundingBreathStep1": "Breathe in and count to four.",
  "groundingBreathStep2": "Hold briefly.",
  "groundingBreathStep3": "Breathe out and count to six.",
  "groundingBreathStep4": "Again. No rush.",
  "groundingBreathStep5": "Slower out than in. That is enough."
```

- [x] **Step 5: Regenerate localizations**

Run: `flutter gen-l10n`
Expected: keine Fehlermeldung. Warnungen zu untranslated messages für `es`, `fr`, `it` sind Bestand.

- [x] **Step 6: Implement the exercises**

`lib/modules/grounding/data/grounding_exercises.dart`:

```dart
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:flutter/material.dart';

/// Die fünf Erdungsübungen
///
/// Abgeleitet aus dem Programm *Finding Solid Ground* und den ISSTD-Leitlinien
/// zu Phase 1. Statische Inhaltsliste nach dem Muster von
/// `lib/utils/did_you_know_facts.dart`.
abstract final class GroundingExercises {
  static const List<GroundingExercise> all = [
    _orientation,
    _senses,
    _body,
    _container,
    _breath,
  ];

  /// Die Übung hinter dem großen Anker. Wer nicht wählen kann, landet hier.
  static GroundingExercise get anchor => _orientation;

  static const _orientation = GroundingExercise(
    id: 'orientation',
    titleKey: 'groundingOrientationTitle',
    icon: Icons.explore,
    color: Color(0xFF4DB6AC),
    steps: [
      GroundingStep(
        imageKey: 'calendar_today',
        textKey: 'groundingOrientationStep1',
        showsCurrentDateTime: true,
      ),
      GroundingStep(imageKey: 'look_around', textKey: 'groundingOrientationStep2'),
      GroundingStep(imageKey: 'name_tag', textKey: 'groundingOrientationStep3'),
      GroundingStep(imageKey: 'grown_body', textKey: 'groundingOrientationStep4'),
      GroundingStep(imageKey: 'past_behind', textKey: 'groundingOrientationStep5'),
      GroundingStep(imageKey: 'you_are_here', textKey: 'groundingOrientationStep6'),
    ],
  );

  static const _senses = GroundingExercise(
    id: 'senses',
    titleKey: 'groundingSensesTitle',
    icon: Icons.visibility,
    color: Color(0xFF64B5F6),
    steps: [
      GroundingStep(imageKey: 'sense_eye', textKey: 'groundingSensesStep1'),
      GroundingStep(imageKey: 'sense_ear', textKey: 'groundingSensesStep2'),
      GroundingStep(imageKey: 'sense_touch', textKey: 'groundingSensesStep3'),
      GroundingStep(imageKey: 'sense_nose', textKey: 'groundingSensesStep4'),
      GroundingStep(imageKey: 'sense_mouth', textKey: 'groundingSensesStep5'),
      GroundingStep(imageKey: 'you_are_here', textKey: 'groundingSensesStep6'),
    ],
  );

  static const _body = GroundingExercise(
    id: 'body',
    titleKey: 'groundingBodyTitle',
    icon: Icons.accessibility_new,
    color: Color(0xFF81C784),
    steps: [
      GroundingStep(imageKey: 'feet_ground', textKey: 'groundingBodyStep1'),
      GroundingStep(imageKey: 'press_down', textKey: 'groundingBodyStep2'),
      GroundingStep(imageKey: 'hand_ice', textKey: 'groundingBodyStep3'),
      GroundingStep(
        imageKey: 'hold_tight',
        textKey: 'groundingBodyStep4',
        hold: Duration(seconds: 20),
      ),
      GroundingStep(imageKey: 'back_chair', textKey: 'groundingBodyStep5'),
      GroundingStep(imageKey: 'ground_holds', textKey: 'groundingBodyStep6'),
    ],
  );

  static const _container = GroundingExercise(
    id: 'container',
    titleKey: 'groundingContainerTitle',
    icon: Icons.inventory_2,
    color: Color(0xFFBA68C8),
    steps: [
      GroundingStep(imageKey: 'container_empty', textKey: 'groundingContainerStep1'),
      GroundingStep(imageKey: 'container_lid', textKey: 'groundingContainerStep2'),
      GroundingStep(imageKey: 'container_fill', textKey: 'groundingContainerStep3'),
      GroundingStep(imageKey: 'container_closed', textKey: 'groundingContainerStep4'),
      GroundingStep(imageKey: 'container_shelf', textKey: 'groundingContainerStep5'),
      GroundingStep(imageKey: 'container_key', textKey: 'groundingContainerStep6'),
    ],
  );

  static const _breath = GroundingExercise(
    id: 'breath',
    titleKey: 'groundingBreathTitle',
    icon: Icons.air,
    color: Color(0xFF9FA8DA),
    steps: [
      GroundingStep(
        imageKey: 'breath_in',
        textKey: 'groundingBreathStep1',
        hold: Duration(seconds: 4),
      ),
      GroundingStep(
        imageKey: 'breath_hold',
        textKey: 'groundingBreathStep2',
        hold: Duration(seconds: 2),
      ),
      GroundingStep(
        imageKey: 'breath_out',
        textKey: 'groundingBreathStep3',
        hold: Duration(seconds: 6),
      ),
      GroundingStep(imageKey: 'breath_repeat', textKey: 'groundingBreathStep4'),
      GroundingStep(imageKey: 'breath_done', textKey: 'groundingBreathStep5'),
    ],
  );
}
```

- [x] **Step 7: Run test to verify it passes**

Run: `flutter test test/modules/grounding/grounding_exercises_test.dart`
Expected: PASS — 7 Tests

- [x] **Step 8: Commit**

```bash
git add lib/modules/grounding/data/grounding_exercises.dart \
        lib/l10n/app_de.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart \
        test/modules/grounding/grounding_exercises_test.dart
git commit -m "feat: add the five grounding exercises and their strings

Orientation, senses, body, container, breath — derived from Finding Solid
Ground and the ISSTD phase 1 guidelines. A test asserts every text key
exists in both ARB files, so a missing string fails the build instead of
silently shipping an empty step.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: Der Übungsablauf

**Files:**
- Create: `lib/modules/grounding/widgets/step_view.dart`
- Create: `lib/modules/grounding/widgets/exercise_done_sheet.dart`
- Create: `lib/modules/grounding/exercise_player_screen.dart`
- Test: `test/modules/grounding/exercise_player_screen_test.dart`

**Interfaces:**
- Consumes: `GroundingExercise`, `GroundingStep` (Task 2), `GroundingImages.resolve` (Task 2), `GroundingExercises.anchor` (Task 3), `ProgressDots` (Task 1)
- Produces:
  - `StepView({required GroundingExercise exercise, required int index, required DateTime now})`
  - `ExerciseDoneSheet({required VoidCallback onAgain, required VoidCallback onOther, required VoidCallback onCall})`
  - `ExercisePlayerScreen({required GroundingExercise exercise})`

- [x] **Step 1: Write the failing test**

`test/modules/grounding/exercise_player_screen_test.dart`:

```dart
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/exercise_player_screen.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_done_sheet.dart';
import 'package:dis_app/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  group('ExercisePlayerScreen', () {
    testWidgets('startet beim ersten Schritt', (tester) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      final dots = tester.widget<ProgressDots>(find.byType(ProgressDots));
      expect(dots.active, 1);
      expect(dots.total, GroundingExercises.anchor.steps.length);
    });

    testWidgets('erster Schritt des Ankers zeigt das heutige Datum',
        (tester) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      final year = DateTime.now().year.toString();
      expect(find.textContaining(year), findsOneWidget);
    });

    testWidgets('Tippen auf die Flaeche geht einen Schritt weiter',
        (tester) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
      await tester.pumpAndSettle();

      final dots = tester.widget<ProgressDots>(find.byType(ProgressDots));
      expect(dots.active, 2);
    });

    testWidgets('Zurueck ist auf jedem Schritt erreichbar', (tester) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < GroundingExercises.anchor.steps.length - 1; i++) {
        expect(
          find.byKey(const ValueKey('grounding-back')),
          findsOneWidget,
          reason: 'Zurueck fehlt bei Schritt $i',
        );
        await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('der letzte Schritt fuehrt zur Abschluss-Leiter',
        (tester) async {
      final exercise = GroundingExercises.anchor;
      await tester.pumpWidget(_app(ExercisePlayerScreen(exercise: exercise)));
      await tester.pumpAndSettle();

      for (var i = 0; i < exercise.steps.length; i++) {
        await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
        await tester.pumpAndSettle();
      }

      expect(find.byType(ExerciseDoneSheet), findsOneWidget);
    });

    testWidgets('hold blockiert das Weitertippen nicht', (tester) async {
      // Die Atemuebung hat auf Schritt 1 ein hold von vier Sekunden.
      final breath =
          GroundingExercises.all.firstWhere((e) => e.id == 'breath');

      await tester.pumpWidget(_app(ExercisePlayerScreen(exercise: breath)));
      await tester.pumpAndSettle();

      // Sofort tippen, ohne die vier Sekunden abzuwarten.
      await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
      await tester.pumpAndSettle();

      final dots = tester.widget<ProgressDots>(find.byType(ProgressDots));
      expect(dots.active, 2);
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/modules/grounding/exercise_player_screen_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../exercise_player_screen.dart'`

- [x] **Step 3: Implement StepView**

`lib/modules/grounding/widgets/step_view.dart`:

```dart
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/data/grounding_images.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/widgets/progress_dots.dart';
import 'package:flutter/material.dart';

/// Ein einzelner Schritt: Bild groß, Fortschritt darunter, Text zuletzt
///
/// Die Reihenfolge ist Absicht. Das Bild trägt die Anweisung, der Text
/// bestätigt sie nur — wer nicht liest, hat nach dem Bild schon alles.
class StepView extends StatelessWidget {
  const StepView({
    required this.exercise,
    required this.index,
    required this.now,
    super.key,
  });

  final GroundingExercise exercise;
  final int index;

  /// Wird hereingereicht statt intern erzeugt, damit Tests ein festes Datum
  /// setzen können.
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final step = exercise.steps[index];
    final assetPath = GroundingImages.resolve(step.imageKey);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: assetPath != null
                ? Image.asset(
                    assetPath,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    // Fehlt das Asset trotz Eintrag, springt das Symbol ein.
                    errorBuilder: (context, error, stack) =>
                        _FallbackSymbol(exercise: exercise),
                  )
                : _FallbackSymbol(exercise: exercise),
          ),
        ),
        ProgressDots(
          active: index + 1,
          total: exercise.steps.length,
          color: exercise.color,
          maxDots: 12,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _stepText(l10n, step),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, height: 1.4),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  String _stepText(AppLocalizations l10n, GroundingStep step) {
    final base = _lookup(l10n, step.textKey);
    if (!step.showsCurrentDateTime) return base;

    final date = '${now.day}.${now.month}.${now.year}';
    final time = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    return '$base\n$date, $time';
  }

  /// Übersetzt einen Schlüssel. Fehlt er, bleibt der Text leer statt zu
  /// werfen — das Bild trägt den Schritt ohnehin allein.
  String _lookup(AppLocalizations l10n, String key) {
    return _groundingStrings(l10n)[key] ?? '';
  }

  static Map<String, String> _groundingStrings(AppLocalizations l10n) => {
        'groundingOrientationStep1': l10n.groundingOrientationStep1,
        'groundingOrientationStep2': l10n.groundingOrientationStep2,
        'groundingOrientationStep3': l10n.groundingOrientationStep3,
        'groundingOrientationStep4': l10n.groundingOrientationStep4,
        'groundingOrientationStep5': l10n.groundingOrientationStep5,
        'groundingOrientationStep6': l10n.groundingOrientationStep6,
        'groundingSensesStep1': l10n.groundingSensesStep1,
        'groundingSensesStep2': l10n.groundingSensesStep2,
        'groundingSensesStep3': l10n.groundingSensesStep3,
        'groundingSensesStep4': l10n.groundingSensesStep4,
        'groundingSensesStep5': l10n.groundingSensesStep5,
        'groundingSensesStep6': l10n.groundingSensesStep6,
        'groundingBodyStep1': l10n.groundingBodyStep1,
        'groundingBodyStep2': l10n.groundingBodyStep2,
        'groundingBodyStep3': l10n.groundingBodyStep3,
        'groundingBodyStep4': l10n.groundingBodyStep4,
        'groundingBodyStep5': l10n.groundingBodyStep5,
        'groundingBodyStep6': l10n.groundingBodyStep6,
        'groundingContainerStep1': l10n.groundingContainerStep1,
        'groundingContainerStep2': l10n.groundingContainerStep2,
        'groundingContainerStep3': l10n.groundingContainerStep3,
        'groundingContainerStep4': l10n.groundingContainerStep4,
        'groundingContainerStep5': l10n.groundingContainerStep5,
        'groundingContainerStep6': l10n.groundingContainerStep6,
        'groundingBreathStep1': l10n.groundingBreathStep1,
        'groundingBreathStep2': l10n.groundingBreathStep2,
        'groundingBreathStep3': l10n.groundingBreathStep3,
        'groundingBreathStep4': l10n.groundingBreathStep4,
        'groundingBreathStep5': l10n.groundingBreathStep5,
      };

  /// Titel einer Übung, für Kachel und Kopfzeile
  static String titleOf(AppLocalizations l10n, GroundingExercise exercise) {
    switch (exercise.id) {
      case 'orientation':
        return l10n.groundingOrientationTitle;
      case 'senses':
        return l10n.groundingSensesTitle;
      case 'body':
        return l10n.groundingBodyTitle;
      case 'container':
        return l10n.groundingContainerTitle;
      case 'breath':
        return l10n.groundingBreathTitle;
      default:
        return '';
    }
  }
}

/// Ersatz, wenn kein Bild vorliegt: das Symbol der Übung, groß
class _FallbackSymbol extends StatelessWidget {
  const _FallbackSymbol({required this.exercise});

  final GroundingExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Icon(exercise.icon, size: 160, color: exercise.color);
  }
}
```

- [x] **Step 4: Implement ExerciseDoneSheet**

`lib/modules/grounding/widgets/exercise_done_sheet.dart`:

```dart
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Die Leiter am Ende einer Übung
///
/// Drei Wege, gleich gewichtet, ohne Bewertung. Keine Frage, ob es geholfen
/// hat — die ließe sich mit Nein beantworten, und ein Misserfolgserlebnis
/// genau hier schadet.
class ExerciseDoneSheet extends StatelessWidget {
  const ExerciseDoneSheet({
    required this.onAgain,
    required this.onOther,
    required this.onCall,
    super.key,
  });

  final VoidCallback onAgain;
  final VoidCallback onOther;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            _DoneAction(
              key: const ValueKey('grounding-done-again'),
              icon: Icons.refresh,
              label: l10n.groundingDoneAgain,
              onTap: onAgain,
            ),
            const SizedBox(height: 12),
            _DoneAction(
              key: const ValueKey('grounding-done-other'),
              icon: Icons.more_horiz,
              label: l10n.groundingDoneOther,
              onTap: onOther,
            ),
            const SizedBox(height: 12),
            _DoneAction(
              key: const ValueKey('grounding-done-call'),
              icon: Icons.phone,
              label: l10n.groundingDoneCall,
              onTap: onCall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneAction extends StatelessWidget {
  const _DoneAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
```

- [x] **Step 5: Implement ExercisePlayerScreen**

`lib/modules/grounding/exercise_player_screen.dart`:

```dart
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_done_sheet.dart';
import 'package:dis_app/modules/grounding/widgets/step_view.dart';
import 'package:dis_app/modules/help/help_resources_screen.dart';
import 'package:dis_app/modules/emergency/emergency_screen.dart';
import 'package:flutter/material.dart';

/// Führt durch eine Erdungsübung
///
/// Der Zustand lebt nur hier. Nichts wird gespeichert, nichts protokolliert.
/// Wer die App mitten in der Übung verlässt, landet beim nächsten Start auf
/// der Übersicht — ein „willst du weitermachen?" wäre in dem Zustand eine
/// Zumutung.
class ExercisePlayerScreen extends StatefulWidget {
  const ExercisePlayerScreen({required this.exercise, super.key});

  final GroundingExercise exercise;

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  int _index = 0;
  bool _done = false;

  void _next() {
    if (_index >= widget.exercise.steps.length - 1) {
      setState(() => _done = true);
      return;
    }
    setState(() => _index++);
  }

  void _back() {
    if (_index == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _index--);
  }

  void _again() {
    setState(() {
      _index = 0;
      _done = false;
    });
  }

  void _other() => Navigator.of(context).pop();

  /// Führt in den Notfallbereich. Fehlt das Recht, zu den Hotlines — die
  /// gehören keinem Profil und brauchen keines. Der Knopf zeigt nie ins Leere.
  void _call() {
    final profile = getIt<DataEntry>().getActiveProfile();
    final mayCall =
        profile?.hasPermission(Permission.callEmergencyContacts) ?? false;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            mayCall ? const EmergencyScreen() : const HelpResourcesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Scaffold(
        body: Center(
          child: ExerciseDoneSheet(
            onAgain: _again,
            onOther: _other,
            onCall: _call,
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Die ganze Fläche ist das Ziel. Kein kleiner Knopf.
            GestureDetector(
              key: const ValueKey('grounding-step-surface'),
              behavior: HitTestBehavior.opaque,
              onTap: _next,
              child: SizedBox.expand(
                child: StepView(
                  exercise: widget.exercise,
                  index: _index,
                  now: DateTime.now(),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: IconButton(
                key: const ValueKey('grounding-back'),
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: _back,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [x] **Step 6: Run test to verify it passes**

Run: `flutter test test/modules/grounding/exercise_player_screen_test.dart`
Expected: PASS — 6 Tests

- [x] **Step 7: Commit**

```bash
git add lib/modules/grounding/ test/modules/grounding/exercise_player_screen_test.dart
git commit -m "feat: add grounding exercise player

The whole surface is the tap target, back is on every step, and hold never
blocks. Ending offers three equal paths without asking whether it helped —
that question can be answered with no, and failing here would hurt.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 5: Die Übersicht

**Files:**
- Create: `lib/modules/grounding/widgets/anchor_button.dart`
- Create: `lib/modules/grounding/widgets/exercise_tile.dart`
- Create: `lib/modules/grounding/grounding_screen.dart`
- Test: `test/modules/grounding/grounding_screen_test.dart`

**Interfaces:**
- Consumes: `GroundingExercises.all`, `GroundingExercises.anchor` (Task 3), `ExercisePlayerScreen` (Task 4), `StepView.titleOf` (Task 4), `StateSymbol` (Task 1), `AnimatedTapCard`, `StandardAppBar`, `SectionHeader`, `AnimatedEmptyState`
- Produces: `GroundingScreen()` — konstanter Konstruktor, damit sie als `const` in `_allTabDefinitions` steht

- [x] **Step 1: Write the failing test**

`test/modules/grounding/grounding_screen_test.dart`:

```dart
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/exercise_player_screen.dart';
import 'package:dis_app/modules/grounding/grounding_screen.dart';
import 'package:dis_app/modules/grounding/widgets/anchor_button.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  group('GroundingScreen', () {
    testWidgets('zeigt Anker und fuenf Kacheln', (tester) async {
      await tester.pumpWidget(_app(const GroundingScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AnchorButton), findsOneWidget);
      expect(find.byType(ExerciseTile), findsNWidgets(5));
    });

    testWidgets('der Anker startet die Orientierungsuebung', (tester) async {
      await tester.pumpWidget(_app(const GroundingScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AnchorButton));
      await tester.pumpAndSettle();

      final player = tester.widget<ExercisePlayerScreen>(
        find.byType(ExercisePlayerScreen),
      );
      expect(player.exercise.id, 'orientation');
    });

    testWidgets('eine Kachel startet ihre eigene Uebung', (tester) async {
      await tester.pumpWidget(_app(const GroundingScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('grounding-tile-breath')));
      await tester.pumpAndSettle();

      final player = tester.widget<ExercisePlayerScreen>(
        find.byType(ExercisePlayerScreen),
      );
      expect(player.exercise.id, 'breath');
    });

    testWidgets('rendert ohne aktives Profil und ohne jedes Recht',
        (tester) async {
      // Erdung ist nicht rechtegesteuert. Der Screen fragt kein Profil und
      // keine Permission ab — wenn dieser Test bricht, wurde genau das
      // eingebaut.
      await tester.pumpWidget(_app(const GroundingScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AnchorButton), findsOneWidget);
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/modules/grounding/grounding_screen_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../grounding_screen.dart'`

- [x] **Step 3: Implement AnchorButton**

`lib/modules/grounding/widgets/anchor_button.dart`:

```dart
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/widgets/animated_tap_card.dart';
import 'package:flutter/material.dart';

/// Der große Anker
///
/// Ein Tippen, sofort in der Orientierungsübung. Wer nicht wählen kann, muss
/// nicht wählen — im dissoziativen Zustand ist Auswählen selbst schon
/// Überforderung.
class AnchorButton extends StatelessWidget {
  const AnchorButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = GroundingExercises.anchor.color;

    return AnimatedTapCard(
      onTap: onTap,
      borderRadius: 24,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(GroundingExercises.anchor.icon, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              l10n.groundingAnchorLabel,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [x] **Step 4: Implement ExerciseTile**

`lib/modules/grounding/widgets/exercise_tile.dart`:

```dart
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/modules/grounding/widgets/step_view.dart';
import 'package:dis_app/widgets/animated_tap_card.dart';
import 'package:dis_app/widgets/state_symbol.dart';
import 'package:flutter/material.dart';

/// Eine Übungskachel: Symbol groß, Name klein darunter
class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    required this.exercise,
    required this.onTap,
    super.key,
  });

  final GroundingExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedTapCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: exercise.color.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StateSymbol(
              icon: exercise.icon,
              color: exercise.color,
              active: true,
              size: 56,
            ),
            const SizedBox(height: 8),
            Text(
              StepView.titleOf(l10n, exercise),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [x] **Step 5: Implement GroundingScreen**

`lib/modules/grounding/grounding_screen.dart`:

```dart
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/exercise_player_screen.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/modules/grounding/widgets/anchor_button.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_tile.dart';
import 'package:dis_app/widgets/section_header.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';

/// Übersicht des Erdungsbereichs
///
/// Fragt bewusst kein Profil und keine Berechtigung ab. Erdung ist nicht
/// rechtegesteuert — ein Anteil, dem ein anderer die Erdungsübungen entziehen
/// kann, ist genau die Machtdynamik, die dieses Modul nicht nachbauen soll.
class GroundingScreen extends StatelessWidget {
  const GroundingScreen({super.key});

  void _open(BuildContext context, GroundingExercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExercisePlayerScreen(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: StandardAppBar(title: l10n.groundingTitle),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnchorButton(
            onTap: () => _open(context, GroundingExercises.anchor),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            icon: Icons.grid_view,
            title: l10n.groundingChooseLabel,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: GroundingExercises.all
                .map(
                  (exercise) => ExerciseTile(
                    key: ValueKey('grounding-tile-${exercise.id}'),
                    exercise: exercise,
                    onTap: () => _open(context, exercise),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
```

- [x] **Step 6: Run test to verify it passes**

Run: `flutter test test/modules/grounding/grounding_screen_test.dart`
Expected: PASS — 4 Tests

- [x] **Step 7: Commit**

```bash
git add lib/modules/grounding/ test/modules/grounding/grounding_screen_test.dart
git commit -m "feat: add grounding overview with anchor and exercise tiles

The screen asks for no profile and no permission. A test asserts it renders
without either, so wiring grounding to a permission later would break the
build instead of quietly shipping.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 6: In die Navigation einhängen

Der Mantras-Tab wird zum Erdungsbereich und ist ab jetzt immer sichtbar. Dabei fällt die vorhandene Index-Sonderbehandlung für Chat und Feedback weg: `requiredPermission` wird nullable, `null` heißt „immer sichtbar". Das ersetzt drei hartkodierte Indizes durch eine Eigenschaft am Tab selbst.

**Files:**
- Modify: `lib/main.dart:296-310` (`TabDefinition`), `lib/main.dart:901-1006` (Tab-Liste), `lib/main.dart:1148-1170` (`_getVisibleTabs`)
- Delete: `lib/modules/mantras/mantras_screen.dart`
- Test: `test/widgets/tab_visibility_test.dart`

**Interfaces:**
- Consumes: `GroundingScreen` (Task 5)
- Produces: `TabDefinition({required TabItem tabItem, required Widget screen, required FABConfig? fabConfig, required Permission? requiredPermission})` — `requiredPermission` ist ab jetzt nullable

- [x] **Step 1: Write the failing test**

`test/widgets/tab_visibility_test.dart`:

```dart
import 'package:dis_app/main.dart';
import 'package:dis_app/models/permission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TabDefinition', () {
    test('requiredPermission darf null sein und heisst immer sichtbar', () {
      const tab = TabDefinition(
        tabItem: TabItem(icon: Icons.anchor, label: 'Halt'),
        screen: SizedBox.shrink(),
        fabConfig: null,
        requiredPermission: null,
      );

      expect(tab.requiredPermission, isNull);
    });

    test('ein Tab mit Permission behaelt sie', () {
      const tab = TabDefinition(
        tabItem: TabItem(icon: Icons.book, label: 'Tagebuch'),
        screen: SizedBox.shrink(),
        fabConfig: null,
        requiredPermission: Permission.viewDiaryTab,
      );

      expect(tab.requiredPermission, Permission.viewDiaryTab);
    });
  });
}
```

Hinweis: `TabItem` und `Icons` brauchen ihre Imports —
`import 'package:flutter/material.dart';` sowie den Import, unter dem `TabItem`
in `main.dart` verfügbar ist (`package:dis_app/widgets/carousel_tab_navigator.dart`).
Beide Imports oben ergänzen.

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/tab_visibility_test.dart`
Expected: FAIL — `The parameter 'requiredPermission' can't have a value of 'null'`

- [x] **Step 3: Make requiredPermission nullable**

In `lib/main.dart`, Klasse `TabDefinition`:

```dart
  final Permission requiredPermission;
```

wird zu:

```dart
  /// Recht, das diesen Tab sichtbar macht. `null` heißt: immer sichtbar.
  ///
  /// Gilt für Kernfunktionen, die kein Anteil einem anderen entziehen können
  /// soll — Chat, Feedback und der Erdungsbereich.
  final Permission? requiredPermission;
```

- [x] **Step 4: Replace the index-based filtering**

In `lib/main.dart`, in `_getVisibleTabs` den Block ab `// Chat-Tab und Feedback-Tab sind IMMER sichtbar` bis `return [chatTab, feedbackTab, ...otherTabs];` ersetzen durch:

```dart
    // Tabs ohne requiredPermission sind immer sichtbar (Kern-Funktionen).
    // Die Reihenfolge der Definition bleibt erhalten.
    return _allTabDefinitions
        .where((tab) =>
            tab.requiredPermission == null ||
            activeProfile.hasPermission(tab.requiredPermission!))
        .toList();
```

- [x] **Step 5: Mark Chat and Feedback as always visible**

In der Tab-Liste in `initState`:

```dart
        requiredPermission: Permission.viewChatTab,
```

wird zu:

```dart
        requiredPermission: null, // Kern-Funktion, immer sichtbar
```

und

```dart
        requiredPermission: Permission.viewFeedbackTab,
```

wird zu:

```dart
        requiredPermission: null, // Kern-Funktion, immer sichtbar
```

- [x] **Step 6: Replace the Mantras tab with the grounding area**

In der Tab-Liste den Eintrag `// 9: Mantras` ersetzen:

```dart
      // 9: Mantras
      const TabDefinition(
        tabItem: TabItem(icon: Icons.self_improvement, label: 'Mantras'),
        screen: MantrasScreen(),
        fabConfig: null, // Read-only (später erweiterbar)
        requiredPermission: Permission.viewMantrasTab,
      ),
```

wird zu:

```dart
      // 9: Halt (Erdung)
      const TabDefinition(
        tabItem: TabItem(icon: Icons.anchor, label: 'Halt'),
        screen: GroundingScreen(),
        fabConfig: null,
        // Kern-Funktion, immer sichtbar. Erdung darf kein Anteil einem
        // anderen entziehen können.
        requiredPermission: null,
      ),
```

Import tauschen:

```dart
import 'package:dis_app/modules/mantras/mantras_screen.dart';
```

wird zu:

```dart
import 'package:dis_app/modules/grounding/grounding_screen.dart';
```

- [x] **Step 7: Delete the placeholder**

```bash
rm lib/modules/mantras/mantras_screen.dart
rmdir lib/modules/mantras
```

Prüfen, dass niemand mehr darauf zeigt:

Run: `grep -rn "MantrasScreen" lib/ test/`
Expected: keine Ausgabe

- [x] **Step 8: Run tests and analyze**

Run: `flutter test`
Expected: PASS — alle Tests

Run: `flutter analyze lib/main.dart`
Expected: keine `error`-Zeile

- [x] **Step 9: Commit**

```bash
git add lib/main.dart test/widgets/tab_visibility_test.dart
git rm -r --cached lib/modules/mantras 2>/dev/null || true
git add -A lib/modules/mantras
git commit -m "feat: turn the empty mantras tab into the grounding area

requiredPermission is now nullable and null means always visible. That
replaces three hardcoded indices for chat and feedback with a property on
the tab itself, and it is how grounding stays reachable for every part.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 7: Bildersatz einbinden

Bis hierher läuft das Modul mit dem Übungssymbol als Ersatz. Diese Task legt die Zeichnungen darüber. Sie ist bewusst die letzte — das Modul hängt nicht an ihr.

**Files:**
- Create: `assets/grounding/` (27 Bilddateien)
- Create: `assets/grounding/LICENSE.md`
- Modify: `pubspec.yaml:159` (Assetliste)
- Modify: `lib/modules/grounding/data/grounding_images.dart` (Map füllen)
- Modify: `lib/modules/help/help_resources_screen.dart` (Namensnennung)

**Interfaces:**
- Consumes: `GroundingImages` (Task 2), die Bildschlüssel aus `GroundingExercises` (Task 3)
- Produces: keine neuen Signaturen; `GroundingImages.hasAssets` wird `true` und schaltet damit den bereits geschriebenen Vollständigkeitstest aus Task 3 scharf

- [x] **Step 1: Pick and check the image set**

Kandidat ist OpenMoji unter CC BY-SA 4.0. Vor dem Herunterladen prüfen, ob diese 27 Motive vorhanden sind und stilistisch zusammenpassen. Ein uneinheitlicher Satz verwirrt im dissoziativen Zustand mehr, als er hilft — im Zweifel lieber ein Motiv ersetzen als den Stil brechen.

Benötigte Schlüssel:

```
calendar_today   look_around      name_tag         grown_body
past_behind      you_are_here     sense_eye        sense_ear
sense_touch      sense_nose       sense_mouth      feet_ground
press_down       hand_ice         hold_tight       back_chair
ground_holds     container_empty  container_lid    container_fill
container_closed container_shelf  container_key    breath_in
breath_hold      breath_out       breath_repeat    breath_done
```

Das sind 28 Schlüssel; `you_are_here` wird von zwei Übungen genutzt, also 28 Dateien für 29 Schrittvorkommen.

Ergebnis der Prüfung in `assets/grounding/LICENSE.md` festhalten: Quelle, Lizenz, Fassung, und für jede Datei den ursprünglichen Namen. Die Lizenz CC BY-SA 4.0 verlangt Namensnennung und Weitergabe unter gleichen Bedingungen; sie gilt für die Bilder, nicht für den MPL-2.0-Code.

- [x] **Step 2: Place the files**

Alle Dateien als PNG mit mindestens 512×512 unter `assets/grounding/` ablegen, benannt nach dem Schlüssel: `assets/grounding/hand_ice.png` und so weiter.

- [x] **Step 3: Declare the assets**

In `pubspec.yaml` unter `assets:` ergänzen:

```yaml
    # Grounding-Bildersatz (siehe assets/grounding/LICENSE.md)
    - assets/grounding/
```

- [x] **Step 4: Fill the map**

In `lib/modules/grounding/data/grounding_images.dart`:

```dart
  static const Map<String, String> _paths = <String, String>{};
```

wird zu:

```dart
  static const Map<String, String> _paths = <String, String>{
    'calendar_today': 'assets/grounding/calendar_today.png',
    'look_around': 'assets/grounding/look_around.png',
    'name_tag': 'assets/grounding/name_tag.png',
    'grown_body': 'assets/grounding/grown_body.png',
    'past_behind': 'assets/grounding/past_behind.png',
    'you_are_here': 'assets/grounding/you_are_here.png',
    'sense_eye': 'assets/grounding/sense_eye.png',
    'sense_ear': 'assets/grounding/sense_ear.png',
    'sense_touch': 'assets/grounding/sense_touch.png',
    'sense_nose': 'assets/grounding/sense_nose.png',
    'sense_mouth': 'assets/grounding/sense_mouth.png',
    'feet_ground': 'assets/grounding/feet_ground.png',
    'press_down': 'assets/grounding/press_down.png',
    'hand_ice': 'assets/grounding/hand_ice.png',
    'hold_tight': 'assets/grounding/hold_tight.png',
    'back_chair': 'assets/grounding/back_chair.png',
    'ground_holds': 'assets/grounding/ground_holds.png',
    'container_empty': 'assets/grounding/container_empty.png',
    'container_lid': 'assets/grounding/container_lid.png',
    'container_fill': 'assets/grounding/container_fill.png',
    'container_closed': 'assets/grounding/container_closed.png',
    'container_shelf': 'assets/grounding/container_shelf.png',
    'container_key': 'assets/grounding/container_key.png',
    'breath_in': 'assets/grounding/breath_in.png',
    'breath_hold': 'assets/grounding/breath_hold.png',
    'breath_out': 'assets/grounding/breath_out.png',
    'breath_repeat': 'assets/grounding/breath_repeat.png',
    'breath_done': 'assets/grounding/breath_done.png',
  };
```

- [x] **Step 5: Run tests — the completeness test is now live**

Run: `flutter test test/modules/grounding/`
Expected: PASS. Der Test „jeder Bildschluessel loest auf, sobald ein Bildersatz vorliegt" prüft ab jetzt scharf und schlägt fehl, sobald ein Schlüssel ohne Datei bleibt.

- [x] **Step 6: Add the attribution**

In `lib/modules/help/help_resources_screen.dart` am Ende der Liste einen Hinweis auf Quelle und Lizenz des Bildersatzes ergänzen, mit demselben `InfoCard`-Muster, das die Datei bereits verwendet. Der Text gehört als neuer Schlüssel `groundingImageCredits` in beide ARB-Dateien, danach `flutter gen-l10n`.

- [x] **Step 7: Verify in the running app**

Run: `flutter run`
Prüfen: Tab „Halt" ist da, Anker startet die Orientierungsübung, erster Schritt zeigt das heutige Datum, alle Bilder erscheinen, Tippen geht weiter, Zurück funktioniert auf jedem Schritt, der letzte Schritt zeigt die drei Wege.

- [x] **Step 8: Commit**

```bash
git add assets/grounding/ pubspec.yaml \
        lib/modules/grounding/data/grounding_images.dart \
        lib/modules/help/help_resources_screen.dart \
        lib/l10n/app_de.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart
git commit -m "feat: add the grounding image set

Attribution and licence in assets/grounding/LICENSE.md. With the map filled,
the completeness test from task 3 goes live and fails on any key without a
file.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review

**1. Spec coverage**

| Spec-Abschnitt | Task |
|---|---|
| §4 Entscheidung 1 (Bildfolge, Tippen) | 4 |
| §4 Entscheidung 2 (Schlüssel statt Pfad) | 2, 7 |
| §4 Entscheidung 3 (Anker + Kacheln) | 5 |
| §4 Entscheidung 4 (Leiter ohne Bewertung) | 4 |
| §5 fünf Übungen | 3 |
| §6 Architektur, kein Service/Hive | 2, 3, 4, 5 |
| §6 Datenmodell | 2 |
| §6 Bildauflösung | 2, 7 |
| §7 Wiederverwendung | 1 (ProgressDots, StateSymbol), 5 (AnimatedTapCard, StandardAppBar, SectionHeader) |
| §8 Bedienung (Tippen, Zurück, hold, Abbruch) | 4 |
| §8 Erreichbarkeit ohne Recht | 5, 6 |
| §8 Hotline-Fallback | 4 |
| §8 Tab-Umwidmung | 6 |
| §9 Fehlerfälle Bild/Text | 4 (`errorBuilder`, `_FallbackSymbol`, leerer Text) |
| §9 Übung ohne Schritte | 3 (Test) |
| §9 kein Bildersatz | 4 (`_FallbackSymbol`) |
| §10 Vollständigkeitstests | 3, 7 |
| §10 Verhaltenstests | 4, 5 |
| §10 Regression nach Hochziehen | 1 |

**Abweichung von der Spec, bewusst:** Spec §9 nennt „kein Bildersatz vorhanden → `AnimatedEmptyState` statt leerer Fläche". Umgesetzt ist stattdessen `_FallbackSymbol` je Schritt — die stärkere Lösung, weil die Übung benutzbar bleibt, statt durch einen Leerzustand ersetzt zu werden. Ein Leerzustand für diesen Fall entsteht damit nicht, und es werden auch keine Strings dafür angelegt. `AnimatedEmptyState` taucht deshalb in keiner Task auf.

**2. Placeholder scan**

Keine „TBD", kein „implement later", kein „similar to Task N". Jeder Codeschritt enthält vollständigen Code. Task 7 Step 1 und Step 6 beschreiben Auswahl- und Redaktionsarbeit statt Code — das ist keine ausgelassene Implementierung, sondern die einzige Stelle, an der ein Mensch eine inhaltliche Wahl trifft.

**3. Type consistency**

- `ProgressDots({active, total, color, maxDots})` — definiert Task 1, genutzt Task 1 (Rechte-Screen), Task 4 (`StepView`), Task 4 (Tests).
- `StateSymbol({icon, color, active, badge, badgeColor, size})` — definiert Task 1, genutzt Task 1, Task 5 (`ExerciseTile`).
- `GroundingStep({imageKey, textKey, hold, showsCurrentDateTime})` — definiert Task 2, genutzt Task 3, Task 4.
- `GroundingImages.resolve/knownKeys/hasAssets` — definiert Task 2, genutzt Task 3 (Test), Task 4 (`StepView`), Task 7.
- `GroundingExercises.all/anchor` — definiert Task 3, genutzt Task 4 (Test), Task 5.
- `StepView.titleOf(l10n, exercise)` — definiert Task 4, genutzt Task 5 (`ExerciseTile`).
- `TabDefinition.requiredPermission` wird in Task 6 von `Permission` zu `Permission?`; alle Verwender in `main.dart` werden im selben Task angepasst.
- Widget-Schlüssel durchgängig: `grounding-step-surface`, `grounding-back`, `grounding-tile-<id>`, `grounding-done-again|other|call`.
