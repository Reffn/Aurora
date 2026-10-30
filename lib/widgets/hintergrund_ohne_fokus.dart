import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Hält Schirme, die unter dem aktuellen liegen, vom Fokus fern.
///
/// Flutter schützt Routen im Hintergrund nicht. `autofocus` greift, sobald der
/// Fokusbereich einer Route nichts fokussiert hat — und eine Route unter dem
/// aktuellen Schirm hat nie etwas fokussiert. Wird dort etwas mit `autofocus`
/// neu eingehängt, zieht es den Fokus aus dem Schirm davor.
///
/// Genau das schloss im Herbst 2026 die Tastatur, sobald sie aufging
/// (Rückmeldungen vom 29.09. und 05.10.): Die Tastatur verkleinert auch die
/// Route darunter, die Profilauswahl wechselte dabei den Layoutzweig, hängte
/// ihre Karte neu ein, und die Karte griff sich den Fokus. Niemand konnte
/// einen Namen tippen. Die Karte ist an ihrer Stelle entschärft; diese Sperre
/// sorgt dafür, dass der nächste Greifer im Hintergrund nicht dasselbe tut.
///
/// Eingehängt über `ThemeData.pageTransitionsTheme`, damit sie für jede
/// `MaterialPageRoute` gilt, ohne dass eine einzige Aufrufstelle davon wissen
/// muss. Der Übergang selbst bleibt der des Systems.
class HintergrundOhneFokus extends PageTransitionsBuilder {
  const HintergrundOhneFokus(this.uebergang);

  /// Der Übergang, der gezeichnet wird. Diese Klasse ändert nur den Fokus.
  final PageTransitionsBuilder uebergang;

  /// Die Übergänge des Systems, jeder mit der Sperre davor.
  static final PageTransitionsTheme theme = PageTransitionsTheme(
    builders: {
      for (final eintrag in const PageTransitionsTheme().builders.entries)
        eintrag.key: HintergrundOhneFokus(eintrag.value),
    },
  );

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      uebergang.delegatedTransition;

  @override
  Duration get transitionDuration => uebergang.transitionDuration;

  @override
  Duration get reverseTransitionDuration => uebergang.reverseTransitionDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return uebergang.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      _Sperre(vorn: route.isCurrent, child: child),
    );
  }
}

class _Sperre extends StatefulWidget {
  const _Sperre({required this.vorn, required this.child});

  final bool vorn;
  final Widget child;

  @override
  State<_Sperre> createState() => _SperreState();
}

class _SperreState extends State<_Sperre> {
  /// Was in dieser Route zuletzt den Fokus hatte, als sie nach hinten ging.
  FocusNode? _gemerkt;

  @override
  void didUpdateWidget(_Sperre alt) {
    super.didUpdateWidget(alt);
    if (alt.vorn && !widget.vorn) {
      // Jetzt merken, nicht beim Zurückkommen: Beim Zurückkommen fragt
      // Flutter den Fokusbereich nach seinem letzten Feld, *bevor* diese
      // Sperre sich öffnet. Ein gesperrtes Feld gilt dann als nicht
      // fokussierbar und fällt aus der Erinnerung des Bereichs — der Bereich
      // fokussiert sich selbst, und die Tastatur käme nach keinem Dialog
      // mehr zurück.
      _gemerkt = FocusScope.of(context).focusedChild;
    } else if (!alt.vorn && widget.vorn) {
      final gemerkt = _gemerkt;
      _gemerkt = null;
      if (gemerkt == null) return;
      final bereich = FocusScope.of(context);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // Nur zurückgeben, wenn der Fokus auf dem Bereich selbst geparkt ist.
        // Hat inzwischen etwas anderes ihn bekommen, war das gewollt.
        if (!mounted || FocusManager.instance.primaryFocus != bereich) return;
        if (gemerkt.context == null || !gemerkt.canRequestFocus) return;
        gemerkt.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(excluding: !widget.vorn, child: widget.child);
  }
}
