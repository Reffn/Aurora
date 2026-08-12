import 'dart:math';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/feedback_category.dart';
import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/modules/transparency/transparency_screen.dart';
import 'package:dis_app/screens/feedback_thank_you_screen.dart';
import 'package:dis_app/services/feedback_sender.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/utils/contact_config.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/form_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Feedback Screen für User-Feedback per Email
///
/// Features:
/// - Kategorie-Auswahl (Bug, Feature, General)
/// - Text-Nachricht
/// - Optional: Email für Rückfragen
/// - Versand über FeedbackSender (Firestore, sonst E-Mail)
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // Form State
  FeedbackCategory _selectedCategory = FeedbackCategory.generalFeedback;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Loading State
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _buildHeader(l10n),
        Expanded(child: _buildFeedbackForm(l10n)),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo_rainbow.png',
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.contact_support,
                  size: 40,
                  color: Color(ContactConfig.auroraPurple),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.feedbackTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ContactConfig.teamName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(ContactConfig.auroraPurple),
                        fontWeight: FontWeight.w600,
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
              color: const Color(
                ContactConfig.auroraPurple,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color(ContactConfig.auroraPurple),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.feedbackPrivacyInfo,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        // Bottom Padding mit Safe Area für System UI (Navigation Bar, Home Indicator)
        bottom: 20 + context.safeBottomPadding,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategorie-Auswahl
            Text(
              l10n.feedbackSelectCategory,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...FeedbackCategory.values.map((category) {
              return RadioListTile<FeedbackCategory>(
                value: category,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                title: Row(
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(category.label(l10n)),
                  ],
                ),
                activeColor: const Color(ContactConfig.auroraPurple),
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),

            // Titel-Feld
            Text(
              l10n.feedbackTitleLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            AuroraTextField(
              label: null,
              controller: _titleController,
              hint: l10n.feedbackTitleHint,
              maxLength: 100,
              validator: (value) {
                logger.debug(
                  LogCategory.ui,
                  '🔍 Validating title',
                  data: {
                    'value': value,
                    'isEmpty': value == null || value.trim().isEmpty,
                    'length': value?.trim().length,
                  },
                );
                if (value == null || value.trim().isEmpty) {
                  return l10n.feedbackTitleRequired;
                }
                if (value.trim().length < 5) {
                  return l10n.feedbackTitleTooShort;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nachricht-Feld
            Text(
              l10n.feedbackMessageLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            AuroraTextField(
              label: null,
              controller: _messageController,
              hint: l10n.feedbackMessageHint,
              maxLines: 8,
              maxLength: 2000,
              validator: (value) {
                logger.debug(
                  LogCategory.ui,
                  '🔍 Validating message',
                  data: {
                    'value': value != null
                        ? value.substring(0, min(50, value.length))
                        : null,
                    'isEmpty': value == null || value.trim().isEmpty,
                    'length': value?.trim().length,
                    'requiredMin': 20,
                  },
                );
                if (value == null || value.trim().isEmpty) {
                  return l10n.feedbackMessageRequired;
                }
                // Untergrenze aus firestore.rules — siehe FeedbackPayload.
                if (value.trim().length < FeedbackPayload.minMessageLength) {
                  return l10n.feedbackMessageTooShort;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email-Feld
            Text(
              l10n.feedbackEmailLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.feedbackEmailHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            AuroraTextField(
              label: null,
              controller: _emailController,
              hint: l10n.feedbackEmailPlaceholder,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                logger.debug(
                  LogCategory.ui,
                  '🔍 Validating email',
                  data: {
                    'value': value,
                    'isEmpty': value == null || value.isEmpty,
                  },
                );
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return l10n.feedbackEmailInvalid;
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            FormActionButton(
              label: l10n.feedbackSend,
              icon: Icons.send,
              loading: _isLoading,
              backgroundColor: const Color(ContactConfig.auroraPurple),
              onPressed: () => _sendFeedback(l10n),
            ),

            // Kopieren-Button (Fallback)
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _copyToClipboard(l10n),
                icon: const Icon(Icons.copy),
                label: Text(l10n.feedbackCopyToClipboard),
              ),
            ),

            // Der Weg zum Protokoll steht auf der Fläche, die sendet.
            //
            // Die Zusage lautet: Alles, was das Gerät verlässt, ist wörtlich
            // nachlesbar. Nachlesbar war es auch vorher — aber nur, wer den
            // Weg über die Einstellungen kannte, fand es. Ausgerechnet hier
            // stand kein Verweis: Hier schickt jemand gerade etwas weg und
            // trägt darüber freiwillig seine E-Mail-Adresse ein, also genau
            // das eine Feld dieser App, das auf einen Menschen zurückführt.
            //
            // Ruhig gesetzt, mit Symbol und Wort: ein Angebot, kein
            // Warnhinweis (Richtlinie 4 und 5).
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TransparencyScreen(),
                  ),
                ),
                icon: const Icon(Icons.receipt_long, size: 18),
                label: Text(l10n.settingsWhatAuroraSends),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sendet Feedback über Firestore oder E-Mail (Fallback)
  Future<void> _sendFeedback(AppLocalizations l10n) async {
    logger.info(LogCategory.ui, 'Send Feedback Button Clicked');

    // Log complete form state before validation
    logger.debug(
      LogCategory.ui,
      '🔍 Form state before validation',
      data: {
        'titleController': _titleController.text,
        'titleLength': _titleController.text.trim().length,
        'messageController': _messageController.text,
        'messageLength': _messageController.text.trim().length,
        'emailController': _emailController.text,
      },
    );

    // Validiere Form
    if (!_formKey.currentState!.validate()) {
      // Log detailed validation failure reasons
      final titleValid = _titleController.text.trim().length >= 5;
      final messageValid =
          _messageController.text.trim().length >=
          FeedbackPayload.minMessageLength;
      final emailValid =
          _emailController.text.isEmpty ||
          RegExp(
            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
          ).hasMatch(_emailController.text);

      logger.warning(
        LogCategory.ui,
        '❌ Form validation FAILED - checking fields',
        data: {
          'titleLength': _titleController.text.trim().length,
          'titleValid': titleValid,
          'titleError': !titleValid
              ? (_titleController.text.trim().isEmpty
                    ? 'empty'
                    : 'too_short_<5')
              : null,
          'messageLength': _messageController.text.trim().length,
          'messageValid': messageValid,
          'messageError': !messageValid
              ? (_messageController.text.trim().isEmpty
                    ? 'empty'
                    : 'too_short_<20')
              : null,
          'emailEmpty': _emailController.text.isEmpty,
          'emailValid': emailValid,
          'emailError': !emailValid ? 'invalid_format' : null,
        },
      );
      return;
    }

    logger.info(LogCategory.ui, '✅ Form validation passed');

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final message = _messageController.text.trim();
      final email = _emailController.text.trim();

      logger.info(
        LogCategory.ui,
        'Sending feedback',
        data: {
          'category': _selectedCategory.wireName,
          'hasEmail': email.isNotEmpty,
        },
      );

      // Erstelle Feedback Payload
      final payload = FeedbackPayload(
        // Der sprachunabhängige Wert: Was ausgewertet wird, darf nicht davon
        // abhängen, in welcher Sprache jemand die App bedient.
        category: _selectedCategory.wireName,
        message: '$title\n\n$message',
        replyEmail: email.isNotEmpty ? email : null,
      );

      final result = await getIt<FeedbackSender>().send(payload);

      logger.info(
        LogCategory.ui,
        'Feedback transport result',
        data: {'outcome': result.outcome.name},
      );

      if (!mounted) return;

      // Zeige Erfolgs-Seite wenn erfolgreich oder wartet
      if (result.outcome == TransportOutcome.sent) {
        logger.info(LogCategory.ui, 'Feedback sent successfully');

        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FeedbackThankYouScreen(
              userEmail: email.isNotEmpty ? email : null,
            ),
          ),
        );

        // Clear form nach Rückkehr
        if (mounted) {
          _titleController.clear();
          _messageController.clear();
          _emailController.clear();
          setState(() => _selectedCategory = FeedbackCategory.generalFeedback);
        }
      } else if (result.outcome == TransportOutcome.pending) {
        logger.info(LogCategory.ui, 'Feedback pending (offline)');

        // Zeige pending-Meldung
        showCustomSnackBar(
          context,
          message: l10n.feedbackQueued,
          type: SnackBarType.info,
        );

        // Clear form
        if (mounted) {
          _titleController.clear();
          _messageController.clear();
          _emailController.clear();
          setState(() => _selectedCategory = FeedbackCategory.generalFeedback);
        }
      } else {
        // Fehler beim Senden - Zeige Dialog
        logger.warning(LogCategory.ui, 'Feedback send failed');
        await _showErrorDialog(l10n, result);
      }
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        'Error in sendFeedback',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );

      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.feedbackErrorOccurred,
          type: SnackBarType.error,
        );
        await _copyToClipboard(l10n);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Kopiert Feedback in Zwischenablage (Fallback)
  Future<void> _copyToClipboard(AppLocalizations l10n) async {
    final l10n = AppLocalizations.of(context);
    final buffer = StringBuffer();
    buffer.writeln('Aurora Feedback');
    buffer.writeln();
    // Dieser Text landet in der Zwischenablage beziehungsweise im
    // E-Mail-Fenster — er wird gelesen, also die Beschriftung, nicht der
    // Leitungswert.
    buffer.writeln(
      '${l10n.feedbackCategoryLabel}: ${_selectedCategory.label(l10n)}',
    );
    buffer.writeln(
      '${l10n.feedbackTitleLabel}: ${_titleController.text.trim()}',
    );
    buffer.writeln();
    buffer.writeln('${l10n.feedbackMessageLabel}:');
    buffer.writeln(_messageController.text.trim());

    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('${l10n.feedbackContactLabel}: $email');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (mounted) {
      showCustomSnackBar(
        context,
        message: l10n.feedbackCopiedToClipboard,
        type: SnackBarType.success,
      );
    }

    logger.info(LogCategory.ui, 'Feedback copied to clipboard');
  }

  /// Zeigt detaillierten Fehler-Dialog mit spezifischer Fehlermeldung
  Future<void> _showErrorDialog(
    AppLocalizations l10n,
    TransportResult result,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        title: Text(l10n.feedbackCouldNotSend),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.reason ?? l10n.feedbackErrorOccurred,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.feedbackErrorClipboardHint(ContactConfig.supportEmail),
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
              await _copyToClipboard(l10n);
              if (mounted) {
                nav.pop();
              }
            },
            icon: const Icon(Icons.copy),
            label: Text(l10n.feedbackCopyToClipboard),
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
