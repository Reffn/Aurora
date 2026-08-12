import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/services/geocoding_service.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Usage Context für MapPicker
enum MapPickerUsageContext {
  /// Finder-Einträge (Orte/Dinge) - editierbarer Titel
  finder,

  /// Kontakte (Personen) - Name als Titel
  contact,
}

/// MapPicker Widget - Interaktive Karte zum Setzen von GPS-Position
/// Zeigt Karte nur wenn User Kartendaten aktiviert hat
class MapPicker extends StatefulWidget {
  const MapPicker({
    required this.onLocationPicked,
    super.key,
    this.initialLocation,
    this.initialTitle,
    this.usageContext = MapPickerUsageContext.finder,
  });

  final LatLng? initialLocation;
  final String? initialTitle;
  final MapPickerUsageContext usageContext;
  final void Function(LatLng? coordinates) onLocationPicked;

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  final _mapService = getIt<MapService>();
  final _geocodingService = getIt<GeocodingService>();
  late final DataEntry _dataEntry;
  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _titleController = TextEditingController();

  LatLng? _selectedLocation;
  bool _isDownloadingTiles = false;
  bool _isSearching = false;

  // Daten für die Karte
  List<FinderItem> _finderLocations = [];
  List<Contact> _contacts = [];

  // Autocomplete
  Timer? _debounceTimer;
  List<GeocodingResult> _searchSuggestions = [];
  bool _showSuggestions = false;

  // Reverse Geocoding
  String? _selectedLocationAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();
    _selectedLocation = widget.initialLocation;

    // Daten für die Karte laden
    _finderLocations = _dataEntry
        .getFinderItemsByType(FinderItemType.location)
        .where((item) => item.latitude != null && item.longitude != null)
        .toList();
    _contacts = _dataEntry
        .getContacts()
        .where((c) => c.latitude != null && c.longitude != null)
        .toList();

