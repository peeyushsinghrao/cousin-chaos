import 'package:audioplayers/audioplayers.dart';

enum SoundEvent {
  tap,
  cardFlip,
  cardReveal,
  wheelSpin,
  wheelLand,
  wheelTick,
  nextPlayer,
  win,
  wrong,
  timerTick,
  timerEnd,
  pageTransition,
  xpGain,
  countdown,
  bombTick,
  freeze,
  explosion,
  gameStart,

  // Ludo-specific
  ludoDiceRoll,
  ludoTokenMove,
  ludoTokenEnter,
  ludoTokenHome,
  ludoTokenSentHome,
  ludoChaosTitle,
  ludoJailEnter,
  ludoJailFree,
  ludoGiftSquare,
  ludoWormhole,
  ludoSabotage,
  ludoPowerRoll,
  ludoBountySet,
  ludoBountyCapture,
  ludoKingCrown,
  ludoCurseReveal,
  ludoSpeedRound,
  ludoSwapTrap,
  ludoEventGood,
  ludoEventBad,
  ludoWin,
}

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  final AudioPlayer _player = AudioPlayer();

  static const Map<SoundEvent, String> _assetMap = {
    SoundEvent.tap: 'sounds/click.mp3',
    SoundEvent.cardFlip: 'sounds/reveal.mp3',
    SoundEvent.cardReveal: 'sounds/reveal.mp3',
    SoundEvent.wheelSpin: 'sounds/whoosh.mp3',
    SoundEvent.wheelLand: 'sounds/click.mp3',
    SoundEvent.wheelTick: 'sounds/tick.mp3',
    SoundEvent.nextPlayer: 'sounds/whoosh.mp3',
    SoundEvent.win: 'sounds/success.mp3',
    SoundEvent.wrong: 'sounds/fail.mp3',
    SoundEvent.timerTick: 'sounds/tick.mp3',
    SoundEvent.timerEnd: 'sounds/timer_end.mp3',
    SoundEvent.pageTransition: 'sounds/whoosh.mp3',
    SoundEvent.xpGain: 'sounds/success.mp3',
    SoundEvent.countdown: 'sounds/tick.mp3',
    SoundEvent.bombTick: 'sounds/tick.mp3',
    SoundEvent.freeze: 'sounds/freeze.mp3',
    SoundEvent.explosion: 'sounds/explosion.mp3',
    SoundEvent.gameStart: 'sounds/success.mp3',

    // Ludo — mapped to existing sounds (replace with dedicated files when available)
    SoundEvent.ludoDiceRoll: 'sounds/whoosh.mp3',
    SoundEvent.ludoTokenMove: 'sounds/tick.mp3',
    SoundEvent.ludoTokenEnter: 'sounds/click.mp3',
    SoundEvent.ludoTokenHome: 'sounds/success.mp3',
    SoundEvent.ludoTokenSentHome: 'sounds/fail.mp3',
    SoundEvent.ludoChaosTitle: 'sounds/reveal.mp3',
    SoundEvent.ludoJailEnter: 'sounds/freeze.mp3',
    SoundEvent.ludoJailFree: 'sounds/success.mp3',
    SoundEvent.ludoGiftSquare: 'sounds/success.mp3',
    SoundEvent.ludoWormhole: 'sounds/whoosh.mp3',
    SoundEvent.ludoSabotage: 'sounds/explosion.mp3',
    SoundEvent.ludoPowerRoll: 'sounds/reveal.mp3',
    SoundEvent.ludoBountySet: 'sounds/tick.mp3',
    SoundEvent.ludoBountyCapture: 'sounds/success.mp3',
    SoundEvent.ludoKingCrown: 'sounds/success.mp3',
    SoundEvent.ludoCurseReveal: 'sounds/fail.mp3',
    SoundEvent.ludoSpeedRound: 'sounds/timer_end.mp3',
    SoundEvent.ludoSwapTrap: 'sounds/whoosh.mp3',
    SoundEvent.ludoEventGood: 'sounds/success.mp3',
    SoundEvent.ludoEventBad: 'sounds/fail.mp3',
    SoundEvent.ludoWin: 'sounds/success.mp3',
  };

  Future<void> play(SoundEvent event, {required bool soundEnabled}) async {
    if (!soundEnabled) return;
    final asset = _assetMap[event];
    if (asset == null) return;
    try {
      await _player.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
