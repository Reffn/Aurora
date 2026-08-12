/// Entscheidet, ob Aurora nach einer Unterbrechung erneut nach dem aktiven
/// Anteil fragen soll.
///
/// Die App selbst bleibt dabei am Leben. Nur der Anteil wird nach einer
/// längeren Abwesenheit erneut bestätigt. Der Vergleich beim Zurückkehren ist
/// zuverlässiger als ein Timer, den Android im Hintergrund anhalten kann.
class ProfileSessionPolicy {
  ProfileSessionPolicy({this.timeout = defaultTimeout});

  static const defaultTimeout = Duration(minutes: 15);

  final Duration timeout;
  DateTime? _pausedAt;

  /// Merkt den Beginn der Abwesenheit. Doppelte Lifecycle-Meldungen dürfen
  /// die bereits verstrichene Zeit nicht verkürzen.
  void paused(DateTime at) {
    _pausedAt ??= at;
  }

  /// Verbraucht die gemerkte Abwesenheit und meldet, ob eine neue Profilwahl
  /// nötig ist.
  bool resumed(DateTime at) {
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null || at.isBefore(pausedAt)) return false;

    return at.difference(pausedAt) >= timeout;
  }
}
