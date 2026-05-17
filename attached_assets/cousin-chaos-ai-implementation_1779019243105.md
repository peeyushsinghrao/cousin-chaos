# Cousin Chaos — AI Implementation Plan (All 22 Phases)

> **CRITICAL RULE FOR AI:** Execute phases in the EXACT order below. After every 3 phases run `flutter analyze` and fix ALL errors before proceeding. Never skip. Never reorder.

---

## PHASE 1 — DELETE SCREENS & CLEAN CODEBASE

### Step 1: Delete these files from disk entirely
```
lib/screens/new_modes/bomb_pass_screen.dart
lib/screens/new_modes/chaos_mode_screen.dart
lib/screens/new_modes/freeze_mode_screen.dart
lib/screens/new_modes/secret_mission_screen.dart
lib/screens/new_modes/target_player_screen.dart
lib/screens/new_modes/most_likely_screen.dart
lib/screens/new_modes/rank_it_screen.dart
lib/screens/new_modes/judge_me_screen.dart
lib/screens/new_modes/laugh_attack_screen.dart
lib/screens/new_modes/hot_seat_screen.dart
lib/screens/crew/crew_screen.dart
lib/screens/vault/vault_screen.dart
lib/screens/daily_challenge/daily_challenge_screen.dart
```

### Step 2: Global codebase search — remove ALL of the following
Search every `.dart` file for each deleted filename and remove:
- Every `import` statement referencing a deleted file
- Every `route` or `MaterialPageRoute` referencing a deleted screen class
- Every widget instantiation of a deleted screen class
- Every named route string (e.g. `'/bomb_pass'`, `'/crew'`, `'/vault'`) in `routes:` maps

### Step 3: In `lib/screens/home/home_screen.dart` remove
- The `_buildDailyChallengeBanner()` method and its call site in the `build` tree
- The `_buildStatsSection()` method (removes Chaos Meter, Crew Active, Total Vault widgets)
- The Crew tab entry from `IndexedStack` children list
- The Vault tab entry from `IndexedStack` children list
- The corresponding `BottomNavigationBarItem` entries for Crew and Vault
- All variables named or related to `streak` (e.g. `_streakCount`, `_streakDays`, etc.)
- All methods named or related to `streak`
- All UI widgets that display streak info

### Step 4: In `lib/services/preferences_service.dart` remove
- Every method, key constant, or getter referencing `'daily_challenge'`
- Every method, key constant, or getter referencing `'streak'`
- Every method, key constant, or getter referencing `'seen_today'`

---

## PHASE 2 — RESTRUCTURE BOTTOM NAV TO 3 TABS

### Step 1: In `lib/screens/home/home_screen.dart`
Replace the entire `IndexedStack` + `BottomNavigationBar` with exactly 3 tabs:

```dart
// State variable
int _currentIndex = 0;

// IndexedStack children — in order
IndexedStack(
  index: _currentIndex,
  children: [
    ChaosTab(),      // existing home content (game mode grid)
    PlayersScreen(), // new — created below
    SettingsScreen(),
  ],
)
```

### Step 2: Bottom nav widget — floating pill bar

```dart
Positioned(
  bottom: 24,
  left: 24,
  right: 24,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(32),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, LucideIcons.zap, 'Chaos'),
            _buildNavItem(1, LucideIcons.users, 'Players'),
            _buildNavItem(2, LucideIcons.settings, 'Settings'),
          ],
        ),
      ),
    ),
  ),
)
```

```dart
Widget _buildNavItem(int index, IconData icon, String label) {
  final isActive = _currentIndex == index;
  return GestureDetector(
    onTap: () => setState(() => _currentIndex = index),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => isActive
              ? LinearGradient(colors: [AppColors.primary, AppColors.secondary])
                  .createShader(bounds)
              : const LinearGradient(colors: [Colors.white54, Colors.white54])
                  .createShader(bounds),
          child: Icon(icon, size: 24, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : Colors.white54,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}
```

### Step 3: Create `lib/screens/players/players_screen.dart`

```dart
class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerManager>(
      builder: (context, pm, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Players', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      GestureDetector(
                        onTap: () => _showAddPlayerDialog(context, pm),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)],
                          ),
                          child: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                // Player list
                Expanded(
                  child: pm.players.isEmpty
                      ? Center(child: Text('No players yet.\nTap + to add one.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: pm.players.length,
                          itemBuilder: (context, index) {
                            final player = pm.players[index];
                            return _PlayerCard(player: player, pm: pm);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

```dart
class _PlayerCard extends StatefulWidget {
  final Player player;
  final PlayerManager pm;
  const _PlayerCard({required this.player, required this.pm});

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(/* player avatar */),
        title: _isEditing
            ? TextField(controller: _nameController, autofocus: true, style: const TextStyle(color: Colors.white))
            : Text(widget.player.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text('${widget.player.xp} XP', style: TextStyle(color: AppColors.gold)),
        trailing: _isEditing
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(LucideIcons.check, color: Colors.green), onPressed: () {
                  widget.pm.renamePlayer(widget.player.id, _nameController.text.trim());
                  setState(() => _isEditing = false);
                }),
                IconButton(icon: const Icon(LucideIcons.x, color: Colors.red), onPressed: () {
                  widget.pm.deletePlayer(widget.player.id);
                }),
              ])
            : null,
        onTap: () => setState(() => _isEditing = true),
      ),
    );
  }
}
```

---

## PHASE 3 — LUCIDE ICONS EVERYWHERE

### Step 1: Add to `pubspec.yaml`
```yaml
dependencies:
  lucide_flutter: ^1.0.0
```
Run: `flutter pub get`

### Step 2: Global find-and-replace in ALL `.dart` files

| Find (exact string) | Replace with |
|---|---|
| `Icons.settings` | `LucideIcons.settings` |
| `Icons.person` | `LucideIcons.user` |
| `Icons.people` | `LucideIcons.users` |
| `Icons.arrow_back_ios_new_rounded` | `LucideIcons.arrowLeft` |
| `Icons.add` | `LucideIcons.plus` |
| `Icons.add_circle` | `LucideIcons.plusCircle` |
| `Icons.close` | `LucideIcons.x` |
| `Icons.cancel` | `LucideIcons.x` |
| `Icons.info` | `LucideIcons.info` |
| `Icons.info_outline` | `LucideIcons.info` |
| `Icons.star` | `LucideIcons.star` |
| `Icons.star_border` | `LucideIcons.star` |
| `Icons.refresh` | `LucideIcons.refreshCw` |
| `Icons.replay` | `LucideIcons.refreshCw` |
| `Icons.check` | `LucideIcons.check` |
| `Icons.check_circle` | `LucideIcons.checkCircle` |
| `Icons.timer` | `LucideIcons.timer` |
| `Icons.access_time` | `LucideIcons.timer` |
| `Icons.emoji_events` | `LucideIcons.trophy` |
| `Icons.logout` | `LucideIcons.logOut` |
| `Icons.volume_up` | `LucideIcons.volume2` |
| `Icons.volume_off` | `LucideIcons.volumeX` |
| `Icons.bolt` | `LucideIcons.zap` |
| `Icons.lock` | `LucideIcons.lock` |
| `Icons.play_arrow` | `LucideIcons.play` |
| `Icons.pause` | `LucideIcons.pause` |
| `Icons.skip_next` | `LucideIcons.skipForward` |
| `Icons.casino` | `LucideIcons.dices` |
| `Icons.sports_esports` | `LucideIcons.gamepad2` |

### Step 3: Add import to every file that uses icons
Add this line at the top of every `.dart` file that references `LucideIcons`:
```dart
import 'package:lucide_flutter/lucide_flutter.dart';
```

---

### ✅ CHECKPOINT — Run `flutter analyze`. Fix every error before Phase 4.

---

## PHASE 4 — ONBOARDING (SHOW ONLY ONCE)

### Step 1: Modify `lib/screens/splash/splash_screen.dart`
Replace the existing `_navigateToNext()` method with:

```dart
void _navigateToNext() async {
  if (!mounted) return;
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('onboarding_complete') ?? false;
  final destination = seen ? const HomeScreen() : const OnboardingScreen();
  if (!mounted) return;
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => destination,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: ColoredBox(color: AppColors.background, child: child),
      ),
      transitionDuration: const Duration(milliseconds: 500),
    ),
  );
}
```

Add import: `import 'package:shared_preferences/shared_preferences.dart';`
Add import: `import '../onboarding/onboarding_screen.dart';`

### Step 2: Create `lib/screens/onboarding/onboarding_screen.dart`

```dart
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToPage(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MeshGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Skip button — only on pages 0 and 1
                Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    opacity: _currentPage < 2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: () => _goToPage(2),
                      child: Text('Skip', style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                ),
                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _OnboardingPage1(),
                      _OnboardingPage2(),
                      _OnboardingPage3(onFinish: _finish),
                    ],
                  ),
                ),
                // Dot indicator
                _DotIndicator(current: _currentPage, total: 3),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Page 1 widget:**
