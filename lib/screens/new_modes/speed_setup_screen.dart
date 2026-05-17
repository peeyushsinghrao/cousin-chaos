import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../services/player_manager.dart';
import '../../widgets/counter_row.dart';
import '../shared/pre_game_scaffold.dart';
import '../shared/player_confirm_list.dart';
import 'speed_challenge_screen.dart';

class SpeedSetupScreen extends StatefulWidget {
  const SpeedSetupScreen({super.key});

  @override
  State<SpeedSetupScreen> createState() => _SpeedSetupScreenState();
}

class _SpeedSetupScreenState extends State<SpeedSetupScreen> {
  int _challengeCount = 10;
  static const _color = AppColors.dareRed;

  void _startGame() {
    Navigator.push(context, slideUpRoute(const SpeedChallengeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.watch<PlayerManager>();
    return PreGameScaffold(
      modeName: 'Speed Challenge',
      modeColor: _color,
      step: 1,
      totalSteps: 1,
      ctaLabel: 'Start Game ⚡',
      ctaEnabled: pm.playerCount >= 2,
      onCta: _startGame,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Settings',
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Configure your Speed Challenge round',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            CounterRow(
              label: 'Challenges per Round',
              value: _challengeCount,
              min: 5,
              max: 20,
              accentColor: _color,
              recommendedLabel: 'Recommended: 10',
              onChanged: (v) => setState(() => _challengeCount = v),
            ),
            const SizedBox(height: 24),
            PlayerConfirmList(
              themeColor: _color,
              minPlayers: 2,
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
