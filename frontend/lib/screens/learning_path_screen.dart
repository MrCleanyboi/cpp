import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lesson_screen.dart';
import '../models/lesson_model.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    // structured list with sections
    final List<dynamic> pathItems = [
      {'type': 'section', 'title': 'BEGINNER'},
      {'type': 'lesson', 'title': 'Beginner 1', 'icon': Icons.star_rounded, 'locked': false},
      {'type': 'lesson', 'title': 'Beginner 2', 'icon': Icons.translate_rounded, 'locked': true},
      {'type': 'lesson', 'title': 'Beginner 3', 'icon': Icons.chat_bubble_rounded, 'locked': true},
      
      {'type': 'section', 'title': 'INTERMEDIATE'},
      {'type': 'lesson', 'title': 'Intermediate 1', 'icon': Icons.school_rounded, 'locked': true},
      {'type': 'lesson', 'title': 'Intermediate 2', 'icon': Icons.restaurant_menu_rounded, 'locked': true},
      {'type': 'lesson', 'title': 'Intermediate 3', 'icon': Icons.train_rounded, 'locked': true},

      {'type': 'section', 'title': 'ADVANCED'},
      {'type': 'lesson', 'title': 'Advanced 1', 'icon': Icons.menu_book_rounded, 'locked': true},
      {'type': 'lesson', 'title': 'Advanced 2', 'icon': Icons.business_center_rounded, 'locked': true},
      {'type': 'lesson', 'title': 'Advanced 3', 'icon': Icons.theater_comedy_rounded, 'locked': true},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Path"),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E212B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6C63FF), width: 1.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text("2", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: pathItems.length,
        itemBuilder: (context, index) {
          final item = pathItems[index];

          if (item['type'] == 'section') {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  item['title'],
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                    letterSpacing: 2,
                  ),
                ),
              ),
            );
          }

          // Logic for snake path for lessons
          // We need to count how many lessons appeared before this one in THIS SECTION
          // to determine left/right placement.
          int lessonsInSection = 0;
          for (int i = index - 1; i >= 0; i--) {
            if (pathItems[i]['type'] == 'section') break;
            lessonsInSection++;
          }
          
          final bool isRightSide = lessonsInSection % 2 != 0;
          
          // Check if next is a lesson to decide on connector
          bool nextIsLesson = false;
          if (index + 1 < pathItems.length) {
             nextIsLesson = pathItems[index + 1]['type'] == 'lesson';
          }

          return _buildLessonNode(
            context,
            title: item['title'],
            icon: item['icon'],
            isLocked: item['locked'],
            offset: isRightSide ? 50.0 : -50.0,
            isLast: !nextIsLesson, // Don't draw connector if next is not a lesson (e.g. end of list or next is section)
            nextOffset: !isRightSide ? 50.0 : -50.0, // Flip side for next
          );
        },
      ),
    );
  }

  Widget _buildLessonNode(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isLocked,
    required double offset,
    required bool isLast,
    required double nextOffset,
  }) {
    return Column(
      children: [
        Transform.translate(
          offset: Offset(offset, 0),
          child: _LessonButton(
             title: title,
             icon: icon,
             isLocked: isLocked,
             onTap: () {
               if (!isLocked) {
                 // Fetch lesson data
                 final lesson = LessonData.getLesson(title);
                 if (lesson != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(lesson: lesson),
                      ),
                    );
                 } else {
                   // Fallback for lessons not in data yet
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Lesson content coming soon!")),
                   );
                 }
               }
             },
          ),
        ),
        if (!isLast)
           SizedBox(
            height: 60,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: PathConnectorPainter(
                startX: offset, 
                endX: (isLast ? offset : -offset) // Swaps side for next one
              ),
            ),
          ),
      ],
    );
  }
}

class _LessonButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isLocked;
  final VoidCallback onTap;

  const _LessonButton({
    required this.title,
    required this.icon,
    required this.isLocked,
    required this.onTap,
  });

  @override
  State<_LessonButton> createState() => _LessonButtonState();
}

class _LessonButtonState extends State<_LessonButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - _controller.value,
            child: child,
          );
        },
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isLocked 
                    ? const Color(0xFF1E212B) 
                    : const Color(0xFF6C63FF),
                boxShadow: [
                  BoxShadow(
                    color: widget.isLocked 
                      ? Colors.transparent 
                      : const Color(0xFF6C63FF).withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  if (!widget.isLocked)
                    const BoxShadow(
                      color: Color(0xFF5A52D5), // Darker shade for 3D effect side
                      offset: Offset(0, 6),
                      blurRadius: 0,
                    ),
                ],
                border: widget.isLocked 
                    ? Border.all(color: Colors.white12, width: 2)
                    : Border.all(color: Colors.white, width: 4),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!widget.isLocked)
                    Positioned(
                      top: 10,
                      left: 15,
                      child: Container(
                        width: 20,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  Icon(
                    widget.isLocked ? Icons.lock_outline_rounded : widget.icon,
                    color: widget.isLocked ? Colors.white24 : Colors.white,
                    size: 36,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isLocked ? Colors.white24 : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PathConnectorPainter extends CustomPainter {
  final double startX;
  final double endX;

  PathConnectorPainter({required this.startX, required this.endX});

  @override
  void paint(Canvas canvas, Size size) {
    if (startX == endX) return; // Should navigate side to side usually

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Draw a curved line from top center (startX) to bottom center (endX)
    // We assume the painter is placed between two nodes vertically
    
    final w = size.width;
    final h = size.height;
    
    // Convert offsets (relative to center) to local coordinates
    final startPointX = (w / 2) + startX;
    final endPointX = (w / 2) + endX;
    
    path.moveTo(startPointX, 0);
    
    // Cubic bezier for smooth S-curve
    path.cubicTo(
      startPointX, h * 0.5, // Control point 1 (vertical down)
      endPointX, h * 0.5,   // Control point 2 (vertical up from bottom)
      endPointX, h          // End point
    );

    canvas.drawPath(path, paint);
    


    // Simple dash effect (drawing small segments)
    // For now a solid cleaner line is better for UI than a messy dash custom impl
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
