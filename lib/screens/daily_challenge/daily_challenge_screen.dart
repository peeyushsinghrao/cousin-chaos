import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/daily_challenges.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late final String _challenge;
  int _streak = 4;

  @override
  void initState() {
    super.initState();
    final index = DateTime.now().difference(DateTime(2024, 1, 1)).inDays % dailyChallenges.length;
    _challenge = dailyChallenges[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Challenge',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 34,
                  )),
              const SizedBox(height: 8),
              Text('Keep the streak burning bright',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  )),
              const SizedBox(height: 24),
              GlassCard(
                borderRadius: 30,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('DAILY DARE',
                          style: GoogleFonts.sora(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          )),
                    ),
                    const SizedBox(height: 20),
                    Text(_challenge,
                        style: GoogleFonts.anybody(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 20),
                    Row(
                      children: List.generate(
                        7,
                        (index) => Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _streak ? AppColors.gold : AppColors.surface.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('${_streak}-DAY STREAK',
                        style: GoogleFonts.sora(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: AppColors.gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Complete this challenge and keep your streak alive. Tap when done to mark it complete.',
                        style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _streak = min(7, _streak + 1);
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.35),
                          blurRadius: 24,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('COMPLETE CHALLENGE',
                          style: GoogleFonts.sora(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          )),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('WEEKLY STREAK',
                  style: GoogleFonts.sora(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  7,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 10,
                      decoration: BoxDecoration(
                        color: index < _streak ? AppColors.gold : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
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
}
