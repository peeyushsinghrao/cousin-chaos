import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/player_manager.dart';

class CrewScreen extends StatelessWidget {
  const CrewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = context.watch<PlayerManager>().players;
    final sortedPlayers = List.of(players)..sort((a, b) => b.score.compareTo(a.score));
    final podium = sortedPlayers.take(3).toList();
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CREW ELITE',
                  style: GoogleFonts.anybody(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: 2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(13),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withAlpha(128)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Invite',
                        style: GoogleFonts.sora(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildPodium(podium),
            const SizedBox(height: 40),
            Text(
              'TOP CHALLENGERS',
              style: GoogleFonts.sora(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedPlayers.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              if (index < 3) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.sora(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildListAvatar(player.name, AppColors.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: GoogleFonts.sora(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Win Rate 67%',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${player.score} CP',
                        style: GoogleFonts.sora(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<dynamic> podium) {
    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (podium.length > 1)
            Expanded(child: _buildPodiumSpot(podium[1], 2)),
          const SizedBox(width: 8),
          Expanded(child: _buildPodiumSpot(podium.isNotEmpty ? podium[0] : null, 1)),
          const SizedBox(width: 8),
          if (podium.length > 2)
            Expanded(child: _buildPodiumSpot(podium[2], 3)),
          if (podium.length <= 2) const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(dynamic player, int rank) {
    if (player == null) return const SizedBox();

    double avatarSize;
    Color borderColor;
    double borderWidth;
    double glowOpacity;
    double heightOffset;

    switch (rank) {
      case 1:
        avatarSize = 88;
        borderColor = AppColors.gold;
        borderWidth = 3;
        glowOpacity = 0.5;
        heightOffset = 0;
        break;
      case 2:
        avatarSize = 72;
        borderColor = AppColors.primary;
        borderWidth = 2.5;
        glowOpacity = 0.3;
        heightOffset = 20;
        break;
      case 3:
      default:
        avatarSize = 64;
        borderColor = AppColors.secondary;
        borderWidth = 2;
        glowOpacity = 0.2;
        heightOffset = 40;
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (rank == 1)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.emoji_events, color: AppColors.gold, size: 24),
          ),
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(glowOpacity),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              player.name.substring(0, player.name.length >= 2 ? 2 : player.name.length).toUpperCase(),
              style: GoogleFonts.sora(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: avatarSize * 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          player.name,
          style: GoogleFonts.sora(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${player.score} CP',
          style: GoogleFonts.sora(
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        SizedBox(height: heightOffset),
      ],
    );
  }

  Widget _buildListAvatar(String name, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(76), width: 1),
      ),
      child: Center(
        child: Text(
          name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase(),
          style: GoogleFonts.sora(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
