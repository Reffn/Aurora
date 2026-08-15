import 'package:dis_app/widgets/gps_status_icon.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Die GPS-Anzeige für Kopfzeilen.
///
/// Verborgen, solange die Standortverfolgung dauerhaft eingeschaltet ist —
/// dann sagt der Fußbereich schon, was Sache ist, und zwei Anzeigen für
/// dasselbe wären eine zu viel.
///
/// Eigene Datei, damit das Gerüst der Arbeitsflächen keine Hive-Box anfassen
/// muss: Sonst bräuchte jeder Test dieses Gerüsts eine geöffnete Datenbank.
class GpsStatusAction extends StatelessWidget {
  const GpsStatusAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<dynamic>('settings').listenable(
        keys: ['global_tracking_always_on'],
      ),
      builder: (context, box, _) {
        final isGlobalTrackingOn =
            box.get(
                  'global_tracking_always_on',
                  defaultValue: false,
                )
                as bool;

        if (isGlobalTrackingOn) {
          return const SizedBox.shrink();
        }
        return const GpsStatusIcon();
      },
    );
  }
}
