import 'dart:typed_data';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/chat_message.dart';
import 'package:dis_app/modules/chat/widgets/doodle_canvas.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/utils/snackbar_helper.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Freies Zeichnen als eigene Fläche.
///
/// Die Zeichenmaschinerie gab es längst — knapp tausend Zeilen mit
/// Werkzeugleiste, Farben und Stempeln, aber nur eingeklemmt unter dem
/// Chatverlauf. In den Spielen stand „Zeichnen" derweil als „Bald". Dieselbe
/// tote Karte neben einer fertigen Sache wie zuvor bei den Atemübungen.
///
/// Zwei Unterschiede zur Fläche im Chat:
///
/// **Kein Moduswechsel.** Im Chat teilt sich die Fläche die Berührungen mit
/// dem Verlauf darunter, deshalb gibt es dort einen Umschalter, dessen
/// oberster Knopf seine Bedeutung wechselt — das verletzt Regel 7 und steht
/// als bekannter Punkt in den Richtlinien. Hier gibt es nichts darunter, also
/// entfällt der Umschalter und die Werkzeugleiste behält eine feste
/// Bedeutung.
///
/// **Das Bild geht in den Chat.** Ein eigener Speicherort hätte eine Datei
/// erzeugt, die nirgends wieder auftaucht. Doodles wohnen in dieser App im
/// Chat; der Knopf sagt das auch (Regel 10: vorher sagen, was passiert).
class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final _dataEntry = getIt<DataEntry>();

  Future<void> _inDenChat(Uint8List imageBytes) async {
    final profile = _dataEntry.getActiveProfile();
    if (profile == null) return;

    final l10n = AppLocalizations.of(context);
    final inhalt = l10n.chatMessageDoodle;
    final bestaetigung = l10n.gamesDrawingSent;

    final filename = await AttachmentHelper.saveDoodle(imageBytes);

    await _dataEntry.createChatMessage(
      ChatMessage(
        id: const Uuid().v4(),
        profileId: profile.id,
        content: inhalt,
        timestamp: DateTime.now(),
        messageType: MessageType.doodle,
        attachmentFilename: filename,
        senderColorValue: profile.preferredColorValue,
      ),
    );

    if (!mounted) return;
    // Sagt, was jetzt passiert ist — und lässt die Fläche los, statt sie
    // stumm stehen zu lassen.
    context.showSuccessSnackBar(bestaetigung);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = _dataEntry.getActiveProfile();

    return Scaffold(
      appBar: StandardAppBar(title: l10n.gamesDrawingTitle),
      body: SafeArea(
        child: DoodleCanvas(
          onSend: _inDenChat,
          profileColor: profile?.preferredColor ?? Colors.grey,
          // Es liegt nichts darunter, was Berührungen bekommen könnte.
          drawingEnabled: true,
          onToggleDrawing: () {},
          showModeToggle: false,
          confirmIcon: Icons.send,
          confirmTooltip: l10n.gamesDrawingSend,
          confirmEmptyTooltip: l10n.gamesDrawingEmpty,
        ),
      ),
    );
  }
}
