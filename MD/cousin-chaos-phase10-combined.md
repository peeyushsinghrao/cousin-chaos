# COUSIN CHAOS — PHASE 10
## Advanced Features & Multiplayer Enhancements

> **Prerequisite:** Phases 1–9 must be fully implemented before starting this phase.
> This document is standalone — it contains only Phase 10 content.

---

### Design Decisions
- **Player avatars:** Color + icon picked together (8 pairs: crown, flame, ghost, skull, star, bolt, diamond, rocket)
- **Prompt difficulty rating:** Only the player who received the prompt rates it
- **Spectator → Player promotion:** Spectator taps "Request to Join", host approves
- **Host migration:** Automatic, with a toast notification to all players
- **Room rejoin:** Name (case-insensitive) + original UID stored locally — both must match
- **QR code:** Both display on host screen (`qr_flutter`) AND scan on joiner screen (`mobile_scanner`)


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

**Also update `GlassCard` accent colors** in each screen to use `GameTheme.primary` instead of hardcoded `AppColors.primaryNeon`.

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

Add a "+" icon button to the AppBar trailing — only visible during the prompt selection phase:

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
        type: _lastSelectedType ?? 'truth',
        onAdd: (prompt) {
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

Show the rating UI after the player taps "Next Player":

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

  switch (_currentTheme) {
    case HapticTheme.subtle:
      await HapticFeedback.selectionClick();
      break;
    case HapticTheme.standard:
      await _standardTrigger(event);
      break;
    case HapticTheme.intense:
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
// Only lock portrait on phones. Tablets get all orientations.
// Phone screens (in initState of every game screen on phones):
if (!ResponsiveLayout.isTablet(context)) {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
```

#### Tablet two-column layout — `home_screen.dart`

```dart
ResponsiveLayout(
  phone: _buildPhoneGrid(),    // existing 2-column grid
  tablet: _buildTabletGrid(),  // 3-column wider grid with larger cards
)

Widget _buildTabletGrid() {
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
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
  await Future.delayed(const Duration(milliseconds: 800));
  if (mounted) widget.onNext();
} else {
  setState(() => _timerComplete = true);
}

// When autoAdvance is on, show countdown notice when _timeLeft <= 5:
// "Auto-advancing in Xs..." text below the timer
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
    final prompts = RandomChallengeData.challenges;
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

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await updateWidget();
  }
}
```

**Call in `main.dart`:** `await HomeWidgetService.init();`

**Call when app resumes** — in `home_screen.dart`:
```dart
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

> **Note for developer:** Native widget layout files must be created manually. Leave `// TODO: Add native widget layout files` comment in `home_widget_service.dart`.

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
final bool hasRequestedToPlay;

// Add to fromMap() and toMap()
```

#### `room_service.dart` — ADD METHODS

```dart
Future<String?> joinAsSpectator({
  required String code,
  required String playerName,
}) async {
  final snap = await _db.child('rooms/$code').get();
  if (!snap.exists) return 'Room not found.';
  final room = Room.fromMap(code, snap.value as Map);
  if (room.status == 'ended') return 'This game has already ended.';

  final uid = currentUid;
  await _db.child('rooms/$code/players/$uid').set(
    RoomPlayer(
      uid: uid,
      name: playerName,
      isHost: false,
      isActive: true,
      isSpectator: true,
      hasRequestedToPlay: false,
      joinedAt: DateTime.now().millisecondsSinceEpoch,
    ).toMap(),
  );
  await _db.child('rooms/$code/players/$uid/isActive').onDisconnect().set(false);
  return null;
}

Future<void> requestToPlay(String code) async {
  await _db.child('rooms/$code/players/$currentUid/hasRequestedToPlay').set(true);
}

Future<void> approveSpectator(String code, String spectatorUid) async {
  await _db.child('rooms/$code/players/$spectatorUid').update({
    'isSpectator': false,
    'hasRequestedToPlay': false,
  });
  final snap = await _db.child('rooms/$code/gameState/playerOrder').get();
  final order = List<String>.from(snap.value as List? ?? []);
  order.add(spectatorUid);
  await _db.child('rooms/$code/gameState/playerOrder').set(order);
}
```

#### `join_room_screen.dart` — ADD SPECTATOR OPTION

If room status is `'playing'`, show:
```
"This game is already in progress."
[Watch as Spectator]  [Cancel]
```

#### `lobby_screen.dart` — SPECTATORS SECTION

```dart
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

#### `spectator_view.dart` (CREATE)

```dart
// Shows the full game in read-only mode with "Watching" banner at top
// Bottom: "Request to Join" button
//   onTap: RoomService.instance.requestToPlay(roomCode)
//   After tap: button changes to "Request sent — waiting for host..."
//   When host approves: SpectatorView replaced by normal game UI automatically
```

#### `join_request_toast.dart` (CREATE)

```dart
// Shown on HOST's game screen when spectator taps "Request to Join"
// Toast: "[Name] wants to join the game"
// Two buttons: "Let In" | "Decline"
// Auto-dismisses after 15 seconds if no action taken
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
Future<void> claimHostIfNeeded(String code, List<RoomPlayer> activePlayers) async {
  final snap = await _db.child('rooms/$code/hostUid').get();
  final currentHostUid = snap.value as String?;
  final hostSnap = await _db.child('rooms/$code/players/$currentHostUid/isActive').get();
  final hostActive = hostSnap.value as bool? ?? false;
  if (hostActive) return;

  activePlayers.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
  final nextHost = activePlayers.firstWhere(
    (p) => p.uid != currentHostUid && p.isActive,
    orElse: () => activePlayers.first,
  );
  if (nextHost.uid != currentUid) return;

  await _db.child('rooms/$code').update({
    'hostUid': currentUid,
    'players/$currentUid/isHost': true,
    'players/$currentHostUid/isHost': false,
    'gameState/newHostUid': currentUid,
  });
}
```

#### Triggering migration + toast in game/lobby screens

```dart
// Add String? _lastKnownHostUid; to state
// Inside roomStream listener:
final host = room.players[room.hostUid];
if (host != null && !host.isActive) {
  RoomService.instance.claimHostIfNeeded(roomCode, room.activePlayers);
}

final newHostUid = room.gameState?.newHostUid;
if (newHostUid != null && newHostUid != _lastKnownHostUid) {
  _lastKnownHostUid = newHostUid;
  _showHostMigratedToast(room.players[newHostUid]?.name ?? 'Someone');
  if (newHostUid == RoomService.instance.currentUid) {
    _db.child('rooms/$roomCode/gameState/newHostUid').remove();
  }
}
```

#### `host_migrated_toast.dart` (CREATE)

```dart
// Overlay toast shown to all players:
// Icon(Icons.admin_panel_settings_rounded) in neonYellow
// "[Name] is now the host"
// Slides down from top, auto-dismisses after 4 seconds
// flutter_animate: .slideY(begin: -1.0).fadeIn()
```

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
    {voterUid}: 'pass' | 'fail'
  dareVoteResult: 'pass' | 'fail' | null
  dareVoteDeadline: timestamp      ← 10 seconds after prompt shown
```

#### `room_service.dart` — ADD METHODS

```dart
Future<void> submitDareVote(String code, String vote) async {
  await _db.child('rooms/$code/gameState/dareVotes/${currentUid}').set(vote);
}

Future<void> resolveDareVote(String code, Map<dynamic, dynamic> votes) async {
  final passCount = votes.values.where((v) => v == 'pass').length;
  final failCount = votes.values.where((v) => v == 'fail').length;
  final result = passCount >= failCount ? 'pass' : 'fail';
  await _db.child('rooms/$code/gameState').update({
    'dareVoteResult': result,
    'dareVotes': null,
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

#### `dare_vote_panel.dart` (CREATE)

```dart
// Shown at the bottom of non-active players' screens during a dare:
// Title: "Did they nail it?"
// Countdown bar: 10 seconds depleting left to right (dareRed color)
// Two large buttons: "They Passed" (neonGreen) | "Doesn't Count" (dareRed)
// After voting: "Vote submitted — waiting for others..."
// Live counter: "X of Y players voted"
// Auto-submits 'pass' if no vote when deadline reached
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

#### `room_service.dart` — REJOIN METHOD

```dart
Future<String?> rejoinRoom({
  required String code,
  required String playerName,
  required String originalUid,
}) async {
  final snap = await _db.child('rooms/$code').get();
  if (!snap.exists) return 'Room no longer exists.';
  final room = Room.fromMap(code, snap.value as Map);
  if (room.status == 'ended') return 'This game has already ended.';

  final match = room.players.values.where((p) =>
    p.uid == originalUid &&
    p.name.toLowerCase() == playerName.trim().toLowerCase() &&
    !p.isActive,
  ).firstOrNull;

  if (match == null) return 'No matching player found in this room.';

  await _db.child('rooms/$code/players/$originalUid').update({'isActive': true});
  await _db.child('rooms/$code/players/$originalUid/isActive').onDisconnect().set(false);
  return null;
}
```

#### `rejoin_banner.dart` (CREATE)

```dart
// Prominent GlassCard at the top of join_room_screen.dart when rejoin detected
// accentColor: AppColors.neonGreen
// "You were in a game!"
// "Room [code] · Playing as [name]"
// Standard Action Button: "Rejoin Game"
//   On success: navigate to LobbyScreen or MultiplayerGameScreen
//   On error: show error and hide the banner
// TextButton: "Dismiss" → clears saved room + hides banner
// Animate in: .fadeIn(400.ms).slideY(begin: -0.3)
```

---

### ITEM 15 — Change Mode Without Leaving Room

**Files to modify:**
```
lib/services/room_service.dart
lib/screens/multiplayer/multiplayer_game_screen.dart
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
    'gameState': null,
    'missionDuration': null,
  });
  final snap = await _db.child('rooms/$code/players').get();
  if (snap.exists) {
    final updates = <String, dynamic>{};
    for (final uid in (snap.value as Map).keys) {
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
// Bottom sheet on host's results/end screen
// Title: "Play Again — Different Mode?"
// Mode list: same GlassCard tiles as CreateRoomScreen
// Pack picker: shown if mode is truth_or_dare
// Two buttons: "Same Mode Again" | "Change Mode"
// On changeRoomMode() success: all devices detect status → 'lobby' → auto-navigate to LobbyScreen
```

#### Integration in `multiplayer_game_screen.dart`

```dart
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
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplaySheet extends StatelessWidget {
  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: AppColors.primaryNeon,
      child: Column(children: [
        Text('Scan to Join', style: /* bold white 20 */),
        SizedBox(height: 8),
        Text('Or enter code: $roomCode', style: /* muted */),
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: QrImageView(
            data: 'cousinchaos://join/$roomCode',
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.background,
          ),
        ),
        SizedBox(height: 20),
        Text('Works on both iPhone and Android', style: /* muted 13 */),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Done')),
      ]),
    );
  }
}
```

#### `qr_scanner_screen.dart` (CREATE)

```dart
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatelessWidget {
  final ValueChanged<String> onCodeScanned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Scan QR Code'), backgroundColor: Colors.transparent),
      body: Stack(children: [
        MobileScanner(
          onDetect: (capture) {
            final value = capture.barcodes.firstOrNull?.rawValue;
            if (value != null && value.startsWith('cousinchaos://join/')) {
              final code = value.replaceFirst('cousinchaos://join/', '');
              if (code.length == 6) { Navigator.pop(context); onCodeScanned(code); }
            }
          },
        ),
        Positioned(bottom: 40, left: 0, right: 0,
          child: Text("Point at the host's QR code",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16))),
      ]),
    );
  }
}
```

---

### ITEM 17 — Cross-Platform Player Badge

**Files to modify:**
```
lib/core/models/room_player.dart              ← add platform field
lib/services/room_service.dart                ← write platform on join
lib/screens/multiplayer/widgets/player_list_tile.dart
```

```dart
// room_player.dart:
final String platform; // 'ios' | 'android'

