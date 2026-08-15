import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/modules/finder/widgets/map_picker.dart';
import 'package:dis_app/services/geocoding_service.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/short_place.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Der Ort eines Termins, wie ihn das Formular hält.
///
/// Ohne Koordinaten heißt: kein Ort gesetzt. Ein Name allein reicht nicht —
/// die Karte kann ihn nicht zeigen, und genau dafür ist das Feld da.
class EventLocationChoice {
  const EventLocationChoice({this.latitude, this.longitude, this.name});

  const EventLocationChoice.none()
    : latitude = null,
      longitude = null,
      name = null;

  final double? latitude;
  final double? longitude;
  final String? name;

  bool get hasLocation => latitude != null && longitude != null;
}

/// Wo findet der Termin statt?
///
/// Gespeicherte Orte zuerst, Karte danach. Wer jede Woche zur selben Praxis
/// geht, soll einmal tippen und nicht jedes Mal eine Karte durchsuchen —
/// und „Zuhause" ist der häufigste Ort überhaupt.
///
/// Die Karte bleibt trotzdem erreichbar: Ein einmaliger Termin an einer
/// fremden Adresse darf nicht dazu zwingen, dafür erst einen dauerhaften Ort
/// anzulegen.
class EventLocationSheet {
  /// Öffnet die Auswahl. `null` heißt abgebrochen — dann bleibt, was war.
  static Future<EventLocationChoice?> show(BuildContext context) {
    return showModalBottomSheet<EventLocationChoice>(
      context: context,
      backgroundColor: AppColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) => const _EventLocationSheetBody(),
    );
  }
}

class _EventLocationSheetBody extends StatelessWidget {
  const _EventLocationSheetBody();

  /// Gespeicherte Orte mit Koordinaten. Ein Ort ohne Koordinaten kann auf
  /// keiner Karte stehen und gehört deshalb nicht in diese Liste.
  List<FinderItem> _places() {
    return getIt<DataEntry>()
        .getFinderItems()
        .where((item) => item.type == FinderItemType.location)
        .where((item) => item.latitude != null && item.longitude != null)
        .toList();
  }

  Future<void> _pickOnMap(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final picked = await navigator.push<LatLng>(
      MaterialPageRoute<LatLng>(
        builder: (mapContext) => Scaffold(
          appBar: AppBar(title: Text(l10n.eventLocationOther)),
          body: MapPicker(
            onLocationPicked: (coordinates) =>
                Navigator.of(mapContext).pop(coordinates),
          ),
        ),
      ),
    );
    if (picked == null) return;

    // Der Name kommt aus der Rückwärts-Geokodierung, damit auf dem Termin
    // „Kirchstraße 3" steht und nicht ein Zahlenpaar. Schlägt sie fehl —
    // kein Netz, kein Treffer —, bleibt der Ort trotzdem gültig; nur der
    // Name fehlt dann.
    String? name;
    try {
      name = shortPlace(await getIt<GeocodingService>().reverseGeocode(picked));
    } catch (e) {
      logger.warning(
        LogCategory.ui,
        'EventLocationSheet: reverse geocoding failed',
        data: {'error': e.toString()},
      );
    }

    navigator.pop(
      EventLocationChoice(
        latitude: picked.latitude,
        longitude: picked.longitude,
        name: name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final places = _places();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              l10n.eventLocationTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final place in places)
                  ListTile(
                    leading: const Icon(Icons.place, color: AppColors.paper),
                    title: Text(
                      place.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.of(context).pop(
                      EventLocationChoice(
                        latitude: place.latitude,
                        longitude: place.longitude,
                        name: place.title,
                      ),
                    ),
                  ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.map, color: Colors.lightBlue),
                  title: Text(
                    l10n.eventLocationOther,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => _pickOnMap(context),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.location_off,
                    color: Colors.white54,
                  ),
                  title: Text(
                    l10n.eventLocationNone,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () => Navigator.of(
                    context,
                  ).pop(const EventLocationChoice.none()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
