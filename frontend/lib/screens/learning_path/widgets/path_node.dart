import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PathNode extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback onTap;
  final Color color;

  const PathNode({
    super.key,
    required this.title,
    required this.icon,
    this.isLocked = false,
    this.isCompleted = false,
    this.isCurrent = false,
    required this.onTap,
    this.color = const Color(0xFF58CC02), // Default Duolingo Green
  });

  @override
  State<PathNode> createState() => _PathNodeState();
}

class _PathNodeState extends State<PathNode> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLocked) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLocked) {
      _controller.reverse();
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLocked) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colors based on state
    final Color mainColor = widget.isLocked
        ? const Color(0xFFE5E5E5) // Light gray for locked
        : widget.color;
        
    final Color shadowColor = widget.isLocked
        ? const Color(0xFFAFAFAF)
        : HSLColor.fromColor(mainColor).withLightness(0.35).toColor(); // Darker shade

    final Color iconColor = widget.isLocked
        ? const Color(0xFFAFAFAF) 
        : Colors.white;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _controller.value * 10), // Push down effect
            child: SizedBox(
               height: 100, // Enough space for the 3D depth
               width: 90,
               child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow / 3D Side (Bottom Layer)
                  Positioned(
                    top: 8, // The depth height
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: shadowColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Main Face (Top Layer)
                  Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(bottom: _controller.value * 10 + 6), // Move this down when pressed
                    decoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shine effect
                        if (!widget.isLocked)
                          Positioned(
                            top: 10,
                            left: 15,
                            child: Container(
                              width: 15,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        
                        // Icon or Checkmark
                        Icon(
                          widget.isCompleted ? Icons.check_rounded : widget.icon,
                          color: iconColor,
                          size: 40,
                        ),
                        
                        // Stars for completed levels (optional decoration)
                        if (widget.isCompleted)
                           Positioned(
                             bottom: 5,
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Icon(Icons.star, size: 12, color: Colors.amber),
                                 Icon(Icons.star, size: 14, color: Colors.amber),
                                 Icon(Icons.star, size: 12, color: Colors.amber),
                               ],
                             ),
                           )
                      ],
                    ),
                  ),
                  
                  // Floating "START" Bubble for current item
                  if (widget.isCurrent)
                    Positioned(
                      top: 0,
                      child: Transform.translate(
                        offset: const Offset(0, -50), // Move above the button
                        child: _StartBubble(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StartBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "START",
            style: GoogleFonts.outfit(
              color: const Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          // Little triangle indicator
           Transform.translate(
             offset: const Offset(0, 4),
             child: CustomPaint(
               size: const Size(10, 6),
               painter: _TrianglePainter(),
             ),
           )
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
