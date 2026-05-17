import 'dart:math';
import '../core/models/ludo_game_state.dart';
import '../core/models/ludo_player.dart';
import '../core/models/ludo_token.dart';
import '../core/constants/ludo_data.dart';

enum MoveResultType {
  cantMove,
  enteredBoard,
  normal,
  attacked,
  chaosTile,
  wormhole,
  jailed,
  jailBailout,
  giftSquare,
  reachedHome,
  movedSafe,
  homeBlocked,
}

class MoveResult {
  final MoveResultType type;
  final LudoToken token;
  final List<LudoToken> attackedTokens;
  final bool curseRevealed;
  final String? chaosPrompt;
  final bool chaosIsTruth;

  const MoveResult({
    required this.type,
    required this.token,
    this.attackedTokens = const [],
    this.curseRevealed = false,
    this.chaosPrompt,
    this.chaosIsTruth = false,
  });
}

class LudoGameService {
  static final LudoGameService instance = LudoGameService._();
  LudoGameService._();

  final _rng = Random.secure();

  // ── Initialisation ────────────────────────────────────────────────────────

  LudoGameState createGame(List<String> playerNames) {
    final players = <LudoPlayer>[];

    for (int i = 0; i < playerNames.length; i++) {
      final personalities = TokenPersonality.values.toList()..shuffle(_rng);
      final tokens = List.generate(4, (j) => LudoToken(
        id: '${LudoPlayer.colorNames[i].toLowerCase()}_$j',
        playerIndex: i,
        tokenIndex: j,
        personality: personalities[j],
      ));
      tokens[_rng.nextInt(4)].isCursed = true;

      players.add(LudoPlayer(
        index: i,
        name: playerNames[i],
        tokens: tokens,
      ));
    }

    final deck = [...kEventCardsData]..shuffle(_rng);

    return LudoGameState(
      players: players,
      wormholeAtoB: _rng.nextBool(),
      eventCardDeck: List.from(deck),
      finishOrder: [],
    );
  }

  // ── Dice rolling ──────────────────────────────────────────────────────────

  ({int primary, int? secondary, bool isPowerRoll}) rollDice(LudoGameState state) {
    state.totalRollCount++;
    final isPower = state.totalRollCount % 5 == 0;
    int primary = 1 + _rng.nextInt(6);
    int? secondary = isPower ? (1 + _rng.nextInt(6)) : null;

    if (state.totalRollCount == 1) {
      final cp = state.currentPlayer;
      final hasSwift = cp.tokens.any((t) => t.personality == TokenPersonality.swift);
      if (hasSwift) return (primary: 6, secondary: null, isPowerRoll: false);
    }

    return (primary: primary, secondary: secondary, isPowerRoll: isPower);
  }

  // ── Event cards ───────────────────────────────────────────────────────────

  Map<String, dynamic> drawEventCard(LudoGameState state) {
    if (state.eventCardDeck.isEmpty) {
      state.eventCardDeck = [...kEventCardsData]..shuffle(_rng);
    }
    final card = state.eventCardDeck.removeAt(0);
    return card;
  }

  void applyEventCard(LudoGameState state, Map<String, dynamic> card) {
    final p = state.currentPlayer;
    switch (card['effect'] as String) {
      case 'moveForward3':
        state.phase = LudoPhase.giftPicker;
        break;
      case 'extraRoll':
        state.extraRollThisTurn = true;
        break;
      case 'stealPoints10':
        final leader = _findLeader(state);
        if (leader.index != p.index) {
          leader.score -= 10;
          p.score += 10;
        }
        break;
      case 'freeJail':
        for (final t in p.tokens) {
          t.jailTurnsRemaining = 0;
        }
        break;
      case 'immune':
        p.immuneNextTurn = true;
        break;
      case 'fastestBack6':
        final fastest = _fastestToken(p);
        if (fastest != null && fastest.isOnBoard) {
          fastest.pathPosition = (fastest.pathPosition - 6 + 52) % 52;
        }
        break;
      case 'skipNext':
        p.skipNextTurn = true;
        break;
      case 'losePoints10':
        p.score -= 10;
        break;
      case 'noMove':
        state.paralysedThisTurn = true;
        break;
      case 'givePoints10':
        final last = _findLastPlace(state);
        if (last.index != p.index && p.score >= 10) {
          p.score -= 10;
          last.score += 10;
        }
        break;
    }
  }

