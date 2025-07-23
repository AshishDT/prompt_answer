import 'package:flutter/material.dart';

import '../models/chat_model.dart';

/// Answer Widget
class AnswerWidget extends StatelessWidget {
  /// Constructor for AnswerWidget
  const AnswerWidget({
    required this.entry,
    required this.scrollKey,
    super.key,
  });

  /// Entry containing the answers to display
  final ChatEntry entry;

  /// Scroll key
  final Key scrollKey;
  @override
  Widget build(BuildContext context) => Padding(
        key: scrollKey,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(
            entry.answers.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                entry.answers[i],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );
}
