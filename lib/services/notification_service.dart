import 'dart:async';
import 'dart:io';

import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/events/calendar_events.dart';
import 'package:dis_app/core/events/medication_events.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder_reconciler.dart';
import 'package:dis_app/services/reminders/reminder_scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce/hive.dart';
import 'package:timezone/data/latest_all.dart' as tz;

/// Notification Service - Manages local notifications and queue
///
/// ## Architecture:
/// - **Queue in Hive**: Single source of truth for all notifications
/// - **Dual Trigger**: Timer (app running) + AlarmManager (app closed)
/// - **Status Tracking**: scheduled → sent/assumed_shown → confirmed
///
/// ## Notification Patterns:
///
/// **Daily Medications:**
/// - -30min: "Medication in 30 Min"
/// - -10min: "Medication in 10 Min"
/// - 0min: "Take medication NOW"
/// - +10min: Repeat every 10 min until marked as taken
///
/// **As-Needed Medications:**
/// - -30min: "Medication available in 30 min"
/// - -10min: "Medication available in 10 min"
/// - -5min: "Medication available in 5 min"
/// - 0min: "Medication available NOW"
///
/// **Events:**
/// - User-configurable reminder (15min to 1 day before)
///
/// ## Queue Sync:
/// - On app start: Mark past "scheduled" as "assumed_shown"
/// - When app running: Timer checks queue every minute
/// - When app closed: AlarmManager handles native scheduling
class NotificationService extends BaseService {
  NotificationService(super.eventBus);

  // ============================================================================
  // DEPENDENCIES
  // ============================================================================

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late Box<Medication> _medicationsBox;
  late Box<dynamic> _settingsBox;

  // ============================================================================
  // STATE
  // ============================================================================

  bool _isInitialized = false;

  /// Ob der Dienst wirklich hochgefahren ist.
  ///
  /// Die Initialisierung fängt ihre Fehler selbst ab, damit der Start nicht
  /// daran hängt. Ohne diesen Blick nach außen war ein stumm gescheiterter
  /// Dienst von einem laufenden nicht zu unterscheiden — registriert war er
  /// in beiden Fällen.
  bool get isReady => _isInitialized;

  /// Die Sprache fuer die Meldungen.
  ///
  /// Hier stand ein `setLocalization`, das niemand je aufgerufen hat: `_l10n`
  /// blieb null, und jede Benachrichtigung lief auf den englischen
  /// Rueckfallwerten -- auch bei deutscher Spracheinstellung. AppTexts wird
  /// von der Oberflaeche bei jedem Bauen gesetzt, ist also wirklich da.
  AppLocalizations get _l10n => AppTexts.current;

  /// Get localized notification channel name
  String get _localizedChannelName => _l10n.notificationChannelName;

  /// Get localized notification channel description
  String get _localizedChannelDescription =>
      _l10n.notificationChannelDescription;

  // ============================================================================
  // CONSTANTS
  // ============================================================================

  static const String androidChannelId = 'aurora_notifications';

  // ============================================================================
  // LOCALIZED TEXT HELPERS
  // ============================================================================

  /// Get localized test notification title
  String get _testNotificationTitle => _l10n.notificationTestTitle;

  /// Get localized test notification body
  String get _testNotificationBody => _l10n.notificationTestBody;

  // ============================================================================
  // NOTIFICATION DETAILS HELPER
  // ============================================================================

  // Wie eine Meldung aussieht, legt `ReminderScheduler` fest. Hier stand
  // dieselbe Zusammenstellung ein zweites Mal, ohne Aufrufer.

  // ============================================================================
  // BASE SERVICE IMPLEMENTATION
  // ============================================================================

  @override
  Future<void> openBoxes() async {
    _medicationsBox = await Hive.openBox<Medication>(
      HiveBoxNames.medications,
    );

    // Geöffnet, nicht gehalten: Der Abgleich liest die Termine über den
    // CalendarService. Diese Zeile sorgt nur dafür, dass die Kiste offen ist,
    // wenn er fragt — ein Feld dafür wäre eine zweite Wahrheit.
    await Hive.openBox<CalendarEvent>(HiveBoxNames.calendarEvents);

    _settingsBox = await Hive.openBox<dynamic>(HiveBoxNames.settings);

    logger.info(
      LogCategory.service,
      'NotificationService: Boxes opened',
      data: {
        'medications': _medicationsBox.length,
        'discreetReminders': discreetReminders,
      },
    );
  }

