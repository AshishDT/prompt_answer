import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Typing shimmer effect widget
class TypingShimmer extends StatefulWidget {
  /// Constructor for TypingShimmer
  const TypingShimmer({super.key});

  @override
  State<TypingShimmer> createState() => _TypingShimmerState();
}

class _TypingShimmerState extends State<TypingShimmer>
    with SingleTickerProviderStateMixin {
  /// Animation controller and animations for the typing shimmer effect
  late final AnimationController _controller;

  /// Animations for the widths of the typing lines
  late final Animation<double> _width1;

  /// Animation for the second typing line
  late final Animation<double> _width2;

  /// Animation for the third typing line
  late final Animation<double> _width3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();

    _width1 = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.33, curve: Curves.easeOut),
      ),
    );
    _width2 = Tween<double>(begin: 0, end: 70).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.34,
          0.66,
          curve: Curves.easeOut,
        ),
      ),
    );
    _width3 = Tween<double>(begin: 0, end: 90).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.67,
          1,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLine(Animation<double> width) => AnimatedBuilder(
        animation: width,
        builder: (_, __) => Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 5.h,
            width: width.value,
            margin: REdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        period: const Duration(milliseconds: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLine(_width1),
            _buildLine(_width2),
            _buildLine(_width3),
          ],
        ),
      );
}
