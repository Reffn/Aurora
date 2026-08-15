import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/profile_edit_screen.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:dis_app/services/password_reset_service.dart';
import 'package:dis_app/l10n/supported_languages.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/gradient_text.dart';
import 'package:dis_app/widgets/language_choice_dialog.dart';
import 'package:flutter/material.dart';

/// Dialog mit Aktionen für ein Profil
/// Zeigt Optionen: Profil wechseln, Profil bearbeiten
class ProfileActionsDialog extends StatefulWidget {
  const ProfileActionsDialog({
    required this.profile,
    this.requireCurrentProfileLogin = false,
    super.key,
  });

  final Profile profile;
  final bool requireCurrentProfileLogin;

  static Future<void> show(
    BuildContext context,
    Profile profile, {
    bool requireCurrentProfileLogin = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ProfileActionsDialog(
        profile: profile,
        requireCurrentProfileLogin: requireCurrentProfileLogin,
      ),
    );
  }

  @override
  State<ProfileActionsDialog> createState() => _ProfileActionsDialogState();
}

class _ProfileActionsDialogState extends State<ProfileActionsDialog> {
  final _dataEntry = getIt<DataEntry>();

  /// Die gewählte Sprache dieses Anteils, `null` heißt „wie die App".
  ///
  /// Eigenes Feld, weil `widget.profile` die Instanz von vor dem Speichern
  /// bleibt — der Knopf zeigte sonst weiter die alte Sprache an.
  late String? _language = widget.profile.preferredLanguage;

