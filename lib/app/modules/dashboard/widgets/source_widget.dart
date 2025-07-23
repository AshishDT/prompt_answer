import 'package:flutter/material.dart';

import '../models/chat_model.dart';

/// Source Widget displays sources related to a chat entry
class SourceWidget extends StatelessWidget {
  /// Constructor for SourceWidget
  const SourceWidget({
    required this.entry,
    required this.scrollKey,
    super.key,
  });

  /// Entry containing the answers to display
  final ChatEntry entry;

  /// Scroll key for the widget
  final Key scrollKey;

  @override
  Widget build(BuildContext context) => Padding(
        key: scrollKey,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: List<Widget>.generate(
            entry.sources.length,
            (int i) {
              final Source source = entry.sources[i];
              return ListTile(
                title: Text(source.title),
                subtitle: Text(source.url),
                leading: const Icon(Icons.link),
                contentPadding: EdgeInsets.zero,
                onTap: () {},
              );
            },
          ),
        ),
      );
}
