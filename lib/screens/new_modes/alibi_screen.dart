import 'package:cousin_chaos/core/icons.dart';
import 'dart:async';
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
import '../../widgets/category_selector.dart';

class AlibiScreen extends StatefulWidget {
  const AlibiScreen({super.key});

  @override
  State<AlibiScreen> createState() => _AlibiScreenState();
}

class _AlibiScreenState extends State<AlibiScreen> {
  int _step = 1;
  List<String> _selectedPlayers = [];
  List<String> _selectedCategories = [];
  String _scenario = '';
  int _currentPlayerIndex = 0;
  int _currentQuestionIndex = 0;
  // Phase 2 fix: votes map is voter → accused player name (not bool)
  Map<String, String> _votes = {};
  List<String> _questions = [];
  bool _sessionSaved = false;

  late ConfettiController _confettiController;
  final _rng = Random();

  static const _alibiCategories = [
    'Work',
    'Party',
    'Travel',
    'Family',
    'Shopping',
    'Sports',
    'Nature',
    'Unexpected',
  ];

  static const _scenarios = {
    'Work': [
      'You were at an emergency board meeting when the incident occurred.',
      'Your laptop crashed and you had to stay late to fix critical code.',
      'A client flew in unexpectedly and needed a 3-hour debrief.',
    ],
    'Party': [
      'You were throwing a surprise birthday party at the time.',
      'A friend dragged you to a karaoke bar all evening.',
      'You attended a rooftop gathering you weren\'t supposed to know about.',
    ],
    'Travel': [
      'Your flight was delayed and you were stuck at the airport.',
      'You took a wrong turn and ended up in the wrong city.',
      'You were on a road trip with terrible phone signal.',
    ],
    'Family': [
      'You were visiting a relative in the hospital all day.',
      'Your grandparent called you for an hours-long phone catch-up.',
      'You were mediating a family argument that escalated.',
    ],
    'Shopping': [
      'You got lost in an IKEA for three hours.',
      'You were waiting in a very long checkout line.',
      'Your car broke down outside the mall.',
    ],
    'Sports': [
      'You were coaching a youth football match that ran overtime.',
      'You were at the gym when the power went out.',
      'You got stuck at a sports bar watching overtime.',
    ],
    'Nature': [
      'You went hiking and got mildly lost on the trail.',
      'A sudden rainstorm trapped you in a café.',
      'Your dog ran off and you spent hours searching.',
    ],
    'Unexpected': [
      'You were helping a stranger who had a car breakdown.',
      'You accidentally stumbled into a film shoot.',
      'A meteor shower kept you outside all night.',
    ],
  };

  static const _questionTemplates = [
    'What exactly were you doing at {time}?',
    'Who else can confirm your whereabouts?',
    'How long were you there exactly?',
    'Why didn\'t you contact anyone during this time?',
    'What did you eat or drink during this time?',
    'How did you get there and how did you leave?',
    'Describe what you were wearing that day.',
    'What was the weather like during your alibi?',
    'What is the first thing you did after leaving?',
    'Why should we believe your alibi?',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pm = context.read<PlayerManager>();
      // Phase 1 fix: auto-populate selected players from PlayerManager
      if (pm.players.length >= 2) {
        setState(() {
          _selectedPlayers = pm.players.map((p) => p.name).toList();
        });
      }
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
    _confettiController.dispose();
    super.dispose();
  }

  String _generateScenario(List<String> categories) {
    final cat =
        categories[_rng.nextInt(categories.length)];
    final list = _scenarios[cat] ?? _scenarios.values.first;
    return list[_rng.nextInt(list.length)];
  }

  List<String> _generateQuestions(String player) {
    final times = ['3:00 PM', '7:00 PM', '9:30 PM', 'midnight'];
    final time = times[_rng.nextInt(times.length)];
    final shuffled = List.from(_questionTemplates)..shuffle(_rng);
    return shuffled
        .take(3)
        .map((q) => q.replaceAll('{time}', time))
        .cast<String>()
        .toList();
  }

