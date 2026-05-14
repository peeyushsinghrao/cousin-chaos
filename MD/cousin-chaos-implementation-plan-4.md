# COUSIN CHAOS — ULTIMATE EDITION
## Complete Implementation Plan
### Bugs · Sound System · Full UI Redesign · Animations · Polish & Launch Readiness

---

> **This document is the single source of truth for the implementing AI.**
> Read every section before touching any file. Follow the order exactly.
> Later steps depend on earlier ones. Every file listed must be modified or created exactly as described.

---

## NON-NEGOTIABLE RULES

- **Remove ALL emojis from every file.** Replace with Flutter Icons only.
- `audioplayers ^6.6.0` is already in `pubspec.yaml` — do **NOT** add it again.
- `flutter_fortune_wheel` is already in `pubspec.yaml` — keep it.
- Never use `withOpacity()` — always use `withAlpha()`. Example: `withAlpha(128)` = 50% opacity.
- Do **not** change any data files: `trivia_data.dart`, `nhie_data.dart`, `wyr_data.dart`, `impostor_data.dart`, `pack_data.dart`, `random_data.dart`.
- Do **not** change: `models/player.dart`, `models/pack.dart`, `services/pack_manager.dart`, `services/player_manager.dart`, `services/preferences_service.dart`, `services/api_service.dart`.
- Keep all existing navigation logic and routes. Only change visual code.
- All new glass card surfaces use `BackdropFilter` with `ImageFilter.blur()` for frosted glass effect.

---

## PACKAGES TO ADD TO pubspec.yaml

Add these two packages. All others are already present.

```yaml
confetti: ^0.8.0        # Win screen particle burst (Animations Phase)
flutter_animate: ^4.5.0  # Clean animation chaining API (Animations Phase)
```

All remaining animation suggestions use only Flutter built-ins: `AnimationController`, `Tween`, `Transform`, `CustomPainter`. No other packages needed.

---

---

# PHASE 1 — BUG FIXES

> Fix every bug in this section before any UI or animation work. Test that the app compiles after each fix.

---

### BUG 1 — ModePlayerSetupScreen: TextField loses focus on every keystroke

**File:** `lib/screens/shared/mode_player_setup_screen.dart`

**Problem:**
Inside `build()`, each player `TextField` is created with `TextEditingController(text: player.name)`. Because this runs on every rebuild, a brand new controller is created every time the user types a character, causing the cursor to jump and focus to be lost.

**Fix:**
- Replace `TextField` with `TextFormField`
- Replace `controller: TextEditingController(text: player.name)` with `initialValue: player.name`
- Keep `onChanged: (v) => pm.updatePlayerName(player.id, v)` unchanged
- Remove the `TextEditingController` entirely — no controller needed

**Reference:** See `player_setup_screen.dart` line ~130 for the correct pattern already used there.

---

### BUG 2 — BombPassScreen: "Play Again" does not reset game

**File:** `lib/screens/new_modes/bomb_pass_screen.dart`

**Problem:**
The "PLAY AGAIN" button on the explosion screen only sets `_isExploded = false`. It does not reset `_isPlaying`, cancel any running timers, or pick a new task. If tapped again the game enters a broken state.

**Fix:**
- Create a new `_resetGame()` method:
  ```dart
  void _resetGame() {
    _bombTimer?.cancel();
    _tickTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _isExploded = false;
      _currentTask = '';
      _timeUntilExplosion = 0;
    });
  }
  ```
- Replace the "PLAY AGAIN" `onTap` body with a single call to `_resetGame()`

---

### BUG 3 — FreezeModeScreen: setState after dispose

**File:** `lib/screens/new_modes/freeze_mode_screen.dart`

**Problem:**
If the user starts the game and immediately navigates back, `_hiddenTimer` fires `_triggerFreeze()` after the widget is disposed. The haptics loop has `mounted` guards but the final `setState()` does not.

**Fix:**
- In `_triggerFreeze()`, add `if (!mounted) return;` immediately before the `setState({ _isFrozen = true... })` call
- This single guard covers the remaining `setState` and `_freezeTimer.start` call

---

### BUG 4 — GameEngineScreen: Stale API response overwrites current prompt

**File:** `lib/screens/truth_or_dare/game_engine_screen.dart`

**Problem:**
`_selectType()` calls `_pickFromLocalDeck()` (instant), then immediately calls `_fetchSinglePrompt()` which on success overwrites `_currentPrompt`. If the player taps "Next" before the API returns, the replacement prompt appears mid-turn or on the wrong player's card.

**Fix:**
- Add a `String _currentTurnId = '';` field to `_GameEngineScreenState`
- Add `const Uuid _uuid = const Uuid();` to `_GameEngineScreenState` directly
- In `_selectType()`, generate a new turn ID: `final turnId = _uuid.v4(); _currentTurnId = turnId;`
- Pass `turnId` as a parameter to `_fetchSinglePrompt(type, turnId)`
- In `_fetchSinglePrompt()`, before the `setState` that sets `_currentPrompt`, add:
  ```dart
  if (_currentTurnId != turnId) return;
  ```

---

### BUG 5 — ApiService: Sequential batch fetch (performance)

**File:** `lib/services/api_service.dart`

**Problem:**
`fetchTruths()` and `fetchDares()` loop with `await fetchTruth()`/`fetchDare()` one at a time. This means 10 sequential HTTP calls at startup. On a slow connection this can take 10–20 seconds.

**Fix:**
- Replace the `for` loop in `fetchTruths()` with:
  ```dart
  return (await Future.wait(
    List.generate(count, (_) => fetchTruth(is18Plus: is18Plus))
  )).whereType<GameCardPrompt>().toList();
  ```
- Apply the same pattern to `fetchDares()`

---

### BUG 6 — PlayerManager: Wrong player number after removal

**File:** `lib/services/player_manager.dart`

**Problem:**
`addPlayer()` uses `_players.length + 1` as the default name. After a removal, this creates duplicate names. E.g. remove Player 2, then add — it becomes "Player 4" which might already exist.

**Fix:**
- In `addPlayer()`, find the first unused number:
  ```dart
  int n = 1;
  while (_players.any((p) => p.name == 'Player $n')) n++;
  ```
- Use `n` as the name: `Player(id: _uuid.v4(), name: 'Player $n')`

---

### BUG 7 — ImpostorGameScreen: "Play Again" pops instead of replaying

**File:** `lib/screens/new_modes/impostor_game_screen.dart`

**Problem:**
"PLAY AGAIN" in the result screen calls `Navigator.pop(context)`, sending the user back to setup. There is no way to replay without going through the full setup again.

**Fix:**
- Replace `Navigator.pop(context)` in the "PLAY AGAIN" button with:
  ```dart
  _initializeGame();
  setState(() { _currentPlayerIndex = 0; _votedPlayer = null; });
  ```
- Add a separate "Leave" `TextButton` below "PLAY AGAIN" that calls `Navigator.pop(context)` for users who want to exit

---

### BUG 8 — DisclaimerDialog: Shows on every single tap

**Files:** `lib/widgets/disclaimer_dialog.dart` + `lib/screens/home/home_screen.dart`

**Problem:**
`DisclaimerDialog.show()` is called on every game card tap. Users see it every single time they tap anything, training them to skip reading it.

**Fix:**
- Add `static bool _accepted = false;` to `DisclaimerDialog`
- In `show()`, check: `if (_accepted) { onAccept(); return Future.value(); }`
- In the `onTap` that calls `onAccept()`, also set `DisclaimerDialog._accepted = true;`
- This makes it show once per app session only

---

### BUG 9 — PreferencesService.clearAllData(): In-memory state not reset

**Files:** `lib/screens/settings/settings_screen.dart` + `lib/services/player_manager.dart` + `lib/services/pack_manager.dart`

**Problem:**
`clearAllData()` clears `SharedPreferences` but `PlayerManager` and `PackManager` still hold old data in memory. The user sees stale players and custom packs until they restart the app.

**Fix:**
- Rename `_loadPlayers()` → `loadPlayers()` in `PlayerManager` (make public)
- Rename `_loadCustomPacks()` → `loadCustomPacks()` in `PackManager` (make public)
- In `settings_screen.dart` `_showClearDataDialog` after `prefs.clearAllData()`, also call:
  ```dart
  context.read<PlayerManager>().loadPlayers();
  context.read<PackManager>().loadCustomPacks();
  ```

---

### BUG 10 — SpeedChallengeScreen: Timer format breaks for 60+ seconds

**File:** `lib/screens/new_modes/speed_challenge_screen.dart`

**Problem:**
The timer display is hardcoded as `'00:${_timeLeft}'`. For values like 5, it shows `'00:5'` not `'00:05'`. For 60+ seconds it would show `'00:65'`.

**Fix:**
- Replace the display string with:
  ```dart
  '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}'
  ```

---

### BUG 11 — BombPassScreen: Tick acceleration uses wrong max time

**File:** `lib/screens/new_modes/bomb_pass_screen.dart`

**Problem:**
`_scheduleTick()` calculates `ratio = timeLeft / 45.0`, but the bomb can explode at 15 seconds. If it explodes at 15s, the tick never accelerates because the ratio never approaches 0.

**Fix:**
- Change the ratio calculation to:
  ```dart
  double ratio = timeLeft / _timeUntilExplosion.toDouble();
  ```

---

### BUG 12 — ImpostorGameScreen: Reveal can be bypassed with quick tap

**File:** `lib/screens/new_modes/impostor_game_screen.dart`

**Problem:**
The reveal uses `onTapDown` to show the word and `onTapUp`/`onTapCancel` to advance. A very quick tap shows the word AND advances in the same gesture, potentially letting a player see the word and hide it without others noticing.

**Fix:**
- Replace the `GestureDetector` with a dedicated long-press:
  - `onLongPressStart` → `setState(() => _isRevealing = true)`
  - `onLongPressEnd` → `_handleRevealComplete()`
  - `onLongPressCancel` → `setState(() => _isRevealing = false)`
- Change the button label to `'HOLD TO REVEAL'`
- Add a minimum hold of 1 second using a `Timer` stored in `_revealTimer`, cancelled on `onLongPressCancel`

---

### BUG 13 — ChaosModeScreen: Same event can repeat back-to-back

**File:** `lib/screens/new_modes/chaos_mode_screen.dart`

**Problem:**
`_nextEvent()` picks randomly from `_events` with no deduplication. The same event can appear two or three times in a row.

**Fix:**
- Add `int _lastEventIndex = -1;` field
- In `_nextEvent()`:
  ```dart
  int idx;
  do {
    idx = _random.nextInt(_events.length);
  } while (idx == _lastEventIndex && _events.length > 1);
  _lastEventIndex = idx;
  _currentEvent = _events[idx];
  ```

---

### BUG 14 — HomeScreen: Wrong navigation for WYR, NHIE, Trivia Battle

**File:** `lib/screens/home/home_screen.dart`

**Problem:**
Would You Rather, Never Have I Ever, and Trivia Battle all route through `PackSelectionScreen` first. These modes do not use T&D packs at all. Sending users through pack selection is misleading and confusing.

**Fix:**
- **Would You Rather:** Navigate directly to:
  ```dart
  ModePlayerSetupScreen(
    title: 'Would You Rather',
    subtitle: 'Pick between two impossible options!',
    themeColor: AppColors.truthBlue,
    icon: Icons.help_outline_rounded,
    onStart: (_) => const StandaloneGameScreen(type: StandaloneGameType.wyr),
  )
  ```
- **Never Have I Ever:** Navigate directly to `ModePlayerSetupScreen` with `StandaloneGameType.nhie`
- **Trivia Battle:** Navigate directly to `const StandaloneGameScreen(type: StandaloneGameType.trivia)`
- Remove the `PackSelectionScreen` wrapper from all three routes

---

### BUG 15 — Verify WYR/NHIE standalone routes end-to-end

**File:** `lib/screens/standalone_game/standalone_game_screen.dart`

**Problem:**
After the Bug 14 fix, confirm `StandaloneGameType.wyr` and `StandaloneGameType.nhie` work correctly end-to-end.

**Fix (verification):**
- Confirm `StandaloneGameType.wyr` calls `ApiService.fetchWouldYouRather()`
- Confirm `StandaloneGameType.nhie` calls `ApiService.fetchNeverHaveIEver()`
- No code changes needed if both already work — this is a verification step only

---

---

# PHASE 2 — SOUND SYSTEM

> `audioplayers ^6.6.0` is already in `pubspec.yaml`. Do not add it again.

---

## STEP 1 — Create SoundService

**File to create:** `lib/services/sound_service.dart`

Create a singleton class `SoundService`. Because the app uses `PreferencesService` to store `soundEnabled`, `SoundService` must accept a `bool soundEnabled` in its `play()` method and check it before playing.

### Sound events enum

```dart
enum SoundEvent {
  tap,          // short click, 80ms
  spin,         // whoosh, plays when wheel starts spinning
  cardReveal,   // flip/whoosh, plays when prompt card appears
  countdown,    // tick, plays every second during last 5s of countdowns
  timerEnd,     // alarm/buzz, plays when any timer reaches 0
  bombTick,     // single tick, used in BombPassScreen._scheduleTick()
  explosion,    // boom, plays on BombPassScreen explosion
  win,          // fanfare, plays on win/result screens
  wrong,        // buzzer, plays when eliminated/wrong answer
  freeze,       // ice whoosh, plays when FREEZE triggers
}
```

### Implementation pattern

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final SoundService instance = SoundService._internal();
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(SoundEvent event, {bool soundEnabled = true}) async {
    if (!soundEnabled) return;

    switch (event) {
      // Simple system sounds — work with zero asset files
      case SoundEvent.tap:
      case SoundEvent.countdown:
      case SoundEvent.bombTick:
        await SystemSound.play(SystemSoundType.click);
        break;

      // Heavy haptic combos — sound + physical feedback
      case SoundEvent.explosion:
      case SoundEvent.win:
        await HapticFeedback.heavyImpact();
        // TODO: replace with AudioPlayer asset when sound files are added
        // await _player.play(AssetSource('sounds/explosion.mp3'));
        break;

      case SoundEvent.wrong:
        await HapticFeedback.vibrate();
        break;

      case SoundEvent.timerEnd:
        await HapticFeedback.heavyImpact();
        await SystemSound.play(SystemSoundType.click);
        break;

      // TODO: plug in real asset files for remaining events
      case SoundEvent.spin:
      case SoundEvent.cardReveal:
      case SoundEvent.freeze:
        await HapticFeedback.mediumImpact();
        break;
    }
  }
}
```

### Register in main.dart

Add to the `MultiProvider` providers list:
```dart
Provider(create: (_) => SoundService.instance),
```

---

## STEP 2 — Wire SoundService into all screens

Always read `soundEnabled` via:
```dart
final soundEnabled = context.read<PreferencesService>().soundEnabled;
SoundService.instance.play(SoundEvent.tap, soundEnabled: soundEnabled);
```

### `game_engine_screen.dart`
| Location | Sound Event |
|---|---|
| `_onPlayerSelected()` | `SoundEvent.spin` |
| `_onTypeSelected()` | `SoundEvent.spin` |
| `_selectType()` after `_pickFromLocalDeck` | `SoundEvent.cardReveal` |
| `_onNextPlayer()` | `SoundEvent.tap` |

### `prompt_card.dart`
| Location | Sound Event |
|---|---|
| `initState()` | `SoundEvent.cardReveal` |
| `_startTimer()` every second when `_timeLeft <= 5` | `SoundEvent.countdown` |
| Timer reaches 0 | `SoundEvent.timerEnd` |

### `bomb_pass_screen.dart`
| Location | Sound Event |
|---|---|
| `_scheduleTick()` | `SoundEvent.bombTick` |
| `_explodeBomb()` | `SoundEvent.explosion` |

### `freeze_mode_screen.dart`
| Location | Sound Event |
|---|---|
| `_triggerFreeze()` | `SoundEvent.freeze` |
| `_showPenaltyPopup()` | `SoundEvent.timerEnd` |

### `speed_challenge_screen.dart`
| Location | Sound Event |
|---|---|
| `_startTimer()` when `_timeLeft <= 3` | `SoundEvent.countdown` |
| Timer reaches 0 | `SoundEvent.timerEnd` |

### `impostor_game_screen.dart`
| Location | Sound Event |
|---|---|
| Result reveal — civilians win | `SoundEvent.win` |
| Result reveal — impostor wins | `SoundEvent.wrong` |

### `last_standing_screen.dart`
| Location | Sound Event |
|---|---|
| `_eliminatePlayer()` | `SoundEvent.wrong` |
| `_buildWinnerScreen()` reveal | `SoundEvent.win` |

### `laugh_attack_screen.dart`
| Location | Sound Event |
|---|---|
| `_handleLaugh()` | `SoundEvent.wrong` |

### `dynamic_timer_widget.dart`
| Location | Sound Event |
|---|---|
| `_startTimer()` when `_currentSeconds <= 5` | `SoundEvent.countdown` |
| `_onTimerComplete()` | `SoundEvent.timerEnd` |

### `target_player_screen.dart`
| Location | Sound Event |
|---|---|
| `_spinWheel()` | `SoundEvent.spin` |
| `_onSpinComplete()` | `SoundEvent.cardReveal` |

---

---

# PHASE 3 — DESIGN SYSTEM UPDATE

---

## STEP 1 — app_colors.dart (REPLACE ENTIRE FILE)

**File:** `lib/core/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // ── Deep Space Background ──
  static const Color background    = Color(0xFF05030F);
  static const Color surface       = Color(0xFF0E0820);
  static const Color surfaceLight  = Color(0xFF160D2E);
  static const Color surfaceBright = Color(0xFF1F1340);

  // ── Glass surfaces ──
  static const Color glassWhite     = Color(0x14FFFFFF); // 8% white
  static const Color glassBorder    = Color(0x22FFFFFF); // 13% white
  static const Color glassHighlight = Color(0x08FFFFFF); // 3% white

  // ── Primary ──
  static const Color primaryNeon    = Color(0xFF9B4DFF);
  static const Color primaryNeonDim = Color(0xFF6B2FCC);

  // ── Game Accents ──
  static const Color truthBlue     = Color(0xFF2DD4F7);
  static const Color truthBlueDark = Color(0xFF0891B2);
  static const Color dareRed       = Color(0xFFFF3A5C);
  static const Color dareRedDark   = Color(0xFFCC0033);
  static const Color neonGreen     = Color(0xFF22FF88);
  static const Color neonYellow    = Color(0xFFFFD60A);
  static const Color neonOrange    = Color(0xFFFF7043);
  static const Color neonPink      = Color(0xFFFF2D92);
  static const Color neonCyan      = Color(0xFF00F0FF);

  // ── Text ──
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0A3C0);
  static const Color textMuted     = Color(0xFF6B5E80);

  // ── Gradients (keep all existing + add glass) ──
  static const LinearGradient truthGradient = LinearGradient(
    colors: [truthBlue, truthBlueDark],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient dareGradient = LinearGradient(
    colors: [dareRed, dareRedDark],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNeon, primaryNeonDim],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF05030F), Color(0xFF0E0820), Color(0xFF05030F)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}
```

---

## STEP 2 — app_theme.dart

**File:** `lib/core/theme/app_theme.dart` — **NO CHANGE.** Keep as-is.

---

## STEP 3 — Create GlassCard widget

**File to create:** `lib/core/widgets/glass_card.dart`

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool intense;

  const GlassCard({
    super.key,
    required this.child,
    required this.accentColor,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(20),
    this.intense = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: AppColors.glassGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: accentColor.withAlpha(intense ? 60 : 30),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withAlpha(20),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

---

---

# PHASE 4 — SCREEN REDESIGNS

> Do one file at a time. Every emoji must be replaced with a Flutter Icon. Apply `GlassCard` to all main content cards.

---

## SCREEN 1 — home_screen.dart (FULL REWRITE)

**File:** `lib/screens/home/home_screen.dart`

**Header changes:**
- Remove `"ULTIMATE EDITION"` subtitle text
- Keep `"Cousin Chaos"` title with `ShaderMask` gradient
- Replace settings gear with a styled `GlassCard` icon button

**Truth or Dare main card:**
- Replace the `"● ACTIVE"` badge with prompt count from `PackManager`: `Icon(Icons.circle, size: 8) + "X prompts ready"`
- Remove the play button arrow — the entire card is tappable
- Add `Icon(Icons.touch_app_rounded)` + `"Tap to play"` label bottom-right
- Replace `"13 Packs"` text tag with `Icon(Icons.layers_rounded)` + `"13 Packs"`
- Replace `"Custom"` text tag with `Icon(Icons.edit_rounded)` + `"Custom"`

**Games grid — add 1-line description under each title:**

| Game | Description |
|---|---|
| Random Challenge | A surprise dare every round |
| Would You Rather | Pick between two impossible options |
| Never Have I Ever | Who's done the wildest things? |
| Trivia Battle | Test your knowledge against friends |
| Impostor Mode | One spy, everyone else knows the word |
| Act It Out | Mime your way to victory, no talking |
| Speed Challenge | Race the clock to complete tasks |
| Laugh Attack | Make them laugh or face the penalty |
| Freeze Mode | When the screen flashes, nobody moves |
| Target Player | Spin the wheel, someone gets a task |
| Secret Mission | Complete your hidden goal undetected |
| Chaos Mode | Random events hit when you least expect |
| Bomb Pass | Pass the phone before it explodes |
| Last Standing | Outlast everyone in the challenge |

**Grid icon containers:** Increase `withAlpha` from `20` → `35` so icons are more visible.

---

## SCREEN 2 — disclaimer_dialog.dart (VISUAL UPDATE)

- Replace `"OK"` button text with `"I Understand"`
- Apply `GlassCard` to the inner container
- Implement Bug 8 session-level dismiss logic here

---

## SCREEN 3 — pack_selection_screen.dart (VISUAL UPDATE)

- Wrap each pack card in `GlassCard`
- Remove `"STEP 1 OF 3"` — replace with screen title `"Choose Packs"`
- `pack.emoji` field is unused visually since `_getIconForPack()` already returns Flutter Icons — keep as-is
- Bottom bar: replace text with `Icon(Icons.play_arrow_rounded)` + `"Play with X packs"`
- Selected pack glow: change `withAlpha(30)` → `withAlpha(50)`

---

## SCREEN 4 — player_setup_screen.dart (VISUAL UPDATE)

- Remove `"STEP 2 OF 3"` — use back button title `"Setup Players"`
- Game mode cards: replace emoji `"🎡"` with `Icon(Icons.rotate_right_rounded)` and `"👆"` with `Icon(Icons.touch_app_rounded)`
- Start button: remove `"🔥"` emoji — use `Icon(Icons.play_arrow_rounded)` + `"Let's Go"`
- Player list rows: wrap in `GlassCard`

---

## SCREEN 5 — game_engine_screen.dart (VISUAL UPDATE)

- Wheel items: replace `"😇 Truth"` with `"TRUTH"` and `"😈 Dare"` with `"DARE"`
- Manual Truth/Dare buttons: icons already present, just remove any emoji text
- Back button: use the Standard Back Button (see Standard Components below)

---

## SCREEN 6 — prompt_card.dart (FULL REWRITE)

- Replace emoji badge `😇 TRUTH` / `😈 DARE` with `Icon(Icons.lightbulb_rounded)` for truth and `Icon(Icons.local_fire_department_rounded)` for dare
- Add `"Time to answer"` label above the 20-second circular timer
- **Pin "Next Player" button to screen bottom** — wrap card content in `Expanded(child: SingleChildScrollView(...))` and put the button outside the scroll area as a persistent footer
- Replace `"Next Player →"` with `Icon(Icons.arrow_forward_rounded)` + `"Next Player"` (no arrow in text string)
- Wrap the prompt card `Container` in `GlassCard`

---

## SCREEN 7 — settings_screen.dart (VISUAL UPDATE)

- Wrap body in `Container` with `AppColors.backgroundGradient`
- Wrap each settings tile in `GlassCard`
- Section headers: add a 2px left border in the section's accent color
- Add `"Manage Players"` tile in the GAMEPLAY section. `onTap` navigates to `PlayerSetupScreen()`
- Version tile: add `Icon(Icons.theater_comedy_rounded)` as decoration

---

## SCREEN 8 — mode_player_setup_screen.dart (VISUAL UPDATE)

- Apply Bug 1 fix (already specified above)
- Apply same glass treatment as `player_setup_screen`
- Remove `"START GAME 🎮"` emoji — replace with `Icon(Icons.sports_esports_rounded)` + `"Start Game"`

---

## SCREENS 9–22 — All Game Mode Screens (BATCH UPDATE)

Apply to all files below:

```
impostor_game_screen.dart     impostor_setup_screen.dart
act_it_out_screen.dart        speed_challenge_screen.dart
laugh_attack_screen.dart      freeze_mode_screen.dart
target_player_screen.dart     secret_mission_screen.dart
chaos_mode_screen.dart        bomb_pass_screen.dart
last_standing_screen.dart     random_challenge_screen.dart
wyr_game_screen.dart          nhie_game_screen.dart
```

**Batch changes for ALL screens above:**
- Back button: use Standard Back Button (see below)
- Any remaining emoji in button labels → replace with icons
- Snack bar content text → plain text, no emoji
- Main content cards → wrap in `GlassCard`

**Screen-specific overrides:**

`freeze_mode_screen.dart`
- Change frozen screen `FREEZE!` text color from `dareRed` → `truthBlue` to match the mode theme

`chaos_mode_screen.dart`
- Remove `backgroundColor: bgColor` (solid neon scaffold color)
- Replace with `backgroundColor: AppColors.background`
- Add a `Container` with `RadialGradient(colors: [currentEvent.color.withAlpha(60), Colors.transparent])` as body overlay so glow comes from behind content rather than flooding the entire screen

`impostor_game_screen.dart`
- Apply Bug 7 fix (Play Again replays in-place)
- Apply Bug 12 fix (hold gesture reveal)

`bomb_pass_screen.dart`
- Apply Bug 2 fix (full reset on Play Again)
- Apply Bug 11 fix (tick ratio uses actual fuse time)

---

---

# PHASE 5 — ANIMATIONS

> All animations use Flutter built-ins unless noted. `flutter_animate ^4.5.0` and `confetti ^0.8.0` must be added to pubspec.yaml.

---

## HIGH IMPACT — Do These First

---

### ANIMATION 1 — Home Screen: Staggered wave card entrance

**File:** `lib/screens/home/home_screen.dart`

**What:** Each game card slides up AND rotates from a slight tilt (3 degrees) back to 0 simultaneously. Creates a wave effect as cards enter.

**Implementation:**
```dart
// Wrap each grid card with AnimationController per card
// Use flutter_animate for clean chaining:
child: GameCard(...)
  .animate(delay: Duration(milliseconds: 60 * index))
  .fadeIn(duration: 400.ms)
  .slideY(begin: 0.3, curve: Curves.easeOutCubic)
  .rotate(begin: 0.05, end: 0.0, curve: Curves.easeOutCubic)
```
- Delay increments by `60ms * index`
- Total wave duration across all 14 cards: ~840ms + 400ms fade = ~1.2s complete
- Only fires on first build — wrap in a `bool _hasAnimated` flag, set to true after first frame

---

### ANIMATION 2 — Prompt Card: 3D flip reveal

**File:** `lib/screens/truth_or_dare/widgets/prompt_card.dart`

**What:** Card flips on the Y-axis when it appears. Front shows TRUTH/DARE badge only. Midway through flip (90°), content switches to the full prompt. Back half completes the flip showing the full card.

**Implementation:**
```dart
// In _PromptCardState, add:
late AnimationController _flipController;
late Animation<double> _flipAnimation;

// initState:
_flipController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 600),
);
_flipAnimation = Tween<double>(begin: 0.0, end: 1.0)
    .animate(CurvedAnimation(parent: _flipController, curve: Curves.easeInOut));
_flipController.forward();

// Build:
AnimatedBuilder(
  animation: _flipAnimation,
  builder: (context, child) {
    final angle = _flipAnimation.value * pi;
    final isFlipped = _flipAnimation.value > 0.5;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateY(angle),
      child: isFlipped
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(pi),
              child: _buildFullCard(),  // prompt text side
            )
          : _buildFrontFace(),  // badge-only side
    );
  },
)
```

---

### ANIMATION 3 — Wheel result: Player name elastic pop

**File:** `lib/screens/truth_or_dare/game_engine_screen.dart`

**What:** When the wheel stops and `_selectedPlayerName` is set, the player name animates with an elastic overshoot scale (0 → 1.1 → 1.0) plus a radial pulse glow ring that expands and fades.

**Implementation:**
```dart
// In _onPlayerSelected(), after setting state, trigger:
selectedName
  .animate()
  .scale(
    begin: const Offset(0, 0),
    end: const Offset(1, 1),
    duration: 500.ms,
    curve: Curves.elasticOut,
  )
  .fadeIn(duration: 200.ms)

// For the glow ring, use a separate AnimationController:
// Scale a Container from size 0 to 120 with opacity 1→0 simultaneously
// This creates the radial pulse effect
```

---

### ANIMATION 4 — Bomb Pass: Screen heat build

**File:** `lib/screens/new_modes/bomb_pass_screen.dart`

**What:** The screen background slowly shifts from dark purple → deep red as time runs out, driven by the remaining time ratio.

**Implementation:**
```dart
// In build(), add a ColorTween driven by remaining time:
final double progress = 1.0 - (_timeUntilExplosion > 0
    ? (_timeUntilExplosion - _elapsedSeconds) / _timeUntilExplosion
    : 0.0);

// Track _elapsedSeconds with a separate Timer.periodic running alongside _bombTimer

final bgColor = ColorTween(
  begin: AppColors.background,
  end: AppColors.dareRed.withAlpha(40),
).lerp(progress.clamp(0.0, 1.0))!;

