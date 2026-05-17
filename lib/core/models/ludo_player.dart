import 'ludo_token.dart';

class LudoPlayer {
  final int index;
  final String name;
  final List<LudoToken> tokens;

  int score;
  int sabotageCardsLeft;
  bool swapTrapUsed;
  bool hasKingsRule;
  int rollCount;
  int homeEntryBlockedTurns;
  bool hasBounty;
  bool skipNextTurn;
  bool immuneNextTurn;
  int chaosCompletedCount;
  int sabotagePlayedCount;

  LudoPlayer({
    required this.index,
    required this.name,
    required this.tokens,
    this.score = 0,
    this.sabotageCardsLeft = 2,
    this.swapTrapUsed = false,
    this.hasKingsRule = false,
    this.rollCount = 0,
    this.homeEntryBlockedTurns = 0,
    this.hasBounty = false,
    this.skipNextTurn = false,
    this.immuneNextTurn = false,
    this.chaosCompletedCount = 0,
    this.sabotagePlayedCount = 0,
  });

  static const List<String> colorNames = ['Blue', 'Red', 'Green', 'Yellow'];
  String get colorName => colorNames[index];

  int get finishedCount => tokens.where((t) => t.isFinished).length;
  bool get allFinished  => tokens.every((t) => t.isFinished);
}
