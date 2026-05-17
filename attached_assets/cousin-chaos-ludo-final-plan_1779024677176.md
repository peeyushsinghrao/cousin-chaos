# COUSIN CHAOS — LUDO CHAOS EDITION
## Complete Implementation Plan (Single Device · Pass-One-Phone)
### Full Board Game · 13 Chaos Features · Ludo King-Inspired · Integrated Sound & Haptics

---

## HOW THE GAME WORKS — FULL EXPLANATION

### The Big Picture

Ludo Chaos is a full board game built inside the existing Cousin Chaos app. It uses the same design system — `AppColors`, `GlassCard`, `SoundService`, `HapticService`, `PreferencesService` — as every other mode. There is no multiplayer. Everyone plays on **one phone**, passing it around the table after each turn, exactly like passing dice in real life.

---

### The Board

The board is a **15×15 grid** drawn with Flutter's `CustomPainter`. It is never an image file — it is drawn in code every frame. The board has:

- **4 home zones** in the four corners (6×6 squares each). Blue is top-left, Red is top-right, Yellow is bottom-left, Green is bottom-right. Each home zone is filled with the player's neon colour at low opacity with a neon border. Inside each home zone are 4 token slots arranged in a 2×2 grid.
- **52 path squares** forming a clockwise loop around the board. These alternate between two dark surface colours.
- **4 home columns** — one per player. These are 6 coloured squares leading from the outer path into the centre triangle. A token that enters its home column cannot be sent back — it is safe.
- **1 centre triangle** — the finish zone. It is divided into 4 triangular sections, one per player colour, meeting at a star in the middle.
- **Safe squares** — 8 star-marked squares around the board where tokens cannot be attacked.
- **Special squares** — Chaos Tiles, Wormholes, Jail, and Gift Square overlaid on specific path positions.

The board is rendered inside an `InteractiveViewer` so players can pinch to zoom and pan. On small phones, zooming in to see their token is comfortable.

---

### Players and Tokens

Each player (2, 3, or 4 players) has **4 tokens**. At the start of the game all tokens sit in the home zone and are off the board. A player must roll a **6** to place a token onto the board at their entry square. Once on the board the token moves clockwise around the path by the dice value each turn.

Each token is assigned a **Token Personality** randomly at game start. There are 4 personalities:

| Personality | Effect |
|---|---|
| ⚡ Swift | Rolls the highest possible value on the very first roll of the game |
| 🛡️ Armored | Immune to all Sabotage Cards — cannot be targeted |
| 🍀 Lucky | Moves +1 extra step on every roll of 6 (so a 6 moves this token 7) |
| 👻 Phantom | Cannot be sent to Jail — passes through square 42 freely |

One token per player is also secretly **Cursed** at game start. The player does not know which one. If an opponent sends the cursed token back to the home zone, the owning player loses **−10 points** and the curse is dramatically revealed.

---

### Turn Flow — Step by Step

This is exactly what happens on every single turn:

**1. The phone is passed to the current player.**

The AppBar shows `"[Name]'s Turn"` with the player's colour dot. If sound is on, a soft whoosh plays when the turn changes.

**2. An Event Card is drawn automatically.**

At the very start of every turn, before the dice are even rolled, an Event Card appears in a bottom sheet sliding up. There are 10 different event cards (5 good, 5 bad). The card shows its emoji, title, description, and a coloured badge. The player reads it out to the group and taps "Apply" — the effect takes place immediately. Then the sheet closes.

**3. The player rolls the dice.**

They tap the dice widget. A shake animation plays and dice pip faces cycle rapidly through random values for 800ms. The final value settles with a bounce animation. A dice roll sound plays (`sounds/dice_roll.mp3`).

**Power Roll:** Every 5th roll across the entire game is a Power Roll. Two dice appear side by side. The player picks the one showing the higher number. A power-up chime plays.

**4. The player picks a token to move.**

Tokens that can legally move pulse with a glowing border. The player taps one. The token animates along the path to its new position (one square at a time, 80ms per square, with a tick sound per step — exactly like Ludo King). If no token can legally move (e.g. all at home and no 6 rolled), the turn passes automatically.

**5. Special square effects fire.**

Depending on what square the token landed on, one of the following happens:

- **Safe square (⭐):** Nothing — the token is safe.
- **Chaos Tile (🌀):** A full-screen popup slides up. A Truth or Dare prompt appears. The player reads it out loud and either does it (tap "Done ✓") or refuses (tap "Refuse — go back 6"). A chaos sting sound plays.
- **Wormhole (🌀 cyan):** The token teleports instantly to the linked wormhole square. A teleport whoosh plays. The direction flips after each use.
- **Jail (🔒):** The token is jailed for 2 turns. A jail clank sound plays. The token shows bar lines on top of it. Each turn the jail counter ticks down. Another player who lands on the same square bails them out — both are freed with a cheer sound.
- **Gift Square (🎁):** The player picks any one of their tokens and it moves forward 6 spaces instantly. A gift chime plays.
- **Opponent token on same square:** If the landing square is not a safe square and another player's token is there, that token is sent back to the home zone. A sending-home sound plays. The attacker gains **+10 points**. If the sent-home token is Cursed, the owner loses **−10 points** and the curse reveal animation plays.

**6. Bounty is checked.**

After every move, the game checks if any player has a score lead of 30+ points over the average. If so, a bounty is placed on that player. A bounty badge appears next to their name in the AppBar, pulsing gold. Any player who sends a bounty player's token home gets **+25 bonus points** on top of the normal +10.

**7. Speed Round is checked.**

When only 2 or fewer tokens are still on the main path (across all players combined), Speed Round activates. A flashing overlay announces it. From this point on, every player has **5 seconds** to roll the dice. A circular countdown arc appears around the dice widget. If they don't roll in time, the turn is skipped automatically.

**8. King's Rule check.**

When any player gets their **first token** to reach the centre, they become King for one round. A king crown popup slides in and they type a custom rule (max 60 characters) — e.g. "everyone must speak in a British accent for the next 3 turns". The rule is shown in the AppBar for the duration. A fanfare sound plays.

**9. Turn advances.**

The turn indicator animates to the next player. The phone is passed.

---

### Winning

The first player to get **all 4 tokens** to the centre triangle wins the game. The result screen shows a podium with all player scores, special awards, and two buttons — "Play Again" and "Home".

**Scoring summary:**

| Action | Points |
|---|---|
| Token reaches centre | +50 |
| Sending an opponent home | +10 |
| Bounty capture | +25 bonus |
| Refused Chaos Tile (own) | −0 (goes back 6, no point change) |
| Cursed token sent home | −10 from owner |
| Event Card: Tax Collector | −10 |
| Event Card: Pickpocket | +10 (stolen from leader) |

---

### All 13 Chaos Features — Full Detail

**1. Chaos Tiles** — 4 squares on the board (positions 5, 18, 31, 44) glow purple and show a 🌀 icon. Landing here triggers a Truth or Dare popup pulled from the existing Cousin Chaos prompt data (`kChaosTruths` / `kChaosDares` lists in `ludo_data.dart`). Completing it costs nothing. Refusing sends the token back 6 spaces (wrapping around 0 if needed) and plays a fail sound.

**2. Sabotage Cards** — Each player starts with **2 sabotage cards**. They can play one on any turn by tapping the sabotage button in the controls area. A bottom sheet opens showing 3 options: **Freeze** (target skips next turn), **Send Back 5** (pick one of their tokens, it moves back 5 squares), **Block Home Entry** (their tokens cannot enter the home column for 2 turns). The Armored token personality blocks all sabotage. The card count badge decrements. A sabotage zap sound plays.

**3. Power Dice** — Every 5th dice roll across the whole game (tracked in `LudoGameState.totalRollCount`) shows two dice. The player picks the higher value. A power chime plays. The player cannot pick the lower value — it is shown greyed out after they tap the higher one.

**4. Bounty System** — When any player's score is 30+ above the group average, a golden 💰 bounty badge appears on their name in the AppBar. A bounty announcement sound plays once. Any player who sends one of the bounty player's tokens home collects +25 bonus points. The bounty is lifted when the score gap drops below 30.

**5. Event Cards** — At the start of every turn, one of 10 event cards is drawn at random. Good cards: Lucky Break (+3 move on any token), Double Up (extra roll), Pickpocket (steal 10 pts from leader), Get Out of Jail (free from jail), Force Field (immune to being sent home next turn). Bad cards: Setback (furthest token back 6), Freeze Up (lose next turn), Tax Collector (−10 pts), Paralysed (no tokens move this turn), Charity (give 10 pts to last place). Cards are drawn from a shuffled deck that resets when exhausted.

**6. Token Personalities** — Assigned randomly at game start. Each player gets one of each (Swift, Armored, Lucky, Phantom) distributed across their 4 tokens. The setup screen shows a collapsible info card explaining personalities. During the game, a small emoji is shown under each token. The Phantom token gets a ghost trail animation when it passes the jail square. The Lucky token gets a sparkle burst on every 6.

**7. Wormhole Squares** — Square 3 (Wormhole A) and square 29 (Wormhole B) are linked. Landing on either one teleports the token to the other. After each use, the direction flips (so next player to land on A goes to B, then B goes to A, etc.). Both squares glow cyan with a rotating vortex overlay. A teleport whoosh plays.