```dart
class _OnboardingPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App logo with glow
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.6), blurRadius: 40, spreadRadius: 10)],
          ),
          child: Image.asset('assets/images/logo.png'), // existing logo
        ),
        const SizedBox(height: 32),
        Text('Welcome to Cousin Chaos',
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Text('The party game that breaks friendships 😈',
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(fontSize: 16, color: Colors.white70)),
      ],
    );
  }
}
```

**Page 2 widget:**
```dart
class _OnboardingPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icons = [LucideIcons.flame, LucideIcons.userX, LucideIcons.helpCircle,
                   LucideIcons.shield, LucideIcons.zap, LucideIcons.star,
                   LucideIcons.gitBranch, LucideIcons.alertTriangle];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Spin. Reveal. Survive.',
            style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16, runSpacing: 16,
          alignment: WrapAlignment.center,
          children: icons.map((icon) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          )).toList(),
        ),
        const SizedBox(height: 24),
        Text('8 chaotic game modes.\nOne winner. No mercy.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15)),
      ],
    );
  }
}
```

**Page 3 widget:**
```dart
class _OnboardingPage3 extends StatelessWidget {
  final VoidCallback onFinish;
  const _OnboardingPage3({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("You're ready.", style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: onFinish,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 24, spreadRadius: 4)],
            ),
            child: Text("LET'S GO 🔥",
                style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
```

**Dot indicator widget:**
```dart
class _DotIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _DotIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: i == current ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: i == current ? AppColors.primary : Colors.white30,
          borderRadius: BorderRadius.circular(4),
        ),
      )),
    );
  }
}
```

---

## PHASE 5 — HOME SCREEN CLEANUP & REDESIGN

### Step 1: In `lib/screens/home/home_screen.dart` remove
- Delete `_buildDailyChallengeBanner()` method and its call in `build`
- Delete `_buildStatsSection()` method and its call in `build`
- Delete all streak variables and methods

### Step 2: Update welcome text
```dart
Consumer<PlayerManager>(
  builder: (context, pm, _) {
    final name = pm.players.isNotEmpty ? pm.players.first.name : 'Chaos Crew';
    return Text('Hey $name 👋',
        style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white));
  },
)
```

### Step 3: Replace game mode grid with exactly 8 modes

```dart
// Define the 8 modes as a constant list
static const _modes = [
  _ModeData('Truth & Dare',      'Spin. Choose. Survive.',     LucideIcons.flame,         '/truth_dare'),
  _ModeData('Impostor',          'Trust no one.',               LucideIcons.userX,         '/impostor'),
  _ModeData('Two Truths One Lie','Spot the lie.',               LucideIcons.helpCircle,    '/two_truths'),
  _ModeData('Alibi',             'Stick to your story.',        LucideIcons.shield,        '/alibi'),
  _ModeData('Speed Challenge',   'Fastest fingers win.',        LucideIcons.zap,           '/speed_challenge'),
  _ModeData('Act It Out',        'No talking allowed.',         LucideIcons.star,          '/act_it_out'),
  _ModeData('Would You Rather',  'Pick your poison.',           LucideIcons.gitBranch,     '/would_you_rather'),
  _ModeData('Never Have I Ever', 'Confess your chaos.',         LucideIcons.alertTriangle, '/never_have_i_ever'),
];

// Grid widget
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.9,
  ),
  itemCount: _modes.length,
  itemBuilder: (context, index) => _ModeCard(mode: _modes[index]),
)
```

```dart
class _ModeCard extends StatelessWidget {
  final _ModeData mode;
  const _ModeCard({required this.mode});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, mode.route),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.surface.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 16, spreadRadius: 2)],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(mode.icon, color: AppColors.primary, size: 32),
            const Spacer(),
            Text(mode.name, style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(mode.tagline, style: TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
```

### Step 4: Add "Last Played" card at bottom of scroll view

```dart
FutureBuilder<List<SessionRecord>>(
  future: SessionService.loadSessions(),
  builder: (context, snapshot) {
    if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
    final last = snapshot.data!.first;
    final ago = _timeAgo(last.playedAt);
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ListTile(
        leading: Icon(_iconForMode(last.mode), color: AppColors.primary),
        title: Text(last.mode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text('Last played $ago · Winner: ${last.winner}', style: TextStyle(color: Colors.white54, fontSize: 12)),
      ),
    );
  },
)

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
```

Place this card in the `ListView`/`SingleChildScrollView` below the mode grid, with `SizedBox(height: 120)` after it for nav spacing.

---

## PHASE 6 — SETTINGS REDESIGN + DARK MODE LOCK

### Step 1: In `lib/screens/settings/settings_screen.dart`
Remove the back arrow from `AppBar`:
```dart
AppBar(
  automaticallyImplyLeading: false, // removes back arrow
  title: Text('Settings', style: GoogleFonts.sora(...)),
  backgroundColor: Colors.transparent,
  elevation: 0,
)
```

### Step 2: Rebuild settings body with 4 GlassCard sections

```dart
body: ListView(
  padding: const EdgeInsets.all(16),
  children: [
    // SOUND SECTION
    GlassCard(child: Column(children: [
      _SectionHeader('🔊 Sound'),
      _SettingsToggle(label: 'Sound Effects', value: prefs.soundEnabled, onChanged: (v) => prefs.setSoundEnabled(v)),
      if (prefs.soundEnabled)
        _SettingsSlider(label: 'Volume', value: prefs.volume, onChanged: (v) => prefs.setVolume(v)),
    ])),
    const SizedBox(height: 12),

    // HAPTICS SECTION
    GlassCard(child: Column(children: [
      _SectionHeader('📳 Haptics'),
      _SettingsToggle(label: 'Haptic Feedback', value: prefs.hapticEnabled, onChanged: (v) => prefs.setHapticEnabled(v)),
    ])),
    const SizedBox(height: 12),

    // GAME DEFAULTS SECTION
    GlassCard(child: Column(children: [
      _SectionHeader('🎮 Game Defaults'),
      _SegmentedControl(
        label: 'Questions per game',
        options: ['10', '15', '20'],
        selected: prefs.questionsPerGame.toString(),
        onChanged: (v) => prefs.setQuestionsPerGame(int.parse(v)),
      ),
      _SegmentedControl(
        label: 'Wheel style',
        options: ['Classic', 'Neon', 'Minimal'],
        selected: prefs.wheelStyle,
        onChanged: (v) => prefs.setWheelStyle(v),
      ),
    ])),
    const SizedBox(height: 12),

    // APP SECTION
    GlassCard(child: Column(children: [
      _SectionHeader('📱 App'),
      ListTile(title: Text('Version', style: TextStyle(color: Colors.white)), trailing: FutureBuilder<PackageInfo>(future: PackageInfo.fromPlatform(), builder: (_, s) => Text(s.data?.version ?? '...', style: TextStyle(color: Colors.white54)))),
      ListTile(title: Text('Share with Friends', style: TextStyle(color: Colors.white)), trailing: Icon(LucideIcons.share2, color: Colors.white54), onTap: () => Share.share('Play Cousin Chaos!')),
      ListTile(title: Text('Rate the App', style: TextStyle(color: Colors.white)), trailing: Icon(LucideIcons.star, color: Colors.white54), onTap: () => LaunchReview.launch()),
    ])),
  ],
)
```

