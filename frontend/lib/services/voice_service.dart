import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  
  // Mapping for human-readable names to locale codes
  final Map<String, String> _langMap = {
    "German": "de-DE",
    "French": "fr-FR",
    "Spanish": "es-ES",
    "English": "en-US",
  };

  Future<void> init() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45); // Slightly slower for better clarity on some browsers
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Enable this to ensure speak() doesn't overlap or return prematurely
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> setLanguage(String languageName) async {
    String code = _langMap[languageName] ?? "en-US";
    await _flutterTts.setLanguage(code);
    print("DEBUG: TTS Language set to $code ($languageName)");
  }

  Future<void> speak(String text) async {
    // 1. Stop any current speech to prevent overlap/distortion
    await _flutterTts.stop();

    // 2. Clean text: Remove suffixes like (A1), (B2), etc.
    String cleanText = text.replaceAll(RegExp(r'\((A1|A2|B1|B2|C1|C2)\)'), '').trim();
    if (cleanText.isEmpty) return;
    
    // 3. Start synthesis
    await _flutterTts.speak(cleanText);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }
}
