import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/onboarding/pre_onboarding_screen.dart';
import 'package:dis_app/modules/profile/profile_creation_screen.dart';
import 'package:dis_app/widgets/animated_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

class _MinimalDataEntry implements DataEntry {
  @override
  List<Profile> getProfiles() => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('reduced_motion_test_');
    Hive.init(tempDir.path);
    await getIt.reset();
    getIt.registerSingleton<DataEntry>(_MinimalDataEntry());
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } on FileSystemException {
      // Windows hält Hive-Dateien gelegentlich noch kurz fest.
    }
  });

  Widget app(Widget child, {required bool disableAnimations}) {
    return MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(900, 1400),
        ).copyWith(disableAnimations: disableAnimations),
        child: child,
      ),
    );
  }

  Future<void> expectNoContinuousMotion(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.pumpWidget(app(child, disableAnimations: true));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.hasRunningAnimations, isFalse);
  }

  Future<void> expectContinuousMotion(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.pumpWidget(app(child, disableAnimations: false));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.hasRunningAnimations, isTrue);
  }

  testWidgets('Pre-Onboarding stoppt dekorative Kreisbewegung', (tester) async {
    await expectNoContinuousMotion(tester, const PreOnboardingScreen());
  });

  testWidgets('Pre-Onboarding bewegt die Kreise ohne Systemoption', (
    tester,
  ) async {
    await expectContinuousMotion(tester, const PreOnboardingScreen());
  });

  testWidgets('Profilerstellung stoppt dekoratives Logo-Pulsieren', (
    tester,
  ) async {
    await expectNoContinuousMotion(tester, const ProfileCreationScreen());
  });

  testWidgets('Profilerstellung pulsiert ohne Systemoption', (tester) async {
    await expectContinuousMotion(tester, const ProfileCreationScreen());
  });

  testWidgets('Leerzustand pulsiert bei reduzierter Bewegung nicht', (
    tester,
  ) async {
    await expectNoContinuousMotion(
      tester,
      const Scaffold(
        body: AnimatedEmptyState(
          icon: Icons.event_note,
          title: 'Noch nichts da',
          subtitle: 'Ein ruhiger Leerzustand',
        ),
      ),
    );
  });

  testWidgets('Leerzustand pulsiert ohne Systemoption', (tester) async {
    await expectContinuousMotion(
      tester,
      const Scaffold(
        body: AnimatedEmptyState(
          icon: Icons.event_note,
          title: 'Noch nichts da',
          subtitle: 'Ein ruhiger Leerzustand',
        ),
      ),
    );
  });
}
