import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'service_reset_registry.dart';

/// Hard cap on every outbound request so a slow backend can never freeze the UI.
const _kTimeout = Duration(seconds: 8);

/// API Service for Communications Module
///
/// Handles all REST API calls for partner matching.
class MatchingApiService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/match';

  MatchingApiService() {
    registerServiceReset(invalidateToken);
  }

  // ── Token cache ─────────────────────────────────────────────────────────────
  // We cache the token once per app session.  Re-read only on logout / re-login.
  String? _token;
  bool _initialized = false;

  /// Reads the auth token from SharedPreferences the FIRST time only, then
  /// caches it in memory.  This avoids repeated disk I/O on every poll.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _initialized = true;
  }

  /// Call this when the user logs out or the token changes.
  void invalidateToken() {
    _initialized = false;
    _token = null;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── API methods ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> joinQueue({
    required String targetLanguage,
    required String proficiencyLevel,
    String practiceMode = 'conversation',
    List<String> topics = const [],
  }) async {
    await _ensureInitialized();
    final response = await http
        .post(
          Uri.parse('$baseUrl/join-queue'),
          headers: _headers,
          body: jsonEncode({
            'target_language': targetLanguage,
            'proficiency_level': proficiencyLevel,
            'practice_mode': practiceMode,
            'topics': topics,
          }),
        )
        .timeout(_kTimeout);

    if (response.statusCode == 200) return jsonDecode(response.body);
    if (response.statusCode == 401) {
      throw Exception('Authentication required. Please login again.');
    }
    if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to join queue');
    }
    throw Exception('Failed to join queue: ${response.statusCode}');
  }

  Future<bool> leaveQueue() async {
    await _ensureInitialized();
    final response = await http
        .post(Uri.parse('$baseUrl/leave-queue'), headers: _headers)
        .timeout(_kTimeout);

    if (response.statusCode == 200) return true;
    if (response.statusCode == 404) return false; // not in queue — OK
    throw Exception('Failed to leave queue');
  }

  Future<Map<String, dynamic>> getMatchStatus() async {
    await _ensureInitialized();
    final response = await http
        .get(Uri.parse('$baseUrl/status'), headers: _headers)
        .timeout(_kTimeout);

    if (response.statusCode == 200) return jsonDecode(response.body);
    if (response.statusCode == 401) throw Exception('Authentication required');
    throw Exception('Failed to get match status');
  }

  Future<Map<String, dynamic>> endMatch({
    required String matchId,
    String reason = 'finished',
  }) async {
    await _ensureInitialized();
    final response = await http
        .post(
          Uri.parse('$baseUrl/end/$matchId'),
          headers: _headers,
          body: jsonEncode({'reason': reason}),
        )
        .timeout(_kTimeout);

    if (response.statusCode == 200) return jsonDecode(response.body);
    if (response.statusCode == 404) throw Exception('Match not found');
    if (response.statusCode == 403) {
      throw Exception('Not authorized to end this match');
    }
    throw Exception('Failed to end match');
  }

  Future<Map<String, dynamic>> reportUser({
    required String matchId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    await _ensureInitialized();
    final response = await http
        .post(
          Uri.parse('$baseUrl/report'),
          headers: _headers,
          body: jsonEncode({
            'match_id': matchId,
            'reported_user_id': reportedUserId,
            'reason': reason,
            'description': description,
          }),
        )
        .timeout(_kTimeout);

    if (response.statusCode == 200) return jsonDecode(response.body);
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'Failed to report user');
  }

  Future<Map<String, dynamic>> getUserStats() async {
    await _ensureInitialized();
    final response = await http
        .get(Uri.parse('$baseUrl/stats'), headers: _headers)
        .timeout(_kTimeout);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get statistics');
  }
}

/// Singleton instance
final matchingApiService = MatchingApiService();
