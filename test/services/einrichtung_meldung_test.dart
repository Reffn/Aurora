import 'dart:typed_data';

import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/profile_events.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/einrichtung_meldung.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/temp_hive.dart';

Profile _profil(String id) => Profile(
  id: id,
  nameRaw: id,
  preferredColorValue: 0xFF3366CC,
  createdAt: DateTime(2026, 10, 30),
);

/// „Einrichtung abgeschlossen“ kommt genau einmal je Installation — beim
/// ersten Profil, nie beim zweiten.
void main() {
  late EventBus bus;
  late Box<dynamic> settings;
  late int meldungen;

  setUp(() async {
    await openTempBox<dynamic>('hive_init_einrichtung');
    settings = await Hive.openBox<dynamic>(
      'settings_einrichtung',
      bytes: Uint8List(0),
    );
    bus = EventBus();
    meldungen = 0;
    meldeEinrichtungEinmal(
      eventBus: bus,
      settingsBox: settings,
      melde: () async => meldungen++,
    );
  });

  tearDown(() async {
    bus.dispose();
    await settings.close();
  });

  Future<void> durchlaufen() => Future<void>.delayed(Duration.zero);

  test('das erste Profil meldet die Einrichtung', () async {
    bus.publish(ProfileCreatedEvent(_profil('lou')));
    await durchlaufen();

    expect(meldungen, 1);
    expect(settings.get(einrichtungGemeldetKey), isTrue);
  });

  test('weitere Profile melden nichts mehr', () async {
    bus
      ..publish(ProfileCreatedEvent(_profil('lou')))
      ..publish(ProfileCreatedEvent(_profil('mira')))
      ..publish(ProfileCreatedEvent(_profil('zora')));
    await durchlaufen();

    expect(meldungen, 1);
  });

  test('schon gemeldet: auch das nächste erste Profil meldet nicht', () async {
    await settings.put(einrichtungGemeldetKey, true);

    bus.publish(ProfileCreatedEvent(_profil('lou')));
    await durchlaufen();

    expect(meldungen, 0);
  });
}
