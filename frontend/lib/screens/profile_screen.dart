import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/gamification_service.dart';
import 'welcome_screen.dart';
import '../services/friends_service.dart';
import 'partner_chat_screen.dart';
import 'shop_screen.dart';

// ─── Styles ──────────────────────────────────────────────────────────────────
final _avatarInitialStyle = GoogleFonts.outfit(
  fontSize: 48,
  fontWeight: FontWeight.bold,
);

final _nameTextStyle = GoogleFonts.outfit(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _usernameTextStyle = GoogleFonts.outfit(
  fontSize: 16,
  color: Colors.white70,
);

final _levelTitleStyle = GoogleFonts.outfit(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

final _xpTextStyle = GoogleFonts.outfit(
  fontSize: 16,
  color: Colors.white70,
);

final _nextLevelStyle = GoogleFonts.outfit(
  fontSize: 14,
  color: Colors.white54,
);

final _dailyGoalTitleStyle = GoogleFonts.outfit(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

final _completedBadgeStyle = GoogleFonts.outfit(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: Colors.greenAccent,
);

final _dailyXpStyle = GoogleFonts.outfit(
  fontSize: 14,
  color: Colors.white70,
);

final _sectionHeaderStyle = GoogleFonts.outfit(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

final _pendingHeaderStyle = GoogleFonts.outfit(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.amberAccent,
);

final _friendNameStyle = GoogleFonts.outfit(fontWeight: FontWeight.bold);

final _noFriendsStyle = GoogleFonts.outfit(color: Colors.white30);

final _statValueStyle = GoogleFonts.outfit(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

final _statLabelStyle = GoogleFonts.outfit(
  fontSize: 12,
  color: Colors.white54,
);

class ProfileScreen extends StatefulWidget {
  final String userId;
  
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final GamificationService _gamificationService = GamificationService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String _username = 'User';
  List<dynamic> _friends = [];
  List<dynamic> _pendingRequests = [];
  final FriendsService _friendsService = FriendsService();
  Timer? _refreshTimer;

  String? _currentUserId;
  bool get _isOwnProfile => widget.userId == _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Get currently logged in user ID to check ownership
    _currentUserId = await _authService.getUserId();
    
    // Load username and profile data
    await _loadUsername();
    await _loadProfile();
    
    // Only start polling and load friends/requests if it's our own profile
    if (_isOwnProfile) {
      await _loadFriendsData();
      _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) _loadFriendsData();
      });
    }
  }

  Future<void> _loadFriendsData() async {
    final friends = await _friendsService.getFriends();
    final requests = await _friendsService.getPendingRequests();
    if (mounted) {
      setState(() {
        _friends = friends;
        _pendingRequests = requests;
      });
    }
  }

  void _navigateToProfile(String userId) {
    if (userId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: userId),
      ),
    );
  }

  Future<void> _acceptRequest(String userId) async {
    final res = await _friendsService.acceptFriendRequest(userId);
    if (res['status'] == 'accepted') {
      await _loadFriendsData();
    }
  }

  Future<void> _callFriend(Map<String, dynamic> friend) async {
     final res = await _friendsService.callFriend(friend['id']);
     if (res['status'] == 'calling') {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Calling...'), backgroundColor: Colors.purple),
         );
         
         // Navigate to chat screen immediately as the caller
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (_) => PartnerChatScreen(
               matchId: res['match_id'],
               partner: {
                 'user_id': friend['id'],
                 'display_name': friend['display_name'],
               },
               targetLanguage: 'en', // Default or get from current user
             ),
           ),
         );
       }
     } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Call failed: ${res['message'] ?? 'Unknown error'}'), backgroundColor: Colors.red),
         );
       }
     }
  }

  Future<void> _loadUsername() async {
    final username = await _authService.getUsername();
    if (username != null) {
      setState(() {
        _username = username;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _gamificationService.getUserProfile(widget.userId);
      if (mounted) {
        setState(() {
          _profileData = {
            'username': profile['username'] ?? _username,
            'display_name': profile['display_name'] ?? _username,
            'xp': (profile['xp'] as num?)?.toInt() ?? 0,
            'level': (profile['level'] as num?)?.toInt() ?? 1,
            'xp_to_next_level': (profile['xp_to_next_level'] as num?)?.toInt() ?? 50,
            'streak_count': (profile['streak_count'] as num?)?.toInt() ?? 0,
            'longest_streak': (profile['longest_streak'] as num?)?.toInt() ?? 0,
            'gems': (profile['gems'] as num?)?.toInt() ?? 0,
            'hearts': (profile['hearts'] as num?)?.toInt() ?? 5,
            'max_hearts': (profile['max_hearts'] as num?)?.toInt() ?? 5,
            'daily_goal_xp': (profile['daily_goal_xp'] as num?)?.toInt() ?? 20,
            'daily_xp_earned': (profile['daily_xp_earned'] as num?)?.toInt() ?? 0,
            'daily_goal_met': profile['daily_goal_met'] ?? false,
            'achievements_count': (profile['achievements_count'] as num?)?.toInt() ?? 0,
            'total_lessons_completed': (profile['total_lessons_completed'] as num?)?.toInt() ?? 0,
            'total_time_minutes': (profile['total_time_minutes'] as num?)?.toInt() ?? 0,
            'inventory': profile['inventory'] ?? [],
            'equipped_banner': profile['equipped_banner'],
            'equipped_effect': profile['equipped_effect'],
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _profileData = {
            'username': _username, 'display_name': _username,
            'xp': 0, 'level': 1, 'xp_to_next_level': 50,
            'streak_count': 0, 'longest_streak': 0,
            'gems': 0, 'hearts': 5, 'max_hearts': 5,
            'daily_goal_xp': 20, 'daily_xp_earned': 0,
            'daily_goal_met': false, 'achievements_count': 0,
            'total_lessons_completed': 0, 'total_time_minutes': 0,
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _profileData!;
    final xpProgress = (profile['xp'] as int) / ((profile['xp'] as int) + (profile['xp_to_next_level'] as int));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isOwnProfile ? 'Profile' : 'User Profile'),
        actions: [
          if (_isOwnProfile) ...[
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
            IconButton(
              icon: const Icon(Icons.storefront_rounded),
              tooltip: 'Shop',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ShopScreen(userId: widget.userId)),
              ).then((_) => _loadProfile()),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: profile['equipped_banner'] == 'banner_neon' 
                      ? [const Color(0xFF6C63FF), const Color(0xFFFF00CC)]
                      : profile['equipped_banner'] == 'banner_nature'
                          ? [const Color(0xFF2D5A27), const Color(0xFF4CB050)]
                          : [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: profile['equipped_effect'] == 'effect_golden'
                              ? Colors.amber.withOpacity(0.5)
                              : profile['equipped_effect'] == 'effect_fire'
                                  ? Colors.orange.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (profile['display_name'] as String)[0].toUpperCase(),
                        style: _avatarInitialStyle.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile['display_name'],
                    style: _nameTextStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${profile['username']}',
                    style: _usernameTextStyle,
                  ),
                ],
              ),
            ),
            
            // Level Progress
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level ${profile['level']}',
                        style: _levelTitleStyle,
                      ),
                      Text(
                        '${profile['xp']} XP',
                        style: _xpTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: xpProgress,
                      minHeight: 12,
                      backgroundColor: const Color(0xFF1E212B),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${profile['xp_to_next_level']} XP to Level ${profile['level'] + 1}',
                    style: _nextLevelStyle,
                  ),
                ],
              ),
            ),

            // Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1, // Made cards slightly taller
                children: [
                  _buildStatCard(
                    '🔥',
                    '${profile['streak_count']} Day',
                    'Current Streak',
                  ),
                  _buildStatCard(
                    '💎',
                    '${profile['gems']}',
                    'Total Gems',
                  ),
                  _buildStatCard(
                    '🏆',
                    '${profile['achievements_count']}',
                    'Achievements',
                  ),
                  _buildStatCard(
                    '📚',
                    '${profile['total_lessons_completed']}',
                    'Lessons Done',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Daily Goal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E212B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Goal',
                          style: _dailyGoalTitleStyle,
                        ),
                        if (profile['daily_goal_met'])
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'COMPLETED',
                              style: _completedBadgeStyle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (profile['daily_xp_earned'] as int) /
                            (profile['daily_goal_xp'] as int),
                        minHeight: 10,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${profile['daily_xp_earned']} / ${profile['daily_goal_xp']} XP',
                      style: _dailyXpStyle,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pending Requests Section
            if (_pendingRequests.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Requests',
                      style: _pendingHeaderStyle,
                    ),
                    const SizedBox(height: 12),
                    ..._pendingRequests.map((req) => _buildRequestTile(req)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Friends List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Friends',
                    style: _sectionHeaderStyle,
                  ),
                  const SizedBox(height: 12),
                  if (_friends.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E212B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No friends yet. Add partners you like!',
                          style: _noFriendsStyle,
                        ),
                      ),
                    )
                  else
                    ..._friends.map((friend) => _buildFriendTile(friend)),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestTile(Map<String, dynamic> req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF6C63FF),
            child: Text(req['from_display_name'][0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              req['from_display_name'],
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
            onPressed: () => _acceptRequest(req['from_user_id']),
          ),
          IconButton(
            icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
            onPressed: () {}, // TODO: Decline
          ),
        ],
      ),
    );
  }

  Widget _buildFriendTile(Map<String, dynamic> friend) {
    return InkWell(
      onTap: () => _navigateToProfile(friend['id']),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
              child: Text(friend['display_name'][0], style: const TextStyle(color: Color(0xFF6C63FF))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                friend['display_name'],
                style: _friendNameStyle,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _callFriend(friend),
              icon: const Icon(Icons.call_rounded, size: 16),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                foregroundColor: const Color(0xFF6C63FF),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: _statValueStyle,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: _statLabelStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
