import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/events/navigation_events.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

/// Navigation-Service - Verwaltet App-Navigation mit Hive-Persistierung
/// Single Source of Truth für aktuelle Page
/// Hinweis: Nutzt ValueNotifier für reaktive UI-Updates
class NavigationService extends BaseService {
  NavigationService(super.eventBus);
  late Box<dynamic> _settingsBox;
  int _currentPageIndex = 0;

  // Finder Sub-Tab Index (0 = Orte, 1 = Dinge)
  int _finderCurrentTabIndex = 0;

  final ValueNotifier<int> _currentPageNotifier = ValueNotifier(0);

  @override
  Future<void> openBoxes() async {
    _settingsBox = await Hive.openBox(HiveBoxNames.settings);

    // Letzte Page-Position laden (falls vorhanden)
    final savedIndex = _settingsBox.get('current_page_index') as int?;
    if (savedIndex != null && savedIndex >= 0) {
      _currentPageIndex = savedIndex;
    }

    _notifyListeners();
  }

  @override
  void subscribeToEvents() {
    eventBus.on<NavigationChangedEvent>().listen(_handleNavigationChanged);
    eventBus.on<NavigationRequestedEvent>().listen(_handleNavigationRequested);
  }

  @override
  Future<void> closeBoxes() async {
    _currentPageNotifier.dispose();
    await _settingsBox.close();
  }

  /// ValueNotifier für aktuelle Page (für UI-Updates)
  ValueListenable<int> get currentPageNotifier => _currentPageNotifier;

  /// Aktuelle Page abrufen (synchron)
  int get currentPageIndex => _currentPageIndex;

  /// Finder Sub-Tab Index abrufen (0 = Orte, 1 = Dinge)
  int get finderCurrentTabIndex => _finderCurrentTabIndex;

  /// Finder Sub-Tab Index setzen
  void setFinderTabIndex(int index) {
    if (index >= 0 && index <= 1) {
      _finderCurrentTabIndex = index;
    }
  }

  /// Zu einer Page navigieren
  void navigateToPage(int index) {
    if (index >= 0 && index != _currentPageIndex) {
      eventBus.publish(NavigationChangedEvent(index));
    }
  }

  /// Navigation geändert
  void _handleNavigationChanged(NavigationChangedEvent event) {
    _currentPageIndex = event.pageIndex;
    _settingsBox.put('current_page_index', event.pageIndex);
    _notifyListeners();
  }

  /// Navigation angefordert (für Query-Pattern)
  void _handleNavigationRequested(NavigationRequestedEvent event) {
    eventBus.publish(NavigationResponseEvent(_currentPageIndex));
  }

  /// Listeners benachrichtigen
  void _notifyListeners() {
    _currentPageNotifier.value = _currentPageIndex;
  }

  /// Navigation-Daten löschen (Debug-Option)
  /// Entfernt nur den aktuellen Page-Index aus der Settings-Box
  Future<void> clearAll() async {
    await _settingsBox.delete('current_page_index');
    _currentPageIndex = 0;
    _notifyListeners();
  }
}
