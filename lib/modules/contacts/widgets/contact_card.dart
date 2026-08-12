import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/modules/contacts/widgets/rating_widget.dart';
import 'package:dis_app/modules/emergency/emergency_screen.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/utils/short_place.dart';
import 'package:dis_app/widgets/contact_avatar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';

/// Contact Card Widget - Zeigt einen Kontakt in der Liste an
class ContactCard extends StatelessWidget {
  const ContactCard({
    required this.contact,
    required this.onTap,
    super.key,
  });
  final Contact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dataEntry = getIt<DataEntry>();
    final activeProfile = dataEntry.getActiveProfile();

    if (activeProfile == null) {
      return const SizedBox.shrink();
    }

    // Rating für aktuelles Profil abrufen
    final rating = dataEntry.getContactRatingForProfile(
      contact.id,
      activeProfile.id,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Prominent Image
              _ContactAvatar(
                imagePath: contact.imagePath,
                name: contact.name,
                rating: rating,
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Relation
                    if (contact.relation != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        contact.relation!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],

                    // Latest Comment (reaktiv)
                    ValueListenableBuilder(
                      valueListenable: dataEntry.contactCommentsBox
                          .listenable(),
                      builder: (context, box, _) {
                        final comments = dataEntry.getContactComments(
                          contact.id,
                        );
                        if (comments.isEmpty) return const SizedBox.shrink();

                        // Letzter Kommentar (neuester = letzter in sortierter Liste)
                        final latestComment = comments.last;
                        final profile = dataEntry.getProfiles().firstWhere(
                          (p) => p.id == latestComment.profileId,
                          orElse: () => dataEntry.getProfiles().first,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.comment,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${profile.name}:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          latestComment.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Kategorie + Rating
                    Row(
                      children: [
                        // Kategorie-Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            contact.category.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Rating
                        RatingWidget(rating: rating, size: 16),
                      ],
                    ),

                    // Location Info (Adresse + Entfernung)
                    _LocationInfo(contact: contact),

                    // Emergency Badge
                    _EmergencyBadge(contact: contact),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Comment Count (reaktiv)
              ValueListenableBuilder(
                valueListenable: dataEntry.contactCommentsBox.listenable(),
                builder: (context, box, _) {
                  final commentCount = dataEntry.getContactCommentCount(
                    contact.id,
                  );

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$commentCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper: Berechnet Luftlinien-Distanz zwischen User und Kontakt
String? _calculateDistance(
  Contact contact,
  LatLng? userPosition,
  GpsManager gpsManager,
) {
  if (contact.latitude == null ||
      contact.longitude == null ||
      userPosition == null) {
    return null;
  }

  final contactPosition = LatLng(contact.latitude!, contact.longitude!);
  final distance = gpsManager.calculateDistance(userPosition, contactPosition);

  // Formatierung via GPS Manager. Das Wort dahinter kommt aus der Sprache
  // des Anteils — es stand hier fest auf Deutsch und ergab in einer
  // französischen Oberfläche „1.3 km entfernt".
  return AppTexts.current.contactDistanceAway(
    gpsManager.formatDistance(distance),
  );
}

/// Helper: Grünes Distanz-Badge (wie Emergency-Badge)
Widget _buildDistanceBadge({required String distance, String? address}) {
  return Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.green.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Colors.green,
        width: 1.5,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.straighten,
          size: 14,
          color: Colors.green,
        ),
        const SizedBox(width: 6),
        Text(
          distance,
          style: TextStyle(
            fontSize: 12,
            color: Colors.green.shade300,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (address != null && address.isNotEmpty) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.place,
            size: 12,
            color: Colors.green.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              // Kurzform: Neben der Entfernung bleibt so wenig Platz, dass
              // die volle Anschrift mitten im Straßennamen abbrach —
              // „244a, Auerstraß…". Hausnummer und Straße genügen, um den
              // Ort wiederzuerkennen.
              shortPlace(address) ?? address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.green.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Helper: Warning-Badge für GPS-Status (Rot/Gelb)
Widget _buildWarningBadge({
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: color,
        width: 1.5,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Location Info Widget - GPS-Status-abhängige Anzeige
class _LocationInfo extends StatelessWidget {
  const _LocationInfo({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    // Kein GPS → nichts anzeigen
    if (contact.latitude == null || contact.longitude == null) {
      return const SizedBox.shrink();
    }

    final trackingService = getIt<LocationTrackingService>();
    final gpsManager = getIt<GpsManager>();

    return ValueListenableBuilder<bool>(
      valueListenable: trackingService.isTrackingRunning,
      builder: (context, isTracking, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: trackingService.hasLocationPermission,
          builder: (context, hasPermission, _) {
            final l10n = AppLocalizations.of(context);
            // 🔴 ROT: Berechtigung fehlt
            if (!hasPermission) {
              return _buildWarningBadge(
                icon: Icons.gps_off,
                text: l10n.gpsPermissionRequired,
                color: Colors.red,
              );
            }

            // 🟡 GELB: Tracking deaktiviert
            if (!isTracking) {
              return _buildWarningBadge(
                icon: Icons.gps_not_fixed,
                text: l10n.gpsTrackingDisabled,
                color: Colors.amber,
              );
            }

            // 🟢 GRÜN: Tracking aktiv → Distanz berechnen
            // Hier stand ein FutureBuilder auf `getUserPosition()`. Dessen
            // eigener Kommentar warnt davor: der Aufruf gehoert an eine
            // Nutzerhandlung, nicht in einen Rebuild. In einer Liste lief er
            // beim Scrollen fuer jede sichtbare Karte -- bei kaltem Cache eine
            // echte Standortabfrage je Karte, sonst wenigstens eine Logzeile
            // mit Map und ein Future pro Neuaufbau.
            //
            // Die Position liegt ohnehin als ValueListenable vor. Wer sie
            // anzeigt, soll ihr zuhoeren, nicht nach ihr fragen.
            return ValueListenableBuilder<LatLng?>(
              valueListenable: gpsManager.userPosition,
              builder: (context, position, _) {
                if (position == null) {
                  return const SizedBox.shrink();
                }

                final distanceText = _calculateDistance(
                  contact,
                  position,
                  gpsManager,
                );

                // Keine Distanz berechenbar
                if (distanceText == null) {
                  return const SizedBox.shrink();
                }

                // Grünes Distanz-Badge
                return _buildDistanceBadge(
                  distance: distanceText,
                  address: contact.address,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Emergency Badge - Grüner Indicator für Notfallkontakte
class _EmergencyBadge extends StatelessWidget {
  const _EmergencyBadge({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    // Nur für Notfallkontakte anzeigen
    if (!contact.isEmergencyContact) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const EmergencyScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emergency,
              size: 14,
              color: Colors.green,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.emergencyContactLabel,
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade300,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: Colors.green.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

/// Contact Avatar mit farbigem Border basierend auf Rating
class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({
    required this.imagePath,
    required this.name,
    required this.rating,
  });
  final String? imagePath;
  final String name;
  final int rating;

  @override
  Widget build(BuildContext context) {
    final borderColor = _getRatingColor(rating);

    return ContactAvatar(
      imagePath: imagePath,
      name: name,
      size: 80,
      borderColor: borderColor,
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
