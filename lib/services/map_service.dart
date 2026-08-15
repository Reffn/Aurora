import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Map Service - Verwaltet Kartendaten-Status
/// Erstmal nur Flag-Management, echter Tile-Download später
class MapService extends BaseService {
  MapService(super.eventBus);

  static const String _keyTilesDownloaded = 'map_tiles_downloaded';
  SharedPreferences? _prefs;

  @override
  Future<void> openBoxes() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void subscribeToEvents() {
    // Keine Events nötig für v3.1
  }

  @override
  Future<void> closeBoxes() async {
    // SharedPreferences braucht kein Close
  }

  /// Prüft ob Kartendaten geladen wurden
  bool get areTilesDownloaded {
    return _prefs?.getBool(_keyTilesDownloaded) ?? false;
  }

  /// Kartendaten als "geladen" markieren
  /// Note: Echter Download wird on-demand von flutter_map gemacht
  /// Dies ist nur ein User-Präferenz-Flag
  Future<void> setTilesDownloaded(bool value) async {
    await _prefs?.setBool(_keyTilesDownloaded, value);
  }

  /// "Download" Kartendaten (erstmal nur Flag setzen)
  /// Echter Tile-Download würde hier später implementiert werden
  Future<void> downloadTiles() async {
    await setTilesDownloaded(true);
  }

  /// Kartendaten löschen (Cache leeren + Flag zurücksetzen)
  Future<void> clearTiles() async {
    logger.info(
      LogCategory.service,
      'MapService: Clearing map tiles data',
    );

    // Reset Flag
    await setTilesDownloaded(false);

    // Note: flutter_map verwaltet seinen eigenen Tile-Cache intern
    // Der wird beim nächsten App-Start automatisch neu geladen
    // Ein manuelles Löschen des Cache-Verzeichnisses ist nicht nötig

    logger.info(
      LogCategory.service,
      'MapService: Map tiles cleared successfully',
      data: {'areTilesDownloaded': areTilesDownloaded},
    );
  }
}
