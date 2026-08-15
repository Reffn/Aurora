import 'package:dis_app/core/logger.dart';
import 'package:hive_ce/hive.dart';

/// Entscheidet, ob nach einem Update einmal gezeigt wird, was sich geändert
/// hat.
///
/// **Warum es diesen Weg überhaupt gibt.** Aurora kann Menschen nicht
/// erreichen. Play verteilt Updates zuverlässig — am 7. August 2026 saßen 39
/// von 39 aktiven Geräten auf derselben Fassung —, aber niemand erfährt
/// dabei, *was* sich geändert hat, und niemand wird gefragt, was fehlt. Bei
/// 24 monatlich aktiven Geräten liegt kein einziges echtes Feedback vor. Der
/// Engpass ist nicht die Reichweite, sondern der Rückweg.
///
/// **Warum kein Push.** Ein FCM-Token ist eine stabile Gerätekennung. Die
/// Zusage der App lautet „keine Kennung, keine Sitzung, kein Zähler" — damit
/// scheidet der Weg aus, nicht aus Aufwand, sondern aus Prinzip. Was bleibt,
/// ist der Augenblick, in dem die neue Fassung zum ersten Mal geöffnet wird.
/// Der gehört dem Gerät und verlässt es nicht.
///
/// **Der Fall, an dem die Sache sonst gescheitert wäre.** In der Fassung, die
/// diese Funktion einführt, hat *kein* Gerät einen gespeicherten Eintrag —
/// eine Neuinstallation sieht genauso aus wie ein Update von vorher. Würde
/// „kein Eintrag" still als Erstinstallation gelten, erschiene der Schirm
/// erstmals eine Fassung später und träfe die Bestandsnutzerinnen nie, für
/// die er gebaut ist. Unterschieden wird deshalb an
/// `pre_onboarding_dismissed`: Wer die Vorstellung hinter sich hat und
/// trotzdem keinen Eintrag trägt, kommt von einer Fassung vor dieser hier.
class ReleaseNotesGate {
  /// Liest und schreibt über Funktionen statt über die Box selbst — dasselbe
  /// Muster wie bei `TelemetryConsent`. Hive schreibt echte Dateien, und echte
  /// Datei-Ein-/Ausgabe blockiert in einem Widget-Test.
  ReleaseNotesGate({
    required String currentVersion,
    required String? Function() readSeenVersion,
    required Future<void> Function(String value) writeSeenVersion,
    required bool Function() hasCompletedOnboarding,
  }) : _currentVersion = currentVersion,
       _read = readSeenVersion,
       _write = writeSeenVersion,
       _hasCompletedOnboarding = hasCompletedOnboarding;

  /// Der Weg für die App: liest und schreibt in der `settings`-Box.
  factory ReleaseNotesGate.fromBox(
    Box<dynamic> settingsBox, {
    required String currentVersion,
  }) {
    return ReleaseNotesGate(
      currentVersion: currentVersion,
      readSeenVersion: () => settingsBox.get(storageKey) as String?,
      writeSeenVersion: (value) => settingsBox.put(storageKey, value),
      hasCompletedOnboarding: () =>
          settingsBox.get(onboardingKey, defaultValue: false) as bool,
    );
  }

  /// Nur für Tests: hält den Zustand im Arbeitsspeicher.
  factory ReleaseNotesGate.inMemory({
    required String currentVersion,
    String? seenVersion,
    bool hasCompletedOnboarding = true,
  }) {
    var value = seenVersion;
    return ReleaseNotesGate(
      currentVersion: currentVersion,
      readSeenVersion: () => value,
      writeSeenVersion: (next) async => value = next,
      hasCompletedOnboarding: () => hasCompletedOnboarding,
    );
  }

  static const String storageKey = 'release_notes_seen_version';

  /// Derselbe Schlüssel, den `main.dart` und der Vorstellungs-Schirm benutzen.
  static const String onboardingKey = 'pre_onboarding_dismissed';

  /// Der Rückfallwert aus `injection.dart`, wenn `PackageInfo` nichts liefert.
  static const String unknownVersion = 'unbekannt';

  final String _currentVersion;
  final String? Function() _read;
  final Future<void> Function(String value) _write;
  final bool Function() _hasCompletedOnboarding;

  bool get needsShowing {
    // Ohne belastbare Fassung entstünde ein Schirm, der bei jedem Start
    // wiederkäme: Gespeichert würde 'unbekannt', verglichen würde gegen
    // 'unbekannt', und beim nächsten echten Wert stünde er wieder da.
    if (_currentVersion.isEmpty || _currentVersion == unknownVersion) {
      return false;
    }

    final seen = _read();

    // Verglichen wird auf Ungleichheit, nie auf Reihenfolge: Nach Zeichenkette
    // sortiert stünde "3.0.9" über "3.0.20", und der Schirm bliebe nach einem
    // Update stumm.
    if (seen != null) return seen != _currentVersion;

    // Kein Eintrag: Die Vorstellung entscheidet. Siehe Klassenkommentar.
    return _hasCompletedOnboarding();
  }

  /// Merkt die laufende Fassung. Danach schweigt der Schirm bis zum nächsten
  /// Update.
  Future<void> markSeen() async {
    if (_currentVersion.isEmpty || _currentVersion == unknownVersion) return;

    await _write(_currentVersion);
    logger.info(
      LogCategory.service,
      'Neuerungen dieser Fassung gesehen',
      data: {'version': _currentVersion},
    );
  }
}
