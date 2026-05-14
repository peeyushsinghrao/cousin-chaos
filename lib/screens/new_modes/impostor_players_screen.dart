import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../models/impostor_player.dart';
import 'impostor_game_screen.dart';

class ImpostorPlayersScreen extends StatefulWidget {
  const ImpostorPlayersScreen({super.key});

  @override
  State<ImpostorPlayersScreen> createState() => _ImpostorPlayersScreenState();
}

class _ImpostorPlayersScreenState extends State<ImpostorPlayersScreen> {
  final _uuid = const Uuid();
  final List<ImpostorPlayer> _players = [];
  bool _timeLimitEnabled = true;
  int _timeLimitSeconds = 300;

  @override
  void initState() {
    super.initState();
    _players.addAll(List.generate(3, (index) => ImpostorPlayer(
      id: _uuid.v4(), name: 'Player ${index + 1}',
    )));
  }

  void _addPlayer() {
    if (_players.length >= 20) return;
    setState(() {
      _players.add(ImpostorPlayer(id: _uuid.v4(), name: 'Player ${_players.length + 1}'));
    });
  }

  void _removePlayer(int index) {
    if (_players.length <= 3) return;
    setState(() {
      _players.removeAt(index);
    });
  }

  void _startGame() {
    if (_players.length < 3) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImpostorSetupScreen(players: _players),
      ),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'IMPOSTOR PLAYERS',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonPink,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customize players', style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
            )),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.surfaceBright),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: player.name,
                            style: GoogleFonts.poppins(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Player ${index + 1}',
                              labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {
                                player.name = value.isEmpty ? 'Player ${index + 1}' : value;
                              });
                            },
                          ),
                        ),
                        if (_players.length > 3)
                          IconButton(
                            onPressed: () => _removePlayer(index),
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _addPlayer,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.neonPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text('ADD PLAYER', style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                        )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text('${_players.length}/20', style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textSecondary,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              value: _timeLimitEnabled,
              activeColor: AppColors.neonPink,
              title: Text('Enable discussion timer', style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w700,
              )),
              subtitle: Text('${_timeLimitSeconds ~/ 60} minutes', style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
              )),
              onChanged: (value) => setState(() => _timeLimitEnabled = value),
            ),
            if (_timeLimitEnabled) ...[
              Slider(
                value: _timeLimitSeconds.toDouble(),
                min: 60,
                max: 600,
                divisions: 9,
                activeColor: AppColors.neonPink,
                label: '${_timeLimitSeconds ~/ 60} min',
                onChanged: (value) => setState(() => _timeLimitSeconds = value.toInt()),
              ),
            ],
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _players.length >= 3 ? _startGame : null,
              child: Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: _players.length >= 3 ? AppColors.neonPink : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'START GAME',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
}
