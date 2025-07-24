
import 'package:nigerian_igbo/app/modules/dashboard/models/source_link.dart';

import 'keyword_link.dart';

/// Model representing a full chat event with all streamable components.
class ChatEventModel {
  /// Constructor for ChatEventModel
  ChatEventModel({
    StringBuffer? html,
    List<SourceLink>? sourceLinks,
    List<KeywordLink>? keywords,
    List<String>? brands,
    List<String>? followUpQuestions,
    this.chatHistoryId,
    this.promptKeyword,
  })  : html = html ?? StringBuffer(),
        sourceLinks = sourceLinks ?? <SourceLink>[],
        keywords = keywords ?? <KeywordLink>[],
        brands = brands ?? <String>[],
        followUpQuestions = followUpQuestions ?? <String>[];

  /// Combined HTML from "message" events.
  StringBuffer html;

  /// Source link cards (from `sourceLinks` or `TestsourceLinks`)
  List<SourceLink> sourceLinks;

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

  /// Useful for UI updates — create a deep copy with current state
  ChatEventModel clone() => ChatEventModel(
        html: StringBuffer(html.toString()),
        sourceLinks: List<SourceLink>.from(sourceLinks),
        keywords: List<KeywordLink>.from(keywords),
        brands: List<String>.from(brands),
        followUpQuestions: List<String>.from(followUpQuestions),
        chatHistoryId: chatHistoryId,
        promptKeyword: promptKeyword,
      );
}