**8. Jail Square** — Square 42 shows a red 🔒 overlay. Landing here (unless the token has Phantom personality) sets `jailTurnsRemaining = 2`. The token cannot move for 2 turns. Each turn a tick-down clank plays. If another player's token lands on the exact same square while you are jailed, both tokens are freed and the landing player skips their jail sentence too. A bail-out cheer plays.

**9. King's Roll** — The first time any player's token reaches the centre, that player becomes King. A crown popup appears and they type a rule into a `TextField`. The rule is stored in `LudoGameState.kingsRuleText` and shown in the AppBar subtitle for all future turns. Only one King per game — once the rule expires (after 3 full rounds) the crown is removed.

**10. Cursed Token** — At `createGame()`, one token per player is randomly marked `isCursed = true`. This is hidden from all players — the token looks identical to others. When an opponent sends it home, a skull reveal animation plays, `isCursed` is set to visible, and the owning player loses −10 points. The curse is shown permanently from that point on (skull overlay on the token).

**11. Swap Trap** — Each player has one Swap Trap to use per game. Tap the swap button to enter swap mode. The player then taps two tokens anywhere on the board (can be their own, an opponent's, or one of each). Their board positions are instantly swapped. The swap button disappears after use. A whoosh + pop sound plays.

**12. Speed Round** — When total active tokens on the main path drops to 2 or fewer, Speed Round activates. An overlay slides down from the top: "⚡ SPEED ROUND". From this point every dice roll has a 5-second countdown arc drawn around the dice widget (like a ring timer). Fail to tap in time = turn forfeited. A speed round fanfare plays once on activation.

**13. Gift Square** — Square 16 shows a green 🎁 overlay. Landing here opens a token picker. The player taps any one of their tokens (including ones still in the home zone — this is the only way to get a bonus before rolling a 6). That token moves forward 6 squares. A gift chime plays.

---

## SOUND EFFECTS — LUDO KING STYLE

The game uses the existing `SoundService` and `audioplayers` package (already in `pubspec.yaml`). New sound events are added to `SoundEvent` enum and new audio files are added to `assets/sounds/`.

### New SoundEvent entries to add to `sound_service.dart`

```dart
enum SoundEvent {
  // ... existing events ...

  // Ludo-specific
  ludoDiceRoll,        // dice shake + settle
  ludoTokenMove,       // single step tick (played per square moved)
  ludoTokenEnter,      // token placed on board from home zone
  ludoTokenHome,       // token reaches centre (finish)
  ludoTokenSentHome,   // opponent's token is sent back
  ludoChaosTitle,      // chaos tile landing sting
  ludoJailEnter,       // token sent to jail
  ludoJailFree,        // token freed from jail
  ludoGiftSquare,      // gift square landing chime
  ludoWormhole,        // wormhole teleport whoosh
  ludoSabotage,        // sabotage card played
  ludoPowerRoll,       // power roll activation chime
  ludoBountySet,       // bounty placed on a player
  ludoBountyCapture,   // bounty collected
  ludoKingCrown,       // king crowned fanfare
  ludoCurseReveal,     // cursed token revealed
  ludoSpeedRound,      // speed round activation
  ludoSwapTrap,        // swap trap used
  ludoEventGood,       // good event card drawn
  ludoEventBad,        // bad event card drawn
  ludoWin,             // game winner screen
}
```

### New asset map entries

```dart
static const Map<SoundEvent, String> _assetMap = {
  // ... existing entries ...

  SoundEvent.ludoDiceRoll:     'sounds/ludo_dice_roll.mp3',
  SoundEvent.ludoTokenMove:    'sounds/ludo_token_step.mp3',
  SoundEvent.ludoTokenEnter:   'sounds/ludo_enter.mp3',
  SoundEvent.ludoTokenHome:    'sounds/ludo_finish.mp3',
  SoundEvent.ludoTokenSentHome:'sounds/ludo_sent_home.mp3',
  SoundEvent.ludoChaosTitle:   'sounds/ludo_chaos_sting.mp3',
  SoundEvent.ludoJailEnter:    'sounds/ludo_jail.mp3',
  SoundEvent.ludoJailFree:     'sounds/ludo_jail_free.mp3',
  SoundEvent.ludoGiftSquare:   'sounds/ludo_gift.mp3',
  SoundEvent.ludoWormhole:     'sounds/ludo_wormhole.mp3',
  SoundEvent.ludoSabotage:     'sounds/ludo_sabotage.mp3',
  SoundEvent.ludoPowerRoll:    'sounds/ludo_power.mp3',
  SoundEvent.ludoBountySet:    'sounds/ludo_bounty.mp3',
  SoundEvent.ludoBountyCapture:'sounds/ludo_bounty_capture.mp3',
  SoundEvent.ludoKingCrown:    'sounds/ludo_king.mp3',
  SoundEvent.ludoCurseReveal:  'sounds/ludo_curse.mp3',
  SoundEvent.ludoSpeedRound:   'sounds/ludo_speed_round.mp3',
  SoundEvent.ludoSwapTrap:     'sounds/ludo_swap.mp3',
  SoundEvent.ludoEventGood:    'sounds/ludo_event_good.mp3',
  SoundEvent.ludoEventBad:     'sounds/ludo_event_bad.mp3',
  SoundEvent.ludoWin:          'sounds/ludo_win.mp3',
};
```

### Sound files to source (free licence)

All files below are freely available from freesound.org, mixkit.co, or pixabay.com. Download, rename, and place in `assets/sounds/`.

| File | Description | Suggested search term |
|---|---|---|
| `ludo_dice_roll.mp3` | Rattling dice shake then settle — 1 second | "dice roll board game" |
| `ludo_token_step.mp3` | Short plastic click — 0.1 seconds | "board game piece click" |
| `ludo_enter.mp3` | Satisfying pop — token enters board | "pop cork soft" |
| `ludo_finish.mp3` | Short triumphant chime — token reaches home | "success chime short" |
| `ludo_sent_home.mp3` | Comic descending whoosh | "cartoon fall whoosh" |
| `ludo_chaos_sting.mp3` | Eerie synth sting — 1 second | "game chaos sting" |
| `ludo_jail.mp3` | Metal clank / bars | "metal door clank" |
| `ludo_jail_free.mp3` | Light chime | "freedom bell chime" |
| `ludo_gift.mp3` | Sparkle chime ascending | "gift sparkle chime" |
| `ludo_wormhole.mp3` | Sci-fi teleport whoosh | "teleport sci-fi whoosh" |
| `ludo_sabotage.mp3` | Electric zap | "electric zap short" |
| `ludo_power.mp3` | Power-up ascending synth | "power up game sound" |
| `ludo_bounty.mp3` | Western-style coin clink | "coin clink western" |
| `ludo_bounty_capture.mp3` | Cash register + cheer | "cash register win" |
| `ludo_king.mp3` | Short royal fanfare — trumpet | "royal fanfare short" |
| `ludo_curse.mp3` | Horror sting — low drone | "horror sting short" |
| `ludo_speed_round.mp3` | Urgent alarm beep sequence | "alarm beep urgent game" |
| `ludo_swap.mp3` | Whoosh + pop | "whoosh pop swap" |
| `ludo_event_good.mp3` | Positive sparkle | "sparkle positive ui" |
| `ludo_event_bad.mp3` | Negative buzz | "negative buzz game" |
| `ludo_win.mp3` | Full victory fanfare — 3 seconds | "victory fanfare game win" |

### `pubspec.yaml` — add sound assets

```yaml
flutter:
  assets:
    - assets/sounds/ludo_dice_roll.mp3
    - assets/sounds/ludo_token_step.mp3
    - assets/sounds/ludo_enter.mp3
    - assets/sounds/ludo_finish.mp3
    - assets/sounds/ludo_sent_home.mp3
    - assets/sounds/ludo_chaos_sting.mp3
    - assets/sounds/ludo_jail.mp3
    - assets/sounds/ludo_jail_free.mp3
    - assets/sounds/ludo_gift.mp3
    - assets/sounds/ludo_wormhole.mp3
    - assets/sounds/ludo_sabotage.mp3
    - assets/sounds/ludo_power.mp3
    - assets/sounds/ludo_bounty.mp3
    - assets/sounds/ludo_bounty_capture.mp3
    - assets/sounds/ludo_king.mp3
    - assets/sounds/ludo_curse.mp3
    - assets/sounds/ludo_speed_round.mp3
    - assets/sounds/ludo_swap.mp3
    - assets/sounds/ludo_event_good.mp3
    - assets/sounds/ludo_event_bad.mp3
    - assets/sounds/ludo_win.mp3
```

### How sounds are called in code

Always read `soundEnabled` from `PreferencesService` via `context.read<PreferencesService>().soundEnabled` before calling `SoundService.instance.play()`. Never call play directly without checking this flag.

```dart
// Example — dice roll
final soundEnabled = context.read<PreferencesService>().soundEnabled;
await SoundService.instance.play(SoundEvent.ludoDiceRoll, soundEnabled: soundEnabled);

// Example — token step (plays once per square during animation loop)
for (int step = 0; step < stepsToMove; step++) {
  await Future.delayed(const Duration(milliseconds: 80));
  setState(() => token.pathPosition++);
  SoundService.instance.play(SoundEvent.ludoTokenMove, soundEnabled: soundEnabled);
}
```

### Token movement sound loop — exactly like Ludo King

Ludo King plays one short click per square as the token slides. Implement this by animating movement one square at a time with an 80ms delay between steps. Play `ludoTokenMove` once per step. This produces the satisfying click-click-click rhythm players expect.

```dart
Future<void> _animateTokenMovement(LudoToken token, int steps) async {
  final soundEnabled = context.read<PreferencesService>().soundEnabled;
  final hapticsEnabled = context.read<PreferencesService>().hapticsEnabled;

  for (int i = 0; i < steps; i++) {
    await Future.delayed(const Duration(milliseconds: 80));
    setState(() {
      token.pathPosition = (token.pathPosition + 1) % 52;
    });
    SoundService.instance.play(SoundEvent.ludoTokenMove, soundEnabled: soundEnabled);
    if (i % 3 == 0) { // haptic every 3rd step — not every step, too much
      HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: hapticsEnabled);
    }
  }

  // After movement — check landing square and play appropriate sound
  _handleLandingSquare(token);
}
```

---

## NEW FILES TO CREATE

```
lib/
  screens/
    ludo/
      ludo_setup_screen.dart          ← player count + name entry
      ludo_board_screen.dart          ← main game screen
      ludo_result_screen.dart         ← winner podium + scores
      widgets/
        ludo_board_painter.dart       ← CustomPainter — draws the entire board
        ludo_token_widget.dart        ← single animated token piece
        ludo_dice_widget.dart         ← animated dice with pip faces
        chaos_tile_popup.dart         ← full-screen Truth or Dare overlay
        event_card_sheet.dart         ← bottom sheet event card reveal
        sabotage_sheet.dart           ← sabotage type + target picker
        kings_rule_sheet.dart         ← king types their rule
        speed_round_overlay.dart      ← speed round announcement
        bounty_banner.dart            ← pulsing bounty badge widget
        scoreboard_sheet.dart         ← mid-game scoreboard bottom sheet
  core/
    models/
      ludo_token.dart                 ← single token model
      ludo_player.dart                ← player model with tokens + chaos state
      ludo_event_card.dart            ← event card model
      ludo_game_state.dart            ← full serialisable game state
  services/
    ludo_game_service.dart            ← all game logic, zero UI
  core/
    constants/
      ludo_data.dart                  ← board path, special squares, all data
```

---

## FILE: `lib/core/constants/ludo_data.dart`

### Board path

The main path is 52 `(col, row)` grid positions indexed 0–51. Position 0 is Blue's entry. Clockwise.

```dart
/// Each element is [col, row] on the 15×15 grid (0-indexed from top-left)
const List<List<int>> kLudoMainPath = [
  // Left column — going up (Blue side)
  [6,14],[6,13],[6,12],[6,11],[6,10],[6,9],   // 0–5  (5 = Chaos Tile)
  [6,8], [5,8], [4,8], [3,8], [2,8], [1,8],  // 6–11
  [0,8],                                       // 12
  // Top row — going right (Red side)
  [0,6], [1,6], [2,6], [3,6], [4,6], [5,6],  // 13–18 (18 = Chaos Tile)
  [6,6],                                       // 19
  // Right column — going down (Green side)
  [6,5], [6,4], [6,3], [6,2], [6,1], [6,0],  // 20–25
  [8,0], [8,1], [8,2], [8,3], [8,4], [8,5],  // 26–31 (31 = Chaos Tile)
  [8,6],                                       // 32
  // Bottom row — going left (Yellow side)
  [8,8],[9,8],[10,8],[11,8],[12,8],[13,8],    // 33–38
  [14,8],                                      // 39
  [14,6],[13,6],[12,6],[11,6],[10,6],[9,6],   // 40–45
  [8,6],                                       // 46
  // Return to Blue entry side
  [8,9],[8,10],[8,11],[8,12],[8,13],[8,14],   // 47–52 (wraps to 0)
];

/// Home column paths — 6 squares each leading into the centre
const List<List<int>> kBlueHomeCol   = [[7,13],[7,12],[7,11],[7,10],[7,9],[7,8]];
const List<List<int>> kRedHomeCol    = [[1,7],[2,7],[3,7],[4,7],[5,7],[6,7]];
const List<List<int>> kGreenHomeCol  = [[13,7],[12,7],[11,7],[10,7],[9,7],[8,7]];
const List<List<int>> kYellowHomeCol = [[7,1],[7,2],[7,3],[7,4],[7,5],[7,6]];

/// Entry squares — index on kLudoMainPath where each player enters
const List<int> kPlayerEntrySquares  = [0, 13, 26, 39];

/// Home column entry — when token passes this index, it enters home column
const List<int> kHomeColEntry        = [51, 12, 25, 38];

/// Safe squares — star squares, cannot be attacked here
const Set<int> kSafeSquares          = {0, 8, 13, 21, 26, 34, 39, 47};

/// Special squares
const Set<int> kChaosTiles           = {5, 18, 31, 44};
const int kWormholeA                 = 3;
const int kWormholeB                 = 29;
const int kJailSquare                = 42;
const int kGiftSquare                = 16;
```

### Truth and Dare prompts for Chaos Tiles

```dart
const List<String> kLudoChaosTruths = [
  'Who in this game would you trust least with your phone password?',
  'What is the most embarrassing thing that has happened to you this year?',
  'Have you ever blamed someone else for something you did?',
  'What is something you have lied about to a family member recently?',
  'Who in this room would you call first in a real emergency?',
  'What is the worst gift you have ever received — and who gave it?',
  'Have you ever cheated in a game before today?',
  'What is something you pretend to enjoy but secretly cannot stand?',
  'Who here do you think secretly dislikes you?',
  'What is the most money you have spent on something embarrassing?',
];

const List<String> kLudoChaosDares = [
  'Do your best impression of another player in this game right now.',
  'Sing the first 10 seconds of any song chosen by the group.',
  'Let the player to your left scroll your camera roll for 10 seconds.',
  'Text someone "we need to talk" and show the group their reply.',
  'Speak in an accent chosen by the group for the next 2 turns.',
  'Do 10 push-ups right now or go back 6 extra spaces.',
  'Swap seats with any player for the rest of this round.',
  'Let any player post one thing to your Instagram story right now.',
];
```

### Event cards data

```dart
const List<Map<String, dynamic>> kEventCardsData = [
  // Good
  {
    'emoji': '🍀',
    'title': 'Lucky Break',
    'desc': 'Move any one of your tokens forward 3 spaces.',
    'effect': 'moveForward3',
    'isGood': true,
  },
  {
    'emoji': '🎲',
    'title': 'Double Up',
    'desc': 'Roll the dice again — you get an extra move this turn.',
    'effect': 'extraRoll',
    'isGood': true,
  },
  {
    'emoji': '🤑',
    'title': 'Pickpocket',
    'desc': 'Steal 10 points from the player currently in the lead.',
    'effect': 'stealPoints10',
    'isGood': true,
  },
  {
    'emoji': '🗝️',
    'title': 'Get Out of Jail',
    'desc': 'Freed from jail immediately. No effect if not jailed.',
    'effect': 'freeJail',
    'isGood': true,
  },
  {
    'emoji': '🛡️',
    'title': 'Force Field',
    'desc': 'Your tokens cannot be sent home on the next turn.',
    'effect': 'immune',
    'isGood': true,
  },
  // Bad
  {
    'emoji': '💀',
    'title': 'Setback',
    'desc': 'Your furthest token goes back 6 spaces. Ouch.',
    'effect': 'fastestBack6',
    'isGood': false,
  },
  {
    'emoji': '🥶',
    'title': 'Freeze Up',
    'desc': 'You lose your next turn.',
    'effect': 'skipNext',
    'isGood': false,
  },
  {
    'emoji': '💸',
    'title': 'Tax Collector',
    'desc': 'Lose 10 points from your score.',
    'effect': 'losePoints10',
    'isGood': false,
  },
  {
    'emoji': '😱',
    'title': 'Paralysed',
    'desc': 'None of your tokens can move this turn.',
    'effect': 'noMove',
    'isGood': false,
  },
  {
    'emoji': '🎁',
    'title': 'Charity',
    'desc': 'Give 10 of your points to the last-place player.',
    'effect': 'givePoints10',
    'isGood': false,
  },
];
```

---

## FILE: `lib/core/models/ludo_token.dart`

```dart
enum TokenPersonality { swift, armored, lucky, phantom }
enum TokenState { home, active, safe, finished }

class LudoToken {
  final String id;           // e.g. "blue_0"
  final int playerIndex;     // 0=blue 1=red 2=green 3=yellow
  final int tokenIndex;      // 0–3 within the player
  final TokenPersonality personality;

  int pathPosition;          // 0–57: 0–51 = main path, 52–57 = home column
                             // -1 = still in home zone (not on board)
  TokenState state;
  bool isCursed;             // set secretly at game start
  bool curseRevealed;        // becomes true when curse triggers
  int jailTurnsRemaining;    // 0 = free
  bool isImmune;             // true = cannot be sent home this turn (Force Field)

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
}
```

---

## FILE: `lib/core/models/ludo_player.dart`

```dart
import 'ludo_token.dart';

class LudoPlayer {
  final int index;        // 0=blue 1=red 2=green 3=yellow
  final String name;
  final List<LudoToken> tokens;

  int score;
  int sabotageCardsLeft;  // starts at 2
  bool swapTrapUsed;
  bool hasKingsRule;
  int rollCount;          // this player's personal roll count
  int homeEntryBlockedTurns;  // sabotage block counter
  bool hasBounty;
  bool skipNextTurn;      // set by Freeze Up event card
  bool immuneNextTurn;    // set by Force Field event card

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
  });

  static const List<String> colorNames = ['Blue', 'Red', 'Green', 'Yellow'];
  String get colorName => colorNames[index];

  int get finishedCount => tokens.where((t) => t.isFinished).length;
  bool get allFinished  => tokens.every((t) => t.isFinished);
}
```

---

## FILE: `lib/core/models/ludo_game_state.dart`

```dart
import 'ludo_player.dart';

enum LudoPhase {
  rolling,        // current player must roll
  choosingToken,  // rolled — pick a token to move
  animating,      // token is mid-animation — no input accepted
  chaosPrompt,    // chaos tile popup is showing
  eventCard,      // event card bottom sheet is showing
  giftPicker,     // player picking which token gets the +6
  kingsRule,      // king typing their rule
  sabotageSelect, // player choosing sabotage type + target
  swapSelect,     // player tapping two tokens to swap
  speedRoll,      // speed round — 5s timer active
  finished,       // game over
}

class LudoGameState {
  final List<LudoPlayer> players;
  int currentPlayerIndex;
  LudoPhase phase;

  int lastDiceValue;
  int? lastDiceValue2;       // second dice (Power Roll only)
  bool isPowerRoll;

  int totalRollCount;        // across all players — triggers Power Roll at every 5th
  bool speedRoundActive;
  bool wormholeAtoB;         // direction of wormhole — flips after each use

  int? bountyPlayerIndex;    // null = no bounty
  String? kingsRuleText;     // null = no king rule active
  int kingsRuleTurnsLeft;    // counts down — rule expires at 0

  List<int> finishOrder;     // playerIndex order of finishing
  List<Map<String, dynamic>> eventCardDeck; // shuffled deck, drawn from top

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
    this.finishOrder = const [],
    this.eventCardDeck = const [],
  });

  LudoPlayer get currentPlayer => players[currentPlayerIndex];

  int get activeTokensOnBoard => players
      .expand((p) => p.tokens)
      .where((t) => t.isOnBoard)
      .length;
}
```

---

## FILE: `lib/services/ludo_game_service.dart`

This file contains 100% of the game rules. No game logic anywhere else.

```dart
import 'dart:math';
import '../core/models/ludo_game_state.dart';
import '../core/models/ludo_player.dart';
import '../core/models/ludo_token.dart';
import '../core/constants/ludo_data.dart';

class LudoGameService {
  static final LudoGameService instance = LudoGameService._();
  LudoGameService._();

  final _rng = Random.secure();

  // ── Initialisation ─────────────────────────────────────────────────────────

  LudoGameState createGame(List<String> playerNames) {
    final players = <LudoPlayer>[];

    for (int i = 0; i < playerNames.length; i++) {
      // Distribute one of each personality across the 4 tokens
      final personalities = TokenPersonality.values.toList()..shuffle(_rng);
      final tokens = List.generate(4, (j) => LudoToken(
        id: '${LudoPlayer.colorNames[i].toLowerCase()}_$j',
        playerIndex: i,
        tokenIndex: j,
        personality: personalities[j],
      ));

      // Curse exactly one token per player secretly
      tokens[_rng.nextInt(4)].isCursed = true;

      players.add(LudoPlayer(
        index: i,
        name: playerNames[i],
        tokens: tokens,
      ));
    }

    // Shuffle event card deck
    final deck = [...kEventCardsData]..shuffle(_rng);

    return LudoGameState(
      players: players,
      wormholeAtoB: _rng.nextBool(),
      eventCardDeck: deck,
    );
  }

  // ── Dice rolling ───────────────────────────────────────────────────────────

  /// Returns primary value, optional secondary (Power Roll), and isPowerRoll flag.
  ({int primary, int? secondary, bool isPowerRoll}) rollDice(LudoGameState state) {
    state.totalRollCount++;
    final isPower = state.totalRollCount % 5 == 0;
    final primary = 1 + _rng.nextInt(6);
    int? secondary = isPower ? (1 + _rng.nextInt(6)) : null;

    // Swift personality: guarantee highest value on the very first roll of the game
    if (state.totalRollCount == 1) {
      final cp = state.currentPlayer;
      final hasSwift = cp.tokens.any((t) => t.personality == TokenPersonality.swift);
      if (hasSwift) return (primary: 6, secondary: null, isPowerRoll: false);
    }

    return (primary: primary, secondary: secondary, isPowerRoll: isPower);
  }

  // ── Draw event card ────────────────────────────────────────────────────────

  Map<String, dynamic> drawEventCard(LudoGameState state) {
    if (state.eventCardDeck.isEmpty) {
      state.eventCardDeck = [...kEventCardsData]..shuffle(_rng);
    }
    final card = state.eventCardDeck.removeAt(0);
    return card;
  }

  // ── Apply event card ───────────────────────────────────────────────────────

  void applyEventCard(LudoGameState state, Map<String, dynamic> card) {
    final p = state.currentPlayer;
    switch (card['effect'] as String) {
      case 'moveForward3':
        // UI enters giftPicker phase — player picks which token
        state.phase = LudoPhase.giftPicker;
        break;
      case 'extraRoll':
        state.phase = LudoPhase.rolling; // give another roll
        break;
      case 'stealPoints10':
        final leader = _findLeader(state);
        if (leader.index != p.index) {
          leader.score -= 10;
          p.score += 10;
        }
        break;
      case 'freeJail':
        for (final t in p.tokens) { t.jailTurnsRemaining = 0; }
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
        p.score = max(0, p.score - 10);
        break;
      case 'noMove':
        // Handled in UI — turn ends with no move available
        break;
      case 'givePoints10':
        final last = _findLastPlace(state);
        p.score = max(0, p.score - 10);
        last.score += 10;
        break;
    }
  }

  // ── Move token ─────────────────────────────────────────────────────────────

  /// Returns a MoveResult describing what happened.
  /// The UI reads this and plays the appropriate sounds + animations.
  MoveResult moveToken(LudoGameState state, LudoToken token, int diceValue) {
    final player = state.players[token.playerIndex];

    // — Enter board from home zone —
    if (token.state == TokenState.home) {
      if (diceValue != 6) return MoveResult.cantMove;
      token.pathPosition = kPlayerEntrySquares[player.index];
      token.state = TokenState.active;
      _checkAttack(state, player, token);
      return MoveResult(
        type: MoveResultType.enteredBoard,
        bonusTurn: true,
        landing: token.pathPosition,
      );
    }

    // — Move along path —
    int newPos = token.pathPosition + diceValue;

    // Lucky personality +1 on every 6
    if (diceValue == 6 && token.personality == TokenPersonality.lucky) {
      newPos++;
    }

    final homeEntry = kHomeColEntry[player.index];

    // — Check home column entry —
    if (_passesHomeEntry(token.pathPosition, newPos, player.index)) {
      final overflow = newPos - homeEntry;
      if (overflow > 6) return MoveResult.cantMove; // overshoot — must not move
      if (player.homeEntryBlockedTurns > 0) {
        // Sabotage blocked entry — bounce back
        token.pathPosition = max(0, token.pathPosition - overflow);
        return MoveResult(type: MoveResultType.homeBlocked, landing: token.pathPosition);
      }
      token.pathPosition = 52 + overflow; // 52–57 = home column
      if (overflow == 6) {
        token.state = TokenState.finished;
        state.finishOrder = [...state.finishOrder, player.index];
        player.score += 50;
        _handleTokenFinished(state, player);
        return MoveResult(type: MoveResultType.reachedHome, bonusTurn: diceValue == 6, landing: token.pathPosition);
      }
      token.state = TokenState.safe;
      return MoveResult(type: MoveResultType.movedSafe, bonusTurn: diceValue == 6, landing: token.pathPosition);
    }

    // — Main path movement —
    newPos = newPos % 52;
    token.pathPosition = newPos;
    token.state = kSafeSquares.contains(newPos) ? TokenState.safe : TokenState.active;

    // — Special square checks —
    if (kChaosTiles.contains(newPos)) {
      state.phase = LudoPhase.chaosPrompt;
      return MoveResult(type: MoveResultType.chaosTile, bonusTurn: false, landing: newPos);
    }

    if (newPos == kWormholeA || newPos == kWormholeB) {
      final dest = state.wormholeAtoB
          ? (newPos == kWormholeA ? kWormholeB : kWormholeA)
          : (newPos == kWormholeA ? kWormholeB : kWormholeA);
      token.pathPosition = dest;
      state.wormholeAtoB = !state.wormholeAtoB;
      _checkAttack(state, player, token);
      return MoveResult(type: MoveResultType.wormhole, bonusTurn: diceValue == 6, landing: dest);
    }

    if (newPos == kJailSquare && token.personality != TokenPersonality.phantom) {
      // Check if another token is already jailed here — bail out both
      final alreadyJailed = _jailedTokenAt(state, newPos, player.index);
      if (alreadyJailed != null) {
        alreadyJailed.jailTurnsRemaining = 0;
        return MoveResult(type: MoveResultType.jailBailout, bonusTurn: diceValue == 6, landing: newPos);
      }
      token.jailTurnsRemaining = 2;
      return MoveResult(type: MoveResultType.jailed, bonusTurn: false, landing: newPos);
    }

    if (newPos == kGiftSquare) {
      state.phase = LudoPhase.giftPicker;
      return MoveResult(type: MoveResultType.giftSquare, bonusTurn: diceValue == 6, landing: newPos);
    }

    // — Attack check —
    final attacked = _checkAttack(state, player, token);

    _updateBounty(state);
    _checkSpeedRound(state);

    return MoveResult(
      type: attacked ? MoveResultType.attacked : MoveResultType.normal,
      bonusTurn: diceValue == 6,
      landing: newPos,
    );
  }

  // ── Chaos tile resolve ──────────────────────────────────────────────────────

  void resolveChaosTile(LudoGameState state, bool accepted) {
    if (!accepted) {
      final p = state.currentPlayer;
      for (final t in p.tokens) {
        if (kChaosTiles.contains(t.pathPosition)) {
          t.pathPosition = (t.pathPosition - 6 + 52) % 52;
          break;
        }
      }
    }
    _nextTurn(state);
  }

  // ── Gift square / Lucky Break event card resolve ───────────────────────────

  void resolveGiftPicker(LudoGameState state, int tokenIndex) {
    final p = state.currentPlayer;
    final t = p.tokens[tokenIndex];
    if (!t.isFinished) {
      if (t.state == TokenState.home) {
        // Gift from home — place on entry square (only legal entry without a 6)
        t.pathPosition = kPlayerEntrySquares[p.index];
        t.state = TokenState.active;
      } else {
        t.pathPosition = (t.pathPosition + 6) % 52;
      }
    }
    _nextTurn(state);
  }

  // ── Sabotage ────────────────────────────────────────────────────────────────

  enum SabotageType { freeze, sendBack5, blockHome }

  void playSabotage(
    LudoGameState state,
    int targetPlayerIndex,
    int? targetTokenIndex,
    SabotageType type,
  ) {
    final attacker = state.currentPlayer;
    if (attacker.sabotageCardsLeft <= 0) return;

    final target = state.players[targetPlayerIndex];

    // Check armored personality
    if (targetTokenIndex != null &&
        target.tokens[targetTokenIndex].personality == TokenPersonality.armored) {
      return; // blocked
    }

    attacker.sabotageCardsLeft--;

    switch (type) {
      case SabotageType.freeze:
        target.skipNextTurn = true;
        break;
      case SabotageType.sendBack5:
        if (targetTokenIndex != null) {
          final t = target.tokens[targetTokenIndex];
          if (t.isOnBoard) t.pathPosition = (t.pathPosition - 5 + 52) % 52;
        }
        break;
      case SabotageType.blockHome:
        target.homeEntryBlockedTurns = 2;
        break;
    }
  }

  // ── Swap trap ───────────────────────────────────────────────────────────────

  bool playSwapTrap(
    LudoGameState state,
    int pA, int tA,
    int pB, int tB,
  ) {
    final attacker = state.currentPlayer;
    if (attacker.swapTrapUsed) return false;

    final tokenA = state.players[pA].tokens[tA];
    final tokenB = state.players[pB].tokens[tB];
    if (!tokenA.isOnBoard || !tokenB.isOnBoard) return false;

    final tempPos = tokenA.pathPosition;
    final tempState = tokenA.state;
    tokenA.pathPosition = tokenB.pathPosition;
    tokenA.state = tokenB.state;
    tokenB.pathPosition = tempPos;
    tokenB.state = tempState;

    attacker.swapTrapUsed = true;
    return true;
  }

  // ── King's rule ─────────────────────────────────────────────────────────────

  void applyKingsRule(LudoGameState state, String rule) {
    state.kingsRuleText = rule;
    state.kingsRuleTurnsLeft = state.players.length * 3; // 3 full rounds
    state.phase = LudoPhase.rolling;
  }

  // ── Advance turn ────────────────────────────────────────────────────────────

  void _nextTurn(LudoGameState state, {bool bonusTurn = false}) {
    // Decrement blocked home entry
    for (final p in state.players) {
      if (p.homeEntryBlockedTurns > 0) p.homeEntryBlockedTurns--;
    }

    // Decrement jail
    for (final t in state.currentPlayer.tokens) {
      if (t.jailTurnsRemaining > 0) t.jailTurnsRemaining--;
    }

    // Decrement king rule counter
    if (state.kingsRuleTurnsLeft > 0) {
      state.kingsRuleTurnsLeft--;
      if (state.kingsRuleTurnsLeft == 0) state.kingsRuleText = null;
    }

    // Clear per-turn flags
    state.currentPlayer.immuneNextTurn = false;

    if (!bonusTurn) {
      int next = state.currentPlayerIndex;
      do {
        next = (next + 1) % state.players.length;
      } while (state.players[next].allFinished);
      state.currentPlayerIndex = next;
    }

    state.phase = LudoPhase.rolling;
    state.lastDiceValue2 = null;
    state.isPowerRoll = false;

    // Check game over (only one player left who hasn't finished)
    final remaining = state.players.where((p) => !p.allFinished).length;
    if (remaining <= 1) state.phase = LudoPhase.finished;
  }

  // ── Internal helpers ────────────────────────────────────────────────────────

  bool _passesHomeEntry(int from, int to, int playerIndex) {
    final entry = kHomeColEntry[playerIndex];
    return from <= entry && to > entry;
  }

  bool _checkAttack(LudoGameState state, LudoPlayer attacker, LudoToken attackerToken) {
    if (attackerToken.state == TokenState.safe) return false;
    bool attacked = false;
    for (final p in state.players) {
      if (p.index == attacker.index) continue;
      for (final t in p.tokens) {
        if (!t.isOnBoard || t.state == TokenState.safe) continue;
        if (t.pathPosition != attackerToken.pathPosition) continue;
        if (p.immuneNextTurn) continue; // Force Field protection
        // Send home
        final wasCursed = t.isCursed && !t.curseRevealed;
        t.pathPosition = -1;
        t.state = TokenState.home;
        t.jailTurnsRemaining = 0;
        if (wasCursed) {
          t.curseRevealed = true;
          p.score -= 10;
        }
        attacker.score += 10;
        // Bounty bonus
        if (p.hasBounty) {
          attacker.score += 25;
          p.hasBounty = false;
          state.bountyPlayerIndex = null;
        }
        attacked = true;
      }
    }
    return attacked;
  }

  LudoToken? _jailedTokenAt(LudoGameState state, int pos, int excludePlayer) {
    for (final p in state.players) {
      if (p.index == excludePlayer) continue;
      for (final t in p.tokens) {
        if (t.isOnBoard && t.pathPosition == pos && t.jailTurnsRemaining > 0) return t;
      }
    }
    return null;
  }

  void _handleTokenFinished(LudoGameState state, LudoPlayer player) {
    if (state.finishOrder.length == 1) {
      // First token to finish — becomes king
      player.hasKingsRule = true;
      state.phase = LudoPhase.kingsRule;
    }
  }

  void _updateBounty(LudoGameState state) {
    final scores = state.players.map((p) => p.score).toList();
    if (scores.isEmpty) return;
    final maxScore = scores.reduce(max);
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    if (maxScore - avg >= 30) {
      final leader = state.players.firstWhere((p) => p.score == maxScore);
      if (state.bountyPlayerIndex != leader.index) {
        for (final p in state.players) { p.hasBounty = false; }
        leader.hasBounty = true;
        state.bountyPlayerIndex = leader.index;
      }
    } else {
      for (final p in state.players) { p.hasBounty = false; }
      state.bountyPlayerIndex = null;
    }
  }

  void _checkSpeedRound(LudoGameState state) {
    if (!state.speedRoundActive && state.activeTokensOnBoard <= 2) {
      state.speedRoundActive = true;
    }
  }

  LudoPlayer _findLeader(LudoGameState state) =>
      state.players.reduce((a, b) => a.score >= b.score ? a : b);

  LudoPlayer _findLastPlace(LudoGameState state) =>
      state.players.reduce((a, b) => a.score <= b.score ? a : b);

  LudoToken? _fastestToken(LudoPlayer p) {
    final active = p.tokens.where((t) => t.isOnBoard).toList();
    if (active.isEmpty) return null;
    return active.reduce((a, b) => a.pathPosition >= b.pathPosition ? a : b);
  }
}

// ── Move result ────────────────────────────────────────────────────────────────

enum MoveResultType {
  normal, enteredBoard, attacked, chaosTile, wormhole,
  jailed, jailBailout, giftSquare, reachedHome, movedSafe,
  homeBlocked, cantMove,
}

class MoveResult {
  final MoveResultType type;
  final bool bonusTurn;
  final int landing;

  const MoveResult({
    required this.type,
    this.bonusTurn = false,
    this.landing = 0,
  });

  static const MoveResult cantMove = MoveResult(type: MoveResultType.cantMove);
}
```

---

## FILE: `lib/screens/ludo/ludo_setup_screen.dart`

**Purpose:** Player count selection + name entry. Entry point to the game.

**State:**
```dart
int _playerCount = 2;
final List<TextEditingController> _nameControllers =
    List.generate(4, (_) => TextEditingController());
bool _showPersonalities = false;
```

**UI (top to bottom):**

1. `Scaffold` with `AppColors.backgroundGradient` background
2. AppBar — `"Ludo Chaos 🎲"` title, standard back button
3. `SingleChildScrollView` body, `resizeToAvoidBottomInset: true` on Scaffold

**Player count row:**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [2, 3, 4].map((n) =>
    GestureDetector(
      onTap: () {
        setState(() => _playerCount = n);
        HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: prefs.hapticsEnabled);
        SoundService.instance.play(SoundEvent.tap, soundEnabled: prefs.soundEnabled);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: _playerCount == n
              ? _playerColour(n - 2).withAlpha(30)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _playerCount == n
                ? _playerColour(n - 2)
                : AppColors.outlineVariant,
            width: 2,
          ),
        ),
        child: Text('$n Players', style: GoogleFonts.poppins(
          color: _playerCount == n ? _playerColour(n - 2) : AppColors.textMuted,
          fontWeight: FontWeight.w700,
        )),
      ),
    )
  ).toList(),
)
```

**Name fields:**
Only show `_playerCount` fields. Each field has:
- A coloured avatar circle with the player's colour (Blue, Red, Green, Yellow)
- `TextFormField` with hint `"Player name"`, `maxLength: 15`, `textCapitalization: words`
- Focus border in the player's colour

**Token personalities info (collapsible):**
```dart
GestureDetector(
  onTap: () => setState(() => _showPersonalities = !_showPersonalities),
  child: GlassCard(
    child: Row(children: [
      Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
      SizedBox(width: 10),
      Expanded(child: Text('Personalities are randomly assigned at game start')),
      Icon(_showPersonalities ? Icons.expand_less : Icons.expand_more),
    ]),
  ),
)
if (_showPersonalities)
  Column(children: [
    for (final p in TokenPersonality.values)
      GlassCard(
        margin: EdgeInsets.only(top: 8),
        child: Row(children: [
          Text(LudoToken.personalityEmoji(p), style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_personalityName(p), style: /* bold */),
            Text(_personalityDesc(p), style: /* muted 12px */),
          ]),
        ]),
      ),
  ])
