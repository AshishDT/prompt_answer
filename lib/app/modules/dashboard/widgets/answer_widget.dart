import 'package:flutter/material.dart';

import '../models/chat_model.dart';

/// Answer Widget
class AnswerWidget extends StatelessWidget {
  /// Constructor for AnswerWidget
  const AnswerWidget({
    required this.entry,
    super.key,
  });

  /// Entry containing the answers to display
  final ChatEntry entry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(
            entry.answers.length,
            (int i) => Padding(
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