### Step 3: Lock dark mode in `lib/core/theme/app_theme.dart`
- Delete the `lightTheme` getter entirely if it exists
- In `main.dart` or `app.dart` where `CousinChaosApp` is defined:

```dart
MaterialApp(
  theme: AppTheme.darkTheme,       // primary theme
  darkTheme: AppTheme.darkTheme,   // same — forces dark always
  themeMode: ThemeMode.dark,       // never follows system
  // remove any themeMode toggle logic
)
```

---

### ✅ CHECKPOINT — Run `flutter analyze`. Fix every error before Phase 7.

---

## PHASE 7 — REMOVE TIMERS FROM TRUTH & DARE

### In `lib/screens/truth_or_dare/game_engine_screen.dart`

**Delete these state members:**
```dart
// DELETE ALL OF THESE:
late AnimationController _timerController;
Timer? _gameTimer;
int _timeLeft = 0;
void _startTimer() { ... }
void _onTimerEnd() { ... }
void _resetTimer() { ... }
```

**Delete from `initState`:** Any call to `_startTimer()` or timer initialization.

**Delete from `dispose`:** `_timerController.dispose()` and any timer cancellation.

**Delete from card UI build method:** The entire row/widget that shows `DynamicTimerWidget(...)`.

**Remove this import (only from game_engine_screen.dart — keep file):**
```dart
// Remove this line from game_engine_screen.dart only:
import '../../widgets/dynamic_timer_widget.dart';
```

**What the card should show after removal — only these 3 things:**
1. Player name (large, bold, at top)
2. Category badge
3. Question text (main body)

---

## PHASE 8 — CARD REVEAL: TAP TO FLIP + NEXT BUTTON

### In `lib/screens/truth_or_dare/game_engine_screen.dart`

**Step 1: Add to class state**
```dart
late AnimationController _flipController;
late Animation<double> _flipAnimation;
bool _isRevealed = false;
bool _swipeHintShown = false; // tracks if swipe hint has been dismissed
```

**Step 2: In `initState` add**
```dart
_flipController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 500),
);
_flipAnimation = Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
);
```

**Step 3: In `dispose` add**
```dart
_flipController.dispose();
```

**Step 4: Add `_onNext()` method**
```dart
void _onNext() {
  _flipController.reverse();
  setState(() {
    _isRevealed = false;
    _swipeHintShown = true;
  });
  SoundService.instance.play(SoundEvent.nextPlayer, soundEnabled: prefs.soundEnabled);
  // existing logic to advance to next player/card
  _advanceToNextCard();
}
```

**Step 5: Replace card widget with this structure**
```dart
GestureDetector(
  onTap: () {
    if (!_isRevealed) {
      _flipController.forward();
      SoundService.instance.play(SoundEvent.cardFlip, soundEnabled: prefs.soundEnabled);
      setState(() => _isRevealed = true);
    }
  },
  onHorizontalDragEnd: (details) {
    if (_isRevealed && details.primaryVelocity! < -300) {
      _onNext();
    }
  },
  child: AnimatedBuilder(
    animation: _flipAnimation,
    builder: (context, child) {
      // Values 0.0–0.5 = front face; 0.5–1.0 = back face
      final angle = _flipAnimation.value * pi;
      final showFront = _flipAnimation.value < 0.5;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle),
        child: showFront ? _buildCardFront() : Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateY(pi), // counter-rotate back face
          child: _buildCardBack(),
        ),
      );
    },
  ),
)
```

**Card front widget:**
```dart
Widget _buildCardFront() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [AppColors.surface, AppColors.surface.withOpacity(0.8)]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.15)),
    ),
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_currentPlayerName, style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        _CategoryBadge(category: _currentCategory),
        const Spacer(),
        // Pulsing hint
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1.0),
          duration: const Duration(milliseconds: 900),
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: Text('TAP TO REVEAL', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
      ],
    ),
  );
}
```

**Card back widget:**
```dart
Widget _buildCardBack() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [AppColors.primary.withOpacity(0.3), AppColors.secondary.withOpacity(0.3)],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
    ),
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CategoryBadge(category: _currentCategory),
        const SizedBox(height: 24),
        Text(_currentQuestion, textAlign: TextAlign.center,
            style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    ),
  );
}
```

**Step 6: NEXT button — shows only after reveal**
Place this below the card in the column:
```dart
AnimatedSlide(
  offset: _isRevealed ? Offset.zero : const Offset(0, 1),
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
  child: AnimatedOpacity(
    opacity: _isRevealed ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 300),
    child: Column(
      children: [
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _onNext,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('NEXT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              const Icon(LucideIcons.arrowRight, color: Colors.white, size: 18),
            ]),
          ),
        ),
        // Swipe hint — fades after first use
        if (!_swipeHintShown)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('← swipe to advance', style: TextStyle(color: Colors.white30, fontSize: 12)),
          ),
      ],
    ),
  ),
)
```

---

## PHASE 9 — SPIN WHEEL OVERHAUL

### In `lib/screens/truth_or_dare/widgets/physics_wheel.dart`

**Step 1: Remove physics-based spin logic**
Delete the code that reads swipe velocity and uses it to set spin speed/duration.

**Step 2: Replace with `_triggerSpin()`**
```dart
void _triggerSpin() {
  if (_isSpinning) return;
  final random = Random();
  final totalRotation = (4 + random.nextInt(3)) * 2 * pi + random.nextDouble() * 2 * pi;
  _controller.reset();
  _controller.animateTo(
    totalRotation,
    duration: const Duration(milliseconds: 3500),
    curve: Curves.decelerate,
  );
  setState(() => _isSpinning = true);
  SoundService.instance.play(SoundEvent.wheelSpin, soundEnabled: prefs.soundEnabled);
  _startTickSound(); // call alongside spin
  Future.delayed(const Duration(milliseconds: 3500), () {
    if (mounted) {
      setState(() => _isSpinning = false);
      SoundService.instance.play(SoundEvent.wheelLand, soundEnabled: prefs.soundEnabled);
      _onSpinComplete(); // existing callback — do not rename or remove
    }
  });
}
```

**Step 3: Add `_startTickSound()`**
```dart
void _startTickSound() async {
  final tickIntervals = [
    ...List.filled(15, 150), // fast ticks (first ~2.25 seconds)
    ...List.filled(8, 250),  // medium ticks
    ...List.filled(5, 400),  // slow ticks (last second)
  ];
  for (final interval in tickIntervals) {
    if (!_isSpinning || !mounted) break;
    SoundService.instance.play(SoundEvent.timerTick, soundEnabled: prefs.soundEnabled);
    await Future.delayed(Duration(milliseconds: interval));
  }
}
```

**Step 4: Make swipe call `_triggerSpin()` (ignore velocity)**
In the `GestureDetector` wrapping the wheel:
```dart
onPanEnd: (details) => _triggerSpin(), // ignore details.velocity
```

**Step 5: Add SPIN button below the wheel**
```dart
Padding(
  padding: const EdgeInsets.only(top: 24),
  child: GestureDetector(
    onTap: _triggerSpin,
    child: AnimatedOpacity(
      opacity: _isSpinning ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          gradient: _isSpinning ? null : LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
          color: _isSpinning ? Colors.white24 : null,
          borderRadius: BorderRadius.circular(32),
          boxShadow: _isSpinning ? [] : [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, spreadRadius: 2)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.refreshCw, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('SPIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
      ),
    ),
  ),
)
```

---

### ✅ CHECKPOINT — Run `flutter analyze`. Fix every error before Phase 10.

---

## PHASE 10 — SOUNDS THROUGHOUT THE APP

### Step 1: In `lib/services/sound_service.dart` update the enum
```dart
enum SoundEvent {
  tap,
  cardFlip,
  wheelSpin,
  wheelLand,
  wheelTick,
  nextPlayer,
  win,
  wrong,
  timerTick,
  timerEnd,
  pageTransition,
  xpGain,
}
```

