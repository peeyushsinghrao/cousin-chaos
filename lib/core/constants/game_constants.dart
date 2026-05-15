class GameConstants {
  static const Map<String, int> minPlayers = {
    'truth_or_dare': 2,
    'impostor': 3,
    'hot_seat': 3,
    'alibi': 3,
    'most_likely': 3,
    'two_truths': 3,
    'judge_me': 3,
    'last_standing': 3,
    'bomb_pass': 2,
    'rank_it': 2,
    'default': 2,
  };

  static int getMin(String mode) => minPlayers[mode] ?? 2;

  static String? getMessage(String mode, int count) {
    final min = getMin(mode);
    if (count >= min) return null;
    return 'Need at least $min players for this mode';
  }
}
