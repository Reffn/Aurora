import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/diary/entry_detail_screen.dart';
import 'package:dis_app/modules/diary/widgets/entry_card.dart';
import 'package:dis_app/services/diary_service.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/animated_empty_state.dart';
import 'package:dis_app/widgets/animated_list_view.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Tagebuch Screen - Tagebuch mit Timeline
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DiaryService? _diaryService;

  @override
  void initState() {
    super.initState();
    // Safe Access: Prüfe ob Service verfügbar ist (Deferred Init abgeschlossen)
    if (getIt.isRegistered<DiaryService>()) {
      _diaryService = getIt<DiaryService>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Wenn Service nicht verfügbar (noch nicht initialisiert), zeige Loading
    if (_diaryService == null) {
      return const Scaffold(
        appBar: StandardAppBar(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: const StandardAppBar(),
      body: ValueListenableBuilder(
        valueListenable: _diaryService!.entriesBox.listenable(),
        builder: (context, box, _) {
          final entries = _diaryService!.entries;

          if (entries.isEmpty) {
            return AnimatedEmptyState(
              icon: Icons.event_note,
              title: l10n.diaryEmptyTitle,
              subtitle: l10n.diaryEmptySubtitle,
            );
          }

          return AnimatedListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              context.safeBottomPaddingForFab,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return EntryCard(
                entry: entry,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          EntryDetailScreen(entryId: entry.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      // FloatingActionButton wird jetzt zentral im MainScreen verwaltet
    );
  }
}
