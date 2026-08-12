import 'dart:convert';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service für Notfall-Nachrichten und Kommunikation mit Notfallkontakten
class EmergencyMessageService {
  EmergencyMessageService(this._dataEntry, this._gpsManager);

  final DataEntry _dataEntry;
  final GpsManager _gpsManager;

  /// Generiert die Notfall-Nachricht automatisch
  ///
  /// Format:
  /// ```
  /// Ich brauche Hilfe, hier ist [Profilname].
  /// Ich befinde mich: [GPS-Position + Adresse]
  /// Kannst du mich bitte anrufen.
  ///
  /// (Gesendet mit der Aurora App - dem Alltagsbegleiter bei Dissoziativer Identitätsstörung)
  /// ```
  Future<String> buildEmergencyMessage() async {
    // 1. Hole aktiven Profilnamen
    final profile = _dataEntry.getActiveProfile();
    final profileName = profile?.name ?? 'Unbekannt';

    // 2. Versuche GPS-Position zu holen
    //
    // Über den GpsManager, nicht direkt über Geolocator: Er ist die einzige
    // Stelle, die den Sensor anfasst, und genau daran hängt die Zusage, dass
    // Standort das Gerät nur auf den erlaubten Wegen verlässt. Er holt die
    // Position mit denselben Vorgaben wie zuvor — hohe Genauigkeit, zehn
    // Sekunden Zeitlimit — und `forceRefresh` umgeht seinen Zwischenspeicher:
    // Im Notfall zählt, wo jemand jetzt ist, nicht wo er vor einer halben
    // Minute war.
    String locationText;
    try {
      final position = await _gpsManager.getUserPosition(forceRefresh: true);

      if (position == null) {
        // Der Unterschied ist für die Empfängerin wichtig: Eine fehlende
        // Berechtigung kann die Nutzerin ändern, ein fehlgeschlagener Abruf
        // nicht. Der GpsManager hat den Berechtigungsstand beim Abruf gerade
        // aufgefrischt.
        locationText = _gpsManager.hasGpsPermission.value
            ? AppTexts.current.emergencyPositionUnavailable
            : AppTexts.current.emergencyPositionNoPermission;
      } else {
        final lat = position.latitude.toStringAsFixed(6);
        final lon = position.longitude.toStringAsFixed(6);

        // Versuche Reverse Geocoding für Adresse
        final address = await _reverseGeocode(
          position.latitude,
          position.longitude,
        );

        if (address != null) {
          locationText = 'Koordinaten: $lat, $lon\nAdresse: $address';
        } else {
          locationText = 'Koordinaten: $lat, $lon';
        }
      }
    } catch (e) {
      locationText = AppTexts.current.emergencyPositionUnavailable;
    }

    // 3. Nachricht zusammenbauen
    return '''
Ich brauche Hilfe, hier ist $profileName.
Ich befinde mich: $locationText
Kannst du mich bitte anrufen.

(Gesendet mit der Aurora App - dem Alltagsbegleiter bei Dissoziativer Identitätsstörung)
''';
  }

  /// Versucht via Nominatim Reverse Geocoding eine Adresse zu ermitteln
  Future<String?> _reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );

      final response = await http
          .get(
            url,
            headers: {'User-Agent': 'Aurora DIS App'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final displayName = data['display_name'] as String?;
        return displayName;
      }
      return null;
    } catch (e) {
      return null; // Reverse Geocoding fehlgeschlagen, ist aber optional
    }
  }

  /// Sendet SMS an einen einzelnen Kontakt
  ///
  /// Öffnet die SMS-App mit vorbefüllter Nachricht
  Future<void> sendSmsToContact(Contact contact) async {
    if (contact.phone == null || contact.phone!.isEmpty) {
      throw Exception('Kontakt hat keine Telefonnummer');
    }

    final message = await buildEmergencyMessage();
    final phoneNumber = contact.phone!.replaceAll(RegExp(r'[^\d+]'), '');

    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    if (!await launchUrl(uri)) {
      throw Exception('SMS-App konnte nicht geöffnet werden');
    }
  }

  /// Sendet SMS an alle Notfallkontakte
  ///
  /// Öffnet die SMS-App mit allen Nummern und vorbefüllter Nachricht
  Future<void> sendSmsToAll(List<Contact> contacts) async {
    final contactsWithPhone = contacts
        .where(
          (c) => c.phone != null && c.phone!.isNotEmpty,
        )
        .toList();

    if (contactsWithPhone.isEmpty) {
      throw Exception('Keine Kontakte mit Telefonnummer gefunden');
    }

    final message = await buildEmergencyMessage();

    // Sammle alle Telefonnummern
    final phoneNumbers = contactsWithPhone
        .map((c) => c.phone!.replaceAll(RegExp(r'[^\d+]'), ''))
        .join(';'); // Semikolon trennt mehrere Empfänger

    final uri = Uri(
      scheme: 'sms',
      path: phoneNumbers,
      queryParameters: {'body': message},
    );

    if (!await launchUrl(uri)) {
      throw Exception('SMS-App konnte nicht geöffnet werden');
    }
  }

  /// Öffnet Share Intent mit der Notfall-Nachricht
  ///
  /// User kann dann App wählen (WhatsApp, Telegram, etc.)
  Future<void> shareMessage() async {
    final message = await buildEmergencyMessage();
    await Share.share(
      message,
      subject: AppTexts.current.emergencySmsSubject,
    );
  }

  /// Ruft einen Kontakt direkt an
  Future<void> callContact(Contact contact) async {
    if (contact.phone == null || contact.phone!.isEmpty) {
      throw Exception('Kontakt hat keine Telefonnummer');
    }

    final phoneNumber = contact.phone!.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: phoneNumber);

    if (!await launchUrl(uri)) {
      throw Exception('Telefon-App konnte nicht geöffnet werden');
    }
  }

  /// Ruft eine Hotline direkt an
  Future<void> callHotline(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);

    if (!await launchUrl(uri)) {
      throw Exception('Telefon-App konnte nicht geöffnet werden');
    }
  }

  /// Öffnet eine Website (für Chat-basierte Hotlines)
  Future<void> openWebsite(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Website konnte nicht geöffnet werden');
    }
  }
}
