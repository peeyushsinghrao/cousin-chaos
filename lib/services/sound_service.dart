import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

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
  countdown,
  bombTick,
  freeze,
  explosion,
  gameStart,
}

// Filename for each event (null = synthesised fallback only)
const Map<SoundEvent, String> _mp3Files = {
  SoundEvent.tap:            'tap.mp3',
  SoundEvent.cardFlip:       'card_flip.mp3',
  SoundEvent.cardReveal:     'card_reveal.mp3',
  SoundEvent.wheelSpin:      'wheel_spin.mp3',
  SoundEvent.win:            'win.mp3',
  SoundEvent.timerTick:      'timer_tick.mp3',
  SoundEvent.timerEnd:       'timer_tick.mp3',   // same file — alarm is at end
  SoundEvent.countdown:      'countdown.mp3',
  SoundEvent.bombTick:       'bomb_tick.mp3',
  SoundEvent.freeze:         'freeze.mp3',
  SoundEvent.explosion:      'explosion.mp3',
  SoundEvent.gameStart:      'game_start.mp3',
  SoundEvent.nextPlayer:     'tap.mp3',          // alias
  SoundEvent.pageTransition: 'page_transition.mp3', // alias (copy of tap)
};

// Per-event volume (0.0–1.0)
const Map<SoundEvent, double> _volumes = {
  SoundEvent.tap:            0.5,
  SoundEvent.cardFlip:       0.7,
  SoundEvent.cardReveal:     0.8,
  SoundEvent.wheelSpin:      0.9,
  SoundEvent.wheelTick:      0.9,
  SoundEvent.wheelLand:      0.9,
  SoundEvent.nextPlayer:     0.5,
  SoundEvent.win:            1.0,
  SoundEvent.wrong:          0.8,
  SoundEvent.timerTick:      0.6,
  SoundEvent.timerEnd:       0.6,
  SoundEvent.pageTransition: 0.3,
  SoundEvent.countdown:      0.9,
  SoundEvent.bombTick:       0.7,
  SoundEvent.freeze:         0.8,
  SoundEvent.explosion:      1.0,
  SoundEvent.gameStart:      1.0,
};

typedef _Tone = ({double freq, double dur, String wave});

