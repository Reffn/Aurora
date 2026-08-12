import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/widgets/animated_empty_state.dart';
import 'package:dis_app/widgets/icon_container.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:dis_app/widgets/profile_switch_avatar.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:dis_app/utils/short_place.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/// Zeitachse-Screen mit Profil-Wechsel Historie und GPS-Tracking
class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  late final LocationTrackingService _trackingService;
  late final DataEntry _dataEntry;
  late final MapController _mapController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _trackingService = getIt<LocationTrackingService>();
    _dataEntry = getIt<DataEntry>();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Zentriert Karte auf GPS-Position und scrollt zur Map
  void _centerMapOnLocation(double latitude, double longitude) {
    // Scrolle zur Karte (falls nicht sichtbar)
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Zentriere Karte auf Position mit Zoom 16
    Future.delayed(const Duration(milliseconds: 350), () {
      _mapController.move(LatLng(latitude, longitude), 16.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: const StandardAppBar(),
      body: ValueListenableBuilder(
        valueListenable: _trackingService.isTrackingRunning,
        builder: (context, isTracking, _) {
          if (!isTracking) {
            return _buildTrackingDisabledState(context, l10n);
          }

          return ListenableBuilder(
            listenable: Listenable.merge([
              _trackingService.locationHistoryBox.listenable(),
              _trackingService.switchEventsBox.listenable(),
              _dataEntry.contactsBox.listenable(),
              _dataEntry.finderItemsBox.listenable(),
            ]),
            builder: (context, _) {
              final locationHistory =
                  _trackingService.locationHistoryBox.values.toList()
                    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

              final switchEvents =
                  _trackingService.switchEventsBox.values.toList()
                    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

              if (locationHistory.isEmpty && switchEvents.isEmpty) {
                return _buildEmptyState(context, l10n);
              }

              // Daten für die Karte vorbereiten
              final allContacts = _dataEntry
                  .getContacts()
                  .where((c) => c.latitude != null && c.longitude != null)
                  .toList();

              final finderLocations = _dataEntry
                  .getFinderItemsByType(FinderItemType.location)
                  .where(
                    (item) => item.latitude != null && item.longitude != null,
                  )
                  .toList();

              final locale = Localizations.localeOf(context).languageCode;

              return SafeArea(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Map Overview
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: OverviewMap(
                          height: 300,
                          showUserLocation: true,
                          showFinderLocations: true,
                          showContacts: true,
                          showZoomControls: true,
                          showLocationButton: true,
                          historyPath: locationHistory,
                          switchEvents: switchEvents,
                          externalController: _mapController,
                          finderLocations: finderLocations,
                          contacts: allContacts,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        child: Divider(),
                      ),
                    ),

                    // Timeline Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.timelineHistory,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              l10n.timelineEntries(
                                locationHistory.length + switchEvents.length,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 12)),

                    // Combined Timeline
                    _buildTimelineList(
                      l10n,
                      locale,
                      locationHistory,
                      switchEvents,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTimelineList(
    AppLocalizations l10n,
    String locale,
    List<LocationHistoryEntry> locationHistory,
    List<ProfileSwitchEvent> switchEvents,
  ) {
    // Kombiniere beide Listen und sortiere nach Timestamp
    final items = <_TimelineItem>[];

    for (final entry in locationHistory) {
      items.add(
        _TimelineItem(
          timestamp: entry.timestamp,
          type: _TimelineItemType.location,
          locationEntry: entry,
        ),
      );
    }

    for (final event in switchEvents) {
      items.add(
        _TimelineItem(
          timestamp: event.timestamp,
          type: _TimelineItemType.profileSwitch,
          switchEvent: event,
        ),
      );
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: item.type == _TimelineItemType.location
                  ? _buildLocationCard(l10n, locale, item.locationEntry!)
                  : _buildProfileSwitchCard(l10n, locale, item.switchEvent!),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    AppLocalizations l10n,
    String locale,
    LocationHistoryEntry entry,
  ) {
    final profile = _dataEntry.profilesBox.get(entry.profileId);
    if (profile == null) return const SizedBox.shrink();

    return Card(
      color: Colors.blue.shade900.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.blue.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            IconContainer.small(
              icon: Icons.location_on,
              circle: true,
              backgroundColor: Colors.blue.withValues(alpha: 0.2),
              iconColor: Colors.blue.shade300,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile Color Indicator
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: profile.preferredColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Kurzform statt voller Anschrift: Hier stand
                    // „3, Kirchstraße, Coswig, Meißen, Sachsen, 01640,
                    // Deutschland" über zwei Zeilen. Postleitzahl, Kreis und
                    // Land tragen nichts dazu bei, eine Zeile im eigenen
                    // Verlauf wiederzuerkennen — sie machen sie nur länger
                    // als der Rest der Karte.
                    shortPlace(entry.address) ?? l10n.timelinePositionUpdated,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(l10n, entry.timestamp, locale),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Accuracy Badge
            if (entry.accuracy != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAccuracyColor(
                    entry.accuracy!,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '±${entry.accuracy!.toInt()}m',
                  style: TextStyle(
                    fontSize: 11,
                    color: _getAccuracyColor(entry.accuracy!),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSwitchCard(
    AppLocalizations l10n,
    String locale,
    ProfileSwitchEvent event,
  ) {
    final fromProfile = event.fromProfileId != null
        ? _dataEntry.profilesBox.get(event.fromProfileId)
        : null;
    final toProfile = _dataEntry.profilesBox.get(event.toProfileId);

    if (toProfile == null) return const SizedBox.shrink();

    return Card(
      color: Colors.red.shade900.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ProfileSwitchAvatar oder Play-Icon für App-Start
            if (event.isAppStart)
              IconContainer.small(
                icon: Icons.play_circle,
                circle: true,
                backgroundColor: Colors.red.withValues(alpha: 0.2),
                iconColor: Colors.red.shade300,
              )
            else
              ProfileSwitchAvatar.small(
                fromAvatarPath: fromProfile?.avatarPath,
                fromProfileName: fromProfile?.name ?? l10n.commonUnknown,
                fromProfileColor: fromProfile?.preferredColor ?? Colors.grey,
                toAvatarPath: toProfile.avatarPath,
                toProfileName: toProfile.name,
                toProfileColor: toProfile.preferredColor,
                size: 40,
              ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.isAppStart)
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: toProfile.preferredColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.timelineProfileActive(toProfile.name),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        // From Profile
                        if (fromProfile != null) ...[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: fromProfile.preferredColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              fromProfile.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 14),
                        const SizedBox(width: 6),
                        // To Profile
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: toProfile.preferredColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            toProfile.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    event.isAppStart
                        ? l10n.timelineAppStarted
                        : l10n.timelineProfileSwitched,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(l10n, event.timestamp, locale),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // GPS Badge (anklickbar - zentriert Karte auf Position)
            if (event.latitude != null && event.longitude != null)
              InkWell(
                onTap: () => _centerMapOnLocation(
                  event.latitude!,
                  event.longitude!,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.gps_fixed,
                    size: 16,
                    color: Colors.green.shade300,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingDisabledState(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AnimatedEmptyState(
      icon: Icons.location_off,
      title: l10n.timelineTrackingDisabledTitle,
      subtitle: l10n.timelineTrackingDisabledSubtitle,
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return AnimatedEmptyState(
      icon: Icons.hourglass_empty,
      title: l10n.timelineEmptyTitle,
      subtitle: l10n.timelineEmptySubtitle,
    );
  }

  String _formatDateTime(
    AppLocalizations l10n,
    DateTime dateTime,
    String locale,
  ) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);

    // Heute
    if (difference.inDays == 0) {
      return l10n.timelineToday(time);
    }

    // Gestern
    if (difference.inDays == 1) {
      return l10n.timelineYesterday(time);
    }

    // Innerhalb einer Woche
    if (difference.inDays < 7) {
      return DateFormat('EEEE, HH:mm', locale).format(dateTime);
    }

    // Älter
    return DateFormat('dd.MM.yyyy, HH:mm').format(dateTime);
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy <= 10) return Colors.green;
    if (accuracy <= 30) return Colors.yellow;
    if (accuracy <= 50) return Colors.orange;
    return Colors.red;
  }
}

/// Helper class für kombinierte Timeline
class _TimelineItem {
  _TimelineItem({
    required this.timestamp,
    required this.type,
    this.locationEntry,
    this.switchEvent,
  });
  final DateTime timestamp;
  final _TimelineItemType type;
  final LocationHistoryEntry? locationEntry;
  final ProfileSwitchEvent? switchEvent;
}

enum _TimelineItemType {
  location,
  profileSwitch,
}
