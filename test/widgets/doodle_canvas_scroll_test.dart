import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/chat/widgets/doodle_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Die Zeichenfläche liegt im Chat über dem Nachrichtenverlauf. Beide
/// scrollen. Nimmt die Werkzeugleiste den PrimaryScrollController, hängen
/// zwei ScrollPositions daran und ihre Scrollbar kann nicht mehr zeichnen —
/// auf dem Gerät kam dann bei jedem Öffnen des Chats ein Framework-Fehler.
void main() {
  testWidgets('Werkzeugleiste scrollt neben einer zweiten Fläche',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              // Der Nachrichtenverlauf darunter — ohne eigenen Controller,
              // genau wie eine beliebige Liste im selben Baum.
              ListView(
                children: List.generate(
                  40,
                  (i) => SizedBox(height: 40, child: Text('$i')),
                ),
              ),
              DoodleCanvas(
                onSend: (_) {},
                profileColor: Colors.blue,
                drawingEnabled: true,
                onToggleDrawing: () {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();

    expect(
      tester.takeException(),
      isNull,
      reason: 'Die Werkzeugleiste braucht ihren eigenen ScrollController',
    );
  });
}
