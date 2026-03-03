import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Pre-computed fonts to avoid disk I/O in build methods
  
  // Headers
  static final h1 = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static final h2 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static final h3 = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Body
  static final bodyLarge = GoogleFonts.outfit(
    fontSize: 18,
    color: Colors.white,
  );
  
  static final bodyMedium = GoogleFonts.outfit(
    fontSize: 16,
    color: Colors.white,
  );
  
  static final bodySmall = GoogleFonts.outfit(
    fontSize: 14,
    color: Colors.white70,
  );

  // Specialized colors/weights for specific contexts
  static final primaryButton = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final muted = GoogleFonts.outfit(
    fontSize: 14,
    color: Colors.white38,
  );

  static final accent = GoogleFonts.outfit(
    fontSize: 16,
    color: const Color(0xFF6C63FF),
    fontWeight: FontWeight.bold,
  );
  
  static final achievementHeader = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.amber,
    letterSpacing: 2,
  );
  
  static final label = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: Colors.white70,
  );

  // Custom helper to quickly get a style with modifications
  static TextStyle outfit({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }
}
