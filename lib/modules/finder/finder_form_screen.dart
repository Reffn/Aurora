import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/modules/finder/widgets/map_picker.dart';
import 'package:dis_app/utils/app_spacing.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/form_action_button.dart';
import 'package:dis_app/widgets/form_scroll_view.dart';
import 'package:dis_app/widgets/image_picker/image_picker_bottom_sheet.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

/// FinderFormScreen - Erstellen/Bearbeiten von FinderItems
class FinderFormScreen extends StatefulWidget {
  const FinderFormScreen({
    super.key,
    this.existingItem,
    this.initialType,
  });

  final FinderItem? existingItem;
  final FinderItemType? initialType;

  @override
  State<FinderFormScreen> createState() => _FinderFormScreenState();
}

class _FinderFormScreenState extends State<FinderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _dataEntry = getIt<DataEntry>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _tagController = TextEditingController();

  FinderItemType _selectedType = FinderItemType.location;
  String? _imagePath;
  LatLng? _coordinates;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();

    // Typ initialisieren (existingItem > initialType > default)
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      _titleController.text = item.title;
      _descriptionController.text = item.description ?? '';
      _locationController.text = item.location ?? '';
      _addressController.text = item.address ?? '';
      _selectedType = item.type;
      _imagePath = item.imagePath;
      _tags = List.from(item.tags);
      if (item.latitude != null && item.longitude != null) {
        _coordinates = LatLng(item.latitude!, item.longitude!);
      }
    } else if (widget.initialType != null) {
      // Neues Item mit vorgegebenem Typ
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _tagController.dispose();
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
        await _save();
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
    if (widget.existingItem == null) {
      return _titleController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _locationController.text.trim().isNotEmpty ||
          _addressController.text.trim().isNotEmpty ||
          _tags.isNotEmpty ||
          _imagePath != null ||
          _coordinates != null;
    }

    // Edit-Modus: Mit Original vergleichen
    final original = widget.existingItem!;
    return _titleController.text.trim() != original.title ||
        _descriptionController.text.trim() != (original.description ?? '') ||
        _locationController.text.trim() != (original.location ?? '') ||
        _addressController.text.trim() != (original.address ?? '') ||
        _selectedType != original.type ||
        _imagePath != original.imagePath ||
        _coordinates?.latitude != original.latitude ||
        _coordinates?.longitude != original.longitude ||
        _tags.length != original.tags.length ||
        !_tags.toSet().containsAll(original.tags) ||
        !original.tags.toSet().containsAll(_tags);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return;

    final item = FinderItem(
      id: widget.existingItem?.id ?? 'finder_${const Uuid().v4()}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      type: _selectedType,
      location:
          _selectedType == FinderItemType.item &&
              _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      latitude: _coordinates?.latitude,
      longitude: _coordinates?.longitude,
      imagePath: _imagePath,
      tags: _tags,
      createdAt: widget.existingItem?.createdAt ?? DateTime.now(),
      createdByProfileId:
          widget.existingItem?.createdByProfileId ?? activeProfile.id,
    );

    final dataEntry = getIt<DataEntry>();
    if (widget.existingItem != null) {
      await dataEntry.updateFinderItem(item);
    } else {
      await dataEntry.createFinderItem(item);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _showMapPicker() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: MapPicker(
          initialLocation: _coordinates,
          initialTitle: _titleController.text,
          onLocationPicked: (coords) {
            setState(() => _coordinates = coords);
          },
        ),
      ),
    );

    // Ergebnis verarbeiten: Titel und Adresse aus Map übernehmen
    if (result != null && mounted) {
      setState(() {
        _coordinates = result['coordinates'] as LatLng?;
        final address = result['address'] as String?;
        final title = result['title'] as String?;

        // Adresse übernehmen (falls vorhanden)
        if (address != null && address.isNotEmpty) {
          _addressController.text = address;
        }

        // Titel übernehmen (falls vorhanden und geändert)
        if (title != null && title.isNotEmpty) {
          _titleController.text = title;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Titel basierend auf Typ
    String title;
    IconData icon;

    if (widget.existingItem != null) {
      // Edit-Modus: "Ort bearbeiten" / "Gegenstand bearbeiten"
      title = _selectedType == FinderItemType.location
          ? l10n.finderLocationEditTitle
          : l10n.finderItemEditTitle;
      icon = _selectedType == FinderItemType.location
          ? Icons.place
          : Icons.inventory_2;
    } else {
      // Create-Modus: "Neuer Ort" / "Neuer Gegenstand"
      title = _selectedType == FinderItemType.location
          ? l10n.finderLocationNewTitle
          : l10n.finderItemNewTitle;
      icon = _selectedType == FinderItemType.location
          ? Icons.place
          : Icons.inventory_2;
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: FormScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              // Titel
              AuroraTextField(
                label: '${l10n.commonTitle} *',
                controller: _titleController,
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? l10n.commonRequired : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Beschreibung
              AuroraTextField(
                label: l10n.commonDescription,
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Conditional: Ort
              if (_selectedType == FinderItemType.location) ...[
                OutlinedButton.icon(
                  onPressed: _showMapPicker,
                  icon: const Icon(Icons.map),
                  label: Text(
                    _coordinates == null
                        ? l10n.finderSetPosition
                        : l10n.finderChangePosition,
                  ),
                ),
                if (_coordinates != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'GPS: ${_coordinates!.latitude.toStringAsFixed(4)}, ${_coordinates!.longitude.toStringAsFixed(4)}',
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AuroraTextField(
                  label: l10n.finderAddressLabel,
                  controller: _addressController,
                ),
              ],

              // Conditional: Gegenstand
              if (_selectedType == FinderItemType.item) ...[
                AuroraTextField(
                  label: l10n.finderStorageLocationLabel,
                  controller: _locationController,
                  hint: l10n.finderStorageLocationHint,
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Foto
              OutlinedButton.icon(
                onPressed: () {
                  ImagePickerBottomSheet.show(
                    context,
                    title: l10n.finderChoosePhoto,
                    onImagePathSelected: (path) {
                      setState(() => _imagePath = path);
                    },
                  );
                },
                icon: const Icon(Icons.photo),
                label: Text(l10n.finderAddPhoto),
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProfileImageWidget(
                    avatarPath: _imagePath,
                    size: 100,
                    // Ein Fundstueck hat keinen Namen und keine Initialen. Das
                    // ist der eine der sieben Rueckfaelle, der berechtigt war --
                    // deshalb gibt es `placeholderIcon` ueberhaupt.
                    placeholderIcon: Icons.image,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Tags
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() => _tags.remove(tag));
                    },
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: AuroraTextField(
                      label: l10n.finderAddTag,
                      controller: _tagController,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_tagController.text.isNotEmpty) {
                        setState(() {
                          _tags.add(_tagController.text.trim());
                          _tagController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Save
              FormActionButton(
                label: widget.existingItem == null
                    ? l10n.actionCreate
                    : l10n.actionSave,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
