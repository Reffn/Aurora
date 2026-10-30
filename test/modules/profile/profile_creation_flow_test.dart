import 'dart:typed_data';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/profile_events.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/profile_creation_screen.dart';
import 'package:dis_app/services/einrichtung_meldung.dart';
import 'package:dis_app/services/permission_preset_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../../helpers/temp_hive.dart';

/// Die Profilanlage von vorn bis hinten, mit echten Tipps auf „Weiter“.
///
/// Der Ablauf tippt nicht nach Seitenzahl, sondern so lange, bis das Profil
/// angelegt ist: Steht ein Altersregler da, wird das Alter gesetzt; steht das
/// Namensfeld leer da, der Name. So galten die Tests für die fünf Schritte
/// bis 3.0.24 und gelten für die zwei ab 3.0.25 — gegen die alte Fassung
/// geschrieben und grün gesehen, bevor sie umgebaut wurde.
class _FakeDataEntry implements DataEntry {
  _FakeDataEntry(this.bus, this.vorhandene);

  final EventBus bus;
  final List<Profile> vorhandene;
  final List<Profile> created = [];
  final List<Profile> aktiviert = [];

  @override
  List<Profile> getProfiles() => [...vorhandene, ...created];

  @override
  List<Profile> getAllProfiles() => [...vorhandene, ...created];

  /// Wie die echte Tür: Das Anlegen ist ein Ereignis auf dem Bus.
  @override
  Future<void> createProfile(Profile profile, {String source = 'UI'}) async {
    created.add(profile);
    bus.publish(ProfileCreatedEvent(profile));
  }

