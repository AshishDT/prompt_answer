import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:nigerian_igbo/app/data/config/logger.dart';
import '../models/chat_event.dart';
import '../models/source_link.dart';
import '../models/keyword_link.dart';
import '../repositories/html_cleaner.dart';

/// Combined mixin that handles HTML stream parsing, event processing, and stream handling
mixin PromptSearchMixin on GetxController {
  /// Reactive list that gets updated as events stream in
  final RxList<ChatEventModel> chatEvent = <ChatEventModel>[].obs;

  /// Internal buffer for message-type events (can be joined)
  final StringBuffer _messageBuffer = StringBuffer();

  /// Scroll controller for the chat view
  final ScrollController scrollController = ScrollController();

  /// Text editing controller for the chat input field
  final TextEditingController chatInputController = TextEditingController();

  /// Writing state for when content is being streamed/written
  final RxBool isWriting = false.obs;

  /// Expose message buffer for other mixins
  StringBuffer get messageBuffer => _messageBuffer;

  /// Loads streamed response from server and maps it to ChatEventModel
  Future<void> loadStreamedHtmlContent() async {
    final String prompt = chatInputController.text.trim();
    chatInputController.clear();

    _messageBuffer.clear();

    // Set writing state
    isWriting.value = true;

    // Add new chat event to the list
    chatEvent.add(ChatEventModel());

    final String encodedPrompt = Uri.encodeComponent(prompt);
    final String url = _buildApiUrl(encodedPrompt);

    final Dio dio = Dio();

    try {
      final Response<ResponseBody> response = await dio.get<ResponseBody>(
        url,
        options: Options(responseType: ResponseType.stream),
      );

      await processStream(response.data!.stream);
    } on DioException catch (e) {
      logWTF('HtmlDataMixin: DioException: ${e.message}');
    } catch (e) {
      logWTF('HtmlDataMixin: Exception: $e');
    } finally {
      // Reset writing state when streaming is complete
      isWriting.value = false;
    }
  }

  /// Builds the API URL with encoded prompt
  String _buildApiUrl(String encodedPrompt) =>
      'https://stagingapi.search.com/search'
      '?prompt=$encodedPrompt'
      '&nt=0'
      '&key=JiMmNjQ_OS43PSE,'
      '&auth=Iw,,'
      '&sub='
      '&currentChatId=chat_6881d4beb6c0b'
      '&is_image='
      '&image_url='
      '&space_id='
      '&source_link_res=true'
      '&uid=YUlRZGNaMzRDVGx5ekg0TXgwSU5zQT09';

  /// Scrolls to bottom of the chat view
  void scrollToBottom() {
    // if (!scrollController.hasClients) {
    //   return;
    // }
    //
    // final double targetPosition = scrollController.position.maxScrollExtent;
    //
    // scrollController.animateTo(
    //   targetPosition,
    //   duration: const Duration(milliseconds: 600),
    //   curve: Curves.easeOut,
    // );
  }

  /// Process stream from byte stream
  Future<void> processStream(Stream<List<int>> byteStream) async {
    final Stream<String> lines = byteStream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .expand((String chunk) => const LineSplitter().convert(chunk));

    String? currentEvent;

    await for (final String line in lines) {
      if (line.startsWith('event:')) {
        currentEvent = line.replaceFirst('event:', '').trim();
        logWTF('HtmlDataMixin: New event received: $currentEvent');
      } else if (line.startsWith('data:')) {
        final String rawData = line.replaceFirst('data:', '').trim();
        if (currentEvent == null || rawData.isEmpty) {
          logWTF('HtmlDataMixin: Skipping empty event or data line');
          continue;
        }
        handleEvent(currentEvent, rawData);
      }
    }
  }

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
    final String htmlContent =
        HtmlCleaner.cleanHtmlContent(messageBuffer.toString());

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
        final List<SourceLink> links =
            jsonList.map((e) => SourceLink.fromJson(e)).toList();
        if (chatEvent.isNotEmpty) {
          final ChatEventModel currentEvent = chatEvent.last;
          currentEvent.sourceLinks = <SourceLink>[
            ...currentEvent.sourceLinks,
            ...links
          ];
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
      final List<KeywordLink> keys =
          jsonList.map((e) => KeywordLink.fromJson(e)).toList();

      if (chatEvent.isNotEmpty) {
        final ChatEventModel currentEvent = chatEvent.last;
        currentEvent.keywords = <KeywordLink>[
          ...currentEvent.keywords,
          ...keys
        ];
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
        currentEvent.brands = <String>[
          ...currentEvent.brands,
          ...brands.cast<String>()
        ];
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
      currentEvent.html
          .write("⚠️ This content is restricted. Please log in to continue.");
      chatEvent.refresh();
    }
    isWriting.value = false;
    scrollToBottom();
  }
}
