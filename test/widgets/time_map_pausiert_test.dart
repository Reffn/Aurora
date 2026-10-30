import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/widgets/time_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Pausierte Anteile auf der Karte.
///
/// `getProfiles()` kennt nur aktive Anteile. Die Karte suchte dort, ob ein
/// Anteil ein Passwort hat — ein pausierter mit Passwort wurde nicht
/// gefunden, galt als offen, und sein Weg stand vor der Anmeldung auf der
/// Profilauswahl.
class _FakeDataEntry implements DataEntry {
  _FakeDataEntry(this._alle);

  final List<Profile> _alle;

  @override
  List<Profile> getProfiles() => _alle.where((p) => p.isActive).toList();

  @override
  List<Profile> getAllProfiles() => _alle;

  @override
  List<FinderItem> getFinderItemsByType(FinderItemType type) => const [];

  @override
  List<Contact> getContacts() => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Kasten<T> implements Box<T> {
  _Kasten(this._werte);

  final List<T> _werte;

  @override
  Iterable<T> get values => _werte;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Aufzeichnung implements LocationTrackingService {
  _Aufzeichnung(this.locationHistoryBox);

  @override
  final Box<LocationHistoryEntry> locationHistoryBox;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Profile _profil(
  String id,
  String name, {
  bool isActive = true,
  String? passwordHash,
}) => Profile.withColor(
  id: id,
  name: name,
  preferredColor: const Color(0xFF00897B),
  createdAt: DateTime(2026, 10, 29),
  isActive: isActive,
  passwordHash: passwordHash,
);

void main() {
  setUp(() async {
    await getIt.reset();
    final vorhin = DateTime.now().subtract(const Duration(hours: 1));
    LocationHistoryEntry punkt(String profileId) => LocationHistoryEntry(
      id: 'punkt-$profileId',
      profileId: profileId,
      latitude: 52.52,
      longitude: 13.40,
      timestamp: vorhin,
    );

    getIt
      ..registerSingleton<DataEntry>(
        _FakeDataEntry([
          _profil('lou', 'Lou'),
          _profil('mira', 'Mira', isActive: false, passwordHash: 'hash'),
          _profil('ben', 'Ben', isActive: false),
        ]),
      )
      ..registerSingleton<LocationTrackingService>(
        _Aufzeichnung(
          _Kasten([punkt('lou'), punkt('mira'), punkt('ben')]),
        ),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  // Regeln 14 und 17: Ein pausierter Anteil ist aus der Auswahl
  // verschwunden. Vor der Anmeldung zeigt auch die Karte ihn nicht, mit
  // Passwort oder ohne: Sein Weg trüge Namen und Farbe.
  test('vor der Anmeldung bleibt jeder pausierte Anteil verborgen', () {
    final karte = TimeMap.fromServices(hidePasswordProtected: true);

    expect(karte.track.map((e) => e.profileId), ['lou']);
  });

  // Hinter der Anmeldung hat sich jemand ausgewiesen.
  test('ein pausierter Anteil behält auf der Karte Namen und Farbe', () {
    final karte = TimeMap.fromServices();

    expect(karte.profileNameOf('ben'), 'Ben');
    expect(karte.profileColorOf!('ben'), const Color(0xFF00897B));
  });
}
