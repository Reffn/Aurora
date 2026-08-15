import 'dart:io';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/profile/widgets/profile_identity_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Am Gerät gefunden: „Profil bearbeiten" zeigte ein leeres weißes Feld statt
/// des Profilbilds.
///
/// Kein Ladefehler. Das Feld trägt die **Profilfarbe**, und der Rückfall
/// darüber schrieb die Initialen in `Colors.white` — ohne Kontur. Bei einem
/// Profil mit heller Farbe stand damit Weiß auf Weiß.
///
/// Überall sonst in der App fällt derselbe Avatar auf die Regenbogen-Initialen
/// von `ProfileImageWidget` zurück, und die tragen eine schwarze Kontur, damit
/// sie auf jedem Untergrund lesbar bleiben. Der Bearbeiten-Bildschirm war die
/// einzige Fläche, die diesen Rückfall überschrieb — und dabei genau das
/// wegließ, was ihn trägt.
Widget _rahmen(Widget child) => MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  Widget abschnitt({required Color farbe, String name = 'Testa'}) =>
      _rahmen(
        ProfileIdentitySection(
          nameController: TextEditingController(text: name),
          selectedColor: farbe,
          selectedAvatarPath: null,
          onAvatarPathSelected: (_) {},
          passwordController: TextEditingController(),
          passwordConfirmController: TextEditingController(),
          isEditMode: true,
          showPasswordFields: false,
        ),
      );

  /// Trägt irgendein Text eine schwarze Kontur?
  ///
  /// Das ist die Zusage, die den Rückfall auf jedem Untergrund lesbar hält —
  /// nicht die Textfarbe, denn die wird ohnehin vom Regenbogen ersetzt.
  bool hatKontur(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .any((t) {
        final farbe = t.style?.foreground;
        return farbe != null &&
            farbe.style == PaintingStyle.stroke &&
            farbe.color == Colors.black;
      });

  testWidgets('bei heller Profilfarbe bleiben die Initialen sichtbar',
      (tester) async {
    await tester.pumpWidget(abschnitt(farbe: Colors.white));
    await tester.pump();

    expect(
      hatKontur(tester),
      isTrue,
      reason: 'Ohne Kontur steht der Rückfall in Weiß auf einer weissen '
          'Profilfarbe. Das Feld sieht dann leer aus, und niemand erfaehrt, '
          'dass dort ein Bild hingehoert.',
    );
  });

  testWidgets('bei dunkler Profilfarbe genauso', (tester) async {
    // Dieselbe Zusage, damit die Korrektur nicht nur den einen Fall trifft,
    // der am Geraet aufgefallen ist.
    await tester.pumpWidget(abschnitt(farbe: const Color(0xFF1B1533)));
    await tester.pump();

    expect(hatKontur(tester), isTrue);
  });

  testWidgets('die Initialen sind die ersten beiden Zeichen des Namens',
      (tester) async {
    await tester.pumpWidget(abschnitt(farbe: Colors.white));
    await tester.pump();

    expect(find.text('TE'), findsWidgets);
  });

  testWidgets('Emoji im Namen bricht die Initialen nicht', (tester) async {
    // UTF-16: `name[0]` zerlegt ein Emoji in seine Haelften und stuerzt oder
    // zeigt Kaese. Der Rueckfall muss ueber runes gehen.
    await tester.pumpWidget(abschnitt(farbe: Colors.white, name: '🦎la'));
    await tester.pump();

    expect(find.text('🦎L'), findsWidgets);
  });

  test('der Bearbeiten-Bildschirm belegt den Avatar vor', () {
    // Die eigentliche Ursache des leeren Felds — und die schwerere.
    //
    // `initState` belegte Farbe, Farbposition, Alter und Reset-Frist aus dem
    // Profil vor, den Avatar nicht. „Profil bearbeiten" zeigte deshalb nie
    // das Bild, das das Profil schon hat, sondern immer den Rueckfall. Beim
    // Speichern fiel es nicht auf, weil `_selectedAvatarPath ??
    // widget.profile.avatarPath` den alten Pfad zurueckholte: sichtbar, aber
    // folgenlos — und damit die Sorte Fehler, die lange bleibt.
    //
    // Strukturell geprueft, nicht ueber die Oberflaeche: `ProfileEditScreen`
    // zieht `DataEntry` im Feld-Initialisierer aus dem getIt-Container, und
    // dessen Attrappe verlangt zehn Dienste mit Hive-Boxen. Dieselbe Form und
    // derselbe Grund wie in `location_tracking_foreground_test.dart`.
    final quelle = File('lib/modules/profile/profile_edit_screen.dart')
        .readAsStringSync()
        .split('\n')
        .where((zeile) => !zeile.trimLeft().startsWith('//'))
        .join('\n');

    expect(
      quelle.contains('_selectedAvatarPath = widget.profile.avatarPath'),
      isTrue,
      reason: 'Ohne diese Vorbelegung steht die Bearbeiten-Flaeche auf dem '
          'Rueckfall, obwohl das Profil ein Bild hat.',
    );
  });
}
