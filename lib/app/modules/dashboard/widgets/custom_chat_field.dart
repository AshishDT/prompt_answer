import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'icon_widget.dart';

/// Custom chat input widget for the dashboard
class CustomChatInput extends StatelessWidget {
  /// Constructor for CustomChatInput
  const CustomChatInput({
    required this.controller,
    super.key,
    this.onSubmitted,
  });

  /// On submitted callback
  final void Function()? onSubmitted;

  /// Creates a controller for the text field
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        margin: GetPlatform.isWeb
            ? const EdgeInsets.only(
                bottom: 30,
              )
            : EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom > 0
                    ? MediaQuery.of(context).systemGestureInsets.bottom
                    : 0,
                left: MediaQuery.of(context).viewPadding.bottom > 0 ? 16 : 0,
                right: MediaQuery.of(context).viewPadding.bottom > 0 ? 16 : 0,
              ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: GetPlatform.isWeb
              ? BorderRadius.circular(24)
              : BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: MediaQuery.of(context).viewPadding.bottom > 0
                      ? const Radius.circular(24)
                      : Radius.zero,
                  bottomRight: MediaQuery.of(context).viewPadding.bottom > 0
                      ? const Radius.circular(24)
                      : Radius.zero,
                ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, 1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          // border: Border.all(color: Colors.grey.shade600),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: controller,
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Ask anything',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                disabledBorder: InputBorder.none,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconWidget(
                      icon: Icons.add,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    IconWidget(
                      icon: Icons.mic,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    IconWidget(
                      icon: Icons.image,
                      name: 'Image',
                    ),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                IconWidget(
                  onTap: () {
                    onSubmitted?.call();
                    FocusScope.of(context).unfocus();
                  },
                  icon: Icons.arrow_upward,
                  shape: BoxShape.circle,
                )
              ],
            ),
          ],
        ),
      );
}
