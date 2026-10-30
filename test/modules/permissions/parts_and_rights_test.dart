import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/part_right.dart';
import 'package:dis_app/models/part_right_text.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/permissions/permissions_manager_screen.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// „Anteile & Rechte“: der Schirm, der sechzig Kästchen in neun rot
/// markierten Kategorien ersetzt.
///
/// Alle Abläufe gehen über echte Tipps. Die Attrappe unten schreibt wie der
/// Dienst in eine Box, die `watch()` meldet; die Regeln des Dienstes selbst
/// prüfen `part_right_service_test.dart` und `profile_pause_test.dart`.
void main() {
  late AppLocalizations l10n;
  late _Anteile anteile;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('de'));
  });

  setUp(() async {
    await getIt.reset();
    anteile = _Anteile();
    getIt.registerSingleton<DataEntry>(anteile);
  });

  tearDown(() async {
    await getIt.reset();
  });

  /// Ada ist der älteste Anteil und Admin, Ben ein zweiter Admin. Lou darf
  /// Rechte vergeben, ist aber kein Admin. Mira hat [miraRechte], Zora
  /// ist pausiert, wenn [zoraPausiert].
  void aufbau({
    String aktiv = 'ada',
    List<Permission> miraRechte = const [],
    bool zoraPausiert = false,
  }) {
    anteile
      ..anlegen(
        'ada',
        isAdmin: true,
        rechte: Permission.values,
        angelegt: DateTime(2026),
      )
      ..anlegen(
        'ben',
        isAdmin: true,
        rechte: Permission.values,
        angelegt: DateTime(2026, 3),
      )
      ..anlegen(
        'lou',
        rechte: [Permission.managePermissions, Permission.accessSettings],
        angelegt: DateTime(2026, 4),
      )
      ..anlegen(
        'mira',
        rechte: miraRechte,
        alter: 9,
        angelegt: DateTime(2026, 5),
      );
    if (zoraPausiert) {
      anteile.anlegen('zora', aktiv: false, angelegt: DateTime(2026, 6));
    }
    anteile.aktivId = aktiv;
  }

  /// Feste Schritte statt `pumpAndSettle`: Avatare und Snackbars laufen
  /// mit Zeitgebern.
  Future<void> warte(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Snackbars nehmen sich selbst zurück. Bis dahin laufen lassen, sonst
  /// bleibt ein Zeitgeber über das Testende hinaus offen.
  Future<void> snackbarAuslaufen(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 15));
  }

  Future<void> listeZeigen(WidgetTester tester) async {
    // Hoch genug, dass alle Schalter ohne Scrollen gebaut sind.
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PermissionsManagerScreen(),
      ),
    );
    await warte(tester);
  }

  Future<void> anteilOeffnen(WidgetTester tester, String name) async {
    await tester.tap(find.text(name).first);
    await warte(tester);
  }

  /// `pageBack()` sucht den Tooltip „Back“, auf Deutsch heißt er anders.
  Future<void> zurueck(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await warte(tester);
  }

  Finder schalter(PartRight right) => find.ancestor(
    of: find.text(right.label(l10n)),
    matching: find.byType(SwitchListTile),
  );

  Set<String> gespeichert(String id) =>
      anteile.getProfileById(id)!.permissions.toSet();

  testWidgets('Admin sieht keine Schalter', (tester) async {
    aufbau();
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'ada');

    expect(find.text(l10n.rightsAdminSummary), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.byType(Switch), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(CheckboxListTile), findsNothing);
  });

  // Von den zehn Schaltern des Modells stehen nur die sechs da, die etwas
  // bewirken (Regel 32, `PartRight.hasEffect`).
  testWidgets('Nicht-Admin sieht genau sechs Schalter in drei Gruppen', (
    tester,
  ) async {
    aufbau();
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'mira');

    // Kopf: Name und Alter.
    expect(find.text('mira'), findsOneWidget);
    expect(find.text(l10n.profileAgeYears(9)), findsOneWidget);

    expect(find.byType(SwitchListTile), findsNWidgets(6));
    expect(find.byType(Checkbox), findsNothing);

    // Jeder Schalter steht unter der Überschrift seiner Gruppe und über der
    // nächsten.
    double oben(Finder f) => tester.getTopLeft(f).dy;
    const gruppen = PartRightGroup.values;
    for (var i = 0; i < gruppen.length; i++) {
      final kopf = find.text(gruppen[i].label(l10n));
      expect(kopf, findsOneWidget);
      final naechster = i + 1 < gruppen.length
          ? oben(find.text(gruppen[i + 1].label(l10n)))
          : double.infinity;
      for (final right in PartRight.values.where(
        (r) => r.group == gruppen[i] && r.hasEffect,
      )) {
        expect(schalter(right), findsOneWidget, reason: right.name);
        final y = oben(schalter(right));
        expect(y, greaterThan(oben(kopf)), reason: right.name);
        expect(y, lessThan(naechster), reason: right.name);
      }
    }
  });

  // Regel 32: Kein Schalter, der nichts bewirkt, auch dann nicht, wenn das
  // Profil seine Rechte gespeichert hat. Auch sein Symbol in der Liste fehlt.
  testWidgets('Schalter ohne Wirkung fehlen, als Schalter und als Symbol', (
    tester,
  ) async {
    const ohneWirkung = [
      PartRight.readOthersDiaries,
      PartRight.createParts,
      PartRight.changeSettings,
      PartRight.resetPasswords,
    ];
    aufbau(
      miraRechte: [
        for (final right in ohneWirkung) ...right.permissions,
        ...PartRight.seeMedication.permissions,
      ],
    );
    await listeZeigen(tester);

    // In der Liste: das Symbol für „Medikamente sehen“ als Gegenprobe, keins
    // der ausgeblendeten.
    final karte = find.ancestor(
      of: find.text('mira'),
      matching: find.byType(Card),
    );
    Finder symbol(IconData icon) =>
        find.descendant(of: karte, matching: find.byIcon(icon));
    expect(symbol(PartRight.seeMedication.icon), findsOneWidget);
    for (final right in ohneWirkung) {
      expect(symbol(right.icon), findsNothing, reason: right.name);
    }

    // Auf der Seite: kein Schalter, kein Wort.
    await anteilOeffnen(tester, 'mira');
    expect(schalter(PartRight.seeMedication), findsOneWidget);
    for (final right in ohneWirkung) {
      expect(find.text(right.label(l10n)), findsNothing, reason: right.name);
    }
  });

  testWidgets('Schalter Medikamente sehen schreibt die Rechte', (tester) async {
    aufbau();
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'mira');
    expect(
      tester.widget<SwitchListTile>(schalter(PartRight.seeMedication)).value,
      isFalse,
    );

    await tester.tap(schalter(PartRight.seeMedication));
    await warte(tester);

    expect(
      gespeichert('mira'),
      containsAll([
        Permission.viewMedication.persistedValue,
        Permission.viewMedicationTab.persistedValue,
      ]),
    );
    // Nur dieser Schalter, nicht der Plan.
    expect(
      gespeichert('mira'),
      isNot(contains(Permission.manageMedication.persistedValue)),
    );
    expect(
      tester.widget<SwitchListTile>(schalter(PartRight.seeMedication)).value,
      isTrue,
    );
  });

  testWidgets('halb gesetzter Schalter zeigt Teilweise erlaubt', (
    tester,
  ) async {
    // Ein altes Profil: ändern darf es Termine, aber keine Tagebucheinträge.
    aufbau(miraRechte: [Permission.editAllEvents]);
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'mira');

    final halb = schalter(PartRight.changeOthersEntries);
    expect(tester.widget<SwitchListTile>(halb).value, isFalse);
    expect(
      find.descendant(of: halb, matching: find.text(l10n.rightsPartly)),
      findsOneWidget,
    );
    expect(find.text(l10n.rightsPartly), findsOneWidget);

    // Einschalten setzt alle seine Rechte, die Unterzeile geht.
    await tester.tap(halb);
    await warte(tester);

    expect(
      gespeichert('mira'),
      containsAll([
        Permission.editAllEvents.persistedValue,
        Permission.editAllDiaryEntries.persistedValue,
      ]),
    );
    expect(tester.widget<SwitchListTile>(halb).value, isTrue);
    expect(find.text(l10n.rightsPartly), findsNothing);
  });

  testWidgets('Pausiert-Gruppe nur mit pausierten Anteilen', (tester) async {
    aufbau();
    await listeZeigen(tester);

    expect(find.text(l10n.partsActiveHeader), findsOneWidget);
    expect(find.text(l10n.partsPausedHeader), findsNothing);
    expect(find.text(l10n.profileResumeAction), findsNothing);
  });

  testWidgets('pausierter Anteil steht unter Pausiert und kommt zurück', (
    tester,
  ) async {
    aufbau(zoraPausiert: true);
    await listeZeigen(tester);

    final kopf = find.text(l10n.partsPausedHeader);
    expect(kopf, findsOneWidget);
    expect(find.text('zora'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('zora')).dy,
      greaterThan(tester.getTopLeft(kopf).dy),
    );

    await tester.tap(find.text(l10n.profileResumeAction));
    await warte(tester);

    expect(anteile.getProfileById('zora')!.isActive, isTrue);
    expect(find.text(l10n.partsPausedHeader), findsNothing);
    expect(find.text(l10n.profileResumedSnack('zora')), findsOneWidget);
    await snackbarAuslaufen(tester);
  });

  testWidgets('ohne Recht zum Pausieren kein Wieder aufnehmen', (
    tester,
  ) async {
    aufbau(aktiv: 'lou', zoraPausiert: true);
    await listeZeigen(tester);

    expect(find.text(l10n.partsPausedHeader), findsOneWidget);
    expect(find.text('zora'), findsOneWidget);
    expect(find.text(l10n.profileResumeAction), findsNothing);
  });

  testWidgets('kein Warndreieck', (tester) async {
    aufbau(miraRechte: [Permission.editAllEvents]);
    await listeZeigen(tester);

    void ruhig(String wo) {
      for (final symbol in const [
        Icons.warning,
        Icons.warning_amber,
        Icons.warning_amber_rounded,
        Icons.warning_rounded,
        Icons.warning_outlined,
        Icons.report_problem,
        Icons.report_problem_outlined,
      ]) {
        expect(find.byIcon(symbol), findsNothing, reason: '$wo: $symbol');
      }
      // Auch keine rote Farbe an einem Symbol: Kräftige Farbe gehört Halt,
      // Notfall und Hilfe.
      for (final icon in tester.widgetList<Icon>(find.byType(Icon))) {
        final farbe = icon.color;
        if (farbe == null) continue;
        final hsl = HSLColor.fromColor(farbe);
        final rot = hsl.saturation > 0.4 && (hsl.hue < 20 || hsl.hue > 340);
        expect(rot, isFalse, reason: '$wo: rötliches Symbol ${icon.icon}');
      }
    }

    ruhig('Liste');
    await anteilOeffnen(tester, 'mira');
    ruhig('Mira');
    await zurueck(tester);
    await anteilOeffnen(tester, 'ada');
    ruhig('Ada');
  });

  testWidgets('auf der eigenen Seite fehlt Rechte vergeben', (tester) async {
    aufbau(aktiv: 'lou');
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'lou');

    // Sonst sperrt sich ein Nicht-Admin mit einem Tipp selbst aus.
    expect(find.byType(SwitchListTile), findsNWidgets(5));
    expect(find.text(PartRight.grantRights.label(l10n)), findsNothing);
  });

  testWidgets('ohne Admin-Rolle keine Admin-Knöpfe', (tester) async {
    aufbau(aktiv: 'lou');
    await listeZeigen(tester);

    await anteilOeffnen(tester, 'mira');
    expect(find.byType(SwitchListTile), findsNWidgets(6));
    expect(find.text(l10n.permissionsMakeAdminButton), findsNothing);
    await zurueck(tester);

    await anteilOeffnen(tester, 'ben');
    expect(find.text(l10n.rightsAdminSummary), findsOneWidget);
    expect(find.text(l10n.rightsRevokeAdmin), findsNothing);
  });

  testWidgets('Admin macht einen Anteil zum Administrator', (tester) async {
    aufbau();
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'mira');

    await tester.tap(find.text(l10n.permissionsMakeAdminButton));
    await warte(tester);
    expect(find.text(l10n.permissionsMakeAdminMessage('mira')), findsOneWidget);
    await tester.tap(find.text(l10n.actionConfirm));
    await warte(tester);

    expect(anteile.getProfileById('mira')!.isAdmin, isTrue);
    expect(find.text(l10n.rightsAdminSummary), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNothing);
  });

  testWidgets('Admin-Rolle abgeben nur, wo es gelingt', (tester) async {
    aufbau();
    await listeZeigen(tester);

    // Der älteste Anteil bleibt Admin, also kein Knopf.
    await anteilOeffnen(tester, 'ada');
    expect(find.text(l10n.rightsRevokeAdmin), findsNothing);
    await zurueck(tester);

    await anteilOeffnen(tester, 'ben');
    await tester.tap(find.text(l10n.rightsRevokeAdmin));
    await warte(tester);
    await tester.tap(find.text(l10n.actionConfirm));
    await warte(tester);

    expect(anteile.getProfileById('ben')!.isAdmin, isFalse);
    expect(find.byType(SwitchListTile), findsNWidgets(6));
  });

  // Regel 31: Wer nur „Anteile pausieren“ hat, kommt über Einstellungen →
  // Verwaltung hierher (`settings_layout_test.dart`). Die Schalter sind dann
  // nur zu lesen, Pausieren und Wieder aufnehmen gehen.
  testWidgets('nur mit Anteile pausieren: Schalter nur zu lesen, Pausieren '
      'und Wieder aufnehmen gehen', (tester) async {
    aufbau();
    anteile
      ..anlegen(
        'kai',
        rechte: [Permission.deactivateProfiles],
        angelegt: DateTime(2026, 7),
      )
      ..aktivId = 'kai';
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'mira');
    final vorher = gespeichert('mira');

    final schalterAufSeite = tester.widgetList<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(schalterAufSeite, isNotEmpty);
    for (final s in schalterAufSeite) {
      expect(s.onChanged, isNull, reason: 'nur zu lesen');
    }
    await tester.tap(schalter(PartRight.seeMedication));
    await warte(tester);
    expect(gespeichert('mira'), vorher);

    // Pausieren.
    await tester.tap(find.text(l10n.partsPauseNamed('mira')));
    await warte(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(l10n.profilePauseAction),
      ),
    );
    await warte(tester);
    expect(anteile.getProfileById('mira')!.isActive, isFalse);
    expect(find.text(l10n.partsPausedHeader), findsOneWidget);
    await snackbarAuslaufen(tester);

    // Wieder aufnehmen.
    await tester.tap(find.text(l10n.profileResumeAction));
    await warte(tester);
    expect(anteile.getProfileById('mira')!.isActive, isTrue);
    expect(find.text(l10n.partsPausedHeader), findsNothing);
    await snackbarAuslaufen(tester);
  });

  testWidgets('der Bestätigungsknopf heißt Pausieren, nicht Löschen', (
    tester,
  ) async {
    aufbau();
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'mira');
    await tester.tap(find.text(l10n.partsPauseNamed('mira')));
    await warte(tester);

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text(l10n.actionDelete)),
      findsNothing,
    );
    expect(
      find.descendant(of: dialog, matching: find.text(l10n.actionCancel)),
      findsOneWidget,
    );

    final knopf = find.ancestor(
      of: find.descendant(
        of: dialog,
        matching: find.text(l10n.profilePauseAction),
      ),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
    expect(knopf, findsOneWidget);

    // Keine Warnfarbe: Pausieren nimmt nichts weg.
    final stil = tester.widget<ButtonStyleButton>(knopf).style;
    final farben = <Color?>[
      stil?.foregroundColor?.resolve(<WidgetState>{}),
      stil?.backgroundColor?.resolve(<WidgetState>{}),
    ].whereType<Color>();
    expect(farben, isNotEmpty);
    for (final farbe in farben) {
      expect(farbe, isNot(AppColors.signal));
      expect(farbe, isNot(AppColors.signalDeep));
      final hsl = HSLColor.fromColor(farbe);
      final rot = hsl.saturation > 0.4 && (hsl.hue < 20 || hsl.hue > 340);
      expect(rot, isFalse, reason: 'rötlicher Knopf: $farbe');
    }

    // Abbrechen lässt alles, wie es war.
    await tester.tap(
      find.descendant(of: dialog, matching: find.text(l10n.actionCancel)),
    );
    await warte(tester);
    expect(anteile.getProfileById('mira')!.isActive, isTrue);
    expect(find.text(l10n.partsPauseNamed('mira')), findsOneWidget);
  });

  // Nach dem Pausieren schließt die Seite sich selbst. Die Snackbar liegt im
  // Overlay darüber und überlebt sie: „Rückgängig“ muss den Anteil trotzdem
  // zurückholen, der tote Kontext der Seite darf den Rückweg nicht
  // verschlucken.
  testWidgets('Rückgängig holt den Anteil zurück, obwohl die Seite schon zu '
      'ist', (tester) async {
    aufbau();
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'mira');
    await tester.tap(find.text(l10n.partsPauseNamed('mira')));
    await warte(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(l10n.profilePauseAction),
      ),
    );
    await warte(tester);
    expect(anteile.getProfileById('mira')!.isActive, isFalse);
    expect(find.byType(SwitchListTile), findsNothing, reason: 'Seite zu');

    await tester.tap(find.text(l10n.actionUndo));
    await warte(tester);

    expect(anteile.getProfileById('mira')!.isActive, isTrue);
    expect(find.text(l10n.partsPausedHeader), findsNothing);
    await snackbarAuslaufen(tester);
  });

  // Am Gerät gefunden (3.0.24): Der Knopf stand klein und grau unter allen
  // Schaltergruppen, und der Schalter „Anteile pausieren“ — ein Recht — sah
  // aus wie die Handlung. Jetzt steht die Handlung oben unter dem Namen,
  // sichtbar ohne Scrollen, mit Symbol und Wort und einer Fläche von 48 dp.
  testWidgets('Pausieren steht oben unter dem Namen, ohne Scrollen sichtbar', (
    tester,
  ) async {
    aufbau();
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'mira');

    // Ein Telefon, nicht die hohe Testfläche: 360 × 780 dp.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    await warte(tester);

    final wort = find.text(l10n.partsPauseNamed('mira'));
    expect(wort, findsOneWidget);
    final knopf = find.ancestor(
      of: wort,
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
    expect(knopf, findsOneWidget);
    expect(
      tester.widget(knopf),
      isNot(isA<TextButton>()),
      reason: 'umrandet oder tonal, kein grauer Textknopf',
    );
    expect(
      find.descendant(of: knopf, matching: find.byType(Icon)),
      findsOneWidget,
      reason: 'Symbol und Wort (Regel 5)',
    );

    final flaeche = tester.getRect(knopf);
    expect(flaeche.height, greaterThanOrEqualTo(48));
    expect(flaeche.bottom, lessThanOrEqualTo(780), reason: 'ohne Scrollen');
    // Unter dem Namen, über der ersten Schaltergruppe.
    expect(flaeche.top, greaterThan(tester.getRect(find.text('mira')).bottom));
    expect(
      flaeche.bottom,
      lessThan(
        tester.getTopLeft(find.text(PartRightGroup.medication.label(l10n))).dy,
      ),
    );
  });

  // Die Schalter sind Erlaubnisse, keine Handlungen. „Anteile pausieren“
  // neben einem Schalter las sich wie der Knopf zum Pausieren; dasselbe gilt
  // für „Einträge anderer löschen“ und „Rechte vergeben“. Alle sagen jetzt,
  // was der Anteil darf.
  testWidgets('jeder Schalter sagt, was der Anteil darf', (tester) async {
    aufbau();
    await listeZeigen(tester);
    await anteilOeffnen(tester, 'mira');

    final titel = [
      for (final tile in tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      ))
        (tile.title! as Text).data!,
    ];
    expect(titel, hasLength(6));
    for (final t in titel) {
      expect(t, startsWith('Darf '), reason: t);
    }
    expect(find.text('Darf Anteile pausieren'), findsOneWidget);
  });

  testWidgets('Pausieren oben auf der Seite, danach steht er unter Pausiert', (
    tester,
  ) async {
    aufbau();
    await listeZeigen(tester);

    // Sich selbst pausiert niemand.
    await anteilOeffnen(tester, 'ada');
    expect(find.text(l10n.partsPauseNamed('ada')), findsNothing);
    await zurueck(tester);

    await anteilOeffnen(tester, 'mira');
    await tester.tap(find.text(l10n.partsPauseNamed('mira')));
    await warte(tester);
    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    await tester.tap(
      find.descendant(
        of: dialog,
        matching: find.text(l10n.profilePauseAction),
      ),
    );
    await warte(tester);

    expect(anteile.getProfileById('mira')!.isActive, isFalse);
    // Zurück in der Liste, Mira unter „Pausiert“.
    expect(find.byType(SwitchListTile), findsNothing);
    final kopf = find.text(l10n.partsPausedHeader);
    expect(kopf, findsOneWidget);
    expect(
      tester.getTopLeft(find.text('mira')).dy,
      greaterThan(tester.getTopLeft(kopf).dy),
    );
    await snackbarAuslaufen(tester);
  });
}

