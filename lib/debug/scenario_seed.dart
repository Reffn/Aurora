import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/permission_preset_service.dart';
import 'package:flutter/material.dart';

/// Test-Szenario „Lina kommt hoch" — nur für Entwicklungs-Durchläufe.
///
/// Aktivierung ausschließlich über
/// `flutter run --dart-define=SEED_SCENARIO=lina-mina`. Ohne das Define ist
/// die Konstante leer und der Compiler entfernt den gesamten Pfad aus dem
/// Release — genau das gewünschte Verhalten: Testdaten können nie in einem
/// normalen Build landen.
///
/// Szenario: Mina war die letzten Stunden vorn. Sie ist von Zuhause
/// (Kirchstraße, Coswig) zum Edeka (Dresdner Straße 73) gegangen und wieder
/// zurück. In 50 Minuten steht ein Arzttermin an (Moritzburger Straße 90D,
/// Weinböhla). Wer die App jetzt öffnet — Lina — muss das alles sehen,
/// ohne zu suchen.
const String _seedScenario = String.fromEnvironment('SEED_SCENARIO');

/// Alle Seed-Einträge tragen dieses Präfix, damit ein erneuter Lauf sie
/// ersetzt statt sie zu stapeln.
const String _seedPrefix = 'seed-';

// Koordinaten aus OpenStreetMap (Nominatim), Raum Coswig/Weinböhla:
const _home = (lat: 51.1259088, lng: 13.5777349); // Kirchstraße 3, Coswig
const _edeka = (lat: 51.1253274, lng: 13.5759941); // Dresdner Straße 73
const _arzt = (
  lat: 51.1617015,
  lng: 13.6054998,
); // Moritzburger Str. 90, Weinböhla

Future<void> maybeSeedScenario() async {
  if (_seedScenario != 'lina-mina') return;

  try {
    await _seedLinaMina();
  } catch (e, stackTrace) {
    logger.error(
      LogCategory.service,
      'SEED: Szenario fehlgeschlagen',
      data: {'error': e.toString()},
      stackTrace: stackTrace,
    );
  }
}

