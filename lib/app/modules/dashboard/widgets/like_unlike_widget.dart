import 'package:flutter/material.dart';

/// Like unlike widget that displays thumbs up and thumbs down icons
class LikeUnlikeWidget extends StatelessWidget {
  /// Constructor for LikeUnlikeWidget
  const LikeUnlikeWidget({
    required this.selected,
    required this.onThumbUp,
    required this.onThumbDown,
    super.key,
  });

  /// selected: 1 (thumbs up), -1 (thumbs down), or null (none)
  final int? selected;

  /// Callback when thumbs up is tapped
  final VoidCallback onThumbUp;

  /// Callback when thumbs down is tapped
  final VoidCallback onThumbDown;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: onThumbUp,
            child: Icon(
              selected == 0 ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: selected == 0 ? Colors.green : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          GestureDetector(
            onTap: onThumbDown,
            child: Icon(
              selected == 1 ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: selected == 1 ? Colors.red : Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
}
