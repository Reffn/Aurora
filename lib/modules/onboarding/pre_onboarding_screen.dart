import 'dart:async';
import 'dart:math' as math;

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/startup_locale.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/modules/onboarding/widgets/dismissable_onboarding_wrapper.dart';
import 'package:dis_app/modules/onboarding/widgets/feature_carousel_page.dart';
import 'package:dis_app/modules/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:dis_app/modules/onboarding/widgets/pre_onboarding_page.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

/// Pre-Onboarding Screen - Stage 1 des Onboarding Systems
/// Zeigt 5 Einführungs-Seiten vor dem ersten Profil:
/// 1. Willkommen (mit Rainbow "Aurora")
/// 2. Privacy First
/// 3. Feature-Carousel (horizontal wischbar)
/// 4. Multi-Profile System
/// 5. Let's Go
/// Kann mit "Nicht mehr anzeigen" übersprungen werden
class PreOnboardingScreen extends StatefulWidget {
  const PreOnboardingScreen({super.key});

  static const String routeName = '/pre-onboarding';

  @override
  State<PreOnboardingScreen> createState() => _PreOnboardingScreenState();
}

class _PreOnboardingScreenState extends State<PreOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _hasSelectedLocale = false;
  String? _selectedLocaleCode;
  Box<dynamic>? _settingsBox;

  /// Verfügbare Sprachen mit Flaggen-Emojis
  static const _availableLanguages = [
    ('de', '🇩🇪', 'Deutsch'),
    ('en', '🇬🇧', 'English'),
    ('es', '🇪🇸', 'Español'),
    ('fr', '🇫🇷', 'Français'),
    ('it', '🇮🇹', 'Italiano'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Smooth pulsating statt reset

    // Prüfe ob bereits eine Sprache gewählt wurde
    _loadLocaleStatus();

    _recordTelemetry(TelemetryEventName.onboardingBegonnen);
  }

  /// Meldet ein Ereignis, wenn Einwilligung und Dienst dafür bereitstehen.
  ///
  /// Beides ist hier nicht selbstverständlich: Dieser Schirm ist der erste
  /// überhaupt, und die aufgeschobene Dependency Injection läuft parallel
  /// noch. `null` heißt, dass diese Version den Ereignisnamen nicht kennt —
  /// dann wird nichts gemeldet statt etwas Falsches.
  void _recordTelemetry(TelemetryEventName? name) {
    if (name == null) return;
    if (!getIt.isRegistered<TelemetryRecorder>()) return;
    unawaited(getIt<TelemetryRecorder>().record(name));
  }

  Future<void> _loadLocaleStatus() async {
    _settingsBox = await Hive.openBox<dynamic>('settings');
    final selectedLocale = _settingsBox?.get('selected_locale') as String?;
    if (mounted) {
      setState(() {
        _selectedLocaleCode = selectedLocale;
        _hasSelectedLocale = selectedLocale != null;
      });
    }
  }

  Future<void> _selectLanguage(String localeCode) async {
    _settingsBox ??= await Hive.openBox<dynamic>('settings');
    await _settingsBox!.put('selected_locale', localeCode);
    // Damit schon der nächste Ladebildschirm diese Sprache spricht — er
    // kommt zu früh, um Hive zu fragen.
    await StartupLocale.merken(localeCode);
    if (mounted) {
      setState(() {
        _selectedLocaleCode = localeCode;
        _hasSelectedLocale = true;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Reihenfolge wie im PageView. Stabile Schlüssel, keine Beschriftungen.
  static const List<String> _stepKeys = [
    'willkommen',
    'privacy',
    'features',
    'profile',
    'los_gehts',
  ];

  Future<void> _dismissOnboarding() async {
    // Der Abbruch ist selbst ein Ereignis. So verlässt nie eine Schrittfolge
    // das Gerät, und die Quote ergibt sich aus dem Verhältnis der Zähler.
    //
    // Dieser Weg wird für beide Ausgänge genommen: „Nicht mehr anzeigen" und
    // das Durchklicken bis zur letzten Seite. Die Seitenzahl unterscheidet sie.
    _recordTelemetry(
      _currentPage >= _stepKeys.length - 1
          ? TelemetryEventName.onboardingBeendet
          : TelemetryEventName.fromWireName(
              'onboarding_abgebrochen_${_stepKeys[_currentPage]}',
            ),
    );

    final settingsBox = await Hive.openBox<dynamic>('settings');
    await settingsBox.put('pre_onboarding_dismissed', true);
    // Kein Navigator mehr nötig!
    // MyApp lauscht auf settingsBox und wechselt automatisch den Screen
  }

  void _nextPage() {
    if (_currentPage < 4) {
      // Jetzt 5 Seiten statt 4
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Letzte Seite - Onboarding abschließen
      _dismissOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: DismissableOnboardingWrapper(
        onDismiss: _dismissOnboarding,
        child: Column(
          children: [
            // PageView mit 5 Seiten (nimmt restlichen Platz)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Seite 1: Willkommen bei Aurora (mit Rainbow-Text)
                  _buildWelcomePage(theme, l10n, screenHeight),

                  // Seite 2: Privacy First (ohne "Open Source")
                  _buildPrivacyPage(l10n),

                  // Seite 3: Feature-Carousel (NEU)
                  const FeatureCarouselPage(),

                  // Seite 4: Multi-Profile System
                  _buildMultiProfilePage(l10n),

                  // Seite 5: Let's Go
                  _buildLetsGoPage(l10n),
                ],
              ),
            ),

            // Navigation-Bereich (minimale Höhe, passt sich an Inhalt an)
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
                    // Page Indicator
                    OnboardingPageIndicator(
                      currentPage: _currentPage,
                      totalPages: 5,
                      activeColor: const Color(0xFFFFB6C1), // Pastell Rosa
                      inactiveColor: const Color(
                        0xFF4A4458,
                      ), // Warmes Dunkelgrau
                    ),
                    const SizedBox(height: 12),
                    // Weiter Button
                    //
                    // Der Verlauf liegt auf dem Container, der Knopf darin ist
                    // durchsichtig. Flutter graut deshalb nur die Schrift aus —
                    // ohne die folgende Fallunterscheidung leuchtet ein
                    // gesperrter Knopf wie ein bedienbarer, und ein Tippen
                    // bleibt wirkungslos, ohne dass es jemand sehen kann.
                    Builder(
                      builder: (context) {
                        final canProceed =
                            _currentPage > 0 || _hasSelectedLocale;

                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: canProceed
                                  ? const [
                                      Color(0xFFFFB6C1), // Pastell Rosa
                                      Color(0xFF87CEEB), // Pastell Blau
                                    ]
                                  : const [
                                      AppColors.slate,
                                      AppColors.slate,
                                    ],
                            ),
                            border: canProceed
                                ? null
                                : Border.all(color: AppColors.line),
                            boxShadow: canProceed
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFFB6C1,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ElevatedButton(
                            onPressed: canProceed ? _nextPage : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              // Dunkle Schrift auf dem hellen Verlauf statt
                              // weißer Schrift mit Schlagschatten.
                              foregroundColor: AppColors.inkDeep,
                              disabledForegroundColor: AppColors.faint,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(
                              _currentPage < 4
                                  ? l10n.onboardingNext
                                  : l10n.onboardingCreateProfile,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildWelcomePage(
    ThemeData theme,
    AppLocalizations l10n,
    double screenHeight,
  ) {
    return ColoredBox(
      color: AppColors.ink,
      child: SafeArea(
        bottom: false, // Navigation-Container handles bottom SafeArea
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 32,
              right: 32,
              top: 28,
              bottom: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo und Begrüßung nebeneinander. Untereinander schoben sie
                // die Sprachauswahl — die einzige Handlung dieser Seite — auf
                // kleinen Geräten unter den Bildrand.
                Row(
                  children: [
                    _buildAnimatedLogo(),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.onboardingWelcomeTo,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              height: 1.2,
                              color: AppColors.paperBright,
                            ),
                          ),
                          const GradientText(
                            'Aurora',
                            gradient: kAuroraRainbowGradient,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.onboardingSubline,
                            style: const TextStyle(
                              color: Color(0xFFE8D4C0), // Warmes Beige
                              fontSize: 15,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  l10n.onboardingDescription,
                  style: const TextStyle(
                    color: Color(0xFFD4C5B9), // Sanftes Beige
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Sprach-Auswahl (immer anzeigen, mit Markierung)
                SizedBox(height: screenHeight * 0.03),
                Text(
                  l10n.onboardingSelectLanguage,
                  style: const TextStyle(
                    color: Color(0xFFE8D4C0),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildLanguageSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPage(AppLocalizations l10n) {
    return PreOnboardingPage(
      icon: Icons.shield,
      headline: l10n.onboardingPrivacyHeadline,
      bulletPoints: [
        l10n.onboardingPrivacyPoint1,
        l10n.onboardingPrivacyPoint2,
        l10n.onboardingPrivacyPoint3,
        l10n.onboardingPrivacyPoint4,
      ],
    );
  }

  Widget _buildMultiProfilePage(AppLocalizations l10n) {
    return PreOnboardingPage(
      iconWidget: _buildRotatingCircles(Theme.of(context)),
      headline: l10n.onboardingMultiProfileHeadline,
      description: l10n.onboardingMultiProfileDescription,
    );
  }

  Widget _buildLetsGoPage(AppLocalizations l10n) {
    return PreOnboardingPage(
      icon: Icons.auto_awesome,
      headline: l10n.onboardingLetsGoHeadline,
      description: l10n.onboardingLetsGoDescription,
    );
  }

  /// Animiertes Aurora Logo mit Glow-Effekt
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFFB6C1,
                ).withValues(alpha: 0.3 + (_animationController.value * 0.2)),
                blurRadius: 22 + (_animationController.value * 8),
                spreadRadius: 4 + (_animationController.value * 2),
              ),
              BoxShadow(
                color: const Color(
                  0xFF87CEEB,
                ).withValues(alpha: 0.2 + (_animationController.value * 0.15)),
                blurRadius: 28 + (_animationController.value * 12),
                spreadRadius: 6 + (_animationController.value * 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo_rainbow.png',
            width: 96,
            height: 96,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  /// Sprach-Auswahl Widget (5 Buttons mit Flaggen und Markierung)
  Widget _buildLanguageSelector() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: _availableLanguages.map((lang) {
        final (code, flag, name) = lang;
        final isSelected = code == _selectedLocaleCode;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectLanguage(code),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFB6C1)
                      : const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                  width: isSelected ? 2.5 : 1.5,
                ),
                gradient: LinearGradient(
                  colors: isSelected
                      ? [
                          const Color(0xFFFFB6C1).withValues(alpha: 0.2),
                          const Color(0xFF87CEEB).withValues(alpha: 0.15),
                        ]
                      : [
                          const Color(0xFF2A2A3E).withValues(alpha: 0.8),
                          AppColors.ink.withValues(alpha: 0.9),
                        ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFFFFB6C1),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.paperBright,
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Rotierende Kreise für Multi-Profile Visualisierung
  Widget _buildRotatingCircles(ThemeData theme) {
    const colors = [
      Color(0xFFFFB6C1), // Pastell Rosa
      Color(0xFF87CEEB), // Pastell Blau
      Color(0xFFB4E7CE), // Pastell Grün/Türkis
      Color(0xFFFFF4A3), // Pastell Gelb
    ];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(4, (index) {
              final angle = (index * 90.0) + (_animationController.value * 360);
              final radians = angle * math.pi / 180;
              final offset = Offset(
                30 * math.cos(radians),
                30 * math.sin(radians),
              );

              return Transform.translate(
                offset: offset,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[index],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
