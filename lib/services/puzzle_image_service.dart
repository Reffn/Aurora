import 'dart:io';
import 'dart:typed_data';

import 'package:dis_app/l10n/app_texts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service für Puzzle-Bildverwaltung
/// Lädt Bilder aus Galerie, Kamera oder Online-Quellen
class PuzzleImageService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Bild aus Galerie auswählen
  ///
  /// Ohne Berechtigungsabfrage auf Android: `image_picker` öffnet dort den
  /// System-Photo-Picker, der das gewählte Bild übergibt und sonst nichts
  /// preisgibt. Die frühere Abfrage von `Permission.photos` verlangte auf
  /// Android 13+ `READ_MEDIA_IMAGES` — Zugriff auf sämtliche Bilder des
  /// Geräts — und hat am 7. August 2026 das Update 3.0.15 gekostet.
  Future<File?> pickImageFromGallery() async {
    if (!Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        throw Exception('Zugriff auf Galerie wurde verweigert');
      }
    }

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw Exception('Fehler beim Laden des Bildes aus der Galerie: $e');
    }
  }

  /// Bild mit Kamera aufnehmen
  Future<File?> takePhotoWithCamera() async {
    // Permissions prüfen
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception('Zugriff auf Kamera wurde verweigert');
    }

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw Exception('Fehler beim Aufnehmen eines Fotos: $e');
    }
  }

  /// Zufälliges beruhigendes Bild von Unsplash laden
  /// Kategorien: nature, animals, landscape, ocean, forest
  Future<Uint8List?> loadRandomOnlineImage({
    String category = 'nature',
  }) async {
    try {
      // Unsplash Random API
      // Für Production sollte hier ein echter API Key verwendet werden
      final url = Uri.parse(
        'https://source.unsplash.com/random/800x800/?$category,calm,peaceful',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
          'Fehler beim Laden des Online-Bildes: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fehler beim Laden des Online-Bildes: $e');
    }
  }

  /// Liste verfügbarer Online-Kategorien für beruhigende Bilder
  static List<OnlineImageCategory> get availableCategories => [
    const OnlineImageCategory(
      id: 'nature',
      name: 'Natur',
      description: 'Beruhigende Naturszenen',
    ),
    OnlineImageCategory(
      id: 'animals',
      name: 'Tiere',
      description: AppTexts.current.puzzleCategoryAnimals,
    ),
    OnlineImageCategory(
      id: 'ocean',
      name: 'Ozean',
      description: AppTexts.current.puzzleCategoryWater,
    ),
    const OnlineImageCategory(
      id: 'forest',
      name: 'Wald',
      description: 'Waldlandschaften',
    ),
    const OnlineImageCategory(
      id: 'landscape',
      name: 'Landschaft',
      description: 'Weite Landschaften',
    ),
    OnlineImageCategory(
      id: 'flowers',
      name: 'Blumen',
      description: AppTexts.current.puzzleCategoryFlowers,
    ),
  ];

  // Hier standen vier Hilfsmethoden für Berechtigungen — hasGalleryPermission,
  // hasCameraPermission, requestGalleryPermission, requestCameraPermission.
  // Keine wurde je aufgerufen; die beiden Galerie-Fassungen fragten dabei
  // genau die Berechtigung ab, die das Update gekostet hat. Wer Kamera oder
  // Galerie öffnet, tut das über pickImageFromGallery bzw.
  // takePhotoWithCamera, und die kümmern sich selbst darum.
}

/// Online-Bild-Kategorie
class OnlineImageCategory {
  const OnlineImageCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}
