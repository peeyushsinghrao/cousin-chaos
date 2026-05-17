import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/ludo_game_state.dart';
import '../../core/models/ludo_token.dart';
import '../../core/models/ludo_player.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ludo_game_service.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';
import '../../services/haptic_service.dart';
import 'widgets/ludo_board_painter.dart';
import 'widgets/ludo_token_widget.dart';
import 'widgets/ludo_dice_widget.dart';
import 'widgets/chaos_tile_popup.dart';
import 'widgets/event_card_sheet.dart';
import 'widgets/sabotage_sheet.dart';
import 'widgets/kings_rule_sheet.dart';
import 'widgets/speed_round_overlay.dart';
import 'widgets/bounty_banner.dart';
import 'widgets/scoreboard_sheet.dart';
import 'ludo_result_screen.dart';

class LudoBoardScreen extends StatefulWidget {
  final LudoGameState gameState;

  const LudoBoardScreen({super.key, required this.gameState});

  @override
  State<LudoBoardScreen> createState() => _LudoBoardScreenState();
}

class _LudoBoardScreenState extends State<LudoBoardScreen> {
  late LudoGameState _state;
  bool _isDiceRolling = false;
  bool _speedRoundShown = false;
  Timer? _speedTimer;
  double _speedProgress = 1.0;
  bool _showChaosPopup = false;
  String _chaosPrompt = '';
  bool _chaosIsTruth = false;
  LudoToken? _pendingChaosToken;
  bool _isAnimating = false;

