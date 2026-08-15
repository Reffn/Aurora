import 'dart:async';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:flutter/material.dart';

/// Die Frage nach der Einwilligung zur Telemetrie.
///
/// Ein eigener Schirm, kein Schritt im Onboarding: `PreOnboardingScreen` ist
/// mit „Nicht mehr anzeigen" überspringbar, und ein Schritt darin würde von
/// genau den Menschen nie gesehen, die zügig durchklicken. Derselbe Schirm
/// erreicht damit auch die bestehenden Nutzerinnen beim ersten Start nach dem
/// Update — ein Mechanismus, zwei Anlässe.
///
/// Richtlinien, die hier zählen:
/// - 5: Das Bild trägt, das Wort bestätigt. Symbol und Text, nie eines allein.
/// - 6: 110 dp Bedienhöhe, weil WCAG 2.2 „more for unsteady hands" sagt.
/// - 10: Es steht dort, was nach der Antwort passiert, und man kann es ändern.
/// - Beide Knöpfe sind gleich groß. Eine visuelle Bevorzugung wäre keine
///   freiwillige Einwilligung im Sinne von DSGVO Art. 9.
class TelemetryConsentScreen extends StatelessWidget {
  const TelemetryConsentScreen({
    required this.onDecided,
    this.consent,
    this.appVersion,
    this.today,
    super.key,
  });

  static const String routeName = '/telemetry-consent';

  /// Wird nach beiden Antworten aufgerufen. Der Ablauf läuft danach
  /// identisch weiter — sonst wäre die Einwilligung nicht freiwillig.
  final VoidCallback onDecided;

  /// Injizierbar für Tests.
  final TelemetryConsent? consent;

  /// Injizierbar für Tests; sonst die Version, die auch gesendet wird.
  final String? appVersion;

  /// Injizierbar für Tests; sonst der heutige Tag.
  final DateTime? today;

  static const double _buttonHeight = 110;

  TelemetryConsent _consent() => consent ?? getIt<TelemetryConsent>();

  /// Das Beispiel entsteht aus denselben Werten wie der echte Versand.
  ///
  /// Hier standen die drei Zeilen als Text im Code, mit „3.2.0" und einem
  /// festen Tag. Beides driftete von der App weg, und niemand merkt es, weil
  /// nichts es prüft. Jetzt kommen Ereignisname, Tagesformat und Version aus
  /// dem Schema und dem Recorder — was sich dort ändert, ändert sich hier mit.
  String _beispiel(AppLocalizations l10n) {
    final version =
        appVersion ??
        (getIt.isRegistered<TelemetryRecorder>()
            ? getIt<TelemetryRecorder>().appVersion
            : l10n.commonUnknown);
    final tag = TelemetryEvent.formatDay(today ?? DateTime.now());

    return '${l10n.telemetryExampleEvent}: '
        '${TelemetryEventName.bereichGeoeffnetChat.wireName}\n'
        '${l10n.telemetryExampleDay}: $tag\n'
        '${l10n.telemetryExampleVersion}: $version';
  }

  Future<void> _answer({required bool zustimmen}) async {
    if (zustimmen) {
      await _consent().grant();
    } else {
      await _consent().deny();
    }
    onDecided();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Der Text scrollt, die Knöpfe bleiben stehen. Prüffrage 6:
              // Nichts liegt außerhalb des Schirms, das man nicht erreicht.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      // Kleiner als vorher (72). Das Symbol trägt die Fläche
                      // an, aber es darf nicht das Beispiel unter die Kante
                      // schieben — siehe die Reihenfolge gleich darunter.
                      Icon(
                        Icons.insights,
                        size: 56,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.telemetryQuestion,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Das Beispiel steht vor der Erklärung.
                      //
                      // Vorher lag es darunter und damit unter der Kante,
                      // während beide Knöpfe ohne Scrollen erreichbar waren:
                      // Man konnte zustimmen, ohne je gesehen zu haben, wozu.
                      // Die Erklärung ist Prosa, das Beispiel ist die Sache
                      // selbst — also kommt die Sache zuerst.
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.telemetryExampleIntro,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            // Die Beschriftungen sprechen die Sprache der
                            // Nutzerin, der Ereignisname nicht: er steht so im
                            // Versand und waere uebersetzt nicht mehr dasselbe,
                            // was gesendet wird.
                            Text(
                              _beispiel(l10n),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.telemetryExplanation,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      // Richtlinie 10: sagen, was danach passiert.
                      Text(
                        l10n.telemetryChangeLater,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _ChoiceButton(
                key: const Key('telemetry_yes'),
                icon: Icons.favorite,
                label: l10n.telemetryConsentAccept,
                height: _buttonHeight,
                onPressed: () => unawaited(_answer(zustimmen: true)),
              ),
              const SizedBox(height: 12),
              _ChoiceButton(
                key: const Key('telemetry_no'),
                icon: Icons.arrow_forward,
                label: l10n.telemetryConsentDecline,
                height: _buttonHeight,
                onPressed: () => unawaited(_answer(zustimmen: false)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Beide Antworten tragen dieselbe Form. Kein Knopf ist lauter als der andere.
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.icon,
    required this.label,
    required this.height,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
