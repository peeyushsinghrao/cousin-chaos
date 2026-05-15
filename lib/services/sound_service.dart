import 'package:audioplayers/audioplayers.dart';

enum SoundEvent {
  tap,
  cardReveal,
  countdown,
  timerEnd,
  explosion,
  win,
  wrong,
  freeze,
  nextPlayer,
  bombTick,
}

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  final AudioPlayer _player = AudioPlayer();

  static const Map<SoundEvent, String> _assetMap = {
    SoundEvent.tap: 'sounds/click.mp3',
    SoundEvent.cardReveal: 'sounds/reveal.mp3',
    SoundEvent.countdown: 'sounds/tick.mp3',
    SoundEvent.timerEnd: 'sounds/timer_end.mp3',
    SoundEvent.explosion: 'sounds/explosion.mp3',
    SoundEvent.win: 'sounds/success.mp3',
    SoundEvent.wrong: 'sounds/fail.mp3',
    SoundEvent.freeze: 'sounds/freeze.mp3',
    SoundEvent.nextPlayer: 'sounds/whoosh.mp3',
    SoundEvent.bombTick: 'sounds/tick.mp3',
  };

  Future<void> play(SoundEvent event, {required bool soundEnabled}) async {
    if (!soundEnabled) return;
    final asset = _assetMap[event];
    if (asset == null) return;
    try {
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Sound asset not found — fail silently
    }
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
