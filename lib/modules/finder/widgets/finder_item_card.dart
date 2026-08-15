import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/utils/location_helper.dart';
import 'package:dis_app/utils/short_place.dart';
import 'package:dis_app/widgets/location_avatar.dart';
import 'package:flutter/material.dart';

/// FinderItemCard - Zeigt ein FinderItem in der Liste
class FinderItemCard extends StatelessWidget {
  const FinderItemCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final FinderItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail (Foto oder Icon)
              _buildThumbnail(context),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titel
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Beschreibung
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],

                    // Location (für Gegenstände) oder GPS (für Orte)
                    if (item.type == FinderItemType.item &&
                        item.location != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (item.type == FinderItemType.location &&
                        item.latitude != null &&
                        item.longitude != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              // Die Anschrift, wenn es eine gibt. Hier stand
                              // „51.1344° N, 13.5812° E" — richtig, aber
                              // niemand erkennt daran einen Ort wieder. Die
                              // Adresse liegt am Eintrag, sie wurde nur nie
                              // gezeigt. Koordinaten bleiben der Rückfall für
                              // Punkte, zu denen keine Adresse gefunden wurde.
                              shortPlace(item.address) ??
                                  LocationHelper.formatCoordinates(
                                    item.latitude!,
                                    item.longitude!,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Tags
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getTagColor(
                                tag,
                                context,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getTagColor(tag, context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    // LocationAvatar (quadratisch) - zeigt Foto oder Rainbow-Initialen
    return LocationAvatar(
      imagePath: item.imagePath,
      title: item.title,
      size: 60,
      borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      borderWidth: 1,
      contentBorderRadius: 7,
      showShadow: false,
    );
  }

  Color _getTagColor(String tag, BuildContext context) {
    switch (tag.toLowerCase()) {
      case 'wichtig':
        return Colors.red;
      case 'notfall':
        return Colors.orange;
      // Gespeicherter Tag-Wert, kein Text fuer Menschen -- bleibt fest.
      case 'täglich':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
