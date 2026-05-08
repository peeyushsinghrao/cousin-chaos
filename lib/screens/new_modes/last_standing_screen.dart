import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../services/player_manager.dart';
import '../../models/player.dart';

class LastStandingScreen extends StatefulWidget {
  const LastStandingScreen({super.key});

  @override
  State<LastStandingScreen> createState() => _LastStandingScreenState();
}

class _LastStandingScreenState extends State<LastStandingScreen> {
  final Random _random = Random();
  bool _isPlaying = false;
  String _currentChallenge = '';
  int _timeElapsed = 0;
  Timer? _timer;
  
  List<Player> _activePlayers = [];
  List<Player> _eliminatedPlayers = [];

  final List<String> _challenges = [
    'One leg balance (eyes closed)',
    'Wall sit',
    'No blinking',
    'Hold your breath',
    'Plank position',
    'Stand on tiptoes',
    'Arm wrestling (tournament style)',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final players = context.read<PlayerManager>().players;
      if (players.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Need at least 2 players! Configure them in settings.'))
        );
        Navigator.pop(context);
        return;
      }
      _resetGame();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _activePlayers = List.from(context.read<PlayerManager>().players);
      _eliminatedPlayers = [];
      _currentChallenge = _challenges[_random.nextInt(_challenges.length)];
      _isPlaying = false;
      _timeElapsed = 0;
      _timer?.cancel();
    });
  }

  void _startGame() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPlaying = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _timeElapsed++);
    });
  }

  void _eliminatePlayer(Player player) {
    if (!_isPlaying || _activePlayers.length <= 1) return;
    
    HapticFeedback.heavyImpact();
    setState(() {
      _activePlayers.removeWhere((p) => p.id == player.id);
      _eliminatedPlayers.add(player);
    });

    if (_activePlayers.length == 1) {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activePlayers.isEmpty) return const Scaffold(backgroundColor: AppColors.background);

    final isGameOver = _isPlaying && _activePlayers.length == 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'LAST STANDING',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonGreen,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.neonGreen.withAlpha(30), AppColors.background],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: isGameOver ? _buildWinnerScreen() : _buildGameScreen(),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.neonGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withAlpha(40),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'CHALLENGE',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neonGreen,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _currentChallenge,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        Text(
          _formatTime(_timeElapsed),
          style: GoogleFonts.poppins(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: _isPlaying ? Colors.white : AppColors.textMuted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        
        if (!_isPlaying)
          Padding(
            padding: const EdgeInsets.all(24),
            child: GestureDetector(
              onTap: _startGame,
              child: Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'START CHALLENGE',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
        if (_isPlaying) ...[
          const SizedBox(height: 16),
          Text(
            'TAP A PLAYER TO ELIMINATE THEM',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.dareRed,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _activePlayers.length,
              itemBuilder: (context, index) {
                final player = _activePlayers[index];
                return FadeInLeft(
                  key: ValueKey(player.id),
                  child: GestureDetector(
                    onTap: () => _eliminatePlayer(player),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBright),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            player.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(Icons.close_rounded, color: AppColors.dareRed),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWinnerScreen() {
    final winner = _activePlayers.first;
    
    return Center(
      child: ZoomIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.neonYellow, size: 120),
            const SizedBox(height: 24),
            Text(
              'LAST STANDING',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.neonGreen,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              winner.name,
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Time: ${_formatTime(_timeElapsed)}',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 64),
            GestureDetector(
              onTap: _resetGame,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PLAY AGAIN',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
