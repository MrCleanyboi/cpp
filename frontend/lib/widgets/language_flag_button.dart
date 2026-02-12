import 'package:flutter/material.dart';

class LanguageFlagButton extends StatelessWidget {
  final String languageCode;
  final VoidCallback onTap;

  const LanguageFlagButton({
    super.key,
    required this.languageCode,
    required this.onTap,
  });

  String _getFlagEmoji(String code) {
    switch (code.toLowerCase()) {
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'es':
        return '🇪🇸';
      default:
        return '🌐';
    }
  }

  String _getLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'es':
        return 'Spanish';
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlagEmoji(languageCode),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 6),
            Text(
              languageCode.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
