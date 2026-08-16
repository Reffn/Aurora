import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/profile_events.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/core/startup_state.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/chat_message.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/contact_comment.dart';
import 'package:dis_app/models/contact_rating.dart';
import 'package:dis_app/models/diary_comment.dart';
import 'package:dis_app/models/diary_entry.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/notification_queue_entry.dart';
import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:dis_app/models/puzzle_config.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/calendar_service.dart';
import 'package:dis_app/services/chat_service.dart';
import 'package:dis_app/services/comment_service.dart';
import 'package:dis_app/services/contact_service.dart';
import 'package:dis_app/services/diary_service.dart';
import 'package:dis_app/services/emergency_message_service.dart';
import 'package:dis_app/services/feedback_sender.dart';
import 'package:dis_app/services/finder_service.dart';
import 'package:dis_app/services/geocoding_service.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:dis_app/services/medication_service.dart';
import 'package:dis_app/services/navigation_service.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:dis_app/services/password_reset_service.dart';
import 'package:dis_app/services/permission_preset_service.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:dis_app/services/puzzle_image_service.dart';
import 'package:dis_app/services/reminders/reminder_reconciler.dart';
import 'package:dis_app/services/reminders/reminder_scheduler.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:dis_app/services/telemetry_dispatcher.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:dis_app/services/tile_cache_manager.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:dis_app/services/translation_service.dart';
import 'package:dis_app/services/transmission_log_service.dart';
import 'package:dis_app/services/transport/firebase_start.dart';
import 'package:dis_app/services/transport/firestore_transport.dart';
import 'package:dis_app/services/transport/mailto_transport.dart';
import 'package:dis_app/services/transport/telemetry_transport.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Globale GetIt-Instanz für Dependency Injection
final getIt = GetIt.instance;

/// Flag to track if deferred services are initialized
bool _deferredServicesInitialized = false;

/// Registriert einen Hive-Adapter, sofern es ihn noch nicht gibt.
///
/// Die Adapterregistratur ist global und gehört nicht der DI: `getIt.reset()`
/// räumt sie nicht mit. Beim zweiten Startanlauf — den die Fehlerfläche nach
/// einem gescheiterten Start anbietet — lief die ungeprüfte Registrierung
/// deshalb in einen `HiveError`, und aus „noch einmal versuchen" wurde eine
/// Sackgasse. Genau dort braucht sie aber jemand, der nicht weiterkommt.
void _registerAdapter<T>(TypeAdapter<T> adapter) {
  if (Hive.isAdapterRegistered(adapter.typeId)) return;
  Hive.registerAdapter(adapter);
}

/// Alle Adapter dieser App, wiederholbar.
///
/// Öffentlich, damit ein Test den zweiten Anlauf prüfen kann, ohne den ganzen
/// Start mit Dateisystem und Diensten nachzubauen.
@visibleForTesting
void registerHiveAdapters() {
  _registerAdapter(ProfileAdapter());
  _registerAdapter(ChatMessageAdapter());
  _registerAdapter(MessageTypeAdapter());
  _registerAdapter(CalendarEventAdapter());
  _registerAdapter(MedicationAdapter());
  _registerAdapter(MedicationLogAdapter());
  _registerAdapter(MedicationStatusAdapter());
  _registerAdapter(MedicationTypeAdapter());
  _registerAdapter(ContactAdapter());
  _registerAdapter(ContactCategoryAdapter());
  _registerAdapter(ContactRatingAdapter());
  _registerAdapter(ContactCommentAdapter());
  _registerAdapter(FinderItemAdapter());
  _registerAdapter(FinderItemTypeAdapter());
  _registerAdapter(EntryPriorityAdapter());
  _registerAdapter(DiaryEntryAdapter());
  _registerAdapter(EntryMoodAdapter());
  _registerAdapter(DiaryCommentAdapter());
  _registerAdapter(CommentAdapter());
  _registerAdapter(CommentableTypeAdapter());
  _registerAdapter(PuzzleTypeAdapter());
  _registerAdapter(PuzzleImageSourceAdapter());
  _registerAdapter(PuzzleDifficultyAdapter());
  _registerAdapter(PuzzleConfigAdapter());
  _registerAdapter(LocationHistoryEntryAdapter());
  _registerAdapter(ProfileSwitchEventAdapter());
  _registerAdapter(NotificationQueueEntryAdapter());
  _registerAdapter(TransmissionLogEntryAdapter());
  _registerAdapter(TransmissionStatusAdapter());
  _registerAdapter(TransmissionChannelAdapter());
  // Ohne diesen Adapter nimmt Hive kein PendingTelemetryEvent an: die
  // Warteschlange bleibt leer und wer zustimmt, dessen Meldungen gehen still
  // verloren — sichtbar nur als HiveError im Log.
  _registerAdapter(PendingTelemetryEventAdapter());
}