```

**Start button:**
```dart
ElevatedButton.icon(
  onPressed: _canStart ? _startGame : null,
  icon: Icon(Icons.casino_rounded),
  label: Text('Start Game'),
)

bool get _canStart => List.generate(_playerCount, (i) =>
    _nameControllers[i].text.trim().isNotEmpty).every((b) => b);

void _startGame() {
  final names = List.generate(
    _playerCount,
    (i) => _nameControllers[i].text.trim(),
  );
  final state = LudoGameService.instance.createGame(names);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => LudoBoardScreen(gameState: state)),
  );
}
```

---

## FILE: `lib/screens/ludo/widgets/ludo_board_painter.dart`

**Extends `CustomPainter`.** Repaints whenever `LudoGameState` changes.

**Constructor:**
```dart
class LudoBoardPainter extends CustomPainter {
  final LudoGameState state;
  const LudoBoardPainter({required this.state});
```

**`paint(Canvas canvas, Size size)` — draw order:**

1. **Board background** — fill entire size with `AppColors.background`
2. **Grid cells (path squares)** — iterate all 15×15 cells. Skip home zones and centre. Alternate fill between `AppColors.surfaceContainerLow` and `AppColors.surfaceContainerLowest`. Draw 0.5px border in `AppColors.outlineVariant`.
3. **Home zones** — draw each corner 6×6 block with player neon colour at 18% opacity, 2px neon border, inner 4×4 token area at 30% opacity, 4 token slot circles.
4. **Home columns** — draw each of the 4 home columns with player colour at 55% opacity.
5. **Centre triangle** — 4 triangular wedges meeting at centre, each player's colour at 85% opacity. Centre star in white.
6. **Safe square stars** — draw a 5-pointed star at each safe square position using a path. `AppColors.neonYellow` at 70% opacity.
7. **Chaos tile overlays** — for each chaos tile position: purple fill at 35% opacity, purple 1.5px border, draw `🌀` emoji in centre using `canvas.drawParagraph`.
8. **Wormhole overlays** — cyan fill at 20%, cyan 1.5px border, concentric circles.
9. **Jail overlay** — red fill at 20%, red border, lock icon emoji.
10. **Gift overlay** — green fill at 20%, green border, gift emoji.

**Emoji rendering in CustomPainter:**
```dart
void _drawEmoji(Canvas canvas, double cx, double cy, double size, String emoji) {
  final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center,
    fontSize: size,
  ))..addText(emoji);
  final para = pb.build()..layout(ui.ParagraphConstraints(width: size * 2));
  canvas.drawParagraph(para, Offset(cx - size, cy - size * 0.75));
}
```

**`shouldRepaint`:**
```dart
@override
bool shouldRepaint(LudoBoardPainter old) => true;
// Always repaint — state changes on every turn.
// For production, compare specific fields instead.
```

---

## FILE: `lib/screens/ludo/widgets/ludo_token_widget.dart`

**Purpose:** One animated token rendered as an `AnimatedPositioned` widget overlaid on the board.

**Position calculation:**
```dart
Offset _tokenOffset(LudoToken token, double cellSize) {
  if (token.state == TokenState.home) {
    // 2×2 grid of slots inside the home zone
    final homeOrigins = [
      [0.0, 0.0], // Blue: top-left corner col 0 row 0
      [9.0, 0.0], // Red: top-right
      [0.0, 9.0], // Yellow: bottom-left
      [9.0, 9.0], // Green: bottom-right
    ];
    final slotOffsets = [
      Offset(1.5, 1.5), Offset(3.0, 1.5),
      Offset(1.5, 3.0), Offset(3.0, 3.0),
    ];
    final origin = homeOrigins[token.playerIndex];
    final slot = slotOffsets[token.tokenIndex];
    return Offset(
      (origin[0] + slot.dx) * cellSize,
      (origin[1] + slot.dy) * cellSize,
    );
  }
  if (token.pathPosition >= 52) {
    final colIndex = token.pathPosition - 52;
    final cols = [kBlueHomeCol, kRedHomeCol, kGreenHomeCol, kYellowHomeCol];
    final sq = cols[token.playerIndex][colIndex];
    return Offset(sq[0] * cellSize + cellSize * 0.1 * token.tokenIndex,
                  sq[1] * cellSize + cellSize * 0.1 * token.tokenIndex);
  }
  final sq = kLudoMainPath[token.pathPosition];
  // Slight offset per tokenIndex so stacked tokens don't overlap exactly
  final offsets = [Offset(0,0), Offset(0.4,0), Offset(0,0.4), Offset(0.4,0.4)];
  return Offset(
    sq[0] * cellSize + offsets[token.tokenIndex].dx * cellSize,
    sq[1] * cellSize + offsets[token.tokenIndex].dy * cellSize,
  );
}
```

**Visual:**
```dart
Widget build(BuildContext context) {
  final color = _playerNeonColor(token.playerIndex);
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 150),
      width: cellSize * 0.75,
      height: cellSize * 0.75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(220),
        border: Border.all(
          color: isSelectable ? Colors.white : color.withAlpha(120),
          width: isSelectable ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(isSelectable ? 160 : 60),
            blurRadius: isSelectable ? 14 : 6,
            spreadRadius: isSelectable ? 3 : 0,
          ),
        ],
      ),
      child: Stack(alignment: Alignment.center, children: [
        // Token letter (B/R/G/Y)
        Text(
          LudoPlayer.colorNames[token.playerIndex][0],
          style: GoogleFonts.poppins(
            fontSize: cellSize * 0.3,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        // Personality emoji — tiny, bottom-right
        Positioned(
          bottom: 0, right: 0,
          child: Text(
            LudoToken.personalityEmoji(token.personality),
            style: TextStyle(fontSize: cellSize * 0.22),
          ),
        ),
        // Jail bars overlay
        if (token.isInJail)
          Positioned.fill(
            child: CustomPaint(painter: _JailBarsPainter()),
          ),
        // Curse skull — only after revealed
        if (token.curseRevealed)
          Positioned(
            top: 0, left: 0,
            child: Text('💀', style: TextStyle(fontSize: cellSize * 0.2)),
          ),
      ]),
    ),
  );
}
```

---

## FILE: `lib/screens/ludo/widgets/ludo_dice_widget.dart`

**Purpose:** Animated dice with pip faces, roll animation, and speed round countdown ring.

**State:**
```dart
late AnimationController _rollController;
late AnimationController _speedController;  // 0–1 over 5 seconds
int _displayValue = 1;
Timer? _cycleTimer;
```

**Roll animation:**
- On `isRolling = true`: start `Timer.periodic(80ms)` cycling `_displayValue` through random 1–6 values
- Simultaneously play `_rollController` for a shake effect (`sin(t * pi * 8) * 4px` horizontal offset)
- At 800ms: cancel timer, set `_displayValue = finalValue`, play bounce settle using `ElasticOutCurve`

**Dice face — pip painter:**
```dart
class _DiceFacePainter extends CustomPainter {
  final int value;
  final Color pipColor;

