import 'dart:convert';
import 'dart:developer';
import '../../../data/config/logger.dart';
import '../models/chat_event.dart';
import '../models/source_link.dart';
import '../models/keyword_link.dart';
import '../repositories/html_cleaner.dart';

/// Chat event handler that processes various chat events
class ChatEventHandler {
  /// Constructor for ChatEventHandler
  ChatEventHandler({
    required this.messageBuffer,
    required this.onEventUpdated,
    required this.onWritingStateChanged,
  });

  /// Buffer to accumulate message content
  final StringBuffer messageBuffer;

  /// Callback to update the current event
  final Function(ChatEventModel) onEventUpdated;

  /// Callback to notify when writing state changes
  final Function(bool) onWritingStateChanged;

  /// Main event handler
  void handleEvent(String event, String rawData, ChatEventModel currentEvent) {
    switch (event) {
      case 'message':
        _handleMessageEvent(rawData, currentEvent);
        break;
      case 'message_complete':
        currentEvent.isStreamComplete = true;
        break;
      case 'sourceLinks':
        _handleSourceLinksHtmlEvent(rawData, currentEvent);
        break;
      case 'TestsourceLinks':
        _handleTestSourceLinksEvent(rawData, currentEvent);
        break;
      case 'keywords':
        _handleKeywordsEvent(rawData, currentEvent);
        break;
      case 'Brands':
        _handleBrandsEvent(rawData, currentEvent);
        break;
      case 'followUpQuestions':
        _handleFollowUpQuestionsEvent(rawData, currentEvent);
        break;
      case 'Prompt Keyword':
        _handlePromptKeywordEvent(rawData, currentEvent);
        break;
      case 'ChatHistoryId':
        _handleChatHistoryIdEvent(rawData, currentEvent);
        break;
      case 'not_safe':
        _handleNotSafeEvent(currentEvent);
        break;
      case 'dataDone':
      case 'end':
        messageBuffer.clear();
        onWritingStateChanged(false);
        break;
      default:
        logWTF('ChatEventHandler: Unrecognized event: $event');
    }

    onEventUpdated(currentEvent);
  }

  /// Handles the message event by cleaning and processing the raw data
  void _handleMessageEvent(String rawData, ChatEventModel currentEvent) {
    final String cleaned = HtmlCleaner.clean(rawData);
    if (_isJsonResponse(cleaned)) {
      _handleJsonResponse(cleaned, currentEvent);
    } else {
      _handleHtmlStreaming(cleaned, currentEvent);
    }
  }

  /// Checks if the response data is in JSON format
  bool _isJsonResponse(String data) {
    final String trimmed = data.trim();
    if (trimmed.startsWith('``````')) {
      return true;
    }
    if (trimmed.startsWith('{')) {
      try {
        final json = jsonDecode(trimmed);
        return json.containsKey('ai_response') ||
            json.containsKey('topKeywords') ||
            json.containsKey('is_safe');
      } on Exception catch (_) {}
    }
    return false;
  }

  /// Handles the JSON response by parsing it and updating the current event
  void _handleJsonResponse(String rawData, ChatEventModel currentEvent) {
    try {
      final String cleanData = rawData.replaceAll('``````', '').trim();
      final Map<String, dynamic> jsonResponse = jsonDecode(cleanData);

      if (jsonResponse.containsKey('ai_response')) {
        final String htmlContent = jsonResponse['ai_response'] as String;
        final String cleanedHtml = HtmlCleaner.cleanHtmlContent(htmlContent);
        currentEvent.html.clear();
        currentEvent.html.write(cleanedHtml);
      }

      if (jsonResponse.containsKey('topKeywords')) {
        final List<dynamic> keywords =
            jsonResponse['topKeywords'] as List<dynamic>;
        currentEvent.keywords = keywords
            .map((k) => KeywordLink(keyword: k.toString(), url: ''))
            .toList();
      }

      if (jsonResponse.containsKey('followUpQuestions')) {
        final List<dynamic> questions =
            jsonResponse['followUpQuestions'] as List<dynamic>;
        currentEvent.followUpQuestions = questions.cast<String>();
      }

      if (jsonResponse.containsKey('promptKeywords')) {
        currentEvent.promptKeyword = jsonResponse['promptKeywords'] as String;
      }

      if (jsonResponse.containsKey('brands')) {
        final List<dynamic> brands = jsonResponse['brands'] as List<dynamic>;
        currentEvent.brands = brands.cast<String>();
      }

      if (jsonResponse.containsKey('chatHistoryId')) {
        currentEvent.chatHistoryId = jsonResponse['chatHistoryId'] as String;
      }

      messageBuffer.clear();
    } on Exception catch (e) {
      logWTF('ChatEventHandler: Error parsing JSON: $e');
      _handleHtmlStreaming(rawData, currentEvent);
    }
  }

  /// Handles HTML streaming by cleaning the data and appending it to the message buffer
  void _handleHtmlStreaming(String cleanedData, ChatEventModel currentEvent) {
    messageBuffer.write(cleanedData);
    final String htmlContent =
        HtmlCleaner.cleanHtmlContent(messageBuffer.toString());
    currentEvent.html.clear();
    currentEvent.html.write(htmlContent);
  }

