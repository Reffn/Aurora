import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Helper für Attachment-Verwaltung (Doodles, Sprachnachrichten, etc.)
/// Nutzt relative Pfade für robuste Session-übergreifende Persistierung
class AttachmentHelper {
  static const String _attachmentsSubdir = 'attachments';

  /// Der einmal aufgelöste Ordner.
  ///
  /// Er ändert sich zur Laufzeit nicht: `getApplicationDocumentsDirectory()`
  /// gibt für denselben Prozess immer dasselbe zurück, und der Unterordner
  /// wird beim ersten Mal angelegt. Ihn jedes Mal neu zu erfragen kostete
  /// einen Plattform-Kanal-Umlauf **und** eine Dateisystem-Abfrage — bei
  /// einem Widget, das im `build` danach fragt, also einmal pro Neuaufbau
  /// und Avatar.
  static Directory? _cached;

  /// Derselbe Wert als Listenable.
  ///
  /// `runApp()` startet die Oberfläche, bevor `warmUp()` durch ist (siehe
  /// `main.dart`: runApp sofort, Abhängigkeiten parallel). Ein Widget, das
  /// den Pfad braucht, kann also im ersten Moment keinen bekommen — und
  /// bräuchte ohne diesen Weg einen `FutureBuilder`, der bei jedem
  /// Neuaufbau von vorn anfängt. Wer hier zuhört, bekommt genau einen
  /// Neuaufbau: den, bei dem der Ordner ankommt.
  static final ValueNotifier<Directory?> _notifier = ValueNotifier<Directory?>(
    null,
  );

  /// Der Ordner, sobald er da ist. Vorher null.
  static ValueListenable<Directory?> get directory => _notifier;

  /// Gibt das Attachments-Verzeichnis zurück, einmal pro Prozess aufgelöst.
  static Future<Directory> getAttachmentsDirectory() async {
    final vorhanden = _cached;
    if (vorhanden != null) return vorhanden;

    final appDocDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${appDocDir.path}/$_attachmentsSubdir');

    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    _cached = attachmentsDir;
    _notifier.value = attachmentsDir;
    return attachmentsDir;
  }

  /// Löst den Ordner im Voraus auf.
  ///
  /// Gehört an den Start, damit die Oberfläche danach [fileSync] benutzen
  /// kann und kein Widget mehr im `build` auf Ein-/Ausgabe warten muss.
  static Future<void> warmUp() => getAttachmentsDirectory();

  /// Der Pfad ohne Warten — oder null, solange der Ordner unbekannt ist.
  ///
  /// `Image.file` braucht nur einen Pfad. Wer diesen hier bekommt, spart
  /// sich einen `FutureBuilder`, der bei jedem Neuaufbau von vorn anfängt
  /// und dabei kurz auf „keine Daten" zurückfällt — daher das Flackern der
  /// Avatare.
  static File? fileSync(String filename) {
    // Ein absoluter Pfad ist schon fertig. Er sollte nicht in der Datenbank
    // stehen — das Medikamenten-Formular hat ihn trotzdem dort abgelegt, und
    // das Zusammensetzen machte daraus `attachments//data/…`, also nichts.
    // Das Tablettenfoto wurde deshalb gespeichert und nie gezeigt. Neu
    // gespeichert wird relativ; diese Zeile holt die alten Bilder zurück.
    if (_istAbsolut(filename)) return File(filename);

    final dir = _cached;
    return dir == null ? null : File('${dir.path}/$filename');
  }

  /// Erkennt Pfade, die nicht mehr zusammengesetzt werden dürfen.
  ///
  /// Android und iOS liefern `/data/…` beziehungsweise `/var/…`; Windows
  /// schreibt `C:\…`. Der Test deckt beide Schreibweisen ab, weil derselbe
  /// Code in den Widget-Tests auf dem Rechner läuft.
  static bool _istAbsolut(String pfad) =>
      pfad.startsWith('/') ||
      pfad.startsWith(r'\\') ||
      RegExp(r'^[A-Za-z]:[\\/]').hasMatch(pfad);

  /// Löscht alle Anhänge und legt den Ordner sofort wieder an.
  ///
  /// Das Wiederanlegen ist der Punkt. Der Ordner wurde vorher aus den
  /// Einstellungen heraus einfach entfernt — [_cached] zeigte danach auf ein
  /// Verzeichnis, das es nicht mehr gab, und jeder folgende Speichervorgang
  /// schrieb in einen Elternordner ohne Kind. Wer nach dem Löschen ein neues
  /// Profilbild wählte, verlor es still.
  static Future<void> clearAll() async {
    // Der aufgelöste Ordner gilt; nur wenn noch keiner da ist, wird die
    // Plattform gefragt.
    final attachmentsDir =
        _cached ??
        Directory(
          '${(await getApplicationDocumentsDirectory()).path}'
          '/$_attachmentsSubdir',
        );

    if (await attachmentsDir.exists()) {
      await attachmentsDir.delete(recursive: true);
    }
    await attachmentsDir.create(recursive: true);

    _cached = attachmentsDir;
    _notifier.value = attachmentsDir;
  }

