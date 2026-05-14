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


---

---

# PHASE 10 ADDENDUM — POST-IMPLEMENTATION BUG FIXES & CLEANUP

> These issues were found after reviewing the implemented codebase. Fix all of them before proceeding with any new Phase 10 features. They are ordered by severity — fix in this exact order.

---

## BUG FIX 1 — SoundService: Double-play when theme is active

**Severity: HIGH — affects every user on every interaction**

**File:** `lib/services/sound_service.dart`

**Problem:**
When a non-system sound theme is active, the code plays the asset file AND then falls through to the `switch` statement below, which plays the system sound a second time. Every tap, every card reveal, every bomb tick — all double-play.

```dart
// CURRENT BROKEN CODE:
if (_currentTheme != SoundTheme.system) {
  await _player.play(AssetSource(path)); // plays theme asset
  // NO return here — falls through to switch below
}
switch (event) {
  case SoundEvent.tap: await SystemSound.play(...); // ALSO plays — BUG
```

**Fix — add `return` after successful asset play:**

```dart
Future<void> play(SoundEvent event, {bool soundEnabled = true}) async {
  if (!soundEnabled) return;

  // Theme-based asset playback — return immediately on success
  if (_currentTheme != SoundTheme.system) {
    final path = SoundThemeConstants.assetPath(_currentTheme, event.name);
    try {
      await _player.play(AssetSource(path));
      return; // ← ADD THIS — prevents falling through to system sounds
    } catch (_) {
      // Asset missing or failed — fall through to system sound fallback below
    }
  }

  // System sound fallback (only reached when theme is 'system' OR asset failed):
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

**File:** `lib/services/haptic_service.dart` + `lib/services/preferences_service.dart` + `lib/main.dart`

**Problem:**
`HapticService` is a singleton with its own `_enabled` field, but `PreferencesService._loadPreferences()` never calls `HapticService.instance.setEnabled()`. So toggling haptics in Settings updates `PreferencesService` but `HapticService._enabled` stays `true` forever — the toggle does nothing.

**Fix — Step 1: In `preferences_service.dart` `_loadPreferences()`:**

```dart
Future<void> _loadPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  _soundEnabled = prefs.getBool(_keySound) ?? true;
  _hapticsEnabled = prefs.getBool(_keyHaptics) ?? true;
  // ... existing code ...

  // ADD THESE TWO LINES — wire enabled state to services:
  HapticService.instance.setEnabled(_hapticsEnabled);
  SoundService.instance.setVolume(_volume);

  notifyListeners();
}
```

**Fix — Step 2: In `preferences_service.dart` `setHapticsEnabled()`:**

```dart
Future<void> setHapticsEnabled(bool value) async {
  _hapticsEnabled = value;
  HapticService.instance.setEnabled(value); // ← ADD THIS
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyHaptics, value);
  notifyListeners();
}
```

**Fix — Step 3: In `preferences_service.dart` `setSoundEnabled()`:**

```dart
Future<void> setSoundEnabled(bool value) async {
  _soundEnabled = value;
  // SoundService reads soundEnabled per-call already — no extra wiring needed
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keySound, value);
  notifyListeners();
}
```

**Fix — Step 4: Register `HapticService` in `main.dart` MultiProvider:**

```dart
// In MultiProvider providers list, add:
Provider(create: (_) => HapticService.instance),
```

---

## BUG FIX 3 — Settings: `activeColor` deprecation warning

**Severity: MEDIUM — will break in future Flutter versions**

**File:** `lib/screens/settings/settings_screen.dart` line 222

**Problem:**
`Switch` widget's `activeColor` property was deprecated after Flutter v3.31.0. Generates a deprecation warning now and will stop compiling in future versions.

**Fix — replace in every Switch widget in settings_screen.dart:**

```dart
// BEFORE:
Switch(
  value: value,
  onChanged: onChanged,
  activeColor: AppColors.primaryNeon,  // deprecated
)

// AFTER:
Switch(
  value: value,
  onChanged: onChanged,
  activeTrackColor: AppColors.primaryNeon,   // ← use this
  activeThumbColor: Colors.white,             // ← and this
)
```

Search for `activeColor:` globally across the entire project and replace every instance. There may be more than one Switch widget affected.

---

## BUG FIX 4 — Lint warnings in production lib files

**Severity: MEDIUM — code quality**

**Files:**
```
lib/screens/home/home_screen.dart                line 112
lib/screens/never_have_i_ever/nhie_game_screen.dart  line 273
lib/screens/shared/mode_player_setup_screen.dart  line 203
lib/screens/truth_or_dare/pack_selection_screen.dart  line 365
lib/screens/truth_or_dare/player_setup_screen.dart    line 326
lib/screens/would_you_rather/wyr_game_screen.dart line 251
lib/services/player_manager.dart                  (curly braces warning)
lib/screens/new_modes/chaos_mode_screen.dart      line 116
lib/screens/settings/settings_screen.dart         (activeColor — already in Bug Fix 3)
```

**Fix each warning:**

**`unnecessary_underscores`** — appears in multiple files. Example pattern:

```dart
// BEFORE (causes warning):
final (__,  ___) = something;

// AFTER:
final (_, __) = something;
// OR use named variables if they're actually used
```

**`curly_braces_in_flow_control_structures`** — in `player_manager.dart`:

```dart
// BEFORE:
while (_players.any((p) => p.name == 'Player $n')) n++;

