import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/games/memory/memory_spiel.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';

/// Memory ohne Uhr, ohne Punkte, ohne Feiermoment.
///
/// Drei Entscheidungen, die von einem üblichen Memory abweichen, und warum:
///
/// **Es dreht nichts von selbst zurück.** Sonst müsste ein Zeitgeber
/// entscheiden, wie lange jemand hinsehen darf. Zwei ungleiche Karten bleiben
/// offen liegen, bis der nächste Griff kommt — der dreht sie um und deckt die
/// neue auf. Damit gibt es keine Frist, innerhalb derer man sich etwas gemerkt
/// haben muss (Regel 10: keine Zeitdruck-Grenzen), und die Karte am Ende ist
/// nie „zu schnell weg".
///
/// **Am Ende steht ein Satz, kein Fest.** Belohnungsschleifen und nicht
/// überspringbare Feiermomente sind ausgeschlossen (Regel 11).
///
/// **Nichts wird gezählt.** Kein Zugzähler, keine Bestzeit. Eine Wertung wäre
/// Druck, und die Fläche verspricht wörtlich Ruhe.
class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: AppLocalizations.of(context).gamesMemoryTitle,
      ),
      body: const SafeArea(child: MemoryTisch()),
    );
  }
}

/// Der Tisch: Raster, Karten und der Weg zu einer neuen Runde.
///
/// Getrennt vom Rahmen, weil das Spiel selbst keinen einzigen Dienst braucht.
/// Damit ist es prüfbar, ohne die halbe App hochzufahren — in diesem
/// Codebase die Ausnahme, hier lässt sie sich haben.
class MemoryTisch extends StatefulWidget {
  const MemoryTisch({super.key});

  /// Die Motive der Karten.
  ///
  /// Neun Bilder für sechs Paare — dadurch sieht nicht jede Runde gleich aus.
  ///
  /// Bewusst ohne die Chamäleons von Halt, Notfall und Hilfe: Diese drei
  /// Bilder stehen für die Wege, die im schlechtesten Zustand gefunden werden
  /// müssen. Sie als Spielkarte zu verwenden, würde ihre Bedeutung verwässern
  /// (Regel 7: was etwas bedeutet, bedeutet morgen dasselbe).
  static const List<String> motive = [
    'assets/images/cham_chat.png',
    'assets/images/cham_kalender.png',
    'assets/images/cham_tagebuch.png',
    'assets/images/cham_medikamente.png',
    'assets/images/cham_kontakte.png',
    'assets/images/cham_finder.png',
    'assets/images/cham_zeitachse.png',
    'assets/images/cham_spiele.png',
    'assets/images/cham_feedback.png',
  ];

  static const int paare = 6;

  @override
  State<MemoryTisch> createState() => _MemoryTischState();
}

class _MemoryTischState extends State<MemoryTisch> {
  late MemorySpiel _spiel;

  @override
  void initState() {
    super.initState();
    _spiel = _neuesSpiel();
  }

  MemorySpiel _neuesSpiel() => MemorySpiel.neu(
    motive: MemoryTisch.motive,
    paare: MemoryTisch.paare,
  );

  void _griff(int platz) {
    if (_spiel.aufdecken(platz)) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _spiel.karten.length,
              itemBuilder: (context, index) {
                final karte = _spiel.karten[index];
                return _Karte(
                  karte: karte,
                  gesamt: _spiel.karten.length,
                  onTap: () => _griff(karte.platz),
                );
              },
            ),
          ),
        ),
        _Fussleiste(
          fertig: _spiel.fertig,
          onNeuesSpiel: () => setState(() => _spiel = _neuesSpiel()),
        ),
      ],
    );
  }
}

/// Eine Karte im Raster.
class _Karte extends StatelessWidget {
  const _Karte({
    required this.karte,
    required this.gesamt,
    required this.onTap,
  });

  final MemoryKarte karte;
  final int gesamt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final verdeckt = karte.zustand == KartenZustand.verdeckt;
    final gefunden = karte.zustand == KartenZustand.gefunden;

    final String zustandInWorten;
    if (verdeckt) {
      zustandInWorten = l10n.memoryCardHidden;
    } else if (gefunden) {
      zustandInWorten = l10n.memoryCardFound;
    } else {
      zustandInWorten = l10n.memoryCardOpen;
    }

    return Semantics(
      button: verdeckt,
      label: l10n.memoryCardPosition(karte.platz + 1, gesamt),
      value: zustandInWorten,
      child: Material(
        color: Colors.white.withValues(alpha: gefunden ? 0.04 : 0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: verdeckt ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedSwitcher(
            // Zeigt die Sache selbst — die Karte dreht sich (Regel 11).
            // Wer Bewegung abgestellt hat, bekommt keinen Übergang.
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            child: verdeckt
                ? const _Rueckseite(key: ValueKey('rueckseite'))
                : Padding(
                    key: ValueKey(karte.bild),
                    padding: const EdgeInsets.all(10),
                    child: Opacity(
                      opacity: gefunden ? 0.45 : 1,
                      child: Image.asset(karte.bild, fit: BoxFit.contain),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Der Rücken einer verdeckten Karte: ruhig, ohne Motiv.
class _Rueckseite extends StatelessWidget {
  const _Rueckseite({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.help_outline,
        size: 32,
        color: Colors.white.withValues(alpha: 0.25),
      ),
    );
  }
}

/// Unter dem Raster: der Weg zu einer neuen Runde, und am Ende ein Satz.
class _Fussleiste extends StatelessWidget {
  const _Fussleiste({required this.fertig, required this.onNeuesSpiel});

  final bool fertig;
  final VoidCallback onNeuesSpiel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fertig)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.memoryAllFound,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          // Immer da, nicht erst am Ende: Wer mittendrin neu anfangen will,
          // findet den Weg, ohne das Spiel zu Ende bringen zu müssen
          // (Regel 10: kein Ablauf ohne Ausgang).
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onNeuesSpiel,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.memoryNewGame),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
