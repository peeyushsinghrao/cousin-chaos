import 'package:cousin_chaos/core/icons.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/leave_game_dialog.dart';
import '../../services/player_manager.dart';
import '../../services/session_service.dart';
import '../../widgets/category_selector.dart';
import '../truth_or_dare/widgets/physics_wheel.dart';

class ActItOutScreen extends StatefulWidget {
  const ActItOutScreen({super.key});

  @override
  State<ActItOutScreen> createState() => _ActItOutScreenState();
}

class _ActItOutScreenState extends State<ActItOutScreen> {
  int _step = 1;
  List<String> _selectedCategories = [];
  List<String> _selectedPlayers = [];
  String _currentPlayer = '';
  String _currentChallenge = '';
  Map<String, int> _penalties = {};
  int _roundsPlayed = 0;
  final int _totalRounds = 3;

  late ConfettiController _confettiController;
  final GlobalKey<PhysicsWheelState> _wheelKey =
      GlobalKey<PhysicsWheelState>();

  static const _categories = [
    'Animals',
    'Movies',
    'Songs',
    'Sports',
    'Jobs',
    'Famous People',
    'Food',
    'Emotions',
    'TV Shows',
    'Actions',
  ];

  static const _challengeMap = {
    'Animals': [
      'Act like a cat who just saw a cucumber',
      'Be a dog learning to drive',
      'Mimic a penguin on a treadmill',
      'Act like a horse at the dentist',
    ],
    'Movies': [
      'Recreate a scene from Titanic with no words',
      'Act out a superhero landing badly',
      'Be an alien seeing humans for the first time',
      'Act like a spy who lost their earpiece',
    ],
    'Songs': [
      'Act like you\'re performing at a stadium but your voice is gone',
      'Mime playing every instrument in a one-man band',
      'Be a DJ with no headphones',
      'Act like you\'re auditioning for a choir but can only hum',
    ],
    'Sports': [
      'Play tennis against an invisible opponent who keeps winning',
      'Be a goalkeeper who\'s terrified of the ball',
      'Act like a swimmer in a pool that keeps shrinking',
      'Be a weightlifter who forgot how to lift',
    ],
    'Jobs': [
      'Be a chef who forgot every recipe',
      'Act like a surgeon who is also a mime',
      'Be a tour guide who doesn\'t know where they are',
      'Act like a pilot who is scared of heights',
    ],
    'Famous People': [
      'Walk like a president on a red carpet',
      'Act like a celebrity tripping on the runway',
      'Mime accepting a Grammy for a terrible song',
      'Act like a famous scientist explaining gravity to a cat',
    ],
    'Food': [
      'Act like you\'re eating something extremely spicy',
      'Be spaghetti being cooked in a pot',
      'Act like a popcorn kernel just before popping',
      'Be a pancake being flipped by a nervous chef',
    ],
    'Emotions': [
      'Act happy but your face can only look sad',
      'Be surprised in slow motion',
      'Act embarrassed at a very important meeting',
      'Be angry but in complete silence',
    ],
    'TV Shows': [
      'Be a news anchor reporting the most boring story ever',
      'Act out a cooking show where everything goes wrong',
      'Be a game show host who forgot the game rules',
      'Act like you\'re in a soap opera but nothing dramatic happens',
    ],
    'Actions': [
      'Walk through an invisible revolving door',
      'Open a jar that absolutely will not open',
      'Try to quietly sneak past someone but you\'re in bubble wrap',
      'Act like you\'re texting while hiking up a mountain',
    ],
  };

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pm = context.read<PlayerManager>();
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

