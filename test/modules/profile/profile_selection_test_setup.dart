import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/chat_message.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:dis_app/services/calendar_service.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/box/box_base.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Dummy MapService für Tests. OverviewMap braucht das.
class _DummyMapService implements MapService {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

/// Dummy CalendarService für Tests. TodayOverviewLine braucht getEventsForDay().
class _DummyCalendarService implements CalendarService {
  final List<CalendarEvent> _events = [];

  void addEvent(CalendarEvent event) {
    _events.add(event);
  }

  @override
  List<CalendarEvent> getEventsForDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _events.where((event) {
      return event.startTime.isBefore(dayEnd) &&
          event.endTime.isAfter(dayStart);
    }).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

/// Dummy DataEntry für Tests. ProfileSelectionScreen braucht getProfiles(), profilesBox.listenable(), etc.
///
/// Pausieren schreibt wie der echte Dienst in die Box. Die Auswahl hört über
/// `profilesBox.listenable()` mit, und das hängt an `watch()` — ohne Ereignis
/// dort bliebe ein pausierter Anteil im Raster stehen, egal was die
/// Oberfläche tut.
class _DummyDataEntry implements DataEntry {
  _DummyDataEntry({required this.darfPausieren});

  /// Steht für `deactivateProfiles` am aktiven Anteil.
  final bool darfPausieren;

  final List<Profile> _profiles = [];
  final List<Contact> _contacts = [];
  late final _profilesBox = _InMemoryBox<Profile>();
  late final _contactsBox = _InMemoryBox<Contact>();
  late final _settingsBox = _InMemoryBox<dynamic>();
  late final _chatMessagesBox = _InMemoryBox<dynamic>();

  void addProfile(Profile profile) {
    _profiles.add(profile);
    _profilesBox._data[profile.id] = profile;
  }

  void addContact(Contact contact) {
    _contacts.add(contact);
    _contactsBox._data[contact.id] = contact;
  }

  @override
  List<Profile> getProfiles() {
    return _profiles.where((p) => p.isActive).toList();
  }

  @override
  List<Profile> getAllProfiles() => List.of(_profiles);

  @override
  Profile? getProfileById(String profileId) {
    for (final p in _profiles) {
      if (p.id == profileId) return p;
    }
    return null;
  }

  @override
  Profile? getActiveProfile() {
    return _profiles.isNotEmpty ? _profiles.first : null;
  }

  /// Dieselben Regeln wie `ProfileService.canPause`, soweit sie hier zählen:
  /// Recht, nicht der aktive Anteil, Ziel noch aktiv.
  @override
  bool canPauseProfile(String profileId) {
    if (!darfPausieren) return false;
    if (profileId == getActiveProfile()?.id) return false;
    return getProfileById(profileId)?.isActive ?? false;
  }

  @override
  Future<bool> pauseProfile(String profileId, {String source = 'UI'}) async {
    if (!canPauseProfile(profileId)) return false;
    _setzeAktiv(profileId, aktiv: false);
    return true;
  }

  void _setzeAktiv(String profileId, {required bool aktiv}) {
    final i = _profiles.indexWhere((p) => p.id == profileId);
    final neu = _profiles[i].copyWith(isActive: aktiv);
    _profiles[i] = neu;
    _profilesBox.schreibe(profileId, neu);
  }

  @override
  Box<Profile> get profilesBox => _profilesBox;

  @override
  Box<Contact> get contactsBox => _contactsBox;

  @override
  Box<dynamic> get settingsBox => _settingsBox;

  @override
  Box<ChatMessage> get chatMessagesBox => _chatMessagesBox as Box<ChatMessage>;

  @override
  List<Contact> getContacts() {
    return _contacts;
  }

  @override
  Future<void> createContact(Contact contact, {String source = 'UI'}) async {
    addContact(contact);
  }

  @override
  List<CalendarEvent> getCalendarEventsForDay(DateTime day) {
    // Für Tests: Leere Liste oder könnte später erweitert werden
    return [];
  }

  @override
  List<Medication> getTodaysMedications() {
    // Für Tests: Leere Liste
    return [];
  }

