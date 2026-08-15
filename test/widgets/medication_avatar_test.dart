// Das Tablettenfoto war gespeichert und nirgends zu sehen.
//
// Das Formular legte einen absoluten Pfad in der Datenbank ab, die Anzeige
// setzte ihn hinter den Anhang-Ordner — `attachments//data/…`. Gefunden wurde
// nie etwas, also stand überall das Namenskürzel. Genau dort, wo das Formular
// verspricht „Foto hilft bei der Identifikation und vermeidet Verwechslungen".
//
// Diese Tests halten beide Hälften der Reparatur fest.

import 'dart:io';

import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/widgets/medication_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kleinstes gültiges PNG (1×1, transparent).
final _einPixelPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

void main() {
  late Directory ordner;

  setUp(() {
    ordner = Directory.systemTemp.createTempSync('aurora_anhang_test');
    AttachmentHelper.setCacheForTest(ordner);
  });

  tearDown(() {
    AttachmentHelper.resetCacheForTest();
    if (ordner.existsSync()) ordner.deleteSync(recursive: true);
  });

  group('AttachmentHelper.fileSync', () {
    test('setzt einen relativen Namen hinter den Anhang-Ordner', () {
      final datei = AttachmentHelper.fileSync('image_abc.jpg');

      expect(datei, isNotNull);
      expect(datei!.path, contains(ordner.path));
      expect(datei.path, endsWith('image_abc.jpg'));
    });

    test('lässt einen absoluten Pfad unangetastet', () {
      // Der Fall der Altdaten: Das Formular hat vor der Reparatur absolute
      // Pfade gespeichert. Würden sie weiter zusammengesetzt, blieben die
      // Bilder für immer verschwunden.
      final vorhanden = File('${ordner.path}/alt_absolut.jpg')
        ..writeAsBytesSync(_einPixelPng);

      final datei = AttachmentHelper.fileSync(vorhanden.path);

      expect(datei, isNotNull);
      expect(datei!.path, vorhanden.path);
      expect(datei.existsSync(), isTrue);
    });
  });

  group('MedicationAvatar', () {
    testWidgets('zeigt das Foto, wenn die Datei im Anhang-Ordner liegt',
        (tester) async {
      File('${ordner.path}/image_pille.jpg').writeAsBytesSync(_einPixelPng);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MedicationAvatar(
              imagePath: 'image_pille.jpg',
              name: 'Quetiapin',
              width: 80,
              height: 40,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      // Das Kürzel darf daneben nicht stehen — sonst läge das Foto wieder
      // als Kreis in einer Pille, die zur Hälfte Buchstaben zeigt.
      expect(find.text('QUE'), findsNothing);
    });

    testWidgets('füllt die ganze Pille, nicht nur einen Kreis darin',
        (tester) async {
      File('${ordner.path}/image_pille.jpg').writeAsBytesSync(_einPixelPng);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MedicationAvatar(
              imagePath: 'image_pille.jpg',
              name: 'Quetiapin',
              width: 80,
              height: 40,
            ),
          ),
        ),
      );

      final bild = tester.widget<Image>(find.byType(Image));
      expect(bild.width, 80);
      expect(bild.height, 40);
      expect(bild.fit, BoxFit.cover);
    });

    testWidgets('fällt ohne Pfad auf das Kürzel zurück', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MedicationAvatar(
              imagePath: null,
              name: 'Quetiapin',
              width: 80,
              height: 40,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.text('QUE'), findsWidgets);
    });
  });
}
