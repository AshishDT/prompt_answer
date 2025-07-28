import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nigerian_igbo/app/ui/components/app_placeholder.dart';
import 'package:nigerian_igbo/app/ui/components/placeholder_card.dart';
import 'package:nigerian_igbo/app/utils/widget_ext.dart';

/// Source widget wrapper that can be used to display a placeholder or a loading indicator
class SourceWidgetWrapper extends StatelessWidget {
  /// Constructor for SourceWidgetWrapper
  const SourceWidgetWrapper({
    required this.isLoading,
    required this.child,
    super.key,
  });

  /// Is loading state to determine if the placeholder should be shown
  final bool isLoading;

  /// Child
  final Widget child;

  @override
  Widget build(BuildContext context) => AppPlaceHolder(
        isLoading: isLoading,
        child: child,
        placeHolder: Padding(
          padding: REdgeInsets.only(top: 8),
          child: Column(
            children: List<Widget>.generate(
              5,
              (int index) => Padding(
                padding: REdgeInsets.only(bottom: 8),
                child: PlaceholderCard(
                  height: 100.h,
                  width: 1.sw,
                ).animate(position: index),
              ),
            ),
          ),
        ),
      );
}
