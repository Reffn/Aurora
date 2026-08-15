import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/delete_all_data.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/core/startup_locale.dart';
import 'package:dis_app/core/startup_state.dart';
import 'package:dis_app/core/today_overview_controller.dart';
import 'package:dis_app/debug/scenario_seed.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/fab_config.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/models/tab_item.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/modules/anchor/anchor_header.dart';
import 'package:dis_app/modules/anchor/anchor_menu_screen.dart';
import 'package:dis_app/modules/anchor/anker_kopfblock.dart';
import 'package:dis_app/modules/calendar/calendar_screen.dart';
import 'package:dis_app/modules/chat/chat_screen.dart';
import 'package:dis_app/modules/contacts/contact_form_screen.dart';
import 'package:dis_app/modules/contacts/contacts_screen.dart';
import 'package:dis_app/modules/diary/diary_screen.dart';
import 'package:dis_app/modules/diary/entry_form_screen.dart';
import 'package:dis_app/modules/emergency/emergency_screen.dart';
import 'package:dis_app/modules/feedback/feedback_screen.dart';
import 'package:dis_app/modules/finder/finder_form_screen.dart';
import 'package:dis_app/modules/finder/finder_screen.dart';
import 'package:dis_app/modules/games/games_screen.dart';
import 'package:dis_app/modules/grounding/grounding_screen.dart';
import 'package:dis_app/modules/help/help_resources_screen.dart';
import 'package:dis_app/modules/medication/medication_form_screen.dart';
import 'package:dis_app/modules/medication/medication_screen.dart';
import 'package:dis_app/modules/onboarding/pre_onboarding_screen.dart';
import 'package:dis_app/modules/profile/profile_creation_screen.dart';
import 'package:dis_app/modules/profile/profile_edit_screen.dart';
import 'package:dis_app/modules/profile/profile_selection_screen.dart';
import 'package:dis_app/modules/settings/settings_screen.dart';
import 'package:dis_app/modules/release_notes/release_notes_screen.dart';
import 'package:dis_app/modules/telemetry/telemetry_consent_screen.dart';
import 'package:dis_app/modules/timeline/timeline_screen.dart';
import 'package:dis_app/services/navigation_service.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:dis_app/services/profile_session_policy.dart';
import 'package:dis_app/services/reminders/reminder_reconciler.dart';
import 'package:dis_app/services/app_update_nudge.dart';
import 'package:dis_app/services/release_notes_gate.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:dis_app/services/telemetry_dispatcher.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:dis_app/modules/splash/splash_screen.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/time_phase.dart';
import 'package:dis_app/widgets/crash_boundary.dart';
import 'package:dis_app/widgets/gps_status_action.dart';
import 'package:dis_app/widgets/quick_timeline_band.dart';
import 'package:dis_app/widgets/reset_banner.dart';
import 'package:dis_app/widgets/startup_failure_screen.dart';
import 'package:dis_app/widgets/time_map.dart';
import 'package:dis_app/widgets/today_overview_line.dart';
import 'package:dis_app/widgets/work_surface_scaffold.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';

/// Der Notfall-Reset hält den Start an, statt dass der Start auf ihn wartet.
///
/// Bis zum 11. August 2026 lief es umgekehrt: Ein `Completer<bool>` wurde nach
/// festen drei Sekunden aufgelöst, und `_initializeAndNavigate` wartete darauf
/// — jeder Start jedes Tages zahlte drei Sekunden dafür, dass jemand *hätte*
/// tippen können. Gemessen am S24: erster Bildaufbau nach 241 ms,
/// Ladebildschirm sichtbar bis 5,6 s.
///
/// Schlimmer war, dass das Fenster seinen eigenen Zweck verfehlte. Nach drei
/// Sekunden setzte der Zeitgeber die Entscheidung auf „nein" und jeder weitere
/// Tap lief ins Leere. Der Löschweg ist aber laut seinem eigenen Kommentar
/// gerade für den Fall gedacht, dass der Start klemmt — dann steht der
/// Ladebildschirm minutenlang sichtbar da und nahm bisher trotzdem nichts mehr
/// an.
///
/// Jetzt trägt das Tippen die Frist: Der erste Tap hält den Start an, jeder
/// weitere verlängert, und wer aufhört, gibt nach drei Sekunden wieder frei.
/// Wer nicht tippt, wartet auf nichts.
bool _splashHaeltDenStartAn = false;
bool _wipeAngefordert = false;
Completer<void>? _splashFreigabe;

/// Der Ladebildschirm meldet, dass jemand angefangen hat zu tippen.
void _splashHaeltAn() {
  _splashHaeltDenStartAn = true;
}

/// Der Ladebildschirm gibt den Start wieder frei.
///
/// [wipe] ist nur dann `true`, wenn jemand fünfmal getippt *und* den Dialog
/// bestätigt hat.
void _splashGibtFrei({required bool wipe}) {
  _wipeAngefordert = wipe;
  _splashHaeltDenStartAn = false;
  _splashFreigabe?.complete();
  _splashFreigabe = null;
}

// Completer für Essential Services (wird in post-frame callback completed)
// Public damit SplashScreen darauf warten kann
final Completer<bool> _essentialServicesCompleter = Completer<bool>();
Future<bool> get essentialServicesInitialized =>
    _essentialServicesCompleter.future;

// Completer für Deferred Services (ChatService, DataEntry, etc.)
final Completer<void> _deferredServicesCompleter = Completer<void>();
Future<void> get deferredServicesInitialized =>
    _deferredServicesCompleter.future;

void main() {
  // Global Error Handler - fängt alle uncaught Exceptions
  runZonedGuarded(
    () async {
      final appStartTime = DateTime.now();
      var stepStart = appStartTime;

      // Minimal Initialization - NUR Flutter Engine
      WidgetsFlutterBinding.ensureInitialized();
      logger.info(
        LogCategory.ui,
        '⏱️ WidgetsFlutterBinding initialized',
        data: {
          'duration':
              '${DateTime.now().difference(stepStart).inMilliseconds}ms',
        },
      );

      // Die gewählte Sprache, bevor das erste Bild steht.
      //
      // Kostet ein paar Millisekunden und erspart dem Ladebildschirm, in der
      // Systemsprache zu sprechen, während die App danach in der gewählten
      // weiterläuft. Siehe `StartupLocale`.
      await StartupLocale.laden();

      // Firebase Initialization (non-blocking: app continues if Firebase unavailable)
      stepStart = DateTime.now();
      try {
        await Firebase.initializeApp();
        logger.info(
          LogCategory.ui,
          '⏱️ Firebase initialized',
          data: {
            'duration':
                '${DateTime.now().difference(stepStart).inMilliseconds}ms',
          },
        );

        // Anbieter ausgeschrieben, obwohl er dem Standard entspricht: Wovon
        // die Echtheitsprüfung abhängt, gehört sichtbar in den Code. Play
        // Integrity greift nur bei Installationen aus dem Play Store —
        // seitlich geladene Testbauten liefern deshalb kein gültiges Token,
        // und die Console zählt sie als „nicht bestätigt".
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
        );
        logger.info(
          LogCategory.ui,
          '⏱️ Firebase App Check activated',
          data: {
            'duration':
                '${DateTime.now().difference(stepStart).inMilliseconds}ms',
          },
        );
      } catch (e, stackTrace) {
        logger.error(
          LogCategory.service,
          'Firebase initialization failed - feedback via email will be offered',
          data: {'error': e.toString()},
          stackTrace: stackTrace,
        );
        // App continues without Firebase feedback transport
      }

      // Flutter Framework Error Handler (für Widget-Build-Errors)
      FlutterError.onError = (FlutterErrorDetails details) {
        logger.critical(
          LogCategory.ui,
          'Flutter Framework Error',
          data: {
            'exception': details.exception.toString(),
            'context': details.context?.toString() ?? 'unknown',
          },
          stackTrace: details.stack,
        );

        // Optionales Breadcrumb für Context
        logger.breadcrumb(
          BreadcrumbType.system,
          'Flutter Framework Error: ${details.exception.runtimeType}',
        );
      };

      // Logger konfigurieren (Production Mode in Release-Builds)
      const isProduction = bool.fromEnvironment('dart.vm.product');
      logger.setProduction(isProduction);
      logger.info(
        LogCategory.ui,
        'App starting',
        data: {'mode': isProduction ? 'Production' : 'Development'},
      );

      // File Logging aktivieren (nur in Release-Mode)
      if (isProduction) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final logPath = '${appDir.path}/logs/app.log';
          logger.enableFileLogging(logPath);
          logger.info(
            LogCategory.ui,
            '📝 File logging enabled',
            data: {'path': logPath},
          );
        } catch (e) {
          logger.warning(
            LogCategory.ui,
            'Failed to enable file logging',
            data: {'error': e.toString()},
          );
        }
      }

      // 🚀 ULTRA-SCHNELLER START: runApp() SOFORT (OHNE Hive!)
      // Erster Frame erscheint in ~600ms!
      stepStart = DateTime.now();
      runApp(const GlobalErrorBoundary(child: MyApp()));
      logger.info(
        LogCategory.ui,
        '⏱️ runApp() called IMMEDIATELY - NO BLOCKING OPERATIONS!',
        data: {
          'duration':
              '${DateTime.now().difference(stepStart).inMilliseconds}ms',
        },
      );

      // PHASE 1: Essential Services NACH erstem Frame (damit SplashScreen sofort sichtbar)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _runStartup(appStartTime);
      });
    },
    (error, stackTrace) {
      // Uncaught Async Error Handler
      logger.critical(
        LogCategory.ui,
        'Uncaught Async Error',
        data: {
          'error': error.toString(),
          'errorType': error.runtimeType.toString(),
        },
        stackTrace: stackTrace,
      );

      // Breadcrumb hinzufügen
      logger.breadcrumb(
        BreadcrumbType.system,
        'Uncaught Async Error: ${error.runtimeType}',
        data: {'error': error.toString()},
      );
    },
  );
}

