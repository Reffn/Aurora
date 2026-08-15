import 'package:dis_app/screens/feedback_thank_you_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/text_scale_harness.dart';

void main() {
  testWidgets('Der Dank steht genau einmal', (tester) async {
    await pumpScaled(tester, const FeedbackThankYouScreen(), scale: 1);

    expect(find.text('Dein Feedback wurde erfasst'), findsOneWidget);
  });

  testWidgets('Der Ausgang steht vor den Kontaktlinks', (tester) async {
    await pumpScaled(tester, const FeedbackThankYouScreen(), scale: 1);

    final ausgang = rectOf(tester, find.text('Zurück zu Aurora'));
    final links = rectOf(tester, find.textContaining('Discord'));
    expect(ausgang.top, lessThan(links.top));
    expectFullyVisible(tester, find.text('Zurück zu Aurora'));
  });

  testWidgets('Der Ausgang bleibt bei 200 % im ersten Bild', (tester) async {
    await pumpScaled(tester, const FeedbackThankYouScreen(), scale: 2,
        deviceSize: geraetS24.size, pixelRatio: geraetS24.ratio);

    expectFullyVisible(tester, find.text('Zurück zu Aurora'));
  });
}