  /// Fragt nach der Sprache dieses Anteils und merkt sie am Profil.
  Future<void> _changeLanguage() async {
    final choice = await showLanguageChoiceDialog(
      context,
      current: _language,
      allowFollowApp: true,
    );
    if (choice == null || !mounted) return;

    await _dataEntry.updateProfile(
      widget.profile.copyWith(
        preferredLanguage: choice.code,
        clearPreferredLanguage: choice.code == null,
      ),
    );
    if (mounted) setState(() => _language = choice.code);
  }

  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _switchToProfile() async {
    // Breadcrumb: Login-Versuch
    logger.breadcrumb(
      BreadcrumbType.user,
      'Attempting profile login',
      data: {
        'profileId': widget.profile.id.substring(0, 8),
        'hasPassword': widget.profile.hasPassword,
      },
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Prüfe ob Passwort benötigt wird
      if (widget.profile.hasPassword) {
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          logger.warning(
            LogCategory.ui,
            'Login failed: Empty password',
            data: {'profileId': widget.profile.id.substring(0, 8)},
          );
          setState(() {
            _errorMessage = AppTexts.current.validationPasswordRequired;
            _isLoading = false;
          });
          return;
        }

        // Prüfe Login mit Reset-Handling (Unit 3)
        final outcome = await _dataEntry.checkAndHandleLogin(
          widget.profile,
          password,
        );

        if (outcome == ResetLoginOutcome.wrongPassword) {
          logger.warning(
            LogCategory.ui,
            'Login failed: Wrong password',
            data: {
              'profileId': widget.profile.id.substring(0, 8),
              'hasPassword': widget.profile.hasPassword,
            },
          );

          // Breadcrumb: Failed login
          logger.breadcrumb(
            BreadcrumbType.user,
            'Login failed - wrong password',
          );

          setState(() {
            _errorMessage = AppTexts.current.pwResetWrongPassword;
            _isLoading = false;
          });
          return;
        }

        // Zeige Reset-Hinweise für cancelled/activated
        if (outcome == ResetLoginOutcome.cancelled) {
          if (mounted) {
            setState(() => _isLoading = false);
            await _showResetCancelledDialog();
          }
        } else if (outcome == ResetLoginOutcome.activated) {
          if (mounted) {
            setState(() => _isLoading = false);
            await _showPasswordActivatedDialog();
          }
        }
      }

      // Eine erneute Bestätigung desselben Anteils ist kein Profilwechsel.
      // Insbesondere darf sie kein falsches Wechselereignis samt Standort in
      // der Zeitachse erzeugen.
      final wasAlreadyActive =
          _dataEntry.getActiveProfile()?.id == widget.profile.id;
      if (!wasAlreadyActive) {
        await _dataEntry.changeActiveProfile(widget.profile);
      }

      logger.info(
        LogCategory.ui,
        'Profile login successful',
        data: {'profileId': widget.profile.id.substring(0, 8)},
      );

      // Breadcrumb: Successful login
      logger.breadcrumb(
        BreadcrumbType.state,
        wasAlreadyActive
            ? 'Profile session confirmed successfully'
            : 'Profile switched successfully',
        data: {'profileId': widget.profile.id.substring(0, 8)},
      );

      if (mounted) {
        Navigator.of(context).pop(); // Schließe Dialog
      }
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        'Error during profile switch',
        data: {
          'profileId': widget.profile.id.substring(0, 8),
          'hasPassword': widget.profile.hasPassword,
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
        stackTrace: stackTrace,
      );

      // Breadcrumb: Error during login
      logger.breadcrumb(
        BreadcrumbType.system,
        'Profile switch error: ${e.runtimeType}',
      );

      setState(() {
        _errorMessage = AppTexts.current.profileSwitchError(e.toString());
        _isLoading = false;
      });
    }
  }

  /// Dialog: Reset-Abbruch durch korrektes altes Passwort
  Future<void> _showResetCancelledDialog() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Row(
          children: [
            Icon(
              Icons.timer_off_outlined,
              color: widget.profile.preferredColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.pwResetCancelledTitle,
                style: TextStyle(color: AppColors.paper),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.pwResetCancelledMessage,
          style: TextStyle(
            color: AppColors.paper.withValues(alpha: 0.8),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.profile.preferredColor,
              foregroundColor: AppColors.onColor(widget.profile.preferredColor),
            ),
            child: Text(l10n.pwResetUnderstood),
          ),
        ],
      ),
    );
  }

  /// Dialog: Neues Passwort aktiviert nach Reset-Ablauf
  Future<void> _showPasswordActivatedDialog() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outlined,
              color: widget.profile.preferredColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.pwResetNowActiveTitle,
                style: TextStyle(color: AppColors.paper),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.pwResetNowActiveMessage,
          style: TextStyle(
            color: AppColors.paper.withValues(alpha: 0.8),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.profile.preferredColor,
              foregroundColor: AppColors.onColor(widget.profile.preferredColor),
            ),
            child: Text(l10n.pwResetUnderstood),
          ),
        ],
      ),
    );
  }

  /// Zeigt Start-Dialog für Passwort-Reset
  /// Reihenfolge: (1) Warnung mit Sanduhr + Auge, (2) Passwort 2x, (3) Bestätigen
  Future<void> _showPasswordResetStartDialog() async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? passwordMismatchError;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateLocal) => AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[400],
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).pwResetStartTitle,
                  style: TextStyle(color: AppColors.paper),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Warnung mit Piktogrammen
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.hourglass_bottom,
                            color: Colors.orange[300],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).pwResetVisibleToAll,
                              style: TextStyle(
                                color: Colors.orange[200],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            color: Colors.orange[300],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Frist: ${widget.profile.resetDurationHours ?? 24} Stunden',
                              style: TextStyle(
                                color: Colors.orange[200],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Passwort-Eingabe
                AuroraTextField(
                  label: AppLocalizations.of(context).pwResetNewPassword,
                  controller: newPasswordController,
                  obscure: true,
                  hint: AppLocalizations.of(context).fieldPasswordEnterHint,
                  // Ohne diese Zeile bliebe die Starttaste grau, bis das
                  // zweite Feld angefasst wird.
                  onChanged: (_) {
                    setStateLocal(() {
                      final gleich =
                          confirmPasswordController.text.isEmpty ||
                          newPasswordController.text ==
                              confirmPasswordController.text;
                      passwordMismatchError = gleich
                          ? null
                          : AppLocalizations.of(
                              context,
                            ).validationPasswordMismatch;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Passwort wiederholen
                AuroraTextField(
                  label: AppLocalizations.of(context).fieldPasswordConfirmHint,
                  controller: confirmPasswordController,
                  obscure: true,
                  hint: AppLocalizations.of(context).fieldPasswordConfirmHint,
                  errorText: passwordMismatchError,
                  onChanged: (_) {
                    setStateLocal(() {
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        passwordMismatchError =
                            AppTexts.current.validationPasswordMismatch;
                      } else {
                        passwordMismatchError = null;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Abbrechen',
                style: TextStyle(color: AppColors.paper),
              ),
            ),
            ElevatedButton(
              // Beide Felder müssen gefüllt und gleich sein — sonst startet
              // eine Frist auf ein Passwort, das niemand bestätigt hat.
              onPressed:
                  passwordMismatchError == null &&
                      newPasswordController.text.isNotEmpty &&
                      confirmPasswordController.text ==
                          newPasswordController.text
                  ? () async {
                      Navigator.pop(context);
                      await _dataEntry.startPasswordReset(
                        widget.profile.id,
                        newPasswordController.text,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.profile.preferredColor,
                foregroundColor: AppColors.onColor(
                  widget.profile.preferredColor,
                ),
              ),
              child: Text(AppLocalizations.of(context).pwResetStart),
            ),
          ],
        ),
      ),
    );
  }

  /// Zeigt Zustand "Reset läuft" mit Restzeit, kein Abbruch-Button
  /// R4: Abbruch nur via Login. R6: Hinweis dass erneuter Start die Frist neu beginnt
  Future<void> _showPasswordResetActiveDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true, // Erlaubt Tappen außerhalb zum Schließen
      builder: (context) => StatefulBuilder(
        builder: (context, setStateLocal) {
          // Widget-Tick für Restzeit-Aktualisierung
          if (!widget.profile.hasActiveReset) {
            Navigator.pop(context);
            return const SizedBox.shrink();
          }

          final now = DateTime.now();
          final endTime = widget.profile.resetEndsAt;
          final remaining = endTime != null
              ? endTime.difference(now)
              : Duration.zero;
          final isExpired = remaining.isNegative;

          return AlertDialog(
            backgroundColor: const Color(0xFF1F1F1F),
            title: Row(
              children: [
                Icon(
                  Icons.hourglass_bottom,
                  color: widget.profile.preferredColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).pwResetRunningShort,
                    style: TextStyle(color: AppColors.paper),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isExpired) ...[
                  Text(
                    'Restzeit: ${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m',
                    style: TextStyle(
                      color: widget.profile.preferredColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).pwResetRestartResetsTimer,
                      style: TextStyle(
                        color: Colors.amber[200],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    AppLocalizations.of(context).pwResetExpired,
                    style: TextStyle(
                      color: Colors.green[300],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).pwResetActivatedAtNextLogin,
                    style: TextStyle(
                      color: AppColors.paper.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (!isExpired)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _showPasswordResetStartDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.profile.preferredColor,
                    foregroundColor: AppColors.onColor(
                      widget.profile.preferredColor,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context).pwResetRestart),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context).actionClose,
                  style: TextStyle(color: AppColors.paper),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentProfile = _dataEntry.getActiveProfile();
    final isCurrentProfile = currentProfile?.id == widget.profile.id;
    final requiresLogin =
        !isCurrentProfile || widget.requireCurrentProfileLogin;
    final canEdit = isCurrentProfile && !widget.requireCurrentProfileLogin;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: AlertDialog(
        scrollable: true, // Ermöglicht Scrollen bei kleinen Bildschirmen
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: widget.profile.preferredColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            // Avatar
            ProfileAvatar(
              profile: widget.profile,
              size: 48,
              avatarSize: AvatarSize.small,
              showName: false,
              showGlow: true, // Glow-Effekt für Dialog-Avatar
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.profile.name,
                    style: const TextStyle(
                      color: AppColors.paper,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.profile.age != null)
                    Text(
                      AppLocalizations.of(
                        context,
                      ).profileAgeYears(widget.profile.age!),
                      style: TextStyle(
                        color: AppColors.paper.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info wenn aktuelles Profil
            if (isCurrentProfile && !widget.requireCurrentProfileLogin)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.profileCurrentlyActive,
                      style: TextStyle(
                        color: Colors.green[200],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Reset-Zustand dieses Profils. Die Frist steht am Profil, nicht
            // mehr in einem globalen Slot — deshalb reicht das Profilobjekt.
            Builder(
              builder: (context) {
                final profile =
                    _dataEntry.getProfileById(widget.profile.id) ??
                    widget.profile;
                if (!profile.hasActiveReset) {
                  return const SizedBox.shrink();
                }

                // Abgelaufen heißt: das neue Passwort greift beim nächsten
                // Login von selbst. Es gibt nichts mehr zu bestätigen.
                final canReset = profile.isResetExpired;
                final remaining = profile.resetEndsAt!.difference(
                  DateTime.now(),
                );
                final timeText = remaining.inHours > 0
                    ? '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m'
                    : remaining.inMinutes > 0
                    ? '${remaining.inMinutes}m ${remaining.inSeconds.remainder(60)}s'
                    : '${remaining.inSeconds.clamp(0, 60)}s';

                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: (canReset ? Colors.green : Colors.orange).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (canReset ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            canReset ? Icons.check_circle_outline : Icons.timer,
                            color: canReset
                                ? Colors.green[400]
                                : Colors.orange[400],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  canReset
                                      ? l10n.pwResetReadyTitle
                                      : l10n.pwResetRunningTitle,
                                  style: TextStyle(
                                    color: canReset
                                        ? Colors.green[200]
                                        : Colors.orange[200],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  canReset
                                      ? l10n.pwResetCanActivateNow
                                      : 'Verbleibende Zeit: $timeText',
                                  style: TextStyle(
                                    color:
                                        (canReset
                                                ? Colors.green
                                                : Colors.orange)
                                            .withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Bei einer Sitzungssperre muss auch der vorher aktive Anteil
            // erneut sein Passwort eingeben.
            if (widget.profile.hasPassword && requiresLogin) ...[
              Text(
                l10n.profilePasswordProtected,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.paper.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              AuroraTextField(
                label: l10n.profilePasswordLabel,
                controller: _passwordController,
                obscure: true,
                icon: Icons.lock,
                errorText: _errorMessage,
                onSubmitted: (_) => _switchToProfile(),
              ),
              const SizedBox(height: 8),
            ],

            // Einstieg in den Reset — nur für Profile mit Passwort.
            if (widget.profile.hasPassword)
              Builder(
                builder: (context) {
                  final profile =
                      _dataEntry.getProfileById(widget.profile.id) ??
                      widget.profile;
                  final laeuft = profile.hasActiveReset;

                  return Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: laeuft
                          ? _showPasswordResetActiveDialog
                          : _showPasswordResetStartDialog,
                      icon: Icon(
                        laeuft ? Icons.hourglass_top : Icons.lock_reset,
                        size: 16,
                      ),
                      label: Text(
                        laeuft
                            ? l10n.pwResetRunningShort
                            : AppLocalizations.of(
                                context,
                              ).pwResetForgotPassword,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange[300],
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),

            // Fehler-Nachricht
            if (_errorMessage != null && !widget.profile.hasPassword)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red[300],
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Bei einer Sitzungssperre bestätigt auch der bisher aktive
            // Anteil sich erneut über diese Aktion.
            if (requiresLogin)
              Container(
                decoration: BoxDecoration(
                  gradient: kAuroraRainbowGradient,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.profile.preferredColor,
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _switchToProfile,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Der Verlauf trägt die Fläche, die Schrift steht
                          // ruhig darauf.
                          //
                          // Vorher wurde der Text zweimal gezeichnet: als 3 px
                          // schwarze Kontur und darüber mit einem invertierten
                          // Regenbogen gefüllt — auf einem Regenbogen-Hintergrund.
                          // Farbe auf Farbe mit Kontur ergibt keinen Kontrast,
                          // sondern Unruhe, und das an der wichtigsten Aktion
                          // des Dialogs.
                          // Der Knopf nennt den Anteil.
                          //
                          // Hier stand „Profil wechseln" — auch beim allerersten
                          // Start, wenn man in keinem Profil war und also nichts
                          // zu wechseln hatte. „Weiter als Mina" stimmt in beiden
                          // Fällen und sagt zugleich, wohin man geht.
                          Text(
                            _isLoading
                                ? AppLocalizations.of(
                                    context,
                                  ).profileContinueInProgress
                                : AppLocalizations.of(
                                    context,
                                  ).profileContinueAs(widget.profile.name),
                            style: const TextStyle(
                              color: AppColors.inkDeep,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Button: Profil bearbeiten (nur wenn berechtigt)
            if (canEdit)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => ProfileEditScreen(
                        profile: widget.profile,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: Text(AppLocalizations.of(context).menuProfileEdit),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.paper,
                  side: BorderSide(
                    color: AppColors.paper.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            // Die Sprache dieses Anteils — hier, wo man ihn auswählt.
            //
            // In einem System sprechen nicht alle dieselbe Sprache. Wer sich
            // gleich anmeldet, soll seine vorfinden, ohne erst durch die
            // Einstellungen zu gehen und sie damit allen anderen zu setzen.
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _changeLanguage,
              icon: const Icon(Icons.language),
              label: Text(
                languageNameFor(_language) ?? l10n.languageFollowApp,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.paper,
                side: BorderSide(
                  color: AppColors.paper.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.actionClose,
              style: TextStyle(color: AppColors.paper),
            ),
          ),
        ],
      ),
    );
  }
}
