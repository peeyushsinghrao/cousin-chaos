import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../new_modes/impostor_mode_setup_screen.dart';

class ImpostorResultScreen extends StatefulWidget {
  final int playerCount;
  final List<int> impostorIndices;
  final String secretWord;
  final int? selectedVote;

  const ImpostorResultScreen({
    super.key,
    required this.playerCount,
    required this.impostorIndices,
    required this.secretWord,
    required this.selectedVote,
  });

  @override
  State<ImpostorResultScreen> createState() => _ImpostorResultScreenState();
}

class _ImpostorResultScreenState extends State<ImpostorResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _triggerReveal();
  }

  void _triggerReveal() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _revealController.forward();
        setState(() => _showResult = true);
      }
    });
  }

  bool _impostorWasVotedOut() {
    return widget.selectedVote != null &&
        widget.impostorIndices.contains(widget.selectedVote);
  }

  String _getImpostorName() {
    if (widget.impostorIndices.isNotEmpty) {
      return 'PLAYER ${widget.impostorIndices.first + 1}';
    }
    return 'UNKNOWN';
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  void _playAgain() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ImpostorModeSetupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final won = _impostorWasVotedOut();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Cinematic background with gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (won ? AppColors.primary : AppColors.error)
                        .withOpacity(0.1),
                    AppColors.background,
                    (won ? AppColors.secondary : AppColors.dareRed)
                        .withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Close button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_showResult)
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.5, end: 1.0)
                                  .animate(_revealController),
                              child: Column(
                                children: [
                                  // Result Title
                                  Text(
                                    'THE IMPOSTOR WAS',
                                    style: Theme.of(context)
                                        .textTheme.labelLarge
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          letterSpacing: 2,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Impostor Name
                                  GlassCard(
                                    borderRadius: 20,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 24,
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.error
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            color: AppColors.error,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _getImpostorName(),
                                          style: GoogleFonts.anybody(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.error,
                                            letterSpacing: 2,
                                            shadows: [
                                              Shadow(
                                                color: AppColors.error
                                                    .withOpacity(0.8),
                                                blurRadius: 25,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // Secret Word
                                  Text(
                                    'SECRET WORD',
                                    style: Theme.of(context)
                                        .textTheme.labelLarge
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          letterSpacing: 2,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  GlassCard(
                                    borderRadius: 20,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 24,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.secondary
                                                .withOpacity(0.2),
                                            AppColors.secondary
                                                .withOpacity(0.05),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: AppColors.secondary
                                              .withOpacity(0.4),
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      child: Text(
                                        widget.secretWord.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.anybody(
                                          fontSize: 44,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.secondary,
                                          letterSpacing: 3,
                                          shadows: [
                                            Shadow(
                                              color: AppColors.secondary
                                                  .withOpacity(0.8),
                                              blurRadius: 25,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // Result message
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (won
                                              ? AppColors.primary
                                              : AppColors.error)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: (won
                                                ? AppColors.primary
                                                : AppColors.error)
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      won
                                          ? 'YOU VOTED OUT THE IMPOSTOR! 🎉'
                                          : 'THE IMPOSTOR SURVIVED! 😱',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: won
                                            ? AppColors.primary
                                            : AppColors.error,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Play Again Button
                if (_showResult)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: GestureDetector(
                      onTap: _playAgain,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: -5,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'PLAY AGAIN',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
