import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:nigerian_igbo/app/data/config/logger.dart';
import 'event_processor_mixin.dart';
import 'html_data_mixin.dart';


/// Mixin to handle stream processing
mixin StreamHandlerMixin on GetxController implements HtmlDataMixin, EventProcessorMixin {
  /// Implements the abstract method from HtmlDataMixin
  @override
  Future<void> processStream(Stream<List<int>> byteStream) async {
    final Stream<String> lines = byteStream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .expand((String chunk) => const LineSplitter().convert(chunk));

    String? currentEvent;

    await for (final String line in lines) {
      if (line.startsWith('event:')) {
        currentEvent = line.replaceFirst('event:', '').trim();
        logWTF('HtmlDataMixin: New event received: $currentEvent');
      } else if (line.startsWith('data:')) {
        final String rawData = line.replaceFirst('data:', '').trim();
        if (currentEvent == null || rawData.isEmpty) {
          logWTF('HtmlDataMixin: Skipping empty event or data line');
          continue;
        }
        handleEvent(currentEvent, rawData);
      }
    }
  }
}
