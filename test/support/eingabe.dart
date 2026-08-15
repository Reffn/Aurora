import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tippen wie ein Mensch: erst greifen, dann schreiben.
///
/// **Warum es das gibt.** `tester.enterText` setzt den Text unmittelbar am
/// Widget — ohne Griff, ohne Fokus, ohne Tastatur. Ein Feld, das man mit dem
/// Finger nie erreicht, besteht damit jeden Test. Genau das ist am
/// 12. August 2026 passiert: Im Passwort-Reset ließ sich am Gerät nichts
/// eintippen, während fünf grüne Tests den Dialog abdeckten. Sie prüften die
/// Logik hinter dem Feld und nie seine Erreichbarkeit.
///
/// `tippeIn` macht die Erreichbarkeit zur Voraussetzung: Wer schreiben will,
/// muss vorher treffen und den Fokus bekommen. Schlägt das fehl, fällt der
/// Test dort um, wo der Mensch scheitern würde.
Future<void> tippeIn(
  WidgetTester tester,
  Finder feld,
  String text, {
  Duration? nachpumpen,
}) async {
  await tester.ensureVisible(feld);
  await tester.pump();

  await tester.tap(feld);
  await tester.pump();

  expect(
    hatFokus(tester, feld),
    isTrue,
    reason: 'Das Feld nimmt keinen Fokus an. Dann bleibt die Tastatur weg — '
        'egal was danach im Controller steht.',
  );

  await tester.enterText(feld, text);
  await tester.pump(nachpumpen ?? Duration.zero);
}

/// Ob der Schreibkern unter [feld] gerade den Fokus hält.
bool hatFokus(WidgetTester tester, Finder feld) {
  final schreibkern = find.descendant(
    of: feld,
    matching: find.byType(EditableText),
  );
  if (schreibkern.evaluate().isEmpty) return false;

  return tester.widget<EditableText>(schreibkern.first).focusNode.hasFocus;
}

/// Prüft, dass das System das Feld überhaupt als Eingabe kennt.
///
/// Am Gerät fehlte genau dieser Knoten: Der Bedienbaum trug die Beschriftung,
/// die Knöpfe und den Schließen-Bereich — aber kein `EditText`. Was das System
/// nicht kennt, kann keine Bedienhilfe ansteuern.
void erwarteBedienbaresFeld(
  WidgetTester tester,
  Finder feld, {
  bool verdeckt = false,
}) {
  final handle = tester.ensureSemantics();
  try {
    final knoten = tester.getSemantics(
      find.descendant(of: feld, matching: find.byType(EditableText)).first,
    );

    expect(
      knoten.hasFlag(SemanticsFlag.isTextField),
      isTrue,
      reason: 'Kein Eingabefeld im Bedienbaum.',
    );
    expect(
      knoten.hasFlag(SemanticsFlag.isEnabled),
      isTrue,
      reason: 'Das Feld kündigt sich als nicht bedienbar an.',
    );
    if (verdeckt) {
      expect(
        knoten.hasFlag(SemanticsFlag.isObscured),
        isTrue,
        reason: 'Ein Passwortfeld muss sich als verdeckt ankündigen, sonst '
            'liest ein Screenreader es laut vor.',
      );
    }
  } finally {
    handle.dispose();
  }
}
