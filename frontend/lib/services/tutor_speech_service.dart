import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'dart:convert';

class TutorSpeechService {
  final Record _recorder = Record();
  bool _isRecording = false;
  String? _audioPath;

  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _audioPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        // Start recording
        // We use standard WAV for compatibility with Whisper/ffmpeg
        await _recorder.start(
          path: _audioPath!,
          encoder: AudioEncoder.wav,
          samplingRate: 16000,
          numChannels: 1,
        );
        _isRecording = true;
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  // Returns { "text": "...", "reply": "...", "pause_analysis": ... } or null
  Future<Map<String, dynamic>?> stopRecordingAndSend() async {
    if (!_isRecording || _audioPath == null) return null;

    try {
      await _recorder.stop();
      _isRecording = false;

      final file = File(_audioPath!);
      if (!await file.exists()) {
        print('Audio file not found');
        return null;
      }

      // Send to backend /ai-tutor/speech
      final uri = Uri.parse("${ApiService.baseUrl}/ai-tutor/speech");
      final request = http.MultipartRequest('POST', uri);
      
      request.files.add(await http.MultipartFile.fromPath(
        'audio', 
        file.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Clean up local file
      await file.delete(); 

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("AI Tutor Response: $data");
        return data;
      } else {
        print('Server error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error processing speech: $e');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
      if (_audioPath != null) {
        final file = File(_audioPath!);
        if (await file.exists()) await file.delete();
      }
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}
