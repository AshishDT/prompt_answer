import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// App Loading placeholder
class AppPlaceHolder extends StatelessWidget {
  /// App Loading placeholder constructor
  const AppPlaceHolder({
    required this.isLoading,
    required this.child,
    required this.placeHolder,
    this.padding,
    Key? key,
  }) : super(key: key);

  /// Is loading
  final bool isLoading;

  /// Child
  final Widget child;

  /// Loader
  final Widget placeHolder;

  /// Padding
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: placeHolder,
        ),
      );
    }
    return child;
  }
}
