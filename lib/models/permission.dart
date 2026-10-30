/// Permission-System für Role-Based Access Control (RBAC)
/// Definiert alle granularen Rechte in der App
///
/// Jede Permission trägt ein eigenes Symbol. Das ist keine Dekoration:
/// Anteile, die nicht lesen können oder im dissoziativen Zustand nicht lesen
/// mögen, erkennen ein Recht am Bild. Der Text bestätigt nur, was das Symbol
/// bereits gesagt hat.
library;

import 'package:flutter/material.dart';

/// Kategorien für bessere Übersicht
enum PermissionCategory {
  system, // Admin-Funktionen (kritisch!)
  chat, // Chat-Modul
  calendar, // Kalender-Modul
  medication, // Medikamenten-Modul
  diary, // Tagebuch-Modul (mit Sichtbarkeits-Control)
  contacts, // Kontakte-Modul
  finder, // Finder-Modul (Orte & Gegenstände)
  emergency, // Notfallkontakte
  security, // Passwörter, Biometrie (später)
}

/// Alle verfügbaren Berechtigungen in der App
enum Permission {
  // ========== SYSTEM (Kritisch!) ==========
  createProfiles(
    PermissionCategory.system,
    Icons.person_add,
    perPart: true,
  ),
  deactivateProfiles(
    PermissionCategory.system,
    Icons.person_off,
    perPart: true,
  ),
  managePermissions(
    PermissionCategory.system,
    Icons.admin_panel_settings,
    perPart: true,
  ),
  accessSettings(
    PermissionCategory.system,
    Icons.settings,
    perPart: true,
  ),

  // ========== CHAT ==========
  viewChat(
    PermissionCategory.chat,
    Icons.forum,
  ),
  sendChatMessage(
    PermissionCategory.chat,
    Icons.send,
  ),

  // Granulare Chat-Rechte (einzeln steuerbar)
  sendTextMessage(
    PermissionCategory.chat,
    Icons.keyboard,
  ),
  sendDoodle(
    PermissionCategory.chat,
    Icons.brush,
  ),
  sendVoiceMessage(
    PermissionCategory.chat,
    Icons.mic,
  ),
  sendImage(
    PermissionCategory.chat,
    Icons.photo_camera,
  ),
  sendVideo(
    PermissionCategory.chat,
    Icons.videocam,
  ),

  deleteOwnMessages(
    PermissionCategory.chat,
    Icons.backspace,
  ),
  deleteAllMessages(
    PermissionCategory.chat,
    Icons.delete_forever,
    perPart: true,
  ),

  // ========== KALENDER ==========
  viewCalendar(
    PermissionCategory.calendar,
    Icons.calendar_month,
  ),
  createEvents(
    PermissionCategory.calendar,
    Icons.event,
  ),
  editOwnEvents(
    PermissionCategory.calendar,
    Icons.edit_calendar,
  ),
  editAllEvents(
    PermissionCategory.calendar,
    Icons.event_repeat,
    perPart: true,
  ),
  deleteOwnEvents(
    PermissionCategory.calendar,
    Icons.event_busy,
  ),
  deleteAllEvents(
    PermissionCategory.calendar,
    Icons.delete_forever,
    perPart: true,
  ),
  attachEventMedia(
    PermissionCategory.calendar,
    Icons.attach_file,
  ),
  commentOnCalendarEvents(
    PermissionCategory.calendar,
    Icons.add_comment,
  ),

  // ========== MEDIKAMENTE ==========
  viewMedication(
    PermissionCategory.medication,
    Icons.medication,
    perPart: true,
  ),
  manageMedication(
    PermissionCategory.medication,
    Icons.medical_services,
    perPart: true,
  ),
  logMedication(
    PermissionCategory.medication,
    Icons.check_circle,
  ),
  overrideMedicationLog(
    PermissionCategory.medication,
    Icons.restart_alt,
    perPart: true,
  ),
  commentOnMedication(
    PermissionCategory.medication,
    Icons.add_comment,
  ),

  // ========== TAGEBUCH ==========
  viewOwnDiary(
    PermissionCategory.diary,
    Icons.book,
  ),
  viewAllDiaries(
    PermissionCategory.diary,
    Icons.library_books,
    perPart: true,
  ),
  writeDiary(
    PermissionCategory.diary,
    Icons.edit,
  ),

