import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

/// Hard cap on every outbound request so a slow/unreachable backend
/// can never freeze the UI thread indefinitely.
const _kTimeout = Duration(seconds: 8);

class AuthService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api';

  // ── SharedPreferences cache ─────────────────────────────────────────────────
  // Loading SharedPreferences.getInstance() from disk is slow.
  // We cache the instance after the first call so subsequent reads are instant.
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  // ── Auth ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String nativeLanguage,
    required String targetLanguage,
    String proficiencyLevel = 'Beginner',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'email': email,
              'password': password,
              'native_language': nativeLanguage,
              'target_language': targetLanguage,
              'proficiency_level': proficiencyLevel,
            }),
          )
          .timeout(_kTimeout);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        await _saveAuthData(data['access_token'], data['user_id'], data['username']);
        return {'success': true, 'data': data};
      }
      final error = json.decode(res.body);
      return {'success': false, 'error': error['detail'] ?? 'Signup failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username_or_email': usernameOrEmail,
              'password': password,
            }),
          )
          .timeout(_kTimeout);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        await _saveAuthData(data['access_token'], data['user_id'], data['username']);
        return {'success': true, 'data': data};
      }
      final error = json.decode(res.body);
      return {'success': false, 'error': error['detail'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'error': 'Not authenticated'};

      final res = await http
          .patch(
            Uri.parse('$baseUrl/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(data),
          )
          .timeout(_kTimeout);

      return res.statusCode == 200
          ? {'success': true}
          : {'success': false, 'error': 'Failed to update profile'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final res = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_kTimeout);

      if (res.statusCode == 200) return UserModel.fromJson(json.decode(res.body));
      return null;
    } catch (e) {
      print('AuthService.getCurrentUser: $e');
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/auth/verify-token'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_kTimeout);

      if (res.statusCode == 200) {
        return json.decode(res.body)['valid'] == true;
      }
    } catch (e) {
      print('AuthService.isAuthenticated: $e');
    }
    return false;
  }

  // ── Storage helpers (all backed by the cached SharedPreferences) ────────────

  static Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString(_userIdKey);
  }

  Future<String?> getUsername() async {
    final prefs = await _getPrefs();
    return prefs.getString(_usernameKey);
  }

  Future<void> logout() async {
    final prefs = await _getPrefs();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }

  Future<void> _saveAuthData(
      String token, String userId, String username) async {
    final prefs = await _getPrefs();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
  }

  // ── Static convenience methods used by screens ─────────────────────────────

  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final res = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_kTimeout);

      if (res.statusCode == 200) return json.decode(res.body);
      return null;
    } catch (e) {
      print('AuthService.getUser: $e');
      return null;
    }
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
