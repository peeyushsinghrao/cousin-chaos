import 'package:cousin_chaos/core/icons.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../services/player_manager.dart';
import '../../services/session_service.dart';
import '../truth_or_dare/pack_selection_screen.dart';
import '../settings/settings_screen.dart';
import '../new_modes/act_it_out_screen.dart';
import '../new_modes/alibi_screen.dart';
import '../new_modes/impostor_players_screen.dart';
import '../new_modes/speed_challenge_screen.dart';
import '../new_modes/two_truths_one_lie_screen.dart';
import '../would_you_rather/wyr_game_screen.dart';
import '../never_have_i_ever/nhie_game_screen.dart';
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
  final Color colorDark;
  final Widget Function(BuildContext) builder;

  const _ModeData({
    required this.name,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.colorDark,
    required this.builder,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<SessionRecord>? _recentSessions;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final sessions = await SessionService.loadSessions();
    if (mounted) setState(() => _recentSessions = sessions);
  }

  List<_ModeData> get _modes => [
        _ModeData(
          name: 'Truth or Dare',
          tagline: 'Dare to speak?',
          icon: Icons.local_fire_department_rounded,
          color: AppColors.primary,
          colorDark: const Color(0xFF3A1C61),
          builder: (_) => throw '',
        ),
        _ModeData(
          name: 'Impostor',
          tagline: 'Find the traitor',
          icon: Icons.person_search_rounded,
          color: AppColors.tertiary,
          colorDark: const Color(0xFF661931),
          builder: (_) => const ImpostorPlayersScreen(),
        ),
        _ModeData(
          name: 'Act It Out',
          tagline: 'Charades with chaos',
          icon: Icons.theater_comedy_rounded,
          color: AppColors.secondary,
          colorDark: const Color(0xFF14496B),
          builder: (_) => const ActItOutScreen(),
        ),
        _ModeData(
          name: 'Two Truths',
          tagline: 'Find the lie',
          icon: Icons.psychology_alt_rounded,
          color: const Color(0xFF93C5FD),
          colorDark: const Color(0xFF1E3A5F),
          builder: (_) => const TwoTruthsOneLieScreen(),
        ),
        _ModeData(
          name: 'Alibi',
          tagline: 'Defend your story',
          icon: Icons.verified_user_rounded,
          color: AppColors.neonGreen,
          colorDark: const Color(0xFF0D3320),
          builder: (_) => const AlibiScreen(),
        ),
        _ModeData(
          name: 'Speed',
          tagline: 'Beat the clock',
          icon: Icons.speed_rounded,
          color: AppColors.dareRed,
          colorDark: const Color(0xFF4A0B14),
          builder: (_) => const SpeedChallengeScreen(),
        ),
        _ModeData(
          name: 'Would You Rather',
          tagline: 'Tough choices',
          icon: Icons.compare_arrows_rounded,
          color: AppColors.neonYellow,
          colorDark: const Color(0xFF3D2F00),
          builder: (_) => const WouldYouRatherScreen(),
        ),
        _ModeData(
          name: 'Never Have I',
          tagline: 'Confess secrets',
          icon: Icons.ramen_dining_rounded,
          color: AppColors.neonOrange,
          colorDark: const Color(0xFF4A1F0A),
          builder: (_) => const NeverHaveIEverScreen(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF08041A), Color(0xFF0E0624), Color(0xFF08041A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            _buildAmbientOrbs(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
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
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientOrbs() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withAlpha(25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withAlpha(18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.tertiary.withAlpha(15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ).createShader(bounds),
            child: Text(
              'COUSIN CHAOS',
              style: GoogleFonts.anybody(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),
          Consumer<PlayerManager>(
            builder: (_, pm, __) => pm.players.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.users, color: AppColors.primary, size: 12),
                        const SizedBox(width: 5),
                        Text(
                          '${pm.players.length}',
                          style: GoogleFonts.sora(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 2),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(18)),
              ),
              child: Icon(LucideIcons.settings, color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _buildWelcome(),
          const SizedBox(height: 24),
          _buildHeroCard(_modes[0]),
          const SizedBox(height: 20),
          _buildSectionHeader('All Modes', '${_modes.length}'),
          const SizedBox(height: 12),
          _buildModeGrid(),
          if (_recentSessions != null && _recentSessions!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildLastPlayed(_recentSessions!.first),
          ],
          const SizedBox(height: 110),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Consumer<PlayerManager>(
      builder: (_, pm, __) {
        final name = pm.players.isNotEmpty
            ? pm.players.first.name.split(' ').first
            : null;
        return FadeInUpAnimation(
          duration: const Duration(milliseconds: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name != null ? 'Hey $name 👋' : 'Welcome back',
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Ready to wreck the party?',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withAlpha(100),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(_ModeData mode) {
    return FadeInUpAnimation(
      duration: const Duration(milliseconds: 450),
      child: GestureDetector(
        onTap: () => _onModeTap(context, mode),
        child: Container(
          height: 158,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                mode.colorDark,
                mode.colorDark.withAlpha(200),
                mode.color.withAlpha(60),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(color: mode.color.withAlpha(60), width: 1),
            boxShadow: [
              BoxShadow(
                color: mode.color.withAlpha(35),
                blurRadius: 28,
                spreadRadius: -4,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  mode.icon,
                  size: 160,
                  color: mode.color.withAlpha(22),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Icon(
                  mode.icon,
                  size: 64,
                  color: mode.color.withAlpha(120),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: mode.color.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: mode.color.withAlpha(80)),
                      ),
                      child: Text(
                        'FEATURED',
                        style: GoogleFonts.sora(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: mode.color,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mode.name,
                      style: GoogleFonts.anybody(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.tagline,
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        color: Colors.white.withAlpha(160),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: mode.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: mode.color.withAlpha(80),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Play Now',
                                style: GoogleFonts.sora(
                                  color: const Color(0xFF0A0518),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0A0518), size: 14),
                            ],
                          ),
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

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withAlpha(50)),
          ),
          child: Text(
            badge,
            style: GoogleFonts.sora(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeGrid() {
    final gridModes = _modes.sublist(1);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: gridModes.length,
      itemBuilder: (ctx, i) => _buildModeCard(ctx, gridModes[i], i),
    );
  }

  Widget _buildModeCard(BuildContext context, _ModeData mode, int index) {
    return FadeInUpAnimation(
      duration: Duration(milliseconds: 350 + index * 50),
      child: GestureDetector(
        onTap: () => _onModeTap(context, mode),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF120E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: mode.color.withAlpha(45), width: 1),
            boxShadow: [
              BoxShadow(
                color: mode.color.withAlpha(18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: mode.color.withAlpha(22),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: mode.color.withAlpha(40)),
                      ),
                      child: Icon(mode.icon, color: mode.color, size: 16),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: mode.color.withAlpha(100),
                      size: 11,
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
                  style: GoogleFonts.sora(
                    fontSize: 10,
                    color: mode.color.withAlpha(180),
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

  Widget _buildLastPlayed(SessionRecord session) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF120E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(LucideIcons.history, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last played',
                  style: GoogleFonts.sora(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  session.mode,
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (session.winner.isNotEmpty)
                  Text(
                    '🏆 ${session.winner}',
                    style: TextStyle(color: AppColors.gold, fontSize: 11),
                  ),
              ],
            ),
          ),
          Icon(LucideIcons.arrowRight, color: Colors.white24, size: 16),
        ],
      ),
    );
  }

  void _onModeTap(BuildContext context, _ModeData mode) {
    final soundEnabled = context.read<PreferencesService>().soundEnabled;
    SoundService.instance.play(SoundEvent.pageTransition, soundEnabled: soundEnabled);

    if (mode.name == 'Truth or Dare') {
      DisclaimerDialog.show(context, () {
        Navigator.push(context, slideUpRoute(const PackSelectionScreen()));
      });
      return;
    }
    Navigator.push(context, slideUpRoute(mode.builder(context)));
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1428).withAlpha(220),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withAlpha(22)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withAlpha(22) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (b) => (isActive
                      ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary])
                      : const LinearGradient(colors: [Colors.white38, Colors.white38]))
                  .createShader(b),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.sora(
                color: isActive ? AppColors.primary : Colors.white38,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
