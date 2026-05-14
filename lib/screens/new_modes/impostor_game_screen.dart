import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/impostor_data.dart';
import '../../core/theme/app_colors.dart';
import '../../models/impostor_player.dart';

enum ImpostorPhase { passDevice, reveal, discussion, vote, result }

class ImpostorGameScreen extends StatefulWidget {
  final String category;
  final int? timeLimitSeconds;
  final bool timeLimitEnabled;
  final List<ImpostorPlayer> players;

  const ImpostorGameScreen({
    super.key,
    required this.category,
    required this.players,
    this.timeLimitSeconds,
    this.timeLimitEnabled = true,
  });

  @override
  State<ImpostorGameScreen> createState() => _ImpostorGameScreenState();
}

class _ImpostorGameScreenState extends State<ImpostorGameScreen> {
  final Random _random = Random();
  ImpostorPhase _currentPhase = ImpostorPhase.passDevice;
  
  List<ImpostorPlayer> _players = [];
  int _currentPlayerIndex = 0;
  
  List<String> _impostorIds = [];
  String _secretWord = '';
  
  bool _isRevealing = false;
  
  // Timer for discussion
  int _timeLeft = 300; // 5 minutes default
  Timer? _discussionTimer;

  ImpostorPlayer? _votedPlayer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  @override
  void dispose() {
    _discussionTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    if (widget.players.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impostor Mode requires at least 3 players!'))
      );
      Navigator.pop(context);
      return;
    }
    
    _players = List.from(widget.players)..shuffle();
    _currentPlayerIndex = 0;
    
    // Set timer based on widget parameters
    if (widget.timeLimitEnabled && widget.timeLimitSeconds != null) {
      _timeLeft = widget.timeLimitSeconds!;
    } else {
      _timeLeft = 300; // Default 5 minutes
    }
    
    int impostorCount = _getRecommendedImpostorCount(_players.length);
    final selectedImpostors = List.from(_players)..shuffle();
    _impostorIds = selectedImpostors.take(impostorCount).map((p) => p.id as String).toList();
    
    final words = ImpostorData.categories[widget.category] ?? ['Mystery'];
    _secretWord = words[_random.nextInt(words.length)];
    