// Use bgColor as the RadialGradient center color
```

---

## GAME-SPECIFIC ANIMATIONS

---

### ANIMATION 5 — Impostor reveal: Hold-to-reveal progress ring

**File:** `lib/screens/new_modes/impostor_game_screen.dart`

**What:** A circular progress ring fills as the user holds the button. When full, the card flips open with a scale + fade entrance.

**Implementation:**
```dart
// Add to _ImpostorGameScreenState:
late AnimationController _holdController;
Timer? _revealTimer;

// initState:
_holdController = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 1),
);

// onLongPressStart:
_holdController.forward();
_revealTimer = Timer(const Duration(seconds: 1), _handleRevealComplete);

// onLongPressEnd/Cancel:
_holdController.reset();
_revealTimer?.cancel();

// Button widget: wrap with AnimatedBuilder showing CircularProgressIndicator
// value: _holdController.value
// color: AppColors.neonPink
// strokeWidth: 6
// Place it as a ring around the button container

// Card entrance after reveal:
_buildRevealCard()
  .animate()
  .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutBack)
  .fadeIn(duration: 300.ms)
```

---

### ANIMATION 6 — Freeze Mode: Screen crack effect

**File:** `lib/screens/new_modes/freeze_mode_screen.dart`

**What:** When FREEZE triggers, an overlay of crack lines spreads from the center outward using a `CustomPainter`.

**Implementation:**
```dart
class CrackPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0, driven by AnimationController

  CrackPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.truthBlue.withAlpha((progress * 200).toInt())
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Define 8 crack line endpoints radiating from center
    final cracks = [
      Offset(size.width * 0.05, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.05),
      Offset(size.width * 0.95, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.95),
      Offset(size.width * 0.1, size.height * 0.9),
      Offset(size.width * 0.02, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.02),
      Offset(size.width * 0.7, size.height * 0.8),
    ];

    for (final end in cracks) {
      // Only draw up to progress amount of each line
      final current = Offset.lerp(center, end, progress)!;
      canvas.drawLine(center, current, paint);
    }
  }

  @override
  bool shouldRepaint(CrackPainter old) => old.progress != progress;
}

// In _triggerFreeze(), start a 600ms AnimationController
// Overlay the CrackPainter on top of the screen using a Stack
// After animation completes, keep cracks visible on frozen screen
```

---

### ANIMATION 7 — Chaos Mode: Event card slam-in with screen shake

**File:** `lib/screens/new_modes/chaos_mode_screen.dart`

**What:** Each new chaos event slams in from off-screen right with a `SlideTransition`, plus the entire screen shakes ±4px a few times.

**Implementation:**
```dart
// Screen shake: offset the Stack contents using AnimationController
late AnimationController _shakeController;
late Animation<Offset> _shakeAnimation;

// initState:
_shakeController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 400),
);
_shakeAnimation = TweenSequence<Offset>([
  TweenSequenceItem(tween: Tween(begin: Offset.zero, end: const Offset(0.01, 0)), weight: 1),
  TweenSequenceItem(tween: Tween(begin: const Offset(0.01, 0), end: const Offset(-0.01, 0)), weight: 2),
  TweenSequenceItem(tween: Tween(begin: const Offset(-0.01, 0), end: const Offset(0.01, 0)), weight: 2),
  TweenSequenceItem(tween: Tween(begin: const Offset(0.01, 0), end: Offset.zero), weight: 1),
]).animate(_shakeController);

// In _nextEvent(), after setting _currentEvent:
_shakeController.forward(from: 0);

// Wrap body content in:
SlideTransition(position: _shakeAnimation, child: _buildEventScreen())

// Card entrance:
_buildEventCard()
  .animate()
  .slideX(begin: 1.0, end: 0.0, duration: 350.ms, curve: Curves.easeOutCubic)
  .fadeIn(duration: 250.ms)
```

---

### ANIMATION 8 — Last Standing: Player elimination slide-off

**File:** `lib/screens/new_modes/last_standing_screen.dart`

**What:** When a player is eliminated, their card slides off to the right AND shrinks in height to 0 simultaneously.

**Implementation:**
```dart
// Replace ListView.builder items with AnimatedList
// Store a GlobalKey<AnimatedListState> _listKey

// In _eliminatePlayer():
final index = _activePlayers.indexWhere((p) => p.id == player.id);
_listKey.currentState?.removeItem(
  index,
  (context, animation) => SizeTransition(
    sizeFactor: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(1.5, 0),
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInCubic)),
      child: _buildPlayerCard(player),
    ),
  ),
  duration: const Duration(milliseconds: 350),
);
// Then remove from _activePlayers list after animation
```

---

### ANIMATION 9 — Impostor/Last Standing win: Confetti burst

**Files:** `lib/screens/new_modes/impostor_game_screen.dart` + `lib/screens/new_modes/last_standing_screen.dart`

**What:** When civilians win or a winner is declared, confetti fires from the top of the screen.

**Package:** `confetti: ^0.8.0` (add to pubspec.yaml)

**Implementation:**
```dart
import 'package:confetti/confetti.dart';

// Add to state:
late ConfettiController _confettiController;

// initState:
_confettiController = ConfettiController(
  duration: const Duration(seconds: 3),
);

// dispose:
_confettiController.dispose();

// When result is civiliansWin / winner found:
_confettiController.play();

// In build, wrap result screen in Stack:
Stack(
  children: [
    _buildResultScreen(),
    Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        numberOfParticles: 30,
        colors: const [
          AppColors.primaryNeon,
          AppColors.neonGreen,
          AppColors.truthBlue,
          AppColors.neonYellow,
        ],
      ),
    ),
  ],
)
```

---

### ANIMATION 10 — Speed Challenge: Urgency card pulse

**File:** `lib/screens/new_modes/speed_challenge_screen.dart`

**What:** When `_timeLeft <= 3`, the challenge card pulses (scale 1.0 → 1.03 → 1.0) in sync with the countdown ticks, and the border shifts to `dareRed`.

**Implementation:**
```dart
// Add AnimationController:
late AnimationController _pulseController;

// initState:
_pulseController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 300),
);

// In _startTimer(), when _timeLeft <= 3 on each tick:
_pulseController.forward(from: 0);

// Wrap challenge card with ScaleTransition:
ScaleTransition(
  scale: Tween<double>(begin: 1.0, end: 1.03)
      .chain(CurveTween(curve: Curves.easeInOut))
      .animate(_pulseController),
  child: GlassCard(
    accentColor: _timeLeft <= 3 ? AppColors.dareRed : AppColors.dareRed.withAlpha(80),
    // ...
  ),
)
```

---

## MICRO-INTERACTIONS

---

### ANIMATION 11 — Pack selection: Checkmark draw-in

**File:** `lib/screens/truth_or_dare/pack_selection_screen.dart`

**What:** When a pack is selected, the checkmark animates drawing itself in using a `CustomPainter` path animation rather than just appearing.

**Implementation:**
```dart
class AnimatedCheckmark extends StatefulWidget {
  final bool visible;
  const AnimatedCheckmark({super.key, required this.visible});

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    if (widget.visible) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedCheckmark old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) _controller.forward(from: 0);
    if (!widget.visible && old.visible) _controller.reverse();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        size: const Size(20, 20),
        painter: _CheckPainter(_controller.value),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Checkmark path: down-left then up-right
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.75)
      ..lineTo(size.width * 0.8, size.height * 0.25);

    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
```

---

### ANIMATION 12 — Settings: Icon pulse on toggle

**File:** `lib/screens/settings/settings_screen.dart`

**What:** When a settings toggle is switched, the icon next to it briefly scales 1.0 → 1.2 → 1.0 to acknowledge the change.

**Implementation:**
```dart
// Convert _buildSwitchTile to a StatefulWidget: _AnimatedSwitchTile

// Add AnimationController:
late AnimationController _iconPulseController;

// In initState:
_iconPulseController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 250),
);

// In onChanged callback, before calling toggle:
_iconPulseController.forward(from: 0);

// Wrap icon Container with ScaleTransition:
ScaleTransition(
  scale: Tween<double>(begin: 1.0, end: 1.2)
      .chain(CurveTween(curve: Curves.easeInOut))
      .animate(_iconPulseController),
  child: /* icon container */,
)
```

---

### ANIMATION 13 — Player name: Confirmation flash on save

**File:** `lib/screens/truth_or_dare/player_setup_screen.dart` + `lib/screens/shared/mode_player_setup_screen.dart`

**What:** When a player finishes editing their name (`onEditingComplete`), the player number badge briefly flashes with a green glow pulse to confirm the save.

**Implementation:**
```dart
// Convert player row to StatefulWidget

// Add AnimationController:
late AnimationController _savedController;

// initState:
_savedController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 400),
);

// onEditingComplete:
_savedController.forward(from: 0);

// Badge decoration: use AnimatedBuilder to shift boxShadow color:
AnimatedBuilder(
  animation: _savedController,
  builder: (_, child) {
    final glow = ColorTween(
      begin: Colors.transparent,
      end: AppColors.neonGreen.withAlpha(120),
    ).evaluate(_savedController);
    return Container(
      // ... badge decoration ...
      decoration: BoxDecoration(
        // existing gradient...
        boxShadow: [BoxShadow(color: glow!, blurRadius: 12)],
      ),
      child: child,
    );
  },
  child: /* badge number text */,
)
```

---

### ANIMATION 14 — Universal: Consistent page transitions

**File:** `lib/screens/home/home_screen.dart` (and all `Navigator.push` calls)

**What:** Replace all raw `MaterialPageRoute` with a consistent shared-axis Z transition: scale from 0.92 → 1.0 with fade-in for forward navigation, reverse for back. Currently some screens have custom transitions and some don't.

**Implementation:**
```dart
// Create a helper function in a new file: lib/core/navigation/page_transitions.dart

Route<T> slideUpRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

// Replace every Navigator.push(context, MaterialPageRoute(builder: (_) => SomeScreen()))
// with: Navigator.push(context, slideUpRoute(const SomeScreen()))
```

---

### ANIMATION 15 — Home Screen: Game card press feedback

**File:** `lib/screens/home/home_screen.dart`

**What:** On press-down of any game card, it scales to 0.95. On release it bounces back to 1.0 with slight overshoot. Standard tactile feel that is currently missing.

**Implementation:**
```dart
// Replace GestureDetector with a StatefulWidget: _PressableCard

class _PressableCard extends StatefulWidget { ... }

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: 150.ms);
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) { _pressController.reverse(); widget.onTap(); },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(scale: _scaleAnim, child: widget.child),
    );
  }
}
```

---

## AMBIENT / BACKGROUND ANIMATIONS

---

### ANIMATION 16 — Home Screen: Drifting glow orbs

**File:** `lib/screens/home/home_screen.dart`

**What:** The two decorative glow orbs on the Truth or Dare card are static. Animate them slowly drifting ±15px over 4 seconds, looping forever.

**Implementation:**
```dart
// In _HomeScreenState, add:
late AnimationController _orbController;
late Animation<Offset> _orb1Anim;
late Animation<Offset> _orb2Anim;

// initState:
_orbController = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 4),
)..repeat(reverse: true);

_orb1Anim = Tween<Offset>(
  begin: const Offset(-30, -30),
  end: const Offset(-15, -15),
).animate(CurvedAnimation(parent: _orbController, curve: Curves.easeInOut));

_orb2Anim = Tween<Offset>(
  begin: const Offset(-20, -40),
  end: const Offset(-35, -25),
).animate(CurvedAnimation(parent: _orbController, curve: Curves.easeInOut));

// In the orb Positioned widgets, wrap with AnimatedBuilder:
AnimatedBuilder(
  animation: _orbController,
  builder: (_, child) => Positioned(
    top: _orb1Anim.value.dy,
    right: _orb1Anim.value.dx,
    child: child!,
  ),
  child: /* orb container */,
)
```

---

### ANIMATION 17 — GlassCard: Shimmer highlight sweep

**File:** `lib/core/widgets/glass_card.dart`

**What:** A thin white gradient shimmer line sweeps diagonally across every `GlassCard` surface every 5 seconds. Subtle but premium.

**Implementation:**
```dart
// Add to GlassCard as a stateful widget:
late AnimationController _shimmerController;

// initState:
_shimmerController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 800),
)..repeat(every: const Duration(seconds: 5)); // wait 5s between each sweep
// Note: use a Timer to trigger forward() every 5 seconds rather than repeat()

// In build, overlay a CustomPainter:
class _ShimmerPainter extends CustomPainter {
  final double progress; // -0.3 → 1.3 (extends beyond edges)
  _ShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final shimmerX = size.width * (progress * 1.6 - 0.3);
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        Colors.white.withAlpha(15),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTWH(shimmerX - 40, 0, 80, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}
```

---

### ANIMATION 18 — Prompt Card: Synchronized glow breath

**File:** `lib/screens/truth_or_dare/widgets/prompt_card.dart`

**What:** The existing `_glowController` already animates the border. Extend it so the card's `boxShadow` blur radius also breathes in sync — expanding from `blurRadius: 20` to `blurRadius: 50` and back. One controller, two animated properties.

**Implementation:**
```dart
// The _glowController already exists. In the AnimatedBuilder:
AnimatedBuilder(
  animation: _glowController,
  builder: (context, child) {
    final glowIntensity = _glowController.value;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: accentColor.withAlpha(
            (120 + glowIntensity * 80).toInt(),  // existing
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(
              (30 + glowIntensity * 50).toInt(),  // NEW: breathes with glow
            ),
            blurRadius: 20 + (glowIntensity * 30),  // NEW: 20 → 50 → 20
            spreadRadius: 2 + (glowIntensity * 4),   // NEW: subtle spread breath
          ),
        ],
      ),
      child: child,
    );
  },
  child: /* card content */,
)
```

---

---

# STANDARD COMPONENTS REFERENCE

---

## Standard Back Button

Use in **every** screen `AppBar` leading:

```dart
IconButton(
  onPressed: () => Navigator.pop(context),
  icon: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.glassWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.glassBorder, width: 1),
    ),
    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
  ),
)
```

---

## Standard Action Button

Full-width primary CTA used throughout game screens:

```dart
GestureDetector(
  onTap: () {
    HapticFeedback.mediumImpact();
    onTap();
  },
  child: Container(
    width: double.infinity,
    height: 64,
    margin: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color, color.withAlpha(200)]),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: color.withAlpha(60), blurRadius: 24, offset: const Offset(0, 8)),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  ),
)
```

---

## GlassCard Usage

Replace any plain `Container` card with:

```dart
GlassCard(
  accentColor: AppColors.primaryNeon, // use the screen's theme color
  padding: const EdgeInsets.all(24),
  child: /* card content */,
)
```

> `GlassCard` handles all decoration. Do **NOT** add extra `border` or `boxShadow` on the child.

---

---

# PUBSPEC.YAML CHANGES

```yaml
# ADD these two new packages:
confetti: ^0.8.0
flutter_animate: ^4.5.0

# These are already present — DO NOT add again:
# audioplayers: ^6.6.0
# animate_do: ^5.1.0
# google_fonts: ^8.1.0
# provider: ^6.1.5+1
# shared_preferences: ^2.5.5
# flutter_fortune_wheel: ^1.3.2
# uuid: ^4.5.3
# http: ^1.6.0
```

> `dart:ui` is a built-in Flutter library. Import it directly: `import 'dart:ui';` — do **NOT** add it as a pubspec dependency.

---

---

# IMPLEMENTATION ORDER

Follow this exact order. Do not skip ahead.

| Step | Task | Phase |
|---|---|---|
| 1 | All 15 bug fixes — fix and compile-test after each | Phase 1 |
| 2 | Create `SoundService` — new file + register in main.dart | Phase 2 |
| 3 | Update `app_colors.dart` — replace entire file | Phase 3 |
| 4 | Create `GlassCard` widget — new file | Phase 3 |
| 5 | Redesign `home_screen.dart` — full rewrite | Phase 4 |
| 6 | Update `disclaimer_dialog.dart` — visual + session logic | Phase 4 |
| 7 | Update `pack_selection_screen.dart` — glass cards | Phase 4 |
| 8 | Update `player_setup_screen.dart` — remove emoji, glass | Phase 4 |
| 9 | Update `game_engine_screen.dart` — remove emoji | Phase 4 |
| 10 | Rewrite `prompt_card.dart` — pinned button, icon badges | Phase 4 |
| 11 | Update `settings_screen.dart` — gradient, glass, players tile | Phase 4 |
| 12 | Update `mode_player_setup_screen.dart` — bug fix + glass | Phase 4 |
| 13 | Batch update all 14 game mode screens | Phase 4 |
| 14 | Wire `SoundService` into all screens | Phase 2 |
| 15 | Add `confetti` + `flutter_animate` to pubspec, run pub get | Phase 5 |
| 16 | Implement Animations 1–4 (high impact) | Phase 5 |
| 17 | Implement Animations 5–10 (game-specific) | Phase 5 |
| 18 | Implement Animations 11–15 (micro-interactions) | Phase 5 |
| 19 | Implement Animations 16–18 (ambient) | Phase 5 |
| 20 | `flutter analyze` — fix all warnings. Final emoji scan. | Pre-QA |
| 21 | Run QA Scenario 1–5 (core flows) — log and fix all issues | Phase 6 |
| 22 | Run QA Scenario 6–10 (game modes) — log and fix all issues | Phase 6 |
| 23 | Run QA Scenario 11–13 (polish + navigation) — log and fix | Phase 6 |
| 24 | Run QA Scenario 14 (stress test) — log and fix all issues | Phase 6 |
| 25 | QA Sign-off — all checkboxes green. App is ship-ready. | Phase 6 |
| 26 | Phase 7A: Splash screen, app icon, onboarding, demo mode | Phase 7 |
| 27 | Phase 7B: Portrait lock, safe area audit, force dark mode | Phase 7 |
| 28 | Phase 7C: Tap targets, semantic labels, text scale protection | Phase 7 |
| 29 | Phase 7D: Offline fallback, skeleton screens, friendly errors | Phase 7 |
| 30 | Phase 7E: Score tally, pack validation, skip, bomb holder, how to play | Phase 7 |
| 31 | Phase 7F: Privacy policy screen + url_launcher | Phase 7 |
| 32 | Phase 7G: Global error handler, Crashlytics, version bump | Phase 7 |
| 33 | Final `flutter analyze` + full regression QA pass | Final |

---

---

# PHASE 6 — AI USER TESTING (QA SIMULATION)

> This phase runs **after all implementation is complete** and `flutter analyze` passes with zero errors. The AI must simulate being a real user playing every game mode from start to finish. Think like a first-time player who has never seen the app — not a developer checking code. Do not look at code during this phase. Navigate the app purely as a user would — tap buttons, read what is shown, notice what feels wrong. After completing each scenario, log any issue found using the Issue Log format at the bottom of this section.

---

## SCENARIO 1 — First Launch (Brand New User)

**Steps:**
1. Launch the app cold (no existing data)
2. Observe the home screen — read every card title and description
3. Confirm the disclaimer dialog appears
4. Tap "I Understand" — confirm it dismisses and proceeds
5. Go back to home. Tap any other game card — confirm disclaimer does NOT appear again
6. Tap the settings gear — confirm settings screen loads with background gradient
7. Go back to home

**What to check:**
- [ ] App does not crash on first launch
- [ ] All 14 game cards have titles AND descriptions — no blanks
- [ ] No emoji visible anywhere on home screen
- [ ] Disclaimer shows exactly once this session
- [ ] Settings gear is visible and tappable
- [ ] Back navigation from settings returns to home cleanly

---

## SCENARIO 2 — Truth or Dare: Full Game Flow

**Steps:**
1. Tap the Truth or Dare main card
2. On pack selection: select 2 packs, deselect one, select it again
3. Tap "Play with X packs" — confirm it goes to player setup
4. Add 4 players by name. Type slowly — observe if cursor stays in place
5. Delete Player 2. Add a new player — confirm it gets the name "Player 2" not "Player 5"
6. Select "Spin Wheel" mode. Tap "Let's Go"
7. Watch the wheel spin and stop
8. Confirm the selected player name pops with an elastic animation
9. Confirm wheel items say "TRUTH" and "DARE" with no emoji
10. A prompt card appears — confirm it flips on entry (3D flip)
11. Confirm the badge shows an icon, not an emoji
12. Confirm "Time to answer" label is above the countdown timer
13. Confirm the "Next Player" button is visible at the bottom without scrolling
14. Tap "Next Player" — repeat 3 more times cycling through all players
15. Press the back button — confirm it uses the standard glass back button style

**What to check:**
- [ ] Pack selection checkmarks draw in (not instant-appear)
- [ ] Player name TextField cursor never jumps while typing
- [ ] New player after deletion gets the correct missing number
- [ ] Wheel items show no emoji
- [ ] Prompt card 3D flip plays on every new card
- [ ] "Time to answer" label present above timer
- [ ] Next Player button always pinned to bottom — never requires scrolling
- [ ] Glass back button consistent on every screen in this flow

---

## SCENARIO 3 — Truth or Dare: Tap Mode

**Steps:**
1. Start a T&D game with 2 players, select "Tap to Choose" mode
2. Manually tap the "TRUTH" button
3. Check the prompt card, tap "Next Player"
4. Manually tap the "DARE" button
5. Go through 3 full rounds

**What to check:**
- [ ] TRUTH/DARE buttons have no emoji in their labels
- [ ] Each new card triggers the flip animation
- [ ] Sound or haptic plays on card reveal
- [ ] No crashes across multiple rounds

---

## SCENARIO 4 — Bomb Pass: Full Tension Test

**Steps:**
1. Open Bomb Pass and start a game
2. Watch the screen background — confirm it gradually shifts darker/redder as time passes
3. Listen and feel for bomb tick sounds accelerating
4. Let the bomb explode — confirm explosion sound + heavy haptic
5. Tap "PLAY AGAIN" — confirm bomb resets completely (timer gone, task cleared)
6. Start again, pass to another player mid-game, let it explode on them
7. Tap "PLAY AGAIN" two more times — 3 Play Again cycles total

**What to check:**
- [ ] Background heat-shift from purple → red is visible as time runs low
- [ ] Tick sounds accelerate relative to the actual fuse, not a fixed 45s
- [ ] Explosion gives heavy haptic
- [ ] Play Again resets ALL state — no ghost timer, no stuck task text
- [ ] Game fully playable for 3+ rounds in a row without restarting the app

---

## SCENARIO 5 — Impostor Mode: Hold Reveal + Play Again

**Steps:**
1. Open Impostor Mode, set up 4 players
2. On the first "pass device" screen — tap the button quickly
3. Confirm the word does NOT reveal on a quick tap
4. Hold the button — watch the progress ring fill over 1 second
5. After ring completes, confirm the card reveals with scale + fade animation
6. Go through all 4 players
7. Vote for a player on the voting screen
8. On the result screen, tap "PLAY AGAIN"
9. Confirm the game restarts from player 1 WITHOUT going back to setup
10. Confirm a "Leave" button is available to exit to home
11. Confirm confetti fires if civilians won

**What to check:**
- [ ] Quick tap does not reveal the word
- [ ] Progress ring visibly fills on hold
- [ ] Reveal card animates in (scale + fade)
- [ ] Play Again stays in-game — no navigation back to setup
- [ ] Leave button exits to home correctly
- [ ] Confetti fires on civilians win only — not on impostor win

---

## SCENARIO 6 — Freeze Mode: FREEZE Trigger

**Steps:**
1. Open Freeze Mode, start with 3 players
2. Play normally and wait for the FREEZE to trigger
3. When FREEZE fires: observe the frozen screen for crack lines from center
4. Confirm the FREEZE text is blue, not red
5. Confirm a freeze sound or haptic fires
6. Resume and trigger another FREEZE
7. Back out mid-game before any FREEZE fires — confirm no crash

**What to check:**
- [ ] Crack line animation spreads from center on FREEZE
- [ ] FREEZE text is `truthBlue` (cyan/blue), not red
- [ ] Sound or haptic on FREEZE trigger
- [ ] Backing out mid-game causes no errors

---

## SCENARIO 7 — Chaos Mode: Event Variety and Visual Check

**Steps:**
1. Open Chaos Mode, start with 4 players
2. Tap through 10 events rapidly
3. Observe: confirm no two back-to-back events are the same
4. Observe: confirm the background is dark with a colored glow — NOT a solid neon color
5. Watch each new event card: confirm it slams in from the right with screen shake
6. Play for 2 full minutes

**What to check:**
- [ ] No two identical events back-to-back across 10 taps
- [ ] Background is dark + radial glow (not a blinding solid color)
- [ ] Slam-in animation with screen shake on every event
- [ ] No slowdown or memory issues after 10+ events

---

## SCENARIO 8 — Last Standing: Elimination Flow

**Steps:**
1. Open Last Standing, set up 5 players
2. Eliminate Player 3 — watch the animation closely
3. Confirm the card slides off to the right AND collapses in height simultaneously
4. Eliminate 3 more players one by one
5. Confirm confetti fires when the winner is revealed

**What to check:**
- [ ] Elimination is slide-right + height collapse (not just disappear)
- [ ] Remaining player count updates correctly after each elimination
- [ ] Winner confetti fires
- [ ] No way to accidentally eliminate the last remaining player

---

## SCENARIO 9 — Speed Challenge: Timer Display and Pulse

**Steps:**
1. Open Speed Challenge and start a challenge
2. Watch the timer — confirm it shows `00:30` not `0:30`
3. Let it count down to 3 seconds — confirm the challenge card starts pulsing
4. Confirm the card border turns red at 3 seconds
5. Let it reach zero — confirm timer-end sound or haptic fires

**What to check:**
- [ ] Timer always zero-padded: `00:05` not `00:5`
- [ ] Card pulse animation starts at exactly 3 seconds remaining
- [ ] Card border shifts to red in last 3 seconds
- [ ] Timer-end feedback fires at zero

---

## SCENARIO 10 — Would You Rather & Never Have I Ever: Direct Navigation

**Steps:**
1. From home, tap "Would You Rather"
2. Confirm it goes directly to player setup — NOT pack selection
3. Set up 2 players and play 3 rounds
4. Return to home, tap "Never Have I Ever"
5. Confirm it goes directly to player setup — NOT pack selection
6. Play 3 rounds

**What to check:**
- [ ] Neither WYR nor NHIE show the pack selection screen
- [ ] Both games load their own content correctly
- [ ] No crashes across 3+ rounds of each

---

## SCENARIO 11 — Settings: Full Walkthrough

**Steps:**
1. Open Settings
2. Confirm the background has the dark gradient — not plain grey
3. Confirm each settings tile has a glass card appearance
4. Toggle Sound OFF — go play a game, confirm silence (or no haptic on sound events)
5. Return to settings, toggle Sound ON — confirm sound resumes
6. Toggle Haptics — feel the difference in a game
7. Toggle Haptics back on
8. Tap "Manage Players" — confirm it opens player management screen
9. Add a player, go back, return to Manage Players — confirm the player persists
10. Tap "Clear All Data" — confirm players AND custom packs disappear immediately without restarting
11. Toggle any setting and watch the icon next to it — confirm it pulses

**What to check:**
- [ ] Settings has the dark background gradient
- [ ] All tiles use glass card style
- [ ] Sound toggle takes effect immediately in gameplay
- [ ] Manage Players tile exists and functions correctly
- [ ] Clear All Data removes all data from memory immediately — no app restart needed
- [ ] Setting icons pulse visibly when toggled

---

## SCENARIO 12 — Navigation Consistency

**Steps:**
1. From home, open any game screen and come back — observe the page transition
2. Open 5 different game modes in a row, back-navigating each time
3. Confirm every screen uses the same scale+fade transition (no mix of slide/pop/etc.)
4. Rapidly open and close 3 screens 5 times in a row
5. Press the back button immediately after a screen opens (mid-animation)

**What to check:**
- [ ] Every screen uses the same scale+fade page transition
- [ ] No crash from rapid navigation
- [ ] Back button mid-transition does not freeze the app
- [ ] All back buttons use the standard glass icon style — no exceptions

---

## SCENARIO 13 — Home Screen: Polish Check

**Steps:**
1. Open the app fresh (restart it)
2. Watch the home screen load — confirm the staggered wave card entrance plays
3. Navigate away and back — confirm the entrance does NOT replay on return
4. Scroll through all game cards — confirm every card has a non-empty description
5. Press and hold a game card — confirm it scales down to 0.95
6. Release — confirm it bounces back
7. Watch the Truth or Dare hero card for 10 seconds — confirm the glow orbs slowly drift
8. Look at any GlassCard surface for several seconds — watch for the shimmer sweep

**What to check:**
- [ ] Wave entrance plays on first load only — not on every navigation return
- [ ] All 14 game cards have non-empty descriptions
- [ ] Press-down scale feedback (0.95) on every game card
- [ ] Glow orbs visibly drift — subtle movement, not jarring
- [ ] Shimmer sweep visible on GlassCard surfaces every ~5 seconds

---

## SCENARIO 14 — Stress Test

**Steps:**
1. Play Truth or Dare for 20 rounds straight without leaving
2. Mid-session: go to settings, toggle sound off, return, play 2 more rounds, go back and toggle sound on
3. Add and remove players between rounds
4. Play Bomb Pass 5 times in a row using "Play Again" each time
5. Trigger the FREEZE in Freeze Mode 3 times in one session without leaving

**What to check:**
- [ ] No memory leaks — app does not visibly slow down after extended play
- [ ] Sound toggle change takes effect immediately on returning to the game
- [ ] Player changes reflect in-game without restarting
- [ ] Bomb Pass Play Again works correctly all 5 times in a row
- [ ] Freeze crack animation plays cleanly each of the 3 times
- [ ] Zero `setState after dispose` or null errors appear in the debug console throughout

---

## ISSUE LOG FORMAT

For every issue found during QA, log it using this format before fixing:

```
ISSUE #[number]
Screen:      [screen name]
Scenario:    [scenario number and name]
Severity:    CRASH / VISUAL / LOGIC / PERFORMANCE / POLISH
Found at:    [exact step number where it appeared]
Description: [what happened vs what was expected]
Fix applied: [what was changed to resolve it]
```

---

## QA SIGN-OFF

The app passes QA and is ship-ready when **all** of the following are true:

- [ ] All 14 scenarios completed with zero CRASH or LOGIC severity issues remaining
- [ ] Zero emoji visible anywhere in the entire app
- [ ] Zero `setState after dispose` or null check errors in the debug console
- [ ] Every game mode is playable start-to-finish without developer intervention
- [ ] All page transitions are consistent — same scale+fade on every screen
- [ ] Sound and haptic fire on all key events
- [ ] All 18 animations play at their intended moments without visual glitches
- [ ] `flutter analyze` returns zero errors and zero warnings

---

---

# FINAL VERIFICATION CHECKLIST

> This checklist covers all 10 phases. Every box must be green before any store submission.

---

### Phase 1 — Bugs
- [ ] TextField in `ModePlayerSetupScreen` does not lose focus when typing
- [ ] `BombPassScreen` Play Again resets all state cleanly
- [ ] `FreezeModeScreen`: navigating back mid-game causes no setState errors
- [ ] `GameEngineScreen`: no stale API prompts appearing after Next Player
- [ ] `fetchTruths`/`fetchDares` run in parallel
- [ ] Adding player after removal uses first unused number, not `length+1`
- [ ] Impostor Play Again replays without going to setup
- [ ] `DisclaimerDialog` shows only once per session
- [ ] Clear All Data refreshes `PlayerManager` and `PackManager` in memory
- [ ] Speed challenge timer shows `00:05` not `00:5`
- [ ] Bomb tick accelerates correctly at 15-second fuse
- [ ] Impostor reveal requires a 1-second hold, not a tap
- [ ] Chaos Mode never shows same event twice in a row
- [ ] WYR and NHIE go directly to player setup, not pack selection

### Phase 2 — Sound
- [ ] Wheel spin plays `SoundEvent.spin`
- [ ] Prompt card appearing plays `SoundEvent.cardReveal`
- [ ] Countdown ticks in last 5 seconds of every timer
- [ ] Timer reaching 0 plays `SoundEvent.timerEnd`
- [ ] Bomb explosion plays `SoundEvent.explosion` + heavy haptic
- [ ] Win screens play `SoundEvent.win`
- [ ] All sounds respect the `soundEnabled` preference

### Phases 3–4 — UI & Design
- [ ] Zero emojis in the entire app (search for unicode emoji codepoints)
- [ ] All game cards on home screen show a 1-line description
- [ ] `GlassCard` used consistently across all main content cards
- [ ] Standard back button on every screen
- [ ] Prompt card Next Player button always visible without scrolling
- [ ] Freeze Mode frozen screen text is `truthBlue` not `dareRed`
- [ ] Chaos Mode uses dark background with radial glow, not solid neon scaffold
- [ ] Settings screen has `backgroundGradient`
- [ ] Settings screen has a Manage Players option

### Phase 5 — Animations
- [ ] Home screen cards wave-entrance on first load only
- [ ] Prompt card flips on Y-axis when appearing
- [ ] Player name pops elastically after wheel stop
- [ ] Bomb Pass screen darkens to red as time runs out
- [ ] Impostor reveal shows progress ring on hold
- [ ] Freeze Mode shows crack lines when FREEZE triggers
- [ ] Chaos Mode event slams in with screen shake
- [ ] Eliminated player cards slide off in Last Standing
- [ ] Confetti fires on civilians win and Last Standing winner
- [ ] Speed Challenge card pulses in last 3 seconds
- [ ] Pack selection checkmark draws itself in
- [ ] Settings icon pulses on toggle
- [ ] Player name badge flashes green on save
- [ ] All `Navigator.push` use consistent scale+fade transition
- [ ] Game cards scale down to 0.95 on press-down
- [ ] Glow orbs on home card drift slowly
- [ ] GlassCard shimmer sweeps every 5 seconds
- [ ] Prompt card glow breath drives both border alpha AND box shadow blur

### Phase 7 — Launch Readiness
- [ ] Splash screen displays on cold launch and removes after data loads
- [ ] App icon set and correct on both Android and iOS home screens
- [ ] Onboarding shown on first launch only — never again after dismissal
- [ ] App locked to portrait — no layout breaks on rotation
- [ ] No content clipped by Dynamic Island, notch, or gesture navigation bar
- [ ] `themeMode: ThemeMode.dark` set — no light mode bleed
- [ ] All interactive targets are minimum 48×48dp
- [ ] Every icon-only button has a descriptive `Tooltip`
- [ ] Text with system font size "Largest" does not overflow any container
- [ ] Offline snack bar shown when API unavailable — local prompts used silently
- [ ] Skeleton cards shown while API data loads
- [ ] No raw error messages or stack traces visible to users
- [ ] Session Stats shows truth/dare/skip counts per player
- [ ] Custom pack save blocked with fewer than 5 prompts
- [ ] Skip button on every prompt card — increments shame count
- [ ] Bomb Pass shows current holder name at all times
- [ ] "How to Play" sheet appears first time each game mode is opened
- [ ] Privacy Policy screen accessible from Settings under LEGAL section
- [ ] `FlutterError.onError` + `PlatformDispatcher.instance.onError` set
- [ ] Firebase Crashlytics receiving errors (verify in console)
- [ ] `pubspec.yaml` version set to `2.0.0+1`, `CHANGELOG.md` created
- [ ] Settings version tile reads from `PackageInfo` — no hardcoded string

### Phase 8 — Multiplayer
- [ ] Room code displays as 6 large digit boxes in lobby
- [ ] Players appear in lobby within 2 seconds of joining
- [ ] Start button disabled until minimum player count met
- [ ] Both devices navigate to game simultaneously on Start
- [ ] Only the current player's device has active action buttons
- [ ] All devices show the same prompt at the same time (within 1–2 seconds)
- [ ] Dropped player removed from active list within ~10 seconds
- [ ] Host leaving ends the game for all devices and deletes the room
- [ ] Secret Mission: no player ever sees another player's mission
- [ ] Secret Mission: timer synced across all devices within 1 second
- [ ] Secret Mission: Play Again fully resets all mission data

### Phase 9 — Hardening
- [ ] Back gesture on every game screen shows "Leave Game?" dialog — never exits silently
- [ ] Start button disabled with clear message when player count is below mode minimum
- [ ] All inline `HapticFeedback.*` calls replaced — zero raw haptic calls outside `HapticService`
- [ ] Share button on prompt cards — native share sheet opens correctly
- [ ] App rating prompt appears after exactly the 3rd completed session — never twice
- [ ] Keyboard opening does not cover the player list or start button on setup screens
- [ ] All 5 unit test files pass with `flutter test`
- [ ] `storage_version` key written to `SharedPreferences` on first launch
- [ ] All `SharedPreferences` key strings replaced with named constants

### Phase 10 — Advanced Features
- [ ] Every player has a visible avatar (icon + color) throughout the entire app
- [ ] Avatar picker opens on tap — all 8 options shown — selection updates immediately
- [ ] Every game screen has its own distinct background gradient and glow color
- [ ] Custom prompt "+" button appears during T&D game — prompt used immediately, not saved
- [ ] Highlights reel shows after every game with correct per-player stats
- [ ] Sound theme picker visible in Settings — "Retro" and "Cinematic" options present
- [ ] Prompt difficulty rating UI slides up after each prompt before advancing
- [ ] Haptic theme picker visible in Settings — "Subtle" lighter, "Intense" heavier
- [ ] On tablets (shortestSide >= 600dp): home shows 3-column grid, game shows two-column layout
- [ ] Auto-advance toggle in Settings — prompt advances without tap when enabled
- [ ] Joining a game in progress shows "Watch as Spectator" option
- [ ] Spectators see the full game in read-only mode with "Request to Join" button
- [ ] Host migration fires within ~10 seconds when host disconnects
- [ ] During a dare, non-active players see the vote panel with 10-second countdown
- [ ] Dropped player can rejoin using same name + original room code
- [ ] After a game ends, host can change mode without kicking players from the room
- [ ] Host lobby shows QR icon — tapping opens scannable QR code
- [ ] Joiner screen has "Scan QR Code instead" — camera opens and auto-fills code
- [ ] Platform badge (iPhone/Android icon) visible next to each player name in lobby

---

# PHASE 7 — POLISH, PLATFORM & LAUNCH READINESS

> This phase covers everything needed before submitting to the App Store or Google Play. Complete Phases 1–6 first. Items are grouped by category. Every item is required for a production-quality release.

---

## 7A — APP STORE & LAUNCH

---

### ITEM 1 — Splash Screen & App Icon

**Packages to add:**
```yaml
flutter_native_splash: ^2.4.0
flutter_launcher_icons: ^0.14.1
```

**Splash screen — File to create:** `flutter_native_splash.yaml` (project root)

```yaml
flutter_native_splash:
  color: "#05030F"
  image: assets/images/splash_logo.png
  android_12:
    color: "#05030F"
    image: assets/images/splash_logo.png
  web: false
