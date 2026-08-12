import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/modules/contacts/widgets/rating_widget.dart';
import 'package:dis_app/modules/finder/widgets/map_picker.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/app_spacing.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/form_action_button.dart';
import 'package:dis_app/widgets/form_avatar_picker.dart';
import 'package:dis_app/widgets/form_scroll_view.dart';
import 'package:dis_app/widgets/image_picker/image_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Contact Form Screen - Erstellen/Bearbeiten von Kontakten
class ContactFormScreen extends StatefulWidget {
  const ContactFormScreen({super.key, this.contactId});
  final String? contactId;

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataEntry = getIt<DataEntry>();

  late final TextEditingController _nameController;
  late final TextEditingController _relationController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;
  late final TextEditingController _addressController;

  ContactCategory _selectedCategory = ContactCategory.other;
  int _defaultRating = 3;
  String? _selectedAvatarPath;
  LatLng? _coordinates;
  Contact? _existingContact;
  bool _isEmergencyContact = false;

  @override
  void initState() {
    super.initState();

    // Edit-Modus: Existierenden Kontakt laden
    if (widget.contactId != null) {
      _existingContact = _dataEntry.getContactById(widget.contactId!);
      if (_existingContact != null) {
        _selectedCategory = _existingContact!.category;
        _defaultRating = _existingContact!.defaultRating;
        _selectedAvatarPath = _existingContact!.imagePath;
        _isEmergencyContact = _existingContact!.isEmergencyContact;

        // GPS-Daten laden
        if (_existingContact!.hasLocation) {
          _coordinates = LatLng(
            _existingContact!.latitude!,
            _existingContact!.longitude!,
          );
        }
      }
    }

    _nameController = TextEditingController(text: _existingContact?.name ?? '');
    _relationController = TextEditingController(
      text: _existingContact?.relation ?? '',
    );
    _phoneController = TextEditingController(
      text: _existingContact?.phone ?? '',
    );
    _emailController = TextEditingController(
      text: _existingContact?.email ?? '',
    );
    _notesController = TextEditingController(
      text: _existingContact?.notes ?? '',
    );
    _addressController = TextEditingController(
      text: _existingContact?.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _addressController.dispose();
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
        await _saveContact();
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
    if (_existingContact == null) {
      return _nameController.text.trim().isNotEmpty ||
          _relationController.text.trim().isNotEmpty ||
          _phoneController.text.trim().isNotEmpty ||
          _emailController.text.trim().isNotEmpty ||
          _notesController.text.trim().isNotEmpty ||
          _addressController.text.trim().isNotEmpty ||
          _selectedAvatarPath != null ||
          _coordinates != null ||
          _isEmergencyContact != false ||
          _selectedCategory != ContactCategory.other ||
          _defaultRating != 3;
    }

    // Edit-Modus: Mit Original vergleichen
    final original = _existingContact!;
    return _nameController.text.trim() != original.name ||
        _relationController.text.trim() != (original.relation ?? '') ||
        _phoneController.text.trim() != (original.phone ?? '') ||
        _emailController.text.trim() != (original.email ?? '') ||
        _notesController.text.trim() != (original.notes ?? '') ||
        _addressController.text.trim() != (original.address ?? '') ||
        _selectedCategory != original.category ||
        _defaultRating != original.defaultRating ||
        _selectedAvatarPath != original.imagePath ||
        _isEmergencyContact != original.isEmergencyContact ||
        _coordinates?.latitude != original.latitude ||
        _coordinates?.longitude != original.longitude;
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return;

    final contact = Contact(
      id:
          _existingContact?.id ??
          'contact_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      relation: _relationController.text.trim().isNotEmpty
          ? _relationController.text.trim()
          : null,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      imagePath: _selectedAvatarPath,
      category: _selectedCategory,
      createdByProfileId:
          _existingContact?.createdByProfileId ?? activeProfile.id,
      createdAt: _existingContact?.createdAt ?? DateTime.now(),
      defaultRating: _defaultRating,
      latitude: _coordinates?.latitude,
      longitude: _coordinates?.longitude,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      isEmergencyContact: _isEmergencyContact,
    );

    if (_existingContact != null) {
      await _dataEntry.updateContact(contact);
    } else {
      await _dataEntry.createContact(contact);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _showMapPicker() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: MapPicker(
          initialLocation: _coordinates,
          initialTitle: _nameController.text, // Kontaktname als Titel
          usageContext: MapPickerUsageContext.contact,
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

        // Titel als Name übernehmen (falls geändert)
        if (title != null &&
            title.isNotEmpty &&
            title != _nameController.text) {
          _nameController.text = title;
        }

        // Adresse übernehmen (falls vorhanden)
        if (address != null && address.isNotEmpty) {
          _addressController.text = address;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditMode = _existingContact != null;

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
            isEditMode ? l10n.contactEditTitle : l10n.contactNewTitle,
          ),
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
              // Avatar + Name Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  FormAvatarPicker(
                    avatarPath: _selectedAvatarPath,
                    fallbackText: _nameController.text,
                    onTap: () {
                      ImagePickerBottomSheet.show(
                        context,
                        title: l10n.contactImagePickerTitle,
                        onImagePathSelected: (path) {
                          setState(() {
                            _selectedAvatarPath = path;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // Name (Pflichtfeld)
                  Expanded(
                    child: AuroraTextField(
                      label: l10n.contactNameLabel,
                      controller: _nameController,
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.contactNameRequired;
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) =>
                          setState(() {}), // Update avatar initials
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Beziehung (Optional)
              AuroraTextField(
                label: l10n.contactRelationLabel,
                controller: _relationController,
                hint: l10n.contactRelationHint,
                icon: Icons.diversity_3,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Kategorie
              AuroraFeldRahmen(
                label: l10n.commonCategory,
                child: DropdownButtonFormField<ContactCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ContactCategory.values
                      .where(
                        (category) => category != ContactCategory.emergency,
                      )
                      .map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.label),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Notfallkontakt Checkbox
              Container(
                decoration: BoxDecoration(
                  color: AppColors.go.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.go.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: CheckboxListTile(
                  value: _isEmergencyContact,
                  onChanged: (value) {
                    setState(() {
                      _isEmergencyContact = value ?? false;
                    });
                  },
                  activeColor: AppColors.go,
                  title: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: AppColors.go,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.contactMarkAsEmergency,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l10n.contactEmergencyDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Telefon (Optional)
              AuroraTextField(
                label: l10n.contactPhoneLabel,
                controller: _phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: AppSpacing.lg),

              // E-Mail (Optional)
              AuroraTextField(
                label: l10n.contactEmailLabel,
                controller: _emailController,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Notizen (Optional)
              AuroraTextField(
                label: l10n.commonNotes,
                controller: _notesController,
                icon: Icons.notes,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Standard-Bewertung
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.contactDefaultRating,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.contactDefaultRatingDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: RatingWidget(
                        rating: _defaultRating,
                        size: 40,
                        showNumber: true,
                        interactive: true,
                        onRatingChanged: (rating) {
                          setState(() {
                            _defaultRating = rating;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Text(
                        _getRatingLabel(_defaultRating),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getRatingColor(_defaultRating),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // GPS-Standort Section
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.contactLocationSection,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                l10n.contactLocationDescription,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _showMapPicker,
                icon: const Icon(Icons.map),
                label: Text(
                  _coordinates == null
                      ? l10n.contactLocationSet
                      : l10n.contactLocationChange,
                ),
              ),
              if (_coordinates != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'GPS: ${_coordinates!.latitude.toStringAsFixed(4)}, ${_coordinates!.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AuroraTextField(
                label: l10n.contactAddressLabel,
                controller: _addressController,
                hint: l10n.contactAddressHint,
                icon: Icons.location_on,
                readOnly: true,
                maxLines: 2,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Hinweis
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.contactVisibleToAll,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Speichern-Button
              FormActionButton(
                label: isEditMode ? l10n.actionSave : l10n.actionCreate,
                onPressed: _saveContact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return AppTexts.current.ratingVeryNegative;
      case 2:
        return 'Negativ';
      case 3:
        return 'Neutral';
      case 4:
        return 'Positiv';
      case 5:
        return AppTexts.current.ratingVeryPositive;
      default:
        return 'Neutral';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return AppColors.ratingNegative;
      case 3:
        return AppColors.ratingNeutral;
      case 4:
      case 5:
        return AppColors.ratingPositive;
      default:
        return AppColors.faint;
    }
  }
}