    setState(() {
      _currentPhase = ImpostorPhase.passDevice;
    });
  }

  void _startDiscussionTimer() {
    _discussionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  int _getRecommendedImpostorCount(int playerCount) {
    if (playerCount <= 7) return 1;
    if (playerCount <= 9) return 2;
    if (playerCount <= 11) return 3;
    if (playerCount <= 13) return 4;
    if (playerCount <= 15) return 5;
    if (playerCount <= 17) return 6;
    if (playerCount <= 19) return 7;
    return 8;
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
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          onPressed: () async {
            final shouldLeave = await _showLeaveDialog();
            if (shouldLeave == true && context.mounted) Navigator.pop(context);
          },
        ),
        title: Text(
          'IMPOSTOR',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonPink,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              _currentPhase == ImpostorPhase.result && (_votedPlayer != null && _impostorIds.contains(_votedPlayer!.id)) 
                ? AppColors.neonGreen.withAlpha(40) 
                : AppColors.neonPink.withAlpha(40), 
              AppColors.background
            ],
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
      case ImpostorPhase.passDevice:
        return _buildPassDevicePhase();
      case ImpostorPhase.reveal:
        return _buildRevealPhase();
      case ImpostorPhase.discussion:
        return _buildDiscussionPhase();
      case ImpostorPhase.vote:
        return _buildVotePhase();
      case ImpostorPhase.result:
        return _buildResultPhase();
    }
  }

  Widget _buildPassDevicePhase() {
    final player = _players[_currentPlayerIndex];
    return FadeIn(
      key: ValueKey('pass_${player.id}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.screen_rotation_rounded, color: AppColors.neonPink, size: 80),
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
          _buildActionButton('I AM ${player.name.toUpperCase()}', AppColors.neonPink, () {
            setState(() {
              _currentPhase = ImpostorPhase.reveal;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildRevealPhase() {
    final player = _players[_currentPlayerIndex];
    final isImpostor = _impostorIds.contains(player.id);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isRevealing) ...[
          const Icon(Icons.visibility_off_rounded, color: AppColors.textMuted, size: 80),
          const SizedBox(height: 32),
          Text(
            'Ensure nobody else can see the screen.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 64),
          GestureDetector(
            onTapDown: (_) {
              HapticFeedback.heavyImpact();
              setState(() => _isRevealing = true);
            },
            onTapUp: (_) => _handleRevealComplete(),
            onTapCancel: () => _handleRevealComplete(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBright, width: 2),
              ),
              child: Center(
                child: Text(
                  'PRESS & HOLD TO REVEAL',
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
        ] else ...[
          FadeIn(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isImpostor ? AppColors.dareRed : AppColors.truthBlue,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isImpostor ? Icons.warning_amber_rounded : Icons.vpn_key_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    isImpostor ? 'YOU ARE THE IMPOSTOR!' : 'THE SECRET WORD IS:',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isImpostor ? 'FAKE IT!' : _secretWord,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _handleRevealComplete() {
    if (!_isRevealing) return;
    setState(() {
      _isRevealing = false;
      _currentPlayerIndex++;
      if (_currentPlayerIndex >= _players.length) {
        _currentPhase = ImpostorPhase.discussion;
        _startDiscussionTimer();
      } else {
        _currentPhase = ImpostorPhase.passDevice;
      }
    });
  }

  Future<bool?> _showLeaveDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Leave Game?',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Your progress will be lost. Are you sure?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'LEAVE',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.dareRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVoteConfirmationDialog(ImpostorPlayer player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Vote to Eliminate?',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to eliminate ${player.name}? This will end the game.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _votedPlayer = player;
                _currentPhase = ImpostorPhase.result;
              });
            },
            child: Text(
              'ELIMINATE',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.dareRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionPhase() {
    final m = _timeLeft ~/ 60;
    final s = _timeLeft % 60;
    
    return FadeIn(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.forum_rounded, color: AppColors.neonPink, size: 80),
          const SizedBox(height: 32),
          Text(
            'TIME TO DISCUSS',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Each player gives ONE clue about the word. Impostors must try to blend in!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
            style: GoogleFonts.poppins(
              fontSize: 80,
              fontWeight: FontWeight.w900,
              color: _timeLeft <= 30 ? AppColors.dareRed : Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 64),
          _buildActionButton('FINISH & VOTE', AppColors.neonPink, () {
            _discussionTimer?.cancel();
            setState(() {
              _currentPhase = ImpostorPhase.vote;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildVotePhase() {
    return FadeInRight(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'WHO IS THE IMPOSTOR?',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.dareRed,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discuss and vote. Tap the eliminated player.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                        _showVoteConfirmationDialog(player);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dareRed.withAlpha(50)),
                    ),
                    child: Center(
                      child: Text(
                        player.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultPhase() {
    final bool civiliansWin = _impostorIds.contains(_votedPlayer!.id);
    final impostorNames = _players.where((p) => _impostorIds.contains(p.id)).map((p) => p.name).join(' & ');

    return Center(
      child: ZoomIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              civiliansWin ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
              color: civiliansWin ? AppColors.neonGreen : AppColors.dareRed,
              size: 120,
            ),
            const SizedBox(height: 24),
            Text(
              civiliansWin ? 'CIVILIANS WIN!' : 'IMPOSTOR WINS!',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: civiliansWin ? AppColors.neonGreen : AppColors.dareRed,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBright),
              ),
              child: Column(
                children: [
                  Text(
                    'The impostors were:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    impostorNames,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(color: AppColors.surfaceBright, height: 32, thickness: 1),
                  Text(
                    'The secret word was:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _secretWord,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.truthBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            _buildActionButton('PLAY AGAIN', AppColors.neonPink, () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
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
