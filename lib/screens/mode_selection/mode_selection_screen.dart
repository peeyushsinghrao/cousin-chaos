import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/glass_card.dart';
import '../truth_or_dare/pack_selection_screen.dart';
import '../new_modes/impostor_players_screen.dart';
import '../../core/navigation/page_transitions.dart';
import '../new_modes/speed_challenge_screen.dart';
import '../../widgets/disclaimer_dialog.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              Color(0xFF12082A),
              AppColors.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Decoration
            _buildBackgroundDecoration(),
            
            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // TopAppBar
                  _buildTopAppBar(),
                  
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          
                          // Hero Header
                          _buildHeroHeader(),
                          
                          const SizedBox(height: 40),
                          
                          // Category Tabs
                          _buildCategoryTabs(),
                          
                          const SizedBox(height: 24),
                          
                          // Mode List
                          _buildModeList(),
                          
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
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

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(13),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(13),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            right: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withAlpha(13),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withAlpha(13),
                    blurRadius: 100,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.primary,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              Text(
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
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(128),
                width: 2,
              ),
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
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      children: [
        Text(
          'Select Your Poison',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.onSurface,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'UNLEASH THE MAYHEM',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            letterSpacing: 0.2,
            shadows: [
              Shadow(
                color: AppColors.primary.withAlpha(153),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['Classic', 'Social', 'Seasonal'];
    
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return Padding(
            padding: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(102),
                            blurRadius: 15,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  categories[index],
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeList() {
    return Column(
      children: [
        _buildModeCard(
          title: 'Truth or Dare',
          description: 'The original chaos starter. Reveal your darkest secrets or perform questionable feats in front of your favorite cousins.',
          icon: Icons.psychology,
          iconColor: AppColors.primary,
          tagColor: AppColors.primary,
          tag: 'Casual',
          playerCount: '3-12 Players',
          buttonText: 'Initialize Chaos',
          buttonGradient: AppColors.primaryGradient,
          onTap: () {
            DisclaimerDialog.show(context, () {
              Navigator.push(
                context,
                slideUpRoute(const PackSelectionScreen()),
              );
            });
          },
        ),
        
        const SizedBox(height: 24),
        
        _buildModeCard(
          title: 'The Impostor',
          description: 'One of you is lying. Complete group tasks while the infiltrator tries to sabotage your sanity. Trust nobody.',
          icon: Icons.theater_comedy,
          iconColor: AppColors.tertiary,
          tagColor: AppColors.tertiary,
          tag: 'Chaotic',
          playerCount: '5-10 Players',
          buttonText: 'Enter The Void',
          buttonGradient: AppColors.tertiaryGradient,
          onTap: () {
            Navigator.push(context, slideUpRoute(const ImpostorPlayersScreen()));
          },
        ),
        
        const SizedBox(height: 24),
        
        _buildModeCard(
          title: 'Speed Run',
          description: 'Rapid-fire challenges that get harder as the clock ticks down. Fastest reflexes win the crown.',
          icon: Icons.timer,
          iconColor: AppColors.secondary,
          tagColor: AppColors.secondary,
          tag: 'Intense',
          playerCount: '2-8 Players',
          buttonText: 'Start Timer',
          buttonGradient: AppColors.secondaryGradient,
          onTap: () {
            DisclaimerDialog.show(context, () {
              Navigator.push(
                context,
                slideUpRoute(const SpeedChallengeScreen()),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color tagColor,
    required String tag,
    required String playerCount,
    required String buttonText,
    required Gradient buttonGradient,
    required VoidCallback onTap,
  }) {
    return FadeInUpAnimation(
      duration: const Duration(milliseconds: 600),
      child: GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(24),
        boxShadow: [BoxShadow(
          color: iconColor.withAlpha(51),
          blurRadius: 15,
          spreadRadius: 0,
        )],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(51),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withAlpha(76),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 32,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: iconColor.withAlpha(51),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: iconColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        playerCount,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: GlassButton(
                isPrimary: true,
                borderRadius: 12,
                gradient: buttonGradient,
                boxShadow: [BoxShadow(
                  color: iconColor.withAlpha(76),
                  blurRadius: 20,
                  spreadRadius: 0,
                )],
                onPressed: onTap,
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
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
          color: AppColors.surfaceContainer.withAlpha(102),
          border: Border(
            top: BorderSide(
              color: Colors.white.withAlpha(26),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(76),
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
                  isSelected: true,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.group,
                  label: 'Crew',
                  isSelected: false,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.history,
                  label: 'Vault',
                  isSelected: false,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: false,
                  onTap: () {},
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
          color: isSelected ? AppColors.primary.withAlpha(51) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(102),
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
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant.withAlpha(178),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant.withAlpha(178),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
