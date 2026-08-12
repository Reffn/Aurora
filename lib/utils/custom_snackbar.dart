import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
  info,
  warning,
}

/// Custom SnackBar mit Slide-Animation und Profil-Farbe
/// Verwendung: showCustomSnackBar(context, message: 'Text', type: SnackBarType.success)
void showCustomSnackBar(
  BuildContext context, {
  required String message,
  SnackBarType type = SnackBarType.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  final profileColor = Theme.of(context).colorScheme.primary;

  // Farbe basierend auf Typ
  Color getColor() {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
        return profileColor;
    }
  }

  // Icon basierend auf Typ
  IconData getIcon() {
    if (icon != null) return icon;
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
    }
  }

  final color = getColor();
  final iconData = getIcon();

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(begin: const Offset(0, -1), end: Offset.zero),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, offset, child) => FractionalTranslation(
          translation: offset,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(iconData, color: color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: () => overlayEntry.remove(),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Auto-remove nach duration
  Future<void>.delayed(duration).then((_) {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}
