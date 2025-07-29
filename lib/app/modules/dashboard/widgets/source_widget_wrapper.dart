import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: List<Widget>.generate(
              5,
              (int index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: const PlaceholderCard(
                  height: 100,
                  width: 1,
                ).animate(position: index),
              ),
            ),
          ),
        ),
      );
}
