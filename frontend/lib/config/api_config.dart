import 'package:flutter/foundation.dart';

class ApiConfig {
  /// The backend host. 10.0.2.2 is the special alias for your 
  /// host machine's localhost from the Android emulator.
  static String get host {
    if (kIsWeb) {
      // Browsers often treat 'localhost' differently than '127.0.0.1' regarding CORS
      return 'localhost:8000'; 
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
