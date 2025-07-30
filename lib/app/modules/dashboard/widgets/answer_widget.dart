import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/data/config/app_colors.dart';
import 'package:nigerian_igbo/app/modules/dashboard/widgets/read_aloud_widget.dart';
import 'package:nigerian_igbo/app/modules/dashboard/widgets/typing_shimmer.dart';
import 'package:nigerian_igbo/app/modules/dashboard/widgets/url_card.dart';
import '../models/chat_event.dart';
import '../widgets/like_unlike_widget.dart';
import 'follow_up_card.dart';

/// Answer Widget to display dynamic answers in a chat event
class AnswerWidget extends StatelessWidget {
  /// Constructor for AnswerWidget
  const AnswerWidget({
    required this.chatEvent,
    required this.eventIndex,
    required this.scrollKey,
    this.onReadOut,
    this.onCopy,
    this.onThumbUp,
    this.onThumbDown,
    this.onFollowUpTap,
    super.key,
  });

  /// Chat event containing the dynamic data
  final ChatEventModel chatEvent;

  /// Index of the event in the list
  final int eventIndex;

  /// Key for the scrollable widget, used for scrolling and identification
  final Key scrollKey;

  /// Callbacks for various actions
  final void Function(ChatEventModel event, int index)? onReadOut;

  /// Callback when the copy icon is tapped
  final void Function(ChatEventModel event)? onCopy;

  /// Callback when thumbs up is tapped
  final void Function(ChatEventModel event, int index)? onThumbUp;

  /// Callback when thumbs down is tapped
  final void Function(ChatEventModel event, int index)? onThumbDown;

  /// On follow-up question tap
  final void Function(String question)? onFollowUpTap;

  @override
  Widget build(BuildContext context) => Padding(
        key: scrollKey,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 4,
            ),
            if (chatEvent.enginSource.isNotEmpty) ...<Widget>[
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ...List<Widget>.generate(
                        chatEvent.enginSource.length,
                        (int index) => UrlCard(
                          source: chatEvent.enginSource[index],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
            if (chatEvent.html.toString().trim().isNotEmpty) ...<Widget>[
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Html(
                    data: chatEvent.html.toString(),
                    extensions: <HtmlExtension>[
                      _codeStyleExt(),
                    ],
                    style: <String, Style>{
                      'body': Style(
                        fontSize: FontSize(14),
                        color: Colors.black87,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.w500,
                        display: Display.block,
                      ),
                      'pre': Style(
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.black,
                        fontSize: FontSize(12),
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        padding: HtmlPaddings.all(12),
                        whiteSpace: WhiteSpace.pre,
                        display: Display.block,
                        textAlign: TextAlign.left,
                        alignment: Alignment.topLeft,
                      ),
                    },
                  ),
                ),
              ),
            ],
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topLeft,
              child: Visibility(
                visible: chatEvent.isStreamComplete ?? false,
                replacement: const SizedBox(
                  width: double.infinity,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ReadAloudWidget(
                      chatEvent: chatEvent,
                      eventIndex: eventIndex,
                      onReadOut: onReadOut,
                    ),
                    Row(
                      children: <Widget>[
                        LikeUnlikeWidget(
                          onThumbDown: () =>
                              onThumbDown?.call(chatEvent, eventIndex),
                          onThumbUp: () =>
                              onThumbUp?.call(chatEvent, eventIndex),
                          selected: chatEvent.like,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                          onTap: () => onCopy?.call(chatEvent),
                          child: const Icon(Icons.copy, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topLeft,
              child: Visibility(
                visible: (chatEvent.isStreamComplete ?? false) &&
                    chatEvent.followUpQuestions.isNotEmpty,
                replacement: const SizedBox(
                  width: double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 30),
                  child: Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                    height: 1,
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topLeft,
              child: Visibility(
                visible: chatEvent.followUpQuestions.isNotEmpty,
                replacement: SizedBox(
                  width: context.width,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 6, right: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.menu_book_outlined,
                            size: 25,
                            color: AppColors.k364958,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Text(
                            'Related Questions',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.k364958,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ...chatEvent.followUpQuestions.map(
                        (String question) => FollowUpCard(
                          question: question,
                          onAddTap: () {
                            onFollowUpTap?.call(question);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!(chatEvent.isStreamComplete ?? false)) ...<Widget>[
              const AnimatedSize(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 8, top: 5),
                  child: TypingShimmer(),
                ),
              ),
            ],
          ],
        ),
      );

  /// Code style extension for HTML rendering
  TagExtension _codeStyleExt() => TagExtension(
        tagsToExtend: <String>{'pre'},
        builder: (ExtensionContext context) {
          final String codeText = context.element?.text.trim() ?? '';

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: codeText));
                    },
                    child: const Icon(
                      Icons.copy,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    codeText,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 13,
                      color: Colors.black,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
