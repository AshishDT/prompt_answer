import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/modules/dashboard/widgets/icon_widget.dart';

import '../models/chat_model.dart';
import 'like_unlike_widget.dart';

/// Answer Widget
class AnswerWidget extends StatelessWidget {
  /// Constructor for AnswerWidget
  const AnswerWidget({
    required this.entry,
    required this.scrollKey,
    this.onShare,
    this.onCopy,
    this.onThumbUp,
    this.onThumbDown,
    super.key,
  });

  /// Entry containing the answers to display
  final ChatEntry entry;

  /// Scroll key
  final Key scrollKey;

  /// Callbacks for various actions
  final void Function(ChatEntry entry)? onShare;

  /// Callback for copying the answer
  final void Function(ChatEntry entry)? onCopy;

  /// Callback for liking the answer
  final void Function(ChatEntry entry)? onThumbUp;

  /// Callback for disliking the answer
  final void Function(ChatEntry entry)? onThumbDown;

  @override
  Widget build(BuildContext context) => Padding(
        key: scrollKey,
        padding: REdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(
            entry.answers.length,
            (int i) {
              final Answer answer = entry.answers[i];

              final bool hasText = answer.text?.trim().isNotEmpty ?? false;
              final bool hasImages = answer.imageUrls?.isNotEmpty ?? false;
              final bool hasPoints = answer.pointsAnswers?.isNotEmpty ?? false;

              if (!hasText && !hasImages && !hasPoints) {
                return 8.verticalSpace;
              }

              return Padding(
                padding: REdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (hasText) ...<Widget>[
                      Padding(
                        padding: REdgeInsets.only(bottom: 8),
                        child: Text(
                          answer.text!,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (hasImages) ...<Widget>[
                      10.verticalSpace,
                      Padding(
                        padding: REdgeInsets.only(bottom: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: answer.imageUrls!
                              .map(
                                (String url) => _imageWidget(url),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                    if (hasPoints) ...<Widget>[
                      10.verticalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: answer.pointsAnswers!
                            .map(
                              (PointsAnswers pa) => Padding(
                                padding: REdgeInsets.only(bottom: 12),
                                child: _pointAnswerWidget(pa),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    10.verticalSpace,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconWidget(
                          onTap: () {
                            onShare?.call(entry);
                          },
                          icon: Icons.share,
                          name: 'Share',
                          radius: 40,
                          iconSize: 20.sp,
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          padding: REdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            LikeUnlikeWidget(
                              onThumbDown: () {
                                onThumbDown?.call(entry);
                              },
                              onThumbUp: () {
                                onThumbUp?.call(entry);
                              },
                              selected: 0,
                            ),
                            12.horizontalSpace,
                            GestureDetector(
                              onTap: () {
                                onCopy?.call(entry);
                              },
                              child: Icon(
                                Icons.copy,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      );

  /// Image widget with rounded corners
  ClipRRect _imageWidget(String url) => ClipRRect(
        borderRadius: BorderRadius.circular(8).r,
        child: Image.network(
          url,
          width: 100.w,
          height: 100.h,
          fit: BoxFit.cover,
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) return child;

            return Container(
              width: 100.w,
              height: 100.h,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) =>
                  Container(
            width: 100.w,
            height: 100.h,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );

  /// Point answer widget
  Widget _pointAnswerWidget(PointsAnswers pa) {
    if (!_pointNotEmpty(pa) && !_declarationNotEmpty(pa)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: REdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: REdgeInsets.only(top: 2),
            child: Text(
              '•',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_pointNotEmpty(pa))
                  Text(
                    pa.point!,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                if (_declarationNotEmpty(pa))
                  Padding(
                    padding: REdgeInsets.only(top: 4),
                    child: Text(
                      pa.declaration!,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Point not empty check
  bool _pointNotEmpty(PointsAnswers pa) => (pa.point ?? '').isNotEmpty;

  /// Declaration not empty check
  bool _declarationNotEmpty(PointsAnswers pa) =>
      (pa.declaration ?? '').isNotEmpty;
}