  /// Nur für Tests: den Zwischenspeicher leeren.
  @visibleForTesting
  static void resetCacheForTest() {
    _cached = null;
    _notifier.value = null;
  }

  /// Nur für Tests: den Ordner setzen, ohne die Plattform zu fragen.
  @visibleForTesting
  static void setCacheForTest(Directory dir) {
    _cached = dir;
    _notifier.value = dir;
  }

  /// Ist der Ordner schon aufgelöst?
  static bool get isWarm => _cached != null;

  /// Konstruiert den vollständigen Pfad zu einem Attachment
  /// @param filename Relativer Filename (z.B. "doodle_abc123.png")
  /// @return File-Objekt mit vollständigem Pfad
  static Future<File> getAttachmentFile(String filename) async {
    final dir = await getAttachmentsDirectory();
    return File('${dir.path}/$filename');
  }

  /// Speichert ein Doodle als PNG-Datei
  /// @param imageBytes PNG-Bytes vom SignatureController
  /// @return Relativer Filename (z.B. "doodle_abc123.png")
  static Future<String> saveDoodle(Uint8List imageBytes) async {
    final filename = 'doodle_${const Uuid().v4()}.png';
    final file = await getAttachmentFile(filename);
    await file.writeAsBytes(imageBytes);
    return filename;
  }

  /// Speichert eine Sprachnachricht als Audio-Datei
  /// @param audioBytes Audio-Bytes (z.B. M4A, MP3)
  /// @param extension Dateiendung (default: m4a)
  /// @return Relativer Filename (z.B. "voice_xyz789.m4a")
  static Future<String> saveVoice(
    Uint8List audioBytes, {
    String extension = 'm4a',
  }) async {
    final filename = 'voice_${const Uuid().v4()}.$extension';
    final file = await getAttachmentFile(filename);
    await file.writeAsBytes(audioBytes);
    return filename;
  }

  /// Speichert ein Bild (JPEG)
  /// @param imageBytes Bild-Bytes als JPEG
  /// @return Relativer Filename (z.B. "image_abc123.jpg")
  static Future<String> saveImage(Uint8List imageBytes) async {
    final filename = 'image_${const Uuid().v4()}.jpg';
    final file = await getAttachmentFile(filename);
    await file.writeAsBytes(imageBytes);
    return filename;
  }

  /// Speichert ein Video
  /// @param videoFile Video-File von ImagePicker
  /// @return Relativer Filename (z.B. "video_xyz789.mp4")
  static Future<String> saveVideo(File videoFile) async {
    final extension = videoFile.path.split('.').last;
    final filename = 'video_${const Uuid().v4()}.$extension';
    final file = await getAttachmentFile(filename);
    await file.writeAsBytes(await videoFile.readAsBytes());
    return filename;
  }

  /// Speichert ein Profilbild (Avatar)
  /// @param imageFile Bild-File von ImagePicker
  /// @return Relativer Filename (z.B. "avatar_abc123.jpg")
  static Future<String> saveProfileAvatar(File imageFile) async {
    try {
      // Validiere dass das Source-File existiert
      if (!await imageFile.exists()) {
        throw Exception('Source image file does not exist: ${imageFile.path}');
      }

      // Lese Bytes vom Source-File
      final bytes = await imageFile.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('Source image file is empty: ${imageFile.path}');
      }

      // Erstelle Ziel-File
      final filename = 'avatar_${const Uuid().v4()}.jpg';
      final file = await getAttachmentFile(filename);

      // Schreibe Bytes
      await file.writeAsBytes(bytes);

      // Validiere dass das Ziel-File erstellt wurde
      if (!await file.exists()) {
        throw Exception('Failed to create avatar file: ${file.path}');
      }

      return filename;
    } catch (e) {
      // Detaillierte Fehlermeldung für Debugging
      throw Exception('Failed to save profile avatar: $e');
    }
  }

  /// Löscht ein Attachment vom Filesystem
  /// Nützlich für Cleanup bei gelöschten Nachrichten
  static Future<void> deleteAttachment(String filename) async {
    try {
      final file = await getAttachmentFile(filename);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignorieren - File existiert möglicherweise nicht mehr
    }
  }

  /// Prüft ob ein Attachment existiert
  static Future<bool> attachmentExists(String filename) async {
    final file = await getAttachmentFile(filename);
    return file.exists();
  }

  /// Cleanup: Löscht verwaiste Attachments (ohne zugehörige Message)
  /// @param validFilenames Liste aller Filenames die noch in Nachrichten referenziert sind
  static Future<int> cleanupOrphanedAttachments(
    List<String> validFilenames,
  ) async {
    var deletedCount = 0;
    final dir = await getAttachmentsDirectory();

    await for (final entity in dir.list()) {
      if (entity is File) {
        final filename = entity.path.split(Platform.pathSeparator).last;

        if (!validFilenames.contains(filename)) {
          try {
            await entity.delete();
            deletedCount++;
          } catch (e) {
            // Ignorieren
          }
        }
      }
    }

    return deletedCount;
  }
}
