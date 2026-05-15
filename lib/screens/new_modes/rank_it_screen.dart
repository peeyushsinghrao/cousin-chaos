import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/leave_game_dialog.dart';
import '../../data/rank_it_prompts.dart';
import '../../services/haptic_service.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';

enum _RankPhase { setup, ranking, reveal }

class RankItScreen extends StatefulWidget {
  const RankItScreen({super.key});

  @override
  State<RankItScreen> createState() => _RankItScreenState();
}

class _RankItScreenState extends State<RankItScreen> {
  final Random _rng = Random();
  _RankPhase _phase = _RankPhase.setup;

  final List<String> _players = ['Player 1', 'Player 2', 'Player 3', 'Player 4', 'Player 5'];
  int _nextId = 6;
  int _totalRounds = 5;
  int _roundsPlayed = 0;

  String _promptRaw = '';
  String _promptTitle = '';
  List<String> _rankingItems = [];
  List<String> _lockedRanking = [];

  @override
  void initState() {
    super.initState();
    _players.length; // just to ensure state
  }

  bool get _soundEnabled => context.read<PreferencesService>().soundEnabled;
  bool get _hapticsEnabled => context.read<PreferencesService>().hapticsEnabled;

  void _startGame() {
    _roundsPlayed = 0;
    _pickPrompt();
    setState(() => _phase = _RankPhase.ranking);
  }

  void _pickPrompt() {
    _promptRaw = rankItPrompts[_rng.nextInt(rankItPrompts.length)];
    final parts = _promptRaw.split('|');
    _promptTitle = parts[0].trim();
    if (parts.length > 1) {
      _rankingItems = List.from(_players);
    } else {
      _rankingItems = List.from(_players);
    }
  }

  void _lockRanking() {
    HapticService.instance.trigger(HapticEvent.cardReveal, hapticsEnabled: _hapticsEnabled);
    SoundService.instance.play(SoundEvent.cardReveal, soundEnabled: _soundEnabled);
    _lockedRanking = List.from(_rankingItems);
    setState(() => _phase = _RankPhase.reveal);
  }