### Step 2: Add sound file mappings
In the map that associates `SoundEvent` → file path, add:
```dart
SoundEvent.cardFlip:      'sounds/card_flip.mp3',
SoundEvent.wheelSpin:     'sounds/wheel_spin.mp3',
SoundEvent.wheelLand:     'sounds/wheel_land.mp3',
SoundEvent.wheelTick:     'sounds/tick.mp3',
SoundEvent.pageTransition:'sounds/whoosh.mp3',
SoundEvent.xpGain:        'sounds/success.mp3',
```

### Step 3: Add sound files to assets
Create/add these `.mp3` files to `assets/sounds/`:
- `card_flip.mp3` — short swoosh/flick sound
- `wheel_spin.mp3` — spinning initiation sound
- `wheel_land.mp3` — tick/click landing sound
- `tick.mp3` — single short tick
- `whoosh.mp3` — page transition whoosh
- `success.mp3` — ascending chime/fanfare

Register in `pubspec.yaml` under `flutter: assets:` if not already using wildcard.

### Step 4: Wire sounds globally

**Every `GestureDetector.onTap` and `ElevatedButton.onPressed` / `TextButton.onPressed`:**
```dart
onTap: () {
  SoundService.instance.play(SoundEvent.tap, soundEnabled: prefs.soundEnabled);
  // ... existing logic
}
```

**Every `Navigator.push` call:**
```dart
SoundService.instance.play(SoundEvent.pageTransition, soundEnabled: prefs.soundEnabled);
Navigator.push(...);
```

**Every `Navigator.pop` call:**
```dart
SoundService.instance.play(SoundEvent.pageTransition, soundEnabled: prefs.soundEnabled);
Navigator.pop(...);
```

**Game result/win screen `initState`:**
```dart
SoundService.instance.play(SoundEvent.win, soundEnabled: prefs.soundEnabled);
```

**Skip/punishment actions:**
```dart
SoundService.instance.play(SoundEvent.wrong, soundEnabled: prefs.soundEnabled);
```

---

## PHASE 11 — XP SYSTEM + CONFETTI

### Step 1: Add `xp` to `lib/models/player.dart`
```dart
class Player {
  final String id;
  String name;
  int xp; // ADD THIS

  Player({required this.id, required this.name, this.xp = 0});

  // Update toJson and fromJson:
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'xp': xp};
  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    xp: json['xp'] ?? 0, // default 0 for existing players
  );
}
```

### Step 2: Add `addXp` to `lib/services/player_manager.dart`
```dart
void addXp(String playerId, int amount) {
  final index = _players.indexWhere((p) => p.id == playerId);
  if (index == -1) return;
  _players[index].xp += amount;
  _savePlayers();
  notifyListeners();
}
```

### Step 3: Call `addXp` at game end in each mode result screen

| Mode | XP Rule |
|---|---|
| Truth & Dare | +10 per card completed by that player; +50 for player with highest score |
| Impostor | +30 for each player who correctly voted the impostor; +50 for impostor if they survive undetected |
| Two Truths One Lie | +20 for each player who correctly identified the lie |
| All other modes | +25 for all participants; +50 for the winner |

### Step 4: Create `lib/widgets/xp_popup.dart`
```dart
class XpPopup {
  static void show(BuildContext context, int amount) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _XpPopupWidget(
        amount: amount,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
    SoundService.instance.play(SoundEvent.xpGain, soundEnabled: /* prefs */ true);
  }
}

class _XpPopupWidget extends StatefulWidget {
  final int amount;
  final VoidCallback onDone;
  const _XpPopupWidget({required this.amount, required this.onDone});

  @override
  State<_XpPopupWidget> createState() => _XpPopupWidgetState();
}

class _XpPopupWidgetState extends State<_XpPopupWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _opacityAnim = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)));
    _slideAnim = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward().then((_) => widget.onDone());
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.3,
      left: 0, right: 0,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _opacityAnim,
          child: Center(
            child: Text('+${widget.amount} XP',
                style: GoogleFonts.sora(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.gold,
                    shadows: [Shadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 20)])),
          ),
        ),
      ),
    );
  }
}
```

**Call at end of every result screen:**
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  XpPopup.show(context, xpEarned);
});
```

### Step 5: Add to `pubspec.yaml`
```yaml
dependencies:
  confetti: ^0.8.0
```
Run: `flutter pub get`

### Step 6: Add confetti to every result/win screen
```dart
// State:
late ConfettiController _confettiController;

// initState:
_confettiController = ConfettiController(duration: const Duration(seconds: 3));
WidgetsBinding.instance.addPostFrameCallback((_) {
  _confettiController.play();
  SoundService.instance.play(SoundEvent.win, soundEnabled: prefs.soundEnabled);
});

// dispose:
_confettiController.dispose();

// In build, wrap Scaffold body in Stack and add as first child:
Align(
  alignment: Alignment.topCenter,
  child: ConfettiWidget(
    confettiController: _confettiController,
    blastDirectionality: BlastDirectionality.explosive,
    colors: [AppColors.primary, AppColors.secondary, AppColors.gold, Colors.white],
    numberOfParticles: 30,
    emissionFrequency: 0.05,
    gravity: 0.2,
  ),
)
```

Apply to: Truth & Dare result, Impostor result, Two Truths result, Alibi verdict, Speed Challenge final, Act It Out final.

---

## PHASE 12 — IMPOSTOR MODE FIX

### In `lib/screens/new_modes/impostor_players_screen.dart`

1. Search the `build` method for any navigation element that calls `Navigator.push` or `Navigator.pushNamed` to the Impostor game screen.
2. There will be TWO such elements. Remove the one that is NOT at the bottom of the screen.
3. Keep ONLY the single bottom button. Make it a full-width gradient button:

```dart
Padding(
  padding: const EdgeInsets.all(24),
  child: GestureDetector(
    onTap: () {
      SoundService.instance.play(SoundEvent.tap, soundEnabled: prefs.soundEnabled);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ImpostorGameScreen(/* params */)));
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, spreadRadius: 2)],
      ),
      child: Text('Start Game', textAlign: TextAlign.center,
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    ),
  ),
)
```

---

### ✅ CHECKPOINT — Run `flutter analyze`. Fix every error before Phase 13.

---

## PHASE 13 — HOW TO PLAY BUTTON (ALL MODES)

### Step 1: Create `lib/widgets/how_to_play_sheet.dart`

```dart
class HowToPlaySheet extends StatelessWidget {
  final String mode;
  final IconData icon;
  final List<String> rules;
  const HowToPlaySheet({required this.mode, required this.icon, required this.rules, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          // Mode header
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            Text('How to Play', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
          const SizedBox(height: 8),
          Text(mode, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          // Rules
          ...rules.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 14))),
            ]),
          )),
          const SizedBox(height: 8),
          // Got it button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Got it ✓', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 2: Add to every game mode screen's AppBar

```dart
AppBar(
  actions: [
    IconButton(
      icon: const Icon(LucideIcons.info, color: Colors.white, size: 20),
      onPressed: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => HowToPlaySheet(
          mode: 'MODENAME',    // replace per screen
          icon: LucideIcons.flame, // replace per screen
          rules: _howToPlayRules, // see rules below
        ),
      ),
    ),
  ],
)
```

### Rules content per mode (define as const List<String> in each screen)

