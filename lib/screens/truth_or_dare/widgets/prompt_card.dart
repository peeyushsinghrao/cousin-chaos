import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/pack.dart';
import '../../../services/preferences_service.dart';
import '../../../services/sound_service.dart';

class PromptCard extends StatefulWidget {
  final String playerName;
  final GameCardPrompt prompt;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final int skipTokens;

  const PromptCard({
    super.key,
    required this.playerName,
    required this.prompt,
    required this.onNext,
    this.onSkip,
    this.skipTokens = 0,
  });

  @override
  State<PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<PromptCard>
    with SingleTickerProviderStateMixin {
  int _timeLeft = 20;
  Timer? _timer;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    final soundEnabled = context.read<PreferencesService>().soundEnabled;
    SoundService.instance.play(SoundEvent.cardReveal, soundEnabled: soundEnabled);
    _startTimer();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
        if (_timeLeft <= 5) {
          HapticFeedback.selectionClick();
          final soundEnabled = context.read<PreferencesService>().soundEnabled;
          SoundService.instance
              .play(SoundEvent.countdown, soundEnabled: soundEnabled);
        }
      } else {
        _timer?.cancel();
        HapticFeedback.heavyImpact();
        final soundEnabled = context.read<PreferencesService>().soundEnabled;
        SoundService.instance
            .play(SoundEvent.timerEnd, soundEnabled: soundEnabled);
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
    final label = isTruth ? 'TRUTH' : 'DARE';
    final screenW = MediaQuery.of(context).size.width;

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                      color: accentColor.withAlpha(
                          120 + (_glowController.value * 80).toInt()),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha(
                            30 + (_glowController.value * 30).toInt()),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTruth
                              ? Icons.lightbulb_rounded
                              : Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
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
                          color: _timeLeft > 5
                              ? accentColor
                              : AppColors.dareRed,
                          backgroundColor: AppColors.surfaceBright,
                        ),
                      ),
                      Text(
                        '$_timeLeft',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _timeLeft > 5
                              ? Colors.white
                              : AppColors.dareRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Skip Tax button
            if (widget.onSkip != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final soundEnabled =
                      context.read<PreferencesService>().soundEnabled;
                  SoundService.instance
                      .play(SoundEvent.tap, soundEnabled: soundEnabled);
                  widget.onSkip!();
                },
                child: Container(
                  width: screenW * 0.75,
                  height: 44,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.neonOrange.withAlpha(100), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.skip_next_rounded,
                          color: AppColors.neonOrange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Skip (+1 dare token) ${widget.skipTokens}/3',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neonOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Next Player Button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                final soundEnabled =
                    context.read<PreferencesService>().soundEnabled;
                SoundService.instance
                    .play(SoundEvent.nextPlayer, soundEnabled: soundEnabled);
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
                    'Next Player',
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
