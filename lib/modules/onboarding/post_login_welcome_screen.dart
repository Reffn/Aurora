import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/onboarding/widgets/dismissable_onboarding_wrapper.dart';
import 'package:dis_app/modules/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:dis_app/modules/onboarding/widgets/post_login_welcome_page.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

/// Post-Login Welcome Screen - Stage 3 des Onboarding Systems
/// Zeigt personalisierte Willkommens-Seiten nach dem ersten Login eines Profils
/// Nur beim ersten Login für jedes Profil
class PostLoginWelcomeScreen extends StatefulWidget {
  const PostLoginWelcomeScreen({
    required this.profile,
    required this.onComplete,
    super.key,
  });

  final Profile profile;
  final VoidCallback onComplete;

  @override
  State<PostLoginWelcomeScreen> createState() => _PostLoginWelcomeScreenState();
}

class _PostLoginWelcomeScreenState extends State<PostLoginWelcomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildPages(AppLocalizations l10n) {
    final pages = <Widget>[];
    final dataEntry = getIt<DataEntry>();
    final otherProfiles = dataEntry
        .getProfiles()
        .where((p) => p.id != widget.profile.id)
        .toList();

    // Seite 1: Persönliche Begrüßung
    pages.add(_buildWelcomePage(l10n));

    // Seite 2: "Du bist nicht allein" (nur wenn andere Profile existieren)
    if (otherProfiles.isNotEmpty) {
      pages.add(_buildNotAlonePage(l10n, otherProfiles));
    }

    // Seite 3: Was du tun kannst (dynamische Permissions)
    pages
      ..add(_buildPermissionsPage(l10n))
      // Seite 4: Dein sicherer Raum
      ..add(_buildSafePlacePage(l10n));

