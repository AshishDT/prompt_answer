import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/data/config/app_colors.dart';
import 'package:nigerian_igbo/app/data/config/app_images.dart';
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
        appBar: AppBar(
          surfaceTintColor: AppColors.kffffff,
          shadowColor: AppColors.kffffff,
          leading: const Icon(Icons.menu),
          foregroundColor: AppColors.kffffff,
          backgroundColor: AppColors.kffffff,
          elevation: 1,
          title: Text(
            'Chat Prompts',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.k000000,
            ),
          ),
        ),
        extendBody: true,
        body: Align(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: GetPlatform.isWeb ? 900 : Get.width,
            ),
            child: Stack(
              children: <Widget>[
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Obx(
                    () => Visibility(
                      visible: controller.chatEvents().isEmpty,
                      replacement: SizedBox(
                        width: context.width,
                      ),
                      child: Align(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Image(
                              width: 50,
                              height: 50,
                              image: AssetImage(
                                AppImages.chat,
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Text(
                              'No conversations yet',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => CustomScrollView(
                    controller: controller.scrollController,
                    slivers: <Widget>[
                      if (controller.chatEvents.isNotEmpty) ...<Widget>[
                        ...List<Widget>.generate(
                          controller.chatEvents.length * 2 -
                              (controller.chatEvents.isEmpty ? 0 : 1),
                          (int i) {
                            final bool isDivider = i.isOdd;
                            final int index = i ~/ 2;

                            if (isDivider &&
                                index < controller.chatEvents.length - 1) {
                              return SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                    height: 1,
                                  ),
                                ),
                              );
                            }

                            if (index >= controller.chatEvents.length) {
                              return const SliverToBoxAdapter(
                                  child: SizedBox.shrink());
                            }

                            final ChatEventModel event =
                                controller.chatEvents[index];

                            return ChatPromptSection(
                              sectionKey: controller.promptKeys[index]!,
                              headerKey: controller.headerKeys[index]!,
                              isPinned: controller.pinnedStates[index](),
                              chatEvent: event,
                              shouldStick: index > 0 ||
                                  !controller.firstSectionShouldUnstick.value,
                              sectionIndex: index,
                              tabs: controller.tabItems[index] ?? <TabItem>[],
                              tabController: controller.tabControllers[index],
                              currentTabIndex:
                                  controller.tabIndices[index]?.value ?? 0,
                              prompt: event.promptKeyword ?? 'Loading...',
                            );
                          },
                        ),
                      ],

                      // Extra bottom spacing
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pinned chat input
                Positioned(
                  bottom: 0,
                  left: GetPlatform.isWeb ? 16 : 0,
                  right: GetPlatform.isWeb ? 16 : 0,
                  child: CustomChatInput(
                    controller: controller.chatInputController,
                    onSubmitted: () {
                      controller.loadStreamedHtmlContent();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
