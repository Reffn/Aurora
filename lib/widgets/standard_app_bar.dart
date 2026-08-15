import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Standard AppBar Widget für konsistente Navigation
///
/// Features:
/// - Konsistente Höhe (48px base)
/// - Top-Strich in Theme-Farbe (1px)
/// - Subtile Profil-Farben-Leiste unten (1px)
/// - Support für Screens mit/ohne TabBar
/// - Aurora Theme-Farben
/// - Reactive Updates via StreamBuilder
class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StandardAppBar({
    this.title,
    this.tabBar,
    this.bottom,
    super.key,
  });

  /// Titel der AppBar. Ohne Titel bleibt nur die Leiste darunter stehen.
  ///
  /// Die Tabs des Karussells brauchen keinen: das Karussell nennt den
  /// gewählten Bereich bereits und hebt ihn hervor. Der Titel wiederholte
  /// dieses Wort eine Zeile tiefer und kostete dabei 48 px — auf einem
  /// Bildschirm, dessen Platz Zeichenfläche und Nachrichtenverlauf brauchen.
  /// Titel tragen nur noch Ansichten, die über einen eigenen Weg geöffnet
  /// werden und deshalb einen Namen und einen Rückweg zeigen müssen.
  final String? title;

  /// Optional: TabBar für Screens mit Untertabs
  final TabBar? tabBar;

  /// Optional: Custom bottom widget (z.B. für ContactsScreen Filter)
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize {
    var height = 1.0 + (title == null ? 0.0 : 48.0) + 1.0;

    if (tabBar != null) {
      height += tabBar!.preferredSize.height;
    } else if (bottom != null) {
      height += bottom!.preferredSize.height;
    }

    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final dataEntry = getIt<DataEntry>();

    // Reaktiv auf Profil-Wechsel via Hive settingsBox
    return ValueListenableBuilder(
      valueListenable: dataEntry.settingsBox.listenable(),
      builder: (context, box, _) {
        final activeProfile = dataEntry.getActiveProfile();
        final profileColor = activeProfile?.preferredColor ?? Colors.grey;

        // Erstelle ein kombiniertes bottom Widget mit Profil-Farbleiste
        final combinedBottom = _ProfileColorBottom(
          color: profileColor,
          child: tabBar ?? bottom,
        );

        // Top-Strich + AppBar in PreferredSize-Column
        return PreferredSize(
          preferredSize: preferredSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top-Strich in Theme-Farbe
              Container(
                height: 1,
                color: AppColors.paper.withValues(alpha: 0.3),
              ),

              // AppBar mit Title und kombiniertem Bottom
              Expanded(
                child: AppBar(
                  title: title == null ? null : Text(title!),
                  automaticallyImplyLeading: title != null,
                  backgroundColor: const Color(0xFF28272C),
                  foregroundColor: AppColors.paper,
                  elevation: 0,
                  toolbarHeight: title == null ? 0 : 48,
                  bottom: combinedBottom,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom PreferredSizeWidget das TabBar + Profil-Farbleiste kombiniert
class _ProfileColorBottom extends StatelessWidget
    implements PreferredSizeWidget {
  const _ProfileColorBottom({
    required this.color,
    this.child,
  });

  final Color color;
  final PreferredSizeWidget? child;

  @override
  Size get preferredSize {
    final childHeight = child?.preferredSize.height ?? 0.0;
    return Size.fromHeight(childHeight + 1.0); // Child + 1px Farbleiste
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional: TabBar oder anderes bottom Widget
        if (child != null) child!,

        // Profil-Farben-Leiste (subtil, kein Shadow)
        Container(
          height: 1,
          color: color.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}
