import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/debug_log_generator.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/debug_log_overlay.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';

/// Diagnose: das Debug-Log zum Weitergeben und wie viele Erinnerungen das
/// System vorgemerkt hat. Beides hilft, wenn etwas nicht ankommt, und steht
/// deshalb nicht auf dem Hauptschirm.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  late final NotificationService _notificationService =
      getIt<NotificationService>();

  /// Wie viele Erinnerungen beim Betriebssystem vorgemerkt sind.
  ///
  /// Einmal beim Oeffnen geholt, nicht im `build`: dort erzeugte jeder
  /// Neuaufbau ein neues Future und damit einen weiteren Umlauf zum
  /// Benachrichtigungs-Plugin. Dieselbe Falle, die die Avatare langsam
  /// gemacht hat.
  late final Future<int> _vorgemerkteErinnerungen = _notificationService
      .countScheduledReminders();

  bool _isGeneratingLog = false;

  /// Generiert Debug-Log und zeigt Overlay
  Future<void> _generateDebugLog() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isGeneratingLog = true;
    });

    try {
      // Generiere Debug-Report
      final logContent = await DebugLogGenerator.generateFullReport();

      if (mounted) {
        setState(() {
          _isGeneratingLog = false;
        });

        // Zeige Overlay mit Logs
        await showDialog<void>(
          context: context,
          builder: (context) => DebugLogOverlay(logContent: logContent),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingLog = false;
        });

        showCustomSnackBar(
          context,
          message: l10n.settingsDebugLogError(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: StandardAppBar(title: l10n.settingsDiagnosticsTitle),
      body: ListView(
        // Unten das Polster der Navigationsleiste, wie im Hauptschirm.
        padding: EdgeInsets.fromLTRB(
          8,
          8,
          8,
          context.safeBottomPaddingWithMargin(8),
        ),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: _isGeneratingLog
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    )
                  : const Icon(
                      Icons.bug_report,
                      color: Colors.blue,
                      size: 32,
                    ),
              title: Text(
                l10n.settingsDebugLog,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                l10n.settingsDebugLogSubtitle,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: _isGeneratingLog
                  ? null
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              enabled: !_isGeneratingLog,
              onTap: _isGeneratingLog ? null : _generateDebugLog,
            ),
          ),

          // Queue Status
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.pending_actions,
                        color: Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.settingsQueue,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Fragt das Betriebssystem, nicht die eigene Notiz.
                  // Vorher stand hier der Inhalt der Warteschlangen-Box —
                  // seit der Abgleich plant, schreibt die niemand mehr, und
                  // die Zahl waere immer null gewesen.
                  FutureBuilder<int>(
                    future: _vorgemerkteErinnerungen,
                    builder: (context, snapshot) {
                      final pendingCount = snapshot.data ?? 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.settingsScheduledNotifications,
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                l10n.settingsCountValue(pendingCount),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          // Hier stand „naechste um …". Die Zeit kam aus
                          // dem ersten Warteschlangeneintrag; das
                          // Betriebssystem gibt sie nicht zurueck
                          // (pendingNotificationRequests liefert Kennung,
                          // Titel, Text und Payload — keinen Zeitpunkt).
                          // Eine Zeit zu zeigen, die wir nicht kennen,
                          // waere genau die Art Zusage, um die es bei
                          // diesem Umbau ging.
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
