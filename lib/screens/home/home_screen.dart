import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/glass_card.dart';
import '../truth_or_dare/pack_selection_screen.dart';
import '../settings/settings_screen.dart';
import '../vault/vault_screen.dart';
import '../crew/crew_screen.dart';
import '../new_modes/alibi_screen.dart';
import '../new_modes/bomb_pass_screen.dart';
import '../new_modes/impostor_players_screen.dart';
import '../../core/navigation/page_transitions.dart';
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              _buildChaosMeter(),
                              const SizedBox(height: 32),
                              _buildChaosGrid(),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                        const CrewScreen(),
                        const VaultScreen(),
                        const SettingsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // BottomNavBar
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
        color: Colors.white.withAlpha(13),
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
            child: const Text(
              'COUSIN CHAOS',
              style: TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                fontSize: 24,
                letterSpacing: 2,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedTab = 1),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(26)),
              ),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaosMeter() {
    return FadeInUpAnimation(
      duration: const Duration(milliseconds: 600),
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT STATUS',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'CHAOS LEVEL',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                PulseGlowAnimation(
                  duration: const Duration(seconds: 2),
                  glowColor: AppColors.tertiaryContainer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.tertiaryContainer),
                    ),
                    child: const Text(
                      'CRITICAL',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tertiaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(128),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryContainer,
                        AppColors.secondaryContainer,
                        AppColors.tertiaryContainer,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withAlpha(128),
                        blurRadius: 8,
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

  Widget _buildChaosGrid() {
    final modes = [
      {
        'title': 'Truth or Dare',
        'tag': 'CLASSIC',
        'icon': Icons.chat_bubble_outline,
        'colors': [const Color(0xFF00C4FD), const Color(0xFF0052FF)],
        'onTap': () {
          DisclaimerDialog.show(context, () {
            Navigator.push(context, slideUpRoute(const PackSelectionScreen()));
          });
        },
      },
      {
        'title': 'Impostor',
        'tag': 'SOCIAL',
        'icon': Icons.person_search,
        'colors': [const Color(0xFF00FF87), const Color(0xFF008A4A)],
        'onTap': () => Navigator.push(context, slideUpRoute(const ImpostorPlayersScreen())),
      },
      {
        'title': 'Bomb Pass',
        'tag': 'STRESS',
        'icon': Icons.bolt,
        'colors': [const Color(0xFFFF5167), const Color(0xFFFF9E00)],
        'onTap': () => Navigator.push(context, slideUpRoute(const BombPassScreen())),
      },
      {
        'title': 'Would You Rather',
        'tag': 'DILEMMA',
        'icon': Icons.help_outline,
        'colors': [const Color(0xFFB76DFF), const Color(0xFF6000FF)],
        'onTap': () => debugPrint('Would You Rather tapped'),
      },
      {
        'title': 'Never Have I Ever',
        'tag': 'EXPOSE',
        'icon': Icons.back_hand,
        'colors': [const Color(0xFFFF5167), const Color(0xFFFF00D4)],
        'onTap': () => debugPrint('Never Have I Ever tapped'),
      },
      {
        'title': 'Alibi',
        'tag': 'DECEPTION',
        'icon': Icons.shield_outlined,
        'colors': [const Color(0xFF00C4FD), const Color(0xFF00FFB3)],
        'onTap': () => Navigator.push(context, slideUpRoute(const AlibiScreen())),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHOOSE YOUR CHAOS',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 10,
            color: AppColors.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: modes.map((mode) => _buildModeCard(mode)).toList(),
        ),
      ],
    );
  }

  Widget _buildModeCard(Map<String, dynamic> mode) {
    return GlassCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      onTap: mode['onTap'] as VoidCallback,
      isInteractive: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: mode['colors'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(mode['icon'] as IconData, color: Colors.white, size: 36),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode['tag'] as String,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mode['title'] as String,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: Colors.white.withAlpha(38)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              children: [
                _buildNavItem(0, Icons.local_fire_department, 'Chaos'),
                _buildNavItem(1, Icons.people, 'Crew'),
                _buildNavItem(2, Icons.inventory_2, 'Vault'),
                _buildNavItem(3, Icons.settings, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    final color = isSelected ? AppColors.primary : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              ShaderMask(
                shaderCallback: (bounds) => RadialGradient(
                  center: Alignment.center,
                  radius: 0.5,
                  colors: [color.withAlpha(204), color.withAlpha(0)],
                ).createShader(bounds),
                child: Icon(icon, color: color, size: 24),
              )
            else
              Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
