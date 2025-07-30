import 'package:flutter/material.dart';
import '../models/chat_event.dart';
import 'icon_widget.dart';

/// Read Aloud Widget
class ReadAloudWidget extends StatelessWidget {
  /// Constructor for ReadAloudWidget
  const ReadAloudWidget({
    required this.chatEvent,
    required this.eventIndex,
    super.key,
    this.onReadOut,
  });

  /// Callbacks for various actions
  final void Function(ChatEventModel event, int index)? onReadOut;

  /// Chat event containing the dynamic data
  final ChatEventModel chatEvent;

  /// Index of the event in the list
  final int eventIndex;

  @override
  Widget build(BuildContext context) => IconWidget(
        onTap: () => onReadOut?.call(chatEvent, eventIndex),
        icon: (chatEvent.isReading ?? false)
            ? Icons.multitrack_audio
            : Icons.volume_up_outlined,
        name: (chatEvent.isReading ?? false) ? 'Reading..' : 'Read Aloud',
        radius: 40,
        iconSize: 20,
        border: Border.all(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );
}
