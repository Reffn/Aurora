import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/medication/widgets/intake_times_picker.dart';
import 'package:dis_app/utils/app_spacing.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/utils/reminder_permission.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/form_action_button.dart';
import 'package:dis_app/widgets/form_scroll_view.dart';
import 'package:dis_app/widgets/permission_guard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// Formular zum Erstellen/Bearbeiten von Medikamenten
class MedicationFormScreen extends StatefulWidget {
  const MedicationFormScreen({
    super.key,
    this.existingMedication,
  });
  final Medication? existingMedication;

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  late final DataEntry _dataEntry;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _dosageFocusNode = FocusNode();

  final _imagePicker = ImagePicker();

  List<String> _timesOfDay = [];
  MedicationType _medicationType = MedicationType.daily;
  bool _isActive = true;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _imagePath;
  int? _maxDailyDoses;
  int? _minIntervalHours;
  bool _remindersEnabled = true;

  bool get _isEditing => widget.existingMedication != null;

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();

    if (_isEditing) {
      // Bearbeiten: Bestehende Werte laden
      final med = widget.existingMedication!;
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
      _notesController.text = med.notes ?? '';
      _descriptionController.text = med.description ?? '';
      _timesOfDay = List.from(med.timesOfDay);
      _medicationType = med.type;
      _isActive = med.isActive;
      _startDate = med.startDate;
      _endDate = med.endDate;
      _imagePath = med.imagePath;
      _maxDailyDoses = med.maxDailyDoses;
      _minIntervalHours = med.minIntervalHours;
      _remindersEnabled = med.remindersEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _dosageFocusNode.dispose();
    super.dispose();
  }

  /// Zeigt Dialog bei ungespeicherten Änderungen
  Future<bool> _showUnsavedChangesDialog() async {
    final result = await ConfirmationDialog.showUnsavedChanges(
      context: context,
    );

    if (result == ConfirmationResult.confirm) {
      // Speichern: Validation prüfen
      if (_formKey.currentState!.validate()) {
        await _saveMedication();
        return true; // Navigation erlauben
      }
      return false; // Validation fehlgeschlagen, auf Screen bleiben
    } else if (result == ConfirmationResult.discard) {
      return true; // Verwerfen, Navigation erlauben
    }

    return false; // Abbrechen oder dismissed, auf Screen bleiben
  }

  /// Prüft ob es ungespeicherte Änderungen gibt
  bool _hasUnsavedChanges() {
    // Neu-Modus: Prüfen ob irgendwas eingegeben wurde
    if (!_isEditing) {
      return _nameController.text.trim().isNotEmpty ||
          _dosageController.text.trim().isNotEmpty ||
          _notesController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _timesOfDay.isNotEmpty ||
          _imagePath != null ||
          _startDate != null ||
          _endDate != null;
    }

    // Edit-Modus: Mit Original vergleichen
    final original = widget.existingMedication!;
    return _nameController.text.trim() != original.name ||
        _dosageController.text.trim() != original.dosage ||
        _notesController.text.trim() != (original.notes ?? '') ||
        _descriptionController.text.trim() != (original.description ?? '') ||
        _medicationType != original.type ||
        _isActive != original.isActive ||
        _imagePath != original.imagePath ||
        _startDate != original.startDate ||
        _endDate != original.endDate ||
        _maxDailyDoses != original.maxDailyDoses ||
        _minIntervalHours != original.minIntervalHours ||
        _remindersEnabled != original.remindersEnabled ||
        _timesOfDay.length != original.timesOfDay.length ||
        !_timesOfDay.toSet().containsAll(original.timesOfDay) ||
        !original.timesOfDay.toSet().containsAll(_timesOfDay);
  }

  /// Bild auswählen (Kamera oder Galerie)
  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Relativer Name im Anhang-Ordner, wie überall sonst. Hier stand ein
        // absoluter Pfad neben dem Anhang-Ordner — gespeichert wurde das Bild,
        // gefunden wurde es nur von diesem Formular, das die Datei direkt
        // öffnet. Liste und Detailseite gingen über `AttachmentHelper` und
        // sahen nie etwas.
        final gespeichert = await AttachmentHelper.saveImage(
          await File(pickedFile.path).readAsBytes(),
        );