  /// Handles keywords event by parsing the raw data and updating the current event
  void _handleKeywordsEvent(String rawData, ChatEventModel currentEvent) {
    try {
      final String cleaned = HtmlCleaner.clean(rawData);
      final List<dynamic> jsonList = jsonDecode(cleaned);
      final List<KeywordLink> keys =
          jsonList.map((dynamic e) => KeywordLink.fromJson(e)).toList();
      currentEvent.keywords = <KeywordLink>[...currentEvent.keywords, ...keys];
    } on Exception catch (e) {
      logWTF('ChatEventHandler: Error parsing keywords: $e');
    }
  }

  /// Handles brands event by parsing the raw data and updating the current event
  void _handleBrandsEvent(String rawData, ChatEventModel currentEvent) {
    try {
      final String cleaned = HtmlCleaner.clean(rawData);
      if (cleaned.isEmpty) {
        return;
      }
      final List<dynamic> brands = jsonDecode(cleaned);
      currentEvent.brands = <String>[
        ...currentEvent.brands,
        ...brands.cast<String>()
      ];
    } on Exception catch (e) {
      logWTF('ChatEventHandler: Error parsing brands: $e');
    }
  }

  /// Handles follow-up questions event by parsing the raw data and updating the current event
  void _handleFollowUpQuestionsEvent(
      String rawData, ChatEventModel currentEvent) {
    try {
      final String cleaned = HtmlCleaner.clean(rawData);

      if (cleaned.isEmpty) {
        return;
      }

      final List<dynamic> questions = jsonDecode(cleaned);
      currentEvent.followUpQuestions = questions.cast<String>();
    } on Exception catch (e) {
      logWTF('ChatEventHandler: Error parsing followUpQuestions: $e');
    }
  }

  /// Handles prompt keyword event by cleaning the raw data and updating the current event
  void _handlePromptKeywordEvent(String rawData, ChatEventModel currentEvent) {
    final String cleaned = HtmlCleaner.clean(rawData);
    if (currentEvent.promptKeyword == null ||
        currentEvent.promptKeyword!.trim().isEmpty) {
      currentEvent.promptKeyword = cleaned;
    }
  }

  /// Handles chat history ID event by cleaning the raw data and updating the current event
  void _handleChatHistoryIdEvent(String rawData, ChatEventModel currentEvent) {
    final String cleaned = HtmlCleaner.clean(rawData);
    currentEvent.chatHistoryId = cleaned;
  }

  /// Handles not safe event by clearing the HTML content and notifying the writing state
  void _handleNotSafeEvent(ChatEventModel currentEvent) {
    currentEvent.html.clear();
    currentEvent.html
        .write('This content is restricted. Please log in to continue.');
    onWritingStateChanged(false);
  }

  /// Handles source links HTML event by cleaning the raw data and extracting source links
  void _handleSourceLinksHtmlEvent(
      String rawData, ChatEventModel currentEvent) {
    final String cleaned = HtmlCleaner.clean(rawData);

    // Parse HTML to extract source links
    final List<SourceLink> links = _parseSourceLinksFromHtml(cleaned);

    if (links.isNotEmpty) {
      currentEvent.enginSource = <SourceLink>[
        ...currentEvent.enginSource,
        ...links
      ];
    } else {
      log('ChatEventHandler: Could not parse sourceLinks HTML, storing as HTML');
      currentEvent.html.write(cleaned);
    }
  }

  void _handleTestSourceLinksEvent(
      String rawData, ChatEventModel currentEvent) {
    final String cleaned = HtmlCleaner.clean(rawData);
    try {
      if (cleaned.trimLeft().startsWith('[')) {
        final List<dynamic> jsonList = jsonDecode(cleaned);
        final List<SourceLink> links =
            jsonList.map((dynamic e) => SourceLink.fromJson(e)).toList();
        currentEvent.sourceLinks = <SourceLink>[
          ...currentEvent.sourceLinks,
          ...links
        ];
      } else {
        currentEvent.html.write(cleaned);
      }
    } on Exception {
      currentEvent.html.write(cleaned);
    }
  }

  List<SourceLink> _parseSourceLinksFromHtml(String htmlContent) {
    final List<SourceLink> links = <SourceLink>[];

    try {
      final RegExp linkRegex = RegExp(
          r'<a class="ai-sourcelink-card" href="([^"]*)"[^>]*>.*?<img src="([^"]*)" alt="favicon">.*?<span[^>]*>([^<]*)</span>.*?<div class="ai-sourcelink-card-title">\s*([^<]*)</div>',
          dotAll: true);

      final Iterable<RegExpMatch> matches = linkRegex.allMatches(htmlContent);

      for (final RegExpMatch match in matches) {
        String url = match.group(1) ?? '';
        final String favicon = match.group(2) ?? '';
        final String domain = match.group(3) ?? '';
        final String title = match.group(4) ?? '';

        if (url.isNotEmpty) {
          url = url.replaceAll('?utm_source=search.com', '');

          links.add(
            SourceLink(
              url: url,
              title: title.trim(),
              domain: domain.isNotEmpty ? domain : _extractDomainFromUrl(url),
              description: title.trim(),
              favicon: favicon,
            ),
          );
        }
      }
    } on Exception catch (e) {
      log('Error parsing HTML sourceLinks: $e');
    }

    return links;
  }

  /// Extracts the domain from a URL
  String _extractDomainFromUrl(String url) {
    try {
      final Uri uri = Uri.parse(url);
      return uri.host;
    } on Exception {
      return '';
    }
  }
}
