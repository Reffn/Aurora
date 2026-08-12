import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/modules/finder/finder_detail_screen.dart';
import 'package:dis_app/modules/finder/widgets/finder_item_card.dart';
import 'package:dis_app/services/navigation_service.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/animated_empty_state.dart';
import 'package:dis_app/widgets/animated_list_view.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Finder Screen - Hauptansicht mit zwei Tabs (Orte & Dinge)
class FinderScreen extends StatefulWidget {
  const FinderScreen({super.key});

  @override
  State<FinderScreen> createState() => _FinderScreenState();
}

class _FinderScreenState extends State<FinderScreen>
    with SingleTickerProviderStateMixin {
  final _dataEntry = getIt<DataEntry>();
  final _navigationService = getIt<NavigationService>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _navigationService.finderCurrentTabIndex,
    );

    // Tab-Änderungen tracken
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _navigationService.setFinderTabIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: StandardAppBar(
        tabBar: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.paper,
          labelColor: AppColors.paper,
          unselectedLabelColor: const Color(0xFF8A8A8A),
          tabs: [
            Tab(text: l10n.finderTabLocations),
            Tab(text: l10n.finderTabItems),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemsList(FinderItemType.location),
          _buildItemsList(FinderItemType.item),
        ],
      ),
    );
  }

  Widget _buildItemsList(FinderItemType type) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder(
      valueListenable: _dataEntry.finderItemsBox.listenable(),
      builder: (context, box, _) {
        final items = _dataEntry.getFinderItemsByType(type);

        // Sortieren: Neueste zuerst
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (items.isEmpty) {
          return AnimatedEmptyState(
            icon: type == FinderItemType.location
                ? Icons.place_outlined
                : Icons.inventory_2_outlined,
            title: type == FinderItemType.location
                ? l10n.finderEmptyLocationsTitle
                : l10n.finderEmptyItemsTitle,
            subtitle: type == FinderItemType.location
                ? l10n.finderEmptyLocationsSubtitle
                : l10n.finderEmptyItemsSubtitle,
          );
        }

        return AnimatedListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            context.safeBottomPaddingForFab,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return FinderItemCard(
              item: item,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => FinderDetailScreen(itemId: item.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
