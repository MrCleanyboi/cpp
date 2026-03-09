import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/friends_service.dart';

// ─── Pre-compute theme ───────────────────────────────────────────────────────
// Loading GoogleFonts inside build() causes "Skipped frames" on every rebuild.
final _outfitTextTheme = GoogleFonts.outfitTextTheme().copyWith(
  bodyLarge: GoogleFonts.outfit(color: Colors.white),
  bodyMedium: GoogleFonts.outfit(color: Colors.white),
  bodySmall: GoogleFonts.outfit(color: Colors.white),
  titleLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
  titleMedium: GoogleFonts.outfit(color: Colors.white),
  titleSmall: GoogleFonts.outfit(color: Colors.white),
  headlineLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
  labelLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() {
    runApp(const AiTutorApp());
  }, (error, stack) {
    debugPrint('CRITICAL: [Uncaught Error] $error\n$stack');
  });
}

class AiTutorApp extends StatelessWidget {
  const AiTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF1E212B),
        ),
        textTheme: _outfitTextTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1117),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            textStyle: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E212B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

// ─── Auth Check Screen ────────────────────────────────────────────────────────
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Small delay for branding logic
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // Verify token with a hard timeout
      final isAuth = await _authService.isAuthenticated().timeout(
        const Duration(seconds: 7),
        onTimeout: () => false,
      ).catchError((_) => false);

      if (!mounted) return;

      if (isAuth) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, // Restored to 120
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.language_rounded, size: 64, color: Color(0xFF6C63FF)), // Restored to 64
            ),
            const SizedBox(height: 32),
            Text(
              'Lexico',
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Language Learning',
              style: GoogleFonts.outfit(
                color: Colors.white38,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Color(0xFF6C63FF)),
          ],
        ),
      ),
    );
  }
}
