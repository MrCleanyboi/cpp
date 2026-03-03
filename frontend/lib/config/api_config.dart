import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  // SET THIS TO YOUR NGROK URL FOR REMOTE TESTING
  // Example: 'lexico-123.ngrok-free.app'
  static const String _ngrokHost = ''; // SET THIS TO YOUR NGROK URL FOR REMOTE TESTING

  static String get host {
    if (_ngrokHost.isNotEmpty) {
      return _ngrokHost;
    }
    
    // Default local behavior
    if (kIsWeb) {
      return '127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      return '10.0.2.2:8000';
    } else {
      return '127.0.0.1:8000';
    }
  }

  static String get baseUrl {
    final protocol = _ngrokHost.isNotEmpty ? 'https' : 'http';
    return '$protocol://$host';
  }

  static String get wsUrl {
    final protocol = _ngrokHost.isNotEmpty ? 'wss' : 'ws';
    return '$protocol://$host';
  }
}