/// Hält die Anteile im Speicher und meldet jede Änderung über `watch()`,
/// wie Hive es tut. Daran hängt `listenable()`.
class _Kiste implements Box<Profile> {
  final Map<String, Profile> daten = {};
  final _ereignisse = StreamController<BoxEvent>.broadcast();

  void schreibe(Profile profile) {
    daten[profile.id] = profile;
    _ereignisse.add(BoxEvent(profile.id, profile, false));
  }

  @override
  Profile? get(dynamic key, {Profile? defaultValue}) =>
      daten[key] ?? defaultValue;

  @override
  Iterable<Profile> get values => daten.values;

  @override
  Stream<BoxEvent> watch({dynamic key}) => key == null
      ? _ereignisse.stream
      : _ereignisse.stream.where((e) => e.key == key);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Dieselben Regeln wie `ProfileService`, soweit dieser Schirm sie fragt.
class _Anteile implements DataEntry {
  final kiste = _Kiste();
  String aktivId = 'ada';

  void anlegen(
    String id, {
    required DateTime angelegt,
    bool isAdmin = false,
    bool aktiv = true,
    List<Permission> rechte = const [],
    int? alter,
  }) => kiste.schreibe(
    Profile(
      id: id,
      nameRaw: id,
      preferredColorValue: 0xFF3366CC,
      createdAt: angelegt,
      isAdmin: isAdmin,
      isActive: aktiv,
      age: alter,
      permissions: rechte.map((p) => p.persistedValue).toList(),
    ),
  );

