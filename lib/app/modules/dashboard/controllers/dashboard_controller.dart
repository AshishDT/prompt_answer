import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:nigerian_igbo/app/data/config/logger.dart';

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
  /// Initializes `GlobalKey`s for each chat section's prompt and header widgets.
  ///
  /// This function sets up:
  /// - [promptKeys]: used to identify and scroll to the prompt text (if needed)
  /// - [headerKeys]: used to track the position and pinned state of each section header
  ///
  /// These keys are essential for scroll positioning, especially when using
  /// sticky headers with `SliverStickyHeader` or similar widgets.
  void initializeKeys() {
    for (int i = 0; i < chatEntries.length; i++) {
      // Assign a unique GlobalKey for the prompt (text) in section i
      promptKeys[i] = GlobalKey(debugLabel: 'chat_prompt_$i');

      // Assign a unique GlobalKey for the header widget in section i
      headerKeys[i] = GlobalKey(debugLabel: 'chat_header_$i');
    }
  }

  /// Tab items for each chat entry
  final Map<int, List<TabItem>> tabItems = <int, List<TabItem>>{};

  /// Initializes tabs for each chat entry
  /// Initializes all tabs, keys, controllers, and listeners for each ChatEntry.
  ///
  /// This is responsible for:
  /// - Disposing old tab controllers
  /// - Rebuilding `TabItem`s for "Answer" and "Sources"
  /// - Creating corresponding GlobalKeys to track header/content visibility
  /// - Attaching listeners to `TabController`s to trigger scroll behavior
  ///
  /// This setup enables sticky header-aware scrolling and tab synchronization
  /// for each section in a scrollable chat view.
  void _initializeTabs() {
    // Dispose any existing TabControllers to prevent memory leaks
    for (final TabController controller in tabControllers.values) {
      controller.dispose();
    }

    // Clear all previously stored data (controllers, keys, etc.)
    tabItems.clear(); // Maps section index to list of TabItem
    tabControllers.clear(); // Maps section index to TabController
    tabIndices.clear(); // Maps section index to selected tab index (RxInt)
    contentKeys.clear(); // Maps section index to list of content widget keys
    promptKeys.clear(); // Maps section index to prompt GlobalKey
    headerKeys.clear(); // Maps section index to header GlobalKey

    // Initialize promptKeys and headerKeys for sticky headers
    initializeKeys();

    // Rebuild everything per chat entry (section)
    for (int i = 0; i < chatEntries.length; i++) {
      final ChatEntry entry = chatEntries[i]
        ..key = GlobalKey(
            debugLabel: 'ChatEntryKey_$i'); // Assign a unique key to each entry

      // Create a safe copy to pass into widgets (prevents mutation side effects)
      final ChatEntry safeEntry = ChatEntry(
        prompt: entry.prompt,
        answers: List<String>.from(entry.answers),
        sources: List<Source>.from(entry.sources),
      );

      final List<TabItem> tabs = <TabItem>[]; // Tabs for this entry
      final List<GlobalKey<State<StatefulWidget>>> contentKeyList = <GlobalKey<
          State<StatefulWidget>>>[]; // Keys for Answer/Sources content

      // If entry has answers, create "Answer" tab and key
      if (entry.answers.isNotEmpty) {
        final GlobalKey<State<StatefulWidget>> key =
            GlobalKey<State<StatefulWidget>>(
          debugLabel:
              'content_answer_${i}_${DateTime.now().microsecondsSinceEpoch}',
        );
        contentKeyList.add(key);
        tabs.add(
          TabItem(
            label: 'Answer',
            builder: () => AnswerWidget(
              scrollKey: key, // Used for scroll-to-view
              entry: safeEntry,
            ),
          ),
        );
      }

      // If entry has sources, create "Sources" tab and key
      if (entry.sources.isNotEmpty) {
        final GlobalKey<State<StatefulWidget>> key =
            GlobalKey<State<StatefulWidget>>(
          debugLabel:
              'content_sources_${i}_${DateTime.now().microsecondsSinceEpoch}',
        );
        contentKeyList.add(key);
        tabs.add(
          TabItem(
            label: 'Sources',
            builder: () => SourceWidget(
              scrollKey: key, // Used for scroll-to-view
              entry: safeEntry,
            ),
          ),
        );
      }

      // Store the keys used for content scrolling (Answers/Sources)
      contentKeys[i] = contentKeyList;

      if (tabs.isNotEmpty) {
        // Create TabController for this section
        final TabController controller = TabController(
          length: tabs.length,
          vsync: this,
        );
        tabControllers[i] = controller; // Store it
        tabItems[i] = tabs; // Store tab data
        tabIndices[i] = 0.obs; // Initially first tab is active (reactive)

        // Add a listener to respond when the user switches tabs
        // Attach a listener to respond when user switches tabs for this section
        controller.addListener(
          () {
            // Only trigger logic when the index is actively changing (not just tapping same tab)
            if (controller.indexIsChanging) {
              // Wait until the next frame — ensures layout is complete before measuring positions
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  // Get the context of the section's sticky header
                  final BuildContext? headerContext =
                      headerKeys[i]?.currentContext;

                  // Get the key of the tab content being switched to
                  final GlobalKey<State<StatefulWidget>>? contentKey =
                      contentKeys[i]?[controller.index];

                  // Check if the header is currently pinned (stuck to top of viewport)
                  final bool isPinned = _isHeaderPinned(headerContext);

                  if (isPinned) {
                    // If the header is already pinned, scroll to reveal the new tab's content
                    if (contentKey != null) {
                      scrollToRevealContent(contentKey);
                    }
                  } else {
                    // If the header isn't pinned, scroll the entire section to top so it gets pinned first
                    scrollToPrompt(headerKeys[i]!);
                  }
                },
              );

              // Update the selected tab index reactively
              tabIndices[i]?.value = controller.index;
            }
          },
        );
      }
    }
  }

  /// Is the header pinned?
  /// Checks if a section header is currently "pinned" (i.e., stuck at the top of the scroll view).
  ///
  /// This is important for deciding *how* to scroll when switching tabs:
  /// - If the header is already pinned, scroll directly to tab content.
  /// - If it's not pinned, scroll the section up so the header sticks first.
  ///
  /// Parameters:
  /// - [context]: The BuildContext of the header widget to inspect.
  ///
  /// Returns:
  /// - `true` if the header is currently pinned (i.e., top-aligned or within toolbar range), else `false`.
  bool _isHeaderPinned(BuildContext? context) {
    if (context == null) {
      return false; // Header context is null, can't be pinned
    }

    // Try to get the RenderBox of the header widget
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return false; // Header is not rendered
    }

    // Get the scroll view's RenderObject to calculate relative position
    final RenderObject? scrollRenderBox =
        scrollController.position.context.storageContext.findRenderObject();
    if (scrollRenderBox == null) {
      return false; // Scroll view itself is not available
    }

    // Calculate the vertical offset of the header *relative to the scroll view*
    final double headerOffset =
        renderBox.localToGlobal(Offset.zero, ancestor: scrollRenderBox).dy;

    // Current scroll offset (not directly used in logic but useful for logs/debug)
    final double scrollOffset = scrollController.offset;

    // Header is considered pinned if it's at the top or within toolbar height
    final bool pinned = headerOffset <= 0 || headerOffset <= kToolbarHeight;

    // Helpful debug log
    logWTF(
        '👾 [PINNED CHECK] headerOffset=$headerOffset, scrollOffset=$scrollOffset → pinned=$pinned');

    return pinned;
  }

  /// Scrolls the main scroll view so that the given [key]'s widget (usually a section header)
  /// is aligned to the top of the viewport (used when a header is not pinned yet).
  ///
  /// This is typically used when switching tabs in a section and the section is not currently
  /// visible/stuck at the top. It ensures the section scrolls into view first so that
  /// follow-up scrolling (to content) behaves as expected.
  ///
  /// Parameters:
  /// - [key]: The GlobalKey of the widget (usually a header) to scroll into view.
  void scrollToPrompt(GlobalKey key) {
    // Get the current context of the widget associated with the key
    final BuildContext? context = key.currentContext;

    // Get the scroll container’s context (used as ancestor reference for localToGlobal)
    final BuildContext scrollContext =
        scrollController.position.context.storageContext;

    // Resolve the RenderObject of the scrollable container
    final RenderObject? scrollRenderObject = scrollContext.findRenderObject();

    // Proceed only if both target widget and scroll container are rendered
    if (context != null && scrollRenderObject != null) {
      final RenderObject? renderBox = context.findRenderObject();

      if (renderBox is RenderBox) {
        // Calculate the vertical offset from the widget to the scroll container
        final double offset = renderBox
            .localToGlobal(Offset.zero, ancestor: scrollRenderObject)
            .dy;

        // Compute the absolute scroll offset needed
        final double scrollOffset = scrollController.offset + offset;

        // Animate the scroll to bring the target into view
        scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Scrolls to reveal content if it is cut off
  /// Scrolls the main scroll view just enough to reveal the content associated with [contentKey],
  /// ensuring it appears below a pinned header (e.g., sticky section header or AppBar).
  ///
  /// This is typically used when a user switches to a new tab within a pinned section,
  /// and we want the new tab's content to be visible just beneath the header.
  ///
  /// Parameters:
  /// - [contentKey]: The GlobalKey of the content widget (like AnswerWidget or SourceWidget).
  void scrollToRevealContent(GlobalKey contentKey) {
    // Get the BuildContext of the content widget
    final BuildContext? context = contentKey.currentContext;

    // Get the context of the scroll view (used as the ancestor for positioning)
    final BuildContext scrollContext =
        scrollController.position.context.storageContext;

    // Get the render object of the scroll container
    final RenderObject? scrollRenderObject = scrollContext.findRenderObject();

    // Ensure both the content and scroll view are rendered
    if (context != null && scrollRenderObject != null) {
      final RenderObject? renderBox = context.findRenderObject();

      if (renderBox is RenderBox) {
        // Calculate the offset of the content widget relative to the scroll view
        final Offset offsetInScroll = renderBox.localToGlobal(
          Offset.zero,
          ancestor: scrollRenderObject,
        );

        final double contentTop =
            offsetInScroll.dy; // Distance from scroll top to content
        final double scrollOffset = scrollController.offset;

        // Define how much height the pinned header occupies
        const double pinnedHeaderHeight = kToolbarHeight + 32;

        // If the content is hidden *behind* the pinned header
        if (contentTop < pinnedHeaderHeight) {
          // Calculate how much we need to scroll to bring it just below the pinned header
          final double targetOffset =
              scrollOffset + (contentTop - pinnedHeaderHeight);

          // Animate to the computed scroll position, clamped within scroll bounds
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
