import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/ludo_player.dart';
import '../../../core/theme/app_colors.dart';

class ScoreboardSheet extends StatelessWidget {
  final List<LudoPlayer> players;

  const ScoreboardSheet({super.key, required this.players});

  static const List<Color> _playerColors = [
    Color(0xFF4FC3F7),
    Color(0xFFEF5350),
    Color(0xFF66BB6A),
    Color(0xFFFFEE58),
  ];

  @override
  Widget build(BuildContext context) {
    final sorted = [...players]..sort((a, b) => b.score.compareTo(a.score));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          Text(
            'Scoreboard',
            style: GoogleFonts.anybody(
              fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < sorted.length; i++)
            _buildRow(sorted[i], i + 1),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRow(LudoPlayer p, int rank) {
    final color = _playerColors[p.index];
    final rankEmojis = ['🥇', '🥈', '🥉', '4️⃣'];
    final rankEmoji = rank <= 4 ? rankEmojis[rank - 1] : '$rank';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(children: [
        Text(rankEmoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(
          p.name,
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15,
          ),
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${p.score} pts',
            style: GoogleFonts.anybody(
              fontWeight: FontWeight.w900, color: color, fontSize: 16,
            ),
          ),
          Text(
            '${p.finishedCount}/4 home',
            style: GoogleFonts.sora(color: AppColors.textMuted, fontSize: 10),
          ),
        ]),
      ]),
    );
  }
}
