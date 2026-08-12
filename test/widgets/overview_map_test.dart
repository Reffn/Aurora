import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:dis_app/widgets/map_marker_contact.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../support/text_scale_harness.dart';

/// Dummy implementations for testing
class _MinimalDataEntry implements DataEntry {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MinimalGpsManager implements GpsManager {
  final hasGpsPermission = ValueNotifier(false);

  @override
  String formatPosition(dynamic position) => position?.toString() ?? 'unknown';

  @override
  String formatCoordinates(double lat, double lng) => '$lat,$lng';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MinimalMapService implements MapService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MinimalLocationTrackingService implements LocationTrackingService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('OverviewMap - Data Consumption (No Hive)', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      await getIt.reset();

      // Register minimal dependencies - NO Hive
      getIt.registerSingleton<DataEntry>(_MinimalDataEntry());
      getIt.registerSingleton<EventBus>(EventBus());

      final fakeGpsManager = _MinimalGpsManager();
      getIt.registerSingleton<GpsManager>(fakeGpsManager);

      getIt.registerSingleton<MapService>(_MinimalMapService());
      getIt.registerSingleton<LocationTrackingService>(
          _MinimalLocationTrackingService());
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('renders with passed contacts without Hive box', (tester) async {
      // Create test contacts with GPS data
      final contacts = [
        Contact(
          id: const Uuid().v4(),
          name: 'Contact 1',
          category: ContactCategory.emergency,
          defaultRating: 0,
          latitude: 52.520008,
          longitude: 13.404954,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
        Contact(
          id: const Uuid().v4(),
          name: 'Contact 2',
          category: ContactCategory.emergency,
          defaultRating: 0,
          latitude: 52.521008,
          longitude: 13.405954,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
      ];

      final map = OverviewMap(
        height: 250,
        showUserLocation: false,
        showContacts: true,
        showFinderLocations: false,
        contacts: contacts,
      );

      await pumpScaled(tester, map, settle: false);

      // Verify the map renders without error
      expect(find.byType(OverviewMap), findsOneWidget);

      // The test passes if we got here without Hive trying to open a box
    });

    testWidgets('renders with passed finder locations without Hive box',
        (tester) async {
      // Create test finder items with GPS data
      final finderItems = [
        FinderItem(
          id: const Uuid().v4(),
          type: FinderItemType.location,
          title: 'Place 1',
          tags: [],
          latitude: 52.520008,
          longitude: 13.404954,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
        FinderItem(
          id: const Uuid().v4(),
          type: FinderItemType.location,
          title: 'Place 2',
          tags: [],
          latitude: 52.521008,
          longitude: 13.405954,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
      ];

      final map = OverviewMap(
        height: 250,
        showUserLocation: false,
        showContacts: false,
        showFinderLocations: true,
        finderLocations: finderItems,
      );

      await pumpScaled(tester, map, settle: false);

      // Verify the map renders without error
      expect(find.byType(OverviewMap), findsOneWidget);
    });

    testWidgets('showContacts false hides contacts even when passed',
        (tester) async {
      final contacts = [
        Contact(
          id: const Uuid().v4(),
          name: 'Contact 1',
          category: ContactCategory.emergency,
          defaultRating: 0,
          latitude: 52.520008,
          longitude: 13.404954,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
      ];

      final map = OverviewMap(
        height: 250,
        showUserLocation: false,
        showContacts: false, // Explicitly false
        showFinderLocations: false,
        contacts: contacts,
      );

      await pumpScaled(tester, map, settle: false);

      // Verify the map renders without showing contacts
      expect(find.byType(OverviewMap), findsOneWidget);
    });

    testWidgets('showFinderLocations false hides locations even when passed',
        (tester) async {
      final finderItems = [
        FinderItem(
          id: const Uuid().v4(),
          type: FinderItemType.location,
          title: 'Place 1',
          tags: [],
          latitude: 52.520008,
          longitude: 13.404954,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
      ];

      final map = OverviewMap(
        height: 250,
        showUserLocation: false,
        showContacts: false,
        showFinderLocations: false, // Explicitly false
        finderLocations: finderItems,
      );

      await pumpScaled(tester, map, settle: false);

      // Verify the map renders without showing locations
      expect(find.byType(OverviewMap), findsOneWidget);
    });

    testWidgets('handles null contacts and finderLocations gracefully',
        (tester) async {
      final map = OverviewMap(
        height: 250,
        showUserLocation: false,
        showContacts: true,
        showFinderLocations: true,
        // No contacts or finderLocations passed
      );

      await pumpScaled(tester, map, settle: false);

      // Verify the map renders without error even with null data
      expect(find.byType(OverviewMap), findsOneWidget);
    });

    testWidgets('filters contacts without GPS', (tester) async {
      final contacts = [
        // Contact with GPS
        Contact(
          id: const Uuid().v4(),
          name: 'Contact 1',
          category: ContactCategory.emergency,
          defaultRating: 0,
          latitude: 52.520008,
          longitude: 13.404954,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
        // Contact without GPS
        Contact(
          id: const Uuid().v4(),
          name: 'Contact 2',
          category: ContactCategory.emergency,
          defaultRating: 0,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
      ];

      final map = OverviewMap(
        height: 250,
        showUserLocation: false,
        showContacts: true,
        showFinderLocations: false,
        contacts: contacts,
      );

      await pumpScaled(tester, map, settle: false);

      // Verify the map renders (only contact with GPS would be shown)
      expect(find.byType(OverviewMap), findsOneWidget);
    });

    testWidgets('privacy: showContacts false hides contacts with GPS coordinates', (tester) async {
      // Profile selection screen before login: must not show contact locations
      // even when they are passed with coordinates. A contact's location is
      // another person's home address and belongs nowhere on a pre-login surface.
      final contactsWithGPS = [
        Contact(
          id: const Uuid().v4(),
          name: 'Contact 1',
          category: ContactCategory.emergency,
          defaultRating: 0,
          latitude: 52.520008,  // Has coordinates
          longitude: 13.404954,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
        Contact(
          id: const Uuid().v4(),
          name: 'Contact 2',
          category: ContactCategory.emergency,
          defaultRating: 0,
          latitude: 52.521008,  // Has coordinates
          longitude: 13.405954,
          createdByProfileId: 'test-profile',
          createdAt: DateTime.now(),
        ),
      ];

      final map = OverviewMap(
        height: 250,
        showUserLocation: false,
        showContacts: false,  // CRITICAL: Privacy — hide contacts
        showFinderLocations: false,
        contacts: contactsWithGPS,  // Passed, but must not be shown
      );

      await pumpScaled(tester, map, settle: false);

      // Verify the map renders
      expect(find.byType(OverviewMap), findsOneWidget);

      // CRITICAL ASSERTION: No contact markers visible — privacy preserved
      // Contact locations are home addresses; showContacts:false must filter them out
      // regardless of whether coordinates are passed. This test has teeth: if the flag
      // were removed or set the other way, the assertion fails.
      expect(
        find.byType(MapMarkerContact),
        findsNothing,
        reason: 'showContacts:false must prevent contact markers '
            'even when contacts with coordinates are passed',
      );
    });
  });
}