  void _nextRound() {
    _roundsPlayed++;
    SoundService.instance.play(SoundEvent.nextPlayer, soundEnabled: _soundEnabled);
    if (_roundsPlayed >= _totalRounds) {
      setState(() => _phase = _RankPhase.setup);
    } else {
      _pickPrompt();
      setState(() => _phase = _RankPhase.ranking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase == _RankPhase.setup,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_phase == _RankPhase.setup) return;
        final leave = await showLeaveGameDialog(context);
        if (leave == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _body() {
    switch (_phase) {
      case _RankPhase.setup: return _setup();
      case _RankPhase.ranking: return _rankingView();
      case _RankPhase.reveal: return _revealView();
    }
  }

  Widget _setup() {
    return Column(children: [
      _appBar(),
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_players.length} players', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          Row(children: [
            _iconBtn(Icons.remove_rounded, _players.length <= 2 ? null : () { HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled); setState(() => _players.removeLast()); }, AppColors.dareRed),
            const SizedBox(width: 10),
            _iconBtn(Icons.add_rounded, _players.length >= 12 ? null : () { HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled); setState(() { _players.add('Player $_nextId'); _nextId++; }); }, AppColors.neonGreen),
          ]),
        ]),
        const SizedBox(height: 10),
        ..._players.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.surfaceBright)),
          child: Row(children: [
            Text('${e.key + 1}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(initialValue: e.value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15), decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true), onChanged: (v) => _players[e.key] = v)),
          ]),
        )),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text('Rounds', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 15))),
          _iconBtn(Icons.remove_rounded, _totalRounds <= 1 ? null : () => setState(() => _totalRounds--), AppColors.textMuted),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$_totalRounds', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
          _iconBtn(Icons.add_rounded, _totalRounds >= 20 ? null : () => setState(() => _totalRounds++), AppColors.neonGreen),
        ]),
      ])),
      Padding(padding: const EdgeInsets.all(24), child: SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonYellow, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _startGame,
        child: Text('START RANKING', style: GoogleFonts.poppins(color: AppColors.background, fontSize: 16, fontWeight: FontWeight.w800)),
      ))),
    ]);
  }

  Widget _rankingView() {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Round ${_roundsPlayed + 1} of $_totalRounds', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.neonYellow.withAlpha(80))),
          child: Text(_promptTitle, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.5)),
        ),
        const SizedBox(height: 12),
        Text('Drag to rank (1 = most to least)', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
      ])),
      Expanded(
        child: ReorderableListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _rankingItems.length,
          onReorder: (oldI, newI) {
            HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled);
            setState(() {
              if (newI > oldI) newI--;
              final item = _rankingItems.removeAt(oldI);
              _rankingItems.insert(newI, item);
            });
          },
          itemBuilder: (_, i) => Container(
            key: ValueKey(_rankingItems[i]),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonYellow.withAlpha(60)),
            ),
            child: Row(children: [
              Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.neonYellow.withAlpha(40), borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Text('${i + 1}', style: GoogleFonts.poppins(color: AppColors.neonYellow, fontWeight: FontWeight.w800, fontSize: 13))),
              const SizedBox(width: 14),
              Expanded(child: Text(_rankingItems[i], style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
              const Icon(Icons.drag_handle_rounded, color: AppColors.textMuted),
            ]),
          ),
        ),
      ),
      Padding(padding: const EdgeInsets.all(24), child: SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonYellow, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _lockRanking,
        child: Text('LOCK IN RANKING', style: GoogleFonts.poppins(color: AppColors.background, fontSize: 16, fontWeight: FontWeight.w800)),
      ))),
    ]);
  }

  Widget _revealView() => Padding(padding: const EdgeInsets.all(24), child: Column(children: [
    const SizedBox(height: 24),
    Text('GROUP RANKING', style: GoogleFonts.poppins(color: AppColors.neonYellow, fontSize: 24, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)), child: Text(_promptTitle, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14, height: 1.5), textAlign: TextAlign.center)),
    const SizedBox(height: 20),
    Expanded(child: ListView.builder(
      itemCount: _lockedRanking.length,
      itemBuilder: (_, i) {
        final colors = [AppColors.neonYellow, AppColors.neonOrange, AppColors.dareRed, AppColors.neonPink, AppColors.primaryNeon];
        final c = colors[i % colors.length];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.withAlpha(60)),
          ),
          child: Row(children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: c.withAlpha(40), borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Text('${i + 1}', style: GoogleFonts.poppins(color: c, fontWeight: FontWeight.w900, fontSize: 14))),
            const SizedBox(width: 14),
            Expanded(child: Text(_lockedRanking[i], style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
          ]),
        );
      },
    )),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.surfaceBright), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: () => Navigator.pop(context), child: Text('Leave', style: GoogleFonts.poppins(color: AppColors.textSecondary)))),
      const SizedBox(width: 12),
      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonYellow, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: _nextRound, child: Text(_roundsPlayed + 1 >= _totalRounds ? 'FINISH' : 'NEXT', style: GoogleFonts.poppins(color: AppColors.background, fontWeight: FontWeight.w800)))),
    ]),
  ]));

  Widget _appBar() => Padding(padding: const EdgeInsets.all(24), child: Row(children: [
    GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBright)), child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18))),
    const SizedBox(width: 16),
    Text('RANK IT', style: GoogleFonts.poppins(color: AppColors.neonYellow, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
  ]));

  Widget _iconBtn(IconData icon, VoidCallback? onTap, Color color) => GestureDetector(
    onTap: onTap,
    child: Container(width: 36, height: 36, decoration: BoxDecoration(color: onTap != null ? color.withAlpha(30) : AppColors.surfaceLight.withAlpha(100), borderRadius: BorderRadius.circular(10), border: Border.all(color: onTap != null ? color.withAlpha(80) : AppColors.surfaceBright)), child: Icon(icon, color: onTap != null ? color : AppColors.textMuted, size: 18)),
  );
}
