import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';
import '../../core/theme/app_colors.dart';

class SpeedChallenge {
  final String text;
  final int seconds;

  SpeedChallenge(this.text, this.seconds);
}

class SpeedChallengeScreen extends StatefulWidget {
  const SpeedChallengeScreen({super.key});

  @override
  State<SpeedChallengeScreen> createState() => _SpeedChallengeScreenState();
}

class _SpeedChallengeScreenState extends State<SpeedChallengeScreen> {
  final Random _random = Random();
  late SpeedChallenge _currentChallenge;
  bool _isRunning = false;
  int _timeLeft = 0;
  Timer? _timer;

  final List<SpeedChallenge> _challenges = [
    SpeedChallenge('Name 5 anime', 7),
    SpeedChallenge('Do 15 jumping jacks', 20),
    SpeedChallenge('Name 3 countries starting with A', 5),
    SpeedChallenge('Find a yellow item in the room', 10),
    SpeedChallenge('Say the alphabet backwards from Z to P', 15),
    SpeedChallenge('Touch your toes 10 times', 15),
    SpeedChallenge('Name 4 Marvel movies', 6),
  ];

  @override
  void initState() {
    super.initState();
    _nextChallenge();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextChallenge() {
    _timer?.cancel();
    _currentChallenge = _challenges[_random.nextInt(_challenges.length)];
    _timeLeft = _currentChallenge.seconds;
    _isRunning = false;
    setState(() {});
  }

  void _startTimer() {
    if (_isRunning || _timeLeft <= 0) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _currentChallenge.seconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SPEED CHALLENGE',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.dareRed,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.dareRed.withAlpha(40), AppColors.background],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              '00:${_timeLeft.toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: _timeLeft <= 3 ? AppColors.dareRed : Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.play_arrow_rounded,
                  color: AppColors.neonGreen,
                  onTap: _startTimer,
                  disabled: _isRunning || _timeLeft == 0,
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: Icons.pause_rounded,
                  color: AppColors.neonYellow,
                  onTap: _stopTimer,
                  disabled: !_isRunning,
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: Icons.refresh_rounded,
                  color: AppColors.truthBlue,
                  onTap: _resetTimer,
                  disabled: _isRunning && _timeLeft > 0,
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: FadeInUp(
                  key: ValueKey(_currentChallenge.text),
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.dareRed.withAlpha(80), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dareRed.withAlpha(30),
                          blurRadius: 40,
                          spreadRadius: -10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_rounded, color: AppColors.dareRed, size: 48),
                        const SizedBox(height: 24),
                        Text(
                          _currentChallenge.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                    color: AppColors.dareRed,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dareRed.withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'NEXT CHALLENGE',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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
    );
  }

  Widget _buildControlButton({required IconData icon, required Color color, required VoidCallback onTap, bool disabled = false}) {
    return GestureDetector(
      onTap: disabled ? null : () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: disabled ? AppColors.surfaceLight : color.withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(
            color: disabled ? Colors.transparent : color,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: disabled ? AppColors.textMuted : color,
          size: 32,
        ),
      ),
    );
  }
}
