import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/player_manager.dart';
import 'game_engine_screen.dart';

enum GameMode { spinTheWheel, oneAtATime }

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  GameMode _selectedMode = GameMode.spinTheWheel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      FadeInDown(
                        child: Text(
                          'Who is\nplaying? 👥',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPlayerList(context),
                      const SizedBox(height: 32),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'How are you playing?',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeInDown(
                        delay: const Duration(milliseconds: 250),
                        child: Text(
                          'Choose a game mode',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGameModeCards(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildStartButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          Text(
            'STEP 2 OF 3',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPlayerList(BuildContext context) {
    return Consumer<PlayerManager>(
      builder: (context, playerManager, _) {
        final players = playerManager.players;
        return Column(
          children: [
            ...List.generate(players.length, (index) {
              final player = players[index];
              return FadeInUp(
                delay: Duration(milliseconds: 50 * index),
                duration: const Duration(milliseconds: 400),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBright, width: 1),
                  ),
                  child: Row(
                    children: [
                      // Player number badge
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: player.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Player ${index + 1}',
                            hintStyle: GoogleFonts.poppins(
                              color: AppColors.textMuted,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (val) => playerManager.updatePlayerName(player.id, val),
                        ),
                      ),
                      if (players.length > 2)
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            playerManager.removePlayer(player.id);
                          },
                          icon: const Icon(Icons.close_rounded, color: AppColors.dareRed, size: 20),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            if (players.length < 10)
              FadeInUp(
                delay: Duration(milliseconds: 50 * players.length),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    playerManager.addPlayer();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryNeon.withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded, color: AppColors.primaryNeon, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Add Player',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNeon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${players.length}/10 players',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameModeCards() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Row(
        children: [
          Expanded(
            child: _buildModeCard(
              '🎡',
              'Spin the\nWheel',
              GameMode.spinTheWheel,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildModeCard(
              '👆',
              'One at\na Time',
              GameMode.oneAtATime,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(String emoji, String label, GameMode mode) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNeon.withAlpha(20) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryNeon : AppColors.surfaceBright,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primaryNeon.withAlpha(25), blurRadius: 15)]
              : [],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.surfaceBright, width: 1)),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => GameEngineScreen(gameMode: _selectedMode),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                    ),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryNeon.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Let\'s Go! 🔥',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
