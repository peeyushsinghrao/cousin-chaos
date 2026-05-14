# Cousin Chaos — AI Agent Implementation Brief
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

## FILES TO PROVIDE TO THIS AGENT (paste full contents before starting)

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

Open `pubspec.yaml` and add under `dependencies` if not already present:

```yaml
home_widget: ^0.7.0
qr_flutter: ^4.1.0
mobile_scanner: ^6.0.2
```

Run `flutter pub get` after editing.

---

---

# PART A — PHASE 10 APP ITEMS (Items 1–10)

---

## ITEM 1 — Player Avatars & Colors

**Files to modify:**
```
lib/models/player.dart
lib/services/player_manager.dart
lib/screens/truth_or_dare/player_setup_screen.dart
lib/screens/shared/mode_player_setup_screen.dart
```
**Already exist — do not recreate:**
```
lib/core/widgets/player_avatar.dart      ✓
lib/core/constants/avatar_constants.dart ✓
```

### `lib/models/player.dart` — ADD FIELD

```dart
final String avatarId; // e.g. 'crown', 'flame', 'ghost'
// Update constructor, copyWith, toJson, fromJson
// Default avatarId: AvatarConstants.byIndex(playerIndex).id
```

### `lib/services/player_manager.dart` — UPDATE `addPlayer()`

```dart
final avatarId = AvatarConstants.byIndex(_players.length).id;
_players.add(Player(
  id: _uuid.v4(),
  name: 'Player $n',
  avatarId: avatarId,
));
```

Add `updatePlayerAvatar()` method:
```dart
void updatePlayerAvatar(String playerId, String avatarId) {
  final index = _players.indexWhere((p) => p.id == playerId);
  if (index != -1) {
    _players[index] = _players[index].copyWith(avatarId: avatarId);
    notifyListeners();
  }
}
```

### Avatar Picker Bottom Sheet

Add `_showAvatarPicker()` in both setup screens and make each player row's avatar widget tappable:

```dart
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
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
```

### Where to show `PlayerAvatar` throughout the app

| Screen | Location |
|---|---|
| `player_setup_screen.dart` | Left of each player name row — tappable to open picker |
| `mode_player_setup_screen.dart` | Left of each player name row — tappable |
| `game_engine_screen.dart` | Current player header — `PlayerAvatar(showGlow: true)` |
| `truth_or_dare/widgets/prompt_card.dart` | Small avatar next to player name at top of card |
| `new_modes/target_player_screen.dart` | Fortune wheel items show avatar icon + name |
| `new_modes/last_standing_screen.dart` | Each player card |
| `multiplayer/lobby_screen.dart` | Each `PlayerListTile` |
| `multiplayer/multiplayer_game_screen.dart` | Current player header + watch mode overlay |
| Session stats bottom sheet | Each player row |
| `highlights/highlights_screen.dart` | Each stat card |

---

## ITEM 2 — Themed Night Modes Per Game

The file `lib/core/constants/game_themes.dart` already exists. Do not recreate it. Import and apply it.

### Apply in each game screen

Replace hardcoded `AppColors.backgroundGradient` with screen-specific `GameTheme`. Add a radial glow behind content:

```dart
Container(
  decoration: BoxDecoration(
    gradient: GameThemes.bombPass.backgroundGradient,
  ),
  child: Stack(children: [
    Positioned(
      top: -100, left: -100,
      child: Container(
        width: 400, height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            GameThemes.bombPass.glowColor.withAlpha(25),
            Colors.transparent,
          ]),
        ),
      ),
    ),
    _buildContent(),
  ]),
)
```

Apply the correct theme per screen:

| Screen | Theme |
|---|---|
| `game_engine_screen.dart` | `GameThemes.truthOrDare` |
| `bomb_pass_screen.dart` | `GameThemes.bombPass` |
| `freeze_mode_screen.dart` | `GameThemes.freezeMode` |
| `laugh_attack_screen.dart` | `GameThemes.laughAttack` |
| `impostor_game_screen.dart` | `GameThemes.impostor` |
| `last_standing_screen.dart` | `GameThemes.lastStanding` |
| `speed_challenge_screen.dart` | `GameThemes.speedChallenge` |
| `secret_mission_screen.dart` | `GameThemes.secretMission` |
| `target_player_screen.dart` | `GameThemes.targetPlayer` |
| `chaos_mode_screen.dart` | `GameThemes.chaosMode` |

Also update each screen's `GlassCard` accent color to use `GameTheme.primary` instead of hardcoded `AppColors.primaryNeon`.

---

## ITEM 3 — Custom Prompt Mid-Game

`lib/core/widgets/add_prompt_sheet.dart` already exists. Wire it into `game_engine_screen.dart`.

### Integration in `game_engine_screen.dart`

Add `+` button to AppBar — only when `_phase == GamePhase.selectType`:

```dart
if (_phase == GamePhase.selectType)
  Tooltip(
    message: 'Add custom prompt',
    child: IconButton(
      onPressed: _showAddPromptSheet,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
      ),
    ),
  ),
```

Add `_showAddPromptSheet()`:

```dart
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

## ITEM 4 — Game Highlights Reel

`lib/screens/highlights/highlights_screen.dart` already exists. Extend `SessionStatsService` and wire into all game screens.

### Extend `lib/services/session_stats_service.dart`

Check what already exists. Add any missing fields and methods:

```dart
// Fields (add if missing):
final Map<String, int> _truths = {};
final Map<String, int> _dares = {};
final Map<String, int> _skips = {};
String? _firstEliminatedName;
String? _impostorName;
bool? _impostorWon;
int _laughCount = 0;
int _challengesFailed = 0;
int _totalRounds = 0;

