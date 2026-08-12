import 'dart:io';
import 'dart:typed_data';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/puzzle_config.dart';
import 'package:dis_app/services/puzzle_image_service.dart';
import 'package:flutter/material.dart';

/// Dialog zur Auswahl der Bildquelle für Puzzle
class PuzzleImagePickerDialog extends StatefulWidget {
  const PuzzleImagePickerDialog({super.key});

  /// Zeigt den Dialog an und gibt die Bildquelle zurück
  static Future<PuzzleImageResult?> show(BuildContext context) {
    return showDialog<PuzzleImageResult>(
      context: context,
      builder: (context) => const PuzzleImagePickerDialog(),
    );
  }

  @override
  State<PuzzleImagePickerDialog> createState() =>
      _PuzzleImagePickerDialogState();
}

class _PuzzleImagePickerDialogState extends State<PuzzleImagePickerDialog> {
  final PuzzleImageService _imageService = getIt<PuzzleImageService>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titel
            Row(
              children: [
                const Icon(Icons.image, size: 28),
                const SizedBox(width: 12),
                Text(
                  l10n.puzzleImagePickerTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.puzzleImagePickerSubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),

            // Fehler-Anzeige
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Lade-Anzeige
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.puzzleImageLoading),
                  ],
                ),
              )
            else
              // Auswahl-Optionen
              Column(
                children: [
                  _buildImageSourceOption(
                    context,
                    l10n,
                    icon: Icons.photo_library,
                    title: l10n.puzzleImageSourceGallery,
                    subtitle: l10n.puzzleImageSourceGallerySubtitle,
                    onTap: () => _pickFromGallery(context, l10n),
                  ),
                  const SizedBox(height: 12),
                  _buildImageSourceOption(
                    context,
                    l10n,
                    icon: Icons.camera_alt,
                    title: l10n.puzzleImageSourceCamera,
                    subtitle: l10n.puzzleImageSourceCameraSubtitle,
                    onTap: () => _takePhoto(context, l10n),
                  ),
                  const SizedBox(height: 12),
                  _buildImageSourceOption(
                    context,
                    l10n,
                    icon: Icons.cloud_download,
                    title: l10n.puzzleImageSourceOnline,
                    subtitle: l10n.puzzleImageSourceOnlineSubtitle,
                    onTap: () => _showOnlineCategoryPicker(context, l10n),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Abbrechen-Button
            if (!_isLoading)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.actionCancel),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context,
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final image = await _imageService.pickImageFromGallery();
      if (image != null && context.mounted) {
        Navigator.pop(
          context,
          PuzzleImageResult(
            file: image,
            source: PuzzleImageSource.gallery,
          ),
        );
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _takePhoto(BuildContext context, AppLocalizations l10n) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final image = await _imageService.takePhotoWithCamera();
      if (image != null && context.mounted) {
        Navigator.pop(
          context,
          PuzzleImageResult(
            file: image,
            source: PuzzleImageSource.camera,
          ),
        );
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _showOnlineCategoryPicker(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    // Zeige Kategorie-Auswahl
    final category = await showDialog<OnlineImageCategory>(
      context: context,
      builder: (context) => _OnlineCategoryPickerDialog(),
    );

    if (category == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final imageBytes = await _imageService.loadRandomOnlineImage(
        category: category.id,
      );

      if (imageBytes != null && context.mounted) {
        Navigator.pop(
          context,
          PuzzleImageResult(
            bytes: imageBytes,
            source: PuzzleImageSource.online,
            categoryName: category.name,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = l10n.puzzleImageLoadFailed;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }
}

/// Dialog zur Auswahl der Online-Bildkategorie
class _OnlineCategoryPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = PuzzleImageService.availableCategories;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.puzzleSelectCategory,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(category.name),
                  subtitle: Text(category.description),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  onTap: () => Navigator.pop(context, category),
                ),
              );
            }),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ergebnis der Bildauswahl
class PuzzleImageResult {
  PuzzleImageResult({
    required this.source,
    this.file,
    this.bytes,
    this.categoryName,
  }) : assert(
         file != null || bytes != null,
         'Either file or bytes must be provided',
       );

  final File? file; // Für Galerie/Kamera
  final Uint8List? bytes; // Für Online
  final PuzzleImageSource source;
  final String? categoryName; // Für Online-Kategorien
}