```

**Implementation steps:**
- Create `assets/images/` directory
- Place a `splash_logo.png` (the Cousin Chaos logo / icon, 512×512px, transparent background, neon purple)
- Place `icon.png` (1024×1024px, same design with solid dark background) for the launcher icon
- Add to `pubspec.yaml` assets section: `- assets/images/`
- Run `dart run flutter_native_splash:create`
- Run `dart run flutter_launcher_icons`

**In `main.dart`:**
```dart
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // ... existing setup ...
  runApp(const CousinChaosApp());
}

// In the first screen's initState, after data is loaded:
FlutterNativeSplash.remove();
```

---

### ITEM 2 — Onboarding Flow (shown once, first launch only)

**File to create:** `lib/screens/onboarding/onboarding_screen.dart`

**Behaviour:**
- Shown automatically on first launch, before the home screen
- 3 slides, swipeable, skippable
- After completion or skip: sets `PreferencesService.hasSeenOnboarding = true`
- Never shown again after that

**Slide content:**

| Slide | Icon | Title | Body |
|---|---|---|---|
| 1 | `Icons.groups_rounded` | Welcome to Cousin Chaos | The ultimate party game collection. 15 games, infinite chaos. |
| 2 | `Icons.touch_app_rounded` | Pick a Game, Pass the Phone | Choose from Truth or Dare, Impostor Mode, Bomb Pass and more. Everyone plays. |
| 3 | `Icons.celebration_rounded` | House Rules Apply | All games are played together in one room. No accounts, no ads, just chaos. |

**Implementation:**
- Add `bool hasSeenOnboarding` to `PreferencesService` backed by `SharedPreferences`
- In `main.dart` or the first `MaterialApp` route, check `hasSeenOnboarding`:
  ```dart
  home: prefs.hasSeenOnboarding ? const HomeScreen() : const OnboardingScreen(),
  ```
- Each slide uses `GlassCard` for the content container
- Bottom row: page dots + "Skip" text button on left + "Next" / "Let's Go" button on right
- "Let's Go" on slide 3 sets `hasSeenOnboarding = true` and navigates to `HomeScreen`
- Apply `slideUpRoute` page transition

---

### ITEM 3 — Demo Mode for App Store Screenshots

**File to create:** `lib/core/demo/demo_data.dart`

**What:** A static set of pre-filled data used exclusively for taking App Store screenshots. Activated by a hidden gesture (triple-tap the version number in Settings).

**Implementation:**
- `DemoData` class with static fields:
  ```dart
  static const List<String> playerNames = ['Alex', 'Jordan', 'Sam', 'Riley'];
  static const String demoTruthPrompt = 'What is the most embarrassing thing you\'ve done in public?';
  static const String demoDarePrompt = 'Do your best impression of someone in this room.';
  static const String demoImpostorWord = 'Swimming Pool';
  ```
- In `settings_screen.dart`, wrap the version tile in a `GestureDetector` with `onDoubleTap`:
  ```dart
  // Toggle DemoMode.enabled = true — log to console only, no visible UI
  ```
- In `GameEngineScreen`, `ImpostorGameScreen`, if `DemoMode.enabled`, skip API calls and return `DemoData` values directly
- This is a developer tool only — never shown to real users

---

## 7B — PLATFORM & DEVICE

---

### ITEM 4 — Lock to Portrait Mode

**File:** `lib/main.dart`

**Problem:** If a player accidentally rotates the phone mid-game, nearly every screen will break — particularly the wheel, prompt card, and bomb pass layouts.

**Fix — Add to `main()` before `runApp()`:**
```dart
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
]);
```

This is a one-line fix. Do it before anything else in Phase 7.

---

### ITEM 5 — Safe Area Audit

**Problem:** Several screens use hardcoded padding that clips on iPhone 15 Pro (Dynamic Island), notched Android devices, and phones with gesture navigation bars.

**Files to audit and fix:**

| File | Issue | Fix |
|---|---|---|
| `home_screen.dart` | Header top padding hardcoded | Wrap header in `SafeArea(bottom: false)` |
| `game_engine_screen.dart` | Bottom button padding fixed | Use `MediaQuery.of(context).padding.bottom + 16` |
| `prompt_card.dart` | Footer button clips on gesture bar | Add `SafeArea(top: false)` around the pinned footer button |
| `bomb_pass_screen.dart` | Explosion screen bottom content clips | Wrap in `SafeArea` |
| All game screens | AppBar may overlap status bar | Ensure `Scaffold` has `appBar` or explicit `SafeArea(bottom: false)` on body |

**Rule for all screens going forward:** Never use a hardcoded top padding less than `MediaQuery.of(context).padding.top`. Never use a hardcoded bottom padding less than `MediaQuery.of(context).padding.bottom`.

---

### ITEM 6 — Force Dark Mode

**File:** `lib/main.dart`

**Problem:** The app is hardcoded dark in its theme but does not explicitly tell Flutter to ignore the system theme. On some devices with accessibility overrides, `ThemeMode.system` can cause light-mode bleed.

**Fix — In `MaterialApp`:**
```dart
MaterialApp(
  themeMode: ThemeMode.dark,   // ADD THIS
  theme: AppTheme.lightTheme,  // keep existing
  darkTheme: AppTheme.darkTheme,
  // ...
)
```

If `AppTheme.lightTheme` does not exist, create a minimal one that mirrors the dark theme. The `themeMode: ThemeMode.dark` line is what matters — it forces dark regardless of system setting.

---

## 7C — ACCESSIBILITY

---

### ITEM 7 — Minimum Tap Target Sizes

**Problem:** Several icon-only buttons are smaller than the required 48×48dp minimum tap target.

**Files and locations to fix:**

```dart
// Wrap every small IconButton or GestureDetector with:
SizedBox(
  width: 48,
  height: 48,
  child: /* your button widget */,
)
```

**Specific locations:**
- Back button container in every screen (currently `padding: 8` = ~34dp)
- Player delete icon in `player_setup_screen.dart`
- Pack deselect/select icons in `pack_selection_screen.dart`
- Settings tile trailing icons in `settings_screen.dart`
- Player eliminate button in `last_standing_screen.dart`

---

### ITEM 8 — Semantic Labels on Icon-Only Buttons

**Problem:** After removing all emoji and replacing with icons, every icon-only button is invisible to screen readers.

**Fix — Add `Tooltip` to every icon-only interactive widget:**

```dart
// Every IconButton that has no visible text label:
Tooltip(
  message: 'Go back',
  child: IconButton(
    onPressed: () => Navigator.pop(context),
    icon: /* glass back button */,
  ),
)
```

**All labels to add:**

| Button | Tooltip message |
|---|---|
| Back button | `'Go back'` |
| Settings gear | `'Open settings'` |
| Player delete (×) | `'Remove player'` |
| Add player (+) | `'Add player'` |
| Pack select toggle | `'Select pack'` / `'Deselect pack'` |
| Sound toggle | `'Toggle sound'` |
| Haptics toggle | `'Toggle haptics'` |
| Eliminate player | `'Eliminate player'` |
| Next event (Chaos) | `'Next event'` |

---

### ITEM 9 — Text Scale Overflow Protection

**Problem:** If the system font size is set to "Large" or "Largest", `Text` widgets inside fixed-height containers (buttons, badges, card headers) will overflow and throw RenderFlex errors.

**Fix — Two approaches, apply both:**

**A) Clamp text scale factor app-wide in `MaterialApp`:**
```dart
builder: (context, child) {
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(
        MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
      ),
    ),
    child: child!,
  );
},
```

**B) On any Text inside a fixed-height container, add:**
```dart
Text(
  label,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  // ...
)
```

Apply `maxLines: 1, overflow: TextOverflow.ellipsis` to: all button labels, all badge texts, all player name displays, all game card titles and descriptions.

---

## 7D — NETWORK & OFFLINE

---

### ITEM 10 — Offline Fallback UI

**Files:** `lib/services/api_service.dart` + `lib/screens/truth_or_dare/game_engine_screen.dart`

**Problem:** When the API fails, the app shows a spinner forever or throws a raw error. The local deck fallback already exists in `GameEngineScreen` — it just isn't surfaced to the user.

**Fix — In `api_service.dart`:**
```dart
// Create a custom exception:
class NoConnectionException implements Exception {
  final String message;
  const NoConnectionException([this.message = 'No internet connection']);
}

