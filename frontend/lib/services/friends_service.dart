import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'api_service.dart';

class FriendsService extends ChangeNotifier {
  static final FriendsService _instance = FriendsService._internal();
  factory FriendsService() => _instance;
  FriendsService._internal();

  WebSocketChannel? _channel;
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String get _wsUrl {
    final base = ApiService.baseUrl.replaceFirst('http', 'ws');
    return '$base/ws';
  }

  // Connect to personal notification WebSocket
  Future<void> connect() async {
    if (_isConnected) return;

    final userId = await AuthService().getUserId();
    if (userId == null) return;

    try {
      final url = '$_wsUrl/$userId';
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _isConnected = true;
      notifyListeners();

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _eventController.add(data);
          } catch (e) {
            debugPrint('Error decoding WS message: $e');
          }
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
          debugPrint('Friends WS disconnected');
          // Optional: Reconnect logic
        },
        onError: (error) {
          _isConnected = false;
          notifyListeners();
          debugPrint('Friends WS error: $error');
        },
      );
    } catch (e) {
      debugPrint('Connection error: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  // --- API Methods ---

  Future<Map<String, dynamic>> sendFriendRequest(String targetUserId) async {
    try {
      final headers = await AuthService.getHeaders();
      final url = '${AuthService.baseUrl}/friends/request/$targetUserId';
      print('DEBUG: POST $url');
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
      );
      print('DEBUG: Response code: ${res.statusCode}, body: ${res.body}');
      return jsonDecode(res.body);
    } catch (e) {
      print('DEBUG: Exception in sendFriendRequest: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> acceptFriendRequest(String fromUserId) async {
    try {
      final headers = await AuthService.getHeaders();
      final res = await http.post(
        Uri.parse('${AuthService.baseUrl}/friends/accept/$fromUserId'),
        headers: headers,
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<List<dynamic>> getFriends() async {
    try {
      final headers = await AuthService.getHeaders();
      final res = await http.get(
        Uri.parse('${AuthService.baseUrl}/friends/'),
        headers: headers,
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getPendingRequests() async {
    try {
      final headers = await AuthService.getHeaders();
      final res = await http.get(
        Uri.parse('${AuthService.baseUrl}/friends/requests'),
        headers: headers,
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> callFriend(String friendId) async {
    try {
      final headers = await AuthService.getHeaders();
      final res = await http.post(
        Uri.parse('${AuthService.baseUrl}/friends/call/$friendId'),
        headers: headers,
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