// AFTER:
while (_players.any((p) => p.name == 'Player $n')) {
  n++;
}
```

**`sized_box_for_whitespace`** — in `chaos_mode_screen.dart` line 116:

```dart
// BEFORE:
Container(height: 16)  // or similar empty Container

// AFTER:
const SizedBox(height: 16)
```

Run `flutter analyze` after fixing and confirm zero warnings in `lib/` files. Warnings in root-level generator scripts are acceptable since they won't ship.

---

## BUG FIX 5 — Room rejoin: Player UID not stored

**Severity: MEDIUM — rejoin feature non-functional**

**File:** `lib/services/preferences_service.dart` + `lib/services/room_service.dart`

**Problem:**
The rejoin banner UI exists but the verification requires both the room code AND the player's original Firebase UID. `PreferencesService` only stores `currentRoomCode` — the UID is never saved. Without it, the identity check in `rejoinRoom()` can't work.

**Fix — Step 1: Add UID key to `PreferencesService`:**

```dart
// Add constant:
static const String _keyLastRoomUid = 'last_room_uid';

// Add getter:
String? get lastRoomUid => _prefs?.getString(_keyLastRoomUid);
// Note: store _prefs as a field after init, or call getInstance() each time

// Add setter:
Future<void> setLastRoomUid(String uid) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyLastRoomUid, uid);
}

Future<void> clearLastRoom() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyRoomCode);
  await prefs.remove(_keyLastRoomUid);
}
```

**Fix — Step 2: In `room_service.dart`, save UID when joining:**

```dart
// In createRoom(), after writing to Firebase:
await PreferencesService.instance.setCurrentRoomCode(code);
await PreferencesService.instance.setLastRoomUid(currentUid); // ← ADD

// In joinRoom(), on success (before return null):
await PreferencesService.instance.setCurrentRoomCode(code);
await PreferencesService.instance.setLastRoomUid(currentUid); // ← ADD
```

**Fix — Step 3: In `room_rejoin_banner.dart`, use both values for matching:**

```dart
// When checking if rejoin is possible:
final lastCode = PreferencesService.instance.currentRoomCode;
final lastUid = PreferencesService.instance.lastRoomUid;

if (lastCode == null || lastUid == null) return; // both required

// When calling rejoin:
final error = await RoomService.instance.rejoinRoom(
  code: lastCode,
  playerName: _playerName, // from the name field
  originalUid: lastUid,    // ← pass the stored UID
);
```

---

## BUG FIX 6 — `ConnectivityService` not wired to offline fallback UI

**Severity: MEDIUM — offline feature exists but does nothing visible**

**File:** `lib/services/connectivity_service.dart` + `lib/screens/truth_or_dare/game_engine_screen.dart`

**Problem:**
`connectivity_service.dart` exists and works, but the offline snack bar ("No connection — using local prompts") was never wired into `game_engine_screen.dart`. When the API fails offline, the app silently falls back to local prompts with no user feedback.

**Fix — In `game_engine_screen.dart`:**

**Step 1: Add offline notice flag to state:**
```dart
bool _hasShownOfflineNotice = false;
```

**Step 2: In the `catch` block of `_fetchSinglePrompt()` (or wherever API calls are caught):**

```dart
catch (e) {
  // Existing fallback to local deck already works — just add the UI notice:
  if (!_hasShownOfflineNotice && mounted) {
    _hasShownOfflineNotice = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text(
            'No connection — using local prompts',
            style: TextStyle(color: Colors.white),
          ),
        ]),
        backgroundColor: AppColors.surfaceBright,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
      ),
    );
  }
  // Continue with local deck as before
}
```

**Step 3: Reset `_hasShownOfflineNotice = false` at the start of each new game session** (in `_initGame()` or equivalent), so the notice can appear again next session if still offline.

**Step 4: In `multiplayer_game_screen.dart`, apply the same pattern** in `_fetchAndSetPrompt()` catch block — the fallback prompt is already there but there's no user notice.

---

## BUG FIX 7 — `slideUpRoute` never implemented: inconsistent transitions

**Severity: LOW-MEDIUM — visual inconsistency**

**File:** `lib/screens/home/home_screen.dart` + all navigation push calls

**Problem:**
The plan specified a `slideUpRoute()` helper for consistent scale+fade transitions across the entire app. The home screen uses raw `MaterialPageRoute` for all navigation — game taps, Create Room, Join Room — while some game screens may have custom transitions. The result is inconsistent animation across the app.

**Fix — Step 1: Create `lib/core/navigation/page_transitions.dart`:**

```dart
import 'package:flutter/material.dart';

Route<T> slideUpRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}
```

**Fix — Step 2: Replace ALL `MaterialPageRoute` pushes in `home_screen.dart`:**

```dart
// BEFORE (every game card tap):
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SomeScreen()),
);