  // Ludo King vivid palette
  static const List<Color> _playerColors = [
    Color(0xFF1565C0), // Blue
    Color(0xFFC62828), // Red
    Color(0xFF2E7D32), // Green
    Color(0xFFF9A825), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _state = widget.gameState;
    // Draw first event card after a short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _drawEventCardForTurn();
    });
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    super.dispose();
  }

  Color get _currentColor => _playerColors[_state.currentPlayerIndex];

  // ── Event card ────────────────────────────────────────────────────────────

  Future<void> _drawEventCardForTurn() async {
    if (!mounted) return;
    final prefs = context.read<PreferencesService>();
    final card = LudoGameService.instance.drawEventCard(_state);
    final isGood = card['isGood'] as bool;

    await SoundService.instance.play(
      isGood ? SoundEvent.cardReveal : SoundEvent.wrong,
      soundEnabled: prefs.soundEnabled,
    );

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => EventCardSheet(
        card: card,
        onApply: () {
          Navigator.pop(context);
          _applyEventCard(card);
        },
      ),
    );
  }

  void _applyEventCard(Map<String, dynamic> card) {
    LudoGameService.instance.applyEventCard(_state, card);

    if (_state.currentPlayer.skipNextTurn) {
      setState(() {});
      Future.delayed(const Duration(milliseconds: 300), () {
        _state.currentPlayer.skipNextTurn = false;
        _advanceTurn();
      });
      return;
    }

    if (_state.phase == LudoPhase.giftPicker) {
      _showGiftTokenPicker(steps: 3);
      return;
    }

    setState(() => _state.phase = LudoPhase.rolling);
  }

  // ── Dice ──────────────────────────────────────────────────────────────────

  Future<void> _onRollDice() async {
    if (_isAnimating) return;
    final prefs = context.read<PreferencesService>();

    setState(() {
      _isDiceRolling = true;
      _isAnimating = true;
    });

    await SoundService.instance.play(
      SoundEvent.ludoDiceRoll, soundEnabled: prefs.soundEnabled);
    HapticService.instance.trigger(
      HapticEvent.tap, hapticsEnabled: prefs.hapticsEnabled);
    await Future.delayed(const Duration(milliseconds: 800));

    final result = LudoGameService.instance.rollDice(_state);
    setState(() {
      _isDiceRolling = false;
      _isAnimating = false;
      _state.lastDiceValue = result.primary;
      _state.lastDiceValue2 = result.secondary;
      _state.isPowerRoll = result.isPowerRoll;
    });

    if (result.isPowerRoll) {
      await SoundService.instance.play(
        SoundEvent.ludoPowerRoll, soundEnabled: prefs.soundEnabled);
      HapticService.instance.trigger(
        HapticEvent.win, hapticsEnabled: prefs.hapticsEnabled);
      setState(() => _state.phase = LudoPhase.choosingToken);
      return;
    }

    final selectableNow = LudoGameService.instance.getSelectableTokens(
      _state, _state.lastDiceValue);

    if (selectableNow.isEmpty) {
      setState(() => _state.phase = LudoPhase.choosingToken);
      await Future.delayed(const Duration(milliseconds: 600));
      _advanceTurn();
      return;
    }

    setState(() => _state.phase = LudoPhase.choosingToken);

    if (_state.speedRoundActive && !_speedRoundShown) {
      _speedRoundShown = true;
      _showSpeedRoundBanner();
    }

    if (_state.speedRoundActive) _startSpeedTimer();
  }

  void _onPickPowerDice(int index) {
    final val = index == 0 ? _state.lastDiceValue : _state.lastDiceValue2!;
    setState(() {
      _state.lastDiceValue = val;
      _state.lastDiceValue2 = null;
      _state.isPowerRoll = false;
    });
  }

  // ── Token selection ───────────────────────────────────────────────────────

  bool _isTokenSelectable(LudoToken token) {
    if (_state.phase != LudoPhase.choosingToken &&
        _state.phase != LudoPhase.swapSelect) return false;
    if (_state.currentPlayerIndex != token.playerIndex) {
      return _state.phase == LudoPhase.swapSelect;
    }
    final dice = _state.lastDiceValue;
    final selectable = LudoGameService.instance.getSelectableTokens(_state, dice);
    return selectable.any((t) => t.id == token.id);
  }

  Future<void> _onTokenTap(LudoToken token) async {
    if (_isAnimating) return;
    if (_state.phase == LudoPhase.swapSelect) {
      _handleSwapSelect(token);
      return;
    }
    if (_state.phase != LudoPhase.choosingToken) return;

    _cancelSpeedTimer();
    final diceValue = _state.lastDiceValue;
    setState(() => _isAnimating = true);

    final result = LudoGameService.instance.moveToken(_state, token, diceValue);
    await _handleMoveResult(result, token);

    setState(() => _isAnimating = false);
  }

  Future<void> _handleMoveResult(MoveResult result, LudoToken token) async {
    final prefs = context.read<PreferencesService>();

    switch (result.type) {
      case MoveResultType.cantMove:
        HapticService.instance.trigger(
          HapticEvent.freeze, hapticsEnabled: prefs.hapticsEnabled);
        return;

      case MoveResultType.enteredBoard:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoTokenEnter, soundEnabled: prefs.soundEnabled);
        HapticService.instance.trigger(
          HapticEvent.gameStart, hapticsEnabled: prefs.hapticsEnabled);
        _checkKingsRule();
        _advanceTurn();
        return;

      case MoveResultType.normal:
      case MoveResultType.movedSafe:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoTokenMove, soundEnabled: prefs.soundEnabled);
        _checkKingsRule();
        _advanceTurn();
        return;

      case MoveResultType.attacked:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoTokenSentHome, soundEnabled: prefs.soundEnabled);
        HapticService.instance.trigger(
          HapticEvent.playerEliminated, hapticsEnabled: prefs.hapticsEnabled);
        if (result.curseRevealed) {
          await _showCurseReveal();
        }
        _checkKingsRule();
        _advanceTurn();
        return;

      case MoveResultType.chaosTile:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoChaosTitle, soundEnabled: prefs.soundEnabled);
        HapticService.instance.trigger(
          HapticEvent.cardReveal, hapticsEnabled: prefs.hapticsEnabled);
        setState(() {
          _showChaosPopup = true;
          _chaosPrompt = result.chaosPrompt ?? '';
          _chaosIsTruth = result.chaosIsTruth;
          _pendingChaosToken = token;
        });
        return;

      case MoveResultType.wormhole:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoWormhole, soundEnabled: prefs.soundEnabled);
        HapticService.instance.trigger(
          HapticEvent.cardReveal, hapticsEnabled: prefs.hapticsEnabled);
        _advanceTurn();
        return;

      case MoveResultType.jailed:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoJailEnter, soundEnabled: prefs.soundEnabled);
        HapticService.instance.trigger(
          HapticEvent.freeze, hapticsEnabled: prefs.hapticsEnabled);
        _advanceTurn();
        return;

      case MoveResultType.jailBailout:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoJailFree, soundEnabled: prefs.soundEnabled);
        HapticService.instance.trigger(
          HapticEvent.win, hapticsEnabled: prefs.hapticsEnabled);
        _advanceTurn();
        return;

      case MoveResultType.giftSquare:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoGiftSquare, soundEnabled: prefs.soundEnabled);
        HapticService.instance.trigger(
          HapticEvent.cardReveal, hapticsEnabled: prefs.hapticsEnabled);
        _showGiftTokenPicker(steps: 6);
        return;

      case MoveResultType.reachedHome:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoTokenHome, soundEnabled: prefs.soundEnabled);
        HapticService.instance.trigger(
          HapticEvent.win, hapticsEnabled: prefs.hapticsEnabled);
        if (_state.phase == LudoPhase.kingsRule) {
          _showKingsRuleSheet();
          return;
        }
        _checkFinished();
        _advanceTurn();
        return;

      case MoveResultType.homeBlocked:
        setState(() {});
        await SoundService.instance.play(
          SoundEvent.ludoSabotage, soundEnabled: prefs.soundEnabled);
        HapticService.instance.trigger(
          HapticEvent.freeze, hapticsEnabled: prefs.hapticsEnabled);
        _showToast('🚧 Home entry blocked!');
        return;
    }
  }

  // ── Chaos tile ────────────────────────────────────────────────────────────

  void _onChaosAccept() {
    setState(() => _showChaosPopup = false);
    final p = _state.currentPlayer;
    p.chaosCompletedCount++;
    _advanceTurn();
  }

  void _onChaosRefuse() {
    setState(() => _showChaosPopup = false);
    if (_pendingChaosToken != null) {
      LudoGameService.instance.applyChaosTileRefuse(_pendingChaosToken!);
    }
    _advanceTurn();
  }

  // ── Gift picker ───────────────────────────────────────────────────────────

  void _showGiftTokenPicker({required int steps}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _GiftPickerSheet(
        player: _state.currentPlayer,
        onPick: (token) {
          Navigator.pop(context);
          LudoGameService.instance.applyGiftMove(_state, token, steps: steps);
          setState(() {});
          SoundService.instance.play(
            SoundEvent.ludoGiftSquare,
            soundEnabled: context.read<PreferencesService>().soundEnabled,
          );
          _advanceTurn();
        },
      ),
    );
  }

  // ── King's rule ───────────────────────────────────────────────────────────

  void _checkKingsRule() {
    if (_state.phase == LudoPhase.kingsRule) {
      _showKingsRuleSheet();
    }
  }

  void _showKingsRuleSheet() {
    final prefs = context.read<PreferencesService>();
    SoundService.instance.play(
      SoundEvent.ludoKingCrown, soundEnabled: prefs.soundEnabled);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => KingsRuleSheet(
        kingName: _state.currentPlayer.name,
        onConfirm: (rule) {
          setState(() {
            _state.kingsRuleText = rule;
            _state.kingsRuleTurnsLeft = _state.players.length * 3;
            _state.phase = LudoPhase.rolling;
          });
          _checkFinished();
          _advanceTurn();
        },
      ),
    );
  }

  // ── Sabotage ──────────────────────────────────────────────────────────────

  void _showSabotageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SabotageSheet(
        players: _state.players,
        currentPlayerIndex: _state.currentPlayerIndex,
        onApply: (targetIdx, type, token) {
          LudoGameService.instance.applySabotage(
            _state, targetIdx, type, token);
          setState(() {});
          final prefs = context.read<PreferencesService>();
          SoundService.instance.play(
            SoundEvent.ludoSabotage, soundEnabled: prefs.soundEnabled);
          HapticService.instance.trigger(
            HapticEvent.explosion, hapticsEnabled: prefs.hapticsEnabled);
        },
      ),
    );
  }

  // ── Swap trap ─────────────────────────────────────────────────────────────

  LudoToken? _swapFirst;

  void _enterSwapMode() {
    setState(() {
      _swapFirst = null;
      _state.phase = LudoPhase.swapSelect;
    });
    _showToast('Tap two tokens to swap their positions');
  }

  void _handleSwapSelect(LudoToken token) {
    if (_swapFirst == null) {
      setState(() => _swapFirst = token);
      _showToast('Now tap the second token');
    } else {
      if (_swapFirst!.id == token.id) {
        setState(() => _swapFirst = null);
        return;
      }
      LudoGameService.instance.applySwapTrap(_state, _swapFirst!, token);
      final prefs = context.read<PreferencesService>();
      SoundService.instance.play(
        SoundEvent.ludoSwapTrap, soundEnabled: prefs.soundEnabled);
      HapticService.instance.trigger(
        HapticEvent.cardReveal, hapticsEnabled: prefs.hapticsEnabled);
      setState(() {
        _swapFirst = null;
        _state.phase = LudoPhase.choosingToken;
      });
    }
  }

  // ── Scoreboard ────────────────────────────────────────────────────────────

  void _showScoreboard() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ScoreboardSheet(players: _state.players),
    );
  }

  // ── Speed round ───────────────────────────────────────────────────────────

  void _showSpeedRoundBanner() {
    final prefs = context.read<PreferencesService>();
    SoundService.instance.play(
      SoundEvent.ludoSpeedRound, soundEnabled: prefs.soundEnabled);
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: SpeedRoundOverlay(),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context, rootNavigator: true).maybePop();
    });
  }

  void _startSpeedTimer() {
    _speedProgress = 1.0;
    _speedTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _speedProgress -= 0.02);
      if (_speedProgress <= 0) {
        t.cancel();
        _speedProgress = 0;
        _advanceTurn();
      }
    });
  }

  void _cancelSpeedTimer() {
    _speedTimer?.cancel();
    _speedProgress = 1.0;
  }

  // ── Curse reveal ──────────────────────────────────────────────────────────

  Future<void> _showCurseReveal() async {
    final prefs = context.read<PreferencesService>();
    await SoundService.instance.play(
      SoundEvent.ludoCurseReveal, soundEnabled: prefs.soundEnabled);
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💀', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(
              'CURSE REVEALED!',
              style: GoogleFonts.anybody(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.dareRed,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A cursed token was sent home! −10 points to its owner.',
              style: GoogleFonts.sora(
                color: AppColors.textSecondary, fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.sora(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ── Turn management ───────────────────────────────────────────────────────

  void _checkFinished() {
    if (LudoGameService.instance.isGameFinished(_state)) {
      _state.phase = LudoPhase.finished;
    }
  }

  void _advanceTurn() {
    if (!mounted) return;
    LudoGameService.instance.advanceTurn(_state);

    if (_state.phase == LudoPhase.finished) {
      _navigateToResult();
      return;
    }

    setState(() {});

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _drawEventCardForTurn();
    });
  }

  void _navigateToResult() {
    final prefs = context.read<PreferencesService>();
    SoundService.instance.play(SoundEvent.ludoWin, soundEnabled: prefs.soundEnabled);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LudoResultScreen(gameState: _state),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showToast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.sora(fontSize: 13)),
        backgroundColor: AppColors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Offset _tokenOffset(LudoToken token, double cellSize) =>
      tokenOffset(token, cellSize);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surfaceContainer,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text('Leave game?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            content: const Text('Current game progress will be lost.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Stay')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Leave',
                      style: TextStyle(color: AppColors.dareRed))),
            ],
          ),
        );
        if (leave == true && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1923),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F1923), Color(0xFF162032)],
            ),
          ),
          child: Stack(children: [
            SafeArea(
              child: Column(children: [
                _buildTopBar(),
                _buildPlayerPanelRow(top: true),
                Expanded(child: _buildBoardArea()),
                _buildPlayerPanelRow(top: false),
                _buildBottomControls(),
              ]),
            ),
            if (_showChaosPopup)
              Positioned.fill(
                child: ChaosTilePopup(
                  playerName: _state.currentPlayer.name,
                  prompt: _chaosPrompt,
                  isTruth: _chaosIsTruth,
                  onAccept: _onChaosAccept,
                  onRefuse: _onChaosRefuse,
                ),
              ),
          ]),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withAlpha(25)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 14),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LUDO CHAOS',
                style: GoogleFonts.anybody(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5)),
            if (_state.kingsRuleText != null)
              Text('👑 "${_state.kingsRuleText}"',
                  style: GoogleFonts.sora(
                      fontSize: 9, color: const Color(0xFFF9A825)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
          ],
        ),
        const Spacer(),
        if (_state.speedRoundActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFC62828).withAlpha(40),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: const Color(0xFFC62828).withAlpha(160)),
            ),
            child: Text('⚡ SPEED',
                style: GoogleFonts.anybody(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFF5252),
                    letterSpacing: 1)),
          ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _showScoreboard,
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withAlpha(25)),
            ),
            child: const Icon(Icons.leaderboard_rounded,
                color: Colors.white70, size: 16),
          ),
        ),
      ]),
    );
  }

  // ── Player panel rows (Ludo King style) ───────────────────────────────────

  Widget _buildPlayerPanelRow({required bool top}) {
    // top=true → players 2 (Green) left, 3 (Yellow) right
    // top=false → players 0 (Blue) left, 1 (Red) right
    final indices = top ? [2, 3] : [0, 1];
    final available = indices
        .where((i) => i < _state.players.length)
        .toList();
    if (available.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: available
            .map((i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildPlayerPanel(_state.players[i]),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPlayerPanel(LudoPlayer p) {
    final color = _playerColors[p.index];
    final isActive = p.index == _state.currentPlayerIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? color.withAlpha(35)
            : Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color.withAlpha(200) : Colors.white.withAlpha(20),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: color.withAlpha(60), blurRadius: 8)]
            : [],
      ),
      child: Row(children: [
        // Colour dot / active crown
        Stack(alignment: Alignment.center, children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(isActive ? 200 : 100),
              border: Border.all(
                  color: isActive ? Colors.white : color.withAlpha(120),
                  width: 1.5),
              boxShadow: isActive
                  ? [BoxShadow(color: color.withAlpha(80), blurRadius: 6)]
                  : [],
            ),
            child: Center(
              child: Text(
                LudoPlayer.colorNames[p.index][0],
                style: GoogleFonts.anybody(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
          ),
          if (isActive)
            Positioned(
              top: -2, right: -2,
              child: Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF9A825)),
                child: const Center(
                  child: Text('▶',
                      style: TextStyle(fontSize: 5, color: Colors.black)),
                ),
              ),
            ),
        ]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                p.name.length > 7 ? '${p.name.substring(0, 7)}…' : p.name,
                style: GoogleFonts.sora(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : Colors.white60),
              ),
              Row(children: [
                Text(
                  '${p.score}',
                  style: GoogleFonts.anybody(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isActive ? color : Colors.white38),
                ),
                const SizedBox(width: 4),
                Text('pts',
                    style: GoogleFonts.sora(
                        fontSize: 8, color: Colors.white38)),
              ]),
            ],
          ),
        ),
        // Token-home indicators (small coloured dots)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              for (int t = 0; t < 4; t++) ...[
                if (t > 0) const SizedBox(width: 2),
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t < p.finishedCount
                        ? color
                        : Colors.white.withAlpha(30),
                    border: Border.all(
                        color: color.withAlpha(60), width: 0.5),
                  ),
                ),
              ]
            ]),
            if (p.hasBounty)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text('💰', style: TextStyle(fontSize: 8)),
              ),
          ],
        ),
      ]),
    );
  }

  // ── Board area ────────────────────────────────────────────────────────────

  Widget _buildBoardArea() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(140),
                  blurRadius: 24,
                  spreadRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final cellSize = constraints.maxWidth / 15;
                  return Stack(children: [
                    CustomPaint(
                      painter: LudoBoardPainter(state: _state),
                      size: Size.infinite,
                    ),
                    for (final player in _state.players)
                      for (final token in player.tokens)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          left: _tokenOffset(token, cellSize).dx,
                          top: _tokenOffset(token, cellSize).dy,
                          child: LudoTokenWidget(
                            token: token,
                            cellSize: cellSize,
                            isSelectable: _isTokenSelectable(token),
                            onTap: (_isTokenSelectable(token) ||
                                    _state.phase == LudoPhase.swapSelect)
                                ? () => _onTokenTap(token)
                                : null,
                          ),
                        ),
                  ]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom controls ───────────────────────────────────────────────────────

  Widget _buildBottomControls() {
    final canRoll = _state.phase == LudoPhase.rolling && !_isAnimating;

    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        border: Border(top: BorderSide(color: Colors.white.withAlpha(18))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Action buttons (left) ──────────────────────────────────
          Row(children: [
            if (_state.currentPlayer.sabotageCardsLeft > 0)
              _actionChip(
                icon: Icons.bolt_rounded,
                label: 'Sabotage\n×${_state.currentPlayer.sabotageCardsLeft}',
                color: const Color(0xFFC62828),
                onTap: _showSabotageSheet,
              ),
            if (!_state.currentPlayer.swapTrapUsed) ...[
              const SizedBox(width: 6),
              _actionChip(
                icon: Icons.swap_horiz_rounded,
                label: 'Swap\nTrap',
                color: const Color(0xFFE65100),
                onTap: _enterSwapMode,
              ),
            ],
          ]),

          // ── Dice + phase label (centre) ────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LudoDiceWidget(
                value: _state.lastDiceValue,
                value2: _state.lastDiceValue2,
                isRolling: _isDiceRolling,
                isPowerRoll: _state.isPowerRoll,
                isSpeedRound: _state.speedRoundActive,
                speedProgress: _speedProgress,
                onRoll: canRoll ? _onRollDice : null,
                onPickDice: _state.isPowerRoll ? _onPickPowerDice : null,
              ),
              const SizedBox(height: 3),
              Text(
                _phaseLabel(),
                style: GoogleFonts.sora(
                    fontSize: 9, color: Colors.white54),
              ),
            ],
          ),

          // ── Turn indicator / dice value (right) ────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentColor.withAlpha(30),
                  border: Border.all(color: _currentColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: _currentColor.withAlpha(80),
                        blurRadius: 10)
                  ],
                ),
                child: Center(
                  child: Text(
                    _state.lastDiceValue.toString(),
                    style: GoogleFonts.anybody(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _state.currentPlayer.name.length > 6
                    ? _state.currentPlayer.name.substring(0, 6)
                    : _state.currentPlayer.name,
                style: GoogleFonts.sora(
                    fontSize: 9,
                    color: _currentColor,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(120)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.sora(
                  fontSize: 8,
                  color: color,
                  fontWeight: FontWeight.w700,
                  height: 1.2),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  String _phaseLabel() {
    switch (_state.phase) {
      case LudoPhase.rolling:      return 'Tap 🎲 to roll';
      case LudoPhase.choosingToken: return 'Pick a token';
      case LudoPhase.swapSelect:   return 'Tap 2 tokens';
      case LudoPhase.giftPicker:   return 'Pick token +6';
      default:                      return '';
    }
  }
}

// ── Gift picker ───────────────────────────────────────────────────────────────

class _GiftPickerSheet extends StatelessWidget {
  final LudoPlayer player;
  final void Function(LudoToken) onPick;

  const _GiftPickerSheet({required this.player, required this.onPick});

  static const List<Color> _playerColors = [
    Color(0xFF4FC3F7),
    Color(0xFFEF5350),
    Color(0xFF66BB6A),
    Color(0xFFFFEE58),
  ];

  @override
  Widget build(BuildContext context) {
    final eligible = player.tokens
        .where((t) => !t.isFinished)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.neonGreen.withAlpha(60)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('🎁', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            'Choose a token to move forward',
            style: GoogleFonts.anybody(
              fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          for (final t in eligible)
            GestureDetector(
              onTap: () => onPick(t),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _playerColors[t.playerIndex].withAlpha(80),
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _playerColors[t.playerIndex].withAlpha(200),
                    ),
                    child: Center(child: Text(
                      LudoPlayer.colorNames[t.playerIndex][0],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w900,
                        color: Colors.black, fontSize: 14,
                      ),
                    )),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Token ${t.tokenIndex + 1} ${LudoToken.personalityEmoji(t.personality)}',
                    style: GoogleFonts.sora(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    t.state == TokenState.home
                        ? 'At home'
                        : 'Square ${t.pathPosition}',
                    style: GoogleFonts.sora(
                      color: AppColors.textMuted, fontSize: 11,
                    ),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
