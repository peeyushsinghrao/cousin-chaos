import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/leave_game_dialog.dart';
import '../../services/haptic_service.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';

enum _JudgePhase { setup, passDevice, confess, judge, reveal, score }
enum _Verdict { mild, chaotic, criminal }

class JudgeMeScreen extends StatefulWidget {
  const JudgeMeScreen({super.key});

  @override
  State<JudgeMeScreen> createState() => _JudgeMeScreenState();
}

class _JudgeMeScreenState extends State<JudgeMeScreen> {
  _JudgePhase _phase = _JudgePhase.setup;

  final List<String> _players = ['Player 1', 'Player 2', 'Player 3'];
  int _nextId = 4;
  int _currentPlayerIndex = 0;
  int _roundsPlayed = 0;
  int _totalRounds = 3;

  final Map<String, int> _scores = {};
  String _currentConfession = '';
  final TextEditingController _confessionCtrl = TextEditingController();
  final Map<String, _Verdict> _playerVerdicts = {};

  @override
  void dispose() {
    _confessionCtrl.dispose();
    super.dispose();
  }

  bool get _soundEnabled => context.read<PreferencesService>().soundEnabled;
  bool get _hapticsEnabled => context.read<PreferencesService>().hapticsEnabled;

  void _startGame() {
    _scores.clear();
    for (final p in _players) _scores[p] = 0;
    _currentPlayerIndex = 0;
    _roundsPlayed = 0;
    _confessionCtrl.clear();
    _playerVerdicts.clear();
    setState(() => _phase = _JudgePhase.passDevice);
  }