// AFTER:
Navigator.push(context, slideUpRoute(const SomeScreen()));
```

Apply to: Create Room button, Join Room button, Settings gear, and all 14 game card taps.

**Fix — Step 3: Apply `slideUpRoute` to all `Navigator.push` calls in:**
```
lib/screens/multiplayer/create_room_screen.dart
lib/screens/multiplayer/join_room_screen.dart
lib/screens/multiplayer/lobby_screen.dart
lib/screens/settings/settings_screen.dart
lib/screens/truth_or_dare/pack_selection_screen.dart
lib/screens/truth_or_dare/player_setup_screen.dart
```

---

## BUG FIX 8 — Root-level junk files: cleanup before store submission

**Severity: LOW — housekeeping, but critical before any store build**

**Files to DELETE from project root:**

```
fix.dart
fix2.dart
update_modes.dart
generate_data.dart
generate_data.py
generate_impostor_data.dart
generate_impostor_data.py
generate_modes_data.dart
generate_modes_data.py
generate_pack_data.dart
gen_sounds.py
remixed-40d671c6.md
remixed-662bd0ea.md
remixed-dff581ff.md
remixed-f10dbd5a.md
analyze_output.txt
analyze_output_utf8.txt
testsprite_tests/          ← entire directory
```

**If the generator scripts are still needed** (for regenerating data files in future), move them to a `scripts/` directory in the project root instead of deleting:

```
scripts/
  generate_data.dart
  generate_data.py
  generate_impostor_data.dart
  generate_impostor_data.py
  generate_modes_data.dart
  generate_modes_data.py
  generate_pack_data.dart
  gen_sounds.py
```

**Add `scripts/` to `.gitignore`** if you don't want them in version control.

The `.md` files and analyze output files should always be deleted — they are never needed in the app bundle.

---

## BUG FIX 9 — `sensors_plus` audit: keep or remove

**Severity: LOW — potential dead dependency**

**File:** `pubspec.yaml`

**Problem:**
`sensors_plus: ^7.0.0` is in `pubspec.yaml` but was never in any phase of the implementation plan. It adds package size and a potential permission requirement (motion sensors can require permission on some platforms). If it's unused it should be removed.

**Fix — Step 1: Search the entire codebase for usage:**

```bash
grep -r "sensors_plus\|SensorsPlatform\|accelerometerEvents\|gyroscopeEvents\|userAccelerometerEvents" lib/
```

**Step 2a — If search returns nothing:** Remove from `pubspec.yaml`:
```yaml
# DELETE this line:
sensors_plus: ^7.0.0
```
Run `flutter pub get` after removal.

**Step 2b — If search finds usage:** Document what it's used for with a comment in the file that uses it, and keep it in `pubspec.yaml`.

**Step 3:** After removal (if removed), run `flutter analyze` to confirm no new errors.

---

## BUG FIX 10 — Missing unit tests

**Severity: LOW — regression safety**

**File:** `test/` directory

**Problem:**
`test/widget_test.dart` contains only the default Flutter boilerplate test. The 5 unit test files specified in Phase 9 were never created.

**Fix — Create all 5 test files exactly as specified in Phase 9 Item 9:**

```
test/services/player_manager_test.dart
test/services/session_stats_service_test.dart
test/services/sound_service_test.dart
test/services/haptic_service_test.dart
test/core/game_constants_test.dart
```

> The full test code for each file is already written in Phase 9 Item 9 of the main implementation plan document. Copy it exactly — do not rewrite.

**After creating the files, run:**

```bash
flutter test
```

All tests must pass with zero failures before marking this complete. If any test fails due to implementation differences (e.g. method names changed during implementation), update the test to match the actual implementation — do not change the implementation to match the test unless the implementation is wrong.

---

## UPDATED IMPLEMENTATION ORDER — POST-IMPLEMENTATION FIXES

Fix in this exact order. Each fix depends on the previous ones being stable.

| Step | Fix | Severity |
|---|---|---|
| P10-F1 | `SoundService` double-play — add `return` after asset play | HIGH |
| P10-F2 | `HapticService` toggle wiring — `setEnabled()` in prefs + MultiProvider | HIGH |
| P10-F3 | `activeColor` → `activeTrackColor` + `activeThumbColor` in Settings | MEDIUM |
| P10-F4 | Fix all `unnecessary_underscores` + `curly_braces` + `sized_box` lint warnings | MEDIUM |
| P10-F5 | Add `lastRoomUid` to `PreferencesService` + wire into `room_service.dart` + `room_rejoin_banner.dart` | MEDIUM |
| P10-F6 | Wire `ConnectivityService` offline snack bar into `game_engine_screen.dart` + `multiplayer_game_screen.dart` | MEDIUM |
| P10-F7 | Create `page_transitions.dart` + replace all `MaterialPageRoute` in home screen and nav screens | LOW-MEDIUM |
| P10-F8 | Delete all root-level junk files + move scripts to `scripts/` folder | LOW |
| P10-F9 | Audit and remove `sensors_plus` if unused | LOW |
| P10-F10 | Create 5 unit test files from Phase 9 spec + run `flutter test` | LOW |

---

## POST-IMPLEMENTATION VERIFICATION CHECKLIST

Run through every item before continuing with Phase 10 features.

- [ ] `flutter analyze` returns **zero warnings in `lib/`** — generator script warnings in root are acceptable
- [ ] Tapping any button with Retro or Cinematic theme active plays ONE sound, not two
- [ ] Toggling haptics OFF in Settings — confirm zero haptic feedback in any game
- [ ] Toggling haptics ON — confirm haptics return immediately
- [ ] No deprecation warnings for `activeColor` anywhere in the project
- [ ] `sensors_plus` either removed from pubspec (if unused) or its usage is documented
- [ ] All root-level `.dart`, `.py`, and `.md` junk files are gone from the project root
- [ ] Room rejoin banner appears correctly when reopening the app after a mid-game disconnect
- [ ] Rejoining a room with the correct name + code works and restores the player to active
- [ ] Going offline mid T&D game shows the "No connection — using local prompts" snack bar exactly once per session
- [ ] Every screen transition from home screen uses the same scale+fade animation
- [ ] All 5 unit test files exist and `flutter test` passes with zero failures
- [ ] `flutter build apk --release` completes with zero errors (Android)
- [ ] `flutter build ios --release` completes with zero errors (iOS, if Mac available)

---


---

---

# PHASE 10 ADDENDUM 2 — STRATEGIC & POLISH ADDITIONS

> These items address audience targeting, monetization, platform strategy, backend hardening, and remaining UX gaps. Implement after all Phase 10 Addendum 1 bug fixes are resolved.

---

## ITEM A — MONETIZATION: Free with Premium Packs

### What It Is

The app is **free to download**. All 14 game modes stay free forever. A subset of Truth or Dare packs are locked behind a **single one-time in-app purchase** that unlocks everything permanently.

### Why This Model

- Zero install friction — friends download it instantly at a party
- The pain point (running out of prompts) only hits after enough play to be genuinely hooked
- One-time purchase feels fair — no subscriptions, no recurring charges
- Word of mouth still works because the free version is genuinely fun
- Apple takes 30% / Google takes 15–30% — price at $2.99 to account for this

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
  // These pack IDs are FREE — match the IDs used in pack_data.dart exactly
  static const Set<String> freePacks = {
    'party_starter',
    'family_night',
    'mild_but_wild',
    'classic',
  };

  // Product ID registered in App Store Connect and Google Play Console:
  static const String premiumProductId = 'com.yourname.cousinchaos.premium';

  static bool isFree(String packId) => freePacks.contains(packId);
  static bool isPremium(String packId) => !freePacks.contains(packId);
}
```