  // ── Token movement ────────────────────────────────────────────────────────

  MoveResult moveToken(LudoGameState state, LudoToken token, int diceValue) {
    final player = state.players[token.playerIndex];

    if (player.homeEntryBlockedTurns > 0 && token.state == TokenState.home) {
      return MoveResult(type: MoveResultType.homeBlocked, token: token);
    }

    if (token.state == TokenState.home) {
      if (diceValue != 6) {
        return MoveResult(type: MoveResultType.cantMove, token: token);
      }
      token.state = TokenState.active;
      token.pathPosition = kPlayerEntrySquares[token.playerIndex];
      _checkAndAttack(state, token, player);
      return MoveResult(type: MoveResultType.enteredBoard, token: token);
    }

    if (token.isInJail) {
      return MoveResult(type: MoveResultType.cantMove, token: token);
    }

    final int steps = (token.personality == TokenPersonality.lucky && diceValue == 6) 
        ? diceValue + 1 
        : diceValue;

    if (token.pathPosition >= 52) {
      final newPos = token.pathPosition + steps;
      if (newPos >= 58) {
        token.pathPosition = 57;
        token.state = TokenState.finished;
        player.score += 50;
        if (!state.kingCrownedThisGame && player.finishedCount == 1) {
          state.kingCrownedThisGame = true;
          state.phase = LudoPhase.kingsRule;
        }
        if (!state.finishOrder.contains(player.index)) {
          state.finishOrder = [...state.finishOrder, player.index];
        }
        return MoveResult(type: MoveResultType.reachedHome, token: token);
      }
      token.pathPosition = newPos;
      return MoveResult(type: MoveResultType.movedSafe, token: token);
    }

    int currentPos = token.pathPosition;
    final homeEntryIndex = kHomeColEntry[token.playerIndex];

    for (int step = 0; step < steps; step++) {
      if (currentPos == homeEntryIndex) {
        final remaining = steps - step - 1;
        final homeColPos = remaining;
        if (homeColPos <= 5) {
          token.pathPosition = 52 + homeColPos;
          if (homeColPos == 5) {
            token.state = TokenState.finished;
            player.score += 50;
            if (!state.kingCrownedThisGame && player.finishedCount == 1) {
              state.kingCrownedThisGame = true;
              state.phase = LudoPhase.kingsRule;
            }
            if (!state.finishOrder.contains(player.index)) {
              state.finishOrder = [...state.finishOrder, player.index];
            }
            return MoveResult(type: MoveResultType.reachedHome, token: token);
          } else {
            return MoveResult(type: MoveResultType.movedSafe, token: token);
          }
        }
      }
      currentPos = (currentPos + 1) % 52;
    }

    token.pathPosition = currentPos;

    if (kSafeSquares.contains(currentPos)) {
      token.state = TokenState.safe;
      return MoveResult(type: MoveResultType.movedSafe, token: token);
    } else {
      token.state = TokenState.active;
    }

    if (kChaosTiles.contains(currentPos)) {
      final isTruth = _rng.nextBool();
      final prompts = isTruth ? kLudoChaosTruths : kLudoChaosDares;
      final prompt = prompts[_rng.nextInt(prompts.length)];
      return MoveResult(
        type: MoveResultType.chaosTile,
        token: token,
        chaosPrompt: prompt,
        chaosIsTruth: isTruth,
      );
    }

    if (currentPos == kWormholeA || currentPos == kWormholeB) {
      final dest = state.wormholeAtoB
          ? (currentPos == kWormholeA ? kWormholeB : kWormholeA)
          : (currentPos == kWormholeB ? kWormholeA : kWormholeB);
      state.wormholeAtoB = !state.wormholeAtoB;
      token.pathPosition = dest;
      return MoveResult(type: MoveResultType.wormhole, token: token);
    }

    if (currentPos == kJailSquare && token.personality != TokenPersonality.phantom) {
      final jailedAlready = _otherJailedTokensOnSquare(state, token, currentPos);
      if (jailedAlready.isNotEmpty) {
        for (final t in jailedAlready) {
          t.jailTurnsRemaining = 0;
        }
        return MoveResult(
          type: MoveResultType.jailBailout,
          token: token,
          attackedTokens: jailedAlready,
        );
      }
      token.jailTurnsRemaining = 2;
      return MoveResult(type: MoveResultType.jailed, token: token);
    }

    if (currentPos == kGiftSquare) {
      return MoveResult(type: MoveResultType.giftSquare, token: token);
    }

    final attacked = _checkAndAttack(state, token, player);
    if (attacked.isNotEmpty) {
      bool curseRevealed = false;
      for (final a in attacked) {
        player.score += 10;
        if (state.bountyPlayerIndex != null &&
            state.players[a.playerIndex].hasBounty) {
          player.score += 25;
        }
        if (a.isCursed && !a.curseRevealed) {
          a.curseRevealed = true;
          state.players[a.playerIndex].score -= 10;
          curseRevealed = true;
        }
      }
      return MoveResult(
        type: MoveResultType.attacked,
        token: token,
        attackedTokens: attacked,
        curseRevealed: curseRevealed,
      );
    }

    return MoveResult(type: MoveResultType.normal, token: token);
  }

