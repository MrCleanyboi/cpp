import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'partner_matched_screen.dart';
import '../services/matching_api_service.dart';

// ─── Styles ──────────────────────────────────────────────────────────────────
final _findingTitleStyle = GoogleFonts.outfit(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _findingSubStyle = GoogleFonts.outfit(
  fontSize: 16,
  color: Colors.white60,
);

final _waitValueStyle = GoogleFonts.outfit(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _waitLabelStyle = GoogleFonts.outfit(
  fontSize: 12,
  color: Colors.white54,
);

final _tipTextStyle = GoogleFonts.outfit(
  fontSize: 14,
  color: Colors.white70,
);

final _cancelBtnStyle = GoogleFonts.outfit(
  fontSize: 16,
  color: Colors.white70,
);

class PartnerWaitingScreen extends StatefulWidget {
  final String targetLanguage;
  final String practiceMode;
  final Map<String, dynamic> queueStatus; // Real API response

  const PartnerWaitingScreen({
    super.key,
    required this.targetLanguage,
    required this.practiceMode,
    required this.queueStatus,
  });

  @override
  State<PartnerWaitingScreen> createState() => _PartnerWaitingScreenState();
}

class _PartnerWaitingScreenState extends State<PartnerWaitingScreen>
    with SingleTickerProviderStateMixin {
  int queuePosition = 0;
  int estimatedSeconds = 0;
  Timer? _statusPollTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isMatched = false;

  @override
  void initState() {
    super.initState();

    // Initialize from queue status
    _updateQueueStatus(widget.queueStatus);

    // Pulse animation for searching indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Poll for match status every 2 seconds
    _statusPollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkMatchStatus();
    });
  }

  void _updateQueueStatus(Map<String, dynamic> status) {
    // Check if immediately matched
    if (status['status'] == 'matched') {
      _isMatched = true;
      _navigateToMatchFound(status);
      return;
    }

    // Update queue info
    setState(() {
      queuePosition = status['position'] ?? 0;
      estimatedSeconds = status['estimated_wait_seconds'] ?? 0;
    });
  }

  Future<void> _checkMatchStatus() async {
    if (_isMatched || !mounted) return;

    try {
      final status = await matchingApiService.getMatchStatus();

      if (status['status'] == 'matched') {
        _isMatched = true;
        _navigateToMatchFound(status);
      } else if (status['status'] == 'waiting' || status['status'] == 'queued') {
        // Update queue position
        setState(() {
          queuePosition = status['position'] ?? queuePosition;
          estimatedSeconds = status['estimated_wait_seconds'] ?? estimatedSeconds;
          
          // Countdown estimate
          if (estimatedSeconds > 0) estimatedSeconds--;
        });
      }
    } catch (e) {
      print('Error checking match status: $e');
      // Continue polling - transient error
    }
  }

  void _navigateToMatchFound(Map<String, dynamic> matchData) {
    _statusPollTimer?.cancel();
    
    if (mounted) {
      // Use Future.delayed to ensure we're not in a build phase
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PartnerMatchedScreen(
                targetLanguage: widget.targetLanguage,
                matchData: matchData, // Pass real match data
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _cancelSearch() async {
    _statusPollTimer?.cancel();
    
    // Call API to leave queue
    try {
      await matchingApiService.leaveQueue();
    } catch (e) {
      print('Error leaving queue: $e');
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated search indicator
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6C63FF).withOpacity(0.3),
                        const Color(0xFF6C63FF).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.search_rounded,
                      size: 60,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Finding Partner',
                style: _findingTitleStyle,
              ),

              const SizedBox(height: 12),

              Text(
                'Searching for ${widget.targetLanguage} speakers...',
                style: _findingSubStyle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Loading bar
              Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E212B),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF6C63FF),
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              const SizedBox(height: 40),

              // Stats cards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatCard(
                    Icons.timer_outlined,
                    '~$estimatedSeconds sec',
                    'Est. wait',
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    Icons.format_list_numbered,
                    '$queuePosition',
                    'In queue',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Tips
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E212B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF00E5FF),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tip: Be polite and patient with your partner!',
                        style: _tipTextStyle,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Cancel button
              OutlinedButton(
                onPressed: _cancelSearch,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel Search',
                  style: _cancelBtnStyle,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: _waitValueStyle,
          ),
          Text(
            label,
            style: _waitLabelStyle,
          ),
        ],
      ),
    );
  }
}
