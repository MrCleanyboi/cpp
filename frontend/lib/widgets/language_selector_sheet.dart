import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

// ─── Styles ──────────────────────────────────────────────────────────────────
final _sheetTitleStyle = GoogleFonts.outfit(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _sheetDescStyle = GoogleFonts.outfit(
  fontSize: 14,
  color: Colors.white60,
);

final _langNameStyle = GoogleFonts.outfit(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final _langNativeStyle = GoogleFonts.outfit(
  fontSize: 14,
  color: Colors.white60,
);

class LanguageSelectorSheet extends StatefulWidget {
  final String currentLanguage;
  final Function(String) onLanguageSelected;

  const LanguageSelectorSheet({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageSelectorSheet> createState() => _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends State<LanguageSelectorSheet> {
  bool _isUpdating = false;

  final List<Map<String, String>> _languages = [
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷', 'native': 'Français'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪', 'native': 'Deutsch'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸', 'native': 'Español'},
  ];

  Future<void> _selectLanguage(String langCode) async {
    if (langCode == widget.currentLanguage) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isUpdating = true);

    try {
      // Update profile on backend
      await AuthService.updateProfile({'target_language': langCode});
      
      if (mounted) {
        Navigator.pop(context);
        widget.onLanguageSelected(langCode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error switching language: $e')),
        );
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E212B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose Language',
                style: _sheetTitleStyle,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your progress is saved for each language',
            style: _sheetDescStyle,
          ),
          const SizedBox(height: 24),

          // Language Options
          ..._languages.map((lang) {
            final isSelected = lang['code'] == widget.currentLanguage;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: _isUpdating ? null : () => _selectLanguage(lang['code']!),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6C63FF).withOpacity(0.2)
                        : const Color(0xFF11141C),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang['flag']!,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang['name']!,
                              style: _langNameStyle,
                            ),
                            Text(
                              lang['native']!,
                              style: _langNativeStyle,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF6C63FF),
                          size: 28,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

void showLanguageSelector(
  BuildContext context,
  String currentLanguage,
  Function(String) onLanguageSelected,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => LanguageSelectorSheet(
      currentLanguage: currentLanguage,
      onLanguageSelected: onLanguageSelected,
    ),
  );
}
