import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gamification_service.dart';

// ─── Styles ──────────────────────────────────────────────────────────────────
final _totalEarnedStyle = GoogleFonts.outfit(
  fontSize: 48,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _unlockedLabelStyle = GoogleFonts.outfit(
  fontSize: 18,
  color: Colors.white70,
);

final _chipLabelStyle = GoogleFonts.outfit();

final _achievementTitleStyle = GoogleFonts.outfit(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

final _tierBadgeStyle = GoogleFonts.outfit(
  fontSize: 10,
  fontWeight: FontWeight.bold,
);

final _detailsTitleStyle = GoogleFonts.outfit(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

final _detailsDescStyle = GoogleFonts.outfit(
  fontSize: 16,
  color: Colors.white70,
);

class AchievementsScreen extends StatefulWidget {
  final String userId;
  
  const AchievementsScreen({super.key, required this.userId});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final GamificationService _gamificationService = GamificationService();
  Map<String, dynamic>? _achievementsData;
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _gamificationService.getAchievements(widget.userId);
      
      if (mounted) {
        setState(() {
          _achievementsData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading achievements: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredAchievements() {
    if (_achievementsData == null) return [];
    
    final achievements = _achievementsData!['achievements'] as List;
    if (_selectedCategory == 'all') {
      return achievements.cast<Map<String, dynamic>>();
    }
    
    return achievements
        .where((a) => a['category'] == _selectedCategory)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _achievementsData!;
    final filteredAchievements = _getFilteredAchievements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${data['total_earned']} / ${data['total_available']}',
                  style: _totalEarnedStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Achievements Unlocked',
                  style: _unlockedLabelStyle,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: data['total_earned'] / data['total_available'],
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                _buildCategoryChip('all', 'All'),
                _buildCategoryChip('lessons', 'Lessons'),
                _buildCategoryChip('streaks', 'Streaks'),
                _buildCategoryChip('perfect', 'Perfect'),
                _buildCategoryChip('milestones', 'Milestones'),
                _buildCategoryChip('social', 'Social'),
              ],
            ),
          ),

          // Achievements Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredAchievements.length,
              itemBuilder: (context, index) {
                final achievement = filteredAchievements[index];
                return _buildAchievementCard(achievement);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        backgroundColor: const Color(0xFF1E212B),
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: _chipLabelStyle.copyWith(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isEarned = achievement['earned'] as bool;
    
    return GestureDetector(
      onTap: () {
        _showAchievementDetails(achievement);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(16),
          border: isEarned
              ? Border.all(
                  color: _getTierColor(achievement['tier']),
                  width: 2,
                )
              : null,
        ),
        child: Stack(
          children: [
            // Locked overlay
            if (!isEarned)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Text(
                    achievement['icon'],
                    style: TextStyle(
                      fontSize: 48,
                      color: isEarned ? null : Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    achievement['title'],
                    style: _achievementTitleStyle.copyWith(
                      color: isEarned ? Colors.white : Colors.white38,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Tier badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTierColor(achievement['tier']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      achievement['tier'].toUpperCase(),
                      style: _tierBadgeStyle.copyWith(
                        color: _getTierColor(achievement['tier']),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Rewards
                  if (isEarned)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✨ ${achievement['xp_reward']}'),
                        const SizedBox(width: 8),
                        Text('💎 ${achievement['gem_reward']}'),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.grey;
    }
  }

  void _showAchievementDetails(Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement['icon'],
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              achievement['title'],
              style: _detailsTitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement['description'],
              style: _detailsDescStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✨ ${achievement['xp_reward']} XP'),
                  const SizedBox(width: 16),
                  Text('💎 ${achievement['gem_reward']} Gems'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
