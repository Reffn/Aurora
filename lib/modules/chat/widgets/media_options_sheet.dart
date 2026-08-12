import 'dart:io';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/permission_text.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/widgets/permission_guard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Die selteneren Wege: ein vorhandenes Bild, ein Video.
///
/// Kamera und Sprachaufnahme standen früher auch hier. Sie sind die beiden
/// Wege, auf die Anteile ohne Schriftsprache angewiesen sind, und liegen
/// deshalb jetzt offen als große Flächen über dem Verlauf statt hinter „+"
/// und einer Liste beschrifteter Zeilen.
class MediaOptionsSheet extends StatefulWidget {
  const MediaOptionsSheet({
    required this.profileColor,
    super.key,
    this.onSendImage,
    this.onSendVideo,
    this.enabled = true,
    this.canSendImage = true,
    this.canSendVideo = true,
  });

  final ValueChanged<File>? onSendImage;
  final ValueChanged<File>? onSendVideo;
  final bool enabled;
  final Color profileColor;

  final bool canSendImage;
  final bool canSendVideo;

  @override
  State<MediaOptionsSheet> createState() => _MediaOptionsSheetState();
}

class _MediaOptionsSheetState extends State<MediaOptionsSheet> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context);
    if (!widget.enabled || widget.onSendImage == null) return;

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        Navigator.pop(context);
        widget.onSendImage!(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showError(l10n.mediaImageNotOpened);
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    if (!widget.enabled || widget.onSendVideo == null) return;

    try {
      final video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null && mounted) {
        Navigator.pop(context);
        widget.onSendVideo!(File(video.path));
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
      _showError(l10n.mediaVideoNotOpened);
    }
  }

  void _showError(String message) {
    if (mounted) {
      showCustomSnackBar(
        context,
        message: message,
        type: SnackBarType.error,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      // Dunkel wie der übrige Chat. Als weiße Fläche blendete das Blatt beim
      // Aufziehen und stand als einziger heller Block im Bild.
      decoration: const BoxDecoration(
        color: Color(0xFF1C1B1F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.profileColor.withValues(alpha: 0.25),
                    const Color(0xFF1C1B1F),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.perm_media, color: widget.profileColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      // Neutral statt „Aus der Galerie": Darunter steht auch
                      // „neues Video aufnehmen", also die Kamera. Die alte
                      // Überschrift sagte etwas anderes als die Liste.
                      l10n.chatMediaSheetTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Ein sichtbarer Ausgang: Bisher schloss nur ein Tippen auf
                  // den Hintergrund, den assistive Dienste als „Gitter"
                  // ankündigen — als Ausweg ist das nicht zu erkennen.
                  IconButton(
                    tooltip: l10n.actionClose,
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Kein Rot und kein Grün: die beiden gehören laut app_colors allein
            // den Handlungsrückmeldungen. Farbe unterscheidet hier nur die
            // Einträge voneinander.
            // Der Grund steht VOR der Berührung im Untertitel — wer die
            // Sperre erst nach dem Tippen als Fehlermeldung erfährt, lernt
            // den Fehlerpfad statt des Weges (Errorless-Learning-Prinzip).
            _buildOption(
              icon: Icons.photo,
              iconColor: Colors.amberAccent,
              title: l10n.mediaPickImage,
              subtitle: widget.canSendImage
                  ? l10n.mediaFromGallery
                  : l10n.permissionYouNeed(Permission.sendImage.label(l10n)),
              enabled: widget.canSendImage,
              onTap: () {
                if (!widget.canSendImage) {
                  showNoPermissionSnackBar(context, Permission.sendImage);
                  return;
                }
                _pickImage();
              },
            ),

            _buildOption(
              icon: Icons.videocam,
              iconColor: Colors.purpleAccent,
              title: l10n.chatRecordVideo,
              subtitle: widget.canSendVideo
                  ? l10n.chatRecordVideoSubtitle
                  : l10n.permissionYouNeed(Permission.sendVideo.label(l10n)),
              enabled: widget.canSendVideo,
              onTap: () {
                if (!widget.canSendVideo) {
                  showNoPermissionSnackBar(context, Permission.sendVideo);
                  return;
                }
                _pickVideo(ImageSource.camera);
              },
            ),

            _buildOption(
              icon: Icons.video_library,
              iconColor: Colors.lightBlueAccent,
              title: l10n.mediaPickVideo,
              subtitle: widget.canSendVideo
                  ? l10n.mediaFromGallery
                  : l10n.permissionYouNeed(Permission.sendVideo.label(l10n)),
              enabled: widget.canSendVideo,
              onTap: () {
                if (!widget.canSendVideo) {
                  showNoPermissionSnackBar(context, Permission.sendVideo);
                  return;
                }
                _pickVideo(ImageSource.gallery);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: enabled ? iconColor : Colors.white24,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: enabled ? Colors.white : Colors.white38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: enabled ? Colors.white70 : Colors.white30,
          ),
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