/// Fährt die Dienste hoch — und meldet, wenn das nicht gelingt.
///
/// Jeder Ausgang erfüllt beide Completer. Vorher lagen sie im Fehlerfall für
/// immer offen: Der Splash-Screen wartete auf ein Ergebnis, das nie kam, und
/// blieb ohne Meldung stehen. Wer die App im schlechtesten Moment öffnet,
/// bekommt jetzt wenigstens einen Satz und zwei Wege.
Future<void> _runStartup(DateTime appStartTime) async {
  var step = 'essential';
  try {
    logger.info(
      LogCategory.ui,
      '🔄 Post-frame initialization started (first frame rendered!)',
    );

    final servicesResult = await _initializeEssentialServices(appStartTime);
    _completeEssential(servicesResult);

    // Clear active profile on every app startup
    // This ensures ProfileSelectionScreen appears (security: prevent accidental profile continuation)
    final profileService = getIt<ProfileService>();
    await profileService.settingsBox.delete('active_profile_id');
    logger.info(
      LogCategory.ui,
      '🔐 Active profile cleared - ProfileSelectionScreen will be shown',
    );

    // PHASE 2: Deferred tasks nach Essential Services
    step = 'deferred';
    final deferredStartTime = DateTime.now();
    logger.info(LogCategory.ui, '🔄 Deferred initialization started');

    // Portrait-Only: App bleibt im Hochformat
    var deferredStepStart = DateTime.now();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    logger.info(
      LogCategory.ui,
      '  ✓ SystemChrome orientations set',
      data: {
        'duration':
            '${DateTime.now().difference(deferredStepStart).inMilliseconds}ms',
      },
    );

    // System UI: Edge-to-Edge mit transparenten Bars
    deferredStepStart = DateTime.now();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    logger.info(
      LogCategory.ui,
      '  ✓ System UI configured (edge-to-edge)',
      data: {
        'duration':
            '${DateTime.now().difference(deferredStepStart).inMilliseconds}ms',
      },
    );

    // Locale-Daten für die Datums-Formatierung initialisieren.
    //
    // Alle Sprachen, nicht nur Deutsch: Vorher lud diese Zeile ausschließlich
    // de_DE, und die Wochentage im Kalender standen deshalb auch in der
    // englischen, spanischen, französischen und italienischen Oberfläche auf
    // Deutsch da („Montag, 3. August" unter der Überschrift „Calendar").
    deferredStepStart = DateTime.now();
    await initializeDateFormatting();
    logger.info(
      LogCategory.ui,
      '  ✓ Locale data initialized (alle Sprachen)',
      data: {
        'duration':
            '${DateTime.now().difference(deferredStepStart).inMilliseconds}ms',
      },
    );

    // Deferred Services initialisieren
    deferredStepStart = DateTime.now();
    await setupDeferredDependencies();

    // Fällige Telemetrie nachreichen. Bewusst ohne await: Der Start darf nie
    // auf das Netz warten, und was fehlschlägt, bleibt in der Warteschlange
    // liegen und wird beim nächsten Start erneut versucht.
    unawaited(getIt<TelemetryDispatcher>().flush());

    // Test-Szenario einspielen — nur aktiv mit
    // --dart-define=SEED_SCENARIO=..., sonst toter Code.
    await maybeSeedScenario();

    logger.info(
      LogCategory.ui,
      '  ✓ Deferred services initialized',
      data: {
        'duration':
            '${DateTime.now().difference(deferredStepStart).inMilliseconds}ms',
      },
    );

    // Deferred Services Completer markieren
    _completeDeferred();

    final totalDeferredDuration = DateTime.now().difference(
      deferredStartTime,
    );
    logger.info(
      LogCategory.ui,
      '✅ All initialization completed',
      data: {'totalDuration': '${totalDeferredDuration.inMilliseconds}ms'},
    );

    if (!startupState.value.isFailed &&
        startupState.value.phase != StartupPhase.degraded) {
      startupState.value = const StartupState(StartupPhase.ready);
    }
  } catch (e, stackTrace) {
    logger.critical(
      LogCategory.ui,
      'Start fehlgeschlagen',
      data: {'step': step, 'error': e.toString()},
      stackTrace: stackTrace,
    );
    startupState.value = StartupState(StartupPhase.failed, failedStep: step);

    // Beide Completer erfüllen, damit niemand mehr auf ein Ergebnis wartet,
    // das nicht mehr kommt. Der Splash-Screen zeigt danach den Fehler.
    _completeEssential(false);
    _completeDeferred();
  }
}

void _completeEssential(bool result) {
  if (!_essentialServicesCompleter.isCompleted) {
    _essentialServicesCompleter.complete(result);
  }
}

void _completeDeferred() {
  if (!_deferredServicesCompleter.isCompleted) {
    _deferredServicesCompleter.complete();
  }
}

