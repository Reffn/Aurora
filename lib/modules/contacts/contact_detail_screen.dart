import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/contacts/contact_form_screen.dart';
import 'package:dis_app/modules/contacts/widgets/rating_widget.dart';
import 'package:dis_app/modules/finder/widgets/map_view.dart';
import 'package:dis_app/widgets/comments/comment_section.dart';
import 'package:dis_app/widgets/contact_avatar.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact Detail Screen - Zeigt alle Details eines Kontakts an
class ContactDetailScreen extends StatefulWidget {
  const ContactDetailScreen({required this.contactId, super.key});
  final String contactId;

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  final _dataEntry = getIt<DataEntry>();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _deleteContact() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: l10n.contactDeleteTitle,
      message: l10n.contactDeleteMessage,
      actionText: l10n.actionDelete,
    );

    if (confirmed && mounted) {
      await _dataEntry.deleteContact(widget.contactId);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contact = _dataEntry.getContactById(widget.contactId);
    final activeProfile = _dataEntry.getActiveProfile();

    if (contact == null || activeProfile == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.contactTitle)),
        body: Center(child: Text(l10n.contactNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        actions: [
          if (activeProfile.hasPermission(Permission.manageContacts))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        ContactFormScreen(contactId: contact.id),
                  ),
                );
              },
            ),
          if (activeProfile.hasPermission(Permission.manageContacts))
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteContact,
            ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _dataEntry.contactRatingsBox.listenable(),
        builder: (context, ratingsBox, _) {
          final currentRating = _dataEntry.getContactRatingForProfile(
            contact.id,
            activeProfile.id,
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header mit Avatar und Rating
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      _buildAvatar(contact, currentRating),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Relation
                      if (contact.relation != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          contact.relation!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Rating (Interaktiv)
                      RatingWidget(
                        rating: currentRating,
                        size: 32,
                        interactive: true,
                        onRatingChanged: (newRating) async {
                          await _dataEntry.setContactRatingForProfile(
                            contact.id,
                            activeProfile.id,
                            newRating,
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // Rating-Info
                      Text(
                        currentRating == contact.defaultRating
                            ? l10n.contactDefaultRating
                            : l10n.contactPersonalRating,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Kontakt-Informationen
                _InfoSection(contact: contact),

                const Divider(height: 32),

                // Kommentare
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CommentSection(
                    type: CommentableType.contact,
                    parentId: contact.id,
                    permission: Permission.commentOnContacts,
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(Contact contact, int rating) {
    final borderColor = _getRatingColor(rating);

    return ContactAvatar(
      imagePath: contact.imagePath,
      name: contact.name,
      size: 120,
      borderColor: borderColor,
      borderWidth: 4,
      showShadow: false,
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

/// Info Section with contact details
class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contactInfoSection,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Kategorie
          _InfoRow(
            icon: Icons.category,
            label: l10n.commonCategory,
            value: contact.category.label,
          ),

          // Telefon
          if (contact.phone != null)
            _InfoRow(
              icon: Icons.phone,
              label: l10n.contactPhoneLabel,
              value: contact.phone!,
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: contact.phone);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),

          // Email
          if (contact.email != null)
            _InfoRow(
              icon: Icons.email,
              label: l10n.contactEmailLabel,
              value: contact.email!,
              onTap: () async {
                final uri = Uri(scheme: 'mailto', path: contact.email);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),

          // Notizen
          if (contact.notes != null) ...[
            const SizedBox(height: 16),
            Text(
              l10n.commonNotes,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                contact.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],

          // GPS-Standort Section
          if (contact.hasLocation) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.contactLocationTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            MapView(
              latitude: contact.latitude!,
              longitude: contact.longitude!,
              title: contact.name,
            ),
          ],

          // Adresse
          if (contact.address != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      contact.address!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Info Row Widget
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
