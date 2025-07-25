import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:nigerian_igbo/app/modules/dashboard/models/keyword_link.dart';
import '../models/chat_event.dart';
import '../widgets/icon_widget.dart';
import '../widgets/like_unlike_widget.dart';

/// Answer Widget to display dynamic answers in a chat event
class AnswerWidget extends GetView<DashboardController> {
  /// Constructor for AnswerWidget
  const AnswerWidget({
    required this.chatEvent,
    required this.eventIndex,
    required this.scrollKey,
    this.onShare,
    this.onCopy,
    this.onThumbUp,
    this.onThumbDown,
    super.key,
  });

  /// Chat event containing the dynamic data
  final ChatEventModel chatEvent;

  /// Index of the event in the list
  final int eventIndex;

  /// Key for the scrollable widget, used for scrolling and identification
  final Key scrollKey;

  /// Callbacks for various actions
  final void Function(ChatEventModel event, int index)? onShare;

  /// Callback when the copy icon is tapped
  final void Function(ChatEventModel event)? onCopy;

  /// Callback when thumbs up is tapped
  final void Function(ChatEventModel event, int index)? onThumbUp;

  /// Callback when thumbs down is tapped
  final void Function(ChatEventModel event, int index)? onThumbDown;

  @override
  Widget build(BuildContext context) => Padding(
        key: scrollKey,
        padding: REdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // HTML Content
            if (chatEvent.html.toString().trim().isNotEmpty)
              Padding(
                padding: REdgeInsets.only(bottom: 16),
                child: Html(
                  data: chatEvent.html.toString(),
                  // Add your HTML styling here
                ),
              ),

            // Keywords
            if (chatEvent.keywords.isNotEmpty)
              Padding(
                padding: REdgeInsets.only(bottom: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chatEvent.keywords
                      .map((KeywordLink keyword) => Chip(
                            label: Text(keyword.keyword ?? ''),
                            onDeleted: keyword.url?.isNotEmpty ?? false
                                ? () {
                                    // Handle keyword tap
                                  }
                                : null,
                          ))
                      .toList(),
                ),
              ),

            // Brands
            if (chatEvent.brands.isNotEmpty)
              Padding(
                padding: REdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Related Brands:',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    8.verticalSpace,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chatEvent.brands
                          .map((String brand) => Chip(label: Text(brand)))
                          .toList(),
                    ),
                  ],
                ),
              ),

            // Follow-up Questions
            if (chatEvent.followUpQuestions.isNotEmpty)
              Padding(
                padding: REdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Follow-up Questions:',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    8.verticalSpace,
                    ...chatEvent.followUpQuestions.map(
                      (String question) => Padding(
                        padding: REdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            // Handle follow-up question tap
                            // You can set the question as the new prompt
                          },
                          child: Container(
                            padding: REdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              question,
                              style: GoogleFonts.poppins(fontSize: 14.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action buttons
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.bottomCenter,
              child: Obx(
                () => Visibility(
                  visible: !controller.isWriting(),
                  replacement: SizedBox(
                    width: context.width,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconWidget(
                        onTap: () => onShare?.call(chatEvent, eventIndex),
                        icon: Icons.share,
                        name: 'Share',
                        radius: 40,
                        iconSize: 20.sp,
                        border: Border.all(color: Colors.grey.shade300),
                        padding:
                            REdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      Row(
                        children: <Widget>[
                          LikeUnlikeWidget(
                            onThumbDown: () =>
                                onThumbDown?.call(chatEvent, eventIndex),
                            onThumbUp: () =>
                                onThumbUp?.call(chatEvent, eventIndex),
                            selected:
                                -1, // You may want to add a like property to ChatEventModel
                          ),
                          12.horizontalSpace,
                          GestureDetector(
                            onTap: () => onCopy?.call(chatEvent),
                            child: Icon(Icons.copy, size: 20.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
