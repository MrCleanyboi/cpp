import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// API Service for Communications Module
/// 
/// Handles all REST API calls for partner matching
class MatchingApiService {
  // Backend URL - dynamic based on platform
  static String get baseUrl => '${ApiConfig.baseUrl}/api/match';
  
  String? _token;
  
  /// Initialize service with authentication token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }
  
  /// Get authorization headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
  
  /// Join the waiting queue
  /// 
  /// Returns immediately matched partner or queue status
  Future<Map<String, dynamic>> joinQueue({
    required String targetLanguage,
    required String proficiencyLevel,
    String practiceMode = 'conversation',
    List<String> topics = const [],
  }) async {
    await initialize();
    
    final response = await http.post(
      Uri.parse('$baseUrl/join-queue'),
      headers: _headers,
      body: jsonEncode({
        'target_language': targetLanguage,
        'proficiency_level': proficiencyLevel,
        'practice_mode': practiceMode,
        'topics': topics,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required. Please login again.');
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to join queue');
    } else {
      throw Exception('Failed to join queue: ${response.statusCode}');
    }
  }
  
  /// Leave the waiting queue
  Future<bool> leaveQueue() async {
    await initialize();
    
    final response = await http.post(
      Uri.parse('$baseUrl/leave-queue'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      // Not in queue - that's fine
      return false;
    } else {
      throw Exception('Failed to leave queue');
    }
  }
  
  /// Get current match status
  /// 
  /// Returns active match, queue status, or no match
  Future<Map<String, dynamic>> getMatchStatus() async {
    await initialize();
    
    print('DEBUG: Polling match status from $baseUrl/status');
    final response = await http.get(
      Uri.parse('$baseUrl/status'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to get match status');
    }
  }
  
  /// End an active match
  Future<Map<String, dynamic>> endMatch({
    required String matchId,
    String reason = 'finished',
  }) async {
    await initialize();
    
    final response = await http.post(
      Uri.parse('$baseUrl/end/$matchId'),
      headers: _headers,
      body: jsonEncode({
        'reason': reason,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Match not found');
    } else if (response.statusCode == 403) {
      throw Exception('Not authorized to end this match');
    } else {
      throw Exception('Failed to end match');
    }
  }
  
  /// Report a user
  Future<Map<String, dynamic>> reportUser({
    required String matchId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    await initialize();
    
    final response = await http.post(
      Uri.parse('$baseUrl/report'),
      headers: _headers,
      body: jsonEncode({
        'match_id': matchId,
        'reported_user_id': reportedUserId,
        'reason': reason,
        'description': description,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to report user');
    }
  }
  
  /// Get user's match statistics
  Future<Map<String, dynamic>> getUserStats() async {
    await initialize();
    
    final response = await http.get(
      Uri.parse('$baseUrl/stats'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get statistics');
    }
  }
}

/// Singleton instance
final matchingApiService = MatchingApiService();
