import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/anchor/anchor_action_bar.dart';
import 'package:dis_app/modules/anchor/anchor_row.dart';
import 'package:dis_app/modules/anchor/anchor_tile.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/utils/time_phase.dart';
import 'package:flutter/material.dart';

/// Ein Eintrag im Ankermenü, losgelöst von der Tab-Definition.
///
/// Dadurch bleibt der Anker ohne Dependency Injection prüfbar: Der Test reicht
/// Einträge herein, statt eine halbe App aufzubauen.
class AnchorEntry {
  const AnchorEntry({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.imageAsset,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  /// Das Chamäleon für diesen Bereich, falls es schon gezeichnet ist.
  final String? imageAsset;
}

/// Die drei Gruppen des Ankers, in ihrer festen Reihenfolge.
///
/// Sortiert nach Zustand, nicht nach Häufigkeit: Was man im schlechtesten
/// Zustand braucht, steht oben und ist farbig. Wer scrollt, hat Kapazität
/// dafür — wer nicht scrollen kann, findet trotzdem, was hilft.
enum AnchorSection {
  whenHard(AnchorEmphasis.solid),
  everyday(AnchorEmphasis.quiet),
  whenCalm(AnchorEmphasis.quiet);

  const AnchorSection(this.emphasis);

  final AnchorEmphasis emphasis;

  /// Die Überschrift der Gruppe in der Sprache der Nutzerin.
  ///
  /// Steht nicht als Feld im Enum, weil ein Enum einmal gebaut wird und die
  /// Sprache sich danach noch ändern kann.
  String label(AppLocalizations l10n) {
    switch (this) {
      case AnchorSection.whenHard:
        return l10n.anchorSectionWhenHard;
      case AnchorSection.everyday:
        return l10n.anchorSectionEveryday;
      case AnchorSection.whenCalm:
        return l10n.anchorSectionWhenCalm;
    }
  }
}

/// Eine benannte Gruppe von Einträgen.
///
/// W3C COGA nennt eine Fläche, auf der alle Einträge ohne Trennung
/// aneinanderstoßen, ausdrücklich schwer benutzbar: „chunks of content run
/// together in a flat design … losing all the benefits of chunking content."
/// Zwölf Zeilen hintereinander sind so eine Fläche.
///
/// Die Gruppe ist die Antwort darauf, ohne etwas zu verstecken: Alles bleibt
/// sichtbar und erreichbar, bekommt aber eine Überschrift und Abstand.
class AnchorGroup {
  const AnchorGroup({
    required this.label,
    required this.entries,
    this.emphasis = AnchorEmphasis.quiet,
  });

  final String label;
  final List<AnchorEntry> entries;

  /// Wie laut die Zeilen dieser Gruppe auftreten.
  final AnchorEmphasis emphasis;
}

/// Der Anker: Startort der App und einziger Ort, an dem gewechselt wird.
///
/// Zwei Bauformen, und die Grenze zwischen ihnen ist die, die Regel 4 der
/// Oberflächen-Richtlinien ohnehin zieht:
///
/// - **Halt, Notfall, Hilfe** stehen in einer festen Leiste am unteren Rand
///   (`AnchorActionBar`), in voller Farbe. Sie scrollen nicht.
/// - **Die neun anderen** stehen als Kacheln in zwei Spalten
///   (`AnchorTile`), ruhig, Farbe nur als Streifen.
///
/// Vorher waren es zwölf Zeilen à 110 dp untereinander — über drei
/// Bildschirmhöhen. Das beantwortete Prüffrage 6 („liegt etwas außerhalb des
/// Schirms?") schlecht: Halt stand oben, war aber weg, sobald jemand bis zum
/// Tagebuch gescrollt hatte. Zwei Spalten halbieren die Strecke, die feste
/// Leiste nimmt die drei wichtigsten Wege ganz aus dem Scrollbereich heraus.
///
/// Kein Karussell, keine verborgenen Einträge: Was nicht sichtbar ist, liegt
/// darunter und kommt beim Scrollen.
///
/// Der aktive Anteil stand hier als Karte über den Gruppen. Er steht jetzt in
/// der Titelzeile: Dort ist er ständig zu sehen, auch wenn man nach unten
/// gescrollt hat, und die Höhe, die er hier belegte, gehört der Zeitkarte.
class AnchorMenu extends StatelessWidget {
  const AnchorMenu({
    required this.groups,
    this.header,
    this.banner,
    super.key,
  });

  final List<AnchorGroup> groups;

  /// Der Kopfblock: Gruß, Name, Anteilswechsel, Begleiter.
  ///
  /// Steht **außerhalb** der Liste und scrollt deshalb nicht mit. Das ist
  /// keine Kosmetik: Der Name beantwortet „wer bin ich gerade?", und diese
  /// Antwort darf nicht nach zwei Fingerbreit verschwinden.
  final Widget? header;

  /// Der Block über den Gruppen: Passwort-Hinweis, Zeitkarte, Erinnerungen.
  ///
  /// Eine Funktion und kein fertiges Widget, weil sein größtes Stück — die
  /// Zeitkarte — eine Höhe wählen muss und diese Wahl nur mit der Fläche
  /// sinnvoll ist, die die Liste tatsächlich hat. Der Wert, den sie bekommt,
  /// ist genau diese Fläche: Was Kopf und Leiste übrig lassen, gemessen von
  /// Flutter, nicht geschätzt.
  ///
  /// Vorher stand dort eine 280, gesetzt an einer Stelle, die keine Fläche
  /// kennt. Auf dem S24 blieb darunter zu wenig für eine ganze Kachelreihe:
  /// „Chat" und „Kalender" zeigten beim Öffnen ihre Figur, aber nicht ihr
  /// Wort (Regel 5 — das Bild trägt, das Wort bestätigt; hier bestätigte
  /// nichts). Am 11. August 2026 am Gerät gesehen.
  final Widget Function(double verfuegbareHoehe)? banner;

  /// Was unter dem Bannerblock frei bleiben muss, damit die erste Kachelreihe
  /// beim Öffnen ganz im Bild steht.
  ///
  /// Gruppenüberschrift (28 Polster + gut 20 Schrift) plus eine Kachelreihe
  /// ([AnchorTile.minHeight] und ihre 5 dp Rand oben und unten).
  ///
  /// Gilt für normale Systemschrift. Bei 200 % wächst die Reihe über ihre
  /// Mindesthöhe hinaus und kann wieder anschneiden — dort trägt das
  /// Scrollen, und die ausgeblendete Kante zeigt, dass es weitergeht. Diese
  /// Reserve verspricht den ganzen Blick, nicht die ganze Schriftgröße.
  static const double reserveFuerErsteReihe = 50 + AnchorTile.minHeight + 10;

  @override
  Widget build(BuildContext context) {
    // Die lauten Gruppen wandern in die feste Leiste, die ruhigen ins Raster.
    // Die Aufteilung folgt der Betonung und nicht einer zweiten Liste, damit
    // es keinen Ort gibt, an dem beide auseinanderlaufen können.
    final quiet = groups
        .where((g) => g.emphasis != AnchorEmphasis.solid)
        .toList();
    final actions = [
      for (final group in groups)
        if (group.emphasis == AnchorEmphasis.solid)
          for (final entry in group.entries)
            AnchorAction(
              icon: entry.icon,
              label: entry.label,
              color: entry.color,
              onTap: entry.onTap,
              imageAsset: entry.imageAsset,
            ),
    ];

    final surface = Theme.of(context).colorScheme.surface;
    final tint = anchorTintOf(DateTime.now().hour);

    return DecoratedBox(
      // Die Tagestönung.
      //
      // Sie ersetzt die zwei Schatten, die Kopf und Leiste vorher von der
      // Liste trennten. Ein Schatten sagt „hier liegt etwas darüber" — richtig,
      // aber es macht aus drei Teilen drei Kästen. Der Verlauf sagt stattdessen
      // gar nichts und lässt die Teile ineinander übergehen.
      //
      // Sie setzt oben genau dort an, wo die Titelzeile aufhört (`main.dart`
      // führt denselben Verlauf über die Leiste), und ist nach gut einem
      // Drittel wieder weg — unten, wo die drei farbigen Knöpfe stehen,
      // konkurriert nichts mit ihnen.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(tint.withValues(alpha: 0.18), surface),
            surface,
          ],
          stops: const [0, 0.38],
        ),
      ),
      child: Column(
        children: [
          ?header,
          Expanded(
            // Hier und nicht in der Liste: In einer `ListView` ist die Höhe
            // nach unten offen, ein `LayoutBuilder` darin bekäme unendlich zu
            // hören. Eine Ebene darüber steht der Rest, den Kopf und Leiste
            // der Spalte übrig gelassen haben — gemessen, nicht geschätzt.
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fuerDenBlock =
                    constraints.maxHeight - AnchorMenu.reserveFuerErsteReihe;

                return _FadingEdges(
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: 8,
                      // Ohne Leiste trägt die Liste den Systemleisten-Abstand
                      // selbst. Mit Leiste bringt die ihn mit — sonst stünde er
                      // doppelt.
                      bottom:
                          24 +
                          _FadingEdges.fade +
                          (actions.isEmpty ? context.safeBottomPadding : 0),
                    ),
                    children: [
                      ?banner?.call(fuerDenBlock),
                      for (final group in quiet) ...[
                        _GroupHeading(group.label),
                        _TileGrid(entries: group.entries),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          AnchorActionBar(actions: actions),
        ],
      ),
    );
  }
}

/// Blendet die Liste an ihren beiden Kanten aus.
///
/// Am Gerät nachgesehen war das der eigentliche Befund: Beim Scrollen wurden
/// Kacheln an der Oberkante mitten im Wort abgeschnitten — „Medication" endete
/// auf halber Höhe, als wäre die Fläche kaputt. Der erste Versuch klebte einen
/// Schatten darüber, der die Kante erklärte. Ausgeblendet gibt es die Kante gar
/// nicht mehr: Was hinausläuft, wird leiser und ist weg, statt zu enden.
///
/// Zwei Fingerbreit reichen dafür. Mehr würde Inhalt schlucken, den man lesen
/// will, und die Liste hält unten ohnehin genug Polster, dass die letzte
/// Kachel nie im Verlauf stehen bleibt.
class _FadingEdges extends StatelessWidget {
  const _FadingEdges({required this.child});

  final Widget child;

  /// Höhe des Übergangs an je einer Kante.
  static const double fade = 24;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        // Auf sehr flachen Flächen — Querformat, geteilter Schirm — nähmen die
        // beiden Verläufe zusammen mehr Platz, als übrig bleibt. Dann lieber
        // eine harte Kante als eine Liste, die nur noch aus Übergang besteht.
        if (!height.isFinite || height <= fade * 4) return child;

        final edge = fade / height;

        return ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0, edge, 1 - edge, 1],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: child,
        );
      },
    );
  }
}

