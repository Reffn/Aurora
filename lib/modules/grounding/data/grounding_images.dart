import 'package:flutter/material.dart';

/// Was ein Schritt zeigt: ein gezeichnetes Bild oder, solange es fehlt, ein
/// Symbol.
sealed class GroundingBild {
  const GroundingBild();
}

/// Ein gebündeltes Bild.
final class GroundingBildAsset extends GroundingBild {
  const GroundingBildAsset(this.path);

  final String path;
}

/// Ein vertrautes Material-Symbol, bis das gezeichnete Bild da ist.
final class GroundingBildSymbol extends GroundingBild {
  const GroundingBildSymbol(this.icon);

  final IconData icon;
}

/// Auflösung von Bildschlüsseln auf Bilder
///
/// Die einzige Stelle im Modul, die Pfade und Symbole kennt. Ein Wechsel des
/// Bildersatzes ändert genau diese Maps — keine Übung, kein Widget, kein
/// Test.
///
/// Bewusst getrennt von `AttachmentHelper` und `ProfileImageWidget`: die lösen
/// nutzergenerierte Dateien im Dokumentenverzeichnis auf. Grounding-Bilder sind
/// ausschließlich gebündelte Assets.
///
/// **Bis 3.0.24 war `_paths` leer**, und alle 28 Schritte zeigten dasselbe
/// Übungssymbol: Das Bild sollte die Anweisung tragen (Regel 5) und trug
/// nichts. Bis gezeichnete Bilder kommen, hat jeder Schlüssel ein eigenes,
/// vertrautes Material-Symbol — nicht neu erfunden, sondern das, was man
/// kennt. Kommt ein Pfad in `_paths`, geht er dem Symbol vor.
abstract final class GroundingImages {
  static const Map<String, String> _paths = <String, String>{};

  static const Map<String, IconData> _symbols = <String, IconData>{
    // Orientierung
    'calendar_today': Icons.calendar_today,
    'look_around': Icons.visibility,
    'name_tag': Icons.badge,
    'grown_body': Icons.person,
    'past_behind': Icons.history,
    'you_are_here': Icons.place,
    // Sinne
    'sense_eye': Icons.visibility,
    'sense_ear': Icons.hearing,
    'sense_touch': Icons.back_hand,
    'sense_nose': Icons.local_florist,
    'sense_mouth': Icons.restaurant,
    // Körper
    'feet_ground': Icons.airline_seat_legroom_normal,
    'press_down': Icons.vertical_align_bottom,
    'hand_ice': Icons.ac_unit,
    'hold_tight': Icons.front_hand,
    'back_chair': Icons.chair,
    'ground_holds': Icons.landscape,
    // Behälter
    'container_empty': Icons.inventory_2_outlined,
    'container_lid': Icons.lock_open,
    'container_fill': Icons.move_to_inbox,
    'container_closed': Icons.lock,
    'container_shelf': Icons.shelves,
    'container_key': Icons.key,
    // Atem
    'breath_in': Icons.arrow_upward,
    'breath_hold': Icons.pause,
    'breath_out': Icons.arrow_downward,
  };

  /// Assetpfad zu einem Schlüssel, oder null, wenn kein Bild hinterlegt ist
  static String? resolve(String imageKey) => _paths[imageKey];

  /// Was der Schritt zeigt: Bild vor Symbol, `null` nur bei unbekanntem
  /// Schlüssel.
  static GroundingBild? bildFuer(String imageKey) {
    final path = _paths[imageKey];
    if (path != null) return GroundingBildAsset(path);
    final icon = _symbols[imageKey];
    if (icon != null) return GroundingBildSymbol(icon);
    return null;
  }

  /// Alle Schlüssel, für die ein Bild hinterlegt ist
  static Set<String> get knownKeys => _paths.keys.toSet();

  /// Ob überhaupt ein Bildersatz hinterlegt ist
  static bool get hasAssets => _paths.isNotEmpty;
}
