import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gamification_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final String userId;
  
  const LeaderboardScreen({super.key, required this.userId});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GamificationService _gamificationService = GamificationService();
  bool _isLoading = true;
  String _currentType = 'weekly';
  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _currentType = 'weekly';
            break;
          case 1:
            _currentType = 'monthly';
            break;
          case 2:
            _currentType = 'all_time';
            break;
        }
      });
      _loadLeaderboard();
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    
    try {
      // final data = await _gamificationService.getLeaderboard(
      //   type: _currentType,
      //   userId: widget.userId,
      // );
      
      // MOCK DATA FOR SCREENSHOT
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      
      // Define directly as the correct type to avoid casting errors
      final List<Map<String, dynamic>> mockRankings = [
          {'rank': 1, 'display_name': 'Sarah Smith', 'level': 12, 'xp': 2450},
          {'rank': 2, 'display_name': 'Mike Johnson', 'level': 11, 'xp': 2340},
          {'rank': 3, 'display_name': 'Emily Davis', 'level': 10, 'xp': 2100},
          {'rank': 4, 'display_name': 'Alex Wilson', 'level': 9, 'xp': 1950},
          {'rank': 5, 'display_name': 'Jessica Brown', 'level': 9, 'xp': 1890},
          {'rank': 6, 'display_name': 'David Miller', 'level': 8, 'xp': 1750},
          {'rank': 7, 'display_name': 'testuser', 'level': 5, 'xp': 450},
          {'rank': 8, 'display_name': 'Daniel Taylor', 'level': 4, 'xp': 320},
          {'rank': 9, 'display_name': 'Laura Anderson', 'level': 3, 'xp': 210},
          {'rank': 10, 'display_name': 'Kevin Thomas', 'level': 2, 'xp': 150},
      ];
      
      if (mounted) {
        setState(() {
          _entries = mockRankings;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  final isTop3 = entry['rank'] <= 3;
                  return _buildLeaderboardEntry(entry, isTop3);
                },
              ),
            ),
    );
  }

  Widget _buildLeaderboardEntry(Map<String, dynamic> entry, bool isTop3) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop3
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(16),
        border: isTop3
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              isTop3 ? _getRankEmoji(entry['rank']) : '#${entry['rank']}',
              style: GoogleFonts.outfit(
                fontSize: isTop3 ? 28 : 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            child: Center(
              child: Text(
                entry['display_name'][0].toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name and Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['display_name'],
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Level ${entry['level']}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          
          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${entry['xp']} XP',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}
