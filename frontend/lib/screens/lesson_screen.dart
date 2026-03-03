import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson_model.dart';
import '../services/gamification_service.dart';
import '../services/auth_service.dart';
import '../widgets/xp_animation_widget.dart';
import '../widgets/achievement_unlock_dialog.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentIndex = 0;
  double _progress = 0.0;
  bool _isAnswerChecked = false;
  bool _isAnswerCorrect = false;
  String? _userAnswer; // For MultipleChoice; TranslateExercise uses _answerController
  final TextEditingController _answerController = TextEditingController();
  
  // Feedback message
  String _feedbackMessage = "";
  
  // Gamification
  final GamificationService _gamificationService = GamificationService();
  final AuthService _authService = AuthService();
  int _mistakesCount = 0;
  DateTime? _lessonStartTime;
  String? _userId;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final userId = await _authService.getUserId();
    if (mounted) setState(() => _userId = userId);
  }

  @override
  void initState() {
    super.initState();
    _lessonStartTime = DateTime.now();
    _loadUserId();
  }

  void _checkAnswer() {
    final currentExercise = widget.lesson.exercises[_currentIndex];

    bool correct = false;

    if (currentExercise is MultipleChoiceExercise) {
      correct = _userAnswer == currentExercise.answer;
    } else if (currentExercise is TranslateExercise) {
      // Read from controller — no setState on every keystroke needed
      final typed = _answerController.text.trim().toLowerCase();
      correct = typed == currentExercise.answer.toLowerCase();
    }

    setState(() {
      _isAnswerChecked = true;
      _isAnswerCorrect = correct;
      
      // Get answer based on exercise type
      String correctAnswer = '';
      if (currentExercise is MultipleChoiceExercise) {
        correctAnswer = currentExercise.answer;
      } else if (currentExercise is TranslateExercise) {
        correctAnswer = currentExercise.answer;
      }
      
      _feedbackMessage = correct ? "Great job!" : "Correct answer: $correctAnswer";
      
      if (correct) {
        // Increment progress immediately only if correct
        _progress = (_currentIndex + 1) / widget.lesson.exercises.length;
      } else {
        // Wrong answer - lose a heart
        _mistakesCount++;
        _loseHeart();
      }
    });
  }

  
  Future<void> _loseHeart() async {
    if (_userId == null) return;
    try {
      await _gamificationService.loseHeart(_userId!);
    } catch (e) {
      print('Error losing heart: $e');
    }
  }
  
  Future<void> _completeLesson() async {
    if (_userId == null) return;
    try {
      final timeSpent = DateTime.now().difference(_lessonStartTime!).inMinutes;
      
      final result = await _gamificationService.completeLesson(
        userId: _userId!,
        lessonId: widget.lesson.id, // Pass lesson ID for per-language tracking
        perfect: _mistakesCount == 0,
        timeSpentMinutes: timeSpent,
      );
      
      // Check for achievements
      if (result['achievements_earned'] != null && 
          (result['achievements_earned'] as List).isNotEmpty) {
        // Show first achievement
        final firstAchievement = (result['achievements_earned'] as List)[0];
        if (mounted) {
          showAchievementUnlock(context, firstAchievement);
        }
      }
      
      // Show XP animation
      if (mounted) {
        showXPAnimation(
          context,
          xpGained: result['xp_gained'] ?? 10,
          showLevelUp: result['level_up'] ?? false,
          newLevel: result['new_level'],
        );
      }
      
      // Wait a moment then show completion dialog
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        _showCompletionDialog(result);
      }
    } catch (e) {
      print('Error completing lesson: $e');
      // Show completion dialog anyway
      if (mounted) {
        _showCompletionDialog({});
      }
    }
  }
  
  void _continue() {
    if (_currentIndex < widget.lesson.exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswerChecked = false;
        _isAnswerCorrect = false;
        _userAnswer = null;
        _feedbackMessage = "";
      });
      // Clear the text field for the next question without triggering setState
      _answerController.clear();
    } else {
      _completeLesson();
    }
  }

  void _showCompletionDialog(Map<String, dynamic> result) {
    final xpGained = result['xp_gained'] ?? 10;
    final perfect = result['perfect'] ?? false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 80),
            const SizedBox(height: 16),
            Text(
              "Lesson Complete!",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (perfect)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PERFECT! NO MISTAKES',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'You earned $xpGained XP',
              style: GoogleFonts.outfit(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close Lesson Screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.lesson.exercises[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(),
        ),
        title: LinearProgressIndicator(
          value: _progress + ( (_isAnswerChecked && _isAnswerCorrect) ? 0 : 0), // Already updated in check?
          backgroundColor: Colors.white10,
          color: const Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "New Word", 
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentExercise.question,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold, // Fixed weight
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Placeholder for Exercise Widget
                  _buildExerciseContent(currentExercise),
                ],
              ),
            ),
          ),
          
          // Bottom Action Area
          _buildBottomArea(),
        ],
      ),
    );
  }
  
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Quit Lesson?"),
        content: const Text("You will lose your progress."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Stay")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            }, 
            child: const Text("Quit", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent(LessonExercise exercise) {
    // This will be replaced by specific widgets
    if (exercise is MultipleChoiceExercise) {
      return Column(
        children: exercise.options.map((opt) {
          final isSelected = _userAnswer == opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: _isAnswerChecked ? null : () {
                setState(() => _userAnswer = opt);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.2) : const Color(0xFF1E212B),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white10,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      opt, 
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Color(0xFF6C63FF)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    } 
    else if (exercise is TranslateExercise) {
       // Determine hint based on the question context
       String hintText = "Type your answer...";
       if (exercise.question.contains("French")) {
         hintText = "Type in French...";
       } else if (exercise.question.contains("German")) {
         hintText = "Type in German...";
       } else if (exercise.question.contains("Spanish")) {
         hintText = "Type in Spanish...";
       }
       
      return TextField(
         enabled: !_isAnswerChecked,
         controller: _answerController,
         // No onChanged setState — controller is read on Check press only
         style: const TextStyle(color: Colors.white),
         decoration: InputDecoration(
           hintText: hintText,
           border: const OutlineInputBorder(),
         ),
       );
    }
    return const SizedBox();
  }

  Widget _buildBottomArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isAnswerChecked 
            ? (_isAnswerCorrect ? const Color(0xFF1E212B) : const Color(0xFF2B1E1E))
            : const Color(0xFF0F1117),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isAnswerChecked) ...[
            Row(
              children: [
                 Icon(
                   _isAnswerCorrect ? Icons.check_circle : Icons.error_rounded,
                   color: _isAnswerCorrect ? Colors.greenAccent : Colors.redAccent,
                   size: 32,
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         _isAnswerCorrect ? "Correct!" : "Incorrect",
                         style: TextStyle(
                           color: _isAnswerCorrect ? Colors.greenAccent : Colors.redAccent,
                           fontWeight: FontWeight.bold,
                           fontSize: 18,
                         ),
                       ),
                       if (!_isAnswerCorrect && _feedbackMessage.isNotEmpty)
                          Text(
                            _feedbackMessage,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                     ],
                   ),
                 ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          
          ElevatedButton(
            onPressed: _isAnswerChecked
                ? _continue
                : () {
                    // For translate exercises, read controller; for MCQ, use _userAnswer
                    final currentExercise = widget.lesson.exercises[_currentIndex];
                    final hasAnswer = currentExercise is TranslateExercise
                        ? _answerController.text.trim().isNotEmpty
                        : _userAnswer != null;
                    if (hasAnswer) _checkAnswer();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAnswerChecked 
                  ? (_isAnswerCorrect ? Colors.green : Colors.redAccent) // Status color
                  : const Color(0xFF6C63FF),
              disabledBackgroundColor: Colors.white10,
            ),
            child: Text(_isAnswerChecked ? "Continue" : "Check"),
          ),
        ],
      ),
    );
  }
}
