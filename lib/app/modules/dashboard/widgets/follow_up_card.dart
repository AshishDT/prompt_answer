import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nigerian_igbo/app/data/config/app_colors.dart';

/// FollowUpCard widget to display a card with a question and an add button
class FollowUpCard extends StatelessWidget {
  /// Constructor for FollowUpCard
  const FollowUpCard({
    required this.question,
    super.key,
    this.onAddTap,
  });

  /// Question to display in the card
  final String question;

  /// Callback when the card is tapped
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: REdgeInsets.only(bottom: 10),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        20.horizontalSpace,
        InkWell(
          onTap: onAddTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.k364958)
            ),
            child: Icon(
              Icons.add,
              size: 18.sp,
              color: AppColors.k364958,
            ),
          ),
        ),
      ],
    ),
  );
}
