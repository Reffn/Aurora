import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Wiederverwendbares animiertes ListView Widget
/// Verwendung: Wrapper um ListView.builder für staggered slide+fade Animationen
class AnimatedListView extends StatelessWidget {
  const AnimatedListView({
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    super.key,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: padding,
        physics: physics,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: itemBuilder(context, index),
              ),
            ),
          );
        },
      ),
    );
  }
}