    // Titel-Controller mit initialem Wert befüllen
    if (widget.initialTitle != null && widget.initialTitle!.isNotEmpty) {
      _titleController.text = widget.initialTitle!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _setMarker(LatLng position) async {
    if (!mounted) return;
    setState(() {
      _selectedLocation = position;
      _selectedLocationAddress = null;
      _isLoadingAddress = true;
    });
    widget.onLocationPicked(position);

    // Reverse Geocoding: Koordinaten → Adresse
    try {
      final address = await _geocodingService.reverseGeocode(position);
      if (mounted) {
        setState(() {
          _selectedLocationAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    // Debouncing: 500ms warten
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);

      try {
        final results = await _geocodingService.searchAddressMultiple(query);
        if (mounted) {
          setState(() {
            _searchSuggestions = results;
            _showSuggestions = results.isNotEmpty;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _showSuggestions = false;
          });
        }
      }
    });
  }

  void _selectSuggestion(GeocodingResult suggestion) {
    setState(() {
      _selectedLocation = suggestion.coordinates;
      _selectedLocationAddress =
          suggestion.displayName; // Adresse schon bekannt
      _isLoadingAddress = false;
      _showSuggestions = false;
      _searchController.text = suggestion.displayName;
    });
    widget.onLocationPicked(suggestion.coordinates);

    // Karte zentrieren
    if (_mapService.areTilesDownloaded) {
      _mapController.move(suggestion.coordinates, 17);
    }

    // Erfolgs-Feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📍 ${suggestion.displayName}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _searchAddress(String query) async {
    final l10n = AppLocalizations.of(context);
    // Bei Enter: Ersten Vorschlag nutzen
    if (_searchSuggestions.isNotEmpty) {
      _selectSuggestion(_searchSuggestions.first);
      return;
    }

    // Fallback: Direkte Suche
    if (query.trim().isEmpty) return;

    if (!mounted) return;
    setState(() => _isSearching = true);

    try {
      final result = await _geocodingService.searchAddress(query);

      if (mounted) {
        if (result != null) {
          _selectSuggestion(result);
        } else {
          setState(() => _isSearching = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.mapAddressNotFound),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mapNeedsInternet),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadTilesAndReload() async {
    final l10n = AppLocalizations.of(context);
    if (!mounted) return;
    setState(() => _isDownloadingTiles = true);

    try {
      // MapService aktivieren
      await _mapService.downloadTiles();

      if (mounted) {
        setState(() => _isDownloadingTiles = false);

        // Erfolgs-Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mapDataEnabled),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Karte wird automatisch neu gebaut weil areTilesDownloaded jetzt true ist
        // Widget rebuildet sich automatisch durch setState
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloadingTiles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetail(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTitleInputSection() {
    final l10n = AppLocalizations.of(context);
    if (_selectedLocation == null) {
      // Kein Marker gesetzt
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.mapTapOrSearch,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingAddress) {
      // Adresse wird geladen
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text(
              l10n.mapAddressLoading,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Marker mit Adresse gesetzt - zeige Adresse und Titel-Eingabe
    final address = _selectedLocationAddress ?? AppTexts.current.addressUnknown;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adresse
          Row(
            children: [
              const Icon(Icons.place, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Titel-Eingabe (kontextsensitiv)
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: widget.usageContext == MapPickerUsageContext.contact
                  ? l10n.finderPersonName
                  : l10n.finderPlaceTitle,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Icon(
                widget.usageContext == MapPickerUsageContext.contact
                    ? Icons.person
                    : Icons.edit_location,
                size: 20,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context);
    final isEnabled = _selectedLocation != null && !_isLoadingAddress;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                // Zurück mit allen Daten: coordinates, address, title
                Navigator.pop(context, {
                  'coordinates': _selectedLocation,
                  'address': _selectedLocationAddress,
                  'title': _titleController.text.trim(),
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              l10n.mapPickTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Karte nur anzeigen wenn User Kartendaten aktiviert hat
    if (!_mapService.areTilesDownloaded) {
      return _buildNoMapPlaceholder();
    }

    // Die Gestenleiste unten gehört dem System; der Knopf darf nicht darunter
    // liegen.
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Die Karte nimmt die ganze Fläche.
            //
            // Vorher blieben oben und unten je zehn Prozent schwarz — ein
            // Fünftel des Schirms für nichts, denn Suchfeld, Titelzeile und
            // Knopf liegen ohnehin über der Karte, nicht daneben. Wer einen
            // Ort auf einer Karte sucht, braucht jeden Punkt davon.
            Positioned.fill(
              child: OverviewMap(
                height: double.infinity, // Höhe wird durch Positioned bestimmt
                showFinderLocations: true,
                showContacts: true,
                showZoomControls: true,
                showLocationButton: true,
                // Kein GPS-Statusband: Es sagt hier nichts, was die Karte
                // nicht zeigt, und es liegt genau dort, wo der Knopf steht,
                // mit dem die Auswahl endet. Der Standortknopf bleibt — er
                // ist eine Handlung, das Band war nur eine Auskunft.
                showGpsStatus: false,
                interactive: true,
                onMapTap: _setMarker,
                externalController: _mapController,
                initialCenter: _selectedLocation,
                finderLocations: _finderLocations,
                contacts: _contacts,
                customMarkers: _selectedLocation != null
                    ? [
                        Marker(
                          point: _selectedLocation!,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.primary,
                            size: 40,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : [],
              ),
            ),

            // Der Erklär-Banner stand hier zweimal: oben „Tippe auf die
            // Karte, suche eine Adresse oder nutze deinen Standort", unten
            // über dem Knopf „Tippe auf die Karte oder suche eine Adresse".
            // Derselbe Satz zweimal sagt ihn nicht deutlicher — er verdeckt
            // nur Karte. Der untere bleibt: Er steht dort, wo die Handlung
            // endet.

            // Adress-Suchfeld + Autocomplete (dynamisch)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Suchfeld
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.mapSearchHint,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchSuggestions = [];
                                    _showSuggestions = false;
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      onSubmitted: _searchAddress,
                      onChanged: _onSearchChanged,
                    ),
                  ),

                  // Autocomplete Dropdown
                  if (_showSuggestions && _searchSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchSuggestions.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final suggestion = _searchSuggestions[index];
                          return ListTile(
                            leading: const Icon(Icons.place, size: 20),
                            title: Text(
                              suggestion.displayName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            dense: true,
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Titel-Eingabe Sektion (dynamisch unten)
            Positioned(
              bottom: safeBottom + 156,
              left: 16,
              right: 16,
              child: _buildTitleInputSection(),
            ),

            // "Ort eintragen" Button (dynamisch unten)
            //
            // Der Abstand nach unten hält den Standortknopf der Karte frei,
            // der in ihrer rechten unteren Ecke sitzt. Lägen beide auf
            // derselben Höhe, verdeckte der breite Knopf den runden.
            Positioned(
              bottom: safeBottom + 86,
              left: 16,
              right: 16,
              child: _buildSaveButton(),
            ),
          ],
        );
      },
    );
  }

  /// Platzhalter wenn Kartendaten nicht geladen
  Widget _buildNoMapPlaceholder() {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.mapDataNotLoaded,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mapEnableToMark,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.mapDataFromOsm,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Haupt-Button: Kartendaten jetzt laden
              ElevatedButton.icon(
                onPressed: _isDownloadingTiles ? null : _downloadTilesAndReload,
                icon: _isDownloadingTiles
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  _isDownloadingTiles ? l10n.commonLoading : l10n.activateNow,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Sekundär-Button: Abbrechen
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).actionCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
