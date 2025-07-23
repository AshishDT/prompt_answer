import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../models/chat_model.dart';
import '../models/tab_item.dart';
import '../widgets/answer_widget.dart';
import '../widgets/source_widget.dart';

/// Dashboard controller
class DashboardController extends GetxController
    with GetTickerProviderStateMixin {
  /// On init
  @override
  void onInit() {
    _initializeTabs();
    super.onInit();
  }

  /// On ready
  @override
  void onReady() {
    super.onReady();
  }

  /// On close
  @override
  void onClose() {
    for (final TabController controller in tabControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  /// Scroll controller for the chat list
  final ScrollController scrollController = ScrollController();

  /// Tab controllers, indices, and items
  final Map<int, TabController> tabControllers = <int, TabController>{};

  /// Tab indices for each chat entry
  final Map<int, RxInt> tabIndices = <int, RxInt>{};

  /// Prompt keys for each chat entry
  final Map<int, GlobalKey> promptKeys =
      <int, GlobalKey<State<StatefulWidget>>>{};

  /// Header keys for each chat entry
  final Map<int, GlobalKey> headerKeys =
      <int, GlobalKey<State<StatefulWidget>>>{};

  /// Keys for tab content of each chat entry
  final Map<int, List<GlobalKey>> contentKeys = <int, List<GlobalKey>>{};

  /// Initializes prompt keys for each chat entry
  void initializeKeys() {
    for (int i = 0; i < chatEntries.length; i++) {
      promptKeys[i] = GlobalKey(debugLabel: 'chat_prompt_$i');
      headerKeys[i] = GlobalKey(debugLabel: 'chat_header_$i');
    }
  }

  /// Tab items for each chat entry
  final Map<int, List<TabItem>> tabItems = <int, List<TabItem>>{};

  /// Initializes tabs for each chat entry
  void _initializeTabs() {
    // Dispose existing tab controllers
    for (final controller in tabControllers.values) {
      controller.dispose();
    }

    // Clear previous data
    tabItems.clear();
    tabControllers.clear();
    tabIndices.clear();
    contentKeys.clear();
    promptKeys.clear();
    headerKeys.clear();

    // Recreate prompt/header keys
    initializeKeys();

    for (int i = 0; i < chatEntries.length; i++) {
      final ChatEntry entry = chatEntries[i]
        ..key = GlobalKey(debugLabel: 'ChatEntryKey_$i');

      final ChatEntry safeEntry = ChatEntry(
        prompt: entry.prompt,
        answers: List<String>.from(entry.answers),
        sources: List<Source>.from(entry.sources),
      );

      final List<TabItem> tabs = <TabItem>[];
      final List<GlobalKey<State<StatefulWidget>>> contentKeyList = [];

      // Unique key for Answer tab content
      if (entry.answers.isNotEmpty) {
        final GlobalKey<State<StatefulWidget>> key = GlobalKey<State<StatefulWidget>>(
          debugLabel: 'content_answer_${i}_${DateTime.now().microsecondsSinceEpoch}',
        );
        contentKeyList.add(key);
        tabs.add(
          TabItem(
            label: 'Answer',
            builder: () => AnswerWidget(
              scrollKey: key,
              entry: safeEntry,
            ),
          ),
        );
      }

      // Unique key for Sources tab content
      if (entry.sources.isNotEmpty) {
        final key = GlobalKey<State<StatefulWidget>>(
          debugLabel: 'content_sources_${i}_${DateTime.now().microsecondsSinceEpoch}',
        );
        contentKeyList.add(key);
        tabs.add(
          TabItem(
            label: 'Sources',
            builder: () => SourceWidget(
              scrollKey: key,
              entry: safeEntry,
            ),
          ),
        );
      }

      // Store content keys for scrolling logic
      contentKeys[i] = contentKeyList;

      if (tabs.isNotEmpty) {
        final TabController controller = TabController(
          length: tabs.length,
          vsync: this,
        );
        tabControllers[i] = controller;
        tabItems[i] = tabs;
        tabIndices[i] = 0.obs;

        controller.addListener(() {
          if (controller.indexIsChanging) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final BuildContext? headerContext = headerKeys[i]?.currentContext;
              final GlobalKey<State<StatefulWidget>>? contentKey =
              contentKeys[i]?[controller.index];

              final bool isPinned = _isHeaderPinned(headerContext);


              if (isPinned) {
                if (contentKey != null) {
                  scrollToRevealContent(contentKey);
                }
              } else {
                scrollToPrompt(headerKeys[i]!);
              }
            });

            tabIndices[i]?.value = controller.index;
          }
        });
      }
    }
  }

  bool _isHeaderPinned(BuildContext? context) {
    if (context == null) return false;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return false;
    }

    final RenderObject? scrollRenderBox =
    scrollController.position.context.storageContext.findRenderObject();
    if (scrollRenderBox == null) {
      return false;
    }

    final double headerOffset = renderBox
        .localToGlobal(Offset.zero, ancestor: scrollRenderBox)
        .dy;

    final double scrollOffset = scrollController.offset;

    final bool pinned = headerOffset <= 0 || headerOffset <= kToolbarHeight;

    debugPrint('👾 [PINNED CHECK] headerOffset=$headerOffset, scrollOffset=$scrollOffset → pinned=$pinned');

    return pinned;
  }

  /// Scrolls to the prompt of a chat entry
  void scrollToPrompt(GlobalKey key) {
    final BuildContext? context = key.currentContext;
    final BuildContext scrollContext =
        scrollController.position.context.storageContext;
    final RenderObject? scrollRenderObject = scrollContext.findRenderObject();

    if (context != null && scrollRenderObject != null) {
      final RenderObject? renderBox = context.findRenderObject();
      if (renderBox is RenderBox) {
        final double offset = renderBox
            .localToGlobal(
              Offset.zero,
              ancestor: scrollRenderObject,
            )
            .dy;

        final double scrollOffset = scrollController.offset + offset;

        scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Scrolls to reveal content if it is cut off
  void scrollToRevealContent(GlobalKey contentKey) {
    final BuildContext? context = contentKey.currentContext;
    final BuildContext scrollContext =
        scrollController.position.context.storageContext;
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
        const double pinnedHeaderHeight = kToolbarHeight + 32;

        if (contentTop < pinnedHeaderHeight) {
          final double targetOffset = scrollOffset + (contentTop - pinnedHeaderHeight);

          scrollController.animateTo(
            targetOffset.clamp(
              scrollController.position.minScrollExtent,
              scrollController.position.maxScrollExtent,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  /// Chat entries
  final RxList<ChatEntry> chatEntries = <ChatEntry>[
    ChatEntry(
      prompt: 'What is Flutter?',
      answers: <String>[
        'Flutter is Google’s UI toolkit for building natively compiled applications.',
        'It allows building apps for mobile, web, and desktop from a single codebase.',
        'It allows building apps for mobile, web, and desktop from a single codebase.',
        'Flutter is Google’s UI toolkit for building natively compiled applications.',
        'Flutter is Google’s UI toolkit for building natively compiled applications.',
        'It allows building apps for mobile, web, and desktop from a single codebase.',
        'It allows building apps for mobile, web, and desktop from a single codebase.',
        'Flutter is Google’s UI toolkit for building natively compiled applications.',
      ],
      sources: <Source>[
        Source(
          id: 1,
          title: 'Flutter Official Documentation',
          url: 'https://flutter.dev/docs',
        ),
        Source(
          id: 2,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 3,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 4,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 5,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
      ],
    ),
    ChatEntry(
      prompt: 'How do sticky headers work?',
      answers: <String>[
        'Sticky headers remain pinned to the top while their section is visible.',
        'This creates a smooth scrolling experience for grouped content.',
        'Sticky headers remain pinned to the top while their section is visible.',
        'This creates a smooth scrolling experience for grouped content.',
        'Sticky headers remain pinned to the top while their section is visible.',
        'This creates a smooth scrolling experience for grouped content.',
      ],
      sources: <Source>[
        Source(
          id: 1,
          title: 'Flutter Official Documentation',
          url: 'https://flutter.dev/docs',
        ),
        Source(
          id: 2,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 3,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 4,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 5,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
      ],
    ),
    ChatEntry(
      prompt: 'Is this statically coded?',
      answers: <String>[
        'Yes, this is a demonstration using statically defined data.',
        'In production, you would typically fetch data dynamically.',
        'Yes, this is a demonstration using statically defined data.',
        'In production, you would typically fetch data dynamically.',
        'Yes, this is a demonstration using statically defined data.',
        'In production, you would typically fetch data dynamically.',
      ],
      sources: <Source>[
        Source(
          id: 1,
          title: 'Flutter Official Documentation',
          url: 'https://flutter.dev/docs',
        ),
        Source(
          id: 2,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 3,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 4,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 5,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
      ],
    ),
    ChatEntry(
      prompt: 'What is Dart?',
      answers: <String>[
        'Dart is a client-optimized language for fast apps on any platform.',
        'It is used as the programming language for Flutter apps.',
        'Dart is a client-optimized language for fast apps on any platform.',
        'It is used as the programming language for Flutter apps.',
        'Dart is a client-optimized language for fast apps on any platform.',
        'It is used as the programming language for Flutter apps.',
      ],
      sources: <Source>[
        Source(
          id: 1,
          title: 'Flutter Official Documentation',
          url: 'https://flutter.dev/docs',
        ),
        Source(
          id: 2,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 3,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 4,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 5,
          title: 'Flutter GitHub',
          url: 'https://github.com/flutter/flutter',
        ),
        Source(
          id: 6,
          title: 'Dart Packages',
          url: 'https://pub.dev/',
        ),
      ],
    ),
  ].obs;
}
