import 'package:nigerian_igbo/app/modules/dashboard/models/source_link.dart';

import 'keyword_link.dart';

/// Model representing a full chat event with all streamable components.
class ChatEventModel {
  /// Constructor for ChatEventModel
  ChatEventModel({
    StringBuffer? html,
    StringBuffer? sourceLinks,
    StringBuffer? testSourceLinksBuffer,
    List<KeywordLink>? keywords,
    List<String>? brands,
    List<String>? followUpQuestions,
    List<SourceLink>? enginSource,
    List<SourceLink>? testSourceLinks,
    bool? isStreamComplete,
    this.chatHistoryId,
    this.promptKeyword,
  })  : html = html ?? StringBuffer(),
        sourceLinks = sourceLinks ?? StringBuffer(),
        testSourceLinksBuffer = testSourceLinksBuffer ?? StringBuffer(),
        keywords = keywords ?? <KeywordLink>[],
        testSourceLinks = testSourceLinks ?? <SourceLink>[],
        brands = brands ?? <String>[],
        followUpQuestions = followUpQuestions ?? <String>[],
        enginSource = enginSource ?? <SourceLink>[],
        isStreamComplete = isStreamComplete ?? false;

  /// Combined HTML from "message" events.
  StringBuffer html;

  /// Source links from the chat event
  StringBuffer sourceLinks;

  /// Engine source links (from `enginSource`)
  List<SourceLink> enginSource;

  /// Test source links
  List<SourceLink> testSourceLinks;

  /// Keywords list with URLs
  List<KeywordLink> keywords;

  /// Brands (just names)
  List<String> brands;

  /// Follow-up questions
  List<String> followUpQuestions;

  /// Chat history ID
  String? chatHistoryId;

  /// Main prompt keyword
  String? promptKeyword;

  /// Indicates if the stream is complete
  bool? isStreamComplete;

  /// Test source links for debugging purposes
  StringBuffer testSourceLinksBuffer;

  /// Useful for UI updates — create a deep copy with current state
  ChatEventModel clone() => ChatEventModel(
        html: StringBuffer(html.toString()),
        sourceLinks: StringBuffer(sourceLinks.toString()),
        keywords: List<KeywordLink>.from(keywords),
        brands: List<String>.from(brands),
        followUpQuestions: List<String>.from(followUpQuestions),
        chatHistoryId: chatHistoryId,
        promptKeyword: promptKeyword,
        enginSource: List<SourceLink>.from(enginSource),
        isStreamComplete: isStreamComplete,
        testSourceLinksBuffer: StringBuffer(testSourceLinksBuffer.toString()),
        testSourceLinks: List<SourceLink>.from(testSourceLinks),
      );
}
