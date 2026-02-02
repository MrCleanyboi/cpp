import 'package:flutter_tts/flutter_tts.dart';
import 'tutor_speech_service.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  final TutorSpeechService _speechService = TutorSpeechService();
  
  bool _isInitialized = false;
  bool _isListening = false;

  // Initialize TTS
  Future<void> init() async {
    if (_isInitialized) return;

    // TTS Setup
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _isInitialized = true;
  }
  
  // TTS Methods
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // STT Methods using TutorSpeechService
  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onListeningStateChanged,
  }) async {
    if (!_isInitialized) await init();

    if (!_isListening) {
      _isListening = true;
      onListeningStateChanged(true);

      try {
        await _speechService.startRecording();
      } catch (e) {
        print('Error starting listening: $e');
        _isListening = false;
        onListeningStateChanged(false);
      }
    }
  }

  // Returns full map {text, reply, pause_analysis} or null
  Future<Map<String, dynamic>?> stopListening(Function(bool) onListeningStateChanged) async {
    if (_isListening) {
      _isListening = false;
      onListeningStateChanged(false);

      try {
        // Stop recording and get FULL backend response
        final result = await _speechService.stopRecordingAndSend();
        return result;
      } catch (e) {
        print('Error stopping listening: $e');
        return null;
      }
    }
    return null;
  }
  
  bool get isListening => _isListening;

  void dispose() {
    _speechService.dispose();
  }
}
