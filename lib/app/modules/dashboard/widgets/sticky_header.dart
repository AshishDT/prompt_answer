import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

/// Conditionally sticky header widget that can switch between
class ConditionalSliverStickyHeader extends StatelessWidget {
  /// Constructor for ConditionalSliverStickyHeader
  const ConditionalSliverStickyHeader({
    required this.header,
    required this.sliver,
    required this.shouldStick,
    required this.sectionIndex,
    super.key,
    this.sectionKey,
  });

  /// Header and sliver widgets
  final Widget header;

  /// Sliver widget that contains the content
  final Widget sliver;

  /// Whether this header should stick or not
  final bool shouldStick;

  /// Index of this section, used for unique keys
  final int sectionIndex;

  /// Optional key for the section, used for scrolling and identification
  final GlobalKey? sectionKey;

  @override
  Widget build(BuildContext context) {
    if (!shouldStick) {
      return SliverMainAxisGroup(
        key: ValueKey<String>('normal_$sectionIndex'),
        slivers: [
          SliverToBoxAdapter(child: header),
          sliver,
        ],
      );
    }

    return SliverStickyHeader(
      key: sectionKey ?? ValueKey<String>('sticky_$sectionIndex'),
      header: header,
      sliver: sliver,
    );
  }
}
