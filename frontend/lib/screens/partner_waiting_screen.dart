import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'partner_matched_screen.dart';

class PartnerWaitingScreen extends StatefulWidget {
  final String targetLanguage;
  final String practiceMode;

  const PartnerWaitingScreen({
    super.key,
    required this.targetLanguage,
    required this.practiceMode,
  });

  @override
  State<PartnerWaitingScreen> createState() => _PartnerWaitingScreenState();
}

class _PartnerWaitingScreenState extends State<PartnerWaitingScreen>
    with SingleTickerProviderStateMixin {
  int queuePosition = 3;
  int estimatedSeconds = 45;
  Timer? _countdownTimer;
  Timer? _matchTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for searching indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulate countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (estimatedSeconds > 0) estimatedSeconds--;
          if (queuePosition > 1 && estimatedSeconds % 7 == 0) {
            queuePosition--;
          }
        });
      }
    });

    // Simulate finding a match after 5-8 seconds
    final matchDelay = 5 + (DateTime.now().millisecond % 3);
    _matchTimer = Timer(Duration(seconds: matchDelay), _navigateToMatchFound);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _matchTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToMatchFound() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PartnerMatchedScreen(
            targetLanguage: widget.targetLanguage,
          ),
        ),
      );
    }
  }

  void _cancelSearch() {
    _countdownTimer?.cancel();
    _matchTimer?.cancel();
    Navigator.pop(context);
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
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Searching for ${widget.targetLanguage} speakers...',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white60,
                ),
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
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
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
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
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
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
