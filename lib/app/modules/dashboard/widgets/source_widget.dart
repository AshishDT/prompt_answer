import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/modules/dashboard/widgets/source_card.dart';
import 'package:nigerian_igbo/app/utils/widget_ext.dart';

import '../models/chat_event.dart';
import '../models/source_link.dart';

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
        child: Column(
          children: List<Widget>.generate(
            chatEvent.sourceLinks.length,
            (int index) => SourceCard(
              source: chatEvent.sourceLinks[index],
            ).animate(position: index),
          ),
        ),
      );
}
