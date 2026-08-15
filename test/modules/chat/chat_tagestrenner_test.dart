import 'package:dis_app/models/chat_message.dart';
import 'package:dis_app/modules/chat/chat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Verlauf trug bisher nur Uhrzeiten. Am 11. August 2026 standen am Gerät
/// zwei Blasen untereinander — „22:07" über „13:50" — und die obere war von
/// gestern. Zu sehen war das nirgends.
void main() {
  ChatMessage nachricht(String id, DateTime wann) => ChatMessage(
        id: id,
        profileId: 'p1',
        content: id,
        timestamp: wann,
        senderColorValue: 0xFF000000,
      );

  group('Tagestrenner im Verlauf', () {
    test('ohne Nachrichten bleibt der Verlauf leer', () {
      expect(mitTagestrennern(const []), isEmpty);
    });

    test('vor der ersten Nachricht steht ihr Tag', () {
      final eintraege = mitTagestrennern([
        nachricht('a', DateTime(2026, 8, 11, 13, 50)),
      ]);

      expect(eintraege.length, 2);
      expect(eintraege.first.tag, DateTime(2026, 8, 11));
      expect(eintraege.last.message?.id, 'a');
    });

    test('zwei Nachrichten desselben Tages teilen sich eine Überschrift', () {
      final eintraege = mitTagestrennern([
        nachricht('a', DateTime(2026, 8, 11, 8)),
        nachricht('b', DateTime(2026, 8, 11, 23, 59)),
      ]);

      expect(eintraege.where((e) => e.tag != null).length, 1);
      expect(eintraege.length, 3);
    });

    test('der Tageswechsel bekommt eine eigene Überschrift', () {
      final eintraege = mitTagestrennern([
        nachricht('gestern', DateTime(2026, 8, 10, 22, 7)),
        nachricht('heute', DateTime(2026, 8, 11, 13, 50)),
      ]);

      final tage = eintraege.where((e) => e.tag != null).map((e) => e.tag);
      expect(tage, [DateTime(2026, 8, 10), DateTime(2026, 8, 11)]);
      expect(
        eintraege.map((e) => e.tag != null ? 'TAG' : e.message!.id),
        ['TAG', 'gestern', 'TAG', 'heute'],
        reason: 'Genau dieser Fall war am Gerät nicht zu unterscheiden: '
            '22:07 stand über 13:50 und war trotzdem älter.',
      );
    });

    test('die Uhrzeit entscheidet nicht über den Tag', () {
      // Eine Minute Abstand, zwei verschiedene Tage.
      final eintraege = mitTagestrennern([
        nachricht('kurz vor zwoelf', DateTime(2026, 8, 10, 23, 59)),
        nachricht('kurz nach zwoelf', DateTime(2026, 8, 11, 0, 1)),
      ]);

      expect(eintraege.where((e) => e.tag != null).length, 2);
    });

    test('ein Eintrag ist entweder Tag oder Nachricht, nie beides', () {
      final eintraege = mitTagestrennern([
        nachricht('a', DateTime(2026, 8, 11, 8)),
      ]);

      for (final eintrag in eintraege) {
        expect(
          (eintrag.tag == null) != (eintrag.message == null),
          isTrue,
          reason: 'Sonst müsste die Fläche raten, was sie zeichnen soll.',
        );
      }
    });
  });
}
