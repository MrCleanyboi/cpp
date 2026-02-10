import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'partner_chat_screen.dart';

class PartnerMatchedScreen extends StatefulWidget {
  final String targetLanguage;
  final Map<String, dynamic> matchData; // Real match data from API

  const PartnerMatchedScreen({
    super.key,
    required this.targetLanguage,
    required this.matchData,
  });

  @override
  State<PartnerMatchedScreen> createState() => _PartnerMatchedScreenState();
}

class _PartnerMatchedScreenState extends State<PartnerMatchedScreen>
    with SingleTickerProviderStateMixin {
  int countdown = 3;
  Timer? _countdownTimer;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Extract partner data from matchData
  late Map<String, dynamic> partner;
  late String matchId;
  late String websocketUrl;

  @override
  void initState() {
    super.initState();

    // Extract data from API response
    matchId = widget.matchData['match_id'];
    partner = widget.matchData['partner'];
    websocketUrl = widget.matchData['websocket_url'] ?? '';

    // Initialize animations
    _initAnimations();
  }

  void _initAnimations() {

    // Scale animation for success indicator
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _scaleController.forward();

    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (countdown > 1) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        _safeNavigateToChat();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  bool _isNavigating = false;

  void _safeNavigateToChat() {
    print("DEBUG: _safeNavigateToChat called (Version Fixed)");
    if (_isNavigating) return;
    _isNavigating = true;
    _countdownTimer?.cancel();

    // Use Future.delayed to avoid scheduler lock issues
    Future.delayed(Duration.zero, () {
      print("DEBUG: Executing Future.delayed navigation callback");
      if (mounted) {
        print("DEBUG: mounted is true, pushing replacement");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PartnerChatScreen(
              matchId: matchId,
              partner: partner,
              targetLanguage: widget.targetLanguage,
              websocketUrl: websocketUrl,
            ),
          ),
        );
      }
    });
  }

  void _skipPartner() {
    _countdownTimer?.cancel();
    Navigator.pop(context);
    Navigator.pop(context);
    // In real implementation, would re-enter queue
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

              // Success icon with animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF00E5FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                '✨ Match Found!',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // Partner card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E212B),
                      const Color(0xFF6C63FF).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF6C63FF),
                      child: Text(
                        (partner['display_name'] ?? 'P')[0],
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name
                    Text(
                      partner['display_name'] ?? 'Partner',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Language info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇪🇸', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            'Native ${partner['language'] ?? 'Unknown'}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Learning language
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Learning ${widget.targetLanguage}',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Proficiency
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFF6C63FF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Language Partner',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bio
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1117),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '@${partner['username'] ?? 'user'}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Countdown
              Text(
                'Starting chat in $countdown...',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: const Color(0xFF00E5FF),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skipPartner,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.skip_next, color: Colors.white54),
                          const SizedBox(width: 8),
                          Text(
                            'Skip',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _safeNavigateToChat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Start Chat',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
