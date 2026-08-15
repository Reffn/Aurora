import 'dart:io';

import 'package:dis_app/utils/attachment_helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Anhang-Ordner wird einmal pro Prozess aufgelöst.
///
/// Vorher fragte jeder Aufruf die Plattform (`getApplicationDocumentsDirectory`)
/// und das Dateisystem (`exists`). Weil `ProfileImageWidget` und
/// `ProfileSwitchAvatar` das im `build` taten — und die hängen in Kopfzeile
/// und Profilleiste, also auf jedem Bildschirm — kostete jeder Tap, der
/// irgendwo einen Neuaufbau auslöste, einen Umlauf je sichtbarem Avatar.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('aurora_anhang');
    AttachmentHelper.resetCacheForTest();
  });

  tearDown(() {
    AttachmentHelper.resetCacheForTest();
    tempDir.deleteSync(recursive: true);
  });

  test('Ohne aufgeloesten Ordner gibt fileSync nichts zurueck', () {
    expect(AttachmentHelper.isWarm, isFalse);
    expect(AttachmentHelper.fileSync('avatar_1.jpg'), isNull);
  });

  test('Nach dem Aufloesen kommt der Pfad ohne Warten', () {
    AttachmentHelper.setCacheForTest(tempDir);

    expect(AttachmentHelper.isWarm, isTrue);
    final datei = AttachmentHelper.fileSync('avatar_1.jpg');
    expect(datei, isNotNull);
    expect(datei!.path, '${tempDir.path}/avatar_1.jpg');
  });

  test('Der zweite Aufruf fragt die Plattform nicht erneut', () async {
    AttachmentHelper.setCacheForTest(tempDir);

    // Ohne Zwischenspeicher wuerde das hier die Plattform rufen und in der
    // Testumgebung mit MissingPluginException scheitern. Dass es durchläuft,
    // ist der Beweis, dass der zwischengespeicherte Ordner genommen wird.
    final erst = await AttachmentHelper.getAttachmentsDirectory();
    final dann = await AttachmentHelper.getAttachmentsDirectory();

    expect(erst.path, tempDir.path);
    expect(dann.path, tempDir.path);
  });

  test('getAttachmentFile und fileSync liefern denselben Pfad', () async {
    AttachmentHelper.setCacheForTest(tempDir);

    final asynchron = await AttachmentHelper.getAttachmentFile('doodle.png');
    final synchron = AttachmentHelper.fileSync('doodle.png');

    expect(synchron, isNotNull);
    expect(synchron!.path, asynchron.path);
  });
}
