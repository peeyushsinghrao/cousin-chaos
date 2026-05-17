import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/player.dart';
import '../../services/player_manager.dart';

class PlayerConfirmList extends StatefulWidget {
  final int minPlayers;
  final int maxPlayers;
  final Color themeColor;
  final ValueChanged<List<Player>> onChanged;

  const PlayerConfirmList({
    super.key,
    this.minPlayers = 2,
    this.maxPlayers = 10,
    required this.themeColor,
    required this.onChanged,
  });

  @override
  State<PlayerConfirmList> createState() => _PlayerConfirmListState();
}

class _PlayerConfirmListState extends State<PlayerConfirmList> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    final pm = context.read<PlayerManager>();
    _selectedIds = pm.players.map((p) => p.id).toSet();
    _notify();
  }

  void _notify() {
    final pm = context.read<PlayerManager>();
    final sel =
        pm.players.where((p) => _selectedIds.contains(p.id)).toList();
    widget.onChanged(sel);
  }

  void _toggle(String id) {
    HapticFeedback.selectionClick();
    final pm = context.read<PlayerManager>();
    final selectedCount = _selectedIds.length;
    setState(() {
      if (_selectedIds.contains(id)) {
        if (selectedCount > widget.minPlayers) {
          _selectedIds.remove(id);
        }
      } else if (selectedCount < widget.maxPlayers) {
        _selectedIds.add(id);
      }
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerManager>(
      builder: (_, pm, __) {
        if (pm.players.isEmpty) {
          return Center(
            child: Text(
              'No players yet.\nAdd players from the Players tab.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PLAYERS (${_selectedIds.length}/${pm.players.length})',
                  style: GoogleFonts.sora(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...pm.players.map((p) {
              final selected = _selectedIds.contains(p.id);
              return GestureDetector(
                onTap: () => _toggle(p.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? widget.themeColor.withAlpha(20)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? widget.themeColor
                          : AppColors.surfaceBright,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: selected
                            ? widget.themeColor.withAlpha(60)
                            : AppColors.surfaceLight,
                        child: Text(
                          p.name.isNotEmpty
                              ? p.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color:
                                selected ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.name,
                          style: GoogleFonts.sora(
                            color: selected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: selected
                              ? widget.themeColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: selected
                                ? widget.themeColor
                                : Colors.white30,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
