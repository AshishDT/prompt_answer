import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/modules/dashboard/models/tab_item.dart';
import '../models/chat_model.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

/// ChatPromptSection displays a section of chat prompts with tabs for answers and sources
class ChatPromptSection extends StatelessWidget {
  /// Constructor for ChatPromptSection
  const ChatPromptSection({
    required this.chatEntry,
    required this.tabs,
    required this.tabController,
    required this.currentTabIndex,
    required this.sectionKey,
    required this.headerKey,
    super.key,
  });

  /// Chat entry containing the prompt, answers, and sources
  final ChatEntry chatEntry;

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

  @override
  Widget build(BuildContext context) => SliverStickyHeader(
        key: sectionKey,
        header: Container(
          key: headerKey,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
          ),
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                chatEntry.prompt,
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (tabs.length > 1 && tabController != null)
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
          ),
        ),
        sliver: SliverToBoxAdapter(
          child: tabs.length == 1
              ? tabs[0].builder()
              : tabs[currentTabIndex].builder(),
        ),
      );
}
