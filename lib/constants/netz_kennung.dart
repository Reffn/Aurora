/// Wie Aurora sich fremden Servern gegenüber nennt.
///
/// ## Warum das eine eigene Datei ist
///
/// Bis zum 16.08.2026 nannte sich Aurora gegenüber OpenStreetMap in zwei
/// Varianten, und beide sagten zu viel:
///
/// - `emergency_message_service.dart`: `Aurora DIS App`
/// - `geocoding_service.dart`: `com.aurora.dis_app`
///
/// Nominatims Nutzungsbedingungen verlangen eine identifizierende Kennung,
/// das war also kein Versehen. Die Wirkung war trotzdem diese: Bei jeder
/// Adresssuche und bei jeder Rückwärtssuche im Notfallbereich ging eine
/// Anfrage hinaus, die einem fremden Betreiber mitteilt, dass unter dieser
/// IP-Adresse **eine App für Dissoziative Identitätsstörung** läuft — im
/// Notfall zusammen mit den genauen Koordinaten des Menschen.
///
/// Nach DSGVO Art. 9 ist das die Offenlegung eines Gesundheitsdatums an
/// einen Dritten, und sie steht in dessen Protokollen. `AGENTS.md` nennt
/// jeden Datenpunkt dieser App kontextbedingt ein Gesundheitsdatum; das gilt
/// nicht nur für Nutzlasten, die wir selbst entgegennehmen.
///
/// Dieses Projekt hat `READ_MEDIA_IMAGES` wegen weniger aufgegeben.
///
/// ## Was die Kennung leisten muss
///
/// Sie muss die Bedingung erfüllen (identifizierbarer Betreiber, erreichbar
/// bei Missbrauch) und darf die Diagnose nicht nennen. Der Betreibername und
/// eine Kontaktadresse leisten beides. Wer wissen will, was `3ofus` ist,
/// kann nachsehen — der Unterschied ist, dass es dann eine Entscheidung ist
/// und keine Zeile in einem fremden Zugriffsprotokoll.
///
/// Bewacht von test/core/keine_stille_verbindung_test.dart.
class NetzKennung {
  const NetzKennung._();

  /// Die Kennung für alle ausgehenden Anfragen an fremde Server.
  ///
  /// Enthält bewusst kein `DIS`, kein `dis_app`, kein `Aurora`. Die
  /// Kontaktadresse ist dieselbe wie im Impressum und in `SECURITY.md`.
  static const String userAgent = '3ofus-app/3.0 (info@3ofus.app)';

  /// Was `flutter_map` an die Kachelanfragen hängt.
  ///
  /// Eigener Wert, weil das Paket keinen freien User-Agent annimmt: Es baut
  /// daraus `flutter_map (<wert>)` und erwartet eine Paketkennung. Der
  /// bisherige Wert war `com.aurora.dis_app` — dieselbe Auskunft wie oben,
  /// nur an den Kachelserver, und der bekommt zusätzlich mit, welchen
  /// Ausschnitt jemand ansieht.
  ///
  /// Die tatsächliche Paketkennung der App (`com.disapp.dis_app`) kommt aus
  /// demselben Grund nicht in Frage.
  static const String kachelPaketName = 'app.3ofus';
}