// In every fetch method, wrap socket/http errors:
on SocketException catch (_) {
  throw const NoConnectionException();
}
```

**Fix — In `game_engine_screen.dart`, in the catch block of `_fetchSinglePrompt()`:**
```dart
catch (e) {
  if (e is NoConnectionException && _localDeck.isNotEmpty) {
    // Already falls back to local — show a one-time snack bar:
    if (!_hasShownOfflineNotice) {
      _hasShownOfflineNotice = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No connection — using local prompts'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
```

Add `bool _hasShownOfflineNotice = false;` to `_GameEngineScreenState`.

---

### ITEM 11 — Loading Skeleton Screens

**File to create:** `lib/core/widgets/skeleton_card.dart`

**Problem:** While `fetchTruths()`/`fetchDares()` runs (even in parallel), there's a raw spinner. Replace spinners with shimmer skeleton cards that match the shape of the real content.

**Implementation:**
```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SkeletonCard extends StatefulWidget {
  final double height;
  final double borderRadius;
  const SkeletonCard({super.key, this.height = 120, this.borderRadius = 20});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 1200.ms)
      ..repeat(reverse: true);
    _shimmer = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withAlpha((_shimmer.value * 255).toInt()),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
```

**Where to use:**
- `game_engine_screen.dart`: while `_isLoading` is true, show `SkeletonCard(height: 200)` where the prompt card would appear
- `pack_selection_screen.dart`: while packs are loading, show 4× `SkeletonCard(height: 80)` in the list

---

### ITEM 12 — User-Friendly API Error Messages

**File:** `lib/services/api_service.dart` + all screens that call it

**Problem:** Raw exception strings or HTTP status codes can surface in the UI. All `catch` blocks must show user-friendly messages.

**Fix — Create a central error message mapper:**
```dart
// In api_service.dart:
static String friendlyError(dynamic error) {
  if (error is NoConnectionException) return 'No internet connection. Check your Wi-Fi or mobile data.';
  if (error is TimeoutException) return 'The server took too long to respond. Try again.';
  return 'Something went wrong. Please try again.';
}
```

**In every screen catch block, replace:**
```dart
// BEFORE:
catch (e) { setState(() => _error = e.toString()); }

// AFTER:
catch (e) { setState(() => _error = ApiService.friendlyError(e)); }
```

**Screens to audit for raw error display:**
- `game_engine_screen.dart`
- `pack_selection_screen.dart`
- `standalone_game_screen.dart`
- Any screen with a `_error` state variable

---

## 7E — GAMEPLAY FEATURES

---

### ITEM 13 — Session Score Tally

**File to create:** `lib/services/session_stats_service.dart`

**What:** Tracks how many truths and dares each player completed in a session. Shown as a summary screen when the game ends or the user taps a new "Stats" button on the game engine screen.

**Implementation:**

```dart
class SessionStatsService extends ChangeNotifier {
  final Map<String, int> _truths = {};
  final Map<String, int> _dares = {};

  void recordTruth(String playerId) {
    _truths[playerId] = (_truths[playerId] ?? 0) + 1;
    notifyListeners();
  }

  void recordDare(String playerId) {
    _dares[playerId] = (_dares[playerId] ?? 0) + 1;
    notifyListeners();
  }

  int truthCount(String playerId) => _truths[playerId] ?? 0;
  int dareCount(String playerId) => _dares[playerId] ?? 0;
  int totalCount(String playerId) => truthCount(playerId) + dareCount(playerId);

  void reset() { _truths.clear(); _dares.clear(); notifyListeners(); }
}
```

- Register in `main.dart` `MultiProvider`
- Call `sessionStats.recordTruth(currentPlayer.id)` / `recordDare(...)` in `game_engine_screen.dart` when a prompt is served
- Add a "Session Stats" icon button to the `game_engine_screen.dart` AppBar
- Tapping it shows a `BottomSheet` with a list of each player's truth/dare counts and total
- Stats reset when a new game session starts (`_initGame()` calls `sessionStats.reset()`)

---

### ITEM 14 — Custom Pack Validation

**File:** wherever custom packs are created/edited (custom pack creator screen)

**Problem:** The custom pack input has no limits. Users can save empty packs, packs with duplicate prompts, or prompts that are thousands of characters long.

**Validation rules to enforce:**
```dart
// Minimum prompts before saving:
const int kMinPromptsToSave = 5;

// Maximum prompt character length:
const int kMaxPromptLength = 280;

// Before saving, run all checks:
bool _validatePack() {
  if (_prompts.length < kMinPromptsToSave) {
    _showError('Add at least $kMinPromptsToSave prompts before saving.');
    return false;
  }

  final duplicates = _prompts.where((p) =>
    _prompts.where((q) => q.trim().toLowerCase() == p.trim().toLowerCase()).length > 1
  ).toList();
  if (duplicates.isNotEmpty) {
    _showError('Remove duplicate prompts before saving.');
    return false;
  }

  final tooLong = _prompts.where((p) => p.length > kMaxPromptLength).toList();
  if (tooLong.isNotEmpty) {
    _showError('One or more prompts exceed $kMaxPromptLength characters.');
    return false;
  }

  return true;
}
```

- Add a live character counter under each prompt input field: `"${prompt.length} / 280"`
- Counter turns `dareRed` when over 240 characters as a warning
- The save button is disabled (greyed out) until `_prompts.length >= 5`

---

### ITEM 15 — Skip Prompt (with shame points)

**File:** `lib/screens/truth_or_dare/widgets/prompt_card.dart` + `lib/services/session_stats_service.dart`

**What:** A "Skip" option appears on every prompt card. Using it adds a visible shame counter to that player's tally. One skip per turn maximum.

**Implementation:**
- Add `int _skips = {};` map to `SessionStatsService`:
  ```dart
  void recordSkip(String playerId) {
    _skips[playerId] = (_skips[playerId] ?? 0) + 1;
    notifyListeners();
  }
  int skipCount(String playerId) => _skips[playerId] ?? 0;
  ```
- In `prompt_card.dart`, add a secondary `TextButton` below the "Next Player" footer:
  ```dart
  TextButton.icon(
    onPressed: onSkip,  // callback to parent
    icon: Icon(Icons.skip_next_rounded, color: AppColors.textMuted, size: 18),
    label: Text(
      'Skip (+1 shame)',
      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
    ),
  )
  ```
- In `game_engine_screen.dart`, `onSkip` callback: calls `sessionStats.recordSkip(currentPlayer.id)` then advances to next player without recording a truth or dare
- Shame count shows in the Session Stats bottom sheet alongside truth/dare counts
- Skip button is only shown once per card — after tapping it moves to next player and cannot be undone

---

### ITEM 16 — Bomb Pass: Current Holder Display

**File:** `lib/screens/new_modes/bomb_pass_screen.dart`

**Problem:** There is no indication of whose turn it is to hold the phone between passes. Players get confused about who currently has it.

**Implementation:**
- Add `int _currentHolderIndex = 0;` to `_BombPassScreenState`
- Add a "PASS" button during active gameplay that increments `_currentHolderIndex` cycling through the players list
- Display at the top of the active game screen:
  ```dart
  // In a GlassCard above the bomb:
  Row(children: [
    Icon(Icons.person_rounded, color: AppColors.neonYellow, size: 16),
    SizedBox(width: 8),
    Text('Currently with:', style: /* muted */),
    SizedBox(width: 6),
    Text(players[_currentHolderIndex].name, style: /* bold white */),
  ])
  ```
- When the bomb explodes, the loser is automatically `players[_currentHolderIndex]`
- The name display animates with `flutter_animate` `.fadeIn().slideY()` when the holder changes

---

### ITEM 17 — "How to Play" Per Game Mode

**File to create:** `lib/core/widgets/how_to_play_sheet.dart`

**What:** A bottom sheet shown the first time a user enters each game mode. Dismissed with "Got it, let's go!". Never shown again for that mode after the first time.

**Storage:** Use `PreferencesService` — add `Set<String> seenHowToPlay` backed by `SharedPreferences` as a comma-separated string.

**Implementation:**
```dart
class HowToPlaySheet extends StatelessWidget {
  final String gameMode;
  final String title;
  final List<HowToPlayStep> steps;
  final VoidCallback onDismiss;

  // ...

  static Future<void> showIfNeeded(
    BuildContext context,
    String gameMode,
    List<HowToPlayStep> steps,
  ) async {
    final prefs = context.read<PreferencesService>();
    if (prefs.hasSeenHowToPlay(gameMode)) return;
    await prefs.markHowToPlaySeen(gameMode);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HowToPlaySheet(gameMode: gameMode, steps: steps, ...),
    );
  }
}

class HowToPlayStep {
  final IconData icon;
  final String title;
  final String body;
}
```

**Call in `initState()` of each game screen:**
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  HowToPlaySheet.showIfNeeded(context, 'impostor', _impostorSteps);
});
```

**How to Play content per mode:**

| Mode | Steps |
|---|---|
| Impostor | 1. Each player secretly sees a word or "IMPOSTOR". 2. Discuss without giving it away. 3. Vote for who you think the impostor is. 4. Impostor wins if they survive the vote. |
| Chaos Mode | 1. A random event appears on screen. 2. Everyone must do it immediately. 3. Tap for the next event whenever ready. 4. Last one to comply loses a point. |
| Bomb Pass | 1. A bomb is ticking — complete the task shown. 2. Pass the phone to the next player. 3. Whoever holds it when it explodes loses. 4. No peeking at the timer! |
| Last Standing | 1. Everyone is in. 2. Complete each round's challenge. 3. Fail and you're eliminated. 4. Last player standing wins. |
| Freeze Mode | 1. Play normally until the screen flashes FREEZE. 2. Everyone must stop moving immediately. 3. Last to freeze gets a penalty. 4. Resume when the screen unfreezes. |
| Speed Challenge | 1. A challenge appears with a countdown timer. 2. Complete it before time runs out. 3. Fail and you're out for that round. |
| Target Player | 1. Spin the wheel. 2. Whoever it lands on must complete the task. 3. No arguing with the wheel. |
| Laugh Attack | 1. Try to make the current player laugh. 2. If they laugh, they get a point against them. 3. Keep a straight face to survive. |
| Secret Mission | 1. You have a secret goal. 2. Complete it without anyone noticing. 3. If you're caught, you lose. |
| Act It Out | 1. Act out the prompt — no talking, no sounds. 2. Your team guesses within the time limit. 3. No guessing = no point. |

---

## 7F — PRIVACY & LEGAL

---

### ITEM 18 — Privacy Policy Screen

**File to create:** `lib/screens/settings/privacy_policy_screen.dart`

**What:** A simple scrollable screen showing the privacy policy. Accessible from a Settings tile. Required by Apple App Store and Google Play.

**Implementation:**
- Add a "Privacy Policy" tile to `settings_screen.dart` under a new "LEGAL" section header
- `onTap` navigates to `PrivacyPolicyScreen`
- `PrivacyPolicyScreen` is a `Scaffold` with `SingleChildScrollView` containing the policy text
- Apply the dark background gradient and the standard glass back button
- The policy text must cover at minimum:
  - What data is collected (API calls are made — no user data is stored on servers)
  - That no personal information is collected or sold
  - Third-party services used (name the API provider if applicable)
  - Contact email for privacy questions
- Host the policy at a URL too (required by stores) and add a `TextButton` at the bottom: "View online" that opens the URL using `url_launcher` package

**Package to add:**
```yaml
url_launcher: ^6.3.1
```

---

## 7G — CODE QUALITY

---

### ITEM 19 — Global Error Handler

**File:** `lib/main.dart`

**Problem:** Unhandled Flutter exceptions show the red error screen to users in release builds.

**Fix — Add to `main()` before `runApp()`:**
```dart
FlutterError.onError = (FlutterErrorDetails details) {
  // In debug mode: print the full error
  if (kDebugMode) {
    FlutterError.presentError(details);
    return;
  }
  // In release mode: show a friendly error screen
  // Log to crash reporting here (see Item 20)
};

PlatformDispatcher.instance.onError = (error, stack) {
  // Catch async errors not caught by FlutterError.onError
  if (kDebugMode) debugPrint('Async error: $error');
  return true; // returning true prevents the error from propagating
};
```

**File to create:** `lib/screens/error/error_screen.dart`

```dart
class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({super.key, this.message = 'Something went wrong.'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: GlassCard(
          accentColor: AppColors.dareRed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.dareRed, size: 48),
              const SizedBox(height: 16),
              Text('Oops!', style: /* bold large white */),
              const SizedBox(height: 8),
              Text(message, style: /* muted */),
              const SizedBox(height: 24),
              // Standard action button:
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  slideUpRoute(const HomeScreen()), (_) => false,
                ),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### ITEM 20 — Crash Reporting (Firebase Crashlytics)

**Packages to add:**
```yaml
firebase_core: ^3.13.0
firebase_crashlytics: ^4.3.4
```

**Setup steps:**
1. Create a Firebase project at console.firebase.google.com
2. Add Android and iOS apps to the project
3. Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Follow FlutterFire CLI setup: `dart pub global activate flutterfire_cli && flutterfire configure`

**In `main.dart`:**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Pass all Flutter errors to Crashlytics:
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const CousinChaosApp());
}
```

> **Note:** Firebase setup requires platform-specific native config files. The AI cannot generate these — the developer must create the Firebase project and download the config files manually. The AI should add the Dart/Flutter code only and leave a `// TODO: Add google-services.json and GoogleService-Info.plist` comment in `main.dart`.

---

### ITEM 21 — Version Bump Strategy

**File:** `pubspec.yaml`

**Current version:** likely `1.0.0+1`

**Convention to follow:**
```yaml
# Format: major.minor.patch+buildNumber
# major: breaking change or full redesign (what this plan is)
# minor: new feature added
# patch: bug fix only
# buildNumber: increments on every single store upload — never reuse

version: 2.0.0+1   # Set to 2.0.0 because this plan is a full redesign
```

**Rules:**
- The build number (`+1`) must be higher than the previous upload on every store submission — never reuse a build number
- Add a `CHANGELOG.md` to the project root documenting what changed in each version
- In `settings_screen.dart`, use `package_info_plus` to read and display the version dynamically instead of a hardcoded string:

**Package to add:**
```yaml
package_info_plus: ^8.3.0
```

```dart
// In settings_screen.dart initState():
final info = await PackageInfo.fromPlatform();
setState(() => _version = '${info.version} (${info.buildNumber})');
```

---

---

# UPDATED PUBSPEC.YAML — ALL NEW PACKAGES

```yaml
# ADD all of these (check none are already present before adding):
flutter_native_splash: ^2.4.0    # Splash screen
flutter_launcher_icons: ^0.14.1  # App icon
confetti: ^0.8.0                  # Win screen confetti
flutter_animate: ^4.5.0           # Animation chaining
url_launcher: ^6.3.1              # Privacy policy link
firebase_core: ^3.13.0            # Crash reporting
firebase_crashlytics: ^4.3.4      # Crash reporting
package_info_plus: ^8.3.0         # Version display in settings

# ALREADY PRESENT — DO NOT ADD AGAIN:
# audioplayers: ^6.6.0
# animate_do: ^5.1.0
# google_fonts: ^8.1.0
# provider: ^6.1.5+1
# shared_preferences: ^2.5.5
# flutter_fortune_wheel: ^1.3.2
# uuid: ^4.5.3
# http: ^1.6.0
```


### Launch Readiness (Phase 7)

**App Store & Launch:**
- [ ] Splash screen displays on cold launch and removes after data loads
- [ ] App icon is set and shows correctly on Android and iOS home screens
- [ ] Onboarding shown on first launch only — never again after "Got it"
- [ ] Demo mode accessible via triple-tap on version number in settings
- [ ] App Store screenshots taken using demo mode pre-filled data

**Platform & Device:**
- [ ] App is locked to portrait mode — no layout breaks on rotation
- [ ] No content clipped by Dynamic Island, notch, or gesture navigation bar
- [ ] `SafeArea` applied to all screens — top and bottom
- [ ] `themeMode: ThemeMode.dark` set in `MaterialApp` — no light mode bleed

**Accessibility:**
- [ ] All interactive targets are at minimum 48×48dp
- [ ] Every icon-only button has a `Tooltip` with a descriptive label
- [ ] Text with system font size "Largest" does not overflow any container
- [ ] All button and card text uses `maxLines: 1, overflow: TextOverflow.ellipsis`

**Network & Offline:**
- [ ] App shows "No connection — using local prompts" snack bar when offline
- [ ] Skeleton loading cards show while API data is fetching
- [ ] No raw error messages, stack traces, or HTTP status codes visible to users
- [ ] All catch blocks use `ApiService.friendlyError(e)` for display

**Gameplay Features:**
- [ ] Session Stats shows truth/dare/skip counts per player after rounds
- [ ] Custom pack cannot be saved with fewer than 5 prompts
- [ ] Custom pack shows live character counter — turns red over 240 chars
- [ ] Save button disabled until minimum prompt count is met
- [ ] Skip button appears on every prompt card
- [ ] Skip increments shame count in Session Stats
- [ ] Bomb Pass shows "Currently with: [Player Name]" at all times during game
- [ ] Holder name animates when the phone is passed
- [ ] "How to Play" bottom sheet appears the first time each game mode is opened
- [ ] "How to Play" never appears again after first dismissal per mode

**Privacy & Legal:**
- [ ] Privacy Policy screen accessible from Settings under "LEGAL" section
- [ ] "View online" button in Privacy Policy screen opens the hosted URL
- [ ] Privacy policy covers: data collected, no personal data sold, third-party services, contact email

**Code Quality:**
- [ ] `FlutterError.onError` set in `main.dart` — no red error screen in release
- [ ] `PlatformDispatcher.instance.onError` set — async errors caught
- [ ] Friendly `ErrorScreen` shown on unhandled exceptions with "Back to Home" button
- [ ] Firebase Crashlytics configured and receiving errors (verify in Firebase console)
- [ ] `TODO` comment left for developer to add `google-services.json` and `GoogleService-Info.plist`
- [ ] `pubspec.yaml` version set to `2.0.0+1`
- [ ] `CHANGELOG.md` created in project root
- [ ] Settings version tile reads from `PackageInfo` dynamically — no hardcoded string

---

# PHASE 8 — MULTIPLAYER ROOM SYSTEM

> This is the largest phase. Complete Phases 1–7 fully before starting Phase 8. The multiplayer system introduces Firebase Realtime Database and Firebase Anonymous Auth. The Firebase project already exists from Phase 7G (Crashlytics) — add the new services to the same project.

---

## OVERVIEW

**How it works:**
- The **host** creates a room, picks a game mode and packs, gets a 6-digit code
- **Joiners** tap "Join Room", enter their name (never saved), enter the code, land in the lobby
- Host taps "Start" — all phones transition to the game simultaneously
- Every phone shows the **same game state in real time** via Firebase listeners
- The **current player's phone** has active controls; all others are in watch mode
- If a player drops they are removed silently and the game continues

**Multiplayer-supported modes:**
| Mode | Supported | Reason if not |
|---|---|---|
| Truth or Dare | ✅ | Core mode, perfect fit |
| Would You Rather | ✅ | Works great remotely |
| Never Have I Ever | ✅ | Works great remotely |
| Trivia Battle | ✅ | Works great remotely |
| Impostor Mode | ✅ | Each phone shows own role secretly |
| Last Standing | ✅ | Elimination works across devices |
| Chaos Mode | ✅ | All phones show same chaos event |
| Bomb Pass | ❌ | Requires physically passing one phone |
| Freeze Mode | ❌ | Requires one shared screen |
| Act It Out | ❌ | Physical performance |
| Speed Challenge | ❌ | Single device timing |
| Laugh Attack | ❌ | Physical reaction |
| Target Player | ❌ | Single phone spin |
| Secret Mission | ❌ | Secret per-device reveal |
| Random Challenge | ❌ | Single device |

---

## FIREBASE SETUP

**Packages to add to `pubspec.yaml`:**
```yaml
firebase_database: ^11.1.6   # Realtime Database
firebase_auth: ^5.5.2        # Anonymous auth for player UIDs
```

**Firebase console steps (developer must do manually — AI adds Dart code only):**
1. Go to the existing Firebase project (created in Phase 7G)
2. Enable **Realtime Database** — start in **test mode** initially
3. Enable **Authentication → Anonymous** sign-in method
4. Set Realtime Database rules:
```json
{
  "rules": {
    "rooms": {
      "$roomCode": {
        ".read": true,
        ".write": "auth != null"
      }
    }
  }
}
```
5. Leave a `// TODO: Tighten Firebase rules before production release` comment in `room_service.dart`

**In `main.dart` — initialize Anonymous Auth after Firebase.initializeApp():**
```dart
// After Firebase.initializeApp():
await FirebaseAuth.instance.signInAnonymously();
```
This gives every device a unique UID without any sign-in screen. The UID is used as the player's identifier inside room data.

---

## FIREBASE DATA STRUCTURE

```
rooms/
  {roomCode}/                         ← 6-digit string e.g. "482913"
    hostUid: "uid_abc123"
    mode: "truth_or_dare"             ← snake_case mode identifier
    packs: ["classic", "spicy"]       ← list of selected pack IDs
    status: "lobby"                   ← "lobby" | "playing" | "ended"
    createdAt: 1716000000000          ← Unix ms timestamp
    gameState/
      currentPlayerUid: "uid_abc123"  ← whose turn it is
      currentType: "truth"            ← "truth" | "dare" | null
      currentPrompt: "..."            ← prompt text currently shown
      roundNumber: 1                  ← increments each round
      playerOrder: ["uid1","uid2"]    ← ordered list used for turn rotation
    players/
      {playerUid}/
        name: "Alex"
        isHost: true
        joinedAt: 1716000000000
        isActive: true                ← set false on disconnect
```

**Key rules:**
- Room codes are always 6-digit strings stored as the key — never as a field
- `gameState` node is written only by the host's device
- `players/{uid}` node is written only by that player's device
- `isActive` is managed via Firebase `onDisconnect()` hooks

---

## NEW FILES TO CREATE

```
lib/
  core/
    models/
      room.dart                        ← Room data model
      room_player.dart                 ← RoomPlayer data model
  services/
    room_service.dart                  ← All Firebase room logic
  screens/
    multiplayer/
      create_room_screen.dart          ← Host flow: pick mode + packs → get code
      join_room_screen.dart            ← Joiner flow: enter name → enter code
      lobby_screen.dart                ← Waiting room for both host and joiners
      multiplayer_game_screen.dart     ← The actual game (all modes unified)
      widgets/
        player_list_tile.dart          ← Reusable player row for lobby
        watch_mode_overlay.dart        ← "Watching" banner for non-active players
        multiplayer_prompt_card.dart   ← Prompt card adapted for multiplayer
        room_code_display.dart         ← Styled 6-digit code widget
```

---

## FILE: `lib/core/models/room_player.dart`

```dart
class RoomPlayer {
  final String uid;
  final String name;
  final bool isHost;
  final bool isActive;
  final int joinedAt;

  const RoomPlayer({
    required this.uid,
    required this.name,
    required this.isHost,
    required this.isActive,
    required this.joinedAt,
  });

  factory RoomPlayer.fromMap(String uid, Map<dynamic, dynamic> map) {
    return RoomPlayer(
      uid: uid,
      name: map['name'] as String? ?? 'Player',
      isHost: map['isHost'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      joinedAt: map['joinedAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'isHost': isHost,
    'isActive': isActive,
    'joinedAt': joinedAt,
  };
}
```

---

## FILE: `lib/core/models/room.dart`

```dart
class GameState {
  final String currentPlayerUid;
  final String currentType;       // "truth" | "dare" | ""
  final String currentPrompt;
  final int roundNumber;
  final List<String> playerOrder;

  const GameState({
    required this.currentPlayerUid,
    required this.currentType,
    required this.currentPrompt,
    required this.roundNumber,
    required this.playerOrder,
  });

  factory GameState.fromMap(Map<dynamic, dynamic> map) {
    return GameState(
      currentPlayerUid: map['currentPlayerUid'] as String? ?? '',
      currentType: map['currentType'] as String? ?? '',
      currentPrompt: map['currentPrompt'] as String? ?? '',
      roundNumber: map['roundNumber'] as int? ?? 1,
      playerOrder: List<String>.from(map['playerOrder'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'currentPlayerUid': currentPlayerUid,
    'currentType': currentType,
    'currentPrompt': currentPrompt,
    'roundNumber': roundNumber,
    'playerOrder': playerOrder,
  };
}

class Room {
  final String code;
  final String hostUid;
  final String mode;
  final List<String> packs;
  final String status;            // "lobby" | "playing" | "ended"
  final int createdAt;
  final Map<String, RoomPlayer> players;
  final GameState? gameState;

  const Room({
    required this.code,
    required this.hostUid,
    required this.mode,
    required this.packs,
    required this.status,
    required this.createdAt,
    required this.players,
    this.gameState,
  });

  factory Room.fromMap(String code, Map<dynamic, dynamic> map) {
    final playersMap = map['players'] as Map<dynamic, dynamic>? ?? {};
    final players = playersMap.map((uid, data) =>
      MapEntry(uid as String, RoomPlayer.fromMap(uid, data)));

    return Room(
      code: code,
      hostUid: map['hostUid'] as String? ?? '',
      mode: map['mode'] as String? ?? 'truth_or_dare',
      packs: List<String>.from(map['packs'] ?? []),
      status: map['status'] as String? ?? 'lobby',
      createdAt: map['createdAt'] as int? ?? 0,
      players: players,
      gameState: map['gameState'] != null
          ? GameState.fromMap(map['gameState'])
          : null,
    );
  }

  List<RoomPlayer> get activePlayers =>
    players.values.where((p) => p.isActive).toList()
      ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
}
```

---

## FILE: `lib/services/room_service.dart`

```dart
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/models/room.dart';
import '../core/models/room_player.dart';

// TODO: Tighten Firebase rules before production release

class RoomService {
  static final RoomService instance = RoomService._internal();
  RoomService._internal();

  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser!.uid;

  // ── Code generation ────────────────────────────────────────────────────────

  String _generateCode() {
    final rng = Random.secure();
    // Generate 6-digit code, avoid codes starting with 0
    int code = 100000 + rng.nextInt(900000);
    return code.toString();
  }

  Future<String> _uniqueCode() async {
    String code;
    bool exists;
    do {
      code = _generateCode();
      final snap = await _db.child('rooms/$code').get();
      exists = snap.exists;
    } while (exists);
    return code;
  }

  // ── Create room ────────────────────────────────────────────────────────────

  Future<String> createRoom({
    required String mode,
    required List<String> packs,
    required String hostName,
  }) async {
    final code = await _uniqueCode();
    final uid = currentUid;
    final now = DateTime.now().millisecondsSinceEpoch;

    final roomData = {
      'hostUid': uid,
      'mode': mode,
      'packs': packs,
      'status': 'lobby',
      'createdAt': now,
      'players': {
        uid: RoomPlayer(
          uid: uid,
          name: hostName,
          isHost: true,
          isActive: true,
          joinedAt: now,
        ).toMap(),
      },
    };

    await _db.child('rooms/$code').set(roomData);

    // Auto-remove the room after 4 hours to keep DB clean
    await _db.child('rooms/$code').onDisconnect().cancel();

    // Set isActive = false on disconnect for the host's player node
    await _db
      .child('rooms/$code/players/$uid/isActive')
      .onDisconnect()
      .set(false);

    return code;
  }

  // ── Join room ──────────────────────────────────────────────────────────────

  /// Returns null if room not found or not in lobby status.
  Future<String?> joinRoom({
    required String code,
    required String playerName,
  }) async {
    final snap = await _db.child('rooms/$code').get();
    if (!snap.exists) return 'Room not found. Check the code and try again.';

    final room = Room.fromMap(code, snap.value as Map);
    if (room.status != 'lobby') return 'This game has already started.';
    if (room.activePlayers.length >= 12) return 'Room is full (max 12 players).';

    final uid = currentUid;
    final now = DateTime.now().millisecondsSinceEpoch;

    await _db.child('rooms/$code/players/$uid').set(
      RoomPlayer(
        uid: uid,
        name: playerName,
        isHost: false,
        isActive: true,
        joinedAt: now,
      ).toMap(),
    );

    // Set isActive = false on disconnect
    await _db
      .child('rooms/$code/players/$uid/isActive')
      .onDisconnect()
      .set(false);

    return null; // null = success
  }

  // ── Listen to room ─────────────────────────────────────────────────────────

  Stream<Room?> roomStream(String code) {
    return _db.child('rooms/$code').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return Room.fromMap(code, event.snapshot.value as Map);
    });
  }

  // ── Start game ─────────────────────────────────────────────────────────────

  Future<void> startGame(String code, Room room) async {
    final playerOrder = room.activePlayers.map((p) => p.uid).toList();
    playerOrder.shuffle();

    await _db.child('rooms/$code').update({
      'status': 'playing',
      'gameState': GameState(
        currentPlayerUid: playerOrder.first,
        currentType: '',
        currentPrompt: '',
        roundNumber: 1,
        playerOrder: playerOrder,
      ).toMap(),
    });
  }

  // ── Update game state (host only) ─────────────────────────────────────────

  Future<void> updateGameState(String code, GameState state) async {
    await _db.child('rooms/$code/gameState').update(state.toMap());
  }

  Future<void> nextPlayer(String code, Room room) async {
    final order = room.gameState!.playerOrder;
    final currentIndex = order.indexOf(room.gameState!.currentPlayerUid);
    final nextUid = order[(currentIndex + 1) % order.length];

    await _db.child('rooms/$code/gameState').update({
      'currentPlayerUid': nextUid,
      'currentType': '',
      'currentPrompt': '',
      'roundNumber': room.gameState!.roundNumber + 1,
    });
  }

  Future<void> setPrompt(String code, {
    required String type,
    required String prompt,
  }) async {
    await _db.child('rooms/$code/gameState').update({
      'currentType': type,
      'currentPrompt': prompt,
    });
  }

  // ── End game ───────────────────────────────────────────────────────────────

  Future<void> endGame(String code) async {
    await _db.child('rooms/$code').update({'status': 'ended'});
  }

  Future<void> leaveRoom(String code) async {
    final uid = currentUid;
    await _db.child('rooms/$code/players/$uid/isActive').set(false);
  }

  Future<void> kickPlayer(String code, String uid) async {
    await _db.child('rooms/$code/players/$uid/isActive').set(false);
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  /// Delete room entirely — called by host on game end or explicit leave
  Future<void> deleteRoom(String code) async {
    await _db.child('rooms/$code').remove();
  }
}
```

---

## FILE: `lib/screens/multiplayer/create_room_screen.dart`

**Purpose:** Host selects mode and packs, enters their name, gets the room code.

**UI layout:**
1. Standard glass `AppBar` with title "Create Room" and glass back button
2. Body is a `SingleChildScrollView` with dark gradient background
3. Section 1 — "Your Name" — `GlassCard` containing a `TextFormField`:
   - Hint: "What should we call you?"
   - `maxLength: 20`
   - `textCapitalization: TextCapitalization.words`
   - No persistence — name is session-only
4. Section 2 — "Choose Mode" — a vertical list of `GlassCard` tiles, one per supported mode:
   - Each tile: mode icon + mode name + 1-line description
   - Selected tile gets `intense: true` on `GlassCard` and a colored left border
   - Supported modes list: Truth or Dare, Would You Rather, Never Have I Ever, Trivia Battle, Impostor Mode, Last Standing, Chaos Mode
5. Section 3 — "Choose Packs" — only shown if mode is Truth or Dare:
   - Reuse the existing pack selection widget
   - For other modes: show "No pack selection needed for this mode" in muted text
6. Bottom: Standard Action Button — `Icon(Icons.add_rounded)` + "Create Room"
   - Disabled (grey) if name is empty or no mode selected
   - `onTap`: calls `RoomService.instance.createRoom(...)` then navigates to `LobbyScreen`

**State variables:**
```dart
final _nameController = TextEditingController();
String? _selectedMode;
List<String> _selectedPacks = [];
bool _isCreating = false;
```

**Navigation on success:**
```dart
final code = await RoomService.instance.createRoom(
  mode: _selectedMode!,
  packs: _selectedPacks,
  hostName: _nameController.text.trim(),
);
Navigator.pushReplacement(context, slideUpRoute(
  LobbyScreen(roomCode: code, isHost: true),
));
```

---

## FILE: `lib/screens/multiplayer/join_room_screen.dart`

**Purpose:** Joiner enters name then code and joins the room.

**UI layout:**
1. Standard glass `AppBar` with title "Join Room"
2. Body: dark gradient background, centered column
3. Large decorative icon at top: `Icon(Icons.meeting_room_rounded)` in `primaryNeon`
4. `GlassCard` containing two fields stacked:
   - Field 1 — "Your Name":
     - `TextFormField`, hint "Enter your name", `maxLength: 20`
     - `textCapitalization: TextCapitalization.words`
     - Name is **never saved** — no `SharedPreferences` call, session only
   - Divider
   - Field 2 — "Room Code":
     - `TextFormField`, hint "6-digit code", `keyboardType: TextInputType.number`
     - `maxLength: 6`, `inputFormatters: [FilteringTextInputFormatter.digitsOnly]`
     - Large centered text style — code should look prominent
5. Error text in `dareRed` below the card (shows join errors)
6. Standard Action Button — `Icon(Icons.login_rounded)` + "Join Room"
   - Disabled if name is empty or code is not 6 digits

**Logic:**
```dart
Future<void> _joinRoom() async {
  setState(() { _isLoading = true; _error = null; });
  final error = await RoomService.instance.joinRoom(
    code: _codeController.text.trim(),
    playerName: _nameController.text.trim(),
  );
  setState(() => _isLoading = false);
  if (error != null) {
    setState(() => _error = error);
    return;
  }
  Navigator.pushReplacement(context, slideUpRoute(
    LobbyScreen(roomCode: _codeController.text.trim(), isHost: false),
  ));
}
```

---

## FILE: `lib/screens/multiplayer/lobby_screen.dart`

**Purpose:** Waiting room. Host sees the code and player list. Joiners wait. Host taps Start.

**Constructor:**
```dart
const LobbyScreen({
  super.key,
  required this.roomCode,
  required this.isHost,
});
```

**State:** Subscribes to `RoomService.instance.roomStream(roomCode)` via `StreamBuilder<Room?>`

**UI layout:**
1. `Scaffold` with dark gradient background, NO `AppBar` — full custom header
2. Top row: `GlassCard` containing the `RoomCodeDisplay` widget (see below) + a small "Copy" icon button that copies the code to clipboard using `Clipboard.setData()`
3. Mode + packs info row: icon + mode name + pack count in muted text
4. Section: "Players in Room" header with live count badge
5. `AnimatedList` of `PlayerListTile` widgets — players animate in as they join
6. If host: "Waiting for players to join…" pulsing muted text if fewer than 2 active players
7. Bottom area:
   - **Host:** Standard Action Button — `Icon(Icons.play_arrow_rounded)` + "Start Game" — disabled until 2+ active players
   - **Joiner:** Muted centered text — "Waiting for the host to start…" with a `CircularProgressIndicator`
8. Both: small `TextButton` at very bottom — "Leave Room" — calls `RoomService.leaveRoom()` then pops

**Room code display widget** (`room_code_display.dart`):
```dart
// Shows the 6 digits in large styled boxes, spaced with a gap in the middle
// e.g.  4 8 2  ·  9 1 3
// Each digit in its own GlassCard box, size 52×64
// Below the digits: muted text "Share this code with your friends"
```

**Player list tile** (`player_list_tile.dart`):
```dart
// GlassCard row: Avatar circle with first letter of name + name text + "HOST" badge if isHost
// Avatar color is deterministic from name hash → picks from neon palette
// Animate in with flutter_animate: .fadeIn().slideX(begin: -0.3)
```

**Start game logic:**
```dart
// Host only:
Future<void> _startGame() async {
  await RoomService.instance.startGame(roomCode, _currentRoom!);
  // The StreamBuilder will pick up status: "playing" and auto-navigate all devices
}
```

**Auto-navigate when game starts:**
```dart
// Inside StreamBuilder builder:
if (room.status == 'playing') {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushReplacement(context, slideUpRoute(
      MultiplayerGameScreen(roomCode: roomCode),
    ));
  });
}
if (room.status == 'ended') {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.popUntil(context, (r) => r.isFirst);
  });
}
```

---

## FILE: `lib/screens/multiplayer/multiplayer_game_screen.dart`

**Purpose:** The actual game screen — adapts to the room's mode. All devices listen to the same Firebase node and react to changes.

**Constructor:**
```dart
const MultiplayerGameScreen({super.key, required this.roomCode});
```

**State:**
```dart
late StreamSubscription<Room?> _roomSub;
Room? _room;
bool _isMyTurn = false;
```

**Core logic:**
```dart
@override
void initState() {
  super.initState();
  _roomSub = RoomService.instance.roomStream(roomCode).listen((room) {
    if (!mounted) return;
    setState(() {
      _room = room;
      _isMyTurn = room?.gameState?.currentPlayerUid == RoomService.instance.currentUid;
    });
    if (room?.status == 'ended') _handleGameEnded();
  });
}

@override
void dispose() {
  _roomSub.cancel();
  super.dispose();
}
```

**UI structure — three states based on `_room!.gameState!.currentType`:**

**State A — Selecting type (currentType is empty, it's my turn):**
- Shows: Current player name + "It's your turn!"
- Two large buttons: "TRUTH" and "DARE"
- On tap: calls `RoomService.instance.setPrompt(roomCode, type: 'truth', prompt: fetchedPrompt)`
- Prompt is fetched from `ApiService` the same way `game_engine_screen.dart` does it

**State B — Selecting type (not my turn):**
- Shows: "{PlayerName}'s turn…" in large text
- `WatchModeOverlay` widget covers action buttons — shows "Watching" with the player's avatar
- The prompt card area shows a skeleton card pulsing while waiting

**State C — Prompt shown (currentType is set, currentPrompt is set):**
- Shows: `MultiplayerPromptCard` — same as the existing `PromptCard` but reads from Firebase state
- If it's my turn: "Done — Next Player" button is active
- If not my turn: button is greyed out with text "Waiting for {PlayerName}…"
- On "Next Player": calls `RoomService.instance.nextPlayer(roomCode, _room!)`

**AppBar:**
- Title: mode name on left
- Right: player count badge `Icon(Icons.people_rounded)` + active player count
- Back button: shows a `PopScope` confirmation dialog — "Leave the game? You'll be removed from the room."

**Watch mode overlay** (`watch_mode_overlay.dart`):
```dart
// Semi-transparent GlassCard pinned to bottom of screen
// Shows: "{PlayerName} is choosing..." with a pulsing dot animation
// Appears with .animate().fadeIn().slideY(begin: 0.3)
// Disappears when currentType is set (prompt is shown)
```

**Multiplayer prompt card** (`multiplayer_prompt_card.dart`):
```dart
// Identical to the existing PromptCard widget but:
// - Reads prompt text and type from GameState passed as parameter
// - 3D flip animation still plays when roundNumber changes (use roundNumber as key)
// - No local timer — timer is removed in multiplayer (no enforcement possible)
// - "Next Player" button: active only if _isMyTurn
```

**Mode routing — the game screen handles all 7 supported modes:**
```dart
Widget _buildGameContent() {
  switch (_room!.mode) {
    case 'truth_or_dare': return _buildTruthOrDareContent();
    case 'would_you_rather': return _buildWyrContent();
    case 'never_have_i_ever': return _buildNhieContent();
    case 'trivia': return _buildTriviaContent();
    case 'impostor': return _buildImpostorContent();
    case 'last_standing': return _buildLastStandingContent();
    case 'chaos': return _buildChaosContent();
    default: return _buildTruthOrDareContent();
  }
}
```

**Impostor mode specifics in multiplayer:**
- Each player's role (impostor/civilian + their word) is stored **locally only** — never in Firebase
- When host starts the game, the host's device distributes roles by writing to each player's individual node:
  ```
  rooms/{code}/players/{uid}/secretRole: "impostor" | "civilian"
  rooms/{code}/players/{uid}/secretWord: "Swimming Pool" | ""  ← empty for impostor
  ```
- Each device only reads its own `players/{ownUid}/secretRole` node
- The hold-to-reveal mechanic works identically to single-player — but after everyone has revealed, the host's device shows the voting screen to all devices simultaneously via a `gameState` update

---

## HOME SCREEN CHANGES

**File:** `lib/screens/home/home_screen.dart`

Add a new prominent section above the game grid called **"Play Together"** (or "Multiplayer"):

```dart
// Between the Truth or Dare hero card and the games grid:
GlassCard(
  accentColor: AppColors.neonGreen,
  child: Row(children: [
    Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withAlpha(30),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.wifi_rounded, color: AppColors.neonGreen, size: 28),
    ),
    SizedBox(width: 16),
    Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Play Together', style: /* bold white 18 */),
        Text('Everyone on their own phone', style: /* muted 13 */),
      ],
    )),
    Column(children: [
      _MultiplayerButton(
        label: 'Create',
        icon: Icons.add_rounded,
        color: AppColors.neonGreen,
        onTap: () => Navigator.push(context, slideUpRoute(const CreateRoomScreen())),
      ),
      SizedBox(height: 8),
      _MultiplayerButton(
        label: 'Join',
        icon: Icons.login_rounded,
        color: AppColors.truthBlue,
        onTap: () => Navigator.push(context, slideUpRoute(const JoinRoomScreen())),
      ),
    ]),
  ]),
)
```

---

## ANDROID BACK GESTURE — ALL MULTIPLAYER SCREENS

Wrap `LobbyScreen`, `MultiplayerGameScreen` in `PopScope`:

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, _) async {
    if (didPop) return;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text('Leave Room?', style: /* white bold */),
        content: Text(
          isHost
            ? 'Leaving will end the game for everyone.'
            : 'You\'ll be removed from the room.',
          style: /* muted */,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Stay')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Leave', style: TextStyle(color: AppColors.dareRed)),
          ),
        ],
      ),
    );
    if (shouldLeave == true) {
      if (isHost) await RoomService.instance.deleteRoom(roomCode);
      else await RoomService.instance.leaveRoom(roomCode);
      if (context.mounted) Navigator.pop(context);
    }
  },
  child: /* screen content */,
)
```

---

## MINIMUM PLAYER VALIDATION FOR MULTIPLAYER

In `lobby_screen.dart`, the Start Game button must enforce minimums:

```dart
bool get _canStart {
  final count = _room?.activePlayers.length ?? 0;
  switch (_room?.mode) {
    case 'impostor': return count >= 3;
    case 'last_standing': return count >= 3;
    default: return count >= 2;
  }
}

