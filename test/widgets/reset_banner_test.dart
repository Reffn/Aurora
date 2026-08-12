import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/l10n/app_localizations.dart';
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
import 'package:dis_app/widgets/reset_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Tests für das Reset-Banner (Unit 5).
///
/// Das Banner ist der sichtbare Teil des Schutzes — ohne es wäre eine
/// Frist nur Wartezeit. Geprüft wird: erscheint es, verschwindet es mit
/// Fristende, und bündelt es die Flächen, bevor der Schirm gesättigt ist.
void main() {
  late Directory tempDir;
  late ProfileService profileService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('reset_banner_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }

    final eventBus = EventBus();
    profileService = ProfileService(eventBus);
    await profileService.openBoxes();
    final resetService = PasswordResetService(profileService, eventBus);

    final dataEntry = DataEntry(
      eventBus,
      chatService: ChatService(eventBus),
      profileService: profileService,
      calendarService: CalendarService(eventBus),
      medicationService: MedicationService(eventBus),
      contactService: ContactService(eventBus),
      finderService: FinderService(eventBus),
      diaryService: DiaryService(eventBus),
      commentService: CommentService(eventBus),
      navigationService: NavigationService(eventBus),
      passwordResetService: resetService,
    );

    await getIt.reset();
    getIt.registerSingleton<ProfileService>(profileService);
    getIt.registerSingleton<PasswordResetService>(resetService);
    getIt.registerSingleton<DataEntry>(dataEntry);
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } on FileSystemException {
      // Windows-Lock — das Betriebssystem räumt auf
    }
  });

  /// Hive-Schreibvorgänge müssen durch runAsync — in der FakeAsync-Zone
  /// von testWidgets completen sie nicht.
  Future<void> legeProfilAn(
    WidgetTester tester,
    String id, {
    Duration? restfrist,
    int farbe = 0xFFAA0000,
  }) async {
    final jetzt = DateTime.now();
    await tester.runAsync(() => profileService.profilesBox.put(
      id,
      Profile(
        id: id,
        nameRaw: 'Profil $id',
        preferredColorValue: farbe,
        createdAt: jetzt,
        passwordHash: 'hash',
        resetStartedAt: restfrist == null ? null : jetzt,
        resetEndsAt: restfrist == null ? null : jetzt.add(restfrist),
        pendingPasswordHash: restfrist == null ? null : 'pending',
      ),
    ));
  }

  Future<void> pumpBanner(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ResetBanner()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }

  group('ResetBanner (Unit 5)', () {
    testWidgets('ohne laufenden Reset bleibt es unsichtbar', (tester) async {
      await legeProfilAn(tester, 'profil-aaaa-1111');

      await pumpBanner(tester);

      expect(find.byIcon(Icons.hourglass_top), findsNothing);
    });

    testWidgets('laufender Reset zeigt Profilnamen und Restzeit',
        (tester) async {
      await legeProfilAn(tester, 'profil-aaaa-1111',
          restfrist: const Duration(hours: 5));

      await pumpBanner(tester);

      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
      expect(find.textContaining('Profil profil-aaaa-1111'), findsOneWidget);
      expect(find.textContaining('4h'), findsOneWidget);
    });

    testWidgets('abgelaufene Frist verschwindet aus dem Banner',
        (tester) async {
      await legeProfilAn(tester, 'profil-aaaa-1111',
          restfrist: const Duration(seconds: -30));

      await pumpBanner(tester);

      expect(find.byIcon(Icons.hourglass_top), findsNothing);
    });

    testWidgets('drei Resets stehen einzeln', (tester) async {
      await legeProfilAn(tester, 'profil-aaaa-1111',
          restfrist: const Duration(hours: 2));
      await legeProfilAn(tester, 'profil-bbbb-2222',
          restfrist: const Duration(hours: 3), farbe: 0xFF00AA00);
      await legeProfilAn(tester, 'profil-cccc-3333',
          restfrist: const Duration(hours: 4), farbe: 0xFF0000AA);

      await pumpBanner(tester);

      expect(find.byIcon(Icons.hourglass_top), findsNWidgets(3));
    });

    testWidgets('ab vier Resets wird gebündelt statt gestapelt',
        (tester) async {
      for (var i = 0; i < 4; i++) {
        await legeProfilAn(tester, 'profil-$i$i$i$i-0000',
            restfrist: Duration(hours: i + 2));
      }

      await pumpBanner(tester);

      // Eine Fläche, vier Farbpunkte — sonst wäre der halbe Schirm gesättigt.
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNWidgets(4));
    });
  });
}
