import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  // Use localhost for Windows/iOS/Web, 10.0.2.2 for Android Emulator
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    }
    if (io.Platform.isAndroid) {
      return "http://10.0.2.2:8000"; 
    }
    return "http://127.0.0.1:8000";
  }

  static Future<String> sendMessage(String message) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/ai-tutor/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
        }),
      );
      
      if (res.statusCode == 200) {
        // The backend returns { "reply": "..." }
        return jsonDecode(res.body)["reply"];
      } else {
        return "Error: Server responded with status ${res.statusCode}";
      }
    } catch (e) {
      return "Error: Could not connect to AI server. Make sure the backend is running.";
    }
  }
}
