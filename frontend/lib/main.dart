import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    print('DEBUG: main() started, WidgetsFlutterBinding initialized');
    
    // Add crash handling if needed
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      print('DEBUG: Flutter Error: ${details.exception}');
      print('DEBUG: Stack Trace: ${details.stack}');
    };

    runApp(const AiTutorApp());
    print('DEBUG: runApp() called');
  }, (error, stack) {
    print('DEBUG: Uncaught error: $error');
    print('DEBUG: Stack trace: $stack');
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
        scaffoldBackgroundColor: const Color(0xFF0F1117), // Deep dark rich blue-black
        primaryColor: const Color(0xFF6C63FF), // Vibrant Purple
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E5FF), // Cyan accent
          surface: Color(0xFF1E212B), // Slightly lighter card bg
        ),
// ... (omitting middle lines for brevity if not strictly needed, but replace_file_content usually needs block)
// ... wait, I'll do two separate replacements or one large block if they are close.
// Title is line 34. Icon is line 187. They are far apart. I should use multi_replace or two calls.
// I will use replace_file_content for the TITLE first.
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
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
      // home: const HomeScreen(), // DEBUG: Direct launch to test rendering
      home: const AuthCheckScreen(),
    );
  }
}

// Splash screen that checks authentication status
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
    print('DEBUG: AuthCheckScreen initState');
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    print('DEBUG: Starting _checkAuth');
    try {
      // Wait a moment for splash effect
      await Future.delayed(const Duration(seconds: 1));
      print('DEBUG: Future.delayed completed');
      
      if (!mounted) {
        print('DEBUG: AuthCheckScreen not mounted');
        return;
      }

      print('DEBUG: Checking authenticaton...');
      // Check if user is authenticated with timeout
      final isAuth = await _authService.isAuthenticated().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
            print('DEBUG: Auth check timed out');
            return false;
        },
      );
      print('DEBUG: Auth check result: $isAuth');

      if (!mounted) return;

      if (isAuth) {
        print('DEBUG: Navigating to HomeScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        print('DEBUG: Navigating to WelcomeScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } catch (e, s) {
      print('DEBUG: Error in _checkAuth: $e');
      print('DEBUG: Stack: $s');
      // Navigate to welcome screen on error as fallback
       if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    print('DEBUG: AuthCheckScreen disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: AuthCheckScreen build');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.language_rounded,
                size: 56,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Initializing...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
