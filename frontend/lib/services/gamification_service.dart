import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Hard cap on every outbound request so a slow/unreachable backend
/// can never freeze the UI thread indefinitely.
const _kTimeout = Duration(seconds: 8);

class GamificationService {
  String get baseUrl => '${ApiConfig.baseUrl}/api';

  // ── Helper ──────────────────────────────────────────────────────────────────

  /// GET with timeout.
  Future<http.Response> _get(Uri url) =>
      http.get(url).timeout(_kTimeout);

  /// POST with timeout.
  Future<http.Response> _post(Uri url, Object body) =>
      http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(_kTimeout);

  // ── API methods ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    if (userId.isEmpty) {
      throw Exception('userId cannot be empty for profile lookup');
    }
    try {
      final res = await _get(
        Uri.parse('$baseUrl/gamification/profile?user_id=$userId'),
      );
      if (res.statusCode == 200) {
        return json.decode(res.body)['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to load profile: ${res.statusCode}');
    } catch (e) {
      print('GamificationService.getUserProfile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> completeLesson({
    required String userId,
    String? lessonId,
    required bool perfect,
    required int timeSpentMinutes,
  }) async {
    try {
      final res = await _post(
        Uri.parse('$baseUrl/gamification/lesson/complete'),
        {
          'user_id': userId,
          if (lessonId != null) 'lesson_id': lessonId,
          'perfect': perfect,
          'time_spent_minutes': timeSpentMinutes,
        },
      );
      if (res.statusCode == 200) {
        return json.decode(res.body)['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to complete lesson: ${res.statusCode}');
    } catch (e) {
      print('GamificationService.completeLesson: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> getAchievements(String userId) async {
    try {
      final res = await _get(
        Uri.parse('$baseUrl/gamification/achievements?user_id=$userId'),
      );
      if (res.statusCode == 200) {
        return json.decode(res.body)['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to load achievements: ${res.statusCode}');
    } catch (e) {
      print('GamificationService.getAchievements: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLeaderboard({
    required String type,
    String? userId,
    int limit = 50,
  }) async {
    try {
      String url =
          '$baseUrl/gamification/leaderboard?leaderboard_type=$type&limit=$limit';
      if (userId != null) url += '&user_id=$userId';

      final res = await _get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body)['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to load leaderboard: ${res.statusCode}');
    } catch (e) {
      print('GamificationService.getLeaderboard: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> awardXP({
    required String userId,
    required int xpAmount,
    String reason = '',
  }) async {
    try {
      final res = await _post(
        Uri.parse('$baseUrl/gamification/xp'),
        {'user_id': userId, 'xp_amount': xpAmount, 'reason': reason},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body)['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to award XP: ${res.statusCode}');
    } catch (e) {
      print('GamificationService.awardXP: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateStreak(String userId) async {
    try {
      final res = await _post(
        Uri.parse('$baseUrl/gamification/streak/update?user_id=$userId'),
        {},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body)['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to update streak: ${res.statusCode}');
    } catch (e) {
      print('GamificationService.updateStreak: $e');
      rethrow;
    }
  }
}