// Methods:
void recordTruth(String playerId) { _truths[playerId] = (_truths[playerId] ?? 0) + 1; notifyListeners(); }
void recordDare(String playerId)  { _dares[playerId]  = (_dares[playerId]  ?? 0) + 1; notifyListeners(); }
void recordSkip(String playerId)  { _skips[playerId]  = (_skips[playerId]  ?? 0) + 1; notifyListeners(); }
void incrementRound()             { _totalRounds++; notifyListeners(); }

void recordFirstEliminated(String playerName) { _firstEliminatedName ??= playerName; notifyListeners(); }

void recordImpostorResult({required String impostorName, required bool impostorWon}) {
  _impostorName = impostorName; _impostorWon = impostorWon; notifyListeners();
}

void recordLaugh()           { _laughCount++;       notifyListeners(); }
void recordChallengeFailed() { _challengesFailed++; notifyListeners(); }

// Getters:
String? get mostDaresPerson     => _topByCount(_dares);
String? get mostSkipsPerson     => _topByCount(_skips);
String? get mostTruthsPerson    => _topByCount(_truths);
int     get totalRounds         => _totalRounds;
String? get firstEliminatedName => _firstEliminatedName;
String? get impostorName        => _impostorName;
bool?   get impostorWon         => _impostorWon;
int     get laughCount          => _laughCount;
int     get challengesFailed    => _challengesFailed;

String? _topByCount(Map<String, int> map) {
  if (map.isEmpty) return null;
  return map.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}
```

### Wire stats into `game_engine_screen.dart`

When a player picks Truth: `context.read<SessionStatsService>().recordTruth(currentPlayer.id);`
When a player picks Dare: `context.read<SessionStatsService>().recordDare(currentPlayer.id);`
When a player skips: `context.read<SessionStatsService>().recordSkip(currentPlayer.id);`
At the start of each round: `context.read<SessionStatsService>().incrementRound();`

### Wire per-mode stats

- **`last_standing_screen.dart`** — in elimination logic:
  `context.read<SessionStatsService>().recordFirstEliminated(player.name);`
- **`impostor_game_screen.dart`** — in result phase:
  `context.read<SessionStatsService>().recordImpostorResult(impostorName: ..., impostorWon: ...);`
- **`laugh_attack_screen.dart`** — on laugh detection:
  `context.read<SessionStatsService>().recordLaugh();`
- **`speed_challenge_screen.dart`** — on timer expiry without completion:
  `context.read<SessionStatsService>().recordChallengeFailed();`

### "See Highlights" button on ALL game end screens

Add to end/result screen of: `game_engine_screen.dart`, `last_standing_screen.dart`, `impostor_game_screen.dart`, `laugh_attack_screen.dart`, `speed_challenge_screen.dart`:

```dart
TextButton.icon(
  onPressed: () => Navigator.push(context, slideUpRoute(const HighlightsScreen())),
  icon: Icon(Icons.emoji_events_rounded, color: AppColors.neonYellow),
  label: Text('See Session Highlights', style: TextStyle(color: AppColors.neonYellow)),
)
```
Check `HighlightsScreen`'s actual constructor parameters before wiring.

### Update `highlights_screen.dart` — mode-specific cards

Inside the card-building method (check existing pattern), add conditionally:

```dart
if (stats.firstEliminatedName != null)
  // Card: "First to Fall" / neonPink / sentiment_very_dissatisfied_rounded
  // subtitle: "${stats.firstEliminatedName} was eliminated first"

if (stats.impostorName != null)
  // Card: title = impostorWon ? "The Impostor Won!" : "Civilians Won!"
  // color: dareRed / icon: search_rounded
  // subtitle: "${stats.impostorName} was the impostor"

if (stats.laughCount > 0)
  // Card: "Total Laughs" / neonYellow / emoji_emotions_rounded
  // subtitle: "${stats.laughCount} laughs this session"

if (stats.challengesFailed > 0)
  // Card: "Too Slow!" / neonOrange / timer_off_rounded
  // subtitle: "${stats.challengesFailed} challenges timed out"
```

---

## ITEM 5 — Sound Pack Selection

`lib/core/constants/sound_themes.dart` already exists.

### Update `lib/services/sound_service.dart`

Add `_currentTheme` field and `setTheme()`. Update `play()`:

```dart
SoundTheme _currentTheme = SoundTheme.system;

void setTheme(SoundTheme theme) => _currentTheme = theme;

