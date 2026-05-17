import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/player.dart';
import '../../services/player_manager.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerManager>(
      builder: (context, pm, _) {
        final sorted = [...pm.players]..sort((a, b) => b.xp.compareTo(a.xp));
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Leaderboard', style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('All-time XP rankings', style: GoogleFonts.sora(fontSize: 12, color: AppColors.gold.withAlpha(180), fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showResetDialog(context, pm);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withAlpha(15)),
                          ),
                          child: Icon(LucideIcons.refreshCw, color: Colors.white38, size: 17),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (sorted.length >= 3) _buildPodium(sorted.take(3).toList()),
                const SizedBox(height: 16),
                if (sorted.length > 3) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Rankings', style: GoogleFonts.sora(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 10),
                ],
                Expanded(
                  child: sorted.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: sorted.length > 3 ? sorted.length - 3 : (sorted.length < 3 ? sorted.length : 0),
                          itemBuilder: (_, i) {
                            final rank = sorted.length >= 3 ? i + 4 : i + 1;
                            final player = sorted.length >= 3 ? sorted[i + 3] : sorted[i];
                            return _buildRankTile(player, rank, i);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodium(List<Player> top) {
    final colors = [AppColors.gold, const Color(0xFFB0B8C0), const Color(0xFFCD7F32)];
    final emojis = ['🥇', '🥈', '🥉'];
    final order = top.length == 1 ? [0] : top.length == 2 ? [0, 1] : [1, 0, 2];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: order.map((i) {
          if (i >= top.length) return const SizedBox.shrink();
          final player = top[i];
          final isFirst = i == 0;
          final height = isFirst ? 110.0 : (i == 1 ? 85.0 : 70.0);
          final color = colors[i];

          return Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 500 + i * 120),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Text(emojis[i], style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      player.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sora(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: isFirst ? 14 : 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${player.xp} XP',
                      style: GoogleFonts.sora(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withAlpha(80), color.withAlpha(30)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        border: Border.all(color: color.withAlpha(100)),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.sora(color: color, fontWeight: FontWeight.w900, fontSize: isFirst ? 28 : 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankTile(Player player, int rank, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF120E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(14)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '#$rank',
                  style: GoogleFonts.sora(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha(20),
                  border: Border.all(color: AppColors.primary.withAlpha(50)),
                ),
                child: Center(child: Text(player.name[0].toUpperCase(), style: GoogleFonts.sora(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(player.name, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
              _buildXpBadge(player.xp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildXpBadge(int xp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
          const SizedBox(width: 4),
          Text('$xp XP', style: GoogleFonts.sora(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No rankings yet', style: GoogleFonts.sora(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Play games to earn XP!', style: GoogleFonts.sora(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, PlayerManager pm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1428),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Reset XP?', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('This resets all players\' XP to 0. Scores for the current session are not affected.', style: GoogleFonts.sora(color: Colors.white54, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.sora(color: Colors.white38))),
          TextButton(
            onPressed: () {
              for (final p in pm.players) pm.addXp(p.id, -p.xp);
              Navigator.pop(ctx);
            },
            child: Text('Reset', style: GoogleFonts.sora(color: AppColors.dareRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