  @override
  Future<void> changeActiveProfile(
    Profile profile, {
    String source = 'UI',
  }) async {
    aktiviert.add(profile);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late EventBus bus;
  late Box<dynamic> settings;
  late PermissionPresetService vorlagen;
  late int einrichtungGemeldet;
  late AppLocalizations l10n;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    l10n = await AppLocalizations.delegate.load(const Locale('de'));
    vorlagen = PermissionPresetService();
    await vorlagen.initialize();
  });

  setUp(() async {
    await getIt.reset();
    await openTempBox<dynamic>('hive_init_anlage');
    settings = await Hive.openBox<dynamic>(
      'settings_anlage',
      bytes: Uint8List(0),
    );
    bus = EventBus();
    einrichtungGemeldet = 0;
    meldeEinrichtungEinmal(
      eventBus: bus,
      settingsBox: settings,
      melde: () async => einrichtungGemeldet++,
    );
    getIt.registerSingleton<PermissionPresetService>(vorlagen);
  });

  tearDown(() async {
    await getIt.reset();
    bus.dispose();
    await settings.close();
  });

  /// Die Vorlage so, wie die Anlage sie speichert: nur Rechte, die das
  /// Enum kennt.
  Set<String> vorlage(String name) => vorlagen
      .getPermissionsForPreset(name)
      .map(Permission.fromString)
      .whereType<Permission>()
      .map((p) => p.persistedValue)
      .toSet();

  Profile profil(String id) => Profile(
    id: id,
    nameRaw: id,
    preferredColorValue: 0xFF3366CC,
    createdAt: DateTime(2026, 10, 29),
  );

  /// Baut die Anlage als Startschirm (erstes Profil) oder als Route über
  /// einer Liste (jedes weitere), wie in der App.
  Future<_FakeDataEntry> zeigen(
    WidgetTester tester, {
    List<Profile> vorhandene = const [],
  }) async {
    final dataEntry = _FakeDataEntry(bus, [...vorhandene]);
    getIt.registerSingleton<DataEntry>(dataEntry);

    tester.view
      ..physicalSize = const Size(1200, 2400)
      ..devicePixelRatio = 1.5;
    addTearDown(tester.view.reset);

    Widget anlage(BuildContext context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: const ProfileCreationScreen(),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: vorhandene.isEmpty
            ? Builder(builder: anlage)
            : Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: anlage),
                      ),
                      child: const Text('Liste'),
                    ),
                  ),
                ),
              ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    if (vorhandene.isNotEmpty) {
      await tester.tap(find.text('Liste'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
    return dataEntry;
  }

  Future<void> blaettern(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Füllt aus, was dasteht, und tippt „Weiter“, bis angelegt ist.
  Future<void> anlegen(
    WidgetTester tester,
    _FakeDataEntry dataEntry, {
    required String name,
    required int alter,
  }) async {
    var nameGesetzt = false;
    for (var i = 0; i < 10 && dataEntry.created.isEmpty; i++) {
      final regler = find.byType(Slider);
      if (regler.evaluate().isNotEmpty) {
        tester.widget<Slider>(regler).onChanged!(alter.toDouble());
        await tester.pump();
      }
      final namensfeld = find.byType(TextField);
      if (!nameGesetzt && namensfeld.evaluate().isNotEmpty) {
        await tester.enterText(namensfeld.first, name);
        nameGesetzt = true;
        await tester.pump();
      }
      final knopf = find.byType(ElevatedButton);
      await tester.ensureVisible(knopf);
      await tester.tap(knopf);
      await blaettern(tester);
    }
    // Ereignisse auf dem Bus laufen eine Runde später, und Hive schreibt
    // außerhalb der angehaltenen Testzeit.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('Altersabhängige Rechte bei der Anlage', () {
    testWidgets('unter 8 Jahren: die Kindervorlage', (tester) async {
      final dataEntry = await zeigen(tester);
      await anlegen(tester, dataEntry, name: 'Pip', alter: 6);

      expect(dataEntry.created, hasLength(1));
      final angelegt = dataEntry.created.single;
      expect(angelegt.age, 6);
      expect(vorlage('child'), isNotEmpty);
      expect(angelegt.permissions.toSet(), vorlage('child'));
    });

    testWidgets('ab 8 Jahren: die Standardvorlage', (tester) async {
      final dataEntry = await zeigen(tester);
      await anlegen(tester, dataEntry, name: 'Lou', alter: 30);

      final angelegt = dataEntry.created.single;
      expect(angelegt.age, 30);
      expect(vorlage('standard'), isNot(vorlage('child')));
      expect(angelegt.permissions.toSet(), vorlage('standard'));
      // Das erste Profil ist Admin, die Vorlage gilt trotzdem.
      expect(angelegt.isAdmin, isTrue);
      expect(
        angelegt.permissions,
        contains(Permission.viewChatTab.persistedValue),
      );
    });
  });

  group('Einrichtung abgeschlossen', () {
    testWidgets('das erste Profil meldet sie genau einmal', (tester) async {
      final dataEntry = await zeigen(tester);
      await anlegen(tester, dataEntry, name: 'Lou', alter: 30);

      expect(dataEntry.created, hasLength(1));
      expect(einrichtungGemeldet, 1);
    });

    testWidgets('ein weiteres Profil meldet sie nicht noch einmal', (
      tester,
    ) async {
      await settings.put(einrichtungGemeldetKey, true);
      final dataEntry = await zeigen(tester, vorhandene: [profil('lou')]);
      await anlegen(tester, dataEntry, name: 'Mira', alter: 30);

      expect(dataEntry.created, hasLength(1));
      expect(einrichtungGemeldet, 0);
    });
  });

  // C2: Wer das erste Profil anlegt, landet direkt in der App — ohne
  // Startauswahl und ohne „Weiter als …“. Die Startkette in `main.dart`
  // wechselt `home` von selbst auf den Hauptschirm, sobald ein aktives
  // Profil da ist; die Anlage ist dort `home`, nichts liegt darüber.
  group('Nach dem Anlegen', () {
    testWidgets('das erste Profil wird aktiv, nichts wird geschlossen', (
      tester,
    ) async {
      final dataEntry = await zeigen(tester);
      await anlegen(tester, dataEntry, name: 'Lou', alter: 30);

      expect(dataEntry.aktiviert.map((p) => p.id), [
        dataEntry.created.single.id,
      ]);
      expect(find.byType(ProfileCreationScreen), findsOneWidget);
    });

    testWidgets('ein weiteres Profil wird nicht aktiv, die Anlage schließt', (
      tester,
    ) async {
      final dataEntry = await zeigen(tester, vorhandene: [profil('lou')]);
      await anlegen(tester, dataEntry, name: 'Mira', alter: 30);

      expect(dataEntry.created, hasLength(1));
      expect(dataEntry.aktiviert, isEmpty);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ProfileCreationScreen), findsNothing);
      expect(find.text('Liste'), findsOneWidget);
    });
  });

  // Abnahme am Emulator: Bei „Neues Profil“ mit leerem Namensfeld stand im
  // Farbrad „LU“ — die Initialen von Lumi. Das ist Lumis Marke für ihre
  // schon belegte Farbe (`_UserMarkersPainter`), keine Vorschau des neuen
  // Profils. Die Vorschau selbst zeigt bei leerem Feld „?“ und folgt dem
  // Namen, sobald er getippt wird; das hält dieser Test fest.
  testWidgets('leeres Namensfeld: die Vorschau zeigt „?“, keine fremden '
      'Initialen', (tester) async {
    final lumi = Profile(
      id: 'lumi',
      nameRaw: 'Lumi',
      preferredColorValue: 0xFF3366CC,
      createdAt: DateTime(2026, 10, 29),
      colorPickerPositionX: 0.5,
      colorPickerPositionY: 0.3,
    );
    await zeigen(tester, vorhandene: [lumi]);

    List<String> texte() => tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
        .toList();

    expect(texte().where((t) => t.toUpperCase() == 'LU'), isEmpty);
    expect(texte(), contains('?'));

    await tester.enterText(find.byType(TextField).first, 'Mo');
    await tester.pump();
    expect(texte(), contains('MO'));
    expect(texte(), isNot(contains('?')));
  });

  testWidgets('ohne Namen geht es nicht weiter', (tester) async {
    final dataEntry = await zeigen(tester);
    final weiter = find.byType(ElevatedButton);
    for (var i = 0; i < 6; i++) {
      await tester.ensureVisible(weiter);
      await tester.tap(weiter);
      await blaettern(tester);
    }
    expect(dataEntry.created, isEmpty);
    expect(find.text(l10n.profileWhoAreYou), findsOneWidget);
  });
}
