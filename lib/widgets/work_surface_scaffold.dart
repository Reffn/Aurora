import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Das Gerüst jeder Arbeitsfläche.
///
/// Trägt genau einen Weg zurück: das Ankersymbol links in der Kopfzeile. Die
/// Zurück-Taste des Geräts tut dasselbe, weil sie diese Seite vom Stapel nimmt
/// — ein Weg, zwei Auslöser, nicht zweimal programmiert.
class WorkSurfaceScaffold extends StatelessWidget {
  const WorkSurfaceScaffold({
    required this.title,
    required this.child,
    this.profile,
    this.fab,
    this.actions = const [],
    this.subHeader,
    this.onProfileTap,
    super.key,
  });

  final String title;
  final Widget child;

  /// Der Anteil, der gerade hier ist — sichtbar unter dem Bereichstitel.
  ///
  /// Nach einem Wechsel mitten in der Arbeit weiß sonst niemand, als wer er
  /// gerade handelt, ohne zum Anker zurückzugehen; Amnesie ist der Normalfall,
  /// nicht die Ausnahme. Avatar und Farbring tragen, der Name bestätigt.
  final Profile? profile;

  /// Führt ins Profilmenü (bearbeiten, Einstellungen, ausloggen).
  ///
  /// Die Anteilszeile sah bisher aus wie ein Knopf und war keiner — wer den
  /// Weg zum Wechsel oder zu den Einstellungen suchte, griff genau dorthin
  /// ins Leere. Sie ist jetzt der Weg, den sie schon versprochen hat, und
  /// damit sind die Einstellungen von jeder Arbeitsfläche erreichbar statt
  /// nur vom Anker. Ohne Rückruf bleibt die Zeile reine Auskunft.
  final VoidCallback? onProfileTap;
  final Widget? fab;
  final List<Widget> actions;

  /// Schmale Zeile unter der Kopfzeile — das Marken-Band der Orientierung.
  final Widget? subHeader;

  @override
  Widget build(BuildContext context) {
    final aktiverAnteil = profile;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        // Zwei Zeilen brauchen mehr Höhe als die Standard-Kopfzeile hergibt.
        toolbarHeight: aktiverAnteil == null ? null : 72,
        // Wort unter dem Symbol: Symbol und Wort zusammen werden schneller
        // erkannt als das Symbol allein (Turk & Hutchings, CHI 2023) — und
        // nie trägt ein Symbol allein (Regel 5).
        leading: Tooltip(
          message: l10n.navBackToAnchor,
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.anchor, size: 24),
                Text(l10n.anchorTitle, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
        title: aktiverAnteil == null
            ? Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Semantics(
                    button: onProfileTap != null,
                    label: onProfileTap == null
                        ? l10n.workSurfaceActiveProfile(aktiverAnteil.name)
                        : '${l10n.workSurfaceActiveProfile(aktiverAnteil.name)} '
                              '— ${l10n.profileMenuTitle}',
                    child: InkWell(
                      onTap: onProfileTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: aktiverAnteil.preferredColor,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: ProfileImageWidget(
                                avatarPath: aktiverAnteil.avatarPath,
                                profileName: aktiverAnteil.name,
                                profileColor: aktiverAnteil.preferredColor,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              aktiverAnteil.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Das Zahnrad steht neben dem Namen, nie allein
                          // (Regel 5) — es sagt, dass diese Zeile weiterführt.
                          if (onProfileTap != null) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.settings,
                              size: 14,
                              color: aktiverAnteil.preferredColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        centerTitle: true,
        actions: actions,
        bottom: subHeader == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: subHeader!,
              ),
      ),
      body: child,
      floatingActionButton: fab,
    );
  }
}
