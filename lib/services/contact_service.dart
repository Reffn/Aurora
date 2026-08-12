import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/contact_comment.dart';
import 'package:dis_app/models/contact_rating.dart';
import 'package:dis_app/services/comment_service.dart';
import 'package:hive_ce/hive.dart';

/// Contact-Service - Verwaltet Kontakte mit Hive-Persistierung
/// Inkl. Multi-Rating System (Default + Overrides) und Kommentare
class ContactService extends BaseService {
  ContactService(super.eventBus);
  late Box<Contact> _contactsBox;
  late Box<ContactRating> _ratingsBox;
  late Box<ContactComment> _commentsBox;

  @override
  Future<void> openBoxes() async {
    // PARALLEL: Öffne alle 3 Boxes gleichzeitig für bessere Performance
    final results = await Future.wait([
      Hive.openBox<Contact>(HiveBoxNames.contacts),
      Hive.openBox<ContactRating>(HiveBoxNames.contactRatings),
      Hive.openBox<ContactComment>(HiveBoxNames.contactComments),
    ]);

    _contactsBox = results[0] as Box<Contact>;
    _ratingsBox = results[1] as Box<ContactRating>;
    _commentsBox = results[2] as Box<ContactComment>;
  }

  @override
  void subscribeToEvents() {
    // TODO: Events später hinzufügen wenn benötigt
  }

  @override
  Future<void> closeBoxes() async {
    await _contactsBox.close();
    await _ratingsBox.close();
    await _commentsBox.close();
  }

  /// Zugriff auf Contacts-Box für ValueListenable
  Box<Contact> get contactsBox => _contactsBox;

  /// Zugriff auf Ratings-Box für ValueListenable
  Box<ContactRating> get ratingsBox => _ratingsBox;

  /// Zugriff auf Comments-Box für ValueListenable
  Box<ContactComment> get commentsBox => _commentsBox;

  /// Alle Kontakte abrufen
  List<Contact> get contacts => List.unmodifiable(_contactsBox.values.toList());

  /// Kontakte nach Kategorie filtern
  List<Contact> getByCategory(ContactCategory category) {
    return _contactsBox.values
        .where((contact) => contact.category == category)
        .toList();
  }

  /// Kontakte nach Name suchen
  List<Contact> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return _contactsBox.values.where((contact) {
      return contact.name.toLowerCase().contains(lowerQuery) ||
          (contact.relation?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Kontakt erstellen
  Future<void> create(Contact contact) async {
    await _contactsBox.put(contact.id, contact);
  }

  /// Kontakt aktualisieren
  Future<void> update(Contact contact) async {
    await _contactsBox.put(contact.id, contact);
  }

  /// Kontakt löschen (inkl. cascade delete für Ratings und Comments)
  Future<void> delete(String contactId) async {
    // Kontakt löschen
    await _contactsBox.delete(contactId);

    // Alle Ratings zu diesem Kontakt löschen
    final ratingKeysToDelete = _ratingsBox.keys.where((key) {
      final rating = _ratingsBox.get(key);
      return rating?.contactId == contactId;
    }).toList();

    for (final key in ratingKeysToDelete) {
      await _ratingsBox.delete(key);
    }

    // Alle ALTEN ContactComments löschen (legacy data)
    final commentKeysToDelete = _commentsBox.keys.where((key) {
      final comment = _commentsBox.get(key);
      return comment?.contactId == contactId;
    }).toList();

    for (final key in commentKeysToDelete) {
      await _commentsBox.delete(key);
    }

    // Alle NEUEN unified Comments löschen (cascade delete)
    final commentService = getIt<CommentService>();
    await commentService.deleteCommentsForParent(
      CommentableType.contact,
      contactId,
    );
  }

  /// Kontakt per ID abrufen
  Contact? getById(String id) {
    return _contactsBox.get(id);
  }

  // ============ RATING SYSTEM ============

  /// Bewertung für ein Profil abrufen
  /// Gibt Override-Rating zurück, falls vorhanden, sonst Default-Rating
  int getRatingForProfile(String contactId, String profileId) {
    final contact = getById(contactId);
    if (contact == null) return 3; // Neutral fallback

    // Suche nach Override-Rating
    final override = _ratingsBox.values.firstWhere(
      (r) => r.contactId == contactId && r.profileId == profileId,
      orElse: () => ContactRating(
        id: '',
        contactId: '',
        profileId: '',
        rating: contact.defaultRating,
        createdAt: DateTime.now(),
      ),
    );

    // Falls kein Override gefunden (erkennbar an leerer ID), verwende Default
    return override.id.isEmpty ? contact.defaultRating : override.rating;
  }

  /// Rating für ein Profil setzen (Override)
  Future<void> setRatingForProfile(
    String contactId,
    String profileId,
    int rating,
  ) async {
    assert(rating >= 1 && rating <= 5, 'Rating muss zwischen 1 und 5 liegen');

    // Suche existierendes Override
    ContactRating? existingRating;
    try {
      existingRating = _ratingsBox.values.firstWhere(
        (r) => r.contactId == contactId && r.profileId == profileId,
      );
    } catch (e) {
      // Kein Override vorhanden
    }

    if (existingRating != null) {
      // Update existing
      final updated = existingRating.copyWith(
        rating: rating,
        editedAt: DateTime.now(),
      );
      await _ratingsBox.put(existingRating.id, updated);
    } else {
      // Create new override
      final newRating = ContactRating(
        id: '${contactId}_$profileId',
        contactId: contactId,
        profileId: profileId,
        rating: rating,
        createdAt: DateTime.now(),
      );
      await _ratingsBox.put(newRating.id, newRating);
    }
  }

  /// Entfernt Override-Rating (fällt zurück auf Default)
  Future<void> removeRatingOverride(String contactId, String profileId) async {
    final key = '${contactId}_$profileId';
    await _ratingsBox.delete(key);
  }

  // ============ COMMENT SYSTEM ============

  /// Alle Kommentare zu einem Kontakt
  List<ContactComment> getCommentsForContact(String contactId) {
    return _commentsBox.values.where((c) => c.contactId == contactId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Anzahl der Kommentare zu einem Kontakt
  int getCommentCount(String contactId) {
    return _commentsBox.values.where((c) => c.contactId == contactId).length;
  }

  /// Kommentar hinzufügen
  Future<void> addComment(ContactComment comment) async {
    await _commentsBox.put(comment.id, comment);
  }

  /// Kommentar aktualisieren
  Future<void> updateComment(ContactComment comment) async {
    await _commentsBox.put(comment.id, comment);
  }

  /// Kommentar löschen
  Future<void> deleteComment(String commentId) async {
    await _commentsBox.delete(commentId);
  }

  /// Alle Kontakte, Bewertungen und Kommentare löschen (Debug-Option)
  Future<void> clearAll() async {
    await _contactsBox.clear();
    await _ratingsBox.clear();
    await _commentsBox.clear();
    // Hive notified automatisch alle ValueListenable Listener!
  }
}