Future<void> _seedLinaMina() async {
  final dataEntry = getIt<DataEntry>();
  final tracking = getIt<LocationTrackingService>();
  final now = DateTime.now();

  // --- Profile: vorhandene wiederverwenden, fehlende anlegen -------------
  final profiles = dataEntry.getProfiles();

  Profile? byName(String name) {
    for (final p in profiles) {
      if (p.name.toLowerCase() == name.toLowerCase()) return p;
    }
    return null;
  }

  // Leere Permissions stoßen beim nächsten Start die Profil-Migration an,
  // die den PermissionPresetService braucht, bevor er registriert ist —
  // also bekommen Seed-Profile von Anfang an das Standard-Preset.
  final standardPermissions = getIt<PermissionPresetService>()
      .getPermissionsForPreset('standard');

  // Ohne Picker-Position setzt die Profil-Migration die Farbe auf Weiß
  // zurück — deshalb wird sie hier immer mitgegeben, und ein bereits
  // weiß-migriertes Seed-Profil bekommt seine Farbe zurück.
  Future<Profile> ensureProfile({
    required String id,
    required String name,
    required Color color,
    required double pickerX,
    required double pickerY,
    bool isAdmin = false,
  }) async {
    final existing = byName(name);
    if (existing == null) {
      final profile = Profile.withColor(
        id: id,
        name: name,
        preferredColor: color,
        createdAt: now,
        isAdmin: isAdmin,
        permissions: standardPermissions,
        colorPickerPositionX: pickerX,
        colorPickerPositionY: pickerY,
      );
      await dataEntry.createProfile(profile, source: 'SEED');
      return profile;
    }
    if (existing.preferredColorValue != color.toARGB32() ||
        existing.colorPickerPositionX == null) {
      final repaired = existing.copyWith(
        preferredColor: color,
        colorPickerPositionX: pickerX,
        colorPickerPositionY: pickerY,
      );
      await dataEntry.updateProfile(repaired);
      return repaired;
    }
    return existing;
  }

  final lina = await ensureProfile(
    id: '${_seedPrefix}profile-lina',
    name: 'Lina',
    color: const Color(0xFF26A69A),
    pickerX: 0.42,
    pickerY: 0.55,
    isAdmin: true,
  );
  final mina = await ensureProfile(
    id: '${_seedPrefix}profile-mina',
    name: 'Mina',
    color: const Color(0xFF7E57C2),
    pickerX: 0.72,
    pickerY: 0.45,
  );

  // --- Alte Seed-Daten ersetzen statt stapeln ----------------------------
  final switchBox = tracking.switchEventsBox;
  final locationBox = tracking.locationHistoryBox;
  for (final key
      in switchBox.keys
          .whereType<String>()
          .where((k) => k.startsWith(_seedPrefix))
          .toList()) {
    await switchBox.delete(key);
  }
  for (final key
      in locationBox.keys
          .whereType<String>()
          .where((k) => k.startsWith(_seedPrefix))
          .toList()) {
    await locationBox.delete(key);
  }

  // --- Mina kam vor 3 Stunden nach vorn (Zuhause) ------------------------
  await switchBox.put(
    '${_seedPrefix}switch-mina',
    ProfileSwitchEvent(
      id: '${_seedPrefix}switch-mina',
      fromProfileId: lina.id,
      toProfileId: mina.id,
      timestamp: now.subtract(const Duration(hours: 3)),
      latitude: _home.lat,
      longitude: _home.lng,
    ),
  );

  // --- Minas Weg: Zuhause → Edeka → Zuhause ------------------------------
  final path = <(int minutesAgo, double lat, double lng, String? address)>[
    (170, _home.lat, _home.lng, 'Kirchstraße 3, 01640 Coswig, Deutschland'),
    (150, 51.12572, 13.57705, null),
    (
      140,
      _edeka.lat,
      _edeka.lng,
      'Dresdner Straße 73, 01640 Coswig, Deutschland',
    ),
    (
      120,
      _edeka.lat,
      _edeka.lng,
      'Dresdner Straße 73, 01640 Coswig, Deutschland',
    ),
    (110, 51.12560, 13.57680, null),
    (95, _home.lat, _home.lng, 'Kirchstraße 3, 01640 Coswig, Deutschland'),
  ];
  for (final (minutesAgo, lat, lng, address) in path) {
    final id = '${_seedPrefix}loc-$minutesAgo';
    await locationBox.put(
      id,
      LocationHistoryEntry(
        id: id,
        profileId: mina.id,
        latitude: lat,
        longitude: lng,
        timestamp: now.subtract(Duration(minutes: minutesAgo)),
        accuracy: 12,
        address: address,
      ),
    );
  }

  // --- Arzttermin in 50 Minuten ------------------------------------------
  // Immer neu gesetzt: Ein stehengebliebener Termin von gestern läge beim
  // nächsten Testlauf in der Vergangenheit und das Szenario wäre kaputt.
  final existingEvents = dataEntry.getCalendarEvents();
  if (existingEvents.any((e) => e.id == '${_seedPrefix}event-arzt')) {
    await dataEntry.deleteCalendarEvent('${_seedPrefix}event-arzt');
  }
  await dataEntry.createCalendarEvent(
    CalendarEvent(
      id: '${_seedPrefix}event-arzt',
      title: 'Arzttermin',
      startTime: now.add(const Duration(minutes: 50)),
      endTime: now.add(const Duration(minutes: 110)),
      profileIds: [lina.id, mina.id],
      latitude: _arzt.lat,
      longitude: _arzt.lng,
      locationName: 'Moritzburger Straße 90D, 01689 Weinböhla',
    ),
    source: 'SEED',
  );

  // --- Medikament mit Einnahme in 2 Stunden --------------------------------
  // Liegt nach dem Arzttermin, damit auf der Zukunftsleiste beide Kerben
  // stehen: Kalender nahe am Jetzt, Pille dahinter. Zeit immer relativ zum
  // Start, aus demselben Grund wie beim Termin.
  final einnahme = now.add(const Duration(hours: 2));
  final einnahmeZeit =
      '${einnahme.hour.toString().padLeft(2, '0')}:'
      '${einnahme.minute.toString().padLeft(2, '0')}';
  if (dataEntry.getAllMedications().any(
    (m) => m.id == '${_seedPrefix}med-vitamin',
  )) {
    await dataEntry.deleteMedication('${_seedPrefix}med-vitamin');
  }
  await dataEntry.createMedication(
    Medication(
      id: '${_seedPrefix}med-vitamin',
      name: 'Vitamin D',
      dosage: '1 Tablette',
      timesOfDay: [einnahmeZeit],
      profileIds: [lina.id, mina.id],
      createdAt: now,
    ),
    source: 'SEED',
  );

  // --- Martin wohnt um die Ecke --------------------------------------------
  // Wer an einem Ort hochkommt, den er nicht einordnen kann, braucht mehr als
  // die Karte: einen Menschen in Reichweite. Martin steht deshalb mit
  // Koordinaten in den Kontakten und erscheint dadurch auf der Zeitkarte —
  // aber erst hinter der Anmeldung, denn es ist seine Adresse.
  // Alle Seed-Kontakte weg, nicht nur der eigene: Frühere Durchläufe haben
  // welche mit anderen Kennungen hinterlassen, und zwei Martins nebeneinander
  // auf der Karte sind schlimmer als keiner.
  const martinId = '${_seedPrefix}contact-martin';
  for (final stale
      in dataEntry
          .getContacts()
          .where((c) => c.id.startsWith(_seedPrefix))
          .toList()) {
    await dataEntry.deleteContact(stale.id, source: 'SEED');
  }
  await dataEntry.createContact(
    Contact(
      id: martinId,
      name: 'Martin',
      relation: 'Nachbar',
      phone: '0351 5551234',
      notes: 'Hat einen Schlüssel. Kann man auch nachts anrufen.',
      category: ContactCategory.friends,
      createdByProfileId: lina.id,
      createdAt: now,
      defaultRating: 5,
      // Rund zweihundert Meter vom Zuhause: nah genug, um hinzugehen, weit
      // genug, dass sein Punkt nicht auf dem Standort-Marker klebt.
      latitude: 51.12730,
      longitude: 13.57930,
      address: 'Kirchstraße 18, 01640 Coswig',
    ),
    source: 'SEED',
  );

  logger.info(
    LogCategory.service,
    'SEED: Szenario lina-mina eingespielt',
    data: {
      'mina': mina.id,
      'lina': lina.id,
      'locations': path.length,
      'terminIn': '50min',
      'kontakt': 'Martin',
    },
  );
}
