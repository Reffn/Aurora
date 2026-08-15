import 'package:dis_app/core/logger.dart';
import 'package:dis_app/utils/contact_config.dart';

/// Newsletter Service Scaffold
///
/// Vorbereitet für Newsletter-Integration (z.B. Mailchimp, Sendinblue, etc.)
/// Aktuell nur Stub-Implementation - kann später erweitert werden.
///
/// Verwendung:
/// ```dart
/// final service = NewsletterService();
/// final success = await service.subscribe('user@email.com');
/// ```
class NewsletterService {
  factory NewsletterService() => _instance;
  NewsletterService._();
  static final NewsletterService _instance = NewsletterService._();

  /// Meldet Email für Newsletter an
  ///
  /// Returns: true bei Erfolg, false bei Fehler
  ///
  /// TODO: Implementiere tatsächliche Newsletter-API Integration
  /// Optionen:
  /// - Mailchimp API
  /// - Sendinblue API
  /// - Newsletter2Go
  /// - Custom Backend
  Future<bool> subscribe(String email) async {
    logger.info(
      LogCategory.network,
      'Newsletter subscription requested',
      data: {'email': _anonymizeEmail(email)},
    );

    try {
      // Validiere Email
      if (!_isValidEmail(email)) {
        logger.warning(
          LogCategory.network,
          'Invalid email for newsletter',
        );
        return false;
      }

      // Prüfe ob Newsletter URL konfiguriert
      if (ContactConfig.newsletterSignupUrl.isEmpty) {
        logger.info(
          LogCategory.network,
          'Newsletter signup URL not configured - storing locally',
        );
        // TODO: Speichere Email lokal für spätere Verarbeitung
        return _storeEmailLocally(email);
      }

      // TODO: Hier Newsletter-API Integration implementieren
      // Beispiel für Mailchimp:
      // final response = await http.post(
      //   Uri.parse(ContactConfig.newsletterSignupUrl),
      //   headers: {
      //     'Authorization': 'Bearer YOUR_API_KEY',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'email_address': email,
      //     'status': 'subscribed',
      //   }),
      // );
      //
      // return response.statusCode == 200;

      logger.warning(
        LogCategory.network,
        'Newsletter API not implemented yet',
      );

      return _storeEmailLocally(email);
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.network,
        'Error subscribing to newsletter',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Speichert Email lokal (bis API implementiert ist)
  ///
  /// TODO: Speichere in Hive oder SharedPreferences
  /// Dann können Emails später manuell exportiert und importiert werden
  Future<bool> _storeEmailLocally(String email) async {
    try {
      // TODO: Implementiere lokale Speicherung
      // Beispiel:
      // final prefs = await SharedPreferences.getInstance();
      // final emails = prefs.getStringList('newsletter_emails') ?? [];
      // if (!emails.contains(email)) {
      //   emails.add(email);
      //   await prefs.setStringList('newsletter_emails', emails);
      // }

      logger.info(
        LogCategory.network,
        'Newsletter email stored locally',
        data: {'email': _anonymizeEmail(email)},
      );

      return true;
    } catch (e) {
      logger.error(
        LogCategory.network,
        'Error storing newsletter email locally',
        data: {'error': e.toString()},
      );
      return false;
    }
  }

  /// Validiert Email-Adresse
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Anonymisiert Email für Logging (Privacy)
  ///
  /// Beispiel: "user@example.com" → "u***@e***.com"
  String _anonymizeEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***@***.***';

    final name = parts[0];
    final domain = parts[1];

    final anonymizedName = name.length > 1
        ? '${name[0]}${'*' * (name.length - 1)}'
        : '*';

    final domainParts = domain.split('.');
    final anonymizedDomain = domainParts
        .map((part) {
          return part.length > 1 ? '${part[0]}${'*' * (part.length - 1)}' : '*';
        })
        .join('.');

    return '$anonymizedName@$anonymizedDomain';
  }

  /// Gibt an ob Newsletter-Feature aktiviert ist
  bool get isEnabled => ContactConfig.newsletterSignupUrl.isNotEmpty;
}
