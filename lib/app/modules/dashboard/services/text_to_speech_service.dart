import 'dart:developer';
import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:nigerian_igbo/app/data/config/logger.dart';

/// Text to Speech Service
class TextToSpeechService {
  /// Singleton instance
  TextToSpeechService() {
    _tts
      ..setCompletionHandler(() => isReading(false))
      ..setCancelHandler(() => isReading(false))
      ..setErrorHandler(
        (dynamic msg) {
          logE('TextToSpeechService: Error occurred: $msg');
          isReading(false);
        },
      )
      ..setLanguage('en-US')
      ..setPitch(1)
      ..awaitSpeakCompletion(true)
      ..setVolume(1)
      ..setSpeechRate(0.5);
  }

  /// Is currently reading
  final RxBool isReading = false.obs;

  /// Instance of FlutterTts
  final FlutterTts _tts = FlutterTts();

  /// Get the singleton instance
  Future<void> readAloud(
    String text, {
    VoidCallback? onComplete,
  }) async {
    if (text.trim().isEmpty) {
      return;
    }

    await _tts.stop();
    isReading(true);

    log(text);

    final List<String> chunks = _chunkText(text);

    logWTF('Chunks length || ${chunks.length}');

    await _tts.awaitSpeakCompletion(true);

    for (final String chunk in chunks) {
      if (!isReading()) {
        break;
      }
      await _tts.speak(chunk);
    }

    isReading(false);
    onComplete?.call();
  }

  /// Check if TTS is currently reading
  Future<void> stop() async {
    await _tts.stop();
    isReading(false);
  }

  /// Chunks the text into smaller parts to fit TTS limits
  List<String> _chunkText(
    String text, {
    int maxChunkLength = 350,
  }) {
    final List<String> sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final List<String> chunks = <String>[];

    final StringBuffer buffer = StringBuffer();

    for (final String sentence in sentences) {
      if ((buffer.length + sentence.length) > maxChunkLength) {
        if (buffer.isNotEmpty) {
          chunks.add(buffer.toString().trim());
          buffer.clear();
        }
      }
      buffer
        ..write(sentence)
        ..write(' ');
    }

    if (buffer.isNotEmpty) {
      chunks.add(buffer.toString().trim());
    }

    return chunks;
  }
}