// Below the player list, if !_canStart:
Text(
  _minPlayersMessage(_room?.mode),
  style: TextStyle(color: AppColors.neonYellow, fontSize: 13),
)

String _minPlayersMessage(String? mode) {
  switch (mode) {
    case 'impostor':
    case 'last_standing': return 'Need at least 3 players to start';
    default: return 'Need at least 2 players to start';
  }
}
```

---

## ROOM CLEANUP STRATEGY

Rooms accumulate in Firebase. Add automatic cleanup:

**Option A — Firebase TTL (recommended):**
- In Firebase console, enable TTL on the `createdAt` field with a 4-hour expiry
- This requires Firebase Blaze plan (paid) — add a `// TODO: Enable TTL in Firebase console (requires Blaze plan)` comment

**Option B — Client-side cleanup (free):**
- In `RoomService.endGame()` and `deleteRoom()`, always call `_db.child('rooms/$code').remove()`
- In `createRoom()`, scan for and delete rooms older than 4 hours:
  ```dart
  Future<void> _cleanOldRooms() async {
    final cutoff = DateTime.now().millisecondsSinceEpoch - (4 * 60 * 60 * 1000);
    final snap = await _db.child('rooms')
      .orderByChild('createdAt')
      .endAt(cutoff)
      .get();
    if (snap.exists) {
      final old = snap.value as Map;
      for (final code in old.keys) {
        await _db.child('rooms/$code').remove();
      }
    }
  }
  ```
- Call `_cleanOldRooms()` inside `createRoom()` before generating the new code

**Use Option B** — it's free and sufficient for a party game.

---

## QA SCENARIOS FOR MULTIPLAYER (add to Phase 6)

**SCENARIO 15 — Create Room and Lobby**
1. Tap "Create Room" on home screen
2. Enter name, select "Truth or Dare", select 2 packs
3. Tap "Create Room" — confirm lobby screen appears with the 6-digit code
4. Confirm room code is displayed in 6 large digit boxes
5. Confirm "Start Game" button is disabled with "Need at least 2 players" message
6. On a second device: tap "Join Room", enter name, enter the code
7. Confirm the second player appears in the lobby list on both devices within 2 seconds
8. Confirm "Start Game" button becomes enabled on host device
9. Host taps "Start Game" — confirm both devices transition to the game simultaneously

**What to check:**
- [ ] Room code displays as 6 large digit boxes
- [ ] "Copy" button copies the code to clipboard
- [ ] Players appear in lobby within 2 seconds of joining
- [ ] Start button disabled until minimum players met
- [ ] Both devices navigate to game simultaneously on Start

**SCENARIO 16 — Join Room Validation**
1. Tap "Join Room" with empty name — confirm button stays disabled
2. Enter name, enter a 5-digit code — confirm button stays disabled
3. Enter a valid name and a fake 6-digit code — confirm "Room not found" error appears
4. Enter the code of a room that's already playing — confirm "Game already started" error

**What to check:**
- [ ] Join button disabled with empty name or non-6-digit code
- [ ] Friendly error for wrong code
- [ ] Friendly error for game already started

**SCENARIO 17 — Multiplayer Game: Full Round**
1. Create a Truth or Dare room with 3 devices
2. Start the game
3. On device 1 (active player): confirm TRUTH and DARE buttons are active
4. On devices 2 and 3 (watchers): confirm buttons are greyed out, "Watching" overlay shows
5. Device 1 picks TRUTH — confirm all 3 devices show the same prompt simultaneously
6. Device 1 taps "Next Player" — confirm all 3 devices advance to device 2's turn
7. Go through one full rotation (all 3 players take a turn)

**What to check:**
- [ ] Only the current player's device has active action buttons
- [ ] All devices show the same prompt at the same time (within 1–2 seconds)
- [ ] Watch mode overlay appears and disappears at correct times
- [ ] Turn advances correctly through all players

**SCENARIO 18 — Player Drop Mid-Game**
1. Start a 3-player game
2. Mid-game: force-close the app on device 3
3. Within 10 seconds: confirm device 3 disappears from the active player list
4. Confirm the game continues on devices 1 and 2 without crashing
5. Confirm turn rotation skips the dropped player

**What to check:**
- [ ] Dropped player removed from active list within ~10 seconds
- [ ] No crash or freeze on remaining devices
- [ ] Turn rotation continues correctly without the dropped player

**SCENARIO 19 — Host Leaves**
1. Start a 3-player game
2. Host taps the back button — confirm "Leave Room?" dialog appears
3. Host confirms leave — confirm all devices are returned to the home screen
4. Confirm the room is deleted from Firebase (no orphaned room code)

**What to check:**
- [ ] Back gesture shows confirmation dialog (not instant exit)
- [ ] Host leaving ends the game for all devices
- [ ] Room deleted from Firebase on host leave

**SCENARIO 20 — Room Code Copy & Share**
1. Create a room
2. Tap the copy icon next to the room code
3. Open any text field and paste — confirm the 6-digit code was copied correctly
4. The code itself has no spaces, dashes, or extra characters

**What to check:**
- [ ] Copy button copies exactly the 6-digit number string
- [ ] No formatting characters included in the copied text

---

## UPDATED IMPLEMENTATION ORDER — PHASE 8 STEPS

Add these steps after Step 33:

| Step | Task | Phase |
|---|---|---|
| 34 | Add `firebase_database` + `firebase_auth` to pubspec | Phase 8 |
| 35 | Enable Realtime Database + Anonymous Auth in Firebase console | Phase 8 |
| 36 | Create `room_player.dart` + `room.dart` models | Phase 8 |
| 37 | Create `room_service.dart` — full implementation | Phase 8 |
| 38 | Create `create_room_screen.dart` | Phase 8 |
| 39 | Create `join_room_screen.dart` | Phase 8 |
| 40 | Create `lobby_screen.dart` + `room_code_display.dart` + `player_list_tile.dart` | Phase 8 |
| 41 | Create `multiplayer_game_screen.dart` + `watch_mode_overlay.dart` + `multiplayer_prompt_card.dart` | Phase 8 |
| 42 | Update `home_screen.dart` — add Play Together section | Phase 8 |
| 43 | Add `PopScope` back gesture guard to all multiplayer screens | Phase 8 |
| 44 | Run QA Scenarios 15–20 — log and fix all issues | Phase 8 |
| 45 | Final `flutter analyze` + full regression pass across all phases | Final |

---

## UPDATED PUBSPEC — PHASE 8 ADDITIONS

```yaml
# ADD these (Phase 8 — on top of all previous additions):
firebase_database: ^11.1.6
firebase_auth: ^5.5.2
```

---


---

---

## PHASE 8 ADDENDUM — SECRET MISSION MULTIPLAYER

> Add Secret Mission to the supported multiplayer modes. This extends Phase 8. All existing Phase 8 files are modified or extended — no Phase 8 code needs to be rewritten from scratch, only added to.

---

### WHY SECRET MISSION WORKS PERFECTLY IN MULTIPLAYER

In single-player, one phone is passed around and players peek at their mission privately. In multiplayer, each player already has their own phone — so private missions are built-in by design. No passing, no peeking risk, no trust required. It is actually a better experience than the single-player version.

---

### SUPPORTED MODES LIST UPDATE

**File:** `lib/screens/multiplayer/create_room_screen.dart`

Add Secret Mission to the `_supportedModes` list:

```dart
// Add this entry to the modes list in CreateRoomScreen:
{
  'id': 'secret_mission',
  'label': 'Secret Mission',
  'description': 'Complete your hidden goal without anyone noticing',
  'icon': Icons.visibility_off_rounded,
  'color': AppColors.neonPink,
  'minPlayers': 3,
}
```

When Secret Mission is selected, show a duration picker below the mode list inside a `GlassCard`:

```dart
// Duration picker — only visible when mode == 'secret_mission'
AnimatedSize(
  duration: 300.ms,
  child: _selectedMode == 'secret_mission'
    ? GlassCard(
        accentColor: AppColors.neonPink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mission Duration', style: /* bold white 15 */),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [3, 5, 10].map((mins) => _DurationChip(
                minutes: mins,
                selected: _missionDuration == mins,
                onTap: () => setState(() => _missionDuration = mins),
              )).toList(),
            ),
          ],
        ),
      )
    : const SizedBox.shrink(),
)

// _DurationChip widget:
class _DurationChip extends StatelessWidget {
  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  // Renders a rounded pill: "3 min" | "5 min" | "10 min"
  // Selected: solid neonPink background, white text
  // Unselected: glassWhite background, muted text
}
```

Add `int _missionDuration = 5;` to `_CreateRoomScreenState`.

Pass duration to `createRoom()`:

```dart
final code = await RoomService.instance.createRoom(
  mode: _selectedMode!,
  packs: _selectedPacks,
  hostName: _nameController.text.trim(),
  missionDuration: _missionDuration * 60, // store as seconds
);
```

---

### FIREBASE DATA STRUCTURE — SECRET MISSION ADDITIONS

```
rooms/{code}/
  missionDuration: 300              ← total seconds (set by host on create)
  players/{uid}/
    secretMission: "Mention the word 'banana' in every sentence"
                                    ← written by host on startGame, read only by owner
    hasReadMission: false           ← player sets true after reading
    accusations/
      {suspectUid}: true            ← this player thinks suspectUid completed a mission
                                       written privately, only read by host on reveal
  gameState/
    phase: "reveal"                 ← "reveal" | "playing" | "accuse" | "results"
    timeRemaining: 300              ← countdown in seconds, decremented by host device
    revealedAccusations: false      ← host sets true to trigger results on all phones
```

**Privacy guarantee:** Each `players/{uid}/secretMission` node is written by the host but only ever READ by that uid's own device. Firebase rules enforce this:

```json
{
  "rules": {
    "rooms": {
      "$roomCode": {
        ".read": "auth != null",
        ".write": "auth != null",
        "players": {
          "$uid": {
            "secretMission": {
              ".read": "auth.uid === $uid || data.parent().parent().parent().child('hostUid').val() === auth.uid"
            },
            "accusations": {
              ".read": "auth.uid === $uid || data.parent().parent().parent().child('hostUid').val() === auth.uid"
            }
          }
        }
      }
    }
  }
}
```

> **Note:** Update the Firebase rules comment in `room_service.dart` to reference these tighter rules. The developer must paste these into the Firebase console.

---

### ROOM SERVICE ADDITIONS

**File:** `lib/services/room_service.dart`

Add the following methods:

```dart
// ── Secret Mission: assign missions ──────────────────────────────────────────

/// Called by host device only immediately after startGame() for secret_mission mode.
/// Shuffles the mission list and writes one unique mission to each player's private node.
Future<void> assignSecretMissions(String code, List<RoomPlayer> players) async {
  // Import your existing secret mission data:
  final missions = List<String>.from(SecretMissionData.missions)..shuffle();

  final updates = <String, dynamic>{};
  for (int i = 0; i < players.length; i++) {
    final uid = players[i].uid;
    updates['rooms/$code/players/$uid/secretMission'] = missions[i % missions.length];
    updates['rooms/$code/players/$uid/hasReadMission'] = false;
  }
  await _db.update(updates);
}

// ── Secret Mission: mark mission read ────────────────────────────────────────

Future<void> markMissionRead(String code) async {
  await _db
    .child('rooms/$code/players/${currentUid}/hasReadMission')
    .set(true);
}

// ── Secret Mission: read own mission ─────────────────────────────────────────

/// Each device calls this once on game start to fetch its own private mission.
/// Returns null if not yet assigned.
Future<String?> fetchMyMission(String code) async {
  final snap = await _db
    .child('rooms/$code/players/$currentUid/secretMission')
    .get();
  return snap.exists ? snap.value as String? : null;
}

// ── Secret Mission: timer (host only) ────────────────────────────────────────

Timer? _missionTimer;

/// Host calls this to start the synced countdown.
/// Updates timeRemaining in Firebase every second.
void startMissionTimer(String code, int totalSeconds) {
  int remaining = totalSeconds;
  _missionTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
    remaining--;
    await _db.child('rooms/$code/gameState/timeRemaining').set(remaining);
    if (remaining <= 0) {
      t.cancel();
      await _db.child('rooms/$code/gameState').update({
        'phase': 'accuse',
        'timeRemaining': 0,
      });
    }
  });
}

void stopMissionTimer() => _missionTimer?.cancel();

// ── Secret Mission: submit accusation (private) ───────────────────────────────

/// Each player submits their suspicions privately.
/// suspectedUids: list of UIDs this player thinks completed their mission.
Future<void> submitAccusations(String code, List<String> suspectedUids) async {
  final updates = <String, dynamic>{};
  for (final uid in suspectedUids) {
    updates['rooms/$code/players/$currentUid/accusations/$uid'] = true;
  }
  await _db.update(updates);
  // Mark this player's accusation as submitted in gameState:
  await _db
    .child('rooms/$code/gameState/submittedAccusations/$currentUid')
    .set(true);
}

// ── Secret Mission: reveal all (host only) ───────────────────────────────────

/// Host calls this after all accusations are submitted.
/// Fetches all missions + accusations and writes the full results node.
Future<void> revealAllMissions(String code, List<RoomPlayer> players) async {
  final results = <String, dynamic>{};

  for (final player in players) {
    final missionSnap = await _db
      .child('rooms/$code/players/${player.uid}/secretMission')
      .get();
    final accusationsSnap = await _db
      .child('rooms/$code/players/${player.uid}/accusations')
      .get();

    final accusedBy = accusationsSnap.exists
      ? (accusationsSnap.value as Map).keys.toList()
      : [];

    results[player.uid] = {
      'name': player.name,
      'mission': missionSnap.value ?? '',
      'accusedBy': accusedBy,
      'caught': accusedBy.isNotEmpty,
    };
  }

  await _db.child('rooms/$code/gameState').update({
    'results': results,
    'phase': 'results',
    'revealedAccusations': true,
  });
}
```

---

### MULTIPLAYER GAME SCREEN — SECRET MISSION ROUTING

**File:** `lib/screens/multiplayer/multiplayer_game_screen.dart`

Add to `_buildGameContent()`:

```dart
case 'secret_mission': return _buildSecretMissionContent();
```

Add the phase-based builder:

```dart
Widget _buildSecretMissionContent() {
  final phase = _room!.gameState?.phase ?? 'reveal';
  switch (phase) {
    case 'reveal':  return _SecretMissionRevealPhase(
                      room: _room!,
                      myMission: _myMission,  // fetched in initState
                      onRead: () => RoomService.instance.markMissionRead(roomCode),
                    );
    case 'playing': return _SecretMissionPlayingPhase(
                      room: _room!,
                      myMission: _myMission,
                      isHost: RoomService.instance.currentUid == _room!.hostUid,
                      roomCode: roomCode,
                    );
    case 'accuse':  return _SecretMissionAccusePhase(
                      room: _room!,
                      roomCode: roomCode,
                    );
    case 'results': return _SecretMissionResultsPhase(room: _room!);
    default:        return _SecretMissionRevealPhase(
                      room: _room!,
                      myMission: _myMission,
                      onRead: () => RoomService.instance.markMissionRead(roomCode),
                    );
  }
}
```

Add to `initState()` — fetch own mission after stream confirms `status == 'playing'`:

```dart
// Inside _roomSub listener, when room.status becomes 'playing' and mode is secret_mission:
if (room.mode == 'secret_mission' && _myMission == null) {
  final mission = await RoomService.instance.fetchMyMission(roomCode);
  if (mounted) setState(() => _myMission = mission);

  // Host also assigns missions and starts the timer:
  if (RoomService.instance.currentUid == room.hostUid) {
    await RoomService.instance.assignSecretMissions(roomCode, room.activePlayers);
    await Future.delayed(const Duration(seconds: 2)); // give assignment time to propagate
    RoomService.instance.startMissionTimer(roomCode, room.missionDuration ?? 300);
    await _db.child('rooms/$roomCode/gameState/phase').set('reveal');
  }
}
```

Add `String? _myMission;` and `int? get _missionDuration => _room?.missionDuration;` to state.

Add to `Room` model — `int? get missionDuration => /* read from map['missionDuration'] */`

---

### NEW WIDGET FILES

---

#### `lib/screens/multiplayer/widgets/secret_mission_card.dart`

**Phase: reveal — each player reads their own mission**

```dart
class SecretMissionCard extends StatefulWidget {
  final String mission;
  final VoidCallback onRead;
  // ...
}

class _SecretMissionCardState extends State<SecretMissionCard>
    with SingleTickerProviderStateMixin {

  bool _hasRead = false;
  late AnimationController _flipController;

  // UI layout:
  // Large GlassCard (accentColor: AppColors.neonPink, intense: true)
  // Top: Icon(Icons.visibility_off_rounded) in neonPink
  // Title: "Your Secret Mission"
  // Subtitle muted: "Only you can see this"
  // Divider
  // Mission text: large, bold, white, centered
  // Bottom: Standard Action Button "I've Read It — Icon(Icons.check_rounded)"
  //   onTap: flip card face-down + call onRead()

  // On tap "I've Read It":
  // 1. Run 3D flip animation (same as prompt card flip)
  // 2. After flip completes: show face-down card (lock icon only, no text)
  // 3. Call widget.onRead()
  // 4. Set _hasRead = true
  // 5. Show muted text: "Waiting for others to read their missions..."
}
```

**Waiting state — shown after all players have read:**

```dart
// StreamBuilder watching rooms/{code}/players — counts hasReadMission == true
// When all players have read: show animated checkmark + "Everyone's ready! Game starting..."
// Then gameState/phase transitions to 'playing' automatically (host sets it)
```

---

#### `lib/screens/multiplayer/widgets/mission_timer.dart`

**Phase: playing — synced countdown on all phones**

```dart
class MissionTimer extends StatelessWidget {
  final int timeRemaining;  // read from gameState/timeRemaining via StreamBuilder
  final String myMission;   // shown on peek

  // UI layout:
  // Full screen dark background with neonPink radial glow
  //
  // Top section: GlassCard containing:
  //   Large countdown display: MM:SS format
  //   Subtitle: "Complete your mission before time runs out"
  //
  // Middle: GlassCard with blurred/hidden mission text:
  //   Blurred overlay using ImageFilter.blur(sigmaX: 10, sigmaY: 10)
  //   Text underneath: mission text (fully blurred)
  //   Label: "Hold to peek at your mission"
  //   GestureDetector onLongPressStart: set _isPeeking = true → remove blur
  //   GestureDetector onLongPressEnd: set _isPeeking = false → restore blur
  //
  // Bottom: muted text — "Act natural. Complete your mission."
  //   Icon(Icons.people_rounded) + "X players are also on their missions"
  //
  // Timer color shifts:
  //   > 60s remaining: neonGreen
  //   30–60s: neonYellow
  //   < 30s: dareRed + card pulse animation (same as SpeedChallenge)
  //   < 10s: heavy haptic every second
}
```

---

#### `lib/screens/multiplayer/widgets/accusation_card.dart`

**Phase: accuse — each player privately marks who they suspect**

```dart
class AccusationCard extends StatefulWidget {
  final Room room;
  final String roomCode;
  // ...
}

// UI layout:
// Header GlassCard: Icon(Icons.gavel_rounded) + "Who completed their mission?"
// Subtitle: "Select everyone you think pulled it off"
//
// List of all OTHER players (not yourself) as selectable GlassCard tiles:
//   PlayerListTile with a checkbox on the right
//   Tapping toggles selection
//   Selected: tile border glows neonYellow, checkbox filled
//   Unselected: normal glass card
//
// Bottom: Standard Action Button "Submit Accusations — Icon(Icons.send_rounded)"
//   onTap: calls RoomService.instance.submitAccusations(roomCode, _selectedUids)
//   After submit: replace button with "Waiting for others..." + CircularProgressIndicator
//
// Host sees an additional counter: "X / Y players have submitted"
// When all submitted, host sees: "Reveal Results — Icon(Icons.lock_open_rounded)" button
//   onTap: calls RoomService.instance.revealAllMissions(roomCode, room.activePlayers)
```

---

#### `lib/screens/multiplayer/widgets/mission_results_card.dart`

**Phase: results — all missions and accusations revealed simultaneously**

```dart
class MissionResultsCard extends StatefulWidget {
  final Room room;
  // ...
}

// UI layout:
// Fires confetti on enter (ConfettiController) — same as Last Standing winner
//
// Header: Icon(Icons.emoji_events_rounded) + "Mission Results"
//
// List of all players — each in a GlassCard:
//   Player name + avatar (same style as PlayerListTile)
//   Their mission text below the name
//   Result badge on the right:
//     ESCAPED: neonGreen badge + Icon(Icons.check_circle_rounded)
//       → shown if accusedBy list is empty
//     CAUGHT: dareRed badge + Icon(Icons.cancel_rounded)  
//       → shown if accusedBy list is non-empty
//   Expand arrow: tapping the card reveals accusedBy names
//     "Caught by: Alex, Jordan"
//
// Each card animates in staggered using flutter_animate:
//   .animate(delay: 200.ms * index).fadeIn(400.ms).slideY(begin: 0.2)
//
// Bottom section: winner summary GlassCard
//   "X players escaped undetected!"
//   "X players were caught"
//
// Two buttons at bottom:
//   Standard Action Button: "Play Again — Icon(Icons.replay_rounded)"
//     onTap: host resets game state — phase back to 'reveal', clears missions/accusations
//   TextButton: "Leave Room — Icon(Icons.exit_to_app_rounded)"
//     onTap: RoomService.leaveRoom() + Navigator.popUntil home
```

---

### ROOM SERVICE — PLAY AGAIN FOR SECRET MISSION

**File:** `lib/services/room_service.dart`

Add:

```dart
/// Resets Secret Mission for a new round without closing the room.
/// Host only. Reassigns new missions and resets all player nodes.
Future<void> resetSecretMission(String code, List<RoomPlayer> players) async {
  // Clear all player mission data:
  final updates = <String, dynamic>{};
  for (final player in players) {
    updates['rooms/$code/players/${player.uid}/secretMission'] = null;
    updates['rooms/$code/players/${player.uid}/hasReadMission'] = false;
    updates['rooms/$code/players/${player.uid}/accusations'] = null;
  }

  // Reset game state:
  updates['rooms/$code/gameState/phase'] = 'reveal';
  updates['rooms/$code/gameState/timeRemaining'] = null;
  updates['rooms/$code/gameState/results'] = null;
  updates['rooms/$code/gameState/revealedAccusations'] = false;
  updates['rooms/$code/gameState/submittedAccusations'] = null;

  await _db.update(updates);

  // Re-assign missions and restart timer:
  await assignSecretMissions(code, players);
  await Future.delayed(const Duration(seconds: 2));
  startMissionTimer(code, players.first.joinedAt); // use missionDuration from room
}
```

> **Note:** The `resetSecretMission` timer restart should read `missionDuration` from the room node — pass it as a parameter: `Future<void> resetSecretMission(String code, List<RoomPlayer> players, int missionDuration)`

---

### UPDATED MULTIPLAYER SUPPORTED MODES TABLE

Replace the existing table in Phase 8 with:

| Mode | Supported | Reason if not |
|---|---|---|
| Truth or Dare | ✅ | Core mode, perfect fit |
| Would You Rather | ✅ | Works great remotely |
| Never Have I Ever | ✅ | Works great remotely |
| Trivia Battle | ✅ | Works great remotely |
| Impostor Mode | ✅ | Each phone shows own role secretly |
| Last Standing | ✅ | Elimination works across devices |
| Chaos Mode | ✅ | All phones show same chaos event |
| Secret Mission | ✅ | Private missions — better on own phone |
| Bomb Pass | ❌ | Requires physically passing one phone |
| Freeze Mode | ❌ | Requires one shared screen |
| Act It Out | ❌ | Physical performance |
| Speed Challenge | ❌ | Single device timing |
| Laugh Attack | ❌ | Physical reaction |
| Target Player | ❌ | Single phone spin spectacle |
| Random Challenge | ❌ | Single device |

---

### QA SCENARIO 21 — Secret Mission Multiplayer

**Setup:** 3 devices, host selects Secret Mission, sets 3-minute duration

**Steps:**
1. Host creates room with Secret Mission, selects 3 minutes, taps Create Room
2. All 3 devices join the lobby
3. Host taps Start — confirm all 3 devices transition to the reveal phase
4. On Device 1: confirm it shows only Device 1's mission (not others)
5. On Device 2: confirm it shows only Device 2's mission (not others)
6. On Device 3: confirm it shows only Device 3's mission (not others)
7. Each player taps "I've Read It" — confirm card flips face-down
8. After all 3 tap: confirm all phones transition to the playing phase simultaneously
9. Confirm the timer on all 3 phones shows the same time and counts down in sync
10. On any device: hold the mission peek area — confirm mission text unblurs on hold only
11. Let the timer reach zero — confirm all phones simultaneously enter the accusation phase
12. Each player selects their suspicions and taps Submit
13. Host sees submission count update in real time ("2 / 3 submitted")
14. After all submit: host taps "Reveal Results"
15. Confirm all phones simultaneously show the results screen with all missions revealed
16. Verify ESCAPED / CAUGHT badges are correct based on actual accusations
17. Confetti fires on the results screen
18. Host taps "Play Again" — confirm all phones return to reveal phase with new missions
19. Confirm previous missions are gone — new missions assigned

**What to check:**
- [ ] No player ever sees another player's mission at any point
- [ ] Timer is perfectly synced across all devices (within 1 second)
- [ ] Hold-to-peek works — mission hidden immediately on release
- [ ] Accusation submission count updates live on host device
- [ ] Results screen shows correct ESCAPED / CAUGHT for each player
- [ ] Play Again fully resets all mission data and assigns new missions
- [ ] Confetti fires on results screen

---

### IMPLEMENTATION ORDER — SECRET MISSION ADDITIONS

Add these steps after Step 44 (before Step 45 final regression):

| Step | Task |
|---|---|
| 44a | Update `room.dart` — add `missionDuration` field |
| 44b | Update `room_service.dart` — add all 6 new Secret Mission methods |
| 44c | Update `create_room_screen.dart` — add Secret Mission to modes list + duration picker |
| 44d | Update `multiplayer_game_screen.dart` — add Secret Mission phase routing + initState logic |
| 44e | Create `secret_mission_card.dart` — reveal phase widget |
| 44f | Create `mission_timer.dart` — playing phase widget |
| 44g | Create `accusation_card.dart` — accuse phase widget |
| 44h | Create `mission_results_card.dart` — results phase widget with confetti |
| 44i | Update Firebase rules in console — paste tighter per-player rules |
| 44j | Run QA Scenario 21 — 3 devices, full flow, verify privacy |

---

# PHASE 9 — REMAINING POLISH & HARDENING

> These 10 items cover the final gaps before the app is genuinely production-grade. Complete Phases 1–8 before starting Phase 9. Items are ordered from highest to lowest risk.

---

## ITEM 1 — Android Back Gesture: PopScope on Game Screens

**Priority: CRITICAL — causes 1-star reviews**

**Files to modify:**
```
lib/screens/truth_or_dare/game_engine_screen.dart
lib/screens/new_modes/bomb_pass_screen.dart
lib/screens/new_modes/impostor_game_screen.dart
lib/screens/new_modes/last_standing_screen.dart
lib/screens/new_modes/speed_challenge_screen.dart
lib/screens/new_modes/freeze_mode_screen.dart
lib/screens/new_modes/chaos_mode_screen.dart
lib/screens/new_modes/laugh_attack_screen.dart
lib/screens/new_modes/secret_mission_screen.dart
lib/screens/new_modes/target_player_screen.dart
lib/screens/new_modes/act_it_out_screen.dart
lib/screens/new_modes/random_challenge_screen.dart
lib/screens/standalone_game/standalone_game_screen.dart
```

**Problem:** On Android 13+, the edge swipe back gesture dismisses a game mid-round instantly with no warning. Progress is lost silently. Players see this as a bug.

**Fix — wrap every game screen Scaffold with PopScope:**

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, _) async {
    if (didPop) return;
    final shouldLeave = await _showLeaveDialog(context);
    if (shouldLeave == true && context.mounted) {
      Navigator.pop(context);
    }
  },
  child: Scaffold(/* existing content */),
)
```

**Reusable dialog — create once, call everywhere:**

```dart
// lib/core/widgets/leave_game_dialog.dart

Future<bool?> showLeaveGameDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        Icon(Icons.exit_to_app_rounded, color: AppColors.dareRed, size: 22),
        SizedBox(width: 10),
        Text('Leave Game?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
      content: Text(
        'Progress will be lost and the game will end for all players.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Keep Playing', style: TextStyle(color: AppColors.primaryNeon)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Leave', style: TextStyle(color: AppColors.dareRed)),
        ),
      ],
    ),
  );
}
```

**Also update the standard glass back button on all game screens to use the same dialog:**

```dart
// Every AppBar leading back button in game screens:
IconButton(
  onPressed: () async {
    final shouldLeave = await showLeaveGameDialog(context);
    if (shouldLeave == true && context.mounted) Navigator.pop(context);
  },
  icon: /* existing glass back button container */,
)
```

> **Note:** The multiplayer screens already have `PopScope` from Phase 8. Do not add a second one to those screens.

---

## ITEM 2 — Minimum Player Count Enforcement

**Priority: HIGH — silent crash risk**

**File:** `lib/screens/shared/mode_player_setup_screen.dart` + `lib/screens/truth_or_dare/player_setup_screen.dart`

**Problem:** Nothing stops a user from starting Impostor with 1 player or Last Standing with 2 — both break silently or crash.

**Minimum player requirements per mode:**

```dart
// lib/core/constants/game_constants.dart (create this file)