  LinearGradient _categoryGradient(String cat) {
    final gradients = {
      'Work': LinearGradient(colors: [
        const Color(0xFF1E3A5F),
        AppColors.background
      ]),
      'Party': LinearGradient(colors: [
        const Color(0xFF5F1E5F),
        AppColors.background
      ]),
      'Travel': LinearGradient(colors: [
        const Color(0xFF1E5F5F),
        AppColors.background
      ]),
      'Family': LinearGradient(colors: [
        const Color(0xFF5F3A1E),
        AppColors.background
      ]),
      'Sports': LinearGradient(colors: [
        const Color(0xFF1E5F1E),
        AppColors.background
      ]),
      'Nature': LinearGradient(colors: [
        const Color(0xFF2A5F1E),
        AppColors.background
      ]),
    };
    return gradients[cat] ??
        LinearGradient(
            colors: [AppColors.surfaceLight, AppColors.background]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_step == 1) {
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
              SafeArea(child: _buildStep()),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: const [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.neonGreen,
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

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _buildSetup();
      case 2:
        return _buildSceneReveal();
      case 3:
        return _buildPlanning();
      case 4:
        return _buildInterrogation();
      case 5:
        return _buildVerdict();
      case 6:
        return _buildResults();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSetup() {
    return Consumer<PlayerManager>(
      builder: (context, pm, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Alibi',
                  style: GoogleFonts.sora(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Build your cover story together',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 20),
            Text(
              'PLAYERS',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pm.players.map((p) => Chip(
                label: Text(p.name,
                    style: GoogleFonts.sora(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                backgroundColor: AppColors.primary.withAlpha(30),
                side: const BorderSide(color: AppColors.primary, width: 1),
                avatar: CircleAvatar(
                  backgroundColor: AppColors.primary.withAlpha(80),
                  child: Text(p.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'CATEGORY (2–3)',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            CategorySelector(
              categories: _alibiCategories,
              initialSelected: _selectedCategories.isEmpty
                  ? [_alibiCategories.first]
                  : _selectedCategories,
              onChanged: (cats) =>
                  setState(() => _selectedCategories = cats),
            ),
            const Spacer(),
            GestureDetector(
              onTap: (_selectedPlayers.length >= 2 &&
                      _selectedCategories.isNotEmpty)
                  ? () {
                      _scenario = _generateScenario(_selectedCategories);
                      setState(() => _step = 2);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: (_selectedPlayers.length >= 2 &&
                          _selectedCategories.isNotEmpty)
                      ? AppColors.primaryGradient
                      : null,
                  color: (_selectedPlayers.length >= 2 &&
                          _selectedCategories.isNotEmpty)
                      ? null
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Begin Alibi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    color: (_selectedPlayers.length >= 2 &&
                            _selectedCategories.isNotEmpty)
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

  Widget _buildSceneReveal() {
    bool buttonEnabled = false;
    final cat = _selectedCategories.isNotEmpty
        ? _selectedCategories.first
        : 'Work';
    return StatefulBuilder(
      builder: (context, innerSet) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) innerSet(() => buttonEnabled = true);
        });
        return Container(
          decoration: BoxDecoration(
              gradient: _categoryGradient(cat)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _selectedCategories.join(' · '),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    '🕵️ THE CRIME SCENE',
                    style: TextStyle(
                      color: Colors.white54,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _scenario,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 64),
                  AnimatedOpacity(
                    opacity: buttonEnabled ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 400),
                    child: GestureDetector(
                      onTap: buttonEnabled
                          ? () => setState(() => _step = 3)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: Colors.white54),
                        ),
                        child: Text(
                          "We're Ready",
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanning() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.brain, color: AppColors.primary, size: 60),
          const SizedBox(height: 24),
          Text(
            'Plan Your Story',
            style: GoogleFonts.sora(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coordinate your alibis. Get your story straight.',
            style: TextStyle(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _PlanningTimer(
            seconds: 60,
            onEnd: () => setState(() => _step = 4),
          ),
        ],
      ),
    );
  }

  Widget _buildInterrogation() {
    final player = _selectedPlayers[_currentPlayerIndex];

    if (_currentQuestionIndex == 0) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pass phone to',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              player,
              style: GoogleFonts.sora(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re in the hot seat 🔥',
              style: TextStyle(color: AppColors.tertiary),
            ),
            const SizedBox(height: 48),
            Icon(LucideIcons.arrowRight, color: Colors.white, size: 40),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () {
                _questions = _generateQuestions(player);
                setState(() => _currentQuestionIndex = 1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 40),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  "I'm Ready",
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

    final question = _questions[_currentQuestionIndex - 1];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$player is in the hot seat 🔥',
            style: TextStyle(
                color: AppColors.tertiary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: AppColors.tertiary.withAlpha(80)),
              boxShadow: [
                BoxShadow(
                    color: AppColors.tertiary.withAlpha(30),
                    blurRadius: 30),
              ],
            ),
            child: Text(
              question,
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                fontSize: 18,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Question $_currentQuestionIndex of 3',
            style: TextStyle(color: Colors.white38),
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () {
              if (_currentQuestionIndex < 3) {
                setState(() => _currentQuestionIndex++);
              } else {
                setState(() {
                  _currentQuestionIndex = 0;
                  _currentPlayerIndex++;
                  if (_currentPlayerIndex >=
                      _selectedPlayers.length) {
                    _step = 5;
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 40),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                _currentQuestionIndex < 3
                    ? 'Next Question →'
                    : _currentPlayerIndex <
                            _selectedPlayers.length - 1
                        ? 'Next Player →'
                        : 'Vote →',
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

  Widget _buildVerdict() {
    final remaining = _selectedPlayers
        .where((p) => !_votes.containsKey(p))
        .toList();
    if (remaining.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _step = 6);
      });
      return const SizedBox.shrink();
    }
    final currentVoter = remaining.first;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'VERDICT',
            style: GoogleFonts.sora(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Does the alibi hold?',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Text(
            '${_votes.length} / ${_selectedPlayers.length} voted',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Text(
                  '$currentVoter, cast your vote:',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Phase 2 fix: vote FOR a player (accuse), not hold/break
                ...(_selectedPlayers
                    .where((p) => p != currentVoter)
                    .map((accused) => GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _votes[currentVoter] = accused;
                          if (_votes.length == _selectedPlayers.length) {
                            _confettiController.play();
                            _step = 6;
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withAlpha(20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.tertiary.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.tertiary.withAlpha(60),
                              child: Text(accused[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                            const SizedBox(width: 12),
                            Text(accused,
                                style: GoogleFonts.sora(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                )),
                            const Spacer(),
                            const Icon(Icons.gavel_rounded,
                                color: AppColors.tertiary, size: 18),
                          ],
                        ),
                      ),
                    ))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    // Phase 2 fix: tally accusation votes per player
    final Map<String, int> voteCounts = {};
    for (final accused in _votes.values) {
      voteCounts[accused] = (voteCounts[accused] ?? 0) + 1;
    }
    final sorted = _selectedPlayers.toList()
      ..sort((a, b) =>
          (voteCounts[b] ?? 0).compareTo(voteCounts[a] ?? 0));
    final mostAccused = sorted.isNotEmpty ? sorted.first : '';
    final topVotes = voteCounts[mostAccused] ?? 0;
    final totalVotes = _votes.length;

    // Phase 2 fix: guard duplicate session saves
    if (!_sessionSaved) {
      _sessionSaved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SessionService.saveSession(SessionRecord(
          id: const Uuid().v4(),
          mode: 'Alibi',
          playedAt: DateTime.now(),
          players: _selectedPlayers,
          winner: mostAccused.isNotEmpty ? mostAccused : 'Nobody',
          themeColor: 'green',
        ));
      });
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            mostAccused.isNotEmpty ? '🎯 VERDICT' : '🤔 NO VERDICT',
            style: GoogleFonts.sora(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (mostAccused.isNotEmpty)
            Text(
              '$mostAccused got the most accusations ($topVotes/$totalVotes)',
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 32),
          // Phase 3 fix: show vote % per player
          Expanded(
            child: ListView(
              children: sorted.map((player) {
                final count = voteCounts[player] ?? 0;
                final pct = totalVotes > 0
                    ? (count / totalVotes * 100).round()
                    : 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: player == mostAccused
                        ? AppColors.tertiary.withAlpha(25)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: player == mostAccused
                          ? AppColors.tertiary.withAlpha(100)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withAlpha(60),
                        child: Text(player[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(player,
                              style: const TextStyle(color: Colors.white))),
                      Text(
                        '$count vote${count == 1 ? '' : 's'} ($pct%)',
                        style: TextStyle(
                          color: player == mostAccused
                              ? AppColors.tertiary
                              : Colors.white54,
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
                  onPressed: () {
                    final pm = context.read<PlayerManager>();
                    setState(() {
                      _step = 1;
                      _votes = {};
                      _currentPlayerIndex = 0;
                      _currentQuestionIndex = 0;
                      _sessionSaved = false;
                      _selectedPlayers =
                          pm.players.map((p) => p.name).toList();
                      _selectedCategories = [];
                    });
                  },
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

class _PlanningTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onEnd;

  const _PlanningTimer({required this.seconds, required this.onEnd});

  @override
  State<_PlanningTimer> createState() => _PlanningTimerState();
}

class _PlanningTimerState extends State<_PlanningTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining > 0) {
        setState(() => _remaining--);
      } else {
        _timer?.cancel();
        widget.onEnd();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLow = _remaining <= 10;
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _remaining / widget.seconds,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                color: isLow ? AppColors.dareRed : AppColors.primary,
                backgroundColor: AppColors.surfaceBright,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_remaining',
                    style: GoogleFonts.sora(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isLow ? AppColors.dareRed : Colors.white,
                    ),
                  ),
                  Text(
                    'sec',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isLow ? 'Wrap it up!' : 'Sync your alibis...',
          style: TextStyle(
            color: isLow ? AppColors.dareRed : Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
