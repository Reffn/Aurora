import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/widgets/profile_age_section.dart';
import 'package:dis_app/modules/profile/widgets/profile_color_section.dart';
import 'package:dis_app/modules/profile/widgets/profile_identity_section.dart';
import 'package:dis_app/modules/profile/widgets/profile_reset_frist_section.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/form_action_button.dart';
import 'package:flutter/material.dart';

/// Screen zum Bearbeiten eines existierenden Profils
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({
    required this.profile,
    super.key,
  });

  final Profile profile;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordConfirmController;
  final _dataEntry = getIt<DataEntry>();

  late Color _selectedColor;
  Offset? _selectedColorPosition; // Normalisierte Position im ColorWheelPicker
  late double _selectedAge;
  bool _isLoading = false;
  String? _selectedAvatarPath;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late int _resetFristStunden;

  @override
  void initState() {
    super.initState();

    // Initialisiere Controller mit bestehenden Werten
    _nameController = TextEditingController(text: widget.profile.name);
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();

    _selectedColor = widget.profile.preferredColor;
    _selectedColorPosition = widget.profile.colorPickerPositionNormalized;
    // Das vorhandene Bild gehoert in die Flaeche, bevor jemand etwas aendert.
    //
    // Diese Zeile fehlte. Farbe, Farbposition, Alter und Reset-Frist wurden
    // vorbelegt, der Avatar nicht -- also zeigte „Profil bearbeiten" nie das
    // Bild, das das Profil schon hat, sondern den Rueckfall. Beim Speichern
    // fiel es nicht auf, weil `_selectedAvatarPath ?? widget.profile.avatarPath`
    // den alten Pfad zurueckholte: der Fehler war sichtbar, aber folgenlos --
    // und damit die Sorte, die lange bleibt.
    _selectedAvatarPath = widget.profile.avatarPath;
    _selectedAge = widget.profile.age?.toDouble() ?? 25;
    _resetFristStunden = widget.profile.resetDurationHours ?? 24;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  /// Ob seit dem Öffnen etwas am Profil verändert wurde.
  ///
  /// Wird beim Zurückgehen ausgewertet, nicht beim Bauen: Ein beim Bauen
  /// festgehaltener Wert wäre schon veraltet, sobald jemand tippt.
  bool _hasUnsavedChanges() {
    if (_nameController.text.trim() != widget.profile.name) return true;
    // Ein angefangenes Passwort zählt, auch wenn die Bestätigung noch fehlt —
    // gerade der halb fertige Zustand ist der, den niemand verlieren will.
    if (_passwordController.text.isNotEmpty) return true;
    if (_passwordConfirmController.text.isNotEmpty) return true;
    if (_selectedColor != widget.profile.preferredColor) return true;
    if (_selectedAge.toInt() != (widget.profile.age ?? 25)) return true;
    if (_selectedAvatarPath != null &&
        _selectedAvatarPath != widget.profile.avatarPath) {
      return true;
    }
    if (_resetFristStunden != (widget.profile.resetDurationHours ?? 24)) {
      return true;
    }
    return false;
  }

  /// Dasselbe Drei-Wege-Muster wie in Kalender, Medikamenten, Tagebuch,
  /// Kontakten und Finder. Das Profil war die einzige Ausnahme.
  ///
  /// Rückgabe: ob das Verlassen erlaubt ist.
  Future<bool> _showUnsavedChangesDialog() async {
    final result = await ConfirmationDialog.showUnsavedChanges(
      context: context,
    );

    if (result == ConfirmationResult.confirm) {
      if (_formKey.currentState!.validate()) {
        await _saveProfile();
        // `_saveProfile` schließt den Bildschirm bei Erfolg selbst.
        return false;
      }
      // Die Eingabe trägt noch nicht — hier bleiben, sonst wäre die
      // Speicherabsicht folgenlos verpufft.
      return false;
    }

    return result == ConfirmationResult.discard;
  }

  /// Der Weg für den sichtbaren Pfeil.
  ///
  /// Er rief früher unmittelbar `Navigator.pop` und lief damit an jedem
  /// `PopScope` vorbei. Beide Rückwege müssen durch dieselbe Prüfung.
  Future<void> _handleBack() async {
    if (!_hasUnsavedChanges()) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final darfGehen = await _showUnsavedChangesDialog();
    if (darfGehen && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Avatar-Pfad übernehmen falls geändert
      // Entweder Asset-Pfad oder bereits gespeicherter File-Pfad
      var avatarPath = _selectedAvatarPath ?? widget.profile.avatarPath;

      // Passwort-Hash (nur wenn neues Passwort gesetzt)
      var passwordHash = widget.profile.passwordHash;
      final password = _passwordController.text.trim();
      if (password.isNotEmpty) {
        passwordHash = Profile.hashPassword(password);
        debugPrint('New password set for profile');
      }

      final updatedProfile = widget.profile.copyWith(
        name: _nameController.text.trim(),
        avatarPath: avatarPath,
        preferredColor: _selectedColor,
        age: _selectedAge.toInt(),
        // Permissions werden NICHT geändert - nur Admin kann das im PermissionsManager
        passwordHash: passwordHash,
        colorPickerPositionX: _selectedColorPosition?.dx,
        colorPickerPositionY: _selectedColorPosition?.dy,
        // Wirkt nur auf künftige Resets — ein laufender behält sein Ende.
        resetDurationHours: _resetFristStunden,
      );

      debugPrint('Updating profile: ${updatedProfile.name}');
      await _dataEntry.updateProfile(updatedProfile);
      debugPrint('Profile updated successfully');

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        showCustomSnackBar(
          context,
          message: AppLocalizations.of(context).errorGeneric(e.toString()),
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Immer false: Ob gegangen werden darf, entscheidet die Prüfung unten.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.ink,
              AppColors.inkDeep,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        // Beschriftet, weil Android den Pfeil sonst als
                        // namenlosen Button meldet und TalkBack ihn nur als
                        // „Schaltfläche" ansagt.
                        tooltip: AppLocalizations.of(context).actionBack,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.paper,
                        ),
                        onPressed: _handleBack,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Header
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo_rainbow.png',
                            height: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context).profileEditTitle,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).profileEditSubtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.paper.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Card 1: Identität
                    _buildCard(
                      title: AppLocalizations.of(
                        context,
                      ).profileSectionIdentity,
                      child: ProfileIdentitySection(
                        nameController: _nameController,
                        selectedColor: _selectedColor,
                        selectedAvatarPath: _selectedAvatarPath,
                        onAvatarPathSelected: (avatarPath) {
                          setState(() => _selectedAvatarPath = avatarPath);
                        },
                        passwordController: _passwordController,
                        passwordConfirmController: _passwordConfirmController,
                        isEditMode: true,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card 2: Alter
                    _buildCard(
                      title: AppLocalizations.of(context).profileSectionAge,
                      child: ProfileAgeSection(
                        selectedAge: _selectedAge,
                        selectedColor: _selectedColor,
                        onAgeChanged: (value) {
                          setState(() {
                            _selectedAge = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card 3: Farbe
                    _buildCard(
                      title: AppLocalizations.of(context).profileSectionColor,
                      child: ProfileColorSection(
                        selectedColor: _selectedColor,
                        onColorChanged: (color, position) {
                          setState(() {
                            _selectedColor = color;
                            _selectedColorPosition = position;
                          });
                        },
                        existingProfiles: _dataEntry.getProfiles(),
                        currentProfileId: widget.profile.id,
                      ),
                    ),

                    // Card 4: Wartefrist beim Zurücksetzen — nur im eigenen,
                    // passwortgeschützten Profil sichtbar.
                    if (widget.profile.hasPassword &&
                        _dataEntry.getActiveProfile()?.id ==
                            widget.profile.id) ...[
                      const SizedBox(height: 20),
                      _buildCard(
                        title: AppLocalizations.of(
                          context,
                        ).resetWaitingPeriodTitle,
                        child: ProfileResetFristSection(
                          gewaehlteStunden: _resetFristStunden,
                          profilFarbe: _selectedColor,
                          onFristChanged: (stunden) {
                            setState(() => _resetFristStunden = stunden);
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Speichern Button
                    FormActionButton(
                      label: AppLocalizations.of(
                        context,
                      ).profileActionSaveChanges,
                      loading: _isLoading,
                      backgroundColor: AppColors.paper,
                      foregroundColor: AppColors.ink,
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.paper,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