  @override
  void subscribeToEvents() {
    // Medikamente: jedes Ereignis löst denselben Abgleich aus.
    //
    // Vorher hatte jedes seine eigene Planungs- und Abbruchlogik, und wer
    // eine Abbruchzeile vergaß, hinterließ einen Alarm für eine erledigte
    // Dosis. `MedicationLogUpdatedEvent` und `MedicationLogDeletedEvent`
    // fehlten hier ganz — eine Korrektur der Einnahme berührte die
    // Erinnerungen also überhaupt nicht.
    eventBus.on<MedicationCreatedEvent>().listen(_reconcileOnEvent);
    eventBus.on<MedicationUpdatedEvent>().listen(_reconcileOnEvent);
    eventBus.on<MedicationDeletedEvent>().listen(_reconcileOnEvent);
    eventBus.on<MedicationTakenEvent>().listen(_reconcileOnEvent);
    eventBus.on<MedicationLogUpdatedEvent>().listen(_reconcileOnEvent);
    eventBus.on<MedicationLogDeletedEvent>().listen(_reconcileOnEvent);

    // Termine: derselbe Abgleich wie bei Medikamenten.
    //
    // Hier standen drei eigene Handler mit eigener Planungs- und
    // Abbruchlogik. Die Termin-Kennung trug kein Datum, weshalb beim
    // Verschieben das Anmelden das Abmelden ueberschrieb -- es wirkte
    // richtig, weil das Ergebnis stimmte und nicht der Weg.
    eventBus.on<CalendarEventCreatedEvent>().listen(_reconcileOnEvent);
    eventBus.on<CalendarEventUpdatedEvent>().listen(_reconcileOnEvent);
    eventBus.on<CalendarEventDeletedEvent>().listen(_reconcileOnEvent);

    logger.info(
      LogCategory.service,
      'NotificationService: Subscribed to events',
    );
  }

  /// Jedes Medikamenten-Ereignis führt zum selben Abgleich.
  ///
  /// Der Ereignistyp ist absichtlich `dynamic`: was genau passiert ist,
  /// spielt keine Rolle mehr. Der Abgleich liest den Bestand neu und
  /// bringt das Betriebssystem auf den Stand — angelegt, geändert,
  /// gelöscht, genommen, korrigiert, alles derselbe Weg.
  Future<void> _reconcileOnEvent(dynamic event) =>
      getIt<ReminderReconciler>().reconcile();

  /// Schlüssel des Migrationsmerkers in der `settings`-Box.
  /// Der Merker steht auf v3, seit auch die Termine ueber den Abgleich
  /// laufen. Auf Geraeten mit v2 liegt sonst der alte Bestand mit
  /// datumslosen Termin-Kennungen fuer immer herum.
  static const String kMigrationKey = 'reminders_migrated_v3';

  /// Einmaliges Aufräumen beim Umstieg auf den Abgleich.
  ///
  /// Der alte Bestand trägt Kennungen ohne Datum und ohne Namensraum. Der
  /// Abgleich könnte sie keinem Soll zuordnen und würde sie für immer
  /// stehen lassen — auf dem Testgerät waren das zehn Alarme aus zwei
  /// vergangenen Tagen.
  Future<void> migrateRemindersOnce() async {
    if (_settingsBox.get(kMigrationKey, defaultValue: false) as bool) return;

    await getIt<ReminderScheduler>().cancelEverything();
    // Die Warteschlange war die zweite Kopie der Wahrheit: eine Liste
    // dessen, was geplant sein sollte, neben dem, was wirklich vorgemerkt
    // war. Seit der Abgleich das Betriebssystem fragt, schreibt sie
    // niemand mehr und liest sie niemand mehr — sie kommt von der Platte.
    await Hive.deleteBoxFromDisk(HiveBoxNames.notificationQueue);

    // Termine muessen hier nicht mehr nachgeplant werden -- der Abgleich
    // im Anschluss deckt sie mit ab.
    await _settingsBox.put(kMigrationKey, true);

    logger.info(
      LogCategory.service,
      'NotificationService: Erinnerungen auf den Abgleich umgestellt',
    );
  }