> **Note for developer:** Replace `com.yourname.cousinchaos` with your actual bundle ID. Register the product ID `cousinchaos.premium` in both App Store Connect (Consumable → Non-Consumable) and Google Play Console (In-app products → One-time purchase) before testing.

---

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
    // Load from local storage first (instant, no network):
    final prefs = await SharedPreferences.getInstance();
    _premiumUnlocked = prefs.getBool(_keyPremiumUnlocked) ?? false;
    notifyListeners();

    // Listen to purchase updates:
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) => _setError('Purchase stream error: $e'),
    );

    // Restore previous purchases (important for reinstalls):
    await InAppPurchase.instance.restorePurchases();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  // ── Buy premium ────────────────────────────────────────────────────────────

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

    final purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
    // Result comes via purchaseStream — _handlePurchaseUpdates called next
  }

  // ── Restore purchases ──────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    _setError(null);
    await InAppPurchase.instance.restorePurchases();
  }

  // ── Handle purchase stream ─────────────────────────────────────────────────

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases) async {
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

        case PurchaseStatus.canceled:
          // User cancelled — no error message needed
          break;

        case PurchaseStatus.pending:
          // Waiting — do nothing yet
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

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }
}
```

**Register in `main.dart` MultiProvider:**
```dart
ChangeNotifierProvider(create: (_) => PurchaseService.instance),
```

**Call `init()` in `main.dart` before `runApp()`:**
```dart
await PurchaseService.instance.init();
```

---

### `lib/core/widgets/locked_pack_overlay.dart` (CREATE)

```dart
// Shown as an overlay on premium pack cards in pack_selection_screen.dart
// when the user has not purchased premium

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
          border: Border.all(
            color: AppColors.neonYellow.withAlpha(60),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              color: AppColors.neonYellow,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              'Premium',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.neonYellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### `lib/screens/store/unlock_screen.dart` (CREATE)

```dart
// Full paywall screen shown when user taps a locked pack or the "Unlock All" button

// UI layout:
// Dark gradient background with neonYellow glow
// Top: Icon(Icons.workspace_premium_rounded) in neonYellow, size 64
//   Animated: scale 1.0 → 1.1 → 1.0 looping (pulse)
//
// Title: "Unlock All Packs"
// Subtitle: "One-time purchase — yours forever"
//
// Feature list GlassCard — what premium includes:
//   Icon(Icons.check_circle_rounded) in neonGreen + text for each:
//   "9 additional Truth or Dare packs"
//   "All future packs included free"
//   "Spicy, couples, girls night & more"
//   "Supports the developer"
//
// Price display: fetched from productDetails.price (real store price, not hardcoded)
// Show SkeletonCard while price is loading
//
// Standard Action Button: "Unlock Everything — $X.XX"
//   color: neonYellow, icon: Icons.lock_open_rounded
//   onTap: PurchaseService.instance.buyPremium()
//   While _isPurchasing: show CircularProgressIndicator instead
//
// Error text in dareRed if _errorMessage is not null
//
// TextButton below: "Restore Previous Purchase"
//   onTap: PurchaseService.instance.restorePurchases()
//
// Standard glass back button in AppBar
```

---

### `pack_selection_screen.dart` — Premium Integration

```dart
// Wrap each pack card with Consumer<PurchaseService>:
Consumer<PurchaseService>(
  builder: (context, purchases, _) {
    final isLocked = PackTiers.isPremium(pack.id) && !purchases.premiumUnlocked;

    return Stack(
      children: [
        // Existing pack card widget:
        _buildPackCard(pack, isSelected: !isLocked && isSelected),

        // Lock overlay on top if premium and not purchased:
        if (isLocked)
          Positioned.fill(
            child: LockedPackOverlay(
              onUnlock: () => Navigator.push(
                context,
                slideUpRoute(const UnlockScreen()),
              ),
            ),
          ),
      ],
    );
  },
)
```

**Also add an "Unlock All Packs" banner** at the top of pack selection for non-premium users:

```dart
// Show only when !purchases.premiumUnlocked:
Consumer<PurchaseService>(
  builder: (context, purchases, _) {
    if (purchases.premiumUnlocked) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.push(context, slideUpRoute(const UnlockScreen())),
      child: GlassCard(
        accentColor: AppColors.neonYellow,
        intense: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(Icons.workspace_premium_rounded,
              color: AppColors.neonYellow, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unlock All 13 Packs',
                    style: /* bold white 14 */),
                Text('One-time purchase — includes future packs',
                    style: /* muted 11 */),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.neonYellow, size: 16),
        ]),
      ),
    );
  },
)
```

---

### Settings Screen — Premium Status

```dart
// In settings_screen.dart, add a PURCHASE section above LEGAL:
// If premiumUnlocked:
GlassCard(
  accentColor: AppColors.neonGreen,
  child: Row(children: [
    Icon(Icons.workspace_premium_rounded, color: AppColors.neonGreen),
    SizedBox(width: 12),
    Text('Premium Unlocked', style: /* bold white */),
    Spacer(),
    Icon(Icons.check_circle_rounded, color: AppColors.neonGreen),
  ]),
)

// If not premiumUnlocked:
GestureDetector(
  onTap: () => Navigator.push(context, slideUpRoute(const UnlockScreen())),
  child: GlassCard(
    accentColor: AppColors.neonYellow,
    child: Row(children: [
      Icon(Icons.lock_rounded, color: AppColors.neonYellow),
      SizedBox(width: 12),
      Text('Unlock Premium Packs', style: /* bold white */),
      Spacer(),
      Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neonYellow, size: 16),
    ]),
  ),
)
```

---

## ITEM B — Target Audience: Both Family & Friend Groups

**Impact on the app — changes to make:**

**Home screen description:** Change the onboarding slide 1 body text from "The ultimate party game collection" to "The ultimate party game for families, friends, and everyone in between."

**Pack labeling:** Add audience tags to packs in `pack_data.dart` and show them on pack cards:
```dart
// In each pack definition, add a tag:
'audience': 'family'    // shown as a green "Family Safe" badge
'audience': 'friends'   // shown as a blue "Friends" badge  
'audience': '18+'       // shown as a red "18+" badge (only if is18Plus enabled)
```

**Pack selection filter:** Add a horizontal filter row at the top of pack selection:
```dart
// Filter chips: "All" | "Family" | "Friends" | "18+" (only if enabled)
// Tapping a filter hides packs that don't match the audience tag
// Implemented as a simple _selectedFilter state variable
```

**App Store description:** Target both family game nights AND friend group parties in the store listing copy. Two different use cases = broader keyword coverage = more downloads.

---

## ITEM C — Firebase Backend Hardening

### C1 — Room Creation Rate Limiting

**File:** Firebase Console → Realtime Database → Rules

**Problem:** Without rate limiting, a script could create thousands of rooms flooding the database.

**Updated Firebase Security Rules:**

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
              ".read": "auth.uid === $uid || root.child('rooms').child($roomCode).child('hostUid').val() === auth.uid"
            },
            "accusations": {
              ".read": "auth.uid === $uid || root.child('rooms').child($roomCode).child('hostUid').val() === auth.uid"
            }
          }
        }
      }
    },
    "rateLimits": {
      "$uid": {
        ".read": "auth.uid === $uid",
        ".write": "auth.uid === $uid"
      }
    }
  }
}
```

**Client-side rate limit** in `room_service.dart` (simpler, works without Blaze plan):

```dart
// Add to RoomService:
DateTime? _lastRoomCreated;
static const _minRoomCreateInterval = Duration(minutes: 2);

