import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'learning_path/learning_path_screen.dart';
import 'partner_matching_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import '../services/auth_service.dart';
import '../services/gamification_service.dart';
import '../widgets/language_flag_button.dart';
import '../widgets/language_selector_sheet.dart';
import '../services/friends_service.dart';
import '../widgets/incoming_call_overlay.dart';
import 'partner_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _gamificationService = GamificationService();
  String? _userId;
  String _targetLanguage = 'en';
  int _gems = 0;
  int _hearts = 5;
  final FriendsService _friendsService = FriendsService();
  StreamSubscription? _friendsSubscription;
  List<Widget>? _cachedScreens;
  String? _cachedLanguage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initFriendsListener();
  }

  void _initFriendsListener() {
    _friendsSubscription = _friendsService.events.listen((event) {
      if (!mounted) return;

      if (event['type'] == 'incoming_call') {
        _showIncomingCall(event);
      } else if (event['type'] == 'friend_request') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New friend request from ${event['from_display_name']}!'),
            backgroundColor: Colors.amber,
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.black,
              onPressed: () => setState(() => _currentIndex = 3), // Profile
            ),
          ),
        );
      }
    });
  }

  void _showIncomingCall(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: IncomingCallOverlay(
          callerName: data['from_display_name'],
          callerId: data['from_user_id'],
          matchId: data['match_id'],
          onAccept: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PartnerChatScreen(
                  matchId: data['match_id'],
                  partner: {
                    'user_id': data['from_user_id'],
                    'display_name': data['from_display_name'],
                  },
                  targetLanguage: _targetLanguage,
                ),
              ),
            );
          },
          onDecline: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _friendsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userId = await _authService.getUserId();
    final user = await AuthService.getUser();

    if (mounted) {
      setState(() {
        _userId = userId;
        _targetLanguage = user?['target_language'] ?? 'en';
        // Invalidate cached screens since userId/language may have changed
        _cachedScreens = null;
        _cachedLanguage = null;
      });
    }

    if (userId != null) {
      await _loadGamificationStats(userId);
    }
  }

  Future<void> _loadGamificationStats(String userId) async {
    try {
      final profile = await _gamificationService.getUserProfile(userId);
      if (mounted) {
        setState(() {
          _gems = (profile['gems'] as num?)?.toInt() ?? 0;
          _hearts = (profile['hearts'] as num?)?.toInt() ?? 5;
        });
      }
    } catch (e) {
      print('DEBUG: Failed to load gamification stats: $e');
    }
  }

  Future<void> refreshLanguage() async {
    final user = await AuthService.getUser();
    if (mounted && user != null) {
      setState(() {
        _targetLanguage = user['target_language'] ?? 'en';
      });
    }
  }

  void _showLanguageSelector() {
    showLanguageSelector(
      context,
      _targetLanguage,
      (newLanguage) {
        refreshLanguage();
      },
    );
  }

  List<Widget> _getScreens() {
    if (_cachedScreens != null &&
        _cachedLanguage == _targetLanguage &&
        _cachedScreens!.length == 4) {
      return _cachedScreens!;
    }
    _cachedLanguage = _targetLanguage;
    _cachedScreens = [
      LearningPathScreen(
        key: ValueKey(_targetLanguage),
        targetLanguage: _targetLanguage,
      ),
      ChatScreen(topic: _targetLanguage == 'de' ? 'German Basics' : 'General Practice'),
      const PartnerMatchingScreen(),
      ProfileScreen(userId: _userId ?? ''),
    ];
    return _cachedScreens!;
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: HomeScreen build. Current Tab: $_currentIndex');
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('Lexico'),
              centerTitle: false,
              actions: [
                // Language switcher
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: LanguageFlagButton(
                    languageCode: _targetLanguage,
                    onTap: _showLanguageSelector,
                  ),
                ),
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
                // Hearts display (live from API)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E212B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$_hearts',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Gems display (live from API)
                GestureDetector(
                  onTap: () {
                    if (_userId != null) _loadGamificationStats(_userId!);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E212B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          '$_gems',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _getScreens(),
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
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
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
