import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/gamification_service.dart';
import '../utils/language_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PROGRESS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  final _gamificationService = GamificationService();

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _user;
  List<dynamic> _achievements = [];
  bool _isLoading = true;
  String? _error;

  // Animation controllers
  late AnimationController _counterController;
  late AnimationController _barController;
  late AnimationController _ringController;

  late Animation<double> _counterAnim;
  late Animation<double> _barAnim;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();

    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _counterAnim = CurvedAnimation(parent: _counterController, curve: Curves.easeOut);
    _barAnim     = CurvedAnimation(parent: _barController,     curve: Curves.easeOutCubic);
    _ringAnim    = CurvedAnimation(parent: _ringController,    curve: Curves.easeOutCubic);

    _loadData();
  }

  @override
  void dispose() {
    _counterController.dispose();
    _barController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final userId = await AuthService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      final results = await Future.wait([
        _gamificationService.getUserProfile(userId),
        AuthService.getUser(),
        _gamificationService.getAchievements(userId).catchError((_) => <String, dynamic>{}),
      ]);

      final profile    = results[0] as Map<String, dynamic>;
      final user       = results[1] as Map<String, dynamic>?;
      final achievData = results[2] as Map<String, dynamic>;
      final achievList = achievData['achievements'] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _profile      = profile;
          _user         = user;
          _achievements = achievList.where((a) => a['earned'] == true).toList();
          _isLoading    = false;
        });
        // Start animations once data is ready
        _counterController.forward();
        Future.delayed(const Duration(milliseconds: 150), () => _barController.forward());
        Future.delayed(const Duration(milliseconds: 300), () => _ringController.forward());
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        elevation: 0,
        title: Text(
          'My Progress',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _counterController.reset();
              _barController.reset();
              _ringController.reset();
              _loadData();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoader()
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  color: const Color(0xFF6C63FF),
                  onRefresh: () async {
                    _counterController.reset();
                    _barController.reset();
                    _ringController.reset();
                    await _loadData();
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    children: [
                      _buildHeroStats(),
                      const SizedBox(height: 24),
                      _buildXpLevelCard(),
                      const SizedBox(height: 24),
                      _buildDailyGoalRing(),
                      const SizedBox(height: 24),
                      _buildLanguageBreakdown(),
                      const SizedBox(height: 24),
                      if (_achievements.isNotEmpty) ...[
                        _buildAchievements(),
                        const SizedBox(height: 24),
                      ],
                      _buildAllTimeStats(),
                    ],
                  ),
                ),
    );
  }

  // ── Loading / Error ────────────────────────────────────────────────────────

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF6C63FF)),
          const SizedBox(height: 16),
          Text('Loading your stats…',
              style: GoogleFonts.outfit(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white30, size: 48),
          const SizedBox(height: 12),
          Text('Could not load progress', style: GoogleFonts.outfit(color: Colors.white54)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  // ── Section 1: Hero Stats ─────────────────────────────────────────────────

  Widget _buildHeroStats() {
    final xp      = (_profile!['xp']                    as num?)?.toInt() ?? 0;
    final streak  = (_profile!['streak_count']           as num?)?.toInt() ?? 0;
    final lessons = (_profile!['total_lessons_completed'] as num?)?.toInt() ?? 0;

    return Row(
      children: [
        _buildStatPill('⚡', xp,      'Total XP',   const Color(0xFF6C63FF)),
        const SizedBox(width: 12),
        _buildStatPill('🔥', streak,  'Day Streak',  const Color(0xFFFF6B35)),
        const SizedBox(width: 12),
        _buildStatPill('📚', lessons, 'Lessons',     const Color(0xFF00BFA5)),
      ],
    );
  }

  Widget _buildStatPill(String emoji, int value, String label, Color color) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _counterAnim,
        builder: (_, __) {
          final displayed = (value * _counterAnim.value).round();
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 8),
                Text(
                  '$displayed',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Section 2: XP Level Card ──────────────────────────────────────────────

  Widget _buildXpLevelCard() {
    final level    = (_profile!['level']             as num?)?.toInt() ?? 1;
    final xp       = (_profile!['xp']               as num?)?.toInt() ?? 0;
    final xpToNext = (_profile!['xp_to_next_level'] as num?)?.toInt() ?? 50;
    final progress = xp / (xp + xpToNext).clamp(1, double.infinity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURRENT LEVEL',
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: Colors.white38, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    'Level $level',
                    style: GoogleFonts.outfit(
                        fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('⚡', style: TextStyle(fontSize: 28)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _barAnim,
            builder: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress * _barAnim.value,
                    minHeight: 14,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$xp XP earned',
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
                    Text('$xpToNext XP to Level ${level + 1}',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF6C63FF), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 3: Daily Goal Ring ────────────────────────────────────────────

  Widget _buildDailyGoalRing() {
    final earned = (_profile!['daily_xp_earned'] as num?)?.toInt() ?? 0;
    final goal   = (_profile!['daily_goal_xp']   as num?)?.toInt() ?? 20;
    final met    = _profile!['daily_goal_met'] == true;
    final ratio  = (earned / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Ring
          AnimatedBuilder(
            animation: _ringAnim,
            builder: (_, __) => SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: ratio * _ringAnim.value,
                  color: met ? const Color(0xFF00E676) : const Color(0xFF6C63FF),
                  bgColor: Colors.white12,
                  strokeWidth: 12,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$earned',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'of $goal',
                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Goal',
                  style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  met
                      ? '🎉 Completed today!'
                      : '${goal - earned} XP left to reach your goal',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: met ? const Color(0xFF00E676) : Colors.white54,
                  ),
                ),
                const SizedBox(height: 16),
                if (met)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00E676).withOpacity(0.4)),
                    ),
                    child: Text(
                      '✅  GOAL MET',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00E676)),
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation: _ringAnim,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ratio * _ringAnim.value,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 4: Language Breakdown ────────────────────────────────────────

  Widget _buildLanguageBreakdown() {
    final langProgress =
        (_user?['language_progress'] as Map<String, dynamic>?) ?? {};

    const totalLessons = 27; // 9 units × 3 lessons
    const langs = ['de', 'fr', 'es'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Language Progress'),
        const SizedBox(height: 14),
        ...langs.map((code) {
          final theme    = LanguageTheme.getTheme(code);
          final langData = langProgress[code] as Map<String, dynamic>?;
          final completed = (langData?['completed_lessons'] as List?)?.length ?? 0;
          final ratio    = (completed / totalLessons).clamp(0.0, 1.0);
          final pct      = (ratio * 100).round();

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E212B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Text(theme.flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Text(theme.name,
                            style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ]),
                      Text(
                        '$completed / $totalLessons lessons',
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _barAnim,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ratio * _barAnim.value,
                        minHeight: 10,
                        backgroundColor: Colors.white12,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$pct% complete',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Section 5: Achievements ───────────────────────────────────────────────

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Achievements'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_achievements.length} earned',
                style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                _buildAchievementBadge(_achievements[i] as Map<String, dynamic>),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(Map<String, dynamic> a) {
    final icon  = a['icon']  as String? ?? '🏆';
    final title = a['title'] as String? ?? 'Achievement';

    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Section 6: All-Time Stats ─────────────────────────────────────────────

  Widget _buildAllTimeStats() {
    final gems    = (_profile!['gems']              as num?)?.toInt() ?? 0;
    final timeMin = (_profile!['total_time_minutes'] as num?)?.toInt() ?? 0;
    final longest = (_profile!['longest_streak']    as num?)?.toInt() ?? 0;
    final hearts  = (_profile!['hearts']            as num?)?.toInt() ?? 5;

    final hours   = timeMin ~/ 60;
    final mins    = timeMin % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('All-Time Stats'),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildMiniStat('💎', '$gems',          'Gems Earned'),
            _buildMiniStat('⏱️', timeStr,          'Time Studied'),
            _buildMiniStat('🏅', '$longest Days',  'Best Streak'),
            _buildMiniStat('❤️', '$hearts',        'Hearts Left'),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(label,
                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.white38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  RING PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color       = bgColor
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap   = StrokeCap.round,
    );

    if (progress > 0) {
      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      // Glow
      canvas.drawArc(
        rect, startAngle, sweepAngle, false,
        Paint()
          ..color       = color.withOpacity(0.25)
          ..style       = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..strokeCap   = StrokeCap.round
          ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Arc
      canvas.drawArc(
        rect, startAngle, sweepAngle, false,
        Paint()
          ..color       = color
          ..style       = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap   = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
