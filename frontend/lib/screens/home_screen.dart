import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'learning_path/learning_path_screen.dart';
import 'partner_matching_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
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
  final FriendsService _friendsService = FriendsService();
  StreamSubscription? _friendsSubscription;
  List<Widget?>? _cachedScreens;
  String? _cachedLanguage;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initFriendsListener();
    
    // Ensure the notification WebSocket is connected (handles new login/signup)
    _friendsService.connect();
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
              onPressed: () => setState(() => _currentIndex = 4), // Profile
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
    // 1. Read cached userId — instant from memory cache.
    final userId = await _authService.getUserId();
    if (userId == null) {
      // Not logged in — nothing to load.
      if (mounted) setState(() => _userId = '');
      return;
    }

    // Set userId immediately so the UI renders without waiting for HTTP.
    if (mounted) setState(() => _userId = userId);

    // 2. Fire both HTTP calls IN PARALLEL — saves ~300-500ms vs sequential.
    final results = await Future.wait([
      AuthService.getUser().catchError((_) => null),
      _gamificationService.getUserProfile(userId).catchError((_) => <String, dynamic>{}),
    ]);

    final user = results[0] as Map<String, dynamic>?;
    final profile = results[1] as Map<String, dynamic>;

    if (mounted) {
      setState(() {
        _targetLanguage = user?['target_language'] ?? _targetLanguage;
        _gems = (profile['gems'] as num?)?.toInt() ?? _gems;
        
        // IMPORTANT: Invalidate cache if language OR userId changed
        if (_cachedLanguage != _targetLanguage || _lastUserId != _userId) {
          _cachedScreens = null;
          _cachedLanguage = _targetLanguage;
          _lastUserId = _userId;
        }
      });
    }
  }

  Future<void> _loadGamificationStats(String userId) async {
    try {
      final profile = await _gamificationService.getUserProfile(userId);
      if (mounted) {
        setState(() {
          _gems = (profile['gems'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {
      print('DEBUG: Failed to load gamification stats: $e');
    }
  }


  Future<void> refreshLanguage([String? newLanguage]) async {
    if (newLanguage != null) {
      if (mounted) {
        setState(() {
          if (_targetLanguage != newLanguage) {
            _targetLanguage = newLanguage;
            _cachedScreens = null; // Forced reload
            _cachedLanguage = newLanguage;
          }
        });
      }
      return;
    }

    final user = await AuthService.getUser();
    if (mounted && user != null) {
      setState(() {
        final backendLanguage = user['target_language'] ?? 'en';
        if (_targetLanguage != backendLanguage) {
          _targetLanguage = backendLanguage;
          _cachedScreens = null; // Forced reload
          _cachedLanguage = backendLanguage;
        }
      });
    }
  }

  void _showLanguageSelector() {
    showLanguageSelector(
      context,
      _targetLanguage,
      (newLanguage) {
        refreshLanguage(newLanguage);
      },
    );
  }

  List<Widget> _getScreens() {
    // 1. Initialize the fixed-size list if null or invalidated
    if (_cachedScreens == null || _cachedScreens!.length != 5) {
      _cachedScreens = List<Widget?>.filled(5, null);
      _cachedLanguage = _targetLanguage;
      _lastUserId = _userId;
    }

    // 2. Lazy-instantiate ONLY the current screen if it doesn't exist
    if (_cachedScreens![_currentIndex] == null) {
      switch (_currentIndex) {
        case 0:
          _cachedScreens![0] = LearningPathScreen(
            key: ValueKey('lp_$_targetLanguage'),
            targetLanguage: _targetLanguage,
          );
          break;
        case 1:
          _cachedScreens![1] = ChatScreen(
            key: ValueKey('chat_$_targetLanguage'),
            topic: _targetLanguage == 'de' ? 'German Basics' : 'General Practice',
          );
          break;
        case 2:
          _cachedScreens![2] = const PartnerMatchingScreen();
          break;
        case 3:
          _cachedScreens![3] = const ProgressScreen();
          break;
        case 4:
          _cachedScreens![4] = ProfileScreen(
            key: ValueKey('profile_$_userId'),
            userId: _userId ?? '',
          );
          break;
      }
    }

    // 3. Return the list — replace nulls with placeholders so IndexedStack
    // doesn't crash (the current index is always filled above).
    return _cachedScreens!.map((w) => w ?? const SizedBox.shrink()).toList();
  }

  @override
  Widget build(BuildContext context) {

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
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Progress',
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