Future<void> play(SoundEvent event, {bool soundEnabled = true}) async {
  if (!soundEnabled) return;

  if (_currentTheme != SoundTheme.system) {
    final path = SoundThemeConstants.assetPath(_currentTheme, event.name);
    try {
      await _player.play(AssetSource(path));
      return; // ← CRITICAL: prevents double-play bug
    } catch (_) {
      // asset missing — fall through to system sound
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

### Update `lib/services/preferences_service.dart`

```dart
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

In `_loadPreferences()`, add:
```dart
SoundService.instance.setTheme(soundTheme);
```

### Settings UI — Sound Theme chip row

In `settings_screen.dart`, under the Sound toggle, add:

```dart
Row(
  children: SoundTheme.values.map((theme) {
    final isSelected = prefs.soundTheme == theme;
    return GestureDetector(
      onTap: () => prefs.setSoundTheme(theme),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNeon : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryNeon : AppColors.glassBorder,
          ),
        ),
        child: Text(
          SoundThemeConstants.labels[theme] ?? theme.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }).toList(),
)
```

---

## ITEM 6 — Prompt Difficulty Rating

`lib/services/prompt_rating_service.dart` already exists.

### Integration in `lib/screens/truth_or_dare/widgets/prompt_card.dart`

Add state:
```dart
bool _showRating = false;
int? _selectedRating;
```

Modify "Next Player" button `onTap`:
```dart
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
```

Add rating UI below the prompt card:
```dart
AnimatedSize(
  duration: const Duration(milliseconds: 250),
  child: _showRating
    ? GlassCard(
        accentColor: AppColors.neonYellow,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(children: [
          Text('How was that?', style: /* bold white 15 */),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RatingButton(icon: Icons.sentiment_satisfied_rounded,
                label: 'Too Easy', color: AppColors.neonGreen,
                selected: _selectedRating == 1,
                onTap: () => setState(() => _selectedRating = 1)),
              _RatingButton(icon: Icons.sentiment_neutral_rounded,
                label: 'Just Right', color: AppColors.neonYellow,
                selected: _selectedRating == 2,
                onTap: () => setState(() => _selectedRating = 2)),
              _RatingButton(icon: Icons.sentiment_very_dissatisfied_rounded,
                label: 'Brutal', color: AppColors.dareRed,
                selected: _selectedRating == 3,
                onTap: () => setState(() => _selectedRating = 3)),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedRating == null)
            TextButton(onPressed: widget.onNext, child: const Text('Skip Rating →')),
        ]),
      )
    : const SizedBox.shrink(),
)
```

### Weight-based deck in `game_engine_screen.dart`

```dart
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

Call `_buildWeightedDeck()` instead of a plain shuffle when initializing the deck.

---

## ITEM 7 — Haptic Themes

`lib/core/constants/haptic_themes.dart` already exists.

### Update `lib/services/haptic_service.dart`

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
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      break;
  }
}
```

### Update `lib/services/preferences_service.dart`

```dart
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

In `_loadPreferences()`, add both:
```dart
HapticService.instance.setEnabled(_hapticsEnabled); // also fixes Bug Fix 2
HapticService.instance.setTheme(hapticTheme);
```

### Settings UI — Haptic Theme chip row

Under the Haptics toggle in `settings_screen.dart`, same chip pattern as Sound Theme using `HapticTheme.values`, `HapticThemeConstants.labels`, and `prefs.setHapticTheme(theme)`. Labels: `Subtle` | `Standard` | `Intense`.

---

## ITEM 8 — Tablet / Landscape Support

`lib/core/layout/responsive_layout.dart` already exists.

### `lib/main.dart` — remove blanket portrait lock

Remove:
```dart
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
]);
```

In each game screen's `initState()`, add phone-only portrait lock:
```dart
if (!ResponsiveLayout.isTablet(context)) {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
```

### `home_screen.dart` — tablet 3-column grid

```dart
ResponsiveLayout(
  phone: _buildPhoneGrid(),
  tablet: _buildTabletGrid(),
)

Widget _buildTabletGrid() => GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    childAspectRatio: 1.4,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  // same items as phone grid
);
```

### `prompt_card.dart` + `game_engine_screen.dart` — tablet layout

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

## ITEM 9 — Timed Auto-Advance

### `lib/services/preferences_service.dart`

```dart
static const String _keyAutoAdvance = 'auto_advance';
bool get autoAdvanceEnabled => _prefs.getBool(_keyAutoAdvance) ?? false;
Future<void> setAutoAdvance(bool value) async {
  await _prefs.setBool(_keyAutoAdvance, value);
  notifyListeners();
}
```

### `settings_screen.dart` — GAMEPLAY section

Add toggle: `Auto-advance prompts` / subtitle: `Automatically moves to next player when timer ends`.
Bound to `prefs.autoAdvanceEnabled` / `prefs.setAutoAdvance(value)`.

### `lib/screens/truth_or_dare/widgets/prompt_card.dart`

In `initState()`:
```dart
final autoAdvance = context.read<PreferencesService>().autoAdvanceEnabled;
```

In `_startTimer()` when `_timeLeft` hits 0:
```dart
if (autoAdvance) {
  await Future.delayed(const Duration(milliseconds: 800));
  if (mounted) widget.onNext();
} else {
  setState(() => _timerComplete = true);
}
```

When `autoAdvance` on and `_timeLeft <= 5`, show:
```dart
Text('Auto-advancing in ${_timeLeft}s...', style: /* muted small */)
```

---

## ITEM 10 — Home Screen Widget

`lib/services/home_widget_service.dart` already exists.

### `lib/main.dart` — call `init()` before `runApp()`

```dart
await HomeWidgetService.init();
```

### `lib/screens/home/home_screen.dart` — refresh on resume

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

> Leave a `// TODO: Add native widget layout files for Android (res/layout/) and iOS (SwiftUI extension)` comment in `home_widget_service.dart` if not already present.

---

---

# PART B — PHASE 10 MULTIPLAYER ITEMS (Items 11–17)

---

## ITEM 11 — Spectator Mode

Already exist: `lib/screens/multiplayer/widgets/spectator_view.dart` ✓ and `lib/core/widgets/join_request_toast.dart` ✓

### `lib/core/models/room_player.dart` — ADD FIELDS

