import 'package:cousin_chaos/core/icons.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/player_manager.dart';
import '../../services/session_service.dart';
import '../truth_or_dare/pack_selection_screen.dart';
import '../settings/settings_screen.dart';
import '../new_modes/act_it_out_screen.dart';
import '../new_modes/alibi_screen.dart';
import '../new_modes/impostor_players_screen.dart';
import '../new_modes/speed_challenge_screen.dart';
import '../new_modes/two_truths_one_lie_screen.dart';
import '../../core/navigation/page_transitions.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/disclaimer_dialog.dart';
import '../players/players_screen.dart';

class _ModeData {
  final String name;
  final String tagline;
  final IconData icon;
  final Color color;
  final Widget Function(BuildContext) builder;

  const _ModeData({
    required this.name,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<SessionRecord>? _recentSessions;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await SessionService.loadSessions();
    if (mounted) setState(() => _recentSessions = sessions);
  }

  List<_ModeData> _getModes(BuildContext context) => [
        _ModeData(
          name: 'Truth or Dare',
          tagline: 'Dare to speak?',
          icon: Icons.psychology_rounded,
          color: AppColors.primary,
          builder: (_) => throw '',
        ),
        _ModeData(
          name: 'Impostor',
          tagline: 'Find the traitor',
          icon: Icons.person_search_rounded,
          color: AppColors.tertiary,
          builder: (_) => const ImpostorPlayersScreen(),
        ),
        _ModeData(
          name: 'Act It Out',
          tagline: 'Charades with chaos',
          icon: Icons.theater_comedy_rounded,
          color: AppColors.secondary,
          builder: (_) => const ActItOutScreen(),
        ),
        _ModeData(
          name: 'Two Truths',
          tagline: 'Find the lie',
          icon: Icons.sentiment_satisfied_alt_rounded,
          color: const Color(0xFF93C5FD),
          builder: (_) => const TwoTruthsOneLieScreen(),
        ),
        _ModeData(
          name: 'Alibi',
          tagline: 'Defend your story',
          icon: Icons.verified_user_rounded,
          color: AppColors.neonGreen,
          builder: (_) => const AlibiScreen(),
        ),
        _ModeData(
          name: 'Speed Challenge',
          tagline: 'Answers under pressure',
          icon: Icons.speed_rounded,
          color: AppColors.error,
          builder: (_) => const SpeedChallengeScreen(),
        ),
        _ModeData(
          name: 'Would You Rather',
          tagline: 'Tough choices ahead',
          icon: Icons.compare_arrows_rounded,
          color: AppColors.neonYellow,
          builder: (_) => const SpeedChallengeScreen(),
        ),
        _ModeData(
          name: 'Never Have I Ever',
          tagline: 'Confess your secrets',
          icon: Icons.ramen_dining_rounded,
          color: AppColors.neonOrange,
          builder: (_) => const SpeedChallengeScreen(),
        ),
      ];

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
                        _buildChaosTab(),
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

  Widget _buildChaosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildWelcomeSection(),
          const SizedBox(height: 32),
          _buildGameModeGrid(),
          if (_recentSessions != null && _recentSessions!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildLastPlayedCard(_recentSessions!.first),
          ],
          const SizedBox(height: 120),
        ],
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
          bottom: BorderSide(color: Colors.white.withAlpha(26)),
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
              child: Icon(LucideIcons.settings,
                  color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return FadeInUpAnimation(
      duration: const Duration(milliseconds: 600),
      child: Consumer<PlayerManager>(
        builder: (context, pm, _) {
          final firstName = pm.players.isNotEmpty
              ? pm.players.first.name.split(' ').first
              : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstName != null
                    ? 'Hey $firstName 👋'
                    : 'Welcome to the Chaos',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to wreck the party? Pick your poison.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameModeGrid() {
    final modes = _getModes(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.65,
      ),
      itemCount: modes.length,
      itemBuilder: (context, index) =>
          _buildModeCard(context, modes[index], index),
    );
  }

  Widget _buildModeCard(
      BuildContext context, _ModeData mode, int index) {
    return FadeInUpAnimation(
      duration: Duration(milliseconds: 300 + index * 50),
      child: GestureDetector(
        onTap: () => _onModeTap(context, mode),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: mode.color.withAlpha(50), width: 1),
            boxShadow: [
              BoxShadow(
                color: mode.color.withAlpha(20),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: mode.color.withAlpha(35),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(mode.icon, color: mode.color, size: 17),
                    ),
                    const Spacer(),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mode.color.withAlpha(180),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  mode.name,
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  mode.tagline,
                  style: TextStyle(
                    fontSize: 10,
                    color: mode.color.withAlpha(200),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onModeTap(BuildContext context, _ModeData mode) {
    final soundEnabled =
        context.read<PreferencesService>().soundEnabled;
    SoundService.instance
        .play(SoundEvent.pageTransition, soundEnabled: soundEnabled);

    if (mode.name == 'Truth or Dare') {
      DisclaimerDialog.show(context, () {
        Navigator.push(
            context, slideUpRoute(const PackSelectionScreen()));
      });
      return;
    }
    Navigator.push(context, slideUpRoute(mode.builder(context)));
  }

  Widget _buildLastPlayedCard(SessionRecord session) {
    return FadeInUpAnimation(
      duration: const Duration(milliseconds: 500),
      child: GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.history,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Played',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.mode,
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (session.winner.isNotEmpty)
                    Text(
                      '🏆 ${session.winner} won',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(LucideIcons.arrowRight,
                color: Colors.white30, size: 18),
          ],
        ),
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
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(32),
              border:
                  Border.all(color: Colors.white.withAlpha(38)),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, LucideIcons.zap, 'Chaos'),
                _buildNavItem(1, LucideIcons.users, 'Players'),
                _buildNavItem(2, LucideIcons.settings, 'Settings'),
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
                ? LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary])
                    .createShader(bounds)
                : const LinearGradient(
                        colors: [Colors.white54, Colors.white54])
                    .createShader(bounds),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white54,
              fontSize: 11,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
