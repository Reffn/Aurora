import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/calendar_events.dart';
import 'package:dis_app/core/events/chat_events.dart';
import 'package:dis_app/core/events/comment_events.dart';
import 'package:dis_app/core/events/diary_events.dart';
import 'package:dis_app/core/events/medication_events.dart';
import 'package:dis_app/core/events/profile_events.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/chat_message.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/contact_comment.dart';
import 'package:dis_app/models/contact_rating.dart';
import 'package:dis_app/models/diary_entry.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/calendar_service.dart';
import 'package:dis_app/services/chat_service.dart';
import 'package:dis_app/services/comment_service.dart';
import 'package:dis_app/services/contact_service.dart';
import 'package:dis_app/services/diary_service.dart';
import 'package:dis_app/services/finder_service.dart';
import 'package:dis_app/services/medication_service.dart';
import 'package:dis_app/services/navigation_service.dart';
import 'package:dis_app/services/password_reset_service.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:hive_ce/hive.dart';

/// Zentrale Daten-Eingangsschnittstelle (Data Entry Point)
/// Alle Daten fließen durch diese Schicht: Validierung, Logging, Event-Publishing
///
/// **Unified API für Read & Write:**
/// - Commands (Write): createChatMessage(), updateProfile(), etc.
/// - Queries (Read): getChatMessages(), getActiveProfile(), etc.
/// - Reactive: messagesBox, profilesBox für ValueListenableBuilder
class DataEntry {
  DataEntry(
    this._eventBus, {
    required ChatService chatService,
    required ProfileService profileService,
    required CalendarService calendarService,
    required MedicationService medicationService,
    required ContactService contactService,
    required FinderService finderService,
    required DiaryService diaryService,
    required CommentService commentService,
    required NavigationService navigationService,
    required PasswordResetService passwordResetService,
  }) : _chatService = chatService,
       _profileService = profileService,
       _calendarService = calendarService,
       _medicationService = medicationService,
       _contactService = contactService,
       _finderService = finderService,
       _diaryService = diaryService,
       _commentService = commentService,
       _navigationService = navigationService,
       _passwordResetService = passwordResetService;

  final EventBus _eventBus;
  final ChatService _chatService;
  final ProfileService _profileService;
  final CalendarService _calendarService;
  final MedicationService _medicationService;
  final ContactService _contactService;
  final FinderService _finderService;
  final DiaryService _diaryService;
  final CommentService _commentService;
  final NavigationService _navigationService;
  final PasswordResetService _passwordResetService;

  /// Zentrale Logging-Methode für alle Datenflüsse
  void _log(String action, {String source = 'UI', Map<String, dynamic>? data}) {
    logger.info(
      LogCategory.dataEntry,
      action,
      data: {
        'source': source,
        if (data != null) ...data,
      },
    );
  }

  /// Query-Tracking-Methode mit automatischer Performance-Messung
  /// - Loggt Duration, Result Count, Empty Results
  /// - Nutzt logger.trackSync() für automatische Start/End-Logs
  T _trackQuery<T>(
    String queryName,
    T Function() queryFn, {
    Map<String, dynamic>? params,
  }) {
    return logger.trackSync(
      queryName,
      LogCategory.dataEntry,
      () {
        final result = queryFn();

        final resultInfo = <String, dynamic>{
          if (params != null) ...params,
        };

        // Result-Count für Listen loggen
        if (result is List) {
          resultInfo['resultCount'] = result.length;
          if (result.isEmpty) {
            logger.warning(
              LogCategory.dataEntry,
              '$queryName returned empty list',
            );
          }
        } else if (result == null) {
          resultInfo['resultIsNull'] = true;
          logger.warning(LogCategory.dataEntry, '$queryName returned null');
        }

        logger.debug(
          LogCategory.dataEntry,
          '$queryName result',
          data: resultInfo,
        );
        return result;
      },
    );
  }

  // ============ Chat API ============

  /// Chat-Nachricht erstellen
  Future<void> createChatMessage(
    ChatMessage message, {
    String source = 'UI',
  }) async {
    _log('createChatMessage', source: source, data: message.toMap());

    // Validierung
    if (message.content.trim().isEmpty) {
      throw ArgumentError('Chat-Nachricht darf nicht leer sein');
    }

    // Event publishen
    _eventBus.publish(ChatMessageCreatedEvent(message));
  }

