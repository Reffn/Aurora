import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/services/comment_service.dart';
import 'package:hive_ce/hive.dart';

/// Finder-Service - Verwaltet Orte und Gegenstände mit Hive-Persistierung
/// Platzhalter-Implementation (ohne Events vorerst)
class FinderService extends BaseService {
  FinderService(super.eventBus);
  late Box<FinderItem> _finderItemsBox;

  @override
  Future<void> openBoxes() async {
    _finderItemsBox = await Hive.openBox<FinderItem>(HiveBoxNames.finderItems);
  }

  @override
  void subscribeToEvents() {
    // TODO: Events später hinzufügen wenn benötigt
  }

  @override
  Future<void> closeBoxes() async {
    await _finderItemsBox.close();
  }

  /// Zugriff auf FinderItems-Box für ValueListenable
  Box<FinderItem> get finderItemsBox => _finderItemsBox;

  /// Alle Items abrufen
  List<FinderItem> get items =>
      List.unmodifiable(_finderItemsBox.values.toList());

  /// Items nach Typ filtern
  List<FinderItem> getByType(FinderItemType type) {
    return _finderItemsBox.values.where((item) => item.type == type).toList();
  }

  /// Items nach Titel suchen
  List<FinderItem> searchByTitle(String query) {
    final lowerQuery = query.toLowerCase();
    return _finderItemsBox.values.where((item) {
      return item.title.toLowerCase().contains(lowerQuery) ||
          (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Items nach Tag filtern
  List<FinderItem> filterByTag(String tag) {
    return _finderItemsBox.values
        .where((item) => item.tags.contains(tag))
        .toList();
  }

  /// Wichtige Items (Tag "wichtig")
  List<FinderItem> get importantItems {
    return _finderItemsBox.values.where((item) => item.isImportant).toList();
  }

  /// Notfall-Items (Tag "notfall")
  List<FinderItem> get emergencyItems {
    return _finderItemsBox.values.where((item) => item.isEmergency).toList();
  }

  /// Item erstellen
  Future<void> create(FinderItem item) async {
    await _finderItemsBox.put(item.id, item);
  }

  /// Item aktualisieren
  Future<void> update(FinderItem item) async {
    await _finderItemsBox.put(item.id, item);
  }

  /// Item löschen (inkl. cascade delete für Comments)
  Future<void> delete(String itemId) async {
    await _finderItemsBox.delete(itemId);

    // Cascade delete: Alle unified Comments löschen
    final commentService = getIt<CommentService>();
    await commentService.deleteCommentsForParent(
      CommentableType.finder,
      itemId,
    );
  }

  /// Item per ID abrufen
  FinderItem? getById(String id) {
    return _finderItemsBox.get(id);
  }

  /// Alle Finder-Items löschen (Debug-Option)
  Future<void> clearAll() async {
    await _finderItemsBox.clear();
    // Hive notified automatisch alle ValueListenable Listener!
  }
}