// room_service.dart — in joinRoom() and joinAsSpectator():
import 'dart:io';
'platform': Platform.isIOS ? 'ios' : 'android',

// player_list_tile.dart:
Tooltip(
  message: player.platform == 'ios' ? 'iPhone' : 'Android',
  child: Icon(
    player.platform == 'ios' ? Icons.phone_iphone_rounded : Icons.phone_android_rounded,
    color: AppColors.textMuted,
    size: 14,
  ),
)
```

---

## PHASE 10 PUBSPEC ADDITIONS

```yaml
home_widget: ^0.7.0         # Home screen widget (App Item 10)
qr_flutter: ^4.1.0          # QR code display (Multiplayer Item 16)
mobile_scanner: ^6.0.2      # QR code scanning (Multiplayer Item 16)
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
- [ ] Sound theme picker in Settings — "Retro" and "Cinematic" options visible
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

---

# PHASE 10 ADDENDUM 1 — POST-IMPLEMENTATION BUG FIXES & CLEANUP

> These issues were found after reviewing the implemented codebase. Fix all of them before proceeding with any new Phase 10 features. They are ordered by severity — fix in this exact order.

---

## BUG FIX 1 — SoundService: Double-play when theme is active

**Severity: HIGH — affects every user on every interaction**

**File:** `lib/services/sound_service.dart`

