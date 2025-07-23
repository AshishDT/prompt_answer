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
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.link, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            source.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            source.url,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
}
