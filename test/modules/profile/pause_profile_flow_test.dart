import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/profile/profile_selection_screen.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:dis_app/widgets/profile_actions_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';
import 'profile_selection_test_setup.dart';

/// Was die Auswahl beim Antippen und beim langen Drücken anbietet.
///
/// Pausieren und Zurückholen liegen in Einstellungen → „Anteile & Rechte“
/// (`parts_and_rights_test.dart`). Die Auswahl steht nur ohne angemeldeten
/// Anteil oder bei gesperrter Sitzung da (Regel 30). Das lange Drücken bietet
/// deshalb kein Pausieren mehr, und die Zeile „Pausierte Anteile“ gibt es
/// nicht mehr.
///
/// Der Dialog beim Antippen öffnet sich auch aus dem Reset-Banner im Anker,
/// mit angemeldetem Anteil. Für ihn gilt sein Pausieren-Knopf weiter; die
/// Attrappe meldet dafür Lina als angemeldet.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('de'));
  });

  /// Feste Schritte statt `pumpAndSettle`: Die Auswahl trägt eine Karte, und
  /// der Glow im Profildialog läuft dauerhaft.
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

  Future<void> auswahlZeigen(
    WidgetTester tester, {
    ProfileSelectionScreen schirm = const ProfileSelectionScreen(),
  }) async {
    await pumpScaled(
      tester,
      schirm,
      deviceSize: geraetA14.size,
      pixelRatio: geraetA14.ratio,
      settle: false,
    );
    await warte(tester);
  }

  Finder avatar(String name) => find.byWidgetPredicate(
    (w) => w is ProfileAvatar && w.profile.name == name,
  );

  Finder bestaetigung(String name) => find.ancestor(
    of: find.text(l10n.profilePauseTitle(name)),
    matching: find.byType(AlertDialog),
  );

  Finder pausierenIn(Finder dialog) => find.descendant(
    of: dialog,
    matching: find.text(l10n.profilePauseAction),
  );

  /// Schließt das Blatt nach dem langen Drücken.
  Future<void> blattSchliessen(WidgetTester tester) async {
    Navigator.of(tester.element(find.text(l10n.actionEdit))).pop();
    await warte(tester);
    expect(find.byType(BottomSheet), findsNothing);
  }

  testWidgets('ohne Recht kein Pausieren-Knopf', (tester) async {
    await profilAufbau();
    await auswahlZeigen(tester);

    // Antippen
    await tester.tap(avatar('Mina'));
    await warte(tester);
    expect(find.byType(ProfileActionsDialog), findsOneWidget);
    expect(find.text(l10n.profilePauseAction), findsNothing);
    await tester.tap(find.text(l10n.actionClose));
    await warte(tester);

    // Langes Drücken: Das Blatt geht auf, weil Bearbeiten erlaubt ist.
    await tester.longPress(avatar('Mina'));
    await warte(tester);
    expect(find.text(l10n.actionEdit), findsOneWidget);
    expect(find.text(l10n.profilePauseAction), findsNothing);
  });

  testWidgets('mit Recht: Pausieren im Dialog, bestätigen, Anteil weg; das '
      'lange Drücken bietet nur Bearbeiten', (tester) async {
    await profilAufbau(darfPausieren: true);
    await auswahlZeigen(tester);

    await tester.longPress(avatar('Mina'));
    await warte(tester);
    expect(find.text(l10n.actionEdit), findsOneWidget);
    expect(find.text(l10n.profilePauseAction), findsNothing);
    await blattSchliessen(tester);

    await tester.tap(avatar('Mina'));
    await warte(tester);
    await tester.tap(pausierenIn(find.byType(ProfileActionsDialog)));
    await warte(tester);
    expect(bestaetigung('Mina'), findsOneWidget);
    await tester.tap(pausierenIn(bestaetigung('Mina')));
    await warte(tester);

    expect(avatar('Mina'), findsNothing);
    expect(avatar('Lina'), findsOneWidget);
    expect(find.text(l10n.profilePausedSnack('Mina')), findsOneWidget);

    await snackbarAuslaufen(tester);
  });

  // Regel 16: Pausieren hat dieselbe Anmeldeschranke wie Bearbeiten. Bei
  // einer gesperrten Sitzung (`onProfileSelected` gesetzt) ist niemand
  // angemeldet, dessen Rechte gälten — erst „Weiter als …", dann Pausieren.
  testWidgets('gesperrte Sitzung: Pausieren erst nach der Anmeldung', (
    tester,
  ) async {
    await profilAufbau(darfPausieren: true);
    await auswahlZeigen(
      tester,
      schirm: ProfileSelectionScreen(onProfileSelected: (_) async {}),
    );

    // Antippen: Der Dialog verlangt die Anmeldung und bietet kein Pausieren.
    await tester.tap(avatar('Mina'));
    await warte(tester);
    expect(find.byType(ProfileActionsDialog), findsOneWidget);
    expect(find.text(l10n.profileContinueAs('Mina')), findsOneWidget);
    expect(find.text(l10n.profilePauseAction), findsNothing);
    await tester.tap(find.text(l10n.actionClose));
    await warte(tester);

    // Langes Drücken: dasselbe. Das Blatt geht für Bearbeiten auf, weil
    // Mina kein Passwort hat.
    await tester.longPress(avatar('Mina'));
    await warte(tester);
    expect(find.text(l10n.actionEdit), findsOneWidget);
    expect(find.text(l10n.profilePauseAction), findsNothing);
  });

  // Bei gesperrter Sitzung steht `active_profile_id` noch. Bot das lange
  // Drücken dem zuletzt aktiven Anteil „Bearbeiten" an, setzte jeder, der
  // das Telefon hält, dort ein neues Passwort, ohne das alte zu kennen, und
  // meldete sich danach damit an.
  testWidgets('gesperrte Sitzung: kein Bearbeiten für den zuletzt aktiven '
      'Anteil mit Passwort', (tester) async {
    await profilAufbau(darfPausieren: true, mitPasswort: {'Lina'});
    await auswahlZeigen(
      tester,
      schirm: ProfileSelectionScreen(onProfileSelected: (_) async {}),
    );

    // Gegenprobe: Mina hat kein Passwort, ihr Blatt geht auf.
    await tester.longPress(avatar('Mina'));
    await warte(tester);
    expect(find.text(l10n.actionEdit), findsOneWidget);
    await blattSchliessen(tester);

    // Lina ist der zuletzt aktive Anteil und hat ein Passwort.
    await tester.longPress(avatar('Lina'));
    await warte(tester);
    expect(find.text(l10n.actionEdit), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
  });
}
