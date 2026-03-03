import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Styles ──────────────────────────────────────────────────────────────────
final _headerLabelStyle = GoogleFonts.outfit(
  color: Colors.white.withOpacity(0.9),
  fontSize: 12,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.2,
);

final _headerDescStyle = GoogleFonts.outfit(
  color: Colors.white,
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

class SectionHeader extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: _headerLabelStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: _headerDescStyle,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 24,
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
}