```dart
final bool isSpectator;
final bool hasRequestedToPlay;
// Add to fromMap() and toMap()
```

### `lib/services/room_service.dart` — ADD METHODS

```dart
Future<String?> joinAsSpectator({required String code, required String playerName}) async {
  final snap = await _db.child('rooms/$code').get();
  if (!snap.exists) return 'Room not found.';
  final room = Room.fromMap(code, snap.value as Map);
  if (room.status == 'ended') return 'This game has already ended.';
  final uid = currentUid;
  await _db.child('rooms/$code/players/$uid').set(
    RoomPlayer(uid: uid, name: playerName, isHost: false, isActive: true,
      isSpectator: true, hasRequestedToPlay: false,
      joinedAt: DateTime.now().millisecondsSinceEpoch).toMap(),
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

### `join_room_screen.dart` — spectator join option

After code validation, if `room.status == 'playing'`, show a dialog:
```
"This game is already in progress."
[Watch as Spectator]  [Cancel]
```
"Watch as Spectator" calls `joinAsSpectator()`.

### `lobby_screen.dart` — Watching section

Below the Players list:
```dart
if (spectators.isNotEmpty) ...[
  const SizedBox(height: 16),
  Text('Watching', style: /* muted 13 */),
  const SizedBox(height: 8),
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

### `multiplayer_game_screen.dart`

```dart
final myPlayer = _room?.players[RoomService.instance.currentUid];
if (myPlayer?.isSpectator == true) {
  return SpectatorView(room: _room!, roomCode: roomCode);
}
```

Wire `JoinRequestToast` on host's game screen: watch `_room.players` for any `hasRequestedToPlay == true` and show the toast with "Let In" / "Decline".

---

## ITEM 12 — Host Migration

`lib/core/widgets/host_migrated_toast.dart` already exists.

### `lib/services/room_service.dart` — ADD METHOD

```dart
Future<void> claimHostIfNeeded(String code, List<RoomPlayer> activePlayers) async {
  final snap = await _db.child('rooms/$code/hostUid').get();
  final currentHostUid = snap.value as String?;
  final hostSnap = await _db.child('rooms/$code/players/$currentHostUid/isActive').get();
  if (hostSnap.value as bool? ?? false) return;

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

### Wire into both `multiplayer_game_screen.dart` and `lobby_screen.dart`

Add `String? _lastKnownHostUid;` to state. Inside `roomStream` listener:

```dart
// Host migration check:
final host = room.players[room.hostUid];
if (host != null && !host.isActive) {
  RoomService.instance.claimHostIfNeeded(roomCode, room.activePlayers);
}

// Show toast when host changes:
final newHostUid = room.gameState?.newHostUid;
if (newHostUid != null && newHostUid != _lastKnownHostUid) {
  _lastKnownHostUid = newHostUid;
  _showHostMigratedToast(room.players[newHostUid]?.name ?? 'Someone');
  if (newHostUid == RoomService.instance.currentUid) {
    _db.child('rooms/$roomCode/gameState/newHostUid').remove();
  }
}
```

Show `HostMigratedToast` with the new host's name.

---

## ITEM 13 — Dare Vote

`lib/screens/multiplayer/widgets/dare_vote_panel.dart` already exists.

### Add to `GameState` model

```dart
final Map<String, String>? dareVotes;  // uid → 'pass'|'fail'
final String? dareVoteResult;          // 'pass'|'fail'|null
final int? dareVoteDeadline;           // timestamp ms
// fromMap / toMap accordingly
```

### `lib/services/room_service.dart` — ADD METHODS

```dart
Future<void> submitDareVote(String code, String vote) async {
  await _db.child('rooms/$code/gameState/dareVotes/$currentUid').set(vote);
}

Future<void> resolveDareVote(String code, Map<dynamic, dynamic> votes) async {
  final passCount = votes.values.where((v) => v == 'pass').length;
  final failCount = votes.values.where((v) => v == 'fail').length;
  await _db.child('rooms/$code/gameState').update({
    'dareVoteResult': passCount >= failCount ? 'pass' : 'fail',
    'dareVotes': null,
  });
}

Future<void> clearDareVote(String code) async {
  await _db.child('rooms/$code/gameState').update({
    'dareVotes': null, 'dareVoteResult': null, 'dareVoteDeadline': null,
  });
}
```

### Wire into `multiplayer_game_screen.dart`

- When a dare prompt is set: host writes `dareVoteDeadline = now + 10000`
- For non-active players: show `DareVotePanel` at bottom of screen
- Host watches deadline → calls `resolveDareVote()` when expired
- When `dareVoteResult` set: show result banner on all screens, then `clearDareVote()` + advance after 2s

---

## ITEM 14 — Room Rejoin

`lib/core/widgets/room_rejoin_banner.dart` already exists.

### `lib/services/preferences_service.dart`

```dart
static const String _keyLastRoomCode = 'last_room_code';
static const String _keyLastRoomUid  = 'last_room_uid';

String? get lastRoomCode => _prefs?.getString(_keyLastRoomCode);
String? get lastRoomUid  => _prefs?.getString(_keyLastRoomUid);

Future<void> saveLastRoom(String code, String uid) async {
  await _prefs.setString(_keyLastRoomCode, code);
  await _prefs.setString(_keyLastRoomUid, uid);
}

Future<void> clearLastRoom() async {
  await _prefs.remove(_keyLastRoomCode);
  await _prefs.remove(_keyLastRoomUid);
}
```

### `lib/services/room_service.dart` — save on join + add `rejoinRoom()`

After successful `createRoom()` and `joinRoom()`:
```dart
await PreferencesService.instance.saveLastRoom(code, currentUid);
```

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

### `join_room_screen.dart` — rejoin detection in `initState()`

```dart
final lastCode = context.read<PreferencesService>().lastRoomCode;
final lastUid  = context.read<PreferencesService>().lastRoomUid;

if (lastCode != null && lastUid != null) {
  final snap = await FirebaseDatabase.instance.ref('rooms/$lastCode').get();
  if (snap.exists) {
    final room = Room.fromMap(lastCode, snap.value as Map);
    final player = room.players[lastUid];
    if (player != null && !player.isActive && room.status != 'ended') {
      setState(() {
        _showRejoinBanner = true;
        _rejoinCode = lastCode;
        _rejoinName = player.name;
        _rejoinUid = lastUid;
      });
    }
  } else {
    context.read<PreferencesService>().clearLastRoom();
  }
}
```

Show `RoomRejoinBanner` at top of join screen UI when `_showRejoinBanner` is true. On success: navigate based on `room.status`.

---

## ITEM 15 — Change Mode Without Leaving Room

`lib/screens/multiplayer/widgets/mode_change_sheet.dart` already exists.

### `lib/services/room_service.dart` — ADD METHOD

```dart
Future<void> changeRoomMode({
  required String code,
  required String newMode,
  required List<String> newPacks,
}) async {
  await _db.child('rooms/$code').update({
    'mode': newMode, 'packs': newPacks, 'status': 'lobby',
    'gameState': null, 'missionDuration': null,
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

### Wire into `multiplayer_game_screen.dart` results screen

- Host: "Play Again" button → opens `ModeChangeSheet` (check actual widget name in the existing file)
- Non-host: "Waiting for host to start next game..." + `CircularProgressIndicator`
- All devices: when `roomStream` sees `status == 'lobby'`, auto-navigate to `LobbyScreen`

---

## ITEM 16 — QR Code (Display + Scan)

**New files to CREATE:**

### `lib/screens/multiplayer/widgets/qr_display_sheet.dart`

```dart
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplaySheet extends StatelessWidget {
  final String roomCode;
  const QrDisplaySheet({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: AppColors.primaryNeon,
      child: Column(children: [
        Text('Scan to Join', style: /* bold white 20 */),
        const SizedBox(height: 8),
        Text('Or enter code: $roomCode', style: /* muted */),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: QrImageView(
            data: 'cousinchaos://join/$roomCode',
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.background,
          ),
        ),
        const SizedBox(height: 20),
        Text('Works on both iPhone and Android', style: /* muted 13 */),
        const SizedBox(height: 8),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
      ]),
    );
  }
}
```

### `lib/screens/multiplayer/widgets/qr_scanner_screen.dart`

```dart
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatelessWidget {
  final ValueChanged<String> onCodeScanned;
  const QrScannerScreen({super.key, required this.onCodeScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Scan QR Code'), backgroundColor: Colors.transparent),
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
            style: const TextStyle(color: Colors.white, fontSize: 16))),
      ]),
    );
  }
}
```

### Wire into `lobby_screen.dart`

QR icon button next to Share Code:
```dart
GestureDetector(
  onTap: () => showModalBottomSheet(context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => QrDisplaySheet(roomCode: widget.roomCode)),
  child: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: AppColors.glassWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.glassBorder)),
    child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 22),
  ),
)
```

### Wire into `join_room_screen.dart`

Below the code input:
```dart
TextButton.icon(
  onPressed: () => Navigator.push(context,
    slideUpRoute(QrScannerScreen(
      onCodeScanned: (code) {
        _codeController.text = code;
        if (_nameController.text.trim().isNotEmpty) _joinRoom();
      },
    ))),
  icon: Icon(Icons.qr_code_scanner_rounded, color: AppColors.truthBlue),
  label: Text('Scan QR Code instead', style: TextStyle(color: AppColors.truthBlue)),
)
```

---

## ITEM 17 — Cross-Platform Player Badge

### `lib/core/models/room_player.dart` — ADD FIELD

```dart
final String platform; // 'ios' | 'android'
// toMap: 'platform': platform,
// fromMap: platform: map['platform'] as String? ?? 'android',
```

### `lib/services/room_service.dart` — write on join

In `joinRoom()` and `joinAsSpectator()`:
```dart
import 'dart:io';
// In player data map:
'platform': Platform.isIOS ? 'ios' : 'android',
```

### `lib/screens/multiplayer/widgets/player_list_tile.dart`

Add in trailing section:
```dart
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

---

# PART C — ADDENDUM 1: BUG FIXES

Fix in this exact order.

---

## BUG FIX 1 — SoundService Double-Play [HIGH]

Covered in Item 5 — verify `return;` exists after `await _player.play(AssetSource(path))` inside the non-system theme branch.

---

## BUG FIX 2 — HapticService Toggle Has No Effect [HIGH]

Covered in Item 7 — verify `HapticService.instance.setEnabled(_hapticsEnabled)` is called in `_loadPreferences()` and `setHapticsEnabled()`.

Also in `lib/main.dart` MultiProvider, add:
```dart
Provider(create: (_) => HapticService.instance),
```

---

## BUG FIX 3 — Switch `activeColor` Deprecation [MEDIUM]

Search entire `lib/` for `activeColor:` on Switch widgets. Replace every instance:
```dart
// BEFORE:
activeColor: AppColors.primaryNeon,
// AFTER:
activeTrackColor: AppColors.primaryNeon,
activeThumbColor: Colors.white,
```

---

## BUG FIX 4 — Lint Warnings [MEDIUM]

Run `flutter analyze`. Fix every warning in `lib/`:

- `unnecessary_underscores` — rename `__`/`___` to `_`/`__`
- `curly_braces_in_flow_control_structures` in `player_manager.dart`:
  ```dart
  while (_players.any((p) => p.name == 'Player $n')) { n++; }
  ```
- `sized_box_for_whitespace` — replace `Container(height: X)` with `SizedBox(height: X)`

Zero warnings in `lib/` required.

---

## BUG FIX 5 — Room Rejoin UID Not Stored [MEDIUM]

Covered fully in Item 14. Cross-check `saveLastRoom(code, currentUid)` is called in both `createRoom()` and `joinRoom()`, and `RoomRejoinBanner` passes `originalUid` to `rejoinRoom()`.

---

## BUG FIX 6 — Offline Snack Bar Not Wired [MEDIUM]

In `game_engine_screen.dart` state:
```dart
bool _hasShownOfflineNotice = false;
```

Reset in `_initGame()`:
```dart
_hasShownOfflineNotice = false;
```

In prompt-fetch `catch` block:
```dart
if (!_hasShownOfflineNotice && mounted) {
  _hasShownOfflineNotice = true;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
      const SizedBox(width: 10),
      const Text('No connection — using local prompts',
          style: TextStyle(color: Colors.white)),
    ]),
    backgroundColor: AppColors.surfaceBright,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 3),
  ));
}
```

Apply the same pattern in `multiplayer_game_screen.dart` catch block.

---

## BUG FIX 7 — `slideUpRoute` Never Implemented [LOW-MEDIUM]

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
- `create_room_screen.dart`
- `join_room_screen.dart`
- `lobby_screen.dart`
- `settings_screen.dart`
- `pack_selection_screen.dart`
- `player_setup_screen.dart`

---

## BUG FIX 8 — Delete Junk Root Files [LOW]

Delete from project root:
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

If scripts may be needed later: move to `scripts/` and add `scripts/` to `.gitignore`.

---

## BUG FIX 9 — `sensors_plus` Audit [LOW]

Search `lib/` for `sensors_plus`, `accelerometerEvents`, `gyroscopeEvents`, `userAccelerometerEvents`.

- Nothing found → remove `sensors_plus: ^7.0.0` from `pubspec.yaml`, run `flutter pub get`
- Found → add comment in `pubspec.yaml` explaining usage

---

## BUG FIX 10 — Missing Unit Tests [LOW]

Create in `test/`:

**`test/services/player_manager_test.dart`**
Test `addPlayer()` adds a player, `removePlayer()` removes one, avatar IDs cycle through `AvatarConstants.options`, `updatePlayerAvatar()` updates correctly.

**`test/services/session_stats_service_test.dart`**
Test `recordTruth/Dare/Skip()` increment counts, `mostDaresPerson` returns correct player ID, `totalRounds` increments with `incrementRound()`.

**`test/services/sound_service_test.dart`**
Test `SoundService.instance` is a singleton, `play()` with `soundEnabled: false` completes without error.

**`test/services/haptic_service_test.dart`**
Test `HapticService.instance` is a singleton, `setEnabled(false)` + `trigger()` completes without error, `setTheme(HapticTheme.subtle)` doesn't throw.

**`test/core/game_constants_test.dart`**
Test timer durations are positive, player count min < max, all `AvatarConstants.options` have unique IDs.

Run `flutter test` — zero failures required.

---

---

# PART D — ADDENDUM 2: POLISH (Excluding Monetization)

---

## ITEM A — Target Audience: Family & Friend Groups

**`lib/screens/onboarding/onboarding_screen.dart`**
Change slide 1 body text to: `"The ultimate party game for families, friends, and everyone in between."`

**`lib/core/constants/pack_data.dart`**
Add `'audience'` tag to each pack: `'family'`, `'friends'`, or `'18+'`.

**`lib/screens/truth_or_dare/pack_selection_screen.dart`**
Add horizontal filter chips at top: `All` | `Family` | `Friends` | `18+` (only if 18+ toggle enabled).
Show audience badge on each pack card.

---

## ITEM B — Firebase Backend Hardening

### B1 — Room Creation Rate Limit (`lib/services/room_service.dart`)

```dart
DateTime? _lastRoomCreated;
static const _minRoomCreateInterval = Duration(minutes: 2);
```

At START of `createRoom()`:
```dart
if (_lastRoomCreated != null) {
  final elapsed = DateTime.now().difference(_lastRoomCreated!);
  if (elapsed < _minRoomCreateInterval) {
    final remaining = _minRoomCreateInterval - elapsed;
    throw Exception('Please wait ${remaining.inSeconds} seconds before creating another room.');
  }
}
```

At END of `createRoom()` before return:
```dart
_lastRoomCreated = DateTime.now();
```

In `create_room_screen.dart`: wrap `createRoom()` in try-catch showing the exception message via `setState(() => _error = ...)`.

### B2 — Room Code Retry Limit

Replace infinite loop in `_uniqueCode()`:
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

Add `import 'dart:async';` if missing.

### B3 — Firebase Cost Comment Block

Add near top of `lib/services/room_service.dart`:
```dart
// ── Firebase Usage Notes ─────────────────────────────────────────────────────
// Free Spark plan: 1GB storage, 10GB/month downloads, 100 simultaneous connections
// ~5-20 KB written per room, ~50-200 KB downloaded per device per session
// Blaze plan recommended if MAU > 10,000
// Monitor at: console.firebase.google.com → Usage tab
// ─────────────────────────────────────────────────────────────────────────────
```

---

## ITEM C — Multiplayer Fetch Loading State

### `lib/services/room_service.dart`
```dart
Future<void> setFetchingPrompt(String code, bool isFetching) async {
  await _db.child('rooms/$code/gameState/isFetchingPrompt').set(isFetching);
}
```

### GameState model — add field
```dart
final bool isFetchingPrompt;
// fromMap: isFetchingPrompt: map['isFetchingPrompt'] as bool? ?? false,
// toMap: 'isFetchingPrompt': isFetchingPrompt,
```

### `multiplayer_game_screen.dart` — wrap fetch + show skeleton
```dart
// Wrap _fetchAndSetPrompt():
await RoomService.instance.setFetchingPrompt(widget.roomCode, true);
try {
  // existing logic
} finally {
  await RoomService.instance.setFetchingPrompt(widget.roomCode, false);
}

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

