import 'dart:io';
import 'dart:typed_data';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/chat_message.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/chat/widgets/camera_capture_screen.dart';
import 'package:dis_app/modules/chat/widgets/capture_bar.dart';
import 'package:dis_app/modules/chat/widgets/chat_input_field.dart';
import 'package:dis_app/modules/chat/widgets/chat_message_bubble.dart';
import 'package:dis_app/modules/chat/widgets/doodle_canvas.dart';
import 'package:dis_app/modules/chat/widgets/voice_recording_sheet.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/utils/snackbar_helper.dart';
import 'package:dis_app/widgets/animated_empty_state.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Haupt-Chat-Screen für Kommunikation zwischen Anteilen
/// Verwendet ValueListenableBuilder für reaktive Hive-Updates
/// **Nutzt DataEntry für alle Datenoperationen (Read + Write)**
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final _dataEntry = getIt<DataEntry>();

  /// Ob Berührungen auf der Fläche ans Malen gehen oder an den Verlauf.
  ///
  /// Junge Anteile beginnen im Malmodus — für sie ist Zeichnen die
  /// Grundhandlung im Chat und kein Sonderfall. Wer älter ist, beginnt beim
  /// Blättern. Umschalten kann jede und jeder, die Wahl bleibt bestehen.
  ///
  /// **Ohne Altersangabe wird geblättert, nicht gemalt.** Vorher hieß `null`
  /// dasselbe wie „acht Jahre alt": Wer kein Alter hinterlegt hat — und das
  /// ist keine Pflichtangabe —, fand den Chat im Malmodus vor, mit
  /// abgeblendetem Verlauf und einer Werkzeugleiste, die niemand gewählt
  /// hatte. Unbekannt ist nicht Kind. Der lautere von zwei Zuständen darf
  /// nicht der geratene sein (Regel 9: Zustände werden angeboten, nicht
  /// erkannt).
  late bool _drawing;

  @override
  void initState() {
    super.initState();
    final age = _dataEntry.getActiveProfile()?.age;
    _drawing = age != null && age <= 8;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Führt an das Ende des Verlaufs — die neueste Nachricht.
  ///
  /// Der Verlauf läuft umgekehrt (`reverse: true`), deshalb liegt das Ende
  /// bei `minScrollExtent` und nicht bei `maxScrollExtent`.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        // Zweiter Check: Controller könnte nach 100ms detached sein (schnelle Tab-Wechsel)
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Profile? _getProfileForMessage(ChatMessage message, List<Profile> profiles) {
    try {
      return profiles.firstWhere((p) => p.id == message.profileId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _sendMessage(String text, Profile? activeProfile) async {
    if (text.trim().isEmpty) return;
    if (activeProfile == null) {
      throw Exception(AppLocalizations.of(context).errorNoProfile);
    }

    final message = ChatMessage(
      id: const Uuid().v4(),
      profileId: activeProfile.id,
      content: text.trim(),
      timestamp: DateTime.now(),
      senderColorValue: activeProfile.preferredColorValue,
    );

    try {
      await _dataEntry.createChatMessage(message);
      _scrollToBottom();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sendDoodle(Uint8List imageBytes) async {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) {
      throw Exception(AppLocalizations.of(context).errorNoProfile);
    }

    // Vor dem await geholt: danach kann der Screen weg sein, die Nachricht
    // soll trotzdem entstehen.
    final inhalt = AppLocalizations.of(context).chatMessageDoodle;

    try {
      // Speichere Doodle und erhalte relativen Filename
      final filename = await AttachmentHelper.saveDoodle(imageBytes);

      // Erstelle Nachricht mit Doodle
      final message = ChatMessage(
        id: const Uuid().v4(),
        profileId: activeProfile.id,
        content: inhalt,
        timestamp: DateTime.now(),
        messageType: MessageType.doodle,
        attachmentFilename: filename,
        senderColorValue: activeProfile.preferredColorValue,
      );

      await _dataEntry.createChatMessage(message);
      _scrollToBottom();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sendVoiceMessage(Uint8List audioBytes) async {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) {
      throw Exception(AppLocalizations.of(context).errorNoProfile);
    }

    final inhalt = AppLocalizations.of(context).chatMessageVoice;

    try {
      // Speichere Voice und erhalte relativen Filename
      final filename = await AttachmentHelper.saveVoice(audioBytes);

      // Erstelle Nachricht mit Voice
      final message = ChatMessage(
        id: const Uuid().v4(),
        profileId: activeProfile.id,
        content: inhalt,
        timestamp: DateTime.now(),
        messageType: MessageType.voice,
        attachmentFilename: filename,
        senderColorValue: activeProfile.preferredColorValue,
      );

      await _dataEntry.createChatMessage(message);
      _scrollToBottom();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sendImageMessage(File imageFile) async {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) {
      throw Exception(AppLocalizations.of(context).errorNoProfile);
    }

    final inhalt = AppLocalizations.of(context).chatMessageImage;

    try {
      // Speichere Image und erhalte relativen Filename
      final bytes = await imageFile.readAsBytes();
      final filename = await AttachmentHelper.saveImage(bytes);

      // Erstelle Nachricht mit Image
      final message = ChatMessage(
        id: const Uuid().v4(),
        profileId: activeProfile.id,
        content: inhalt,
        timestamp: DateTime.now(),
        messageType: MessageType.image,
        attachmentFilename: filename,
        senderColorValue: activeProfile.preferredColorValue,
      );

      await _dataEntry.createChatMessage(message);
      _scrollToBottom();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sendVideoMessage(File videoFile) async {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) {
      throw Exception(AppLocalizations.of(context).errorNoProfile);
    }

    final inhalt = AppLocalizations.of(context).chatMessageVideo;

    try {
      // Speichere Video und erhalte relativen Filename
      final filename = await AttachmentHelper.saveVideo(videoFile);

      // Erstelle Nachricht mit Video
      final message = ChatMessage(
        id: const Uuid().v4(),
        profileId: activeProfile.id,
        content: inhalt,
        timestamp: DateTime.now(),
        messageType: MessageType.video,
        attachmentFilename: filename,
        senderColorValue: activeProfile.preferredColorValue,
      );

      await _dataEntry.createChatMessage(message);
      _scrollToBottom();
    } catch (e) {
      rethrow;
    }
  }

  /// Der Nachrichtenverlauf. Liegt hinter der Zeichenfläche und wird blasser,
  /// solange gemalt wird — sichtbar genug, um zu erkennen, worauf man antwortet,
  /// zurückgenommen genug, dass die eigene Zeichnung klar davor steht.
  ///
  /// [railVisible] sagt, ob rechts der Streifen der Zeichenfläche liegt. Wer
  /// nicht malen darf, sieht ihn nie — dann darf die leere Fläche auch nicht
  /// dafür ausrücken.
  Widget _buildMessageList({required bool railVisible}) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        _dataEntry.chatMessagesBox.listenable(),
        _dataEntry.profilesBox.listenable(),
        _dataEntry.settingsBox.listenable(),
      ]),
      builder: (context, _) {
        final messages = _dataEntry.getChatMessages();
        final profiles = _dataEntry.getProfiles();
        final activeProfile = _dataEntry.getActiveProfile();

        if (messages.isEmpty) {
          // Die Werkzeugleiste der Zeichenfläche liegt rechts darüber. Ohne
          // diesen Streifen lief der mittige Text darunter und war am Rand
          // abgeschnitten.
          return Padding(
            padding: EdgeInsets.only(
              right: railVisible ? DoodleCanvas.toolRailWidth : 0,
            ),
            child: AnimatedEmptyState(
              icon: Icons.chat_bubble_outline,
              title: l10n.chatEmptyTitle,
              subtitle: l10n.chatEmptySubtitle,
            ),
          );
        }

        // Der Verlauf trug bisher nur Uhrzeiten. Zwei Blasen untereinander,
        // „22:07" über „13:50", und die obere war von gestern — zu sehen war
        // das nirgends. In einer App, deren Startfläche um „wann bin ich"
        // herum gebaut ist, ist das die falsche Auslassung: Der Chat ist der
        // Ort, an dem Anteile einander Nachrichten hinterlassen.
        //
        // Ein Datum an jeder Blase wäre Lärm. Der Trenner beantwortet
        // dieselbe Frage einmal pro Tag.
        final eintraege = mitTagestrennern(messages);

        return ListView.builder(
          controller: _scrollController,
          // Der Verlauf steht auf dem Kopf: Element 0 liegt unten.
          //
          // Vorher war er oben verankert, und ein Bildaufbau nach dem anderen
          // schob ihn per Rückruf ans Ende. Wer den Chat mit einer Nachricht
          // öffnete, sah eine Blase unter der Werkzeugleiste und darunter
          // einen halben Schirm Leere — am 11. August 2026 am Gerät gesehen.
          // `reverse` verlangt keine Rechnung und keinen Bildaufbau: Das Ende
          // des Verlaufs ist der Anfang der Liste und liegt am Eingabefeld.
          //
          // Damit fällt auch der `addPostFrameCallback` weg, der bei jedem
          // Bildaufbau eine Bewegung anstieß — auf einer Fläche, die an drei
          // Hive-Kisten hängt.
          reverse: true,
          // Kein berechnetes Bodenpolster mehr: Eingabe und Zeichenfläche
          // liegen nicht länger über dem Verlauf, sondern in derselben Spalte.
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: eintraege.length,
          itemBuilder: (context, index) {
            final eintrag = eintraege[eintraege.length - 1 - index];

            final tag = eintrag.tag;
            if (tag != null) return _Tagestrenner(tag: tag);

            final message = eintrag.message!;
            final profile = _getProfileForMessage(message, profiles);

            return ChatMessageBubble(
              message: message,
              profile: profile,
              isCurrentUser: profile?.id == activeProfile?.id,
              onLongPress: () {
                if (!message.isRead) {
                  _dataEntry.markMessageAsRead(message.id);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNoPermissionNotice(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.signal.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(color: AppColors.signal.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.block, color: AppColors.signal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.errorNoPermission,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  /// Öffnet Auroras eigene Kameraansicht und schickt das Bild ab.
  Future<void> _captureImage() async {
    final file = await CameraCaptureScreen.open(context);
    if (file == null || !mounted) return;
    try {
      await _sendImageMessage(file);
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          AppLocalizations.of(context).chatErrorSendingImage(e.toString()),
        );
      }
    }
  }

  Future<void> _recordVoice(Color profileColor) async {
    final bytes = await VoiceRecordingSheet.record(context, profileColor);
    if (bytes == null || !mounted) return;
    try {
      await _sendVoiceMessage(bytes);
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          AppLocalizations.of(context).chatErrorSendingVoice(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Zurück schließt erst die Zeichenfläche, dann den Chat.
    //
    // Im Malmodus liegt die Fläche über dem Verlauf, und die Zurück-Geste ist
    // das Naheliegendste, um sie loszuwerden. Ohne diese Stufe führte sie bis
    // auf den Startschirm — eine angefangene, nicht gesendete Zeichnung war
    // damit weg, ohne Nachfrage.
    return PopScope(
      canPop: !_drawing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_drawing) {
          setState(() => _drawing = false);
        }
      },
      child: Scaffold(
        appBar: const StandardAppBar(),
        body: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: _dataEntry.settingsBox.listenable(),
            builder: (context, settingsBox, _) {
              final activeProfile = _dataEntry.getActiveProfile();
              final profileColor = activeProfile?.preferredColor ?? Colors.grey;

              // Die alte Sammelberechtigung gilt weiter als Freibrief für alles.
              final hasLegacyPermission =
                  activeProfile?.hasPermission(Permission.sendChatMessage) ??
                  false;
              bool may(Permission permission) =>
                  hasLegacyPermission ||
                  (activeProfile?.hasPermission(permission) ?? false);

              final canSendText = may(Permission.sendTextMessage);
              final canSendDoodle = may(Permission.sendDoodle);
              final canSendVoice = may(Permission.sendVoiceMessage);
              final canSendImage = may(Permission.sendImage);
              final canSendVideo = may(Permission.sendVideo);

              final canSendAnything =
                  canSendText ||
                  canSendDoodle ||
                  canSendVoice ||
                  canSendImage ||
                  canSendVideo;

              if (!canSendAnything) {
                return Column(
                  children: [
                    Expanded(child: _buildMessageList(railVisible: false)),
                    _buildNoPermissionNotice(l10n),
                  ],
                );
              }

              return Column(
                children: [
                  CaptureBar(
                    profileColor: profileColor,
                    canSendImage: canSendImage,
                    canSendVoice: canSendVoice,
                    onCamera: _captureImage,
                    onVoice: () => _recordVoice(profileColor),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _drawing ? 0.3 : 1,
                            child: _buildMessageList(
                              railVisible: canSendDoodle,
                            ),
                          ),
                        ),

                        if (canSendDoodle)
                          Positioned.fill(
                            child: DoodleCanvas(
                              profileColor: profileColor,
                              drawingEnabled: _drawing,
                              onToggleDrawing: () {
                                // Erst die Tastatur weg, dann umschalten: Sonst
                                // bleibt sie über der Zeichenfläche stehen, die
                                // Zeile darunter ist aber nicht mehr zu sehen.
                                FocusScope.of(context).unfocus();
                                setState(() => _drawing = !_drawing);
                              },
                              onSend: (imageBytes) async {
                                try {
                                  await _sendDoodle(imageBytes);
                                  // Nach dem Abschicken zurück in den Verlauf.
                                  //
                                  // Sonst bleibt die Zeichenfläche über dem
                                  // Chat liegen, und der Verlauf steht auf
                                  // Deckkraft 0,3 — man sieht ausgerechnet das
                                  // gerade gesendete Bild nur verdunkelt und
                                  // muss erst den Umschalter suchen.
                                  if (mounted) {
                                    setState(() => _drawing = false);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    context.showErrorSnackBar(
                                      l10n.chatErrorSendingDoodle(e.toString()),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Die Textzeile tritt zurück, solange gemalt wird.
                  //
                  // Sonst liegen zwei gleiche Sende-Pfeile gleichzeitig auf dem
                  // Schirm — einer für die Zeichnung, einer für den Text —, und
                  // beide sagen dasselbe Wort für zwei verschiedene Inhalte.
                  // Das Malen ist ein gewählter Zustand, kein geratener; der
                  // Pinsel holt die Zeile zurück.
                  //
                  // Kamera und Mikrofon bleiben in beiden Fällen stehen: Sie
                  // sind die Wege für alle, die nicht schreiben — und genau die
                  // beginnen im Malmodus.
                  //
                  // Verborgen, nicht entfernt. Wird die Zeile aus dem Baum
                  // genommen, geht ihr Controller mit — ein halb getippter Satz
                  // wäre nach einem Griff auf den Pinsel weg, ohne Hinweis und
                  // ohne Weg zurück. Gerade hier wird der Pinsel auch ungewollt
                  // getroffen.
                  Visibility(
                    visible: !_drawing,
                    maintainState: true,
                    child: ChatInputField(
                      enabled: activeProfile != null,
                      profileColor: profileColor,
                      canSendText: canSendText,
                      canSendImage: canSendImage,
                      canSendVideo: canSendVideo,
                      onSendMessage: (text) async {
                        try {
                          await _sendMessage(text, activeProfile);
                        } catch (e) {
                          if (context.mounted) {
                            context.showErrorSnackBar(
                              l10n.chatErrorSending(e.toString()),
                            );
                          }
                        }
                      },
                      onSendImage: (imageFile) async {
                        try {
                          await _sendImageMessage(imageFile);
                        } catch (e) {
                          if (context.mounted) {
                            context.showErrorSnackBar(
                              l10n.chatErrorSendingImage(e.toString()),
                            );
                          }
                        }
                      },
                      onSendVideo: (videoFile) async {
                        try {
                          await _sendVideoMessage(videoFile);
                        } catch (e) {
                          if (context.mounted) {
                            context.showErrorSnackBar(
                              l10n.chatErrorSendingVideo(e.toString()),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Ein Eintrag im Verlauf: entweder eine Nachricht oder die Überschrift des
/// Tages, an dem die folgenden Nachrichten geschrieben wurden.
class VerlaufsEintrag {
  const VerlaufsEintrag.nachricht(ChatMessage this.message) : tag = null;
  const VerlaufsEintrag.tag(DateTime this.tag) : message = null;

  final ChatMessage? message;
  final DateTime? tag;
}

/// Schiebt vor die erste Nachricht jedes Tages dessen Überschrift.
///
/// Erwartet die Nachrichten in zeitlicher Ordnung — dafür sorgt
/// `ChatService.messages`. Ohne diese Ordnung stünde derselbe Tag mehrfach
/// im Verlauf.
List<VerlaufsEintrag> mitTagestrennern(List<ChatMessage> messages) {
  final eintraege = <VerlaufsEintrag>[];
  DateTime? letzterTag;

  for (final message in messages) {
    final tag = DateUtils.dateOnly(message.timestamp);
    if (tag != letzterTag) {
      eintraege.add(VerlaufsEintrag.tag(tag));
      letzterTag = tag;
    }
    eintraege.add(VerlaufsEintrag.nachricht(message));
  }

  return eintraege;
}

/// „Heute", „Gestern", sonst der ausgeschriebene Tag.
///
/// Leise gehalten: Die Überschrift ordnet ein, sie ruft nicht. Gesättigte
/// Farbe bleibt dem vorbehalten, was im schlechtesten Zustand gefunden werden
/// muss (`docs/oberflaechen-richtlinien.md`, Regel 4).
class _Tagestrenner extends StatelessWidget {
  const _Tagestrenner({required this.tag});

  final DateTime tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final heute = DateUtils.dateOnly(DateTime.now());
    // Nicht `subtract(Duration(days: 1))`: An einem Tag mit Zeitumstellung
    // landet das 23 oder 25 Stunden früher und damit auf dem falschen Datum.
    final gestern = DateTime(heute.year, heute.month, heute.day - 1);

    final String beschriftung;
    if (tag == heute) {
      beschriftung = l10n.miscToday;
    } else if (tag == gestern) {
      beschriftung = l10n.chatDayYesterday;
    } else {
      beschriftung = DateFormat.yMMMMEEEEd(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(tag);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.white24)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              beschriftung,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const Expanded(child: Divider(color: Colors.white24)),
        ],
      ),
    );
  }
}
