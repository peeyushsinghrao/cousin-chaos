import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../core/theme/app_colors.dart';

class DisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccept;
  
  const DisclaimerDialog({super.key, required this.onAccept});

  static Future<void> show(BuildContext context, VoidCallback onAccept) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(220),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return DisclaimerDialog(onAccept: onAccept);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A24), // Dark purple/black
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.neonPink.withAlpha(50), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonPink.withAlpha(40),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeInDown(
                child: Text(
                  'DISCLAIMER',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: _buildCard(
                  icon: Icons.health_and_safety_rounded,
                  color: AppColors.neonGreen,
                  title: 'Play safe',
                  description: 'Safety comes first! The game should be fun for all players involved. Make sure no one gets hurt physically or emotionally.',
                ),
              ),
              
              const SizedBox(height: 16),
              
              FadeInRight(
                delay: const Duration(milliseconds: 400),
                child: _buildCard(
                  icon: Icons.privacy_tip_rounded,
                  color: AppColors.neonCyan,
                  title: 'Respect privacy',
                  description: "Don't spill the beans! Remember that what happens in the game, stays in the game.",
                ),
              ),
              
              const SizedBox(height: 40),
              
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(context);
                    onAccept();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.neonPink,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPink.withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'OK',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white70,
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