## ITEM D — DisclaimerDialog: Once Per Install

### `lib/services/preferences_service.dart`
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

### `lib/widgets/disclaimer_dialog.dart`
1. Delete `static bool _accepted` field
2. In `show()`, add at top:
   ```dart
   final prefs = context.read<PreferencesService>();
   if (prefs.disclaimerAccepted) { onAccept(); return; }
   ```
3. In accept callback: call `prefs.setDisclaimerAccepted();` before `onAccept()`

---

## ITEM E — Web Version (Flutter Web Companion)

**New files to create:**
```
lib/web/web_app.dart
lib/web/web_join_screen.dart
lib/web/web_game_screen.dart
```

### `lib/main.dart`
```dart
import 'package:flutter/foundation.dart';

// In main():
if (kIsWeb) {
  runApp(const CousinChaosWebApp());
} else {
  runApp(const CousinChaosApp());
}
```

### `lib/web/web_app.dart`
```dart
class CousinChaosWebApp extends StatelessWidget {
  const CousinChaosWebApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cousin Chaos — Join Game',
      theme: AppTheme.dark,
      home: const WebJoinScreen(),
    );
  }
}
```

### `lib/web/web_join_screen.dart`
Browser-optimized join flow: room code field, player name field, "Join Game" button → `joinRoom()` → navigates to `WebGameScreen`. Clean centered desktop layout.

