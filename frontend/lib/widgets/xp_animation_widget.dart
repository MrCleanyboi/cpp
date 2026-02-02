import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class XPAnimationWidget extends StatefulWidget {
  final int xpGained;
  final bool showLevelUp;
  final int? newLevel;
  final VoidCallback? onComplete;
  
  const XPAnimationWidget({
    super.key,
    required this.xpGained,
    this.showLevelUp = false,
    this.newLevel,
    this.onComplete,
  });

  @override
  State<XPAnimationWidget> createState() => _XPAnimationWidgetState();
}

class _XPAnimationWidgetState extends State<XPAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showLevelUp) ...[
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'LEVEL UP!',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Level ${widget.newLevel}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '✨',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${widget.xpGained} XP',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper function to show XP animation as overlay
void showXPAnimation(
  BuildContext context, {
  required int xpGained,
  bool showLevelUp = false,
  int? newLevel,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: 0,
      right: 0,
      child: Center(
        child: XPAnimationWidget(
          xpGained: xpGained,
          showLevelUp: showLevelUp,
          newLevel: newLevel,
          onComplete: () {
            Future.delayed(const Duration(milliseconds: 500), () {
              overlayEntry.remove();
            });
          },
        ),
      ),
    ),
  );
  
  overlay.insert(overlayEntry);
}
