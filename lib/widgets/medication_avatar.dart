import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Horizontales Pillen-Avatar für Medikamente
///
/// Universell verwendbar in:
/// - Timeline (`TimelineEventSymbol`) - Klein (20-48px)
/// - Medikamenten-Karten (`MedicationCard`) - Mittel (60x30px)
/// - As-needed Cards (`AsNeededMedicationCard`)
///
/// **Features:**
/// - Horizontale Pillenform (breiter als hoch, ~2:1 Ratio)
/// - ProfileImageWidget mit Rainbow-Initialen Fallback
/// - Intelligente Textabkürzung (2-3 Buchstaben statt nur 1)
/// - Status-basierte Hintergrundfarben (grün/rot/orange/blau/grau)
/// - White Border (anpassbar)
/// - Box Shadow
///
/// **Verwendung:**
/// ```dart
/// MedicationAvatar(
///   imagePath: medication.imagePath,
///   name: medication.name,
///   statusColor: Colors.green,  // taken
///   width: 40,
///   height: 20,
/// )
/// ```
class MedicationAvatar extends StatelessWidget {
  const MedicationAvatar({
    required this.imagePath,
    required this.name,
    super.key,
    this.width = 40,
    this.height,
    this.statusColor,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.showShadow = true,
  });

  final String? imagePath;
  final String name;
  final double width;
  final double? height;
  final Color? statusColor;
  final Color borderColor;
  final double borderWidth;
  final bool showShadow;

  /// Berechnet Höhe basierend auf Breite (2:1 Ratio)
  double get _height => height ?? (width / 2);

  /// Status-Farbe oder Default Blau
  Color get _backgroundColor => statusColor ?? Colors.blue.shade600;

  /// Berechnet intelligente Textabkürzung für Medikamentennamen
  /// - Namen ≤3 Zeichen: vollständig
  /// - Namen 4-6 Zeichen: erste 3 Buchstaben
  /// - Namen >6 Zeichen: erste 2-3 Buchstaben (basierend auf Breite)
  int get _optimalCharCount {
    if (name.length <= 3) return name.length; // Vollständig bei kurzen Namen
    if (name.length <= 6) return 3; // 3 Buchstaben für mittlere Namen

    // Bei langen Namen: 2-3 Buchstaben basierend auf verfügbarer Breite
    // Bei schmalen Pillen (< 30px): 2 Buchstaben
    // Bei breiteren Pillen (≥ 30px): 3 Buchstaben
    return width >= 30 ? 3 : 2;
  }

  @override
  Widget build(BuildContext context) {
    final pillRadius = _height / 2;

    return Container(
      width: width,
      height: _height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(pillRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(pillRadius - borderWidth),
        child: _inhalt(),
      ),
    );
  }

  /// Das Foto füllt die Pille; ohne Foto bleibt es beim Kürzel.
  ///
  /// [ProfileImageWidget] schneidet rund und rechnet mit einer quadratischen
  /// Kantenlänge — richtig für Profilbilder, falsch für eine liegende Pille:
  /// Das Tablettenfoto erschien darin als Kreis von Höhe mal Höhe und ließ
  /// den Rest der Fläche leer. Für das Kürzel bleibt der gemeinsame Weg, weil
  /// dessen Regenbogen-Darstellung überall dieselbe sein soll.
  Widget _inhalt() {
    final pfad = imagePath;
    if (pfad != null && !pfad.startsWith('assets/')) {
      final datei = AttachmentHelper.fileSync(pfad);
      if (datei != null) {
        return Image.file(
          datei,
          width: width,
          height: _height,
          fit: BoxFit.cover,
          // Fehlt die Datei, steht dort das Kürzel — nie ein leeres Feld.
          errorBuilder: (context, error, stackTrace) => _kuerzel(),
        );
      }
    }
    return _kuerzel();
  }

  Widget _kuerzel() => ProfileImageWidget(
    avatarPath: imagePath,
    size: _height,
    profileName: name,
    profileColor: _backgroundColor,
    maxInitialChars: _optimalCharCount,
  );
}

/// Helper: Status-String zu Farbe konvertieren
///
/// Basierend auf MedicationLog Status:
/// - taken → Green
/// - refused → Red
/// - snoozed → Orange
/// - skipped → Grey
/// - scheduled → Blue
/// - missed → Red
Color getMedicationStatusColor(String? status) {
  if (status == null) return Colors.blue.shade600;

  final statusLower = status.toLowerCase();

  if (statusLower.contains('taken') || statusLower.contains('genommen')) {
    return Colors.green.shade600;
  } else if (statusLower.contains('refused') ||
      statusLower.contains('verweigert')) {
    return Colors.red.shade600;
  } else if (statusLower.contains('snoozed') ||
      statusLower.contains(AppTexts.current.medicationLater)) {
    return Colors.orange.shade600;
  } else if (statusLower.contains('skipped') ||
      statusLower.contains(AppTexts.current.timelineSkipped)) {
    return Colors.grey.shade600;
  } else if (statusLower.contains('missed') ||
      statusLower.contains('verpasst')) {
    return Colors.red.shade700;
  } else if (statusLower.contains('scheduled') ||
      statusLower.contains('geplant')) {
    return Colors.blue.shade600;
  }

  return Colors.blue.shade600; // Default
}
