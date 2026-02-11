import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../utils/language_theme.dart';
import 'lesson_screen.dart';
import '../models/lesson_model.dart';
import '../services/api_service.dart'; // Ensure this exists for baseUrl

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
  bool _isLoading = true;
  Map<String, dynamic>? _courseData;
  late LanguageTheme _theme;
  String _error = '';

  @override
  void initState() {
    super.initState();
    print('DEBUG LearningPath: initState called with language: ${widget.targetLanguage}');
    _theme = LanguageTheme.getTheme(widget.targetLanguage);
    _fetchCourseData();
  }

  Future<void> _fetchCourseData() async {
    try {
      final langCode = widget.targetLanguage;
      print('DEBUG LearningPath: Fetching course for language: $langCode');
      print('DEBUG LearningPath: Theme color: ${_theme.primaryColor}');
        
      // Fetch course structure
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/learning/course/$langCode'),
        headers: await AuthService.getHeaders(),
      );

      print('DEBUG LearningPath: API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG LearningPath: Course title: ${data['title']}');
        
        if (mounted) {
          setState(() {
            _courseData = data;
            _isLoading = false;
          });
        }
      } else {
         // Fallback/Error handling
         if (mounted) setState(() => _error = "Course not found for $langCode");
      }
    } catch (e) {
      print('DEBUG LearningPath: Error: $e');
      if (mounted) setState(() => _error = "Error loading path: $e");
    } finally {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Learning Path")),
        body: Center(child: Text(_error, style: const TextStyle(color: Colors.red))),
      );
    }

    // Flatten units into a renderable list
    final List<dynamic> pathItems = [];
    if (_courseData != null && _courseData!['units'] != null) {
      for (var unit in _courseData!['units']) {
        pathItems.add({'type': 'section', 'title': unit['title']});
        for (var lesson in unit['lessons']) {
          pathItems.add({
            'type': 'lesson', 
            'title': lesson['title'], 
            'icon': _getIconData(lesson['icon']), 
            'locked': lesson['is_locked'] ?? true
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_courseData?['title'] ?? "Learning Path"),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E212B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _theme.primaryColor, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                const Text("2", style: TextStyle(fontWeight: FontWeight.bold)), // TODO: Real Streak
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
                    color: _theme.primaryColor, // Theme Color
                    letterSpacing: 2,
                  ),
                ),
              ),
            );
          }

          // Snake Logic
          int lessonsInSection = 0;
          for (int i = index - 1; i >= 0; i--) {
            if (pathItems[i]['type'] == 'section') break;
            lessonsInSection++;
          }
          
          final bool isRightSide = lessonsInSection % 2 != 0;
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
            isLast: !nextIsLesson, 
            nextOffset: !isRightSide ? 50.0 : -50.0,
            themeColor: _theme.primaryColor,
          );
        },
      ),
    );
  }
  
  // Helper to map string icon names to IconData
  IconData _getIconData(String? iconName) {
    switch(iconName) {
        case 'star_rounded': return Icons.star_rounded;
        case 'translate_rounded': return Icons.translate_rounded;
        case 'chat_bubble_rounded': return Icons.chat_bubble_rounded;
        case 'school_rounded': return Icons.school_rounded;
        case 'restaurant_menu_rounded': return Icons.restaurant_menu_rounded;
        case 'train_rounded': return Icons.train_rounded;
        case 'menu_book_rounded': return Icons.menu_book_rounded;
        case 'business_center_rounded': return Icons.business_center_rounded;
        case 'theater_comedy_rounded': return Icons.theater_comedy_rounded;
        // French
        case 'waving_hand': return Icons.waving_hand;
        case 'looks_one': return Icons.looks_one;
        case 'looks_two': return Icons.looks_two;
        case 'flight': return Icons.flight;
        case 'restaurant': return Icons.restaurant;
        case 'people': return Icons.people;
        case 'work': return Icons.work;
        case 'palette': return Icons.palette;
        case 'gavel': return Icons.gavel;
        // Spanish
        case 'emoji_people': return Icons.emoji_people;
        case 'filter_1': return Icons.filter_1;
        case 'filter_2': return Icons.filter_2;
        case 'tapas': return Icons.local_pizza; // Close enough
        case 'location_city': return Icons.location_city;
        case 'groups': return Icons.groups;
        case 'attach_money': return Icons.attach_money;
        case 'history_edu': return Icons.history_edu;
        case 'auto_stories': return Icons.auto_stories;
        
        default: return Icons.category;
    }
  }

  Widget _buildLessonNode(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isLocked,
    required double offset,
    required bool isLast,
    required double nextOffset,
    required Color themeColor,
  }) {
    return Column(
      children: [
        Transform.translate(
          offset: Offset(offset, 0),
          child: _LessonButton(
             title: title,
             icon: icon,
             isLocked: isLocked,
             themeColor: themeColor,
             onTap: () {
               if (!isLocked) {
                 final lesson = LessonData.getLesson(title);
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
        if (!isLast)
           SizedBox(
            height: 60,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: PathConnectorPainter(
                startX: offset, 
                endX: (isLast ? offset : -offset) 
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
  final Color themeColor;
  final VoidCallback onTap;

  const _LessonButton({
    required this.title,
    required this.icon,
    required this.isLocked,
    required this.themeColor,
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
                    : widget.themeColor,
                boxShadow: [
                  BoxShadow(
                    color: widget.isLocked 
                      ? Colors.transparent 
                      : widget.themeColor.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  if (!widget.isLocked)
                     BoxShadow(
                      color: Color.lerp(widget.themeColor, Colors.black, 0.2)!,
                      offset: const Offset(0, 6),
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
    if (startX == endX) return; 

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    final w = size.width;
    final h = size.height;
    
    final startPointX = (w / 2) + startX;
    final endPointX = (w / 2) + endX;
    
    path.moveTo(startPointX, 0);
    
    path.cubicTo(
      startPointX, h * 0.5, 
      endPointX, h * 0.5,   
      endPointX, h          
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