  void _submitConfession() {
    final text = _confessionCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Write a confession first!')));
      return;
    }
    _currentConfession = text;
    _playerVerdicts.clear();
    SoundService.instance.play(SoundEvent.cardReveal, soundEnabled: _soundEnabled);
    setState(() => _phase = _JudgePhase.judge);
  }

  void _vote(String playerName, _Verdict verdict) {
    if (_playerVerdicts.containsKey(playerName)) return;
    HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled);
    setState(() => _playerVerdicts[playerName] = verdict);
  }

  void _lockVerdicts() {
    if (_playerVerdicts.length < _players.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All judges must vote!')));
      return;
    }
    SoundService.instance.play(SoundEvent.win, soundEnabled: _soundEnabled);
    setState(() => _phase = _JudgePhase.reveal);
  }

  int _verdictScore(_Verdict v) {
    switch (v) {
      case _Verdict.mild: return 1;
      case _Verdict.chaotic: return 2;
      case _Verdict.criminal: return 3;
    }
  }

  void _nextRound() {
    SoundService.instance.play(SoundEvent.nextPlayer, soundEnabled: _soundEnabled);
    int totalScore = _playerVerdicts.values.fold(0, (sum, v) => sum + _verdictScore(v));
    _scores[_players[_currentPlayerIndex]] = (_scores[_players[_currentPlayerIndex]] ?? 0) + totalScore;

    _roundsPlayed++;
    final totalTurns = _totalRounds * _players.length;
    if (_roundsPlayed >= totalTurns) {
      setState(() => _phase = _JudgePhase.score);
      return;
    }
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    _confessionCtrl.clear();
    _playerVerdicts.clear();
    setState(() => _phase = _JudgePhase.passDevice);
  }

  Color _verdictColor(_Verdict v) {
    switch (v) {
      case _Verdict.mild: return AppColors.neonGreen;
      case _Verdict.chaotic: return AppColors.neonOrange;
      case _Verdict.criminal: return AppColors.dareRed;
    }
  }

  String _verdictLabel(_Verdict v) {
    switch (v) {
      case _Verdict.mild: return 'Mild';
      case _Verdict.chaotic: return 'Chaotic';
      case _Verdict.criminal: return 'Criminal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase == _JudgePhase.setup,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_phase == _JudgePhase.setup) return;
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
      case _JudgePhase.setup: return _setup();
      case _JudgePhase.passDevice: return _passDevice();
      case _JudgePhase.confess: return _confessView();
      case _JudgePhase.judge: return _judgeView();
      case _JudgePhase.reveal: return _revealView();
      case _JudgePhase.score: return _scoreView();
    }
  }

  Widget _setup() => Column(children: [
    _appBar(),
    Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
      _playerHeader(),
      const SizedBox(height: 10),
      ..._players.asMap().entries.map((e) => _playerRow(e.key)),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: Text('Rounds each', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 15))),
        _iconBtn(Icons.remove_rounded, _totalRounds <= 1 ? null : () => setState(() => _totalRounds--), AppColors.textMuted),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$_totalRounds', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
        _iconBtn(Icons.add_rounded, _totalRounds >= 10 ? null : () => setState(() => _totalRounds++), AppColors.neonGreen),
      ]),
    ])),
    Padding(padding: const EdgeInsets.all(24), child: SizedBox(width: double.infinity, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: _startGame,
      child: Text('START JUDGE ME', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    ))),
  ]);

  Widget _passDevice() => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.lock_rounded, size: 80, color: AppColors.neonPink),
    const SizedBox(height: 32),
    Text('Pass to', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 18)),
    const SizedBox(height: 8),
    Text(_players[_currentPlayerIndex], style: GoogleFonts.poppins(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    Text('Round ${(_roundsPlayed ~/ _players.length) + 1} of $_totalRounds', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14)),
    const Spacer(),
    SizedBox(width: double.infinity, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: () { setState(() => _phase = _JudgePhase.confess); },
      child: Text('READY', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    )),
  ]));

  Widget _confessView() => Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(_players[_currentPlayerIndex], style: GoogleFonts.poppins(color: AppColors.neonPink, fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 4),
    Text('Write your confession — nobody reads it until judging', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
    const SizedBox(height: 20),
    Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.neonPink.withAlpha(80))),
      child: TextField(
        controller: _confessionCtrl,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, height: 1.6),
        maxLines: 6,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: 'I once...',
          hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 15),
        ),
      ),
    ),
    const Spacer(),
    SizedBox(width: double.infinity, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: _submitConfession,
      child: Text('SUBMIT', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    )),
  ]));

  Widget _judgeView() {
    final confessor = _players[_currentPlayerIndex];
    final judges = _players.where((p) => p != confessor).toList();
    return Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      Text('JUDGE THE CONFESSION', style: GoogleFonts.poppins(color: AppColors.neonPink, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.neonPink.withAlpha(80))),
        child: Text(_currentConfession, style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, height: 1.6, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
      ),
      const SizedBox(height: 20),
      Text('Each judge rates it:', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(height: 12),
      Expanded(child: ListView(children: judges.map((judge) {
        final voted = _playerVerdicts[judge];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBright)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(judge, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(children: _Verdict.values.map((v) => Expanded(child: GestureDetector(
              onTap: () => _vote(judge, v),
              child: Container(
                margin: EdgeInsets.only(right: v != _Verdict.criminal ? 6.0 : 0.0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: voted == v ? _verdictColor(v).withAlpha(40) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: voted == v ? _verdictColor(v) : AppColors.surfaceBright, width: voted == v ? 2 : 1),
                ),
                alignment: Alignment.center,
                child: Text(_verdictLabel(v), style: GoogleFonts.poppins(color: voted == v ? _verdictColor(v) : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ))).toList()),
          ]),
        );
      }).toList())),
      SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: _lockVerdicts,
        child: Text('LOCK IN VERDICTS', style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
      )),
    ]));
  }

  Widget _revealView() {
    final verdictCounts = {_Verdict.mild: 0, _Verdict.chaotic: 0, _Verdict.criminal: 0};
    for (final v in _playerVerdicts.values) { verdictCounts[v] = verdictCounts[v]! + 1; }
    final dominant = verdictCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('THE VERDICT IS IN', style: GoogleFonts.poppins(color: _verdictColor(dominant), fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _verdictColor(dominant).withAlpha(80))),
        child: Column(children: [
          Text(_currentConfession, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14, height: 1.5, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: _verdictColor(dominant).withAlpha(30), borderRadius: BorderRadius.circular(50)),
            child: Text(_verdictLabel(dominant).toUpperCase(), style: GoogleFonts.poppins(color: _verdictColor(dominant), fontSize: 22, fontWeight: FontWeight.w900)),
          ),
        ]),
      ),
      const SizedBox(height: 24),
      ...verdictCounts.entries.where((e) => e.value > 0).map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Container(width: 12, height: 12, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: _verdictColor(e.key), shape: BoxShape.circle)),
          Text(_verdictLabel(e.key), style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('${e.value} vote${e.value != 1 ? 's' : ''}', style: GoogleFonts.poppins(color: _verdictColor(e.key), fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      )),
      const SizedBox(height: 40),
      SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _nextRound,
        child: Text('NEXT', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      )),
    ]));
  }

  Widget _scoreView() {
    final sorted = _players.toList()..sort((a, b) => (_scores[b] ?? 0).compareTo(_scores[a] ?? 0));
    return Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 24),
      Text('MOST JUDGED', style: GoogleFonts.poppins(color: AppColors.neonPink, fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text('High score = most dramatic confessions', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(height: 32),
      Expanded(child: ListView.builder(itemCount: sorted.length, itemBuilder: (_, i) {
        final p = sorted[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: i == 0 ? AppColors.neonPink.withAlpha(25) : AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: i == 0 ? AppColors.neonPink : AppColors.surfaceBright)),
          child: Row(children: [
            Text('${i + 1}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(width: 16),
            Expanded(child: Text(p, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            Text('${_scores[p]} pts', style: GoogleFonts.poppins(color: AppColors.neonPink, fontSize: 16, fontWeight: FontWeight.w800)),
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
    Text('JUDGE ME', style: GoogleFonts.poppins(color: AppColors.neonPink, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
  ]));

  Widget _playerHeader() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text('${_players.length} players', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    Row(children: [
      _iconBtn(Icons.remove_rounded, _players.length <= 2 ? null : () { HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled); setState(() => _players.removeLast()); }, AppColors.dareRed),
      const SizedBox(width: 10),
      _iconBtn(Icons.add_rounded, _players.length >= 12 ? null : () { HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled); setState(() { _players.add('Player $_nextId'); _nextId++; }); }, AppColors.neonGreen),
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