  /// Chat-Nachricht als gelesen markieren
  Future<void> markMessageAsRead(String messageId) async {
    if (messageId.isEmpty) {
      throw ArgumentError('Message ID darf nicht leer sein');
    }

    _eventBus.publish(ChatMessageReadEvent(messageId));
  }

  /// Chat-History abrufen
  Future<void> loadChatHistory({int limit = 50, int offset = 0}) async {
    _eventBus.publish(ChatHistoryRequestedEvent(limit: limit, offset: offset));
  }

  // ============ Profile API ============

  /// Profil erstellen
  Future<void> createProfile(Profile profile, {String source = 'UI'}) async {
    _log('createProfile', source: source, data: profile.toMap());

    // Validierung
    if (profile.name.trim().isEmpty) {
      throw ArgumentError('Profil-Name darf nicht leer sein');
    }

    // Event publishen
    _eventBus.publish(ProfileCreatedEvent(profile));
  }

  /// Profil aktualisieren
  Future<void> updateProfile(Profile profile) async {
    if (profile.name.trim().isEmpty) {
      throw ArgumentError('Profil-Name darf nicht leer sein');
    }

    _eventBus.publish(ProfileUpdatedEvent(profile));
  }

  /// Profil deaktivieren (Soft Delete)
  Future<void> deactivateProfile(String profileId) async {
    if (profileId.isEmpty) {
      throw ArgumentError('Profile ID darf nicht leer sein');
    }

    _eventBus.publish(ProfileDeactivatedEvent(profileId));
  }

  /// Profil reaktivieren
  Future<void> reactivateProfile(String profileId) async {
    if (profileId.isEmpty) {
      throw ArgumentError('Profile ID darf nicht leer sein');
    }

    _eventBus.publish(ProfileReactivatedEvent(profileId));
  }

  /// Alle Profile abrufen
  Future<void> loadProfiles() async {
    _eventBus.publish(ProfilesRequestedEvent());
  }

  /// Aktives Profil wechseln
  Future<void> changeActiveProfile(
    Profile profile, {
    String source = 'UI',
  }) async {
    _log(
      'changeActiveProfile',
      source: source,
      data: {'profileId': profile.id, 'profileName': profile.name},
    );
    _eventBus.publish(ActiveProfileChangedEvent(profile));
  }

  // ============ Password Reset API ============

  /// Startet einen Passwort-Reset für ein Profil
  /// Gibt true zurück bei Erfolg, false wenn Profil kein Passwort hat
  Future<bool> startPasswordReset(
    String profileId,
    String newPassword, {
    String source = 'UI',
  }) async {
    _log('startPasswordReset', source: source, data: {'profileId': profileId});

    if (profileId.isEmpty) {
      throw ArgumentError('Profile ID darf nicht leer sein');
    }

    if (newPassword.isEmpty) {
      throw ArgumentError('Neues Passwort darf nicht leer sein');
    }

    final result = await _passwordResetService.startReset(
      profileId,
      newPassword,
    );

    if (result) {
      final profile = _profileService.profilesBox.get(profileId);
      if (profile != null) {
        _eventBus.publish(PasswordResetStartedEvent(profile));
      }
    }

    return result;
  }

  /// Prüft Login-Versuch bei aktivem Reset und gibt Ergebnis zurück
  /// Atomare Operation: Aktivierung, Abbruch oder Verifikation
  Future<ResetLoginOutcome> checkAndHandleLogin(
    Profile profile,
    String enteredPassword, {
    String source = 'UI',
  }) async {
    _log(
      'checkAndHandleLogin',
      source: source,
      data: {'profileId': profile.id},
    );

    if (profile.id.isEmpty) {
      throw ArgumentError('Profile ID darf nicht leer sein');
    }

    if (enteredPassword.isEmpty) {
      throw ArgumentError('Passwort darf nicht leer sein');
    }

    final outcome = await _passwordResetService.checkAndHandleLogin(
      profile,
      enteredPassword,
    );

    // Aktuelle Profile nach der Operation abrufen für Events
    final updatedProfile = _profileService.profilesBox.get(profile.id);
    if (updatedProfile != null) {
      if (outcome == ResetLoginOutcome.cancelled) {
        _eventBus.publish(PasswordResetCancelledEvent(updatedProfile));
      } else if (outcome == ResetLoginOutcome.activated) {
        _eventBus.publish(PasswordResetActivatedEvent(updatedProfile));
      }
    }

    return outcome;
  }

