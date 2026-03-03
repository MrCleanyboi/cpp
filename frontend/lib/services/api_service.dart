import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

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
