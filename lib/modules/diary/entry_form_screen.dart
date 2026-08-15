import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/diary_entry.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/utils/app_spacing.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/form_action_button.dart';
import 'package:dis_app/widgets/form_scroll_view.dart';
import 'package:dis_app/widgets/profile_visibility_selector.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Entry Form Screen - Erstellen und Bearbeiten von Notfall-Tagebuch Einträgen
class EntryFormScreen extends StatefulWidget {
  // Null = Neuer Eintrag

  const EntryFormScreen({super.key, this.entry});
  final DiaryEntry? entry;

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final DataEntry _dataEntry;

  EntryPriority _selectedPriority = EntryPriority.medium;
  List<String> _imagePaths = [];
  Set<String> _selectedProfileIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();
    final activeProfile = _dataEntry.getActiveProfile();

    if (widget.entry != null) {
      // Bearbeitungsmodus: Felder vorausfüllen
      _titleController.text = widget.entry!.title;
      _descriptionController.text = widget.entry!.description;
      _selectedPriority = widget.entry!.priority;
      _imagePaths = List.from(widget.entry!.imagePaths ?? []);
      _selectedProfileIds = Set.from(widget.entry!.visibleTo ?? []);
    } else {
      // Neuer Eintrag: Autor automatisch als sichtbar markieren
      if (activeProfile != null) {
        _selectedProfileIds = {activeProfile.id};
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
        await _saveEntry();
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
    if (widget.entry == null) {
      return _titleController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _imagePaths.isNotEmpty;
    }

    // Edit-Modus: Mit Original vergleichen
    final original = widget.entry!;
    return _titleController.text.trim() != original.title ||
        _descriptionController.text.trim() != original.description ||
        _selectedPriority != original.priority ||
        _imagePaths.length != (original.imagePaths?.length ?? 0) ||
        !_selectedProfileIds.containsAll(original.visibleTo ?? []) ||
        !(original.visibleTo ?? <String>[]).toSet().containsAll(
          _selectedProfileIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditMode = widget.entry != null;
    final activeProfile = _dataEntry.getActiveProfile();

    // Permission-Check
    if (activeProfile == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.commonError)),
        body: Center(child: Text(l10n.profileNotSelected)),
      );
    }

