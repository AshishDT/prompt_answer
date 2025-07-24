import 'package:flutter/material.dart';
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
}
