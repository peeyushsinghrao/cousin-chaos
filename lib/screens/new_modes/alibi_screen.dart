import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/alibi_questions.dart';

enum _AlibiPhase { setup, crime, prepTimer, giveAlibi, vote, verdict }

class AlibiScreen extends StatefulWidget {
  const AlibiScreen({super.key});

  @override
  State<AlibiScreen> createState() => _AlibiScreenState();
}

class _AlibiScreenState extends State<AlibiScreen> {
  final Random _rng = Random();
  _AlibiPhase _phase = _AlibiPhase.setup;

  final List<String> _players = ['Player 1', 'Player 2', 'Player 3'];
  int _nextId = 4;
  int _currentPlayerIndex = 0;
  int _roundsPerPlayer = 1;
  int _roundsPlayed = 0;

  String _currentCategory = '';
  String _currentQuestion = '';

  int _prepSecondsLeft = 30;
  Timer? _prepTimer;

  String? _votedPlayerId;
  final Map<String, int> _scores = {};

  @override
  void initState() {
    super.initState();
    _currentCategory = alibiQuestionsByCategory.keys.first;
  }

  @override
  void dispose() {
    _prepTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _scores.clear();
    for (final p in _players) _scores[p] = 0;
    _currentPlayerIndex = 0;
    _roundsPlayed = 0;
    _pickQuestion();
    setState(() => _phase = _AlibiPhase.crime);
  }

  void _pickQuestion() {
    final questions = alibiQuestionsByCategory[_currentCategory]!;
    _currentQuestion = questions[_rng.nextInt(questions.length)];
  }

