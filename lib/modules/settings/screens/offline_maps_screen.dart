import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/services/tile_cache_manager.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';

/// Karten offline: Kachelspeicher, Grenze und Leeren.
///
/// „Karten vorab laden“ stand hier und sagte nur „kommt bald“: eine
/// Handlung, die nur scheitern kann. Sie kommt wieder, wenn es sie gibt.
class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key});

  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  late final _tileCacheManager = getIt<TileCacheManager>();

  /// Groesse und Anzahl der Kartenkacheln, beim Oeffnen geholt und nicht im
  /// `build` -- dort entstand pro Neuaufbau ein neues Future auf den
  /// Kachelspeicher. Nach Leeren und neuer Grenze holt [_zahlenNeuLaden] sie
  /// frisch; vorher blieben dort die alten Zahlen stehen.
  late Future<Map<String, dynamic>> _kachelZahlen = _kachelZahlenLaden();

  Future<Map<String, dynamic>> _kachelZahlenLaden() =>
      Future.wait([
        _tileCacheManager.getCacheSizeMB(),
        _tileCacheManager.getTileCount(),
      ]).then(
        (results) => {
          'sizeMB': results[0],
          'count': results[1],
          'limitMB': _tileCacheManager.maxCacheSizeMB,
        },
      );

  void _zahlenNeuLaden() {
    setState(() {
      _kachelZahlen = _kachelZahlenLaden();
    });
  }

  Future<void> _clearMapCache() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: l10n.settingsClearCache,
      message:
          '${l10n.settingsMapCacheClearQuestion}\n\n'
          '${l10n.settingsCacheClearHint}',
      confirmText: l10n.settingsClearCache,
      confirmColor: Colors.orange,
      icon: Icons.delete_sweep,
    );

    if (confirmed == ConfirmationResult.confirm) {
      try {
        await _tileCacheManager.clearCache();
        if (mounted) {
          showCustomSnackBar(
            context,
            message: l10n.settingsMapCacheCleared,
            type: SnackBarType.success,
          );
          _zahlenNeuLaden();
        }
      } catch (e) {
        if (mounted) {
          showCustomSnackBar(
            context,
            message: l10n.errorWithDetail(e.toString()),
            type: SnackBarType.error,
          );
        }
      }
    }
  }

  Future<void> _showCacheLimitDialog() async {
    final l10n = AppLocalizations.of(context);
    final currentLimit = _tileCacheManager.maxCacheSizeMB;
    var newLimit = currentLimit.toDouble();

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.settingsCacheLimitTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsCacheLimitValue(newLimit.round()),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: newLimit,
                min: 100,
                max: 2000,
                divisions: 19,
                label: l10n.settingsCacheLimitMegabytes(newLimit.round()),
                onChanged: (value) {
                  setDialogState(() {
                    newLimit = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settingsCacheLimitExplanation,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, newLimit.round()),
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );

    if (result != null && result != currentLimit) {
      try {
        await _tileCacheManager.setMaxCacheSizeMB(result);
        if (mounted) {
          showCustomSnackBar(
            context,
            message: l10n.settingsCacheLimitSet(result),
            type: SnackBarType.success,
          );
          _zahlenNeuLaden();
        }
      } catch (e) {
        if (mounted) {
          showCustomSnackBar(
            context,
            message: l10n.errorWithDetail(e.toString()),
            type: SnackBarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: StandardAppBar(title: l10n.settingsOfflineMapsTitle),
      body: ListView(
        // Unten das Polster der Navigationsleiste, wie im Hauptschirm.
        padding: EdgeInsets.fromLTRB(
          8,
          8,
          8,
          context.safeBottomPaddingWithMargin(8),
        ),
        children: [
          // Cache Statistics
          FutureBuilder<Map<String, dynamic>>(
            future: _kachelZahlen,
            builder: (context, snapshot) {
              final sizeMB = snapshot.data?['sizeMB'] as int? ?? 0;
              final count = snapshot.data?['count'] as int? ?? 0;
              final limitMB = snapshot.data?['limitMB'] as int? ?? 500;
              final percentage = limitMB > 0
                  ? (sizeMB / limitMB * 100).clamp(0, 100)
                  : 0;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.storage,
                            color: Colors.blue,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.settingsCacheStorage,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.settingsTilesCount(
                                    sizeMB.toString(),
                                    limitMB.toString(),
                                    count.toString().replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (Match m) => '${m[1]}.',
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            l10n.settingsPercent(percentage.round()),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: percentage > 90
                                  ? Colors.red
                                  : percentage > 70
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage > 90
                                ? Colors.red
                                : percentage > 70
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Cache Limit Setting
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(
                Icons.tune,
                color: Colors.purple,
                size: 28,
              ),
              title: Text(
                l10n.settingsCacheLimitLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.settingsMaxStorage(_tileCacheManager.maxCacheSizeMB),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showCacheLimitDialog,
            ),
          ),

          // Clear Cache
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(
                Icons.delete_sweep,
                color: Colors.orange,
                size: 28,
              ),
              title: Text(
                l10n.settingsClearCache,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.settingsClearCacheSubtitle,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _clearMapCache,
            ),
          ),
        ],
      ),
    );
  }
}
