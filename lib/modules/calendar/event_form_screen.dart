import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/modules/calendar/calendar_view_logic.dart';
import 'package:dis_app/modules/calendar/widgets/event_location_sheet.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/app_spacing.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/reminder_permission.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/utils/time_picker_helper.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/form_action_button.dart';
import 'package:dis_app/widgets/form_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Event-Formular zum Erstellen/Bearbeiten von Kalender-Events
class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.selectedDate, this.existingEvent});
  final DateTime? selectedDate;
  final CalendarEvent? existingEvent;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  late final DataEntry _dataEntry;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  Set<String> _selectedProfileIds = {};
  late final CalendarDraftTimes _initialDraftTimes;
  late final int _initialReminderMinutesBefore;

  /// Aurora erinnert standardmaessig an jeden Termin. Einstellbar ist nur,
  /// wie lange vorher die Meldung kommt.
  int _reminderMinutesBefore = defaultCalendarEventReminderMinutes;

  /// Wo der Termin stattfindet.
  ///
  /// Bleibt leer, wenn niemand einen Ort setzt — ein Termin ohne Ort ist
  /// erlaubt. Steht einer da, kann die Zeitkarte zeigen, wo man hin muss.
  double? _latitude;
  double? _longitude;
  String? _locationName;

  bool get _hasLocation => _latitude != null && _longitude != null;

  /// Vorlaufzeiten, die `CalendarEvent.reminderMinutesBefore` kennt.
  static const List<int> _reminderChoices = [15, 30, 60, 1440];

  bool get _isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();

    if (_isEditing) {
      // Bearbeiten: Bestehende Werte laden
      final event = widget.existingEvent!;
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _categoryController.text = event.category ?? '';
      _startDate = event.startTime;
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endDate = event.endTime;
      _endTime = TimeOfDay.fromDateTime(event.endTime);
      _selectedProfileIds = Set.from(event.profileIds);
      _reminderMinutesBefore =
          event.reminderMinutesBefore ?? defaultCalendarEventReminderMinutes;
      _latitude = event.latitude;
      _longitude = event.longitude;
      _locationName = event.locationName;
    } else {
      // Neu: Standardwerte
      final clockNow = DateTime.now();
      final selectedDay = widget.selectedDate;
      final reference =
          selectedDay == null || DateUtils.isSameDay(selectedDay, clockNow)
          ? clockNow
          : DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 9);
      final draft = initialCalendarDraftTimes(reference);
      _startDate = draft.start;
      _startTime = TimeOfDay.fromDateTime(draft.start);
      _endDate = draft.end;
      _endTime = TimeOfDay.fromDateTime(draft.end);

      // Die Profil-ID bleibt intern als Ersteller-Zuordnung erhalten. Der
      // Termin selbst gehoert zum gemeinsamen Koerperkalender.
      final activeProfile = _dataEntry.getActiveProfile();
      if (activeProfile != null) {
        _selectedProfileIds = {activeProfile.id};
      }
    }

    _initialDraftTimes = _draftTimes;
    _initialReminderMinutesBefore = _reminderMinutesBefore;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  /// Zeigt Dialog bei ungespeicherten Änderungen
  Future<bool> _showUnsavedChangesDialog() async {
    final result = await ConfirmationDialog.showUnsavedChanges(
      context: context,
    );

    if (result == ConfirmationResult.confirm) {
      return _saveEvent(popOnSuccess: false);
    } else if (result == ConfirmationResult.discard) {
      return true; // Verwerfen, Navigation erlauben
    }

    return false; // Abbrechen oder dismissed, auf Screen bleiben
  }

  /// Prüft ob es ungespeicherte Änderungen gibt
  bool _hasUnsavedChanges() {
    // Neu-Modus: Prüfen ob irgendwas eingegeben wurde
    if (!_isEditing) {
      return _titleController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _categoryController.text.trim().isNotEmpty ||
          !_sameMinute(_draftTimes.start, _initialDraftTimes.start) ||
          !_sameMinute(_draftTimes.end, _initialDraftTimes.end) ||
          _reminderMinutesBefore != _initialReminderMinutesBefore ||
          _hasLocation;
    }

    // Edit-Modus: Mit Original vergleichen
    final original = widget.existingEvent!;
    final currentStart = _combineDateAndTime(_startDate, _startTime);
    final currentEnd = _combineDateAndTime(_endDate, _endTime);

    return _titleController.text.trim() != original.title ||
        _descriptionController.text.trim() != (original.description ?? '') ||
        _categoryController.text.trim() != (original.category ?? '') ||
        !_sameMinute(currentStart, original.startTime) ||
        !_sameMinute(currentEnd, original.endTime) ||
        _reminderMinutesBefore !=
            (original.reminderMinutesBefore ??
                defaultCalendarEventReminderMinutes) ||
        _latitude != original.latitude ||
        _longitude != original.longitude ||
        _locationName != original.locationName;
  }

  /// Gleiche Minute — mehr Genauigkeit kann das Formular nicht haben.
  ///
  /// Die Uhrzeit kommt aus einem `TimeOfDay`, das keine Sekunden kennt; der
  /// gespeicherte Termin hat welche. Auf die Sekunde verglichen galt deshalb
  /// jeder Termin, der nicht zufällig zur vollen Minute anfing, schon beim
  /// bloßen Öffnen als geändert — und beim Zurückgehen stand die Frage „Willst
  /// du speichern?" über einem Schirm, an dem niemand etwas getan hatte.
  bool _sameMinute(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  CalendarDraftTimes get _draftTimes => CalendarDraftTimes(
    start: _combineDateAndTime(_startDate, _startTime),
    end: _combineDateAndTime(_endDate, _endTime),
  );

  void _applyDraftTimes(CalendarDraftTimes draft) {
    _startDate = draft.start;
    _startTime = TimeOfDay.fromDateTime(draft.start);
    _endDate = draft.end;
    _endTime = TimeOfDay.fromDateTime(draft.end);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          final newStart = _combineDateAndTime(picked, _startTime);
          _applyDraftTimes(_draftTimes.moveStartTo(newStart));
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? _startTime : _endTime;
    final picked = await showCustomTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          final newStart = _combineDateAndTime(_startDate, picked);
          _applyDraftTimes(_draftTimes.moveStartTo(newStart));
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<bool> _saveEvent({bool popOnSuccess = true}) async {
    if (!_formKey.currentState!.validate()) return false;

    final l10n = AppLocalizations.of(context);
    final activeProfile = _dataEntry.getActiveProfile();
    if (_selectedProfileIds.isEmpty && activeProfile != null) {
      _selectedProfileIds = {activeProfile.id};
    }
    if (_selectedProfileIds.isEmpty) {
      showCustomSnackBar(
        context,
        message: l10n.eventSelectProfileRequired,
        type: SnackBarType.warning,
      );
      return false;
    }

    final startDateTime = _combineDateAndTime(_startDate, _startTime);
    final endDateTime = _combineDateAndTime(_endDate, _endTime);

    if (endDateTime.isBefore(startDateTime)) {
      showCustomSnackBar(
        context,
        message: l10n.eventEndTimeError,
        type: SnackBarType.warning,
      );
      return false;
    }

    await ensureReminderPermission(context);
    if (!mounted) return false;

    final event = CalendarEvent(
      id: _isEditing ? widget.existingEvent!.id : const Uuid().v4(),
      title: _titleController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      profileIds: _selectedProfileIds.toList(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      notificationEnabled: true,
      reminderMinutesBefore: _reminderMinutesBefore,
      latitude: _latitude,
      longitude: _longitude,
      locationName: _locationName,
    );

    try {
      if (_isEditing) {
        await _dataEntry.updateCalendarEvent(event);
      } else {
        await _dataEntry.createCalendarEvent(event);
      }

      if (mounted) {
        final successL10n = AppLocalizations.of(context);
        showCustomSnackBar(
          context,
          message: _isEditing
              ? successL10n.eventUpdated
              : successL10n.eventCreated,
          type: SnackBarType.success,
        );
        if (popOnSuccess) Navigator.pop(context);
        return true;
      }
      return false;
    } catch (e) {
      if (mounted) {
        final errorL10n = AppLocalizations.of(context);
        showCustomSnackBar(
          context,
          message: errorL10n.errorGeneric(e.toString()),
          type: SnackBarType.error,
        );
      }
      return false;
    }
  }

  /// Eine beschriftete Zeile aus Datum und Uhrzeit.
  ///
  /// Die Uhrzeit trägt kein Symbol mehr. Vorher teilte sie sich ihren Knopf
  /// mit einem Uhr-Icon, und für „13:00" blieb so wenig Platz, dass die Zahl
  /// mitten im Wert umbrach: „13:0" in der ersten, „0" in der zweiten Zeile.
  Widget _dateTimeRow({
    required String label,
    required String dateText,
    required String timeText,
    required VoidCallback onDate,
    required VoidCallback onTime,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final dateButton = OutlinedButton.icon(
              onPressed: onDate,
              icon: const Icon(Icons.calendar_today, size: 20),
              label: Text(
                dateText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 58),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            );
            final timeButton = OutlinedButton.icon(
              onPressed: onTime,
              icon: const Icon(Icons.schedule, size: 20),
              label: Text(
                timeText,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 58),
              ),
            );

            if (constraints.maxWidth < 420) {
              return Column(
                children: [
                  dateButton,
                  const SizedBox(height: AppSpacing.sm),
                  timeButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 3, child: dateButton),
                const SizedBox(width: AppSpacing.sm),
                Expanded(flex: 2, child: timeButton),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Waehlt nur die Vorlaufzeit; die Erinnerung selbst gehoert zum Termin.
  Future<void> _chooseReminderTime() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Text(
                  l10n.eventRemindMe,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              for (final minutes in _reminderChoices)
                ListTile(
                  minTileHeight: 64,
                  leading: Icon(
                    minutes == _reminderMinutesBefore
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  title: Text(_reminderLabel(l10n, minutes)),
                  onTap: () => Navigator.pop(sheetContext, minutes),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _reminderMinutesBefore = picked);
    }
  }

  /// Wo der Termin stattfindet.
  ///
  /// Eine Zeile, kein Kartenausschnitt im Formular: Die Wahl passiert auf
  /// einer eigenen Fläche, hier steht nur das Ergebnis. Wer einen Ort
  /// gesetzt hat, sieht seinen Namen; wer keinen hat, sieht die Einladung.
  ///
  /// Ein Ort ohne Namen — auf der Karte gesetzt, Geokodierung fehlgeschlagen
  /// — bekommt eine Ersatzbeschriftung. „50.9, 13.6" wäre keine.
  Widget _locationCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = _hasLocation
        ? (_locationName ?? l10n.eventLocationUnnamed)
        : l10n.eventLocationNone;

    return Card(
      child: ListTile(
        leading: Icon(
          _hasLocation ? Icons.place : Icons.location_off,
          color: _hasLocation
              ? AppColors.paper
              : Colors.white.withValues(alpha: 0.4),
        ),
        title: Text(l10n.eventLocationLabel),
        subtitle: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final choice = await EventLocationSheet.show(context);
          // `null` heißt abgebrochen — dann bleibt, was war.
          if (choice == null) return;
          setState(() {
            _latitude = choice.latitude;
            _longitude = choice.longitude;
            _locationName = choice.name;
          });
        },
      ),
    );
  }

  Widget _reminderCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.eventRemindMe,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _chooseReminderTime,
              icon: const Icon(Icons.schedule),
              label: Text(_reminderLabel(l10n, _reminderMinutesBefore)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.eventReminderNotice(
                _reminderLabel(l10n, _reminderMinutesBefore),
              ),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Die Dauer, wie sie auf dem Chip steht — in der Sprache des Anteils.
  ///
  /// Hier standen „15 Minuten", „1 Stunde", „1 Tag" fest auf Deutsch, mitten
  /// in einem sonst übersetzten Formular. Wer Aurora auf Französisch stellt,
  /// las an der einzigen Stelle Deutsch, an der es um eine Zahl geht, die
  /// stimmen muss.
  static String _reminderLabel(AppLocalizations l10n, int minutes) {
    if (minutes >= 1440) return l10n.eventReminderDay;
    if (minutes >= 60) return l10n.eventReminderHours(minutes ~/ 60);
    return l10n.eventReminderMinutes(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Kein festes Muster: „06.08.2026" heißt in einer französischen
    // Oberfläche etwas anderes als hier — dort steht der Tag zwar auch
    // vorn, aber getrennt mit Schrägstrichen, und wer die App auf Englisch
    // stellt, liest den 8. Juni. yMd bringt für jede Sprache die dort
    // übliche Reihenfolge mit.
    final dateFormat = DateFormat.yMMMMEEEEd(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return PopScope(
      canPop: false, // Immer false - wir entscheiden selbst
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Navigation schon passiert

        // Live-Check beim Back-Press (nicht beim Build!)
        if (!_hasUnsavedChanges()) {
          // Keine Änderungen → Direkt zurück
          if (context.mounted) Navigator.pop(context);
          return;
        }

        // Ungespeicherte Änderungen → Dialog zeigen
        final shouldPop = await _showUnsavedChangesDialog();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? l10n.eventEditTitle : l10n.eventNewTitle),
        ),
        body: Form(
          key: _formKey,
          child: FormScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              // Safe Area Padding für System UI und Keyboard
              bottom: 16 + context.safeBottomPaddingMinimal,
            ),
            children: [
              // Titel
              AuroraTextField(
                label: l10n.eventTitleLabel,
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.eventTitleRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Beginn und Ende
              //
              // Vorher standen hier zwei Zeilen, die genau gleich aussahen: vier
              // Knöpfe, kein Wort dazu. Welche Zeile das Ende meinte, stand
              // nirgends — man musste es aus den Zahlen erraten.
              _dateTimeRow(
                label: AppLocalizations.of(context).eventStart,
                dateText: dateFormat.format(_startDate),
                timeText: _startTime.format(context),
                onDate: () => _selectDate(context, true),
                onTime: () => _selectTime(context, true),
              ),

              const SizedBox(height: AppSpacing.md),

              _dateTimeRow(
                label: AppLocalizations.of(context).eventEnd,
                dateText: dateFormat.format(_endDate),
                timeText: _endTime.format(context),
                onDate: () => _selectDate(context, false),
                onTime: () => _selectTime(context, false),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Ort
              _locationCard(context),

              const SizedBox(height: 16),

              // Erinnerung
              _reminderCard(context),

              const SizedBox(height: AppSpacing.lg),

              // Selten gebrauchte Angaben bleiben erreichbar, stehen aber
              // nicht zwischen Titel, Zeit und Speichern.
              Card(
                child: ExpansionTile(
                  initiallyExpanded:
                      _categoryController.text.trim().isNotEmpty ||
                      _descriptionController.text.trim().isNotEmpty,
                  leading: const Icon(Icons.notes_outlined),
                  title: Text(
                    l10n.eventMoreDetails,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  children: [
                    AuroraTextField(
                      label: l10n.eventDescriptionLabel,
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AuroraTextField(
                      label: l10n.eventCategoryLabel,
                      controller: _categoryController,
                      hint: l10n.eventCategoryHint,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Speichern-Button
              FormActionButton(
                label: _isEditing ? l10n.actionSave : l10n.actionCreate,
                onPressed: () async {
                  await _saveEvent();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