  /// Setzt die Reset-Frist für zukünftige Resets dieses Profils (in Stunden)
  /// Wirkt nicht auf laufende Resets
  Future<void> setResetDuration(
    String profileId,
    int hours, {
    String source = 'UI',
  }) async {
    _log(
      'setResetDuration',
      source: source,
      data: {'profileId': profileId, 'hours': hours},
    );

    if (profileId.isEmpty) {
      throw ArgumentError('Profile ID darf nicht leer sein');
    }

    if (hours < 1) {
      throw ArgumentError('Reset-Frist muss mindestens 1 Stunde sein');
    }

    await _passwordResetService.setResetDuration(profileId, hours);
  }

  // ============ Permission Management API ============

  /// Berechtigung an/aus schalten
  /// Gibt zurück, ob das Umschalten gelungen ist (nicht den neuen Zustand)
  Future<bool> togglePermission(
    String profileId,
    Permission permission, {
    String source = 'UI',
  }) async {
    _log(
      'togglePermission',
      source: source,
      data: {
        'profileId': profileId,
        'permission': permission.persistedValue,
      },
    );

    return _profileService.togglePermission(profileId, permission);
  }

  /// Profil zum Administrator ernennen
  /// Gibt alle Rechte und setzt isAdmin = true
  Future<bool> makeAdmin(String profileId, {String source = 'UI'}) async {
    _log('makeAdmin', source: source, data: {'profileId': profileId});

    return _profileService.makeAdmin(profileId);
  }

  /// Administrator-Status widerrufen
  /// Entfernt alle Rechte und setzt isAdmin = false
  Future<bool> revokeAdmin(String profileId, {String source = 'UI'}) async {
    _log('revokeAdmin', source: source, data: {'profileId': profileId});

    return _profileService.revokeAdmin(profileId);
  }

  // ============ Calendar API ============

  /// Kalender-Event erstellen
  Future<void> createCalendarEvent(
    CalendarEvent event, {
    String source = 'UI',
  }) async {
    _log('createCalendarEvent', source: source, data: event.toMap());

    // Validierung
    if (event.title.trim().isEmpty) {
      throw ArgumentError('Event-Titel darf nicht leer sein');
    }

    if (event.endTime.isBefore(event.startTime)) {
      throw ArgumentError('End-Zeit muss nach Start-Zeit liegen');
    }

    if (event.profileIds.isEmpty) {
      throw ArgumentError('Mindestens ein Profil muss zugeordnet sein');
    }

    // Event publishen
    _eventBus.publish(CalendarEventCreatedEvent(event));
  }

  /// Kalender-Event aktualisieren
  Future<void> updateCalendarEvent(CalendarEvent event) async {
    if (event.title.trim().isEmpty) {
      throw ArgumentError('Event-Titel darf nicht leer sein');
    }

    if (event.endTime.isBefore(event.startTime)) {
      throw ArgumentError('End-Zeit muss nach Start-Zeit liegen');
    }

    if (event.profileIds.isEmpty) {
      throw ArgumentError('Mindestens ein Profil muss zugeordnet sein');
    }

    _eventBus.publish(CalendarEventUpdatedEvent(event));
  }

  /// Kalender-Event löschen
  Future<void> deleteCalendarEvent(String eventId) async {
    if (eventId.isEmpty) {
      throw ArgumentError('Event ID darf nicht leer sein');
    }

    _eventBus.publish(CalendarEventDeletedEvent(eventId));
  }

  // ============ Medication API ============

  /// Medikament erstellen
  Future<void> createMedication(
    Medication medication, {
    String source = 'UI',
  }) async {
    _log('createMedication', source: source, data: medication.toMap());

    // Validierung
    if (medication.name.trim().isEmpty) {
      throw ArgumentError('Medikamenten-Name darf nicht leer sein');
    }

    if (medication.dosage.trim().isEmpty) {
      throw ArgumentError('Dosierung darf nicht leer sein');
    }

    // Nur für Tagesmedizin müssen Einnahmezeiten angegeben werden
    if (medication.type == MedicationType.daily &&
        medication.timesOfDay.isEmpty) {
      throw ArgumentError('Mindestens eine Einnahmezeit muss angegeben werden');
    }

    if (medication.profileIds.isEmpty) {
      throw ArgumentError('Mindestens ein Profil muss zugeordnet sein');
    }

    // Event publishen
    _eventBus.publish(MedicationCreatedEvent(medication));
  }

