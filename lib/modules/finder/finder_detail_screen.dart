import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/finder/finder_form_screen.dart';
import 'package:dis_app/modules/finder/widgets/map_view.dart';
import 'package:dis_app/widgets/comments/comment_section.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/location_avatar.dart';
import 'package:flutter/material.dart';

/// FinderDetailScreen - Detailansicht eines FinderItems
class FinderDetailScreen extends StatelessWidget {
  const FinderDetailScreen({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataEntry = getIt<DataEntry>();
    final item = dataEntry.getFinderItemById(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.finderNotFound)),
        body: Center(child: Text(l10n.finderNotFoundMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => FinderFormScreen(existingItem: item),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Hol Navigator vor dem await
              final nav = Navigator.of(context);
              final confirm = await ConfirmationDialog.showDestructive(
                context: context,
                title: l10n.finderDeleteTitle,
                message: l10n.finderDeleteMessage(item.title),
                actionText: l10n.actionDelete,
              );

              if (confirm && context.mounted) {
                await dataEntry.deleteFinderItem(item.id);
                nav.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Foto
          // Foto (quadratisch, LocationAvatar)
          LocationAvatar(
            imagePath: item.imagePath,
            title: item.title,
            size: 200,
            borderRadius: 12,
            contentBorderRadius: 10,
            showShadow: true,
          ),
          const SizedBox(height: 16),

          // Beschreibung
          if (item.description != null) ...[
            Text(
              item.description!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
          ],

          // Karte (nur für Orte mit GPS)
          if (item.latitude != null && item.longitude != null) ...[
            MapView(
              latitude: item.latitude!,
              longitude: item.longitude!,
              title: item.title,
            ),
            const SizedBox(height: 16),
          ],

          // Adresse
          if (item.address != null) ...[
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(l10n.finderAddressLabel),
              subtitle: Text(item.address!),
            ),
          ],

          // Location (für Gegenstände)
          if (item.location != null) ...[
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(l10n.finderStorageLocationLabel),
              subtitle: Text(item.location!),
            ),
          ],

          // Tags
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: item.tags.map((String tag) {
                return Chip(label: Text(tag));
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Kommentare
          CommentSection(
            type: CommentableType.finder,
            parentId: item.id,
            permission: Permission.commentOnFinderEntries,
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
