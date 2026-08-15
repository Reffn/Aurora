import 'package:dis_app/l10n/app_localizations.dart';

/// Feedback-Kategorien für Entwickler-Kontakt
enum FeedbackCategory {
  bugReport,
  featureRequest,
  generalFeedback;

  /// Der Wert, der die Leitung verlässt — unabhängig von der Sprache.
  ///
  /// Hier stand einmal `displayName`, dasselbe Feld, das auch die Schaltfläche
  /// beschriftete. Das koppelte zwei Dinge, die nichts miteinander zu tun
  /// haben: Was jemand liest, hängt von seiner Sprache ab; was ausgewertet
  /// wird, darf es nicht. Sonst kommt dieselbe Kategorie je nach Gerät als
  /// „Bug Report", „Rapport de bug" oder „Segnalazione" an und zerfällt in der
  /// Auswertung.
  String get wireName {
    switch (this) {
      case FeedbackCategory.bugReport:
        return 'bug_report';
      case FeedbackCategory.featureRequest:
        return 'feature_request';
      case FeedbackCategory.generalFeedback:
        return 'general';
    }
  }

  /// Beschriftung für die Oberfläche, in der Sprache der App.
  ///
  /// Vorher standen hier feste englische Wörter — „Bug Report" und „Feature
  /// Request" auch auf einer deutschen Oberfläche. Fachwörter aus einer
  /// Fremdsprache sind für diese Zielgruppe ausgeschlossen
  /// (`docs/oberflaechen-richtlinien.md`, nach W3C COGA).
  String label(AppLocalizations l10n) {
    switch (this) {
      case FeedbackCategory.bugReport:
        return l10n.feedbackCategoryBug;
      case FeedbackCategory.featureRequest:
        return l10n.feedbackCategoryWish;
      case FeedbackCategory.generalFeedback:
        return l10n.feedbackCategoryGeneral;
    }
  }

  /// Emoji-Icon für Kategorie
  String get icon {
    switch (this) {
      case FeedbackCategory.bugReport:
        return '🐛';
      case FeedbackCategory.featureRequest:
        return '✨';
      case FeedbackCategory.generalFeedback:
        return '💬';
    }
  }

  /// E-Mail Subject Präfix
  String get emailSubjectPrefix {
    switch (this) {
      case FeedbackCategory.bugReport:
        return '[Bug]';
      case FeedbackCategory.featureRequest:
        return '[Feature]';
      case FeedbackCategory.generalFeedback:
        return '[Feedback]';
    }
  }
}
