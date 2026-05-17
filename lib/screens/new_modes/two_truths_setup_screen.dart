import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../services/player_manager.dart';
import '../../widgets/disclaimer_dialog.dart';
import '../shared/pre_game_scaffold.dart';
import '../shared/player_confirm_list.dart';
import 'two_truths_one_lie_screen.dart';

class TwoTruthsSetupScreen extends StatefulWidget {
  const TwoTruthsSetupScreen({super.key});

  @override
  State<TwoTruthsSetupScreen> createState() => _TwoTruthsSetupScreenState();
}

class _TwoTruthsSetupScreenState extends State<TwoTruthsSetupScreen> {
  int _writeTimeSec = 90;
  int _voteTimeSec = 30;

  static const _color = Color(0xFF93C5FD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDisclaimer());
  }

  void _showDisclaimer() {
    DisclaimerDialog.show(context, () {});
  }

  void _startGame() {
    final pm = context.read<PlayerManager>();
    if (pm.playerCount < 2) return;
    Navigator.push(
      context,
      slideUpRoute(TwoTruthsOneLieScreen(
        writeTimeSec: _writeTimeSec,
        voteTimeSec: _voteTimeSec,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.watch<PlayerManager>();
    return PreGameScaffold(
      modeName: 'Two Truths One Lie',
      modeColor: _color,
      step: 1,
      totalSteps: 1,
      ctaLabel: 'Start Game 🎭',
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
              'Customise timers for each round',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _TimeSelector(
              label: 'WRITING TIME',
              value: _writeTimeSec,
              options: const [30, 45, 60, 90, 120, 180],
              color: _color,
              onChanged: (v) => setState(() => _writeTimeSec = v),
            ),
            const SizedBox(height: 16),
            _TimeSelector(
              label: 'VOTING TIME',
              value: _voteTimeSec,
              options: const [15, 20, 30, 45, 60],
              color: _color,
              onChanged: (v) => setState(() => _voteTimeSec = v),
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

class _TimeSelector extends StatelessWidget {
  final String label;
  final int value;
  final List<int> options;
  final Color color;
  final ValueChanged<int> onChanged;

  const _TimeSelector({
    required this.label,
    required this.value,
    required this.options,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sora(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final selected = value == opt;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? color.withAlpha(30) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? color : AppColors.surfaceBright,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(
                  '${opt}s',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : Colors.white54,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
