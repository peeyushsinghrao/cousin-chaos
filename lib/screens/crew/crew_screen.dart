import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/player_avatar.dart';
import '../../widgets/glass_card.dart';
import '../../services/player_manager.dart';

class CrewScreen extends StatelessWidget {
  const CrewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = context.watch<PlayerManager>().players;
    final sortedPlayers = List.of(players)..sort((a, b) => b.score.compareTo(a.score));
    final podium = sortedPlayers.take(3).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Crew Elite',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 34,
                  )),
              const SizedBox(height: 8),
              Text('The crew leaderboard',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  )),
              const SizedBox(height: 24),
              SizedBox(
                height: 260,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (podium.length > 1)
                      Expanded(child: _buildPodiumSpot(context, podium[1], 2, 0.8, AppColors.secondary)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPodiumSpot(context, podium.isNotEmpty ? podium[0] : null, 1, 1.0, AppColors.gold)),
                    const SizedBox(width: 12),
                    if (podium.length > 2)
                      Expanded(child: _buildPodiumSpot(context, podium[2], 3, 0.7, AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Top Challengers',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  )),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = sortedPlayers[index];
                    if (index < 3) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text('${index + 1}',
                                style: GoogleFonts.sora(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                )),
                            const SizedBox(width: 14),
                            PlayerAvatar(playerName: player.name, color: AppColors.secondary, size: 48),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(player.name,
                                      style: GoogleFonts.sora(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      )),
                                  const SizedBox(height: 4),
                                  Text('Win Rate 67%',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      )),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${player.score} CP',
                                    style: GoogleFonts.sora(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    )),
                                const SizedBox(height: 6),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index.isEven ? Colors.green : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumSpot(BuildContext context, dynamic player, int rank, double heightFactor, Color glow) {
    if (player == null) {
      return const SizedBox.shrink();
    }
    final double baseHeight = 220 * heightFactor;
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Container(
        height: baseHeight,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (rank == 1)
              Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 32)
            else
              const SizedBox(height: 32),
            PlayerAvatar(playerName: player.name, color: glow, size: 80, isActive: rank == 1),
            Column(
              children: [
                Text('Rank $rank',
                    style: GoogleFonts.sora(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    )),
                const SizedBox(height: 6),
                Text(player.name,
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
                const SizedBox(height: 4),
                Text('${player.score} CP',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