### `lib/web/web_game_screen.dart`
Read-only game view: shows current prompt from Firebase stream, whose turn it is, dare vote panel when active. "Watching" label — no turn-advance controls.

### `web/index.html` — update meta tags
```html
<meta name="description" content="Join a Cousin Chaos party game room from your browser. No download required.">
<meta property="og:title" content="Join Cousin Chaos">
<meta property="og:description" content="You've been invited to a Cousin Chaos party game!">
<title>Cousin Chaos — Join Game</title>
```

### `lobby_screen.dart` — update Share Code text
```dart
'Join my Cousin Chaos room! 🎮\n\n'
'Room code: ${widget.roomCode}\n\n'
'Join from browser: https://play.cousinchaos.com/join/${widget.roomCode}\n'
'Or open the app and tap "Join Room"'
```

> **Developer note:** Deploy with `flutter build web` then `firebase deploy --only hosting`. Configure `firebase.json` to route `/join/*` to the Flutter web app.

---

---

# COMPLETE IMPLEMENTATION ORDER

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
| 14 | Update `preferences_service.dart`: haptic theme + `setEnabled()` wiring + load both in `_loadPreferences()` | App 7 / BF2 |
| 15 | Add Haptic Theme chip picker to `settings_screen.dart` | App 7 |
| 16 | Remove portrait lock from `main.dart` + per-screen lock in game screens + tablet layouts in home + prompt card | App 8 |
| 17 | Add auto-advance to `preferences_service.dart` + settings toggle + `prompt_card.dart` timer logic | App 9 |
| 18 | Call `HomeWidgetService.init()` in `main.dart` + `AppLifecycleListener` in `home_screen.dart` | App 10 |
| 19 | Add `isSpectator` + `hasRequestedToPlay` to `room_player.dart` | MP 11 |
| 20 | Add `joinAsSpectator()`, `requestToPlay()`, `approveSpectator()` to `room_service.dart` | MP 11 |
| 21 | Spectator join dialog in `join_room_screen.dart` + Watching section in `lobby_screen.dart` + spectator view check + join request toast on host in `multiplayer_game_screen.dart` | MP 11 |
| 22 | Add `claimHostIfNeeded()` to `room_service.dart` + wire into both screens + show `HostMigratedToast` | MP 12 |
| 23 | Add dare vote fields to `GameState` + vote methods to `room_service.dart` + wire `DareVotePanel` | MP 13 |
| 24 | Add `lastRoomCode/Uid` to `preferences_service.dart` + `saveLastRoom()` + `clearLastRoom()` | MP 14 |
| 25 | Add `rejoinRoom()` to `room_service.dart` + call `saveLastRoom()` in `createRoom()` + `joinRoom()` | MP 14 |
| 26 | Wire rejoin detection + `RoomRejoinBanner` in `join_room_screen.dart` | MP 14 |
| 27 | Add `changeRoomMode()` to `room_service.dart` + wire Play Again / mode change in multiplayer results | MP 15 |
| 28 | Create `qr_display_sheet.dart` + `qr_scanner_screen.dart` + wire into lobby + join screens | MP 16 |
| 29 | Add `platform` field to `room_player.dart` + write on join + badge in `player_list_tile.dart` | MP 17 |
| 30 | Fix `activeColor` → `activeTrackColor` + `activeThumbColor` in ALL Switch widgets | BF3 |
| 31 | Run `flutter analyze` — fix all `lib/` warnings | BF4 |
| 32 | Create `page_transitions.dart` + replace all `MaterialPageRoute` in all nav screens | BF7 |
| 33 | Wire offline snack bar into `game_engine_screen.dart` + `multiplayer_game_screen.dart` | BF6 |
| 34 | Add `disclaimerAccepted` to `preferences_service.dart` + update `disclaimer_dialog.dart` | Addendum D |
| 35 | Add audience tags to packs + filter chips in pack selection + update onboarding text | Addendum A |
| 36 | Rate limit + retry limit + cost comment in `room_service.dart` + try-catch in `create_room_screen.dart` | Addendum B |
| 37 | `setFetchingPrompt()` + `isFetchingPrompt` in `GameState` + skeleton in `multiplayer_game_screen.dart` | Addendum C |
| 38 | Create web files + update `main.dart` kIsWeb + update `index.html` + lobby share text | Addendum E |
| 39 | Create 5 unit test files + run `flutter test` | BF10 |
| 40 | Add `Provider(HapticService.instance)` to `main.dart` MultiProvider | BF2 |
| 41 | Audit + remove `sensors_plus` if unused | BF9 |
| 42 | Delete / move junk root files | BF8 |
| 43 | `flutter build apk --release` — zero errors | QA |
| 44 | Full QA pass against checklist below | QA |