  // Pip positions for each face value (as fractions of the die size)
  static const Map<int, List<Offset>> _pipPositions = {
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.25, 0.25), Offset(0.75, 0.75)],
    3: [Offset(0.25, 0.25), Offset(0.5, 0.5), Offset(0.75, 0.75)],
    4: [Offset(0.25,0.25), Offset(0.75,0.25), Offset(0.25,0.75), Offset(0.75,0.75)],
    5: [Offset(0.25,0.25), Offset(0.75,0.25), Offset(0.5,0.5), Offset(0.25,0.75), Offset(0.75,0.75)],
    6: [Offset(0.25,0.2), Offset(0.75,0.2), Offset(0.25,0.5), Offset(0.75,0.5), Offset(0.25,0.8), Offset(0.75,0.8)],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final positions = _pipPositions[value] ?? [];
    final pipRadius = size.width * 0.09;
    for (final pos in positions) {
      canvas.drawCircle(
        Offset(pos.dx * size.width, pos.dy * size.height),
        pipRadius,
        Paint()..color = pipColor,
      );
    }
  }

  @override
  bool shouldRepaint(_DiceFacePainter old) => old.value != value;
}
```

**Speed round ring:**
```dart
if (isSpeedRound && speedProgress != null)
  Positioned.fill(
    child: CustomPaint(
      painter: _CountdownRingPainter(
        progress: speedProgress!, // 1.0 = full, 0.0 = expired
        color: speedProgress! > 0.4 ? AppColors.neonGreen : AppColors.dareRed,
      ),
    ),
  ),
