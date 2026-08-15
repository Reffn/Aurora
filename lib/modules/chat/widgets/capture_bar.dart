import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/widgets/permission_guard.dart';
import 'package:flutter/material.dart';

/// Kamera und Mikrofon, ganz oben im Chat und immer sichtbar.
///
/// Für Anteile, die nicht schreiben, sind Bild und Stimme die beiden Wege nach
/// draußen. Beide lagen bisher hinter „+" in einem Blatt mit fünf beschrifteten
/// Zeilen — ein Weg, der Lesen voraussetzt und damit genau die ausschließt, für
/// die er gedacht war.
///
/// Die Leiste bleibt stehen, auch während getippt wird: was verschwindet und
/// wiederkommt, muss jedes Mal neu gefunden werden.
class CaptureBar extends StatelessWidget {
  const CaptureBar({
    required this.profileColor,
    super.key,
    this.onCamera,
    this.onVoice,
    this.canSendImage = false,
    this.canSendVoice = false,
  });

  final Color profileColor;
  final VoidCallback? onCamera;
  final VoidCallback? onVoice;
  final bool canSendImage;
  final bool canSendVoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: _CaptureTile(
              icon: Icons.photo_camera,
              label: AppLocalizations.of(context).chatCaptureImageShort,
              profileColor: profileColor,
              allowed: canSendImage,
              deniedPermission: Permission.sendImage,
              onTap: onCamera,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CaptureTile(
              icon: Icons.mic,
              label: AppLocalizations.of(context).permSendVoiceMessageLabel,
              profileColor: profileColor,
              allowed: canSendVoice,
              deniedPermission: Permission.sendVoiceMessage,
              onTap: onVoice,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureTile extends StatelessWidget {
  const _CaptureTile({
    required this.icon,
    required this.label,
    required this.profileColor,
    required this.allowed,
    required this.deniedPermission,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color profileColor;
  final bool allowed;
  final Permission deniedPermission;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: allowed ? 1.0 : 0.35,
      child: Material(
        color: const Color(0xFF2A2A2E),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (!allowed) {
              showNoPermissionSnackBar(context, deniedPermission);
              return;
            }
            onTap?.call();
          },
          child: Container(
            // 64 px hoch: ein Ziel, das auch mit ungenauer Motorik und ohne
            // Zielen getroffen wird.
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                // Die Profilfarbe nur als Rahmen: Farbe steht in Aurora für
                // „wer bin ich gerade", nicht für „was tut dieser Knopf".
                color: profileColor.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: Colors.white),
                const SizedBox(width: 10),
                // Das Wort bestätigt nur, was das Symbol schon sagt.
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