---

# FINAL VERIFICATION CHECKLIST

**App Items:**
- [ ] Every player has a visible avatar — picker opens on tap — 8 options shown — selection updates immediately
- [ ] Every game screen has its own distinct gradient and glow color
- [ ] Custom "+" button in T&D AppBar — entered prompt used immediately and not saved
- [ ] "See Highlights" button on ALL 5 game end screens
- [ ] Highlights reel shows swipeable cards with correct stats per game mode
- [ ] Sound Theme chip row in Settings — System / Retro / Cinematic
- [ ] Retro or Cinematic active: ONE sound per action (not two)
- [ ] Prompt rating slides up after completing a prompt
- [ ] Rated prompts appear more/less frequently in subsequent rounds
- [ ] Haptic Theme chip row in Settings — Subtle / Standard / Intense
- [ ] Haptics OFF toggle → zero haptic feedback anywhere
- [ ] Haptics ON → haptics return immediately
- [ ] Tablet (shortestSide ≥ 600dp): home shows 3-column grid, game shows two-column layout
- [ ] Auto-advance ON: prompt advances without tap after timer ends
- [ ] Home screen widget shows today's challenge

**Multiplayer:**
- [ ] Joining in-progress game shows "Watch as Spectator" option
- [ ] Spectator sees read-only game + "Request to Join" button
- [ ] Host sees join request toast — "Let In" promotes spectator
- [ ] Host disconnect → next player becomes host within ~10s
- [ ] All players see host migration toast
- [ ] During dare: non-active players see 10-second vote panel
- [ ] Vote result shows on all screens simultaneously
- [ ] Rejoin banner auto-detects last room on join screen
- [ ] Rejoin with correct name + code restores player to active
- [ ] Host can choose same mode or different mode after game ends
- [ ] Mode change: all players auto-navigate to lobby
- [ ] Lobby QR icon → scannable QR code
- [ ] Join screen QR scanner → camera → auto-fills code
- [ ] Platform badge (iPhone/Android) visible in lobby player list

