import 'package:flutter/foundation.dart';

class ApiConfig {
  /// The backend host. 10.0.2.2 is the special alias for your 
  /// host machine's localhost from the Android emulator.
  static String get host {
    if (kIsWeb) {
      // 127.0.0.1 is often more reliable than 'localhost' for WebSockets in local dev
      return '127.0.0.1:8000'; 
    }
    
    // Use targetPlatform which is web-safe (Foundation library)
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2:8000';
    }
    
    // Default for iOS/Desktop/Web-locals
    return '127.0.0.1:8000';
  }

  static String get baseUrl => 'http://$host';
  static String get wsUrl => 'ws://$host';
}