/// Initialisiert Essential Services asynchron
/// Wird parallel zu runApp() ausgeführt für maximale Performance
Future<bool> _initializeEssentialServices(DateTime appStartTime) async {
  final stepStart = DateTime.now();

  await setupEssentialDependencies();

  logger.info(
    LogCategory.ui,
    '⏱️ Essential DI Setup done',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  final totalStartupDuration = DateTime.now().difference(appStartTime);
  logger.info(
    LogCategory.ui,
    'Essential services initialized successfully',
    data: {'totalStartupTime': '${totalStartupDuration.inMilliseconds}ms'},
  );

  return true;
}

/// Tab-Definition kombiniert alle Metadaten eines Tabs
/// (UI, Screen, FAB, benötigte Permission)
class TabDefinition {
  const TabDefinition({
    required this.tabItem,
    required this.screen,
    required this.fabConfig,
    required this.requiredPermission,
    required this.color,
    required this.telemetryKey,
    required this.section,
  });
  final TabItem tabItem;
  final Widget screen;
  final FABConfig? fabConfig;

  /// Farbe der Zeile im Ankermenü. Fest je Bereich, unabhängig vom Profil.
  ///
  /// Beschriftung ist immer weiß; alle Werte halten mindestens 4,5:1 Kontrast
  /// dagegen (WCAG AA). Die Farbe ist Zugabe, nicht Träger — erkannt wird ein
  /// Bereich am Symbol.
  final Color color;

  /// Gruppe, unter der dieser Bereich im Anker steht.
  final AnchorSection section;

  /// Stabiler Schlüssel für die Telemetrie.
  ///
  /// Bewusst getrennt von `tabItem.label`: Anzeigetexte ändern sich, und eine
  /// Umbenennung würde sonst jede Zeitreihe zerreißen. Der Schlüssel bildet
  /// den Ereignisnamen `bereich_geoeffnet_<schlüssel>`.
  final String telemetryKey;

  /// Recht, das diesen Tab sichtbar macht. `null` heißt: immer sichtbar.
  ///
  /// Gilt für Kernfunktionen, die kein Anteil einem anderen entziehen können
  /// soll — Chat, Feedback und der Erdungsbereich.
  final Permission? requiredPermission;
}

/// Reine Filterlogik für Tab-Sichtbarkeit, testbar ohne State
///
/// - Ohne Profil: alle Tabs sichtbar
/// - Mit Profil: Tabs ohne requiredPermission (null) sind immer sichtbar (Kern-Funktionen),
///   andere Tabs nur wenn das Profil das requiredPermission hat
List<TabDefinition> visibleTabsFor(
  List<TabDefinition> allTabs,
  Profile? activeProfile,
) {
  // Fallback: Wenn kein Profil aktiv, zeige alle Tabs
  if (activeProfile == null) {
    return allTabs;
  }

  // Tabs ohne requiredPermission sind immer sichtbar (Kern-Funktionen).
  // Die Reihenfolge der Definition bleibt erhalten.
  return allTabs
      .where(
        (tab) =>
            tab.requiredPermission == null ||
            activeProfile.hasPermission(tab.requiredPermission!),
      )
      .toList();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _servicesReady = false;
  bool _shouldShowSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  /// Notfall-Reset: Tippen aufs Logo während des Splash-Screens.
  ///
  /// Hier stand einmal eine Liste von sechzehn Boxnamen. Sie ist von dem
  /// abgedriftet, was die App tatsächlich anlegt: `profile_switches` gab es
  /// gar nicht — die Box heißt `switch_events` —, und
  /// `transmission_log`, `telemetry_queue` sowie sämtliche Anhänge standen
  /// nie darauf. Der Reset meldete trotzdem „16 Boxen gelöscht".
  ///
  /// Jetzt liegt der Umfang an einer Stelle, die ein Test bewacht. Der
  /// Löschweg selbst braucht keine angemeldeten Dienste — er wird ja gerade
  /// dann angetippt, wenn der Start klemmt.
  Future<void> _performEmergencyWipe() async {
    final ergebnis = await deleteAllLocalData();
    if (ergebnis.isComplete) {
      logger.info(LogCategory.hive, '🗑️ Notfall-Reset vollstaendig');
    } else {
      logger.error(
        LogCategory.hive,
        'Notfall-Reset unvollstaendig',
        data: {'failedSteps': ergebnis.failedSteps},
      );
      // Weiter im Start: Die App legt fehlende Boxen neu an.
    }
  }

  Future<void> _initializeAndNavigate() async {
    final splashStartTime = DateTime.now();

    // Nur so lange, dass der Ladebildschirm nicht aufblitzt.
    //
    // Hier standen 3000 ms, und sie waren nicht Ladezeit: Sie hielten das
    // Zeitfenster für den Notfall-Reset offen. Das Fenster trägt sich jetzt
    // selbst (siehe `_splashHaeltAn`), also bleibt nur noch der Grund, aus dem
    // eine Mindestanzeige überhaupt existiert — ein Bild, das nach 200 ms
    // wieder verschwindet, liest sich als Fehler, nicht als Start.
    const minimumDisplayTime = Duration(milliseconds: 900);

    // 1. Warte auf ALLE Services (Essential + Deferred)
    // CRITICAL: Deferred Services (DataEntry, ChatService, etc.) müssen
    // geladen sein BEVOR MainScreen mit ChatScreen gebaut wird
    await essentialServicesInitialized;
    await deferredServicesInitialized;

    // 2. Berechne wie lange bereits vergangen
    final elapsedTime = DateTime.now().difference(splashStartTime);

    if (elapsedTime < minimumDisplayTime) {
      await Future<void>.delayed(minimumDisplayTime - elapsedTime);
    }

    // 3. Tippt gerade jemand auf das Logo, bleibt der Ladebildschirm stehen.
    //
    // Zwischen der Prüfung und dem Warten liegt kein `await`, also kann kein
    // Tap dazwischenrutschen: Beides läuft im selben Durchlauf der
    // Ereignisschleife.
    if (_splashHaeltDenStartAn) {
      logger.info(LogCategory.ui, '⏸️ Splash hält den Start an (Logo-Tap)');
      _splashFreigabe = Completer<void>();
      await _splashFreigabe!.future;
    }

    if (_wipeAngefordert) {
      logger.warning(
        LogCategory.ui,
        '🗑️ Emergency wipe triggered - deleting all data',
      );
      await _performEmergencyWipe();
      logger.info(
        LogCategory.ui,
        '✅ Emergency wipe completed - app will start fresh',
      );
    }

    // Services ready - baue Real App
    if (mounted) {
      setState(() {
        _servicesReady = true;
        _shouldShowSplash = false;
      });
    }
  }

  /// Noch einmal von vorn.
  ///
  /// Die Anmeldung wird zurückgesetzt, sonst stolpert der zweite Anlauf über
  /// die Dienste des ersten. Hive-Boxen bleiben offen — sie erneut zu öffnen
  /// gibt dieselbe Box zurück.
  Future<void> _retryStartup() async {
    startupState.value = const StartupState(StartupPhase.loading);
    if (mounted) {
      setState(() {
        _servicesReady = false;
        _shouldShowSplash = true;
      });
    }
    await getIt.reset();
    await _runStartup(DateTime.now());
    if (!mounted) return;
    setState(() {
      _servicesReady = !startupState.value.isFailed;
      _shouldShowSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StartupState>(
      valueListenable: startupState,
      builder: (context, zustand, _) {
        // Ein gescheiterter Start bekommt eine Fläche mit zwei Wegen statt
        // eines Logos, das für immer steht.
        if (zustand.isFailed) {
          return StartupFailureApp(onRetry: _retryStartup);
        }

        // Während Services laden: Zeige Splash Screen
        if (_shouldShowSplash || !_servicesReady) {
          return const SplashMaterialApp();
        }

        // Services ready: Zeige Real App
        return _buildRealApp();
      },
    );
  }

  /// Builds the real app after services are ready
  /// Dynamischer home-Screen basierend auf App-State
  Widget _buildRealApp() {
    final profileService = getIt<ProfileService>();

    return ValueListenableBuilder(
      valueListenable: profileService.profilesBox.listenable(),
      builder: (context, profilesBox, _) {
        return ValueListenableBuilder(
          valueListenable: profileService.settingsBox.listenable(),
          builder: (context, settingsBox, _) {
            logger.info(
              LogCategory.ui,
              '⏱️ buildRealApp ValueListenableBuilder triggered',
            );

            // Prüfe App-Status
            final preOnboardingDismissed =
                settingsBox.get('pre_onboarding_dismissed', defaultValue: false)
                    as bool;

            // ✅ FIX: Lese direkt aus Box-Parametern (fresh data) statt aus Gettern (stale data)
            final hasProfiles = profilesBox.values.isNotEmpty;
            final activeProfileId =
                settingsBox.get('active_profile_id') as String?;
            final hasActiveProfile =
                activeProfileId != null &&
                profilesBox.values.any((p) => p.id == activeProfileId);

            // Auf derselben Box wie dieser Builder — dadurch löst die Antwort
            // den Rebuild aus, ohne dass GetIt hier schon bereit sein muss.
            final telemetryConsent = TelemetryConsent.fromBox(settingsBox);

            // Theme-Farbe basierend auf aktivem Profil
            final themeColor =
                profileService.activeProfile?.preferredColor ??
                Colors.deepPurple;

            // Bestimme welcher Screen angezeigt wird
            Widget homeScreen;
            if (!preOnboardingDismissed) {
              // Schritt 1: Pre-Onboarding beim ersten Start
              homeScreen = const PreOnboardingScreen();
            } else if (telemetryConsent.needsAsking) {
              // Schritt 2: Einmal fragen, ob anonyme Nutzungsdaten helfen
              // dürfen. Ein Mechanismus, zwei Anlässe — neue Nutzerinnen
              // sehen den Schirm nach der Vorstellung, bestehende beim ersten
              // Start nach dem Update. Danach nie wieder, egal wie entschieden.
              //
              // Bewusst vor der Profilerstellung: Wer dort abbricht, käme
              // sonst nie zur Frage, und die Abbrüche der Einrichtung wären
              // prinzipiell unmessbar — der Recorder legt ohne Zustimmung
              // nichts an.
              //
              // `onDecided` bleibt leer: Die Antwort landet in derselben
              // settings-Box, auf die dieser ValueListenableBuilder hört —
              // der Rebuild kommt von selbst.
              homeScreen = TelemetryConsentScreen(
                consent: telemetryConsent,
                onDecided: () {},
              );
            } else if (!hasProfiles) {
              // Schritt 3: Erstes Profil erstellen
              homeScreen = const ProfileCreationScreen();
            } else if (!hasActiveProfile) {
              // Schritt 4: Profil auswählen
              homeScreen = const ProfileSelectionScreen();
            } else {
              // Schritt 5: Main Screen (App nutzen)
              //
              // Die Neuerungen hängen bewusst NICHT in dieser Kette. Am Gerät
              // erwies sich das als unerreichbar: `ProfileSelectionScreen`
              // navigiert nach der Wahl selbst per `pushReplacement` zu
              // `PostLoginWelcomeScreen` und weiter zum `MainScreen`. Damit
              // liegt eine Route ueber diesem `home` — der Zweig wurde
              // gebaut und war vollstaendig verdeckt.
              //
              // Diese Kette gilt nur, solange niemand navigiert. Der Schirm
              // wird deshalb aus `MainScreen` heraus geoeffnet, wo er auch
              // ankommt.
              homeScreen = const MainScreen();
            }

            // Die Sprache des Anteils geht vor der App-Einstellung.
            //
            // In einem System sprechen nicht alle dieselbe Sprache. Wer sich
            // anmeldet, soll seine vorfinden, ohne sie jedes Mal umzustellen —
            // und ohne sie den anderen aufzuzwingen. Wer keine eigene gewählt
            // hat, folgt weiterhin der App-weiten Einstellung.
            final settingsLocale =
                settingsBox.get('selected_locale') as String?;
            final selectedLocale =
                profileService.activeProfile?.preferredLanguage ??
                settingsLocale;

            return MaterialApp(
              title: 'Aurora',
              locale: selectedLocale != null ? Locale(selectedLocale) : null,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('de'), // Deutsch
                Locale('en'), // English
                Locale('fr'), // Français
                Locale('es'), // Español
                Locale('it'), // Italiano
              ],
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: themeColor,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,

                // Freundlichere Hintergrundfarben (Material 3 Surface statt hart schwarz)
                scaffoldBackgroundColor: const Color(0xFF1C1B1F),

                // Rundere, weichere Card-Formen
                cardTheme: CardThemeData(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                // Rundere Buttons
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),

                // Material 3: FilledButton Theme
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                ),

                // Material 3: OutlinedButton Theme
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),

                // Material 3: TextButton Theme
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),

                // Rundere Floating Action Buttons
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                // AppBar mit Profil-Farbe
                appBarTheme: AppBarTheme(
                  centerTitle: false,
                  elevation: 0,
                  backgroundColor: themeColor.withValues(alpha: 0.15),
                ),

                // Input-Felder
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Reicht die Sprache an Dienste weiter, die keinen
              // BuildContext haben -- Benachrichtigungen und Transports.
              home: AppTextsBinding(child: homeScreen),
            );
          },
        );
      },
    );
  }
}

