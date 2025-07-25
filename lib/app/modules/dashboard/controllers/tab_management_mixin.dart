import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/config/logger.dart';
import '../models/chat_event.dart';
import '../models/source_link.dart';
import '../models/tab_item.dart';
import '../widgets/answer_widget.dart';
import '../widgets/source_widget.dart';

/// Tab management mixin for handling dynamic tabs in chat events
mixin TabManagementMixin on GetxController, GetTickerProviderStateMixin {
  /// Tab controllers, indices, and items for dynamic chat events
  final Map<int, TabController> tabControllers = <int, TabController>{};

  /// Map to keep track of the current tab index for each event
  final Map<int, RxInt> tabIndices = <int, RxInt>{};

  /// Keys for the prompt, header, and content sections of each chat event
  final Map<int, GlobalKey> promptKeys =
      <int, GlobalKey<State<StatefulWidget>>>{};

  /// Keys for the header and content sections of each chat event
  final Map<int, GlobalKey> headerKeys =
      <int, GlobalKey<State<StatefulWidget>>>{};

  /// Keys for the content sections of each chat event
  final Map<int, List<GlobalKey>> contentKeys = <int, List<GlobalKey>>{};

  /// Map to hold the tab items for each event
  final Map<int, List<TabItem>> tabItems = <int, List<TabItem>>{};

  /// Abstract getters that must be implemented by the controller
  ScrollController get scrollController;

  /// Reactive list of chat events that will be updated dynamically
  RxList<ChatEventModel> get chatEvent;

  /// Reactive list to manage the pinned states of headers
  final RxList<RxBool> pinnedStates = <RxBool>[].obs;

  /// Load streamed content based on the prompt
  Future<void> loadStreamedContent(String prompt);

  @override
  void onClose() {
    for (final TabController controller in tabControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  /// Create initial tabs structure when request starts
  void createInitialTabsForEvent(int eventIndex, String prompt) {
    if (!promptKeys.containsKey(eventIndex)) {
      promptKeys[eventIndex] = GlobalKey(debugLabel: 'chat_prompt_$eventIndex');
    }
    if (!headerKeys.containsKey(eventIndex)) {
      headerKeys[eventIndex] = GlobalKey(debugLabel: 'chat_header_$eventIndex');
    }

    final ChatEventModel event = chatEvent[eventIndex];
    final List<TabItem> tabs = <TabItem>[];
    final List<GlobalKey<State<StatefulWidget>>> contentKeyList =
        <GlobalKey<State<StatefulWidget>>>[];

    // Create Answer tab
    final GlobalKey<State<StatefulWidget>> answerKey =
        GlobalKey<State<StatefulWidget>>(
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
          onThumbUp: onThumbsUp,
          onThumbDown: onThumbsDown,
          onCopy: copyChatEventContent,
          onFollowUpTap: onFollowUpQuestionTap,
        ),
      ),
    );

    // Create Sources tab
    final GlobalKey<State<StatefulWidget>> sourcesKey =
        GlobalKey<State<StatefulWidget>>(
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

    contentKeys[eventIndex] = contentKeyList;
    tabItems[eventIndex] = tabs;

    final TabController controller = TabController(
      length: tabs.length,
      vsync: this,
    );
    tabControllers[eventIndex] = controller;
    tabIndices[eventIndex] = 0.obs;

    if (pinnedStates.length <= eventIndex) {
      pinnedStates.add(false.obs);
    }

    controller.addListener(() {
      if (controller.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final BuildContext? headerContext =
              headerKeys[eventIndex]?.currentContext;
          final GlobalKey<State<StatefulWidget>>? contentKey =
              contentKeys[eventIndex]?[controller.index];
          final bool isPinned = isHeaderPinned(headerContext);

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

  /// Handle follow-up question tap
  void onFollowUpQuestionTap(String question) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    loadStreamedContent(question);
  }

  /// Update existing tabs content when new data arrives
  void updateTabsContent(int eventIndex) {
    chatEvent.refresh();
  }

  /// On thumbs up or down action
  void onThumbsUp(ChatEventModel event, int index) {}

  /// On thumbs down action
  void onThumbsDown(ChatEventModel event, int index) {}

  /// Copy chat event content to clipboard
  void copyChatEventContent(ChatEventModel event) {
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

  /// Check if the header is pinned (i.e., visible at the top of the screen)
  bool isHeaderPinned(BuildContext? context) {
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

  /// Scroll to the prompt section of the chat event
  void scrollToPrompt(GlobalKey key) {
    final BuildContext? context = key.currentContext;
    final BuildContext scrollContext =
        scrollController.position.context.storageContext;
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

  /// Scroll to reveal the content of a specific tab
  void scrollToRevealContent(GlobalKey contentKey) {
    final BuildContext? context = contentKey.currentContext;
    final BuildContext scrollContext =
        scrollController.position.context.storageContext;
    final RenderObject? scrollRenderObject = scrollContext.findRenderObject();

    if (context != null && scrollRenderObject != null) {
      final RenderObject? renderBox = context.findRenderObject();

      if (renderBox is RenderBox) {
        final Offset offsetInScroll =
            renderBox.localToGlobal(Offset.zero, ancestor: scrollRenderObject);
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
