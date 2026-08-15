import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Symbol und Wort eines Bereichs.
///
/// Wohnte bis zum Wegfall des Karussells in dessen Datei. Der Ort war ein
/// Zufall der Entstehung: Ein Bereich hat einen Namen und ein Symbol,
/// unabhängig davon, wie er ausgewählt wird.
class TabItem {
  const TabItem({
    required this.icon,
    required this.label,
    this.image,
  });

  final IconData icon;

  /// Der Name des Bereichs, gelesen in dem Moment, in dem er gezeigt wird.
  ///
  /// Vorher stand hier eine feste Zeichenkette. Die Liste der Bereiche wird
  /// einmal beim Start gebaut, die Sprache kann sich danach noch ändern —
  /// eine feste Zeichenkette hätte den Namen für den Rest des Laufs
  /// eingefroren, und zwar in der Sprache des Entwicklers.
  final String Function(AppLocalizations) label;

  /// Das Chamäleon dieses Bereichs, erkennbar an seinem Requisit.
  ///
  /// Die Figur bleibt über alle Bereiche gleich, nur was sie hält, wechselt —
  /// einmal gelernt, überall wiedererkannt. Das Icon bleibt als Rückfall
  /// stehen, damit ein Bereich ohne fertiges Bild nicht leer läuft.
  final String? image;
}
