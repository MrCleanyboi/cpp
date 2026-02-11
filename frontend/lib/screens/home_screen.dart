import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'learning_path/learning_path_screen.dart';
import 'partner_matching_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  String? _userId;
  String _targetLanguage = 'en'; // Default to English

  @override
  void initState() {
    super.initState();
    print('DEBUG: HomeScreen initState');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('DEBUG: HomeScreen loading user data...');
    final userId = await _authService.getUserId();
    final user = await AuthService.getUser();
    
    print('DEBUG: HomeScreen loaded userId: $userId');
    print('DEBUG: HomeScreen loaded user: $user');
    
    if (mounted) {
        setState(() {
            _userId = userId;
            _targetLanguage = user?['target_language'] ?? 'en';
        });
        print('DEBUG: HomeScreen set target language: $_targetLanguage');
    }
  }

  // Method to refresh language (call this after language selection)
  Future<void> refreshLanguage() async {
    final user = await AuthService.getUser();
    if (mounted && user != null) {
      setState(() {
        _targetLanguage = user['target_language'] ?? 'en';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /*
    print('DEBUG: HomeScreen RAW BUILD');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.red,
        child: const Center(
          child: Text('IF YOU SEE THIS, RENDERING WORKS', style: TextStyle(color: Colors.white, fontSize: 30)),
        ),
      ),
    );
    */
    
    print('DEBUG: HomeScreen build. _userId: $_userId, targetLanguage: $_targetLanguage');
    if (_userId == null) {
      print('DEBUG: HomeScreen showing loading indicator');
      return const Scaffold(
        backgroundColor: Colors.red, // TEMPORARY DEBUG COLOR to verify visibility
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final List<Widget> screens = [
      LearningPathScreen(
        key: ValueKey(_targetLanguage), // Rebuild when language changes
        targetLanguage: _targetLanguage,
      ),
      const ChatScreen(),
      const PartnerMatchingScreen(),
      ProfileScreen(userId: _userId!),
    ];
    return Scaffold(
      backgroundColor: Colors.blue, // TEMPORARY DEBUG COLOR
      appBar: _currentIndex == 0 ? AppBar(
        title: const Text('AI Language Tutor'),
        actions: [
          // Leaderboard button
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(userId: _userId!),
                ),
              );
            },
          ),
          // TODO: Load hearts and gems dynamically from gamification service
          // Hearts display
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E212B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.favorite, color: Colors.red, size: 18),
                SizedBox(width: 4),
                Text('5', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Gems display
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E212B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Text('💎', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ) : null,

      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
          color: const Color(0xFF0F1117),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF0F1117),
          selectedItemColor: const Color(0xFF6C63FF),
          unselectedItemColor: Colors.white24,
          selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.outfit(),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy_rounded),
              label: 'AI Tutor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Connect',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