  /// Medikament aktualisieren
  Future<void> updateMedication(Medication medication) async {
    if (medication.name.trim().isEmpty) {
      throw ArgumentError('Medikamenten-Name darf nicht leer sein');
    }

    if (medication.dosage.trim().isEmpty) {
      throw ArgumentError('Dosierung darf nicht leer sein');
    }

    // Nur für Tagesmedizin müssen Einnahmezeiten angegeben werden
    if (medication.type == MedicationType.daily &&
        medication.timesOfDay.isEmpty) {
      throw ArgumentError('Mindestens eine Einnahmezeit muss angegeben werden');
    }

    if (medication.profileIds.isEmpty) {
      throw ArgumentError('Mindestens ein Profil muss zugeordnet sein');
    }

    _eventBus.publish(MedicationUpdatedEvent(medication));
  }

  /// Medikament löschen
  Future<void> deleteMedication(String medicationId) async {
    if (medicationId.isEmpty) {
      throw ArgumentError('Medication ID darf nicht leer sein');
    }

    _eventBus.publish(MedicationDeletedEvent(medicationId));
  }

  /// Medikamenten-Einnahme loggen
  Future<void> logMedicationTaken(
    MedicationLog log, {
    String source = 'UI',
  }) async {
    _log('logMedicationTaken', source: source, data: log.toMap());

    if (log.medicationId.isEmpty) {
      throw ArgumentError('Medication ID darf nicht leer sein');
    }

    if (log.profileId.isEmpty) {
      throw ArgumentError('Profile ID darf nicht leer sein');
    }

    _eventBus.publish(MedicationTakenEvent(log));
  }

  /// Medikamenten-Log aktualisieren
  Future<void> updateMedicationLog(MedicationLog log) async {
    if (log.medicationId.isEmpty) {
      throw ArgumentError('Medication ID darf nicht leer sein');
    }

    _eventBus.publish(MedicationLogUpdatedEvent(log));
  }

  /// Medikamenten-Log löschen
  Future<void> deleteMedicationLog(String logId) async {
    if (logId.isEmpty) {
      throw ArgumentError('Log ID darf nicht leer sein');
    }

    _eventBus.publish(MedicationLogDeletedEvent(logId));
  }

  // ============ Comment Commands ============

  /// Kommentar erstellen
  Future<void> createComment(Comment comment, {String source = 'UI'}) async {
    _log('createComment', source: source, data: comment.toMap());

    // Validierung
    if (comment.content.trim().isEmpty) {
      throw ArgumentError('Kommentar darf nicht leer sein');
    }
    if (comment.parentId.isEmpty) {
      throw ArgumentError('Parent ID darf nicht leer sein');
    }
    if (comment.profileId.isEmpty) {
      throw ArgumentError('Profile ID darf nicht leer sein');
    }

    // Event publishen
    _eventBus.publish(CommentCreatedEvent(comment));
  }

  /// Kommentar aktualisieren
  Future<void> updateComment(Comment comment, {String source = 'UI'}) async {
    _log('updateComment', source: source, data: comment.toMap());

    // Validierung
    if (comment.content.trim().isEmpty) {
      throw ArgumentError('Kommentar darf nicht leer sein');
    }

    // Event publishen
    _eventBus.publish(CommentUpdatedEvent(comment));
  }

  /// Kommentar löschen
  Future<void> deleteComment(
    String commentId,
    CommentableType type,
    String parentId, {
    String source = 'UI',
  }) async {
    _log(
      'deleteComment',
      source: source,
      data: {'commentId': commentId, 'type': type.name, 'parentId': parentId},
    );

    // Validierung
    if (commentId.isEmpty) {
      throw ArgumentError('Comment ID darf nicht leer sein');
    }

    // Event publishen
    _eventBus.publish(
      CommentDeletedEvent(
        commentId: commentId,
        type: type,
        parentId: parentId,
      ),
    );
  }

