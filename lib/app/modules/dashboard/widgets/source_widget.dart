import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/chat_model.dart';

/// Source Widget displays sources related to a chat entry
class SourceWidget extends StatelessWidget {
  /// Constructor for SourceWidget
  const SourceWidget({
    required this.entry,
    required this.scrollKey,
    super.key,
  });

  /// Entry containing the answers to display
  final ChatEntry entry;

  /// Scroll key for the widget
  final Key scrollKey;

  @override
  Widget build(BuildContext context) => Padding(
        key: scrollKey,
        padding: REdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: List<Widget>.generate(
            entry.sources.length,
            (int i) {
              final Source source = entry.sources[i];
              return Padding(
                padding: REdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.link,
                      size: 24.sp,
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            source.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          4.verticalSpace,
                          Text(
                            source.url,
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
              );
            },
          ),
        ),
      );
}
