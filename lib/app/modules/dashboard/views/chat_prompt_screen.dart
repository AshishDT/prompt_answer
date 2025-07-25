import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/modules/dashboard/models/tab_item.dart';
import '../models/chat_event.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

/// ChatPromptSection displays a section of chat prompts with tabs for answers and sources
class ChatPromptSection extends StatelessWidget {
  /// Constructor for ChatPromptSection
  const ChatPromptSection({
    required this.chatEvent,
    required this.tabs,
    required this.tabController,
    required this.currentTabIndex,
    required this.sectionKey,
    required this.headerKey,
    required this.prompt,
    this.isPinned = false,
    super.key,
  });

  /// Chat event containing the dynamic data
  final ChatEventModel chatEvent;

  /// List of tabs to display in the section
  final List<TabItem> tabs;

  /// Tab controller for managing the tabs
  final TabController? tabController;

  /// Current index of the selected tab
  final int currentTabIndex;

  /// Key for the section, used for scrolling and identification
  final GlobalKey sectionKey;

  /// Header key for the section, used for sticky header functionality
  final GlobalKey headerKey;

  /// The prompt text to display in the header
  final String prompt;

  /// Is pinned state for the header
  final bool isPinned;

  @override
  Widget build(BuildContext context) => SliverStickyHeader(
        key: sectionKey,
        header: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          key: headerKey,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
          ),
          padding: REdgeInsets.only(left: 12, right: 12, top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Text(
                    prompt,
                    maxLines: isPinned ? 1 : null,
                    overflow: isPinned ? TextOverflow.ellipsis : null,
                    style: GoogleFonts.poppins(
                      fontSize: isPinned ? 18.sp : 26.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (tabs.length > 1 && tabController != null) ...<Widget>[
                TabBar(
                  controller: tabController,
                  dividerHeight: 0,
                  padding: EdgeInsets.zero,
                  isScrollable: true,
                  splashBorderRadius: BorderRadius.zero,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2),
                  ),
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorAnimation: TabIndicatorAnimation.elastic,
                  labelPadding: const EdgeInsets.only(right: 30),
                  tabs: tabs
                      .map(
                        (TabItem tab) => Tab(
                          iconMargin: EdgeInsets.zero,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(Icons.ac_unit_outlined, size: 16),
                              const SizedBox(width: 6),
                              Text(tab.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        sliver: SliverToBoxAdapter(
          child: tabs.length == 1
              ? tabs[0].builder()
              : tabs[currentTabIndex].builder(),
        ),
      );
}
