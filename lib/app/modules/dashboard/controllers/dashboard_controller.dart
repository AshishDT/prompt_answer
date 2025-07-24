import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:nigerian_igbo/app/data/config/logger.dart';
import '../models/chat_event.dart';
import '../models/source_link.dart';
import '../models/keyword_link.dart';
import '../models/tab_item.dart';
import '../repositories/html_cleaner.dart';
import '../widgets/answer_widget.dart';
import '../widgets/source_widget.dart';

/// Combined mixin that handles HTML stream parsing, event processing, and stream handling
class DashboardController extends GetxController with GetTickerProviderStateMixin {
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

  /// Tab controllers, indices, and items for dynamic chat events
  final Map<int, TabController> tabControllers = <int, TabController>{};
  final Map<int, RxInt> tabIndices = <int, RxInt>{};
  final Map<int, GlobalKey> promptKeys = <int, GlobalKey<State<StatefulWidget>>>{};
  final Map<int, GlobalKey> headerKeys = <int, GlobalKey<State<StatefulWidget>>>{};
  final Map<int, List<GlobalKey>> contentKeys = <int, List<GlobalKey>>{};
  final Map<int, List<TabItem>> tabItems = <int, List<TabItem>>{};

  /// Expose message buffer for other mixins
  StringBuffer get messageBuffer => _messageBuffer;

  @override
  void onClose() {
    for (final TabController controller in tabControllers.values) {
      controller.dispose();
    }
    scrollController.dispose();
    chatInputController.dispose();
    super.onClose();
  }

