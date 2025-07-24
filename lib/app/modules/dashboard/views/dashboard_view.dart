import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nigerian_igbo/app/data/config/app_colors.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nigerian_igbo/app/modules/dashboard/models/chat_event.dart';
import 'package:nigerian_igbo/app/modules/dashboard/models/keyword_link.dart';
import 'package:nigerian_igbo/app/modules/dashboard/models/source_link.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/custom_chat_field.dart';

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
            // ...List<Widget>.generate(
            //   controller.chatEntries().length * 2 - 1,
            //       (int i) {
            //     final bool isDivider = i.isOdd;
            //     final int index = i ~/ 2;
            //
            //     if (isDivider) {
            //       return SliverToBoxAdapter(
            //         child: Padding(
            //           padding: REdgeInsets.only(bottom: 20),
            //           child: Divider(
            //             color: Colors.grey.shade300,
            //             thickness: 1,
            //             height: 1,
            //           ),
            //         ),
            //       );
            //     }
            //
            //     return ChatPromptSection(
            //       sectionKey: controller.promptKeys[index]!,
            //       headerKey: controller.headerKeys[index]!,
            //       chatEntry: controller.chatEntries()[index],
            //       tabs: controller.tabItems[index] ?? <TabItem>[],
            //       tabController: controller.tabControllers[index],
            //       currentTabIndex:
            //       controller.tabIndices[index]?.value ?? 0,
            //     );
            //   },
            // ),

            ...List<Widget>.generate(
              controller.chatEvent.length * 2 - (controller.chatEvent.isEmpty ? 0 : 1),
                  (int i) {
                final bool isDivider = i.isOdd;
                final int index = i ~/ 2;

                if (isDivider && index < controller.chatEvent.length - 1) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
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

                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (event.html.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Html(data: event.html.toString(), style: <String,
                            Style>{
                          'img': Style(
                            width: Width.auto(),
                            height: Height.auto(),
                            margin: Margins.symmetric(vertical: 10),
                          ),
                          'code': Style(
                            backgroundColor: Colors.grey.shade200,
                            padding: HtmlPaddings.all(8),
                            fontFamily: 'Courier',
                            whiteSpace: WhiteSpace.pre,
                            display: Display.block,
                          ),
                          'pre': Style(
                            backgroundColor: Colors.grey.shade100,
                            padding: HtmlPaddings.all(12),
                            fontFamily: 'Courier',
                            whiteSpace: WhiteSpace.pre,
                            display: Display.block,
                          ),
                        }, extensions: <HtmlExtension>[
                          TagExtension(
                            tagsToExtend: {'img'},
                            builder: (context) {
                              final String? src =
                              context.element?.attributes['src'];
                              if (src == null || src.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ConstrainedBox(
                                    constraints:
                                    const BoxConstraints(maxHeight: 300),
                                    child: Image.network(
                                      src,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (ctx, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 200,
                                          alignment: Alignment.center,
                                          child:
                                          const CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) =>
                                      const SizedBox(
                                          height: 200,
                                          child: Icon(Icons.broken_image)),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          TagExtension(
                            tagsToExtend: <String>{'code'},
                            builder: (ExtensionContext context) {
                              final String? codeText = context.element?.text;
                              return Container(
                                color: Colors.grey.shade200,
                                padding: const EdgeInsets.all(12),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    codeText ?? '',
                                    style: const TextStyle(
                                        fontFamily: 'Courier', fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                        ]),
                      ),

                    if (event.sourceLinks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Sources',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            ...event.sourceLinks.map(
                                  (SourceLink link) => Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 4),
                                child: InkWell(
                                  onTap: () {},
                                  child: Text(
                                    link.url ?? '',
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (event.followUpQuestions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Follow-up Questions',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            ...event.followUpQuestions.map(
                                  (String q) => Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    controller.chatInputController.text = q;
                                    controller.loadStreamedHtmlContent();
                                  },
                                  child: Text(
                                    '• $q',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (event.keywords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.keywords
                              .map(
                                (KeywordLink keyword) => ActionChip(
                              label: Text(keyword.keyword ?? ''),
                              onPressed: () {
                                controller.chatInputController.text =
                                    keyword.keyword ?? '';
                                controller.loadStreamedHtmlContent();
                              },
                            ),
                          )
                              .toList(),
                        ),
                      ),

                    if (event.brands.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.brands
                              .map(
                                (String brand) => Chip(label: Text(brand)),
                          )
                              .toList(),
                        ),
                      ),
                  ]),
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
