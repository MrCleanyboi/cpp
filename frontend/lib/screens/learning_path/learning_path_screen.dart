import 'package:flutter/material.dart';
import 'widgets/path_node.dart';
import 'widgets/section_header.dart';
import '../../models/lesson_model.dart';
import '../../utils/language_theme.dart'; // Import LanguageTheme
import '../lesson_screen.dart';
import '../vocab_preview_screen.dart';
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

  // Static course data — defined at class level to avoid re-allocation on every build
  static final Map<String, List<Map<String, dynamic>>> _courseData = {
    'de': [
      { 'level': 'Beginner', 'title': 'The Café', 'desc': 'Ordering food and drinks', 'unitNum': 1, 'color_key': 'primary', 'lessons': [ {'title': 'Ordering Coffee', 'icon': Icons.coffee, 'id': 'l1'}, {'title': 'The Menu', 'icon': Icons.restaurant_menu, 'id': 'l2'}, {'title': 'Paying the Bill', 'icon': Icons.receipt_long, 'id': 'l3'} ] },
      { 'level': 'Beginner', 'title': 'Family & Friends', 'desc': 'Talking about people', 'unitNum': 2, 'color_key': 'primary', 'lessons': [ {'title': 'Family Members', 'icon': Icons.groups, 'id': 'l1'}, {'title': 'Describing People', 'icon': Icons.face, 'id': 'l2'}, {'title': 'Pets', 'icon': Icons.pets, 'id': 'l3'} ] },
      { 'level': 'Beginner', 'title': 'My Home', 'desc': 'Housing and objects', 'unitNum': 3, 'color_key': 'primary', 'lessons': [ {'title': 'Rooms', 'icon': Icons.home, 'id': 'l1'}, {'title': 'Furniture', 'icon': Icons.chair, 'id': 'l2'}, {'title': 'Location', 'icon': Icons.search, 'id': 'l3'} ] },
      { 'level': 'Intermediate', 'title': 'Travel & City', 'desc': 'Getting around', 'unitNum': 4, 'color_key': 'secondary', 'lessons': [ {'title': 'At the Station', 'icon': Icons.train, 'id': 'l1'}, {'title': 'Hotel', 'icon': Icons.hotel, 'id': 'l2'}, {'title': 'Directions', 'icon': Icons.map, 'id': 'l3'} ] },
      { 'level': 'Intermediate', 'title': 'Hobbies', 'desc': 'Free time', 'unitNum': 5, 'color_key': 'secondary', 'lessons': [ {'title': 'Sports', 'icon': Icons.sports_soccer, 'id': 'l1'}, {'title': 'Music & Movies', 'icon': Icons.movie, 'id': 'l2'}, {'title': 'Weekend', 'icon': Icons.calendar_today, 'id': 'l3'} ] },
      { 'level': 'Intermediate', 'title': 'Shopping', 'desc': 'Buying things', 'unitNum': 6, 'color_key': 'secondary', 'lessons': [ {'title': 'Clothing', 'icon': Icons.checkroom, 'id': 'l1'}, {'title': 'Colors', 'icon': Icons.palette, 'id': 'l2'}, {'title': 'Market', 'icon': Icons.storefront, 'id': 'l3'} ] },
      { 'level': 'Advanced', 'title': 'Business', 'desc': 'Professional life', 'unitNum': 7, 'color_key': 'accent', 'lessons': [ {'title': 'The Meeting', 'icon': Icons.meeting_room, 'id': 'l1'}, {'title': 'Office Life', 'icon': Icons.desk, 'id': 'l2'}, {'title': 'Emails', 'icon': Icons.email, 'id': 'l3'} ] },
      { 'level': 'Advanced', 'title': 'Media', 'desc': 'Current events', 'unitNum': 8, 'color_key': 'accent', 'lessons': [ {'title': 'The News', 'icon': Icons.newspaper, 'id': 'l1'}, {'title': 'Technology', 'icon': Icons.computer, 'id': 'l2'}, {'title': 'Social Media', 'icon': Icons.share, 'id': 'l3'} ] },
      { 'level': 'Advanced', 'title': 'Environment', 'desc': 'Global issues', 'unitNum': 9, 'color_key': 'accent', 'lessons': [ {'title': 'Nature', 'icon': Icons.forest, 'id': 'l1'}, {'title': 'The Future', 'icon': Icons.public, 'id': 'l2'}, {'title': 'Debate', 'icon': Icons.record_voice_over, 'id': 'l3'} ] },
    ],
    'fr': [
      { 'level': 'Débutant', 'title': 'Le Café', 'desc': 'Parisian coffee', 'unitNum': 1, 'color_key': 'primary', 'lessons': [ {'title': 'Un Café', 'icon': Icons.coffee, 'id': 'l1'}, {'title': 'Croissants', 'icon': Icons.bakery_dining, 'id': 'l2'}, {'title': 'Paying', 'icon': Icons.receipt, 'id': 'l3'} ] },
      { 'level': 'Débutant', 'title': 'Famille', 'desc': 'Family members', 'unitNum': 2, 'color_key': 'primary', 'lessons': [ {'title': 'Parents', 'icon': Icons.groups, 'id': 'l1'}, {'title': 'Siblings', 'icon': Icons.face, 'id': 'l2'}, {'title': 'Pets', 'icon': Icons.pets, 'id': 'l3'} ] },
      { 'level': 'Débutant', 'title': 'Ma Maison', 'desc': 'My House', 'unitNum': 3, 'color_key': 'primary', 'lessons': [ {'title': 'Rooms', 'icon': Icons.home, 'id': 'l1'}, {'title': 'Furniture', 'icon': Icons.chair, 'id': 'l2'}, {'title': 'Garden', 'icon': Icons.deck, 'id': 'l3'} ] },
      { 'level': 'Intermédiaire', 'title': 'Voyage', 'desc': 'Travel to Paris', 'unitNum': 4, 'color_key': 'secondary', 'lessons': [ {'title': 'Métro', 'icon': Icons.subway, 'id': 'l1'}, {'title': 'Musée', 'icon': Icons.museum, 'id': 'l2'}, {'title': 'Tour Eiffel', 'icon': Icons.camera_alt, 'id': 'l3'} ] },
      { 'level': 'Intermédiaire', 'title': 'Loisirs', 'desc': 'Hobbies', 'unitNum': 5, 'color_key': 'secondary', 'lessons': [ {'title': 'Sport', 'icon': Icons.sports_soccer, 'id': 'l1'}, {'title': 'Cinema', 'icon': Icons.movie, 'id': 'l2'}, {'title': 'Music', 'icon': Icons.music_note, 'id': 'l3'} ] },
      { 'level': 'Intermédiaire', 'title': 'Shopping', 'desc': 'Mode & Style', 'unitNum': 6, 'color_key': 'secondary', 'lessons': [ {'title': 'Clothes', 'icon': Icons.checkroom, 'id': 'l1'}, {'title': 'Colors', 'icon': Icons.palette, 'id': 'l2'}, {'title': 'Boutique', 'icon': Icons.shopping_bag, 'id': 'l3'} ] },
      { 'level': 'Avancé', 'title': 'Vie Pro', 'desc': 'Work Life', 'unitNum': 7, 'color_key': 'accent', 'lessons': [ {'title': 'Interview', 'icon': Icons.work, 'id': 'l1'}, {'title': 'Office', 'icon': Icons.desk, 'id': 'l2'}, {'title': 'Meeting', 'icon': Icons.meeting_room, 'id': 'l3'} ] },
      { 'level': 'Avancé', 'title': 'Actualités', 'desc': 'News', 'unitNum': 8, 'color_key': 'accent', 'lessons': [ {'title': 'Journal', 'icon': Icons.newspaper, 'id': 'l1'}, {'title': 'Politics', 'icon': Icons.policy, 'id': 'l2'}, {'title': 'Internet', 'icon': Icons.language, 'id': 'l3'} ] },
      { 'level': 'Avancé', 'title': 'Environnement', 'desc': 'Ecology', 'unitNum': 9, 'color_key': 'accent', 'lessons': [ {'title': 'Nature', 'icon': Icons.forest, 'id': 'l1'}, {'title': 'Pollution', 'icon': Icons.warning, 'id': 'l2'}, {'title': 'Recycling', 'icon': Icons.recycling, 'id': 'l3'} ] },
    ],
    'es': [
      { 'level': 'Principiante', 'title': 'El Restaurante', 'desc': 'Ordering food', 'unitNum': 1, 'color_key': 'primary', 'lessons': [ {'title': 'Tapas', 'icon': Icons.tapas, 'id': 'l1'}, {'title': 'Bebidas', 'icon': Icons.wine_bar, 'id': 'l2'}, {'title': 'La Cuenta', 'icon': Icons.receipt, 'id': 'l3'} ] },
      { 'level': 'Principiante', 'title': 'Familia', 'desc': 'Family', 'unitNum': 2, 'color_key': 'primary', 'lessons': [ {'title': 'Parents', 'icon': Icons.groups, 'id': 'l1'}, {'title': 'Siblings', 'icon': Icons.face, 'id': 'l2'}, {'title': 'Pets', 'icon': Icons.pets, 'id': 'l3'} ] },
      { 'level': 'Principiante', 'title': 'Mi Casa', 'desc': 'My House', 'unitNum': 3, 'color_key': 'primary', 'lessons': [ {'title': 'Rooms', 'icon': Icons.home, 'id': 'l1'}, {'title': 'Furniture', 'icon': Icons.chair, 'id': 'l2'}, {'title': 'Location', 'icon': Icons.search, 'id': 'l3'} ] },
      { 'level': 'Intermedio', 'title': 'La Ciudad', 'desc': 'City life', 'unitNum': 4, 'color_key': 'secondary', 'lessons': [ {'title': 'Market', 'icon': Icons.storefront, 'id': 'l1'}, {'title': 'Taxi', 'icon': Icons.local_taxi, 'id': 'l2'}, {'title': 'Emergencia', 'icon': Icons.emergency, 'id': 'l3'} ] },
      { 'level': 'Intermedio', 'title': 'Hobbies', 'desc': 'Pasatiempos', 'unitNum': 5, 'color_key': 'secondary', 'lessons': [ {'title': 'Soccer', 'icon': Icons.sports_soccer, 'id': 'l1'}, {'title': 'Music', 'icon': Icons.music_note, 'id': 'l2'}, {'title': 'Beach', 'icon': Icons.beach_access, 'id': 'l3'} ] },
      { 'level': 'Intermedio', 'title': 'Compras', 'desc': 'Shopping', 'unitNum': 6, 'color_key': 'secondary', 'lessons': [ {'title': 'Clothes', 'icon': Icons.checkroom, 'id': 'l1'}, {'title': 'Colors', 'icon': Icons.palette, 'id': 'l2'}, {'title': 'Paying', 'icon': Icons.credit_card, 'id': 'l3'} ] },
      { 'level': 'Avanzado', 'title': 'Negocios', 'desc': 'Business', 'unitNum': 7, 'color_key': 'accent', 'lessons': [ {'title': 'Office', 'icon': Icons.desk, 'id': 'l1'}, {'title': 'Meeting', 'icon': Icons.meeting_room, 'id': 'l2'}, {'title': 'Contract', 'icon': Icons.gavel, 'id': 'l3'} ] },
      { 'level': 'Avanzado', 'title': 'Noticias', 'desc': 'News', 'unitNum': 8, 'color_key': 'accent', 'lessons': [ {'title': 'Newspaper', 'icon': Icons.newspaper, 'id': 'l1'}, {'title': 'World', 'icon': Icons.public, 'id': 'l2'}, {'title': 'Internet', 'icon': Icons.language, 'id': 'l3'} ] },
      { 'level': 'Avanzado', 'title': 'Medio Ambiente', 'desc': 'Ecology', 'unitNum': 9, 'color_key': 'accent', 'lessons': [ {'title': 'Nature', 'icon': Icons.forest, 'id': 'l1'}, {'title': 'Change', 'icon': Icons.trending_up, 'id': 'l2'}, {'title': 'Future', 'icon': Icons.history_edu, 'id': 'l3'} ] },
    ]
  };

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
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading completed lessons: $e');
      setState(() => _isLoading = false);
    }
  }

  bool _isLessonCompleted(String lessonId) => _completedLessons.contains(lessonId);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF11141C),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = LanguageTheme.getTheme(widget.targetLanguage);
    final List<dynamic> pathItems = [];
    final units = _courseData[widget.targetLanguage] ?? _courseData['de']!;
    
    // Flatten logic
    for (int s = 0; s < units.length; s++) {
      final unit = units[s];
      final String levelName = unit['level'];
      final String unitTitle = unit['title'];
      final String unitDesc = unit['desc'];
      final String colorKey = unit['color_key'];
      final Color sectionColor = colorKey == 'primary' 
          ? theme.primaryColor 
          : (colorKey == 'secondary' ? theme.secondaryColor : theme.accentColor);
      
      final int unitNum = unit['unitNum'];
      final List<Map<String, dynamic>> lessons = unit['lessons'];

      // Unit Header
      pathItems.add({
        'type': 'header', 
        'title': '$levelName - $unitTitle', 
        'desc': unitDesc, 
        'color': sectionColor,
        'unitId': '${widget.targetLanguage}_u$unitNum',
      });

      // Track lesson count within this unit for snake pattern
      int sectionLessonCount = 0;

      for (int l = 0; l < lessons.length; l++) {
        final lessonData = lessons[l];
        final int lessonNum = l + 1; // 1-based index within unit
        
        // Construct Backend-Matching ID: {lang}_u{unit}_l{lesson}
        final String fullLessonId = '${widget.targetLanguage}_u${unitNum}_l${lessonNum}';
        
        // Unlock logic
        bool isUnlocked = false;
        if (unitNum == 1 && lessonNum == 1) {
           isUnlocked = true;
        } else {
           // Find previous lesson ID
           String prevId;
           if (lessonNum > 1) {
              prevId = '${widget.targetLanguage}_u${unitNum}_l${lessonNum - 1}';
           } else {
              // Previous unit's last lesson (Lesson 3)
              prevId = '${widget.targetLanguage}_u${unitNum - 1}_l3'; 
           }
           isUnlocked = _isLessonCompleted(prevId);
        }

        final bool isCompleted = _isLessonCompleted(fullLessonId);
        
        // Snake Pattern
        final positions = [0.0, 0.4, 0.0, -0.4];
        final double x = positions[sectionLessonCount % positions.length];
        sectionLessonCount++;

        pathItems.add({
          'type': 'node', 
          'title': lessonData['title'], 
          'icon': lessonData['icon'], 
          'status': isCompleted ? 'completed' : (isUnlocked ? 'current' : 'locked'),
          'x': x,
          'sectionColor': sectionColor,
          'fullId': fullLessonId,
        });
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
        child: RepaintBoundary(
          child: ListView.builder(
          cacheExtent: 200,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: pathItems.length,
            itemBuilder: (context, index) {
              final item = pathItems[index];

              if (item['type'] == 'header') {
                return SectionHeader(
                  title: item['title'],
                  description: item['desc'],
                  color: item['color'],
                  onTap: () {
                    final intro = IntroLessonData.getIntroLesson(item['unitId']);
                    if (intro != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VocabPreviewScreen(
                            introLesson: intro,
                            themeColor: item['color'],
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Preview coming soon!")),
                      );
                    }
                  },
                );
              } else {
                return _buildPathNodeRow(context, item, index, pathItems);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPathNodeRow(BuildContext context, Map<String, dynamic> item, int index, List<dynamic> allItems) {
    final status = item['status'];
    final bool isLocked = status == 'locked';
    final bool isCompleted = status == 'completed';
    final bool isCurrent = status == 'current';
    final double alignmentX = item['x'] ?? 0.0;

    return Align(
      alignment: Alignment(alignmentX, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: PathNode(
          title: item['title'],
          icon: item['icon'],
          isLocked: isLocked,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          color: item['sectionColor'] ?? const Color(0xFF58CC02),
          onTap: () {
            if (!isLocked) {
              final String lessonId = item['fullId'];
              Lesson? lesson = LessonData.getLessonByLanguage(widget.targetLanguage, lessonId);
              if (lesson == null && LessonData.lessons.containsKey(lessonId)) {
                lesson = LessonData.lessons[lessonId];
              }
              if (lesson != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonScreen(lesson: lesson!),
                  ),
                ).then((_) => _loadCompletedLessons());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lesson '$lessonId' coming soon!")),
                );
              }
            }
          },
        ),
      ),
    );
  }
}