  // ============ Diary Commands ============

  /// Tagebuch-Eintrag erstellen
  Future<void> createDiaryEntry(
    DiaryEntry entry, {
    String source = 'UI',
  }) async {
    _log('createDiaryEntry', source: source, data: entry.toMap());

    // Validierung
    if (entry.title.trim().isEmpty) {
      throw ArgumentError('Tagebuch-Titel darf nicht leer sein');
    }

    if (entry.description.trim().isEmpty) {
      throw ArgumentError('Tagebuch-Beschreibung darf nicht leer sein');
    }

    if (entry.authorProfileId.isEmpty) {
      throw ArgumentError('Autor-Profil-ID darf nicht leer sein');
    }

    // Event publishen
    _eventBus.publish(DiaryEntryCreatedEvent(entry));
  }

  /// Tagebuch-Eintrag aktualisieren
  Future<void> updateDiaryEntry(DiaryEntry entry) async {
    if (entry.title.trim().isEmpty) {
      throw ArgumentError('Tagebuch-Titel darf nicht leer sein');
    }

    if (entry.description.trim().isEmpty) {
      throw ArgumentError('Tagebuch-Beschreibung darf nicht leer sein');
    }

    if (entry.authorProfileId.isEmpty) {
      throw ArgumentError('Autor-Profil-ID darf nicht leer sein');
    }

    _eventBus.publish(DiaryEntryUpdatedEvent(entry));
  }

  /// Tagebuch-Eintrag löschen
  Future<void> deleteDiaryEntry(String entryId) async {
    if (entryId.isEmpty) {
      throw ArgumentError('Entry ID darf nicht leer sein');
    }

    _eventBus.publish(DiaryEntryDeletedEvent(entryId));
  }

  // Weitere API-Methoden für andere Module können hier ergänzt werden
  // (Emergency, Help, Mantras, Games)

  // ========================================================================
  // QUERY API (Read Operations)
  // ========================================================================

  // ============ Chat Queries ============

  /// Chat-Nachrichten abrufen (synchron)
  /// Für nicht-reaktive Zugriffe
  List<ChatMessage> getChatMessages() {
    return _trackQuery(
      'getChatMessages',
      () => _chatService.messages,
    );
  }

  /// Einzelne Chat-Nachricht per ID abrufen
  ChatMessage? getChatMessageById(String messageId) {
    return _trackQuery(
      'getChatMessageById',
      () {
        try {
          return _chatService.messages.firstWhere((msg) => msg.id == messageId);
        } catch (e) {
          return null;
        }
      },
      params: {'messageId': messageId},
    );
  }

  /// Zugriff auf Messages-Box für ValueListenableBuilder (reaktiv)
  /// UI kann damit automatische Updates bei Datenänderungen erhalten
  Box<ChatMessage> get chatMessagesBox => _chatService.messagesBox;

  // ============ Profile Queries ============

  /// Alle aktiven Profile abrufen (synchron)
  /// Für nicht-reaktive Zugriffe (z.B. Dropdowns)
  List<Profile> getProfiles() {
    return _trackQuery(
      'getProfiles',
      () => _profileService.activeProfiles,
    );
  }

  /// Alle Profile inkl. deaktivierte abrufen
  /// Für Admin-Views oder History
  List<Profile> getAllProfiles() {
    return _trackQuery(
      'getAllProfiles',
      () => _profileService.allProfiles,
    );
  }

  /// Aktives Profil abrufen (synchron)
  Profile? getActiveProfile() {
    return _trackQuery(
      'getActiveProfile',
      () => _profileService.activeProfile,
    );
  }

  /// Einzelnes Profil per ID abrufen
  Profile? getProfileById(String profileId) {
    return _trackQuery(
      'getProfileById',
      () {
        try {
          return _profileService.profiles.firstWhere((p) => p.id == profileId);
        } catch (e) {
          return null;
        }
      },
      params: {'profileId': profileId},
    );
  }

  /// Zugriff auf Profile-Box für ValueListenableBuilder (reaktiv)
  Box<Profile> get profilesBox => _profileService.profilesBox;

  /// Zugriff auf Settings-Box für ValueListenableBuilder (reaktiv)
  /// Inkl. active_profile_id
  Box<dynamic> get settingsBox => _profileService.settingsBox;

  // ============ Calendar Queries ============

