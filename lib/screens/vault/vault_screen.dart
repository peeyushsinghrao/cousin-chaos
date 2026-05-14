import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/session_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  late Future<List<SessionRecord>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = SessionService.loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vault',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 34,
                  )),
              const SizedBox(height: 8),
              Text('Relive the anarchy',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  )),
              const SizedBox(height: 24),
              Text('CHAOS MILESTONES',
                  style: GoogleFonts.sora(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildMilestoneCard('First Burn', 'Complete your first game', 0.75),
                    _buildMilestoneCard('Chaos Streak', 'Win 3 days in a row', 0.4),
                    _buildMilestoneCard('Elite Jury', 'Vote in 10 sessions', 0.92),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('RECENT WINS',
                  style: GoogleFonts.sora(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 16),
              GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1F1945), Color(0xFF0F0A18)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Chaos Night',
                                  style: GoogleFonts.anybody(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  )),
                              const Spacer(),
                              Text('May 11 • 10 players',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildMiniSessionCard('Impostor', 'WIN')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMiniSessionCard('Bomb Pass', 'LOSS')),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Wins', '24')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Chaos Rating', '87%')),
                ],
              ),
              const SizedBox(height: 24),
              Text('UNLOCKED BADGES',
                  style: GoogleFonts.sora(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildBadgeCard('🔥', 'First Flame', true),
                  _buildBadgeCard('👑', 'Chaos Master', true),
                  _buildBadgeCard('🗝️', 'Secret Finder', false),
                  _buildBadgeCard('🌀', 'Double Trouble', true),
                ],
              ),
              const SizedBox(height: 24),
              Text('RECENT SESSIONS',
                  style: GoogleFonts.sora(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 16),
              FutureBuilder<List<SessionRecord>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  final sessions = snapshot.data ?? [];
                  if (sessions.isEmpty) {
                    return GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Center(
                        child: Text(
                          'No sessions saved yet.',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: sessions.take(3).map((session) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.secondary.withOpacity(0.2),
                                child: Text(session.mode.substring(0, 1), style: const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
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
                                    const SizedBox(height: 6),
                                    Text(
                                      '${session.winner} won • ${session.playedAt.month}/${session.playedAt.day}/${session.playedAt.year}',
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
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(String title, String subtitle, double progress) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  )),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  )),
              const Spacer(),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('${(progress * 100).toInt()}%',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniSessionCard(String title, String tag) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.sora(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              )),
          const Spacer(),
          Text(tag,
              style: GoogleFonts.sora(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 12,
              )),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.sora(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 32,
              )),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(String icon, String label, bool unlocked) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Opacity(
        opacity: unlocked ? 1 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                )),
          ],
        ),
      ),
    );
  }
}
