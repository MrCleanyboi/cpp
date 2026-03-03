import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ─── Styles ──────────────────────────────────────────────────────────────────
final _achievementHeaderStyle = GoogleFonts.outfit(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.amber,
  letterSpacing: 2,
);

final _achievementTitleStyle = GoogleFonts.outfit(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _achievementDescStyle = GoogleFonts.outfit(
  fontSize: 16,
  color: Colors.white70,
);

final _rewardTextStyle = GoogleFonts.outfit(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _awesomeBtnStyle = GoogleFonts.outfit(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

class AchievementUnlockDialog extends StatefulWidget {
  final Map<String, dynamic> achievement;
  final VoidCallback? onClose;
  
  const AchievementUnlockDialog({
    super.key,
    required this.achievement,
    this.onClose,
  });

  @override
  State<AchievementUnlockDialog> createState() => _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.1,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF6C63FF),
                        const Color(0xFF6C63FF).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Achievement Unlocked" header
                      Text(
                        'ACHIEVEMENT UNLOCKED!',
                        style: _achievementHeaderStyle,
                      ),
                      const SizedBox(height: 24),
                      
                      // Icon with glow effect
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          // Icon
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amber, width: 4),
                            ),
                            child: Center(
                              child: Text(
                                widget.achievement['icon'] ?? '🏆',
                                style: const TextStyle(fontSize: 56),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        widget.achievement['title'] ?? 'Achievement',
                        style: _achievementTitleStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Description
                      Text(
                        widget.achievement['description'] ?? '',
                        style: _achievementDescStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Rewards
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '✨ ${widget.achievement['xp_reward'] ?? 0} XP',
                              style: _rewardTextStyle,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '💎 ${widget.achievement['gem_reward'] ?? 0} Gems',
                              style: _rewardTextStyle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Close button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (widget.onClose != null) {
                            widget.onClose!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Awesome!',
                          style: _awesomeBtnStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper function to show achievement unlock dialog
void showAchievementUnlock(
  BuildContext context,
  Map<String, dynamic> achievement, {
  VoidCallback? onClose,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AchievementUnlockDialog(
      achievement: achievement,
      onClose: onClose,
    ),
  );
}
