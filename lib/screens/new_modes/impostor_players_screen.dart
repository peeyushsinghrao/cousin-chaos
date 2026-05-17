import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/page_transitions.dart';
import '../../models/impostor_player.dart';
import 'impostor_game_screen.dart';

class ImpostorPlayersScreen extends StatefulWidget {
  final String category;
  final bool timeLimitEnabled;
  final int timeLimitSeconds;
  final bool showCategoryToImpostor;
  final bool showHintToImpostor;

  const ImpostorPlayersScreen({
    super.key,
    required this.category,
    required this.timeLimitEnabled,
    required this.timeLimitSeconds,
    required this.showCategoryToImpostor,
    required this.showHintToImpostor,
  });

  @override
  State<ImpostorPlayersScreen> createState() => _ImpostorPlayersScreenState();
}

class _ImpostorPlayersScreenState extends State<ImpostorPlayersScreen> {
  final List<ImpostorPlayer> _players = [
    ImpostorPlayer(id: 'p1', name: 'Player 1'),
    ImpostorPlayer(id: 'p2', name: 'Player 2'),
    ImpostorPlayer(id: 'p3', name: 'Player 3'),
  ];

  int _nextId = 4;
  int? _editingIndex;
  late int _impostorCount;

  @override
  void initState() {
    super.initState();
    _impostorCount = _recommendedImpostorCount(_players.length);
  }

  int _recommendedImpostorCount(int playerCount) {
    if (playerCount <= 7) return 1;
    if (playerCount <= 9) return 2;
    if (playerCount <= 11) return 3;
    if (playerCount <= 13) return 4;
    if (playerCount <= 15) return 5;
    if (playerCount <= 17) return 6;
    if (playerCount <= 19) return 7;
    return 8;
  }

  void _addPlayer() {
    if (_players.length >= 20) return;
    HapticFeedback.lightImpact();
    setState(() {
      _players.add(ImpostorPlayer(id: 'p$_nextId', name: 'Player $_nextId'));
      _nextId++;
      final max = _players.length - 1;
      if (_impostorCount > max) _impostorCount = max;
    });
  }

  void _removePlayer() {
    if (_players.length <= 3) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (_editingIndex != null && _editingIndex! >= _players.length - 1) {
        _editingIndex = null;
      }
      _players.removeLast();
      final max = _players.length - 1;
      if (_impostorCount > max) _impostorCount = max.clamp(1, max);
    });
  }

  void _showImpostorCountSheet() {
    final max = _players.length - 1;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Impostors', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          ...List.generate(max, (i) {
            final n = i + 1;
            return ListTile(
              title: Text('$n impostor${n > 1 ? 's' : ''}', style: GoogleFonts.poppins(color: Colors.white)),
              trailing: _impostorCount == n ? const Icon(Icons.check_rounded, color: AppColors.neonPink) : null,
              onTap: () {
                setState(() => _impostorCount = n);
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _startGame() {
    HapticFeedback.mediumImpact();
    setState(() => _editingIndex = null);
    Navigator.push(
      context,
      slideUpRoute(ImpostorGameScreen(
        category: widget.category,
        players: List.from(_players),
        impostorCount: _impostorCount,
        timeLimitEnabled: widget.timeLimitEnabled,
        timeLimitSeconds: widget.timeLimitEnabled ? widget.timeLimitSeconds : null,
        showCategoryToImpostor: widget.showCategoryToImpostor,
        showHintToImpostor: widget.showHintToImpostor,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGlass, width: 1),
            ),
            child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
          ),
        ),
        title: Text(
          'PLAYERS',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonPink,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.neonPink.withAlpha(25), AppColors.background],
            radius: 1.0,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_players.length} players',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Tap a name to rename',
                        style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCircleButton(
                        Icons.remove_rounded,
                        _players.length <= 3 ? null : _removePlayer,
                        AppColors.dareRed,
                      ),
                      const SizedBox(width: 12),
                      _buildCircleButton(
                        Icons.add_rounded,
                        _players.length >= 20 ? null : _addPlayer,
                        AppColors.neonGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _players.length,
                itemBuilder: (context, i) => _buildPlayerRow(i),
              ),
            ),
            _buildImpostorRow(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPink,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _startGame,
                  child: Text(
                    'START GAME',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpostorRow() {
    return GestureDetector(
      onTap: _showImpostorCountSheet,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.surfaceBright),
        ),
        child: Row(
          children: [
            Icon(Icons.person_off_rounded, color: AppColors.neonPink, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Impostors',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            Text(
              '$_impostorCount',
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow(int index) {
    final player = _players[index];
    final isEditing = _editingIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _editingIndex = isEditing ? null : index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isEditing ? AppColors.neonPink.withAlpha(20) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEditing ? AppColors.neonPink.withAlpha(128) : AppColors.surfaceBright,
            width: isEditing ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.truthBlue.withAlpha(200),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: isEditing
                  ? TextFormField(
                      initialValue: player.name,
                      autofocus: true,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (v) => _players[index].name = v,
                      onFieldSubmitted: (_) => setState(() => _editingIndex = null),
                    )
                  : Text(
                      player.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            Icon(
              isEditing ? Icons.check_rounded : Icons.edit_rounded,
              color: isEditing ? AppColors.neonPink : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback? onTap, Color color) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: enabled ? color.withAlpha(30) : AppColors.surfaceLight.withAlpha(100),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: enabled ? color.withAlpha(100) : AppColors.surfaceBright),
        ),
        child: Icon(icon, color: enabled ? color : AppColors.textMuted, size: 22),
      ),
    );
  }
}
