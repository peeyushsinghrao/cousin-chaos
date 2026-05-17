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
  Map<String, bool> _votes = {};
  List<String> _questions = [];

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
            Text(
              'Alibi',
              style: GoogleFonts.sora(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Build your cover story together',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            Text(
              'SELECT PLAYERS (3–8)',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            ...pm.players.map((p) {
              final selected = _selectedPlayers.contains(p.name);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (selected) {
                      if (_selectedPlayers.length > 3) {
                        _selectedPlayers.remove(p.name);
                      }
                    } else if (_selectedPlayers.length < 8) {
                      _selectedPlayers.add(p.name);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withAlpha(40)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.white12,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primary.withAlpha(60),
                        child: Text(
                          p.name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.name,
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(LucideIcons.check,
                            color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
              );
            }),
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
              onTap: (_selectedPlayers.length >= 3 &&
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
                  gradient: (_selectedPlayers.length >= 3 &&
                          _selectedCategories.isNotEmpty)
                      ? AppColors.primaryGradient
                      : null,
                  color: (_selectedPlayers.length >= 3 &&
                          _selectedCategories.isNotEmpty)
                      ? null
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Begin Alibi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    color: (_selectedPlayers.length >= 3 &&
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _votes[currentVoter] = true;
                            if (_votes.length ==
                                _selectedPlayers.length) {
                              _confettiController.play();
                              _step = 6;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                          decoration: BoxDecoration(
                            color:
                                Colors.green.withAlpha(40),
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.green
                                    .withAlpha(100)),
                          ),
                          child: const Column(
                            children: [
                              Text('🤝', style: TextStyle(fontSize: 28)),
                              SizedBox(height: 4),
                              Text(
                                'Alibi Holds',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _votes[currentVoter] = false;
                            if (_votes.length ==
                                _selectedPlayers.length) {
                              _step = 6;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(40),
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                                color:
                                    Colors.red.withAlpha(100)),
                          ),
                          child: const Column(
                            children: [
                              Text('💥', style: TextStyle(fontSize: 28)),
                              SizedBox(height: 4),
                              Text(
                                'Story Breaks',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final holdsCount = _votes.values.where((v) => v).length;
    final breaksCount = _votes.values.where((v) => !v).length;
    final alibiHolds = holdsCount >= breaksCount;

    SessionService.saveSession(SessionRecord(
      id: const Uuid().v4(),
      mode: 'Alibi',
      playedAt: DateTime.now(),
      players: _selectedPlayers,
      winner: alibiHolds ? 'The Group' : 'Nobody',
      themeColor: 'green',
    ));

    return Stack(
      children: [
        if (!alibiHolds)
          Container(color: Colors.red.withAlpha(20)),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                alibiHolds ? '🤝 ALIBI HOLDS!' : '💥 STORY BREAKS!',
                style: GoogleFonts.sora(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: alibiHolds ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                alibiHolds
                    ? '$holdsCount votes held the alibi'
                    : '$breaksCount votes broke the story',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: _votes.entries.map((e) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withAlpha(60),
                        child: Text(e.key[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        e.key,
                        style:
                            const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        e.value ? '🤝 Holds' : '💥 Breaks',
                        style: TextStyle(
                          color: e.value ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
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
                        side:
                            const BorderSide(color: Colors.white30),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                      ),
                      onPressed: () => setState(() {
                        _step = 1;
                        _votes = {};
                        _currentPlayerIndex = 0;
                        _currentQuestionIndex = 0;
                        _selectedPlayers = [];
                        _selectedCategories = [];
                      }),
                      child: Text('Play Again',
                          style: GoogleFonts.sora(
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.popUntil(
                          context, (r) => r.isFirst),
                      child: Text('Home',
                          style: GoogleFonts.sora(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