```dart
// Truth & Dare
const _rules = [
  'Spin the wheel to randomly select a player.',
  'The selected player must choose Truth or Dare.',
  'Complete the challenge honestly or bravely.',
  'Pass the phone and spin again for the next player.',
  'Player with most challenges completed wins.',
];

// Impostor
const _rules = [
  'Everyone gets a secret word — one player gets a different word.',
  'Take turns describing your word without saying it.',
  'Discuss and vote who you think the impostor is.',
  'Impostor wins by staying hidden. Group wins by finding them.',
  'Correct identification earns XP for the group.',
];

// Two Truths One Lie
const _rules = [
  'Write two true statements and one convincing lie.',
  'Other players vote which statement they think is the lie.',
  'Try to make your lie believable to fool others.',
  'Correct guessers earn +20 XP each.',
  'Hardest to detect writer wins the round.',
];

// Alibi
const _rules = [
  'A suspicious scenario is revealed to the whole group.',
  'Use the planning phase to coordinate your story.',
  'Face interrogation one by one — answer honestly... or not.',
  'After all interrogations, everyone votes: Alibi Holds or Story Breaks.',
  'Majority vote decides the verdict.',
];

// Speed Challenge
const _rules = [
  'Answer as many challenges correctly as possible.',
  'In Last Standing mode, slowest player each round is eliminated.',
  'Continue until one player remains standing.',
  'In Normal mode, highest total score wins.',
  'Speed and accuracy both count.',
];

// Act It Out
const _rules = [
  'Spin the wheel to pick which player acts first.',
  'That player acts out the challenge — no talking allowed.',
  'A 60-second timer runs while they perform.',
  'If someone laughs, they get a penalty point.',
  'Player with fewest penalty points wins.',
];

// Would You Rather
const _rules = [
  'A dilemma with two options is shown to everyone.',
  'Each player secretly picks Option A or Option B.',
  'All choices are revealed simultaneously.',
  'Discuss and debate why you chose what you chose.',
  'No wrong answers — just chaos.',
];

// Never Have I Ever
const _rules = [
  'A statement beginning with Never Have I Ever is shown.',
  'Players who HAVE done it raise their hand (or take a point).',
  'Points accumulate across all statements.',
  'Most points at the end = most chaotic player.',
  'Be honest. Or don\'t. That\'s chaos.',
];
```

---

## PHASE 14 — LEAVE GAME POPUP (ALL MODES)

### Step 1: Create `lib/core/widgets/leave_game_dialog.dart`

```dart
Future<bool?> showLeaveGameSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.logOut, color: AppColors.tertiary, size: 40),
          const SizedBox(height: 16),
          Text('Leave Game?', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Your progress will be lost.', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Quit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ],
      ),
    ),
  );
}
```

### Step 2: In EVERY game mode screen's AppBar

```dart
AppBar(
  leading: IconButton(
    icon: const Icon(LucideIcons.logOut, color: Colors.white, size: 20),
    onPressed: () async {
      final shouldLeave = await showLeaveGameSheet(context);
      if (shouldLeave == true && mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    },
  ),
  // existing actions...
)
```

**Also:** Remove any existing `PopScope` or `WillPopScope` widgets and replace with this pattern. Apply to all 8 modes: Truth & Dare, Impostor, Two Truths One Lie, Alibi, Speed Challenge, Act It Out, Would You Rather, Never Have I Ever.

---

## PHASE 15 — PLAYER SYNC ACROSS ALL MODES

### Step 1: In every game mode screen's `initState`

```dart
@override
void initState() {
  super.initState();
  final pm = context.read<PlayerManager>();
  _players = pm.players.map((p) => p.name).toList();

  // Guard: need at least 2 players
  if (_players.length < 2) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Players First', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Go to the Players tab and add at least 2 players to start a game.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to home
              },
              child: Text('Go to Players', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    });
  }
}
```

Apply to: Truth & Dare, Impostor, Two Truths One Lie, Alibi, Speed Challenge, Act It Out, Would You Rather, Never Have I Ever.

---

### ✅ CHECKPOINT — Run `flutter analyze`. Fix every error before Phase 16.

---

## PHASE 16 — MULTI-CATEGORY SELECTOR WIDGET

### Create `lib/widgets/category_selector.dart`

```dart
class CategorySelector extends StatefulWidget {
  final List<String> categories;
  final List<String> initialSelected;
  final ValueChanged<List<String>> onChanged;

  const CategorySelector({
    required this.categories,
    required this.initialSelected,
    required this.onChanged,
    super.key,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
  }

  void _toggle(String cat) {
    setState(() {
      if (_selected.contains(cat)) {
        if (_selected.length > 1) _selected.remove(cat);
        else ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least 1 category'), duration: Duration(seconds: 1)),
        );
      } else {
        _selected.add(cat);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_selected.length} selected', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            Row(children: [
              TextButton(onPressed: () { setState(() => _selected = List.from(widget.categories)); widget.onChanged(_selected); }, child: const Text('All')),
              TextButton(onPressed: () { setState(() => _selected = [widget.categories.first]); widget.onChanged(_selected); }, child: const Text('Clear')),
            ]),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.5,
          ),
          itemCount: widget.categories.length,
          itemBuilder: (context, index) {
            final cat = widget.categories[index];
            final isSelected = _selected.contains(cat);
            return GestureDetector(
              onTap: () => _toggle(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.white24, width: isSelected ? 2 : 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    if (isSelected) Icon(LucideIcons.checkCircle, color: AppColors.primary, size: 16)
                    else Icon(LucideIcons.circle, color: Colors.white30, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
```

**Replace category picker in:** Impostor, Alibi, Act It Out, Would You Rather, Never Have I Ever, Truth & Dare pack selection.

---

## PHASE 17 — ACT IT OUT FULL REWRITE

Completely replace `lib/screens/new_modes/act_it_out_screen.dart` with a 6-step `StatefulWidget` using a `_step` integer (1–6):

```dart
class ActItOutScreen extends StatefulWidget {
  const ActItOutScreen({super.key});
  @override
  State<ActItOutScreen> createState() => _ActItOutScreenState();
}

class _ActItOutScreenState extends State<ActItOutScreen> {
  int _step = 1;
  List<String> _selectedCategories = [];
  List<String> _selectedPlayers = [];
  String _currentPlayer = '';
  String _currentChallenge = '';
  Map<String, int> _penalties = {}; // player name → penalty count
  int _roundsPlayed = 0;
  final int _totalRounds = 3; // 3 turns each

  static const _categories = [
    'Animals', 'Movies', 'Songs', 'Sports', 'Jobs',
    'Famous People', 'Food', 'Emotions', 'TV Shows', 'Actions'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        const MeshGradientBackground(),
        SafeArea(child: _buildStep()),
      ]),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1: return _buildCategorySelection();
      case 2: return _buildPlayerSelection();
      case 3: return _buildSpinWheel();
      case 4: return _buildChallenge();
      case 5: return _buildWhoLaughed();
      case 6: return _buildResults();
      default: return const SizedBox.shrink();
    }
  }
```

**Step 1 — Category Selection:**
```dart
Widget _buildCategorySelection() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Act It Out', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Pick categories to act from', style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 24),
        Expanded(
          child: CategorySelector(
            categories: _categories,
            initialSelected: _selectedCategories.isEmpty ? [_categories.first] : _selectedCategories,
            onChanged: (cats) => setState(() => _selectedCategories = cats),
          ),
        ),
        GestureDetector(
          onTap: _selectedCategories.isNotEmpty ? () => setState(() => _step = 2) : null,
          child: Container(/* gradient Next button, greyed if empty */),
        ),
      ],
    ),
  );
}
```

**Step 2 — Player Selection:**
```dart
Widget _buildPlayerSelection() {
  final pm = context.read<PlayerManager>();
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Row(children: [
          IconButton(icon: Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => setState(() => _step = 1)),
          Text('Select Players', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        Text('${_selectedPlayers.length}/10 selected', style: TextStyle(color: AppColors.primary)),
        Expanded(
          child: ListView.builder(
            itemCount: pm.players.length,
            itemBuilder: (context, i) {
              final p = pm.players[i];
              final selected = _selectedPlayers.contains(p.name);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) _selectedPlayers.remove(p.name);
                    else if (_selectedPlayers.length < 10) _selectedPlayers.add(p.name);
                  });
                },
                child: GlassCard(/* avatar + name + checkmark if selected */),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: _selectedPlayers.length >= 2 ? () {
            _penalties = {for (var p in _selectedPlayers) p: 0};
            setState(() => _step = 3);
          } : null,
          child: Container(/* Start button */),
        ),
      ],
    ),
  );
}
```

**Step 3 — Spin Wheel:** Use existing `PhysicsWheel` with `_selectedPlayers` as segments. On `_onSpinComplete(playerName)`:
```dart
_currentPlayer = playerName;
_currentChallenge = _getChallengeFromCategories(_selectedCategories);
setState(() => _step = 4);
```