  // ========== KONTAKTE ==========
  viewContacts(
    PermissionCategory.contacts,
    Icons.contacts,
  ),
  manageContacts(
    PermissionCategory.contacts,
    Icons.person_add_alt,
  ),
  commentOnContacts(
    PermissionCategory.contacts,
    Icons.add_comment,
  ),

  // ========== FINDER (Orte & Gegenstände) ==========
  viewFinder(
    PermissionCategory.finder,
    Icons.search,
  ),
  manageFinder(
    PermissionCategory.finder,
    Icons.add_location_alt,
  ),
  commentOnFinderEntries(
    PermissionCategory.finder,
    Icons.add_comment,
  ),

  // ========== TAGEBUCH (Erweitert) ==========
  createDiaryEntry(
    PermissionCategory.diary,
    Icons.post_add,
  ),
  editOwnDiaryEntries(
    PermissionCategory.diary,
    Icons.edit_note,
  ),
  editAllDiaryEntries(
    PermissionCategory.diary,
    Icons.edit_document,
    perPart: true,
  ),
  deleteOwnDiaryEntries(
    PermissionCategory.diary,
    Icons.delete_outline,
  ),
  deleteAllDiaryEntries(
    PermissionCategory.diary,
    Icons.delete_forever,
    perPart: true,
  ),
  commentOnDiaryEntries(
    PermissionCategory.diary,
    Icons.add_comment,
  ),
  viewSharedEntries(
    PermissionCategory.diary,
    Icons.folder_shared,
  ),

  // ========== NOTFALLKONTAKTE ==========
  viewEmergencyContacts(
    PermissionCategory.emergency,
    Icons.contact_phone,
  ),
  callEmergencyContacts(
    PermissionCategory.emergency,
    Icons.phone_in_talk,
  ),
  editEmergencyContacts(
    PermissionCategory.emergency,
    Icons.contact_page,
  ),

  // ========== SECURITY (Zukünftig) ==========
  resetPasswords(
    PermissionCategory.security,
    Icons.lock_reset,
    perPart: true,
  ),
  changeOwnPassword(
    PermissionCategory.security,
    Icons.password,
  ),
  enableBiometrics(
    PermissionCategory.security,
    Icons.fingerprint,
  ),

  // ========== NAVIGATION (Tab-Sichtbarkeit) ==========
  viewChatTab(
    PermissionCategory.chat,
    Icons.chat,
  ),
  viewFeedbackTab(
    PermissionCategory.system,
    Icons.contact_support,
  ),
  viewCalendarTab(
    PermissionCategory.calendar,
    Icons.calendar_today,
  ),
  viewMedicationTab(
    PermissionCategory.medication,
    Icons.medication,
    perPart: true,
  ),
  viewDiaryTab(
    PermissionCategory.diary,
    Icons.book,
  ),
  viewContactsTab(
    PermissionCategory.contacts,
    Icons.people,
  ),
  viewFinderTab(
    PermissionCategory.finder,
    Icons.search,
  ),
  viewEmergencyTab(
    PermissionCategory.emergency,
    Icons.emergency,
  ),
  viewHelpTab(
    PermissionCategory.system,
    Icons.health_and_safety,
  ),
  viewMantrasTab(
    PermissionCategory.system,
    Icons.self_improvement,
  ),
  viewGamesTab(
    PermissionCategory.system,
    Icons.games,
  ),
  viewTimelineTab(
    PermissionCategory.system,
    Icons.timeline,
  );

  /// Kategorie für Gruppierung in UI
  final PermissionCategory category;

  /// Symbol für die Darstellung ohne Lesen
  final IconData icon;

  /// Ob dieses Recht je Anteil vergeben wird
  ///
  /// Alles andere gilt für alle: Sechzig Kästchen überblickt im
  /// dissoziativen Zustand niemand. Die Rechte pro Anteil bündelt `PartRight`
  /// zu zehn Schaltern.
  final bool perPart;

  const Permission(
    this.category,
    this.icon, {
    this.perPart = false,
  });

  /// Hive speichert Enums als String-Namen
  String get persistedValue => name;

  /// Von Hive-String zurück zu Permission
  static Permission? fromString(String value) {
    try {
      return Permission.values.firstWhere((p) => p.name == value);
    } catch (e) {
      return null;
    }
  }
}