  String _getChallenge(List<String> categories) {
    final rng = Random();
    final cat =
        categories[rng.nextInt(categories.length)];
    final list = _challengeMap[cat] ?? _challengeMap.values.first;
    return list[rng.nextInt(list.length)];
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
                    AppColors.tertiary,
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

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _buildCategorySelection();
      case 2:
        return _buildPlayerSelection();
      case 3:
        return _buildSpinWheel();
      case 4:
        return _buildChallenge();
      case 5:
        return _buildWhoLaughed();
      case 6:
        return _buildResults();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategorySelection() {
    return Padding(
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
                'Act It Out',
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
            'Pick categories to act from',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: CategorySelector(
                categories: _categories,
                initialSelected: _selectedCategories.isEmpty
                    ? [_categories.first]
                    : _selectedCategories,
                onChanged: (cats) =>
                    setState(() => _selectedCategories = cats),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PrimaryButton(
            label: 'Next',
            icon: LucideIcons.arrowRight,
            enabled: _selectedCategories.isNotEmpty,
            onTap: () => setState(() => _step = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSelection() {
    return Consumer<PlayerManager>(
      builder: (context, pm, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(LucideIcons.arrowLeft, color: Colors.white),
                  onPressed: () => setState(() => _step = 1),
                ),
                Text(
                  'Select Players',
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              '${_selectedPlayers.length} / 10 selected',
              style: TextStyle(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pm.players.length,
                itemBuilder: (context, i) {
                  final p = pm.players[i];
                  final selected =
                      _selectedPlayers.contains(p.name);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (selected) {
                          _selectedPlayers.remove(p.name);
                        } else if (_selectedPlayers.length < 10) {
                          _selectedPlayers.add(p.name);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withAlpha(40)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
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
                            radius: 18,
                            backgroundColor:
                                AppColors.primary.withAlpha(60),
                            child: Text(
                              p.name[0].toUpperCase(),
                              style: TextStyle(
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
                            Icon(LucideIcons.checkCircle,
                                color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _PrimaryButton(
              label: 'Start',
              icon: LucideIcons.play,
              enabled: _selectedPlayers.length >= 2,
              onTap: () {
                _penalties = {
                  for (var p in _selectedPlayers) p: 0
                };
                setState(() => _step = 3);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinWheel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Spin to pick a performer!',
            style: GoogleFonts.sora(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Round ${(_roundsPlayed ~/ _selectedPlayers.length) + 1} of $_totalRounds',
            style: TextStyle(color: AppColors.primary),
          ),
          const Spacer(),
          PhysicsWheel(
            key: _wheelKey,
            items: _selectedPlayers,
            size: 260,
            onSpinComplete: (index) {
              _currentPlayer = _selectedPlayers[index];
              _currentChallenge =
                  _getChallenge(_selectedCategories);
              setState(() => _step = 4);
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildChallenge() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 44),
              Text(
                'ACT IT OUT',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.logOut,
                    color: Colors.white38, size: 20),
                onPressed: () async {
                  final leave = await showLeaveGameSheet(context);
                  if (leave == true && mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
          const Spacer(),
          Text(
            _currentPlayer,
            style: GoogleFonts.sora(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: AppColors.secondary.withAlpha(120),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'it\'s your turn!',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: AppColors.secondary.withAlpha(80)),
              boxShadow: [
                BoxShadow(
                    color: AppColors.secondary.withAlpha(30),
                    blurRadius: 30)
              ],
            ),
            child: Text(
              _currentChallenge,
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                fontSize: 18,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _CountdownTimer(
            key: ValueKey(_currentChallenge),
            seconds: 60,
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _step = 5),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.withAlpha(40),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.pinkAccent.withAlpha(100)),
                    ),
                    child: Column(
                      children: [
                        const Text('😂', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          'Someone Laughed',
                          style: TextStyle(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
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
                    _currentChallenge =
                        _getChallenge(_selectedCategories);
                    setState(() {});
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        const Text('😐', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          'No One Laughed',
                          style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildWhoLaughed() {
    String? selectedLaugher;
    return StatefulBuilder(
      builder: (context, innerSet) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Who Laughed? 😂',
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the guilty one',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: _selectedPlayers
                    .where((p) => p != _currentPlayer)
                    .map(
                      (p) => GestureDetector(
                        onTap: () =>
                            innerSet(() => selectedLaugher = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: selectedLaugher == p
                                ? Colors.pinkAccent.withAlpha(40)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedLaugher == p
                                  ? Colors.pinkAccent
                                  : Colors.white12,
                              width: selectedLaugher == p ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.pinkAccent
                                    .withAlpha(60),
                                child: Text(
                                  p[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  p,
                                  style: GoogleFonts.sora(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (selectedLaugher == p)
                                const Icon(Icons.emoji_emotions_rounded,
                                    color: Colors.pinkAccent,
                                    size: 20),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            _PrimaryButton(
              label: 'Confirm',
              icon: LucideIcons.check,
              enabled: selectedLaugher != null,
              onTap: () {
                _penalties[selectedLaugher!] =
                    (_penalties[selectedLaugher!] ?? 0) + 1;
                _roundsPlayed++;
                if (_roundsPlayed >=
                    _selectedPlayers.length * _totalRounds) {
                  _confettiController.play();
                  setState(() => _step = 6);
                } else {
                  setState(() => _step = 3);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final sorted = _penalties.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final winner = sorted.first.key;
    final pm = context.read<PlayerManager>();

    SessionService.saveSession(SessionRecord(
      id: const Uuid().v4(),
      mode: 'Act It Out',
      playedAt: DateTime.now(),
      players: _selectedPlayers,
      winner: winner,
      themeColor: 'purple',
    ));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            '🎉 $winner wins!',
            style: GoogleFonts.sora(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Fewest penalties wins!',
            style: TextStyle(color: Colors.white54),
          ),
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
                        isFirst ? '🏆' : '${e.key + 1}.',
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
                        '${e.value.value} penalties',
                        style: TextStyle(
                          color: e.value.value == 0
                              ? AppColors.neonGreen
                              : Colors.white54,
                          fontWeight: FontWeight.w600,
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
                    _step = 1;
                    _penalties = {};
                    _roundsPlayed = 0;
                    _selectedPlayers = [];
                    _selectedCategories = [];
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.mediumImpact();
              onTap();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.primaryGradient : null,
          color: enabled ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: enabled ? Colors.white : Colors.white38,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon,
                color: enabled ? Colors.white : Colors.white38,
                size: 18),
          ],
        ),
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  final int seconds;

  const _CountdownTimer({super.key, required this.seconds});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _start();
  }

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining > 0) {
        setState(() => _remaining--);
        if (_remaining <= 10) HapticFeedback.selectionClick();
      } else {
        _timer?.cancel();
        HapticFeedback.heavyImpact();
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
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _remaining / widget.seconds,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                color: isLow ? AppColors.dareRed : AppColors.secondary,
                backgroundColor: AppColors.surfaceBright,
              ),
              Text(
                '$_remaining',
                style: GoogleFonts.sora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isLow ? AppColors.dareRed : Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isLow ? 'Time\'s almost up!' : 'seconds remaining',
          style: TextStyle(
            color: isLow ? AppColors.dareRed : Colors.white38,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
