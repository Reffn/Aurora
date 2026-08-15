import 'package:flutter/material.dart';

/// Leiste am unteren Bildschirmrand für die Hauptaktion eines Screens.
///
/// **Als Layout-Element einsetzen, nicht als Overlay.** Gehört als letztes Kind
/// in eine [Column], deren Inhalt darüber in einem [Expanded] liegt:
///
/// ```dart
/// Column(
///   children: [
///     Expanded(child: PageView(...)),
///     BottomActionBar(child: MyButton()),
///   ],
/// )
/// ```
///
/// Der Unterschied ist nicht kosmetisch. Liegt die Leiste stattdessen in einem
/// [Stack] über dem Inhalt, kennt der Scrollbereich sie nicht: Beim Tippen
/// schiebt Flutter das fokussierte Feld nur bis zum Rand des Scrollbereichs —
/// und der endet hinter der Leiste. Das Feld bleibt verdeckt, während man
/// hineinschreibt.
///
/// Als Layout-Element schrumpft der Inhalt darüber stattdessen um die
/// Leistenhöhe, und der Scaffold zieht bei geöffneter Tastatur zusätzlich deren
/// Höhe ab. Beides erledigt Flutter dann von selbst, ohne Rechnerei mit
/// `viewInsets`.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    required this.child,
    this.horizontalPadding = 32,
    super.key,
  });

  final Widget child;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          8,
          horizontalPadding,
          16,
        ),
        child: child,
      ),
    );
  }
}