  void applyGiftMove(LudoGameState state, LudoToken token, {int steps = 6}) {
    if (token.state == TokenState.finished) return;
    if (token.state == TokenState.home) {
      token.state = TokenState.active;
      token.pathPosition = kPlayerEntrySquares[token.playerIndex];
    } else if (token.pathPosition < 52) {
      token.pathPosition = (token.pathPosition + steps) % 52;
    }
  }

  void applyChaosTileRefuse(LudoToken token) {
    if (token.pathPosition >= 52) return;
    token.pathPosition = (token.pathPosition - 6 + 52) % 52;
  }

  void applySabotage(LudoGameState state, int targetPlayerIndex, String type, LudoToken? targetToken) {
    final attacker = state.currentPlayer;
    if (attacker.sabotageCardsLeft <= 0) return;
    attacker.sabotageCardsLeft--;
    attacker.sabotagePlayedCount++;

    final target = state.players[targetPlayerIndex];
    switch (type) {
      case 'freeze':
        target.skipNextTurn = true;
        break;
      case 'sendBack5':
        if (targetToken != null &&
            targetToken.personality != TokenPersonality.armored &&
            targetToken.isOnBoard &&
            targetToken.pathPosition < 52) {
          targetToken.pathPosition = (targetToken.pathPosition - 5 + 52) % 52;
        }
        break;
      case 'blockHome':
        if (targetToken?.personality != TokenPersonality.armored) {
          target.homeEntryBlockedTurns = 2;
        }
        break;
    }
  }

  void applySwapTrap(LudoGameState state, LudoToken tokenA, LudoToken tokenB) {
    final playerA = state.players[tokenA.playerIndex];
    playerA.swapTrapUsed = true;

    final tempPos = tokenA.pathPosition;
    final tempState = tokenA.state;

    tokenA.pathPosition = tokenB.pathPosition;
    tokenA.state = tokenB.state;

    tokenB.pathPosition = tempPos;
    tokenB.state = tempState;
  }

