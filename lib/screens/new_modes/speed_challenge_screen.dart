import 'package:cousin_chaos/core/icons.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/leave_game_dialog.dart';
import '../../models/player.dart';
import '../../services/player_manager.dart';
import '../../services/session_service.dart';

class SpeedChallenge {
  final String text;
  final int seconds;
  SpeedChallenge(this.text, this.seconds);
}

class SpeedChallengeScreen extends StatefulWidget {
  const SpeedChallengeScreen({super.key});

  @override
  State<SpeedChallengeScreen> createState() => _SpeedChallengeScreenState();
}

class _SpeedChallengeScreenState extends State<SpeedChallengeScreen> {
  final Random _random = Random();
  late SpeedChallenge _currentChallenge;
  bool _isRunning = false;
  int _timeLeft = 0;
  Timer? _timer;
  final Set<int> _recentIndices = {};

  bool _isLastStanding = false;
  List<Player> _activePlayers = [];
  List<Player> _eliminatedPlayers = [];
  String? _winnerId;

  late ConfettiController _confettiController;

  final List<SpeedChallenge> _challenges = [
    SpeedChallenge('Name 5 anime series', 7),
    SpeedChallenge('Do 15 jumping jacks', 20),
    SpeedChallenge('Name 3 countries starting with A', 5),
    SpeedChallenge('Find a yellow item in the room', 10),
    SpeedChallenge('Say the alphabet backwards from Z to P', 15),
    SpeedChallenge('Touch your toes 10 times', 15),
    SpeedChallenge('Name 4 Marvel movies', 6),
    SpeedChallenge('Recite the months in reverse', 8),
    SpeedChallenge('Name 5 sports that use a ball', 6),
    SpeedChallenge('Do 10 sit-ups', 18),
    SpeedChallenge('Name 3 things in this room that are blue', 5),
    SpeedChallenge('Say tongue twister: "She sells seashells" 3x', 10),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _nextChallenge();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pm = context.read<PlayerManager>();
      _activePlayers = List.from(pm.players);
      if (pm.players.length < 2) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Add Players First', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: const Text('Go to the Players tab and add at least 2 players to start a game.', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                child: Text('Go to Players', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _nextChallenge() {
    _timer?.cancel();
    int idx;
    do {
      idx = _random.nextInt(_challenges.length);
    } while (_recentIndices.contains(idx) &&
        _recentIndices.length < _challenges.length);
    _recentIndices.add(idx);
    if (_recentIndices.length >= _challenges.length) _recentIndices.clear();
    _currentChallenge = _challenges[idx];
    _timeLeft = _currentChallenge.seconds;
    _isRunning = false;
    setState(() {});
  }

