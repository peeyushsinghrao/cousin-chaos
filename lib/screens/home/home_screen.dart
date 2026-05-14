import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/glass_card.dart';
import '../truth_or_dare/pack_selection_screen.dart';
import '../settings/settings_screen.dart';
import '../vault/vault_screen.dart';
import '../crew/crew_screen.dart';
import '../daily_challenge/daily_challenge_screen.dart';
import '../new_modes/act_it_out_screen.dart';
import '../new_modes/alibi_screen.dart';
import '../new_modes/bomb_pass_screen.dart';
import '../new_modes/chaos_mode_screen.dart';
import '../new_modes/freeze_mode_screen.dart';
import '../new_modes/hot_seat_screen.dart';
import '../new_modes/impostor_players_screen.dart';
import '../new_modes/judge_me_screen.dart';
import '../new_modes/laugh_attack_screen.dart';
import '../new_modes/last_standing_screen.dart';
import '../new_modes/most_likely_screen.dart';
import '../new_modes/rank_it_screen.dart';
import '../new_modes/secret_mission_screen.dart';
import '../new_modes/speed_challenge_screen.dart';
import '../new_modes/two_truths_one_lie_screen.dart';
import '../new_modes/target_player_screen.dart';
import '../../widgets/disclaimer_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshGradientBackground(
        duration: const Duration(seconds: 15),
        child: Stack(
          children: [
            // Background Orbs
            _buildBackgroundOrbs(),
            
            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // TopAppBar
                  _buildTopAppBar(),
                  
                  // Tab content
                  Expanded(
                    child: IndexedStack(
                      index: _selectedTab,
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              _buildWelcomeSection(),
                              const SizedBox(height: 24),
                              _buildDailyChallengeBanner(),
                              const SizedBox(height: 32),
                              _buildGameModeGrid(),
                              const SizedBox(height: 40),
                              _buildStatsSection(),
                              const SizedBox(height: 40),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                        const CrewScreen(),
                        const VaultScreen(),
                      ],
                    ),
                  ),
                
                // FAB: Play Now
                Visibility(
                  visible: _selectedTab == 0,
                  child: _buildPlayNowFAB(),
                ),
                
                // BottomNavBar
                _buildBottomNavBar(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildBackgroundOrbs() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Floating Orbs
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
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
                color: AppColors.secondary.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.15),
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
        color: AppColors.surface.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                color: AppColors.primary,
                onPressed: () {},
              ),
              const SizedBox(width: 16),
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
                        color: AppColors.primary.withOpacity(0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Player One',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'CHAOS MASTER',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: AppColors.surfaceContainer,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
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

  Widget _buildDailyChallengeBanner() {
    return FadeInUpAnimation(
      duration: const Duration(milliseconds: 600),
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Center(
                child: Icon(Icons.local_fire_department_rounded, color: Colors.white),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Challenge',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          )),
                  const SizedBox(height: 6),
                  Text('Keep the streak alive with today’s chaos dare.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          )),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                );
              },
              child: Text('VIEW', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeGrid() {
    return Column(
      children: [
        // Large Mode Cards
        _buildLargeModeCard(
          title: 'Truth or Dare',
          subtitle: 'Dare to speak?',
          tag: 'Classic Mode',
          tagColor: AppColors.primary,
          icon: Icons.psychology,
          color: AppColors.primary,
          onTap: () {
            DisclaimerDialog.show(context, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PackSelectionScreen()),
              );
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
            DisclaimerDialog.show(context, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImpostorPlayersScreen()),
              );
            });
          },
        ),
        
        const SizedBox(height: 24),
        
        // Horizontal Scroll for Other Modes
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
          boxShadow: BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 50,
            spreadRadius: -12,
            offset: const Offset(0, 20),
          ),
          child: Container(
            height: 192,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.1),
                  Colors.transparent,
                  AppColors.surface.withOpacity(0.8),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Icon Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(8),
                    boxShadow: BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 20,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                ),
                
                // Content
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
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1,
                          ),
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
      {'title': 'Bomb Pass', 'subtitle': 'Keep it moving fast', 'icon': Icons.bolt, 'color': AppColors.tertiary, 'route': const BombPassScreen()},
      {'title': 'Chaos Mode', 'subtitle': 'Random challenges', 'icon': Icons.shuffle, 'color': AppColors.primary, 'route': const ChaosModeScreen()},
      {'title': 'Freeze', 'subtitle': 'Stop on command', 'icon': Icons.ac_unit, 'color': AppColors.truthBlue, 'route': const FreezeModeScreen()},
      {'title': 'Laugh Attack', 'subtitle': 'Who can hold it?', 'icon': Icons.emoji_emotions, 'color': AppColors.neonPink, 'route': const LaughAttackScreen()},
      {'title': 'Secret Mission', 'subtitle': 'Complete it quietly', 'icon': Icons.visibility_off, 'color': AppColors.primaryNeon, 'route': const SecretMissionScreen()},
      {'title': 'Speed Challenge', 'subtitle': 'Answers under pressure', 'icon': Icons.speed, 'color': AppColors.error, 'route': const SpeedChallengeScreen()},
      {'title': 'Target Player', 'subtitle': 'Point and play', 'icon': Icons.gps_fixed, 'color': AppColors.secondaryContainer, 'route': const TargetPlayerScreen()},
      {'title': 'Last Standing', 'subtitle': 'Survive the round', 'icon': Icons.emoji_events, 'color': AppColors.gold, 'route': const LastStandingScreen()},
      {'title': 'Hot Seat', 'subtitle': 'Dares and disclosure', 'icon': Icons.whatshot, 'color': AppColors.dareRed, 'route': const HotSeatScreen()},
      {'title': 'Alibi', 'subtitle': 'Defend your story', 'icon': Icons.verified_user, 'color': AppColors.secondary, 'route': const AlibiScreen()},
      {'title': 'Most Likely', 'subtitle': 'Pick the group', 'icon': Icons.people, 'color': AppColors.tertiary, 'route': const MostLikelyScreen()},
      {'title': 'Rank It', 'subtitle': 'Order the players', 'icon': Icons.leaderboard, 'color': AppColors.neonGreen, 'route': const RankItScreen()},
      {'title': 'Two Truths', 'subtitle': 'Find the lie', 'icon': Icons.sentiment_satisfied_alt, 'color': AppColors.surfaceContainerHigh, 'route': const TwoTruthsOneLieScreen()},
      {'title': 'Judge Me', 'subtitle': 'Vote and reveal', 'icon': Icons.gavel, 'color': AppColors.gold, 'route': const JudgeMeScreen()},
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => mode['route'] as Widget),
              ),
              child: GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(0),
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
                              (mode['color'] as Color).withOpacity(0.25),
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

  Widget _buildStatsSection() {
    return Column(
      children: [
        // Chaos Meter
        FadeInUpAnimation(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 500),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHAOS METER',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '85% CRITICAL',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Stats Grid
        Row(
          children: [
            Expanded(
              child: FadeInUpAnimation(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 600),
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CREW ACTIVE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '12',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppColors.primary,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'Friends',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary.withOpacity(0.6),
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
            const SizedBox(width: 16),
            Expanded(
              child: FadeInUpAnimation(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 700),
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL VAULT',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '4.2k',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppColors.secondary,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'XP',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.secondary.withOpacity(0.6),
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
          ],
        ),
      ],
    );
  }

  Widget _buildPlayNowFAB() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: FadeInUpAnimation(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 800),
          child: GlassButton(
            isPrimary: true,
            height: 56,
            borderRadius: 28,
            gradient: AppColors.primaryGradient,
            boxShadow: BoxShadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 0,
            ),
            onPressed: () {
              DisclaimerDialog.show(context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PackSelectionScreen()),
                );
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'PLAY NOW',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onPrimaryFixed,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer.withOpacity(0.4),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: -10,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.sports_esports,
                  label: 'Chaos',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _buildNavItem(
                  icon: Icons.group,
                  label: 'Crew',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
                _buildNavItem(
                  icon: Icons.history,
                  label: 'Vault',
                  isSelected: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: _selectedTab == 3,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