**Step 4 — Challenge Screen:**
```dart
Widget _buildChallenge() {
  return Column(children: [
    // AppBar with leave button
    Padding(padding: const EdgeInsets.all(20), child:
      Text(_currentPlayer, style: GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
          shadows: [Shadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 20)])),
    ),
    GlassCard(
      margin: const EdgeInsets.all(20),
      child: Text(_currentChallenge, textAlign: TextAlign.center,
          style: GoogleFonts.sora(fontSize: 18, color: Colors.white)),
    ),
    // 60-second countdown timer
    _CountdownTimer(
      seconds: 60,
      onTick: (remaining) {
        if (remaining <= 10) SoundService.instance.play(SoundEvent.timerTick, soundEnabled: true);
      },
      onEnd: () => SoundService.instance.play(SoundEvent.timerEnd, soundEnabled: true),
    ),
    // Buttons
    Row(children: [
      Expanded(child: GestureDetector(
        onTap: () => setState(() => _step = 5), // someone laughed
        child: Container(/* gradient pink/red "😂 Someone Laughed" button */),
      )),
      const SizedBox(width: 12),
      Expanded(child: GestureDetector(
        onTap: () {
          // same player, new challenge, reset timer
          _currentChallenge = _getChallengeFromCategories(_selectedCategories);
          setState(() {}); // rebuild with new challenge (timer widget key changes)
        },
        child: Container(/* outlined "😐 No One Laughed" button */),
      )),
    ]),
  ]);
}
```

**Step 5 — Who Laughed?**
```dart
Widget _buildWhoLaughed() {
  String? _selectedLaugher;
  return StatefulBuilder(builder: (context, innerSet) => Column(children: [
    Text('Who Laughed? 😂', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
    // Show all players EXCEPT _currentPlayer
    ...(_selectedPlayers.where((p) => p != _currentPlayer).map((p) => GestureDetector(
      onTap: () => innerSet(() => _selectedLaugher = p),
      child: GlassCard(/* player card, highlighted if _selectedLaugher == p */),
    ))),
    GestureDetector(
      onTap: _selectedLaugher != null ? () {
        _penalties[_selectedLaugher!] = (_penalties[_selectedLaugher!] ?? 0) + 1;
        _roundsPlayed++;
        if (_roundsPlayed >= _selectedPlayers.length * _totalRounds) {
          setState(() => _step = 6);
        } else {
          setState(() => _step = 3); // back to spin wheel
        }
      } : null,
      child: Container(/* Confirm button */),
    ),
  ]));
}
```

**Step 6 — Final Results:**
```dart
Widget _buildResults() {
  final sorted = _penalties.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
  final winner = sorted.first.key;
  // award XP
  final pm = context.read<PlayerManager>();
  for (final entry in _penalties.entries) {
    final player = pm.players.firstWhere((p) => p.name == entry.key, orElse: () => throw '');
    pm.addXp(player.id, entry.key == winner ? 75 : 25);
  }
  return Stack(children: [
    // Confetti
    Align(alignment: Alignment.topCenter, child: ConfettiWidget(/* colors, 30 particles */)),
    Column(children: [
      Text('$winner wins! 🎉', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      ...sorted.map((e) => ListTile(
        title: Text(e.key, style: TextStyle(color: Colors.white)),
        trailing: Text('${e.value} penalties', style: TextStyle(color: e.value == 0 ? AppColors.gold : Colors.white54)),
      )),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => setState(() { _step = 1; _penalties = {}; _roundsPlayed = 0; }), child: const Text('Play Again'))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('Home'))),
      ]),
    ]),
  ]);
}
```

---

## PHASE 18 — SPEED CHALLENGE + LAST STANDING MERGE

### In `lib/screens/new_modes/speed_challenge_screen.dart`

**Step 1: Add mode toggle state**
```dart
bool _isLastStanding = false;
List<String> _eliminatedPlayers = [];
```

**Step 2: Add segmented control to setup screen**
```dart
Container(
  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(32)),
  child: Row(children: [
    _ModeToggleButton(label: 'Normal Mode', active: !_isLastStanding, onTap: () => setState(() => _isLastStanding = false)),
    _ModeToggleButton(label: 'Last Standing', active: _isLastStanding, onTap: () => setState(() => _isLastStanding = true)),
  ]),
)
```

**Step 3: Last Standing round-end logic** — after each round:
```dart
void _onRoundEnd() {
  if (!_isLastStanding) {
    _proceedToNextRound(); // normal mode unchanged
    return;
  }

  // Find player with fewest correct in this round
  final activePlayers = _players.where((p) => !_eliminatedPlayers.contains(p)).toList();
  final loser = activePlayers.reduce((a, b) => _roundScores[a]! <= _roundScores[b]! ? a : b);

  setState(() => _eliminatedPlayers.add(loser));

  // Show elimination card
  showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
    backgroundColor: Colors.red.shade900,
    title: Text('ELIMINATED 💀', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.bold)),
    content: Text('$loser is out!', style: TextStyle(color: Colors.white70)),
    actions: [TextButton(onPressed: () {
      Navigator.pop(context);
      SoundService.instance.play(SoundEvent.wrong, soundEnabled: prefs.soundEnabled);
      if (activePlayers.length - 1 <= 1) {
        _showLastStandingWinner(activePlayers.where((p) => p != loser).first);
      } else {
        _proceedToNextRound();
      }
    }, child: const Text('Continue', style: TextStyle(color: Colors.white)))],
  ));
}

void _showLastStandingWinner(String winner) {
  // Full-screen win card with confetti and XP
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpeedChallengeResultScreen(winner: winner, mode: 'Last Standing')));
}
```

---

### ✅ CHECKPOINT — Run `flutter analyze`. Fix every error before Phase 19.

---

## PHASE 19 — ALIBI MODE PROFESSIONAL REDESIGN

Completely replace `lib/screens/new_modes/alibi_screen.dart` with a 6-step `StatefulWidget`:

**State:**
```dart
int _step = 1;
List<String> _selectedPlayers = [];
List<String> _selectedCategories = [];
String _scenario = '';
int _currentPlayerIndex = 0;
Map<String, bool> _votes = {}; // player → true = holds, false = breaks
List<String> _questions = [];
int _currentQuestionIndex = 0;
```

**Step 1 — Setup:**
```dart
Widget _buildSetup() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      Text('Alibi', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 24),
      // Player multi-select (3–8 players)
      Consumer<PlayerManager>(builder: (context, pm, _) {
        return Column(children: pm.players.map((p) => GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedPlayers.contains(p.name)) { if (_selectedPlayers.length > 3) _selectedPlayers.remove(p.name); }
              else if (_selectedPlayers.length < 8) _selectedPlayers.add(p.name);
            });
          },
          child: GlassCard(/* player card with checkmark */),
        )).toList());
      }),
      const SizedBox(height: 24),
      // Category selection (2–3)
      CategorySelector(categories: _alibiCategories, initialSelected: [], onChanged: (cats) => setState(() => _selectedCategories = cats)),
      GestureDetector(
        onTap: (_selectedPlayers.length >= 3 && _selectedCategories.isNotEmpty) ? () {
          _scenario = _generateScenario(_selectedCategories);
          setState(() => _step = 2);
        } : null,
        child: Container(/* Begin button */),
      ),
    ]),
  );
}
```

**Step 2 — Scene Reveal:**
```dart
Widget _buildSceneReveal() {
  bool _buttonEnabled = false;
  return StatefulBuilder(builder: (context, innerSet) {
    Future.delayed(const Duration(seconds: 3), () { if (mounted) innerSet(() => _buttonEnabled = true); });
    return Stack(children: [
      // Atmospheric gradient by category
      Container(decoration: BoxDecoration(gradient: _categoryGradient(_selectedCategories.first))),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Category badge
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text(_selectedCategories.join(', '), style: TextStyle(color: Colors.white))),
        const SizedBox(height: 32),
        // Scenario text
        Text(_scenario, textAlign: TextAlign.center, style: GoogleFonts.sora(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 48),
        // We're Ready button — disabled for 3s
        AnimatedOpacity(
          opacity: _buttonEnabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: _buttonEnabled ? () => setState(() => _step = 3) : null,
            child: Container(/* "We're Ready" gradient button */),
          ),
        ),
      ]),
    ]);
  });
}
```