  void advanceTurn(LudoGameState state) {
    final p = state.currentPlayer;

    if (p.homeEntryBlockedTurns > 0) p.homeEntryBlockedTurns--;
    if (p.immuneNextTurn) p.immuneNextTurn = false;

    state.paralysedThisTurn = false;
    state.extraRollThisTurn = false;

    if (state.kingsRuleTurnsLeft > 0) {
      state.kingsRuleTurnsLeft--;
      if (state.kingsRuleTurnsLeft == 0) {
        state.kingsRuleText = null;
      }
    }

    int next = (state.currentPlayerIndex + 1) % state.players.length;
    while (state.players[next].allFinished) {
      next = (next + 1) % state.players.length;
      if (next == state.currentPlayerIndex) break;
    }
    state.currentPlayerIndex = next;
    state.phase = LudoPhase.rolling;
    state.isPowerRoll = false;
    state.lastDiceValue2 = null;

    _checkSpeedRound(state);
    _checkBounty(state);

    for (final token in state.currentPlayer.tokens) {
      if (token.isInJail) token.jailTurnsRemaining--;
    }

    if (state.finishOrder.length >= state.players.length - 1 &&
        state.players.length > 1) {
      for (final pl in state.players) {
        if (!state.finishOrder.contains(pl.index)) {
          state.finishOrder = [...state.finishOrder, pl.index];
        }
      }
      state.phase = LudoPhase.finished;
    }
  }

  bool isGameFinished(LudoGameState state) {
    final activePlayers = state.players.where((p) => !p.allFinished).toList();
    return activePlayers.length <= 1;
  }

  List<LudoToken> getSelectableTokens(LudoGameState state, int diceValue) {
    if (state.paralysedThisTurn) return [];
    final p = state.currentPlayer;
    final result = <LudoToken>[];

    for (final token in p.tokens) {
      if (token.isFinished) continue;
      if (token.isInJail) continue;
      if (token.state == TokenState.home && diceValue == 6) {
        result.add(token);
      } else if (token.isOnBoard) {
        result.add(token);
      }
    }
    return result;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  List<LudoToken> _checkAndAttack(LudoGameState state, LudoToken mover, LudoPlayer moverPlayer) {
    if (kSafeSquares.contains(mover.pathPosition)) return [];
    final attacked = <LudoToken>[];

    for (final player in state.players) {
      if (player.index == moverPlayer.index) continue;
      if (player.immuneNextTurn) continue;
      for (final token in player.tokens) {
        if (!token.isOnBoard) continue;
        if (token.pathPosition != mover.pathPosition) continue;
        if (kSafeSquares.contains(token.pathPosition)) continue;
        token.state = TokenState.home;
        token.pathPosition = -1;
        token.jailTurnsRemaining = 0;
        attacked.add(token);
      }
    }
    return attacked;
  }

  List<LudoToken> _otherJailedTokensOnSquare(
      LudoGameState state, LudoToken mover, int pos) {
    final result = <LudoToken>[];
    for (final player in state.players) {
      if (player.index == mover.playerIndex) continue;
      for (final token in player.tokens) {
        if (token.isOnBoard &&
            token.pathPosition == pos &&
            token.isInJail) {
          result.add(token);
        }
      }
    }
    return result;
  }

  LudoPlayer _findLeader(LudoGameState state) {
    return state.players.reduce((a, b) => a.score >= b.score ? a : b);
  }

  LudoPlayer _findLastPlace(LudoGameState state) {
    return state.players.reduce((a, b) => a.score <= b.score ? a : b);
  }

  LudoToken? _fastestToken(LudoPlayer player) {
    LudoToken? fastest;
    for (final t in player.tokens) {
      if (!t.isOnBoard) continue;
      if (fastest == null || t.pathPosition > fastest.pathPosition) {
        fastest = t;
      }
    }
    return fastest;
  }

  void _checkSpeedRound(LudoGameState state) {
    if (!state.speedRoundActive && state.activeTokensOnBoard <= 2) {
      state.speedRoundActive = true;
    }
  }

  void _checkBounty(LudoGameState state) {
    if (state.players.length < 2) return;
    final scores = state.players.map((p) => p.score).toList();
    final avg = scores.reduce((a, b) => a + b) / scores.length;

    for (final p in state.players) {
      if (p.score - avg >= 30) {
        p.hasBounty = true;
        state.bountyPlayerIndex = p.index;
      } else {
        p.hasBounty = false;
      }
    }
    if (!state.players.any((p) => p.hasBounty)) {
      state.bountyPlayerIndex = null;
    }
  }
}

