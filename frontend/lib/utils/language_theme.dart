import 'package:flutter/material.dart';

class LanguageTheme {
  final String code;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String flag;
  final String name;

  const LanguageTheme._({
    required this.code,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.flag,
    required this.name,
  });

  static const LanguageTheme german = LanguageTheme._(
    code: 'de',
    primaryColor: Color(0xFF4CAF50), // Green for Germany
    secondaryColor: Color(0xFF1B5E20),
    accentColor: Color(0xFF81C784),
    flag: '🇩🇪',
    name: 'German',
  );

  static const LanguageTheme french = LanguageTheme._(
    code: 'fr',
    primaryColor: Color(0xFF2196F3), // Blue for France
    secondaryColor: Color(0xFF0D47A1),
    accentColor: Color(0xFF64B5F6),
    flag: '🇫🇷',
    name: 'French',
  );

  static const LanguageTheme spanish = LanguageTheme._(
    code: 'es',
    primaryColor: Color(0xFFF44336), // Red for Spain
    secondaryColor: Color(0xFFB71C1C),
    accentColor: Color(0xFFE57373),
    flag: '🇪🇸',
    name: 'Spanish',
  );

  static const LanguageTheme english = LanguageTheme._(
    code: 'en',
    primaryColor: Color(0xFF6C63FF), // Purple default
    secondaryColor: Color(0xFF4527A0),
    accentColor: Color(0xFF9575CD),
    flag: '🇬🇧',
    name: 'English',
  );

  static LanguageTheme getTheme(String code) {
    switch (code) {
      case 'fr': return french;
      case 'es': return spanish;
      case 'de': return german;
      default: return english;
    }
  }
}
