import 'package:audioplayers/audioplayers.dart';

/// Sound utilities for Impostor Mode
class ImpostorSounds {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isSoundEnabled = true;

  static void enableSound(bool enable) {
    _isSoundEnabled = enable;
  }

  /// Play reveal sound (reveal the impostor/word)
  static Future<void> playRevealSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(
        AssetSource('sounds/reveal.mp3'),
      );
    } catch (e) {
      // Sound file not found - silently fail
    }
  }

  /// Play click/tap sound
  static Future<void> playClickSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(
        AssetSource('sounds/click.mp3'),
      );
    } catch (e) {
      // Sound file not found - silently fail
    }
  }

  /// Play voting/selection sound
  static Future<void> playVoteSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(
        AssetSource('sounds/vote.mp3'),
      );
    } catch (e) {
      // Sound file not found - silently fail
    }
  }

  /// Play success/win sound
  static Future<void> playSuccessSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(
        AssetSource('sounds/success.mp3'),
      );
    } catch (e) {
      // Sound file not found - silently fail
    }
  }

  /// Play fail/lose sound
  static Future<void> playFailSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(
        AssetSource('sounds/fail.mp3'),
      );
    } catch (e) {
      // Sound file not found - silently fail
    }
  }

  /// Play suspense sound (countdown/tension)
  static Future<void> playSuspenseSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(
        AssetSource('sounds/suspense.mp3'),
      );
    } catch (e) {
      // Sound file not found - silently fail
    }
  }

  static Future<void> stop() async {
    await _audioPlayer.stop();
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
