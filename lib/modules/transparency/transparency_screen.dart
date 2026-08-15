import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:dis_app/services/transmission_log_service.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Liest die Einträge des Übertragungsprotokolls.
typedef TransmissionLogReader = List<TransmissionLogEntry> Function();

/// Löscht einen Eintrag aus dem Übertragungsprotokoll.
typedef TransmissionLogEraser = Future<void> Function(String id);

class TransparencyScreen extends StatelessWidget {
  const TransparencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: AppLocalizations.of(context).settingsWhatAuroraSends,
      ),
      body: const TransparencyList(),
    );
  }
}

/// Die Liste selbst, ohne Rahmen.
///
/// Getrennt vom [TransparencyScreen], damit sie prüfbar ist: Die
/// [StandardAppBar] holt sich die Profilfarbe aus der DI und wirft im
/// Widget-Test, wo keine eingerichtet ist. Getestet wird dieses Widget —
/// dasselbe, das der Bildschirm einsetzt, kein Nachbau.
class TransparencyList extends StatefulWidget {
  const TransparencyList({
    super.key,
    this.readLog,
    this.eraseEntry,
    this.consent,
    this.clearTelemetryQueue,
  });

  /// Nur für Tests. Ohne Angabe kommt alles aus der DI.
  ///
  /// Funktionen statt des Dienstes, wie bei MailtoTransport und seinem
  /// UrlLauncher: Der Dienst schreibt über Hive echte Dateien, und echte
  /// Datei-Ein-/Ausgabe blockiert in einem Widget-Test.
  final TransmissionLogReader? readLog;
  final TransmissionLogEraser? eraseEntry;
  final TelemetryConsent? consent;
  final Future<void> Function()? clearTelemetryQueue;

  @override
  State<TransparencyList> createState() => _TransparencyListState();
}

class _TransparencyListState extends State<TransparencyList> {
  late final TransmissionLogReader _readLog;
  late final TransmissionLogEraser _eraseEntry;
  late List<TransmissionLogEntry> _entries;

  @override
  void initState() {
    super.initState();
    _readLog = widget.readLog ?? getIt<TransmissionLogService>().all;
    _eraseEntry = widget.eraseEntry ?? getIt<TransmissionLogService>().delete;
    _reload();
  }

  TelemetryConsent? get _consent {
    if (widget.consent != null) return widget.consent;
    return getIt.isRegistered<TelemetryConsent>()
        ? getIt<TelemetryConsent>()
        : null;
  }

  void _reload() {
    setState(() => _entries = _readLog());
  }

  Future<void> _delete(String id) async {
    await _eraseEntry(id);
    _reload();
  }

  /// Vor dem Löschen fragen — und dabei sagen, was das Löschen bedeutet.
  /// Der Eintrag verschwindet vom Gerät; das bereits Gesendete holt das nicht
  /// zurück. Wer das verwechselt, wiegt sich in falscher Sicherheit.
  Future<bool> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transparencyDeleteTitle),
        content: Text(l10n.transparencyDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _setTelemetry({required bool an}) async {
    final consent = _consent;
    if (consent == null) return;

    if (an) {
      await consent.grant();
    } else {
      await consent.revoke();
      // Der Widerruf wirkt sofort auf die Erzeugung, nicht erst auf den
      // Versand: Was noch in der Warteschlange liegt, geht nicht mehr raus.
      final clear =
          widget.clearTelemetryQueue ??
          (getIt.isRegistered<TelemetryRecorder>()
              ? getIt<TelemetryRecorder>().clearQueue
              : null);
      await clear?.call();
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Beide Gruppen stehen immer da, auch leer. Richtlinie 3: gruppieren,
    // nicht verstecken — und ein leerer Abschnitt ist hier keine Fehlmeldung,
    // sondern der Beleg, dass auf diesem Weg nichts das Gerät verlassen hat.
    final items = <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(l10n.transparencyIntroFull),
      ),
      const _GroupHeading('Feedback'),
      ..._sectionFor(TransmissionChannel.feedback),
      const SizedBox(height: 24),
      _GroupHeading(l10n.transparencyGroupTelemetry),
      if (_consent != null) _telemetrySwitch(),
      ..._sectionFor(TransmissionChannel.telemetry),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  List<Widget> _sectionFor(TransmissionChannel channel) {
    final entries = _entries
        .where((entry) => entry.channel == channel)
        .toList();

    if (entries.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(AppLocalizations.of(context).transparencyNothingSent),
        ),
      ];
    }

    return entries.map(_buildEntry).toList();
  }

  Widget _telemetrySwitch() {
    final l10n = AppLocalizations.of(context);
    return SwitchListTile(
      key: const Key('telemetry_toggle'),
      value: _consent!.allowsRecording,
      title: Text(l10n.transparencySendUsageData),
      subtitle: Text(l10n.transparencyIrreversibleFull),
      onChanged: (an) => _setTelemetry(an: an),
    );
  }

  Widget _buildEntry(TransmissionLogEntry entry) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Icon(Icons.delete_outline),
      ),
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) => _delete(entry.id),
      child: Card(
        child: ExpansionTile(
          leading: _statusIcon(entry.status),
          title: Text(_formatTimestamp(entry.timestamp)),
          subtitle: Text(_statusLabel(context, entry)),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(entry.payloadText),
            ),
          ],
        ),
      ),
    );
  }

  Icon _statusIcon(TransmissionStatus status) => switch (status) {
    TransmissionStatus.sent => const Icon(Icons.check_circle_outline),
    TransmissionStatus.pending => const Icon(Icons.schedule),
    TransmissionStatus.failed => const Icon(Icons.error_outline),
  };

  String _statusLabel(BuildContext context, TransmissionLogEntry entry) {
    final l10n = AppLocalizations.of(context);
    return switch (entry.status) {
      TransmissionStatus.sent => l10n.transparencyArrived,
      TransmissionStatus.pending => l10n.transparencyWaitingForConnection,
      TransmissionStatus.failed => l10n.transparencyNotSent(
        entry.errorMessage ?? l10n.transparencyReasonUnknown,
      ),
    };
  }

  /// Datum und Uhrzeit in der Schreibweise der eingestellten Sprache.
  ///
  /// Vorher stand hier ein selbstgebautes Muster mit angehängtem „Uhr" —
  /// in der französischen Oberfläche las sich das als „05.08.2026, 23:39 Uhr".
  String _formatTimestamp(DateTime t) =>
      '${DateFormat.yMd().format(t)}, ${DateFormat.jm().format(t)}';
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
