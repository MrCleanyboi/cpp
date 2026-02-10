import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// WebSocket Service for real-time chat
class ChatWebSocketService {
  WebSocketChannel? _channel;
  final String matchId;
  String? _token;
  
  // Callbacks for handling incoming messages
  Function(Map<String, dynamic>)? onMessage;
  Function(bool)? onTyping;
  Function()? onPartnerConnected;
  Function()? onPartnerDisconnected;
  Function(String)? onError;
  Function()? onConnected;
  Function(String reason)? onMatchEnded;
  Function(Map<String, dynamic>)? onSignal;
  
  ChatWebSocketService({required this.matchId});
  
  /// Connect to WebSocket
  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    
    if (_token == null) {
      onError?.call('No authentication token found');
      return;
    }
    
    // Dynamic host based on platform
    final host = kIsWeb ? '127.0.0.1:8000' : '10.0.2.2:8000';
    final url = 'ws://$host/ws/chat/$matchId?token=$_token';
    
    print('DEBUG: ChatWebSocketService connecting to: $url');
    print('DEBUG: Token being used: ${_token?.substring(0, 10)}...');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Listen to incoming messages
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _handleMessage(data);
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          onError?.call('Connection error: $error');
        },
        onDone: () {
          print('WebSocket closed');
          onPartnerDisconnected?.call();
        },
      );
    } catch (e) {
      onError?.call('Failed to connect: $e');
    }
  }
  
  /// Handle incoming messages
  void _handleMessage(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'connected':
        print('Connected! Partner: ${data['partner']['display_name']}');
        onConnected?.call();
        break;
      
      case 'message':
        // Incoming chat message
        onMessage?.call({
          'sender_id': data['sender_id'],
          'sender_name': data['sender_name'],
          'text': data['text'],
          'timestamp': data['timestamp'],
        });
        break;
      
      case 'typing':
        // Typing indicator
        final isTyping = data['is_typing'] ?? false;
        onTyping?.call(isTyping);
        break;
      
      case 'partner_connected':
        onPartnerConnected?.call();
        break;
      
      case 'partner_disconnected':
        onPartnerDisconnected?.call();
        break;
      
      case 'error':
        final message = data['message'] ?? 'Unknown error';
        onError?.call(message);
        break;
      
      case 'pong':
        // Keep-alive response
        break;
        
      case 'match_ended':
        final reason = data['reason'] ?? 'Match ended';
        onMatchEnded?.call(reason);
        break;
        
      case 'offer':
      case 'answer':
      case 'ice_candidate':
        // WebRTC Signaling messages
        onSignal?.call(data);
        break;
      
      default:
        print('Unknown message type: $type');
    }
  }
  
  /// Send a text message
  void sendMessage(String text) {
    if (_channel == null) {
      print('WebSocket not connected');
      return;
    }
    
    _channel!.sink.add(jsonEncode({
      'type': 'message',
      'text': text,
    }));
  }
  
  /// Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (_channel == null) return;
    
    _channel!.sink.add(jsonEncode({
      'type': 'typing',
      'is_typing': isTyping,
    }));
  }
  
  /// Send WebRTC signaling message
  void sendSignal(Map<String, dynamic> data) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode(data));
  }

  /// Send ping to keep connection alive
  void sendPing() {
    if (_channel == null) return;
    
    _channel!.sink.add(jsonEncode({
      'type': 'ping',
    }));
  }
  
  /// Disconnect from WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
  
  /// Check if connected
  bool get isConnected => _channel != null;
}
