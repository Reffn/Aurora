import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:hive_ce/hive.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:dis_app/services/emergency_message_service.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Dummy EmergencyMessageService für Tests.
class _DummyEmergencyMessageService implements EmergencyMessageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Ein Profil und [mitKontakten] Notfallkontakte.
///
/// Standortrecht steht vorgabegemäß auf „entzogen": Das ist die Lage, in der
/// der Befund entstand.
///
/// Diese Funktion öffnet KEINE Hive-Boxen. Sie erstellt Test-Kontakte im
/// Speicher über _MinimalDataEntry. Das ermöglicht Tests ohne Dateisystem-Zugriff.
Future<void> notfallAufbau({
  required int mitKontakten,
  bool mitStandortrecht = false,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  await getIt.reset();

  addTearDown(() async {
    await getIt.reset();
  });

  // Create test contacts in memory
  final testContacts = <Contact>[];
  for (var i = 0; i < mitKontakten; i++) {
    testContacts.add(
      Contact(
        id: const Uuid().v4(),
        name: 'Notfallkontakt $i',
        category: ContactCategory.emergency,
        createdByProfileId: 'test-profile',
        createdAt: DateTime.now(),
        defaultRating: 0,
        isEmergencyContact: true,
      ),
    );
  }

  // Minimal dependency registration with in-memory data
  getIt.registerSingleton<DataEntry>(_MinimalDataEntry(testContacts));
  getIt.registerSingleton<EventBus>(EventBus());

  final fakeGpsManager = _MinimalGpsManager();
  fakeGpsManager.hasGpsPermission.value = mitStandortrecht;
  getIt.registerSingleton<GpsManager>(fakeGpsManager);

  getIt.registerSingleton<MapService>(_MinimalMapService());
  getIt.registerSingleton<LocationTrackingService>(
      _MinimalLocationTrackingService());
  getIt.registerSingleton<EmergencyMessageService>(
      _DummyEmergencyMessageService());
}

// Minimal implementations

class _MinimalDataEntry implements DataEntry {
  _MinimalDataEntry([List<Contact>? initialContacts])
      : _contactsBox = _InMemoryBox<Contact>(),
        _finderItemsBox = _InMemoryBox<FinderItem>() {
    // Populate with initial contacts if provided
    if (initialContacts != null) {
      for (final contact in initialContacts) {
        _contactsBox._data[contact.id] = contact;
      }
    }
  }

  final _InMemoryBox<Contact> _contactsBox;
  final _InMemoryBox<FinderItem> _finderItemsBox;

  @override
  Box<Contact> get contactsBox => _contactsBox;

  @override
  Box<FinderItem> get finderItemsBox => _finderItemsBox;

  @override
  Box<dynamic> get settingsBox => _InMemoryBox();

  @override
  Box<Profile> get profilesBox => _InMemoryBox();

  @override
  List<Contact> getContacts() => contactsBox.values.toList();

  @override
  List<FinderItem> getFinderItemsByType(FinderItemType type) => [];

  @override
  List<Profile> getProfiles() => [];

  @override
  Profile? getActiveProfile() => null;

  @override
  Future<void> createContact(Contact contact, {String source = 'UI'}) async {
    _contactsBox._data[contact.id] = contact;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MinimalGpsManager implements GpsManager {
  final ValueNotifier<bool> hasGpsPermission = ValueNotifier(false);

  @override
  String formatPosition(dynamic position) => '';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MinimalMapService implements MapService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MinimalLocationTrackingService implements LocationTrackingService {
  @override
  ValueListenable<bool> get hasLocationPermission => ValueNotifier(false);

  @override
  Box<LocationHistoryEntry> get locationHistoryBox =>
      _InMemoryBox<LocationHistoryEntry>();

  @override
  Box<ProfileSwitchEvent> get switchEventsBox =>
      _InMemoryBox<ProfileSwitchEvent>();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _InMemoryBox<T> implements Box<T> {
  final Map<dynamic, T> _data = {};

  @override
  Iterable<T> get values => _data.values;

  ValueListenable<Box<T>> listenable() =>
      _DummyValueListenable<Box<T>>(this as Box<T>);

  @override
  Stream<BoxEvent> watch({dynamic key}) => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _DummyValueListenable<T> implements ValueListenable<T> {
  _DummyValueListenable(this.value);

  @override
  final T value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
