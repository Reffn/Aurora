import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Die gewählte Sprache, schon bevor Hive offen ist.
///
/// Die Wahl liegt in der Einstellungs-Kiste (`selected_locale`), und die wird
/// erst in den Diensten geöffnet — nach dem Ladebildschirm. Der sprach
/// deshalb die **System**sprache: Auf einem englischen Gerät stand dort
/// „Aurora is loading", während die App danach auf Deutsch weiterlief. Am
/// 11. August 2026 am S24 gesehen, und es ist kein Randfall — ein deutsches
/// Android mit englischer Systemsprache ist verbreitet.
///
/// Die Wahl wird deshalb zusätzlich dort abgelegt, wo man sie ohne Hive und
/// ohne Dienste lesen kann. Ein zweiter Ort für dieselbe Angabe ist ein
/// Preis: Er darf nur gezahlt werden, weil das Original in Hive die einzige
/// Wahrheit bleibt und diese Kopie ausschließlich den einen Bildschirm
/// versorgt, der zu früh kommt, um zu fragen.
class StartupLocale {
  const StartupLocale._();

  static const String _schluessel = 'selected_locale';

  static String? _code;

  /// Die gemerkte Sprache, oder `null` — dann gilt die Systemsprache.
  static Locale? get locale => _code == null ? null : Locale(_code!);

  /// Holt die gemerkte Sprache. Läuft in `main()` vor dem ersten Bild.
  ///
  /// Schlägt das fehl, bleibt es bei der Systemsprache: Eine fehlende
  /// Sprachnotiz darf keinen Start verhindern.
  static Future<void> laden() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _code = prefs.getString(_schluessel);
    } on Exception {
      _code = null;
    }
  }

  /// Legt die Sprache für den nächsten Start ab.
  ///
  /// Wird von jeder Stelle gerufen, die `selected_locale` schreibt — der
  /// Sprachwahl im Onboarding und der in den Einstellungen. Wer eine dritte
  /// hinzufügt und das hier vergisst, merkt es erst beim übernächsten Start.
  static Future<void> merken(String code) async {
    _code = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_schluessel, code);
    } on Exception {
      // Die Wahl steht in Hive und wirkt sofort. Verloren geht nur, dass der
      // nächste Ladebildschirm sie schon kennt.
    }
  }
}
