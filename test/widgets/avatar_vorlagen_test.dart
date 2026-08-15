import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Wacht über die Avatar-Vorlagen im Profilbild-Wähler.
///
/// Bis zum 14.08.2026 standen dort drei fremde Tierbilder — Hund, Katze,
/// Giraffe —, deren Herkunft und Nutzungsrecht niemand belegen konnte. In
/// einer App, die Open Source gehen soll, ist ein Bild ohne Lizenz kein
/// Schönheitsfehler: es wandert mit jeder Kopie des Quelltextes weiter.
///
/// Ersetzt durch Aurora-eigene Chamäleons aus demselben Bestand, aus dem auch
/// die Bereichsbilder kommen.
///
/// Drei Wege, auf denen eine Vorlage still kaputtgehen kann, und alle drei
/// zeigen sich erst am Gerät: die Datei fehlt, sie steht nicht in `pubspec`
/// (dann fehlt sie im Bündel und der Wähler zeigt ein rotes Fehlersymbol),
/// oder ihr Name fehlt in einer der fünf Sprachen.
void main() {
  // Kein `expect` hier oben: Die Liste der Vorlagen wird beim Laden der Datei
  // gebaut, und dort gibt es noch keinen laufenden Test, in dem eine
  // Erwartung fehlschlagen koennte.
  String lies(String pfad) {
    final datei = File(pfad);
    if (!datei.existsSync()) throw StateError('Datei fehlt: $pfad');
    return datei.readAsStringSync();
  }

  final quelle = lies('lib/widgets/animal_avatar_picker_dialog.dart');

  final pfade = RegExp(r"assetPath: '([^']+)'")
      .allMatches(quelle)
      .map((t) => t.group(1)!)
      .toList();

  final namen = RegExp(r'l10n\.(animalAvatar\w+)')
      .allMatches(quelle)
      .map((t) => t.group(1)!)
      .toList();

  test('keine fremden Tierbilder mehr', () {
    for (final fremd in ['Hund.png', 'Katze.webp', 'Girafe.png']) {
      expect(
        quelle.contains(fremd),
        isFalse,
        reason: '$fremd steht wieder im Wähler. Herkunft und Nutzungsrecht '
            'sind ungeklärt — das gehört nicht in ein offenes Repo.',
      );
      expect(
        File('assets/images/$fremd').existsSync(),
        isFalse,
        reason: '$fremd liegt wieder in assets/. Auch ungenutzt wandert es '
            'mit jeder Kopie weiter.',
      );
      expect(
        lies('pubspec.yaml').contains(fremd),
        isFalse,
        reason: '$fremd steht wieder in pubspec und landet im Bündel.',
      );
    }
  });

  test('der Wähler bietet mehr als eine Handvoll Vorlagen', () {
    expect(
      pfade.length,
      greaterThanOrEqualTo(6),
      reason: 'Ein Profilbild ist für viele Anteile die erste eigene '
          'Entscheidung. Drei Vorlagen sind dafür zu wenig.',
    );
  });

  test('jede Vorlage hat eine Datei und steht in pubspec', () {
    final pubspec = lies('pubspec.yaml');
    for (final pfad in pfade) {
      expect(File(pfad).existsSync(), isTrue, reason: 'Datei fehlt: $pfad');
      expect(
        pubspec.contains(pfad),
        isTrue,
        reason: '$pfad steht nicht in pubspec. Die Datei liegt dann zwar im '
            'Baum, fehlt aber im Bündel — der Wähler zeigt an ihrer Stelle '
            'ein rotes Fehlersymbol, und zwar erst am Gerät.',
      );
    }
  });

  test('jede Vorlage trägt einen Namen in allen fünf Sprachen', () {
    expect(namen.length, pfade.length,
        reason: 'Jede Vorlage braucht genau einen Namen.');
    for (final sprache in ['de', 'en', 'es', 'fr', 'it']) {
      final arb = lies('lib/l10n/app_$sprache.arb');
      for (final name in namen) {
        expect(
          arb.contains('"$name"'),
          isTrue,
          reason: 'Für $sprache fehlt $name. Ein Wähler ohne Namen ist in '
              'der falschen Sprache nicht schlimmer als gar nicht — er ist '
              'gar nicht bedienbar.',
        );
      }
    }
  });
}
