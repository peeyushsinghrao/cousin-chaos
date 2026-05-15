import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/most_likely_prompts.dart';

enum _MLPhase { setup, countdown, voting, tally, score }

class MostLikelyScreen extends StatefulWidget {
  const MostLikelyScreen({super.key});

  @override
  State<MostLikelyScreen> createState() => _MostLikelyScreenState();
}

class _MostLikelyScreenState extends State<MostLikelyScreen> with SingleTickerProviderStateMixin {
  final Random _rng = Random();
  _MLPhase _phase = _MLPhase.setup;

  final List<String> _players = ['Player 1', 'Player 2', 'Player 3'];
  int _nextId = 4;
  String _currentCategory = '';
  String _currentPrompt = '';
  int _countdownValue = 3;
  Timer? _countdownTimer;
  int _totalRounds = 5;
  int _roundsPlayed = 0;
  final Map<String, int> _scores = {};
  final Map<String, int> _tally = {};
  String? _myPick;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _currentCategory = mostLikelyPrompts.keys.first;
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    _scores.clear();
    for (final p in _players) _scores[p] = 0;
    _roundsPlayed = 0;
    _pickPrompt();
    setState(() => _phase = _MLPhase.countdown);
    _runCountdown();
  }

  void _pickPrompt() {
    final list = mostLikelyPrompts[_currentCategory]!;
    _currentPrompt = list[_rng.nextInt(list.length)];
    _tally.clear();
    _myPick = null;
  }

  void _runCountdown() {
    _countdownValue = 3;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { _countdownValue--; HapticFeedback.lightImpact(); });
      if (_countdownValue <= 0) {
        t.cancel();
        setState(() => _phase = _MLPhase.voting);
      }
    });
  }

  void _pick(String player) {
    if (_myPick != null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _myPick = player;
      _tally[player] = (_tally[player] ?? 0) + 1;
    });
  }

  void _lockIn() {
    if (_myPick == null) return;
    final sorted = _tally.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isNotEmpty) {
      _scores[sorted.first.key] = (_scores[sorted.first.key] ?? 0) + 1;
    }
    setState(() => _phase = _MLPhase.tally);
  }

  void _nextRound() {
    _roundsPlayed++;
    if (_roundsPlayed >= _totalRounds) { setState(() => _phase = _MLPhase.score); return; }
    _pickPrompt();
    setState(() => _phase = _MLPhase.countdown);
    _runCountdown();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(child: _body()),
  );

  Widget _body() {
    switch (_phase) {
      case _MLPhase.setup: return _setup();
      case _MLPhase.countdown: return _countdown();
      case _MLPhase.voting: return _voting();
      case _MLPhase.tally: return _tallyView();
      case _MLPhase.score: return _scoreView();
    }
  }

  Widget _setup() {
    final cats = mostLikelyPrompts.keys.toList();
    return Column(children: [
      _appBar('MOST LIKELY', AppColors.neonGreen),
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
        _playerHeader(),
        const SizedBox(height: 10),
        ..._players.asMap().entries.map((e) => _playerRow(e.key)),
        const SizedBox(height: 16),
        Text('Category', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: cats.map((c) => GestureDetector(
          onTap: () => setState(() => _currentCategory = c),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _currentCategory == c ? AppColors.neonGreen.withAlpha(30) : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _currentCategory == c ? AppColors.neonGreen : AppColors.surfaceBright),
            ),
            child: Text(c, style: GoogleFonts.poppins(color: _currentCategory == c ? AppColors.neonGreen : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        )).toList())),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text('Rounds', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 15))),
          _iconBtn(Icons.remove_rounded, _totalRounds <= 1 ? null : () => setState(() => _totalRounds--), AppColors.textMuted),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$_totalRounds', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
          _iconBtn(Icons.add_rounded, _totalRounds >= 20 ? null : () => setState(() => _totalRounds++), AppColors.neonGreen),
        ]),
      ])),
      _bottomBtn('START', AppColors.neonGreen, _startGame, textColor: AppColors.background),
    ]);
  }

  Widget _countdown() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('GET READY TO POINT!', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16)),
    const SizedBox(height: 24),
    ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)),
      child: Text('$_countdownValue', style: GoogleFonts.poppins(color: AppColors.neonGreen, fontSize: 120, fontWeight: FontWeight.w900)),
    ),
  ]));

  Widget _voting() => Padding(padding: const EdgeInsets.all(24), child: Column(children: [
    Text('Round ${_roundsPlayed + 1} of $_totalRounds', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.neonGreen.withAlpha(80))),
      child: Text(_currentPrompt, style: GoogleFonts.poppins(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, height: 1.5), textAlign: TextAlign.center),
    ),
    const SizedBox(height: 16),
    Text('Point then tap their name', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
    const SizedBox(height: 12),
    Expanded(child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.5),
      itemCount: _players.length,
      itemBuilder: (_, i) {
        final p = _players[i];
        final sel = _myPick == p;
        return GestureDetector(
          onTap: () => _pick(p),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? AppColors.neonGreen.withAlpha(30) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sel ? AppColors.neonGreen : AppColors.surfaceBright, width: sel ? 2 : 1),
            ),
            child: Text(p, style: GoogleFonts.poppins(color: sel ? AppColors.neonGreen : Colors.white, fontSize: 13, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          ),
        );
      },
    )),
    const SizedBox(height: 12),
    _bottomBtn('LOCK IN', _myPick != null ? AppColors.neonGreen : AppColors.surface, _myPick != null ? _lockIn : null, textColor: _myPick != null ? AppColors.background : AppColors.textMuted),
  ]));

  Widget _tallyView() {
    final sorted = _tally.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('MOST VOTED!', style: GoogleFonts.poppins(color: AppColors.neonGreen, fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 32),
      ...sorted.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.neonGreen.withAlpha(80))),
        child: Row(children: [
          Expanded(child: Text(e.key, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
          Text('${e.value} vote${e.value != 1 ? 's' : ''}', style: GoogleFonts.poppins(color: AppColors.neonGreen, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
      )),
      const SizedBox(height: 40),
      _bottomBtn('NEXT ROUND', AppColors.neonGreen, _nextRound, textColor: AppColors.background),
    ]));
  }

  Widget _scoreView() {
    final sorted = _players.toList()..sort((a, b) => (_scores[b] ?? 0).compareTo(_scores[a] ?? 0));
    return Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 24),
      Text('FINAL SCORES', style: GoogleFonts.poppins(color: AppColors.neonGreen, fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 32),
      Expanded(child: ListView.builder(itemCount: sorted.length, itemBuilder: (_, i) {
        final p = sorted[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: i == 0 ? AppColors.neonGreen.withAlpha(25) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: i == 0 ? AppColors.neonGreen : AppColors.surfaceBright),
          ),
          child: Row(children: [
            Text('${i + 1}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(width: 16),
            Expanded(child: Text(p, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            Text('${_scores[p]} pts', style: GoogleFonts.poppins(color: AppColors.neonGreen, fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        );
      })),
      Row(children: [
        Expanded(child: OutlinedButton(
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.surfaceBright), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          onPressed: () => Navigator.pop(context),
          child: Text('Leave', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        )),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          onPressed: _startGame,
          child: Text('AGAIN', style: GoogleFonts.poppins(color: AppColors.background, fontWeight: FontWeight.w800)),
        )),
      ]),
    ]));
  }

  Widget _appBar(String title, Color color) => Padding(
    padding: const EdgeInsets.all(24),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBright)), child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
      ),
      const SizedBox(width: 16),
      Text(title, style: GoogleFonts.poppins(color: color, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
    ]),
  );

  Widget _playerHeader() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text('${_players.length} players', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    Row(children: [
      _iconBtn(Icons.remove_rounded, _players.length <= 2 ? null : () { HapticFeedback.lightImpact(); setState(() => _players.removeLast()); }, AppColors.dareRed),
      const SizedBox(width: 10),
      _iconBtn(Icons.add_rounded, _players.length >= 12 ? null : () { HapticFeedback.lightImpact(); setState(() { _players.add('Player $_nextId'); _nextId++; }); }, AppColors.neonGreen),
    ]),
  ]);

  Widget _playerRow(int i) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.surfaceBright)),
    child: Row(children: [
      Text('${i + 1}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(width: 12),
      Expanded(child: TextFormField(initialValue: _players[i], style: GoogleFonts.poppins(color: Colors.white, fontSize: 15), decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true), onChanged: (v) => _players[i] = v)),
    ]),
  );

  Widget _bottomBtn(String label, Color bg, VoidCallback? onTap, {Color textColor = Colors.white}) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: SizedBox(width: double.infinity, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: bg, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: onTap,
      child: Text(label, style: GoogleFonts.poppins(color: textColor, fontSize: 16, fontWeight: FontWeight.w800)),
    )),
  );

  Widget _iconBtn(IconData icon, VoidCallback? onTap, Color color) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: onTap != null ? color.withAlpha(30) : AppColors.surfaceLight.withAlpha(100), borderRadius: BorderRadius.circular(10), border: Border.all(color: onTap != null ? color.withAlpha(80) : AppColors.surfaceBright)),
      child: Icon(icon, color: onTap != null ? color : AppColors.textMuted, size: 18),
    ),
  );
}
