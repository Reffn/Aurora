import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Die Sprache für Stellen, die keinen BuildContext haben.
///
/// Dienste und Modelle sehen keinen Widget-Baum: Der NotificationService
/// baut Meldungen im Hintergrund, die Transports geben Fehlertexte zurück,
/// die erst später auf dem Schirm landen. Sie können `AppLocalizations.of`
/// nicht aufrufen.
///
/// Hier liegt deshalb eine Referenz, die die Oberfläche bei jedem Bauen
/// setzt. Solange die App läuft, ist sie da; vorher greift der Rückfall auf
/// die Vorlagensprache, was nur beim allerersten Start vor dem ersten
/// Frame vorkommen kann.
///
/// Der NotificationService hatte dafür ein eigenes `setLocalization`, das
/// niemand je aufgerufen hat — alle Benachrichtigungen liefen deshalb auf
/// den englischen Rückfallwerten, auch bei deutscher Spracheinstellung.
/// Diese Stelle wird tatsächlich gesetzt: von AppTextsBinding in main.dart.
class AppTexts {
  const AppTexts._();

  static AppLocalizations? _current;

  /// Die aktuelle Sprache, oder Deutsch, falls noch nichts gebaut wurde.
  static AppLocalizations get current =>
      _current ?? lookupAppLocalizations(const Locale('de'));

  static final ValueNotifier<String?> _localeTag = ValueNotifier<String?>(null);

  /// Die aktuelle Sprachkennung, sobald eine gebunden ist.
  ///
  /// Wer vorgemerkte Texte hält, muss von einem Sprachwechsel erfahren: Eine
  /// Erinnerung trägt ihren Wortlaut seit dem Vormerken mit sich. Ohne dieses
  /// Signal blieben Meldungen in der alten Sprache stehen, bis sie erscheinen
  /// — und beim Kaltstart in Deutsch, weil hier bis zum ersten Binden der
  /// Rückfallwert steht.
  static ValueListenable<String?> get localeTag => _localeTag;

  /// Wird von AppTextsBinding bei jedem Bauen gesetzt.
  ///
  /// Der Notifier meldet sich nur bei echtem Wechsel, nicht bei jedem Bauen.
  static void update(AppLocalizations l10n) {
    _current = l10n;
    _localeTag.value = l10n.localeName;
  }

  /// Setzt die Sprache aus einer gespeicherten Kennung.
  ///
  /// Das braucht der Start: Der Abgleich der Erinnerungen läuft, bevor
  /// irgendein Widget gebaut ist — also bevor [AppTextsBinding] je zum Zug
  /// kommt. Ohne diese Zeile plante ein Kaltstart alle Meldungen auf dem
  /// deutschen Rückfallwert, auch auf einem englisch eingestellten Gerät.
  ///
  /// Eine unbekannte Kennung ändert nichts; der Rückfallwert bleibt stehen.
  static void useLocaleTag(String? tag) {
    if (tag == null || tag.isEmpty) return;
    try {
      update(lookupAppLocalizations(Locale(tag)));
    } catch (_) {
      // Nicht unterstützte Sprache: lieber die Vorgabe als ein Absturz
      // im Start.
    }
  }
}

/// Reicht die Sprache an [AppTexts] und an `intl` weiter.
///
/// Gehört möglichst weit oben in den Baum, unterhalb der MaterialApp, damit
/// AppLocalizations bereits verfügbar ist.
///
/// `Intl.defaultLocale` gehört hierher, weil `DateFormat` ohne ausdrückliche
/// Sprache genau darauf zurückgreift. Ohne diese Zeile blieb der Vorgabewert
/// stehen, und der Kalender schrieb „Montag, 3. August" unter die Überschrift
/// „Calendar" — die Oberfläche war übersetzt, die Datumsangaben nicht.
class AppTextsBinding extends StatelessWidget {
  const AppTextsBinding({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    AppTexts.update(AppLocalizations.of(context));
    Intl.defaultLocale = Localizations.localeOf(context).toLanguageTag();
    return child;
  }
}