  /// Alle Calendar-Events abrufen
  List<CalendarEvent> getCalendarEvents() {
    return _trackQuery(
      'getCalendarEvents',
      () => _calendarService.events,
    );
  }

  /// Calendar-Events für einen Tag abrufen
  List<CalendarEvent> getCalendarEventsForDay(DateTime day) {
    return _trackQuery(
      'getCalendarEventsForDay',
      () => _calendarService.getEventsForDay(day),
      params: {'day': day.toIso8601String()},
    );
  }

  /// Calendar-Events für einen Monat abrufen
  List<CalendarEvent> getCalendarEventsForMonth(int year, int month) {
    return _trackQuery(
      'getCalendarEventsForMonth',
      () => _calendarService.getEventsForMonth(year, month),
      params: {'year': year, 'month': month},
    );
  }

  /// Calendar-Event anhand ID abrufen
  CalendarEvent? getEventById(String id) {
    return _trackQuery(
      'getEventById',
      () => _calendarService.getEventById(id),
      params: {'id': id},
    );
  }

  /// Zugriff auf Calendar-Box (reaktiv)
  Box<CalendarEvent> get calendarEventsBox => _calendarService.eventsBox;

  // ============ Medication Queries ============

  /// Alle aktiven Medikamente abrufen
  List<Medication> getActiveMedications() {
    return _trackQuery(
      'getActiveMedications',
      () => _medicationService.activeMedications,
    );
  }

  /// Alle Medikamente (inkl. inaktive) abrufen
  List<Medication> getAllMedications() {
    return _trackQuery(
      'getAllMedications',
      () => _medicationService.allMedications,
    );
  }

  /// Heutige Medikamente abrufen
  List<Medication> getTodaysMedications() {
    return _trackQuery(
      'getTodaysMedications',
      _medicationService.getTodaysMedications,
    );
  }

  /// Heutiger Eintrag für ein Medikament zu einer Tageszeit, falls vorhanden
  MedicationLog? getTodaysLog(String medicationId, String timeOfDay) {
    return _trackQuery(
      'getTodaysLog',
      () => _medicationService.getTodaysLog(medicationId, timeOfDay),
      params: {'medicationId': medicationId, 'timeOfDay': timeOfDay},
    );
  }

  /// Zugriff auf Medication-Box (reaktiv)
  Box<Medication> get medicationsBox => _medicationService.medicationsBox;

  /// Zugriff auf Medication-Logs-Box (reaktiv)
  Box<MedicationLog> get medicationLogsBox => _medicationService.logsBox;

  /// Heutige Logs für Bedarfsmedikament abrufen
  List<MedicationLog> getTodaysAsNeededLogs(String medicationId) {
    return _trackQuery(
      'getTodaysAsNeededLogs',
      () => _medicationService.getTodaysAsNeededLogs(medicationId),
      params: {'medicationId': medicationId},
    );
  }

  /// Verfügbare Dosen heute (für Bedarfsmedizin)
  int getAvailableDoses(Medication medication) {
    return _trackQuery(
      'getAvailableDoses',
      () => _medicationService.getAvailableDoses(medication),
      params: {'medicationId': medication.id},
    );
  }

  /// Nächste erlaubte Einnahme-Zeit (für Bedarfsmedizin mit Mindestabstand)
  DateTime? getNextAllowedTime(Medication medication) {
    return _trackQuery(
      'getNextAllowedTime',
      () => _medicationService.getNextAllowedTime(medication),
      params: {'medicationId': medication.id},
    );
  }

  /// Kann Bedarfsmedikament jetzt genommen werden?
  bool canTakeNow(Medication medication) {
    return _trackQuery(
      'canTakeNow',
      () => _medicationService.canTakeNow(medication),
      params: {'medicationId': medication.id},
    );
  }

  // ============ Contact Commands ============

  /// Neuen Kontakt erstellen
  Future<void> createContact(Contact contact, {String source = 'UI'}) async {
    _log('createContact', source: source, data: contact.toMap());

    if (contact.name.trim().isEmpty) {
      throw ArgumentError('Contact name darf nicht leer sein');
    }

    if (contact.id.isEmpty) {
      throw ArgumentError('Contact ID darf nicht leer sein');
    }

    await _contactService.create(contact);
  }

