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

    test('ein Anteil ohne viewDiaryTab sieht das Tagebuch nicht', () {
      final profile = Profile.withColor(
        id: 'test-1',
        name: 'Test User',
        preferredColor: Colors.blue,
        createdAt: DateTime.now(),
        permissions: [], // Keine Rechte
      );

      final visible = visibleTabsFor(allTestTabs, profile);

      // Nur Chat, Feedback, Halt (immer sichtbar)
      // Tagebuch und Kalender nicht (brauchen Rechte)
      expect(visible, hasLength(3));
      expect(visible, isNot(contains(diaryTab)));
      expect(visible, isNot(contains(calendarTab)));
      expect(visible.contains(chatTab), isTrue);
      expect(visible.contains(feedbackTab), isTrue);
      expect(visible.contains(groundingTab), isTrue);
    });

    test('ein Anteil ohne viewCalendarTab sieht den Kalender nicht', () {
      final profile = Profile.withColor(
        id: 'test-2',
        name: 'Test User',
        preferredColor: Colors.blue,
        createdAt: DateTime.now(),
        permissions: [Permission.viewDiaryTab.name], // Nur Tagebuch
      );

      final visible = visibleTabsFor(allTestTabs, profile);

      // Chat, Feedback, Tagebuch, Halt (immer sichtbar oder erlaubt)
      // Kalender nicht (braucht viewCalendarTab)
      expect(visible, hasLength(4));
      expect(visible, isNot(contains(calendarTab)));
      expect(visible.contains(chatTab), isTrue);
      expect(visible.contains(feedbackTab), isTrue);
      expect(visible.contains(diaryTab), isTrue);
      expect(visible.contains(groundingTab), isTrue);
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