const Map<SoundEvent, _Tone> _fallbackTones = {
  SoundEvent.tap:            (freq: 900,  dur: 0.05, wave: 'sine'),
  SoundEvent.cardFlip:       (freq: 520,  dur: 0.12, wave: 'sine'),
  SoundEvent.cardReveal:     (freq: 660,  dur: 0.18, wave: 'sine'),
  SoundEvent.wheelSpin:      (freq: 360,  dur: 0.25, wave: 'sawtooth'),
  SoundEvent.wheelLand:      (freq: 700,  dur: 0.10, wave: 'sine'),
  SoundEvent.wheelTick:      (freq: 950,  dur: 0.04, wave: 'square'),
  SoundEvent.nextPlayer:     (freq: 580,  dur: 0.14, wave: 'sine'),
  SoundEvent.win:            (freq: 880,  dur: 0.40, wave: 'sine'),
  SoundEvent.wrong:          (freq: 200,  dur: 0.30, wave: 'sawtooth'),
  SoundEvent.timerTick:      (freq: 740,  dur: 0.05, wave: 'square'),
  SoundEvent.timerEnd:       (freq: 280,  dur: 0.50, wave: 'sawtooth'),
  SoundEvent.pageTransition: (freq: 600,  dur: 0.10, wave: 'sine'),
  SoundEvent.countdown:      (freq: 680,  dur: 0.09, wave: 'sine'),
  SoundEvent.bombTick:       (freq: 420,  dur: 0.07, wave: 'square'),
  SoundEvent.freeze:         (freq: 240,  dur: 0.40, wave: 'sine'),
  SoundEvent.explosion:      (freq: 120,  dur: 0.50, wave: 'sawtooth'),
  SoundEvent.gameStart:      (freq: 720,  dur: 0.35, wave: 'sine'),
};

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  // Dedicated players: long-form sounds don't interrupt short UI sounds
  final AudioPlayer _uiPlayer   = AudioPlayer();  // tap, flip, tick, transition
  final AudioPlayer _longPlayer = AudioPlayer();  // wheel_spin, win, explosion, etc.

  final Set<SoundEvent> _availableMp3s  = {};
  final Set<SoundEvent> _checkedEvents  = {};

  // Events that use the sustained long player
  static const _longEvents = {
    SoundEvent.wheelSpin,
    SoundEvent.win,
    SoundEvent.explosion,
    SoundEvent.gameStart,
    SoundEvent.freeze,
    SoundEvent.countdown,
    SoundEvent.timerEnd,
  };

  // wheel_spin.mp3 is a complete file (spin + ticks + land).
  // wheelTick and wheelLand are no-ops when the MP3 is available.
  static const _wheelCoveredEvents = {
    SoundEvent.wheelTick,
    SoundEvent.wheelLand,
  };

  /// Call once at app startup to pre-check which MP3s exist.
  Future<void> preload() async {
    final allEvents = SoundEvent.values;
    for (final event in allEvents) {
      final filename = _mp3Files[event];
      if (filename == null) continue;
      try {
        await rootBundle.load('assets/sounds/$filename');
        _availableMp3s.add(event);
      } catch (_) {}
      _checkedEvents.add(event);
    }
  }

  Future<void> play(SoundEvent event, {required bool soundEnabled}) async {
    if (!soundEnabled) return;

    // wheel_spin.mp3 covers ticks and land — skip those separately
    if (_wheelCoveredEvents.contains(event) && _availableMp3s.contains(SoundEvent.wheelSpin)) {
      return;
    }

    // Lazy-check if not preloaded yet
    if (!_checkedEvents.contains(event)) {
      _checkedEvents.add(event);
      final filename = _mp3Files[event];
      if (filename != null) {
        try {
          await rootBundle.load('assets/sounds/$filename');
          _availableMp3s.add(event);
        } catch (_) {}
      }
    }

    final volume = _volumes[event] ?? 0.7;
    final player = _longEvents.contains(event) ? _longPlayer : _uiPlayer;

    try {
      if (_availableMp3s.contains(event)) {
        await player.stop();
        await player.setVolume(volume);
        await player.play(AssetSource('sounds/${_mp3Files[event]}'));
      } else {
        final tone = _fallbackTones[event];
        if (tone == null) return;
        final bytes = _buildWav(tone.freq, tone.dur, tone.wave);
        await player.stop();
        await player.setVolume(volume);
        await player.play(BytesSource(bytes));
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    try { await _uiPlayer.stop(); } catch (_) {}
    try { await _longPlayer.stop(); } catch (_) {}
  }

  void dispose() {
    _uiPlayer.dispose();
    _longPlayer.dispose();
  }

  static Uint8List _buildWav(double freq, double durationSec, String waveType,
      {int sampleRate = 22050, double amplitude = 0.25}) {
    final numSamples = (sampleRate * durationSec).ceil().clamp(1, sampleRate * 5);
    final dataSize = numSamples * 2;
    final buf = ByteData(44 + dataSize);
    void setStr(int offset, String s) {
      for (int i = 0; i < s.length; i++) buf.setUint8(offset + i, s.codeUnitAt(i));
    }
    setStr(0, 'RIFF');
    buf.setUint32(4, 36 + dataSize, Endian.little);
    setStr(8, 'WAVE');
    setStr(12, 'fmt ');
    buf.setUint32(16, 16, Endian.little);
    buf.setUint16(20, 1, Endian.little);
    buf.setUint16(22, 1, Endian.little);
    buf.setUint32(24, sampleRate, Endian.little);
    buf.setUint32(28, sampleRate * 2, Endian.little);
    buf.setUint16(32, 2, Endian.little);
    buf.setUint16(34, 16, Endian.little);
    setStr(36, 'data');
    buf.setUint32(40, dataSize, Endian.little);
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final phase = 2 * pi * freq * t;
      double sample;
      switch (waveType) {
        case 'square':   sample = sin(phase) >= 0 ? 1.0 : -1.0; break;
        case 'sawtooth': sample = 2 * ((freq * t) - (freq * t).floor()) - 1; break;
        default:         sample = sin(phase);
      }
      final attack = (t / 0.005).clamp(0.0, 1.0);
      final decay  = (1.0 - t / durationSec).clamp(0.0, 1.0);
      final pcm = (sample * attack * decay * amplitude * 32767).round().clamp(-32768, 32767);
      buf.setInt16(44 + i * 2, pcm, Endian.little);
    }
    return buf.buffer.asUint8List();
  }
}
