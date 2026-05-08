import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_icon.dart';
import '../truth_or_dare/pack_selection_screen.dart';
import '../settings/settings_screen.dart';
import '../random_challenge/random_challenge_screen.dart';
import '../standalone_game/standalone_game_screen.dart';
import '../shared/mode_player_setup_screen.dart';
import '../would_you_rather/wyr_game_screen.dart';
import '../never_have_i_ever/nhie_game_screen.dart';
import '../new_modes/act_it_out_screen.dart';
import '../new_modes/speed_challenge_screen.dart';
import '../new_modes/laugh_attack_screen.dart';
import '../new_modes/freeze_mode_screen.dart';
import '../new_modes/target_player_screen.dart';
import '../new_modes/secret_mission_screen.dart';
import '../new_modes/chaos_mode_screen.dart';
import '../new_modes/bomb_pass_screen.dart';
import '../new_modes/last_standing_screen.dart';
import '../new_modes/impostor_setup_screen.dart';
import '../../widgets/disclaimer_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildMainCard(context),
                const SizedBox(height: 28),
                _buildSectionTitle(context, 'More Games'),
                const SizedBox(height: 16),
                _buildComingSoonGrid(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primaryNeon, AppColors.neonPink],
                ).createShader(bounds),
                child: Text(
                  'Cousin Chaos',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ULTIMATE EDITION',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBright, width: 1),
              ),
              child: const Icon(Icons.settings_rounded, color: AppColors.textMuted, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      child: GestureDetector(
        onTap: () {
          DisclaimerDialog.show(context, () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => const PackSelectionScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
              ),
            );
          });
        },
        child: Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1050), Color(0xFF1A0830)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.primaryNeon.withAlpha(80),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryNeon.withAlpha(40),
                blurRadius: 30,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Neon glow orb top-right
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryNeon.withAlpha(60),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Neon glow orb bottom-left
              Positioned(
                bottom: -40,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.dareRed.withAlpha(40),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.neonGreen.withAlpha(80)),
                          ),
                          child: Text(
                            '● ACTIVE',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neonGreen,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const GradientIconContainer(
                              icon: Icons.theater_comedy_rounded,
                              color: AppColors.truthBlue,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Truth or Dare',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The ultimate party game engine',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildTag('13 Packs', AppColors.truthBlue),
                            const SizedBox(width: 8),
                            _buildTag('Custom', AppColors.neonOrange),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNeon,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildComingSoonGrid(BuildContext context) {
    final games = [
      {'icon': Icons.bolt_rounded, 'title': 'Random Challenge', 'color': AppColors.neonGreen},
      {'icon': Icons.help_outline_rounded, 'title': 'Would You Rather', 'color': AppColors.truthBlue},
      {'icon': Icons.front_hand_rounded, 'title': 'Never Have I Ever', 'color': AppColors.neonPink},
      {'icon': Icons.psychology_rounded, 'title': 'Trivia Battle', 'color': AppColors.neonYellow},
      {'icon': Icons.search_rounded, 'title': 'Impostor Mode', 'color': AppColors.dareRed},
      {'icon': Icons.theater_comedy_rounded, 'title': 'Act It Out', 'color': AppColors.neonOrange},
      {'icon': Icons.timer_rounded, 'title': 'Speed Challenge', 'color': AppColors.dareRed},
      {'icon': Icons.emoji_emotions_rounded, 'title': 'Laugh Attack', 'color': AppColors.neonCyan},
      {'icon': Icons.ac_unit_rounded, 'title': 'Freeze Mode', 'color': AppColors.truthBlue},
      {'icon': Icons.my_location_rounded, 'title': 'Target Player', 'color': AppColors.neonPink},
      {'icon': Icons.vpn_key_rounded, 'title': 'Secret Mission', 'color': AppColors.primaryNeon},
      {'icon': Icons.cyclone_rounded, 'title': 'Chaos Mode', 'color': AppColors.neonYellow},
      {'icon': Icons.local_fire_department_rounded, 'title': 'Bomb Pass', 'color': AppColors.dareRed},
      {'icon': Icons.accessibility_new_rounded, 'title': 'Last Standing', 'color': AppColors.neonGreen},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: games.length,
      itemBuilder: (context, i) {
        final title = games[i]['title'] as String;
        final color = games[i]['color'] as Color;
        final icon = games[i]['icon'] as IconData;

        return FadeInUp(
          delay: Duration(milliseconds: 50 * i),
          duration: const Duration(milliseconds: 500),
          child: GestureDetector(
            onTap: () {
              DisclaimerDialog.show(context, () {
                if (title == 'Random Challenge') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RandomChallengeScreen()));
                } else if (title == 'Would You Rather') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PackSelectionScreen(
                    onNext: (ctx) => ModePlayerSetupScreen(
                      title: 'Would You Rather',
                      subtitle: 'Choose between two crazy options!',
                      themeColor: AppColors.truthBlue,
                      icon: Icons.help_outline_rounded,
                      onStart: (_) => const WouldYouRatherScreen(),
                    )
                  )));
                } else if (title == 'Never Have I Ever') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PackSelectionScreen(
                    onNext: (ctx) => ModePlayerSetupScreen(
                      title: 'Never Have I Ever',
                      subtitle: 'Reveal your wildest experiences!',
                      themeColor: AppColors.neonPink,
                      icon: Icons.front_hand_rounded,
                      onStart: (_) => const NeverHaveIEverScreen(),
                    )
                  )));
                } else if (title == 'Trivia Battle') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PackSelectionScreen(
                    onNext: (ctx) => const StandaloneGameScreen(type: StandaloneGameType.trivia)
                  )));
                } else if (title == 'Impostor Mode') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ImpostorSetupScreen()));
                } else if (title == 'Act It Out') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ActItOutScreen()));
                } else if (title == 'Speed Challenge') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SpeedChallengeScreen()));
                } else if (title == 'Laugh Attack') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LaughAttackScreen()));
                } else if (title == 'Freeze Mode') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FreezeModeScreen()));
                } else if (title == 'Target Player') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TargetPlayerScreen()));
                } else if (title == 'Secret Mission') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SecretMissionScreen()));
                } else if (title == 'Chaos Mode') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChaosModeScreen()));
                } else if (title == 'Bomb Pass') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BombPassScreen()));
                } else if (title == 'Last Standing') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LastStandingScreen()));
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withAlpha(50), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: GradientIconContainer(
                      icon: icon,
                      color: color,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