  bool _darf(Permission permission) =>
      getActiveProfile()?.hasPermission(permission) ?? false;

  int _aktiveAdminsAusser(String id) =>
      kiste.values.where((p) => p.isAdmin && p.isActive && p.id != id).length;

  @override
  Box<Profile> get profilesBox => kiste;

  @override
  Profile? getActiveProfile() => kiste.daten[aktivId];

  @override
  Profile? getProfileById(String profileId) => kiste.daten[profileId];

  @override
  List<Profile> getAllProfiles() => kiste.values.toList();

  @override
  List<Profile> getProfiles() => kiste.values.where((p) => p.isActive).toList();

  @override
  List<Profile> getPausedProfiles() =>
      kiste.values.where((p) => !p.isActive).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  @override
  Future<bool> setPartRight(
    String profileId,
    PartRight right, {
    required bool on,
    String source = 'UI',
  }) async {
    final profile = kiste.daten[profileId];
    if (!_darf(Permission.managePermissions) || profile == null) return false;
    final rechte = right.applyTo(profile.parsedPermissions.toSet(), on: on);
    kiste.schreibe(
      profile.copyWith(
        permissions: rechte.map((p) => p.persistedValue).toList(),
      ),
    );
    return true;
  }

  @override
  Future<bool> makeAdmin(String profileId, {String source = 'UI'}) async {
    final profile = kiste.daten[profileId];
    if (getActiveProfile()?.isAdmin != true || profile == null) return false;
    kiste.schreibe(profile.copyWith(isAdmin: true));
    return true;
  }

