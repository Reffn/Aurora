import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/games/games_screen.dart';
import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/exercise_player_screen.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// „Atemübungen" in Spiele & Entspannung.
///
/// Der Eintrag stand als „Bald" auf der Fläche, während „Halt" eine fertige
/// Atemübung anbietet. Wer unter Stress den naheliegenden Eintrag wählt,
/// landete damit in einer Sackgasse statt auf dem vorhandenen Weg.
///
/// Eine tote Karte an einer Stelle, die jemand in schlechtem Zustand
/// ansteuert, ist teurer als eine fehlende.
void main() {
  late Directory tempDir;

  // Die Kopfzeile der Fläche holt sich DataEntry über getIt. Ohne diesen
  // Aufbau scheitert schon das Bauen, bevor irgendetwas geprüft wäre.
  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atemuebung_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }

    final eventBus = EventBus();
    final profileService = ProfileService(eventBus);
    await profileService.openBoxes();
    final resetService = PasswordResetService(profileService, eventBus);

    await getIt.reset();
    getIt.registerSingleton<DataEntry>(
      DataEntry(
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
      ),
    );
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows gibt die Datei manchmal verzögert frei.
    }
  });

  Future<void> zeigeSpiele(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('de'),
        home: GamesScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Die Atemübung ist erreichbar und landet bei der echten Übung',
      (tester) async {
    await zeigeSpiele(tester);

    await tester.tap(find.text('Atemübungen'));
    await tester.pumpAndSettle();

    expect(find.byType(ExercisePlayerScreen), findsOneWidget);

    final spieler = tester.widget<ExercisePlayerScreen>(
      find.byType(ExercisePlayerScreen),
    );
    expect(
      spieler.exercise.id,
      GroundingExercises.breath.id,
      reason: 'Es muss dieselbe Übung sein, die „Halt" anbietet — keine '
          'zweite Fassung, die getrennt gepflegt werden müsste.',
    );
  });

  testWidgets('Die Atemübung wird nicht mehr als „Bald" geführt',
      (tester) async {
    await zeigeSpiele(tester);

    final karte = find.ancestor(
      of: find.text('Atemübungen'),
      matching: find.byType(InkWell),
    );

    expect(
      karte,
      findsWidgets,
      reason: 'Ohne antippbare Fläche wäre der Eintrag weiterhin tot.',
    );
  });
}
