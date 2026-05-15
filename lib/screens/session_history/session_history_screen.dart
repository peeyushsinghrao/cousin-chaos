import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../widgets/player_avatar.dart';
import '../../services/session_service.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  List<SessionRecord> _sessions = [];
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await SessionService.loadSessions();
    setState(() => _sessions = sessions);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _sessions.where((session) {
      if (_filter == 'All') return true;
      final days = DateTime.now().difference(session.playedAt).inDays;
      if (_filter == 'This Week') return days < 7;
      if (_filter == 'This Month') return days < 30;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('The Archives', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['All', 'This Week', 'This Month'].map((label) {
                final selected = _filter == label;
                return GestureDetector(
                  onTap: () => setState(() => _filter = label),
                  child: GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Text(label,
                        style: GoogleFonts.plusJakartaSans(
                          color: selected ? Colors.white : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.archive_outlined, size: 64, color: AppColors.textSecondary.withAlpha(128)),
                          const SizedBox(height: 16),
                          Text('No chaos recorded yet',
                              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final session = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            borderRadius: 24,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary.withAlpha(46),
                                      ),
                                      child: const Icon(Icons.sports_esports_rounded, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(session.mode,
                                              style: GoogleFonts.sora(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              )),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${session.playedAt.month}/${session.playedAt.day}/${session.playedAt.year} • ${session.playedAt.hour.toString().padLeft(2, '0')}:${session.playedAt.minute.toString().padLeft(2, '0')}',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: session.players.take(4).map((name) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: PlayerAvatar(
                                        playerName: name,
                                        color: AppColors.secondary,
                                        size: 36,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 18),
                                    const SizedBox(width: 8),
                                    Text(session.winner,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        )),
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
    );
  }
}
