import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/impostor_data.dart';
import '../../core/theme/app_colors.dart';
import '../../models/impostor_player.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';

enum ImpostorPhase { passDevice, reveal, discussion, vote, result }

class ImpostorGameScreen extends StatefulWidget {
  final String category;
  final List<ImpostorPlayer> players;
  final int impostorCount;
  final bool timeLimitEnabled;
  final int? timeLimitSeconds;
  final bool showCategoryToImpostor;
  final bool showHintToImpostor;
  final List<String>? customWords;

  const ImpostorGameScreen({
    super.key,
    required this.category,
    required this.players,
    this.impostorCount = 1,
    this.timeLimitEnabled = false,
    this.timeLimitSeconds,
    this.showCategoryToImpostor = false,
    this.showHintToImpostor = false,
    this.customWords,
  });

  @override
  State<ImpostorGameScreen> createState() => _ImpostorGameScreenState();
}

class _ImpostorGameScreenState extends State<ImpostorGameScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();

  ImpostorPhase _phase = ImpostorPhase.passDevice;
  late List<ImpostorPlayer> _players;
  int _currentPlayerIndex = 0;
  late List<String> _impostorIds;
  late String _secretWord;

  // Flip animation
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _hasFlipped = false;
  bool _isHolding = false;
  Timer? _holdTimer;

  // Shake animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Discussion
  int _timeLeft = 180;
  Timer? _discussionTimer;

  // Vote
  String? _votedPlayerId;

  bool get _soundEnabled => context.read<PreferencesService>().soundEnabled;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _flipController, curve: Curves.easeInOut));

    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _shakeAnimation =
        Tween<double>(begin: -3, end: 3).animate(_shakeController);

    _initializeGame();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _discussionTimer?.cancel();
    _flipController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    _players = List.from(widget.players)..shuffle();
    _currentPlayerIndex = 0;

    final words = widget.customWords ??
        ImpostorData.categories[widget.category] ?? [];
    _secretWord =
        words.isEmpty ? 'Mystery' : words[_random.nextInt(words.length)];

    final shuffledIds = _players.map((p) => p.id).toList()..shuffle();
    _impostorIds = shuffledIds.take(widget.impostorCount).toList();

    _hasFlipped = false;
    _isHolding = false;
    _phase = ImpostorPhase.passDevice;
    _votedPlayerId = null;

    if (widget.timeLimitEnabled && widget.timeLimitSeconds != null) {
      _timeLeft = widget.timeLimitSeconds!;
    } else {
      _timeLeft = 180;
    }
  }

  void _advanceToReveal() {
    SoundService.instance.play(SoundEvent.tap, soundEnabled: _soundEnabled);
    setState(() {
      _phase = ImpostorPhase.reveal;
      _hasFlipped = false;
      _isHolding = false;
    });
    _flipController.reset();
    _shakeController.stop();
    _shakeController.reset();
  }

  void _onHoldStart(LongPressStartDetails _) {
    if (_hasFlipped) return;
    _isHolding = true;
    HapticFeedback.mediumImpact();
    _shakeController.repeat(reverse: true);
    _holdTimer = Timer(const Duration(seconds: 1), () {
      if (_isHolding && !_hasFlipped && mounted) {
        setState(() => _hasFlipped = true);
        _shakeController.stop();
        _shakeController.reset();
        _flipController.forward();
        SoundService.instance
            .play(SoundEvent.cardReveal, soundEnabled: _soundEnabled);
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _onHoldEnd(LongPressEndDetails _) {
    if (_hasFlipped) return;
    _isHolding = false;
    _holdTimer?.cancel();
    _shakeController.stop();
    _shakeController.reset();
  }

  void _onHoldCancel() {
    if (_hasFlipped) return;
    _isHolding = false;
    _holdTimer?.cancel();
    _shakeController.stop();
    _shakeController.reset();
  }

  void _onGotIt() {
    HapticFeedback.lightImpact();
    SoundService.instance.play(SoundEvent.nextPlayer, soundEnabled: _soundEnabled);
    final isLast = _currentPlayerIndex >= _players.length - 1;
    if (isLast) {
      _startDiscussion();
    } else {
      setState(() {
        _currentPlayerIndex++;
        _phase = ImpostorPhase.passDevice;
        _hasFlipped = false;
        _isHolding = false;
      });
      _flipController.reset();
    }
  }

  void _startDiscussion() {
    setState(() => _phase = ImpostorPhase.discussion);
    if (!widget.timeLimitEnabled) return;
    _discussionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 5 && _timeLeft > 0) {
          HapticFeedback.lightImpact();
          SoundService.instance
              .play(SoundEvent.countdown, soundEnabled: _soundEnabled);
        }
        if (_timeLeft <= 0) {
          t.cancel();
          HapticFeedback.heavyImpact();
          SoundService.instance
              .play(SoundEvent.timerEnd, soundEnabled: _soundEnabled);
          _goToVote();
        }
      });
    });
  }

  void _goToVote() {
    _discussionTimer?.cancel();
    setState(() => _phase = ImpostorPhase.vote);
  }

  void _castVote(String playerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm Vote?',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'You\'re accusing ${_players.firstWhere((p) => p.id == playerId).name}.',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style:
                      GoogleFonts.poppins(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Vote',
                  style: GoogleFonts.poppins(
                      color: AppColors.dareRed,
                      fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final won = _impostorIds.contains(playerId);
      SoundService.instance.play(
        won ? SoundEvent.win : SoundEvent.wrong,
        soundEnabled: _soundEnabled,
      );
      setState(() {
        _votedPlayerId = playerId;
        _phase = ImpostorPhase.result;
      });
    }
  }

  bool get _civiliansWin {
    if (_votedPlayerId == null) return false;
    return _impostorIds.contains(_votedPlayerId);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text('Leave Game?',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text('Progress will be lost.',
                style:
                    GoogleFonts.poppins(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Keep Playing',
                      style: GoogleFonts.poppins(
                          color: AppColors.textSecondary))),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Leave',
                      style: GoogleFonts.poppins(
                          color: AppColors.dareRed))),
            ],
          ),
        );
        if (leave == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: _buildPhase()),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case ImpostorPhase.passDevice:
        return _buildPassDevice();
      case ImpostorPhase.reveal:
        return _buildReveal();
      case ImpostorPhase.discussion:
        return _buildDiscussion();
      case ImpostorPhase.vote:
        return _buildVote();
      case ImpostorPhase.result:
        return _buildResult();
    }
  }

  // ─── Phase 1: Pass Device ──────────────────────────────────────────────────
  Widget _buildPassDevice() {
    final player = _players[_currentPlayerIndex];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 64, color: AppColors.primaryNeon),
          const SizedBox(height: 32),
          Text('Pass to',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 18)),
          const SizedBox(height: 8),
          Text(player.name,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            '${_currentPlayerIndex + 1} of ${_players.length}',
            style:
                GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 64),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonPink,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _advanceToReveal,
              child: Text('PASS DEVICE',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Phase 2: Card Reveal ─────────────────────────────────────────────────
  Widget _buildReveal() {
    final player = _players[_currentPlayerIndex];
    final isImpostor = _impostorIds.contains(player.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(player.name,
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          GestureDetector(
            onLongPressStart: _onHoldStart,
            onLongPressEnd: _onHoldEnd,
            onLongPressCancel: _onHoldCancel,
            child: AnimatedBuilder(
              animation: Listenable.merge([_flipAnimation, _shakeAnimation]),
              builder: (_, __) {
                final angle = _flipAnimation.value * pi;
                final showBack = _flipAnimation.value > 0.5;
                final shakeX =
                    _isHolding && !_hasFlipped ? _shakeAnimation.value : 0.0;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle)
                    ..translate(shakeX),
                  child: showBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: isImpostor
                              ? _buildImpostorCard()
                              : _buildCivilianCard(),
                        )
                      : _buildFrontCard(),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          if (!_hasFlipped)
            Text(
              'Hold the card to reveal your role',
              style: GoogleFonts.poppins(
                  color: AppColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          AnimatedOpacity(
            opacity: _hasFlipped ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedSlide(
              offset:
                  _hasFlipped ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Text('Pass device to next player',
                      style: GoogleFonts.poppins(
                          color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonPink,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _hasFlipped ? _onGotIt : null,
                      child: Text('GOT IT!',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0820),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.primaryNeon.withAlpha(180), width: 2),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryNeon.withAlpha(60),
              blurRadius: 30,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded, size: 64, color: AppColors.primaryNeon),
          const SizedBox(height: 16),
          Text('Hold to reveal',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCivilianCard() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF001A4A), Color(0xFF0A0030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.truthBlue.withAlpha(200), width: 2),
        boxShadow: [
          BoxShadow(
              color: AppColors.truthBlue.withAlpha(60), blurRadius: 30)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Find the Impostor!',
              style: GoogleFonts.poppins(
                  color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 12),
          Text(_secretWord,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          const Icon(Icons.groups_rounded,
              color: AppColors.truthBlue, size: 48),
        ],
      ),
    );
  }

  Widget _buildImpostorCard() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A0010), Color(0xFF0A0005)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.dareRed.withAlpha(200), width: 2),
        boxShadow: [
          BoxShadow(
              color: AppColors.dareRed.withAlpha(60), blurRadius: 30)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.visibility_off_rounded,
              color: AppColors.dareRed, size: 56),
          const SizedBox(height: 12),
          Text('IMPOSTOR',
              style: GoogleFonts.poppins(
                  color: AppColors.neonPink,
                  fontSize: 34,
                  fontWeight: FontWeight.w900)),
          if (widget.showHintToImpostor) ...[
            const SizedBox(height: 12),
            const Icon(Icons.lightbulb_rounded,
                color: AppColors.neonYellow, size: 20),
            Text('Blend in — guess the word!',
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  // ─── Phase 3: Discussion ──────────────────────────────────────────────────
  Widget _buildDiscussion() {
    final timerColor = _timeLeft <= 10
        ? AppColors.dareRed
        : (_timeLeft <= 30 ? AppColors.neonOrange : Colors.white);
    final mm = _timeLeft ~/ 60;
    final ss = _timeLeft % 60;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.forum_rounded,
              color: AppColors.neonPink, size: 80),
          const SizedBox(height: 24),
          Text('TIME TO DISCUSS',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          Text(
            'Discuss who the impostor might be.\nEveryone shares their thoughts!',
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 14, height: 1.6),
            textAlign: TextAlign.center,
          ),
          if (widget.timeLimitEnabled) ...[
            const SizedBox(height: 40),
            Text(
              '${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(
                  color: timerColor,
                  fontSize: 64,
                  fontWeight: FontWeight.w900),
            ),
          ] else
            const SizedBox(height: 40),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dareRed,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _goToVote,
              child: Text('FINISH & VOTE',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Phase 4: Vote ────────────────────────────────────────────────────────
  Widget _buildVote() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('WHO IS THE IMPOSTOR?',
                  style: GoogleFonts.poppins(
                      color: AppColors.dareRed,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              Text('Tap to vote',
                  style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _players.length,
            itemBuilder: (_, i) {
              final p = _players[i];
              return GestureDetector(
                onTap: () => _castVote(p.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.dareRed.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.dareRed.withAlpha(40),
                            borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: Text('${i + 1}',
                            style: GoogleFonts.poppins(
                                color: AppColors.dareRed,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Text(p.name,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600))),
                      const Icon(Icons.how_to_vote_rounded,
                          color: AppColors.dareRed, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Phase 5: Result ──────────────────────────────────────────────────────
  Widget _buildResult() {
    final impostorNames = _impostorIds
        .map((id) => _players.firstWhere((p) => p.id == id).name)
        .toList();
    final won = _civiliansWin;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            won ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 100,
            color: won ? AppColors.neonGreen : AppColors.dareRed,
          ),
          const SizedBox(height: 24),
          Text(
            won ? 'CIVILIANS WIN!' : 'IMPOSTOR WINS!',
            style: GoogleFonts.poppins(
              color: won ? AppColors.neonGreen : AppColors.dareRed,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBright),
            ),
            child: Column(
              children: [
                Text(
                  'The impostor${impostorNames.length > 1 ? 's were' : ' was'}:',
                  style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  impostorNames.join(', '),
                  style: GoogleFonts.poppins(
                      color: AppColors.neonPink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text('The secret word was:',
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                Text(_secretWord,
                    style: GoogleFonts.poppins(
                        color: AppColors.truthBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonPink,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () => setState(() => _initializeGame()),
              child: Text('PLAY AGAIN',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Leave',
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
