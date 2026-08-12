import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/supported_languages.dart';
import 'package:flutter/material.dart';

/// Was bei der Sprachwahl herauskam.
///
/// Eigener Typ, weil `null` sonst zwei Dinge hieße: „abgebrochen" und „keine
/// eigene Sprache". Der Dialog gibt `null` zurück, wenn niemand gewählt hat,
/// und `LanguageChoice(null)`, wenn der Anteil der App-Einstellung folgen
/// soll.
class LanguageChoice {
  const LanguageChoice(this.code);

  /// ISO-639-1, oder `null` für „der App folgen".
  final String? code;
}

/// Fragt nach einer Sprache.
///
/// [current] wird angehakt. Mit [allowFollowApp] steht „wie die App" zur
/// Wahl — das braucht die Sprache je Anteil, die App-weite Einstellung
/// dagegen nicht.
Future<LanguageChoice?> showLanguageChoiceDialog(
  BuildContext context, {
  String? current,
  bool allowFollowApp = false,
}) {
  final l10n = AppLocalizations.of(context);

  return showDialog<LanguageChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.settingsLanguage),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allowFollowApp)
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(l10n.languageFollowApp),
                trailing: current == null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                selected: current == null,
                onTap: () => Navigator.pop(context, const LanguageChoice(null)),
              ),
            for (final language in supportedLanguages)
              ListTile(
                leading: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(language.name),
                trailing: current == language.code
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                selected: current == language.code,
                onTap: () =>
                    Navigator.pop(context, LanguageChoice(language.code)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
      ],
    ),
  );
}
