import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/pack.dart';

class PromptCard extends StatefulWidget {
  final String playerName;
  final GameCardPrompt prompt;
  final VoidCallback onNext;

  const PromptCard({
    super.key,
    required this.playerName,
    required this.prompt,
    required this.onNext,
  });

  @override
  State<PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<PromptCard> with SingleTickerProviderStateMixin {
  int _timeLeft = 20;
  Timer? _timer;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _startTimer();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
        if (_timeLeft <= 5) HapticFeedback.selectionClick();
      } else {
        _timer?.cancel();
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTruth = widget.prompt.type == 'truth';
    final accentColor = isTruth ? AppColors.truthBlue : AppColors.dareRed;
    final gradient = isTruth ? AppColors.truthGradient : AppColors.dareGradient;
    final emoji = isTruth ? '😇' : '😈';
    final label = isTruth ? 'TRUTH' : 'DARE';
    final screenW = MediaQuery.of(context).size.width;

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Player name
            Text(
              widget.playerName.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            // Card
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: screenW * 0.88,
                  constraints: const BoxConstraints(minHeight: 380),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: accentColor.withAlpha(120 + (_glowController.value * 80).toInt()),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha(30 + (_glowController.value * 30).toInt()),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Prompt Text
                  Text(
                    widget.prompt.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Timer
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          value: _timeLeft / 20,
                          strokeWidth: 4,
                          strokeCap: StrokeCap.round,
                          color: _timeLeft > 5 ? accentColor : AppColors.dareRed,
                          backgroundColor: AppColors.surfaceBright,
                        ),
                      ),
                      Text(
                        '$_timeLeft',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _timeLeft > 5 ? Colors.white : AppColors.dareRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Next Player Button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onNext();
              },
              child: Container(
                width: screenW * 0.7,
                height: 58,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNeon.withAlpha(50),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Next Player →',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
}
