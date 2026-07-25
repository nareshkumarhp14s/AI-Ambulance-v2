import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  VoiceService._();

  static final VoiceService instance = VoiceService._();

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();

  bool _isListening = false;

  bool get isListening => _isListening;

  /// Initialize
  Future<void> initialize() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    await _speech.initialize();
  }

  /// Speak
  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stop Speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// Listen
  Future<String?> listen({
    Duration duration = const Duration(seconds: 8),
  }) async {
    final available = await _speech.initialize();

    if (!available) {
      return null;
    }

    String result = "";

    _isListening = true;

    await _speech.listen(
      listenFor: duration,
      onResult: (value) {
        result = value.recognizedWords;
      },
    );

    await Future.delayed(duration);

    await _speech.stop();

    _isListening = false;

    return result.trim().isEmpty ? null : result;
  }

  /// Check Emergency Command
  bool isEmergencyCommand(String text) {
    final command = text.toLowerCase();

    const commands = [
      "help",
      "emergency",
      "save me",
      "ambulance",
      "call ambulance",
      "sos",
      "bachao",
      "madad",
      "meri help karo",
      "ambulance bulao",
      "help me",
      "doctor",
      "accident",
    ];

    return commands.any(command.contains);
  }

  /// Dispose
  Future<void> dispose() async {
    await _speech.stop();
    await _tts.stop();
  }
}
