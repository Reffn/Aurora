/// Die Sprachen, die Aurora spricht — an einer Stelle.
///
/// Die Liste stand zweimal im Code: einmal in der Erst-Einrichtung, einmal in
/// den Einstellungen. Mit der Sprache je Anteil wäre eine dritte Kopie
/// dazugekommen, und wer eine Sprache ergänzt, hätte sie an drei Stellen
/// finden müssen. Wer hier etwas ändert, muss auch `supportedLocales` in
/// `main.dart` und die `app_*.arb` mitziehen.
library;

class SupportedLanguage {
  const SupportedLanguage(this.code, this.flag, this.name);

  /// ISO-639-1, wie er in `Locale(...)` und am Profil steht.
  final String code;

  final String flag;

  /// Der Name in der Sprache selbst — wer Español sucht, sucht nicht
  /// „Spanisch".
  final String name;
}

const supportedLanguages = <SupportedLanguage>[
  SupportedLanguage('de', '🇩🇪', 'Deutsch'),
  SupportedLanguage('en', '🇬🇧', 'English'),
  SupportedLanguage('es', '🇪🇸', 'Español'),
  SupportedLanguage('fr', '🇫🇷', 'Français'),
  SupportedLanguage('it', '🇮🇹', 'Italiano'),
];

/// Der Anzeigename zu einem Code, oder `null` wenn er unbekannt ist.
String? languageNameFor(String? code) {
  if (code == null) return null;
  for (final language in supportedLanguages) {
    if (language.code == code) return language.name;
  }
  return null;
}

/// Die Flagge zu einem Code, oder `null` wenn er unbekannt ist.
String? languageFlagFor(String? code) {
  if (code == null) return null;
  for (final language in supportedLanguages) {
    if (language.code == code) return language.flag;
  }
  return null;
}
