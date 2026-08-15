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

/// Symbol und Farbe je Kategorie
///
/// Liegt im Modell und nicht im Screen, damit jede Oberfläche dieselbe
/// Bildsprache verwendet. Ein Anteil, der die Farbe Lila mit Medikamenten
/// verbindet, soll das überall wiederfinden.
extension PermissionCategoryAppearance on PermissionCategory {
  IconData get icon {
    switch (this) {
      case PermissionCategory.system:
        return Icons.security;
      case PermissionCategory.chat:
        return Icons.chat;
      case PermissionCategory.calendar:
        return Icons.calendar_today;
      case PermissionCategory.medication:
        return Icons.medication;
      case PermissionCategory.diary:
        return Icons.book;
      case PermissionCategory.contacts:
        return Icons.contacts;
      case PermissionCategory.finder:
        return Icons.search;
      case PermissionCategory.emergency:
        return Icons.emergency;
      case PermissionCategory.security:
        return Icons.lock;
    }
  }

  Color get color {
    switch (this) {
      case PermissionCategory.system:
        return Colors.red;
      case PermissionCategory.chat:
        return Colors.blue;
      case PermissionCategory.calendar:
        return Colors.green;
      case PermissionCategory.medication:
        return Colors.purple;
      case PermissionCategory.diary:
        return Colors.orange;
      case PermissionCategory.contacts:
        return Colors.teal;
      case PermissionCategory.finder:
        return Colors.cyan;
      case PermissionCategory.emergency:
        return Colors.red;
      case PermissionCategory.security:
        return Colors.amber;
    }
  }
}

/// Alle verfügbaren Berechtigungen in der App
enum Permission {
  // ========== SYSTEM (Kritisch!) ==========
  createProfiles(
    PermissionCategory.system,
    Icons.person_add,
    dangerous: true,
  ),
  deactivateProfiles(
    PermissionCategory.system,
    Icons.person_off,
    dangerous: true,
  ),
  managePermissions(
    PermissionCategory.system,
    Icons.admin_panel_settings,
    dangerous: true,
  ),
  accessSettings(
    PermissionCategory.system,
    Icons.settings,
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
    dangerous: true,
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
  ),
  deleteOwnEvents(
    PermissionCategory.calendar,
    Icons.event_busy,
  ),
  deleteAllEvents(
    PermissionCategory.calendar,
    Icons.delete_forever,
    dangerous: true,
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
  ),
  manageMedication(
    PermissionCategory.medication,
    Icons.medical_services,
    dangerous: true,
  ),
  logMedication(
    PermissionCategory.medication,
    Icons.check_circle,
  ),
  overrideMedicationLog(
    PermissionCategory.medication,
    Icons.restart_alt,
    dangerous: true,
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
    dangerous: true,
  ),
  deleteOwnDiaryEntries(
    PermissionCategory.diary,
    Icons.delete_outline,
  ),
  deleteAllDiaryEntries(
    PermissionCategory.diary,
    Icons.delete_forever,
    dangerous: true,
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
    dangerous: true,
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
    dangerous: true,
  );

  /// Kategorie für Gruppierung in UI
  final PermissionCategory category;

  /// Symbol für die Darstellung ohne Lesen
  final IconData icon;

  /// Ob diese Berechtigung als gefährlich markiert werden soll (UI: Rot)
  final bool dangerous;

  const Permission(
    this.category,
    this.icon, {
    this.dangerous = false,
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

/// Helper Extension für Listen von Permissions
extension PermissionListExtensions on List<Permission> {
  /// Gruppiert Permissions nach Kategorie für UI
  Map<PermissionCategory, List<Permission>> groupByCategory() {
    final grouped = <PermissionCategory, List<Permission>>{};
    for (final permission in this) {
      grouped.putIfAbsent(permission.category, () => []).add(permission);
    }
    return grouped;
  }

  /// Nur System-Rechte (gefährlich)
  List<Permission> get systemPermissions =>
      where((p) => p.category == PermissionCategory.system).toList();

  /// Nur gefährliche Rechte
  List<Permission> get dangerousPermissions =>
      where((p) => p.dangerous).toList();
}
