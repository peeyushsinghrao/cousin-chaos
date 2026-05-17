import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/player.dart';
import '../../services/player_manager.dart';
import '../../widgets/player_avatar.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  void _showAddPlayerDialog(BuildContext context, PlayerManager pm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1428),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person_add_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              'Add Player',
              style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.sora(color: Colors.white, fontSize: 15),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Enter player name…',
            hintStyle: GoogleFonts.sora(color: Colors.white30, fontSize: 14),
            filled: true,
            fillColor: Colors.white.withAlpha(8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withAlpha(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withAlpha(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary.withAlpha(180), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onSubmitted: (_) => _addWithName(ctx, pm, controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.sora(color: Colors.white38)),
          ),
          GestureDetector(
            onTap: () => _addWithName(ctx, pm, controller.text.trim()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Add',
                style: GoogleFonts.sora(
                  color: const Color(0xFF0A0518),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _addWithName(BuildContext ctx, PlayerManager pm, String name) {
    pm.addPlayer();
    if (name.isNotEmpty) {
      final newPlayer = pm.players.last;
      pm.updatePlayerName(newPlayer.id, name);
    }
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerManager>(
      builder: (context, pm, _) {
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
                          Text(
                            'Players',
                            style: GoogleFonts.sora(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            pm.players.isEmpty
                                ? 'No players yet'
                                : '${pm.players.length} player${pm.players.length == 1 ? '' : 's'} ready',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: pm.players.isEmpty ? Colors.white30 : AppColors.primary.withAlpha(180),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showAddPlayerDialog(context, pm);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(60),
                                blurRadius: 14,
                                spreadRadius: -2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.plus, color: Color(0xFF0A0518), size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: pm.players.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: pm.players.length,
                          itemBuilder: (ctx, i) => _PlayerCard(
                            player: pm.players[i],
                            pm: pm,
                            rank: i + 1,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withAlpha(30)),
            ),
            child: Icon(LucideIcons.users, color: AppColors.primary.withAlpha(150), size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'No players yet',
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first player',
            style: GoogleFonts.sora(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatefulWidget {
  final Player player;
  final PlayerManager pm;
  final int rank;

  const _PlayerCard({required this.player, required this.pm, required this.rank});

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  final List<Color> _rankColors = [
    AppColors.gold,
    const Color(0xFFB0B8C0),
    const Color(0xFFCD7F32),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color get _avatarColor {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.neonGreen,
      AppColors.neonOrange,
      AppColors.neonYellow,
    ];
    return colors[(widget.rank - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = widget.rank <= 3 ? _rankColors[widget.rank - 1] : Colors.white24;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF120E1E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withAlpha(14)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                alignment: Alignment.center,
                child: Text(
                  '#${widget.rank}',
                  style: GoogleFonts.sora(
                    color: rankColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PlayerAvatar(
                playerName: widget.player.name,
                color: _avatarColor,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isEditing
                        ? TextField(
                            controller: _nameController,
                            autofocus: true,
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            cursorColor: AppColors.primary,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) => _save(),
                          )
                        : GestureDetector(
                            onTap: () => setState(() => _isEditing = true),
                            child: Text(
                              widget.player.name,
                              style: GoogleFonts.sora(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: AppColors.gold, size: 11),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.player.score} pts',
                          style: GoogleFonts.sora(
                            color: AppColors.gold.withAlpha(200),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_isEditing) ...[
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withAlpha(25),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(LucideIcons.check, color: AppColors.neonGreen, size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _delete,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.dareRed.withAlpha(25),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(LucideIcons.trash, color: AppColors.dareRed, size: 16),
                  ),
                ),
              ] else
                GestureDetector(
                  onTap: () => setState(() => _isEditing = true),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(8),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(LucideIcons.edit, color: Colors.white38, size: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.pm.updatePlayerName(widget.player.id, name);
    }
    setState(() => _isEditing = false);
  }

  void _delete() {
    widget.pm.removePlayer(widget.player.id);
  }
}