    if (isEditMode) {
      // Prüfen ob Berechtigung zum Bearbeiten besteht
      final canEdit =
          activeProfile.isAdmin ||
          activeProfile.hasPermission(Permission.editAllDiaryEntries) ||
          (activeProfile.hasPermission(Permission.editOwnDiaryEntries) &&
              widget.entry!.authorProfileId == activeProfile.id);

      if (!canEdit) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.commonNoPermission)),
          body: Center(child: Text(l10n.diaryCannotEditEntry)),
        );
      }
    } else {
      // Prüfen ob Berechtigung zum Erstellen besteht
      if (!activeProfile.isAdmin &&
          !activeProfile.hasPermission(Permission.createDiaryEntry)) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.commonNoPermission)),
          body: Center(child: Text(l10n.diaryCannotCreateEntry)),
        );
      }
    }

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
            isEditMode ? l10n.diaryEntryEditTitle : l10n.diaryEntryNewTitle,
          ),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.15),
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
                label: l10n.commonTitle,
                controller: _titleController,
                hint: l10n.diaryTitleHint,
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.diaryTitleRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Beschreibung
              AuroraTextField(
                label: l10n.commonDescription,
                controller: _descriptionController,
                hint: l10n.diaryDescriptionHint,
                maxLines: 8,
                maxLength: 2000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.diaryDescriptionRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Priorität
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.diaryPriorityLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PrioritySelector(
                        selectedPriority: _selectedPriority,
                        onChanged: (priority) {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Sichtbarkeit
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ProfileVisibilitySelector(
                    selectedProfileIds: _selectedProfileIds,
                    onChanged: (newSelection) {
                      setState(() {
                        _selectedProfileIds = newSelection;
                      });
                    },
                    allProfiles: _dataEntry.getProfiles(),
                    label: l10n.commonVisibleFor,
                    disabledProfileIds: {
                      activeProfile.id,
                    }, // Autor kann sich nicht abwählen
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Bilder
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.diaryImagesLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addImage,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: Text(l10n.actionAdd),
                          ),
                        ],
                      ),
                      if (_imagePaths.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _ImagePreviewGrid(
                          imagePaths: _imagePaths,
                          onRemove: (index) {
                            setState(() {
                              _imagePaths.removeAt(index);
                            });
                          },
                        ),
                      ] else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            l10n.diaryNoImagesYet,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Speichern-Button
              FormActionButton(
                label: isEditMode ? l10n.actionSave : l10n.actionCreate,
                loading: _isLoading,
                onPressed: _saveEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImage() async {
    // TODO: Implement image picker
    final l10n = AppLocalizations.of(context);
    showCustomSnackBar(
      context,
      message: l10n.diaryImagePickerComingSoon,
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final activeProfile = _dataEntry.getActiveProfile();
      if (activeProfile == null) throw Exception('No active profile');

      final now = DateTime.now();
      final isEditMode = widget.entry != null;

      // Die Berechtigung wird beim Aufbau des Bildschirms geprüft (siehe build):
      // Ohne sie erscheint hier kein Formular, sondern der Hinweis. Eine zweite
      // Prüfung an dieser Stelle wäre nicht nur überflüssig, sie wäre auch
      // laxer — oben muss für „eigene Einträge bearbeiten" zusätzlich der
      // Eintrag einem selbst gehören.

      // Sicherstellen dass Autor immer in visibleTo enthalten ist
      final visibilityList = _selectedProfileIds.toList();
      final authorId = isEditMode
          ? widget.entry!.authorProfileId
          : activeProfile.id;
      if (!visibilityList.contains(authorId)) {
        visibilityList.add(authorId);
      }

      if (isEditMode) {
        // Eintrag bearbeiten
        final updatedEntry = DiaryEntry(
          id: widget.entry!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          timestamp: widget.entry!.timestamp,
          authorProfileId: widget.entry!.authorProfileId,
          imagePaths: _imagePaths.isEmpty ? null : _imagePaths,
          priority: _selectedPriority,
          editedAt: now,
          visibleTo: visibilityList.isEmpty ? null : visibilityList,
        );

        await _dataEntry.updateDiaryEntry(updatedEntry);

        if (mounted) {
          final l10n = AppLocalizations.of(context);
          showCustomSnackBar(
            context,
            message: l10n.diaryEntryUpdated,
            type: SnackBarType.success,
          );
          Navigator.pop(context);
        }
      } else {
        // Neuen Eintrag erstellen
        final newEntry = DiaryEntry(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          timestamp: now,
          authorProfileId: activeProfile.id,
          imagePaths: _imagePaths.isEmpty ? null : _imagePaths,
          priority: _selectedPriority,
          visibleTo: visibilityList.isEmpty ? null : visibilityList,
        );

        await _dataEntry.createDiaryEntry(newEntry);

        if (mounted) {
          final l10n = AppLocalizations.of(context);
          showCustomSnackBar(
            context,
            message: l10n.diaryEntryCreated,
            type: SnackBarType.success,
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showCustomSnackBar(
          context,
          message: l10n.commonSaveError(e.toString()),
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Priority Selector Widget
class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.selectedPriority,
    required this.onChanged,
  });
  final EntryPriority selectedPriority;
  final ValueChanged<EntryPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: EntryPriority.values.map((priority) {
        final isSelected = priority == selectedPriority;
        final color = _getPriorityColor(priority);

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPriorityIcon(priority),
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(priority.label),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(priority),
          selectedColor: color,
          backgroundColor: color.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(color: color),
        );
      }).toList(),
    );
  }

  Color _getPriorityColor(EntryPriority priority) {
    switch (priority) {
      case EntryPriority.low:
        return Colors.green;
      case EntryPriority.medium:
        return Colors.orange;
      case EntryPriority.high:
        return Colors.red;
      case EntryPriority.critical:
        return Colors.red.shade900;
    }
  }

  IconData _getPriorityIcon(EntryPriority priority) {
    switch (priority) {
      case EntryPriority.low:
        return Icons.arrow_downward;
      case EntryPriority.medium:
        return Icons.remove;
      case EntryPriority.high:
        return Icons.arrow_upward;
      case EntryPriority.critical:
        return Icons.warning;
    }
  }
}

/// Image Preview Grid Widget
class _ImagePreviewGrid extends StatelessWidget {
  const _ImagePreviewGrid({
    required this.imagePaths,
    required this.onRemove,
  });
  final List<String> imagePaths;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 32),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