/// Essential Dependency Injection Setup (Phase 1)
/// Initialisiert nur kritische Services für ersten Frame:
/// - ProfileService (benötigt für Theme)
/// - NavigationService (benötigt für Routing)
Future<void> setupEssentialDependencies() async {
  final setupStartTime = DateTime.now();
  logger.info(LogCategory.service, '🚀 Essential DI Setup started');

  // Logger als erstes registrieren (damit er überall verfügbar ist)
  getIt.registerSingleton<AppLogger>(logger);

  // Hive initialisieren
  var stepStart = DateTime.now();
  await Hive.initFlutter();
  logger.info(
    LogCategory.service,
    '  ✓ Hive.initFlutter()',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Hive Type Adapters registrieren
  stepStart = DateTime.now();
  registerHiveAdapters();
  logger.info(
    LogCategory.service,
    '  ✓ Hive Adapters registered',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // FMTC (Flutter Map Tile Caching) v10 - for persistent offline map tiles
  stepStart = DateTime.now();
  logger.info(
    LogCategory.service,
    '  → FMTC: Starting ObjectBox backend init...',
  );
  try {
    final fmtcBackend = FMTCObjectBoxBackend();
    await fmtcBackend.initialise();
    logger.info(LogCategory.service, '  → FMTC: ObjectBox backend initialized');
    await const FMTCStore('mapStore').manage.create();
    logger.info(
      LogCategory.service,
      '  ✓ FMTC v10 initialized (tile cache store created)',
      data: {
        'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
      },
    );
  } catch (e, stackTrace) {
    logger.error(
      LogCategory.service,
      '  ✗ FMTC initialization FAILED',
      data: {'error': e.toString()},
      stackTrace: stackTrace,
    );
    logger.warning(
      LogCategory.service,
      '  ⚠️ Continuing without FMTC tile cache',
    );
  }

  // Den Anhang-Ordner einmal aufloesen.
  //
  // Danach kommt jeder Avatar synchron an seinen Pfad. Vorher fragte jedes
  // Bild-Widget im `build` danach -- ein Plattform-Kanal und eine
  // Dateisystem-Abfrage pro Neuaufbau und Avatar, auf jedem Bildschirm.
  stepStart = DateTime.now();
  await AttachmentHelper.warmUp();
  logger.info(
    LogCategory.service,
    '  ✓ Anhang-Ordner aufgeloest',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Core
  stepStart = DateTime.now();
  getIt.registerSingleton<EventBus>(EventBus());
  logger.info(
    LogCategory.service,
    '  ✓ EventBus registered',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // ESSENTIAL: PermissionPresetService — muss VOR dem ProfileService stehen:
  // dessen Profil-Migration holt sich für Profile ohne Berechtigungen das
  // Standard-Preset über getIt. Stand er dahinter, hing die App beim Start
  // an einem StateError, sobald ein solches Profil in der Box lag.
  stepStart = DateTime.now();
  final permissionPresetService = PermissionPresetService();
  await permissionPresetService.initialize();
  getIt.registerSingleton<PermissionPresetService>(permissionPresetService);
  logger.info(
    LogCategory.service,
    '  ✓ PermissionPresetService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // ESSENTIAL: ProfileService (benötigt für Theme)
  stepStart = DateTime.now();
  logger.info(LogCategory.service, '  → ProfileService: Creating instance...');
  final profileService = ProfileService(getIt<EventBus>());
  logger.info(
    LogCategory.service,
    '  → ProfileService: Calling initialize()...',
  );
  await profileService.initialize();
  logger.info(
    LogCategory.service,
    '  → ProfileService: Ensuring single profile is admin...',
  );
  await _ensureSingleProfileIsAdmin(profileService);
  getIt.registerSingleton<ProfileService>(profileService);
  logger.info(
    LogCategory.service,
    '  ✓ ProfileService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // ESSENTIAL: NavigationService (benötigt für Routing)
  stepStart = DateTime.now();
  final navigationService = NavigationService(getIt<EventBus>());
  await navigationService.initialize();
  getIt.registerSingleton<NavigationService>(navigationService);
  logger.info(
    LogCategory.service,
    '  ✓ NavigationService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  final totalDuration = DateTime.now().difference(setupStartTime);
  logger.info(
    LogCategory.service,
    '✅ Essential DI Setup completed',
    data: {'totalDuration': '${totalDuration.inMilliseconds}ms'},
  );
}

/// Deferred Dependency Injection Setup (Phase 2)
/// Initialisiert nicht-kritische Services nach erstem Frame
/// Kann parallel im Hintergrund laufen
Future<void> setupDeferredDependencies() async {
  // Verhindere doppelte Initialisierung
  if (_deferredServicesInitialized) {
    logger.info(
      LogCategory.service,
      '⏭️  Deferred services already initialized, skipping',
    );
    return;
  }

  final setupStartTime = DateTime.now();
  logger.info(LogCategory.service, '🔄 Deferred DI Setup started');

  var stepStart = DateTime.now();

  // Password Reset Service (benötigt ProfileService)
  stepStart = DateTime.now();
  final passwordResetService = PasswordResetService(
    getIt<ProfileService>(),
    getIt<EventBus>(),
  );
  await passwordResetService.initialize();
  getIt.registerSingleton<PasswordResetService>(passwordResetService);
  logger.info(
    LogCategory.service,
    '  ✓ PasswordResetService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  stepStart = DateTime.now();
  final chatService = ChatService(getIt<EventBus>());
  await chatService.initialize();
  getIt.registerSingleton<ChatService>(chatService);
  logger.info(
    LogCategory.service,
    '  ✓ ChatService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  stepStart = DateTime.now();
  final calendarService = CalendarService(getIt<EventBus>());
  await calendarService.initialize();
  getIt.registerSingleton<CalendarService>(calendarService);
  logger.info(
    LogCategory.service,
    '  ✓ CalendarService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  stepStart = DateTime.now();
  final medicationService = MedicationService(getIt<EventBus>());
  await medicationService.initialize();
  getIt.registerSingleton<MedicationService>(medicationService);
  logger.info(
    LogCategory.service,
    '  ✓ MedicationService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  stepStart = DateTime.now();
  final contactService = ContactService(getIt<EventBus>());
  await contactService.initialize();
  getIt.registerSingleton<ContactService>(contactService);
  logger.info(
    LogCategory.service,
    '  ✓ ContactService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Migration: Convert existing emergency category contacts to isEmergencyContact flag
  stepStart = DateTime.now();
  await _migrateEmergencyContacts(contactService);
  logger.info(
    LogCategory.service,
    '  ✓ Emergency contacts migrated',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  stepStart = DateTime.now();
  final finderService = FinderService(getIt<EventBus>());
  await finderService.initialize();
  getIt.registerSingleton<FinderService>(finderService);
  logger.info(
    LogCategory.service,
    '  ✓ FinderService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  stepStart = DateTime.now();
  final diaryService = DiaryService(getIt<EventBus>());
  await diaryService.initialize();
  getIt.registerSingleton<DiaryService>(diaryService);
  logger.info(
    LogCategory.service,
    '  ✓ DiaryService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Unified Comment Service (replaces separate diary/contact comment logic)
  stepStart = DateTime.now();
  final commentService = CommentService(getIt<EventBus>());
  await commentService.initialize();
  getIt.registerSingleton<CommentService>(commentService);
  logger.info(
    LogCategory.service,
    '  ✓ CommentService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Map Service (v3.1 - Finder Feature)
  stepStart = DateTime.now();
  final mapService = MapService(getIt<EventBus>());
  await mapService.initialize();
  getIt.registerSingleton<MapService>(mapService);
  logger.info(
    LogCategory.service,
    '  ✓ MapService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Tile Cache Manager (for persistent map tile caching with LRU)
  stepStart = DateTime.now();
  final tileCacheManager = TileCacheManager(getIt<EventBus>());
  await tileCacheManager.initialize();
  getIt.registerSingleton<TileCacheManager>(tileCacheManager);
  logger.info(
    LogCategory.service,
    '  ✓ TileCacheManager initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Geocoding Service (v3.1 - Adress-Suche via Nominatim)
  stepStart = DateTime.now();
  getIt.registerSingleton<GeocodingService>(GeocodingService());
  logger.info(
    LogCategory.service,
    '  ✓ GeocodingService registered',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // GPS Manager (v3.1 - Zentrale Position-Autorität)
  // Benötigt Contact/Finder Boxes (bereits von Services geöffnet)
  stepStart = DateTime.now();
  getIt.registerSingleton<GpsManager>(
    GpsManager(
      eventBus: getIt<EventBus>(),
      contactsBox: await Hive.openBox<Contact>(HiveBoxNames.contacts),
      finderItemsBox: await Hive.openBox<FinderItem>(HiveBoxNames.finderItems),
    ),
  );
  logger.info(
    LogCategory.service,
    '  ✓ GpsManager registered',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Translation Service (benötigt keine Hive Box)
  stepStart = DateTime.now();
  getIt.registerSingleton<TranslationService>(TranslationService());
  logger.info(
    LogCategory.service,
    '  ✓ TranslationService registered',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Puzzle Image Service (für Spiele & Entspannung)
  stepStart = DateTime.now();
  getIt.registerSingleton<PuzzleImageService>(PuzzleImageService());
  logger.info(
    LogCategory.service,
    '  ✓ PuzzleImageService registered',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Location Tracking Service (für Zeitachse & GPS-Tracking)
  stepStart = DateTime.now();
  final locationHistoryBox = await Hive.openBox<LocationHistoryEntry>(
    HiveBoxNames.locationHistory,
  );
  final switchEventsBox = await Hive.openBox<ProfileSwitchEvent>(
    HiveBoxNames.profileSwitches,
  );
  final locationTrackingService = LocationTrackingService(
    locationHistoryBox: locationHistoryBox,
    switchEventsBox: switchEventsBox,
    settingsBox: getIt<ProfileService>().settingsBox,
    eventBus: getIt<EventBus>(),
    geocodingService: getIt<GeocodingService>(),
    gpsManager: getIt<GpsManager>(),
  );
  getIt.registerSingleton<LocationTrackingService>(locationTrackingService);
  logger.info(
    LogCategory.service,
    '  ✓ LocationTrackingService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Timeline Data Service (für Zeitstrahl-Visualisierung)
  stepStart = DateTime.now();
  final medicationLogsBox = await Hive.openBox<MedicationLog>(
    HiveBoxNames.medicationLogs,
  );
  final calendarEventsBox = await Hive.openBox<CalendarEvent>(
    HiveBoxNames.calendarEvents,
  );
  final medicationsBox = await Hive.openBox<Medication>(
    HiveBoxNames.medications,
  );
  getIt.registerSingleton<TimelineDataService>(
    TimelineDataService(
      profileSwitchBox: switchEventsBox,
      medicationLogsBox: medicationLogsBox,
      calendarEventsBox: calendarEventsBox,
      medicationsBox: medicationsBox,
      profilesBox: getIt<ProfileService>().profilesBox,
      profileService: getIt<ProfileService>(),
    ),
  );
  logger.info(
    LogCategory.service,
    '  ✓ TimelineDataService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Notification Service (für lokale Benachrichtigungen)
  stepStart = DateTime.now();

  // Die gewählte Sprache muss stehen, bevor die erste Meldung vorgemerkt
  // wird. Ihr Wortlaut steht ab dem Vormerken fest, und der Abgleich läuft
  // hier — lange bevor MaterialApp die Sprache in den Widget-Baum bindet.
  // Ohne diese Zeile plante jeder Kaltstart auf Deutsch.
  AppTexts.useLocaleTag(
    getIt<ProfileService>().settingsBox.get('selected_locale') as String?,
  );

  final notificationService = NotificationService(getIt<EventBus>());

  // Der Abgleich muss stehen, bevor der Dienst hochfährt: sein
  // postInitialize() ruft ihn als Erstes. Registriert wird der Dienst
  // selbst aber erst danach — deshalb bekommt der Abgleich hier die
  // Instanz direkt und nicht über getIt.
  getIt.registerLazySingleton<ReminderScheduler>(
    () => PluginReminderScheduler.forApp(
      channelId: NotificationService.androidChannelId,
      channelName: AppTexts.current.notificationChannelName,
    ),
  );
  getIt.registerLazySingleton<ReminderReconciler>(
    () => ReminderReconciler(
      scheduler: getIt<ReminderScheduler>(),
      readMedications: () => getIt<MedicationService>().allMedications,
      readLogs: () => getIt<MedicationService>().logsBox.values.toList(),
      readEvents: () => getIt<CalendarService>().events,
      readPermission: notificationService.hasPermission,
      readDiscreet: () => notificationService.discreetReminders,
    ),
  );

  // Ein Sprachwechsel macht jede vorgemerkte Meldung falsch — der Wortlaut
  // steht seit dem Vormerken fest. Der Abgleich erkennt die neue Fassung und
  // schreibt sie neu; ohne dieses Signal bliebe die alte Sprache stehen, bis
  // die Meldung erscheint.
  AppTexts.localeTag.addListener(() {
    if (!getIt.isRegistered<ReminderReconciler>()) return;
    unawaited(getIt<ReminderReconciler>().reconcile());
  });

  await notificationService.initialize();
  getIt.registerSingleton<NotificationService>(notificationService);

  // Ein Dienst, dessen Initialisierung geworfen hat, ist nicht bereit — auch
  // wenn er registriert ist. Vorher stand hier in jedem Fall ein Haken im
  // Log, und ein stumm gescheiterter Meldungsdienst sah aus wie ein
  // laufender. Die App startet trotzdem: Erinnerungen sind wichtig, aber
  // nicht die Bedingung dafür, überhaupt hineinzukommen.
  if (notificationService.isReady) {
    logger.info(
      LogCategory.service,
      '  ✓ NotificationService initialized',
      data: {
        'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
      },
    );
  } else {
    logger.error(
      LogCategory.service,
      '  ✗ NotificationService nicht bereit - Erinnerungen fallen aus',
    );
    startupState.value = StartupState(
      StartupPhase.degraded,
      degradedServices: [
        ...startupState.value.degradedServices,
        'notifications',
      ],
    );
  }

  // Transmission Log Service (für lokale Übertragungsprotokollierung)
  stepStart = DateTime.now();
  final transmissionLogBox = await Hive.openBox<TransmissionLogEntry>(
    HiveBoxNames.transmissionLog,
  );
  getIt.registerSingleton<TransmissionLogService>(
    TransmissionLogService(box: transmissionLogBox),
  );
  logger.info(
    LogCategory.service,
    '  ✓ TransmissionLogService initialized',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Transport Services (Firestore & Mailto)
  stepStart = DateTime.now();
  getIt.registerSingleton<FirestoreTransport>(FirestoreTransport());
  getIt.registerSingleton<MailtoTransport>(MailtoTransport());

  // Der Sender kennt die Reihenfolge der Wege und protokolliert jeden Versuch.
  // Die Formulare rufen nur noch ihn — keines baut den Ablauf selbst nach.
  getIt.registerSingleton<FeedbackSender>(
    FeedbackSender(
      primary: getIt<FirestoreTransport>(),
      fallback: getIt<MailtoTransport>(),
      record: getIt<TransmissionLogService>().record,
      // Firebase startet im Sendeversuch, nicht im App-Start.
      // Siehe `FirebaseStart` und docs/befund-stiller-firebase-start.md.
      starteFirebase: firebaseBeimSendenStarten,
    ),
  );
  logger.info(
    LogCategory.service,
    '  ✓ Transport services registered (Firestore, Mailto, Sender)',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Telemetrie
  //
  // Reihenfolge zählt: Die Einwilligung zuerst, weil der Recorder sie braucht
  // und ohne sie nichts anlegen darf.
  stepStart = DateTime.now();
  // Ohne Versionsinfo startet die App trotzdem — Telemetrie meldet dann 'unbekannt'
  String appVersion;
  try {
    appVersion = (await PackageInfo.fromPlatform()).version;
  } catch (e) {
    appVersion = 'unbekannt';
    logger.warning(
      LogCategory.service,
      'PackageInfo unavailable, using fallback app version',
      data: {'error': e.toString()},
    );
  }
  final telemetrySettingsBox = await Hive.openBox<dynamic>(
    HiveBoxNames.settings,
  );
  final telemetryQueueBox = await Hive.openBox<PendingTelemetryEvent>(
    HiveBoxNames.telemetryQueue,
  );
  final telemetryConsent = TelemetryConsent.fromBox(telemetrySettingsBox);
  final telemetryTransport = FirestoreTelemetryTransport();

  getIt
    ..registerSingleton<TelemetryConsent>(telemetryConsent)
    ..registerSingleton<TelemetryRecorder>(
      TelemetryRecorder(
        consent: telemetryConsent,
        queue: telemetryQueueBox,
        // Nur die Release-Version, nie die Build-Nummer: Bei rund zehn
        // zustimmenden Geräten wäre eine seltene Build-Nummer ein Merkmal.
        appVersion: appVersion,
      ),
    )
    ..registerSingleton<FirestoreTelemetryTransport>(telemetryTransport)
    ..registerSingleton<TelemetryDispatcher>(
      TelemetryDispatcher(
        queue: telemetryQueueBox,
        transport: telemetryTransport,
        record: getIt<TransmissionLogService>().record,
        // Nur wenn wirklich etwas ansteht — der Dispatcher prüft die
        // Warteschlange, bevor er das hier ruft.
        starteFirebase: firebaseBeimSendenStarten,
      ),
    );

  // Ein neues Ereignis geht sofort raus, nicht erst beim nächsten Start.
  //
  // Erst hier verdrahtet, weil der Recorder vor dem Dispatcher entsteht und
  // nichts vom Versand wissen soll. Ohne `await`: Kein Ereignis darf den
  // Bedienfluss aufhalten, und was fehlschlägt, bleibt in der Warteschlange.
  getIt<TelemetryRecorder>().onRecorded = () =>
      unawaited(getIt<TelemetryDispatcher>().flush());

  // Erst hier, weil der GpsManager lange vorher entsteht und nichts von der
  // Telemetrie weiß. Gemeldet wird nur, dass ein Positionsabruf scheiterte —
  // kein Grund, kein Ort.
  getIt<GpsManager>().onPositionFailed = () => unawaited(
    getIt<TelemetryRecorder>().record(TelemetryEventName.fehlerGpsTimeout),
  );

  // Einrichtung abgeschlossen — einmal je Installation.
  //
  // Bis zum 13.08.2026 war das der groesste blinde Fleck: Onboarding-Abbrueche
  // wurden seitengenau gezaehlt, und danach kam nichts mehr. Wer beim ersten
  // Profil aufgab, hinterliess keine Spur.
  //
  // Angehaengt wird am EventBus, nicht an `DataEntry` oder `ProfileService`:
  // Beide sollen nichts von Telemetrie wissen — dasselbe Muster wie beim
  // GpsManager eine Zeile hoeher.
  //
  // **Einmal, nicht je Profil.** Firestore setzt `createTime` serverseitig;
  // drei Eingaenge derselben Minute waeren lesbar als „dieses System hat drei
  // Anteile". Der Merker wird deshalb VOR dem Melden gesetzt: Bricht der
  // Versand ab, bleibt die Meldung aus — eine doppelte waere schlimmer als
  // eine fehlende.
  const einrichtungGemeldetKey = 'einrichtung_gemeldet';
  final settingsBox = getIt<ProfileService>().settingsBox;
  getIt<EventBus>().on<ProfileCreatedEvent>().listen((_) async {
    if (settingsBox.get(einrichtungGemeldetKey) == true) return;

    await settingsBox.put(einrichtungGemeldetKey, true);
    await getIt<TelemetryRecorder>().record(
      TelemetryEventName.einrichtungAbgeschlossen,
    );
  });

  // Eine geplante Erinnerung ist der Beweis, dass der Pfad traegt. Genau der
  // ist mehrfach lautlos ausgefallen — fehlende Empfaenger, von R8 verworfene
  // Signaturen, Kennungen ohne Zeitpunkt.
  getIt<ReminderReconciler>().onRemindersScheduled = () => unawaited(
    getIt<TelemetryRecorder>().record(TelemetryEventName.erinnerungGeplant),
  );
  logger.info(
    LogCategory.service,
    '  ✓ Telemetry registered (Consent, Recorder, Transport, Dispatcher)',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Data Entry (zentrale Eingangsschnittstelle) - NACH Services registrieren
  stepStart = DateTime.now();
  getIt.registerSingleton<DataEntry>(
    DataEntry(
      getIt<EventBus>(),
      chatService: chatService,
      profileService: getIt<ProfileService>(),
      calendarService: calendarService,
      medicationService: medicationService,
      contactService: contactService,
      finderService: finderService,
      diaryService: diaryService,
      commentService: getIt<CommentService>(),
      navigationService: getIt<NavigationService>(),
      passwordResetService: getIt<PasswordResetService>(),
    ),
  );
  logger.info(
    LogCategory.service,
    '  ✓ DataEntry registered',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  // Emergency Message Service (für Notfall-Kommunikation)
  stepStart = DateTime.now();
  getIt.registerSingleton<EmergencyMessageService>(
    EmergencyMessageService(getIt<DataEntry>(), getIt<GpsManager>()),
  );
  logger.info(
    LogCategory.service,
    '  ✓ EmergencyMessageService registered',
    data: {
      'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
    },
  );

  _deferredServicesInitialized = true;

  final totalDuration = DateTime.now().difference(setupStartTime);
  logger.info(
    LogCategory.service,
    '✅ Deferred DI Setup completed',
    data: {'totalDuration': '${totalDuration.inMilliseconds}ms'},
  );
}

/// Legacy wrapper für Kompatibilität (initialisiert alles sequenziell)
/// @deprecated Use setupEssentialDependencies() + setupDeferredDependencies()
@Deprecated('Use two-phase initialization for better performance')
Future<void> setupDependencyInjection() async {
  await setupEssentialDependencies();
  await setupDeferredDependencies();
}

/// Failsafe: Wenn nur ein einziges Profil existiert und es kein Admin ist,
/// wird es automatisch zum Admin gemacht
Future<void> _ensureSingleProfileIsAdmin(ProfileService profileService) async {
  final profiles = profileService.profiles;

  // Nur wenn genau 1 Profil existiert
  if (profiles.length == 1) {
    final profile = profiles.first;

    // Wenn es noch kein Admin ist, mache es zum Admin
    if (!profile.isAdmin) {
      logger.info(
        LogCategory.service,
        'Failsafe: Making single profile admin',
        data: {'profileName': profile.name, 'profileId': profile.id},
      );

      final updatedProfile = profile.copyWith(isAdmin: true);
      await profileService.profilesBox.put(profile.id, updatedProfile);
    }
  }
}

/// Migration: Konvertiert bestehende Kontakte mit category=emergency zu isEmergencyContact=true
/// Diese Funktion wird einmalig beim Update ausgeführt und setzt dann für alle
/// Kontakte mit ContactCategory.emergency das neue isEmergencyContact Flag
Future<void> _migrateEmergencyContacts(ContactService contactService) async {
  final contacts = contactService.contacts;
  var migratedCount = 0;

  for (final contact in contacts) {
    // Wenn Kontakt emergency-Kategorie hat, aber isEmergencyContact noch false ist
    if (contact.category == ContactCategory.emergency &&
        !contact.isEmergencyContact) {
      final updatedContact = contact.copyWith(
        isEmergencyContact: true,
        // Setze Kategorie auf "other" um Dopplung zu vermeiden
        category: ContactCategory.other,
      );
      await contactService.update(updatedContact);
      migratedCount++;
    }
  }

  if (migratedCount > 0) {
    logger.info(
      LogCategory.service,
      'Emergency contacts migration completed',
      data: {'migratedCount': migratedCount},
    );
  }
}
