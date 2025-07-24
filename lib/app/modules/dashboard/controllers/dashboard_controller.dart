import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../models/chat_model.dart';
import '../models/tab_item.dart';
import '../repositories/static_declarations.dart' show StaticDeclarations;
import '../widgets/answer_widget.dart';
import '../widgets/source_widget.dart';
import 'package:uuid/uuid.dart';

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
      // Assign a unique GlobalKey for the prompt (text) in section i
      promptKeys[i] = GlobalKey(debugLabel: 'chat_prompt_$i');

      // Assign a unique GlobalKey for the header widget in section i
      headerKeys[i] = GlobalKey(debugLabel: 'chat_header_$i');
    }
  }

  /// Tab items for each chat entry
  final Map<int, List<TabItem>> tabItems = <int, List<TabItem>>{};

  /// Initializes tabs for each chat entry
  void _initializeTabs() {
    for (final TabController controller in tabControllers.values) {
      controller.dispose();
    }

    // Clear all previously stored data (controllers, keys, etc.)
    tabItems.clear();
    tabControllers.clear();
    tabIndices.clear();
    contentKeys.clear();
    promptKeys.clear();
    headerKeys.clear();

    initializeKeys();

    for (int i = 0; i < chatEntries.length; i++) {
      final ChatEntry entry = chatEntries[i]
        ..key = GlobalKey(debugLabel: 'ChatEntryKey_$i');

      final List<TabItem> tabs = <TabItem>[];
      final List<GlobalKey<State<StatefulWidget>>> contentKeyList =
          <GlobalKey<State<StatefulWidget>>>[];

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
              scrollKey: key,
              entry: entry,
              onThumbUp: _onThumbsUp,
              onThumbDown: _onThumbsDown,
            ),
          ),
        );
      }

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
              scrollKey: key,
              entry: entry,
            ),
          ),
        );
      }

      contentKeys[i] = contentKeyList;

      if (tabs.isNotEmpty) {
        final TabController controller = TabController(
          length: tabs.length,
          vsync: this,
        );
        tabControllers[i] = controller;
        tabItems[i] = tabs;
        tabIndices[i] = 0.obs;

        controller.addListener(
          () {
            if (controller.indexIsChanging) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  final BuildContext? headerContext =
                      headerKeys[i]?.currentContext;

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

  /// Handles thumbs down action on a chat entry
  void _onThumbsUp(ChatEntry entry) {
    final int index = chatEntries.indexWhere((ChatEntry e) => e.id == entry.id);
    if (index != -1) {
      final ChatEntry updated = chatEntries[index].copyWith(like: 0);
      chatEntries[index] = updated;
      chatEntries.refresh();
      _initializeTabs();
    }
  }

  /// Handles thumbs up action on a chat entry
  void _onThumbsDown(ChatEntry entry) {
    final int index = chatEntries.indexWhere((ChatEntry e) => e.id == entry.id);
    if (index != -1) {
      final ChatEntry updated = chatEntries[index].copyWith(like: 1);
      chatEntries[index] = updated;
      chatEntries.refresh();
      _initializeTabs();
    }
  }

  /// Scrolls the main scroll view so that the given [key]'s widget (usually a section header)
  /// Is the header pinned?
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

    final bool pinned = headerOffset <= 0 || headerOffset <= kToolbarHeight;

    return pinned;
  }

  /// is aligned to the top of the viewport (used when a header is not pinned yet).
  /// This method scrolls the main scroll view to ensure that the widget associated with [key]
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

  /// Chat entries
  final RxList<ChatEntry> chatEntries = <ChatEntry>[
    ChatEntry(
      id: const Uuid().v4(),
      prompt: 'What is Flutter?',
      answers: <Answer>[
        Answer(
          id: 1,
          text:
              'Flutter is an open-source UI software development toolkit created by Google.',
          imageUrls: <String>[
            'https://picsum.photos/200',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200',
            'https://picsum.photos/200/300',
          ],
          pointsAnswers: StaticDeclarations.samplePoints.take(7).toList(),
        ),
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
      id: const Uuid().v4(),
      prompt: 'How do sticky headers work?',
      answers: <Answer>[
        Answer(
          id: 1,
          text:
              'Sticky headers are a UI pattern where headers remain visible at the top of the viewport as you scroll through content.',
          imageUrls: <String>[
            'https://picsum.photos/200/300',
            'https://picsum.photos/200',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200',
            'https://picsum.photos/200/300',
          ],
          pointsAnswers: StaticDeclarations.samplePoints..sublist(6),
        ),
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
      id: const Uuid().v4(),
      prompt: 'Is this statically coded?',
      answers: <Answer>[
        Answer(
          id: 1,
          text: 'Yes, this is statically coded.',
          imageUrls: <String>[
            'https://picsum.photos/200/300',
            'https://picsum.photos/200',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200',
            'https://picsum.photos/200/300',
            'https://picsum.photos/200/300',
          ],
          pointsAnswers: StaticDeclarations.samplePoints.take(5).toList(),
        ),
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
      id: const Uuid().v4(),
      prompt: 'What is Dart?',
      answers: <Answer>[
        Answer(
          id: 1,
          text:
              'Dart is a programming language optimized for building mobile, desktop, server, and web applications.',
          imageUrls: <String>[
            'https://picsum.photos/200/300',
            'https://picsum.photos/200',
            'https://picsum.photos/200/300',
          ],
          pointsAnswers: StaticDeclarations.samplePoints.take(3).toList(),
        ),
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