  @override
  Future<void> closeBoxes() async {
    await _medicationsBox.close();
    // _settingsBox bleibt offen: Hive gibt für denselben Namen dieselbe Box
    // zurück, und andere Dienste halten sie noch. Schließen hier würde sie
    // ihnen unter den Händen wegziehen.
    logger.info(LogCategory.service, 'NotificationService: Closed');
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Plugin-Initialisierung nach Box-Opening
  /// Called by BaseService.initialize() after openBoxes()
  @override
  Future<void> postInitialize() async {
    if (_isInitialized) {
      logger.info(
        LogCategory.service,
        'NotificationService: Already initialized',
      );
      return;
    }

    try {
      // Initialize timezone data for scheduled notifications
      tz.initializeTimeZones();

      // Android initialization settings
      //
      // Nicht das Startsymbol: Android liest bei Meldungssymbolen nur den
      // Alphakanal und färbt alles Übrige weiß. Ein volldeckendes, buntes
      // Bild wird dabei zum Klecks — neben Auroras Erinnerungen stand ein
      // leerer weißer Ring, der Umriss des runden Rahmens. `ic_notification`
      // ist dieselbe Figur als einfarbige Silhouette, erzeugt von
      // `tool/meldungssymbol.py`.
      const androidSettings = AndroidInitializationSettings(
        '@drawable/ic_notification',
      );

      // iOS initialization settings
      final darwinSettings = DarwinInitializationSettings(
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      // Initialize plugin
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationTapped,
      );

      // Create Android notification channel
      if (Platform.isAndroid) {
        await _createAndroidNotificationChannel();
      }

      // Note: Permissions are requested lazily when scheduling notifications
      // (Better UX - only ask when actually needed)

      // Einmaliges Aufräumen beim Umstieg auf den Abgleich.
      await migrateRemindersOnce();

      // Ein Abgleich statt dreier Nachpflegeschritte.
      //
      // Hier standen `syncQueueWithPlatform()`, `rescheduleMissingReminders()`
      // und `_startQueueTimer()` — drei Wege, denselben Rückstand
      // nachzuholen, und keiner fragte je das Betriebssystem, was dort
      // wirklich vorgemerkt ist.
      await getIt<ReminderReconciler>().reconcile();

      _isInitialized = true;

      logger.info(
        LogCategory.service,
        'NotificationService: Initialized successfully',
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'NotificationService: Initialization failed',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Create Android notification channel
  Future<void> _createAndroidNotificationChannel() async {
    final channel = AndroidNotificationChannel(
      androidChannelId,
      _localizedChannelName,
      description: _localizedChannelDescription,
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    logger.info(
      LogCategory.service,
      'NotificationService: Android channel created',
      data: {'channelId': androidChannelId},
    );
  }

  /// Request notification permissions
  ///
  /// Ruft den Systemdialog auf. Nur von einer Handlung des Menschen aus
  /// aufrufen — nie beim Speichern, beim Blättern oder sonst nebenbei.
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Request POST_NOTIFICATIONS permission (Android 13+)
      final granted = await androidPlugin?.requestNotificationsPermission();

      // Die genaue Uhrzeit ist eine eigene Freigabe und ein eigener
      // Systembildschirm. Wir fragen danach, aber sie entscheidet nicht
      // darüber, ob überhaupt erinnert wird — siehe unten.
      final exactAlarmGranted = await androidPlugin
          ?.requestExactAlarmsPermission();

      logger.info(
        LogCategory.service,
        'NotificationService: Permissions requested',
        data: {
          'notifications': granted ?? false,
          'exactAlarms': exactAlarmGranted ?? false,
        },
      );

      // Ohne genaue Alarme kommt die Erinnerung ein paar Minuten später.
      // Sie deshalb ganz ausfallen zu lassen, wäre das schlechtere von zwei
      // Ergebnissen: Vorher gab diese Zeile `granted && exactAlarmGranted`
      // zurück, und auf jedem Gerät ohne Exact-Alarm-Freigabe wurde
      // stillschweigend gar nichts geplant.
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      logger.info(
        LogCategory.service,
        'NotificationService: iOS permissions requested',
        data: {'granted': granted ?? false},
      );

      return granted ?? false;
    }

    return false;
  }

  /// Darf Aurora Benachrichtigungen zeigen? Fragt nicht nach, sieht nur nach.
  ///
  /// Hier stand vorher `_ensurePermissions()`, und das rief in Wahrheit
  /// `requestPermissions()` — also den Systemdialog. Damit sprang beim
  /// Speichern eines Termins der Android-Dialog auf, mitten in einer
  /// Handlung, die mit Berechtigungen nichts zu tun hat. Derselbe Fehler
  /// wie beim Standort: Gefragt wird dort, wo der Mensch den Schalter
  /// umlegt, und sonst nirgends. Alles andere schaut nur nach.
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    if (Platform.isIOS) {
      // iOS beantwortet die Frage nur über den Anfrage-Weg. Ein erneuter
      // Aufruf zeigt nach der ersten Entscheidung keinen Dialog mehr.
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await iosPlugin?.checkPermissions().then(
            (p) => p?.isEnabled ?? false,
          ) ??
          false;
    }
    return false;
  }

  /// Darf Aurora auf die Minute genau erinnern?
  ///
  /// Fehlt diese Freigabe, kommt die Erinnerung trotzdem — nur wenige
  /// Minuten später, wann immer Android das Gerät ohnehin weckt.
  Future<bool> canScheduleExactly() async {
    if (!Platform.isAndroid) return true;
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await androidPlugin?.canScheduleExactNotifications() ?? false;
  }

  // ============================================================================
  // QUEUE TIMER
  // ============================================================================

  // ============================================================================
  // NOTIFICATION SENDING
  // ============================================================================

  /// Send a notification from queue entry
  // ============================================================================
  // DISKRETE ERINNERUNGEN
  // ============================================================================

  /// Schlüssel des Schalters in der `settings`-Box.
  static const String kDiscreetRemindersKey = 'discreet_reminders';

  /// Nennt die Meldung Name und Dosis, oder nur, dass es eine gibt?
  ///
  /// Eine Erinnerung erscheint auf dem Sperrbildschirm, also auch vor Augen,
  /// die nicht dafür gedacht sind. „Ritalin 10mg jetzt nehmen" ist ein
  /// Gesundheitsdatum. Voreingestellt ist Klartext, weil die meisten Menschen
  /// allein auf ihr Telefon sehen und die Meldung sonst nutzlos wäre — wer
  /// nicht allein lebt, schaltet hier um.
  bool get discreetReminders =>
      _settingsBox.get(kDiscreetRemindersKey, defaultValue: false) as bool;

  Future<void> setDiscreetReminders(bool value) async {
    if (value == discreetReminders) return;
    await _settingsBox.put(kDiscreetRemindersKey, value);

    // Vom Betriebssystem vorgemerkte Meldungen tragen ihren Text seit dem
    // Vormerken mit sich. Ohne neues Vormerken bliebe der alte Wortlaut
    // stehen, und der Schalter wäre ein Versprechen ohne Wirkung.
    //
    // `syncQueueWithPlatform()` stand hier und tat genau das nicht: es
    // verglich die Warteschlange mit der Uhr und rührte die vorgemerkten
    // Meldungen nie an.
    await getIt<ReminderReconciler>().reconcile();

    logger.info(
      LogCategory.service,
      'NotificationService: Discreet reminders changed',
      data: {'discreetReminders': value},
    );
  }

  // Die Texte einer Meldung entstehen im Abgleich, nicht hier: `ReminderTexts`
  // kennt `discreet` und entscheidet damit über Titel und Inhalt. Zwei
  // Methoden, die dasselbe noch einmal taten, standen hier bis zum
  // 8. August 2026 unbenutzt herum — Reste aus der Zeit vor dem Abgleich.

  // ============================================================================
  // PLATFORM SCHEDULING (AlarmManager/iOS Fallback)
  // ============================================================================

  // ============================================================================
  // NOTIFICATION CALLBACKS
  // ============================================================================

  /// Jemand hat die Meldung angetippt.
  ///
  /// Der Payload trägt seit dem Abgleich den Zielschlüssel der Erinnerung
  /// (`med|…` oder `evt|…`), keinen Warteschlangeneintrag mehr — die
  /// Warteschlange gab es nur, solange die App selbst zustellte.
  @pragma('vm:entry-point')
  void _onNotificationTapped(NotificationResponse response) {
    logger.info(
      LogCategory.service,
      'NotificationService: Meldung angetippt',
      data: {'ziel': response.payload ?? 'ohne'},
    );
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    // Note: Static method, limited access to instance members
    // Just log for now - use debugPrint for production safety
    debugPrint('[NotificationService] Background tap: ${response.payload}');
  }

  /// Handle iOS local notification (app in foreground)
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    logger.info(
      LogCategory.service,
      'NotificationService: iOS foreground notification',
      data: {'id': id, 'title': title},
    );
  }

  // ============================================================================
  // QUEUE SYNC
  // ============================================================================

  /// Sync queue with platform on app start
  ///
  /// Mark past "scheduled" notifications as "assumed_shown"
  /// Zählt, was zugesagt, aber nicht geplant ist.
  ///
  /// Ein Medikament mit eingeschalteten Erinnerungen und ein Termin mit
  /// `notificationEnabled` behaupten beide, es werde erinnert. Ob dazu auch
  /// etwas in der Warteschlange steht, weiß bisher niemand: fehlte beim
  /// Anlegen die Erlaubnis, brach die Planung mit einer Zeile im Log ab und
  /// der Zustand blieb unsichtbar. Diese Zahl macht ihn abfragbar.
  /// Wie viele Einnahmezeiten tragen ein Erinnerungsversprechen?
  ///
  /// Das Erlaubnisband nennt diese Zahl. Es fragt bewusst nicht die
  /// Warteschlange: die füllt der Abgleich für Medikamente nicht mehr, und
  /// [countUnscheduledPromises] zählte deshalb jedes Medikament als
  /// ungeplant — auch wenn alles ordentlich beim Betriebssystem stand. Die
  /// Frage des Bands ist ohnehin eine andere: nicht „was ist geplant",
  /// sondern „was wurde versprochen".
  int countPromisedIntakeTimes() {
    var zeiten = 0;
    for (final medication in _medicationsBox.values) {
      if (!medication.isActive || !medication.remindersEnabled) continue;
      if (medication.type != MedicationType.daily) continue;
      zeiten += medication.timesOfDay.length;
    }
    return zeiten;
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Wie viele Erinnerungen sind beim Betriebssystem vorgemerkt?
  ///
  /// Fragt das System, nicht die eigene Notiz. Die Einstellungen zeigten
  /// vorher den Inhalt der Warteschlangen-Box — seit der Abgleich plant,
  /// wäre das eine Zahl über eine Liste, die niemand mehr füllt.
  Future<int> countScheduledReminders() async =>
      (await getIt<ReminderScheduler>().pendingOwnIds()).length;

  /// Send a test notification immediately (for debugging)
  /// Uses standard send flow with full permission checking and logging
  /// Zeigt sofort eine Meldung — für die Probe in den Einstellungen.
  ///
  /// Läuft über den ReminderScheduler, damit auch dieser eine Aufruf durch
  /// die Stelle geht, die das Plugin besitzt. Der Umweg über einen
  /// Warteschlangeneintrag entfällt: eine Probe ist nichts, was geplant,
  /// abgeglichen oder nachgehalten werden müsste.
  Future<void> sendTestNotification() async {
    if (!await hasPermission()) {
      logger.warning(
        LogCategory.service,
        'NotificationService: Testmeldung ohne Erlaubnis',
      );
      return;
    }
    await getIt<ReminderScheduler>().showNow(
      title: _testNotificationTitle,
      body: _testNotificationBody,
    );
    logger.info(
      LogCategory.service,
      'NotificationService: Testmeldung gezeigt',
    );
  }

  // ============================================================================
  // MEDICATION REMINDERS (Phase 2)
  // ============================================================================

  // ============================================================================
  // AS-NEEDED MEDICATION AVAILABILITY REMINDERS (Phase 3)
  // ============================================================================

  // ============================================================================
  // EVENT REMINDERS (Phase 4)
  // ============================================================================

  // ============================================================================
  // EVENT HANDLERS
  // ============================================================================
}
