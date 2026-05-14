import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../core/theme/app_colors.dart';
import '../../core/constants/impostor_categories_data.dart';
import '../../core/widgets/glass_card.dart';
import '../new_modes/impostor_voting_screen.dart';

class ImpostorPlayerRevealScreen extends StatefulWidget {
  final String category;
  final int playerCount;
  final int impostorCount;
  final bool timeLimitEnabled;
  final int timeLimitSeconds;

  const ImpostorPlayerRevealScreen({
    super.key,
    required this.category,
    required this.playerCount,
    required this.impostorCount,
    required this.timeLimitEnabled,
    required this.timeLimitSeconds,
  });

  @override
  State<ImpostorPlayerRevealScreen> createState() =>
      _ImpostorPlayerRevealScreenState();
}

class _ImpostorPlayerRevealScreenState
    extends State<ImpostorPlayerRevealScreen> with TickerProviderStateMixin {
  late List<int> _impostorIndices;
  late String _secretWord;
  int _currentPlayerIndex = 0;
  bool _showReveal = false;
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initializeGame();
  }

  void _initializeGame() {
    // Generate random impostor indices
    final random = Random();
    _impostorIndices = [];
    while (_impostorIndices.length < widget.impostorCount) {
      final index = random.nextInt(widget.playerCount);
      if (!_impostorIndices.contains(index)) {
        _impostorIndices.add(index);
      }
    }

    // Get random secret word
    final words = ImpostorCategoriesData.getCategory(widget.category);
    _secretWord = words[random.nextInt(words.length)];
  }

  void _revealCard() {
    if (!_showReveal) {
      HapticFeedback.vibrate();
      _revealController.forward();
      setState(() => _showReveal = true);
    }
  }

  void _nextPlayer() {
    HapticFeedback.lightImpact();
    if (_currentPlayerIndex < widget.playerCount - 1) {
      _revealController.reset();
      setState(() {
        _currentPlayerIndex++;
        _showReveal = false;
      });
    } else {
      // All players have seen - go to voting
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ImpostorVotingScreen(
            playerCount: widget.playerCount,
            impostorIndices: _impostorIndices,
            secretWord: _secretWord,
            timeLimitEnabled: widget.timeLimitEnabled,
            timeLimitSeconds: widget.timeLimitSeconds,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  bool _isCurrentPlayerImpostor() {
    return _impostorIndices.contains(_currentPlayerIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background with cinematic effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.background,
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header with progress
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Player ${_currentPlayerIndex + 1}/${widget.playerCount}',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      letterSpacing: 1,
                                    ),
                          ),
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
                      const SizedBox(height: 12),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentPlayerIndex + 1) / widget.playerCount,
                          minHeight: 4,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Main Content Area
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_showReveal) ...[
                            // Before reveal
                            GlassCard(
                              borderRadius: 24,
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'PASS THE DEVICE',
                                    style: GoogleFonts.anybody(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          color: AppColors.primary
                                              .withOpacity(0.6),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.secondary
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'Player ${_currentPlayerIndex + 1}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  GestureDetector(
                                    onTap: _revealCard,
                                    child: Container(
                                      padding: const EdgeInsets.all(60),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.tertiary.withOpacity(0.3),
                                            AppColors.tertiary
                                                .withOpacity(0.1),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: AppColors.tertiary
                                              .withOpacity(0.5),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.tertiary
                                                .withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: -5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.touch_app,
                                            color: AppColors.tertiary,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'TAP TO REVEAL',
                                            style: Theme.of(context)
                                                .textTheme.labelMedium
                                                ?.copyWith(
                                                  color: AppColors.tertiary,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 1,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // After reveal
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.5, end: 1.0)
                                  .animate(_revealController),
                              child: GlassCard(
                                borderRadius: 24,
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Role indicator
                                    if (_isCurrentPlayerImpostor()) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.error.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppColors.error
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          'YOU ARE THE IMPOSTOR',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.error,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      Text(
                                        'Find the SECRET WORD\nduring the game!',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme.bodyLarge
                                            ?.copyWith(
                                              color:
                                                  AppColors.onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    ] else ...[
                                      Text(
                                        'YOUR ROLE',
                                        style: Theme.of(context)
                                            .textTheme.labelSmall
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              letterSpacing: 1,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'CIVILIAN',
                                        style: GoogleFonts.anybody(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary,
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.6),
                                              blurRadius: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      Text(
                                        'THE SECRET WORD IS',
                                        style: Theme.of(context)
                                            .textTheme.labelSmall
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              letterSpacing: 1,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.secondary.withOpacity(
                                            0.2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppColors.secondary
                                                .withOpacity(0.5),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.secondary
                                                  .withOpacity(0.3),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          _secretWord.toUpperCase(),
                                          style: GoogleFonts.anybody(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.secondary,
                                            letterSpacing: 2,
                                            shadows: [
                                              Shadow(
                                                color: AppColors.secondary
                                                    .withOpacity(0.8),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom Actions
                if (_showReveal)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: GestureDetector(
                      onTap: _nextPlayer,
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
                            _currentPlayerIndex < widget.playerCount - 1
                                ? 'NEXT PLAYER'
                                : 'START VOTING',
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
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
