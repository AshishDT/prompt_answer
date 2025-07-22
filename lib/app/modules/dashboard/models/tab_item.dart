import 'package:flutter/cupertino.dart';

/// Represents a tab item in the dashboard
class TabItem {
  /// Creates a TabItem with a label and a builder function
  TabItem({
    required this.label,
    required this.builder,
  });

  /// Constructor for TabItem
  final String label;

  /// Builder function to create the widget for this tab
  final Widget Function() builder;
}
