import 'dart:io';

import 'package:dis_app/models/chat_message.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/chat/widgets/attachment_viewer.dart';
import 'package:dis_app/modules/chat/widgets/video_message_player.dart';
import 'package:dis_app/modules/chat/widgets/voice_message_player.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Chat-Nachricht als Bubble anzeigen
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.profile,
    super.key,
    this.isCurrentUser = false,
    this.onLongPress,
  });
  final ChatMessage message;
  final Profile? profile;
  final bool isCurrentUser;
  final VoidCallback? onLongPress;

  /// Normalisiert UTF-16 String um Rendering-Crashes zu vermeiden
  /// Verwendet Dart's runes API - erhält Emojis und gültige Unicode-Zeichen
  static String _sanitizeText(String text) {
    // Dart's runes API normalisiert automatisch und entfernt nur wirklich ungültige Zeichen
    // Emojis wie 😅 werden korrekt erhalten
    return String.fromCharCodes(text.runes);
  }

  @override
  Widget build(BuildContext context) {
    final alignment = isCurrentUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    // Die aktuelle Farbe des Profils, nicht die beim Senden gespeicherte.
    // Sonst trägt dasselbe Profil im Verlauf so viele Farben, wie es je
    // hatte — und die Farbe taugt nicht mehr zum Auseinanderhalten.
    // message.senderColor bleibt der Rückfall für gelöschte Profile.
    final color = profile?.preferredColor ?? message.senderColor;
    final timeFormat = DateFormat('HH:mm');

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar links (wenn nicht current user)
              if (!isCurrentUser) ...[
                _buildAvatar(color),
                const SizedBox(width: 8),
              ],

              // Nachricht-Bubble
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: color,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      if (profile != null)
                        Text(
                          _sanitizeText(profile!.name),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 4),

                      // Nachrichteninhalt (Switch basierend auf MessageType)
                      _buildMessageContent(context),

                      const SizedBox(height: 4),

                      // Zeitstempel
                      Text(
                        timeFormat.format(message.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Avatar rechts (wenn current user)
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                _buildAvatar(color),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ProfileImageWidget(
          avatarPath: profile?.avatarPath,
          size: 36,
          // Sichtbare Aenderung: die Blase malte ihre Initialen bisher selbst,
          // mit `AppColors.onColor(color)` — als einzige der sieben eigenen
          // Rueckfaelle rechnete sie den Kontrast wirklich aus. Jetzt tragen
          // sie dieselbe Kontur wie ueberall sonst. Eine Ausnahme fuer die
          // eine richtige Stelle waere die Hintertuer unter neuem Namen.
          profileName: profile?.name ?? '?',
          profileColor: color,
        ),
      ),
    );
  }

  /// Der Text der Nachricht. Zugleich der Rückfall für jeden Anhang, der
  /// fehlt oder sich nicht laden lässt.
  Widget _buildText() {
    return Text(
      _sanitizeText(message.content),
      style: const TextStyle(fontSize: 17, color: Colors.white),
    );
  }

  /// Baut den Message-Content basierend auf MessageType
  Widget _buildMessageContent(BuildContext context) {
    final filename = message.attachmentFilename;

    // Jeder Anhangstyp fällt ohne Datei auf den Text zurück — einmal geprüft
    // statt in jedem Zweig noch einmal.
    if (message.messageType != MessageType.text && filename == null) {
      return _buildText();
    }

    switch (message.messageType) {
      case MessageType.text:
        return _buildText();

      case MessageType.doodle:
      case MessageType.image:
        return _buildImageAttachment(context, filename!);

      case MessageType.voice:
        return VoiceMessagePlayer(
          audioFilename: filename!,
          color: profile?.preferredColor ?? message.senderColor,
        );

      case MessageType.video:
        return VideoMessagePlayer(videoFilename: filename!);
    }
  }

  /// Bild oder Doodle in der Bubble, antippbar für die große Ansicht.
  ///
  /// Doodle und Foto liefen vorher durch zwei fast gleiche Zweige, die sich
  /// nur im `fit` unterschieden — das Foto stand auf `cover` und wurde ohne
  /// Höhengrenze beschnitten. Beide zeigen jetzt das ganze Bild und deckeln
  /// die Höhe, damit eine hochkant fotografierte Aufnahme nicht den halben
  /// Verlauf einnimmt.
  Widget _buildImageAttachment(BuildContext context, String filename) {
    // Kein Future im build: der Ordner kommt als Listenable, weil runApp()
    // startet, bevor das Aufwaermen durch ist. Vorher baute jede Blase beim
    // Scrollen den Ordner neu auf und zeigte kurz einen Ladekreis, obwohl
    // das Bild laengst da war.
    return ValueListenableBuilder<Directory?>(
      valueListenable: AttachmentHelper.directory,
      builder: (context, _, __) {
        final datei = AttachmentHelper.fileSync(filename);
        if (datei == null) {
          return const SizedBox(
            width: 40,
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return _buildImageFrom(context, datei);
      },
    );
  }

  /// Das Bild selbst, unabhängig davon, woher die Datei kam.
  Widget _buildImageFrom(BuildContext context, File file) => GestureDetector(
    onTap: () => AttachmentViewer.show(context, file),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildText(),
        ),
      ),
    ),
  );
}