**Problem:**
When a non-system sound theme is active, the code plays the asset file AND then falls through to the `switch` statement below, which plays the system sound a second time.

**Fix — add `return` after successful asset play:**

```dart
Future<void> play(SoundEvent event, {bool soundEnabled = true}) async {
  if (!soundEnabled) return;

  if (_currentTheme != SoundTheme.system) {
    final path = SoundThemeConstants.assetPath(_currentTheme, event.name);
    try {
      await _player.play(AssetSource(path));
      return; // ← ADD THIS — prevents falling through to system sounds
    } catch (_) {
      // Asset missing or failed — fall through to system sound fallback
    }
  }

  // System sound fallback:
  switch (event) {
    case SoundEvent.tap:
    case SoundEvent.countdown:
    case SoundEvent.bombTick:
      await SystemSound.play(SystemSoundType.click);
      HapticService.instance.tap();
      break;
    case SoundEvent.explosion:
    case SoundEvent.win:
      HapticService.instance.success();
      break;
    case SoundEvent.wrong:
      HapticService.instance.error();
      break;
    case SoundEvent.timerEnd:
      HapticService.instance.warning();
      await SystemSound.play(SystemSoundType.click);
      break;
    case SoundEvent.spin:
    case SoundEvent.cardReveal:
    case SoundEvent.freeze:
      HapticService.instance.confirm();
      break;
  }
}
```

---

## BUG FIX 2 — HapticService: `hapticsEnabled` toggle has no effect

**Severity: HIGH — Settings haptics toggle broken for all users**

**Fix — Step 1: In `preferences_service.dart` `_loadPreferences()`:**

```dart
HapticService.instance.setEnabled(_hapticsEnabled);
SoundService.instance.setVolume(_volume);
```

**Fix — Step 2: In `setHapticsEnabled()`:**

```dart
Future<void> setHapticsEnabled(bool value) async {
  _hapticsEnabled = value;
  HapticService.instance.setEnabled(value); // ← ADD THIS
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyHaptics, value);
  notifyListeners();
}
```

**Fix — Step 3: Register `HapticService` in `main.dart` MultiProvider:**

```dart
Provider(create: (_) => HapticService.instance),
```

---

## BUG FIX 3 — Settings: `activeColor` deprecation warning

**Severity: MEDIUM**

**Fix — replace in every Switch widget in settings_screen.dart:**

```dart
// BEFORE:
activeColor: AppColors.primaryNeon,

// AFTER:
activeTrackColor: AppColors.primaryNeon,
activeThumbColor: Colors.white,
```

Search for `activeColor:` globally and replace every instance.

---

## BUG FIX 4 — Lint warnings in production lib files

**Severity: MEDIUM**

**Fix each warning:**

- `unnecessary_underscores` — rename `__`/`___` to `_`/`__`
- `curly_braces_in_flow_control_structures` in `player_manager.dart`:
  ```dart
  while (_players.any((p) => p.name == 'Player $n')) {
    n++;
  }
  ```
- `sized_box_for_whitespace` — replace `Container(height: X)` with `SizedBox(height: X)`

Run `flutter analyze` after fixing and confirm zero warnings in `lib/`.

---

## BUG FIX 5 — Room rejoin: Player UID not stored

**Severity: MEDIUM — rejoin feature non-functional**

**Fix — Step 1: Add UID key to `PreferencesService`:**

```dart
static const String _keyLastRoomUid = 'last_room_uid';
String? get lastRoomUid => _prefs?.getString(_keyLastRoomUid);

Future<void> setLastRoomUid(String uid) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyLastRoomUid, uid);
}
```

**Fix — Step 2: In `room_service.dart`, save UID when joining:**

```dart
await PreferencesService.instance.setCurrentRoomCode(code);
await PreferencesService.instance.setLastRoomUid(currentUid); // ← ADD
```

**Fix — Step 3: In `room_rejoin_banner.dart`, use both values:**

```dart
final lastCode = PreferencesService.instance.currentRoomCode;
final lastUid = PreferencesService.instance.lastRoomUid;
if (lastCode == null || lastUid == null) return;

final error = await RoomService.instance.rejoinRoom(
  code: lastCode,
  playerName: _playerName,
  originalUid: lastUid,
);
```

---

## BUG FIX 6 — `ConnectivityService` not wired to offline fallback UI

**Severity: MEDIUM**

**Fix — In `game_engine_screen.dart`:**

```dart
bool _hasShownOfflineNotice = false;
// Reset in _initGame(): _hasShownOfflineNotice = false;

// In catch block of prompt fetch:
if (!_hasShownOfflineNotice && mounted) {
  _hasShownOfflineNotice = true;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(children: [
        Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
        SizedBox(width: 10),
        Text('No connection — using local prompts',
            style: TextStyle(color: Colors.white)),
      ]),
      backgroundColor: AppColors.surfaceBright,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: Duration(seconds: 3),
    ),
  );
}
```

Apply the same pattern in `multiplayer_game_screen.dart`.

---

## BUG FIX 7 — `slideUpRoute` never implemented

**Severity: LOW-MEDIUM**

**Create `lib/core/navigation/page_transitions.dart`:**

```dart
import 'package:flutter/material.dart';

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
```

