import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/pack.dart';
import '../../services/player_manager.dart';
import '../../services/pack_manager.dart';
import '../../services/api_service.dart';
import 'player_setup_screen.dart';
import 'widgets/physics_wheel.dart';
import 'widgets/prompt_card.dart';

enum GamePhase { spinPlayer, spinType, showCard }

class GameEngineScreen extends StatefulWidget {
  final GameMode gameMode;
  const GameEngineScreen({super.key, required this.gameMode});

  @override
  State<GameEngineScreen> createState() => _GameEngineScreenState();
}

class _GameEngineScreenState extends State<GameEngineScreen> {
  GamePhase _phase = GamePhase.spinPlayer;
  List<GameCardPrompt> _truths = [];
  List<GameCardPrompt> _dares = [];
  
  String? _selectedPlayerName;
  String? _selectedType;
  GameCardPrompt? _currentPrompt;
  int _currentPlayerIndex = 0;
  bool _isLoadingApi = false;
  bool _isPunishmentRound = false;
  bool _showLeaderboard = false;
  List<String> _currentWheelItems = [];
  bool _is18Plus = false;

  @override
  void initState() {
    super.initState();
    _loadDeck();
    _generateWheelItems();
  }

  void _generateWheelItems() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final playerNames = context.read<PlayerManager>().players.map((p) => p.name).toList();
      final items = List<String>.from(playerNames);
      if (Random().nextDouble() < 0.20) {
        items.add('Everyone');
      }
      items.shuffle();
      setState(() => _currentWheelItems = items);
    });
  }

  void _loadDeck() {
    final packManager = context.read<PackManager>();
    _is18Plus = packManager.hasAny18PlusSelected;
    final deck = packManager.getMergedDeck();
    _truths = deck.where((p) => p.type == 'truth').toList();
    _dares = deck.where((p) => p.type == 'dare').toList();
    // Preload matching API prompts in background
    _preloadApiPrompts();
  }

  Future<void> _preloadApiPrompts() async {
    final apiTruths = await ApiService.fetchTruths(5, is18Plus: _is18Plus);
    final apiDares = await ApiService.fetchDares(5, is18Plus: _is18Plus);
    if (!mounted) return;
    setState(() {
      _truths.addAll(apiTruths);
      _dares.addAll(apiDares);
      _truths.shuffle();
      _dares.shuffle();
    });
  }

  Future<void> _fetchSinglePrompt(String type) async {
    setState(() => _isLoadingApi = true);
    GameCardPrompt? prompt;
    if (type == 'truth') {
      prompt = await ApiService.fetchTruth(is18Plus: _is18Plus);
    } else {
      prompt = await ApiService.fetchDare(is18Plus: _is18Plus);
    }
    if (!mounted) return;
    if (prompt != null) {
      setState(() {
        _currentPrompt = prompt;
        _isLoadingApi = false;
      });
    } else {
      _pickFromLocalDeck(type);
      setState(() => _isLoadingApi = false);
    }
  }

  void _pickFromLocalDeck(String type) {
    final list = type == 'truth' ? _truths : _dares;
    if (list.isNotEmpty) {
      _currentPrompt = list[Random().nextInt(list.length)];
    } else {
      _currentPrompt = GameCardPrompt(
        id: 'fallback',
        text: type == 'truth' 
            ? "Tell us something nobody knows about you." 
            : "Do something embarrassing for 30 seconds.",
        type: type,
      );
    }
  }

  void _onPlayerSelected(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedPlayerName = _currentWheelItems[index];
      _phase = GamePhase.spinType;
    });
  }

  /// Called when the wheel lands on truth/dare
  void _onTypeSelected(int index) {
    final type = (index % 2 == 0) ? 'truth' : 'dare';
    _selectType(type);
  }

  /// Called by both the wheel result AND the manual tap buttons
  void _selectType(String type) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedType = type;
    });

    // Pick from local deck first (instant), then try API in background
    _pickFromLocalDeck(type);
    setState(() => _phase = GamePhase.showCard);

    _fetchSinglePrompt(type); // will update _currentPrompt if API succeeds
  }

  void _handleSkip() {
    final playerManager = context.read<PlayerManager>();
    if (playerManager.players.isEmpty) return;
    final currentPlayer = playerManager.players[_currentPlayerIndex % playerManager.players.length];
    final updatedTokens = currentPlayer.skipTokens + 1;
    playerManager.updatePlayerSkipTokens(currentPlayer.id, updatedTokens);

    if (updatedTokens >= 3) {
      setState(() {
        _isPunishmentRound = true;
        _currentPrompt = GameCardPrompt(
          id: 'punishment',
          text: 'GROUP DARE: Everyone performs a challenge together! No skips allowed.',
          type: 'dare',
        );
        _phase = GamePhase.showCard;
      });
      return;
    }

    _onNextPlayer();
  }

  void _toggleLeaderboard() {
    setState(() {
      _showLeaderboard = !_showLeaderboard;
    });
  }

  void _onNextPlayer() {
    final playerManager = context.read<PlayerManager>();
    setState(() {
      _isPunishmentRound = false;
      _currentPlayerIndex = (_currentPlayerIndex + 1) % playerManager.players.length;

      if (widget.gameMode == GameMode.oneAtATime) {
        _selectedPlayerName = playerManager.players[_currentPlayerIndex].name;
        _phase = GamePhase.spinType;
      } else {
        _phase = GamePhase.spinPlayer;
        _selectedPlayerName = null;
        _generateWheelItems();
      }
      _selectedType = null;
      _currentPrompt = null;
    });
  }

  void _showManagePlayers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Manage Players',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<PlayerManager>(
                builder: (context, pm, _) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: pm.players.length,
                      itemBuilder: (context, index) {
                        final player = pm.players[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.surfaceBright),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (pm.players.length > 2)
                                IconButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    pm.removePlayer(player.id);
                                  },
                                  icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.dareRed, size: 22),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerManager = context.watch<PlayerManager>();
    final playerNames = playerManager.players.map((p) => p.name).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Text('Leave Game?', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
                            content: Text('Are you sure you want to quit?', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Stay', style: GoogleFonts.poppins(color: AppColors.textMuted)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                                child: Text('Leave', style: GoogleFonts.poppins(color: AppColors.dareRed)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    Text(
                      _phase == GamePhase.spinPlayer
                          ? "WHO'S NEXT?"
                          : _phase == GamePhase.spinType
                              ? 'TRUTH OR DARE?'
                              : (_selectedType?.toUpperCase() ?? ''),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      onPressed: _showManagePlayers,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.people_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              // Game Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: _buildPhase(playerNames),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhase(List<String> playerNames) {
    switch (_phase) {
      case GamePhase.spinPlayer:
        if (widget.gameMode == GameMode.oneAtATime) {
          // Skip wheel, auto-select next player
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_phase == GamePhase.spinPlayer) {
              _selectedPlayerName = playerNames[_currentPlayerIndex % playerNames.length];
              setState(() => _phase = GamePhase.spinType);
            }
          });
          return const SizedBox.shrink(key: ValueKey('loading'));
        }
        return Column(
          key: const ValueKey('spinPlayer'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Text(
                'Flick to Spin! 👆',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 30),
            PhysicsWheel(
              items: _currentWheelItems.isEmpty ? ['Loading...'] : _currentWheelItems,
              onSpinComplete: _onPlayerSelected,
            ),
          ],
        );

      case GamePhase.spinType:
        return SingleChildScrollView(
          key: const ValueKey('spinType'),
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              FadeInDown(
                child: Text(
                  '${_selectedPlayerName ?? ''} is up!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Spin the wheel or choose below',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PhysicsWheel(
                items: const ['😇 Truth', '😈 Dare', '😇 Truth', '😈 Dare'],
                sliceColors: const [
                  AppColors.truthBlue,
                  AppColors.dareRed,
                  AppColors.truthBlueDark,
                  AppColors.dareRedDark,
                ],
                onSpinComplete: _onTypeSelected,
              ),
              const SizedBox(height: 28),
              // ── MANUAL TRUTH / DARE BUTTONS ──
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        'OR PICK DIRECTLY',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildManualButton(
                              label: 'TRUTH',
                              icon: Icons.lightbulb_rounded,
                              color: AppColors.truthBlue,
                              onTap: () => _selectType('truth'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildManualButton(
                              label: 'DARE',
                              icon: Icons.local_fire_department_rounded,
                              color: AppColors.dareRed,
                              onTap: () => _selectType('dare'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );

      case GamePhase.showCard:
        if (_currentPrompt == null || _isLoadingApi) {
          return Center(
            key: const ValueKey('loading'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryNeon),
                const SizedBox(height: 16),
                Text(
                  'Drawing card...',
                  style: GoogleFonts.poppins(color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          key: const ValueKey('showCard'),
          child: PromptCard(
            playerName: _selectedPlayerName ?? 'Player',
            prompt: _currentPrompt!,
            onNext: _onNextPlayer,
          ),
        );
    }
  }

  Widget _buildManualButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(120), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(25),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
