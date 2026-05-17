import 'dart:math';
import 'package:cousin_chaos/core/icons.dart';
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
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isRevealed = false;
  bool _swipeHintShown = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _reveal() {
    if (_isRevealed) return;
    _flipController.forward();
    final soundEnabled = context.read<PreferencesService>().soundEnabled;
    SoundService.instance
        .play(SoundEvent.cardFlip, soundEnabled: soundEnabled);
    setState(() => _isRevealed = true);
    HapticFeedback.mediumImpact();
  }

  void _onNext() {
    final soundEnabled = context.read<PreferencesService>().soundEnabled;
    SoundService.instance
        .play(SoundEvent.nextPlayer, soundEnabled: soundEnabled);
    HapticFeedback.mediumImpact();
    setState(() {
      _isRevealed = false;
      _swipeHintShown = true;
    });
    _flipController.reverse();
    widget.onNext();
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
            GestureDetector(
              onTap: _reveal,
              onHorizontalDragEnd: (details) {
                if (_isRevealed &&
                    (details.primaryVelocity ?? 0) < -300) {
                  _onNext();
                }
              },
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value;
                  final showFront = angle < pi / 2;
                  Widget face = showFront
                      ? _buildCardFront(accentColor, gradient, label, screenW)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: _buildCardBack(
                              accentColor, gradient, label, screenW),
                        );
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: face,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSlide(
              offset: _isRevealed
                  ? Offset.zero
                  : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _isRevealed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_isRevealed,
                  child: Column(
                    children: [
                      if (widget.onSkip != null)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final soundEnabled = context
                                .read<PreferencesService>()
                                .soundEnabled;
                            SoundService.instance.play(SoundEvent.tap,
                                soundEnabled: soundEnabled);
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
                                  color:
                                      AppColors.neonOrange.withAlpha(100),
                                  width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.skip_next_rounded,
                                    color: AppColors.neonOrange, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Skip  ${widget.skipTokens}/3',
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
                      GestureDetector(
                        onTap: _onNext,
                        child: Container(
                          width: screenW * 0.7,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primaryNeon.withAlpha(50),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'NEXT',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.arrowRight,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                      if (!_swipeHintShown)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '← swipe left to advance',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(
      Color accentColor, Gradient gradient, String label, double screenW) {
    return Container(
      width: screenW * 0.88,
      constraints: const BoxConstraints(minHeight: 320),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: accentColor.withAlpha(80), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(30),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  label == 'TRUTH'
                      ? Icons.lightbulb_rounded
                      : Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            widget.playerName,
            style: GoogleFonts.sora(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (_, v, child) =>
                Opacity(opacity: v, child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.primary.withAlpha(100)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.eye,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'TAP TO REVEAL',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(
      Color accentColor, Gradient gradient, String label, double screenW) {
    return Container(
      width: screenW * 0.88,
      constraints: const BoxConstraints(minHeight: 320),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: accentColor.withAlpha(150), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(50),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  label == 'TRUTH'
                      ? Icons.lightbulb_rounded
                      : Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            widget.prompt.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
