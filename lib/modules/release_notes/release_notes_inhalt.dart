import 'package:dis_app/l10n/app_localizations.dart';

/// Was eine Fassung bringt — in der Sprache des Schirms.
///
/// **Pflege bei jedem Release:** Für die neue Nummer aus `pubspec.yaml` einen
/// Schlüssel `releaseNotesFassung<Nummer ohne Punkte>` in **allen fünf**
/// ARB-Dateien anlegen und hier eintragen. Vergessen geht nicht still durch:
/// `test/modules/release_notes/release_notes_inhalt_test.dart` liest die
/// Nummer aus `pubspec.yaml` und schlägt fehl, solange der Eintrag fehlt.
///
/// Ein bis drei Sätze, in der Sprache der Menschen, die Aurora benutzen —
/// was sie merken, nicht was im Code geschah. Gab es nur Ausbesserungen im
/// Hintergrund, steht genau das dort.
///
/// Ohne Eintrag (`null`) zeigt der Schirm `releaseNotesAllgemein` — nie den
/// Text einer früheren Fassung. Bis 3.0.22 stand dort ein einziger fester
/// Satz, und wer ihn zum zweiten Mal las, erfuhr nichts.
///
/// Die Nummer kommt ohne Build-Zusatz an (`3.0.22`, nicht `3.0.22+22`), so
/// wie `TelemetryRecorder.appVersion` sie führt.
String? releaseNotesFuerFassung(String? version, AppLocalizations l10n) {
  return switch (version) {
    '3.0.22' => l10n.releaseNotesFassung3022,
    '3.0.23' => l10n.releaseNotesFassung3023,
    '3.0.24' => l10n.releaseNotesFassung3024,
    '3.0.25' => l10n.releaseNotesFassung3025,
    _ => null,
  };
}
