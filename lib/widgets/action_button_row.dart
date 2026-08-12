import 'package:dis_app/utils/app_spacing.dart';
import 'package:flutter/material.dart';

/// Konfiguration für einen Action-Button
class ActionButtonConfig {
  const ActionButtonConfig({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.filled = false,
    this.tooltip,
    this.loading = false,
  });

  /// Button-Text
  final String label;

  /// Callback beim Drücken (wird disabled wenn loading = true)
  final VoidCallback? onPressed;

  /// Optional: Icon vor dem Text
  final IconData? icon;

  /// Button-Farbe (default: Theme primary)
  final Color? color;

  /// Filled Button (true) oder Outlined Button (false)
  final bool filled;

  /// Optional: Tooltip-Text der bei Hover/Long-Press angezeigt wird
  final String? tooltip;

  /// Loading-State: Zeigt Spinner und disabled Button
  final bool loading;
}

/// Wiederverwendbare Action-Button-Row
///
/// Zeigt mehrere Buttons nebeneinander an, alle gleich breit (Expanded).
/// Automatisches Spacing zwischen Buttons.
///
/// **Verwendet für:**
/// - Medication: Genommen/Verweigert/Später
/// - Contact Cards: Anrufen/SMS/App
/// - Dialogs: Cancel/Discard/Save
///
/// Beispiele:
/// ```dart
/// ActionButtonRow(
///   buttons: [
///     ActionButtonConfig(
///       label: "Genommen",
///       icon: Icons.check,
///       color: Colors.green,
///       filled: true,
///       onPressed: () => ...,
///     ),
///     ActionButtonConfig(
///       label: "Verweigert",
///       icon: Icons.close,
///       color: Colors.red,
///       onPressed: () => ...,
///     ),
///     ActionButtonConfig(
///       label: "Später",
///       icon: Icons.schedule,
///       color: Colors.orange,
///       onPressed: () => ...,
///     ),
///   ],
/// )
/// ```
class ActionButtonRow extends StatelessWidget {
  const ActionButtonRow({
    required this.buttons,
    super.key,
    this.spacing = 8,
    this.height = 44,
  });

  /// Liste der Button-Konfigurationen
  final List<ActionButtonConfig> buttons;

  /// Spacing zwischen Buttons
  final double spacing;

  /// Höhe der Buttons (optional)
  final double? height;

  /// Ab dieser Breite je Knopf passen Symbol und Beschriftung nebeneinander.
  ///
  /// Darunter wurde die Beschriftung gekürzt, und aus „Bearbeiten", „Löschen"
  /// und „Kommentare" wurde „Bea…", „Lös…", „Ko…" — drei Knöpfe, die keiner
  /// mehr auseinanderhalten konnte. In den romanischen Sprachen trifft das
  /// noch häufiger zu, weil die Wörter dort länger sind.
  static const double _sideBySideMinWidth = 132;

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final perButton =
            (constraints.maxWidth - spacing * (buttons.length - 1)) /
            buttons.length;
        final stacked = perButton < _sideBySideMinWidth;

        return SizedBox(
          height: stacked ? 62 : height,
          child: Row(
            children: [
              for (var i = 0; i < buttons.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                Expanded(
                  child: _buildButton(context, buttons[i], stacked: stacked),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    ActionButtonConfig config, {
    bool stacked = false,
  }) {
    // Button Style
    final buttonColor = config.color ?? Theme.of(context).colorScheme.primary;

    // Icon: Spinner bei loading, sonst normales Icon
    final iconWidget = config.loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : (config.icon != null
              ? Icon(config.icon, size: 18)
              : const SizedBox.shrink());

    // Enger Platz: Symbol über die Beschriftung, nicht daneben. So bleibt
    // das ganze Wort stehen, statt auf drei Buchstaben zu schrumpfen.
    final label = Text(
      config.label,
      style: TextStyle(fontSize: stacked ? 11 : 13),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    final stackedChild = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: 3),
        label,
      ],
    );

    final padding = EdgeInsets.symmetric(
      horizontal: stacked ? AppSpacing.xs : AppSpacing.md,
      vertical: stacked ? AppSpacing.xs : AppSpacing.sm + 2,
    );

    // Button erstellen
    final Widget button;
    if (config.filled) {
      final style = FilledButton.styleFrom(
        backgroundColor: buttonColor,
        padding: padding,
      );
      button = stacked
          ? FilledButton(
              onPressed: config.loading ? null : config.onPressed,
              style: style,
              child: stackedChild,
            )
          : FilledButton.icon(
              onPressed: config.loading ? null : config.onPressed,
              icon: iconWidget,
              label: label,
              style: style,
            );
    } else {
      final style = OutlinedButton.styleFrom(
        foregroundColor: buttonColor,
        side: BorderSide(color: buttonColor),
        padding: padding,
      );
      button = stacked
          ? OutlinedButton(
              onPressed: config.loading ? null : config.onPressed,
              style: style,
              child: stackedChild,
            )
          : OutlinedButton.icon(
              onPressed: config.loading ? null : config.onPressed,
              icon: iconWidget,
              label: label,
              style: style,
            );
    }

    // Tooltip wrappen wenn vorhanden
    if (config.tooltip != null) {
      return Tooltip(
        message: config.tooltip,
        child: button,
      );
    }

    return button;
  }
}