**Step 3 — Planning Phase:**
```dart
Widget _buildPlanning() {
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('Plan Your Story', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
    Text('Coordinate your alibis. Get your story straight.', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 40),
    // 60 second countdown — auto-advances when done
    _CountdownTimer(
      seconds: 60,
      onEnd: () => setState(() => _step = 4),
      onTick: (r) => SoundService.instance.play(SoundEvent.timerTick, soundEnabled: true),
    ),
  ]);
}
```

**Step 4 — Interrogation Phase:**
```dart
Widget _buildInterrogation() {
  final player = _selectedPlayers[_currentPlayerIndex];
  if (_currentQuestionIndex == 0) {
    // Show pass screen first
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Pass phone to', style: TextStyle(color: Colors.white54)),
      Text(player, style: GoogleFonts.sora(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
      const Icon(LucideIcons.arrowRight, color: Colors.white, size: 40),
      GestureDetector(onTap: () { _questions = _generateQuestions(player); setState(() => _currentQuestionIndex = 1); }, child: Container(/* Ready button */)),
    ]);
  }

  final question = _questions[_currentQuestionIndex - 1];
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('$player is in the hot seat 🔥', style: TextStyle(color: Colors.white70)),
    GlassCard(
      margin: const EdgeInsets.all(24),
      child: Text(question, textAlign: TextAlign.center, style: GoogleFonts.sora(fontSize: 18, color: Colors.white)),
    ),
    Text('Question $_currentQuestionIndex of 3', style: TextStyle(color: Colors.white54)),
    GestureDetector(onTap: () {
      if (_currentQuestionIndex < 3) {
        setState(() => _currentQuestionIndex++);
      } else {
        // Move to next player or verdict
        setState(() {
          _currentQuestionIndex = 0;
          _currentPlayerIndex++;
          if (_currentPlayerIndex >= _selectedPlayers.length) _step = 5;
        });
      }
    }, child: Container(/* Next Question button */)),
  ]);
}
```

**Step 5 — Verdict Phase:**
```dart
Widget _buildVerdict() {
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('Vote', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
    Text('Does the alibi hold?', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 32),
    // Show which player is voting currently (sequential voting by passing phone)
    ..._selectedPlayers.where((p) => !_votes.containsKey(p)).take(1).map((p) => Column(children: [
      Text('$p, cast your vote:', style: TextStyle(color: Colors.white)),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(onTap: () { setState(() => _votes[p] = true); if (_votes.length == _selectedPlayers.length) setState(() => _step = 6); }, child: Container(/* "Alibi Holds 🤝" large green button */)),
        const SizedBox(width: 20),
        GestureDetector(onTap: () { setState(() => _votes[p] = false); if (_votes.length == _selectedPlayers.length) setState(() => _step = 6); }, child: Container(/* "Story Breaks 💥" large red button */)),
      ]),
    ])),
    if (_votes.isNotEmpty)
      Text('${_votes.length}/${_selectedPlayers.length} voted', style: TextStyle(color: Colors.white54)),
  ]);
}
```

**Step 6 — Results:**
```dart
Widget _buildResults() {
  final holdsCount = _votes.values.where((v) => v).length;
  final breaksCount = _votes.values.where((v) => !v).length;
  final alibiHolds = holdsCount >= breaksCount;
  return Stack(children: [
    if (alibiHolds) Align(alignment: Alignment.topCenter, child: ConfettiWidget(/* colors */)),
    if (!alibiHolds) Container(color: Colors.red.withOpacity(0.15)), // red flash overlay
    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(alibiHolds ? 'ALIBI HOLDS! 🤝' : 'STORY BREAKS! 💥',
          style: GoogleFonts.sora(fontSize: 30, fontWeight: FontWeight.bold, color: alibiHolds ? Colors.green : Colors.red)),
      const SizedBox(height: 24),
      // Vote breakdown
      ..._votes.entries.map((e) => ListTile(
        title: Text(e.key, style: TextStyle(color: Colors.white)),
        trailing: Text(e.value ? '🤝 Holds' : '💥 Breaks', style: TextStyle(color: e.value ? Colors.green : Colors.red)),
      )),
      const SizedBox(height: 32),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => setState(() { _step = 1; _votes = {}; _currentPlayerIndex = 0; }), child: const Text('Play Again'))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('Home'))),
      ]),
    ]),
  ]);
}
```

---

## PHASE 20 — TWO TRUTHS ONE LIE PROFESSIONAL REDESIGN

Completely replace `lib/screens/new_modes/two_truths_one_lie_screen.dart` with a multi-phase `StatefulWidget`:

**State:**
```dart
int _phase = 1; // 1=writing, 2=shuffle+pass, 3=reveal+voting, 4=results
final _truth1Controller = TextEditingController();
final _truth2Controller = TextEditingController();
final _lieController = TextEditingController();
List<Map<String, dynamic>> _shuffledStatements = []; // {text, isLie}
Map<String, int> _votes = {}; // voterName → statementIndex they picked
String _currentVoter = '';
int _currentVoterIndex = 0;
List<String> _otherPlayers = []; // everyone except the writer
```

**Phase 1 — Writing:**
```dart
Widget _buildWritingPhase() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      Text('Write your statements', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 24),
      // Staggered animated cards
      AnimatedCard(delay: 0, accentColor: Colors.green, label: 'Truth 1 ✅', controller: _truth1Controller),
      AnimatedCard(delay: 150, accentColor: Colors.green, label: 'Truth 2 ✅', controller: _truth2Controller),
      AnimatedCard(delay: 300, accentColor: Colors.red, label: 'Lie 🔴', controller: _lieController, trailing: Icon(LucideIcons.lock, color: Colors.red)),
      const Spacer(),
      ValueListenableBuilder(
        valueListenable: Listenable.merge([_truth1Controller, _truth2Controller, _lieController]),
        builder: (_, __, ___) {
          final allFilled = _truth1Controller.text.isNotEmpty && _truth2Controller.text.isNotEmpty && _lieController.text.isNotEmpty;
          return GestureDetector(
            onTap: allFilled ? () {
              _shuffledStatements = [
                {'text': _truth1Controller.text, 'isLie': false},
                {'text': _truth2Controller.text, 'isLie': false},
                {'text': _lieController.text, 'isLie': true},
              ]..shuffle();
              setState(() => _phase = 2);
            } : null,
            child: Container(/* Lock In button, greyed when not allFilled */),
          );
        },
      ),
    ]),
  );
}
```

**Phase 2 — Shuffle & Pass:**
```dart
Widget _buildShufflePass() {
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    // Animated shuffle visual — show 3 cards shuffling
    TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (_, v, __) => /* shuffle animation */,
    ),
    const SizedBox(height: 32),
    Text('Pass to the other players', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    Text('Don\'t show them the screen yet!', style: TextStyle(color: Colors.white54)),
    const SizedBox(height: 32),
    GestureDetector(
      onTap: () {
        _currentVoterIndex = 0;
        _currentVoter = _otherPlayers[0];
        setState(() => _phase = 3);
      },
      child: Container(/* Ready to Vote button */),
    ),
  ]);
}
```

**Phase 3 — Reveal + Voting (per voter):**
```dart
Widget _buildVoting() {
  return Column(children: [
    Text('$_currentVoter, which is the lie?', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    const SizedBox(height: 24),
    // 3 statement cards stagger in
    ..._shuffledStatements.asMap().entries.map((e) {
      final index = e.key;
      final stmt = e.value;
      final isVoted = _votes[_currentVoter] == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12, top: index * 200.0 /* stagger via FutureBuilder */),
        child: GestureDetector(
          onTap: () => setState(() => _votes[_currentVoter] = index),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            border: isVoted ? Border.all(color: AppColors.primary, width: 2) : null,
            child: Column(children: [
              Text(stmt['text'], style: TextStyle(color: Colors.white, fontSize: 16)),
              // Show voter avatars stacked on this card
              if (isVoted) Text(_currentVoter, style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ]),
          ),
        ),
      );
    }),
    const Spacer(),
    // Confirm vote and advance to next voter
    GestureDetector(
      onTap: _votes.containsKey(_currentVoter) ? () {
        setState(() {
          _currentVoterIndex++;
          if (_currentVoterIndex >= _otherPlayers.length) {
            _phase = 4; // all voted → reveal
          } else {
            _currentVoter = _otherPlayers[_currentVoterIndex];
          }
        });
      } : null,
      child: Container(/* Confirm Vote button */),
    ),
  ]);
}
```