Replace ALL `MaterialPageRoute` pushes with `slideUpRoute(...)` in:
- `home_screen.dart` — all 14 game card taps, Create Room, Join Room, Settings
- `create_room_screen.dart`, `join_room_screen.dart`, `lobby_screen.dart`
- `settings_screen.dart`, `pack_selection_screen.dart`, `player_setup_screen.dart`

---

## BUG FIX 8 — Root-level junk files cleanup

**Severity: LOW**

**Delete from project root:**
```
fix.dart, fix2.dart, update_modes.dart
generate_data.dart, generate_data.py
generate_impostor_data.dart, generate_impostor_data.py
generate_modes_data.dart, generate_modes_data.py
generate_pack_data.dart, gen_sounds.py
remixed-40d671c6.md, remixed-662bd0ea.md, remixed-dff581ff.md, remixed-f10dbd5a.md
analyze_output.txt, analyze_output_utf8.txt
testsprite_tests/ (entire directory)
```

If scripts may be needed later, move to `scripts/` and add to `.gitignore`.

---

## BUG FIX 9 — `sensors_plus` audit

**Severity: LOW**

Search `lib/` for `sensors_plus`, `accelerometerEvents`, `gyroscopeEvents`. If nothing found, remove from `pubspec.yaml` and run `flutter pub get`.

---

## BUG FIX 10 — Missing unit tests

**Severity: LOW**

Create in `test/`:
- `test/services/player_manager_test.dart`
- `test/services/session_stats_service_test.dart`
- `test/services/sound_service_test.dart`
- `test/services/haptic_service_test.dart`
- `test/core/game_constants_test.dart`

Run `flutter test` — all must pass with zero failures.

---

## ADDENDUM 1 — IMPLEMENTATION ORDER

| Step | Fix | Severity |
|---|---|---|
| P10-F1 | `SoundService` double-play — add `return` after asset play | HIGH |
| P10-F2 | `HapticService` toggle wiring — `setEnabled()` in prefs + MultiProvider | HIGH |
| P10-F3 | `activeColor` → `activeTrackColor` + `activeThumbColor` in Settings | MEDIUM |
| P10-F4 | Fix all lint warnings in `lib/` | MEDIUM |
| P10-F5 | Add `lastRoomUid` to `PreferencesService` + wire into room service + rejoin banner | MEDIUM |
| P10-F6 | Wire offline snack bar into game engine + multiplayer game screens | MEDIUM |
| P10-F7 | Create `page_transitions.dart` + replace all `MaterialPageRoute` | LOW-MEDIUM |
| P10-F8 | Delete all root-level junk files + move scripts to `scripts/` folder | LOW |
| P10-F9 | Audit and remove `sensors_plus` if unused | LOW |
| P10-F10 | Create 5 unit test files + run `flutter test` | LOW |

---

## ADDENDUM 1 VERIFICATION CHECKLIST

- [ ] `flutter analyze` returns **zero warnings in `lib/`**
- [ ] Tapping any button with Retro or Cinematic theme active plays ONE sound, not two
- [ ] Toggling haptics OFF in Settings — confirm zero haptic feedback in any game
- [ ] No deprecation warnings for `activeColor` anywhere in the project
- [ ] `sensors_plus` either removed from pubspec or its usage is documented
- [ ] All root-level `.dart`, `.py`, and `.md` junk files are gone from project root
- [ ] Room rejoin banner appears correctly when reopening the app after a mid-game disconnect
- [ ] Rejoining a room with the correct name + code works and restores the player to active
- [ ] Going offline mid T&D game shows "No connection — using local prompts" exactly once per session
- [ ] Every screen transition from home screen uses the same scale+fade animation
- [ ] All 5 unit test files exist and `flutter test` passes with zero failures
- [ ] `flutter build apk --release` completes with zero errors
- [ ] `flutter build ios --release` completes with zero errors (if Mac available)

---

---

# PHASE 10 ADDENDUM 2 — STRATEGIC & POLISH ADDITIONS

> These items address audience targeting, monetization, platform strategy, backend hardening, and remaining UX gaps. Implement after all Addendum 1 bug fixes are resolved.

---

## ITEM A — MONETIZATION: Free with Premium Packs

### What It Is

The app is **free to download**. All 14 game modes stay free forever. A subset of Truth or Dare packs are locked behind a **single one-time in-app purchase** that unlocks everything permanently.

### Free vs Premium Pack Split

| Pack | Tier |
|---|---|
| Party Starter | FREE |
| Family Night | FREE |
| Mild But Wild | FREE |
| Classic | FREE |
| Spice It Up | PREMIUM |
| Girls Night | PREMIUM |
| Guys Unleashed | PREMIUM |
| Deep Dive | PREMIUM |
| Couples Edition | PREMIUM |
| Office Party | PREMIUM |
| All remaining packs | PREMIUM |
| Custom Packs | FREE (always) |

### Package to Add

```yaml
in_app_purchase: ^3.2.0
```

### New Files to Create

```
lib/services/purchase_service.dart           ← all IAP logic
lib/screens/store/unlock_screen.dart         ← paywall screen
lib/core/constants/pack_tiers.dart           ← free vs premium pack IDs
lib/core/widgets/locked_pack_overlay.dart    ← lock icon shown on premium packs
```

---

### `lib/core/constants/pack_tiers.dart` (CREATE)

```dart
class PackTiers {
  static const Set<String> freePacks = {
    'party_starter',
    'family_night',
    'mild_but_wild',
    'classic',
  };

  static const String premiumProductId = 'com.yourname.cousinchaos.premium';

  static bool isFree(String packId) => freePacks.contains(packId);
  static bool isPremium(String packId) => !freePacks.contains(packId);
}
```

### `lib/services/purchase_service.dart` (CREATE)

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/pack_tiers.dart';

class PurchaseService extends ChangeNotifier {
  static final PurchaseService instance = PurchaseService._internal();
  PurchaseService._internal();

  static const String _keyPremiumUnlocked = 'premium_unlocked';

  bool _premiumUnlocked = false;
  bool _isPurchasing = false;
  String? _errorMessage;

