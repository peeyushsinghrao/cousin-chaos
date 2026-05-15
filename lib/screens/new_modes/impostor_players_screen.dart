import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/page_transitions.dart';
import '../../models/impostor_player.dart';
import 'impostor_settings_screen.dart';

class ImpostorPlayersScreen extends StatefulWidget {
  const ImpostorPlayersScreen({super.key});

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

  void _addPlayer() {
    if (_players.length >= 20) return;
    HapticFeedback.lightImpact();
    setState(() {
      _players.add(ImpostorPlayer(id: 'p$_nextId', name: 'Player $_nextId'));
      _nextId++;
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
    });
  }

  void _onNext() {
    HapticFeedback.mediumImpact();
    setState(() => _editingIndex = null);
    Navigator.push(
      context,
      slideUpRoute(ImpostorSettingsScreen(players: List.from(_players))),
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
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
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
        actions: [
          TextButton(
            onPressed: _onNext,
            child: Text(
              'Next →',
              style: GoogleFonts.poppins(
                color: AppColors.neonPink,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPink,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _onNext,
                  child: Text(
                    'NEXT — SETTINGS',
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
