import 'package:flutter_tts/flutter_tts.dart';

/// Read aloud service that handles text-to-speech functionality
class ReadAloudService {

  /// Factory constructor to return the singleton instance
  factory ReadAloudService() => _instance;

  /// Private constructor for singleton pattern
  ReadAloudService._internal() {
    _flutterTts..setLanguage('en-US')
    ..setPitch(1)
    ..setSpeechRate(0.5)
    ..setCompletionHandler(() {
      _isSpeaking = false;
    })
    ..setCancelHandler(() {
      _isSpeaking = false;
    })
      ..setErrorHandler((dynamic message) => _isSpeaking = false);
  }

  /// Singleton instance of ReadAloudService
  static final ReadAloudService _instance = ReadAloudService._internal();

  /// FlutterTts instance for text-to-speech functionality
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  /// Toggles the speaking state. If currently speaking, it stops; otherwise, it starts speaking the provided text.
  Future<void> toggle(String text) async {
    if (_isSpeaking) {
      await stop();
    } else {
      await speak(text);
    }
  }

  /// Speaks the provided text using text-to-speech
  Future<void> speak(String text) async {
    _isSpeaking = true;
    await _flutterTts.speak(text);
  }

  /// Stops the text-to-speech if it is currently speaking
  Future<void> stop() async {
    _isSpeaking = false;
    await _flutterTts.stop();
  }

  /// Checks if the service is currently speaking
  bool get isSpeaking => _isSpeaking;
}
