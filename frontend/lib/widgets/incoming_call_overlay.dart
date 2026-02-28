import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncomingCallOverlay extends StatelessWidget {
  final String callerName;
  final String callerId;
  final String matchId;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallOverlay({
    super.key,
    required this.callerName,
    required this.callerId,
    required this.matchId,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulse Animation Placeholder (Avatar)
          _AnimatedAvatar(initial: callerName[0]),
          const SizedBox(height: 24),
          Text(
            'Incoming Call',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: const Color(0xFF00E5FF),
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            callerName,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CallActionBtn(
                icon: Icons.close_rounded,
                color: Colors.redAccent,
                onTap: onDecline,
                label: 'Decline',
              ),
              _CallActionBtn(
                icon: Icons.phone_enabled_rounded,
                color: Colors.greenAccent,
                onTap: onAccept,
                label: 'Accept',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedAvatar extends StatefulWidget {
  final String initial;
  const _AnimatedAvatar({required this.initial});

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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
        return Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(3, (index) {
              final val = (_controller.value + index / 3) % 1;
              return Container(
                width: 100 + val * 100,
                height: 100 + val * 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity((1 - val) * 0.5),
                    width: 2,
                  ),
                ),
              );
            }),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF6C63FF),
              child: Text(
                widget.initial,
                style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CallActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String label;

  const _CallActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
