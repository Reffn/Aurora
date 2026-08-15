import 'package:dis_app/core/delete_all_data.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:flutter/material.dart';

/// Der echte Löschweg als Vorgabewert.
///
/// Nicht `deleteAllLocalData` direkt: eine Funktionsreferenz als Vorgabewert
/// gilt dem Analyzer als verworfenes Ergebnis, weil `@useResult` darüber steht.
/// Der Umweg über einen Aufruf gibt das Ergebnis weiter — die Regel bleibt
/// scharf, statt hier abgeschaltet zu werden.
Future<DeleteAllResult> _echterLoeschweg() => deleteAllLocalData();

/// Was zu sehen ist, wenn der Start nicht gelingt.
///
/// Vorher stand hier ein Logo, das sich nicht mehr rührte — unbegrenzt und
/// ohne ein Wort. Diese Fläche folgt der Regel für Notfallwege: ruhig, ohne
/// Alarmfarbe, mit genau zwei Handlungen und ohne technische Einzelheiten.
///
/// Die zweite Handlung ist der Ausgang aus der Sackgasse. Scheitert der Start
/// an beschädigten Daten, hilft Wiederholen nie; nur Löschen kommt weiter.
/// Der Löschweg braucht keine angemeldeten Dienste — genau deshalb steht er
/// hier zur Verfügung.
class StartupFailureScreen extends StatefulWidget {
  const StartupFailureScreen({
    required this.onRetry,
    this.deleteAllData = _echterLoeschweg,
    super.key,
  });

  final Future<void> Function() onRetry;

  /// Der Löschweg, damit ein Test ihn ersetzen kann. Ohne diese Naht müsste
  /// jede Prüfung dieser Fläche echte Boxen löschen.
  final Future<DeleteAllResult> Function() deleteAllData;

  @override
  State<StartupFailureScreen> createState() => _StartupFailureScreenState();
}

class _StartupFailureScreenState extends State<StartupFailureScreen> {
  bool _busy = false;
  bool _unvollstaendig = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.startupFailedTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.startupFailedBody,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_unvollstaendig) ...[
                  Text(
                    l10n.startupDeleteIncomplete,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
                FilledButton(
                  onPressed: _busy ? null : () => _run(widget.onRetry),
                  child: Text(l10n.startupRetry),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                          final ergebnis = await widget.deleteAllData();
                          if (!ergebnis.isComplete) {
                            // Kein Neustart. Ein Start über verbliebenen
                            // Daten sähe aus wie ein geglücktes Löschen.
                            if (mounted) {
                              setState(() => _unvollstaendig = true);
                            }
                            return;
                          }
                          await widget.onRetry();
                        }),
                  child: Text(l10n.startupDeleteAll),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Die Fehlerfläche als eigene App — es gibt zu diesem Zeitpunkt keine.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({
    required this.onRetry,
    this.deleteAllData = _echterLoeschweg,
    super.key,
  });

  final Future<void> Function() onRetry;
  final Future<DeleteAllResult> Function() deleteAllData;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(AppTexts.current.localeName),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StartupFailureScreen(
        onRetry: onRetry,
        deleteAllData: deleteAllData,
      ),
    );
  }
}
