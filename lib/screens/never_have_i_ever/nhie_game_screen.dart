import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/leave_game_dialog.dart';
import '../../services/haptic_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/nhie_data.dart';
import '../../services/player_manager.dart';
import '../../services/api_service.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';
import '../../models/player.dart';
import '../../services/pack_manager.dart';

enum NhieMode { classic, wild, party, chaos }

class NeverHaveIEverScreen extends StatefulWidget {
  const NeverHaveIEverScreen({super.key});

  @override
  State<NeverHaveIEverScreen> createState() => _NeverHaveIEverScreenState();
}

class _NeverHaveIEverScreenState extends State<NeverHaveIEverScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _statements = [];
  late final List<Player> _gamePlayers;
  int _currentIndex = 0;
  int _currentPlayerIndex = 0;
  bool _isRevealed = false;
  bool _isLegendary = false;
  NhieMode _mode = NhieMode.classic;
  late AnimationController _glowController;
  late AnimationController _flipController;

  // Score tracking — count how many times each player has "done it"
  late Map<String, int> _drinkCounts;
  bool _showLeaderboard = false;

  @override
  void initState() {
    super.initState();
    _gamePlayers = List.from(context.read<PlayerManager>().players);
    _drinkCounts = {for (final p in _gamePlayers) p.name: 0};
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _flipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _loadStatements();
  }

  void _loadStatements() {
    final pm = context.read<PackManager>();
    final selectedPacks = pm.selectedPackIds;
    var filtered = NhieData.statements;
    if (selectedPacks.isNotEmpty) {
      filtered = NhieData.statements
          .where((s) => selectedPacks.contains(s['category']))
          .toList();
      if (filtered.isEmpty) filtered = NhieData.statements;
    }
    _statements.addAll(List.from(filtered)..shuffle(Random()));
    _fetchApiStatement();
  }

  Future<void> _fetchApiStatement() async {
    final prompt = await ApiService.fetchNeverHaveIEver();
    if (prompt != null && mounted) {
      setState(() {
        _statements.add({'text': prompt.text, 'category': 'api'});
      });
    }
  }

  Map<String, dynamic> get _currentStatement =>
      _statements[_currentIndex % _statements.length];

  void _revealCard() {
    if (_isRevealed) return;
    HapticService.instance.trigger(HapticEvent.cardReveal, hapticsEnabled: _hapticsEnabled);
    final soundEnabled = context.read<PreferencesService>().soundEnabled;
    SoundService.instance.play(SoundEvent.cardReveal, soundEnabled: soundEnabled);
    _flipController.forward(from: 0);
    setState(() {
      _isRevealed = true;
      _isLegendary = Random().nextDouble() < 0.08;
    });
  }

  void _nextStatement() {
    HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled);
    final soundEnabled = context.read<PreferencesService>().soundEnabled;
    SoundService.instance.play(SoundEvent.nextPlayer, soundEnabled: soundEnabled);
    setState(() {
      _currentIndex++;
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _gamePlayers.length;
      _isRevealed = false;
      _isLegendary = false;
    });
    if (_currentIndex % 5 == 0) _fetchApiStatement();
    if (_currentIndex >= _statements.length - 3) {
      final pm = context.read<PackManager>();
      final selectedPacks = pm.selectedPackIds;
      var filtered = NhieData.statements;
      if (selectedPacks.isNotEmpty) {
        filtered = NhieData.statements
            .where((s) => selectedPacks.contains(s['category']))
            .toList();
        if (filtered.isEmpty) filtered = NhieData.statements;
      }
      _statements.addAll(List.from(filtered)..shuffle(Random()));
    }
  }

  void _markHasDone(String playerName) {
    HapticService.instance.trigger(HapticEvent.cardReveal, hapticsEnabled: _hapticsEnabled);
    setState(() {
      _drinkCounts[playerName] = (_drinkCounts[playerName] ?? 0) + 1;
    });
  }

  Color get _modeColor {
    switch (_mode) {
      case NhieMode.classic:
        return AppColors.neonPink;
      case NhieMode.wild:
        return AppColors.neonOrange;
      case NhieMode.party:
        return AppColors.neonCyan;
      case NhieMode.chaos:
        return AppColors.dareRed;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  bool get _hapticsEnabled => context.read<PreferencesService>().hapticsEnabled;

  @override
  Widget build(BuildContext context) {
    final player = _gamePlayers[_currentPlayerIndex % _gamePlayers.length];

    if (_showLeaderboard) return _buildLeaderboard();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showLeaveGameDialog(context);
        if (leave == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A0518), Color(0xFF18082E), Color(0xFF0A0518)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 4),
                _buildModeSelector(),
                const SizedBox(height: 8),
                _buildPlayerStrip(context.read<PlayerManager>(), player.name),
                const SizedBox(height: 8),
                _buildPlayerTurn(player.name),
                Expanded(child: _buildStatementCard()),
                if (_isRevealed) _buildScoreButtons(),
                _buildBottomActions(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _showExitDialog(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          Text('NEVER HAVE I EVER',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _modeColor,
                letterSpacing: 2,
              )),
          IconButton(
            onPressed: () => setState(() => _showLeaderboard = true),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.leaderboard_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: NhieMode.values.map((mode) {
          final isActive = _mode == mode;
          final color = _colorForMode(mode);
          return GestureDetector(
            onTap: () {
              HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled);
              setState(() => _mode = mode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? color.withAlpha(30) : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isActive ? color : AppColors.surfaceBright),
              ),
              child: Text(mode.name.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive ? color : AppColors.textMuted,
                    letterSpacing: 1,
                  )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _colorForMode(NhieMode m) {
    switch (m) {
      case NhieMode.classic:
        return AppColors.neonPink;
      case NhieMode.wild:
        return AppColors.neonOrange;
      case NhieMode.party:
        return AppColors.neonCyan;
      case NhieMode.chaos:
        return AppColors.dareRed;
    }
  }

  Widget _buildPlayerStrip(PlayerManager pm, String currentName) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _gamePlayers.length,
        itemBuilder: (_, i) {
          final p = _gamePlayers[i];
          final isActive = p.name == currentName;
          final drinks = _drinkCounts[p.name] ?? 0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? _modeColor.withAlpha(25)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isActive ? _modeColor : AppColors.surfaceBright,
                  width: isActive ? 2 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isActive ? _modeColor : AppColors.textMuted,
                    )),
                if (drinks > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.dareRed.withAlpha(50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('$drinks',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dareRed,
                        )),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerTurn(String name) {
    return FadeIn(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("$name's turn",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          )),
    ));
  }

  Widget _buildStatementCard() {
    final stmt = _currentStatement;
    return GestureDetector(
      onTap: _isRevealed ? null : _revealCard,
      child: Center(
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (_, __) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                    scale: Tween(begin: 0.85, end: 1.0).animate(
                      CurvedAnimation(
                          parent: anim, curve: Curves.easeOutBack),
                    ),
                    child: child),
              ),
              child: _isRevealed
                  ? _buildRevealedCard(stmt)
                  : _buildHiddenCard(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHiddenCard() {
    return Container(
      key: const ValueKey('hidden'),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [_modeColor.withAlpha(25), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
            color: _modeColor.withAlpha(
                (80 + 60 * _glowController.value).toInt()),
            width: 2),
        boxShadow: [
          BoxShadow(
            color: _modeColor
                .withAlpha((30 * _glowController.value).toInt()),
            blurRadius: 40,
            spreadRadius: -10,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.front_hand_rounded, color: _modeColor, size: 56),
          const SizedBox(height: 24),
          Text('TAP TO REVEAL',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _modeColor,
                letterSpacing: 3,
              )),
          const SizedBox(height: 8),
          Text('Are you ready?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textMuted,
              )),
        ],
      ),
    );
  }

  Widget _buildRevealedCard(Map<String, dynamic> stmt) {
    return Container(
      key: const ValueKey('revealed'),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: _isLegendary
            ? LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withAlpha(30),
                  AppColors.surface
                ],
              )
            : LinearGradient(
                colors: [_modeColor.withAlpha(20), AppColors.surface]),
        border: Border.all(
            color: _isLegendary ? const Color(0xFFFFD700) : _modeColor,
            width: 2.5),
        boxShadow: [
          BoxShadow(
            color: (_isLegendary ? const Color(0xFFFFD700) : _modeColor)
                .withAlpha(50),
            blurRadius: 40,
            spreadRadius: -5,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLegendary) ...[
              FadeInDown(
                  child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withAlpha(100)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                    Text('LEGENDARY',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFFD700),
                          letterSpacing: 2,
                        )),
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFD700), size: 14),
                  ],
                ),
              )),
              const SizedBox(height: 20),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _modeColor.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.front_hand_rounded,
                  color: _isLegendary
                      ? const Color(0xFFFFD700)
                      : _modeColor,
                  size: 44),
            ),
            const SizedBox(height: 20),
            Text(stmt['text'] ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.35,
                )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#${stmt['category']?.toString().toUpperCase() ?? 'RANDOM'}',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Score tracking buttons — mark players who have done it
  Widget _buildScoreButtons() {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who has done it? Tap to mark:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMuted,
                )),
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _gamePlayers.length,
                itemBuilder: (_, i) {
                  final p = _gamePlayers[i];
                  final drinks = _drinkCounts[p.name] ?? 0;
                  return GestureDetector(
                    onTap: () => _markHasDone(p.name),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.dareRed.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.dareRed.withAlpha(100)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.front_hand_rounded,
                              color: AppColors.dareRed, size: 14),
                          const SizedBox(width: 4),
                          Text(p.name,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dareRed,
                              )),
                          if (drinks > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.dareRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('$drinks',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  )),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    if (!_isRevealed) return const SizedBox.shrink();
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            Expanded(
                child: _buildActionButton(
                    'I HAVE', AppColors.dareRed, Icons.front_hand_rounded)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildActionButton(
                    'I HAVEN\'T', AppColors.neonGreen, Icons.thumb_up_rounded)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticService.instance.trigger(HapticEvent.cardReveal, hapticsEnabled: _hapticsEnabled);
        _nextStatement();
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(120), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    final sorted = _gamePlayers.toList()
      ..sort((a, b) =>
          (_drinkCounts[b.name] ?? 0).compareTo(_drinkCounts[a.name] ?? 0));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          setState(() => _showLeaderboard = false),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('DRINK LEADERBOARD',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.dareRed,
                          letterSpacing: 2,
                        )),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) {
                    final p = sorted[i];
                    final drinks = _drinkCounts[p.name] ?? 0;
                    final medals = [
                      AppColors.gold,
                      AppColors.textSecondary,
                      AppColors.neonOrange
                    ];
                    final medalColor =
                        i < 3 ? medals[i] : AppColors.textMuted;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: i == 0
                                ? AppColors.gold.withAlpha(80)
                                : AppColors.surfaceBright),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: medalColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text('${i + 1}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  color: medalColor,
                                )),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Text(p.name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ))),
                          Row(
                            children: [
                              const Icon(Icons.local_bar_rounded,
                                  color: AppColors.dareRed, size: 18),
                              const SizedBox(width: 4),
                              Text('$drinks',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.dareRed,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _modeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () =>
                        setState(() => _showLeaderboard = false),
                    child: Text('KEEP PLAYING',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text('Leave Game?',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              content: Text('Are you sure?',
                  style: GoogleFonts.poppins(
                      color: AppColors.textSecondary)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Stay',
                        style: GoogleFonts.poppins(
                            color: AppColors.textMuted))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Text('Leave',
                        style: GoogleFonts.poppins(
                            color: AppColors.dareRed))),
              ],
            ));
  }
}