  /// Existierenden Kontakt aktualisieren
  Future<void> updateContact(Contact contact, {String source = 'UI'}) async {
    _log('updateContact', source: source, data: contact.toMap());

    if (contact.name.trim().isEmpty) {
      throw ArgumentError('Contact name darf nicht leer sein');
    }

    if (contact.id.isEmpty) {
      throw ArgumentError('Contact ID darf nicht leer sein');
    }

    await _contactService.update(contact);
  }

  /// Kontakt löschen (Cascade: Ratings + Comments)
  Future<void> deleteContact(String contactId, {String source = 'UI'}) async {
    _log('deleteContact', source: source, data: {'contactId': contactId});

    if (contactId.isEmpty) {
      throw ArgumentError('Contact ID darf nicht leer sein');
    }

    await _contactService.delete(contactId);
  }

  // ============ Contact Queries ============

  /// Alle Kontakte abrufen
  List<Contact> getContacts() {
    return _trackQuery(
      'getContacts',
      () => _contactService.contacts,
    );
  }

  /// Kontakt per ID abrufen
  Contact? getContactById(String contactId) {
    return _trackQuery(
      'getContactById',
      () {
        try {
          return _contactService.contacts.firstWhere((c) => c.id == contactId);
        } catch (e) {
          return null;
        }
      },
      params: {'contactId': contactId},
    );
  }

  /// Bewertung für ein bestimmtes Profil abrufen (Override oder Default)
  int getContactRatingForProfile(String contactId, String profileId) {
    return _trackQuery(
      'getContactRatingForProfile',
      () => _contactService.getRatingForProfile(contactId, profileId),
      params: {'contactId': contactId, 'profileId': profileId},
    );
  }

  /// Bewertung für ein bestimmtes Profil setzen (Override)
  Future<void> setContactRatingForProfile(
    String contactId,
    String profileId,
    int rating, {
    String source = 'UI',
  }) async {
    _log(
      'setContactRatingForProfile',
      source: source,
      data: {'contactId': contactId, 'profileId': profileId, 'rating': rating},
    );

    if (contactId.isEmpty || profileId.isEmpty) {
      throw ArgumentError('Contact ID und Profile ID dürfen nicht leer sein');
    }

    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating muss zwischen 1 und 5 liegen');
    }

