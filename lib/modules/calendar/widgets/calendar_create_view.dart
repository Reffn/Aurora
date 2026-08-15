import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/time_picker_helper.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/profile_visibility_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Calendar Create View - Event-Erstellungsformular im Tab
///
/// Eingebettetes Formular zum Erstellen neuer Calendar Events
class CalendarCreateView extends StatefulWidget {
  const CalendarCreateView({super.key});

  @override
  State<CalendarCreateView> createState() => _CalendarCreateViewState();
}

class _CalendarCreateViewState extends State<CalendarCreateView> {
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

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();

    // Standardwerte
    final now = DateTime.now();
    _startDate = now;
    _startTime = TimeOfDay(hour: now.hour, minute: 0);
    _endDate = now;
    _endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);

    // Aktives Profil automatisch hinzufügen
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile != null) {
      _selectedProfileIds = {activeProfile.id};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
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
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProfileIds.isEmpty) {
      showCustomSnackBar(
        context,
        message: l10n.eventSelectProfileRequired,
        type: SnackBarType.error,
      );
      return;
    }

    final startTime = _combineDateAndTime(_startDate, _startTime);
    final endTime = _combineDateAndTime(_endDate, _endTime);

    if (endTime.isBefore(startTime)) {
      showCustomSnackBar(
        context,
        message: l10n.eventEndTimeError,
        type: SnackBarType.error,
      );
      return;
    }

    final event = CalendarEvent(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startTime: startTime,
      endTime: endTime,
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      profileIds: _selectedProfileIds.toList(),
    );

    await _dataEntry.createCalendarEvent(event);

    if (mounted) {
      showCustomSnackBar(
        context,
        message: l10n.eventCreated,
        type: SnackBarType.success,
      );

      // Formular zurücksetzen
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _categoryController.clear();

      final now = DateTime.now();
      setState(() {
        _startDate = now;
        _startTime = TimeOfDay(hour: now.hour, minute: 0);
        _endDate = now;
        _endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titel
            AuroraTextField(
              label: l10n.eventTitleLabelRequired,
              controller: _titleController,
              hint: l10n.eventTitleHint,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.eventTitleRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Beschreibung
            AuroraTextField(
              label: l10n.commonDescription,
              controller: _descriptionController,
              hint: l10n.commonOptional,
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Kategorie
            AuroraTextField(
              label: l10n.commonCategory,
              controller: _categoryController,
              hint: l10n.eventCategoryHint,
            ),

            const SizedBox(height: 24),

            // Start-Zeit
            Text(
              l10n.commonStartTime,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormat.yMd(
                        Localizations.localeOf(context).toLanguageTag(),
                      ).format(_startDate),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectTime(context, true),
                    icon: const Icon(Icons.access_time),
                    label: Text(_startTime.format(context)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // End-Zeit
            Text(
              l10n.commonEndTime,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormat.yMd(
                        Localizations.localeOf(context).toLanguageTag(),
                      ).format(_endDate),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectTime(context, false),
                    icon: const Icon(Icons.access_time),
                    label: Text(_endTime.format(context)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Profil-Auswahl
            Text(
              l10n.commonVisibleFor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ProfileVisibilitySelector(
              selectedProfileIds: _selectedProfileIds,
              allProfiles: _dataEntry.getProfiles(),
              onChanged: (Set<String> profileIds) {
                setState(() {
                  _selectedProfileIds = profileIds;
                });
              },
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveEvent,
                icon: const Icon(Icons.save),
                label: Text(l10n.eventCreate),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
