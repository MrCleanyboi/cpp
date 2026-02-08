import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import 'dart:convert';

class WitSpeechService {
  final Record _recorder = Record();
  bool _isRecording = false;
  String? _audioPath;

  Future<void> startRecording() async {
    try {
      // Check and request permission
      if (await _recorder.hasPermission()) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        _audioPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        // Start recording (API for version 4.4.4)
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

  Future<String?> stopRecordingAndTranscribe() async {
    if (!_isRecording || _audioPath == null) return null;

    try {
      // Stop recording
      await _recorder.stop();
      _isRecording = false;

      // Read the audio file
      final file = File(_audioPath!);
      if (!await file.exists()) {
        print('Audio file not found');
        return null;
      }

      // Send to Wit.ai
      final bytes = await file.readAsBytes();
      
      final response = await http.post(
        Uri.parse(ApiConfig.witApiEndpoint),
        headers: {
          'Authorization': 'Bearer ${ApiConfig.witApiToken}',
          'Content-Type': 'audio/wav',
        },
        body: bytes,
      );

      // Clean up the file
      await file.delete();

      print('Wit.ai response status: ${response.statusCode}');
      print('Wit.ai response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);
          
          // Wit.ai returns the text in the 'text' field or sometimes '_text'
          final text = jsonResponse['text'] ?? jsonResponse['_text'] ?? '';
          
          print('Transcribed text: $text');
          return text.toString();
        } catch (e) {
          print('JSON parse error: $e');
          print('Raw response: ${response.body}');
          return null;
        }
      } else {
        print('Wit.ai error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error transcribing: $e');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
      
      // Clean up file if exists
      if (_audioPath != null) {
        final file = File(_audioPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  bool get isRecording => _isRecording;

  void dispose() {
    _recorder.dispose();
  }
}
