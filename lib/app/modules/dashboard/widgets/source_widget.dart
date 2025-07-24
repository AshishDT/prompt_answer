import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
          children: chatEvent.sourceLinks
              .map<Widget>((SourceLink source) => Padding(
                    padding: REdgeInsets.only(bottom: 8),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.link, size: 24.sp),
                        12.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                source.title ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              4.verticalSpace,
                              Text(
                                source.url ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
}
