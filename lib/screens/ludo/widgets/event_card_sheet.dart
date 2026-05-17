import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class EventCardSheet extends StatelessWidget {
  final Map<String, dynamic> card;
  final VoidCallback onApply;

  const EventCardSheet({
    super.key,
    required this.card,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isGood = card['isGood'] as bool;
    final accentColor = isGood ? AppColors.neonGreen : AppColors.dareRed;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: accentColor.withAlpha(60)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withAlpha(100)),
            ),
            child: Text(
              isGood ? '✨ GOOD LUCK' : '💥 BAD LUCK',
              style: GoogleFonts.anybody(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            card['emoji'] as String,
            style: const TextStyle(fontSize: 54),
          ),
          const SizedBox(height: 14),
          Text(
            card['title'] as String,
            style: GoogleFonts.anybody(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            card['desc'] as String,
            style: GoogleFonts.sora(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Apply',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