  /// Create initial tabs structure when request starts
  void _createInitialTabsForEvent(int eventIndex, String prompt) {
    // Create keys for this event if they don't exist
    if (!promptKeys.containsKey(eventIndex)) {
      promptKeys[eventIndex] = GlobalKey(debugLabel: 'chat_prompt_$eventIndex');
    }
    if (!headerKeys.containsKey(eventIndex)) {
      headerKeys[eventIndex] = GlobalKey(debugLabel: 'chat_header_$eventIndex');
    }

    final ChatEventModel event = chatEvent[eventIndex];
    final List<TabItem> tabs = <TabItem>[];
    final List<GlobalKey<State<StatefulWidget>>> contentKeyList = <GlobalKey<State<StatefulWidget>>>[];

    // ALWAYS create Answer tab with fixed key
    final GlobalKey<State<StatefulWidget>> answerKey = GlobalKey<State<StatefulWidget>>(
      debugLabel: 'content_answer_${eventIndex}_fixed',
    );
    contentKeyList.add(answerKey);
    tabs.add(
      TabItem(
        label: 'Answer',
        builder: () => AnswerWidget(
          scrollKey: answerKey,
          chatEvent: event,
          eventIndex: eventIndex,
          onThumbUp: _onThumbsUp,
          onThumbDown: _onThumbsDown,
          onCopy: _copyChatEventContent,
        ),
      ),
    );

    // ALWAYS create Sources tab with fixed key (even if empty initially)
    final GlobalKey<State<StatefulWidget>> sourcesKey = GlobalKey<State<StatefulWidget>>(
      debugLabel: 'content_sources_${eventIndex}_fixed',
    );
    contentKeyList.add(sourcesKey);
    tabs.add(
      TabItem(
        label: 'Sources',
        builder: () => SourceWidget(
          scrollKey: sourcesKey,
          chatEvent: event,
        ),
      ),
    );

    // Save keys and tabs
    contentKeys[eventIndex] = contentKeyList;
    tabItems[eventIndex] = tabs;

    // Create TabController
    final TabController controller = TabController(
      length: tabs.length,
      vsync: this,
    );
    tabControllers[eventIndex] = controller;
    tabIndices[eventIndex] = 0.obs;

    controller.addListener(() {
      if (controller.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final BuildContext? headerContext = headerKeys[eventIndex]?.currentContext;
          final GlobalKey<State<StatefulWidget>>? contentKey = contentKeys[eventIndex]?[controller.index];
          final bool isPinned = _isHeaderPinned(headerContext);

          if (isPinned) {
            if (contentKey != null) {
              scrollToRevealContent(contentKey);
            }
          } else {
            scrollToPrompt(headerKeys[eventIndex]!);
          }
        });

        tabIndices[eventIndex]?.value = controller.index;
      }
    });

    logWTF('Created initial tabs for event $eventIndex with prompt: $prompt');
  }

  /// Update existing tabs content when new data arrives
  void _updateTabsContent(int eventIndex) {
    // Don't recreate tabs, just update the content
    // The TabItem builders will automatically reflect the updated chatEvent data
    // since they reference the same ChatEventModel instance

    // Force UI refresh
    chatEvent.refresh();

    logWTF('Updated tabs content for event $eventIndex');
  }

  /// Loads streamed response from server and maps it to ChatEventModel
  Future<void> loadStreamedHtmlContent() async {
    final String prompt = chatInputController.text.trim();
    if (prompt.isEmpty) {
      return;
    }

    chatInputController.clear();
    _messageBuffer.clear();
    isWriting.value = true;

    // Create new chat event with the prompt
    final ChatEventModel newEvent = ChatEventModel();
    newEvent.promptKeyword = prompt; // Store the original prompt
    chatEvent.add(newEvent);

    final int currentEventIndex = chatEvent.length - 1;

    // IMMEDIATELY create tabs structure with the prompt (before API call)
    _createInitialTabsForEvent(currentEventIndex, prompt);

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
      logWTF('PromptSearchMixin: DioException: ${e.message}');
    } catch (e) {
      logWTF('PromptSearchMixin: Exception: $e');
    } finally {
      isWriting.value = false;
    }
  }

  /// Builds the API URL with encoded prompt
  String _buildApiUrl(String encodedPrompt) => 'https://stagingapi.search.com/search'
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
    // Implementation commented out as in original
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
        logWTF('PromptSearchMixin: New event received: $currentEvent');
      } else if (line.startsWith('data:')) {
        final String rawData = line.replaceFirst('data:', '').trim();
        if (currentEvent == null || rawData.isEmpty) {
          logWTF('PromptSearchMixin: Skipping empty event or data line');
          continue;
        }
        handleEvent(currentEvent, rawData);
      }
    }
  }

  /// Main event handler - now updates existing tabs instead of recreating them
  void handleEvent(String event, String rawData) {
    switch (event) {
      case 'message':
        if (messageBuffer.isEmpty && chatEvent.isEmpty) {
          chatEvent.add(ChatEventModel());
        }
        _handleMessageEvent(rawData);
        break;
      case 'message_complete':
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
        logWTF('PromptSearchMixin: Unrecognized event: $event');
    }

    // Update tabs content after each event (without recreating tabs)
    if (chatEvent.isNotEmpty) {
      final int currentEventIndex = chatEvent.length - 1;
      _updateTabsContent(currentEventIndex);
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
      logWTF('PromptSearchMixin: Error parsing JSON: $e');
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
      logWTF('PromptSearchMixin: Error parsing keywords: $e');
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
      logWTF('PromptSearchMixin: Error parsing brands: $e');
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
      logWTF('PromptSearchMixin: Error parsing followUpQuestions: $e');
    }
    scrollToBottom();
  }

  void _handlePromptKeywordEvent(String rawData) {
    final String cleaned = HtmlCleaner.clean(rawData);
    if (chatEvent.isNotEmpty) {
      final ChatEventModel currentEvent = chatEvent.last;

      // Only update if promptKeyword is not already set (preserve original user input)
      if (currentEvent.promptKeyword == null || currentEvent.promptKeyword!.trim().isEmpty) {
        currentEvent.promptKeyword = cleaned;
        chatEvent.refresh();
      }
      // If already set, ignore the server's version to keep the original prompt
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

  // Tab management methods
  void _onThumbsUp(ChatEventModel event, int index) {
    logWTF('Thumbs up for event at index $index');
  }

  void _onThumbsDown(ChatEventModel event, int index) {
    logWTF('Thumbs down for event at index $index');
  }

  void _copyChatEventContent(ChatEventModel event) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('Prompt:')
      ..writeln(event.promptKeyword ?? 'No prompt available')
      ..writeln()
      ..writeln('Answer:')
      ..writeln(event.html.toString())
      ..writeln();

    if (event.sourceLinks.isNotEmpty) {
      buffer.writeln('Sources:');
      for (final SourceLink source in event.sourceLinks) {
        buffer.writeln('- ${source.title}: ${source.url}');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  bool _isHeaderPinned(BuildContext? context) {
    if (context == null) {
      return false;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return false;
    }

    final RenderObject? scrollRenderBox =
    scrollController.position.context.storageContext.findRenderObject();
    if (scrollRenderBox == null) {
      return false;
    }

    final double headerOffset =
        renderBox.localToGlobal(Offset.zero, ancestor: scrollRenderBox).dy;

    return headerOffset <= 0 || headerOffset <= kToolbarHeight;
  }

  void scrollToPrompt(GlobalKey key) {
    final BuildContext? context = key.currentContext;
    final BuildContext scrollContext = scrollController.position.context.storageContext;
    final RenderObject? scrollRenderObject = scrollContext.findRenderObject();

    if (context != null && scrollRenderObject != null) {
      final RenderObject? renderBox = context.findRenderObject();

      if (renderBox is RenderBox) {
        final double offset = renderBox
            .localToGlobal(Offset.zero, ancestor: scrollRenderObject)
            .dy;

        final double scrollOffset = scrollController.offset + offset;

        scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void scrollToRevealContent(GlobalKey contentKey) {
    final BuildContext? context = contentKey.currentContext;
    final BuildContext scrollContext = scrollController.position.context.storageContext;
    final RenderObject? scrollRenderObject = scrollContext.findRenderObject();

    if (context != null && scrollRenderObject != null) {
      final RenderObject? renderBox = context.findRenderObject();

      if (renderBox is RenderBox) {
        final Offset offsetInScroll = renderBox.localToGlobal(
          Offset.zero,
          ancestor: scrollRenderObject,
        );

        final double contentTop = offsetInScroll.dy;
        final double scrollOffset = scrollController.offset;

        const double pinnedHeaderHeight = kToolbarHeight;

        if (contentTop < pinnedHeaderHeight) {
          final double targetOffset =
              scrollOffset + (contentTop - pinnedHeaderHeight) - 50;

          scrollController.animateTo(
            targetOffset.clamp(
              scrollController.position.minScrollExtent,
              scrollController.position.maxScrollExtent,
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }
}
