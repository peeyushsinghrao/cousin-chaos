import 'package:cousin_chaos/core/icons.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/leave_game_dialog.dart';
import '../../services/player_manager.dart';
import '../../services/session_service.dart';

class TwoTruthsOneLieScreen extends StatefulWidget {
  const TwoTruthsOneLieScreen({super.key});

  @override
  State<TwoTruthsOneLieScreen> createState() =>
      _TwoTruthsOneLieScreenState();
}

class _TwoTruthsOneLieScreenState extends State<TwoTruthsOneLieScreen> {
  int _phase = 1;
  int _currentPlayerIndex = 0;

  final _truth1Controller = TextEditingController();
  final _truth2Controller = TextEditingController();
  final _lieController = TextEditingController();

  List<Map<String, dynamic>> _shuffledStatements = [];
  Map<String, int> _votes = {};
  String _currentVoter = '';
  int _currentVoterIndex = 0;
  List<String> _otherPlayers = [];
  Map<String, int> _scores = {};

  late ConfettiController _confettiController;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _truth1Controller.dispose();
    _truth2Controller.dispose();
    _lieController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String get _currentPlayerName {
    final pm = context.read<PlayerManager>();
    if (_currentPlayerIndex >= pm.players.length) return '';
    return pm.players[_currentPlayerIndex].name;
  }

  bool get _writingComplete =>
      _truth1Controller.text.trim().isNotEmpty &&
      _truth2Controller.text.trim().isNotEmpty &&
      _lieController.text.trim().isNotEmpty;

