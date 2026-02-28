import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson_model.dart';
import '../services/gamification_service.dart';
import '../services/auth_service.dart';
import '../widgets/xp_animation_widget.dart';

/// Full-screen flashcard experience that teaches the key vocab for a unit
/// before the user starts the actual quiz lessons.
class VocabPreviewScreen extends StatefulWidget {
  final IntroLesson introLesson;
  final Color themeColor;

  const VocabPreviewScreen({
    super.key,
    required this.introLesson,
    required this.themeColor,
  });

  @override
  State<VocabPreviewScreen> createState() => _VocabPreviewScreenState();
}

class _VocabPreviewScreenState extends State<VocabPreviewScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isComplete = false;

  late AnimationController _cardController;
  late Animation<double> _cardScaleAnim;
  late Animation<double> _cardOpacityAnim;

  final GamificationService _gamificationService = GamificationService();
  final AuthService _authService = AuthService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _setupCardAnimation();
  }

  Future<void> _loadUser() async {
    _userId = await _authService.getUserId();
  }

  void _setupCardAnimation() {
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cardScaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
    );
    _cardController.forward();
  }

  void _nextCard() {
    final total = widget.introLesson.vocabItems.length;
    if (_currentIndex < total - 1) {
      _cardController.reset();
      setState(() => _currentIndex++);
      _cardController.forward();
    } else {
      // All cards seen — award XP and show complete screen
      _finishPreview();
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      _cardController.reset();
      setState(() => _currentIndex--);
      _cardController.forward();
    }
  }

  Future<void> _finishPreview() async {
    setState(() => _isComplete = true);

    // Award +5 XP for completing the preview
    if (_userId != null) {
      try {
        await _gamificationService.awardXP(
            userId: _userId!, xpAmount: 5, reason: 'vocab_preview');
      } catch (_) {}
    }

    // Show the XP animation
    if (mounted) {
      showXPAnimation(context, xpGained: 5);
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: Text(
          widget.introLesson.title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F1117),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(),
        ),
      ),
      body: _isComplete ? _buildCompleteScreen() : _buildCardScreen(),
    );
  }

  // ─────────────────────────────────────────────
  //  FLASHCARD SCREEN
  // ─────────────────────────────────────────────
  Widget _buildCardScreen() {
    final items = widget.introLesson.vocabItems;
    final item = items[_currentIndex];
    final total = items.length;
    final progress = (_currentIndex + 1) / total;

    return SafeArea(
      child: Column(
        children: [
          // ── Progress bar ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentIndex + 1} of $total',
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Vocab Card ────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: AnimatedBuilder(
                animation: _cardController,
                builder: (context, child) => Transform.scale(
                  scale: _cardScaleAnim.value,
                  child: Opacity(
                    opacity: _cardOpacityAnim.value,
                    child: child,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E212B),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.08),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Book icon header
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Main word (target language)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          item.word,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Meaning (English)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '"${item.meaning}"',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            color: Colors.amber,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          children: [
                            Expanded(
                                child: Divider(color: Colors.white.withOpacity(0.08))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Example',
                                style: GoogleFonts.outfit(
                                  color: Colors.white30,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(color: Colors.white.withOpacity(0.08))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Example sentence
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          item.example,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Example translation
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          item.exampleTranslation,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.white38,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Nav Buttons ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Row(
              children: [
                // Back button (hidden on first card)
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _prevCard,
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white54),
                      label: Text(
                        'Back',
                        style: GoogleFonts.outfit(color: Colors.white54),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white12),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),

                // Got it button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _nextCard,
                    icon: Icon(
                      _currentIndex < widget.introLesson.vocabItems.length - 1
                          ? Icons.arrow_forward_rounded
                          : Icons.check_circle_rounded,
                      color: Colors.black87,
                    ),
                    label: Text(
                      _currentIndex < widget.introLesson.vocabItems.length - 1
                          ? 'Got it!'
                          : 'Finish Preview',
                      style: GoogleFonts.outfit(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: Colors.amber.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  COMPLETION SCREEN
  // ─────────────────────────────────────────────
  Widget _buildCompleteScreen() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Preview Complete!',
                style: GoogleFonts.outfit(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'You\'ve learned ${widget.introLesson.vocabItems.length} words and phrases.\nNow go crush those lessons!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white54,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),

              // XP Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  '✨ +5 XP  Earned',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // CTA Button
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.rocket_launch_rounded,
                    color: Colors.black87),
                label: Text(
                  "Let's Go!",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 12,
                  shadowColor: Colors.amber.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  EXIT CONFIRMATION
  // ─────────────────────────────────────────────
  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Leave Preview?',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You can always come back and review these words.',
          style: GoogleFonts.outfit(color: Colors.white60),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Stay',
                  style: GoogleFonts.outfit(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Leave',
                style: GoogleFonts.outfit(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
