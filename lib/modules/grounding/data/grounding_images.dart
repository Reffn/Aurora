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
