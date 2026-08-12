import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/utils/contact_config.dart';
import 'package:dis_app/utils/enhanced_debug_report_generator.dart';
import 'package:dis_app/widgets/error_report_dialog.dart';
import 'package:flutter/material.dart';

/// Crash Boundary Widget - fängt Widget-Build-Errors ab
///
/// Verhindert dass die ganze App crasht wenn ein einzelnes Widget einen Fehler wirft.
/// Zeigt stattdessen eine freundliche Error-UI mit Option, Report zu senden.
///
/// Verwendung:
/// ```dart
/// CrashBoundary(
///   child: MainScreen(),
/// )
/// ```
class CrashBoundary extends StatefulWidget {
  const CrashBoundary({
    required this.child,
    this.fallback,
    super.key,
  });

  /// Das Child-Widget das geschützt werden soll
  final Widget child;

  /// Optional: Custom Fallback-UI bei Fehler
  final Widget Function(BuildContext context, Object error, StackTrace stack)?
  fallback;

  @override
  State<CrashBoundary> createState() => _CrashBoundaryState();
}

class _CrashBoundaryState extends State<CrashBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  /// Der Builder, der vor dieser Boundary galt.
  ///
  /// `ErrorWidget.builder` ist global. Wer ihn setzt, muss ihn auch
  /// zuruecklegen — sonst zeigt eine laengst ausgehaengte Boundary noch auf
  /// ihren Closure, und bei verschachtelten Boundaries faengt die falsche.
  late final ErrorWidgetBuilder _previousErrorWidgetBuilder;

  @override
  void initState() {
    super.initState();
    // Bewusst hier und nicht in build(): build laeuft bei jedem Rebuild und
    // darf nichts ausserhalb dieses Widgets veraendern.
    _previousErrorWidgetBuilder = ErrorWidget.builder;
    ErrorWidget.builder = _catchBuildError;
  }

  @override
  void dispose() {
    ErrorWidget.builder = _previousErrorWidgetBuilder;
    super.dispose();
  }

  /// Faengt Build-Fehler aus dem geschuetzten Teilbaum ab.
  Widget _catchBuildError(FlutterErrorDetails details) {
    // Ein Fehler in der Fallback-UI darf nicht erneut umschalten, sonst
    // dreht sich setState -> build -> Fehler im Kreis.
    if (_error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _error != null) return;

        setState(() {
          _error = details.exception;
          // Ohne Stack bliebe die Fallback-UI aus und der Fehler waere
          // verschluckt — lieber ein leerer Stack als gar keine Anzeige.
          _stackTrace = details.stack ?? StackTrace.empty;
        });

        // Logge Error
        logger.critical(
          LogCategory.ui,
          'Widget build error caught by CrashBoundary',
          data: {'error': details.exception.toString()},
          stackTrace: details.stack,
        );
      });
    }

    // Bis der naechste Frame umschaltet, bleibt die Stelle leer
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _stackTrace != null) {
      // Error gefangen - zeige Fallback-UI
      if (widget.fallback != null) {
        return widget.fallback!(context, _error!, _stackTrace!);
      }

      return _buildDefaultErrorUI();
    }

    return widget.child;
  }

  /// Baut die Fallback-UI — und den Rahmen dazu, falls er fehlt.
  ///
  /// In main.dart haengt die Boundary ueber der MaterialApp. Dort gibt es
  /// weder Directionality noch Material-Localizations noch Navigator; ein
  /// nacktes Scaffold wirft dann selbst, und uebrig bleibt ein schwarzer
  /// Bildschirm ohne jeden Hinweis. Genau die Stelle, an der ein
  /// Sicherheitsnetz halten muss.
  Widget _buildDefaultErrorUI() {
    if (Directionality.maybeOf(context) != null) {
      return _buildErrorScaffold(context);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(builder: _buildErrorScaffold),
    );
  }

  Widget _buildErrorScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Error Message
              Text(
                AppTexts.current.crashTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppTexts.current.crashMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Error Details (collapsed)
              ExpansionTile(
                title: Text(AppTexts.current.crashTechnicalDetails),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      '${_error.runtimeType}: $_error\n\n$_stackTrace',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fehler melden
                  ElevatedButton.icon(
                    onPressed: () => _showErrorReportDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(ContactConfig.auroraPurple),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.bug_report),
                    label: Text(AppTexts.current.crashReport),
                  ),
                  const SizedBox(height: 12),

                  // App neu starten
                  OutlinedButton.icon(
                    onPressed: () => _restartApp(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(AppTexts.current.crashRestart),
                  ),
                  const SizedBox(height: 12),

                  // Trotzdem fortfahren
                  TextButton(
                    onPressed: _clearError,
                    child: Text(AppTexts.current.crashContinue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Zeigt Error Report Dialog
  ///
  /// [context] ist der Kontext unterhalb der Fallback-UI, nicht der des
  /// States: nur dort steht ein Navigator, wenn die Boundary ueber der
  /// MaterialApp haengt.
  Future<void> _showErrorReportDialog(BuildContext context) async {
    if (_error == null || _stackTrace == null) return;

    // Generiere Crash Report
    final report = await EnhancedDebugReportGenerator.generateCrashReport(
      error: _error!,
      stackTrace: _stackTrace!,
      context: 'Widget Build Error (CrashBoundary)',
    );

    if (!mounted || !context.mounted) return;

    // Zeige Dialog
    await showDialog<void>(
      context: context,
      builder: (_) => ErrorReportDialog(
        reportContent: report,
        errorType: _error.runtimeType.toString(),
        isCrash: true,
      ),
    );
  }

  /// Setzt Error zurück (versucht App fortzusetzen)
  void _clearError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });

    logger.info(
      LogCategory.ui,
      'User chose to continue after widget error',
    );
  }

  /// Startet App neu (Navigator reset)
  void _restartApp(BuildContext context) {
    // Clear error
    setState(() {
      _error = null;
      _stackTrace = null;
    });

    // Pop to root — ueber der MaterialApp gibt es keinen Navigator, dann
    // genuegt das Zuruecksetzen des Fehlers oben.
    Navigator.maybeOf(context)?.popUntil((route) => route.isFirst);

    logger.info(
      LogCategory.ui,
      'App restarted after widget error',
    );
  }
}

/// Global Error Boundary - wraps entire app
///
/// Verwendung in main.dart:
/// ```dart
/// runApp(
///   GlobalErrorBoundary(
///     child: MyApp(),
///   ),
/// );
/// ```
class GlobalErrorBoundary extends StatelessWidget {
  const GlobalErrorBoundary({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => CrashBoundary(child: child);
}
