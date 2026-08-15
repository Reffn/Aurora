import 'dart:typed_data';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/chat/widgets/doodle_canvas.dart';
import 'package:flutter/material.dart';

/// Ein Profilbild selbst malen.
///
/// Dieselbe Fläche wie im Chat, nur ohne das, was dort den Chat meint: keine
/// Sticker, kein Umschalter zum Nachrichtenverlauf, und der Knopf sendet
/// nicht, sondern übernimmt.
///
/// Warum überhaupt gemalt statt fotografiert: Gezeichnete Darstellungen
/// werden zuverlässiger erkannt als Fotos (Medhi u. a.), und in einem Körper,
/// den mehrere teilen, zeigt jedes Foto denselben Menschen. Ein gemaltes Bild
/// zeigt, wer man ist, nicht wie der Körper aussieht.
class DoodleAvatarScreen extends StatelessWidget {
  const DoodleAvatarScreen({required this.profileColor, super.key});

  /// Färbt den Übernehmen-Knopf und die Radierer-Markierung.
  final Color profileColor;

  /// Öffnet die Fläche und gibt das gemalte Bild als PNG zurück.
  ///
  /// `null`, wenn zurückgegangen wurde, ohne zu übernehmen.
  static Future<Uint8List?> show(
    BuildContext context, {
    required Color profileColor,
  }) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        builder: (_) => DoodleAvatarScreen(profileColor: profileColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // Die Zeichenfläche selbst hat keinen Grund — im Chat scheint der
      // Verlauf durch. Hier steht nichts dahinter, also trägt der Schirm ihn.
      backgroundColor: const Color(0xFF14131A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1B1F),
        foregroundColor: Colors.white,
        title: Text(l10n.doodleAvatarTitle),
      ),
      body: DoodleCanvas(
        profileColor: profileColor,
        // Es liegt nichts darunter, das man erreichen wollen könnte.
        drawingEnabled: true,
        onToggleDrawing: () {},
        showStickers: false,
        showModeToggle: false,
        confirmIcon: Icons.check,
        confirmTooltip: l10n.doodleAvatarDone,
        confirmEmptyTooltip: l10n.doodleAvatarEmptyHint,
        onSend: (imageBytes) => Navigator.of(context).pop(imageBytes),
      ),
    );
  }
}
