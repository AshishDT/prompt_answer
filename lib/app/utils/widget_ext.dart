import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../data/config/app_colors.dart';

/// Extension for widget
extension WidgetExt on Widget {
  /// Wraps the widget with padding to avoid system gesture insets
  Widget withGPad(
    BuildContext context, {
    Color color = AppColors.kffffff,
    BoxDecoration? decoration,
  }) {
    final double bottom = MediaQuery.of(context).systemGestureInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottom + 5),
      color: decoration != null ? null : color,
      child: this,
      decoration: decoration,
    );
  }

  /// Wraps the widget with an AnimatedSwitcher for smooth transitions
  Widget animate({
    int? position,
    double verticalOffset = 20,
    double horizontalOffset = 0,
    bool limiter = false,
    Duration? delay,
  }) {
    if (this is ListView || limiter) {
      return AnimationLimiter(child: this);
    }
    if (position == null) {
      return this;
    }
    return AnimationConfiguration.staggeredList(
      position: position,
      delay: delay,
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        delay: delay,
        verticalOffset: verticalOffset,
        horizontalOffset: horizontalOffset,
        child: FadeInAnimation(
          delay: delay,
          child: this,
        ),
      ),
    );
  }
}
