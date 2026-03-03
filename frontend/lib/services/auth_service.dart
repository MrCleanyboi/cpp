import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class AuthService {
  // Base URL - platform aware
  static String get baseUrl => '${ApiConfig.baseUrl}/api';

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  // Sign up a new user
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String nativeLanguage,
    required String targetLanguage,
    String proficiencyLevel = 'Beginner',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/signup');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'native_language': nativeLanguage,
          'target_language': targetLanguage,
          'proficiency_level': proficiencyLevel,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Save token and user info
        await _saveAuthData(
          data['access_token'],
          data['user_id'],
          data['username'],
        );
        
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Login with username/email and password
  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username_or_email': usernameOrEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Save token and user info
        await _saveAuthData(
          data['access_token'],
          data['user_id'],
          data['username'],
        );
        
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final url = Uri.parse('$baseUrl/auth/me');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'error': 'Failed to update profile'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }


  // Get current authenticated user
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final url = Uri.parse('$baseUrl/auth/me');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    // Verify token with backend
    try {
      final url = Uri.parse('$baseUrl/auth/verify-token');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['valid'] == true;
      }
    } catch (e) {
      print('Error verifying token: $e');
    }
    
    return false;
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get stored username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Logout - clear all stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }

  // Private: Save authentication data
  Future<void> _saveAuthData(String token, String userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
  }

  // Get current user data as Map (for non-model usage)
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final url = Uri.parse('$baseUrl/auth/me');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Get authorization headers
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
