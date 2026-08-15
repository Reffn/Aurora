import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/profile_actions_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Zeigt laufende Passwort-Resets, solange ihre Frist läuft.
///
/// Das Banner ist der sichtbare Teil des Schutzes: Wer sein Passwort noch
/// kennt, muss den Reset bemerken können, um ihn per Login abzubrechen.
/// Deshalb hängt es über allen Bereichen und lässt sich nicht wegwischen.
///
/// Es liest nur. Zustand ändert allein der Login-Pfad.
class ResetBanner extends StatefulWidget {
  const ResetBanner({super.key});

  /// Ab hier werden die Farbflächen gebündelt, statt den Schirm zu füllen.
  static const int maxEinzeln = 3;

  @override
  State<ResetBanner> createState() => _ResetBannerState();
}

class _ResetBannerState extends State<ResetBanner> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Die Box meldet keinen Zeitablauf — die Restzeit braucht einen eigenen
    // Takt, sonst bliebe das Banner nach Fristende stehen.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _restzeit(Profile profile) {
    final rest = profile.resetEndsAt!.difference(DateTime.now());
    if (rest.inDays >= 1) {
      return '${rest.inDays}d ${rest.inHours.remainder(24)}h';
    }
    if (rest.inHours >= 1) {
      return '${rest.inHours}h ${rest.inMinutes.remainder(60)}m';
    }
    if (rest.inMinutes >= 1) return '${rest.inMinutes}m';
    return '${rest.inSeconds.clamp(0, 60)}s';
  }

  void _oeffneProfil(Profile profile) {
    unawaited(ProfileActionsDialog.show(context, profile));
  }

  @override
  Widget build(BuildContext context) {
    final dataEntry = getIt<DataEntry>();

    return ValueListenableBuilder(
      valueListenable: dataEntry.profilesBox.listenable(),
      builder: (context, Box<Profile> box, _) {
        final laufende = box.values
            .where((p) => p.hasActiveReset && !p.isResetExpired)
            .toList();

        if (laufende.isEmpty) return const SizedBox.shrink();

        if (laufende.length <= ResetBanner.maxEinzeln) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [for (final p in laufende) _einzeln(p)],
          );
        }
        return _gebuendelt(laufende);
      },
    );
  }

  /// Ein Reset: Farbe des betroffenen Profils, Sanduhr, Restzeit.
  Widget _einzeln(Profile profile) {
    final foreground = AppColors.onColor(profile.preferredColor);
    return Material(
      color: profile.preferredColor,
      child: InkWell(
        onTap: () => _oeffneProfil(profile),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.hourglass_top, color: foreground, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${profile.name} · ${_restzeit(profile)}',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: foreground,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Vier und mehr: eine Fläche, die Profile als Punkte. Sonst wäre der
  /// halbe Schirm gesättigt und nichts stäche mehr hervor.
  Widget _gebuendelt(List<Profile> laufende) {
    return Material(
      color: const Color(0xFF1F1F1F),
      child: InkWell(
        onTap: () => _zeigeListe(laufende),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              for (final p in laufende)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: p.preferredColor,
                  ),
                ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _zeigeListe(List<Profile> laufende) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF1F1F1F),
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final p in laufende)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: p.preferredColor,
                    child: const Icon(
                      Icons.hourglass_top,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(color: AppColors.paper),
                  ),
                  subtitle: Text(
                    _restzeit(p),
                    style: TextStyle(
                      color: AppColors.paper.withValues(alpha: 0.7),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _oeffneProfil(p);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
