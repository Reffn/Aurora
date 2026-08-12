import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Overlay zum Anzeigen und Kopieren von Debug-Logs
///
/// Zeigt Debug-Report in scrollbarem Text-Widget
/// mit Copy-to-Clipboard Funktionalität.
class DebugLogOverlay extends StatelessWidget {
  const DebugLogOverlay({
    required this.logContent,
    super.key,
  });

  final String logContent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).debugLogReportTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // Copy-Button
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'In Zwischenablage kopieren',
              onPressed: () => _copyToClipboard(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Info-Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade900.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade300,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Diagnose-Informationen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.debugLogHint,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Log-Content (scrollbar)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  logContent,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Zeilen-Count
                      Expanded(
                        child: Text(
                          '${logContent.split('\n').length} Zeilen · '
                          '${(logContent.length / 1024).toStringAsFixed(1)} KB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),

                      // Copy-Button (großflächig)
                      FilledButton.icon(
                        onPressed: () => _copyToClipboard(context),
                        icon: const Icon(Icons.copy, size: 20),
                        label: const Text('Kopieren'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kopiert Log-Content in Zwischenablage
  Future<void> _copyToClipboard(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: logContent));

      if (context.mounted) {
        context.showSuccessSnackBar(
          '✅ Debug-Log in Zwischenablage kopiert (${(logContent.length / 1024).toStringAsFixed(1)} KB)',
        );
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(
          'Fehler beim Kopieren: $e',
        );
      }
    }
  }
}
