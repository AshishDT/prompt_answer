import 'dart:convert';
import 'package:get/get.dart';
import 'package:nigerian_igbo/app/data/config/logger.dart';
import '../models/chat_event.dart';
import '../models/source_link.dart';
import '../models/keyword_link.dart';
import '../repositories/html_cleaner.dart';
import 'html_data_mixin.dart';

/// Mixin to handle event processing
mixin EventProcessorMixin on GetxController implements HtmlDataMixin {
  /// Main event handler
  void handleEvent(String event, String rawData) {
    switch (event) {
      case 'message':
        if (messageBuffer.isEmpty && chatEvent.isEmpty) {
          chatEvent.add(ChatEventModel());
        }
        _handleMessageEvent(rawData);
        break;
      case 'message_complete':
      // Optional: finalize or mark streaming done
        break;
      case 'sourceLinks':
      case 'TestsourceLinks':
        _handleSourceLinksEvent(rawData);
        break;
      case 'keywords':
        _handleKeywordsEvent(rawData);
        break;
      case 'Brands':
        _handleBrandsEvent(rawData);
        break;
      case 'followUpQuestions':
        _handleFollowUpQuestionsEvent(rawData);
        break;
      case 'Prompt Keyword':
        _handlePromptKeywordEvent(rawData);
        break;
      case 'ChatHistoryId':
        _handleChatHistoryIdEvent(rawData);
        break;
      case 'not_safe':
        _handleNotSafeEvent();
        break;
      case 'dataDone':
      case 'end':
        messageBuffer.clear();
        isWriting.value = false;
        break;
      default:
        logWTF('HtmlDataMixin: Unrecognized event: $event');
    }
  }

  void _handleMessageEvent(String rawData) {
    final String cleaned = HtmlCleaner.clean(rawData);
    if (_isJsonResponse(cleaned)) {
      _handleJsonResponse(cleaned);
    } else {
      _handleHtmlStreaming(cleaned);
    }
  }

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
      } catch (_) {}
    }
    return false;
  }

  void _handleJsonResponse(String rawData) {
    try {
      final String cleanData = rawData.replaceAll('``````', '').trim();
      final Map<String, dynamic> jsonResponse = jsonDecode(cleanData);

      if (chatEvent.isNotEmpty) {
        final ChatEventModel currentEvent = chatEvent.last;

        if (jsonResponse.containsKey('ai_response')) {
          final String htmlContent = jsonResponse['ai_response'] as String;
          final String cleanedHtml = HtmlCleaner.cleanHtmlContent(htmlContent);
          currentEvent.html.clear();
          currentEvent.html.write(cleanedHtml);
        }

        if (jsonResponse.containsKey('topKeywords')) {
          final List<dynamic> keywords = jsonResponse['topKeywords'] as List<dynamic>;
          currentEvent.keywords = keywords
              .map((k) => KeywordLink(keyword: k.toString(), url: ''))
              .toList();
        }

        if (jsonResponse.containsKey('followUpQuestions')) {
          final List<dynamic> questions = jsonResponse['followUpQuestions'] as List<dynamic>;
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

        chatEvent.refresh();
      }

      messageBuffer.clear();
      scrollToBottom();
    } catch (e) {
      logWTF('HtmlDataMixin: Error parsing JSON: $e');
      _handleHtmlStreaming(rawData);
    }
  }

  void _handleHtmlStreaming(String cleanedData) {
    messageBuffer.write(cleanedData);
    final String htmlContent = HtmlCleaner.cleanHtmlContent(messageBuffer.toString());

    if (chatEvent.isNotEmpty) {
      final ChatEventModel currentEvent = chatEvent.last;
      currentEvent.html.clear();
      currentEvent.html.write(htmlContent);
      chatEvent.refresh();
    }

    scrollToBottom();
  }

  void _handleSourceLinksEvent(String rawData) {
    final String cleaned = HtmlCleaner.clean(rawData);
    try {
      if (cleaned.trimLeft().startsWith('[')) {
        final List<dynamic> jsonList = jsonDecode(cleaned);
        final List<SourceLink> links = jsonList.map((e) => SourceLink.fromJson(e)).toList();
        if (chatEvent.isNotEmpty) {
          final ChatEventModel currentEvent = chatEvent.last;
          currentEvent.sourceLinks = <SourceLink>[...currentEvent.sourceLinks, ...links];
          chatEvent.refresh();
        }
      } else {
        if (chatEvent.isNotEmpty) {
          final ChatEventModel currentEvent = chatEvent.last;
          currentEvent.html.write(cleaned);
          chatEvent.refresh();
        }
      }
    } catch (e) {
      if (chatEvent.isNotEmpty) {
        final ChatEventModel currentEvent = chatEvent.last;
        currentEvent.html.write(cleaned);
        chatEvent.refresh();
      }
    }
    scrollToBottom();
  }

  void _handleKeywordsEvent(String rawData) {
    try {
      final String cleaned = HtmlCleaner.clean(rawData);
      final List<dynamic> jsonList = jsonDecode(cleaned);
      final List<KeywordLink> keys = jsonList.map((e) => KeywordLink.fromJson(e)).toList();

      if (chatEvent.isNotEmpty) {
        final ChatEventModel currentEvent = chatEvent.last;
        currentEvent.keywords = <KeywordLink>[...currentEvent.keywords, ...keys];
        chatEvent.refresh();
      }
    } catch (e) {
      logWTF('HtmlDataMixin: Error parsing keywords: $e');
    }
    scrollToBottom();
  }

  void _handleBrandsEvent(String rawData) {
    try {
      final String cleaned = HtmlCleaner.clean(rawData);
      final List<dynamic> brands = jsonDecode(cleaned);

      if (chatEvent.isNotEmpty) {
        final ChatEventModel currentEvent = chatEvent.last;
        currentEvent.brands = <String>[...currentEvent.brands, ...brands.cast<String>()];
        chatEvent.refresh();
      }
    } catch (e) {
      logWTF('HtmlDataMixin: Error parsing brands: $e');
    }
    scrollToBottom();
  }

  void _handleFollowUpQuestionsEvent(String rawData) {
    try {
      final String cleaned = HtmlCleaner.clean(rawData);
      final List<dynamic> questions = jsonDecode(cleaned);

      if (chatEvent.isNotEmpty) {
        final ChatEventModel currentEvent = chatEvent.last;
        currentEvent.followUpQuestions = questions.cast<String>();
        chatEvent.refresh();
      }
    } catch (e) {
      logWTF('HtmlDataMixin: Error parsing followUpQuestions: $e');
    }
    scrollToBottom();
  }

  void _handlePromptKeywordEvent(String rawData) {
    final String cleaned = HtmlCleaner.clean(rawData);
    if (chatEvent.isNotEmpty) {
      final ChatEventModel currentEvent = chatEvent.last;
      currentEvent.promptKeyword = cleaned;
      chatEvent.refresh();
    }
    scrollToBottom();
  }

  void _handleChatHistoryIdEvent(String rawData) {
    final String cleaned = HtmlCleaner.clean(rawData);
    if (chatEvent.isNotEmpty) {
      final ChatEventModel currentEvent = chatEvent.last;
      currentEvent.chatHistoryId = cleaned;
      chatEvent.refresh();
    }
    scrollToBottom();
  }

  void _handleNotSafeEvent() {
    if (chatEvent.isNotEmpty) {
      final ChatEventModel currentEvent = chatEvent.last;
      currentEvent.html.clear();
      currentEvent.html.write("⚠️ This content is restricted. Please log in to continue.");
      chatEvent.refresh();
    }
    isWriting.value = false;
    scrollToBottom();
  }
}
