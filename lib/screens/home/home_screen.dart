import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/glass_card.dart';
import '../truth_or_dare/pack_selection_screen.dart';
import '../settings/settings_screen.dart';
import '../new_modes/act_it_out_screen.dart';
import '../new_modes/alibi_screen.dart';
import '../new_modes/impostor_players_screen.dart';
import '../new_modes/last_standing_screen.dart';
import '../new_modes/speed_challenge_screen.dart';
import '../new_modes/two_truths_one_lie_screen.dart';
import '../../core/navigation/page_transitions.dart';
import '../../widgets/disclaimer_dialog.dart';
import '../players/players_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshGradientBackground(
        duration: const Duration(seconds: 15),
        child: Stack(
          children: [
            _buildBackgroundOrbs(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopAppBar(),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              _buildWelcomeSection(),
                              const SizedBox(height: 32),
                              _buildGameModeGrid(),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                        const PlayersScreen(),
                        const SettingsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(38),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(38),
                    blurRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withAlpha(38),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withAlpha(38),
                    blurRadius: 80,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(76),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PulseGlowAnimation(
            duration: const Duration(seconds: 3),
            glowColor: AppColors.primary,
            child: Text(
              'COUSIN CHAOS',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.primary,
                fontSize: 24,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withAlpha(204),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 2),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGlass),
              ),
              child: Icon(Icons.settings_rounded, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return FadeInUpAnimation(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to the Chaos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.onSurface,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to wreck the party? Pick your poison and let the games begin.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeGrid() {
    return Column(
      children: [
        _buildLargeModeCard(
          title: 'Truth or Dare',
          subtitle: 'Dare to speak?',
          tag: 'Classic Mode',
          tagColor: AppColors.primary,
          icon: Icons.psychology,
          color: AppColors.primary,
          onTap: () {
            DisclaimerDialog.show(context, () {
              Navigator.push(context, slideUpRoute(const PackSelectionScreen()));
            });
          },
        ),
        const SizedBox(height: 24),
        _buildLargeModeCard(
          title: 'Impostor',
          subtitle: 'Find the traitor',
          tag: 'Trending',
          tagColor: AppColors.tertiary,
          icon: Icons.person_search,
          color: AppColors.tertiary,
          onTap: () {
            Navigator.push(context, slideUpRoute(const ImpostorPlayersScreen()));
          },
        ),
        const SizedBox(height: 24),
        _buildHorizontalScrollModes(),
      ],
    );
  }

  Widget _buildLargeModeCard({
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return FadeInUpAnimation(
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          borderRadius: 16,
          padding: EdgeInsets.zero,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(102),
              blurRadius: 50,
              spreadRadius: -12,
              offset: const Offset(0, 20),
            ),
          ],
          child: Container(
            height: 192,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withAlpha(26),
                  Colors.transparent,
                  AppColors.surface.withAlpha(204),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(102),
                        blurRadius: 20,
                      ),
                    ],
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withAlpha(51),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withAlpha(76), width: 1),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: color,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalScrollModes() {
    final modes = [
      {'title': 'Act It Out', 'subtitle': 'Charades with a twist', 'icon': Icons.theater_comedy, 'color': AppColors.secondary, 'route': const ActItOutScreen()},
      {'title': 'Speed Challenge', 'subtitle': 'Answers under pressure', 'icon': Icons.speed, 'color': AppColors.error, 'route': const SpeedChallengeScreen()},
      {'title': 'Last Standing', 'subtitle': 'Survive the round', 'icon': Icons.emoji_events, 'color': AppColors.gold, 'route': const LastStandingScreen()},
      {'title': 'Alibi', 'subtitle': 'Defend your story', 'icon': Icons.verified_user, 'color': AppColors.secondary, 'route': const AlibiScreen()},
      {'title': 'Two Truths', 'subtitle': 'Find the lie', 'icon': Icons.sentiment_satisfied_alt, 'color': AppColors.surfaceContainerHigh, 'route': const TwoTruthsOneLieScreen()},
    ];

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: modes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final mode = modes[index];
          return SizedBox(
            width: 250,
            child: GestureDetector(
              onTap: () => Navigator.push(context, slideUpRoute(mode['route'] as Widget)),
              child: GlassCard(
                borderRadius: 18,
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (mode['color'] as Color).withAlpha(64),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GlassCard(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  mode['icon'] as IconData,
                                  color: mode['color'] as Color,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mode['title'] as String,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 19,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              mode['subtitle'] as String,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: mode['color'] as Color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.bolt, 'Chaos'),
                _buildNavItem(1, Icons.group, 'Players'),
                _buildNavItem(2, Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => isActive
                ? LinearGradient(colors: [AppColors.primary, AppColors.secondary])
                    .createShader(bounds)
                : const LinearGradient(colors: [Colors.white54, Colors.white54])
                    .createShader(bounds),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white54,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
