import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

/// Text to Speech Service
class TextToSpeechService {
  /// Singleton instance
  TextToSpeechService() {
    _tts
      ..setCompletionHandler(() => isReading(false))
      ..setCancelHandler(() => isReading(false))
      ..setErrorHandler((dynamic msg) => isReading(false))
      ..setLanguage('en-US')
      ..setPitch(1)
      ..setSpeechRate(0.5);
  }

  /// Is currently reading
  final RxBool isReading = false.obs;

  /// Instance of FlutterTts
  final FlutterTts _tts = FlutterTts();

  /// Get the singleton instance
  Future<void> readAloud(String text) async {
    if (text.trim().isEmpty) {
      return;
    }

    await _tts.stop();
    isReading(true);

    await _tts.speak(text);
  }

  /// Check if TTS is currently reading
  Future<void> stop() async {
    await _tts.stop();
    isReading(false);
  }
}