```

**Tap:**
- Tappable only when `onRoll != null` (i.e. it is this player's turn and phase is rolling)
- Grey overlay when disabled

---

## FILE: `lib/screens/ludo/ludo_board_screen.dart`

**Purpose:** Main game screen. Orchestrates all game logic calls, sounds, haptics, and overlays.

**Constructor:**
```dart
const LudoBoardScreen({super.key, required this.gameState});
final LudoGameState gameState;
```

**State:**
```dart
late LudoGameState _state;
bool _isDiceRolling = false;
bool _speedRoundShown = false;
Timer? _speedTimer;
double _speedProgress = 1.0;
int? _selectedPowerDice; // null = not choosing, 0 = chose primary, 1 = chose secondary
```

**AppBar:**
```dart
AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: /* PopScope back button */,
  title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _playerNeonColor(_state.currentPlayerIndex),
      )),
      SizedBox(width: 8),
      Text('${_state.currentPlayer.name}\'s Turn',
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
      if (_state.currentPlayer.hasBounty) ...[
        SizedBox(width: 8),
        BountyBanner(),
      ],
    ]),
    if (_state.kingsRuleText != null)
      Text('👑 "${_state.kingsRuleText}"',
        style: TextStyle(fontSize: 11, color: AppColors.neonYellow),
        maxLines: 1, overflow: TextOverflow.ellipsis),
  ]),
  actions: [
    IconButton(
      icon: Icon(Icons.leaderboard_rounded, color: AppColors.textMuted),
      onPressed: _showScoreboard,
    ),
  ],
)
```

**Board area:**
```dart
Expanded(
  flex: 6,
  child: InteractiveViewer(
    minScale: 0.8,
    maxScale: 3.0,
    child: AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final cellSize = constraints.maxWidth / 15;
          return Stack(children: [
            // Board
            CustomPaint(
              painter: LudoBoardPainter(state: _state),
              size: Size.infinite,
            ),
            // All tokens
            for (final player in _state.players)
              for (final token in player.tokens)
                AnimatedPositioned(
                  duration: Duration(milliseconds: 80),
                  left: _tokenOffset(token, cellSize).dx,
                  top: _tokenOffset(token, cellSize).dy,
                  child: LudoTokenWidget(
                    token: token,
                    cellSize: cellSize,
                    isSelectable: _isTokenSelectable(token),
                    onTap: _isTokenSelectable(token)
                        ? () => _onTokenTap(token)
                        : null,
                  ),
                ),
          ]);
        },
      ),
    ),
  ),
)
```

**Controls area (bottom):**
```dart
Expanded(
  flex: 4,
  child: GlassCard(
    margin: EdgeInsets.all(12),
    padding: EdgeInsets.all(16),
    child: Column(children: [
      // Score badges row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _state.players.map((p) => _buildScoreBadge(p)).toList(),
      ),
      SizedBox(height: 16),
      // Dice + action buttons row
      Row(children: [
        // Dice
        LudoDiceWidget(
          value: _state.lastDiceValue,
          value2: _state.lastDiceValue2,
          isRolling: _isDiceRolling,
          isPowerRoll: _state.isPowerRoll,
          isSpeedRound: _state.speedRoundActive,
          speedProgress: _speedProgress,
          onRoll: _state.phase == LudoPhase.rolling ? _onRollDice : null,
          onPickDice: _state.isPowerRoll ? _onPickPowerDice : null,
        ),
        Spacer(),
        // Sabotage
        if (_state.currentPlayer.sabotageCardsLeft > 0)
          _buildActionButton(
            icon: Icons.bolt_rounded,
            label: 'Sabotage\n×${_state.currentPlayer.sabotageCardsLeft}',
            color: AppColors.dareRed,
            onTap: _showSabotageSheet,
          ),
        SizedBox(width: 8),
        // Swap trap
        if (!_state.currentPlayer.swapTrapUsed)
          _buildActionButton(
            icon: Icons.swap_horiz_rounded,
            label: 'Swap\nTrap',
            color: AppColors.neonOrange,
            onTap: _enterSwapMode,
          ),
      ]),
    ]),
  ),
)
```

**`_onRollDice()`:**
```dart
Future<void> _onRollDice() async {
  final prefs = context.read<PreferencesService>();
  setState(() { _isDiceRolling = true; _state.phase = LudoPhase.animating; });

  // Sound
  await SoundService.instance.play(SoundEvent.ludoDiceRoll, soundEnabled: prefs.soundEnabled);
  await HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: prefs.hapticsEnabled);
  await Future.delayed(const Duration(milliseconds: 800));

  // Get result
  final result = LudoGameService.instance.rollDice(_state);
  setState(() {
    _isDiceRolling = false;
    _state.lastDiceValue = result.primary;
    _state.lastDiceValue2 = result.secondary;
    _state.isPowerRoll = result.isPowerRoll;
  });

  if (result.isPowerRoll) {
    await SoundService.instance.play(SoundEvent.ludoPowerRoll, soundEnabled: prefs.soundEnabled);
    await HapticService.instance.trigger(HapticEvent.win, hapticsEnabled: prefs.hapticsEnabled);
    // Wait for player to pick which dice value
    setState(() => _state.phase = LudoPhase.choosingToken);
    return;
  }

  // Draw event card
  final card = LudoGameService.instance.drawEventCard(_state);
  await _showEventCard(card);

  // Check if skip turn
  if (_state.currentPlayer.skipNextTurn) {
    _state.currentPlayer.skipNextTurn = false;
    _advanceTurn();
    return;
  }

  setState(() => _state.phase = LudoPhase.choosingToken);

  // Start speed round timer if active
  if (_state.speedRoundActive) _startSpeedTimer();
}
```

**`_onTokenTap(LudoToken token)`:**
```dart
void _onTokenTap(LudoToken token) {
  if (_state.phase != LudoPhase.choosingToken) return;
  final diceValue = _selectedPowerDice == null
      ? _state.lastDiceValue
      : (_selectedPowerDice == 0 ? _state.lastDiceValue : _state.lastDiceValue2!);

  _cancelSpeedTimer();
  final result = LudoGameService.instance.moveToken(_state, token, diceValue);
  _handleMoveResult(result, token);
}
```

**`_handleMoveResult()`:**
Every `MoveResultType` maps to specific sounds + haptics + next phase. Full mapping:

| MoveResultType | Sound | Haptic | Next action |
|---|---|---|---|
| `cantMove` | none | none | do nothing |
| `enteredBoard` | `ludoTokenEnter` | `gameStart` | animate to entry square |
| `normal` | `ludoTokenMove` × steps | `tap` × every 3rd | next turn |
| `attacked` | `ludoTokenSentHome` | `playerEliminated` | show attack flash, next turn |
| `chaosTile` | `ludoChaosTitle` | `cardReveal` | show `ChaosTilePopup` |
| `wormhole` | `ludoWormhole` | `cardReveal` | animate teleport |
| `jailed` | `ludoJailEnter` | `freeze` | next turn |
| `jailBailout` | `ludoJailFree` | `win` | animate bail-out |
| `giftSquare` | `ludoGiftSquare` | `cardReveal` | show gift picker |
| `reachedHome` | `ludoTokenHome` | `win` | confetti burst, next turn |
| `movedSafe` | `ludoTokenMove` × steps | none | next turn |
| `homeBlocked` | `ludoSabotage` | `freeze` | show blocked toast |

**Speed round timer:**
```dart
void _startSpeedTimer() {
  _speedProgress = 1.0;
  _speedTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
    setState(() => _speedProgress -= 0.02); // 5 seconds total
    if (_speedProgress <= 0) {
      _speedTimer?.cancel();
      // Time's up — forfeit turn
      _advanceTurn();
    }
  });
}

