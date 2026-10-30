import 'package:dis_app/main.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/models/tab_item.dart';
import 'package:dis_app/modules/anchor/anchor_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TabDefinition', () {
    test('requiredPermission darf null sein und heisst immer sichtbar', () {
      // Nicht mehr const: Die Beschriftung ist seit der Übersetzungsumstellung
      // eine Funktion über AppLocalizations, und Funktionsliterale sind in
      // Dart nie konstant. Für diesen Test genügt eine, die den Text zurückgibt.
      final tab = TabDefinition(
        tabItem: TabItem(icon: Icons.anchor, label: (l) => 'Halt'),
        screen: const SizedBox.shrink(),
        fabConfig: null,
        requiredPermission: null,
        color: Colors.teal,
        telemetryKey: 'halt',
        section: AnchorSection.everyday,
      );

      expect(tab.requiredPermission, isNull);
    });

    test('ein Tab mit Permission behaelt sie', () {
      final tab = TabDefinition(
        tabItem: TabItem(icon: Icons.book, label: (l) => 'Tagebuch'),
        screen: const SizedBox.shrink(),
        fabConfig: null,
        requiredPermission: Permission.viewDiaryTab,
        color: Colors.brown,
        telemetryKey: 'tagebuch',
        section: AnchorSection.everyday,
      );

      expect(tab.requiredPermission, Permission.viewDiaryTab);
    });
  });

  group('visibleTabsFor', () {
    // Test-Tabs für die Sichtbarkeitstests
    final chatTab = TabDefinition(
      tabItem: TabItem(icon: Icons.chat, label: (l) => 'Chat'),
      screen: const SizedBox.shrink(),
      fabConfig: null,
      requiredPermission: null, // Immer sichtbar
      color: Colors.grey,
      telemetryKey: 'chat',
      section: AnchorSection.everyday,
    );

    final feedbackTab = TabDefinition(
      tabItem:
          TabItem(icon: Icons.contact_support, label: (l) => 'Feedback'),
      screen: const SizedBox.shrink(),
      fabConfig: null,
      requiredPermission: null, // Immer sichtbar
      color: Colors.grey,
      telemetryKey: 'feedback',
      section: AnchorSection.everyday,
    );

    final diaryTab = TabDefinition(
      tabItem: TabItem(icon: Icons.book, label: (l) => 'Tagebuch'),
      screen: const SizedBox.shrink(),
      fabConfig: null,
      requiredPermission: Permission.viewDiaryTab,
      color: Colors.grey,
      telemetryKey: 'tagebuch',
      section: AnchorSection.everyday,
    );

    final calendarTab = TabDefinition(
      tabItem:
          TabItem(icon: Icons.calendar_today, label: (l) => 'Kalender'),
      screen: const SizedBox.shrink(),
      fabConfig: null,
      requiredPermission: Permission.viewCalendarTab,
      color: Colors.grey,
      telemetryKey: 'kalender',
      section: AnchorSection.everyday,
    );

    final groundingTab = TabDefinition(
      tabItem: TabItem(icon: Icons.anchor, label: (l) => 'Halt'),
      screen: const SizedBox.shrink(),
      fabConfig: null,
      requiredPermission: null, // Immer sichtbar (Erdung)
      color: Colors.grey,
      telemetryKey: 'halt',
      section: AnchorSection.everyday,
    );

    final allTestTabs = [chatTab, feedbackTab, diaryTab, calendarTab, groundingTab];

    test('ohne Profil werden alle Tabs angezeigt', () {
      final visible = visibleTabsFor(allTestTabs, null);
      expect(visible, hasLength(5));
      expect(visible, orderedEquals(allTestTabs));
    });

    // Tagebuch und Kalender gelten für alle: Ein altes Profil ohne die
    // gespeicherten Tab-Rechte sieht sie trotzdem.
    test('Tagebuch und Kalender gelten für alle, auch ohne gespeichertes Recht',
        () {
      final profile = Profile.withColor(
        id: 'test-1',
        name: 'Test User',
        preferredColor: Colors.blue,
        createdAt: DateTime.now(),
        permissions: [], // Keine Rechte
      );

      final visible = visibleTabsFor(allTestTabs, profile);

      expect(visible, orderedEquals(allTestTabs));
    });

    // Medikamente sehen bleibt ein Recht pro Anteil, der Filter muss also
    // weiter greifen.
    test('ein Anteil ohne viewMedicationTab sieht die Medikamente nicht', () {
      final medicationTab = TabDefinition(
        tabItem: TabItem(icon: Icons.medication, label: (l) => 'Medikamente'),
        screen: const SizedBox.shrink(),
        fabConfig: null,
        requiredPermission: Permission.viewMedicationTab,
        color: Colors.grey,
        telemetryKey: 'medikamente',
        section: AnchorSection.everyday,
      );
      final tabs = [...allTestTabs, medicationTab];

      Profile profileWith(List<String> permissions) => Profile.withColor(
        id: 'test-2',
        name: 'Test User',
        preferredColor: Colors.blue,
        createdAt: DateTime.now(),
        permissions: permissions,
      );

      expect(
        visibleTabsFor(tabs, profileWith([])),
        orderedEquals(allTestTabs),
      );
      expect(
        visibleTabsFor(tabs, profileWith([Permission.viewMedicationTab.name])),
        orderedEquals(tabs),
      );
    });

    test('Chat ist immer sichtbar auch ohne viewChatTab', () {
      final profile = Profile.withColor(
        id: 'test-3',
        name: 'Test User',
        preferredColor: Colors.blue,
        createdAt: DateTime.now(),
        permissions: [], // Keine Rechte
      );

      final visible = visibleTabsFor(allTestTabs, profile);

      // Chat muss trotzdem sichtbar sein
      expect(visible.contains(chatTab), isTrue);
    });

    test('Feedback ist immer sichtbar auch ohne viewFeedbackTab', () {
      final profile = Profile.withColor(
        id: 'test-4',
        name: 'Test User',
        preferredColor: Colors.blue,
        createdAt: DateTime.now(),
        permissions: [], // Keine Rechte
      );

      final visible = visibleTabsFor(allTestTabs, profile);

      // Feedback muss trotzdem sichtbar sein
      expect(visible.contains(feedbackTab), isTrue);
    });

    test('Halt (Erdung) ist immer sichtbar (Kern-Funktion)', () {
      final profile = Profile.withColor(
        id: 'test-5',
        name: 'Test User',
        preferredColor: Colors.blue,
        createdAt: DateTime.now(),
        permissions: [], // Keine Rechte
      );

      final visible = visibleTabsFor(allTestTabs, profile);

      // Halt muss trotzdem sichtbar sein (Kern-Funktion)
      expect(visible.contains(groundingTab), isTrue);
    });

    test('die Reihenfolge der Tabs bleibt die der Definition', () {
      final profile = Profile.withColor(
        id: 'test-6',
        name: 'Test User',
        preferredColor: Colors.blue,
        createdAt: DateTime.now(),
        permissions: [
          Permission.viewDiaryTab.name,
          Permission.viewCalendarTab.name,
        ], // Alle Rechte
      );

      final visible = visibleTabsFor(allTestTabs, profile);

      // Alle sollten sichtbar sein in der ursprünglichen Reihenfolge
      expect(visible, orderedEquals(allTestTabs));
    });

    test('ein Admin-Profil sieht alle Tabs', () {
      final profile = Profile.withColor(
        id: 'test-admin',
        name: 'Admin',
        preferredColor: Colors.red,
        createdAt: DateTime.now(),
        isAdmin: true,
        permissions: [], // Admin braucht keine expliziten Rechte
      );

      final visible = visibleTabsFor(allTestTabs, profile);

      // Admin sieht alles
      expect(visible, hasLength(5));
      expect(visible, orderedEquals(allTestTabs));
    });
  });
}