Future<String> createRoom({...}) async {
  // Rate limit check:
  if (_lastRoomCreated != null) {
    final elapsed = DateTime.now().difference(_lastRoomCreated!);
    if (elapsed < _minRoomCreateInterval) {
      final remaining = _minRoomCreateInterval - elapsed;
      throw Exception(
        'Please wait ${remaining.inSeconds} seconds before creating another room.'
      );
    }
  }

  // Existing create logic...
  _lastRoomCreated = DateTime.now();
  return code;
}
```

**Handle the exception in `create_room_screen.dart`:**

```dart
try {
  final code = await RoomService.instance.createRoom(...);
  // navigate to lobby
} catch (e) {
  setState(() => _error = e.toString().replaceAll('Exception: ', ''));
}
```

### C2 — Room Code Retry Limit

**File:** `lib/services/room_service.dart`

**Problem:** `_uniqueCode()` loops forever if Firebase is unreachable.

**Fix:**

```dart
Future<String> _uniqueCode() async {
  const maxRetries = 10;
  int attempts = 0;

  while (attempts < maxRetries) {
    final code = _generateCode();
    try {
      final snap = await _db.child('rooms/$code').get()
          .timeout(const Duration(seconds: 5));
      if (!snap.exists) return code;
    } on TimeoutException {
      throw Exception('Connection timed out. Check your internet and try again.');
    }
    attempts++;
  }

  throw Exception('Could not generate a room code. Please try again.');
}
```

### C3 — Firebase Cost Awareness

**Add this comment block to `room_service.dart`:**

```dart
// ── Firebase Usage Notes ────────────────────────────────────────────────────
// Free Spark plan limits:
//   Storage:  1 GB
//   Downloads: 10 GB/month
//   Connections: 100 simultaneous
//
// Estimated usage per room session:
//   ~5-20 KB written per room (players + game state)
//   ~50-200 KB downloaded per device (streaming updates)
//   Average session: 30 min
//
// At 100 concurrent rooms (400 devices):
//   ~80 MB/month downloads → well within free tier
//
// Blaze plan (pay-as-you-go) recommended if MAU > 10,000
// Current client-side cleanup deletes rooms after 4 hours
// Monitor usage at: console.firebase.google.com → Usage tab
// ─────────────────────────────────────────────────────────────────────────────
```

---

## ITEM D — Web Version

**Target:** Joiners can open a browser link to join a multiplayer room without installing the app. Host still uses the app. Joiners get a simplified web experience.

**Packages needed:**
```yaml
# No new packages — Flutter web is built-in
# Run: flutter build web
```

**Strategy:** Build a minimal web companion at a subdomain (e.g. `play.cousinchaos.com`) that only supports:
- Entering a room code + name → joining a room
- Seeing the current prompt
- Voting on dares
- Seeing the watch mode overlay

The full game (creating rooms, hosting, all game modes) stays app-only.

**Files to create:**

```
lib/web/
  web_join_screen.dart     ← browser-optimized join flow
  web_game_screen.dart     ← browser-optimized game view (prompt display only)
  web_app.dart             ← separate MaterialApp entry for web