  bool get premiumUnlocked => _premiumUnlocked;
  bool get isPurchasing => _isPurchasing;
  String? get errorMessage => _errorMessage;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _premiumUnlocked = prefs.getBool(_keyPremiumUnlocked) ?? false;
    notifyListeners();

    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) => _setError('Purchase stream error: $e'),
    );

    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> buyPremium() async {
    _setError(null);
    setState(() => _isPurchasing = true);

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      _setError('Store not available. Check your connection and try again.');
      setState(() => _isPurchasing = false);
      return;
    }

    final response = await InAppPurchase.instance.queryProductDetails(
      {PackTiers.premiumProductId},
    );

    if (response.productDetails.isEmpty) {
      _setError('Product not found. Try again later.');
      setState(() => _isPurchasing = false);
      return;
    }

    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: response.productDetails.first),
    );
  }

  Future<void> restorePurchases() async {
    _setError(null);
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != PackTiers.premiumProductId) continue;
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _unlockPremium();
          await InAppPurchase.instance.completePurchase(purchase);
          break;
        case PurchaseStatus.error:
          _setError(purchase.error?.message ?? 'Purchase failed.');
          break;
        default:
          break;
      }
      setState(() => _isPurchasing = false);
    }
  }

  Future<void> _unlockPremium() async {
    _premiumUnlocked = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPremiumUnlocked, true);
    notifyListeners();
  }

  void _setError(String? msg) { _errorMessage = msg; notifyListeners(); }
  void setState(VoidCallback fn) { fn(); notifyListeners(); }

  @override
  void dispose() { _purchaseSubscription?.cancel(); super.dispose(); }
}
```

**Register in `main.dart`:** `ChangeNotifierProvider(create: (_) => PurchaseService.instance)`
**Call `init()` in `main.dart` before `runApp()`:** `await PurchaseService.instance.init();`

### `lib/core/widgets/locked_pack_overlay.dart` (CREATE)

```dart
class LockedPackOverlay extends StatelessWidget {
  final VoidCallback onUnlock;
  const LockedPackOverlay({super.key, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUnlock,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withAlpha(180),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neonYellow.withAlpha(60), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, color: AppColors.neonYellow, size: 28),
            SizedBox(height: 6),
            Text('Premium', style: /* bold neonYellow 11 */),
          ],
        ),
      ),
    );
  }
}
```

### `pack_selection_screen.dart` — Premium Integration

```dart
Consumer<PurchaseService>(
  builder: (context, purchases, _) {
    final isLocked = PackTiers.isPremium(pack.id) && !purchases.premiumUnlocked;
    return Stack(children: [
      _buildPackCard(pack, isSelected: !isLocked && isSelected),
      if (isLocked)
        Positioned.fill(
          child: LockedPackOverlay(
            onUnlock: () => Navigator.push(context, slideUpRoute(const UnlockScreen())),
          ),
        ),
    ]);
  },
)
```

Also add an "Unlock All Packs" banner at the top for non-premium users.

---

## ITEM B — Target Audience: Both Family & Friend Groups

- Update onboarding slide 1 body text: `"The ultimate party game for families, friends, and everyone in between."`
- Add `'audience'` tag to each pack: `'family'`, `'friends'`, or `'18+'`
- Add horizontal filter chips at top of pack selection: `All` | `Family` | `Friends` | `18+`
- Show audience badge on each pack card

---

## ITEM C — Firebase Backend Hardening

### C1 — Room Creation Rate Limiting

```dart
// In RoomService:
DateTime? _lastRoomCreated;
static const _minRoomCreateInterval = Duration(minutes: 2);

// At start of createRoom():
if (_lastRoomCreated != null) {
  final elapsed = DateTime.now().difference(_lastRoomCreated!);
  if (elapsed < _minRoomCreateInterval) {
    final remaining = _minRoomCreateInterval - elapsed;
    throw Exception('Please wait ${remaining.inSeconds} seconds before creating another room.');
  }
}
// At end before return:
_lastRoomCreated = DateTime.now();
```

Handle the exception in `create_room_screen.dart` via try-catch.

### C2 — Room Code Retry Limit

```dart
Future<String> _uniqueCode() async {
  const maxRetries = 10;
  int attempts = 0;
  while (attempts < maxRetries) {
    final code = _generateCode();
    try {
      final snap = await _db.child('rooms/$code').get().timeout(const Duration(seconds: 5));
      if (!snap.exists) return code;
    } on TimeoutException {
      throw Exception('Connection timed out. Check your internet and try again.');
    }
    attempts++;
  }
  throw Exception('Could not generate a room code. Please try again.');
}
```

### C3 — Firebase Cost Comment Block

```dart
// ── Firebase Usage Notes ─────────────────────────────────────────────────────
// Free Spark plan: 1GB storage, 10GB/month downloads, 100 simultaneous connections
// ~5-20 KB written per room, ~50-200 KB downloaded per device per session
// Blaze plan recommended if MAU > 10,000
// Monitor at: console.firebase.google.com → Usage tab
// ─────────────────────────────────────────────────────────────────────────────
```

---

## ITEM D — Web Version

**Strategy:** Minimal web companion at `play.cousinchaos.com` for joiners only. Host still uses the app.

**Files to create:**
```
lib/web/web_join_screen.dart
lib/web/web_game_screen.dart
lib/web/web_app.dart
```

**`main.dart` — platform-conditional entry:**
```dart
import 'package:flutter/foundation.dart';

if (kIsWeb) {
  runApp(const CousinChaosWebApp());
} else {
  runApp(const CousinChaosApp());
}
```

**`lobby_screen.dart` — update Share Code:**
```dart
'Join my Cousin Chaos room! 🎮\n\n'
'Room code: ${widget.roomCode}\n\n'
'Join from browser: https://play.cousinchaos.com/join/${widget.roomCode}\n'
'Or open the app and tap "Join Room"'
```

**`web/index.html` — update meta tags:**
```html
<meta name="description" content="Join a Cousin Chaos party game room from your browser. No download required.">
<meta property="og:title" content="Join Cousin Chaos">
<title>Cousin Chaos — Join Game</title>
```

> **Developer note:** Deploy with `flutter build web` then `firebase deploy --only hosting`.

---

## ITEM E — Loading State in Multiplayer Game Screen

### `room_service.dart`
```dart
Future<void> setFetchingPrompt(String code, bool isFetching) async {
  await _db.child('rooms/$code/gameState/isFetchingPrompt').set(isFetching);
}
```

### `GameState` model — add field
```dart
final bool isFetchingPrompt;
// fromMap: isFetchingPrompt: map['isFetchingPrompt'] as bool? ?? false,
// toMap: 'isFetchingPrompt': isFetchingPrompt,
```

### `multiplayer_game_screen.dart`
```dart
// Wrap _fetchAndSetPrompt():
await RoomService.instance.setFetchingPrompt(widget.roomCode, true);
try { /* existing logic */ }
finally { await RoomService.instance.setFetchingPrompt(widget.roomCode, false); }

