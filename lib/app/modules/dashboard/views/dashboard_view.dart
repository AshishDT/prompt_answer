import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nigerian_igbo/app/data/config/app_colors.dart';
import 'package:nigerian_igbo/app/modules/dashboard/models/chat_event.dart';
import '../controllers/dashboard_controller.dart';
import '../models/tab_item.dart';
import '../widgets/custom_chat_field.dart';
import 'chat_prompt_screen.dart';

/// Dashboard View
class DashboardView extends GetView<DashboardController> {
  /// Constructor for DashboardView
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.kffffff,
    extendBody: true,
    body: Stack(
      children: <Widget>[
        Obx(() => CustomScrollView(
          controller: controller.scrollController,
          slivers: <Widget>[
            // Use the tab-based system with ChatPromptSection
            ...List<Widget>.generate(
              controller.chatEvent.length * 2 - (controller.chatEvent.isEmpty ? 0 : 1),
                  (int i) {
                final bool isDivider = i.isOdd;
                final int index = i ~/ 2;

                if (isDivider && index < controller.chatEvent.length - 1) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: REdgeInsets.only(bottom: 20),
                      child: Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                  );
                }

                if (index >= controller.chatEvent.length) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                final ChatEventModel event = controller.chatEvent[index];

                return ChatPromptSection(
                  sectionKey: controller.promptKeys[index]!,
                  headerKey: controller.headerKeys[index]!,
                  chatEvent: event,
                  tabs: controller.tabItems[index] ?? <TabItem>[],
                  tabController: controller.tabControllers[index],
                  currentTabIndex: controller.tabIndices[index]?.value ?? 0,
                  prompt: event.promptKeyword ?? 'Loading...',
                );
              },
            ),

            // Writing indicator when isWriting is true
            if (controller.isWriting.value)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI is writing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Extra bottom spacing
            SliverToBoxAdapter(child: 200.verticalSpace),
          ],
        )),

        // Pinned chat input
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: CustomChatInput(
            controller: controller.chatInputController,
            onSubmitted: () {
              controller.loadStreamedHtmlContent();
            },
          ),
        ),
      ],
    ),
  );
}
