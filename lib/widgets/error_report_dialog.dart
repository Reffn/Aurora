import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/screens/error_report_thank_you_screen.dart';
import 'package:dis_app/services/feedback_sender.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/utils/contact_config.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Error Report Dialog für Crash- und Error-Reporting
///
/// Zeigt 2 Tabs:
/// - Tab 1: Report-Details (Vorschau)
/// - Tab 2: Kontakt-Info (optional Email, Newsletter)
///
/// Features:
/// - Report-Preview
/// - Versand über FeedbackSender (Firestore, sonst E-Mail)
/// - Privacy-Hinweise
class ErrorReportDialog extends StatefulWidget {
  const ErrorReportDialog({
    required this.reportContent,
    required this.errorType,
    this.isCrash = false,
    super.key,
  });

  /// Vollständiger Error-Report (von EnhancedDebugReportGenerator)
  final String reportContent;

  /// Error-Type (z.B. "StateError", "HiveError")
  final String errorType;

  /// Ist das ein Crash-Report? (sonst Error-Report)
  final bool isCrash;

  @override
  State<ErrorReportDialog> createState() => _ErrorReportDialogState();
}

class _ErrorReportDialogState extends State<ErrorReportDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Controllers
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State
  bool _isLoading = false;
  bool _subscribeNewsletter = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(child: _buildTabBarView()),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                widget.isCrash ? Icons.error : Icons.warning,
                size: 40,
                color: widget.isCrash ? Colors.red : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isCrash
                          ? l10n.crashDialogTitle
                          : l10n.errorDialogTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isCrash
                          ? l10n.errorReportHelpUs
                          : l10n.errorHelpUsFix,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.errorReportRoute,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: const Color(ContactConfig.auroraPurple),
      unselectedLabelColor: Colors.grey,
      indicatorColor: const Color(ContactConfig.auroraPurple),
      tabs: [
        Tab(text: AppLocalizations.of(context).errorReportDetailsSection),
        Tab(text: AppLocalizations.of(context).errorReportContactSection),
      ],
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildReportPreview(),
        _buildContactForm(),
      ],
    );
  }

  Widget _buildReportPreview() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Preview
          Text(
            l10n.errorReportPreviewTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.errorReportWhatIsSent,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),

          // Report in Code-Block-Style
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: SelectableText(
                widget.reportContent,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.errorReportContactSection,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.errorReportContactExplanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            AuroraTextField(
              label: l10n.errorReportEmailLabel,
              controller: _emailController,
              hint: l10n.feedbackEmailPlaceholder,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null; // Optional
                }

                // Einfache Email-Validierung
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return l10n.feedbackEmailInvalid;
                }

                return null;
              },
            ),
            const SizedBox(height: 24),

            // Newsletter Checkbox (wenn URL konfiguriert)
            if (ContactConfig.newsletterSignupUrl.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _subscribeNewsletter,
                onChanged: (value) {
                  setState(() {
                    _subscribeNewsletter = value ?? false;
                  });
                },
                title: Text(l10n.errorReportNewsletter),
                subtitle: Text(
                  l10n.errorReportNewsletterSubtitle,
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Privacy Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.errorReportEmailPrivacy,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        children: [
          // Nur kopieren
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _copyToClipboard,
            icon: const Icon(Icons.copy),
            label: Text(l10n.errorReportCopy),
          ),
          const SizedBox(width: 12),

          // Senden
          Expanded(
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _sendReport,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(ContactConfig.auroraPurple),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isLoading
                    ? AppLocalizations.of(context).statusSending
                    : AppLocalizations.of(context).errorReportSendButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kopiert Report in Zwischenablage
  Future<void> _copyToClipboard() async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: widget.reportContent));

    if (mounted) {
      showCustomSnackBar(
        context,
        message: l10n.errorReportCopied,
        type: SnackBarType.success,
      );
    }

    logger.info(LogCategory.ui, 'Error report copied to clipboard');
  }

  /// Sendet Report über Firestore oder E-Mail (Fallback)
  Future<void> _sendReport() async {
    final l10n = AppLocalizations.of(context);
    // Validiere Form
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(1); // Wechsle zu Kontakt-Tab
      return;
    }

    setState(() {
      _isLoading = true;
    });

    logger.info(LogCategory.ui, 'Sending error report...');

    try {
      // Der erzeugte Bericht gehört in `diagnostics`, nicht in `message`:
      // Die Serverregel lässt für `message` 5000 Zeichen zu, ein Absturz-
      // bericht mit Stacktrace, 30 Breadcrumbs und 10 Logzeilen liegt
      // regelmäßig darüber. Als Diagnose hat er 10000 Zeichen Platz, und
      // `message` trägt die Zeile, die im Posteingang lesbar ist.
      final payload = FeedbackPayload(
        category: widget.isCrash ? 'Crash Report' : 'Error Report',
        message: l10n.errorReportAutoBody(widget.errorType),
        replyEmail: _emailController.text.isNotEmpty
            ? _emailController.text
            : null,
        diagnostics: widget.reportContent,
      );

      final result = await getIt<FeedbackSender>().send(payload);

      logger.info(
        LogCategory.ui,
        'Error report transport result',
        data: {'outcome': result.outcome.name},
      );

      if (!mounted) return;

      // Zeige Erfolgs-Seite wenn erfolgreich oder wartet
      if (result.outcome == TransportOutcome.sent) {
        logger.info(LogCategory.ui, 'Error report sent successfully');

        Navigator.of(context).pop(); // Schließe Dialog

        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ErrorReportThankYouScreen(
              userEmail: _emailController.text.isNotEmpty
                  ? _emailController.text
                  : null,
            ),
          ),
        );
      } else if (result.outcome == TransportOutcome.pending) {
        logger.info(LogCategory.ui, 'Error report pending (offline)');

        Navigator.of(context).pop(); // Schließe Dialog

        showCustomSnackBar(
          context,
          message: l10n.errorReportQueued,
        );
      } else {
        // Fehler beim Senden - Zeige Dialog
        logger.warning(LogCategory.ui, 'Error report send failed');
        await _showErrorDialog(result);
      }
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        'Error in sendReport',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );

      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.feedbackErrorOccurred,
          type: SnackBarType.error,
        );
        await _copyToClipboard();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Zeigt detaillierten Fehler-Dialog mit spezifischer Fehlermeldung
  Future<void> _showErrorDialog(TransportResult result) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        title: Text(l10n.errorReportFailed),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.reason ?? l10n.errorSendingFailed,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.errorReportClipboardFallback(ContactConfig.supportEmail),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Zwischenablage Button
          TextButton.icon(
            onPressed: () async {
              // Hol Navigator vor dem await
              final nav = Navigator.of(context);
              await _copyToClipboard();
              if (mounted) {
                nav.pop();
              }
            },
            icon: const Icon(Icons.copy),
            label: Text(l10n.errorReportCopyToClipboard),
          ),
          // Schließen Button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }
}
