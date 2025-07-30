import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nigerian_igbo/app/modules/dashboard/repositories/html_cleaner.dart';
import '../../../data/config/logger.dart';
import '../models/chat_event.dart';
import '../models/tab_item.dart';
import '../repositories/copy_content_repo.dart';
import '../services/text_to_speech_service.dart';
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
  RxList<ChatEventModel> get chatEvents;

  /// Text editing controller for the chat input field
  TextToSpeechService get ttsService;

  /// Reactive list to manage the pinned states of headers
  final RxList<RxBool> pinnedStates = <RxBool>[].obs;

  /// Reactive boolean to control the unstick behavior of the first section
  final RxBool firstSectionShouldUnstick = false.obs;

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

    final ChatEventModel event = chatEvents[eventIndex];
    final List<TabItem> tabs = <TabItem>[];
    final List<GlobalKey<State<StatefulWidget>>> contentKeyList =
        <GlobalKey<State<StatefulWidget>>>[];

    final GlobalKey<State<StatefulWidget>> answerKey =
        GlobalKey<State<StatefulWidget>>(
            debugLabel: 'content_answer_${eventIndex}_fixed');
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
          onReadOut: onReadOut,
        ),
      ),
    );

    contentKeys[eventIndex] = contentKeyList;
    tabItems[eventIndex] = tabs;

    final TabController controller =
        TabController(length: tabs.length, vsync: this);
    tabControllers[eventIndex] = controller;
    tabIndices[eventIndex] = 0.obs;

    if (pinnedStates.length <= eventIndex) {
      pinnedStates.add(false.obs);
    }

    controller.addListener(
      () {
        if (controller.indexIsChanging) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
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
            },
          );

          tabIndices[eventIndex]?.value = controller.index;
        }
      },
    );

    logWTF('Created initial tabs for event $eventIndex with prompt: $prompt');
  }

  /// On read out action for a chat event
  void onReadOut(ChatEventModel event, int index) {
    if (event.isReading ?? false) {
      ttsService.stop();
      event.isReading = false;
      chatEvents.refresh();
      return;
    }

    for (final ChatEventModel _event in chatEvents) {
      if (_event.isReading ?? false) {
        _event.isReading = false;
      }
      chatEvents.refresh();
    }

    final String cleanedText = HtmlCleaner.toPlainText(
      event.html.toString(),
    );

    ttsService.readAloud(
      cleanedText,
      onComplete: () {
        event.isReading = false;
        chatEvents.refresh();
      },
    );

    event.isReading = true;

    chatEvents.refresh();
  }

  /// Handle follow-up question tap
  void onFollowUpQuestionTap(String question) {
    scrollController.jumpTo(
      scrollController.position.maxScrollExtent,
    );
    loadStreamedContent(question);
  }

  /// Update existing tabs content when new data arrives
  void updateTabsContent(int eventIndex) {
    chatEvents.refresh();
  }

  /// type: 0 = thumbs up, 1 = thumbs down
  void toggleLike(ChatEventModel event, int index, int type) {
    final int selected = (type == 0) ? 0 : 1;

    if (event.like == selected) {
      event.like = -1;
    } else {
      event.like = selected;
    }

    chatEvents.refresh();
  }

  /// On thumbs up or down action
  void onThumbsUp(ChatEventModel event, int index) {
    toggleLike(event, index, 0);
  }

  /// On thumbs down action
  void onThumbsDown(ChatEventModel event, int index) {
    toggleLike(event, index, 1);
  }

  /// Copy chat event content to clipboard
  void copyChatEventContent(ChatEventModel event) {
    CopyContentRepo.copy(event);
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
              scrollOffset + (contentTop - pinnedHeaderHeight);

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

  /// Add a Sources tab for the specified chat event
  void addSourcesTabForEvent(int eventIndex) {
    final ChatEventModel event = chatEvents[eventIndex];

    final bool sourcesTabExists =
        tabItems[eventIndex]?.any((TabItem tab) => tab.label == 'Sources') ??
            false;
    if (sourcesTabExists) {
      return;
    }

    final GlobalKey<State<StatefulWidget>> sourcesKey =
        GlobalKey<State<StatefulWidget>>(
            debugLabel: 'content_sources_${eventIndex}_fixed');

    contentKeys[eventIndex]?.add(sourcesKey);

    tabItems[eventIndex]?.add(
      TabItem(
        label: 'Sources',
        builder: () => SourceWidget(
          scrollKey: sourcesKey,
          chatEvent: event,
        ),
      ),
    );

    final TabController? oldController = tabControllers[eventIndex];
    oldController?.dispose();

    final List<TabItem> newTabs = tabItems[eventIndex]!;
    final TabController newController =
        TabController(length: newTabs.length, vsync: this);
    tabControllers[eventIndex] = newController;

    tabIndices[eventIndex] = 0.obs;

    newController.addListener(
      () {
        if (newController.indexIsChanging) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final BuildContext? headerContext =
                headerKeys[eventIndex]?.currentContext;
            final GlobalKey<State<StatefulWidget>>? contentKey =
                contentKeys[eventIndex]?[newController.index];
            final bool isPinned = isHeaderPinned(headerContext);

            if (isPinned) {
              if (contentKey != null) {
                scrollToRevealContent(contentKey);
              }
            } else {
              scrollToPrompt(headerKeys[eventIndex]!);
            }
          });

          tabIndices[eventIndex]?.value = newController.index;
        }
      },
    );

    logWTF('Added Sources tab for event $eventIndex');

    chatEvents.refresh();
  }
}