  @override
  List<FinderItem> getFinderItemsByType(FinderItemType type) {
    // Für Tests: Leere Liste
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

/// In-Memory Box für Tests - verhält sich wie eine Hive Box aber gespeichert im RAM
class _InMemoryBox<T> implements Box<T> {
  final Map<dynamic, T> _data = {};
  final _ereignisse = StreamController<BoxEvent>.broadcast();

  /// Schreibt wie `put` und meldet es, wie Hive es tut.
  void schreibe(dynamic key, T value) {
    _data[key] = value;
    _ereignisse.add(BoxEvent(key, value, false));
  }

  @override
  Iterable<T> get values => _data.values;

  /// Gibt einen ValueListenable zurück für ValueListenableBuilder
  ValueListenable<Box<T>> listenable() {
    return _DummyValueListenable<Box<T>>(this as Box<T>);
  }

  /// Daran hängt `listenable()` aus hive_ce_flutter — die Methode oben ruft
  /// die Oberfläche nie auf, weil die Erweiterung statisch gewählt wird.
  @override
  Stream<BoxEvent> watch({dynamic key}) {
    if (key == null) return _ereignisse.stream;
    return _ereignisse.stream.where((e) => e.key == key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

/// Dummy ValueListenable für Tests - gibt einfach den Wert zurück
class _DummyValueListenable<T> implements ValueListenable<T> {
  _DummyValueListenable(this.value);

  @override
  final T value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

/// Dummy LocationTrackingService für Tests. OverviewMap braucht das.
class _DummyLocationTrackingService implements LocationTrackingService {
  final ValueNotifier<bool> _hasLocationPermission = ValueNotifier(false);

  /// Dummy Box für Locationhistorie - TimeMap liest daraus
  @override
  late Box<LocationHistoryEntry> locationHistoryBox =
      _InMemoryBox<LocationHistoryEntry>();

  /// Dummy Box für ProfileSwitchEvents
  @override
  late Box<ProfileSwitchEvent> switchEventsBox =
      _InMemoryBox<ProfileSwitchEvent>();

  @override
  ValueListenable<bool> get hasLocationPermission => _hasLocationPermission;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

/// Fake GpsManager für Tests. Implementiert nur hasGpsPermission.
class _FakeGpsManager implements GpsManager {
  final ValueNotifier<bool> hasGpsPermission = ValueNotifier(false);

  @override
  String formatPosition(LatLng position) {
    return '${position.latitude}, ${position.longitude}';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

/// Zwei Anteile, „Lina" und „Mina" — dieselbe Lage, in der der Bruch am
/// S24 am 10. August 2026 auftrat.
///
/// [darfPausieren] gibt dem aktiven Anteil (Lina) das Recht, andere zu
/// pausieren. [mitPasswort] nennt Anteile, die ein Passwort haben.
Future<void> profilAufbau({
  bool mitTageshinweis = false,
  bool mitStandortrecht = true,
  bool darfPausieren = false,
  Set<String> mitPasswort = const {},
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences für Flutter Map Tile Caching
  SharedPreferences.setMockInitialValues({});

  // GetIt zurücksetzen
  await getIt.reset();

  // Erstelle ein Dummy DataEntry, das unsere Test-Profile speichert
  final dummyDataEntry = _DummyDataEntry(darfPausieren: darfPausieren);

  // Erstelle zwei Test-Profile
  final now = DateTime.now();
  final lina = Profile.withColor(
    id: const Uuid().v4(),
    name: 'Lina',
    preferredColor: Colors.pink,
    createdAt: now,
  );
  final mina = Profile.withColor(
    id: const Uuid().v4(),
    name: 'Mina',
    preferredColor: Colors.blue,
    createdAt: now,
  );

  for (final profil in [lina, mina]) {
    dummyDataEntry.addProfile(
      profil.copyWith(
        passwordHash: mitPasswort.contains(profil.name)
            ? 'hash-von-${profil.name}'
            : null,
      ),
    );
  }

  // Registriere das Dummy DataEntry
  getIt.registerSingleton<DataEntry>(dummyDataEntry);

  // Registriere EventBus
  final eventBus = EventBus();
  getIt.registerSingleton<EventBus>(eventBus);

  // Registriere einen Fake GpsManager mit steuerbarer Permission
  final fakeGpsManager = _FakeGpsManager();
  fakeGpsManager.hasGpsPermission.value = mitStandortrecht;
  getIt.registerSingleton<GpsManager>(fakeGpsManager);

  // Registriere weitere Services, die OverviewMap braucht
  getIt.registerSingleton<MapService>(_DummyMapService());
  getIt.registerSingleton<LocationTrackingService>(
    _DummyLocationTrackingService(),
  );

  // Registriere CalendarService mit optional einem Event für heute
  final calendarService = _DummyCalendarService();
  if (mitTageshinweis) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    calendarService.addEvent(
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Heute ist Freitag. Du hast einen Termin.',
        startTime: todayStart,
        endTime: todayEnd,
        profileIds: [],
      ),
    );
  }
  getIt.registerSingleton<CalendarService>(calendarService);

  addTearDown(() async {
    await getIt.reset();
  });
}
