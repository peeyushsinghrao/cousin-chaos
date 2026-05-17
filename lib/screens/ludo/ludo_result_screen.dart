import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/ludo_game_state.dart';
import '../../core/models/ludo_player.dart';
import '../../core/theme/app_colors.dart';

class LudoResultScreen extends StatefulWidget {
  final LudoGameState gameState;

  const LudoResultScreen({super.key, required this.gameState});

  @override
  State<LudoResultScreen> createState() => _LudoResultScreenState();
}

class _LudoResultScreenState extends State<LudoResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _fadeController;

  static const List<Color> _playerColors = [
    Color(0xFF4FC3F7),
    Color(0xFFEF5350),
    Color(0xFF66BB6A),
    Color(0xFFFFEE58),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    )..play();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  List<LudoPlayer> get _rankedPlayers {
    final sorted = [...widget.gameState.players]
      ..sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final ranked = _rankedPlayers;
    final winner = ranked.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                colors: const [
                  Color(0xFF4FC3F7),
                  Color(0xFFEF5350),
                  Color(0xFF66BB6A),
                  Color(0xFFFFEE58),
                  Colors.white,
                ],
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeController,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text('🏆', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 12),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            const LinearGradient(
                              colors: [AppColors.neonYellow, AppColors.neonOrange],
                            ).createShader(bounds),
                        child: Text(
                          'GAME OVER',
                          style: GoogleFonts.anybody(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${winner.name} wins! 🎉',
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 36),
                      _buildPodium(ranked),
                      const SizedBox(height: 28),
                      _buildDetailedScores(ranked),
                      const SizedBox(height: 24),
                      _buildSpecialAwards(),
                      const SizedBox(height: 32),
                      _buildActionButtons(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<LudoPlayer> ranked) {
    if (ranked.isEmpty) return const SizedBox.shrink();

    final heights = [140.0, 110.0, 85.0, 65.0];
    final rankColors = [
      AppColors.gold,
      AppColors.textSecondary,
      AppColors.neonOrange,
      AppColors.textMuted,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(ranked.length, (i) {
        final p = ranked[i];
        final color = rankColors[i];
        final playerColor = _playerColors[p.index];
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                ['🥇', '🥈', '🥉', '4️⃣'][i],
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                p.name,
                style: GoogleFonts.sora(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withAlpha(80), color.withAlpha(40)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border.all(color: playerColor.withAlpha(150)),
                ),
                child: Center(
                  child: Text(
                    '${p.score}',
                    style: GoogleFonts.anybody(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailedScores(List<LudoPlayer> ranked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Final Scores',
          style: GoogleFonts.sora(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < ranked.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _playerColors[ranked[i].index].withAlpha(60),
              ),
            ),
            child: Row(children: [
              Text(['🥇', '🥈', '🥉', '4️⃣'][i],
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _playerColors[ranked[i].index],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(
                ranked[i].name,
                style: GoogleFonts.sora(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14,
                ),
              )),
              Text(
                '${ranked[i].score} pts',
                style: GoogleFonts.anybody(
                  fontWeight: FontWeight.w900,
                  color: _playerColors[ranked[i].index],
                  fontSize: 16,
                ),
              ),
            ]),
          ),
      ],
    );
  }

  Widget _buildSpecialAwards() {
    final players = widget.gameState.players;

    String? mostSabotages;
    int maxSab = 0;
    String? chaosChampion;
    int maxChaos = 0;

    for (final p in players) {
      if (p.sabotagePlayedCount > maxSab) {
        maxSab = p.sabotagePlayedCount;
        mostSabotages = p.name;
      }
      if (p.chaosCompletedCount > maxChaos) {
        maxChaos = p.chaosCompletedCount;
        chaosChampion = p.name;
      }
    }

    final awards = <(String, String, String)>[];
    if (mostSabotages != null && maxSab > 0) {
      awards.add(('💣', 'Most Sabotages', mostSabotages!));
    }
    if (chaosChampion != null && maxChaos > 0) {
      awards.add(('🌀', 'Chaos Survivor', chaosChampion!));
    }

    if (awards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Awards',
          style: GoogleFonts.sora(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        for (final (emoji, label, name) in awards)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withAlpha(40)),
            ),
            child: Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.sora(
                    color: AppColors.textMuted, fontSize: 11,
                  )),
                  Text(name, style: GoogleFonts.sora(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14,
                  )),
                ],
              )),
            ]),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withAlpha(80)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text('Home', style: GoogleFonts.sora(
              fontWeight: FontWeight.w700, fontSize: 15,
            )),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // back to setup
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text('Play Again', style: GoogleFonts.sora(
              fontWeight: FontWeight.w800, fontSize: 15,
            )),
          ),
        ),
      ],
    );
  }
}
