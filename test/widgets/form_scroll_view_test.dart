import 'package:dis_app/widgets/form_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Baut ein Formular, dessen Pflichtfeld ganz oben steht und dessen
/// Speichern-Knopf so weit unten, dass beide nie gleichzeitig sichtbar sind.
Widget _buildForm({
  required GlobalKey<FormState> formKey,
  required Widget Function(List<Widget> children) scrollBuilder,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Form(
        key: formKey,
        child: scrollBuilder([
          TextFormField(
            decoration: const InputDecoration(labelText: 'Dosierung'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Pflichtfeld' : null,
          ),
          // Füllt mehrere Bildschirmhöhen, damit das Feld oben aushängt.
          ...List.generate(30, (i) => SizedBox(height: 100, child: Text('Block $i'))),
        ]),
      ),
    ),
  );
}

void main() {
  group('FormScrollView hält alle Felder beim Form registriert', () {
    testWidgets(
      'validate() schlägt fehl, wenn das Pflichtfeld ausgescrollt ist',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(
          _buildForm(
            formKey: formKey,
            scrollBuilder: (children) => FormScrollView(children: children),
          ),
        );

        // Ans Ende scrollen — dort steht in der echten App der Speichern-Knopf.
        await tester.drag(find.byType(FormScrollView), const Offset(0, -2500));
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(TextFormField, 'Dosierung').hitTestable(),
          findsNothing,
          reason: 'Testaufbau ungültig: Das Feld muss ausgescrollt sein.',
        );
        expect(
          formKey.currentState!.validate(),
          isFalse,
          reason: 'Das leere Pflichtfeld muss auch ausgescrollt anschlagen.',
        );
      },
    );

    testWidgets(
      'ListView lässt dieselbe Prüfung durchrutschen — der Grund für dieses Widget',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(
          _buildForm(
            formKey: formKey,
            scrollBuilder: (children) => ListView(children: children),
          ),
        );

        await tester.drag(find.byType(ListView), const Offset(0, -2500));
        await tester.pumpAndSettle();

        expect(
          formKey.currentState!.validate(),
          isTrue,
          reason: 'Belegt das Fehlverhalten: ListView hängt das Feld aus, '
              'der validator läuft nicht mehr mit, und validate() meldet '
              'fälschlich Erfolg. Schlägt dieser Test fehl, hat Flutter das '
              'Verhalten geändert und FormScrollView ist entbehrlich.',
        );
      },
    );

    testWidgets('streckt Kinder auf volle Breite wie ListView', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormScrollView(
              children: [
                SizedBox(height: 50, child: Placeholder()),
              ],
            ),
          ),
        ),
      );

      final width = tester.getSize(find.byType(Placeholder)).width;
      expect(width, equals(800), reason: 'Testbildschirm ist 800 breit.');
    });
  });
}