**Phase 4 — Reveal Animation + Results:**
```dart
Widget _buildReveal() {
  // Find lie index
  final lieIndex = _shuffledStatements.indexWhere((s) => s['isLie'] == true);
  // Count correct guessers
  final correct = _votes.entries.where((e) => e.value == lieIndex).map((e) => e.key).toList();
  final wrong = _votes.entries.where((e) => e.value != lieIndex).map((e) => e.key).toList();

  return Column(children: [
    // XP awards
    // ... award +20 XP per correct guesser
    // Confetti if majority guessed wrong (writer wins)

    Stack(children: [
      if (wrong.length > correct.length)
        Align(alignment: Alignment.topCenter, child: ConfettiWidget(/* */)),

      Column(children: [
        Text('REVEAL!', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        // 3 cards — lie card flips red, truth cards flip green
        ..._shuffledStatements.asMap().entries.map((e) {
          final isLie = e.value['isLie'] == true;
          return _FlipRevealCard(
            text: e.value['text'],
            isLie: isLie,
            delay: Duration(milliseconds: e.key * 400),
          );
        }),
        const SizedBox(height: 24),
        // Who got it right
        ...correct.map((p) => Text('$p guessed right! +20 XP ✅', style: TextStyle(color: Colors.green))),
        ...wrong.map((p) => Text('$p was fooled 😈', style: TextStyle(color: Colors.red.shade300))),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => setState(() { _phase = 1; _votes = {}; }), child: const Text('Play Again'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('Home'))),
        ]),
      ]),
    ]),
  ]);
}
```

**`_FlipRevealCard` widget:**
```dart
class _FlipRevealCard extends StatefulWidget {
  final String text;
  final bool isLie;
  final Duration delay;
  // ...
}
class _FlipRevealCardState extends State<_FlipRevealCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final showFront = _ctrl.value < 0.5;
        final angle = _ctrl.value * pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
          child: showFront
              ? Container(/* grey card front — statement text */)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: Container(
                    color: widget.isLie ? Colors.red.shade800 : Colors.green.shade800,
                    child: Text(widget.isLie ? 'THIS WAS THE LIE 🔴' : 'TRUTH ✅', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
        );
      },
    );
  }
}
```

---

## PHASE 21 — TRUTH & DARE CONTENT QUALITY

### In `lib/core/constants/pack_data.dart` and all pack files:

**Task 1: Audit & re-categorize**
- Read every question in every category
- If a question clearly belongs in a different category (e.g. a dare listed under truths), move it to the correct one

**Task 2: Migrate Hot Seat dares**
- Find all dare questions from the now-deleted Hot Seat mode (may be hardcoded inline or in a separate map)
- Distribute them into: `Physical`, `Social`, `Creative`, or `Funny` dare categories
- Remove the original `hotSeat` key from the data map entirely

**Task 3: Generate additional questions to hit 200 per category**
Using the existing `ApiService`:
```dart
// For each category that has < 200 questions:
final response = await ApiService.prompt(
  'Generate ${200 - currentCount} unique dare questions for the category: $categoryName. '
  'Format as a JSON array of strings. No repeats. No numbering. Just the array.'
);
final List<String> newQuestions = List<String>.from(jsonDecode(response));
existingCategory.addAll(newQuestions);
```

**Task 4: Deduplicate**
```dart
// For every pair of categories, check intersection
for (int i = 0; i < categories.length; i++) {
  for (int j = i + 1; j < categories.length; j++) {
    final dups = categories[i].toSet().intersection(categories[j].toSet());
    categories[j].removeWhere((q) => dups.contains(q)); // remove from second category
  }
}
```

---

## PHASE 22 — FINAL POLISH

### Step 1: Session saving in every game result screen's `initState`

```dart
@override
void initState() {
  super.initState();
  // Save session
  SessionService.saveSession(SessionRecord(
    mode: 'MODENAME', // e.g. 'Truth & Dare', 'Impostor', etc.
    players: _players,
    winner: _winner,
    playedAt: DateTime.now(),
  ));
  // Confetti
  _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _confettiController.play();
    SoundService.instance.play(SoundEvent.win, soundEnabled: prefs.soundEnabled);
    XpPopup.show(context, _xpEarned);
  });
}
```

Apply to all 8 modes.

### Step 2: Transition sounds on every navigation

Wrap a helper:
```dart
void navigateTo(BuildContext context, Widget screen) {
  SoundService.instance.play(SoundEvent.pageTransition, soundEnabled: prefs.soundEnabled);
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

void navigateBack(BuildContext context) {
  SoundService.instance.play(SoundEvent.pageTransition, soundEnabled: prefs.soundEnabled);
  Navigator.pop(context);
}
```

Replace all `Navigator.push` and `Navigator.pop` calls with these helpers.

### Step 3: Final `flutter analyze`
Run `flutter analyze`. Fix every warning and every error. Zero issues target.

### Step 4: Test checklist verification

Verify each item is working:
```
[ ] Onboarding shows on first launch, never again after
[ ] Home loads without blank screen
[ ] All 8 mode cards navigate correctly
[ ] Spin wheel always spins 4+ rotations with decelerating tick sounds
[ ] Card tap-to-flip works, NEXT button appears after reveal
[ ] Left swipe on revealed card advances to next
[ ] Leave button in every mode shows quit/cancel sheet
[ ] How to Play ⓘ button works in every mode
[ ] Players tab shows all players with XP
[ ] Confetti plays on all result screens
[ ] XP popup animates on result screens
[ ] No timers visible in Truth & Dare cards
[ ] Sounds play on tap, flip, spin, land, win
[ ] App stays dark regardless of system theme
```

---

## EXECUTION ORDER (STRICT — DO NOT DEVIATE)

| # | Phase | Action |
|---|---|---|
| 1 | Phase 1 | Delete 13 screens + clean all references |
| 2 | Phase 2 | 3-tab nav + new PlayersScreen |
| 3 | Phase 3 | Lucide icons global replacement |
| ✅ | — | `flutter analyze` — fix ALL |
| 4 | Phase 4 | Onboarding 3-page flow |
| 5 | Phase 5 | Home cleanup + Last Played card + 8-mode grid |
| 6 | Phase 6 | Settings redesign + dark mode lock |
| ✅ | — | `flutter analyze` — fix ALL |
| 7 | Phase 7 | Remove timers from Truth & Dare |
| 8 | Phase 8 | Tap-to-flip card + NEXT button + swipe |
| 9 | Phase 9 | Spin wheel fixed profile + tick sounds + SPIN button |
| ✅ | — | `flutter analyze` — fix ALL |
| 10 | Phase 10 | Sound events enum + wire globally |
| 11 | Phase 11 | XP model + addXp + XpPopup + confetti package |
| 12 | Phase 12 | Impostor duplicate button removal |
| ✅ | — | `flutter analyze` — fix ALL |
| 13 | Phase 13 | HowToPlaySheet + ⓘ button all 8 modes |
| 14 | Phase 14 | LeaveGameSheet + LogOut button all 8 modes |
| 15 | Phase 15 | PlayerManager sync + 2-player guard all modes |
| ✅ | — | `flutter analyze` — fix ALL |
| 16 | Phase 16 | CategorySelector widget + integrate all modes |
| 17 | Phase 17 | Act It Out 6-step full rewrite |
| 18 | Phase 18 | Speed Challenge + Last Standing toggle |
| ✅ | — | `flutter analyze` — fix ALL |
| 19 | Phase 19 | Alibi 6-step professional redesign |
| 20 | Phase 20 | Two Truths One Lie full redesign + flip cards |
| 21 | Phase 21 | Content audit + deduplicate + generate to 200 |
| 22 | Phase 22 | Session saving + transition sounds + final analyze |
| ✅ | — | `flutter analyze` — FINAL zero-error pass |

---

*Cousin Chaos Flutter App — Full Overhaul v2.0 — AI Implementation Guide*
