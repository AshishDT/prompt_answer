import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/data/config/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import 'chat_prompt_screen.dart';

/// Dashboard View
class DashboardView extends GetView<DashboardController> {
  /// Constructor for DashboardView
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.kffffff,
        appBar: AppBar(
          foregroundColor: AppColors.kffffff,
          shadowColor: AppColors.kffffff,
          surfaceTintColor: AppColors.kffffff,
          backgroundColor: AppColors.kffffff,
          elevation: 0,
          title: Text(
            'Chat UI',
            style: GoogleFonts.poppins(
              color: AppColors.k000000,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Obx(
            () => CustomScrollView(
              controller: controller.scrollController,
              slivers: List<Widget>.generate(
                controller.chatEntries().length,
                (int i) => ChatPromptSection(
                  sectionKey: controller.promptKeys[i]!,
                  headerKey: controller.headerKeys[i]!,
                  chatEntry: controller.chatEntries()[i],
                  tabs: controller.tabItems[i] ?? [],
                  tabController: controller.tabControllers[i],
                  currentTabIndex: controller.tabIndices[i]?.value ?? 0,
                ),
              ),
            ),
          ),
        ),
      );
}
