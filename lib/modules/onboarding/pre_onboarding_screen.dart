import 'dart:async';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/startup_locale.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/modules/onboarding/widgets/dismissable_onboarding_wrapper.dart';
import 'package:dis_app/services/release_notes_gate.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

/// Die Vorstellung vor dem ersten Profil — seit 3.0.25 eine Seite.
///
/// Willkommen, Sprache und ein Satz zum Datenschutz („Alles bleibt auf
/// diesem Gerät.“). Bis 3.0.24 waren es fünf Seiten: Willkommen, Datenschutz,
/// ein Funktionskarussell, „Mehrere Profile“ und „Bereit?“ — zusammen mit
/// Profilanlage und Begrüßungsseiten rund sechzehn Schirme bis zur App. Am
/// Gerät war das zu lang für jemanden, der gerade nur anfangen will.
///
/// Danach kommt die Telemetrie-Frage, dann das erste Profil.
///
/// „Nicht mehr anzeigen“ bleibt als Ausgang: Wer keine Sprache wählt, kommt
/// darüber trotzdem weiter.
class PreOnboardingScreen extends StatefulWidget {
  const PreOnboardingScreen({super.key});

  static const String routeName = '/pre-onboarding';

  @override
  State<PreOnboardingScreen> createState() => _PreOnboardingScreenState();
}

class _PreOnboardingScreenState extends State<PreOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Prüfe ob bereits eine Sprache gewählt wurde
    _loadLocaleStatus();

    _recordTelemetry(TelemetryEventName.onboardingBegonnen);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animationController
        ..stop()
        ..value = 0;
    } else if (!_animationController.isAnimating) {
      _animationController.repeat(reverse: true);
    }
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
    _animationController.dispose();
    super.dispose();
  }

  /// Schließt die Vorstellung ab.
  ///
  /// [abgebrochen] heißt „Nicht mehr anzeigen“, sonst „Weiter“. Der Ausgang
  /// wird mitgegeben, nicht aus der Seitenzahl gelesen: Bei einer Seite ist
  /// jede Seite die letzte, und ein Abbruch hätte sich als Ende gemeldet.
  ///
  /// Der Abbruch ist ein eigenes Ereignis, damit nie eine Schrittfolge das
  /// Gerät verlässt; die Quote ergibt sich aus dem Verhältnis der Zähler.
  /// Die Abbruch-Ereignisse der entfallenen Seiten (privacy, features,
  /// profile, los_gehts) bleiben im Enum — ältere Fassungen senden sie.
  Future<void> _dismissOnboarding({required bool abgebrochen}) async {
    _recordTelemetry(
      abgebrochen
          ? TelemetryEventName.onboardingAbgebrochenWillkommen
          : TelemetryEventName.onboardingBeendet,
    );

    final settingsBox = await Hive.openBox<dynamic>('settings');

    // Wer die Vorstellung gerade gesehen hat, braucht keine Neuerungen — er
    // lernt diese Fassung genau jetzt kennen.
    //
    // Diese Zeile steht bewusst VOR dem Merker unten: „kein Eintrag plus
    // abgeschlossene Vorstellung" ist für den Neuerungs-Schirm das Zeichen
    // eines Updates. Andersherum geschrieben, feuerte der Rebuild auf
    // `pre_onboarding_dismissed`, bevor die Fassung notiert wäre, und der
    // Schirm blitzte unmittelbar nach dem Onboarding auf.
    await ReleaseNotesGate.fromBox(
      settingsBox,
      currentVersion: getIt.isRegistered<TelemetryRecorder>()
          ? getIt<TelemetryRecorder>().appVersion
          : ReleaseNotesGate.unknownVersion,
    ).markSeen();

    await settingsBox.put('pre_onboarding_dismissed', true);
    // Kein Navigator mehr nötig!
    // MyApp lauscht auf settingsBox und wechselt automatisch den Screen
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: DismissableOnboardingWrapper(
        onDismiss: () => _dismissOnboarding(abgebrochen: true),
        child: Column(
          children: [
            Expanded(child: _buildWelcomePage(l10n, screenHeight)),

            // Navigation-Bereich (minimale Höhe, passt sich an Inhalt an)
            Container(
              color: AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  // Weiter Button
                  //
                  // Der Verlauf liegt auf dem Container, der Knopf darin ist
                  // durchsichtig. Flutter graut deshalb nur die Schrift aus —
                  // ohne die folgende Fallunterscheidung leuchtet ein
                  // gesperrter Knopf wie ein bedienbarer, und ein Tippen
                  // bleibt wirkungslos, ohne dass es jemand sehen kann.
                  child: Builder(
                    builder: (context) {
                      final canProceed = _hasSelectedLocale;

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
                          onPressed: canProceed
                              ? () => _dismissOnboarding(abgebrochen: false)
                              : null,
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
                            l10n.onboardingNext,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n, double screenHeight) {
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

                const SizedBox(height: 20),

                // Der Datenschutz in einem Satz. Bis 3.0.24 eine eigene Seite
                // mit vier Punkten; was im Einzelnen gilt, steht in den
                // Einstellungen unter „Was Aurora sendet“.
                _buildPrivacyLine(l10n),

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

  /// „Alles bleibt auf diesem Gerät.“ — Schild links, Satz daneben, darunter
  /// ruhiger die Zusage „Keine Cloud-Sicherung, kein Tracking, keine
  /// Werbung“.
  ///
  /// Die zweite Zeile ist keine Wiederholung: An ihr hängen die
  /// Manifest-Attribute, die Androids Sicherung in die Google Drive
  /// abschalten (`test/core/keine_cloud_sicherung_test.dart` prüft beides).
  /// Mit der entfallenen Datenschutzseite war sie kurz verschwunden.
  Widget _buildPrivacyLine(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB4E7CE).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFFB4E7CE)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingPrivacyOneLine,
                  style: const TextStyle(
                    color: AppColors.paperBright,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.onboardingPrivacyBullet2,
                  style: const TextStyle(
                    color: Color(0xFFD4C5B9), // Sanftes Beige
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
}
