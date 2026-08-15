import 'dart:async';

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Der Bildschirm, den jeder Start zuerst zeigt.
///
/// Er lag bis zum 11. August 2026 in `main.dart` und trug vier Dinge, die
/// dort nicht hingehörten:
///
/// **Eine Liste mit acht Sprachen** unter der Überschrift „Sprachen, die
/// Aurora spricht" — gezogen aus einer Tabelle mit vierundvierzig, darunter
/// Zulu, Suaheli, Esperanto und Walisisch. Aurora spricht fünf. Die Liste
/// behauptete etwas Falsches, kostete beim Start Lesekapazität und stand in
/// sieben Schriftsystemen vor jemandem, der die App gerade zum ersten Mal
/// öffnet. Sie ist ersatzlos weg; `loading_translations.dart` mit ihr.
///
/// **Eine Überschrift, die immer deutsch war.** Dort stand `all['de']!` aus
/// derselben Tabelle, hart verdrahtet. Wer Aurora auf Spanisch stellte, las
/// „Aurora lädt" über spanischen Sätzen. Der übersetzte Text lag längst in
/// allen fünf Sprachdateien und wurde nie benutzt — jetzt schon.
///
/// **Einen „Wusstest du?"-Satz.** Er braucht drei bis fünf Sekunden Lesezeit
/// und stand deshalb auf einer Fläche, die künstlich drei Sekunden lang
/// blieb. Beide Gründe sind gefallen: Die Sätze bleiben erhalten
/// (`did_you_know_facts.dart`, in allen fünf Sprachen übersetzt) und warten
/// auf einen Ort, an dem jemand Zeit zum Lesen hat. Ein Start ist kein
/// solcher Ort — wer die App öffnet, will hinein.
///
/// **Die Sprache kommt vom System, nicht aus der Wahl.** Das bleibt so und
/// ist kein Versehen: Die gespeicherte Wahl liegt in Hive, und Hive wird erst
/// in den Diensten geöffnet (`injection.dart`), also nach diesem Bildschirm.
/// Wessen Systemsprache eine andere ist als seine gewählte, sieht hier knapp
/// eine Sekunde lang die Systemsprache. Dafür den Start umzuverdrahten wäre
/// teurer als der Fehler.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.onHold,
    required this.onRelease,
    super.key,
  });

  /// Jemand hat angefangen, auf das Logo zu tippen.
  ///
  /// Ab hier wartet der Start, auch wenn er längst fertig wäre.
  final VoidCallback onHold;

  /// Das Tippen ist vorbei — der Start darf weiter.
  ///
  /// `wipe` ist nur dann `true`, wenn [tapsFuerReset] Mal getippt *und* der
  /// Dialog bestätigt wurde.
  final void Function({required bool wipe}) onRelease;

  /// Wie lange nach dem letzten Tap noch weitergetippt werden darf.
  ///
  /// Läuft die Frist ab, ist das Tippen vorbei und der Start geht weiter. Sie
  /// beginnt bei **jedem** Tap neu — die Frist hängt am Tippen, nicht am
  /// Start. Vorher war es umgekehrt: Drei Sekunden nach dem Öffnen war das
  /// Fenster zu, egal was danach geschah. Ausgerechnet im Fall, für den der
  /// Löschweg gedacht ist — ein Start, der klemmt —, nahm er nichts mehr an.
  static const Duration tippfenster = Duration(seconds: 3);

  /// So oft muss das Logo getippt werden.
  static const int tapsFuerReset = 5;

  /// Die Punktreihe, die das Tippen zählt.
  static const zaehlerSchluessel = Key('splash-tap-zaehler');

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _tippfenster;
  int _taps = 0;
  bool _haelt = false;
  bool _entschieden = false;

  @override
  void dispose() {
    _tippfenster?.cancel();
    super.dispose();
  }

  /// Gibt den Start frei — genau einmal.
  void _freigeben({required bool wipe}) {
    if (_entschieden) return;
    _entschieden = true;
    _tippfenster?.cancel();
    if (mounted) setState(() => _taps = 0);
    widget.onRelease(wipe: wipe);
  }

  Future<void> _handleLogoTap() async {
    if (_entschieden) return;

    if (!_haelt) {
      _haelt = true;
      widget.onHold();
      logger.info(LogCategory.ui, '⏸️ Logo getippt — der Start wartet');
    }

    setState(() => _taps++);

    // Jeder Tap setzt die Frist neu. Wer aufhört, gibt frei.
    _tippfenster?.cancel();
    _tippfenster = Timer(SplashScreen.tippfenster, () {
      logger.info(
        LogCategory.ui,
        '⏱️ Tippfenster abgelaufen — Start geht weiter',
      );
      _freigeben(wipe: false);
    });

    if (_taps < SplashScreen.tapsFuerReset) return;

    _tippfenster?.cancel();

    logger.warning(
      LogCategory.ui,
      '🚨 ${SplashScreen.tapsFuerReset} Taps — Rückfrage zum Notfall-Reset',
    );

    final l10n = AppLocalizations.of(context);
    final shouldWipe = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.emergencyResetTitle)),
          ],
        ),
        content: Text(l10n.emergencyResetWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.emergencyResetConfirm),
          ),
        ],
      ),
    );

    if (shouldWipe ?? false) {
      logger.error(LogCategory.ui, '💥 Notfall-Reset bestätigt');
    }
    _freigeben(wipe: shouldWipe ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.ink, AppColors.inkDeep],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Das Logo trägt den Notfall-Reset, ohne Beschriftung.
                //
                // Das ist die eine Stelle, an der Richtlinie 8 („jede Geste
                // hat einen sichtbaren Knopf") bewusst gebrochen wird: Der
                // Weg ist für Menschen da, denen jemand über die Schulter
                // sieht. Ein sichtbarer Knopf „alles löschen" verriete ihn.
                GestureDetector(
                  onTap: _handleLogoTap,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB6C1).withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: const Color(
                            0xFF87CEEB,
                          ).withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo_rainbow.png',
                      height: 160,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  l10n.splashLoading,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.paper,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 28),

                // Der Zähler erscheint erst ab dem zweiten Tap.
                //
                // Wer einmal danebentippt, soll nichts von diesem Weg
                // erfahren — und wer ihn absichtlich geht, soll nicht ins
                // Leere tippen. Vorher zählte die App still mit, und man
                // erfuhr beim fünften Mal, dass man vier Mal getroffen hatte.
                SizedBox(
                  height: 12,
                  child: _taps >= 2
                      ? Row(
                          key: SplashScreen.zaehlerSchluessel,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < SplashScreen.tapsFuerReset; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i < _taps
                                        ? AppColors.paper
                                        : AppColors.paper.withValues(
                                            alpha: 0.25,
                                          ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
