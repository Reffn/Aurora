import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/chat/widgets/doodle_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wer nicht malt, sieht keine Malwerkzeuge.
///
/// Am Gerät standen sechs Werkzeugknöpfe und dreizehn Punkte der
/// Materialleiste dauerhaft über dem Nachrichtenverlauf — auch für jemanden,
/// der gerade blätterte. Dazu lagen zwei gleiche Sende-Pfeile gleichzeitig auf
/// dem Schirm, einer für die Zeichnung und einer für den Text.
Widget _flaeche({required bool drawingEnabled, bool showModeToggle = true}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: DoodleCanvas(
        onSend: (_) {},
        profileColor: Colors.blue,
        drawingEnabled: drawingEnabled,
        showModeToggle: showModeToggle,
        onToggleDrawing: () {},
      ),
    ),
  );
}

void main() {
  testWidgets('im Blättermodus bleibt nur der Pinsel', (tester) async {
    await tester.pumpWidget(_flaeche(drawingEnabled: false));
    await tester.pump();

    expect(find.byIcon(Icons.brush), findsOneWidget);
    expect(
      find.byIcon(Icons.send),
      findsNothing,
      reason: 'Ein zweiter Sende-Pfeil neben dem der Textzeile',
    );
    expect(find.byIcon(Icons.undo), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.emoji_emotions), findsNothing);
  });

  testWidgets('beim Malen stehen die Werkzeuge wieder da', (tester) async {
    await tester.pumpWidget(_flaeche(drawingEnabled: true));
    await tester.pump();

    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.byIcon(Icons.undo), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    // Der Umschalter zeigt jetzt den Weg zurück, nicht den Pinsel.
    expect(find.byIcon(Icons.pan_tool_alt), findsOneWidget);
    expect(find.byIcon(Icons.brush), findsNothing);
  });

  testWidgets('ohne Umschalter bleiben die Werkzeuge stehen', (tester) async {
    // Das gemalte Profilbild: Die Fläche steht für sich, es gibt keinen
    // Verlauf darunter und damit keinen Weg zurück in die Werkzeuge.
    await tester.pumpWidget(
      _flaeche(drawingEnabled: false, showModeToggle: false),
    );
    await tester.pump();

    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.byIcon(Icons.undo), findsOneWidget);
  });
}
