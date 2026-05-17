import 'ludo_player.dart';

enum LudoPhase {
  rolling,
  choosingToken,
  animating,
  chaosPrompt,
  eventCard,
  giftPicker,
  kingsRule,
  sabotageSelect,
  swapSelect,
  speedRoll,
  finished,
}

class LudoGameState {
  final List<LudoPlayer> players;
  int currentPlayerIndex;
  LudoPhase phase;

  int lastDiceValue;
  int? lastDiceValue2;
  bool isPowerRoll;

  int totalRollCount;
  bool speedRoundActive;
  bool wormholeAtoB;

  int? bountyPlayerIndex;
  String? kingsRuleText;
  int kingsRuleTurnsLeft;
  bool kingCrownedThisGame;

  List<int> finishOrder;
  List<Map<String, dynamic>> eventCardDeck;

  bool paralysedThisTurn;
  bool extraRollThisTurn;

  LudoGameState({
    required this.players,
    this.currentPlayerIndex = 0,
    this.phase = LudoPhase.rolling,
    this.lastDiceValue = 1,
    this.lastDiceValue2,
    this.isPowerRoll = false,
    this.totalRollCount = 0,
    this.speedRoundActive = false,
    this.wormholeAtoB = true,
    this.bountyPlayerIndex,
    this.kingsRuleText,
    this.kingsRuleTurnsLeft = 0,
    this.kingCrownedThisGame = false,
    this.finishOrder = const [],
    this.eventCardDeck = const [],
    this.paralysedThisTurn = false,
    this.extraRollThisTurn = false,
  });

  LudoPlayer get currentPlayer => players[currentPlayerIndex];

  int get activeTokensOnBoard => players
      .expand((p) => p.tokens)
      .where((t) => t.isOnBoard)
      .length;
}
