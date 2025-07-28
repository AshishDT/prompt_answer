import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nigerian_igbo/app/modules/dashboard/widgets/source_card.dart';
import 'package:nigerian_igbo/app/modules/dashboard/widgets/source_widget_wrapper.dart';
import 'package:nigerian_igbo/app/utils/widget_ext.dart';
import '../models/chat_event.dart';

/// Widget to display dynamic source links in a chat event
class SourceWidget extends StatelessWidget {
  /// Constructor for DynamicSourceWidget
  const SourceWidget({
    required this.chatEvent,
    required this.scrollKey,
    super.key,
  });

  /// Chat event containing the dynamic data
  final ChatEventModel chatEvent;

  /// Key for the scrollable widget, used for scrolling and identification
  final Key scrollKey;

  @override
  Widget build(BuildContext context) => Padding(
        key: scrollKey,
        padding: REdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: SourceWidgetWrapper(
          isLoading: !(chatEvent.isStreamComplete ?? false),
          child: Column(
            children: List<Widget>.generate(
              chatEvent.testSourceLinks.length,
              (int index) => SourceCard(
                source: chatEvent.testSourceLinks[index],
              ).animate(position: index),
            ),
          ),
        ),
      );
}
