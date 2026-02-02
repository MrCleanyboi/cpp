import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class GamificationService {
  // Base URL - platform aware
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }
  
  // Get user gamification profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/gamification/profile?user_id=$userId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('Error getting profile: $e');
      rethrow;
    }
  }
  
  // Complete a lesson
  Future<Map<String, dynamic>> completeLesson({
    required String userId,
    required bool perfect,
    required int timeSpentMinutes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/gamification/lesson/complete');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'perfect': perfect,
          'time_spent_minutes': timeSpentMinutes,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to complete lesson');
      }
    } catch (e) {
      print('Error completing lesson: $e');
      rethrow;
    }
  }
  
  // Lose a heart
  Future<Map<String, dynamic>> loseHeart(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/gamification/hearts/lose');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to lose heart');
      }
    } catch (e) {
      print('Error losing heart: $e');
      rethrow;
    }
  }
  
  // Refill hearts
  Future<Map<String, dynamic>> refillHearts({
    required String userId,
    required bool useGems,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/gamification/hearts/refill');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'use_gems': useGems,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to refill hearts');
      }
    } catch (e) {
      print('Error refilling hearts: $e');
      rethrow;
    }
  }
  
  // Get achievements
  Future<Map<String, dynamic>> getAchievements(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/gamification/achievements?user_id=$userId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load achievements');
      }
    } catch (e) {
      print('Error getting achievements: $e');
      rethrow;
    }
  }
  
  // Get leaderboard
  Future<Map<String, dynamic>> getLeaderboard({
    required String type, // weekly, monthly, all_time
    String? userId,
    int limit = 50,
  }) async {
    try {
      String url = '$baseUrl/gamification/leaderboard?leaderboard_type=$type&limit=$limit';
      if (userId != null) {
        url += '&user_id=$userId';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      print('Error getting leaderboard: $e');
      rethrow;
    }
  }
  
  // Award XP (for when AI chat gives XP, etc.)
  Future<Map<String, dynamic>> awardXP({
    required String userId,
    required int xpAmount,
    String reason = '',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/gamification/xp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'xp_amount': xpAmount,
          'reason': reason,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to award XP');
      }
    } catch (e) {
      print('Error awarding XP: $e');
      rethrow;
    }
  }
  
  // Update streak
  Future<Map<String, dynamic>> updateStreak(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/gamification/streak/update?user_id=$userId');
      final response = await http.post(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update streak');
      }
    } catch (e) {
      print('Error updating streak: $e');
      rethrow;
    }
  }
}
