import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/leave_game_dialog.dart';
import '../../data/hot_seat_dares.dart';
import '../../services/haptic_service.dart';
import '../../services/player_manager.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';

enum _HotSeatPhase { setup, passDevice, dare, score }

class HotSeatScreen extends StatefulWidget {
  const HotSeatScreen({super.key});

  @override
  State<HotSeatScreen> createState() => _HotSeatScreenState();
}

class _HotSeatScreenState extends State<HotSeatScreen> {
  final Random _rng = Random();
  _HotSeatPhase _phase = _HotSeatPhase.setup;

  final List<String> _players = ['Player 1', 'Player 2', 'Player 3'];
  int _nextId = 4;

  int _currentPlayerIndex = 0;
  int _totalRounds = 3;
  int _roundsPlayed = 0;

  final Map<String, int> _scores = {};
  String _currentDare = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pm = context.read<PlayerManager>();
      if (pm.players.isNotEmpty) {
        setState(() {
          _players.clear();
          _players.addAll(pm.players.map((p) => p.name));
          _nextId = _players.length + 1;
        });
      }
    });
  }

  bool get _soundEnabled => context.read<PreferencesService>().soundEnabled;
  bool get _hapticsEnabled => context.read<PreferencesService>().hapticsEnabled;

  void _addPlayer() {
    if (_players.length >= 12) return;
    HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled);
    setState(() => _players.add('Player $_nextId'));
    _nextId++;
  }

  void _removePlayer() {
    if (_players.length <= 2) return;
    HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled);
    setState(() => _players.removeLast());
  }

  void _startGame() {
    HapticService.instance.trigger(HapticEvent.cardReveal, hapticsEnabled: _hapticsEnabled);
    SoundService.instance.play(SoundEvent.tap, soundEnabled: _soundEnabled);
    _scores.clear();
    for (final p in _players) {
      _scores[p] = 0;
    }
    _currentPlayerIndex = 0;
    _roundsPlayed = 0;
    setState(() => _phase = _HotSeatPhase.passDevice);
    _drawDare();
  }

  void _drawDare() {
    _currentDare = hotSeatDares[_rng.nextInt(hotSeatDares.length)];
  }

  void _onPassDevice() {
    HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled);
    SoundService.instance.play(SoundEvent.nextPlayer, soundEnabled: _soundEnabled);
    setState(() => _phase = _HotSeatPhase.dare);
  }

  void _onComplete(bool success) {
    HapticService.instance.trigger(HapticEvent.cardReveal, hapticsEnabled: _hapticsEnabled);
    SoundService.instance.play(success ? SoundEvent.win : SoundEvent.wrong, soundEnabled: _soundEnabled);
    if (success) {
      _scores[_players[_currentPlayerIndex]] = (_scores[_players[_currentPlayerIndex]] ?? 0) + 1;
    }
    _roundsPlayed++;
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;

    final totalRounds = _totalRounds * _players.length;
    if (_roundsPlayed >= totalRounds) {
      setState(() => _phase = _HotSeatPhase.score);
    } else {
      _drawDare();
      setState(() => _phase = _HotSeatPhase.passDevice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase == _HotSeatPhase.setup,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_phase == _HotSeatPhase.setup) return;
        final leave = await showLeaveGameDialog(context);
        if (leave == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: _buildPhase()),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _HotSeatPhase.setup: return _buildSetup();
      case _HotSeatPhase.passDevice: return _buildPass();
      case _HotSeatPhase.dare: return _buildDare();
      case _HotSeatPhase.score: return _buildScore();
    }
  }

  Widget _buildSetup() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBright)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 16),
              Text('HOT SEAT', style: GoogleFonts.poppins(color: AppColors.neonOrange, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_players.length} players', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              Row(
                children: [
                  _btn(Icons.remove_rounded, _players.length <= 2 ? null : _removePlayer, AppColors.dareRed),
                  const SizedBox(width: 10),
                  _btn(Icons.add_rounded, _players.length >= 12 ? null : _addPlayer, AppColors.neonGreen),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _players.length,
            itemBuilder: (_, i) => _buildPlayerRow(i),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Rounds each', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 15))),
                  Row(
                    children: [
                      _btn(Icons.remove_rounded, _totalRounds <= 1 ? null : () => setState(() => _totalRounds--), AppColors.textMuted),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_totalRounds', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      ),
                      _btn(Icons.add_rounded, _totalRounds >= 10 ? null : () => setState(() => _totalRounds++), AppColors.neonGreen),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonOrange,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _startGame,
                  child: Text('START HOT SEAT', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPlayerRow(int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBright),
      ),
      child: Row(
        children: [
          Text('${i + 1}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: _players[i],
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
              onChanged: (v) => _players[i] = v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPass() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department_rounded, size: 80, color: AppColors.neonOrange),
          const SizedBox(height: 32),
          Text('Pass to', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 18)),
          const SizedBox(height: 8),
          Text(_players[_currentPlayerIndex], style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Text(
            'Round ${(_roundsPlayed ~/ _players.length) + 1} of $_totalRounds',
            style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonOrange,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _onPassDevice,
              child: Text('PASS DEVICE', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDare() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _players[_currentPlayerIndex].toUpperCase(),
            style: GoogleFonts.poppins(color: AppColors.neonOrange, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.neonOrange.withAlpha(100), width: 2),
              boxShadow: [BoxShadow(color: AppColors.neonOrange.withAlpha(40), blurRadius: 30)],
            ),
            child: Text(
              _currentDare,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, height: 1.6, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dareRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _onComplete(false),
                  child: Text('SKIP', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _onComplete(true),
                  child: Text('DONE +1', style: GoogleFonts.poppins(color: AppColors.background, fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScore() {
    final sorted = _players.toList()..sort((a, b) => (_scores[b] ?? 0).compareTo(_scores[a] ?? 0));
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text('RESULTS', style: GoogleFonts.poppins(color: AppColors.neonOrange, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text('Game over!', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: sorted.length,
              itemBuilder: (_, i) {
                final p = sorted[i];
                final pts = _scores[p] ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: i == 0 ? AppColors.neonOrange.withAlpha(30) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: i == 0 ? AppColors.neonOrange.withAlpha(100) : AppColors.surfaceBright),
                  ),
                  child: Row(
                    children: [
                      Text('${i + 1}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 16),
                      Expanded(child: Text(p, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
                      Text('$pts pts', style: GoogleFonts.poppins(color: AppColors.neonOrange, fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.surfaceBright),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Leave', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _startGame,
                  child: Text('PLAY AGAIN', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: onTap != null ? color.withAlpha(30) : AppColors.surfaceLight.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: onTap != null ? color.withAlpha(80) : AppColors.surfaceBright),
        ),
        child: Icon(icon, color: onTap != null ? color : AppColors.textMuted, size: 20),
      ),
    );
  }
}
