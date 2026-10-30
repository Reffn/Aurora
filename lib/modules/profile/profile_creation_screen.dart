import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:dis_app/modules/profile/widgets/profile_age_section.dart';
import 'package:dis_app/modules/profile/widgets/profile_color_section.dart';
import 'package:dis_app/modules/profile/widgets/profile_identity_section.dart';
import 'package:dis_app/services/permission_preset_service.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/bottom_action_bar.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Ein neues Profil anlegen — seit 3.0.25 in zwei Schritten.
///
/// 1. Name, Bild und Farbe (die Farbe ist vorausgewählt).
/// 2. Alter und, wer mag, ein Passwort.
///
/// Bis 3.0.24 waren es fünf: eine Einleitung („Wer möchte sich
/// vorstellen?“), dann Name und Bild, Farbe, Alter, Passwort — je eine Seite.
/// Zusammen mit der Vorstellung davor und den Begrüßungsseiten danach waren
/// es rund sechzehn Schirme bis zur App. Am Gerät entschieden: kurz.
///
/// Wird das **erste** Profil angelegt, wird es sofort aktiv: Die Startkette
/// in `main.dart` wechselt dann von selbst auf den Hauptschirm, ohne
/// Startauswahl und ohne „Weiter als …“. Jedes weitere Profil kommt über
/// „Neues Profil“ und führt wie bisher zurück.
class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  DataEntry? _dataEntry;

  late PageController _pageController;
  int _currentPage = 0;

  Color _selectedColor = Colors.blue;
  Offset? _selectedColorPosition; // Normalisierte Position im ColorWheelPicker

  /// Abstand am Ende jeder Seite zur Leiste darunter.
  ///
  /// Die Leiste liegt außerhalb des Scrollbereichs und nimmt ihren Platz selbst
  /// ein, deshalb genügt hier ein normaler Abstand.
  static const double _navigationBarHeight = 24;
  double _selectedAge = 25;
  bool _isLoading = false;
  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    // Safe Access: Prüfe ob Service verfügbar ist (Deferred Init abgeschlossen)
    if (getIt.isRegistered<DataEntry>()) {
      _dataEntry = getIt<DataEntry>();
    }
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  /// Gibt automatische Permissions basierend auf Alter zurück
  List<Permission> _getPermissionsByAge(int age) {
    final presetService = getIt<PermissionPresetService>();

    // Kind-Profil (< 8 Jahre) oder Standard-Profil (≥ 8 Jahre)
    final presetName = age < 8 ? 'child' : 'standard';
    final permissionStrings = presetService.getPermissionsForPreset(presetName);

    // Konvertiere String-Liste zu Permission-Enum-Liste
    return permissionStrings
        .map(Permission.fromString)
        .whereType<Permission>()
        .toList();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Prüfe ob Name bereits existiert, auch bei pausierten Anteilen: Sonst
    // stünden nach dem Wiederaufnehmen zwei gleichnamige in der Auswahl.
    final trimmedName = _nameController.text.trim();
    final nameExists = _dataEntry!.getAllProfiles().any(
      (p) => p.name.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (nameExists) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: AppLocalizations.of(context).profileNameExists,
          type: SnackBarType.warning,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isFirstProfile = _dataEntry!.getProfiles().isEmpty;
      // Gar keins, auch kein pausiertes: Nur dann ist dieser Schirm der
      // Startschirm der App und nicht eine Route über der Auswahl.
      final keinesVorher = _dataEntry!.getAllProfiles().isEmpty;

      final avatarPath = _selectedAvatarPath;

      final profilePermissions = _getPermissionsByAge(
        _selectedAge.toInt(),
      ).map((p) => p.persistedValue).toList();

      String? passwordHash;
      final password = _passwordController.text.trim();
      if (password.isNotEmpty) {
        passwordHash = Profile.hashPassword(password);
      }

      final profile = Profile.withColor(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        avatarPath: avatarPath,
        preferredColor: _selectedColor,
        age: _selectedAge.toInt(),
        createdAt: DateTime.now(),
        isAdmin: isFirstProfile,
        permissions: profilePermissions,
        passwordHash: passwordHash,
        colorPickerPositionX: _selectedColorPosition?.dx,
        colorPickerPositionY: _selectedColorPosition?.dy,
      );

      // Safe Access: Wenn DataEntry noch nicht verfügbar, warte darauf
      if (_dataEntry == null) {
        // Warte bis DataEntry registriert ist
        while (!getIt.isRegistered<DataEntry>()) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        _dataEntry = getIt<DataEntry>();
      }

      await _dataEntry!.createProfile(profile);

      if (keinesVorher) {
        // Das erste Profil wird gleich aktiv. Dieser Schirm ist dann `home`,
        // nichts liegt über ihm: Die Startkette in `main.dart` sieht ein
        // aktives Profil und baut den Hauptschirm — keine Startauswahl, kein
        // „Weiter als …“. Hat es ein Passwort, ist das in Ordnung: Es wurde
        // eben erst getippt.
        //
        // Jeder spätere Start löscht `active_profile_id` weiterhin und
        // beginnt in der Auswahl; die Sperre bleibt, wie sie ist.
        await _dataEntry!.changeActiveProfile(profile);
      } else if (mounted) {
        // Über „Neues Profil“: zurück zur Auswahl.
        Navigator.pop(context);
      }
    } catch (e) {
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

  /// Index der Seite, auf der der Profilname eingegeben wird.
  static const int _identityPageIndex = 0;

  /// Die letzte Seite: Alter und Passwort. Ihr Knopf legt das Profil an.
  static const int _lastPageIndex = 1;

  void _nextPage() {
    // Der Name ist Pflicht. Ohne diese Prüfung blättert man vier Seiten weiter
    // und erfährt erst beim Speichern, dass er fehlt — dann als technische
    // Ausnahme aus der Datenschicht ("Invalid argument(s)"), ohne Weg zurück
    // zum betroffenen Feld.
    if (_currentPage == _identityPageIndex &&
        _nameController.text.trim().isEmpty) {
      // Löst den Validator am Namensfeld aus, der den Hinweis direkt dort zeigt.
      _formKey.currentState?.validate();
      // Und setzt den Fokus dorthin: Der Hinweis steht oben am Feld, der Knopf
      // unten am Rand. Ohne den Sprung wirkt ein Tippen auf „Weiter" folgenlos.
      _nameFocusNode.requestFocus();
      return;
    }

    if (_currentPage < _lastPageIndex) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Letzte Seite - Profil erstellen
      _saveProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          bottom: false,
          // Leiste und Inhalt liegen untereinander, nicht übereinander.
          //
          // Vorher baute jede Seite Indikator und Knopf selbst,
          // innerhalb ihres Scroll-Inhalts — dadurch konnte jeder Seiteninhalt
          // den Knopf unter den Bildschirmrand schieben, bei der Farbseite war
          // er nur durch Scrollen erreichbar.
          //
          // Als Overlay im Stack wäre es nicht besser: Dann kennt der
          // Scrollbereich die Leiste nicht und schiebt das fokussierte Feld nur
          // bis zu seinem eigenen Rand — hinter die Leiste. Genau deshalb steht
          // sie hier als Geschwister im Column.
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Zwei Seiten: wer, dann wie alt und wie geschützt.
                    Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          // Die Tastatur vom Namensfeld bleibt sonst offen
                          // und verdeckt die nächste Seite — auf der
                          // Farbseite lag das halbe Farbrad darunter.
                          FocusScope.of(context).unfocus();
                          setState(() => _currentPage = index);
                        },
                        children: [
                          _buildIdentityPage(),
                          _buildAgePage(),
                        ],
                      ),
                    ),

                    // Zurück-Button (nur wenn nicht Erst-Erstellung)
                    if (_dataEntry!.getProfiles().isNotEmpty)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.paper,
                            size: 28,
                          ),
                          onPressed: () {
                            if (_currentPage > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),

              BottomActionBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPageIndicator(),
                    const SizedBox(height: 24),
                    _buildNavigationButton(
                      _currentPage < _lastPageIndex
                          ? '${AppLocalizations.of(context).actionContinue} →'
                          : AppLocalizations.of(
                              context,
                            ).profileActionCreateProfile,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper: Page Indicator (wiederverwendbar für alle Pages)
  Widget _buildPageIndicator() {
    return OnboardingPageIndicator(
      currentPage: _currentPage,
      totalPages: _lastPageIndex + 1,
      activeColor: const Color(0xFFFFB6C1), // Pastell Rosa
      inactiveColor: const Color(0xFF4A4458), // Warmes Dunkelgrau
    );
  }

  /// Helper: Navigation Button (wiederverwendbar für alle Pages)
  Widget _buildNavigationButton(String buttonText) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFB6C1), // Pastell Rosa
            Color(0xFF87CEEB), // Pastell Blau
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB6C1).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  /// Seite 1: Name, Bild und Farbe.
  Widget _buildIdentityPage() {
    return ColoredBox(
      color: AppColors.ink,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 32,
            right: 32,
            top: 72,
            bottom: 28,
          ),
          child: Column(
            children: [
              _pageHeader(
                symbol: _selectedAvatarPath != null
                    ? ClipOval(
                        child: ProfileImageWidget(
                          avatarPath: _selectedAvatarPath,
                          size: 84,
                          // Hier stand `SizedBox.shrink()`: laedt das gerade
                          // gewaehlte Bild nicht, blieb die Kopfzeile leer und
                          // niemand erfuhr, dass etwas fehlgeschlagen ist.
                          // Der Zweig darunter behaelt sein 👤 — das ist der
                          // gewollte Platzhalter, wenn noch nichts gewaehlt ist.
                          placeholderIcon: Icons.person,
                        ),
                      )
                    : const Text('👤', style: TextStyle(fontSize: 40)),
                title: AppLocalizations.of(context).profileWhoAreYou,
              ),
              _pageDescription(
                AppLocalizations.of(context).profileWhoAreYouDescription,
              ),

              const SizedBox(height: 32),

              // Identity Section
              ProfileIdentitySection(
                nameController: _nameController,
                nameFocusNode: _nameFocusNode,
                selectedColor: _selectedColor,
                selectedAvatarPath: _selectedAvatarPath,
                onAvatarPathSelected: (avatarPath) {
                  setState(() => _selectedAvatarPath = avatarPath);
                },
                passwordController: _passwordController,
                passwordConfirmController: _passwordConfirmController,
                showPasswordFields: false,
              ),

              // Die Farbe auf derselben Seite. Vorausgewählt ist eine, damit
              // niemand hier hängen bleibt; ändern lässt sie sich später in
              // „Profil bearbeiten“.
              const SizedBox(height: 32),
              _sectionTitle(
                AppLocalizations.of(context).profileColorTitle,
                AppLocalizations.of(context).profileColorDescription,
              ),
              const SizedBox(height: 16),
              ProfileColorSection(
                selectedColor: _selectedColor,
                onColorChanged: (color, position) {
                  setState(() {
                    _selectedColor = color;
                    _selectedColorPosition = position;
                  });
                },
                existingProfiles: _dataEntry!.getProfiles(),
              ),

              const SizedBox(height: 40),

              // Platz für die feste Leiste am unteren Rand
              const SizedBox(height: _navigationBarHeight),
            ],
          ),
        ),
      ),
    );
  }

  /// Kopfzeile einer Assistentenseite: Sinnbild links, Text rechts.
  ///
  /// Vorher stand das Sinnbild als 120-Pixel-Kreis mittig über Titel und
  /// Beschreibung. Zusammen mit dem Abstand darüber schob das den eigentlichen
  /// Inhalt — Namensfeld, Farbrad, Altersregler — bis weit unter die Mitte des
  /// Schirms, auf kleinen Geräten aus dem Bild heraus. Nebeneinander braucht
  /// derselbe Kopf rund 250 Pixel weniger.
  ///
  /// Beide Seiten teilen sich diesen Aufbau.
  Widget _pageHeader({
    required Widget symbol,
    required String title,
    List<Color> gradient = const [Color(0xFFFFB6C1), Color(0xFF87CEEB)],
    bool framed = true,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          height: 84,
          child: framed
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradient),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(child: symbol),
                )
              : Center(child: symbol),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.paperBright,
            ),
          ),
        ),
      ],
    );
  }

  /// Der erklärende Satz unter der Kopfzeile.
  ///
  /// Steht bewusst über die volle Breite und nicht neben dem Sinnbild: Die
  /// Sätze sind lang, und in einer halben Spalte brachen sie auf sieben
  /// Zeilen um, während neben ihnen leerer Raum blieb.
  Widget _pageDescription(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE8D4C0),
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  /// Seite 2: Alter und Passwort.
  Widget _buildAgePage() {
    return ColoredBox(
      color: AppColors.ink,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 32,
            right: 32,
            top: 72,
            bottom: 28,
          ),
          child: Column(
            children: [
              _pageHeader(
                symbol: const Text('🎂', style: TextStyle(fontSize: 40)),
                title: AppLocalizations.of(context).profileAgeTitle,
                gradient: const [Color(0xFFFFDAB9), Color(0xFFFFF4A3)],
              ),
              _pageDescription(
                AppLocalizations.of(context).profileAgeDescription,
              ),

              const SizedBox(height: 32),

              // Age Section
              ProfileAgeSection(
                selectedAge: _selectedAge,
                selectedColor: _selectedColor,
                onAgeChanged: (value) {
                  setState(() => _selectedAge = value);
                },
              ),

              const SizedBox(height: 24),

              // Permission Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _selectedAge < 8
                        ? [
                            Colors.orange.withValues(alpha: 0.15),
                            Colors.orange.withValues(alpha: 0.08),
                          ]
                        : [
                            Colors.green.withValues(alpha: 0.15),
                            Colors.green.withValues(alpha: 0.08),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedAge < 8
                        ? Colors.orange.withValues(alpha: 0.3)
                        : Colors.green.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _selectedAge < 8 ? Icons.child_care : Icons.check_circle,
                      color: _selectedAge < 8 ? Colors.orange : Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAge < 8
                                ? AppLocalizations.of(context).profileModeChild
                                : AppLocalizations.of(
                                    context,
                                  ).profileModeFullAccess,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _selectedAge < 8
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedAge < 8
                                ? AppLocalizations.of(
                                    context,
                                  ).profileModeChildDescription
                                : AppLocalizations.of(
                                    context,
                                  ).profileModeFullDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(
                                0xFFE8D4C0,
                              ).withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Das Passwort auf derselben Seite, nach dem Alter: Die
              // Rechte-Vorlage hängt am Alter, nicht am Passwort — beides
              // auf einer Seite ändert daran nichts.
              const SizedBox(height: 32),
              _sectionTitle(
                AppLocalizations.of(context).profileSecurityTitle,
                AppLocalizations.of(context).profileSecurityDescription,
              ),
              const SizedBox(height: 16),

              // Password Fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Password Field
                  AuroraTextField(
                    label: AppLocalizations.of(context).fieldPassword,
                    controller: _passwordController,
                    obscure: true,
                    icon: Icons.lock,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 4) {
                        return AppLocalizations.of(
                          context,
                        ).validationPasswordLength;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Confirm Field
                  AuroraTextField(
                    label: AppLocalizations.of(context).fieldPasswordConfirm,
                    controller: _passwordConfirmController,
                    obscure: true,
                    icon: Icons.lock_outline,
                    validator: (value) {
                      if (_passwordController.text.isNotEmpty) {
                        if (value != _passwordController.text) {
                          return AppLocalizations.of(
                            context,
                          ).validationPasswordMismatch;
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Info Text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF87CEEB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF87CEEB).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF87CEEB),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).profilePasswordOptionalInfo,
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(
                                0xFFE8D4C0,
                              ).withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Platz für die feste Leiste am unteren Rand
              const SizedBox(height: _navigationBarHeight),
            ],
          ),
        ),
      ),
    );
  }

  /// Überschrift eines zweiten Abschnitts auf derselben Seite: kleiner als
  /// die Kopfzeile, damit die Seite einen Anfang hat und nicht zwei.
  Widget _sectionTitle(String title, String description) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.paperBright,
            ),
          ),
          _pageDescription(description),
        ],
      ),
    );
  }
}
