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

    await _tts.speak(text);

    isReading(false);
    onComplete?.call();
  }

  /// Check if TTS is currently reading
  Future<void> stop() async {
    await _tts.stop();
    isReading(false);
  }
}