/// Minimale MaterialApp nur für Splash Screen
///
/// Oeffentlich, damit ein Widget-Test sie rendern kann: der Splash liegt vor
/// jeder anderen Oberflaeche, ein Fehler hier macht die App unstartbar.
class SplashMaterialApp extends StatelessWidget {
  const SplashMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Der Splash spricht, also braucht er die Delegates. Ohne sie liefert
      // AppLocalizations.of(context) null und der Null-Check reisst die App
      // beim Start ab.
      //
      // Die Sprache kommt aus `StartupLocale` — der Kopie der Wahl, die ohne
      // Hive lesbar ist. Ist dort nichts hinterlegt (erster Start, oder die
      // Wahl steht noch aus), bleibt `null` und damit die Systemsprache.
      locale: StartupLocale.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.inkDeep,
      ),
      // Der Bildschirm meldet, statt zu entscheiden: Er hält den Start an,
      // solange jemand tippt, und gibt ihn wieder frei. So bleibt er ohne den
      // halben Start prüfbar.
      home: SplashScreen(onHold: _splashHaeltAn, onRelease: _splashGibtFrei),
    );
  }
}

/// Was im Bannerblock des Ankers neben der Zeitkarte steht.
///

/// Main Screen mit Anker-Navigation: zwei Orte, nie beide gleichzeitig.
/// 1. AppBar - Logo, Titel, GPS-Status
/// 2. AnchorMenu - der Anker: senkrechte Liste aller Bereiche, Profilkarte oben
///
/// Jeder Bereich öffnet als eigene Arbeitsfläche (Navigator-Push); zurück geht
/// es über das Ankersymbol oder die Android-Zurück-Taste. Siehe
/// docs/superpowers/specs/2026-08-05-anker-menue-design.md
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late NavigationService _navigationService;

  final ProfileSessionPolicy _profileSessionPolicy = ProfileSessionPolicy();
  bool _profileChoiceOpen = false;

  // Alle Tab-Definitionen (kombiniert UI, Screen, FAB, Permission)
  late final List<TabDefinition> _allTabDefinitions;

  /// Das Lesemodell hinter „Was dieser Tag trägt".
  late final TodayOverviewController _todayOverview = TodayOverviewController(
    dataEntry: getIt<DataEntry>(),
    eventBus: getIt<EventBus>(),
  );

  @override
  void initState() {
    super.initState();
    _navigationService = getIt<NavigationService>();

    // App Lifecycle Observer registrieren (für Auto-Logout)
    WidgetsBinding.instance.addObserver(this);

    // Play fragen, ob eine neuere Fassung bereitliegt — höchstens einmal die
    // Woche und erst hier, nachdem die App tatsächlich benutzbar ist.
    //
    // Nicht früher: Vor der Profilwahl orientiert sich jemand, der gerade
    // hochkommt. Ein Systemdialog von Play gehört nicht in diesen Moment.
    unawaited(
      AppUpdateNudge.fromBox(getIt<ProfileService>().settingsBox).maybePrompt(),
    );

    // Neuerungen zeigen, sobald der Bildschirm steht.
    //
    // Erst nach dem ersten Bild: Im `initState` gibt es noch keinen
    // Navigator, ueber den sich etwas legen liesse. Und hier statt in der
    // Startkette von `_buildRealApp`, weil die Profilauswahl selbst
    // navigiert und jeden dortigen Zweig verdeckt — am Geraet gemessen,
    // nicht vermutet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_zeigeNeuerungenWennFaellig());
    });

    // Reihenfolge im Ankermenü. Sie ist fest und wird nie nach Nutzung
    // umsortiert: Was gestern an dritter Stelle stand, steht morgen an dritter
    // Stelle. Halt und Notfall stehen oben, weil man sie im schlechtesten
    // Zustand braucht — und dann scrollt niemand.
    _allTabDefinitions = [
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.anchor,
          label: (l) => l.groundingTitle,
          image: 'assets/images/cham_halt.png',
        ),
        screen: const GroundingScreen(),
        fabConfig: null,
        // Kern-Funktion, immer sichtbar. Erdung darf kein Anteil einem
        // anderen entziehen können.
        requiredPermission: null,
        color: const Color(0xFF00796B),
        telemetryKey: 'halt',
        section: AnchorSection.whenHard,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.emergency,
          label: (l) => l.tabEmergency,
          image: 'assets/images/cham_notfall.png',
        ),
        screen: const EmergencyScreen(),
        fabConfig: null, // Kontakte werden im Kontakte-Tab erstellt
        requiredPermission: Permission.viewEmergencyTab,
        color: const Color(0xFFC62828),
        telemetryKey: 'notfall',
        section: AnchorSection.whenHard,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.chat,
          label: (l) => l.tabChat,
          image: 'assets/images/cham_chat.png',
        ),
        screen: const ChatScreen(),
        fabConfig: null, // Chat hat ChatInputField
        requiredPermission: null, // Kern-Funktion, immer sichtbar
        color: const Color(0xFF3949AB),
        telemetryKey: 'chat',
        section: AnchorSection.everyday,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.calendar_today,
          label: (l) => l.tabCalendar,
          image: 'assets/images/cham_kalender.png',
        ),
        screen: const CalendarScreen(),
        fabConfig: null, // Event-Erstellung im "Erstellen" Tab
        requiredPermission: Permission.viewCalendarTab,
        color: const Color(0xFF1976D2),
        telemetryKey: 'kalender',
        section: AnchorSection.everyday,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.medication,
          label: (l) => l.tabMedication,
          image: 'assets/images/cham_medikamente.png',
        ),
        screen: const MedicationScreen(),
        fabConfig: FABConfig(
          permission: Permission.manageMedication,
          icon: Icons.add,
          label: (l) => l.fabMedication,
          onPressed: _addMedication,
        ),
        requiredPermission: Permission.viewMedicationTab,
        color: const Color(0xFF7B1FA2),
        telemetryKey: 'medikamente',
        section: AnchorSection.everyday,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.book,
          label: (l) => l.tabDiary,
          image: 'assets/images/cham_tagebuch.png',
        ),
        screen: const DiaryScreen(),
        fabConfig: FABConfig(
          permission: Permission.createDiaryEntry,
          icon: Icons.add,
          label: (l) => l.fabDiaryEntry,
          onPressed: _openDiaryForm,
        ),
        requiredPermission: Permission.viewDiaryTab,
        color: const Color(0xFF6D4C41),
        telemetryKey: 'tagebuch',
        section: AnchorSection.everyday,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.people,
          label: (l) => l.tabContacts,
          image: 'assets/images/cham_kontakte.png',
        ),
        screen: const ContactsScreen(),
        fabConfig: FABConfig(
          permission: Permission.manageContacts,
          icon: Icons.add,
          label: (l) => l.fabContact,
          onPressed: _openContactForm,
        ),
        requiredPermission: Permission.viewContactsTab,
        color: const Color(0xFF2E7D32),
        telemetryKey: 'kontakte',
        section: AnchorSection.everyday,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.search,
          label: (l) => l.tabFinder,
          image: 'assets/images/cham_finder.png',
        ),
        screen: const FinderScreen(),
        fabConfig: FABConfig(
          permission: Permission.manageFinder,
          icon: Icons.add,
          // Nicht der Text des Tagebuchs: Hier wird ein Ort oder ein
          // Gegenstand gemerkt, kein Eintrag geschrieben. Auf Italienisch
          // stand deshalb „Voce" auf dem Knopf — dasselbe Wort heißt auch
          // „Stimme", neben einer Fläche mit Sprachnachrichten.
          label: (l) => l.fabFinderEntry,
          onPressed: _openFinderForm,
        ),
        requiredPermission: Permission.viewFinderTab,
        color: const Color(0xFF00838F),
        telemetryKey: 'finder',
        section: AnchorSection.everyday,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.health_and_safety,
          label: (l) => l.tabHelp,
          image: 'assets/images/cham_hilfe.png',
        ),
        screen: const HelpResourcesScreen(),
        fabConfig: null, // Read-only
        requiredPermission: Permission.viewHelpTab,
        color: const Color(0xFFD84315),
        telemetryKey: 'hilfe',
        section: AnchorSection.whenHard,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.games,
          label: (l) => l.tabGames,
          image: 'assets/images/cham_spiele.png',
        ),
        screen: const GamesScreen(),
        fabConfig: null, // Read-only (später erweiterbar)
        requiredPermission: Permission.viewGamesTab,
        color: const Color(0xFFD81B60),
        telemetryKey: 'spiele',
        section: AnchorSection.whenCalm,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.timeline,
          label: (l) => l.tabTimeline,
          image: 'assets/images/cham_zeitachse.png',
        ),
        screen: const TimelineScreen(),
        fabConfig: null, // Read-only (GPS-Tracking via Footer-Toggle)
        requiredPermission: Permission.viewTimelineTab,
        color: const Color(0xFF546E7A),
        telemetryKey: 'zeitachse',
        section: AnchorSection.whenCalm,
      ),
      TabDefinition(
        tabItem: TabItem(
          icon: Icons.contact_support,
          label: (l) => l.tabFeedback,
          image: 'assets/images/cham_feedback.png',
        ),
        screen: const FeedbackScreen(),
        fabConfig: null, // Feedback hat eigene Submit-Buttons
        requiredPermission: null, // Kern-Funktion, immer sichtbar
        color: const Color(0xFFE65100),
        telemetryKey: 'feedback',
        section: AnchorSection.whenCalm,
      ),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _todayOverview.dispose();
    super.dispose();
  }

  /// Schickt weg, was fällig ist — ohne den Bedienfluss aufzuhalten.
  ///
  /// Bewusst ohne `await`: Kein Zustandswechsel der App darf auf das Netz
  /// warten. Was fehlschlägt, bleibt in der Warteschlange und wird beim
  /// nächsten Anlauf erneut versucht.
  void _telemetrieNachreichen() {
    if (!getIt.isRegistered<TelemetryDispatcher>()) return;
    unawaited(getIt<TelemetryDispatcher>().flush());
  }

  /// Einmal nach einem Update: was sich geändert hat, und die Frage, was fehlt.
  ///
  /// Der Vermerk läuft im Schirm selbst, nicht hier — wer ihn wegwischt, hat
  /// ihn gesehen.
  Future<void> _zeigeNeuerungenWennFaellig() async {
    if (!mounted) return;

    final settingsBox = getIt<ProfileService>().settingsBox;
    final gate = ReleaseNotesGate.fromBox(
      settingsBox,
      currentVersion: getIt.isRegistered<TelemetryRecorder>()
          ? getIt<TelemetryRecorder>().appVersion
          : ReleaseNotesGate.unknownVersion,
    );
    if (!gate.needsShowing) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReleaseNotesScreen(
          gate: gate,
          appVersion: getIt.isRegistered<TelemetryRecorder>()
              ? getIt<TelemetryRecorder>().appVersion
              : null,
          onDismissed: () {
            // Der Schirm ist eine Route, kein Startbildschirm: Er schliesst
            // sich selbst, statt auf einen Rebuild zu warten.
            if (mounted) Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _profileSessionPolicy.paused(DateTime.now().toUtc());
        logger.info(
          LogCategory.ui,
          'App im Hintergrund → Abwesenheit gemerkt',
          data: {
            'timeout': '${_profileSessionPolicy.timeout.inMinutes} Minuten',
          },
        );
        // Fällige Telemetrie noch schnell mitnehmen.
        //
        // Bis zum 11. August 2026 lief der Versand ausschließlich beim Start,
        // und zwar *bevor* die Ereignisse dieser Sitzung fällig wurden. Jedes
        // Ereignis kam damit frühestens einen Start später an — und von
        // jemandem, der die App einmal öffnet und nicht wieder, kam nie
        // etwas. Bei 43 Installationen lagen am 11. August sieben Ereignisse
        // vor, alle aus einem einzigen Testlauf im August.
        _telemetrieNachreichen();

        // Ein geladenes Update jetzt fertig installieren, nicht früher.
        //
        // Ohne diesen Schritt bleibt ein flexibles Update auf `DOWNLOADED`
        // liegen; Play installiert von selbst nichts. Im Vordergrund
        // abgeschlossen, zeigt die Plattform ein Vollbild und startet die App
        // neu — ein Abbruch mitten in der Handlung. Im Hintergrund läuft
        // dieselbe Installation still. Also hier.
        unawaited(
          AppUpdateNudge.fromBox(
            getIt<ProfileService>().settingsBox,
          ).completeIfDownloaded(),
        );
        break;

      case AppLifecycleState.resumed:
        // Wiederöffnen, nicht Kaltstart — der Name sagt genau das.
        //
        // In `initState` gemessen wäre es eine Lüge: Davor liegen
        // Einwilligung, Profilwahl und der Neuerungs-Schirm, und die Methode
        // feuert bei manchen Rebuilds mit. Der Lebenszyklus-Beobachter sieht
        // die Rückkehr aus dem Hintergrund, und nur die wird gemeldet.
        if (getIt.isRegistered<TelemetryRecorder>()) {
          unawaited(
            getIt<TelemetryRecorder>().record(
              TelemetryEventName.appFortgesetzt,
            ),
          );
        }
        final needsProfileChoice = _profileSessionPolicy.resumed(
          DateTime.now().toUtc(),
        );
        if (needsProfileChoice) {
          unawaited(_requestProfileChoice());
        }

        // Und die Erinnerungen abgleichen.
        //
        // Die Benachrichtigungserlaubnis kann in den Systemeinstellungen
        // entzogen worden sein, ohne dass Aurora davon erfährt; der Tag kann
        // gewechselt haben, die Zeitzone auch. Der Abgleich ist billig und
        // idempotent — zweimal laufen ändert nichts.
        if (getIt.isRegistered<ReminderReconciler>()) {
          unawaited(getIt<ReminderReconciler>().reconcile());
        }
        // Wer die App nach Stunden wieder öffnet, bringt fällig gewordene
        // Ereignisse mit — ohne dass er sie erst beenden und neu starten muss.
        _telemetrieNachreichen();
        logger.info(
          LogCategory.ui,
          needsProfileChoice
              ? 'App wieder aktiv → Anteil erneut auswählen'
              : 'App wieder aktiv → Sitzung fortsetzen',
        );
        break;

      case AppLifecycleState.inactive:
        // Temporärer State (z.B. Anruf) → Nichts tun
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App wird beendet → Nichts tun (bereits in dispose)
        break;
    }
  }

  /// Fragt nach längerer Abwesenheit nur neu, wer gerade da ist. Aurora und
  /// der Navigator darunter bleiben bestehen: Derselbe Anteil kehrt an die
  /// vorige Stelle zurück, ein anderer beginnt auf einem neutralen Anker.
  Future<void> _requestProfileChoice() async {
    if (_profileChoiceOpen || !mounted) return;

    final profileService = getIt<ProfileService>();
    final previousProfile = profileService.activeProfile;
    if (previousProfile == null) return;

    _profileChoiceOpen = true;
    try {
      final selectedProfile = await Navigator.of(context).push<Profile>(
        MaterialPageRoute<Profile>(
          fullscreenDialog: true,
          builder: (routeContext) => PopScope(
            canPop: false,
            child: ProfileSelectionScreen(
              onProfileSelected: (profile) async {
                Navigator.of(routeContext).pop(profile);
              },
            ),
          ),
        ),
      );

      if (!mounted || selectedProfile == null) return;

      if (selectedProfile.id != previousProfile.id) {
        unawaited(
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const MainScreen()),
            (_) => false,
          ),
        );
      }
    } finally {
      if (mounted) _profileChoiceOpen = false;
    }
  }

  /// Zeigt Profilmenü mit Bearbeiten und Ausloggen
  void _showProfileMenu(BuildContext context, Profile activeProfile) {
    final profileService = getIt<ProfileService>();
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Wo bin ich hier gelandet? Die Fläche hat bisher nur drei
            // Einträge gezeigt und nie gesagt, was sie ist.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    size: 20,
                    color: activeProfile.preferredColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.profileMenuTitle,
                    style: const TextStyle(
                      color: AppColors.paper,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Bearbeiten
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.paper),
              title: Text(
                l10n.menuProfileEdit,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        ProfileEditScreen(profile: activeProfile),
                  ),
                );
              },
            ),

            // Einstellungen
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.paper),
              title: Text(
                l10n.menuSettings,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),

            // Ausloggen
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.paper),
              title: Text(
                l10n.menuLogout,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);

                // Kompletter Logout mit Navigation
                await profileService.performLogout(
                  context,
                  reason: 'Manuelles Logout',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Filtert Tabs basierend auf aktiven Profil-Permissions
  /// (Delegiert zu visibleTabsFor für bessere Testbarkeit)
  List<TabDefinition> _getVisibleTabs() {
    final profileService = getIt<ProfileService>();
    final activeProfile = profileService.activeProfile;
    return visibleTabsFor(_allTabDefinitions, activeProfile);
  }

  /// Öffnet einen Bereich als eigene Arbeitsfläche.
  ///
  /// Die Fläche liegt auf dem Navigator-Stapel über dem Anker. Sie zu
  /// verlassen heißt, sie vom Stapel zu nehmen — deshalb tun das Ankersymbol
  /// und die Zurück-Taste des Geräts dasselbe, ohne dass es doppelt
  /// programmiert wäre.
  /// Öffnet die Zeitachse — den vollständigen Verlauf.
  ///
  /// Die Zeitkarte im Anker zeigt einen Tag und drei Marken je Rand. Wer
  /// weiter zurück will, tippt sie an und landet hier. Dass sie überhaupt
  /// weiterführt, ist der Grund, warum sie sich auf einen Tag beschränken
  /// darf.
  ///
  /// Fehlt der Bereich diesem Anteil, führt der Griff ins Leere statt in
  /// eine Fläche, die er nicht sehen darf.
  void _openTimeline() {
    final ziel = _timelineTarget;
    if (ziel == null) return;
    unawaited(_openWorkSurface(ziel));
  }

  /// Der Zeitachsen-Bereich dieses Anteils — oder nichts.
  TabDefinition? get _timelineTarget {
    final tabs = _getVisibleTabs().where((t) => t.telemetryKey == 'zeitachse');
    return tabs.isEmpty ? null : tabs.first;
  }

  /// Die Handlung, aber nur wenn es sie gibt.
  ///
  /// Vorher blieb das Band anklickbar, auch wenn das Ziel für diesen Anteil
  /// gar nicht existierte: Der Griff löste eine Welle aus und dann nichts.
  /// Wer das erlebt, sucht den Fehler bei sich. Eine Fläche darf nur dann
  /// aussehen wie eine Handlung, wenn sie eine ist — dieselbe Auflösung
  /// gilt für Band und Zeitkarte, damit Rechte nicht an zwei Stellen
  /// verschieden ausgelegt werden.
  VoidCallback? get _openTimelineIfAllowed =>
      _timelineTarget == null ? null : _openTimeline;

  Future<void> _openWorkSurface(TabDefinition tab) async {
    final l10n = AppLocalizations.of(context);
    // Gezählt wird ausschließlich das Öffnen — auch bei Halt, Notfall und
    // Hilfe. Ob der Notfallweg gefunden wird, ist die wichtigste Einzelfrage
    // dieser Erhebung. Was innerhalb der Bereiche geschieht, erzeugt nie ein
    // Ereignis: kein ausgelöster Notruf, keine alarmierten Kontakte.
    //
    // `null` heißt: Es kam ein Bereich dazu, ohne dass ein Ereignis dafür
    // angelegt wurde. Dann wird nichts gesendet statt etwas Falsches.
    final areaEvent = TelemetryEventName.fromWireName(
      'bereich_geoeffnet_${tab.telemetryKey}',
    );
    // Die Registrierungsprüfung fehlte hier als einziger der drei
    // Meldepunkte. Ein Bereichswechsel, bevor die Verdrahtung steht, hätte
    // geworfen — nicht theoretisch, sondern genau in dem Zeitfenster, in dem
    // die Oberfläche schon steht und `setupDependencyInjection` noch läuft.
    if (areaEvent != null && getIt.isRegistered<TelemetryRecorder>()) {
      unawaited(getIt<TelemetryRecorder>().record(areaEvent));
    }

    _navigationService.navigateToPage(_allTabDefinitions.indexOf(tab));

    final anteil = getIt<ProfileService>().activeProfile;
    final vergangenes = getIt<TimelineDataService>().getPastEvents(hours: 12);
    final kommendes = getIt<TimelineDataService>().getUpcomingEvents();
    // Ein Band ohne Marken zeigt nur den Avatar — dieselbe Auskunft, die eine
    // Zeile höher schon steht. Dann bleibt die Leiste besser leer.
    final bandTraegt =
        anteil != null &&
        QuickTimelineBand.hasContent(
          profile: anteil,
          pastEvents: vergangenes,
          upcomingEvents: kommendes,
        );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkSurfaceScaffold(
          title: tab.tabItem.label(l10n),
          profile: getIt<ProfileService>().activeProfile,
          // Derselbe Griff wie auf dem Anker, an derselben Stelle: die
          // Anteilszeile führt ins Profilmenü. Ein Muster, zwei Orte.
          onProfileTap: () {
            final profile = getIt<ProfileService>().activeProfile;
            if (profile != null) _showProfileMenu(context, profile);
          },
          subHeader: !bandTraegt
              ? null
              : QuickTimelineBand(
                  profile: anteil,
                  pastEvents: vergangenes,
                  upcomingEvents: kommendes,
                  profileNameOf: (id) =>
                      getIt<ProfileService>().profilesBox.get(id)?.name,
                  // Das Band versprach im eigenen Kommentar, zur Chronologie
                  // zu führen — der Rückruf fehlte, der Griff lief ins Leere.
                  onTap: _openTimelineIfAllowed,
                ),
          fab: tab.fabConfig?.build(context),
          actions: const [GpsStatusAction(), SizedBox(width: 8)],
          child: tab.screen,
        ),
      ),
    );
  }

  /// Navigation Helper Methods für FABs

  void _addMedication() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const MedicationFormScreen(),
      ),
    );
  }

  void _openDiaryForm() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const EntryFormScreen()),
    );
  }

  void _openContactForm() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const ContactFormScreen()),
    );
  }

  void _openFinderForm() {
    // Tab-Index aus NavigationService lesen (0 = Orte, 1 = Dinge)
    final tabIndex = getIt<NavigationService>().finderCurrentTabIndex;
    final initialType = tabIndex == 0
        ? FinderItemType.location
        : FinderItemType.item;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => FinderFormScreen(initialType: initialType),
      ),
    );
  }

  /// Zeigt laufende Passwort-Resets ueber allen Bereichen.
  Widget _buildPasswordResetBanner(BuildContext context) {
    return const ResetBanner();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Android Back Button: "Wirklich beenden?" Dialog
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.appQuitTitle),
              content: Text(l10n.appQuitMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.actionCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.actionQuit),
                ),
              ],
            ),
          );

          if (shouldExit == true) {
            await SystemNavigator.pop(); // App beenden
          }
        }
      },
      child: Stack(
        children: [
          Scaffold(
            // Layer 1: AppBar im oberen Ende der Tagestönung
            //
            // Hier stand ein Verlauf in der Profilfarbe. Am Gerät nachgesehen
            // ergab Orange auf dunklem Grund einen braunen Balken, der hart
            // gegen die Tönung des Ankers darunter stand — die Kante, die der
            // Anker gerade losgeworden war, saß dann eben eine Zeile höher.
            //
            // Die Tönung läuft jetzt durch: Sie beginnt an der Statusleiste
            // ungefärbt, ist an der Unterkante der Leiste voll da und wird im
            // Anker weiter nach unten wieder weniger. Verloren geht dabei
            // nichts — wessen Anteil vorn ist, sagt der Kopf darunter mit Name
            // und farbigem Punkt deutlicher, als ein Hauch in der Leiste es je
            // konnte.
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Color.alphaBlend(
                        anchorTintOf(
                          DateTime.now().hour,
                        ).withValues(alpha: 0.18),
                        Theme.of(context).colorScheme.surface,
                      ),
                    ],
                  ),
                ),
              ),
              // Die Wortmarke steht neben dem Zeichen, nicht darunter.
              //
              // Gestapelt musste sie in die Höhe einer Leiste passen, die
              // beides tragen sollte — dabei blieben zehn Punkte für die
              // Schrift übrig, und am A14 war „Aurora" trotzdem an der
              // Unterkante angeschnitten. Nebeneinander gibt es das Problem
              // nicht: Die Leiste hat die Breite übrig, nicht die Höhe.
              //
              // Der Verlauf ist derselbe Regenbogen, nur aufgehellt. Die
              // gesättigte Fassung sprang aus einer Fläche heraus, auf der
              // Sättigung eine Aufgabe hat (Regel 4): Was volle Farbe trägt,
              // muss im schlechtesten Zustand gefunden werden. Eine Wortmarke
              // muss das nicht — sie steht da, sie ruft nicht.
              leadingWidth: 172,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo_rainbow.png',
                      height: 30,
                      width: 30,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFA8A8), // Rosé
                            Color(0xFFFFCE8A), // Gold
                            Color(0xFF8FE6D8), // Türkis
                            Color(0xFF9BCCF7), // Hellblau
                            Color(0xFFCBAAF2), // Flieder
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Aurora',
                          // Die Wortmarke wächst nicht mit der Systemschrift:
                          // Sie ist Marke, kein Inhalt, und bei 1,5 sprengte
                          // sie die Leiste. Alles Lesbare auf dieser Fläche
                          // skaliert weiterhin.
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Der aktive Anteil steht hier, wo vorher „Anker" stand.
              //
              // Er stand vorher als Karte im Menü darunter — und das Wort
              // „Anker" hier oben sagte nichts, was die Fläche nicht schon
              // durch ihr Aussehen sagt. Die Karte kostete rund neunzig
              // Punkte Höhe, die jetzt der Zeitkarte gehören; die beantwortet
              // die dringendere Frage.
              //
              // Doppelt steht der Name damit nicht: Die Karte darunter ist
              // weg, und das ist die Bedingung dafür, dass er hier stehen
              // darf.
              // Kein Titel mehr in der Zeile.
              //
              // Der Name stand hier, weil er beim Scrollen sichtbar bleiben
              // muss („wer bin ich gerade?"). Diese Bedingung erfüllt jetzt
              // der `AnchorHeader` darunter genauso: Er steht fest über der
              // Liste und scrollt nicht mit. Dort hat er den Platz für Gruß
              // und Begleiter, den eine Titelzeile nicht hergibt — und
              // zweimal darf der Name nicht stehen.
              title: ValueListenableBuilder(
                valueListenable: getIt<ProfileService>().settingsBox
                    .listenable(),
                builder: (context, box, _) {
                  final profile = getIt<ProfileService>().activeProfile;
                  // Ohne aktiven Anteil gibt es keinen Kopfblock, der den
                  // Namen der Fläche tragen könnte.
                  if (profile == null) {
                    return Text(
                      l10n.anchorTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              centerTitle: false,
              actions: [
                const GpsStatusAction(),
                // Das Zahnrad ist aus dem Titel hierher gewandert, weil der
                // Titel weg ist. Was dahinter liegt, ist unverändert:
                // Profil bearbeiten, Einstellungen, Ausloggen — nichts davon
                // wechselt den Anteil. Der Wechsel steht als eigener Weg im
                // Kopfblock, benannt nach seinem Zweck.
                ValueListenableBuilder(
                  valueListenable: getIt<ProfileService>().settingsBox
                      .listenable(),
                  builder: (context, box, _) {
                    final profile = getIt<ProfileService>().activeProfile;
                    if (profile == null) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: l10n.menuSettings,
                      onPressed: () => _showProfileMenu(context, profile),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Der Anker. Kein Karussell, kein PageView, keine dritte Schicht:
            // Von hier führt jeder Weg in genau einen Bereich und zurück.
            body: ValueListenableBuilder(
              valueListenable: getIt<ProfileService>().settingsBox.listenable(),
              builder: (context, box, _) {
                final activeProfile = getIt<ProfileService>().activeProfile;
                final visibleTabs = _getVisibleTabs();
                // Die Karte nimmt, was der Block hergibt — höchstens 280.
                //
                // 180 waren zu wenig: Oben und unten liegt je ein Zeitstrang,
                // dazwischen standen Standort, Orte, Wechselmarken und Zeiten
                // übereinander. Die Profilkarte ist in die Titelzeile
                // gewandert und hat ihre Höhe hier gelassen — genug, dass die
                // Karte auch die Wechselpunkte wieder trägt.
                //
                // Aber 280 war eine feste Zahl an einer Stelle, die keine
                // Fläche kennt. Auf dem S24 blieb darunter zu wenig für eine
                // ganze Kachelreihe.
                //
                // Hier wird nur noch abgezogen, was neben der Karte im Block
                // steht. Was aus dem Rest wird, entscheidet die Karte selbst
                // (`TimeMap.hoeheFuerBlock`) — sie kennt ihre Grenzen, diese
                // Stelle kennt sie nicht.
                TimeMap timeMapFuer(double platz) => TimeMap.fromServices(
                  profile: activeProfile,
                  height: TimeMap.hoeheFuerBlock(platz),
                  onTap: _openTimelineIfAllowed,
                );

                return AnchorMenu(
                  // Fest über der Liste, nicht in ihr: Gruß, Name, der Weg
                  // zum Anteilswechsel und der Begleiter.
                  header: activeProfile == null
                      ? null
                      : AnchorHeader(
                          profile: activeProfile,
                          onSwitchProfile: () =>
                              getIt<ProfileService>().performLogout(
                                context,
                                reason: 'Anteil wechseln',
                              ),
                        ),
                  // Der Kopfblock bekommt eine Obergrenze und teilt sie selbst
                  // auf. Vorher zog diese Stelle eine feste Zahl ab
                  // (`_bannerNebenDerZeitkarte = 60`) für alles, was neben der
                  // Zeitkarte im Block steht — und wer dort etwas ergänzte,
                  // änderte die Höhe und nicht die Zahl. Genau das ist am
                  // 11. August zum vierten Mal passiert, als der
                  // Telemetrie-Hinweis dazukam und die erste Kachelreihe aus
                  // dem Bild schob.
                  //
                  // Jetzt messen die Nachbarn sich selbst: Sie nehmen ihre
                  // natürliche Höhe, die Karte bekommt als einziges
                  // `Flexible` den Rest und entscheidet über
                  // `TimeMap.hoeheFuerBlock`, was sie daraus macht. Kommt hier
                  // etwas dazu, schrumpft die Karte — nicht die Kachelreihe
                  // darunter.
                  // Der Kopfblock teilt seine Obergrenze selbst auf. Vorher
                  // zog diese Stelle eine feste Zahl ab für alles, was neben
                  // der Zeitkarte liegt — wer dort etwas ergänzte, änderte die
                  // Höhe und nicht die Zahl, und die erste Kachelreihe fiel
                  // aus dem Bild. Viermal passiert, zuletzt am 11. August.
                  banner: (verfuegbareHoehe) => AnkerKopfblock(
                    verfuegbar: verfuegbareHoehe,
                    resetHinweis: _buildPasswordResetBanner(context),
                    // „Wann bin ich" vor „wer bin ich": Zeitverlust gehört zum
                    // Krankheitsbild, und die Profilkarte darunter beantwortet
                    // nur die zweite Frage. Fehlt der Weg, zeichnet die Karte
                    // sich selbst weg und die Zeilen treten an ihre Stelle.
                    karteBauen: timeMapFuer,
                    // „Was dieser Tag trägt" — Termine und Medikamente. Die
                    // Zeitkarte kennt keine Medikamente, und genau die fehlten
                    // auf der Fläche, auf der man nach Zeitverlust landet.
                    //
                    // Zählen und Aktualisieren liegen im Lesemodell, nicht in
                    // dieser Ansicht. Hier standen einmal zwei Hive-Boxen von
                    // Diensten — die Oberfläche griff damit an DataEntry
                    // vorbei.
                    tagesUeberblick: TodayOverviewLine(
                      profile: activeProfile,
                      countEventsForDay: _todayOverview.countEventsForDay,
                      countMedicationsToday:
                          _todayOverview.countMedicationsToday,
                      refresh: _todayOverview,
                    ),
                  ),
                  groups: [
                    // Feste Reihenfolge der Gruppen. Eine Gruppe, in der dieses
                    // Profil nichts sehen darf, entfällt ganz — eine Überschrift
                    // ohne Zeilen wäre eine Frage ohne Antwort.
                    for (final section in AnchorSection.values)
                      if (visibleTabs.any((tab) => tab.section == section))
                        AnchorGroup(
                          label: section.label(l10n),
                          emphasis: section.emphasis,
                          entries: [
                            for (final tab in visibleTabs)
                              if (tab.section == section)
                                AnchorEntry(
                                  icon: tab.tabItem.icon,
                                  label: tab.tabItem.label(l10n),
                                  color: tab.color,
                                  onTap: () => _openWorkSurface(tab),
                                  imageAsset: tab.tabItem.image,
                                ),
                          ],
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Wer gerade vorn ist — in der Titelzeile des Ankers.
///
/// Bild zuerst, Wort daneben: Wer den Anteil nicht liest, erkennt ihn am
/// Gesicht und an der Farbe. Der Pfeil rechts sagt, dass sich das hier ändern
/// lässt; er ist der einzige Weg zum Wechsel und steht deshalb ständig da.
///
/// Die Fläche ist die ganze Zeile, nicht nur der Pfeil. Ein Ziel von wenigen
/// Punkten Breite trifft niemand, dessen Hände zittern — und in dem Zustand,
/// in dem man wechseln will, zittern sie oft.
// Die Profilzeile der Kopfzeile stand hier. Sie ist im `AnchorHeader`
// aufgegangen: Der steht ebenfalls fest über der Liste, erfüllt damit
// dieselbe Zusage („wer bin ich gerade?", ständig sichtbar) und hat den
// Platz für Gruß, Anteilswechsel und Begleiter, den eine Titelzeile nicht
// hergibt. Das Zahnrad ist als eigene Aktion in die Titelzeile gewandert.
