import 'dart:convert';

import 'package:dis_app/l10n/app_texts.dart';

/// Was beim Feedback das Gerät verlässt.
///
/// Bewusst ein eigener Typ statt einer freien Map: Das Schema ist die Stelle,
/// an der die Kanaltrennung aus der Spec durchgesetzt und getestet wird.
/// Standortdaten sind hier strukturell nicht vorgesehen.
class FeedbackPayload {
  /// Die Grenzen spiegeln die Feld-Whitelist in `firestore.rules`. Was der
  /// Server abweist, darf hier gar nicht erst entstehen: Ein Absturzbericht
  /// mit 30 Breadcrumbs sprengt die 5000 Zeichen für `message` mühelos, und
  /// die Regel hätte jeden davon abgelehnt — der Firestore-Weg wäre für genau
  /// die Berichte tot gewesen, für die er gedacht ist.
  static const int maxCategoryLength = 50;
  static const int maxMessageLength = 5000;
  static const int maxReplyEmailLength = 200;
  static const int maxDiagnosticsLength = 10000;

  /// Untergrenze der Regel. Wird nicht erzwungen — kürzen kann man, verlängern
  /// nicht. Die Formulare prüfen sie beim Ausfüllen, der Fehlerbericht-Dialog
  /// setzt eine feste Zeile, die sie überschreitet.
  static const int minMessageLength = 20;

  static const String _truncationMarker = '\n[gekürzt]';

  factory FeedbackPayload({
    required String category,
    required String message,
    String? replyEmail,
    String? diagnostics,
  }) {
    return FeedbackPayload._(
      category: _clamp(category, maxCategoryLength),
      message: _clamp(message, maxMessageLength),
      replyEmail: replyEmail == null
          ? null
          : _clamp(replyEmail, maxReplyEmailLength),
      diagnostics: diagnostics == null
          ? null
          : _clamp(diagnostics, maxDiagnosticsLength),
    );
  }

  const FeedbackPayload._({
    required this.category,
    required this.message,
    this.replyEmail,
    this.diagnostics,
  });

  final String category;
  final String message;

  /// Optionale Rückmeldeadresse. Nur gesetzt, wenn die Nutzerin sie einträgt.
  final String? replyEmail;

  /// Gerätediagnose: der erzeugte Fehler- oder Absturzbericht. Enthält keine
  /// Inhalte aus der App — der Generator schwärzt vorher.
  final String? diagnostics;

  /// Kürzt auf die Grenze der Serverregel und macht das Kürzen sichtbar.
  ///
  /// Gemessen wird in UTF-8-Bytes, nicht in Zeichen: Das ist die
  /// konservativere Grenze, weil ein Zeichen nie weniger Bytes als
  /// UTF-16-Einheiten belegt. Geschnitten wird an Rune-Grenzen, damit kein
  /// Emoji in zwei Hälften zerfällt.
  static String _clamp(String value, int limitInBytes) {
    if (utf8.encode(value).length <= limitInBytes) {
      return value;
    }

    final budget = limitInBytes - utf8.encode(_truncationMarker).length;
    final kept = StringBuffer();
    var used = 0;

    for (final rune in value.runes) {
      final width = utf8.encode(String.fromCharCode(rune)).length;
      if (used + width > budget) break;
      kept.writeCharCode(rune);
      used += width;
    }

    kept.write(_truncationMarker);
    return kept.toString();
  }

  /// Serialisierung für den Versand. Leere Felder entfallen vollständig,
  /// damit keine leeren Schlüssel übertragen werden.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'category': category,
      'message': message,
    };

    if (replyEmail != null && replyEmail!.isNotEmpty) {
      map['replyEmail'] = replyEmail;
    }
    if (diagnostics != null && diagnostics!.isNotEmpty) {
      map['diagnostics'] = diagnostics;
    }

    return map;
  }

  /// Wörtliche Darstellung für Vorschau und Übertragungsprotokoll.
  /// Muss exakt das zeigen, was gesendet wird.
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln('Kategorie: $category');
    buffer.writeln();
    buffer.writeln(message);

    if (replyEmail != null && replyEmail!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Antwort an: $replyEmail');
    }
    if (diagnostics != null && diagnostics!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(AppTexts.current.feedbackDeviceDiagnostics);
      buffer.writeln(diagnostics);
    }

    return buffer.toString();
  }
}
