import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Player',
          style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Player name',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderGlass),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          onSubmitted: (_) {
            _addWithName(ctx, pm, controller.text.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.sora(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => _addWithName(ctx, pm, controller.text.trim()),
            child: Text('Add', style: GoogleFonts.sora(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
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
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Players',
                        style: GoogleFonts.sora(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddPlayerDialog(context, pm),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: pm.players.isEmpty
                      ? Center(
                          child: Text(
                            'No players yet.\nTap + to add one.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sora(color: Colors.white54, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: pm.players.length,
                          itemBuilder: (context, index) {
                            final player = pm.players[index];
                            return _PlayerCard(player: player, pm: pm);
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
}

class _PlayerCard extends StatefulWidget {
  final Player player;
  final PlayerManager pm;

  const _PlayerCard({required this.player, required this.pm});

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard> {
  bool _isEditing = false;
  late TextEditingController _nameController;

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ListTile(
          leading: PlayerAvatar(
            playerName: widget.player.name,
            color: AppColors.primary,
            size: 44,
          ),
          title: _isEditing
              ? TextField(
                  controller: _nameController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _save(),
                )
              : Text(
                  widget.player.name,
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
          subtitle: Text(
            '${widget.player.score} pts',
            style: GoogleFonts.sora(
              color: AppColors.gold,
              fontSize: 12,
            ),
          ),
          trailing: _isEditing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green, size: 20),
                      onPressed: _save,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: _delete,
                    ),
                  ],
                )
              : null,
          onTap: () => setState(() => _isEditing = true),
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
