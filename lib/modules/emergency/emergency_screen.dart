import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/modules/contacts/contact_form_screen.dart';
import 'package:dis_app/modules/emergency/widgets/emergency_contact_card.dart';
import 'package:dis_app/modules/help/help_resources_screen.dart';
import 'package:dis_app/services/emergency_message_service.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Notfallkontakte-Screen mit GPS-Karte zur Orientierung im Notfall
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late final DataEntry _dataEntry;
  late final EmergencyMessageService _emergencyService;
  late final LocationTrackingService _trackingService;

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();
    _emergencyService = getIt<EmergencyMessageService>();
    _trackingService = getIt<LocationTrackingService>();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: const StandardAppBar(),
      body: ValueListenableBuilder(
        valueListenable: _dataEntry.contactsBox.listenable(),
        builder: (context, box, _) {
          final emergencyContacts = _dataEntry
              .getContacts()
              .where((c) => c.isEmergencyContact)
              .toList();

          // Sortiere Notfallkontakte nach Name
          emergencyContacts.sort((a, b) => a.name.compareTo(b.name));

          // Alle Finder-Orte mit GPS für Karte
          final finderLocations = _dataEntry
              .getFinderItemsByType(FinderItemType.location)
              .where((item) => item.latitude != null && item.longitude != null)
              .toList();

          // Alle Kontakte mit GPS für Karte
          final contactsWithLocation = _dataEntry
              .getContacts()
              .where((c) => c.latitude != null && c.longitude != null)
              .toList();

          // Location History und Switch Events aus Cache
          final locationHistory = _trackingService.locationHistoryBox.values
              .toList();
          final switchEvents = _trackingService.switchEventsBox.values.toList();

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Notfallkontakte oder Leerer Zustand
                if (emergencyContacts.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(context),
                  )
                else ...[
                  // Liste der Notfallkontakte
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final contact = emergencyContacts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EmergencyContactCard(
                              contact: contact,
                              emergencyService: _emergencyService,
                            ),
                          );
                        },
                        childCount: emergencyContacts.length,
                      ),
                    ),
                  ),

                  // "An ALLE senden" Buttons
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Divider(),
                          const SizedBox(height: 16),

                          // SMS an alle
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _sendSmsToAll(emergencyContacts),
                              icon: const Icon(Icons.sms, size: 24),
                              label: Text(l10n.emergencySendSmsAll),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Via App an alle
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _shareToAll,
                              icon: const Icon(Icons.share, size: 24),
                              label: Text(l10n.emergencyShareAll),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue.shade300,
                                side: BorderSide(color: Colors.blue.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],

                // Divider
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Divider(),
                  ),
                ),

                // GPS-Orientierungskarte
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: OverviewMap(
                      showUserLocation: false,
                      showPermissionBanner: false,
                      showLocationButton: false,
                      showFinderLocations: true,
                      showContacts: true,
                      showZoomControls: true,
                      finderLocations: finderLocations,
                      contacts: contactsWithLocation,
                      historyPath: locationHistory,
                      switchEvents: switchEvents,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.emergencyEmptyTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.emergencyEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.emergencyEmptyDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Ein Leerzustand, der nur auf einen anderen Bereich zeigt, lässt
            // genau die Person allein, die am wenigsten vorbereitet ist. Beide
            // Wege stehen deshalb hier: einer legt vor, einer hilft sofort.
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ContactFormScreen(),
                  ),
                ),
                icon: const Icon(Icons.person_add, size: 24),
                label: Text(l10n.emergencyEmptyAddContact),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HelpResourcesScreen(),
                  ),
                ),
                icon: const Icon(Icons.support_agent, size: 24),
                label: Text(l10n.emergencyEmptyOpenHelp),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendSmsToAll(List<Contact> contacts) async {
    final l10n = AppLocalizations.of(context);
    try {
      // Zeige Bestätigungs-Dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.emergencySmsDialogTitle),
          content: Text(l10n.emergencySmsDialogMessage(contacts.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: Text(l10n.emergencySendNow),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
      if (!mounted) return;

      // Zeige Loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emergencyMessagePreparing),
          duration: const Duration(seconds: 2),
        ),
      );

      await _emergencyService.sendSmsToAll(contacts);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emergencyErrorSms(e.toString()))),
      );
    }
  }

  Future<void> _shareToAll() async {
    final l10n = AppLocalizations.of(context);
    try {
      // Zeige Loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emergencyMessagePreparing),
          duration: const Duration(seconds: 2),
        ),
      );

      await _emergencyService.shareMessage();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emergencyErrorShare(e.toString()))),
      );
    }
  }
}