    return pages;
  }

  Future<void> _dismissWelcome() async {
    final settingsBox = await Hive.openBox<dynamic>('settings');

    // Markiere für dieses Profil als übersprungen
    await settingsBox.put(
      'post_login_welcome_dismissed_${widget.profile.id}',
      true,
    );

    if (mounted) {
      widget.onComplete();
    }
  }

  void _nextPage(int totalPages) {
    if (_currentPage < totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Letzte Seite - markiere Welcome als gesehen und navigiere zu MainScreen
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _buildPages(l10n);

    return Scaffold(
      body: DismissableOnboardingWrapper(
        onDismiss: _dismissWelcome,
        child: Column(
          children: [
            // PageView mit dynamischen Seiten
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: pages,
              ),
            ),

            // Navigation-Bereich
            Container(
              color: AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    OnboardingPageIndicator(
                      currentPage: _currentPage,
                      totalPages: pages.length,
                      activeColor: const Color(0xFFFFB6C1), // Pastell Rosa
                      inactiveColor: const Color(
                        0xFF4A4458,
                      ), // Warmes Dunkelgrau
                    ),
                    const SizedBox(height: 12),
                    // Weiter Button
                    //
                    // `width` und die waagerechte Polsterung fehlten beide.
                    // Der Verlauf schrumpfte damit auf die Eigengröße des
                    // Knopfes, und `EdgeInsets.symmetric(vertical: 16)` lässt
                    // waagerecht null — „Weiter →" und „Los geht's! →" standen
                    // links und rechts über der farbigen Fläche. Im
                    // Pre-Onboarding steht dasselbe Wort korrekt, weil der
                    // Knopf dort über die volle Breite geht.
                    Container(
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
                            color: const Color(
                              0xFFFFB6C1,
                            ).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _nextPage(pages.length),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          _currentPage < pages.length - 1
                              ? l10n.onboardingNext
                              : l10n.onboardingLetsGo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seite 1: Persönliche Begrüßung mit Profil-Farbe
  Widget _buildWelcomePage(AppLocalizations l10n) {
    // Gradient mit Profil-Farbe
    final profileColor = widget.profile.preferredColor;
    final gradientColors = [
      profileColor.withValues(alpha: 0.8),
      profileColor.withValues(alpha: 0.4),
    ];

    return PostLoginWelcomePage(
      headline: l10n.onboardingHelloName(widget.profile.name),
      subline: l10n.onboardingGladYoureHere,
      description: l10n.onboardingWelcomeDescription,
      gradientColors: gradientColors,
      iconWidget: _buildProfileAvatar(),
    );
  }

  /// Seite 2: "Du bist nicht allein" (nur wenn andere Profile existieren)
  Widget _buildNotAlonePage(
    AppLocalizations l10n,
    List<Profile> otherProfiles,
  ) {
    return PostLoginWelcomePage(
      headline: l10n.onboardingNotAlone,
      description: l10n.onboardingNotAloneDescription,
      content: _buildOtherProfilesWidget(otherProfiles),
    );
  }

  /// Seite 3: Was du tun kannst (dynamische Permissions)
  Widget _buildPermissionsPage(AppLocalizations l10n) {
    final permissions = widget.profile.parsedPermissions;
    final isChild = widget.profile.age != null && widget.profile.age! < 8;

    // Gruppiere Permissions nach Features
    final features = _getFeatureList(l10n, permissions, isChild);

    return PostLoginWelcomePage(
      headline: l10n.onboardingWhatYouCanDo,
      description: isChild
          ? l10n.onboardingChildAccessDescription
          : l10n.onboardingAdultAccessDescription,
      bulletPoints: features,
    );
  }

  /// Seite 4: Dein sicherer Raum
  Widget _buildSafePlacePage(AppLocalizations l10n) {
    return PostLoginWelcomePage(
      icon: Icons.shield,
      headline: l10n.onboardingSafeSpace,
      description: l10n.onboardingSafeSpaceDescription,
      subline: l10n.onboardingHaveFun,
    );
  }

  /// Profil-Avatar Widget
  Widget _buildProfileAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFFFB6C1,
            ).withValues(alpha: 0.4), // Pastell Rosa
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(
              0xFF87CEEB,
            ).withValues(alpha: 0.3), // Pastell Blau
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: ProfileImageWidget(
          avatarPath: widget.profile.avatarPath,
          size: 100,
          profileName: widget.profile.name,
          profileColor: widget.profile.preferredColor,
        ),
      ),
    );
  }

  /// Widget mit anderen Profil-Avataren
  Widget _buildOtherProfilesWidget(List<Profile> otherProfiles) {
    // Zeige max. 4 Profile
    final displayProfiles = otherProfiles.take(4).toList();

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: displayProfiles.map((profile) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: profile.preferredColor,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: ProfileImageWidget(
                      avatarPath: profile.avatarPath,
                      size: 60,
                      profileName: profile.name,
                      profileColor: profile.preferredColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: Text(
                    profile.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Erstellt Feature-Liste basierend auf Permissions
  List<String> _getFeatureList(
    AppLocalizations l10n,
    List<Permission> permissions,
    bool isChild,
  ) {
    final features = <String>[];

    if (isChild) {
      // Kind-Profil: Einfache Liste
      if (permissions.contains(Permission.viewChatTab)) {
        features.add(l10n.onboardingFeatureChatChild);
      }
      if (permissions.contains(Permission.viewDiaryTab)) {
        features.add(l10n.onboardingFeatureDiaryChild);
      }
      if (permissions.contains(Permission.viewGamesTab)) {
        features.add(l10n.onboardingFeatureGamesChild);
      }
      if (permissions.contains(Permission.viewTimelineTab)) {
        features.add(l10n.onboardingFeatureTimelineChild);
      }
    } else {
      // Erwachsenen-Profil: Gruppierte Features
      if (permissions.contains(Permission.viewChatTab)) {
        features.add(l10n.onboardingFeatureChat);
      }
      if (permissions.contains(Permission.viewCalendarTab)) {
        features.add(l10n.onboardingFeatureCalendar);
      }
      if (permissions.contains(Permission.viewContactsTab)) {
        features.add(l10n.onboardingFeatureContacts);
      }
      if (permissions.contains(Permission.viewMedicationTab)) {
        features.add(l10n.onboardingFeatureMedication);
      }
      if (permissions.contains(Permission.viewDiaryTab)) {
        features.add(l10n.onboardingFeatureDiary);
      }
      if (permissions.contains(Permission.viewFinderTab)) {
        features.add(l10n.onboardingFeatureFinder);
      }
      if (permissions.contains(Permission.viewEmergencyTab)) {
        features.add(l10n.onboardingFeatureEmergency);
      }
      if (permissions.contains(Permission.viewMantrasTab)) {
        features.add(l10n.onboardingFeatureMantras);
      }
    }

    // Fallback wenn keine Features
    if (features.isEmpty) {
      features.add(l10n.onboardingFeatureChatBasic);
    }

    return features;
  }
}
