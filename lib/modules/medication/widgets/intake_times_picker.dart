import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_spacing.dart';
import 'package:dis_app/utils/time_picker_helper.dart';
import 'package:flutter/material.dart';

/// Ein Abschnitt des Tages und die Uhrzeit, die Aurora dafür vorschlägt.
///
/// Die Fenster decken die vollen 24 Stunden ab und überlappen nicht. Dadurch
/// lässt sich jede gespeicherte Uhrzeit genau einem Abschnitt zuordnen, und
/// das Medikament braucht kein zusätzliches Feld: Die Liste der Uhrzeiten
/// bleibt die einzige Wahrheit. Wer eine Zeit von Hand ändert, sieht sie
/// weiterhin in ihrem Abschnitt stehen.
/// Die vier Symbole müssen sich unterscheiden lassen, ohne dass jemand die
/// Wörter darunter liest. Abends und Nachts trugen zuerst beide einen Mond —
/// nebeneinander sahen sie gleich aus. Das Bett sagt „Nachts", auch für den,
/// der gerade nicht lesen kann.
enum DaySection {
  morning(Icons.wb_twilight, 5, 11, '08:00'),
  midday(Icons.wb_sunny_outlined, 11, 16, '12:00'),
  evening(Icons.nights_stay_outlined, 16, 22, '18:00'),
  night(Icons.bed_outlined, 22, 5, '22:00');

  const DaySection(
    this.icon,
    this.fromHour,
    this.toHour,
    this.defaultTime,
  );

  /// Der Name des Abschnitts in der Sprache der Nutzerin.
  ///
  /// Steht bewusst nicht als Feld im Enum: Ein Enum wird einmal gebaut, die
  /// Sprache kann sich danach noch ändern.
  String label(AppLocalizations l10n) {
    switch (this) {
      case DaySection.morning:
        return l10n.medicationSectionMorning;
      case DaySection.midday:
        return l10n.medicationSectionMidday;
      case DaySection.evening:
        return l10n.medicationSectionEvening;
      case DaySection.night:
        return l10n.medicationSectionNight;
    }
  }

  final IconData icon;

  /// Erste Stunde des Fensters, einschließlich.
  final int fromHour;

  /// Erste Stunde nach dem Fenster, ausschließlich.
  final int toHour;

  /// Uhrzeit, die ein Tipp auf den Abschnitt setzt.
  final String defaultTime;

  /// Liegt diese Uhrzeit (Format `HH:mm`) in diesem Abschnitt?
  bool contains(String time) {
    final hour = int.tryParse(time.split(':').first);
    if (hour == null) return false;

    // Nachts läuft über Mitternacht: 22, 23, 0, 1, 2, 3, 4.
    if (fromHour < toHour) return hour >= fromHour && hour < toHour;
    return hour >= fromHour || hour < toHour;
  }
}

/// Auswahl der Einnahmezeiten über Tagesabschnitte.
///
/// Vorher stand hier ein kleines Pluszeichen und der Satz „Keine Zeiten
/// hinzugefügt". Wer ein Medikament eintrug, musste sich jede Uhrzeit selbst
/// ausdenken und über eine Uhr eingeben. Jetzt trägt ein Tipp auf „Morgens"
/// eine sinnvolle Zeit ein, die danach noch geändert werden kann.
class IntakeTimesPicker extends StatelessWidget {
  const IntakeTimesPicker({
    super.key,
    required this.times,
    required this.onChanged,
  });

  /// Die gespeicherten Uhrzeiten im Format `HH:mm`, aufsteigend sortiert.
  final List<String> times;

  final ValueChanged<List<String>> onChanged;

  List<String> _timesIn(DaySection section) =>
      times.where(section.contains).toList();

  void _emit(List<String> next) {
    final sorted = next.toSet().toList()..sort();
    onChanged(sorted);
  }

  void _toggle(DaySection section) {
    final inSection = _timesIn(section);
    if (inSection.isEmpty) {
      _emit([...times, section.defaultTime]);
    } else {
      _emit(times.where((t) => !section.contains(t)).toList());
    }
  }

  Future<void> _changeTime(BuildContext context, DaySection section) async {
    final current = _timesIn(section).first;
    final picked = await showCustomTimePicker(
      context: context,
      initialTime: _parse(current),
    );
    if (picked == null) return;

    final next = times.toList()..remove(current);
    _emit([...next, _format(picked)]);
  }

  Future<void> _addOwnTime(BuildContext context) async {
    final picked = await showCustomTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    _emit([...times, _format(picked)]);
  }

  static TimeOfDay _parse(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  static String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicationWhenToTake,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _row(context, DaySection.morning, DaySection.midday),
        const SizedBox(height: AppSpacing.md),
        _row(context, DaySection.evening, DaySection.night),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _addOwnTime(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.medicationOtherTime),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, DaySection left, DaySection right) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _tile(context, left)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _tile(context, right)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, DaySection section) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final inSection = _timesIn(section);
    final selected = inSection.isNotEmpty;

    // Ausgewählt trägt Fläche, nicht ausgewählt nur einen Rand. Die Farbe
    // allein entscheidet nicht: Das Häkchen sagt dasselbe noch einmal, für
    // alle, die Farben nicht unterscheiden oder gerade nicht darauf achten.
    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _toggle(section),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Semantics(
                button: true,
                selected: selected,
                label:
                    '${section.label(l10n)}, '
                    '${selected ? inSection.join(", ") : l10n.medicationSectionNotChosen}',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            section.icon,
                            size: 28,
                            color: selected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                          if (selected) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: scheme.onPrimaryContainer,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        section.label(l10n),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (selected)
              // Eigene Fläche, eigene Handlung: Die obere Hälfte schaltet den
              // Abschnitt ab, diese Zeile ändert nur die Uhrzeit. Beide sind
              // groß genug für unsichere Hände.
              InkWell(
                onTap: () => _changeTime(context, section),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: scheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          inSection.join(' · '),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  section.defaultTime,
                  style: TextStyle(
                    fontSize: 15,
                    // Nicht zu blass: Die Uhrzeit zeigt, was ein Tipp
                    // eintragen würde, und muss dafür lesbar bleiben.
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
