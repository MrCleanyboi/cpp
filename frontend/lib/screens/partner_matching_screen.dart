import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'partner_waiting_screen.dart';
import '../services/matching_api_service.dart';

// ─── Styles ──────────────────────────────────────────────────────────────────
final _exchangeTitleStyle = GoogleFonts.outfit(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _exchangeSubStyle = GoogleFonts.outfit(
  fontSize: 14,
  color: Colors.white54,
);

final _dropdownStyle = GoogleFonts.outfit(
  fontSize: 16,
  color: Colors.white,
  fontWeight: FontWeight.w500,
);

final _levelBtnStyle = GoogleFonts.outfit(
  fontSize: 13,
  fontWeight: FontWeight.w600,
);

final _modeTextStyle = GoogleFonts.outfit(
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

final _findPartnerBtnStyle = GoogleFonts.outfit(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _statsTitleStyle = GoogleFonts.outfit(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _sectionTitleStyle = GoogleFonts.outfit(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _statRowStyle = GoogleFonts.outfit(
  fontSize: 14,
  color: Colors.white70,
);

class PartnerMatchingScreen extends StatefulWidget {
  const PartnerMatchingScreen({super.key});

  @override
  State<PartnerMatchingScreen> createState() => _PartnerMatchingScreenState();
}

class _PartnerMatchingScreenState extends State<PartnerMatchingScreen> {
  String selectedLanguage = 'Spanish';
  String selectedLevel = 'Intermediate';
  String practiceMode = 'Conversation';

  Map<String, dynamic>? userStats;
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await matchingApiService.getUserStats();
      if (mounted) {
        setState(() {
          userStats = stats;
          isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingStats = false);
      }
    }
  }
  final List<String> languages = [
    'Spanish',
    'French',
    'German',
  ];

  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> modes = ['Conversation', 'Tutoring', 'Casual Chat'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Color(0xFF6C63FF),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Language Exchange',
                          style: _exchangeTitleStyle,
                        ),
                        Text(
                          'Practice with native speakers',
                          style: _exchangeSubStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Practice Language Selection
              _buildSectionTitle('Practice Language'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E212B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
                    dropdownColor: const Color(0xFF1E212B),
                    style: _dropdownStyle,
                    items: languages.map((String language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLanguage = newValue!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Proficiency Level
              _buildSectionTitle('Your Level'),
              const SizedBox(height: 12),
              Row(
                children: levels.map((level) {
                  final isSelected = selectedLevel == level;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedLevel = level),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFF1E212B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6C63FF)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          level,
                          style: _levelBtnStyle.copyWith(
                            color: isSelected ? Colors.white : Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Practice Mode
              _buildSectionTitle('Practice Mode'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: modes.map((mode) {
                  final isSelected = practiceMode == mode;
                  return GestureDetector(
                    onTap: () => setState(() => practiceMode = mode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF).withOpacity(0.2)
                            : const Color(0xFF1E212B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          Text(
                            mode,
                            style: _modeTextStyle.copyWith(
                              color: isSelected ? const Color(0xFF6C63FF) : Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),


              // Find Partner Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _findPartner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_rounded, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Find Practice Partner',
                        style: _findPartnerBtnStyle,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E212B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Stats',
                      style: _statsTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    if (isLoadingStats)
                      const Center(child: CircularProgressIndicator())
                    else if (userStats == null)
                      _buildStatRow(Icons.error_outline, 'Could not load stats', Colors.redAccent)
                    else ...[
                      _buildStatRow(Icons.check_circle_outline, '${userStats!['total_matches']} total matches', Colors.greenAccent),
                      const SizedBox(height: 12),
                      _buildStatRow(Icons.timer_outlined, '${userStats!['total_duration_hours']} hours practiced', const Color(0xFF00E5FF)),
                      const SizedBox(height: 12),
                      _buildStatRow(Icons.message_outlined, '${userStats!['total_messages']} messages sent', const Color(0xFF6C63FF)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: _sectionTitleStyle,
    );
  }

  Widget _buildStatRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          text,
          style: _statRowStyle,
        ),
      ],
    );
  }

  Future<void> _findPartner() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Call real API
      final result = await matchingApiService.joinQueue(
        targetLanguage: selectedLanguage,
        proficiencyLevel: selectedLevel,
        practiceMode: practiceMode.toLowerCase().replaceAll(' ', '_'),
      );
      
      // Close loading
      if (mounted) Navigator.pop(context);
      
      // Navigate to waiting screen with real data
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PartnerWaitingScreen(
              targetLanguage: selectedLanguage,
              practiceMode: practiceMode,
              queueStatus: result, // Pass API result
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading if still showing
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to find partner: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

  }
}