```

**`web/index.html` — update for proper SEO and sharing:**

```html
<!-- Replace the default Flutter web index.html meta tags: -->
<meta name="description"
  content="Join a Cousin Chaos party game room from your browser. No download required.">
<meta property="og:title" content="Join Cousin Chaos">
<meta property="og:description"
  content="You've been invited to a Cousin Chaos party game!">
<title>Cousin Chaos — Join Game</title>
```

**Deep link format for web join:**
```
https://play.cousinchaos.com/join/482913
```

**In `lobby_screen.dart` — update Share Code to include web URL:**

```dart
await SharePlus.instance.share(
  ShareParams(
    text: 'Join my Cousin Chaos room! 🎮\n\n'
          'Room code: ${widget.roomCode}\n\n'
          'Join from browser: https://play.cousinchaos.com/join/${widget.roomCode}\n'
          'Or open the app and tap "Join Room"',
    subject: 'Join my Cousin Chaos game!',
  ),
);
```

**`main.dart` — platform-conditional entry:**

```dart
import 'package:flutter/foundation.dart';

void main() async {
  // ... existing init ...

  if (kIsWeb) {
    runApp(const CousinChaosWebApp()); // simplified web entry
  } else {
    runApp(const CousinChaosApp());    // full mobile app
  }
}
```

> **Note for developer:** Deploy the web build to Firebase Hosting (free tier, integrates with existing Firebase project):
> ```bash
> flutter build web
> firebase deploy --only hosting
> ```
> Configure `firebase.json` to route `/join/*` paths to the Flutter web app.

---

## ITEM E — Loading State in Multiplayer Game Screen

**File:** `lib/screens/multiplayer/multiplayer_game_screen.dart`

**Problem:** When the active player picks Truth or Dare, the host fetches from the API and writes to Firebase. All other devices wait with no visible indicator — looks frozen.

**Fix — Add a `isFetchingPrompt` state to the game state:**

```dart
// In room_service.dart setPrompt(), write isFetching first:
Future<void> setFetchingPrompt(String code, bool isFetching) async {
  await _db.child('rooms/$code/gameState/isFetchingPrompt').set(isFetching);
}

// In multiplayer_game_screen.dart _fetchAndSetPrompt():
Future<void> _fetchAndSetPrompt(BuildContext context, Room room, String type) async {
  final isHost = room.hostUid == RoomService.instance.currentUid;
  if (!isHost) return;

  // Signal all devices that fetch is in progress:
  await RoomService.instance.setFetchingPrompt(widget.roomCode, true);

  try {
    // ... existing fetch logic ...
    await RoomService.instance.setPrompt(widget.roomCode, type: type, prompt: prompt);
  } finally {
    await RoomService.instance.setFetchingPrompt(widget.roomCode, false);
  }
}
```

**In `Room` model — add `isFetchingPrompt` field:**

```dart
// In GameState:
final bool isFetchingPrompt;

// In fromMap():
isFetchingPrompt: map['isFetchingPrompt'] as bool? ?? false,

// In toMap():
'isFetchingPrompt': isFetchingPrompt,
```

**In `multiplayer_game_screen.dart` build — show skeleton while fetching:**

```dart
// In _buildGameContent(), when currentType is empty:
if (room.gameState?.isFetchingPrompt == true) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(children: [
      SkeletonCard(height: 200),  // existing widget from Phase 7
      const SizedBox(height: 16),
      Text(
        'Getting your prompt...',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    ]),
  );
}
```

---

## ITEM F — DisclaimerDialog: Once per Install

**File:** `lib/widgets/disclaimer_dialog.dart` + `lib/services/preferences_service.dart`

**Problem:** Current `static bool _accepted` resets every time the app process is killed, which happens constantly on mobile. Feels like a bug to real users.

**Fix — Move to `PreferencesService`:**

**Step 1 — Add to `PreferencesService`:**

```dart
static const String _keyDisclaimerAccepted = 'disclaimer_accepted';
bool _disclaimerAccepted = false;

bool get disclaimerAccepted => _disclaimerAccepted;

// In _loadPreferences():
_disclaimerAccepted = prefs.getBool(_keyDisclaimerAccepted) ?? false;

// New method:
Future<void> setDisclaimerAccepted() async {
  _disclaimerAccepted = true;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyDisclaimerAccepted, true);
  notifyListeners();
}
```

**Step 2 — Update `disclaimer_dialog.dart`:**

```dart
// Replace the static bool with PreferencesService check:
static Future<void> show(BuildContext context, VoidCallback onAccept) async {
  final prefs = context.read<PreferencesService>();

  // Skip if already accepted (persisted across app restarts):
  if (prefs.disclaimerAccepted) {
    onAccept();
    return;
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => DisclaimerDialog(
      onAccept: () {
        prefs.setDisclaimerAccepted(); // persist forever
        onAccept();
      },
    ),
  );
}
```

**Step 3 — Remove the old `static bool _accepted` field** from `DisclaimerDialog` entirely.

---

## ITEM G — Highlights Reel: All Game Modes

**Files to modify:**
```
lib/screens/new_modes/last_standing_screen.dart
lib/screens/new_modes/impostor_game_screen.dart
lib/screens/new_modes/laugh_attack_screen.dart
lib/screens/new_modes/speed_challenge_screen.dart
lib/services/session_stats_service.dart
```

**Step 1 — Extend `SessionStatsService` with per-mode tracking:**

```dart
// Add fields:
String? _firstEliminatedName;   // Last Standing
String? _impostorName;          // Impostor Mode
bool? _impostorWon;             // Impostor Mode result
int _laughCount = 0;            // Laugh Attack
int _challengesFailed = 0;      // Speed Challenge

// Add methods:
void recordFirstEliminated(String playerName) {
  _firstEliminatedName ??= playerName; // only record the first one
  notifyListeners();
}

void recordImpostorResult({required String impostorName, required bool impostorWon}) {
  _impostorName = impostorName;
  _impostorWon = impostorWon;
  notifyListeners();
}

void recordLaugh() {
  _laughCount++;
  notifyListeners();
}

void recordChallengeFailed() {
  _challengesFailed++;
  notifyListeners();
}

// Getters:
String? get firstEliminatedName => _firstEliminatedName;
String? get impostorName => _impostorName;
bool? get impostorWon => _impostorWon;
int get laughCount => _laughCount;
int get challengesFailed => _challengesFailed;
```

**Step 2 — Wire into each game screen:**

```dart
// last_standing_screen.dart — in _eliminatePlayer():
final stats = context.read<SessionStatsService>();
stats.recordElimination(player.id, position);
stats.recordFirstEliminated(player.name); // first one only

// impostor_game_screen.dart — in result phase build:
final stats = context.read<SessionStatsService>();
stats.recordImpostorResult(
  impostorName: impostorPlayer.name,
  impostorWon: impostorWon,
);

// laugh_attack_screen.dart — in _handleLaugh():
context.read<SessionStatsService>().recordLaugh();

// speed_challenge_screen.dart — when timer reaches 0 without completion:
context.read<SessionStatsService>().recordChallengeFailed();
```

**Step 3 — Show "See Highlights" button on each end screen:**

```dart
// Add to the result/winner screen of each mode:
TextButton.icon(
  onPressed: () => Navigator.push(
    context,
    slideUpRoute(HighlightsScreen(onPlayAgain: _restartGame)),
  ),
  icon: Icon(Icons.emoji_events_rounded, color: AppColors.neonYellow),
  label: Text(
    'See Session Highlights',
    style: TextStyle(color: AppColors.neonYellow),
  ),
)
```

**Step 4 — Update `HighlightsScreen` to show mode-specific cards:**

```dart
// In _buildHighlightCards(), add these conditionally:

// Card: First Out (Last Standing only)
if (stats.firstEliminatedName != null)
  _HighlightCard(
    icon: Icons.sentiment_very_dissatisfied_rounded,
    color: AppColors.neonPink,
    title: 'First to Fall',
    subtitle: '${stats.firstEliminatedName} was eliminated first',
  ),

// Card: The Impostor (Impostor Mode only)
if (stats.impostorName != null)
  _HighlightCard(
    icon: Icons.search_rounded,
    color: AppColors.dareRed,
    title: stats.impostorWon == true ? 'The Impostor Won!' : 'Civilians Won!',
    subtitle: '${stats.impostorName} was the impostor',
  ),

// Card: Laugh Count (Laugh Attack only)
if (stats.laughCount > 0)
  _HighlightCard(
    icon: Icons.emoji_emotions_rounded,
    color: AppColors.neonYellow,
    title: 'Total Laughs',
    subtitle: '${stats.laughCount} laughs this session',
  ),

// Card: Speed Challenge failures
if (stats.challengesFailed > 0)
  _HighlightCard(
    icon: Icons.timer_off_rounded,
    color: AppColors.neonOrange,
    title: 'Too Slow!',
    subtitle: '${stats.challengesFailed} challenges timed out',
  ),
```

---

## UPDATED PUBSPEC — ADDENDUM 2 ADDITIONS

```yaml
# ADD (Addendum 2):
in_app_purchase: ^3.2.0   # Premium pack monetization

# Already present from previous phases — DO NOT add again:
# share_plus, url_launcher, firebase_*, in_app_review, etc.
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
| A7 | Register product in App Store Connect + Google Play Console (developer manual step) |
| B1 | Update onboarding slide 1 body text for both audiences |
| B2 | Add audience tags to pack definitions + filter chips in pack selection |
| C1 | Add client-side room creation rate limit (2-minute cooldown) to `room_service.dart` |
| C2 | Add retry limit + timeout to `_uniqueCode()` in `room_service.dart` |
| C3 | Add Firebase cost awareness comment block to `room_service.dart` |
| D1 | Create `web_join_screen.dart` + `web_game_screen.dart` + `web_app.dart` |
| D2 | Update `web/index.html` meta tags |
| D3 | Update Share Code in `lobby_screen.dart` to include web URL |
| D4 | Update `main.dart` for platform-conditional app entry |
| D5 | Run `flutter build web` + deploy to Firebase Hosting (developer manual step) |
| E1 | Add `setFetchingPrompt()` to `room_service.dart` |
| E2 | Add `isFetchingPrompt` to `GameState` model |
| E3 | Wire skeleton card loading state in `multiplayer_game_screen.dart` |
| F1 | Add `disclaimerAccepted` + `setDisclaimerAccepted()` to `PreferencesService` |
| F2 | Update `disclaimer_dialog.dart` to use `PreferencesService` instead of static bool |
| G1 | Extend `SessionStatsService` with per-mode fields and methods |
| G2 | Wire `recordFirstEliminated`, `recordImpostorResult`, `recordLaugh`, `recordChallengeFailed` into each game screen |
| G3 | Add "See Highlights" button to Last Standing, Impostor, Laugh Attack, Speed Challenge end screens |
| G4 | Update `HighlightsScreen._buildHighlightCards()` with mode-specific conditional cards |

---

## ADDENDUM 2 VERIFICATION CHECKLIST

**Monetization:**
- [ ] Free packs (Party Starter, Family Night, Mild But Wild, Classic) are fully selectable with no lock
- [ ] Premium packs show a lock overlay with "Unlock Premium" on tap
- [ ] Tapping any locked pack opens `UnlockScreen` with real price fetched from store
- [ ] Completing a purchase unlocks all premium packs immediately without restart
- [ ] Restoring purchases works — re-installing the app and tapping "Restore" re-unlocks premium
- [ ] Premium unlock status shows correctly in Settings
- [ ] Purchasing from one device and restoring on another works correctly
- [ ] `PurchaseService` registered in `MultiProvider` and `init()` called before `runApp()`

**Audience & Discovery:**
- [ ] Onboarding slide 1 mentions both families and friends
- [ ] Pack audience tags (Family / Friends / 18+) visible on pack cards
- [ ] Pack filter chips work — selecting "Family" hides non-family packs

**Backend Hardening:**
- [ ] Creating two rooms within 2 minutes shows a friendly wait message
- [ ] `_uniqueCode()` times out gracefully after 5 seconds per attempt with a user-facing error
- [ ] Firebase cost comment block present in `room_service.dart`

**Web Version:**
- [ ] `flutter build web` completes with zero errors
- [ ] Web join flow works from a browser — enter code + name → join room → see prompts
- [ ] Share Code in lobby includes the `play.cousinchaos.com/join/XXXXXX` URL
- [ ] `kIsWeb` conditional entry point routes to web app correctly

**Multiplayer Loading:**
- [ ] When active player picks Truth/Dare, other devices show skeleton card + "Getting your prompt..." text
- [ ] Skeleton disappears and prompt appears simultaneously on all devices

**Disclaimer:**
- [ ] Disclaimer shows only on first install — never again after accepting
- [ ] Reinstalling the app still shows the disclaimer (SharedPreferences cleared on reinstall)
- [ ] The old `static bool _accepted` field is fully removed from `disclaimer_dialog.dart`

**Highlights Reel:**
- [ ] "See Session Highlights" button visible on Last Standing, Impostor, Laugh Attack, Speed Challenge end screens
- [ ] Last Standing highlights show "First to Fall" card with correct player name
- [ ] Impostor highlights show impostor name and result (won/lost)
- [ ] Laugh Attack highlights show total laugh count
- [ ] Speed Challenge highlights show number of timeouts
- [ ] Confetti fires on highlights screen entry for all modes

---

*End of Phase 10 Addendum 2. Total additions: monetization system + audience targeting + Firebase hardening + web version + 4 UX fixes.*
