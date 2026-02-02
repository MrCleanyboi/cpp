import 'package:flutter/material.dart';
import 'widgets/path_node.dart';
import 'widgets/section_header.dart';
import '../../models/lesson_model.dart';
import '../lesson_screen.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // structured list with sections
    final List<dynamic> pathItems = [];
    final sections = [
      {'name': 'Beginner', 'color': const Color(0xFF58CC02)}, 
      {'name': 'Intermediate', 'color': const Color(0xFFCE82FF)}, 
      {'name': 'Advanced', 'color': const Color(0xFFFF9600)}
    ];

    for (int s = 0; s < sections.length; s++) {
      final section = sections[s];
      final String sectionName = section['name'] as String;
      final Color sectionColor = section['color'] as Color;
      
      // Track lesson count within this section for snake pattern
      int sectionLessonCount = 0;

      for (int u = 1; u <= 3; u++) {
        // Unit Header
        pathItems.add({
          'type': 'header', 
          'title': '$sectionName - Unit $u', 
          'desc': 'Unit $u Description', 
          'color': sectionColor
        });

        // 6 Lessons per Unit
        for (int l = 1; l <= 6; l++) {
          final bool isFirst = s == 0 && u == 1 && l == 1;
          
          // Create smooth diagonal snake pattern (like Duolingo)
          // Pattern creates smooth S-curve: far right → mid right → center → mid left → far left → ...
          final positions = [0.6, 0.3, 0.0, -0.3, -0.6, -0.3, 0.0, 0.3];
          final double x = positions[sectionLessonCount % positions.length];
          
          sectionLessonCount++;

          pathItems.add({
            'type': 'node', 
            'title': '$sectionName $u-$l', 
            'icon': _getIconForLesson(l), 
            'status': isFirst ? 'current' : 'locked', 
            'x': x
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF11141C),
      appBar: AppBar(
        title: const Text("Learning Path"),
        backgroundColor: const Color(0xFF11141C),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: pathItems.length,
        itemBuilder: (context, index) {
          final item = pathItems[index];
          print('DEBUG: Rendering item $index: ${item['type']}');

          if (item['type'] == 'header') {
            return SectionHeader(
              title: item['title'],
              description: item['desc'],
              color: item['color'],
            );
          } else {
            return _buildPathNodeRow(context, item, index, pathItems);
          }
        },
      ),
    );
  }

  Widget _buildPathNodeRow(BuildContext context, Map<String, dynamic> item, int index, List<dynamic> allItems) {
    // Determine status
    final status = item['status'];
    final bool isLocked = status == 'locked';
    final bool isCompleted = status == 'completed';
    final bool isCurrent = status == 'current';

    // Alignment based on 'x' value (-1.0 to 1.0)
    final double alignmentX = item['x'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8), // Spacing between nodes
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Draw Path Line (Behind the nodes)
          if (index < allItems.length - 1 && allItems[index + 1]['type'] == 'node')
            Positioned.fill(
              child: CustomPaint(
                painter: PathLinePainter(
                  startX: alignmentX,
                  endX: allItems[index + 1]['x'] ?? 0.0,
                  isNextLocked: allItems[index + 1]['status'] == 'locked',
                ),
              ),
            ),

          // The Node Itself
          Align(
            alignment: Alignment(alignmentX, 0),
            child: PathNode(
              title: item['title'],
              icon: item['icon'],
              isLocked: isLocked,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              color: _getColorForSection(index), // Dynamic color based on section
              onTap: () {
                if (!isLocked) {
                   final lesson = LessonData.getLesson(item['title']);
                   if (lesson != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonScreen(lesson: lesson),
                        ),
                      );
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Lesson content coming soon!")),
                     );
                   }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getColorForSection(int index) {
    // Simple logic to alternate colors based on approximate position
    // In a real app, pass the section color down
    if (index < 9) return const Color(0xFF58CC02); // Green
    return const Color(0xFFCE82FF); // Purple
  }

  IconData _getIconForLesson(int index) {
    const icons = [
      Icons.star_rounded,
      Icons.translate_rounded,
      Icons.chat_bubble_rounded, 
      Icons.headphones_rounded,
      Icons.menu_book_rounded,
      Icons.edit_rounded
    ];
    return icons[index % icons.length];
  }
}

class PathLinePainter extends CustomPainter {
  final double startX;
  final double endX;
  final bool isNextLocked;

  PathLinePainter({
    required this.startX,
    required this.endX,
    required this.isNextLocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isNextLocked ? const Color(0xFF37464F) : const Color(0xFF58CC02) // Dark Grey vs Green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Convert alignment (-1 to 1) to pixels
    final w = size.width;
    final h = size.height;
    
    // We assume the painter covers the Row's height plus some extra to reach the next row
    // BUT since we are inside a Stack in a Row, we need to be careful.
    // Actually, drawing spanning lines in a ListView is tricky.
    // Simplified specific implementation:
    // We just draw a line from Current Center to Next Center (conceptually).
    // In this specific widget structure, the `CustomPaint` is `Positioned.fill` in the CURRENT row.
    // It implies we draw from (startX, center) to (endX, bottom + gap).
    
    final startPixelX = (startX + 1) / 2 * w; // Map -1..1 to 0..w
    final endPixelX = (endX + 1) / 2 * w;
    
    // Start at center of current node
    path.moveTo(startPixelX, h / 2 + 20); 
    
    // Draw to center of next node (which is assumed to be at 'h + spacing')
    // We approximate the vertical distance to the next node center
    final nextNodeCenterY = h + 100; // Estimated height of next row
    
    path.cubicTo(
      startPixelX, h, // Control 1
      endPixelX, h,   // Control 2
      endPixelX, nextNodeCenterY // End
    );

    // canvas.drawPath(path, paint);
    // Note: Implementing perfect lines in ListView requires knowing exact heights. 
    // For this MVP, we might skip the lines or keep them simple short dashes.
    
    // Alternative: Simple vertical SVG-like curve
    // Drawing lines between ListView items is notoriously hard without valid extent data.
    // We will stick to the "Nodes" look which is cleaner for now, users can see the path order by position.
  }



  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