    await _contactService.setRatingForProfile(contactId, profileId, rating);
  }

  /// Zugriff auf Contacts-Box (reaktiv)
  Box<Contact> get contactsBox => _contactService.contactsBox;

  /// Zugriff auf ContactRatings-Box (reaktiv)
  Box<ContactRating> get contactRatingsBox => _contactService.ratingsBox;

  /// Zugriff auf ContactComments-Box (reaktiv) — Legacy-Architektur
  /// Wird von contact_card.dart für alte ContactComment-Datenstruktur genutzt
  Box<ContactComment> get contactCommentsBox => _contactService.commentsBox;

  // ============ Finder API ============

  /// FinderItem erstellen
  Future<void> createFinderItem(FinderItem item, {String source = 'UI'}) async {
    _log('createFinderItem', source: source, data: item.toMap());

    // Validierung
    if (item.title.trim().isEmpty) {
      throw ArgumentError('Titel darf nicht leer sein');
    }

    await _finderService.create(item);
  }

  /// FinderItem aktualisieren
  Future<void> updateFinderItem(FinderItem item) async {
    if (item.title.trim().isEmpty) {
      throw ArgumentError('Titel darf nicht leer sein');
    }

    await _finderService.update(item);
  }

  /// FinderItem löschen
  Future<void> deleteFinderItem(String itemId) async {
    if (itemId.isEmpty) {
      throw ArgumentError('Item ID darf nicht leer sein');
    }

    await _finderService.delete(itemId);
  }

  /// Alle Finder-Items abrufen
  List<FinderItem> getFinderItems() {
    return _trackQuery(
      'getFinderItems',
      () => _finderService.items,
    );
  }

  /// FinderItems nach Typ filtern
  List<FinderItem> getFinderItemsByType(FinderItemType type) {
    return _trackQuery(
      'getFinderItemsByType',
      () => _finderService.getByType(type),
      params: {'type': type.name},
    );
  }

  /// FinderItem per ID abrufen
  FinderItem? getFinderItemById(String id) {
    return _trackQuery(
      'getFinderItemById',
      () => _finderService.getById(id),
      params: {'id': id},
    );
  }

  /// FinderItems suchen
  List<FinderItem> searchFinderItems(String query) {
    return _trackQuery(
      'searchFinderItems',
      () => _finderService.searchByTitle(query),
      params: {'query': query},
    );
  }

  /// Zugriff auf Finder-Box (reaktiv)
  Box<FinderItem> get finderItemsBox => _finderService.finderItemsBox;

  // ============ Diary Queries ============

  /// Alle Tagebuch-Einträge abrufen
  List<DiaryEntry> getDiaryEntries() {
    return _trackQuery(
      'getDiaryEntries',
      () => _diaryService.entries,
    );
  }

  /// Einträge die für ein Profil sichtbar sind
  List<DiaryEntry> getDiaryEntriesVisibleToProfile(
    String profileId, {
    bool isAdmin = false,
  }) {
    return _trackQuery(
      'getDiaryEntriesVisibleToProfile',
      () =>
          _diaryService.getEntriesVisibleToProfile(profileId, isAdmin: isAdmin),
      params: {'profileId': profileId, 'isAdmin': isAdmin},
    );
  }

  /// Tagebuch-Eintrag per ID abrufen
  DiaryEntry? getDiaryEntryById(String entryId) {
    return _trackQuery(
      'getDiaryEntryById',
      () {
        try {
          return _diaryService.entries.firstWhere((e) => e.id == entryId);
        } catch (e) {
          return null;
        }
      },
      params: {'entryId': entryId},
    );
  }

  /// Zugriff auf Diary Box (reaktiv)
  Box<DiaryEntry> get diaryBox => _diaryService.entriesBox;

  // ============ Comment Queries ============

  /// Kommentare für ein Parent-Objekt abrufen
  List<Comment> getComments(CommentableType type, String parentId) {
    return _trackQuery(
      'getComments',
      () => _commentService.getComments(type, parentId),
      params: {'type': type.name, 'parentId': parentId},
    );
  }

  /// Anzahl der Kommentare für ein Parent-Objekt
  int getCommentCount(CommentableType type, String parentId) {
    return _trackQuery(
      'getCommentCount',
      () => _commentService.getCommentCount(type, parentId),
      params: {'type': type.name, 'parentId': parentId},
    );
  }

  /// Kommentare eines Profils abrufen
  List<Comment> getCommentsByProfile(String profileId) {
    return _trackQuery(
      'getCommentsByProfile',
      () => _commentService.getCommentsByProfile(profileId),
      params: {'profileId': profileId},
    );
  }

  /// Einzelnen Kommentar abrufen
  Comment? getCommentById(String commentId) {
    return _trackQuery(
      'getCommentById',
      () => _commentService.getCommentById(commentId),
      params: {'commentId': commentId},
    );
  }

  /// Legacy: Kommentare zu einem Kontakt abrufen (alte ContactComment-Architektur)
  /// Wird von contact_card.dart verwendet
  List<ContactComment> getContactComments(String contactId) {
    return _trackQuery(
      'getContactComments',
      () => _contactService.getCommentsForContact(contactId),
      params: {'contactId': contactId},
    );
  }

  /// Legacy: Anzahl der Kommentare zu einem Kontakt (alte ContactComment-Architektur)
  int getContactCommentCount(String contactId) {
    return _trackQuery(
      'getContactCommentCount',
      () => _contactService.getCommentCount(contactId),
      params: {'contactId': contactId},
    );
  }

  /// Zugriff auf Comments-Box (reaktiv)
  Box<Comment> get commentsBox => _commentService.commentsBox;

  // ============ Destructive Operations ============

  /// Löscht ALLE Daten aus sämtlichen Services
  /// Dies ist eine irreversible Operation und sollte nur nach Benutzerbestätigung durchgeführt werden
  Future<void> clearAllData() async {
    _log('clearAllData', data: {'action': 'destructive_data_wipe'});

    await _chatService.clearAll();
    await _calendarService.clearAll();
    await _profileService.clearAll();
    await _medicationService.clearAll();
    await _contactService.clearAll();
    await _finderService.clearAll();
    await _diaryService.clearAll();
    await _commentService.clearAll();
    await _navigationService.clearAll();
  }
}
