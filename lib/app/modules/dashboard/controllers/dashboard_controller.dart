import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:nigerian_igbo/app/data/config/logger.dart';
import 'tab_management_mixin.dart';
import '../models/chat_event.dart';
import '../repositories/chat_event_handler.dart';
import '../services/api_service.dart';

/// DashboardController for managing chat events and UI state
class DashboardController extends GetxController
    with GetTickerProviderStateMixin, TabManagementMixin {
  /// Reactive list that gets updated as events stream in
  @override
  final RxList<ChatEventModel> chatEvent = <ChatEventModel>[].obs;

  /// Internal buffer for message-type events
  final StringBuffer _messageBuffer = StringBuffer();

  /// Scroll controller for the chat view
  @override
  final ScrollController scrollController = ScrollController();

  /// Text editing controller for the chat input field
  final TextEditingController chatInputController = TextEditingController();

  /// Writing state for when content is being streamed/written
  final RxBool isWriting = false.obs;

  /// API service instance for making requests
  final SearchApiService _apiService = SearchApiService();

  /// Event handler instance
  late final ChatEventHandler _eventHandler;

  /// Expose message buffer for other components
  StringBuffer get messageBuffer => _messageBuffer;

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(_onScroll);

    _eventHandler = ChatEventHandler(
      messageBuffer: _messageBuffer,
      onEventUpdated: _handleEventUpdated,
      onWritingStateChanged: (bool writing) => isWriting(writing),
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    chatInputController.dispose();
    super.onClose();
  }

  @override
  Future<void> loadStreamedContent(String prompt) async {
    await loadStreamedHtmlContent(specialPrompt: prompt);
  }

  /// Loads streamed response from server and maps it to ChatEventModel
  Future<void> loadStreamedHtmlContent({
    String? specialPrompt,
  }) async {
    String prompt = '';

    if (specialPrompt != null && specialPrompt.isNotEmpty) {
      prompt = specialPrompt.trim();
    } else {
      prompt = chatInputController.text.trim();
    }

    if (prompt.isEmpty) {
      return;
    }

    _prepareForNewSearch(prompt);

    try {
      final Stream<List<int>> stream = await _apiService.searchStream(prompt);
      await processStream(stream);
    } on SearchApiException catch (e) {
      _handleSearchError(e);
    } finally {
      isWriting(false);
    }
  }

  void _onScroll() {
    if (chatEvent.isNotEmpty) {
      final bool isAtVeryTop = scrollController.offset <= 10;

      firstSectionShouldUnstick(isAtVeryTop);
    }
    for (int i = 0; i < headerKeys.length; i++) {
      final BuildContext? context = headerKeys[i]?.currentContext;
      final bool isPinned = isHeaderPinned(context);

      if (pinnedStates.length > i) {
        final RxBool pinnedState = pinnedStates[i];

        if (isPinned && !pinnedState.value) {
          pinnedState(true);
        } else if (!isPinned && pinnedState.value) {
          pinnedState(false);
        }
      }
    }
  }

  /// Prepares UI state for new search
  void _prepareForNewSearch(String prompt) {
    chatInputController.clear();
    _messageBuffer.clear();
    isWriting(true);

    final ChatEventModel newEvent = ChatEventModel()..promptKeyword = prompt;
    chatEvent.add(newEvent);

    final int currentEventIndex = chatEvent.length - 1;
    createInitialTabsForEvent(currentEventIndex, prompt);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final GlobalKey? headerKey = headerKeys[currentEventIndex];
      if (headerKey != null) {
        scrollToPrompt(headerKey);
      }
    });
  }

  /// Handles search API specific errors
  void _handleSearchError(SearchApiException e) {
    logWTF('Search API Error: ${e.message}');
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
        currentEvent = line.replaceFirst('event: ', '');
        logWTF('New event received: $currentEvent');
      } else if (line.startsWith('data:')) {
        final String rawData = line.replaceFirst('data: ', '');
        if (currentEvent == null || rawData.isEmpty) {
          logWTF('Skipping empty event or data line');
          continue;
        }

        if (chatEvent.isNotEmpty) {
          _eventHandler.handleEvent(currentEvent, rawData, chatEvent.last);
        }
      } else {
        _eventHandler.handleEvent(currentEvent, line, chatEvent.last);
      }
    }
  }

  /// Called when an event is updated
  void _handleEventUpdated(ChatEventModel updatedEvent) {
    if (chatEvent.isNotEmpty) {
      final int currentEventIndex = chatEvent.length - 1;
      updateTabsContent(currentEventIndex);
    }
  }
}
