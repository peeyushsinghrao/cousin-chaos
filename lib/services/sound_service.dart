import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

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
}

typedef _Tone = ({double freq, double dur, String wave});

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  final AudioPlayer _player = AudioPlayer();

  static const Map<SoundEvent, _Tone> _tones = {
    SoundEvent.tap:            (freq: 900, dur: 0.05, wave: 'sine'),
    SoundEvent.cardFlip:       (freq: 520, dur: 0.12, wave: 'sine'),
    SoundEvent.cardReveal:     (freq: 660, dur: 0.18, wave: 'sine'),
    SoundEvent.wheelSpin:      (freq: 360, dur: 0.25, wave: 'sawtooth'),
    SoundEvent.wheelLand:      (freq: 700, dur: 0.10, wave: 'sine'),
    SoundEvent.wheelTick:      (freq: 950, dur: 0.04, wave: 'square'),
    SoundEvent.nextPlayer:     (freq: 580, dur: 0.14, wave: 'sine'),
    SoundEvent.win:            (freq: 880, dur: 0.40, wave: 'sine'),
    SoundEvent.wrong:          (freq: 200, dur: 0.30, wave: 'sawtooth'),
    SoundEvent.timerTick:      (freq: 740, dur: 0.05, wave: 'square'),
    SoundEvent.timerEnd:       (freq: 280, dur: 0.50, wave: 'sawtooth'),
    SoundEvent.pageTransition: (freq: 600, dur: 0.10, wave: 'sine'),
    SoundEvent.xpGain:         (freq: 760, dur: 0.22, wave: 'sine'),
    SoundEvent.countdown:      (freq: 680, dur: 0.09, wave: 'sine'),
    SoundEvent.bombTick:       (freq: 420, dur: 0.07, wave: 'square'),
    SoundEvent.freeze:         (freq: 240, dur: 0.40, wave: 'sine'),
    SoundEvent.explosion:      (freq: 120, dur: 0.50, wave: 'sawtooth'),
    SoundEvent.gameStart:      (freq: 720, dur: 0.35, wave: 'sine'),
  };

  Future<void> play(SoundEvent event, {required bool soundEnabled}) async {
    if (!soundEnabled) return;
    final tone = _tones[event];
    if (tone == null) return;
    try {
      final bytes = _buildWav(tone.freq, tone.dur, tone.wave);
      await _player.play(BytesSource(bytes));
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

  /// Generates a mono 16-bit PCM WAV in memory for the given frequency/duration.
  static Uint8List _buildWav(double freq, double durationSec, String waveType,
      {int sampleRate = 22050, double amplitude = 0.25}) {
    final numSamples = (sampleRate * durationSec).ceil().clamp(1, sampleRate * 5);
    final dataSize = numSamples * 2;
    final buf = ByteData(44 + dataSize);

    void setStr(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        buf.setUint8(offset + i, s.codeUnitAt(i));
      }
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
        case 'square':
          sample = sin(phase) >= 0 ? 1.0 : -1.0;
          break;
        case 'sawtooth':
          sample = 2 * ((freq * t) - (freq * t).floor()) - 1;
          break;
        default:
          sample = sin(phase);
      }
      // Envelope: 5ms attack, then linear decay
      final progress = t / durationSec;
      final attack = (t / 0.005).clamp(0.0, 1.0);
      final decay = (1.0 - progress).clamp(0.0, 1.0);
      final env = attack * decay;
      final pcm = (sample * env * amplitude * 32767).round().clamp(-32768, 32767);
      buf.setInt16(44 + i * 2, pcm, Endian.little);
    }

    return buf.buffer.asUint8List();
  }
}