/// Die Kacheln einer Gruppe, zwei je Reihe.
///
/// Kein `GridView`: Der bräuchte ein festes Seitenverhältnis, und genau das
/// bricht bei 200 % Systemschrift — das Wort einer Kachel braucht dann zwei
/// Zeilen. Reihen aus zwei `Expanded` mit `IntrinsicHeight` wachsen
/// stattdessen mit und halten beide Kacheln einer Reihe gleich hoch.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.entries});

  final List<AnchorEntry> entries;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < entries.length; i += 2) {
      final left = entries[i];
      final right = i + 1 < entries.length ? entries[i + 1] : null;

      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _tile(left)),
              // Bleibt einer übrig, behält er die halbe Breite und der Platz
              // daneben bleibt leer. Ihn über die ganze Zeile zu ziehen würde
              // seinen Ort verschieben, sobald ein Recht dazukommt oder
              // wegfällt — Regel 7 sagt zu, dass Orte bleiben.
              Expanded(
                child: right == null ? const SizedBox.shrink() : _tile(right),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Column(children: rows),
    );
  }

  Widget _tile(AnchorEntry entry) => AnchorTile(
    icon: entry.icon,
    label: entry.label,
    color: entry.color,
    onTap: entry.onTap,
    imageAsset: entry.imageAsset,
  );
}

/// Die Überschrift einer Gruppe.
///
/// Klein und ruhig: Sie ordnet, sie wirbt nicht. Wer sie nicht liest, sieht
/// trotzdem den Abstand und erkennt daran, dass hier etwas anderes anfängt.
class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 10),
      // Normalschreibung, keine Versalien: Durchgehende Großbuchstaben nehmen
      // den Wörtern die Umrissform, an der geübte Leser sie erkennen, und
      // gelten für kognitiv belastete Leser als schwerer (W3C COGA). Der
      // Abstand darüber trägt die Gruppe ohnehin — die Schrift muss nicht
      // zusätzlich rufen.
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// Die Profilkarte stand einmal hier. Sie wird in `main.dart` gebaut, wo sie
// mit der Kopfzeile zusammenspielt; die Fassung an dieser Stelle wurde nie
// aufgerufen und war beim Durchlauf am 7. August eine zweite, leicht andere
// Wahrheit (Symbolgröße 28 statt 24). Eine Karte, ein Ort.
