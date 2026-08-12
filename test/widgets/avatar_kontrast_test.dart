import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/widgets/profile_card.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ein Avatar ohne Bild muss lesbar bleiben — auf jeder Profilfarbe.
///
/// `ProfileImageWidget` löst das an einer Stelle: die Initialen bekommen eine
/// schwarze Kontur, damit sie auf hellen wie dunklen Hintergründen stehen.
/// Elf von achtzehn Aufrufstellen nahmen diesen Weg. Sieben reichten
/// stattdessen ein eigenes `fallbackWidget` herein und bauten die Initialen
/// selbst — drei davon mit hartkodiertem `Colors.white` auf der Profilfarbe.
///
/// Bei einem Profil mit heller Farbe stand damit Weiß auf Weiß. Gefunden am
/// Gerät im Bearbeiten-Bildschirm; die Profilkarte auf dem Startbildschirm
/// hatte denselben Fehler und zeigte ihn nur nicht, weil dort ein Bild lud.
///
/// Deshalb fällt `fallbackWidget` ersatzlos weg. Nicht als Regel, die man
/// übersehen kann — als Parameter, den es nicht mehr gibt. Der Compiler
/// erzwingt, was eine Lint nur anmerken könnte.
Widget _rahmen(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

/// Trägt irgendein Text eine schwarze Kontur?
///
/// Das ist die Zusage, die den Rückfall auf jedem Untergrund lesbar hält —
/// nicht die Textfarbe, denn die wird vom Regenbogen ersetzt.
bool _hatKontur(WidgetTester tester) =>
    tester.widgetList<Text>(find.byType(Text)).any((t) {
      final farbe = t.style?.foreground;
      return farbe != null &&
          farbe.style == PaintingStyle.stroke &&
          farbe.color == Colors.black;
    });

Profile _anteil({required Color farbe, String name = 'Testa'}) =>
    Profile.withColor(
      id: 'p1',
      name: name,
      preferredColor: farbe,
      createdAt: DateTime(2026, 8, 10),
    );

void main() {
  group('Profilkarte', () {
    testWidgets('helle Profilfarbe: die Initialen bleiben sichtbar',
        (tester) async {
      // Der zweite lebende Fall derselben Verwechslung. Die Karte malte
      // `Colors.white` auf `profile.preferredColor` — bei einem weissen
      // Profil eine leere Flaeche. Sichtbar wurde es nie, weil das Profil,
      // an dem es auffiel, ein Bild hatte.
      await tester.pumpWidget(
        _rahmen(ProfileCard(profile: _anteil(farbe: Colors.white))),
      );
      await tester.pump();

      expect(_hatKontur(tester), isTrue);
    });

    testWidgets('dunkle Profilfarbe genauso', (tester) async {
      await tester.pumpWidget(
        _rahmen(ProfileCard(profile: _anteil(farbe: const Color(0xFF1B1533)))),
      );
      await tester.pump();

      expect(_hatKontur(tester), isTrue);
    });

    testWidgets('zwei Zeichen, wie vorher', (tester) async {
      // Die Migration darf die Optik nicht nebenbei aendern: die Karte zeigte
      // schon immer zwei Zeichen.
      await tester.pumpWidget(
        _rahmen(ProfileCard(profile: _anteil(farbe: Colors.white))),
      );
      await tester.pump();

      expect(find.text('TE'), findsWidgets);
    });
  });

  group('ProfileImageWidget', () {
    testWidgets('ohne Namen und ohne Bild traegt das Sinnbild die Flaeche',
        (tester) async {
      // Der ehrliche Ersatz fuer `fallbackWidget: Icon(...)`: ein Sinnbild
      // fuer Dinge, die keine Initialen haben — ein Fundstueck etwa. Als
      // `IconData`, nicht als Widget: ein Widget waere dieselbe Hintertuer
      // unter neuem Namen.
      await tester.pumpWidget(
        _rahmen(
          const ProfileImageWidget(
            avatarPath: null,
            size: 100,
            placeholderIcon: Icons.image,
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('der Name schlaegt das Sinnbild', (tester) async {
      // Wer beides angibt, meint die Initialen. Sonst waere die Reihenfolge
      // eine Falle.
      await tester.pumpWidget(
        _rahmen(
          const ProfileImageWidget(
            avatarPath: null,
            size: 100,
            profileName: 'Lina',
            profileColor: Colors.white,
            placeholderIcon: Icons.image,
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.image), findsNothing);
      expect(_hatKontur(tester), isTrue);
    });

    testWidgets('ohne alles bleibt das Fragezeichen', (tester) async {
      await tester.pumpWidget(
        _rahmen(
          const ProfileImageWidget(avatarPath: null, size: 100),
        ),
      );
      await tester.pump();

      expect(find.text('?'), findsOneWidget);
    });
  });
}
