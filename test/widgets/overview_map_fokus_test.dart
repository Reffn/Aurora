import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MinimalDataEntry implements DataEntry {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MinimalGpsManager implements GpsManager {
  @override
  final hasGpsPermission = ValueNotifier(true);

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

/// Die Fläche unter dem Eingabeschirm: hängt ihre Karte auf Zuruf neu ein.
///
/// So verhält sich die Profilauswahl, sobald die Tastatur aufgeht — sie wird
/// niedriger, wechselt in den Rollzweig und baut die Zeitkarte neu.
class _Unten extends StatefulWidget {
  const _Unten({super.key});

  @override
  State<_Unten> createState() => _UntenState();
}

class _UntenState extends State<_Unten> {
  int _generation = 0;

  void neuEinhaengen() => setState(() => _generation++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverviewMap(
        key: ValueKey(_generation),
        showUserLocation: false,
        showPermissionBanner: false,
      ),
    );
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    getIt
      ..registerSingleton<DataEntry>(_MinimalDataEntry())
      ..registerSingleton<EventBus>(EventBus())
      ..registerSingleton<GpsManager>(_MinimalGpsManager())
      ..registerSingleton<MapService>(_MinimalMapService())
      ..registerSingleton<LocationTrackingService>(
        _MinimalLocationTrackingService(),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  // Rückmeldungen vom 29.09. und 05.10.2026: Die Tastatur geht auf und
  // sofort wieder zu — beim Namen eines neuen Anteils und im Chat. Am A14
  // nachgestellt; ohne Standortrecht, also ohne Karte, blieb sie offen.
  //
  // flutter_map setzt `KeyboardOptions.autofocus` von Haus aus auf true. Eine
  // Karte, die in der Route darunter neu eingehängt wird, zieht damit den
  // Fokus aus dem Textfeld darüber.
  testWidgets(
    'eine neu eingehängte Karte darunter nimmt dem Textfeld den Fokus nicht',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final untenKey = GlobalKey<_UntenState>();
      final feldFokus = FocusNode();
      addTearDown(feldFokus.dispose);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: _Unten(key: untenKey),
        ),
      );
      await tester.pump();

      // Die Route bleibt offen; auf ihr Schließen wartet hier niemand.
      unawaited(
        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              body: Center(child: TextField(focusNode: feldFokus)),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(feldFokus.hasPrimaryFocus, isTrue);

      untenKey.currentState!.neuEinhaengen();
      await tester.pump();
      await tester.pump();

      expect(
        feldFokus.hasPrimaryFocus,
        isTrue,
        reason:
            'Fokus liegt bei '
            '${FocusManager.instance.primaryFocus?.debugLabel}',
      );
    },
  );
}
