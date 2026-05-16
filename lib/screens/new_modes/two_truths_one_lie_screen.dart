import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/leave_game_dialog.dart';
import '../../services/haptic_service.dart';
import '../../services/player_manager.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';

enum _TTLPhase { setup, passDevice, enter, vote, reveal, score }

class TwoTruthsOneLieScreen extends StatefulWidget {
  const TwoTruthsOneLieScreen({super.key});

  @override
  State<TwoTruthsOneLieScreen> createState() => _TwoTruthsOneLieScreenState();
}

class _TwoTruthsOneLieScreenState extends State<TwoTruthsOneLieScreen> {
  _TTLPhase _phase = _TTLPhase.setup;

  final List<String> _players = ['Player 1', 'Player 2', 'Player 3'];
  int _nextId = 4;
  int _currentPlayerIndex = 0;
  int _roundsPlayed = 0;
  int _totalRounds = 3;

  final Map<String, int> _scores = {};
  final List<TextEditingController> _stmtCtrls = [TextEditingController(), TextEditingController(), TextEditingController()];
  int _lieIndex = 0;

  List<String> _submittedStatements = [];
  int _submittedLieIndex = 0;
  int? _guessedIndex;

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

  @override
  void dispose() {
    for (final c in _stmtCtrls) c.dispose();
    super.dispose();
  }

  bool get _soundEnabled => context.read<PreferencesService>().soundEnabled;
  bool get _hapticsEnabled => context.read<PreferencesService>().hapticsEnabled;

  void _startGame() {
    _scores.clear();
    for (final p in _players) _scores[p] = 0;
    _currentPlayerIndex = 0;
    _roundsPlayed = 0;
    _clearStatements();
    setState(() => _phase = _TTLPhase.passDevice);
  }

  void _clearStatements() {
    for (final c in _stmtCtrls) c.clear();
    _lieIndex = 0;
    _guessedIndex = null;
  }