        if (!mounted) return;
        setState(() {
          _imagePath = gespeichert;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.medicationPhotoError(e.toString()))),
      );
    }
  }

  /// Bild entfernen
  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  /// Schaltet die Erinnerungen um — und fragt genau hier nach der Erlaubnis.
  Future<void> _toggleReminders(bool value) async {
    setState(() => _remindersEnabled = value);
    if (!value) return;

    final granted = await ensureReminderPermission(context);
    if (!granted && mounted) {
      setState(() => _remindersEnabled = false);
    }
  }

  /// Beschreibt in Worten, was der Erinnerungs-Schalter tatsächlich auslöst.
  ///
  /// Der Text nennt die Zeitpunkte, die der NotificationService wirklich
  /// plant. Wer hier etwas ändert, muss dort nachsehen — ein Versprechen,
  /// das die App nicht einlöst, ist schlimmer als gar keines.
  String get _reminderExplanation {
    final l10n = AppLocalizations.of(context);
    if (!_remindersEnabled) {
      return l10n.medicationRemindersOff;
    }
    if (_medicationType == MedicationType.daily) {
      return l10n.medicationRemindersDaily;
    }
    if (_minIntervalHours == null || _minIntervalHours == 0) {
      return l10n.medicationRemindersNoInterval;
    }
    return l10n.medicationRemindersAsNeeded;
  }

  /// Eine der beiden Medikamentenarten als volle, antippbare Zeile.
  Widget _typeOption({
    required MedicationType type,
    required IconData icon,
    required String title,
    required String explanation,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _medicationType == type;

    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _medicationType = type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      explanation,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            (selected
                                    ? scheme.onPrimaryContainer
                                    : scheme.onSurfaceVariant)
                                .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Das Häkchen sagt dasselbe wie die Farbe. Wer Farben nicht
              // unterscheidet, sieht trotzdem, was gewählt ist.
              if (selected)
                Icon(Icons.check_circle, color: scheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
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

  /// Setzt den Fokus auf das erste leere Pflichtfeld.
  ///
  /// `validate()` färbt das Feld rot, scrollt aber nicht dorthin. Da der
  /// Speichern-Knopf ganz unten sitzt und die Pflichtfelder ganz oben, sieht
  /// die tippende Person sonst gar keine Reaktion. Der Fokus zieht den
  /// Scrollbereich zum Feld mit.
  void _focusFirstInvalidField() {
    if (_nameController.text.trim().isEmpty) {
      _nameFocusNode.requestFocus();
    } else if (_dosageController.text.trim().isEmpty) {
      _dosageFocusNode.requestFocus();
    }
  }

  Future<void> _saveMedication() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      _focusFirstInvalidField();
      return;
    }

    // Validierung je nach Typ
    if (_medicationType == MedicationType.daily) {
      if (_timesOfDay.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.medicationTimeRequired)),
        );
        return;
      }
    } else if (_medicationType == MedicationType.asNeeded) {
      if (_maxDailyDoses == null || _maxDailyDoses! <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.medicationMaxDosesMissing)),
        );
        return;
      }
    }

    // Der Schalter steht von sich aus an. Gefragt wurde bisher nur, wer ihn
    // selbst umlegt — wer die Vorgabe stehen liess, bekam zugesagte
    // Erinnerungen, die nie geplant wurden.
    if (_remindersEnabled) {
      final granted = await ensureReminderPermission(context);
      if (!mounted) return;
      if (!granted) setState(() => _remindersEnabled = false);
    }

    // Alle Profile-IDs verwenden (alle Anteile teilen sich einen Körper)
    final allProfileIds = _dataEntry.getProfiles().map((p) => p.id).toList();

    final medication = Medication(
      id: _isEditing ? widget.existingMedication!.id : const Uuid().v4(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      timesOfDay: _timesOfDay,
      profileIds: allProfileIds,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      type: _medicationType,
      isActive: _isActive,
      startDate: _startDate,
      endDate: _endDate,
      createdAt: _isEditing
          ? widget.existingMedication!.createdAt
          : DateTime.now(),
      imagePath: _imagePath,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      maxDailyDoses: _medicationType == MedicationType.asNeeded
          ? _maxDailyDoses
          : null,
      minIntervalHours: _medicationType == MedicationType.asNeeded
          ? _minIntervalHours
          : null,
      remindersEnabled: _remindersEnabled,
    );

    try {
      if (_isEditing) {
        await _dataEntry.updateMedication(medication);
      } else {
        await _dataEntry.createMedication(medication);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
        );
      }
    }
  }

  Future<void> _deleteMedication() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: l10n.medicationDeleteTitle,
      message: l10n.medicationDeleteMessage,
    );

    if (confirmed) {
      try {
        await _dataEntry.deleteMedication(widget.existingMedication!.id);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          title: Text(
            _isEditing ? l10n.medicationEditTitle : l10n.medicationNewTitle,
          ),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteMedication,
                color: Colors.red,
              ),
          ],
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
              // Name
              AuroraTextField(
                label: l10n.medicationNameLabel,
                controller: _nameController,
                focusNode: _nameFocusNode,
                icon: Icons.medication,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.medicationNameRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Dosierung
              AuroraTextField(
                label: l10n.medicationDosageLabel,
                controller: _dosageController,
                focusNode: _dosageFocusNode,
                hint: l10n.medicationDosageHint,
                icon: Icons.science,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.medicationDosageRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Medikamenten-Typ
              //
              // Vorher stand hier ein SegmentedButton. Das Wort
              // „Bedarfsmedizin" passte nicht in sein Segment und brach mitten
              // im Wort um: „Bedarfsmediz / in". Zwei volle Zeilen lösen das
              // nicht durch kürzere Wörter, sondern durch mehr Platz — und
              // haben Raum für den Satz, der den Unterschied erklärt.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.medicationTypeQuestion,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _typeOption(
                        type: MedicationType.daily,
                        icon: Icons.schedule,
                        title: l10n.medicationTypeDailyTitle,
                        explanation: l10n.medicationTypeDailyExplanation,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _typeOption(
                        type: MedicationType.asNeeded,
                        icon: Icons.healing,
                        title: l10n.medicationTypeAsNeededTitle,
                        explanation: l10n.medicationTypeAsNeededExplanation,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Einnahmezeiten (nur bei Tagesmedizin)
              if (_medicationType == MedicationType.daily)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IntakeTimesPicker(
                      times: _timesOfDay,
                      onChanged: (times) => setState(() => _timesOfDay = times),
                    ),
                  ),
                ),

              // Bedarfsmedizin-Einstellungen
              if (_medicationType == MedicationType.asNeeded)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.medicationAsNeededSettings,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Maximale Anzahl pro Tag
                        AuroraTextField(
                          label: l10n.medicationMaxDosesLabel,
                          initialValue: _maxDailyDoses?.toString(),
                          hint: l10n.medicationMaxDosesHint,
                          icon: Icons.confirmation_number,
                          helperText: l10n.medicationMaxDosesHelper,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_medicationType == MedicationType.asNeeded) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.medicationMaxDosesRequired;
                              }
                              final num = int.tryParse(value.trim());
                              if (num == null || num <= 0) {
                                return l10n.medicationMaxDosesInvalid;
                              }
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _maxDailyDoses = int.tryParse(value.trim());
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Mindestabstand in Stunden (optional)
                        AuroraTextField(
                          label: l10n.medicationMinIntervalLabel,
                          initialValue: _minIntervalHours?.toString(),
                          hint: l10n.medicationMinIntervalHint,
                          icon: Icons.timer,
                          helperText: l10n.medicationMinIntervalHelper,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              final num = int.tryParse(value.trim());
                              if (num == null || num < 0) {
                                return l10n.medicationMinIntervalInvalid;
                              }
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _minIntervalHours = value.trim().isEmpty
                                ? null
                                : int.tryParse(value.trim());
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),

              // Erinnerungen
              //
              // Sie liefen schon immer, aber das Formular hat sie nie erwähnt.
              // Wer ein Medikament anlegte, bekam Meldungen, ohne je gefragt
              // worden zu sein — und konnte sie nicht abstellen. Beides steht
              // jetzt hier: was passiert, und der Schalter dagegen.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(
                          _remindersEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                        ),
                        title: Text(
                          l10n.medicationRemindersTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: _remindersEnabled,
                        onChanged: _toggleReminders,
                      ),
                      Text(
                        _reminderExplanation,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Zeitraum (optional)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.medicationPeriodTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectDate(true),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _startDate == null
                                    ? l10n.medicationStartDate
                                    : '${_startDate!.day}.${_startDate!.month}.${_startDate!.year}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_startDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _startDate = null),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectDate(false),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _endDate == null
                                    ? l10n.medicationEndDate
                                    : '${_endDate!.day}.${_endDate!.month}.${_endDate!.year}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_endDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _endDate = null),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Notizen
              AuroraTextField(
                label: l10n.medicationNotesLabel,
                controller: _notesController,
                hint: l10n.medicationNotesHint,
                icon: Icons.note,
                maxLines: 3,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Beschreibung (nur mit manageMedication Permission)
              PermissionGuard(
                permission: Permission.manageMedication,
                child: Column(
                  children: [
                    AuroraTextField(
                      label: l10n.medicationDescriptionLabel,
                      controller: _descriptionController,
                      hint: l10n.medicationDescriptionHint,
                      icon: Icons.description,
                      maxLines: 4,
                      maxLength: 200,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),

              // Tablettenbild (nur mit manageMedication Permission)
              PermissionGuard(
                permission: Permission.manageMedication,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.medicationPhotoTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_imagePath != null) ...[
                          // Derselbe Auflöser wie in Liste und Detailseite.
                          // Vorher öffnete das Formular die Datei direkt und
                          // war damit der einzige Ort, an dem das Foto ankam.
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Builder(
                              builder: (context) {
                                final datei = AttachmentHelper.fileSync(
                                  _imagePath!,
                                );
                                if (datei == null) {
                                  return const SizedBox(height: 200);
                                }
                                return Image.file(
                                  datei,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _removeImage,
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                label: Text(l10n.actionRemove),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: Text(l10n.medicationPhotoRetake),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            l10n.medicationPhotoHint,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Wrap statt Row: Bei großer Schrift oder längeren
                          // Beschriftungen rutscht der zweite Knopf in die
                          // nächste Zeile, statt rechts überzulaufen.
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.sm,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: Text(l10n.medicationPhotoTake),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: Text(l10n.commonGallery),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Aktiv-Toggle
              SwitchListTile(
                title: Text(l10n.medicationActiveTitle),
                subtitle: Text(
                  _isActive
                      ? l10n.medicationActiveOn
                      : l10n.medicationActiveOff,
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Speichern-Button
              FormActionButton(
                label: _isEditing ? l10n.actionSave : l10n.actionCreate,
                onPressed: _saveMedication,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