**Bug Fixes:**
- [ ] `flutter analyze` — zero warnings in `lib/`
- [ ] `flutter test` — zero failures
- [ ] No `activeColor` deprecation warnings
- [ ] Offline snack bar shows exactly once per session in T&D and multiplayer
- [ ] All screen transitions use scale+fade animation
- [ ] Disclaimer shows only on first install — never again
- [ ] Root junk files deleted/moved
- [ ] `sensors_plus` audited

**Addendum:**
- [ ] Onboarding mentions both families and friends
- [ ] Pack audience tags + filter chips work
- [ ] Rate-limit message shown when creating two rooms within 2 minutes
- [ ] Room code generation times out gracefully if Firebase unreachable
- [ ] Multiplayer: skeleton card shown while host fetches prompt
- [ ] `flutter build apk --release` — zero errors
- [ ] `flutter build web` — zero errors

---

## PRE-START QUESTIONS FOR THE AGENT

Answer these before beginning:

1. What is the exact constant name for room code storage in `PreferencesService`? (needed for `clearLastRoom()`)
2. What is `currentUid` in `RoomService`? (Firebase Auth getter, stored field, etc.)
3. What parameters does `HighlightsScreen` constructor actually take? (check the file before wiring)
4. Is `GameState` defined inside `room.dart` or a separate file?
5. Do Phase 9 unit test spec files exist anywhere in the project?
6. What is the existing Share Code implementation in `lobby_screen.dart`? (`share_plus`? `Clipboard`?)
7. What is `_lastSelectedType` called in `game_engine_screen.dart`? (for the `AddPromptSheet` type pre-fill)
