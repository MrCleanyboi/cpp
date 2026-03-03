import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/friends_service.dart';

// ─── Pre-compute theme ONCE at module level, not inside build() ───────────────
// GoogleFonts.outfitTextTheme() loads font assets from disk. Putting it inside
// build() caused "Skipped 554 frames" because it ran on every single rebuild.
final _outfitTextTheme = GoogleFonts.outfitTextTheme().copyWith(
  bodyLarge: GoogleFonts.outfit(color: Colors.white),
  bodyMedium: GoogleFonts.outfit(color: Colors.white),
  bodySmall: GoogleFonts.outfit(color: Colors.white),
  titleLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
  titleMedium: GoogleFonts.outfit(color: Colors.white),
  titleSmall: GoogleFonts.outfit(color: Colors.white),
  headlineLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
  headlineMedium: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
  displayLarge: GoogleFonts.outfit(color: Colors.white),
  displayMedium: GoogleFonts.outfit(color: Colors.white),
  labelLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
);

// Shared singleton FriendsService instance — avoid creating new ones
final _friendsServiceSingleton = FriendsService();

final _splashTitleStyle = GoogleFonts.outfit(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  letterSpacing: 1.2,
);

final _splashSubStyle = GoogleFonts.outfit(
  fontSize: 14,
  color: Colors.white38,
  letterSpacing: 2,
);

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
    };

    runApp(const AiTutorApp());
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
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
        // Use pre-computed theme — no per-build font loading
        textTheme: _outfitTextTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0F1117),
          elevation: 0,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
      // Brief delay for splash effect — keeps first frame snappy
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // Verify token with a hard timeout so we never hang indefinitely
      final isAuth = await _authService.isAuthenticated().timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          debugPrint('DEBUG: Auth check timed out, treating as unauthenticated');
          return false;
        },
      );

      if (!mounted) return;

      if (isAuth) {
        // Connect the shared FriendsService singleton (non-blocking)
        _friendsServiceSingleton.connect();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionDuration: const Duration(milliseconds: 400),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const WelcomeScreen(),
              transitionDuration: const Duration(milliseconds: 400),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        }
      }
    } catch (e, s) {
      debugPrint('DEBUG: Error in _checkAuth: $e\n$s');
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
              width: 100,
              height: 100,
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
              child: const Icon(
                Icons.language_rounded,
                size: 56,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Lexico',
              style: _splashTitleStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Language Learning',
              style: _splashSubStyle,
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF6C63FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