void _cancelSpeedTimer() {
  _speedTimer?.cancel();
  _speedProgress = 1.0;
}
```

**Back gesture — `PopScope`:**
```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, _) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: Text('Leave game?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Current game progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Stay')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Leave', style: TextStyle(color: AppColors.dareRed)),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  },
  child: /* Scaffold */,
)
```

---

## FILE: `lib/screens/ludo/widgets/chaos_tile_popup.dart`

Full-screen dark scrim overlay sliding up from the bottom.

```dart
class ChaosTilePopup extends StatelessWidget {
  final String playerName;
  final String prompt;
  final bool isTruth;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;
}
```

**UI:**
- Scrim: `Colors.black.withAlpha(180)`
- Centred `GlassCard` with `AppColors.primaryContainer` border glow
- Top: rotating 🌀 icon (use `AnimatedRotation`)
- Badge: `"CHAOS TILE"` in `AppColors.primaryNeon`, letter-spacing 3
- Type badge: TRUTH in `AppColors.truthBlue` / DARE in `AppColors.dareRed`
- Prompt text: 20px bold white
- Two buttons:
  - `"Done it ✓"` → green, calls `onAccept`
  - `"Refuse — back 6 spaces"` → red, calls `onRefuse`
- Entry: `.animate().slideY(begin: 1.0, duration: 400ms, curve: Curves.easeOutCubic)`

---

## FILE: `lib/screens/ludo/widgets/event_card_sheet.dart`

Bottom sheet shown at start of every turn.

```dart
class EventCardSheet extends StatelessWidget {
  final Map<String, dynamic> card;
  final VoidCallback onApply;
}
```

**UI:**
- `showModalBottomSheet` with `isDismissible: false` — player must tap Apply
- `GlassCard` container
- Colour scheme: green tint for good cards, red tint for bad cards
- Large emoji (48px), title (20px bold), description (14px muted)
- `"GOOD LUCK"` / `"BAD LUCK"` badge
- `"Apply"` button — full width

---

## HOME SCREEN CHANGES

**File:** `lib/screens/home/home_screen.dart`

Add Ludo Chaos to the `_modes` list:

```dart
_ModeData(
  name: 'Ludo Chaos',
  tagline: '13 ways to cause chaos',
  icon: Icons.casino_rounded,
  color: AppColors.neonYellow,
  colorDark: const Color(0xFF4A3800),
  builder: (_) => const LudoSetupScreen(),
),
```

Add the import:
```dart
import '../ludo/ludo_setup_screen.dart';
```

---

## FILE: `lib/screens/ludo/ludo_result_screen.dart`

**UI:**
1. `confetti` package burst on entry
2. `"🏆 Game Over"` heading — gradient text
3. Players ranked by score in podium style:
   - 1st: tall block in `AppColors.gold`
   - 2nd: medium block in `AppColors.textSecondary`
   - 3rd/4th: shorter block in `AppColors.neonOrange`
4. Each block: player name + colour dot + score
5. **Special Awards** section:
   - 💣 Most Sabotages
   - 🌀 Chaos Survivor (most dares completed)
   - 💰 Bounty Hunter (most bounties captured)
   - 💀 Unlucky (whose cursed token was revealed)
6. Two buttons:
   - `"Play Again"` — new `LudoGameService.instance.createGame(sameNames)` → `LudoBoardScreen`
   - `"Home"` — `Navigator.popUntil((r) => r.isFirst)`

**Sound:** `ludoWin` plays on entry. `HapticEvent.win` triggers.

---

## QA SCENARIOS

### L1 — Board Renders Correctly
1. Tap Ludo Chaos on home screen
2. Select 4 players, enter names, tap Start
3. Confirm board fills the screen correctly with all 4 coloured home zones
4. Confirm 16 tokens (4 × 4) appear in the correct home zone corners
5. Zoom in — confirm special squares are visible (🌀 purple, 🔒 red, 🎁 green, cyan wormholes, ⭐ safe squares)

**Checks:** [ ] Board not clipped [ ] All tokens in correct positions [ ] Special squares visually distinct [ ] Zoom works

---

### L2 — Basic Turn Flow + Sounds
1. Player 1 taps dice — confirm roll animation plays AND dice roll sound plays
2. Roll a 6 — confirm a token can be placed, confirm `ludoTokenEnter` sound plays
3. Confirm token animates to entry square with per-step click sounds
4. Roll non-6 with all tokens at home — confirm no tokens are selectable
5. Pass to next player — confirm AppBar updates player name and colour

**Checks:** [ ] Dice sound plays [ ] Enter sound plays [ ] Step clicks play [ ] No moves with non-6 at home [ ] Turn indicator updates

---

### L3 — All 13 Chaos Features

For each feature, move a token to the trigger position or perform the action and verify:

| Feature | Trigger | Expected sound | Expected result |
|---|---|---|---|
| Chaos Tile | Land on sq 5, 18, 31, or 44 | `ludoChaosTitle` | Popup shows truth/dare prompt |
| Chaos Tile (refuse) | Tap "Refuse" | `wrong` | Token moves back 6 |
| Chaos Tile (accept) | Tap "Done it" | `win` | No penalty |
| Sabotage — Freeze | Tap sabotage → Freeze target | `ludoSabotage` | Target skips next turn |
| Sabotage — Send Back | Tap sabotage → Send Back 5 | `ludoSabotage` | Token moves back 5 |
| Sabotage — Block Home | Tap sabotage → Block Home Entry | `ludoSabotage` | Target cannot enter home col for 2 turns |
| Sabotage vs Armored | Target Armored token | none | Card not consumed, blocked message shows |
| Power Dice | 5th total roll | `ludoPowerRoll` | Two dice show, player picks higher |
| Bounty | Score gap ≥ 30 | `ludoBountySet` | Bounty badge appears on leader |
| Bounty capture | Send bounty player's token home | `ludoBountyCapture` | +25 pts, badge removed |
| Event Card — Lucky Break | Any turn (card drawn) | `ludoEventGood` | Token picker shows, token moves +3 |
| Event Card — Skip | Skip event drawn | `ludoEventBad` | Player's turn ends immediately |
| Wormhole A | Land on sq 3 | `ludoWormhole` | Token teleports to sq 29 |
| Wormhole B | Land on sq 29 | `ludoWormhole` | Token teleports to sq 3 |
| Wormhole flip | Use wormhole again | `ludoWormhole` | Direction reversed |
| Jail | Land on sq 42 (non-Phantom) | `ludoJailEnter` | Token jailed 2 turns |
| Jail bail | Another player lands on sq 42 | `ludoJailFree` | Both freed |
| Phantom vs Jail | Phantom token lands on sq 42 | none | Token not jailed |
| Gift Square | Land on sq 16 | `ludoGiftSquare` | Token picker → selected token +6 |
| King's Rule | First token finishes | `ludoKingCrown` | Rule input sheet shows, rule in AppBar |
| Cursed Token | Opponent sends cursed token home | `ludoCurseReveal` | −10 pts, skull shown |
| Swap Trap | Tap Swap Trap, pick 2 tokens | `ludoSwapTrap` | Positions swap, button disappears |
| Speed Round | 2 or fewer tokens on board total | `ludoSpeedRound` | Ring timer appears on dice, 5s limit |
| Speed timeout | Don't roll in 5s | none | Turn forfeited |

---

### L4 — Sound Respects Settings
1. Go to Settings → disable sound effects
2. Play a full turn of Ludo — confirm zero sounds play
3. Re-enable sound — confirm sounds return
4. Disable haptics — confirm no vibration during dice roll or token movement

**Checks:** [ ] All sounds off when disabled [ ] All sounds on when re-enabled [ ] Haptics off when disabled

---

### L5 — Edge Cases
1. Try to move a Phantom token to jail square — confirm it is NOT jailed
2. Try to move an Armored token with a sabotage — confirm it is blocked
3. Have a player with skip turn from sabotage AND skip from event card — confirm they only skip once (flags are OR'd, not doubled)
4. Win the game — confirm confetti, win sound, podium screen with correct ranking

---

## IMPLEMENTATION ORDER

| Step | Task |
|---|---|
| L1 | Add 21 new `SoundEvent` entries to `sound_service.dart` + new asset map entries |
| L2 | Download all 21 sound files, rename, place in `assets/sounds/`, add to `pubspec.yaml` |
| L3 | Create `ludo_data.dart` — board path, special squares, truth/dare prompts, event cards data |
| L4 | Create `ludo_token.dart` + `ludo_player.dart` + `ludo_event_card.dart` |
| L5 | Create `ludo_game_state.dart` |
| L6 | Create `ludo_game_service.dart` — full game logic + `MoveResult` |
| L7 | Create `ludo_board_painter.dart` — full 15×15 board CustomPainter |
| L8 | Create `ludo_token_widget.dart` — animated token with personality, jail, curse overlays |
| L9 | Create `ludo_dice_widget.dart` — pip dice, roll animation, speed round ring |
| L10 | Create `chaos_tile_popup.dart` |
| L11 | Create `event_card_sheet.dart` |
| L12 | Create `sabotage_sheet.dart` + `kings_rule_sheet.dart` |
| L13 | Create `speed_round_overlay.dart` + `bounty_banner.dart` + `scoreboard_sheet.dart` |
| L14 | Create `ludo_setup_screen.dart` |
| L15 | Create `ludo_board_screen.dart` — full game screen, all logic wired up |
| L16 | Create `ludo_result_screen.dart` |
| L17 | Add Ludo Chaos card to `home_screen.dart` |
| L18 | Run QA Scenarios L1–L5, fix all issues, `flutter analyze` |
