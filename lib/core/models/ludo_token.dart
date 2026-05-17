enum TokenPersonality { swift, armored, lucky, phantom }
enum TokenState { home, active, safe, finished }

class LudoToken {
  final String id;
  final int playerIndex;
  final int tokenIndex;
  final TokenPersonality personality;

  int pathPosition;
  TokenState state;
  bool isCursed;
  bool curseRevealed;
  int jailTurnsRemaining;
  bool isImmune;

  LudoToken({
    required this.id,
    required this.playerIndex,
    required this.tokenIndex,
    required this.personality,
    this.pathPosition = -1,
    this.state = TokenState.home,
    this.isCursed = false,
    this.curseRevealed = false,
    this.jailTurnsRemaining = 0,
    this.isImmune = false,
  });

  bool get isOnBoard  => state == TokenState.active || state == TokenState.safe;
  bool get isFinished => state == TokenState.finished;
  bool get isInJail   => jailTurnsRemaining > 0;

  static String personalityEmoji(TokenPersonality p) {
    switch (p) {
      case TokenPersonality.swift:   return '⚡';
      case TokenPersonality.armored: return '🛡️';
      case TokenPersonality.lucky:   return '🍀';
      case TokenPersonality.phantom: return '👻';
    }
  }

  static String personalityName(TokenPersonality p) {
    switch (p) {
      case TokenPersonality.swift:   return 'Swift';
      case TokenPersonality.armored: return 'Armored';
      case TokenPersonality.lucky:   return 'Lucky';
      case TokenPersonality.phantom: return 'Phantom';
    }
  }

  static String personalityDesc(TokenPersonality p) {
    switch (p) {
      case TokenPersonality.swift:
        return 'Rolls the highest possible value on the very first roll.';
      case TokenPersonality.armored:
        return 'Immune to all Sabotage Cards — cannot be targeted.';
      case TokenPersonality.lucky:
        return 'Moves +1 extra step on every roll of 6.';
      case TokenPersonality.phantom:
        return 'Cannot be sent to Jail — passes through freely.';
    }
  }
}
