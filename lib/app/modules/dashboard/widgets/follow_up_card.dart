import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: REdgeInsets.symmetric(vertical: 6),
        child: Material(
          elevation: 1.5,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Container(
            padding: REdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
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
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 20.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