class GameConstants {
  static const Map<String, int> minPlayers = {
    'truth_or_dare':    2,
    'would_you_rather': 2,
    'never_have_i_ever':2,
    'trivia':           2,
    'impostor':         3,
    'act_it_out':       3,
    'speed_challenge':  2,
    'laugh_attack':     2,
    'freeze_mode':      2,
    'target_player':    2,
    'secret_mission':   3,
    'chaos_mode':       2,
    'bomb_pass':        2,
    'last_standing':    3,
    'random_challenge': 1,  // can be played solo
  };

  static const Map<String, String> minPlayerMessages = {
    'impostor':      'Impostor Mode needs at least 3 players',
    'last_standing': 'Last Standing needs at least 3 players',
    'act_it_out':    'Act It Out needs at least 3 players',
    'secret_mission':'Secret Mission needs at least 3 players',
  };

  static int getMinPlayers(String mode) => minPlayers[mode] ?? 2;

  static String? getMinPlayerMessage(String mode, int currentCount) {
    final min = getMinPlayers(mode);
    if (currentCount >= min) return null;
    return minPlayerMessages[mode] ??
      'This mode needs at least $min players (${min - currentCount} more needed)';
  }
}
```

**In `player_setup_screen.dart` and `mode_player_setup_screen.dart`:**

```dart
// Add to state:
String? get _minPlayerError =>
  GameConstants.getMinPlayerMessage(widget.gameMode, players.length);

bool get _canStart => _minPlayerError == null && players.length >= 1;

// Start button:
// If _minPlayerError != null, disable the button and show the error message:
AnimatedSize(
  duration: 200.ms,
  child: _minPlayerError != null
    ? Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, color: AppColors.neonYellow, size: 16),
          SizedBox(width: 8),
          Text(_minPlayerError!, style: TextStyle(color: AppColors.neonYellow, fontSize: 13)),
        ]),
      )
    : SizedBox.shrink(),
)

// Start button opacity and onTap:
Opacity(
  opacity: _canStart ? 1.0 : 0.4,
  child: StandardActionButton(
    label: "Let's Go",
    icon: Icons.play_arrow_rounded,
    color: AppColors.primaryNeon,
    onTap: _canStart ? _startGame : null,
  ),
)
```

**Pass `gameMode` string to all `ModePlayerSetupScreen` and `PlayerSetupScreen` constructors.** If the widget doesn't currently accept a `gameMode` parameter, add one:

```dart
const ModePlayerSetupScreen({
  super.key,
  required this.title,
  required this.gameMode,  // ADD THIS
  // ...existing params...
});
```

---

## ITEM 3 — HapticService (Centralized Haptics)

**Priority: HIGH — mirrors the SoundService pattern already in the plan**

**File to create:** `lib/services/haptic_service.dart`

**Problem:** Haptics are scattered inline across all screens with inconsistent intensity levels. Just like `SoundService` was created to centralize sound, `HapticService` centralizes haptics so intensity always matches the action weight.

```dart
import 'package:flutter/services.dart';

enum HapticEvent {
  // Light — passive feedback
  tap,          // button press, selection change
  selectionTap, // pack select, toggle switch

  // Medium — active feedback
  cardReveal,   // prompt card appears
  playerSelect, // wheel lands on player
  skipPrompt,   // prompt skipped

  // Heavy — significant moment
  gameStart,    // game begins
  playerEliminated,
  timerWarning, // last 3 seconds

  // Impact — dramatic moment
  explosion,    // bomb explodes
  win,          // winner revealed
  freeze,       // FREEZE triggers
  wrong,        // buzzer / loser
}

class HapticService {
  static final HapticService instance = HapticService._internal();
  HapticService._internal();

  Future<void> trigger(HapticEvent event, {bool hapticsEnabled = true}) async {
    if (!hapticsEnabled) return;

    switch (event) {
      // Light
      case HapticEvent.tap:
      case HapticEvent.selectionTap:
        await HapticFeedback.selectionClick();
        break;

      // Medium
      case HapticEvent.cardReveal:
      case HapticEvent.playerSelect:
      case HapticEvent.skipPrompt:
        await HapticFeedback.mediumImpact();
        break;

      // Heavy
      case HapticEvent.gameStart:
      case HapticEvent.playerEliminated:
      case HapticEvent.timerWarning:
        await HapticFeedback.heavyImpact();
        break;

      // Impact — heavy + vibrate combo
      case HapticEvent.explosion:
      case HapticEvent.win:
      case HapticEvent.freeze:
      case HapticEvent.wrong:
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
        break;
    }
  }
}
```

**Register in `main.dart` MultiProvider:**
```dart
Provider(create: (_) => HapticService.instance),
```

**Wiring table — replace ALL inline `HapticFeedback.*` calls with `HapticService.instance.trigger(...)`:**

| File | Old call | New call |
|---|---|---|
| `game_engine_screen.dart` | `HapticFeedback.mediumImpact()` on next player | `HapticEvent.tap` |
| `game_engine_screen.dart` | `HapticFeedback.heavyImpact()` on game start | `HapticEvent.gameStart` |
| `prompt_card.dart` | `HapticFeedback.heavyImpact()` in initState | `HapticEvent.cardReveal` |
| `bomb_pass_screen.dart` | `HapticFeedback.selectionClick()` in tick | `HapticEvent.tap` |
| `bomb_pass_screen.dart` | `HapticFeedback.vibrate()` on explode | `HapticEvent.explosion` |
| `freeze_mode_screen.dart` | All haptic calls in freeze loop | `HapticEvent.freeze` |
| `target_player_screen.dart` | `HapticFeedback.selectionClick()` during spin | `HapticEvent.selectionTap` |
| `target_player_screen.dart` | `HapticFeedback.heavyImpact()` on spin complete | `HapticEvent.playerSelect` |
| `last_standing_screen.dart` | `HapticFeedback.heavyImpact()` on eliminate | `HapticEvent.playerEliminated` |
| `last_standing_screen.dart` | `HapticFeedback.vibrate()` on winner | `HapticEvent.win` |
| `impostor_game_screen.dart` | `HapticFeedback.heavyImpact()` on reveal | `HapticEvent.cardReveal` |
| `speed_challenge_screen.dart` | `HapticFeedback.heavyImpact()` last 3s | `HapticEvent.timerWarning` |
| `chaos_mode_screen.dart` | `HapticFeedback.mediumImpact()` on event | `HapticEvent.cardReveal` |
| All settings toggles | `HapticFeedback.selectionClick()` | `HapticEvent.selectionTap` |
| All Standard Action Buttons | `HapticFeedback.mediumImpact()` | `HapticEvent.tap` |

**Always read `hapticsEnabled` from `PreferencesService` the same way as `soundEnabled`:**
```dart
final hapticsEnabled = context.read<PreferencesService>().hapticsEnabled;
HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: hapticsEnabled);
```

---

## ITEM 4 — Deep Linking & Share Sheet

**Priority: HIGH — viral growth mechanic**

**Package to add:**
```yaml
share_plus: ^10.1.4
```

**Two share features to implement:**

---

### 4A — Share Prompt Result

**File:** `lib/screens/truth_or_dare/widgets/prompt_card.dart`

Add a share icon button in the top-right corner of every prompt card:

```dart
// Inside the prompt card AppBar or top row:
Tooltip(
  message: 'Share this prompt',
  child: GestureDetector(
    onTap: _sharePrompt,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Icon(Icons.ios_share_rounded, color: Colors.white, size: 18),
    ),
  ),
)

Future<void> _sharePrompt() async {
  HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: _hapticsEnabled);
  final type = widget.type == 'truth' ? 'Truth' : 'Dare';
  await SharePlus.instance.share(
    ShareParams(
      text: '🎮 Cousin Chaos — $type\n\n"${widget.prompt}"\n\nPlay now: [your app store link]',
      subject: 'Check out this $type from Cousin Chaos!',
    ),
  );
}
```

---

### 4B — Share Room Code (Multiplayer)

**File:** `lib/screens/multiplayer/lobby_screen.dart`

Replace the current copy-to-clipboard button with a full share button:

```dart
// Next to the room code display:
GestureDetector(
  onTap: () async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Join my Cousin Chaos room! 🎮\n\nRoom code: ${widget.roomCode}\n\nOpen the app and tap "Join Room" to play.',
        subject: 'Join my Cousin Chaos game!',
      ),
    );
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [AppColors.neonGreen, AppColors.truthBlue]),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(children: [
      Icon(Icons.ios_share_rounded, color: Colors.white, size: 18),
      SizedBox(width: 8),
      Text('Share Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ]),
  ),
)
```

Keep the clipboard copy as a secondary option (small copy icon next to the digits).

---

## ITEM 5 — App Rating Prompt

**Priority: MEDIUM — easy win for reviews**

**Package to add:**
```yaml
in_app_review: ^2.0.10
```

**File to modify:** `lib/services/session_stats_service.dart`

**Logic:** Show the rating prompt after the user completes their 3rd session, immediately after a win screen appears. Never show it more than once.

```dart
// Add to SessionStatsService:
int _completedSessions = 0;
bool _hasRequestedReview = false;

void recordSessionComplete() {
  _completedSessions++;
  notifyListeners();
}

bool get shouldRequestReview =>
  _completedSessions >= 3 && !_hasRequestedReview;

void markReviewRequested() {
  _hasRequestedReview = true;
  // Persist so it never shows again across app restarts:
  // SharedPreferences.getInstance().then((p) => p.setBool('reviewRequested', true));
}
```

**Persist `_hasRequestedReview` and `_completedSessions` via `PreferencesService`** — add two new keys: `'review_requested'` (bool) and `'completed_sessions'` (int).

**Call `recordSessionComplete()` in these locations:**
- `game_engine_screen.dart` — when user taps back after at least 5 rounds
- `last_standing_screen.dart` — when winner is revealed
- `impostor_game_screen.dart` — when result screen appears
- `multiplayer_game_screen.dart` — when game ends

**Show the rating prompt from win screens:**

```dart
// In any win screen initState or after win animation completes:
WidgetsBinding.instance.addPostFrameCallback((_) async {
  final stats = context.read<SessionStatsService>();
  stats.recordSessionComplete();
  if (stats.shouldRequestReview) {
    stats.markReviewRequested();
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await Future.delayed(const Duration(seconds: 2)); // let win animation finish
      await inAppReview.requestReview();
    }
  }
});
```

---

## ITEM 6 — Keyboard Handling on Setup Screens

**Priority: MEDIUM — usability bug**

**Files to modify:**
```
lib/screens/truth_or_dare/player_setup_screen.dart
lib/screens/shared/mode_player_setup_screen.dart
lib/screens/multiplayer/create_room_screen.dart
lib/screens/multiplayer/join_room_screen.dart
```

**Problem:** When the keyboard opens on name input fields, it covers the player list and the start button. The scaffold doesn't push content up.

**Fix — three changes per affected screen:**

**1. Set `resizeToAvoidBottomInset: true` on the Scaffold:**
```dart
Scaffold(
  resizeToAvoidBottomInset: true,  // ADD THIS (or ensure it's not set to false)
  // ...
)
```

**2. Wrap the body in a `SingleChildScrollView` if not already:**
```dart
body: SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
  ),
  child: /* existing body content */,
)
```

**3. Dismiss keyboard when tapping outside a field:**
```dart
// Wrap the outermost GestureDetector:
GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  child: /* body */,
)
```

**4. On `player_setup_screen.dart` specifically** — the player list grows as players are added. When the keyboard is open and the user adds a new player, auto-scroll to show the new field:

```dart
// Add ScrollController:
final _scrollController = ScrollController();

// After addPlayer():
WidgetsBinding.instance.addPostFrameCallback((_) {
  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
});
```

---

## ITEM 7 — Font Fallback for Non-Latin Characters

**Priority: MEDIUM — affects international players**

**File:** `lib/core/theme/app_theme.dart`

**Problem:** Poppins (Google Fonts) does not cover Arabic, Chinese, Japanese, Korean, Hindi, or Cyrillic scripts. Player names in these scripts render in the system default font — a jarring visual mismatch against the glassmorphism UI.

**Fix — add a font fallback chain to `AppTheme`:**

```dart
// In AppTheme.darkTheme (and lightTheme if it exists):
// Replace all GoogleFonts.poppins() TextStyle definitions with a fallback chain:

static TextStyle poppins({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.poppins(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  ).copyWith(
    fontFamilyFallback: [
      'NotoSansArabic',   // Arabic
      'NotoSansCJK',      // Chinese, Japanese, Korean
      'NotoSansDevanagari',// Hindi
      'NotoSans',         // General fallback covering Cyrillic + others
    ],
  );
}
```

**Add Noto fonts to `pubspec.yaml` assets** — these are bundled fonts, not Google Fonts network fonts:

```yaml
# Add to flutter: fonts: section in pubspec.yaml:
fonts:
  - family: NotoSansArabic
    fonts:
      - asset: assets/fonts/NotoSansArabic-Regular.ttf
      - asset: assets/fonts/NotoSansArabic-Bold.ttf
  - family: NotoSans
    fonts:
      - asset: assets/fonts/NotoSans-Regular.ttf
      - asset: assets/fonts/NotoSans-Bold.ttf
```

**Download the font files from:** https://fonts.google.com/noto

Place them in `assets/fonts/` directory (create it if it doesn't exist).

> **Note:** Full CJK Noto fonts are very large (10–20MB each). For a party game where CJK is unlikely but possible, `NotoSans` alone covers a wide range including basic CJK fallback. Add `NotoSansCJK` only if CJK support is a priority. Leave a `// TODO: Add NotoSansCJK if CJK language support is needed` comment.

**Apply the fallback to every `Text` widget that renders player-entered content** (names, custom pack prompts). Widgets rendering fixed English content (UI labels, game prompts from API) don't need the fallback.

---

## ITEM 8 — Memory Management: AnimationController Disposal Audit

**Priority: MEDIUM — memory leak risk**

**Problem:** The plan adds approximately 18–22 `AnimationController` instances across all screens. A single missing `dispose()` call compounds into a significant memory leak as users open and close screens repeatedly during a party.

**Create a dedicated audit checklist — verify every controller in every file:**

```
ANIMATION CONTROLLER AUDIT
===========================
For each file below, confirm ALL of the following:
  ✓ Controller declared as `late AnimationController _xController`
  ✓ Controller initialized in initState()
  ✓ Controller disposed in dispose() — BEFORE super.dispose()
  ✓ Widget uses SingleTickerProviderStateMixin (1 controller)
    OR TickerProviderStateMixin (2+ controllers)
  ✓ No controller created inside build() method
```

**Files to audit (every controller must be verified):**

| File | Controllers | Mixin needed |
|---|---|---|
| `home_screen.dart` | `_orbController` | `SingleTicker` |
| `prompt_card.dart` | `_flipController`, `_glowController`, `_pulseController` (if added) | `TickerProvider` |
| `game_engine_screen.dart` | `_elasticController` (player name pop) | `SingleTicker` |
| `bomb_pass_screen.dart` | `_shakeController` (not added yet — N/A) | — |
| `freeze_mode_screen.dart` | `_crackController` | `SingleTicker` |
| `chaos_mode_screen.dart` | `_shakeController`, `_slideController` | `TickerProvider` |
| `last_standing_screen.dart` | AnimatedList handles its own | — |
| `speed_challenge_screen.dart` | `_pulseController` | `SingleTicker` |
| `impostor_game_screen.dart` | `_holdController`, `_revealController` | `TickerProvider` |
| `pack_selection_screen.dart` | `_checkmarkController` per tile | `TickerProvider` |
| `settings_screen.dart` | `_iconPulseController` per tile | `TickerProvider` |
| `player_setup_screen.dart` | `_savedController` per player row | `TickerProvider` |
| `glass_card.dart` | `_shimmerController` | `SingleTicker` |
| `multiplayer screens` | `_confettiController` | External package |
| `mission_timer.dart` | None (reads from Firebase) | — |
| `secret_mission_card.dart` | `_flipController` | `SingleTicker` |

**Standard disposal pattern — every StatefulWidget with controllers:**

```dart
@override
void dispose() {
  _controller1.dispose();
  _controller2.dispose();
  // ALL controllers before super.dispose()
  super.dispose();
}
```

**Add this as a mandatory step in the implementation order** — after all animation code is written, run a global search for `AnimationController(` and verify every result has a corresponding `dispose()` call.

---

## ITEM 9 — Unit Tests

**Priority: MEDIUM — catches regressions**

**No new packages needed** — `flutter_test` is included with every Flutter project.

**File to create:** `test/` directory with the following test files:

---

### `test/services/player_manager_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cousin_chaos/services/player_manager.dart';

void main() {
  group('PlayerManager', () {
    late PlayerManager pm;

    setUp(() {
      pm = PlayerManager();
    });

    test('addPlayer adds a player with a unique name', () {
      pm.addPlayer();
      expect(pm.players.length, 1);
      expect(pm.players.first.name, 'Player 1');
    });

    test('addPlayer after removal uses first unused number', () {
      pm.addPlayer(); // Player 1
      pm.addPlayer(); // Player 2
      pm.addPlayer(); // Player 3
      pm.removePlayer(pm.players[1].id); // remove Player 2
      pm.addPlayer(); // should be Player 2, not Player 4
      expect(pm.players.any((p) => p.name == 'Player 2'), true);
      expect(pm.players.where((p) => p.name == 'Player 4').length, 0);
    });

    test('removePlayer removes the correct player', () {
      pm.addPlayer();
      pm.addPlayer();
      final idToRemove = pm.players.first.id;
      pm.removePlayer(idToRemove);
      expect(pm.players.length, 1);
      expect(pm.players.any((p) => p.id == idToRemove), false);
    });

    test('updatePlayerName updates the correct player name', () {
      pm.addPlayer();
      final id = pm.players.first.id;
      pm.updatePlayerName(id, 'Alex');
      expect(pm.players.first.name, 'Alex');
    });

    test('cannot add more than 12 players', () {
      for (int i = 0; i < 13; i++) pm.addPlayer();
      expect(pm.players.length, lessThanOrEqualTo(12));
    });
  });
}
```

---

### `test/services/session_stats_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cousin_chaos/services/session_stats_service.dart';

void main() {
  group('SessionStatsService', () {
    late SessionStatsService stats;

    setUp(() => stats = SessionStatsService());

    test('recordTruth increments truth count for player', () {
      stats.recordTruth('player1');
      stats.recordTruth('player1');
      expect(stats.truthCount('player1'), 2);
    });

    test('recordDare increments dare count for player', () {
      stats.recordDare('player2');
      expect(stats.dareCount('player2'), 1);
    });

    test('recordSkip increments skip count', () {
      stats.recordSkip('player1');
      expect(stats.skipCount('player1'), 1);
    });

    test('totalCount returns sum of truths + dares', () {
      stats.recordTruth('player1');
      stats.recordDare('player1');
      stats.recordDare('player1');
      expect(stats.totalCount('player1'), 3);
    });

    test('reset clears all stats', () {
      stats.recordTruth('player1');
      stats.recordDare('player2');
      stats.reset();
      expect(stats.totalCount('player1'), 0);
      expect(stats.totalCount('player2'), 0);
    });

    test('unknown player returns 0 for all counts', () {
      expect(stats.truthCount('nobody'), 0);
      expect(stats.dareCount('nobody'), 0);
      expect(stats.skipCount('nobody'), 0);
    });

    test('shouldRequestReview true after 3 sessions', () {
      stats.recordSessionComplete();
      stats.recordSessionComplete();
      expect(stats.shouldRequestReview, false);
      stats.recordSessionComplete();
      expect(stats.shouldRequestReview, true);
    });

    test('shouldRequestReview false after markReviewRequested', () {
      for (int i = 0; i < 3; i++) stats.recordSessionComplete();
      stats.markReviewRequested();
      expect(stats.shouldRequestReview, false);
    });
  });
}
```

---

### `test/services/sound_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cousin_chaos/services/sound_service.dart';

void main() {
  group('SoundService', () {
    test('play returns immediately when soundEnabled is false', () async {
      // Should complete without throwing even with soundEnabled: false
      await expectLater(
        SoundService.instance.play(SoundEvent.tap, soundEnabled: false),
        completes,
      );
    });

    test('play does not throw for any SoundEvent when soundEnabled', () async {
      for (final event in SoundEvent.values) {
        await expectLater(
          SoundService.instance.play(event, soundEnabled: true),
          completes,
        );
      }
    });
  });
}
```

---

### `test/services/haptic_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cousin_chaos/services/haptic_service.dart';

void main() {
  group('HapticService', () {
    test('trigger returns immediately when hapticsEnabled is false', () async {
      await expectLater(
        HapticService.instance.trigger(HapticEvent.tap, hapticsEnabled: false),
        completes,
      );
    });

    test('trigger does not throw for any HapticEvent', () async {
      for (final event in HapticEvent.values) {
        await expectLater(
          HapticService.instance.trigger(event, hapticsEnabled: true),
          completes,
        );
      }
    });
  });
}
```

---

### `test/core/game_constants_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cousin_chaos/core/constants/game_constants.dart';

void main() {
  group('GameConstants', () {
    test('impostor requires minimum 3 players', () {
      expect(GameConstants.getMinPlayers('impostor'), 3);
    });

    test('last_standing requires minimum 3 players', () {
      expect(GameConstants.getMinPlayers('last_standing'), 3);
    });

    test('truth_or_dare requires minimum 2 players', () {
      expect(GameConstants.getMinPlayers('truth_or_dare'), 2);
    });

    test('getMinPlayerMessage returns null when count is sufficient', () {
      expect(GameConstants.getMinPlayerMessage('impostor', 3), isNull);
      expect(GameConstants.getMinPlayerMessage('truth_or_dare', 2), isNull);
    });

    test('getMinPlayerMessage returns message when count is insufficient', () {
      expect(GameConstants.getMinPlayerMessage('impostor', 2), isNotNull);
      expect(GameConstants.getMinPlayerMessage('impostor', 1), isNotNull);
    });
  });
}
```

**Run tests:**
```bash
flutter test
flutter test --coverage   # generates coverage report
```

---

## ITEM 10 — PreferencesService Migration Strategy

**Priority: LOW-MEDIUM — future-proofs all user data**

**File:** `lib/services/preferences_service.dart`

**Problem:** If a future app update renames a `SharedPreferences` key or changes a stored value's type, existing users' data is silently ignored or causes a `TypeError` crash on read.

**Fix — add a storage version system:**

```dart
// In PreferencesService:

// Current storage schema version — increment this whenever keys or types change
static const int _currentStorageVersion = 1;
static const String _versionKey = 'storage_version';

// Call this at the very start of init(), before reading any other key:
Future<void> _migrateIfNeeded(SharedPreferences prefs) async {
  final storedVersion = prefs.getInt(_versionKey) ?? 0;

  if (storedVersion < _currentStorageVersion) {
    await _runMigrations(prefs, fromVersion: storedVersion);
    await prefs.setInt(_versionKey, _currentStorageVersion);
  }
}

Future<void> _runMigrations(SharedPreferences prefs, {required int fromVersion}) async {
  // Each migration block handles upgrading from a specific version:

  if (fromVersion < 1) {
    // v0 → v1: Initial version. No migrations needed.
    // This block runs for all users on first launch after adding versioning.
    // Safe to leave empty — just establishes the baseline.
    debugPrint('PreferencesService: migrated from v0 to v1');
  }

  // Future migration example (do NOT add this now — just a template):
  // if (fromVersion < 2) {
  //   // v1 → v2: renamed 'sound_on' key to 'sound_enabled'
  //   final oldValue = prefs.getBool('sound_on');
  //   if (oldValue != null) {
  //     await prefs.setBool('sound_enabled', oldValue);
  //     await prefs.remove('sound_on');
  //   }
  // }
}

// Updated init():
Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  await _migrateIfNeeded(prefs);  // ALWAYS first
  // ... rest of existing init code ...
}
```

**Document all current keys in a constants block at the top of `preferences_service.dart`:**

```dart
// ── Storage key constants ──────────────────────────────────────────────────
// NEVER rename these without adding a migration in _runMigrations()
static const String _keySoundEnabled        = 'sound_enabled';
static const String _keyHapticsEnabled      = 'haptics_enabled';
static const String _keyIs18Plus            = 'is_18_plus';
static const String _keyHasSeenOnboarding   = 'has_seen_onboarding';
static const String _keyHasSeenHowToPlay    = 'has_seen_how_to_play';
static const String _keyCompletedSessions   = 'completed_sessions';
static const String _keyReviewRequested     = 'review_requested';
static const String _keyStorageVersion      = 'storage_version';
// ─────────────────────────────────────────────────────────────────────────
// When adding a new key: add it here AND use the constant everywhere.
// When renaming a key: increment _currentStorageVersion and add a migration.
```

**Replace all inline string key literals** in `preferences_service.dart` with these constants. Example:
```dart
// BEFORE:
final sound = prefs.getBool('sound_enabled') ?? true;

// AFTER:
final sound = prefs.getBool(_keySoundEnabled) ?? true;
```

---

## PHASE 9 PUBSPEC ADDITIONS

```yaml
# ADD these (Phase 9):
share_plus: ^10.1.4       # Share prompts + room codes
in_app_review: ^2.0.10    # App rating prompt after 3 sessions

