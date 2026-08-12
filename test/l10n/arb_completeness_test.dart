import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Wacht darüber, dass jede Sprache jeden Text hat.
///
/// Aurora hatte 697 Schlüssel auf Deutsch und 317 auf Spanisch, Französisch
/// und Italienisch. Die fehlenden 380 fielen still auf die Vorlagensprache
/// zurück: In der spanischen App stand deutscher Text. Niemand hat es
/// bemerkt, weil `gen-l10n` den Rückfall nicht meldet und kein Test danach
/// gefragt hat.
///
/// Dieser Test fragt danach.
void main() {
  const templateLocale = 'de';
  const locales = ['de', 'en', 'es', 'fr', 'it'];

  // Wird beim Aufbau der Gruppen gelesen, also vor dem ersten Test. Hier
  // darf kein `expect` stehen — das wirft ausserhalb eines Tests.
  Map<String, dynamic> load(String locale) {
    final file = File('lib/l10n/app_$locale.arb');
    if (!file.existsSync()) {
      throw StateError('${file.path} fehlt');
    }
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  /// Die Textschlüssel ohne die @-Einträge, die nur Beschreibungen tragen.
  Set<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  /// Platzhalter wie `{count}` oder `{name}` aus einem Text.
  Set<String> placeholders(String value) => RegExp(r'\{(\w+)\}')
      .allMatches(value)
      .map((m) => m.group(1)!)
      .toSet();

  final template = load(templateLocale);
  final templateKeys = messageKeys(template);

  test('die Vorlage ist nicht leer', () {
    expect(templateKeys, isNotEmpty);
  });

  for (final locale in locales.where((l) => l != templateLocale)) {
    group('app_$locale.arb', () {
      final arb = load(locale);
      final keys = messageKeys(arb);

      test('hat jeden Text der Vorlage', () {
        final missing = templateKeys.difference(keys).toList()..sort();
        expect(
          missing,
          isEmpty,
          reason: '$locale fehlen ${missing.length} Texte. '
              'Sie fallen zur Laufzeit still auf Deutsch zurück. '
              'Erste zehn: ${missing.take(10).join(", ")}',
        );
      });

      test('trägt keinen Text, den die Vorlage nicht kennt', () {
        final extra = keys.difference(templateKeys).toList()..sort();
        expect(
          extra,
          isEmpty,
          reason: '$locale hat ${extra.length} Texte ohne Gegenstück in der '
              'Vorlage: ${extra.take(10).join(", ")}',
        );
      });

      test('verwendet dieselben Platzhalter wie die Vorlage', () {
        // Ein fehlender Platzhalter bricht nicht beim Übersetzen auf, sondern
        // erst zur Laufzeit in der Sprache, die niemand testet.
        final mismatched = <String>[];
        for (final key in templateKeys.intersection(keys)) {
          final expected = placeholders(template[key] as String);
          final actual = placeholders(arb[key] as String);
          if (expected.difference(actual).isNotEmpty ||
              actual.difference(expected).isNotEmpty) {
            mismatched.add('$key (erwartet $expected, gefunden $actual)');
          }
        }
        mismatched.sort();
        expect(
          mismatched,
          isEmpty,
          reason: '$locale: ${mismatched.length} Texte mit abweichenden '
              'Platzhaltern. Erste fünf: ${mismatched.take(5).join("; ")}',
        );
      });
    });
  }
}
