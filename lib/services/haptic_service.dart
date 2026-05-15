import 'package:flutter/services.dart';

enum HapticEvent {
  tap,
  cardReveal,
  gameStart,
  playerEliminated,
  win,
  explosion,
  freeze,
}

class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  Future<void> trigger(HapticEvent event, {required bool hapticsEnabled}) async {
    if (!hapticsEnabled) return;
    switch (event) {
      case HapticEvent.tap:
        await HapticFeedback.lightImpact();
      case HapticEvent.cardReveal:
        await HapticFeedback.mediumImpact();
      case HapticEvent.gameStart:
        await HapticFeedback.mediumImpact();
      case HapticEvent.playerEliminated:
        await HapticFeedback.heavyImpact();
      case HapticEvent.win:
        await HapticFeedback.heavyImpact();
      case HapticEvent.explosion:
        await HapticFeedback.heavyImpact();
      case HapticEvent.freeze:
        await HapticFeedback.vibrate();
    }
  }
}