# NO new packages for:
# Item 1 (PopScope — Flutter built-in)
# Item 2 (GameConstants — new Dart file only)
# Item 3 (HapticService — Flutter built-in HapticFeedback)
# Item 6 (Keyboard handling — Flutter built-in)
# Item 7 (Noto fonts — bundled assets, not packages)
# Item 8 (AnimationController audit — code review only)
# Item 9 (flutter_test — already included in every Flutter project)
# Item 10 (SharedPreferences migration — existing package)
```

---

## PHASE 9 IMPLEMENTATION ORDER

| Step | Task |
|---|---|
| 46 | Create `leave_game_dialog.dart` + add `PopScope` to all 13 game screens |
| 47 | Create `game_constants.dart` + add min player validation to both setup screens |
| 48 | Create `haptic_service.dart` + register in main.dart + replace all inline HapticFeedback calls |
| 49 | Add `share_plus` — implement share button on prompt card + share code in lobby |
| 50 | Add `in_app_review` — wire session tracking + rating prompt on win screens |
| 51 | Fix keyboard handling on all 4 setup screens + add auto-scroll on player add |
| 52 | Add Noto font files to `assets/fonts/` + update `app_theme.dart` fallback chain |
| 53 | AnimationController disposal audit — search `AnimationController(` globally, verify every dispose() |
| 54 | Write and run all unit tests — fix any failures |
| 55 | Add storage version + key constants to `preferences_service.dart` |
| 56 | Final `flutter analyze` + run all unit tests + full manual regression pass |

---

## PHASE 9 VERIFICATION CHECKLIST

- [ ] Back gesture on every game screen shows "Leave Game?" dialog — never exits silently
- [ ] Start button disabled with clear message when player count is below mode minimum
- [ ] All inline `HapticFeedback.*` calls replaced — zero raw haptic calls outside `HapticService`
- [ ] Share button appears on every prompt card — native share sheet opens correctly
- [ ] Share code button in multiplayer lobby shares the 6-digit code as plain text
- [ ] App rating prompt appears after exactly the 3rd completed session — never before, never twice
- [ ] On setup screens, keyboard opening does not cover the player list or start button
- [ ] Tapping outside a text field dismisses the keyboard
- [ ] Player names in Arabic, Chinese, or Cyrillic render without falling back to a mismatched system font
- [ ] Global search for `AnimationController(` returns zero results outside of `initState()` or field declarations
- [ ] Every `AnimationController` declaration has a corresponding `dispose()` call
- [ ] All 5 unit test files pass with `flutter test`
- [ ] `PlayerManager` tests cover: add, remove, rename, numbering after deletion, max players
- [ ] `SessionStatsService` tests cover: record, reset, review trigger, review one-time flag
- [ ] `SoundService` tests confirm: respects `soundEnabled: false`, no throws on any event
- [ ] `HapticService` tests confirm: respects `hapticsEnabled: false`, no throws on any event
- [ ] `GameConstants` tests confirm correct minimums for all modes
- [ ] `storage_version` key written to `SharedPreferences` on first launch after update
- [ ] All `SharedPreferences` key strings replaced with named constants
- [ ] Migration function runs silently without errors on a fresh install and on an existing install

---

# PHASE 10 — ADVANCED FEATURES & MULTIPLAYER ENHANCEMENTS

> 17 features split across App (Items 1–10) and Multiplayer (Items 11–17). Complete Phases 1–9 before starting Phase 10. Items within each section are ordered by dependency — implement in the order listed.

---

## DESIGN DECISIONS

- **Player avatars:** Color + icon picked together (crown, flame, ghost, skull, star, bolt, diamond, rocket)
- **Prompt difficulty rating:** Only the player who received the prompt rates it
- **Spectator → Player promotion:** Spectator taps "Request to Join", host approves
- **Host migration:** Automatic, with a toast notification to all players
- **Room rejoin:** Name + original UID stored locally — must match both
- **QR code:** Both display (host) AND scan (joiners) — `qr_flutter` + `mobile_scanner`

---

---

## APP ITEMS

---

### ITEM 1 — Player Avatars & Colors

**Files to modify:**
```
lib/models/player.dart                        ← add avatar fields
lib/services/player_manager.dart              ← assign avatar on add
lib/screens/truth_or_dare/player_setup_screen.dart
lib/screens/shared/mode_player_setup_screen.dart
lib/core/widgets/player_avatar.dart           ← NEW
lib/core/constants/avatar_constants.dart      ← NEW
```

**Avatar system design:**
- Every player gets a **color** (from a palette of 8 neon colors) and an **icon** (from a set of 8 icons)
- Both are picked together from a combined grid — 8 options total, each is a unique color+icon pair
- Assignment is automatic on `addPlayer()` — cycles through the 8 pairs by player index
- Players can tap their avatar in the setup screen to change it — shows a bottom sheet picker

---

#### `lib/core/constants/avatar_constants.dart` (CREATE)

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AvatarOption {
  final IconData icon;
  final Color color;
  final String id;

  const AvatarOption({
    required this.icon,
    required this.color,
    required this.id,
  });
}

class AvatarConstants {
  static const List<AvatarOption> options = [
    AvatarOption(id: 'crown',   icon: Icons.workspace_premium_rounded, color: AppColors.neonYellow),
    AvatarOption(id: 'flame',   icon: Icons.local_fire_department_rounded, color: AppColors.dareRed),
    AvatarOption(id: 'ghost',   icon: Icons.blur_on_rounded,           color: AppColors.primaryNeon),
    AvatarOption(id: 'skull',   icon: Icons.sentiment_very_dissatisfied_rounded, color: AppColors.neonPink),
    AvatarOption(id: 'star',    icon: Icons.star_rounded,              color: AppColors.neonGreen),
    AvatarOption(id: 'bolt',    icon: Icons.bolt_rounded,              color: AppColors.truthBlue),
    AvatarOption(id: 'diamond', icon: Icons.diamond_rounded,           color: AppColors.neonCyan),
    AvatarOption(id: 'rocket',  icon: Icons.rocket_launch_rounded,     color: AppColors.neonOrange),
  ];

  static AvatarOption byIndex(int index) => options[index % options.length];

  static AvatarOption byId(String id) =>
    options.firstWhere((o) => o.id == id, orElse: () => options.first);
}
```

---

#### `lib/models/player.dart` — ADD FIELDS

```dart
// Add to Player class:
final String avatarId;   // e.g. 'crown', 'flame', 'ghost' etc.

// Update constructor, copyWith, toJson, fromJson accordingly
// Default avatarId: AvatarConstants.byIndex(playerIndex).id
```

---

#### `lib/services/player_manager.dart` — UPDATE addPlayer()

```dart
// In addPlayer(), assign avatar by current player count:
final avatarId = AvatarConstants.byIndex(_players.length).id;
_players.add(Player(
  id: _uuid.v4(),
  name: 'Player $n',
  avatarId: avatarId,
));
```

---

#### `lib/core/widgets/player_avatar.dart` (CREATE)

```dart
import 'package:flutter/material.dart';
import '../constants/avatar_constants.dart';
import '../theme/app_colors.dart';

class PlayerAvatar extends StatelessWidget {
  final String avatarId;
  final double size;
  final bool showGlow;

  const PlayerAvatar({
    super.key,
    required this.avatarId,
    this.size = 44,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = AvatarConstants.byId(avatarId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatar.color.withAlpha(30),
        border: Border.all(color: avatar.color.withAlpha(80), width: 2),
        boxShadow: showGlow ? [
          BoxShadow(color: avatar.color.withAlpha(60), blurRadius: 16, spreadRadius: 2),
        ] : null,
      ),
      child: Icon(avatar.icon, color: avatar.color, size: size * 0.5),
    );
  }
}
```

---

#### Avatar Picker Bottom Sheet

Show when player taps their avatar in setup screen:

```dart
// Call from onTap on the PlayerAvatar widget in player rows:
Future<void> _showAvatarPicker(BuildContext context, Player player) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => GlassCard(
      accentColor: AppColors.primaryNeon,
      borderRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Choose Avatar', style: /* bold white 18 */),
          SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: AvatarConstants.options.map((option) {
              final isSelected = player.avatarId == option.id;
              return GestureDetector(
                onTap: () {
                  pm.updatePlayerAvatar(player.id, option.id);
                  Navigator.pop(context);
                },
                child: PlayerAvatar(
                  avatarId: option.id,
                  size: 56,
                  showGlow: isSelected,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
        ],
      ),
    ),
  );
}
```

---

#### Where to show PlayerAvatar throughout the app

| Screen | Location |
|---|---|
| `player_setup_screen.dart` | Left of each player name row — tappable to open picker |
| `mode_player_setup_screen.dart` | Left of each player name row — tappable |
| `game_engine_screen.dart` | Current player header — `PlayerAvatar(showGlow: true)` |
| `prompt_card.dart` | Small avatar next to player name at top of card |
| `target_player_screen.dart` | Fortune wheel items show avatar icon + name |
| `last_standing_screen.dart` | Each player card shows avatar |
| `lobby_screen.dart` (multiplayer) | Each `PlayerListTile` |
| `multiplayer_game_screen.dart` | Current player header + watch mode overlay |
| Session stats bottom sheet | Each player row |
| Highlights reel screen | Each stat card |

---

### ITEM 2 — Themed Night Modes Per Game

**Files to modify:**
```
lib/core/theme/game_themes.dart              ← NEW
lib/screens/truth_or_dare/game_engine_screen.dart
lib/screens/new_modes/bomb_pass_screen.dart
lib/screens/new_modes/freeze_mode_screen.dart
lib/screens/new_modes/laugh_attack_screen.dart
lib/screens/new_modes/chaos_mode_screen.dart
lib/screens/new_modes/impostor_game_screen.dart
lib/screens/new_modes/last_standing_screen.dart
lib/screens/new_modes/speed_challenge_screen.dart
lib/screens/new_modes/secret_mission_screen.dart
lib/screens/new_modes/target_player_screen.dart
```

#### `lib/core/theme/game_themes.dart` (CREATE)

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class GameTheme {
  final Color primary;
  final Color secondary;
  final LinearGradient backgroundGradient;
  final Color glowColor;

  const GameTheme({
    required this.primary,
    required this.secondary,
    required this.backgroundGradient,
    required this.glowColor,
  });
}

class GameThemes {
  static const GameTheme truthOrDare = GameTheme(
    primary: AppColors.primaryNeon,
    secondary: AppColors.truthBlue,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF05030F), Color(0xFF0E0820)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.primaryNeon,
  );

  static const GameTheme bombPass = GameTheme(
    primary: AppColors.dareRed,
    secondary: AppColors.neonOrange,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF0F0300), Color(0xFF1A0500)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.dareRed,
  );

  static const GameTheme freezeMode = GameTheme(
    primary: AppColors.truthBlue,
    secondary: AppColors.neonCyan,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF00080F), Color(0xFF001520)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.truthBlue,
  );

  static const GameTheme laughAttack = GameTheme(
    primary: AppColors.neonYellow,
    secondary: AppColors.neonOrange,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF0F0A00), Color(0xFF1A1000)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.neonYellow,
  );

  static const GameTheme impostor = GameTheme(
    primary: AppColors.neonPink,
    secondary: AppColors.dareRed,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF0F0008), Color(0xFF1A0010)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.neonPink,
  );

  static const GameTheme lastStanding = GameTheme(
    primary: AppColors.neonGreen,
    secondary: AppColors.truthBlue,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF000F05), Color(0xFF001A08)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.neonGreen,
  );

  static const GameTheme speedChallenge = GameTheme(
    primary: AppColors.neonOrange,
    secondary: AppColors.neonYellow,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF0F0500), Color(0xFF1A0800)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.neonOrange,
  );

  static const GameTheme secretMission = GameTheme(
    primary: AppColors.neonPink,
    secondary: AppColors.primaryNeon,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF0A000F), Color(0xFF12001A)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.neonPink,
  );

  static const GameTheme targetPlayer = GameTheme(
    primary: AppColors.neonCyan,
    secondary: AppColors.truthBlue,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF000A0F), Color(0xFF00121A)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.neonCyan,
  );

  static const GameTheme chaosMode = GameTheme(
    primary: AppColors.primaryNeon,
    secondary: AppColors.neonPink,
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF08000F), Color(0xFF10001A)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    glowColor: AppColors.primaryNeon,
  );
}
```

#### How to apply in each screen

In every game screen, replace the hardcoded `AppColors.backgroundGradient` with the screen's `GameTheme`:

```dart
// In each game screen Scaffold body:
Container(
  decoration: BoxDecoration(
    gradient: GameThemes.bombPass.backgroundGradient,  // ← screen-specific theme
  ),
  child: Stack(
    children: [
      // Radial glow behind content:
      Positioned(
        top: -100, left: -100,
        child: Container(
          width: 400, height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                GameThemes.bombPass.glowColor.withAlpha(25),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      // Screen content:
      _buildContent(),
    ],
  ),
)
```

**Also update `GlassCard` accent colors** in each screen to use `GameTheme.primary` instead of hardcoded `AppColors.primaryNeon` — this makes every card in the screen glow in that mode's color.

---

### ITEM 3 — Custom Prompt Mid-Game

**Files to modify:**
```
lib/screens/truth_or_dare/game_engine_screen.dart
lib/core/widgets/add_prompt_sheet.dart         ← NEW
```

#### `lib/core/widgets/add_prompt_sheet.dart` (CREATE)

```dart
// Bottom sheet that lets the host type a one-off custom prompt during a game session
// The prompt is returned via a callback — never saved to any storage

class AddPromptSheet extends StatefulWidget {
  final String type; // 'truth' or 'dare'
  final ValueChanged<String> onAdd;
  // ...
}

// UI layout:
// GlassCard bottom sheet
// Title: Icon(Icons.add_circle_rounded) + "Add a Custom [Truth/Dare]"
// Subtitle muted: "This prompt is for this round only — not saved"
// TextFormField:
//   hint: type == 'truth' ? 'Type your truth question...' : 'Type your dare challenge...'
//   maxLength: 280
//   maxLines: 3
//   textCapitalization: TextCapitalization.sentences
// Character counter bottom right: live, turns dareRed over 240
// Two buttons at bottom:
//   TextButton: "Cancel"
//   Standard Action Button: "Use This [Truth/Dare]" — disabled if field empty
//     onTap: widget.onAdd(controller.text.trim()); Navigator.pop(context);
```

#### Integration in `game_engine_screen.dart`

Add a "+" icon button to the AppBar trailing — only visible during the prompt selection phase (not while a prompt card is shown):

```dart
// AppBar actions — only when _phase == GamePhase.selectType:
if (_phase == GamePhase.selectType)
  Tooltip(
    message: 'Add custom prompt',
    child: IconButton(
      onPressed: _showAddPromptSheet,
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 18),
      ),
    ),
  ),

Future<void> _showAddPromptSheet() async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AddPromptSheet(
        type: _lastSelectedType ?? 'truth',  // pre-fill based on last pick
        onAdd: (prompt) {
          // Insert at front of local deck so it's the next prompt shown:
          setState(() {
            _currentPrompt = prompt;
            _phase = GamePhase.showPrompt;
          });
        },
      ),
    ),
  );
}
```

---

### ITEM 4 — Game Highlights Reel

**Files to create:**
```
lib/screens/highlights/highlights_screen.dart
lib/services/session_stats_service.dart        ← extend existing
```

#### Extend `SessionStatsService`

```dart
// Add tracking fields:
final Map<String, int> _firstEliminated = {};   // Last Standing
String? _impostorWinner;                         // impostor or civilians
final Map<String, int> _laughs = {};             // Laugh Attack
int _totalRounds = 0;

// Add methods:
void recordElimination(String playerId, int position) {
  _firstEliminated[playerId] = position;
  notifyListeners();
}

void recordLaugh(String playerId) {
  _laughs[playerId] = (_laughs[playerId] ?? 0) + 1;
  notifyListeners();
}

void recordImpostorResult(String winnerId) {
  _impostorWinner = winnerId;
  notifyListeners();
}

void incrementRound() {
  _totalRounds++;
  notifyListeners();
}

// Derived stats:
String? get mostDaresPerson => _topByCount(_dares);
String? get mostSkipsPerson => _topByCount(_skips);
String? get mostTruthsPerson => _topByCount(_truths);
int get totalRounds => _totalRounds;

String? _topByCount(Map<String, int> map) {
  if (map.isEmpty) return null;
  return map.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}
```

#### `lib/screens/highlights/highlights_screen.dart` (CREATE)

**When to show:** After any game session ends — add a "See Highlights" button on every win/end screen alongside the existing buttons.

**UI layout:**
```dart
// Full screen with game theme gradient background
// Title: Icon(Icons.emoji_events_rounded) + "Session Highlights"
// Subtitle: "X rounds played"
//
// Horizontally swipeable PageView of highlight cards:
//   Each card is a GlassCard with a specific stat
//
// Card 1 — Dare Devil:
//   Icon(Icons.local_fire_department_rounded) in dareRed
//   "[Name] was the bravest"
//   "[X] dares completed"
//   PlayerAvatar shown prominently
//
// Card 2 — Truth Seeker:
//   Icon(Icons.lightbulb_rounded) in truthBlue
//   "[Name] answered the most truths"
//   "[X] truths answered"
//
// Card 3 — Hall of Shame (if any skips):
//   Icon(Icons.skip_next_rounded) in neonYellow
//   "[Name] skipped the most"
//   "[X] times skipped (shame!)"
//
// Card 4 — First Out (Last Standing only):
//   Icon(Icons.sentiment_very_dissatisfied_rounded) in neonPink
//   "[Name] was the first to fall"
//
// Card 5 — The Impostor (Impostor Mode only):
//   Result card showing who the impostor was and whether they won
//
// Card 6 — Most Rounds:
//   Icon(Icons.loop_rounded) in neonGreen
//   "You played [X] rounds together!"
//
// Bottom page dots indicator
// Two buttons:
//   Standard Action Button: "Play Again — Icon(Icons.replay_rounded)"
//   TextButton: "Done — Icon(Icons.home_rounded)" → pop to home
//
// Confetti fires on first load (same ConfettiController pattern)
// Each card animates in with flutter_animate staggered fadeIn + slideX
```

---

### ITEM 5 — Sound Pack Selection

**Files to modify:**
```
lib/services/sound_service.dart               ← add theme support
lib/services/preferences_service.dart         ← add soundTheme key
lib/screens/settings/settings_screen.dart     ← add sound theme picker
lib/core/constants/sound_themes.dart          ← NEW
assets/sounds/                                ← add asset files per theme
```

#### `lib/core/constants/sound_themes.dart` (CREATE)

```dart
enum SoundTheme {
  system,   // Flutter SystemSound.click — no assets needed (current default)
  retro,    // 8-bit chiptune style
  cinematic,// deep cinematic impacts
}

class SoundThemeConstants {
  static const Map<SoundTheme, String> labels = {
    SoundTheme.system:    'System (Default)',
    SoundTheme.retro:     'Retro 8-bit',
    SoundTheme.cinematic: 'Cinematic',
  };

  static const Map<SoundTheme, String> descriptions = {
    SoundTheme.system:    'Simple system clicks and haptics',
    SoundTheme.retro:     'Classic 8-bit game sounds',
    SoundTheme.cinematic: 'Epic cinematic impacts',
  };

  // Asset path format: assets/sounds/{theme}/{event}.mp3
  static String assetPath(SoundTheme theme, String eventName) =>
    'sounds/${theme.name}/$eventName.mp3';
}
```

#### Update `SoundService`

```dart
// Add current theme field:
SoundTheme _currentTheme = SoundTheme.system;

void setTheme(SoundTheme theme) {
  _currentTheme = theme;
}

// Update play() to use theme assets when not system:
Future<void> play(SoundEvent event, {bool soundEnabled = true}) async {
  if (!soundEnabled) return;

  if (_currentTheme == SoundTheme.system) {
    // existing system sound / haptic logic
    return;
  }

  // Asset-based playback:
  final eventName = event.name; // uses enum name e.g. 'tap', 'cardReveal'
  final path = SoundThemeConstants.assetPath(_currentTheme, eventName);
  try {
    await _player.play(AssetSource(path));
  } catch (_) {
    // Fallback to system sound if asset missing:
    await SystemSound.play(SystemSoundType.click);
  }
}
```

#### Settings UI — Sound Theme Picker

```dart
// In settings_screen.dart, under the Sound toggle:
// A horizontal row of three selectable chip buttons:
// "System" | "Retro" | "Cinematic"
// Selected chip: solid primaryNeon background
// On select: prefs.setSoundTheme(theme); SoundService.instance.setTheme(theme);

// Add to PreferencesService:
static const String _keySoundTheme = 'sound_theme';
SoundTheme get soundTheme => SoundTheme.values.firstWhere(
  (t) => t.name == (_prefs.getString(_keySoundTheme) ?? 'system'),
  orElse: () => SoundTheme.system,
);
Future<void> setSoundTheme(SoundTheme theme) async {
  await _prefs.setString(_keySoundTheme, theme.name);
  SoundService.instance.setTheme(theme);
  notifyListeners();
}
```

**Asset files required:**
```
assets/sounds/retro/tap.mp3
assets/sounds/retro/cardReveal.mp3
assets/sounds/retro/spin.mp3
assets/sounds/retro/countdown.mp3
assets/sounds/retro/timerEnd.mp3
assets/sounds/retro/bombTick.mp3
assets/sounds/retro/explosion.mp3
assets/sounds/retro/win.mp3
assets/sounds/retro/wrong.mp3
assets/sounds/retro/freeze.mp3
assets/sounds/cinematic/[same 10 files].mp3
```

> **Note for developer:** Source free-to-use 8-bit sounds from freesound.org or mixkit.co. Cinematic impacts from zapsplat.com (free with account). Name files exactly as the `SoundEvent` enum values in lowercase. Leave a `// TODO: Add sound asset files to assets/sounds/` comment in `sound_service.dart`.

---

### ITEM 6 — Prompt Difficulty Rating

**Files to modify:**
```
lib/screens/truth_or_dare/widgets/prompt_card.dart
lib/services/prompt_rating_service.dart        ← NEW
lib/services/preferences_service.dart          ← add rating storage
```

#### `lib/services/prompt_rating_service.dart` (CREATE)

```dart
// Stores prompt ratings locally using SharedPreferences
// Key format: 'prompt_rating_{promptHash}' → int (1=easy, 2=medium, 3=brutal)
// Uses a hash of the prompt text as the key — no server needed

class PromptRatingService {
  static final PromptRatingService instance = PromptRatingService._internal();
  PromptRatingService._internal();

  // Rating values:
  // 1 = Too Easy (fire emoji → Icon(Icons.sentiment_satisfied_rounded))
  // 2 = Just Right
  // 3 = Brutal (skull → Icon(Icons.sentiment_very_dissatisfied_rounded))

  String _keyFor(String prompt) =>
    'prompt_rating_${prompt.hashCode.abs()}';

  Future<void> rate(String prompt, int rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFor(prompt), rating);
  }

  Future<int?> getRating(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFor(prompt));
  }

  // Returns a weight multiplier for deck building:
  // Rating 1 (easy) → weight 0.5 (show less)
  // Rating 2 (just right) → weight 1.0 (normal)
  // Rating 3 (brutal) → weight 1.5 (show more)
  // Unrated → weight 1.0
  Future<double> getWeight(String prompt) async {
    final rating = await getRating(prompt);
    switch (rating) {
      case 1: return 0.5;
      case 3: return 1.5;
      default: return 1.0;
    }
  }
}
```

#### Integration in `prompt_card.dart`

Show the rating UI after the player taps "Next Player" — between completing this prompt and advancing:

```dart
// Add state:
bool _showRating = false;
int? _selectedRating;

// Replace "Next Player" button onTap:
onTap: () {
  if (!_showRating) {
    setState(() => _showRating = true);
  } else {
    if (_selectedRating != null) {
      PromptRatingService.instance.rate(widget.prompt, _selectedRating!);
    }
    widget.onNext();
  }
},

// Rating UI — shown when _showRating is true:
// Appears below the prompt card with flutter_animate .fadeIn().slideY(begin: 0.3)
AnimatedSize(
  duration: 250.ms,
  child: _showRating
    ? GlassCard(
        accentColor: AppColors.neonYellow,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(children: [
          Text('How was that?', style: /* white bold 15 */),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RatingButton(
                icon: Icons.sentiment_satisfied_rounded,
                label: 'Too Easy',
                color: AppColors.neonGreen,
                selected: _selectedRating == 1,
                onTap: () => setState(() => _selectedRating = 1),
              ),
              _RatingButton(
                icon: Icons.sentiment_neutral_rounded,
                label: 'Just Right',
                color: AppColors.neonYellow,
                selected: _selectedRating == 2,
                onTap: () => setState(() => _selectedRating = 2),
              ),
              _RatingButton(
                icon: Icons.sentiment_very_dissatisfied_rounded,
                label: 'Brutal',
                color: AppColors.dareRed,
                selected: _selectedRating == 3,
                onTap: () => setState(() => _selectedRating = 3),
              ),
            ],
          ),
          SizedBox(height: 12),
          // "Next Player" button changes to "Submit & Continue" when rating selected:
          // If no rating selected: shows "Skip Rating →" as TextButton
        ]),
      )
    : SizedBox.shrink(),
)
```

#### Weight-based deck shuffling in `game_engine_screen.dart`

```dart
// When building _localDeck, apply weights:
Future<void> _buildWeightedDeck(List<GameCardPrompt> rawDeck) async {
  final weighted = <GameCardPrompt>[];
  for (final prompt in rawDeck) {
    final weight = await PromptRatingService.instance.getWeight(prompt.text);
    final copies = (weight * 2).round().clamp(1, 3);
    for (int i = 0; i < copies; i++) weighted.add(prompt);
  }
  weighted.shuffle();
  setState(() => _localDeck = weighted);
}
```

---

### ITEM 7 — Haptic Themes

**Files to modify:**
```
lib/services/haptic_service.dart
lib/services/preferences_service.dart
lib/screens/settings/settings_screen.dart
lib/core/constants/haptic_themes.dart         ← NEW
```

#### `lib/core/constants/haptic_themes.dart` (CREATE)

```dart
enum HapticTheme {
  subtle,    // only light impacts
  standard,  // current behavior
  intense,   // always one level heavier
}

class HapticThemeConstants {
  static const Map<HapticTheme, String> labels = {
    HapticTheme.subtle:   'Subtle',
    HapticTheme.standard: 'Standard',
    HapticTheme.intense:  'Intense',
  };
}
```

#### Update `HapticService`

```dart
HapticTheme _currentTheme = HapticTheme.standard;

void setTheme(HapticTheme theme) => _currentTheme = theme;

Future<void> trigger(HapticEvent event, {bool hapticsEnabled = true}) async {
  if (!hapticsEnabled) return;

  // Apply theme modifier to intensity:
  switch (_currentTheme) {
    case HapticTheme.subtle:
      // All events capped at selectionClick — very light
      await HapticFeedback.selectionClick();
      break;

    case HapticTheme.standard:
      // Existing switch logic (unchanged from Phase 9 Item 3):
      await _standardTrigger(event);
      break;

    case HapticTheme.intense:
      // All events one level heavier:
      // light → medium, medium → heavy, heavy → vibrate+heavy
      await _intenseTrigger(event);
      break;
  }
}

Future<void> _intenseTrigger(HapticEvent event) async {
  switch (event) {
    case HapticEvent.tap:
    case HapticEvent.selectionTap:
      await HapticFeedback.mediumImpact();
      break;
    case HapticEvent.cardReveal:
    case HapticEvent.playerSelect:
    case HapticEvent.skipPrompt:
      await HapticFeedback.heavyImpact();
      break;
    default:
      await HapticFeedback.vibrate();
      await Future.delayed(100.ms);
      await HapticFeedback.heavyImpact();
      break;
  }
}
```

#### Settings UI

```dart
// Under the Haptics toggle in settings, same chip pattern as Sound Theme:
// "Subtle" | "Standard" | "Intense"
// Add to PreferencesService:
static const String _keyHapticTheme = 'haptic_theme';
HapticTheme get hapticTheme => HapticTheme.values.firstWhere(
  (t) => t.name == (_prefs.getString(_keyHapticTheme) ?? 'standard'),
  orElse: () => HapticTheme.standard,
);
Future<void> setHapticTheme(HapticTheme theme) async {
  await _prefs.setString(_keyHapticTheme, theme.name);
  HapticService.instance.setTheme(theme);
  notifyListeners();
}
```

---

### ITEM 8 — Tablet / Landscape Support

**Files to modify:**
```
lib/main.dart                                  ← remove portrait-only lock for tablets
lib/core/layout/responsive_layout.dart        ← NEW
lib/screens/home/home_screen.dart
lib/screens/truth_or_dare/game_engine_screen.dart
lib/screens/truth_or_dare/widgets/prompt_card.dart
```

#### `lib/core/layout/responsive_layout.dart` (CREATE)

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget phone;
  final Widget tablet;

  const ResponsiveLayout({
    super.key,
    required this.phone,
    required this.tablet,
  });

  static bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    return isTablet(context) ? tablet : phone;
  }
}
```

#### Portrait lock update in `main.dart`

```dart
// Replace the blanket portrait lock:
// BEFORE:
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
]);

// AFTER:
// Only lock portrait on phones. Tablets get all orientations.
// Detection at runtime inside each screen using ResponsiveLayout.isTablet()
// No system-level lock needed — Flutter handles per-screen orientation via:
// SystemChrome.setPreferredOrientations() called in each screen's initState

// Phone screens (in initState of every game screen on phones):
if (!ResponsiveLayout.isTablet(context)) {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
```

#### Tablet two-column layout — `home_screen.dart`

```dart
// Wrap the game grid with ResponsiveLayout:
ResponsiveLayout(
  phone: _buildPhoneGrid(),    // existing 2-column grid
  tablet: _buildTabletGrid(),  // 3-column wider grid with larger cards
)

Widget _buildTabletGrid() {
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,        // 3 columns on tablet
      childAspectRatio: 1.4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    // ... same items as phone grid
  );
}
```

#### Tablet layout — `prompt_card.dart` and `game_engine_screen.dart`

```dart
// On tablet, show prompt and player info side by side:
ResponsiveLayout(
  phone: Column(children: [_playerHeader(), _promptCard(), _actionButton()]),
  tablet: Row(children: [
    Expanded(child: _playerHeader()),
    Expanded(flex: 2, child: Column(children: [_promptCard(), _actionButton()])),
  ]),
)
```

---

### ITEM 9 — Timed Auto-Advance Option

**Files to modify:**
```
lib/services/preferences_service.dart         ← add autoAdvance key
lib/screens/settings/settings_screen.dart     ← add toggle
lib/screens/truth_or_dare/widgets/prompt_card.dart
```

#### Settings

```dart
// Add to PreferencesService:
static const String _keyAutoAdvance = 'auto_advance';
bool get autoAdvanceEnabled => _prefs.getBool(_keyAutoAdvance) ?? false;
Future<void> setAutoAdvance(bool value) async {
  await _prefs.setBool(_keyAutoAdvance, value);
  notifyListeners();
}

// In settings_screen.dart, under GAMEPLAY section:
// Toggle: "Auto-advance prompts"
// Subtitle: "Automatically moves to next player when timer ends"
```

#### `prompt_card.dart`

```dart
// In initState(), check if autoAdvance is enabled:
final autoAdvance = context.read<PreferencesService>().autoAdvanceEnabled;

// In _startTimer(), when _timeLeft reaches 0:
if (autoAdvance) {
  // Brief pause then auto-advance:
  await Future.delayed(const Duration(milliseconds: 800));
  if (mounted) widget.onNext();
} else {
  // Existing behavior — wait for button tap
  setState(() => _timerComplete = true);
}

// When autoAdvance is on, change the countdown display:
// Show "Auto-advancing in Xs..." text below the timer when _timeLeft <= 5
```

---

### ITEM 10 — Home Screen Widget

**Package to add:**
```yaml
home_widget: ^0.7.0
```

**Files to create:**
```
lib/widgets/home_widget_service.dart          ← NEW
android/app/src/main/res/layout/             ← widget layout (Android)
ios/Runner/                                   ← widget extension (iOS)
```

#### `lib/widgets/home_widget_service.dart` (CREATE)

```dart
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String _appGroupId = 'group.com.yourapp.cousinchaos';
  static const String _widgetName = 'DailyChallenge';

  static Future<void> updateWidget() async {
    // Pick a random prompt from local data:
    final prompts = RandomChallengeData.challenges; // existing data file
    final prompt = prompts[Random().nextInt(prompts.length)];

    await HomeWidget.saveWidgetData<String>('challenge_text', prompt);
    await HomeWidget.saveWidgetData<String>(
      'updated_at',
      DateFormat('MMM d').format(DateTime.now()),
    );
    await HomeWidget.updateWidget(
      androidName: _widgetName,
      iOSName: _widgetName,
    );
  }

  // Call this in main() and whenever app comes to foreground:
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await updateWidget();
  }
}
```

**Call in `main.dart`:**
```dart
await HomeWidgetService.init();
```

**Call when app resumes** — in `home_screen.dart`:
```dart
// Add AppLifecycleListener in _HomeScreenState:
late final AppLifecycleListener _lifecycleListener;

@override
void initState() {
  super.initState();
  _lifecycleListener = AppLifecycleListener(
    onResume: () => HomeWidgetService.updateWidget(),
  );
}