  void _startTimer() {
    if (_isRunning || _timeLeft <= 0) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
        if (_timeLeft <= 3) HapticFeedback.selectionClick();
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
        HapticFeedback.heavyImpact();
        if (_isLastStanding && _activePlayers.length > 1) {
          _showEliminationDialog();
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _currentChallenge.seconds;
    });
  }

  void _showEliminationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.timer_off_rounded, color: AppColors.dareRed),
            const SizedBox(width: 8),
            Text('Time\'s Up!', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who failed the challenge?', style: GoogleFonts.sora(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            ..._activePlayers.map((p) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _eliminatePlayer(p);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.dareRed.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.dareRed.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.userX, color: AppColors.dareRed, size: 16),
                    const SizedBox(width: 10),
                    Text(p.name, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _nextChallenge();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('Everyone passed — next challenge', style: GoogleFonts.sora(color: Colors.white54, fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminatePlayer(Player player) {
    setState(() {
      _activePlayers.removeWhere((p) => p.name == player.name);
      _eliminatedPlayers.add(player);
    });

    if (_activePlayers.length == 1) {
      _winnerId = _activePlayers.first.name;
      _confettiController.play();
      _saveSessionAndShowXp();
    } else {
      _nextChallenge();
    }
  }

  Future<void> _saveSessionAndShowXp() async {
    final pm = context.read<PlayerManager>();
    final allPlayers = pm.players.map((p) => p.name).toList();
    await SessionService.saveSession(SessionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mode: 'Speed Challenge',
      playedAt: DateTime.now(),
      players: allPlayers,
      winner: _winnerId ?? '',
      themeColor: 'red',
    ));
    
  }

  void _resetLastStanding() {
    final pm = context.read<PlayerManager>();
    setState(() {
      _activePlayers = List.from(pm.players);
      _eliminatedPlayers = [];
      _winnerId = null;
    });
    _nextChallenge();
  }

  @override
  Widget build(BuildContext context) {
    if (_winnerId != null) return _buildWinnerScreen();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final should = await showLeaveGameDialog(context);
        if (should == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.dareRed.withAlpha(40),
                    AppColors.background
                  ],
                  radius: 1.2,
                  center: Alignment.topCenter,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildModeToggle(),
                  if (_isLastStanding) _buildLastStandingPlayers(),
                  const SizedBox(height: 12),
                  Expanded(child: _buildMain()),
                  _buildControls(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.gold,
                ],
                numberOfParticles: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastStandingPlayers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          ..._activePlayers.map((p) => Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neonGreen.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: AppColors.neonGreen, size: 8),
                const SizedBox(width: 6),
                Text(p.name, style: GoogleFonts.sora(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
          ..._eliminatedPlayers.map((p) => Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.dareRed.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.dareRed.withAlpha(40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.close, color: AppColors.dareRed, size: 10),
                const SizedBox(width: 6),
                Text(p.name, style: GoogleFonts.sora(color: AppColors.textMuted, fontSize: 12, decoration: TextDecoration.lineThrough)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWinnerScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF2D0A0A), AppColors.background],
                radius: 1.5,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [AppColors.gold, AppColors.neonGreen, AppColors.primary],
              numberOfParticles: 60,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFF6B00)]),
                      boxShadow: [BoxShadow(color: AppColors.gold.withAlpha(80), blurRadius: 40, spreadRadius: 10)],
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 60),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text('LAST STANDING!', style: GoogleFonts.sora(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: AppColors.textMuted, letterSpacing: 4,
                  )),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [AppColors.gold, Color(0xFFFF6B00)],
                    ).createShader(b),
                    child: Text(_winnerId!, style: GoogleFonts.sora(
                      fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white,
                    )),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Text('wins the Speed Challenge!', style: GoogleFonts.sora(
                    fontSize: 18, color: Colors.white70,
                  )),
                ),
                const SizedBox(height: 48),
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _resetLastStanding();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.dareRed,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: AppColors.dareRed.withAlpha(60), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Text('Play Again', style: GoogleFonts.sora(
                            fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                          )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.surfaceLight),
                          ),
                          child: Text('Exit', style: GoogleFonts.sora(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70,
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(LucideIcons.arrowLeft,
                  color: Colors.white, size: 18),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'SPEED CHALLENGE',
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.dareRed,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ToggleButton(
                label: 'Normal Mode',
                active: !_isLastStanding,
                onTap: () => setState(() => _isLastStanding = false),
              ),
            ),
            Expanded(
              child: _ToggleButton(
                label: 'Last Standing',
                active: _isLastStanding,
                onTap: () => setState(() => _isLastStanding = true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        Text(
          '00:${_timeLeft.toString().padLeft(2, '0')}',
          style: GoogleFonts.sora(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: _timeLeft <= 3 && _isRunning
                ? AppColors.dareRed
                : Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: LucideIcons.play,
              color: AppColors.neonGreen,
              onTap: _startTimer,
              disabled: _isRunning || _timeLeft == 0,
            ),
            const SizedBox(width: 16),
            _buildControlButton(
              icon: LucideIcons.pause,
              color: AppColors.neonYellow,
              onTap: _stopTimer,
              disabled: !_isRunning,
            ),
            const SizedBox(width: 16),
            _buildControlButton(
              icon: LucideIcons.refreshCw,
              color: AppColors.truthBlue,
              onTap: _resetTimer,
              disabled: _isRunning && _timeLeft > 0,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: FadeInUp(
              key: ValueKey(_currentChallenge.text),
              duration: const Duration(milliseconds: 400),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: AppColors.dareRed.withAlpha(80), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dareRed.withAlpha(30),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_rounded,
                        color: AppColors.dareRed, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      _currentChallenge.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sora(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_currentChallenge.seconds}s',
                      style: TextStyle(
                          color: AppColors.dareRed,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _nextChallenge();
        },
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.dareRed,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.dareRed.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'NEXT CHALLENGE',
              style: GoogleFonts.sora(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.surfaceLight
              : color.withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(
            color: disabled ? Colors.transparent : color,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: disabled ? AppColors.textMuted : color,
          size: 28,
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.dareRed : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.sora(
              color: active ? Colors.white : Colors.white38,
              fontWeight:
                  active ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
