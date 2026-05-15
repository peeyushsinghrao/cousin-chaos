import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/leave_game_dialog.dart';

class LaughAttackScreen extends StatefulWidget {
  const LaughAttackScreen({super.key});

  @override
  State<LaughAttackScreen> createState() => _LaughAttackScreenState();
}

class _LaughAttackScreenState extends State<LaughAttackScreen> {
  final Random _random = Random();
  String _currentChallenge = '';
  bool _someoneLaughed = false;

  final List<String> _challenges = [
    'Stare into the soul of the person to your left without blinking until someone laughs',
    'Talk in a British accent and explain why beans on toast is a delicacy',
    'Do your best impression of a dying mosquito',
    'Act like a T-Rex trying to make a bed',
    'Pretend you are a malfunctioning robot trying to say "I love you"',
    'Make the most absurd facial expression and hold it',
    'Read the last text message you received but make it sound like a dramatic movie trailer',
  ];

  @override
  void initState() {
    super.initState();
    _nextChallenge();
  }

  void _nextChallenge() {
    setState(() {
      _currentChallenge = _challenges[_random.nextInt(_challenges.length)];
      _someoneLaughed = false;
    });
  }

  void _handleLaugh() {
    HapticFeedback.vibrate();
    setState(() {
      _someoneLaughed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final should = await showLeaveGameDialog(context);
        if (should == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'LAUGH ATTACK',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonCyan,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              _someoneLaughed ? AppColors.dareRed.withAlpha(50) : AppColors.neonCyan.withAlpha(40),
              AppColors.background
            ],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _someoneLaughed ? _buildLoserScreen() : _buildChallengeScreen(),
              ),
            ),
            if (!_someoneLaughed)
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: _handleLaugh,
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.dareRed,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dareRed.withAlpha(60),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'SOMEONE LAUGHED! 😆',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_someoneLaughed)
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _nextChallenge();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withAlpha(60),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'NEXT ROUND',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
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

  Widget _buildChallengeScreen() {
    return FadeInUp(
      key: ValueKey(_currentChallenge),
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.neonCyan.withAlpha(80), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withAlpha(30),
              blurRadius: 40,
              spreadRadius: -10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_emotions_rounded, color: AppColors.neonCyan, size: 64),
            const SizedBox(height: 32),
            Text(
              _currentChallenge,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Goal: Make them laugh.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neonCyan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoserScreen() {
    return ZoomIn(
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_very_dissatisfied_rounded, color: AppColors.dareRed, size: 100),
          const SizedBox(height: 24),
          Text(
            'WE HAVE A LOSER!',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.dareRed,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Whoever laughed has to drink\nor do a punishment!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
