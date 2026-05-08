import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../core/theme/app_colors.dart';
import '../../services/player_manager.dart';
import '../../models/player.dart';

enum SecretMissionPhase { setup, passDevice, revealMission, gameActive, reviewResults }

class SecretMissionScreen extends StatefulWidget {
  const SecretMissionScreen({super.key});

  @override
  State<SecretMissionScreen> createState() => _SecretMissionScreenState();
}

class _SecretMissionScreenState extends State<SecretMissionScreen> {
  final Random _random = Random();
  SecretMissionPhase _currentPhase = SecretMissionPhase.setup;
  
  List<Player> _players = [];
  int _currentPlayerIndex = 0;
  
  final Map<String, String> _playerMissions = {};
  final Map<String, bool> _playerResults = {};

  final List<String> _missions = [
    'Make someone say "bro" 3 times',
    'Get a high five secretly without explaining why',
    'Yawn loudly and make at least one other person yawn',
    'Bring up the weather in a totally unrelated conversation',
    'Convince someone you forgot their name for a second',
    'Steal a small object (like a pen) and return it without them noticing',
    'Use the word "bamboozle" naturally in a sentence',
    'Sigh heavily until someone asks if you are okay',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _players = context.read<PlayerManager>().players;
      if (_players.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Need at least 2 players! Configure them in settings.'))
        );
        Navigator.pop(context);
        return;
      }
      
      // Assign random unique missions
      final availableMissions = List<String>.from(_missions)..shuffle();
      for (int i = 0; i < _players.length; i++) {
        _playerMissions[_players[i].id] = availableMissions[i % availableMissions.length];
        _playerResults[_players[i].id] = false;
      }
      
      setState(() {
        _currentPhase = SecretMissionPhase.passDevice;
      });
    });
  }

  void _nextPhase() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentPhase == SecretMissionPhase.passDevice) {
        _currentPhase = SecretMissionPhase.revealMission;
      } else if (_currentPhase == SecretMissionPhase.revealMission) {
        _currentPlayerIndex++;
        if (_currentPlayerIndex >= _players.length) {
          _currentPhase = SecretMissionPhase.gameActive;
        } else {
          _currentPhase = SecretMissionPhase.passDevice;
        }
      } else if (_currentPhase == SecretMissionPhase.gameActive) {
        _currentPlayerIndex = 0;
        _currentPhase = SecretMissionPhase.reviewResults;
      } else if (_currentPhase == SecretMissionPhase.reviewResults) {
        _currentPlayerIndex++;
        if (_currentPlayerIndex >= _players.length) {
          Navigator.pop(context); // End game
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_players.isEmpty) return const Scaffold(backgroundColor: AppColors.background);

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
          'SECRET MISSION',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNeon,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.primaryNeon.withAlpha(30), AppColors.background],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentPhase) {
      case SecretMissionPhase.setup:
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon));
      case SecretMissionPhase.passDevice:
        return _buildPassDeviceScreen();
      case SecretMissionPhase.revealMission:
        return _buildRevealMissionScreen();
      case SecretMissionPhase.gameActive:
        return _buildGameActiveScreen();
      case SecretMissionPhase.reviewResults:
        return _buildReviewResultsScreen();
    }
  }

  Widget _buildPassDeviceScreen() {
    final player = _players[_currentPlayerIndex];
    return FadeIn(
      key: ValueKey('pass_${player.id}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.screen_rotation_rounded, color: AppColors.primaryNeon, size: 80),
          const SizedBox(height: 32),
          Text(
            'PASS DEVICE TO',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            player.name,
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 64),
          _buildActionButton('I AM ${player.name.toUpperCase()}', AppColors.primaryNeon, _nextPhase),
        ],
      ),
    );
  }

  Widget _buildRevealMissionScreen() {
    final player = _players[_currentPlayerIndex];
    final mission = _playerMissions[player.id]!;
    
    return FadeInUp(
      key: ValueKey('reveal_${player.id}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primaryNeon, width: 2),
            ),
            child: Column(
              children: [
                const Icon(Icons.vpn_key_rounded, color: AppColors.primaryNeon, size: 48),
                const SizedBox(height: 24),
                Text(
                  'YOUR TOP SECRET MISSION',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryNeon,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  mission,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Do this without anyone knowing!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildActionButton('GOT IT (HIDE)', AppColors.surfaceLight, _nextPhase),
        ],
      ),
    );
  }

  Widget _buildGameActiveScreen() {
    return FadeIn(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.visibility_off_rounded, color: AppColors.primaryNeon, size: 100),
          const SizedBox(height: 32),
          Text(
            'MISSIONS ARE ACTIVE',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Play normally. Complete your mission secretly.\nTap below when the game is over.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 64),
          _buildActionButton('END GAME & REVEAL', AppColors.primaryNeon, _nextPhase),
        ],
      ),
    );
  }

  Widget _buildReviewResultsScreen() {
    final player = _players[_currentPlayerIndex];
    final mission = _playerMissions[player.id]!;
    final isLast = _currentPlayerIndex == _players.length - 1;

    return FadeInRight(
      key: ValueKey('review_${player.id}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DID THEY DO IT?',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryNeon,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            player.name,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              mission,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _playerResults[player.id] = false;
                  _nextPhase();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.dareRed.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.dareRed),
                  ),
                  child: Text('FAILED', style: GoogleFonts.poppins(color: AppColors.dareRed, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {
                  _playerResults[player.id] = true;
                  _nextPhase();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonGreen),
                  ),
                  child: Text('COMPLETED', style: GoogleFonts.poppins(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: color == AppColors.surfaceLight ? color : color.withAlpha(200),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2),
            boxShadow: color == AppColors.surfaceLight ? [] : [
              BoxShadow(
                color: color.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
