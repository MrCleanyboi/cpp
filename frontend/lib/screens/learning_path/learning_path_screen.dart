import 'package:flutter/material.dart';
import 'widgets/path_node.dart';
import 'widgets/section_header.dart';
import '../../models/lesson_model.dart';
import '../../utils/language_theme.dart'; // Import LanguageTheme
import '../lesson_screen.dart';
import '../../services/auth_service.dart';

class LearningPathScreen extends StatefulWidget {
  final String targetLanguage;
  
  const LearningPathScreen({
    super.key,
    required this.targetLanguage,
  });

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  List<String> _completedLessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedLessons();
  }

  Future<void> _loadCompletedLessons() async {
    try {
      final user = await AuthService.getUser();
      if (user != null) {
        final languageProgress = user['language_progress'];
        if (languageProgress != null && 
            languageProgress is Map && 
            languageProgress.containsKey(widget.targetLanguage)) {
          
          final langProg = languageProgress[widget.targetLanguage];
          final completed = langProg['completed_lessons'];
          
          if (completed is List) {
            setState(() {
              _completedLessons = completed.map((e) => e.toString()).toList();
              _isLoading = false;
            });
            return;
          }
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading completed lessons: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isLessonCompleted(String lessonId) {
    return _completedLessons.contains(lessonId);
  }

  bool _isLessonUnlocked(int unitNum, int lessonNum) {
    // First lesson is always unlocked
    if (unitNum == 1 && lessonNum == 1) return true;
    
    // Check if previous lesson is completed
    final previousLessonId = '${widget.targetLanguage}_beginner_${unitNum}_${lessonNum - 1}';
    return _isLessonCompleted(previousLessonId);
  }





  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF11141C),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Get theme based on target language
    final theme = LanguageTheme.getTheme(widget.targetLanguage);
    print('DEBUG LearningPath: Using theme for ${widget.targetLanguage}, color: ${theme.primaryColor}');
    
    // structured list with sections
    final List<dynamic> pathItems = [];
    final sections = [
      {'name': 'Beginner', 'color': theme.primaryColor}, // Dynamic color!
      {'name': 'Intermediate', 'color': theme.secondaryColor}, // Dynamic!
      {'name': 'Advanced', 'color': theme.accentColor} // Dynamic!
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
          // Progressive unlock: check if lesson is unlocked
          final bool isUnlocked = s == 0 && u == 1 && l <= 4 && _isLessonUnlocked(u, l);
          
          // Check if this specific lesson is completed
          final lessonId = '${widget.targetLanguage}_beginner_${u}_$l';
          final bool isCompleted = _isLessonCompleted(lessonId);
          
          // Create smooth diagonal snake pattern (like Duolingo)
          // Pattern creates smooth S-curve: far right → mid right → center → mid left → far left → ...
          final positions = [0.6, 0.3, 0.0, -0.3, -0.6, -0.3, 0.0, 0.3];
          final double x = positions[sectionLessonCount % positions.length];
          
          sectionLessonCount++;

          pathItems.add({
            'type': 'node', 
            'title': '$sectionName $u-$l', 
            'icon': _getIconForLesson(l), 
            'status': isCompleted ? 'completed' : (isUnlocked ? 'current' : 'locked'),
            'x': x,
            'sectionColor': sectionColor, // Pass color to node
            'unitNum': u,      // Store unit number for lesson lookup
            'lessonNum': l,    // Store lesson number for lesson lookup
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
      body: RefreshIndicator(
        onRefresh: _loadCompletedLessons,
        color: theme.primaryColor,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(), // Ensure refresh works even if list is short
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: pathItems.length,
          itemBuilder: (context, index) {
            final item = pathItems[index];

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
              color: item['sectionColor'] ?? const Color(0xFF58CC02), // Use dynamic color from item
              onTap: () {
                if (!isLocked) {
                   // Get unit and lesson numbers from item
                   final unitNum = item['unitNum'] ?? 1;
                   final lessonNum = item['lessonNum'] ?? 1;
                   
                   // Try language-specific lesson (e.g., fr_beginner_1_2)
                   final lessonPath = 'beginner_${unitNum}_$lessonNum';
                   Lesson? lesson = LessonData.getLessonByLanguage(widget.targetLanguage, lessonPath);
                   
                   // Fallback to old lookup by title
                   lesson ??= LessonData.getLesson(item['title']);
                   
                   if (lesson != null) {
                      // Navigate and reload when returning
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonScreen(lesson: lesson!),
                        ),
                      ).then((_) {
                        // Reload completed lessons when returning from lesson
                        _loadCompletedLessons();
                      });
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Lesson '${item['title']}' coming soon!")),
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
  
  // Remove old _getColorForSection method since we now use dynamic colors

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
