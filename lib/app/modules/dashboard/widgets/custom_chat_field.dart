import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'icon_widget.dart';

/// Custom chat input widget for the dashboard
class CustomChatInput extends StatelessWidget {
  /// Constructor for CustomChatInput
  const CustomChatInput({super.key});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: REdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        margin: REdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom > 0
              ? MediaQuery.of(context).systemGestureInsets.bottom
              : 0,
          left: MediaQuery.of(context).viewPadding.bottom > 0
              ? 16
              : 0,
          right: MediaQuery.of(context).viewPadding.bottom > 0
              ? 16
              : 0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: MediaQuery.of(context).viewPadding.bottom > 0
                ? const Radius.circular(24)
                : Radius.zero,
            bottomRight: MediaQuery.of(context).viewPadding.bottom > 0
                ? const Radius.circular(24)
                : Radius.zero,
          ).r,
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
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Ask anything',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 14.sp,
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
            10.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const IconWidget(
                      icon: Icons.add,
                    ),
                    8.horizontalSpace,
                    const IconWidget(
                      icon: Icons.mic,
                    ),
                    8.horizontalSpace,
                    const IconWidget(
                      icon: Icons.image,
                      name: 'Image',
                    ),
                  ],
                ),
                10.horizontalSpace,
                const IconWidget(
                  icon: Icons.arrow_upward,
                  shape: BoxShape.circle,
                )
              ],
            ),
          ],
        ),
      );
}
