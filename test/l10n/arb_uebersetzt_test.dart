import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Wacht darüber, dass die Übersetzungen auch übersetzt sind.
///
/// `arb_completeness_test.dart` prüft, dass jeder Schlüssel in jeder Sprache
/// steht. Das reicht nicht: Ein kopierter deutscher Text erfüllt die Prüfung
/// und steht trotzdem auf Deutsch in der spanischen App. Und ein höfliches
/// „Veuillez" erfüllt sie auch, obwohl Aurora überall „du" sagt — am
/// 06.10.2026 stand im französischen Sprachwähler noch „Choisissez votre
/// langue" neben lauter „tu".
void main() {
  const locales = ['en', 'es', 'fr', 'it'];

  Map<String, String> load(String locale) {
    final raw =
        jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
            as Map<String, dynamic>;
    return {
      for (final e in raw.entries)
        if (!e.key.startsWith('@')) e.key: e.value as String,
    };
  }

  final de = load('de');

  /// Werte, die in jeder Sprache gleich heißen dürfen: Eigennamen, Kürzel,
  /// international gebräuchliche Wörter und reine Platzhalter-Gerüste.
  const gleichErlaubt = <String>{
    'Aurora',
    'Chat',
    'App',
    'SMS',
    'GitHub',
    'Website',
    'Avatar',
    'Memory',
    'Puzzle',
    'Mantras',
    'Admin',
    'Administrator',
    'Online',
    'Stop',
    'Finder',
    'Neutral',
    'Optional',
    'Status',
    'Information',
    'Details',
    'Sticker',
    'Feedback',
    'Name',
    'Name *',
    'Galerie',
    'Adresse',
    '[Video]',
    '[Doodle]',
    'Legepuzzle',
  };

  bool nurGeruest(String wert) =>
      !RegExp(r'[A-Za-zÀ-ÿ]{3,}').hasMatch(wert.replaceAll(
        RegExp(r'\{\w+\}'),
        '',
      ));

  for (final locale in locales) {
    test('app_$locale.arb übernimmt keinen deutschen Text ungeprüft', () {
      final arb = load(locale);
      final kopiert = <String>[];
      for (final key in de.keys) {
        final wert = arb[key];
        if (wert == null) continue; // meldet arb_completeness_test
        if (wert.trim() != de[key]!.trim()) continue;
        if (gleichErlaubt.contains(wert.trim()) || nurGeruest(wert)) continue;
        kopiert.add('$key = "$wert"');
      }
      kopiert.sort();
      expect(
        kopiert,
        isEmpty,
        reason:
            '$locale: ${kopiert.length} Texte stehen wörtlich wie auf Deutsch. '
            'Ist einer davon ein Eigenname, gehört er in gleichErlaubt. '
            'Erste fünf: ${kopiert.take(5).join("; ")}',
      );
    });
  }

  test('Französisch duzt durchgehend', () {
    // „Vous" allein taugt nicht als Prüfung: Wo das Deutsche „ihr" sagt
    // (an das ganze System), ist „vous" der richtige Plural. Die Siezform
    // verrät sich an den höflichen Imperativen und am Possessiv „votre".
    final fr = load('fr');
    final siezt = RegExp(
      r'\b(Veuillez|Choisissez|Saisissez|Entrez|Sélectionnez|Appuyez|votre)\b',
    );
    final treffer = [
      for (final e in fr.entries)
        if (siezt.hasMatch(e.value)) '${e.key} = "${e.value}"',
    ]..sort();
    expect(
      treffer,
      isEmpty,
      reason: 'fr: ${treffer.length} Texte siezen. ${treffer.take(5).join("; ")}',
    );
  });

  test('Spanisch nennt die Erinnerung immer recordatorio', () {
    // Dieselbe Sache hieß mal „aviso", mal „recordatorio" — auf dem
    // Sperrbildschirm das eine, in den Einstellungen dazu das andere.
    final es = load('es');
    final erinnerung = RegExp(r'\bErinnerung');
    final abweichend = [
      for (final key in de.keys)
        if (erinnerung.hasMatch(de[key]!) &&
            RegExp(r'\baviso', caseSensitive: false).hasMatch(es[key] ?? ''))
          key,
    ]..sort();
    expect(abweichend, isEmpty, reason: 'es: $abweichend');
  });
}
