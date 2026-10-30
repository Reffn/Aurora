import 'dart:async';

import 'package:flutter/widgets.dart';

/// Baut sein Kind einmal pro Minute neu — im Takt der Uhr, nicht der Widgets.
///
/// Nur die Anzeige tickt: Die Daten kommen weiter vom Aufbau durch den
/// Aufrufer. Eine Minute ist die Auflösung, in der Zeitkarte und Zeitband
/// sprechen; öfter neu zu bauen zeigte nichts Neues.
///
/// Stand bis 3.0.25 privat in `time_map.dart`. Das Zeitband braucht denselben
/// Takt: Eine stehende Uhr ist für Menschen, die sich an genau dieser Zeile
/// orientieren, schlimmer als keine.
class EveryMinute extends StatefulWidget {
  const EveryMinute({required this.builder, super.key});

  final WidgetBuilder builder;

  @override
  State<EveryMinute> createState() => _EveryMinuteState();
}

class _EveryMinuteState extends State<EveryMinute> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