// In build(), when isFetchingPrompt == true:
if (room.gameState?.isFetchingPrompt == true) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(children: [
      SkeletonCard(height: 200),
      const SizedBox(height: 16),
      Text('Getting your prompt...', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
    ]),
  );
}
```

---

## ITEM F — DisclaimerDialog: Once per Install

### `preferences_service.dart`
```dart
static const String _keyDisclaimerAccepted = 'disclaimer_accepted';
bool _disclaimerAccepted = false;
bool get disclaimerAccepted => _disclaimerAccepted;

// In _loadPreferences():
_disclaimerAccepted = prefs.getBool(_keyDisclaimerAccepted) ?? false;

Future<void> setDisclaimerAccepted() async {
  _disclaimerAccepted = true;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyDisclaimerAccepted, true);
  notifyListeners();
}
```

### `disclaimer_dialog.dart`
1. Delete `static bool _accepted` field
2. In `show()`: `if (prefs.disclaimerAccepted) { onAccept(); return; }`
3. In accept callback: call `prefs.setDisclaimerAccepted();` before `onAccept()`

---

## ITEM G — Highlights Reel: All Game Modes

Extend `SessionStatsService` with per-mode fields, wire into each game screen, add "See Highlights" button to all end screens, and update `HighlightsScreen` with mode-specific conditional cards:

- **Last Standing:** "First to Fall" card (neonPink / `sentiment_very_dissatisfied_rounded`)
- **Impostor:** title = `impostorWon ? "The Impostor Won!" : "Civilians Won!"` (dareRed / `search_rounded`)
- **Laugh Attack:** "Total Laughs" card (neonYellow / `emoji_emotions_rounded`)
- **Speed Challenge:** "Too Slow!" card (neonOrange / `timer_off_rounded`)

---

## ADDENDUM 2 PUBSPEC ADDITIONS

```yaml
in_app_purchase: ^3.2.0   # Premium pack monetization
```

---

## ADDENDUM 2 IMPLEMENTATION ORDER

| Step | Task |
|---|---|
| A1 | Create `pack_tiers.dart` + define free/premium split |
| A2 | Create `purchase_service.dart` + register in `main.dart` MultiProvider + call `init()` |
| A3 | Create `locked_pack_overlay.dart` widget |
| A4 | Create `unlock_screen.dart` paywall screen |
| A5 | Update `pack_selection_screen.dart` — lock overlay + unlock banner |
| A6 | Update `settings_screen.dart` — premium status tile |
| A7 | Register product in App Store Connect + Google Play Console |
| B1 | Update onboarding slide 1 body text |
| B2 | Add audience tags to packs + filter chips in pack selection |
| C1 | Add client-side room creation rate limit to `room_service.dart` |
| C2 | Add retry limit + timeout to `_uniqueCode()` |
| C3 | Add Firebase cost comment block to `room_service.dart` |
| D1–D5 | Create web files + update `main.dart` + `index.html` + lobby share text + deploy |
| E1–E3 | `setFetchingPrompt()` + `isFetchingPrompt` in `GameState` + skeleton in multiplayer screen |
| F1–F2 | Add `disclaimerAccepted` to `PreferencesService` + update `disclaimer_dialog.dart` |
| G1–G4 | Extend `SessionStatsService` + wire per-mode stats + add buttons + update highlights screen |

---

## ADDENDUM 2 VERIFICATION CHECKLIST

**Monetization:**
- [ ] Free packs fully selectable with no lock
- [ ] Premium packs show lock overlay with "Unlock Premium" on tap
- [ ] Completing a purchase unlocks all premium packs immediately without restart
- [ ] Restoring purchases re-unlocks premium on reinstall
- [ ] Premium status shows correctly in Settings

**Audience & Discovery:**
- [ ] Onboarding mentions both families and friends
- [ ] Pack audience tags visible on pack cards
- [ ] Pack filter chips work

**Backend Hardening:**
- [ ] Creating two rooms within 2 minutes shows a friendly wait message
- [ ] `_uniqueCode()` times out gracefully after 5 seconds per attempt

**Web Version:**
- [ ] `flutter build web` completes with zero errors
- [ ] Web join flow works from a browser
- [ ] Share Code in lobby includes the `play.cousinchaos.com/join/XXXXXX` URL

**Multiplayer Loading:**
- [ ] Other devices show skeleton card + "Getting your prompt..." while active player picks
- [ ] Skeleton disappears and prompt appears simultaneously on all devices

**Disclaimer:**
- [ ] Disclaimer shows only on first install — never again after accepting

**Highlights Reel:**
- [ ] "See Session Highlights" button visible on all game end screens
- [ ] Mode-specific highlight cards show correct data

---

---

# AI AGENT IMPLEMENTATION BRIEF
## Full Phase 10 + Addendum 1 (Bug Fixes) + Addendum 2 (Polish) — Excluding Monetization

---

## CONTEXT FOR THE AGENT

You are implementing Phase 10 features, bug fixes, and polish additions to **Cousin Chaos**, a Flutter party game app. The codebase from Phases 1–9 is fully working. Phase 10 files were partially created but many are NOT fully wired into the app yet.

**Your job:** implement all items below in the exact order listed. Read each file before editing it. Never recreate a file that already exists — check the EXISTS list first, then open and edit.

---

## WHAT ALREADY EXISTS (DO NOT RECREATE THESE)

```
lib/core/constants/avatar_constants.dart              ✓ EXISTS
lib/core/constants/game_themes.dart                   ✓ EXISTS (in constants/, not theme/)
lib/core/constants/haptic_themes.dart                 ✓ EXISTS
lib/core/constants/sound_themes.dart                  ✓ EXISTS
lib/core/layout/responsive_layout.dart                ✓ EXISTS
lib/core/widgets/add_prompt_sheet.dart                ✓ EXISTS
lib/core/widgets/host_migrated_toast.dart             ✓ EXISTS
lib/core/widgets/join_request_toast.dart              ✓ EXISTS
lib/core/widgets/player_avatar.dart                   ✓ EXISTS
lib/core/widgets/room_rejoin_banner.dart              ✓ EXISTS
lib/core/widgets/skeleton_card.dart                   ✓ EXISTS
lib/screens/highlights/highlights_screen.dart         ✓ EXISTS
lib/screens/multiplayer/widgets/dare_vote_panel.dart  ✓ EXISTS
lib/screens/multiplayer/widgets/mode_change_sheet.dart ✓ EXISTS
lib/screens/multiplayer/widgets/spectator_view.dart   ✓ EXISTS
lib/services/home_widget_service.dart                 ✓ EXISTS
lib/services/prompt_rating_service.dart               ✓ EXISTS
lib/services/session_stats_service.dart               ✓ EXISTS
assets/sounds/retro/*.mp3                             ✓ EXISTS (empty placeholders)
assets/sounds/cinematic/*.mp3                         ✓ EXISTS (empty placeholders)
```

---

## FILES TO PROVIDE TO THIS AGENT

```
lib/main.dart
lib/services/sound_service.dart
lib/services/haptic_service.dart
lib/services/preferences_service.dart
lib/services/room_service.dart
lib/services/session_stats_service.dart
lib/services/player_manager.dart
lib/services/prompt_rating_service.dart
lib/services/home_widget_service.dart
lib/core/constants/avatar_constants.dart
lib/core/constants/game_themes.dart
lib/core/constants/haptic_themes.dart
lib/core/constants/sound_themes.dart
lib/core/layout/responsive_layout.dart
lib/core/models/room.dart
lib/core/models/room_player.dart
lib/core/widgets/player_avatar.dart
lib/core/widgets/add_prompt_sheet.dart
lib/core/widgets/skeleton_card.dart
lib/core/widgets/host_migrated_toast.dart
lib/core/widgets/join_request_toast.dart
lib/core/widgets/room_rejoin_banner.dart
lib/screens/home/home_screen.dart
lib/screens/settings/settings_screen.dart
lib/screens/highlights/highlights_screen.dart
lib/screens/truth_or_dare/game_engine_screen.dart
lib/screens/truth_or_dare/player_setup_screen.dart
lib/screens/truth_or_dare/pack_selection_screen.dart
lib/screens/truth_or_dare/widgets/prompt_card.dart
lib/screens/shared/mode_player_setup_screen.dart
lib/screens/multiplayer/create_room_screen.dart
lib/screens/multiplayer/join_room_screen.dart
lib/screens/multiplayer/lobby_screen.dart
lib/screens/multiplayer/multiplayer_game_screen.dart
lib/screens/multiplayer/widgets/dare_vote_panel.dart
lib/screens/multiplayer/widgets/mode_change_sheet.dart
lib/screens/multiplayer/widgets/spectator_view.dart
lib/screens/multiplayer/widgets/player_list_tile.dart
lib/screens/new_modes/last_standing_screen.dart
lib/screens/new_modes/impostor_game_screen.dart
lib/screens/new_modes/laugh_attack_screen.dart
lib/screens/new_modes/speed_challenge_screen.dart
lib/screens/new_modes/bomb_pass_screen.dart
lib/screens/new_modes/freeze_mode_screen.dart
lib/screens/new_modes/chaos_mode_screen.dart
lib/screens/new_modes/target_player_screen.dart
lib/screens/new_modes/secret_mission_screen.dart
lib/widgets/disclaimer_dialog.dart
lib/models/player.dart
pubspec.yaml
test/widget_test.dart
```

---

## PUBSPEC ADDITIONS — DO FIRST

```yaml
home_widget: ^0.7.0
qr_flutter: ^4.1.0
mobile_scanner: ^6.0.2
```

Run `flutter pub get` after editing.

---

## COMPLETE IMPLEMENTATION ORDER

| Step | Task | Group |
|---|---|---|
| 0 | Add packages to `pubspec.yaml` + `flutter pub get` | Setup |
| 1 | `player.dart` add `avatarId` + `player_manager.dart` `addPlayer()` + `updatePlayerAvatar()` | App 1 |
| 2 | Wire `PlayerAvatar` into all 10 listed screens + avatar picker bottom sheet in both setup screens | App 1 |
| 3 | Apply `GameThemes` gradient + radial glow to all 10 game screens + `GlassCard` accent colors | App 2 |
| 4 | Wire `AddPromptSheet` into `game_engine_screen.dart` AppBar | App 3 |
| 5 | Extend `SessionStatsService` with all missing fields and methods | App 4 |
| 6 | Wire truth/dare/skip/round stats into `game_engine_screen.dart` | App 4 |
| 7 | Wire per-mode stats + "See Highlights" button into Last Standing, Impostor, Laugh Attack, Speed Challenge | App 4 |
| 8 | Update `highlights_screen.dart` with mode-specific conditional cards | App 4 |
| 9 | Update `sound_service.dart`: add `setTheme()` + fix double-play with `return` | App 5 / BF1 |
| 10 | Update `preferences_service.dart`: add sound theme + load in `_loadPreferences()` | App 5 |
| 11 | Add Sound Theme chip picker to `settings_screen.dart` | App 5 |
| 12 | Wire `prompt_card.dart`: rating UI after prompt + `_buildWeightedDeck()` in game engine | App 6 |
| 13 | Update `haptic_service.dart`: add `setTheme()` + subtle/standard/intense logic | App 7 |
| 14 | Update `preferences_service.dart`: haptic theme + `setEnabled()` wiring | App 7 / BF2 |
| 15 | Add Haptic Theme chip picker to `settings_screen.dart` | App 7 |
| 16 | Remove portrait lock from `main.dart` + per-screen lock + tablet layouts | App 8 |
| 17 | Add auto-advance to `preferences_service.dart` + settings toggle + `prompt_card.dart` | App 9 |
| 18 | Call `HomeWidgetService.init()` in `main.dart` + `AppLifecycleListener` in `home_screen.dart` | App 10 |
| 19 | Add `isSpectator` + `hasRequestedToPlay` to `room_player.dart` | MP 11 |
| 20 | Add `joinAsSpectator()`, `requestToPlay()`, `approveSpectator()` to `room_service.dart` | MP 11 |
| 21 | Spectator join dialog + Watching section in lobby + spectator view check + join request toast | MP 11 |
| 22 | Add `claimHostIfNeeded()` + wire into both screens + show `HostMigratedToast` | MP 12 |
| 23 | Add dare vote fields to `GameState` + vote methods + wire `DareVotePanel` | MP 13 |
| 24 | Add `lastRoomCode/Uid` to `preferences_service.dart` | MP 14 |
| 25 | Add `rejoinRoom()` + call `saveLastRoom()` in `createRoom()` + `joinRoom()` | MP 14 |
| 26 | Wire rejoin detection + `RoomRejoinBanner` in `join_room_screen.dart` | MP 14 |
| 27 | Add `changeRoomMode()` + wire Play Again / mode change in multiplayer results | MP 15 |
| 28 | Create `qr_display_sheet.dart` + `qr_scanner_screen.dart` + wire into lobby + join screens | MP 16 |
| 29 | Add `platform` field to `room_player.dart` + write on join + badge in `player_list_tile.dart` | MP 17 |
| 30 | Fix `activeColor` → `activeTrackColor` + `activeThumbColor` in ALL Switch widgets | BF3 |
| 31 | Run `flutter analyze` — fix all `lib/` warnings | BF4 |
| 32 | Create `page_transitions.dart` + replace all `MaterialPageRoute` | BF7 |
| 33 | Wire offline snack bar into game engine + multiplayer game screens | BF6 |
| 34 | Add `disclaimerAccepted` to `preferences_service.dart` + update `disclaimer_dialog.dart` | Addendum F |
| 35 | Add audience tags to packs + filter chips + update onboarding text | Addendum B |
| 36 | Rate limit + retry limit + cost comment in `room_service.dart` | Addendum C |
| 37 | `setFetchingPrompt()` + `isFetchingPrompt` in `GameState` + skeleton | Addendum E |
| 38 | Create web files + update `main.dart` kIsWeb + `index.html` + lobby share text | Addendum D |
| 39 | Create 5 unit test files + run `flutter test` | BF10 |
| 40 | Add `Provider(HapticService.instance)` to `main.dart` MultiProvider | BF2 |
| 41 | Audit + remove `sensors_plus` if unused | BF9 |
| 42 | Delete / move junk root files | BF8 |
| 43 | `flutter build apk --release` — zero errors | QA |
| 44 | Full QA pass against checklist | QA |

---

## FINAL VERIFICATION CHECKLIST

**App Items:**
- [ ] Every player has a visible avatar — picker opens on tap — 8 options shown
- [ ] Every game screen has its own distinct gradient and glow color
- [ ] Custom "+" button in T&D AppBar — entered prompt used immediately and not saved
- [ ] "See Highlights" button on ALL 5 game end screens
- [ ] Highlights reel shows swipeable cards with correct stats per game mode
- [ ] Sound Theme chip row in Settings — System / Retro / Cinematic
- [ ] Retro or Cinematic active: ONE sound per action (not two)
- [ ] Prompt rating slides up after completing a prompt
- [ ] Haptic Theme chip row — Subtle / Standard / Intense
- [ ] Haptics OFF → zero haptic feedback; ON → haptics return immediately
- [ ] Tablet: home shows 3-column grid, game shows two-column layout
- [ ] Auto-advance ON: prompt advances without tap after timer ends
- [ ] Home screen widget shows today's challenge

**Multiplayer:**
- [ ] Joining in-progress game shows "Watch as Spectator" option
- [ ] Spectator sees read-only game + "Request to Join" button
- [ ] Host sees join request toast — "Let In" promotes spectator
- [ ] Host disconnect → next player becomes host within ~10s + toast shown
- [ ] During dare: non-active players see 10-second vote panel
- [ ] Vote result shows on all screens simultaneously
- [ ] Rejoin banner auto-detects last room on join screen
- [ ] Rejoin with correct name + code restores player to active
- [ ] Host can choose same or different mode after game ends
- [ ] Mode change: all players auto-navigate to lobby
- [ ] Lobby QR icon → scannable QR code
- [ ] Join screen QR scanner → auto-fills code
- [ ] Platform badge visible in lobby player list

**Bug Fixes:**
- [ ] `flutter analyze` — zero warnings in `lib/`
- [ ] `flutter test` — zero failures
- [ ] No `activeColor` deprecation warnings
- [ ] Offline snack bar shows exactly once per session
- [ ] All screen transitions use scale+fade animation
- [ ] Disclaimer shows only on first install
- [ ] Root junk files deleted/moved
- [ ] `sensors_plus` audited

**Addendum:**
- [ ] Onboarding mentions both families and friends
- [ ] Pack audience tags + filter chips work
- [ ] Rate-limit message shown on rapid room creation
- [ ] Room code generation times out gracefully
- [ ] Multiplayer skeleton card shown while host fetches prompt
- [ ] `flutter build apk --release` — zero errors
- [ ] `flutter build web` — zero errors

---

## PRE-START QUESTIONS FOR THE AGENT

Answer these before beginning:

1. What is the exact constant name for room code storage in `PreferencesService`?
2. What is `currentUid` in `RoomService`? (Firebase Auth getter, stored field, etc.)
3. What parameters does `HighlightsScreen` constructor actually take?
4. Is `GameState` defined inside `room.dart` or a separate file?
5. Do Phase 9 unit test spec files exist anywhere in the project?
6. What is the existing Share Code implementation in `lobby_screen.dart`?
7. What is `_lastSelectedType` called in `game_engine_screen.dart`?

---

*End of combined Phase 10 document — covers Phase 10 features (Items 1–17), Addendum 1 (Bug Fixes 1–10), Addendum 2 (Strategic & Polish Additions), and the AI Agent Implementation Brief.*
