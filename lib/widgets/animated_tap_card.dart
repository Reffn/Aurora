import 'package:flutter/material.dart';

/// Card mit Micro-Interactions (Scale + Shadow Animation)
/// Verwendung: Wrapper um Card-Content für besseres haptisches Feedback
class AnimatedTapCard extends StatefulWidget {
  const AnimatedTapCard({
    required this.onTap,
    required this.child,
    this.borderRadius = 16.0,
    super.key,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double borderRadius;

  @override
  State<AnimatedTapCard> createState() => _AnimatedTapCardState();
}

class _AnimatedTapCardState extends State<AnimatedTapCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isPressed ? 0.3 : 0.15),
              blurRadius: _isPressed ? 12 : 4,
              spreadRadius: _isPressed ? 2 : 0,
              offset: Offset(0, _isPressed ? 6 : 2),
            ),
          ],
        ),
        child: Card(
          elevation: 0, // Wir nutzen custom shadow
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: InkWell(
            onTapDown: widget.onTap != null
                ? (_) => setState(() => _isPressed = true)
                : null,
            onTapUp: widget.onTap != null
                ? (_) => setState(() => _isPressed = false)
                : null,
            onTapCancel: widget.onTap != null
                ? () => setState(() => _isPressed = false)
                : null,
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
