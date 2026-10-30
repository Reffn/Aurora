import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/time_phase.dart';
import 'package:dis_app/widgets/every_minute.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// „Wann bin ich“: Wochentag, Datum, Uhrzeit und Tagesphase als breites Band
/// direkt unter der Kopfzeile mit „Aurora“.
///
/// Steht auf dem Anker und auf der Profilauswahl. Bis 3.0.24 lagen dieselben
/// Angaben oben rechts in der Zeitkarte, über den Kartenkacheln — am Gerät
/// wirkte das deplatziert, eine Uhr auf einer Landkarte. Der Wunsch war
/// wörtlich: „als Element oben hinten, unter Aurora … als breites Element“.
/// Deshalb über die volle Breite, das Datum vorn, Uhrzeit und Phase hinten.
///
/// Alles ausgeschrieben, nichts als Ziffern: Wer nach Monaten wieder vorn
/// ist, braucht das Jahr; wer einen Tag verloren hat, den Wochentag; und 6:00
/// gegen 18:00 ist auf einer Uhr verwechselbar, „morgens“ gegen „abends“
/// nicht. Die Karte musste dafür abkürzen, das Band hat die Breite.
///
/// Wird die Schrift groß, bricht es in zwei Zeilen um, statt etwas
/// abzuschneiden. Den seitlichen Abstand gibt der Aufrufer vor; das Band
/// nimmt die ganze Breite, die es bekommt.
class ZeitBand extends StatelessWidget {
  const ZeitBand({super.key, this.jetzt = DateTime.now});

  /// Die Uhr. Nur Tests setzen eine andere.
  final DateTime Function() jetzt;

  /// Schrift des Bands. Eine Stelle für Anzeige und Höhenrechnung.
  static const TextStyle _stil = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const EdgeInsets _polster = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const double _rand = 1;
  static const double _abstand = 16;
  static const double _zeilenabstand = 2;

  /// Wie hoch das Band bei dieser Breite wird — gerechnet mit derselben
  /// Schrift, demselben Schriftfaktor und demselben Umbruch wie die Anzeige.
  ///
  /// Hier stand bis zur Abnahme von 3.0.25 eine feste Zahl für eine Zeile
  /// (42 dp). Auf Telefonbreite bricht „Mittwoch, 30. September 2026 ·
  /// 21:48 · abends“ aber zweizeilig um, und die Profilauswahl, die mit der
  /// Zahl ihr Kartenbudget rechnet, schob die Namen um genau diese Zeile
  /// unter die Kante. Eine Zahl, die einen Inhalt beschreibt, driftet von
  /// ihm weg; eine Rechnung über den Inhalt nicht.
  ///
  /// Für die Uhrzeit nimmt die Rechnung die breiteste Tagesphase der
  /// Sprache: Das Band erneuert sich jede Minute, das Budget seines
  /// Aufrufers nicht — so wird es im Lauf des Tages nicht zu knapp.
  static double hoeheFuer(
    BuildContext context, {
    required double breite,
    DateTime Function() jetzt = DateTime.now,
  }) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final scaler = MediaQuery.textScalerOf(context);
    final stil = DefaultTextStyle.of(context).style.merge(_stil);
    final now = jetzt();
    final innen = breite - _polster.horizontal - 2 * _rand;

    Size mass(String text) {
      final maler = TextPainter(
        text: TextSpan(text: text, style: stil),
        textDirection: Directionality.of(context),
        textScaler: scaler,
        locale: Localizations.localeOf(context),
      )..layout(maxWidth: innen);
      final groesse = maler.size;
      maler.dispose();
      return groesse;
    }

    final datum = mass(_datum(locale, now));
    var zeit = Size.zero;
    for (final stunde in const [3, 7, 12, 15, 20]) {
      final z = mass(_zeit(l10n, locale, now, stunde));
      if (z.width > zeit.width ||
          (z.width == zeit.width && z.height > zeit.height)) {
        zeit = z;
      }
    }

    final eineZeile = datum.width + _abstand + zeit.width <= innen;
    final inhalt = eineZeile
        ? (datum.height > zeit.height ? datum.height : zeit.height)
        : datum.height + _zeilenabstand + zeit.height;
    return inhalt + _polster.vertical + 2 * _rand;
  }

  static String _datum(String locale, DateTime now) =>
      DateFormat.yMMMMEEEEd(locale).format(now);

  /// Uhrzeit und Phase; `stunde` wählt die Phase, sonst gilt die Uhr.
  static String _zeit(
    AppLocalizations l10n,
    String locale,
    DateTime now, [
    int? stunde,
  ]) =>
      '${DateFormat.Hm(locale).format(now)} · '
      '${timePhaseOf(l10n, stunde ?? now.hour)}';

  @override
  Widget build(BuildContext context) {
    return EveryMinute(builder: _buildBand);
  }

  Widget _buildBand(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final scheme = Theme.of(context).colorScheme;
    final now = jetzt();

    final datum = _datum(locale, now);
    final zeit = _zeit(l10n, locale, now);

    // Volle Vordergrundfarbe auf einem dunklen, leicht abgesetzten Grund:
    // Lesbarkeit vor Zurückhaltung (Regel 6), aber keine Signalfarbe —
    // die Zeit ruft nicht, sie steht da (Regel 4).
    return Semantics(
      container: true,
      label: '$datum, $zeit',
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: _polster,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant, width: _rand),
          ),
          child: DefaultTextStyle.merge(
            style: _stil.copyWith(color: scheme.onSurface),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: _abstand,
              runSpacing: _zeilenabstand,
              children: [Text(datum), Text(zeit)],
            ),
          ),
        ),
      ),
    );
  }
}