  void _submitStatements() {
    final stmts = _stmtCtrls.map((c) => c.text.trim()).toList();
    if (stmts.any((s) => s.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill in all 3 statements!')));
      return;
    }
    final lieText = stmts[_lieIndex];
    _submittedStatements = List<String>.from(stmts)..shuffle();
    _submittedLieIndex = _submittedStatements.indexOf(lieText);
    if (_submittedLieIndex == -1) _submittedLieIndex = 0;
    SoundService.instance.play(SoundEvent.tap, soundEnabled: _soundEnabled);
    setState(() => _phase = _TTLPhase.vote);
  }

  void _guess(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Is this the lie?', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('"${_submittedStatements[index]}"', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('This is the lie!', style: GoogleFonts.poppins(color: AppColors.truthBlue, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      SoundService.instance.play(
        index == _submittedLieIndex ? SoundEvent.win : SoundEvent.wrong,
        soundEnabled: _soundEnabled,
      );
      setState(() {
        _guessedIndex = index;
        _phase = _TTLPhase.reveal;
      });
    }
  }

  bool get _guessedCorrectly => _guessedIndex == _submittedLieIndex;

  void _nextRound() {
    SoundService.instance.play(SoundEvent.nextPlayer, soundEnabled: _soundEnabled);
    final currentPlayer = _players[_currentPlayerIndex];
    if (!_guessedCorrectly) {
      _scores[currentPlayer] = (_scores[currentPlayer] ?? 0) + 1;
    } else {
      final voters = _players.where((p) => p != currentPlayer).toList();
      for (final v in voters) { _scores[v] = (_scores[v] ?? 0) + 1; }
    }

    _roundsPlayed++;
    final totalTurns = _totalRounds * _players.length;
    if (_roundsPlayed >= totalTurns) {
      setState(() => _phase = _TTLPhase.score);
      return;
    }
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    _clearStatements();
    setState(() => _phase = _TTLPhase.passDevice);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase == _TTLPhase.setup,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_phase == _TTLPhase.setup) return;
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
      case _TTLPhase.setup: return _setup();
      case _TTLPhase.passDevice: return _passDevice();
      case _TTLPhase.enter: return _enterStatements();
      case _TTLPhase.vote: return _voteView();
      case _TTLPhase.reveal: return _revealView();
      case _TTLPhase.score: return _scoreView();
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
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.truthBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: _startGame,
      child: Text('START', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    ))),
  ]);

  Widget _passDevice() => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.lock_rounded, size: 80, color: AppColors.truthBlue),
    const SizedBox(height: 32),
    Text('Pass to', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 18)),
    const SizedBox(height: 8),
    Text(_players[_currentPlayerIndex], style: GoogleFonts.poppins(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    Text('Round ${(_roundsPlayed ~/ _players.length) + 1} of $_totalRounds', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14)),
    const Spacer(),
    SizedBox(width: double.infinity, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.truthBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: () => setState(() => _phase = _TTLPhase.enter),
      child: Text('READY', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    )),
  ]));

  Widget _enterStatements() => Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(_players[_currentPlayerIndex], style: GoogleFonts.poppins(color: AppColors.truthBlue, fontSize: 20, fontWeight: FontWeight.w900)),
    const SizedBox(height: 4),
    Text('Enter 2 truths and 1 lie — then mark the lie below', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
    const SizedBox(height: 20),
    ...List.generate(3, (i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('Statement ${i + 1}', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600))),
        GestureDetector(
          onTap: () => setState(() => _lieIndex = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _lieIndex == i ? AppColors.dareRed.withAlpha(40) : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _lieIndex == i ? AppColors.dareRed : AppColors.surfaceBright),
            ),
            child: Text('This is the lie', style: GoogleFonts.poppins(color: _lieIndex == i ? AppColors.dareRed : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
      const SizedBox(height: 6),
      TextField(
        controller: _stmtCtrls[i],
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
        maxLines: 2,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _lieIndex == i ? AppColors.dareRed : AppColors.surfaceBright)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _lieIndex == i ? AppColors.dareRed.withAlpha(120) : AppColors.surfaceBright)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _lieIndex == i ? AppColors.dareRed : AppColors.truthBlue, width: 2)),
          hintText: i < 2 ? 'A truth about you...' : 'The lie...',
          hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
      const SizedBox(height: 14),
    ])),
    const Spacer(),
    SizedBox(width: double.infinity, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.truthBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: _submitStatements,
      child: Text('SUBMIT', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    )),
  ]));

  Widget _voteView() => Padding(padding: const EdgeInsets.all(24), child: Column(children: [
    Text('${_players[_currentPlayerIndex]}\'s statements', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
    const SizedBox(height: 8),
    Text('WHICH ONE IS THE LIE?', style: GoogleFonts.poppins(color: AppColors.truthBlue, fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 24),
    ...List.generate(_submittedStatements.length, (i) => GestureDetector(
      onTap: () => _guess(i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.truthBlue.withAlpha(60), width: 1.5)),
        child: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.truthBlue.withAlpha(40), borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text('${i + 1}', style: GoogleFonts.poppins(color: AppColors.truthBlue, fontWeight: FontWeight.w800))),
          const SizedBox(width: 14),
          Expanded(child: Text(_submittedStatements[i], style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, height: 1.5))),
        ]),
      ),
    )),
  ]));

  Widget _revealView() {
    final correct = _guessedCorrectly;
    return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(correct ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 80, color: correct ? AppColors.neonGreen : AppColors.dareRed),
      const SizedBox(height: 16),
      Text(correct ? 'CORRECT!' : 'FOOLED EVERYONE!', style: GoogleFonts.poppins(color: correct ? AppColors.neonGreen : AppColors.dareRed, fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 32),
      Text('The lie was:', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.dareRed.withAlpha(25), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.dareRed.withAlpha(100))),
        child: Text(_submittedStatements[_submittedLieIndex], style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, height: 1.5, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
      ),
      if (correct) ...[const SizedBox(height: 12), Text('${_players.where((p) => p != _players[_currentPlayerIndex]).length} guesser(s) get a point!', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13))]
      else ...[const SizedBox(height: 12), Text('${_players[_currentPlayerIndex]} gets a point for fooling everyone!', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13))],
      const Spacer(),
      SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.truthBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _nextRound,
        child: Text('NEXT', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      )),
    ]));
  }

  Widget _scoreView() {
    final sorted = _players.toList()..sort((a, b) => (_scores[b] ?? 0).compareTo(_scores[a] ?? 0));
    return Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 24),
      Text('FINAL SCORES', style: GoogleFonts.poppins(color: AppColors.truthBlue, fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 32),
      Expanded(child: ListView.builder(itemCount: sorted.length, itemBuilder: (_, i) {
        final p = sorted[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: i == 0 ? AppColors.truthBlue.withAlpha(25) : AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: i == 0 ? AppColors.truthBlue : AppColors.surfaceBright)),
          child: Row(children: [
            Text('${i + 1}', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(width: 16),
            Expanded(child: Text(p, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            Text('${_scores[p]} pts', style: GoogleFonts.poppins(color: AppColors.truthBlue, fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        );
      })),
      Row(children: [
        Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.surfaceBright), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: () => Navigator.pop(context), child: Text('Leave', style: GoogleFonts.poppins(color: AppColors.textSecondary)))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.truthBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: _startGame, child: Text('PLAY AGAIN', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800)))),
      ]),
    ]));
  }

  Widget _appBar() => Padding(padding: const EdgeInsets.all(24), child: Row(children: [
    GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBright)), child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18))),
    const SizedBox(width: 16),
    Text('2 TRUTHS 1 LIE', style: GoogleFonts.poppins(color: AppColors.truthBlue, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