  void _startPrep() {
    _prepSecondsLeft = 30;
    setState(() => _phase = _AlibiPhase.prepTimer);
    _prepTimer?.cancel();
    _prepTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _prepSecondsLeft--;
        if (_prepSecondsLeft <= 5 && _prepSecondsLeft > 0) HapticFeedback.lightImpact();
        if (_prepSecondsLeft <= 0) {
          t.cancel();
          HapticFeedback.heavyImpact();
          _phase = _AlibiPhase.giveAlibi;
        }
      });
    });
  }

  void _skipToAlibi() {
    _prepTimer?.cancel();
    setState(() => _phase = _AlibiPhase.giveAlibi);
  }

  void _nextPlayer() {
    _roundsPlayed++;
    final totalTurns = _roundsPerPlayer * _players.length;
    if (_roundsPlayed >= totalTurns) {
      setState(() => _phase = _AlibiPhase.vote);
    } else {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      if (_currentPlayerIndex == 0) _pickQuestion();
      setState(() => _phase = _AlibiPhase.crime);
    }
  }

  void _vote(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Vote for ${_players[index]}?', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('You think their alibi is weakest.', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Vote', style: GoogleFonts.poppins(color: AppColors.dareRed, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _votedPlayerId = _players[index];
      final survivors = _players.where((p) => p != _votedPlayerId).toList();
      for (final p in survivors) { _scores[p] = (_scores[p] ?? 0) + 1; }
      setState(() => _phase = _AlibiPhase.verdict);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(child: _body()),
  );

  Widget _body() {
    switch (_phase) {
      case _AlibiPhase.setup: return _setup();
      case _AlibiPhase.crime: return _crimeView();
      case _AlibiPhase.prepTimer: return _prepView();
      case _AlibiPhase.giveAlibi: return _alibiView();
      case _AlibiPhase.vote: return _voteView();
      case _AlibiPhase.verdict: return _verdictView();
    }
  }

  Widget _setup() {
    final cats = alibiQuestionsByCategory.keys.toList();
    return Column(children: [
      _appBar(),
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
        _playerHeader(),
        const SizedBox(height: 10),
        ..._players.asMap().entries.map((e) => _playerRow(e.key)),
        const SizedBox(height: 16),
        Text('Crime Category', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...cats.map((c) => GestureDetector(
          onTap: () => setState(() => _currentCategory = c),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _currentCategory == c ? AppColors.neonPink.withAlpha(25) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _currentCategory == c ? AppColors.neonPink : AppColors.surfaceBright),
            ),
            child: Row(children: [
              Expanded(child: Text(c, style: GoogleFonts.poppins(color: _currentCategory == c ? AppColors.neonPink : Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
              if (_currentCategory == c) const Icon(Icons.check_rounded, color: AppColors.neonPink, size: 18),
            ]),
          ),
        )),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text('Rounds each', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 15))),
          _iconBtn(Icons.remove_rounded, _roundsPerPlayer <= 1 ? null : () => setState(() => _roundsPerPlayer--), AppColors.textMuted),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$_roundsPerPlayer', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
          _iconBtn(Icons.add_rounded, _roundsPerPlayer >= 5 ? null : () => setState(() => _roundsPerPlayer++), AppColors.neonGreen),
        ]),
      ])),
      Padding(padding: const EdgeInsets.all(24), child: SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _startGame,
        child: Text('START ALIBI', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      ))),
    ]);
  }

  Widget _crimeView() {
    final player = _players[_currentPlayerIndex];
    return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('$_currentCategory', style: GoogleFonts.poppins(color: AppColors.neonPink, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1)),
      const SizedBox(height: 24),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.neonPink.withAlpha(80), width: 2)),
        child: Text(_currentQuestion, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.6), textAlign: TextAlign.center),
      ),
      const SizedBox(height: 32),
      Text('Pass to:', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16)),
      const SizedBox(height: 8),
      Text(player, style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
      const Spacer(),
      SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _startPrep,
        child: Text('START 30s PREP', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      )),
    ]));
  }

  Widget _prepView() {
    final timerColor = _prepSecondsLeft <= 5 ? AppColors.dareRed : (_prepSecondsLeft <= 10 ? AppColors.neonOrange : Colors.white);
    return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('PREPARE YOUR ALIBI', style: GoogleFonts.poppins(color: AppColors.neonPink, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(height: 8),
      Text(_players[_currentPlayerIndex], style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16)),
      const SizedBox(height: 48),
      Text('$_prepSecondsLeft', style: GoogleFonts.poppins(color: timerColor, fontSize: 96, fontWeight: FontWeight.w900)),
      Text('seconds', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14)),
      const SizedBox(height: 64),
      SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceLight, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: _skipToAlibi,
        child: Text('SKIP TIMER', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 15)),
      )),
    ]));
  }

  Widget _alibiView() => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.mic_rounded, size: 80, color: AppColors.neonPink),
    const SizedBox(height: 24),
    Text(_players[_currentPlayerIndex], style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    Text('Give your alibi now!', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16)),
    const SizedBox(height: 12),
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Text(_currentQuestion, style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
    ),
    const Spacer(),
    SizedBox(width: double.infinity, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: _nextPlayer,
      child: Text('DONE — NEXT', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    )),
  ]));

  Widget _voteView() => Column(children: [
    Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('WHO HAD THE WORST ALIBI?', style: GoogleFonts.poppins(color: AppColors.dareRed, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      Text('All vote together', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
    ])),
    Expanded(child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _players.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => _vote(i),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.dareRed.withAlpha(60))),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.dareRed.withAlpha(40), borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text('${i + 1}', style: GoogleFonts.poppins(color: AppColors.dareRed, fontWeight: FontWeight.w800))),
            const SizedBox(width: 16),
            Expanded(child: Text(_players[i], style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            const Icon(Icons.gavel_rounded, color: AppColors.dareRed, size: 20),
          ]),
        ),
      ),
    )),
  ]);

  Widget _verdictView() {
    final sorted = _players.toList()..sort((a, b) => (_scores[b] ?? 0).compareTo(_scores[a] ?? 0));
    return Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 24),
      const Icon(Icons.gavel_rounded, size: 80, color: AppColors.dareRed),
      const SizedBox(height: 16),
      Text('$_votedPlayerId had the worst alibi!', style: GoogleFonts.poppins(color: AppColors.dareRed, fontSize: 20, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
      const SizedBox(height: 32),
      Text('Scores', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
      const SizedBox(height: 12),
      Expanded(child: ListView.builder(itemCount: sorted.length, itemBuilder: (_, i) {
        final p = sorted[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.surfaceBright)),
          child: Row(children: [
            Expanded(child: Text(p, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
            Text('${_scores[p] ?? 0} pts', style: GoogleFonts.poppins(color: AppColors.neonGreen, fontSize: 15, fontWeight: FontWeight.w800)),
          ]),
        );
      })),
      Row(children: [
        Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.surfaceBright), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: () => Navigator.pop(context), child: Text('Leave', style: GoogleFonts.poppins(color: AppColors.textSecondary)))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: _startGame, child: Text('PLAY AGAIN', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800)))),
      ]),
    ]));
  }

  Widget _appBar() => Padding(padding: const EdgeInsets.all(24), child: Row(children: [
    GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBright)), child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18))),
    const SizedBox(width: 16),
    Text('ALIBI', style: GoogleFonts.poppins(color: AppColors.neonPink, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
  ]));

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

  Widget _iconBtn(IconData icon, VoidCallback? onTap, Color color) => GestureDetector(
    onTap: onTap,
    child: Container(width: 36, height: 36, decoration: BoxDecoration(color: onTap != null ? color.withAlpha(30) : AppColors.surfaceLight.withAlpha(100), borderRadius: BorderRadius.circular(10), border: Border.all(color: onTap != null ? color.withAlpha(80) : AppColors.surfaceBright)), child: Icon(icon, color: onTap != null ? color : AppColors.textMuted, size: 18)),
  );
}
