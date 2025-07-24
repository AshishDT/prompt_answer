import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nigerian_igbo/app/data/config/app_colors.dart';
import 'package:nigerian_igbo/app/modules/dashboard/models/tab_item.dart';
import '../controllers/dashboard_controller.dart';
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
            Padding(
              padding: REdgeInsets.only(
                left: 16,
                right: 16,
                top: 40,
              ),
              child: Obx(
                () => CustomScrollView(
                  controller: controller.scrollController,
                  slivers: <Widget>[
                    ...List<Widget>.generate(
                      controller.chatEntries().length * 2 - 1,
                      (int i) {
                        final bool isDivider = i.isOdd;
                        final int index = i ~/ 2;

                        if (isDivider) {
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

                        return ChatPromptSection(
                          sectionKey: controller.promptKeys[index]!,
                          headerKey: controller.headerKeys[index]!,
                          chatEntry: controller.chatEntries()[index],
                          tabs: controller.tabItems[index] ?? <TabItem>[],
                          tabController: controller.tabControllers[index],
                          currentTabIndex:
                              controller.tabIndices[index]?.value ?? 0,
                        );
                      },
                    ),
                    SliverToBoxAdapter(
                      child: 120.verticalSpace,
                    ),
                  ],
                ),
              ),
            ),

            // Pinned chat input
            const Positioned(
              left: 16,
              right: 16,
              bottom: 0,
              child: CustomChatInput(),
            ),
          ],
        ),
      );
}