@override
void dispose() {
  _lifecycleListener.dispose();
  super.dispose();
}
```

**Widget content:**
```
┌─────────────────────────────┐
│  🎮 Today's Challenge       │
│                             │
│  "Do 10 push-ups right      │
│   now or take a dare"       │
│                             │
│  May 9 · Cousin Chaos       │
└─────────────────────────────┘
```

> **Note for developer:** Native widget layout files (Android XML and iOS SwiftUI) must be created manually in their respective platform directories. Leave `// TODO: Add native widget layout files` comment in `home_widget_service.dart`. The Dart code above is the Flutter side only.

---

---

## MULTIPLAYER ITEMS

---

### ITEM 11 — Spectator Mode

**Files to modify:**
```
lib/core/models/room_player.dart              ← add isSpectator field
lib/services/room_service.dart                ← add joinAsSpectator, requestToPlay, approveSpectator
lib/screens/multiplayer/join_room_screen.dart ← add spectator join option
lib/screens/multiplayer/lobby_screen.dart     ← show spectators separately
lib/screens/multiplayer/multiplayer_game_screen.dart ← spectator view
lib/screens/multiplayer/widgets/spectator_view.dart  ← NEW
lib/screens/multiplayer/widgets/join_request_toast.dart ← NEW
```

#### `room_player.dart` — ADD FIELDS

```dart
final bool isSpectator;
final bool hasRequestedToPlay;  // true when spectator taps "Request to Join"

// Add to fromMap() and toMap()
```

#### `room_service.dart` — ADD METHODS

```dart
// Join room as spectator (game already in progress):
Future<String?> joinAsSpectator({
  required String code,
  required String playerName,
}) async {
  final snap = await _db.child('rooms/$code').get();
  if (!snap.exists) return 'Room not found.';

  final room = Room.fromMap(code, snap.value as Map);
  // Spectators can join even when game is playing:
  if (room.status == 'ended') return 'This game has already ended.';

  final uid = currentUid;
  final now = DateTime.now().millisecondsSinceEpoch;

  await _db.child('rooms/$code/players/$uid').set(
    RoomPlayer(
      uid: uid,
      name: playerName,
      isHost: false,
      isActive: true,
      isSpectator: true,
      hasRequestedToPlay: false,
      joinedAt: now,
    ).toMap(),
  );

  await _db.child('rooms/$code/players/$uid/isActive')
    .onDisconnect().set(false);

  return null;
}

// Spectator requests to become a player:
Future<void> requestToPlay(String code) async {
  await _db
    .child('rooms/$code/players/$currentUid/hasRequestedToPlay')
    .set(true);
}

// Host approves a spectator to become a player:
Future<void> approveSpectator(String code, String spectatorUid) async {
  await _db.child('rooms/$code/players/$spectatorUid').update({
    'isSpectator': false,
    'hasRequestedToPlay': false,
  });
  // Also add them to gameState/playerOrder:
  final snap = await _db.child('rooms/$code/gameState/playerOrder').get();
  final order = List<String>.from(snap.value as List? ?? []);
  order.add(spectatorUid);
  await _db.child('rooms/$code/gameState/playerOrder').set(order);
}
```

#### `join_room_screen.dart` — ADD SPECTATOR OPTION

After the code is validated and the room is found — if the room status is `'playing'`:

```dart
// Show a choice dialog:
// "This game is already in progress."
// [Watch as Spectator]  [Cancel]
// Tapping "Watch as Spectator" calls joinAsSpectator() instead of joinRoom()
```

If the room is in `'lobby'` status, show the normal join flow (no spectator option).

#### `lobby_screen.dart` — SPECTATORS SECTION

```dart
// Below the "Players" section, add a "Watching" section:
// Only shown if there are any spectators:
if (spectators.isNotEmpty) ...[
  SizedBox(height: 16),
  Text('Watching', style: /* muted 13 */),
  SizedBox(height: 8),
  ...spectators.map((s) => PlayerListTile(
    player: s,
    trailing: s.hasRequestedToPlay && isHost
      ? TextButton(
          onPressed: () => RoomService.instance.approveSpectator(roomCode, s.uid),
          child: Text('Let In', style: TextStyle(color: AppColors.neonGreen)),
        )
      : null,
  )),
]
```

#### `multiplayer_game_screen.dart` — SPECTATOR VIEW

```dart
// In build():
final myPlayer = _room?.players[RoomService.instance.currentUid];
if (myPlayer?.isSpectator == true) {
  return SpectatorView(room: _room!, roomCode: roomCode);
}
// Otherwise show the normal game UI
```

#### `spectator_view.dart` (CREATE)

```dart
// Shows the full game in read-only mode:
// Same prompt card content visible to spectators
// "Watching" banner at top in muted text
// Bottom: "Request to Join" button
//   onTap: RoomService.instance.requestToPlay(roomCode)
//   After tap: button changes to "Request sent — waiting for host..."
//   When host approves (isSpectator flips to false in stream):
//     SpectatorView is replaced by the normal game UI automatically
```

#### `join_request_toast.dart` (CREATE)

```dart
// Shown on the HOST's game screen when a spectator taps "Request to Join"
// Appears as an overlay toast at the top of the screen:
// "[Name] wants to join the game"
// Two buttons: "Let In" | "Decline"
// Auto-dismisses after 15 seconds if no action taken (request stays pending)
// Watch _room.players for any player where hasRequestedToPlay == true
// Show one toast per pending request
```

---

### ITEM 12 — Host Migration

**Files to modify:**
```
lib/services/room_service.dart
lib/screens/multiplayer/lobby_screen.dart
lib/screens/multiplayer/multiplayer_game_screen.dart
lib/core/widgets/host_migrated_toast.dart     ← NEW
```

#### `room_service.dart` — HOST MIGRATION LOGIC

```dart
// Add onDisconnect hook when host creates the room:
// When hostUid player's isActive goes false → trigger migration check on all clients

// Add method — called by all clients when they detect host is gone:
Future<void> claimHostIfNeeded(String code, List<RoomPlayer> activePlayers) async {
  final snap = await _db.child('rooms/$code/hostUid').get();
  final currentHostUid = snap.value as String?;

  // Check if current host is inactive:
  final hostSnap = await _db.child('rooms/$code/players/$currentHostUid/isActive').get();
  final hostActive = hostSnap.value as bool? ?? false;
  if (hostActive) return; // host still here, nothing to do

  // Race: all clients try to set the new host at the same time
  // Only the winner (first writer) becomes host — Firebase last-write-wins
  // Sort active players by joinedAt to get consistent ordering:
  activePlayers.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
  final nextHost = activePlayers.firstWhere(
    (p) => p.uid != currentHostUid && p.isActive,
    orElse: () => activePlayers.first,
  );

  // Only attempt if this device is the next host:
  if (nextHost.uid != currentUid) return;

  await _db.child('rooms/$code').update({
    'hostUid': currentUid,
    'players/$currentUid/isHost': true,
    'players/$currentHostUid/isHost': false,
    'gameState/newHostUid': currentUid, // signals all clients to show toast
  });
}
```

#### Triggering migration check

```dart
// In multiplayer_game_screen.dart and lobby_screen.dart:
// Inside the roomStream listener, when any player's isActive changes:
_roomSub = RoomService.instance.roomStream(roomCode).listen((room) {
  if (room == null) return;

  // Check if host went inactive:
  final host = room.players[room.hostUid];
  if (host != null && !host.isActive) {
    RoomService.instance.claimHostIfNeeded(roomCode, room.activePlayers);
  }

  // Detect new host toast:
  final newHostUid = room.gameState?.newHostUid;
  if (newHostUid != null && newHostUid != _lastKnownHostUid) {
    _lastKnownHostUid = newHostUid;
    _showHostMigratedToast(room.players[newHostUid]?.name ?? 'Someone');
    // Clear the signal after reading:
    if (newHostUid == RoomService.instance.currentUid) {
      _db.child('rooms/$roomCode/gameState/newHostUid').remove();
    }
  }

  setState(() => _room = room);
});
```

#### `host_migrated_toast.dart` (CREATE)

```dart
// Overlay toast shown to all players:
// Icon(Icons.admin_panel_settings_rounded) in neonYellow
// "[Name] is now the host"
// Slides down from top, auto-dismisses after 4 seconds
// flutter_animate: .slideY(begin: -1.0).fadeIn()
// Host's device also gets PopScope updated — they now have host controls
```

**Add `String? _lastKnownHostUid` to `_MultiplayerGameScreenState` and `_LobbyScreenState`.**

---

### ITEM 13 — Dare Vote (Spectator Vote on Dares)

**Files to modify:**
```
lib/services/room_service.dart
lib/screens/multiplayer/multiplayer_game_screen.dart
lib/screens/multiplayer/widgets/dare_vote_panel.dart  ← NEW
```

#### Firebase additions

```
rooms/{code}/gameState/
  dareVotes/
    {voterUid}: 'pass' | 'fail'    ← each player's vote
  dareVoteResult: 'pass' | 'fail' | null
  dareVoteDeadline: timestamp      ← 10 seconds after prompt shown
```

#### `room_service.dart` — ADD METHODS

```dart
Future<void> submitDareVote(String code, String vote) async {
  await _db
    .child('rooms/$code/gameState/dareVotes/${currentUid}')
    .set(vote); // 'pass' or 'fail'
}

Future<void> resolveDareVote(String code, Map<dynamic, dynamic> votes) async {
  final passCount = votes.values.where((v) => v == 'pass').length;
  final failCount = votes.values.where((v) => v == 'fail').length;
  final result = passCount >= failCount ? 'pass' : 'fail';
  await _db.child('rooms/$code/gameState').update({
    'dareVoteResult': result,
    'dareVotes': null, // clear votes after resolution
  });
}

Future<void> clearDareVote(String code) async {
  await _db.child('rooms/$code/gameState').update({
    'dareVotes': null,
    'dareVoteResult': null,
    'dareVoteDeadline': null,
  });
}
```

#### `multiplayer_game_screen.dart`

```dart
// When a dare prompt is set (currentType == 'dare') and the active player's
// turn is shown — start the vote window for OTHER players:
// Set dareVoteDeadline = DateTime.now().millisecondsSinceEpoch + 10000

// In build(), if currentType == 'dare' and !_isMyTurn:
// Show DareVotePanel at bottom of screen

// Auto-resolve after deadline:
// Host device watches dareVoteDeadline and calls resolveDareVote() when expired
// Non-host devices cannot resolve — only read dareVoteResult

// When dareVoteResult is set:
// Show result banner: "✓ They passed!" or "✗ Doesn't count!"
// Then clear vote and advance to next player after 2 seconds
```

#### `dare_vote_panel.dart` (CREATE)

```dart
// Shown at the bottom of non-active players' screens during a dare:
// GlassCard sliding up from bottom with flutter_animate
//
// Title: "Did they nail it?"
// Countdown bar: 10 seconds depleting left to right (dareRed color)
// Two large buttons side by side:
//   "They Passed" — neonGreen background, Icon(Icons.check_rounded)
//   "Doesn't Count" — dareRed background, Icon(Icons.close_rounded)
// After voting: buttons replaced with "Vote submitted — waiting for others..."
// Live counter: "X of Y players voted" (watch dareVotes node count)
//
// Auto-submits 'pass' if user hasn't voted when deadline is reached
```

---

### ITEM 14 — Room Rejoin

**Files to modify:**
```
lib/services/room_service.dart
lib/services/preferences_service.dart         ← store last room + uid
lib/screens/multiplayer/join_room_screen.dart  ← rejoin detection
lib/screens/multiplayer/widgets/rejoin_banner.dart ← NEW
```

#### Store last room locally

```dart
// In PreferencesService:
static const String _keyLastRoomCode = 'last_room_code';
static const String _keyLastRoomUid  = 'last_room_uid';

String? get lastRoomCode => _prefs.getString(_keyLastRoomCode);
String? get lastRoomUid  => _prefs.getString(_keyLastRoomUid);

Future<void> saveLastRoom(String code, String uid) async {
  await _prefs.setString(_keyLastRoomCode, code);
  await _prefs.setString(_keyLastRoomUid, uid);
}

Future<void> clearLastRoom() async {
  await _prefs.remove(_keyLastRoomCode);
  await _prefs.remove(_keyLastRoomUid);
}
```

**Save after joining any room in `room_service.dart`:**
```dart
// At end of joinRoom() and joinAsSpectator() on success:
final prefs = await SharedPreferences.getInstance();
await prefs.setString('last_room_code', code);
await prefs.setString('last_room_uid', currentUid);
```

#### `room_service.dart` — REJOIN METHOD

```dart
// Rejoin verification: name (case-insensitive) + original UID must match
Future<String?> rejoinRoom({
  required String code,
  required String playerName,
  required String originalUid,
}) async {
  final snap = await _db.child('rooms/$code').get();
  if (!snap.exists) return 'Room no longer exists.';

  final room = Room.fromMap(code, snap.value as Map);
  if (room.status == 'ended') return 'This game has already ended.';

  // Find matching inactive player:
  final match = room.players.values.where((p) =>
    p.uid == originalUid &&
    p.name.toLowerCase() == playerName.trim().toLowerCase() &&
    !p.isActive,
  ).firstOrNull;

  if (match == null) return 'No matching player found in this room.';

  // Restore as active:
  await _db.child('rooms/$code/players/$originalUid').update({
    'isActive': true,
  });

  // Re-register onDisconnect:
  await _db
    .child('rooms/$code/players/$originalUid/isActive')
    .onDisconnect()
    .set(false);

  return null; // success
}
```

#### `join_room_screen.dart` — REJOIN DETECTION

```dart
// In initState(), check for a saved last room:
final lastCode = context.read<PreferencesService>().lastRoomCode;
final lastUid  = context.read<PreferencesService>().lastRoomUid;

if (lastCode != null && lastUid != null) {
  // Check if room still exists and player is inactive:
  final snap = await FirebaseDatabase.instance.ref('rooms/$lastCode').get();
  if (snap.exists) {
    final room = Room.fromMap(lastCode, snap.value as Map);
    final player = room.players[lastUid];
    if (player != null && !player.isActive && room.status != 'ended') {
      // Show rejoin banner at top of join screen
      setState(() {
        _showRejoinBanner = true;
        _rejoinCode = lastCode;
        _rejoinName = player.name;
        _rejoinUid = lastUid;
      });
    }
  } else {
    // Room gone — clear saved data:
    context.read<PreferencesService>().clearLastRoom();
  }
}
```

#### `rejoin_banner.dart` (CREATE)

```dart
// Prominent GlassCard at the top of join_room_screen.dart when rejoin is detected:
// accentColor: AppColors.neonGreen
// Icon(Icons.refresh_rounded) in neonGreen
// "You were in a game!"
// "Room [code] · Playing as [name]"
// Standard Action Button: "Rejoin Game"
//   onTap: calls RoomService.instance.rejoinRoom(code, name, uid)
//   On success: navigate to LobbyScreen or MultiplayerGameScreen based on room.status
//   On error: show error and hide the banner
// Small TextButton below: "Dismiss" → clears saved room + hides banner

// Animate in with flutter_animate: .fadeIn(400.ms).slideY(begin: -0.3)
```

---

### ITEM 15 — Change Mode Without Leaving Room

**Files to modify:**
```
lib/services/room_service.dart
lib/screens/multiplayer/multiplayer_game_screen.dart  ← add "Change Mode" on results
lib/screens/multiplayer/create_room_screen.dart       ← extract mode picker as reusable widget
lib/screens/multiplayer/widgets/change_mode_sheet.dart ← NEW
```

#### `room_service.dart` — ADD METHOD

```dart
Future<void> changeRoomMode({
  required String code,
  required String newMode,
  required List<String> newPacks,
}) async {
  await _db.child('rooms/$code').update({
    'mode': newMode,
    'packs': newPacks,
    'status': 'lobby',
    'gameState': null,          // clear previous game state entirely
    'missionDuration': null,    // clear secret mission specific fields
  });
  // Clear per-player mission data:
  final snap = await _db.child('rooms/$code/players').get();
  if (snap.exists) {
    final updates = <String, dynamic>{};
    final players = snap.value as Map;
    for (final uid in players.keys) {
      updates['rooms/$code/players/$uid/secretMission'] = null;
      updates['rooms/$code/players/$uid/hasReadMission'] = null;
      updates['rooms/$code/players/$uid/accusations'] = null;
    }
    await _db.update(updates);
  }
}
```

#### `change_mode_sheet.dart` (CREATE)

```dart
// Bottom sheet shown only on the host's results/end screen
// Reuses the mode picker list from CreateRoomScreen (extract to a shared widget)
// Title: "Play Again — Different Mode?"
// Mode list: same GlassCard tiles as CreateRoomScreen
// Pack picker: shown if mode is truth_or_dare
// Duration picker: shown if mode is secret_mission
//
// Two buttons at bottom:
//   "Same Mode Again" — calls RoomService.startGame() with current settings
//   "Change Mode" — confirms selection and calls RoomService.changeRoomMode()
//
// On changeRoomMode() success:
//   All devices detect status changed back to 'lobby' via roomStream
//   All devices auto-navigate back to LobbyScreen
//   Host sees the lobby with "Start Game" button
//   Non-hosts see "Waiting for host to start..."
```

#### Integration in `multiplayer_game_screen.dart`

```dart
// On the game-end/results screen, replace "Play Again" with:
if (RoomService.instance.currentUid == _room!.hostUid) ...[
  StandardActionButton(
    label: 'Play Again',
    icon: Icons.replay_rounded,
    color: AppColors.neonGreen,
    onTap: () => showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeModeSheet(
        roomCode: roomCode,
        currentMode: _room!.mode,
        currentPacks: _room!.packs,
      ),
    ),
  ),
] else ...[
  // Non-host sees:
  Text('Waiting for host to start next game...', style: /* muted */),
  CircularProgressIndicator(color: AppColors.primaryNeon),
]
```

---

### ITEM 16 — QR Code (Display + Scan)

**Packages to add:**
```yaml
qr_flutter: ^4.1.0
mobile_scanner: ^6.0.2
```

**Files to modify:**
```
lib/screens/multiplayer/lobby_screen.dart         ← QR display
lib/screens/multiplayer/join_room_screen.dart     ← QR scan
lib/screens/multiplayer/widgets/qr_display_sheet.dart ← NEW
lib/screens/multiplayer/widgets/qr_scanner_screen.dart ← NEW
```

#### `qr_display_sheet.dart` (CREATE)

```dart
// Bottom sheet triggered from lobby_screen.dart by host tapping "Show QR":
class QrDisplaySheet extends StatelessWidget {
  final String roomCode;
  // ...

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: AppColors.primaryNeon,
      child: Column(children: [
        Text('Scan to Join', style: /* bold white 20 */),
        SizedBox(height: 8),
        Text('Or enter code: $roomCode', style: /* muted */),
        SizedBox(height: 24),

        // QR code — white background required for scanning:
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: QrImageView(
            data: 'cousinchaos://join/$roomCode',  // deep link format
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.background,
          ),
        ),

        SizedBox(height: 20),
        Text('Works on both iPhone and Android', style: /* muted 13 */),
        SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Done'),
        ),
      ]),
    );
  }
}
```

#### Lobby screen — add QR button

```dart
// Next to the Share Code button in lobby_screen.dart:
GestureDetector(
  onTap: () => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => QrDisplaySheet(roomCode: widget.roomCode),
  ),
  child: Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.glassWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.glassBorder),
    ),
    child: Icon(Icons.qr_code_rounded, color: Colors.white, size: 22),
  ),
)
```

#### `qr_scanner_screen.dart` (CREATE)

```dart
// Full-screen camera scanner using mobile_scanner:
class QrScannerScreen extends StatelessWidget {
  final ValueChanged<String> onCodeScanned;
  // ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Scan QR Code'),
        leading: /* standard glass back button */,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(children: [
        MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            final value = barcode?.rawValue;
            if (value != null && value.startsWith('cousinchaos://join/')) {
              final code = value.replaceFirst('cousinchaos://join/', '');
              if (code.length == 6) {
                Navigator.pop(context);
                onCodeScanned(code);
              }
            }
          },
        ),
        // Overlay: dark corners with a clear center square:
        _ScannerOverlay(),
        // Bottom label:
        Positioned(
          bottom: 40,
          left: 0, right: 0,
          child: Text(
            'Point at the host\'s QR code',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ]),
    );
  }
}
```

#### `join_room_screen.dart` — ADD QR SCAN BUTTON

```dart
// Add a secondary button below the code input field:
TextButton.icon(
  onPressed: () => Navigator.push(
    context,
    slideUpRoute(QrScannerScreen(
      onCodeScanned: (code) {
        _codeController.text = code;
        // Auto-trigger join if name is already filled:
        if (_nameController.text.trim().isNotEmpty) {
          _joinRoom();
        }
      },
    )),
  ),
  icon: Icon(Icons.qr_code_scanner_rounded, color: AppColors.truthBlue),
  label: Text('Scan QR Code instead', style: TextStyle(color: AppColors.truthBlue)),
)
```

---

### ITEM 17 — Cross-Platform Player Badge

**Files to modify:**
```
lib/core/models/room_player.dart              ← add platform field
lib/services/room_service.dart                ← write platform on join
lib/screens/multiplayer/widgets/player_list_tile.dart
lib/screens/multiplayer/lobby_screen.dart     ← update How to Play text
```

#### `room_player.dart` — ADD FIELD

```dart
final String platform; // 'ios' | 'android'

// In toMap():
'platform': platform,

// In fromMap():
platform: map['platform'] as String? ?? 'android',
```

#### `room_service.dart` — WRITE PLATFORM ON JOIN

```dart
// In both joinRoom() and joinAsSpectator(), add platform to player data:
import 'dart:io';

// In the player toMap():
'platform': Platform.isIOS ? 'ios' : 'android',
```

#### `player_list_tile.dart` — SHOW PLATFORM BADGE

```dart
// In the trailing section of each player tile:
// Small icon next to the player name:
Icon(
  player.platform == 'ios'
    ? Icons.phone_iphone_rounded
    : Icons.phone_android_rounded,
  color: AppColors.textMuted,
  size: 14,
)

// Show as a Tooltip:
Tooltip(
  message: player.platform == 'ios' ? 'iPhone' : 'Android',
  child: Icon(/* above */),
)
```

#### Lobby How to Play text update

```dart
// In the lobby screen informational section or HowToPlaySheet for multiplayer:
// Add: "Works on both iPhone and Android in the same room"
// With: Row of Icon(Icons.phone_iphone_rounded) + Icon(Icons.phone_android_rounded)
```

---

## PHASE 10 PUBSPEC ADDITIONS

```yaml
# ADD these (Phase 10):
home_widget: ^0.7.0         # Home screen widget (App Item 10)
qr_flutter: ^4.1.0          # QR code display (Multiplayer Item 16)
mobile_scanner: ^6.0.2      # QR code scanning (Multiplayer Item 16)

# NO new packages for:
# App Items 1–9 (Flutter built-ins + existing packages)
# Multiplayer Items 11–15, 17 (Firebase + Flutter built-ins)
```

---

## PHASE 10 IMPLEMENTATION ORDER

| Step | Task | Group |
|---|---|---|
| 57 | Create `avatar_constants.dart` + `player_avatar.dart` + update `player.dart` + `player_manager.dart` | App 1 |
| 58 | Update all screens to show `PlayerAvatar` — add avatar picker bottom sheet | App 1 |
| 59 | Create `game_themes.dart` + apply per-screen theme to all 10 game screens | App 2 |
| 60 | Create `add_prompt_sheet.dart` + integrate into `game_engine_screen.dart` | App 3 |
| 61 | Extend `SessionStatsService` + create `highlights_screen.dart` | App 4 |
| 62 | Create `sound_themes.dart` + update `SoundService` + settings UI + add asset TODOs | App 5 |
| 63 | Create `prompt_rating_service.dart` + integrate into `prompt_card.dart` + weighted deck | App 6 |
| 64 | Create `haptic_themes.dart` + update `HapticService` + settings UI | App 7 |
| 65 | Create `responsive_layout.dart` + update portrait lock + tablet layouts | App 8 |
| 66 | Add auto-advance to `PreferencesService` + settings toggle + `prompt_card.dart` | App 9 |
| 67 | Add `home_widget` package + create `home_widget_service.dart` + native TODO comments | App 10 |
| 68 | Add `isSpectator` to `room_player.dart` + spectator join flow + `spectator_view.dart` + `join_request_toast.dart` | MP 11 |
| 69 | Add host migration to `room_service.dart` + `host_migrated_toast.dart` + wire in screens | MP 12 |
| 70 | Add dare vote to `room_service.dart` + `dare_vote_panel.dart` + wire in `multiplayer_game_screen.dart` | MP 13 |
| 71 | Add rejoin to `preferences_service.dart` + `room_service.dart` + `rejoin_banner.dart` + wire in `join_room_screen.dart` | MP 14 |
| 72 | Create `change_mode_sheet.dart` + `room_service.changeRoomMode()` + wire in results screen | MP 15 |
| 73 | Add `qr_flutter` + `mobile_scanner` + create `qr_display_sheet.dart` + `qr_scanner_screen.dart` + wire into lobby + join screens | MP 16 |
| 74 | Add `platform` field to `room_player.dart` + write on join + show badge in `player_list_tile.dart` | MP 17 |
| 75 | Run full QA pass — all new screens and multiplayer features across 3+ devices | QA |
| 76 | Final `flutter analyze` + all unit tests green + full regression | Final |

---

## PHASE 10 VERIFICATION CHECKLIST

**App:**
- [ ] Every player has a visible avatar (icon + color) throughout the entire app
- [ ] Avatar picker opens on tap — all 8 options shown — selection updates immediately
- [ ] Every game screen has its own distinct background gradient and glow color
- [ ] Custom prompt "+" button appears during T&D game — entered prompt is used immediately and not saved
- [ ] Highlights reel shows after every game — swipeable cards with correct stats per player
- [ ] Sound theme picker in Settings — "Retro" and "Cinematic" options visible (play system sounds until assets added)
- [ ] After completing a prompt, rating UI (Too Easy / Just Right / Brutal) slides up before advancing
- [ ] Rated prompts appear more/less frequently in subsequent rounds matching their rating
- [ ] Haptic theme picker in Settings — "Subtle" noticeably lighter, "Intense" noticeably heavier
- [ ] On a tablet (shortestSide >= 600dp): home screen shows 3-column grid, game screen shows two-column layout
- [ ] Auto-advance toggle in Settings — when on, prompt advances without tapping after timer ends
- [ ] Home screen widget shows on device home screen with today's challenge (after native setup)

**Multiplayer:**
- [ ] Joining a game already in progress shows "Watch as Spectator" option
- [ ] Spectators see the full game in read-only mode with a "Request to Join" button
- [ ] Host sees a join request toast — "Let In" promotes spectator to active player
- [ ] If host disconnects mid-game, next player (by join order) becomes host within ~10 seconds
- [ ] Toast notification shown to all players when host migrates
- [ ] New host has full host controls immediately after migration
- [ ] During a dare, non-active players see the vote panel with 10-second countdown
- [ ] After all votes, result banner shows "They passed!" or "Doesn't count!" on all screens
- [ ] If phone dies mid-game, player can rejoin using same name + original code
- [ ] Rejoin banner auto-detects last room on the join screen
- [ ] After a game ends, host can tap "Play Again" and choose same mode or a different mode
- [ ] Changing mode resets all game state but keeps all players in the room
- [ ] Non-host players auto-navigate back to lobby when mode is changed
- [ ] Host's lobby screen shows a QR icon — tapping it shows scannable QR code
- [ ] Joiner's screen has "Scan QR Code instead" — camera opens, scans, auto-fills code
- [ ] Platform badge (iPhone/Android icon) visible next to each player name in lobby

---

# MASTER PUBSPEC.YAML — ALL PACKAGES ACROSS ALL PHASES

> Cumulative reference. Add packages in phase order. Never add a package twice.

```yaml
# ── Already present in original project (DO NOT ADD) ──────────────────────
# audioplayers: ^6.6.0
# animate_do: ^5.1.0
# google_fonts: ^8.1.0
# provider: ^6.1.5+1
# shared_preferences: ^2.5.5
# flutter_fortune_wheel: ^1.3.2
# uuid: ^4.5.3
# http: ^1.6.0

# ── Phase 5 ────────────────────────────────────────────────────────────────
confetti: ^0.8.0                  # Win screen confetti burst
flutter_animate: ^4.5.0           # Animation chaining API

# ── Phase 7 ────────────────────────────────────────────────────────────────
flutter_native_splash: ^2.4.0    # Splash screen
flutter_launcher_icons: ^0.14.1  # App icon
url_launcher: ^6.3.1             # Privacy policy link
firebase_core: ^3.13.0           # Firebase foundation (also needed for Phase 8)
firebase_crashlytics: ^4.3.4     # Crash reporting
package_info_plus: ^8.3.0        # Dynamic version display in settings

# ── Phase 8 ────────────────────────────────────────────────────────────────
firebase_database: ^11.1.6       # Realtime Database for multiplayer rooms
firebase_auth: ^5.5.2            # Anonymous auth for player UIDs

# ── Phase 9 ────────────────────────────────────────────────────────────────
share_plus: ^10.1.4              # Share prompts and room codes
in_app_review: ^2.0.10           # App rating prompt after 3rd session

# ── Phase 10 ───────────────────────────────────────────────────────────────
home_widget: ^0.7.0              # Home screen widget (requires native setup)
qr_flutter: ^4.1.0               # QR code display in lobby
mobile_scanner: ^6.0.2           # QR code scanning on join screen
```

---

*End of implementation plan. Total: 15 bug fixes + sound system + full UI redesign + 18 animations + 21 QA scenarios (14 core + 6 multiplayer + 1 secret mission) + 21 launch readiness items + full multiplayer room system (8 modes including Secret Mission) + 10 hardening items + 17 advanced features (10 app + 7 multiplayer). 76 implementation steps across 10 phases.*