  void _submitStatements() {
    final statements = [
      {'text': _truth1Controller.text.trim(), 'isLie': false},
      {'text': _truth2Controller.text.trim(), 'isLie': false},
      {'text': _lieController.text.trim(), 'isLie': true},
    ];
    statements.shuffle(_rng);
    setState(() {
      _shuffledStatements = List.from(statements);
      _votes = {};
      _currentVoterIndex = 0;
    });

    final pm = context.read<PlayerManager>();
    _otherPlayers = pm.players
        .where((p) => p.name != _currentPlayerName)
        .map((p) => p.name)
        .toList();

    if (_otherPlayers.isNotEmpty) {
      _currentVoter = _otherPlayers[0];
    }
    setState(() => _phase = 2);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_phase == 1) {
          Navigator.pop(context);
          return;
        }
        final leave = await showLeaveGameSheet(context);
        if (leave == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        body: MeshGradientBackground(
          child: Stack(
            children: [
              SafeArea(child: _buildPhase()),
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
                  numberOfParticles: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case 1:
        return _buildWritingPhase();
      case 2:
        return _buildPassAndVotePhase();
      case 3:
        return _buildRevealPhase();
      case 4:
        return _buildScoresPhase();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWritingPhase() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: () {
                  if (_currentPlayerIndex == 0) {
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      _currentPlayerIndex--;
                      _truth1Controller.clear();
                      _truth2Controller.clear();
                      _lieController.clear();
                    });
                  }
                },
              ),
              Expanded(
                child: Text(
                  'Pass to $_currentPlayerName',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Write your 2 truths and 1 lie',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildStatementField(
                  controller: _truth1Controller,
                  label: 'Truth 1 ✅',
                  hint: 'Something true about you...',
                  accentColor: Colors.green,
                ),
                const SizedBox(height: 14),
                _buildStatementField(
                  controller: _truth2Controller,
                  label: 'Truth 2 ✅',
                  hint: 'Another true thing...',
                  accentColor: Colors.green,
                ),
                const SizedBox(height: 14),
                _buildStatementField(
                  controller: _lieController,
                  label: 'The Lie ❌',
                  hint: 'Something false that sounds true...',
                  accentColor: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _writingComplete ? _submitStatements : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _writingComplete
                    ? AppColors.primaryGradient
                    : null,
                color: _writingComplete
                    ? null
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _writingComplete
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'Lock In & Pass',
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  color: _writingComplete
                      ? Colors.white
                      : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Colors.white),
          maxLines: 2,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white30),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassAndVotePhase() {
    if (_currentVoterIndex >= _otherPlayers.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _phase = 3);
      });
      return const SizedBox.shrink();
    }

    int? _selectedIndex;

    return StatefulBuilder(
      builder: (context, innerSet) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Pass to $_currentVoter',
              style: GoogleFonts.sora(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Which one is the lie?',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentVoterIndex + 1} / ${_otherPlayers.length}',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Text(
              _currentPlayerName,
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ..._shuffledStatements.asMap().entries.map((e) {
              final index = e.key;
              final stmt = e.value;
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => innerSet(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(40)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceBright,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          stmt['text'] as String,
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            GestureDetector(
              onTap: _selectedIndex != null
                  ? () {
                      HapticFeedback.mediumImpact();
                      _votes[_currentVoter] = _selectedIndex!;
                      _currentVoterIndex++;
                      if (_currentVoterIndex < _otherPlayers.length) {
                        _currentVoter =
                            _otherPlayers[_currentVoterIndex];
                        innerSet(() => _selectedIndex = null);
                        setState(() {});
                      } else {
                        setState(() => _phase = 3);
                      }
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _selectedIndex != null
                      ? AppColors.primaryGradient
                      : null,
                  color: _selectedIndex != null
                      ? null
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Confirm Vote',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    color: _selectedIndex != null
                        ? Colors.white
                        : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevealPhase() {
    final lieIndex = _shuffledStatements
        .indexWhere((s) => s['isLie'] as bool);
    int correctGuesses = 0;
    for (final vote in _votes.values) {
      if (vote == lieIndex) correctGuesses++;
    }

    final writerPoints = _votes.length - correctGuesses;
    final voterPoints = correctGuesses;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'REVEAL 🎭',
            style: GoogleFonts.sora(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$correctGuesses / ${_otherPlayers.length} guessed it right',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          ..._shuffledStatements.asMap().entries.map((e) {
            final index = e.key;
            final stmt = e.value;
            final isLie = stmt['isLie'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isLie
                    ? Colors.red.withAlpha(30)
                    : Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLie
                      ? Colors.red.withAlpha(100)
                      : Colors.green.withAlpha(60),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    isLie ? '❌' : '✅',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stmt['text'] as String,
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        if (isLie)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'THE LIE',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: _votes.entries
                        .where((v) => v.value == index)
                        .map((v) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                v.key[0],
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            );
          }),
          const Spacer(),
          _ScoreBadge(
            writerName: _currentPlayerName,
            writerPoints: writerPoints,
            voterPoints: voterPoints,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              final pm = context.read<PlayerManager>();
              _scores[_currentPlayerName] =
                  (_scores[_currentPlayerName] ?? 0) + writerPoints;

              _currentPlayerIndex++;
              if (_currentPlayerIndex >= pm.players.length) {
                _confettiController.play();
                setState(() => _phase = 4);
              } else {
                _truth1Controller.clear();
                _truth2Controller.clear();
                _lieController.clear();
                setState(() => _phase = 1);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _currentPlayerIndex + 1 < context.read<PlayerManager>().players.length
                    ? 'Next Player →'
                    : 'View Scores →',
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresPhase() {
    final sorted = _scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final winner = sorted.isNotEmpty ? sorted.first.key : '';
    final pm = context.read<PlayerManager>();

    SessionService.saveSession(SessionRecord(
      id: const Uuid().v4(),
      mode: 'Two Truths, One Lie',
      playedAt: DateTime.now(),
      players: pm.players.map((p) => p.name).toList(),
      winner: winner,
      themeColor: 'blue',
    ));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '🏆 Final Scores',
            style: GoogleFonts.sora(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (winner.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '$winner wins!',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: sorted.asMap().entries.map((e) {
                final isFirst = e.key == 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? AppColors.gold.withAlpha(30)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFirst
                          ? AppColors.gold.withAlpha(100)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        isFirst ? '🥇' : '${e.key + 1}.',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value.key,
                          style: GoogleFonts.sora(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${e.value.value} pts',
                        style: TextStyle(
                          color: isFirst
                              ? AppColors.gold
                              : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white30),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() {
                    _phase = 1;
                    _currentPlayerIndex = 0;
                    _scores = {};
                    _truth1Controller.clear();
                    _truth2Controller.clear();
                    _lieController.clear();
                  }),
                  child: Text('Play Again',
                      style: GoogleFonts.sora(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: Text('Home',
                      style: GoogleFonts.sora(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String writerName;
  final int writerPoints;
  final int voterPoints;

  const _ScoreBadge({
    required this.writerName,
    required this.writerPoints,
    required this.voterPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '$writerPoints pts',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$writerName (writer)',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white12),
          Column(
            children: [
              Text(
                '$voterPoints pts',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Correct guesses',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