  @override
  bool canRevokeAdmin(String profileId) {
    final profile = kiste.daten[profileId];
    if (getActiveProfile()?.isAdmin != true) return false;
    if (profile == null || !profile.isAdmin) return false;
    final erster = kiste.values.reduce(
      (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
    );
    if (erster.id == profileId) return false;
    return _aktiveAdminsAusser(profileId) > 0;
  }

  @override
  Future<bool> revokeAdmin(String profileId, {String source = 'UI'}) async {
    if (!canRevokeAdmin(profileId)) return false;
    kiste.schreibe(
      kiste.daten[profileId]!.copyWith(isAdmin: false, permissions: []),
    );
    return true;
  }

  @override
  bool canPauseProfile(String profileId) {
    if (!_darf(Permission.deactivateProfiles)) return false;
    if (profileId == aktivId) return false;
    final profile = kiste.daten[profileId];
    if (profile == null || !profile.isActive) return false;
    return !profile.isAdmin || _aktiveAdminsAusser(profileId) > 0;
  }

  @override
  bool canResumeProfiles() => _darf(Permission.deactivateProfiles);

  @override
  Future<bool> pauseProfile(String profileId, {String source = 'UI'}) async {
    if (!canPauseProfile(profileId)) return false;
    kiste.schreibe(kiste.daten[profileId]!.copyWith(isActive: false));
    return true;
  }

  @override
  Future<bool> resumeProfile(String profileId, {String source = 'UI'}) async {
    final profile = kiste.daten[profileId];
    if (!canResumeProfiles() || profile == null || profile.isActive) {
      return false;
    }
    kiste.schreibe(profile.copyWith(isActive: true));
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
