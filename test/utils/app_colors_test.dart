import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Aurora soll ohne Lesen bedienbar sein, also trägt Farbe Bedeutung mit.
/// Das funktioniert nur, solange ein Farbton nicht gleichzeitig eine Handlung
/// und einen Anteil bezeichnet. Diese Tests halten die Trennung fest.
void main() {
  group('Farbräume', () {
    test('kein Vorschlag für Anteile kollidiert mit einer Handlungsfarbe', () {
      for (final color in AppColors.identityPalette) {
        expect(
          AppColors.isReservedForAction(color),
          isFalse,
          reason:
              'Identitätsfarbe ${_hex(color)} liegt zu nah an go, wait oder signal',
        );
      }
    });

    test('die drei Handlungsfarben sind für Anteile gesperrt', () {
      for (final color in <Color>[
        AppColors.go,
        AppColors.wait,
        AppColors.signal,
      ]) {
        expect(AppColors.isReservedForAction(color), isTrue);
      }
    });

    test('auf jeder Identitätsfarbe bleibt der Vordergrund lesbar', () {
      // Fest weißer Vordergrund auf der Profilfarbe hat Inhalte verschwinden
      // lassen: die Initiale im Chat-Avatar und das Senden-Symbol im
      // Doodle-Feld waren bei hellen Profilen nicht mehr zu sehen.
      const minimumContrast = 4.5; // WCAG 2.2 für Text

      for (final background in [
        ...AppColors.identityPalette,
        Colors.white,
        Colors.black,
        const Color(0xFF777777),
      ]) {
        final foreground = AppColors.onColor(background);
        final lighter =
            background.computeLuminance() > foreground.computeLuminance()
            ? background
            : foreground;
        final darker = lighter == background ? foreground : background;
        final ratio =
            (lighter.computeLuminance() + 0.05) /
            (darker.computeLuminance() + 0.05);

        expect(
          ratio,
          greaterThanOrEqualTo(minimumContrast),
          reason:
              'Auf ${_hex(background)} erreicht der Vordergrund nur '
              '${ratio.toStringAsFixed(1)}:1',
        );
      }
    });

    test('gesättigte Töne der Handlungsfarben sind gesperrt', () {
      // Ein sattes Grün, das nicht exakt AppColors.go ist.
      expect(AppColors.isReservedForAction(const Color(0xFF2ECC71)), isTrue);
      // Ein sattes Rot.
      expect(AppColors.isReservedForAction(const Color(0xFFE74C3C)), isTrue);
    });

    test('blasse Töne bleiben wählbar, auch mit farbigem Stich', () {
      // Ein Grau mit leichtem Grünstich trägt keine Handlungsbedeutung.
      expect(AppColors.isReservedForAction(const Color(0xFF8E9A92)), isFalse);
    });

    test('Blau und Violett bleiben vollständig verfügbar', () {
      expect(AppColors.isReservedForAction(const Color(0xFF87CEEB)), isFalse);
      expect(AppColors.isReservedForAction(const Color(0xFF9B8AE0)), isFalse);
    });

    test('die Vorschlagspalette bietet genug Auswahl für ein System', () {
      expect(AppColors.identityPalette.length, greaterThanOrEqualTo(8));
      expect(
        AppColors.identityPalette.toSet().length,
        AppColors.identityPalette.length,
        reason: 'Doppelte Farben in der Palette',
      );
    });
  });
}

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
