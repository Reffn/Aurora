import 'dart:io';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/chat/widgets/media_options_sheet.dart';
import 'package:dis_app/widgets/permission_guard.dart';
import 'package:flutter/material.dart';

/// Die Textzeile am unteren Rand.
///
/// Sie ist bewusst schmal geworden. Bild und Stimme liegen jetzt als große
/// Flächen oben, Malen auf der Fläche darüber — hier bleibt der Weg für
/// Anteile, die schreiben. Was früher alles in dieser einen Zeile hing
/// (Aufnahme, Kamera, Zeichenmodus), lag hinter Symbolen von 18 bis 20 px.
class ChatInputField extends StatefulWidget {
  const ChatInputField({
    required this.onSendMessage,
    required this.profileColor,
    super.key,
    this.onSendImage,
    this.onSendVideo,
    this.enabled = true,
    this.canSendText = true,
    this.canSendImage = true,
    this.canSendVideo = true,
  });

  final ValueChanged<String> onSendMessage;
  final ValueChanged<File>? onSendImage;
  final ValueChanged<File>? onSendVideo;
  final bool enabled;
  final Color profileColor;

  final bool canSendText;
  final bool canSendImage;
  final bool canSendVideo;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _sendMessage() {
    if (!widget.enabled || !widget.canSendText) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(text);
    _controller.clear();
  }

  void _showMediaOptions() {
    if (!widget.enabled) return;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MediaOptionsSheet(
        enabled: widget.enabled,
        profileColor: widget.profileColor,
        onSendImage: widget.onSendImage,
        onSendVideo: widget.onSendVideo,
        canSendImage: widget.canSendImage,
        canSendVideo: widget.canSendVideo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(
          // Dieselbe Fläche wie die Nachrichten-Bubbles. Vorher war sie weiß,
          // während der Text darin auf Weiß gesetzt war — getippte Zeichen
          // waren dadurch unsichtbar, nur der graue Platzhalter stand da.
          color: const Color(0xFF2A2A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: widget.profileColor, width: 2),
        ),
        child: Row(
          children: [
            // Galerie und Video — die selteneren Wege bleiben hinter dem Plus.
            Material(
              color: Colors.transparent,
              child: Semantics(
                // Ohne Namen war das hier ein klickbarer Knoten ohne
                // Beschriftung — wer ihn nicht sieht, muss ihn antippen, um
                // zu erfahren, was er tut.
                label: AppLocalizations.of(context).chatAddMedia,
                button: true,
                child: InkWell(
                  onTap: _showMediaOptions,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add_circle,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Opacity(
                opacity: widget.canSendText ? 1.0 : 0.4,
                // Ein bleibender Feldname: Der Platzhalter „Nachricht
                // schreiben…" verschwindet, sobald jemand tippt, und damit
                // auch die einzige Auskunft darüber, worin man gerade
                // schreibt.
                child: Semantics(
                  label: AppLocalizations.of(context).chatMessageFieldLabel,
                  textField: true,
                  child: TextField(
                    controller: _controller,
                    enabled: widget.enabled && widget.canSendText,
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: widget.canSendText
                          ? AppLocalizations.of(context).chatInputHint
                          : AppLocalizations.of(context).chatNoPermissionHint,
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    onTap: !widget.canSendText
                        ? () => showNoPermissionSnackBar(
                            context,
                            Permission.sendTextMessage,
                          )
                        : null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Material(
                // Hell gegen dunkel statt Grau gegen Grau: bereit und nicht
                // bereit unterscheiden sich in der Helligkeit, nicht im
                // Farbton — auch ohne Farbsehen erkennbar.
                color: _hasText && widget.canSendText
                    ? Colors.white
                    : Colors.white12,
                shape: const CircleBorder(),
                child: Semantics(
                  label: AppLocalizations.of(context).chatSendMessage,
                  button: true,
                  // Der Zustand wird mitgesagt: Ohne Text oder ohne
                  // Berechtigung ist der Knopf zwar sichtbar, aber wirkungslos
                  // — das gehört angesagt, nicht erraten.
                  enabled: _hasText && widget.canSendText && widget.enabled,
                  child: InkWell(
                    onTap: () {
                      if (!widget.canSendText) {
                        showNoPermissionSnackBar(
                          context,
                          Permission.sendTextMessage,
                        );
                        return;
                      }
                      if (_hasText && widget.enabled) _sendMessage();
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.send,
                        color: _hasText && widget.canSendText
                            ? const Color(0xFF1C1B1F)
                            : Colors.white38,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
