import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../services/supabase_service.dart';

class LobbyScreen extends StatefulWidget {
  final String roomId;
  final String roomCode;
  final String playerName;
  final bool isHost;

  const LobbyScreen({
    super.key,
    required this.roomId,
    required this.roomCode,
    required this.playerName,
    required this.isHost,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  List<Map<String, dynamic>> _players = [];
  RealtimeChannel? _channel;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _subscribe();
  }

  Future<void> _loadPlayers() async {
    final players = await SupabaseService.instance.getRoomPlayers(widget.roomId);
    if (mounted) setState(() => _players = players);
  }

  void _subscribe() {
    _channel = SupabaseService.instance.subscribeToRoom(
      widget.roomId,
      onPlayersChanged: (_) => _loadPlayers(),
      onRoomChanged: (room) {
        if (room['status'] == 'playing' && !_gameStarted) {
          setState(() => _gameStarted = true);
          _showGameStarted();
        }
      },
    );
  }

  void _showGameStarted() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Game started!', style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _startGame() async {
    await SupabaseService.instance.startGame(widget.roomId);
  }

  Future<void> _leave() async {
    if (widget.isHost) {
      await SupabaseService.instance.closeRoom(widget.roomId);
    } else {
      await SupabaseService.instance.leaveRoom(widget.roomId, widget.playerName);
    }
    _channel?.unsubscribe();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF08041A), Color(0xFF0E0624), Color(0xFF08041A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
                      onPressed: _leave,
                    ),
                    Text('Game Lobby', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    const Spacer(),
                    if (widget.isHost)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gold.withAlpha(60)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, color: AppColors.gold, size: 13),
                            const SizedBox(width: 4),
                            Text('HOST', style: GoogleFonts.sora(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildRoomCodeBadge(),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Players (${_players.length})', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const Spacer(),
                    Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('Live', style: GoogleFonts.sora(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _players.length,
                  itemBuilder: (_, i) => _buildPlayerTile(_players[i], i),
                ),
              ),
              if (widget.isHost) ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: _players.length >= 2 ? _startGame : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _players.length >= 2 ? 1.0 : 0.4,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(60), blurRadius: 20, offset: const Offset(0, 6))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              _players.length >= 2 ? 'Start Game' : 'Need 2+ players',
                              style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Text('Waiting for host to start...', style: GoogleFonts.sora(color: Colors.white60, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCodeBadge() {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.roomCode));
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code copied!', style: GoogleFonts.sora()),
            backgroundColor: AppColors.neonGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha(60), width: 2),
          boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(30), blurRadius: 30, spreadRadius: 5)],
        ),
        child: Column(
          children: [
            Text('ROOM CODE', style: GoogleFonts.sora(color: AppColors.primary.withAlpha(180), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3)),
            const SizedBox(height: 8),
            Text(
              widget.roomCode,
              style: GoogleFonts.sora(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 10),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.copy, color: Colors.white38, size: 12),
                const SizedBox(width: 4),
                Text('tap to copy', style: GoogleFonts.sora(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Map<String, dynamic> player, int index) {
    final isHost = player['is_host'] == true;
    final name = player['player_name'] ?? 'Player';
    final colors = [AppColors.primary, AppColors.secondary, AppColors.tertiary, AppColors.neonGreen, AppColors.neonOrange];
    final color = colors[index % colors.length];

    return Padding(
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
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(25), border: Border.all(color: color.withAlpha(80))),
              child: Center(
                child: Text(name[0].toUpperCase(), style: GoogleFonts.sora(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
            if (isHost)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold.withAlpha(50)),
                ),
                child: Text('Host', style: GoogleFonts.sora(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}
