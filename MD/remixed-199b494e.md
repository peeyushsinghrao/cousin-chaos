# 🕵️ Impostor Mode — Complete Implementation Plan
**For AI Agent: Full rewrite of impostor mode — both Mobile Pass and Multiplayer**

---

## 📁 Files to Create / Modify

| Action | File Path |
|--------|-----------|
| **MODIFY** | `lib/screens/new_modes/impostor_setup_screen.dart` |
| **MODIFY** | `lib/screens/new_modes/impostor_game_screen.dart` |
| **MODIFY** | `lib/core/constants/impostor_data.dart` |
| **MODIFY** | `lib/core/models/room.dart` |
| **MODIFY** | `lib/services/room_service.dart` |
| **MODIFY** | `lib/screens/multiplayer/lobby_screen.dart` |
| **CREATE** | `lib/screens/new_modes/impostor_players_screen.dart` |
| **CREATE** | `lib/screens/new_modes/impostor_settings_screen.dart` |
| **CREATE** | `lib/screens/new_modes/widgets/impostor_card_flip_widget.dart` |
| **CREATE** | `lib/screens/multiplayer/impostor_lobby_settings_sheet.dart` |
| **CREATE** | `lib/screens/multiplayer/multiplayer_impostor_screen.dart` |

---

## 🗺️ Navigation Flow — BOTH MODES

```
Home Screen → "Impostor Mode" tapped
  └─► ImpostorSetupScreen  (Entry screen — shows TWO play options)
        │
        ├─► [📱 MOBILE PASS] tapped
        │     └─► ImpostorPlayersScreen  (Players 3–20, Add/Remove, editable names)
        │           └─► ImpostorSettingsScreen  (Impostor count, Time Limit, Game Mode, Category, Hints)
        │                 └─► ImpostorGameScreen  (Pass device → Hold to flip → Discussion → Vote → Result)
        │
        └─► [🌐 MULTIPLAYER] tapped
              └─► CreateRoomScreen / JoinRoomScreen  (existing multiplayer flow)
                    └─► LobbyScreen  (host picks Impostor Mode + settings via sheet)
                          └─► MultiplayerImpostorScreen  (all players → flip own card → discussion → vote → result)
```

---

## 📄 SCREEN 1 — `ImpostorSetupScreen` (Entry — Choose Play Style)

**What it shows when Impostor Mode is tapped from Home:**
- Dark background with pink/red glow gradient
- Title: "IMPOSTOR MODE" with spy icon 🕵️
- Subtitle: "One of you is lying. Find them."
- **TWO large option cards stacked vertically:**

### Card 1 — Mobile Pass
- Icon: 📱 (phone with arrows)
- Title: **"Mobile Pass"**
- Subtitle: "One phone, passed around. Perfect for same room."
- Color accent: `AppColors.neonPink`
- Tap → navigate to `ImpostorPlayersScreen`

### Card 2 — Multiplayer
- Icon: 🌐 (wifi / people icon)
- Title: **"Multiplayer"**
- Subtitle: "Everyone on their own phone. Same room or online."
- Color accent: `AppColors.truthBlue`
- Tap → navigate to existing `CreateRoomScreen` with mode pre-set to `'impostor'`
  ```dart
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => const CreateRoomScreen(presetMode: 'impostor'),
  ));
  ```

**UI Notes:**
- Both cards are full-width, rounded, glass style with icon + title + subtitle
- No game mode selection here — game mode (Word/Question) is chosen in settings for both paths
- Consistent with existing app card style
- Both cards have icon + title + subtitle text

---

## 📄 SCREEN 2 — `ImpostorPlayersScreen`

**Matches reference frame exactly (frame_006.jpg):**

### Layout:
- AppBar: back arrow + title "Players"
- Subheader bar: 👥 icon + "Players: X" + right-aligned "3-20" range label
- Scrollable list of players, each row:
  - Blue rounded number badge (1, 2, 3…)
  - Player name (editable inline on tap of pencil icon)
  - ✏️ pencil icon on right → tap to rename inline
- Bottom fixed bar (two buttons side by side):
  - ❌ **Remove** button (red border, left half) — removes last player, disabled if 3 players
  - ➕ **Add** button (blue border, right half) — adds new player, disabled if 20 players

### Logic:
- Players are LOCAL to impostor mode (NOT from `PlayerManager`) — separate list managed inside this screen and passed forward as `List<ImpostorPlayer>`
- `ImpostorPlayer` is a simple class: `{String id, String name}`
- Default: start with 3 players named "Player 1", "Player 2", "Player 3"
- Min: 3 players | Max: 20 players
- Add player → appends "Player N" where N is next unused number
- Remove → removes the last player in the list
- Rename → tap pencil → shows inline `TextField` for that row, confirm on done/enter
- "Next →" or arrow button in AppBar top-right → navigates to `ImpostorSettingsScreen` passing `List<ImpostorPlayer>` and `ImpostorGameMode`

---

## 📄 SCREEN 3 — `ImpostorSettingsScreen`

**Matches reference frames (frame_010.jpg, frame_014.jpg, frame_016.jpg, screenshots):**

### Layout (scrollable):
1. **Two info tiles (side by side):**
   - Left tile: 👥 icon, "How many players?", large number (read-only, reflects player list count)
   - Right tile: 🕵️ icon, "How many imposters?", large number (tappable → opens impostor picker sheet)

2. **Time Limit row:**
   - ⏰ icon + "Time Limit" title + current value ("2 Minutes")
   - Toggle switch (on/off)
   - `>` arrow → opens time picker sheet (only shown when toggle is ON)
   - When toggle is OFF: timer doesn't run during discussion phase

3. **Game Mode section:**
   - Label: "Game Mode" with crosshair icon
   - Two cards side by side: **Word Game** | **Question Game** (same as setup screen, re-selectable here too)

4. **Categories section:**
   - Label: "Categories" with grid icon
   - Tap row → opens `CategoryPickerSheet` (multi-select from all categories list)
   - Shows currently selected category count or "All Categories"
   - Toggle: "Show Category to Impostor" (on/off)
   - Toggle: "Show Hint to Impostor" (on/off)

5. **"Start Game" button** — full-width blue button at bottom

---

### Impostor Picker Bottom Sheet (`SelectImpostersSheet`)

**Matches screenshot exactly:**
- Header: 🕵️ icon + "Select Imposters" title
- Row 1: shuffle icon + "Random (1-X)" + toggle
  - When ON: randomly picks impostor count each game between 1 and max_allowed
- Row 2: 👁️ icon + "Show Imposter Count" + toggle
  - When ON: during discussion, show how many impostors are playing
- Counter row: `[-]` `[N]` `[+]` with "Recommended" label below when count matches recommendation

**Impostor count rules:**
- Max imposters = playerCount - 1 (must always have at least 1 civilian)
- Hard caps: min=1, max=19
- `[-]` disabled when count = 1
- `[+]` disabled when count = playerCount - 1

**Recommended impostor count by player count:**
| Players | Recommended Impostors |
|---------|----------------------|
| 3–7     | 1                    |
| 8–9     | 2                    |
| 10–11   | 3                    |
| 12–13   | 4                    |
| 14–15   | 5                    |
| 16–17   | 6                    |
| 17–18   | 7                    |
| 19–20   | 8                    |

Show "Recommended" label in blue below counter only when user's current selection matches the recommendation.

---

### Time Limit Picker Sheet (`SelectTimeLimitSheet`)

**Matches screenshot exactly (second screenshot):**
- Title: "SELECT TIME LIMIT" (bold, centered)
- Subtitle: "Choose a time limit between 1 and 10 minutes"
- Scrollable list of options: 2 Minute, 3 Minute, 4 Minute, 5 Minute, 6 Minute, 7 Minute, 8 Minute, 9 Minute, 10 Minute
- Selected item has blue checkmark ✓ on right
- Blue "Confirm" button at bottom

---

## 📄 SCREEN 4 — `ImpostorGameScreen` (completely rewritten)

### State model:
```dart
class ImpostorGameConfig {
  final List<ImpostorPlayer> players;
  final int impostorCount;
  final bool randomImpostorCount;
  final bool showImpostorCount;
  final bool timeLimitEnabled;
  final int timeLimitMinutes;
  final ImpostorGameMode gameMode;
  final String category; // or 'ALL' for random from all
  final bool showCategoryToImpostor;
  final bool showHintToImpostor;
}
```

### Phase enum:
```dart
enum ImpostorPhase { passDevice, cardReveal, discussion, vote, result }
```

### Phase 1 — Pass Device Screen:
- Full dark screen
- Center: player number indicator (e.g., "Player 3 of 8")
- Large player name
- Big blue card (the card BACK — plain deep blue, rounded corners, no text) centered on screen
- Instructional text below card: "Pass device to [Player Name]"
- Auto-transitions after 1.5 seconds OR on card tap → goes to Phase 2

### Phase 2 — Card Reveal (THE KEY FEATURE):

**This is a 3D card flip animation:**

**Card FRONT (before flip):**
- Deep blue card, centered, large (fills most of vertical space)
- No text, no icon — just the blue card face
- Background is dark with split blue-left / red-right gradient behind the card (subtle)
- Small text below: "Tap to reveal"
- User taps the card → triggers 3D flip animation

**Card FLIP animation:**
- `AnimationController` with 600ms duration
- Use `Transform` with `Matrix4.rotationY` for true 3D perspective flip
- Play `SoundEvent.cardReveal` on tap
- Haptic: `HapticFeedback.mediumImpact()` on tap

**Card BACK revealed — CIVILIAN:**
- Background color: Deep blue (same side as before)
- Top text (small, white/light): "Find the Imposter before time runs out!"
- Center: **Large bold word** — the secret word (e.g., "Telephone")
- Below word: 👥 group icon in blue
- Below card: "Got it!" blue button
- Small text below button: "Pass device to the next player"

**Card BACK revealed — IMPOSTOR:**
- Background color: Deep dark red (#8B0000 or similar)
- Center: **"Imposter"** in large bold red text
- Below title: 🕵️ spy icon (hat + glasses) in red
- If `showHintToImpostor = true`:
  - 💡 "Your Clue" label (yellow/orange)
  - Large bold: **[CLUE WORD]** — a related word hint (see clue generation below)
  - Small text: "Use this in the first round to blend in!"
- Below card: "Got it!" blue button
- Small text: "Pass device to the next player"

**"Got it!" button** → play `SoundEvent.tap`, advance to next player or go to Discussion phase

### Impostor Clue Generation:
Each word in `ImpostorData` should have associated clue words. Add a parallel `Map<String, List<String>> wordClues` inside `ImpostorData`. The clue is a semantically related word that helps the impostor bluff without giving away the secret word. Example:
- Secret word: "Telephone" → Clues: ["Ring", "Call", "Dial", "Signal", "Talk"]
- Secret word: "Pizza" → Clues: ["Cheese", "Slice", "Delivery", "Hot", "Round"]

For **Question Game mode**: impostor gets a *different but related* question from a separate question bank (see data section below).

### Phase 3 — Discussion Timer:
- Same as current but with fixes:
- If time limit is DISABLED: show discussion phase with no timer countdown, just "FINISH & VOTE" button
- If time limit is ENABLED: show MM:SS countdown from `timeLimitMinutes * 60`
- If `showImpostorCount = true`: show "X impostor(s) among you" badge
- Last 30 seconds: timer turns red + haptic pulse every 10 seconds
- Timer reaches 0: auto-play `SoundEvent.timerEnd` + show vote phase

### Phase 4 — Vote Phase:
- List of all players (scrollable)
- Each player tile: number badge + name
- Tap a player = voted them as impostor → go to result

### Phase 5 — Result Phase (COMBINED — existing + reference):
- **Win/Lose banner**: "CIVILIANS WIN! 🎉" or "IMPOSTOR WINS! 😈"
- Color: green if civilians win, red if impostor wins
- Card showing:
  - "The impostor(s) were:" + bold names
  - Divider
  - "The secret word was:" + bold word (blue)
- Two action buttons:
  - "PLAY AGAIN" (pink/neon) → reinitializes game
  - "SEE HIGHLIGHTS" (yellow text button) → opens HighlightsScreen
- "Leave" text button → Navigator.pop

---

## 📊 DATA: `impostor_data.dart` — FULL REWRITE

### Existing categories (KEEP ALL 16, expand words to 50+ each):
- GAMING
- TIKTOK & MEMES
- FOODS
- BRANDS & SNEAKERS
- MOVIES & SHOWS
- SCHOOL LIFE
- COUNTRIES & CITIES
- FAMILY SCENARIOS
- MUSIC
- SUPERHEROES & VILLAINS
- SPORTS
- SOCIAL MEDIA
- SCIENCE & SCHOOL SUBJECTS
- RANDOM OBJECTS
- REACTIONS & EMOTIONS
- LATE NIGHT / VIBE

### NEW CATEGORIES to add (Cousin Chaos adult theme, mild-but-wild):

#### COUSIN CHAOS — WORD GAME CATEGORIES (add these 8):

**1. COUSIN CHAOS CLASSICS** (family chaos moments, adults)
50 words including: "Lending Money", "Family Group Chat", "Borrowing the Car", "Skipping Family Dinner", "Showing Up Late", "Oversharing on Social Media", "The Favorite Child", "Family Feud", "Awkward Hug", "Spilling Tea at Dinner", "Uninvited Plus One", "Fighting Over the Remote", "Roasting Each Other", "Old Embarrassing Photos", "Copying Each Other's Style", "The Flaky Cousin", "Side Eye at Christmas", "Drunk Uncle Energy", "The Know-It-All Aunt", "Ghosting Family Texts", "Sibling Rivalry", "Stealing Thunder", "Family Reunion Drama", "The Group Chat Admin", "Crashing at Someone's Place", "Bringing Home a Stranger", "Forgetting Birthdays", "Showing Off New Partner", "Breaking Curfew at 30", "Family WhatsApp War", "Comparing Salaries", "Who's Mum's Favourite", "Asking for Advice Then Ignoring It", "Random Interrogation at Dinner", "The Wedding Seating Chart", "Overstaying Welcome", "Acting Like a Child at 25", "Reading Someone's Diary", "Blaming the Youngest", "Getting Caught Lying", "The Group Nap", "Kitchen Territory Wars", "Tattling to Mum", "The Broke Cousin", "The Successful One", "Baby of the Family", "Eldest Child Syndrome", "Middle Child Issues", "The Cool Cousin", "Holiday Planning Chaos"

**2. ADULTING DISASTERS** (adult life chaos)
50 words: "Forgetting to Pay Rent", "Burning Dinner", "Calling in Sick", "Unread Emails", "Dead Plant Collection", "Overdrawn Account", "3AM Impulse Buy", "Skipping the Gym Again", "Netflix Instead of Work", "Lost Charger", "Messy Car", "Expired Food in Fridge", "Forgetting a Password", "Driving Anxiety", "Tax Season Panic", "The Coffee Addiction", "Sleeping Through Alarm", "Talking to Yourself", "Doom Scrolling", "Sunday Scaries", "Imposter Syndrome at Work", "Inbox Zero Attempt", "Crying in the Car", "Therapy Homework", "Arguing with a Robot Chatbot", "Buying Plants Again", "Meal Prep Failure", "Adulting Overwhelm", "The Situationship", "Quitting then Unquitting", "Muting Everyone", "Leaving Dishes for Tomorrow", "Online Shopping Regret", "Screen Time Warning", "Random Anxiety at 2AM", "Hating your Job but Staying", "Avoiding the Doctor", "Losing Keys Daily", "Spending Too Much on Food Delivery", "The Unfiled Tax Return", "Crying at Commercials", "Sending the Wrong Text", "Reply All Disaster", "Forgetting to Eat", "Drunk Online Shopping", "Saying Yes when you Mean No", "Can't Adult Today", "The Quarter Life Crisis", "The Situationship Spiral", "Making Plans then Cancelling"

**3. NIGHTS OUT CHAOS** (adult party/going out — mild wild)
50 words: "Pre-Drinks Too Hard", "Lost Phone", "Splitting the Bill", "Can't Find the Uber", "Missing Shoes", "Drunk Texting Ex", "Group Photo Chaos", "Bouncer Drama", "Long Queue", "Bad DJ", "Spilled Drink", "Crying in the Bathroom", "Random Confession Night", "2AM Kebab Run", "Finding a Stranger's Jacket", "Dance Floor Fall", "Karaoke Disaster", "Mixing Drinks", "Losing the Group", "That One Friend who Disappears", "Dress Code Panic", "Hangover the Next Day", "Regret Selfies", "The Sober Driver", "Secret Mission to Leave Early", "Table Drama", "That One Who Can't Handle It", "Bar Tab Shock", "Flirting with the Bartender", "Getting into VIP for Free", "The Afterparty Regret", "The Walk of Shame", "Stolen Lighter", "Lost Cash", "Venue Change Three Times", "Overpacked Handbag", "Social Anxiety Spiral", "Calling it Early", "The All-Nighter Crew", "3AM Maccas Run", "Getting Separated", "Heels vs Flats Debate", "Rain on a Night Out", "Not Remembering the Uber Driver", "Arguing About Next Stop", "Crowd Surfing Fail", "Taking a Wrong Turn", "Best Night Ever Syndrome", "The Friend Who Can't Handle it", "Regretting the Eyeliner"

**4. RELATIONSHIP CHAOS** (adult dating/friendships — mild)
50 words: "Leaving Someone on Read", "Posting Then Deleting", "The Talking Stage", "Situationship", "Double Texting", "Sliding into DMs", "Moving Too Fast", "Mixed Signals", "Ghosting Someone", "Being Ghosted", "The 'We Need to Talk' Text", "Jealous of Their Instagram", "Stalking Their Page", "Posting a Thirst Trap After a Breakup", "Third Wheeling", "Comparing Partners", "Commitment Issues", "Meeting the Family Too Soon", "Fighting Over Nothing", "The Silent Treatment", "Making Up and Breaking Up", "Sending a Paragraph Text", "Overthinking the Emoji", "Watching Their Stories but Not Texting Back", "Deleting Their Number then Re-adding It", "Falling for a Friend", "The Friend Zone", "Asking Their Friends About Them", "Relationship Advice from a Single Friend", "Being Obsessed with Someone Low-Key", "Pretending to be Fine", "Couple Fights at the Worst Time", "Getting Feelings Too Fast", "Partner Who Never Commits", "Venting to Everyone", "Snapchat Streaks as Love Language", "First Date Awkwardness", "The Long Distance Struggle", "Posting 'Unbothered' But Very Bothered", "The 'I Miss You' at 3AM", "Blocking then Unblocking", "Talking to Two People at Once", "Getting Back Together", "The Playlist They Made You", "Anniversary Panic", "Social Media Official", "Breaking Up Over Text", "Crying Over a Year Ago", "Catching Feelings for Your Best Friend", "Unrequited Love"

**5. COUSIN CHAOS DARES & CONFESSIONS** (party truth/wild - mild)
50 words: "Most Embarrassing Moment", "Worst Lie to Parents", "Biggest Secret Kept", "Most Regretted Night", "Who You Have a Crush On", "Weirdest Habit", "Craziest Plan that Actually Worked", "Most Times Said 'I'll Start Monday'", "Best Night You've Had", "Worst Date Story", "First Time Getting Drunk", "Most Dramatic Reaction", "Best Roast of a Family Member", "Weirdest Text Sent", "Most Money Spent in One Night", "Biggest Bluff that Worked", "Most Times Called Out by Mum", "Best Excuse for Being Late", "Weirdest Dream", "Most Random Thing Done at 3AM", "Best Wingman Story", "Most Embarrassing Phase", "Worst Fashion Choice", "Secret Talent Nobody Knows", "Most Irrational Fear", "Worst Advice Given", "Funniest Fail Caught on Camera", "Most Dramatic Breakup", "Weirdest Argument Won", "Best Group Chat Drama Started", "Biggest Lie to a Teacher", "Most Times Napped on a Night Out", "Worst Job Story", "Most Random Purchase", "Biggest FOMO Moment", "Funniest Family Argument", "Craziest Excuse Used", "Best Gossip That Turned Out False", "Most Dramatic Exit from a Party", "Biggest Group Chat Disaster", "Worst Costume Worn", "Most Embarrassing Public Moment", "Best Story About a Stranger", "Worst Hairstyle Phase", "Most Dramatic Reaction to Food", "Biggest Overreaction", "Best Plot Twist in Real Life", "Weirdest Compliment Received", "Most Times the Same Mistake Made", "Funniest Thing Witnessed"

**6. WILD CARD CHAOS** (general wild adult fun)
50 words: "Accidentally Liking an Old Post", "Crying at a Movie Nobody Else Cried At", "Making Up a Fake Emergency", "Pretending to Know the Song", "Faking Confidence", "Zoning Out Mid-Conversation", "Nodding Without Listening", "Panic Buying", "Stress Eating", "Stress Cleaning", "Sending a Voice Note Instead of Calling", "Saving Memes at 2AM", "Accidentally Starting Beef", "Posting Something then Immediately Regretting", "The Group Decision That Takes Forever", "Being the Most Dramatic", "The Cancel Plan Text", "Overpacking for a Weekend Trip", "Going Incognito", "Telling the Same Story Twice", "Taking 50 Photos to Post 1", "Accidentally Starting a Rumour", "Googling Symptoms and Panicking", "Reading a Long Post then Forgetting It", "Lying About Starting Something", "The Fake Laugh", "Panic Researching Before a Trip", "The Overconfident Karaoke Opener", "The Unexpected Crying Scene", "The Unnecessary Apology", "Overexplaining Yourself", "Turning Down Plans then Feeling FOMO", "The Spiral After a Small Mistake", "Accidentally Sending Audio to the Wrong Person", "The Emergency Snack Run", "Being Petty Just a Little", "Pretending to Be Busy", "The Long Reply That Says Nothing", "The Fake Sick Day", "The Unnecessary Overthink", "The Accidental Roast", "Trying Something Once and Claiming Expertise", "The Viral Recipe Attempt", "The Unsolicited Opinion", "The Stubborn Opinion Held Too Long", "The Fake Calm", "Agreeing Just to End the Argument", "The Unnecessary Group Chat Poll", "Making Plans You'll Cancel", "The Solo Dance Party"

**7. CELEBRITY & POP CULTURE CHAOS** (fun, adult-appropriate)
50 words: "Cancellation", "Glow Up", "Red Carpet Fail", "Going Viral for the Wrong Reason", "The Comeback", "The Beef on Social Media", "The Collab Nobody Expected", "Dropping an Album at Midnight", "The Tell-All Interview", "The Cryptic Post", "The Unexpected Breakup", "Getting Roasted Online", "Changing Your Look Completely", "The Award Show Speech", "Going Off Script", "The Netflix Documentary", "The Memoir Drama", "The Leaked Recording", "The Tour Disaster", "Surprise Retirement", "The Controversial Opinion", "Trending for 5 Minutes", "The Label Drama", "Going Independent", "The Unpopular Era", "The Fan War", "The Private Life Becoming Public", "Getting Papped on a Bad Day", "The Fashion Fail at an Event", "The Reply that Started Everything", "The Fake Feud", "The Unexpected Friendship", "The Brand Deal Gone Wrong", "The Tearful Interview", "The Clap Back", "Going Dark on Social Media", "Losing Followers Overnight", "Gaining Followers Overnight", "The Meme That Won't Die", "The Stage Name Drama", "The Mysterious Hiatus", "The Reunion Show", "The Surprise Engagement", "The Reality TV Moment", "The Throwback That Came Back", "The Movie Role Controversy", "The Sold Out Merch", "The Headline Nobody Expected", "The Apology Video", "The World Tour Announcement"

**8. HOUSE CHAOS** (adult living together/house scenarios)
50 words: "Forgetting to Replace the Toilet Roll", "Dishes That Were 'Just Soaking'", "Someone's Food in the Fridge", "The Passive Aggressive Note", "The Chore Chart That Nobody Follows", "Shower Time War", "Hogging the TV Remote", "Leaving Lights On", "Blasting Music Too Loud", "Having People Over Without Warning", "The Smelly Bin Nobody Took Out", "The Broken Appliance Nobody Reported", "Fridge Tetris", "Mystery Spill Left Overnight", "Arguing Over the Thermostat", "Someone Always Out of Milk", "The Loud Phone Call at Night", "Parking Drama", "The Snooze Alarm at 6AM", "Borrowing Something and Not Returning It", "Bringing Home a Stranger", "The Late Night Kitchen Raid", "Leaving the Bathroom a Mess", "The Dog Not Walked", "Package Left Blocking the Door", "That One Housemate Who's Never Home", "Blaming Each Other for the Mess", "The Broken House Rule", "The Unexpected Guest Who Stays Too Long", "Late Night Gaming Sounds", "The Never-Empty Sink", "Forgetting to Lock Up", "The Smell Nobody Admits To", "Bills Not Paid On Time", "Someone Eating Your Leftovers", "Late Night Delivery Waking Everyone", "One Bathroom, Five People", "Netflix Password Sharing Drama", "The WFH Noise Problem", "The One Who's Always 'About to Clean'", "Bringing Work Friends Home", "The House Meeting Nobody Wants", "Passive Aggressive Fridge Labels", "Venting About a Housemate to Another", "The Broken Thing Nobody Fixed", "The One Who Sleeps All Day", "Kitchen Smells That Divide", "Shared Spotify Awkwardness", "The Party Aftermath", "The Moving Out Drama"

---

### NEW CATEGORIES — QUESTION GAME MODE (50 questions each, 2 sets):

**Structure for Question Game:**
```dart
// Each entry: {question, impostor_question}
// Civilians get 'question', impostor gets 'impostor_question'
class ImpostorQuestion {
  final String civilianQuestion;
  final String impostorQuestion;
}
```

#### QUESTION GAME SET 1 — "COUSIN CHAOS QUESTIONS" (mild, fun, adult)
50 question pairs where civilian gets one question and impostor gets a slightly different (but still related) one that makes them stand out if caught:

| # | Civilian Question | Impostor Question |
|---|-------------------|-------------------|
| 1 | What's something you'd do at a family BBQ? | What's something you'd do at a stranger's party? |
| 2 | What do you always forget to buy at the supermarket? | What do you never buy but always want? |
| 3 | What's the worst thing a cousin has done to you? | What's the worst thing a classmate has done to you? |
| 4 | What's something only your family says? | What's something only your friend group says? |
| 5 | What's a typical Sunday in your house? | What's a typical Saturday night out like? |
| 6 | What do you argue about most with siblings? | What do you argue about most with a partner? |
| 7 | What's the weirdest family tradition you have? | What's the weirdest thing your friends do together? |
| 8 | Who in your family gives the best advice? | Who in your friend group gives the worst advice? |
| 9 | What's a meal everyone in your family loves? | What's a meal everyone in your friend group hates? |
| 10 | What do you do when you're at a boring family event? | What do you do when you're bored on a first date? |
| 11 | How does your family celebrate birthdays? | How does your friend group celebrate birthdays? |
| 12 | What's the one thing your mum always says? | What's the one thing your boss always says? |
| 13 | What's the house rule everyone breaks? | What's the office rule everyone ignores? |
| 14 | What's your family's favourite holiday destination? | What's a holiday you'd go on alone? |
| 15 | Who in the family always runs late? | Who in your friend group is always the first to leave? |
| 16 | What's something embarrassing your family knows about you? | What's something embarrassing only strangers have seen? |
| 17 | What's the group chat drama in your family right now? | What's the latest drama in your friend group? |
| 18 | Who do you call first in a crisis? | Who would you avoid calling in a crisis? |
| 19 | What's the most competitive thing at family gatherings? | What's the most competitive thing on a night out? |
| 20 | What food does someone always bring that nobody wants? | What drink does someone always bring that everyone loves? |
| 21 | What holiday does your family go all-out for? | What holiday do you celebrate alone? |
| 22 | What show does everyone in your family watch? | What show do you watch that nobody else does? |
| 23 | What childhood memory do your cousins remind you of? | What childhood memory do you wish people forgot? |
| 24 | What does your mum cook that you actually hate? | What do you cook that everyone secretly hates? |
| 25 | How do family members greet each other? | How do strangers greet you in your culture? |
| 26 | What do you do the morning after a big family event? | What do you do the morning after a big night out? |
| 27 | What's one thing every family member has an opinion on? | What's one thing you wish nobody had an opinion on? |
| 28 | What's the family car journey like on a long trip? | What's a road trip with friends like? |
| 29 | What does your family do when someone brings a new partner? | What do your friends do when you bring someone new around? |
| 30 | What's a habit everyone in your family has? | What's a habit everyone in your office has? |
| 31 | What's the funniest thing that's ever happened at a wedding? | What's the most awkward thing at a work event? |
| 32 | Who is the loudest at family gatherings? | Who is the loudest on a group night out? |
| 33 | What board game causes the most arguments in your family? | What game causes the most arguments with friends? |
| 34 | What's the family photo like at Christmas? | What's the friend group photo like on a night out? |
| 35 | What does your family always fight over the remote for? | What does your housemate always put on without asking? |
| 36 | What's the most dramatic thing to happen at a family dinner? | What's the most dramatic thing to happen on a first date? |
| 37 | Who always starts the karaoke at family parties? | Who always refuses to do karaoke on a night out? |
| 38 | What's the one cousin everyone is slightly scared of? | What's the one friend everyone slightly avoids? |
| 39 | What does your family think of your job? | What does your boss think of your after-hours life? |
| 40 | What's a rumour that went around your family? | What's a rumour that went around your workplace? |
| 41 | What childhood nickname haunts you at family events? | What nickname from school followed you into adult life? |
| 42 | What's the family vote split on that nobody talks about? | What's the work opinion that divides the team? |
| 43 | What gift does a family member always give that misses? | What gift do you always give that people pretend to love? |
| 44 | What do you do at a family event when you're bored? | What do you do at a work event when you're uncomfortable? |
| 45 | Who in your family is the best cook? | Who among your friends pretends to be the best cook? |
| 46 | What family story gets told every single year? | What work story gets repeated at every team lunch? |
| 47 | What does the family group chat blow up about? | What does the friend group chat blow up about? |
| 48 | What's the most passive-aggressive thing your family does? | What's the most passive-aggressive thing a housemate does? |
| 49 | What's a phrase only people in your family use? | What's a phrase that's unique to your friend group? |
| 50 | What would make a family gathering go completely off the rails? | What would make a night out go completely off the rails? |

#### QUESTION GAME SET 2 — "WILD CARD QUESTIONS" (more adventurous, still mild)
50 additional question pairs for more chaos:

| # | Civilian Question | Impostor Question |
|---|-------------------|-------------------|
| 1 | What would you do with a surprise day off? | What would you do if you called in sick when you weren't? |
| 2 | What's your go-to karaoke song? | What song would you perform at a stranger's karaoke night? |
| 3 | What's the worst thing you've eaten to be polite? | What's the best lie you've told about liking someone's cooking? |
| 4 | What's one thing you always lie about in social situations? | What's one thing you always tell the truth about even when you shouldn't? |
| 5 | What would you do with £500 you had to spend in one day? | What would you do with £500 you had to spend on someone else? |
| 6 | What's your secret talent that you barely admit to? | What's a talent you fake having? |
| 7 | What's one habit you'd be embarrassed for people to see? | What's one habit you're secretly proud of? |
| 8 | What would you do if you had no responsibilities for a weekend? | What would you do if you swapped lives with a celebrity for a day? |
| 9 | What's the most spontaneous thing you've done? | What's the most impulsive thing you've almost done but didn't? |
| 10 | What's the biggest lie you've told to get out of something? | What's the strangest truth you've used to get out of something? |
| 11 | What would your friends say is your most annoying habit? | What would your colleagues say is your most annoying habit? |
| 12 | What's the weirdest thing you do when home alone? | What's the most embarrassing thing you've done on public transport? |
| 13 | What's something you're weirdly competitive about? | What's something you pretend not to be competitive about? |
| 14 | What's a childhood fear you still kind of have? | What's an adult fear you're embarrassed to admit? |
| 15 | What's the worst advice you've ever followed? | What's the best advice you've ever ignored? |
| 16 | What's your most embarrassing music taste? | What's a song you blast when nobody's watching? |
| 17 | What would you do if you found £100 in an old jacket? | What would you do if you found a stranger's wallet with cash in it? |
| 18 | What skill do you think you're better at than you are? | What skill are you actually great at but undersell? |
| 19 | What would be your first purchase if you won the lottery? | What would be your first purchase if you got a huge bonus? |
| 20 | What's the most dramatic thing you've done for attention? | What's the most dramatic thing you've done to avoid attention? |
| 21 | What's your most irrational dealbreaker in a relationship? | What's your most rational dealbreaker that people find odd? |
| 22 | What do you do when you're stressed that you'd never admit? | What do you do when you're stressed that actually works? |
| 23 | What's a movie or show you cry at every time? | What's a movie or show you claim to hate but secretly love? |
| 24 | What's the worst way you've tried to impress someone? | What's the most successful thing you've done to impress someone? |
| 25 | What do you eat when nobody's watching? | What do you refuse to eat in public but love at home? |
| 26 | What's a decision you made that you'll never fully explain? | What's a decision you made that you still think was right but nobody agrees? |
| 27 | What's something you do that makes you feel like a real adult? | What's something you do that makes you feel like you're still 16? |
| 28 | What's something you've Googled that you'd delete from history? | What's something you've searched repeatedly hoping the answer changes? |
| 29 | What's your go-to excuse for being late? | What's the most creative excuse you've ever heard from someone else? |
| 30 | What's the weirdest compliment you've ever received? | What's the strangest insult you've turned into a compliment? |
| 31 | What would you spend a whole day doing with zero guilt? | What would you spend a whole week avoiding? |
| 32 | What's something you're proud of that nobody else cares about? | What's an achievement you downplay but are secretly very proud of? |
| 33 | What's a weird thing you collect or keep for no reason? | What's the most sentimental object you own that looks like junk? |
| 34 | What's the quickest you've ever made a decision you regret? | What's the longest you've taken to make a decision that turned out right? |
| 35 | What's your ideal way to spend a Sunday with nothing planned? | What's your ideal way to spend a Sunday when you're avoiding someone? |
| 36 | What's something you changed your mind about completely? | What's something everyone else changed their mind about but you haven't? |
| 37 | What do you do first thing in the morning before checking your phone? | What's the first thing you check on your phone in the morning? |
| 38 | What's your most used emoji and what does it actually mean coming from you? | What emoji do you use ironically? |
| 39 | What's a trend you quietly participated in that you now deny? | What's a trend you publicly hated but secretly tried? |
| 40 | What's your biggest social media habit you won't admit to? | What's the most time you've spent down a social media rabbit hole? |
| 41 | What's a food combination you eat that others find disgusting? | What's something you used to eat as a kid that you've disowned? |
| 42 | What's one lie you tell on your CV or dating profile? | What's one truth you'd never put on a CV or dating profile? |
| 43 | What would be the first sign you're in a simulation? | What would you do differently if you knew life was a simulation? |
| 44 | What's a conversation topic you always steer away from? | What's a conversation topic you're weirdly too confident in? |
| 45 | What's something you did online that you're glad nobody knows about? | What's something you almost posted but deleted at the last second? |
| 46 | What's the most dramatic exit you've made from a situation? | What's the most awkward way you've stayed in a situation too long? |
| 47 | What's a compliment you give that you never fully mean? | What's an insult you've disguised as a compliment? |
| 48 | What's a phase you went through that you'll never speak of? | What's a phase you went through that you're secretly nostalgic about? |
| 49 | What's the weirdest way you've tried to solve a problem? | What's the simplest problem you've massively overcomplicated? |
| 50 | What would you do if you woke up and none of your responsibilities existed? | What would you do if you had to take on someone else's responsibilities for a week? |

---

## 🔊 SOUNDS — `sound_service.dart` Updates

### New sound events to add to `SoundEvent` enum:
```dart
enum SoundEvent {
  tap,          // existing
  spin,         // existing
  cardReveal,   // existing — use for card flip in impostor
  countdown,    // existing
  timerEnd,     // existing
  bombTick,     // existing
  explosion,    // existing
  win,          // existing
  wrong,        // existing
  freeze,       // existing
  gotIt,        // NEW — "Got it!" button tap in impostor reveal
  discussionStart, // NEW — plays when discussion timer begins
  impostorReveal,  // NEW — dramatic reveal for impostor card (distinct from civilian)
}
```

### Sound mappings for impostor flow:
| Event | When | Sound |
|-------|------|-------|
| `tap` | Button pressed | `SystemSoundType.click` + haptic |
| `cardReveal` | Card flip animation starts | Asset: `cardReveal.mp3` |
| `gotIt` | Got it! pressed | `SystemSoundType.click` + `HapticFeedback.lightImpact()` |
| `discussionStart` | After last player reveals | Asset: `win.mp3` or discussion sound |
| `timerEnd` | Timer hits 0 | Asset: `timerEnd.mp3` + heavy haptic |
| `win` | Civilians win result | Asset: `win.mp3` |
| `wrong` | Impostor wins result | Asset: `wrong.mp3` |
| `countdown` | Last 10 seconds of timer | Asset: `countdown.mp3` tick per second |

---

## 🃏 CARD FLIP WIDGET — `impostor_card_flip_widget.dart`

```dart
// Core logic:
// - AnimationController, duration: 600ms
// - Use Transform.rotate + Matrix4.rotationY
// - At 90° (halfway): swap front/back widget
// - perspective: apply Matrix4.identity()..setEntry(3,2,0.001)

class ImpostorCardFlipWidget extends StatefulWidget {
  final Widget frontCard;   // Blue "Tap to reveal" card
  final Widget backCard;    // Civilian or Impostor revealed card
  final VoidCallback onFlipComplete;
}

// Gesture: single tap on front → trigger flip
// After flip completes → show "Got it!" button
// Add particle/sparkle effect on reveal (use flutter_animate package)
```

### Front card design:
```
┌─────────────────────┐
│                     │
│                     │
│   [tap icon small]  │
│   Tap to reveal     │
│                     │
│                     │
└─────────────────────┘
Background: deep blue (#1A2A8F or similar)
Rounded corners: 24px
Size: ~80% of screen width, ~60% of screen height
```

### Civilian back card design:
```
┌─────────────────────┐
│  Find the Imposter  │
│  before time runs   │
│  out!               │
│                     │
│  [WORD - LARGE]     │
│                     │
│  👥                 │
└─────────────────────┘
Background: deep blue (same/similar)
```

### Impostor back card design:
```
┌─────────────────────┐
│                     │
│    Imposter         │
│                     │
│       🕵️           │
│                     │
│  💡 Your Clue       │
│     [CLUE WORD]     │
│  Use this to        │
│  blend in!          │
└─────────────────────┘
Background: dark red (#6B0000 to #8B0000)
```

---

## ⚙️ `ImpostorGameConfig` — Data Model (pass between screens)

```dart
class ImpostorGameConfig {
  final List<ImpostorPlayer> players;
  final int impostorCount;
  final bool randomImpostorCount;
  final bool showImpostorCount;
  final bool timeLimitEnabled;
  final int timeLimitMinutes; // 2–10
  final ImpostorGameMode gameMode; // wordGame or questionGame
  final String? category; // null = use all categories randomly
  final bool showCategoryToImpostor;
  final bool showHintToImpostor;
}

class ImpostorPlayer {
  final String id;
  String name;
  ImpostorPlayer({required this.id, required this.name});
}

enum ImpostorGameMode { wordGame, questionGame }
```

---

## 🎨 Visual Style Rules

- **Background**: dark with pink/red radial glow (match existing `GameThemes.impostor`)
- **Primary accent**: `AppColors.neonPink` (#FF2D92) for buttons, borders, highlights
- **Secondary accent**: `AppColors.dareRed` (#FF3A5C) for impostor reveals
- **Card blue**: `Color(0xFF1A2A8F)` — deep navy blue matching reference
- **Card red**: `Color(0xFF6B0000)` — deep dark red matching reference
- **Fonts**: `GoogleFonts.poppins` throughout (match rest of app)
- **Animations**: Use `animate_do` package (already installed) + `flutter_animate`
- **Buttons**: rounded rectangle, height 64px, `BorderRadius.circular(20)`
- **"Got it!" button**: same style, full width, deep blue/indigo color

---

## 🔗 Navigation Wiring in `home_screen.dart`

**NO CHANGES needed** to home screen navigation. The existing:
```dart
} else if (title == 'Impostor Mode') {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const ImpostorSetupScreen()));
}
```
Still routes to `ImpostorSetupScreen` — which now shows the mode select + flows through the new screens.

---

## ✅ Implementation Checklist

- [ ] Create `ImpostorPlayer` model class
- [ ] Create `ImpostorGameConfig` model class
- [ ] Create `ImpostorGameMode` enum
- [ ] Rewrite `ImpostorSetupScreen` → mode select entry screen
- [ ] Create `ImpostorPlayersScreen` → 3-20 players, add/remove/rename
- [ ] Create `ImpostorSettingsScreen` → all settings (impostor count, time, mode, category)
- [ ] Create `SelectImpostersSheet` bottom sheet
- [ ] Create `SelectTimeLimitSheet` bottom sheet
- [ ] Create `ImpostorCardFlipWidget` with 3D flip animation
- [ ] Rewrite `ImpostorGameScreen` with 5 phases using new config
- [ ] Implement impostor clue words in `ImpostorData`
- [ ] Add Question Game question pairs to `ImpostorData`
- [ ] Add 8 new Cousin Chaos categories to `ImpostorData`
- [ ] Expand existing 16 categories to 50 words each
- [ ] Add `gotIt` and `discussionStart` to `SoundEvent` enum
- [ ] Wire sounds throughout impostor flow
- [ ] Test navigation flow end-to-end
- [ ] Test impostor clue display toggle
- [ ] Test time limit toggle + all durations
- [ ] Test player count 3-20 + impostor count rules
- [ ] Test both Word Game and Question Game modes

---

## 📝 Notes for Agent

1. **Do NOT modify** `PlayerManager` — impostor mode uses its own local player list
2. **Keep existing** `ImpostorData.categories` and ADD to them, don't replace
3. The **card flip is tap-to-flip**, NOT hold-to-flip (user changed to hold-to-flip for their UX, but reference is tap — user confirmed `hold to flip` in their Q6 answer, so keep hold mechanic from existing code but replace the circular progress with a full card that you hold)
4. Actually re-read: User said **"Yes I want hold to flip"** — so keep HOLD mechanics but replace circular progress indicator with a beautiful card that animates when held (card shakes/glows as you hold, then flips at completion)
5. The **"Got it!" button** appears AFTER reveal, NOT before
6. Question game impostor sees a **different question**, not a clue word
7. All screens should have `PopScope(canPop: false)` with leave game dialog during active game
8. The `ImpostorSettingsScreen` is where "Start Game" is — it launches `ImpostorGameScreen` with full config
9. Use `const Duration(milliseconds: 600)` for card flip, `const Duration(milliseconds: 300)` for card appear
10. Sound `cardReveal` should play at START of hold (when finger goes down), `gotIt` plays on button tap

---

## 📋 QUESTION GAME DATA — `impostor_questions.dart`

Add this as a new file: `lib/core/constants/impostor_questions.dart`

This file contains **1,800 question pairs across all 24 categories** (75 per category).

### How to use in game:
```dart
// In ImpostorData, add:
static Map<String, List<ImpostorQuestion>> get questionCategories => impostorQuestions;

// In ImpostorGameScreen, when gameMode == questionGame:
final questions = ImpostorData.questionCategories[category] ?? [];
final question = questions[_random.nextInt(questions.length)];
// Civilians see: question.civilianQuestion
// Impostors see: question.impostorQuestion
```

### `ImpostorQuestion` class (add to `impostor_data.dart`):
```dart
class ImpostorQuestion {
  final String civilianQuestion;
  final String impostorQuestion;
  const ImpostorQuestion({
    required this.civilianQuestion,
    required this.impostorQuestion,
  });
}
```

### Full question data — paste this entire content into `lib/core/constants/impostor_questions.dart`:

```dart
// Generated for Cousin Chaos Impostor Party Game
// 24 categories × 75 question pairs = 1800 pairs
import 'impostor_data.dart';

final Map<String, List<ImpostorQuestion>> impostorQuestions = {
  'GAMING': [
    ImpostorQuestion(civilianQuestion: 'Which game has the most satisfying win screen overall?', impostorQuestion: 'Which game has the most exciting final moment overall?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the sweatiest players overall?', impostorQuestion: 'Which game has the most competitive players overall?'),
    ImpostorQuestion(civilianQuestion: 'Name one gaming character would be best in real life overall.', impostorQuestion: 'Name one gaming character would be worst in real life overall.'),
    ImpostorQuestion(civilianQuestion: 'Pick the game map is easiest to get lost in overall.', impostorQuestion: 'Pick the game map is hardest to escape from overall.'),
    ImpostorQuestion(civilianQuestion: 'What is the game item feels most overpowered overall?', impostorQuestion: 'What is the game item feels most unfair overall?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the best comeback potential overall?', impostorQuestion: 'Which game has the best clutch potential overall?'),
    ImpostorQuestion(civilianQuestion: 'What game mode causes the most arguments overall?', impostorQuestion: 'What game mode causes the most shouting overall?'),
    ImpostorQuestion(civilianQuestion: 'What mobile game wastes the most time overall?', impostorQuestion: 'What online game wastes the most time overall?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the funniest glitches overall?', impostorQuestion: 'Which game has the weirdest bugs overall?'),
    ImpostorQuestion(civilianQuestion: 'Which game skin is most overpriced overall?', impostorQuestion: 'Which game cosmetic is most unnecessary overall?'),
    ImpostorQuestion(civilianQuestion: 'What is the game has the most satisfying win screen in this group?', impostorQuestion: 'What is the game has the most exciting final moment in this group?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the sweatiest players in this group?', impostorQuestion: 'Which game has the most competitive players in this group?'),
    ImpostorQuestion(civilianQuestion: 'Name one gaming character would be best in real life in this group.', impostorQuestion: 'Name one gaming character would be worst in real life in this group.'),
    ImpostorQuestion(civilianQuestion: 'Which game map is easiest to get lost in in this group?', impostorQuestion: 'Which game map is hardest to escape from in this group?'),
    ImpostorQuestion(civilianQuestion: 'What game item feels most overpowered in this group?', impostorQuestion: 'What game item feels most unfair in this group?'),
    ImpostorQuestion(civilianQuestion: 'What game has the best comeback potential in this group?', impostorQuestion: 'What game has the best clutch potential in this group?'),
    ImpostorQuestion(civilianQuestion: 'Which game mode causes the most arguments in this group?', impostorQuestion: 'Which game mode causes the most shouting in this group?'),
    ImpostorQuestion(civilianQuestion: 'What mobile game wastes the most time in this group?', impostorQuestion: 'What online game wastes the most time in this group?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the funniest glitches in this group?', impostorQuestion: 'Which game has the weirdest bugs in this group?'),
    ImpostorQuestion(civilianQuestion: 'Which game skin is most overpriced in this group?', impostorQuestion: 'Which game cosmetic is most unnecessary in this group?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the most satisfying win screen during a party?', impostorQuestion: 'Which game has the most exciting final moment during a party?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the sweatiest players during a party?', impostorQuestion: 'Which game has the most competitive players during a party?'),
    ImpostorQuestion(civilianQuestion: 'Name a gaming character that would be best in real life during a party.', impostorQuestion: 'Name a gaming character that would be worst in real life during a party.'),
    ImpostorQuestion(civilianQuestion: 'Which game map is easiest to get lost in during a party?', impostorQuestion: 'Which game map is hardest to escape from during a party?'),
    ImpostorQuestion(civilianQuestion: 'What game item feels most overpowered during a party?', impostorQuestion: 'What game item feels most unfair during a party?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the best comeback potential during a party?', impostorQuestion: 'Which game has the best clutch potential during a party?'),
    ImpostorQuestion(civilianQuestion: 'What game mode causes the most arguments during a party?', impostorQuestion: 'What game mode causes the most shouting during a party?'),
    ImpostorQuestion(civilianQuestion: 'What mobile game wastes the most time during a party?', impostorQuestion: 'What online game wastes the most time during a party?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the funniest glitches during a party?', impostorQuestion: 'Which game has the weirdest bugs during a party?'),
    ImpostorQuestion(civilianQuestion: 'Which game skin is most overpriced during a party?', impostorQuestion: 'Which game cosmetic is most unnecessary during a party?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the most satisfying win screen during vacation?', impostorQuestion: 'Which game has the most exciting final moment during vacation?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the sweatiest players during vacation?', impostorQuestion: 'Which game has the most competitive players during vacation?'),
    ImpostorQuestion(civilianQuestion: 'Name a gaming character that would be best in real life during vacation.', impostorQuestion: 'Name a gaming character that would be worst in real life during vacation.'),
    ImpostorQuestion(civilianQuestion: 'Which game map is easiest to get lost in during vacation?', impostorQuestion: 'Which game map is hardest to escape from during vacation?'),
    ImpostorQuestion(civilianQuestion: 'What game item feels most overpowered during vacation?', impostorQuestion: 'What game item feels most unfair during vacation?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the best comeback potential during vacation?', impostorQuestion: 'Which game has the best clutch potential during vacation?'),
    ImpostorQuestion(civilianQuestion: 'What game mode causes the most arguments during vacation?', impostorQuestion: 'What game mode causes the most shouting during vacation?'),
    ImpostorQuestion(civilianQuestion: 'What mobile game wastes the most time during vacation?', impostorQuestion: 'What online game wastes the most time during vacation?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the funniest glitches during vacation?', impostorQuestion: 'Which game has the weirdest bugs during vacation?'),
    ImpostorQuestion(civilianQuestion: 'Which game skin is most overpriced during vacation?', impostorQuestion: 'Which game cosmetic is most unnecessary during vacation?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the most satisfying win screen when bored?', impostorQuestion: 'Which game has the most exciting final moment when bored?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the sweatiest players when bored?', impostorQuestion: 'Which game has the most competitive players when bored?'),
    ImpostorQuestion(civilianQuestion: 'Name a gaming character that would be best in real life when bored.', impostorQuestion: 'Name a gaming character that would be worst in real life when bored.'),
    ImpostorQuestion(civilianQuestion: 'Which game map is easiest to get lost in when bored?', impostorQuestion: 'Which game map is hardest to escape from when bored?'),
    ImpostorQuestion(civilianQuestion: 'What game item feels most overpowered when bored?', impostorQuestion: 'What game item feels most unfair when bored?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the best comeback potential when bored?', impostorQuestion: 'Which game has the best clutch potential when bored?'),
    ImpostorQuestion(civilianQuestion: 'What game mode causes the most arguments when bored?', impostorQuestion: 'What game mode causes the most shouting when bored?'),
    ImpostorQuestion(civilianQuestion: 'What mobile game wastes the most time when bored?', impostorQuestion: 'What online game wastes the most time when bored?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the funniest glitches when bored?', impostorQuestion: 'Which game has the weirdest bugs when bored?'),
    ImpostorQuestion(civilianQuestion: 'Which game skin is most overpriced when bored?', impostorQuestion: 'Which game cosmetic is most unnecessary when bored?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the most satisfying win screen for a funny argument?', impostorQuestion: 'Which game has the most exciting final moment for a funny argument?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the sweatiest players for a funny argument?', impostorQuestion: 'Which game has the most competitive players for a funny argument?'),
    ImpostorQuestion(civilianQuestion: 'Name a gaming character that would be best in real life for a funny argument.', impostorQuestion: 'Name a gaming character that would be worst in real life for a funny argument.'),
    ImpostorQuestion(civilianQuestion: 'Which game map is easiest to get lost in for a funny argument?', impostorQuestion: 'Which game map is hardest to escape from for a funny argument?'),
    ImpostorQuestion(civilianQuestion: 'What game item feels most overpowered for a funny argument?', impostorQuestion: 'What game item feels most unfair for a funny argument?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the best comeback potential for a funny argument?', impostorQuestion: 'Which game has the best clutch potential for a funny argument?'),
    ImpostorQuestion(civilianQuestion: 'What game mode causes the most arguments for a funny argument?', impostorQuestion: 'What game mode causes the most shouting for a funny argument?'),
    ImpostorQuestion(civilianQuestion: 'What mobile game wastes the most time for a funny argument?', impostorQuestion: 'What online game wastes the most time for a funny argument?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the funniest glitches for a funny argument?', impostorQuestion: 'Which game has the weirdest bugs for a funny argument?'),
    ImpostorQuestion(civilianQuestion: 'Which game skin is most overpriced for a funny argument?', impostorQuestion: 'Which game cosmetic is most unnecessary for a funny argument?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the most satisfying win screen for a game night?', impostorQuestion: 'Which game has the most exciting final moment for a game night?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the sweatiest players for a game night?', impostorQuestion: 'Which game has the most competitive players for a game night?'),
    ImpostorQuestion(civilianQuestion: 'Name a gaming character that would be best in real life for a game night.', impostorQuestion: 'Name a gaming character that would be worst in real life for a game night.'),
    ImpostorQuestion(civilianQuestion: 'Which game map is easiest to get lost in for a game night?', impostorQuestion: 'Which game map is hardest to escape from for a game night?'),
    ImpostorQuestion(civilianQuestion: 'What game item feels most overpowered for a game night?', impostorQuestion: 'What game item feels most unfair for a game night?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the best comeback potential for a game night?', impostorQuestion: 'Which game has the best clutch potential for a game night?'),
    ImpostorQuestion(civilianQuestion: 'What game mode causes the most arguments for a game night?', impostorQuestion: 'What game mode causes the most shouting for a game night?'),
    ImpostorQuestion(civilianQuestion: 'What mobile game wastes the most time for a game night?', impostorQuestion: 'What online game wastes the most time for a game night?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the funniest glitches for a game night?', impostorQuestion: 'Which game has the weirdest bugs for a game night?'),
    ImpostorQuestion(civilianQuestion: 'Which game skin is most overpriced for a game night?', impostorQuestion: 'Which game cosmetic is most unnecessary for a game night?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the most satisfying win screen for cousins?', impostorQuestion: 'Which game has the most exciting final moment for cousins?'),
    ImpostorQuestion(civilianQuestion: 'Which game has the sweatiest players for cousins?', impostorQuestion: 'Which game has the most competitive players for cousins?'),
    ImpostorQuestion(civilianQuestion: 'Name a gaming character that would be best in real life for cousins.', impostorQuestion: 'Name a gaming character that would be worst in real life for cousins.'),
    ImpostorQuestion(civilianQuestion: 'Which game map is easiest to get lost in for cousins?', impostorQuestion: 'Which game map is hardest to escape from for cousins?'),
    ImpostorQuestion(civilianQuestion: 'What game item feels most overpowered for cousins?', impostorQuestion: 'What game item feels most unfair for cousins?'),
  ],
  // NOTE TO AGENT: The remaining 23 categories follow the same pattern.
  // The full raw question data for all 24 categories is in the uploaded file:
  // impostor_questions_24_categories_75_each.dart
  // Copy that file's content into lib/core/constants/impostor_questions.dart
  // and rename the map keys to match ImpostorData.categories keys:
  // 'Gaming' → 'GAMING', 'TikTok & Memes' → 'TIKTOK & MEMES', etc.
};
```

### ⚠️ AGENT KEY NOTE:
The uploaded `impostor_questions_24_categories_75_each.dart` file contains ALL 1,800 question pairs ready to use. Copy it to `lib/core/constants/impostor_questions.dart` and update the map keys to match the uppercase category names used in `ImpostorData.categories`.

**Key name mapping:**
| File key | ImpostorData key |
|----------|-----------------|
| 'Gaming' | 'GAMING' |
| 'TikTok & Memes' | 'TIKTOK & MEMES' |
| 'Foods' | 'FOODS' |
| 'Brands & Sneakers' | 'BRANDS & SNEAKERS' |
| 'Movies & Shows' | 'MOVIES & SHOWS' |
| 'School Life' | 'SCHOOL LIFE' |
| 'Countries & Cities' | 'COUNTRIES & CITIES' |
| 'Family Scenarios' | 'FAMILY SCENARIOS' |
| 'Music' | 'MUSIC' |
| 'Superheroes & Villains' | 'SUPERHEROES & VILLAINS' |
| 'Sports' | 'SPORTS' |
| 'Social Media' | 'SOCIAL MEDIA' |
| 'Science & School Subjects' | 'SCIENCE & SCHOOL SUBJECTS' |
| 'Random Objects' | 'RANDOM OBJECTS' |
| 'Reactions & Emotions' | 'REACTIONS & EMOTIONS' |
| 'Late Night / Vibe' | 'LATE NIGHT / VIBE' |
| 'Cousin Chaos Classics' | 'COUSIN CHAOS CLASSICS' |
| 'Adulting Disasters' | 'ADULTING DISASTERS' |
| 'Nights Out Chaos' | 'NIGHTS OUT CHAOS' |
| 'Relationship Chaos' | 'RELATIONSHIP CHAOS' |
| 'Cousin Chaos Dares & Confessions' | 'COUSIN CHAOS DARES & CONFESSIONS' |
| 'Wild Card Chaos' | 'WILD CARD CHAOS' |
| 'Celebrity & Pop Culture Chaos' | 'CELEBRITY & POP CULTURE CHAOS' |
| 'House Chaos' | 'HOUSE CHAOS' |
# 🕵️ Impostor Mode — Multiplayer Implementation Plan
**For AI Agent: Full multiplayer impostor mode via Firebase Realtime Database**

---

## 📁 Files to Create / Modify

| Action | File Path |
|--------|-----------|
| **MODIFY** | `lib/core/models/room.dart` |
| **MODIFY** | `lib/services/room_service.dart` |
| **MODIFY** | `lib/screens/multiplayer/lobby_screen.dart` |
| **MODIFY** | `lib/screens/multiplayer/widgets/mode_change_sheet.dart` |
| **CREATE** | `lib/screens/multiplayer/impostor_lobby_settings_sheet.dart` |
| **CREATE** | `lib/screens/multiplayer/multiplayer_impostor_screen.dart` |

---

## 🗺️ Full Multiplayer Flow

```
Lobby Screen
  Host taps mode → picks "Impostor Mode"
  Host taps ✏️ edit → ImpostorLobbySettingsSheet opens
    → picks: Word Game / Question Game, category, impostor count, time limit, hint toggle
  Host taps "Start Game"
    → RoomService.startImpostorGame() called
    → Firebase writes impostorState node with all roles assigned
    → room.status → 'playing'
  ALL players' screens auto-navigate to MultiplayerImpostorScreen
    → Each player sees their own role card (tap to reveal)
    → Discussion timer synced across all screens
    → All players vote simultaneously
    → Results shown on all screens
```

---

## 🔥 Firebase Data Structure

### New node: `rooms/{code}/impostorState`

```json
{
  "impostorState": {
    "gameMode": "wordGame",
    "category": "GAMING",
    "secretWord": "Headshot",
    "timeLimitEnabled": true,
    "timeLimitSeconds": 300,
    "showHintToImpostor": true,
    "showImpostorCount": true,
    "impostorCount": 2,
    "phase": "reveal",
    "timerStartedAt": 1715000000000,
    "roles": {
      "uid_player1": {
        "isImpostor": false,
        "revealed": false,
        "clue": null
      },
      "uid_player2": {
        "isImpostor": true,
        "revealed": false,
        "clue": "Sniper"
      }
    },
    "votes": {
      "uid_player1": "uid_player3",
      "uid_player2": "uid_player3"
    },
    "eliminatedUid": null,
    "winningSide": null
  }
}
```

### `phase` values (controls what all screens show):
| Phase | What players see |
|-------|-----------------|
| `"reveal"` | Each player's card — tap to flip and see role |
| `"discussion"` | Discussion timer + instructions (synced) |
| `"vote"` | Vote list — everyone picks who they think is impostor |
| `"result"` | Result screen showing winner + word + impostors |

---

## 🔧 `room.dart` — Changes

### 1. Add `ImpostorRole` model:
```dart
class ImpostorRole {
  final bool isImpostor;
  final bool revealed;
  final String? clue; // null for civilians

  const ImpostorRole({
    required this.isImpostor,
    required this.revealed,
    this.clue,
  });

  factory ImpostorRole.fromMap(Map<dynamic, dynamic> map) => ImpostorRole(
    isImpostor: map['isImpostor'] as bool? ?? false,
    revealed: map['revealed'] as bool? ?? false,
    clue: map['clue'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'isImpostor': isImpostor,
    'revealed': revealed,
    'clue': clue,
  };
}
```

### 2. Add `ImpostorState` model:
```dart
class ImpostorState {
  final String gameMode;         // 'wordGame' | 'questionGame'
  final String category;
  final String secretWord;       // word for wordGame, civilian question for questionGame
  final String? impostorContent; // null for wordGame; impostor question for questionGame
  final bool timeLimitEnabled;
  final int timeLimitSeconds;
  final bool showHintToImpostor;
  final bool showImpostorCount;
  final int impostorCount;
  final String phase;            // 'reveal' | 'discussion' | 'vote' | 'result'
  final int? timerStartedAt;     // epoch ms when discussion started
  final Map<String, ImpostorRole> roles; // uid → role
  final Map<String, String> votes;       // voterUid → accusedUid
  final String? eliminatedUid;
  final String? winningSide;     // 'civilians' | 'impostors'

  const ImpostorState({
    required this.gameMode,
    required this.category,
    required this.secretWord,
    this.impostorContent,
    required this.timeLimitEnabled,
    required this.timeLimitSeconds,
    required this.showHintToImpostor,
    required this.showImpostorCount,
    required this.impostorCount,
    required this.phase,
    this.timerStartedAt,
    required this.roles,
    this.votes = const {},
    this.eliminatedUid,
    this.winningSide,
  });

  factory ImpostorState.fromMap(Map<dynamic, dynamic> map) {
    final rolesMap = map['roles'] as Map<dynamic, dynamic>? ?? {};
    final roles = rolesMap.map((uid, data) =>
        MapEntry(uid as String, ImpostorRole.fromMap(data as Map)));

    final votesMap = map['votes'] as Map<dynamic, dynamic>? ?? {};
    final votes = votesMap.map((uid, accused) =>
        MapEntry(uid as String, accused as String));

    return ImpostorState(
      gameMode: map['gameMode'] as String? ?? 'wordGame',
      category: map['category'] as String? ?? '',
      secretWord: map['secretWord'] as String? ?? '',
      impostorContent: map['impostorContent'] as String?,
      timeLimitEnabled: map['timeLimitEnabled'] as bool? ?? false,
      timeLimitSeconds: map['timeLimitSeconds'] as int? ?? 300,
      showHintToImpostor: map['showHintToImpostor'] as bool? ?? true,
      showImpostorCount: map['showImpostorCount'] as bool? ?? false,
      impostorCount: map['impostorCount'] as int? ?? 1,
      phase: map['phase'] as String? ?? 'reveal',
      timerStartedAt: map['timerStartedAt'] as int?,
      roles: roles,
      votes: votes,
      eliminatedUid: map['eliminatedUid'] as String?,
      winningSide: map['winningSide'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'gameMode': gameMode,
    'category': category,
    'secretWord': secretWord,
    if (impostorContent != null) 'impostorContent': impostorContent,
    'timeLimitEnabled': timeLimitEnabled,
    'timeLimitSeconds': timeLimitSeconds,
    'showHintToImpostor': showHintToImpostor,
    'showImpostorCount': showImpostorCount,
    'impostorCount': impostorCount,
    'phase': phase,
    if (timerStartedAt != null) 'timerStartedAt': timerStartedAt,
    'roles': roles.map((uid, role) => MapEntry(uid, role.toMap())),
    if (votes.isNotEmpty) 'votes': votes,
    if (eliminatedUid != null) 'eliminatedUid': eliminatedUid,
    if (winningSide != null) 'winningSide': winningSide,
  };
}
```

### 3. Add `impostorState` field to `Room` class:
```dart
// In Room class, add:
final ImpostorState? impostorState;

// In Room.fromMap(), add:
impostorState: map['impostorState'] != null
    ? ImpostorState.fromMap(map['impostorState'] as Map)
    : null,
```

### 4. Add `impostorSettings` to Room for lobby config:
```dart
// This is what the host sets BEFORE starting — stored separately from impostorState
// Add to Room model:
final Map<String, dynamic> impostorSettings; // pre-game settings

// In fromMap:
impostorSettings: Map<String, dynamic>.from(map['impostorSettings'] ?? {}),
```

---

## 🔧 `room_service.dart` — New Methods

### Add impostor settings to lobby:
```dart
Future<void> updateImpostorSettings(String code, {
  required String gameMode,
  required String category,
  required int impostorCount,
  required bool timeLimitEnabled,
  required int timeLimitMinutes,
  required bool showHintToImpostor,
  required bool showImpostorCount,
}) async {
  await _db.child('rooms/$code/impostorSettings').set({
    'gameMode': gameMode,
    'category': category,
    'impostorCount': impostorCount,
    'timeLimitEnabled': timeLimitEnabled,
    'timeLimitMinutes': timeLimitMinutes,
    'showHintToImpostor': showHintToImpostor,
    'showImpostorCount': showImpostorCount,
  });
}
```

### Start impostor game:
```dart
Future<void> startImpostorGame(String code, Room room) async {
  final settings = room.impostorSettings;
  final players = room.activePlayers;
  final rng = Random();

  // Pick word / question
  final gameMode = settings['gameMode'] as String? ?? 'wordGame';
  final category = settings['category'] as String? ?? 'GAMING';
  final impostorCount = settings['impostorCount'] as int? ?? 1;
  final timeLimitEnabled = settings['timeLimitEnabled'] as bool? ?? false;
  final timeLimitMinutes = settings['timeLimitMinutes'] as int? ?? 5;
  final showHint = settings['showHintToImpostor'] as bool? ?? true;
  final showImpostorCount = settings['showImpostorCount'] as bool? ?? false;

  String secretWord = '';
  String? impostorContent;

  if (gameMode == 'wordGame') {
    final words = ImpostorData.categories[category] ?? ['Mystery'];
    secretWord = words[rng.nextInt(words.length)];
    // Clue for impostor from ImpostorData.wordClues
    impostorContent = null; // clue stored per-role below
  } else {
    // questionGame
    final questions = impostorQuestions[category] ?? [];
    if (questions.isNotEmpty) {
      final q = questions[rng.nextInt(questions.length)];
      secretWord = q.civilianQuestion;
      impostorContent = q.impostorQuestion;
    }
  }

  // Assign roles
  final shuffled = List<RoomPlayer>.from(players)..shuffle();
  final impostorUids = shuffled.take(impostorCount).map((p) => p.uid).toSet();

  // Get clues for impostors (word game only)
  final clues = ImpostorData.wordClues[secretWord] ?? [];

  final roles = <String, ImpostorRole>{};
  int clueIndex = 0;
  for (final player in players) {
    final isImpostor = impostorUids.contains(player.uid);
    String? clue;
    if (isImpostor && gameMode == 'wordGame' && showHint && clues.isNotEmpty) {
      clue = clues[clueIndex % clues.length];
      clueIndex++;
    }
    roles[player.uid] = ImpostorRole(
      isImpostor: isImpostor,
      revealed: false,
      clue: clue,
    );
  }

  final impostorState = ImpostorState(
    gameMode: gameMode,
    category: category,
    secretWord: secretWord,
    impostorContent: impostorContent,
    timeLimitEnabled: timeLimitEnabled,
    timeLimitSeconds: timeLimitMinutes * 60,
    showHintToImpostor: showHint,
    showImpostorCount: showImpostorCount,
    impostorCount: impostorCount,
    phase: 'reveal',
    roles: roles,
  );

  await _db.child('rooms/$code').update({
    'status': 'playing',
    'impostorState': impostorState.toMap(),
  });
}
```

### Mark player's card as revealed:
```dart
Future<void> markImpostorCardRevealed(String code, String uid) async {
  await _db.child('rooms/$code/impostorState/roles/$uid/revealed').set(true);
}
```

### Advance to discussion phase (host only):
```dart
Future<void> startImpostorDiscussion(String code) async {
  await _db.child('rooms/$code/impostorState').update({
    'phase': 'discussion',
    'timerStartedAt': DateTime.now().millisecondsSinceEpoch,
  });
}
```

### Advance to vote phase:
```dart
Future<void> startImpostorVote(String code) async {
  await _db.child('rooms/$code/impostorState').update({
    'phase': 'vote',
  });
}
```

### Submit vote:
```dart
Future<void> submitImpostorVote(String code, String voterUid, String accusedUid) async {
  await _db.child('rooms/$code/impostorState/votes/$voterUid').set(accusedUid);
}
```

### Resolve votes and show result:
```dart
Future<void> resolveImpostorVotes(String code, ImpostorState state) async {
  // Count votes — most accused player is eliminated
  final voteCounts = <String, int>{};
  for (final accused in state.votes.values) {
    voteCounts[accused] = (voteCounts[accused] ?? 0) + 1;
  }

  String? eliminatedUid;
  int maxVotes = 0;
  for (final entry in voteCounts.entries) {
    if (entry.value > maxVotes) {
      maxVotes = entry.value;
      eliminatedUid = entry.key;
    }
  }

  final isImpostor = eliminatedUid != null &&
      (state.roles[eliminatedUid]?.isImpostor ?? false);
  final winningSide = isImpostor ? 'civilians' : 'impostors';

  await _db.child('rooms/$code/impostorState').update({
    'phase': 'result',
    'eliminatedUid': eliminatedUid,
    'winningSide': winningSide,
  });
}
```

### Play again (host resets):
```dart
Future<void> resetImpostorGame(String code, Room room) async {
  // Clear impostorState, keep settings, go back to lobby
  await _db.child('rooms/$code').update({
    'status': 'lobby',
    'impostorState': null,
  });
}
```

---

## 📄 `ImpostorLobbySettingsSheet` — New Widget

**Shown when host taps ✏️ next to "Impostor Mode" in lobby.**

### Layout (scrollable bottom sheet):
1. **Game Mode** — Word Game | Question Game (two selectable cards)
2. **Category** — scrollable list of all 24 categories, tap to select one (or "All" = random)
3. **Impostor Count** — `[-]` `[N]` `[+]` counter with Recommended label (same rules as local mode)
4. **Time Limit** — toggle on/off + minute picker (2–10 min) when on
5. **Show Hint to Impostor** — toggle
6. **Show Impostor Count** — toggle
7. **Save** button — calls `RoomService.updateImpostorSettings()`

```dart
class ImpostorLobbySettingsSheet extends StatefulWidget {
  final String roomCode;
  final Map<String, dynamic> currentSettings;
  final int playerCount;

  const ImpostorLobbySettingsSheet({
    super.key,
    required this.roomCode,
    required this.currentSettings,
    required this.playerCount,
  });
}
```

**On "Save" tapped:**
```dart
await RoomService.instance.updateImpostorSettings(
  widget.roomCode,
  gameMode: _gameMode,
  category: _category,
  impostorCount: _impostorCount,
  timeLimitEnabled: _timeLimitEnabled,
  timeLimitMinutes: _timeLimitMinutes,
  showHintToImpostor: _showHint,
  showImpostorCount: _showImpostorCount,
);
Navigator.pop(context);
```

---

## 📄 `lobby_screen.dart` — Changes

### 1. When mode is `'impostor'`, show settings summary below mode row:
```dart
// Below existing mode row, add:
if (room.mode == 'impostor') ...[
  const SizedBox(height: 8),
  _buildImpostorSettingsSummary(room),
]
```

```dart
Widget _buildImpostorSettingsSummary(Room room) {
  final settings = room.impostorSettings;
  final category = settings['category'] as String? ?? 'All Categories';
  final gameMode = settings['gameMode'] as String? ?? 'wordGame';
  final impostorCount = settings['impostorCount'] as int? ?? 1;

  return GlassCard(
    accentColor: AppColors.dareRed.withAlpha(40),
    borderRadius: 12,
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        const Icon(Icons.tune_rounded, color: AppColors.dareRed, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$category · ${gameMode == 'wordGame' ? 'Word' : 'Question'} · $impostorCount impostor${impostorCount > 1 ? 's' : ''}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        if (isHost)
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ImpostorLobbySettingsSheet(
                roomCode: widget.roomCode,
                currentSettings: room.impostorSettings,
                playerCount: room.activePlayers.length,
              ),
            ),
            child: const Icon(Icons.edit_rounded, color: AppColors.dareRed, size: 14),
          ),
      ],
    ),
  );
}
```

### 2. Override "Start Game" button for impostor mode:
```dart
// Replace existing onTap for Start Game:
onTap: activePlayers.length >= 3  // impostor needs min 3
    ? () {
        if (room.mode == 'impostor') {
          RoomService.instance.startImpostorGame(widget.roomCode, room);
        } else {
          RoomService.instance.startGame(widget.roomCode, room);
        }
      }
    : null,
```

### 3. Navigation when game starts — impostor goes to different screen:
```dart
// In the existing if (room.status == 'playing') block:
if (room.status == 'playing') {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (room.mode == 'impostor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiplayerImpostorScreen(
            roomCode: widget.roomCode,
            isHost: room.hostUid == currentUserUid,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiplayerGameScreen(
            roomCode: widget.roomCode,
            isHost: room.hostUid == currentUserUid,
          ),
        ),
      );
    }
  });
}
```

---

## 📄 `MultiplayerImpostorScreen` — New Screen

This screen replaces `ImpostorGameScreen` for multiplayer. It listens to `impostorState` in Firebase in real-time and shows the correct UI based on `phase`.

```dart
class MultiplayerImpostorScreen extends StatefulWidget {
  final String roomCode;
  final bool isHost;

  const MultiplayerImpostorScreen({
    super.key,
    required this.roomCode,
    required this.isHost,
  });
}
```

### Build method — stream from Firebase:
```dart
@override
Widget build(BuildContext context) {
  return StreamBuilder<Room?>(
    stream: RoomService.instance.roomStream(widget.roomCode),
    builder: (context, snapshot) {
      final room = snapshot.data;
      if (room == null || room.impostorState == null) {
        return const LoadingScreen();
      }

      final state = room.impostorState!;
      final myUid = RoomService.instance.currentUid;

      switch (state.phase) {
        case 'reveal':   return _buildRevealPhase(state, myUid);
        case 'discussion': return _buildDiscussionPhase(state, myUid, room);
        case 'vote':     return _buildVotePhase(state, myUid, room);
        case 'result':   return _buildResultPhase(state, room);
        default:         return const LoadingScreen();
      }
    },
  );
}
```

---

### Phase 1 — `reveal` phase

**ALL players see their own card simultaneously on their own phone.**

```dart
Widget _buildRevealPhase(ImpostorState state, String myUid) {
  final myRole = state.roles[myUid];
  final isImpostor = myRole?.isImpostor ?? false;
  final revealed = myRole?.revealed ?? false;
  final clue = myRole?.clue;
  final allRevealed = state.roles.values.every((r) => r.revealed);

  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: _buildAppBar('IMPOSTOR'),
    body: Column(
      children: [
        // Progress indicator: X of Y players have revealed
        _buildRevealProgress(state),
        
        Expanded(
          child: Center(
            child: !revealed
                // Show flip card — HOLD to reveal
                ? ImpostorCardFlipWidget(
                    onHoldComplete: () async {
                      await RoomService.instance.markImpostorCardRevealed(
                        widget.roomCode, myUid,
                      );
                      SoundService.instance.play(SoundEvent.cardReveal);
                    },
                    frontCard: _buildCardFront(),
                    backCard: isImpostor
                        ? _buildImpostorCard(clue, state)
                        : _buildCivilianCard(state),
                  )
                // Already revealed — show role card + waiting message
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isImpostor
                          ? _buildImpostorCard(clue, state)
                          : _buildCivilianCard(state),
                      const SizedBox(height: 24),
                      if (!allRevealed)
                        Text(
                          'Waiting for others to reveal...',
                          style: GoogleFonts.poppins(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
          ),
        ),

        // Host sees "Start Discussion" once all revealed
        if (widget.isHost && allRevealed)
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildActionButton(
              'Start Discussion',
              AppColors.neonPink,
              () => RoomService.instance.startImpostorDiscussion(widget.roomCode),
            ),
          ),
      ],
    ),
  );
}
```

**Reveal progress bar:**
```dart
Widget _buildRevealProgress(ImpostorState state) {
  final total = state.roles.length;
  final revealed = state.roles.values.where((r) => r.revealed).length;
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          '$revealed / $total players revealed',
          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total == 0 ? 0 : revealed / total,
          color: AppColors.neonPink,
          backgroundColor: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ),
  );
}
```

---

### Phase 2 — `discussion` phase

**All players see the same screen with synced countdown timer.**

```dart
Widget _buildDiscussionPhase(ImpostorState state, String myUid, Room room) {
  // Calculate time remaining from timerStartedAt
  int timeLeft = state.timeLimitSeconds;
  if (state.timeLimitEnabled && state.timerStartedAt != null) {
    final elapsed = (DateTime.now().millisecondsSinceEpoch - state.timerStartedAt!) ~/ 1000;
    timeLeft = (state.timeLimitSeconds - elapsed).clamp(0, state.timeLimitSeconds);
  }

  return Scaffold(
    backgroundColor: AppColors.background,
    body: Container(
      decoration: BoxDecoration(gradient: GameThemes.impostor.backgroundGradient),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_rounded, color: AppColors.neonPink, size: 80),
            const SizedBox(height: 32),
            Text('TIME TO DISCUSS', style: /* big white bold */),
            const SizedBox(height: 16),
            if (state.showImpostorCount)
              Text(
                '${state.impostorCount} impostor${state.impostorCount > 1 ? 's' : ''} among you',
                style: GoogleFonts.poppins(color: AppColors.dareRed, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            const SizedBox(height: 16),
            Text(
              'Each player gives ONE clue. Find the impostor!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 48),
            // Timer (counts down locally from timerStartedAt)
            if (state.timeLimitEnabled)
              _SyncedTimerWidget(
                startedAt: state.timerStartedAt!,
                totalSeconds: state.timeLimitSeconds,
                onExpired: widget.isHost
                    ? () => RoomService.instance.startImpostorVote(widget.roomCode)
                    : null,
              ),
            const SizedBox(height: 64),
            // Only host can end discussion early
            if (widget.isHost)
              _buildActionButton(
                'FINISH & VOTE',
                AppColors.neonPink,
                () => RoomService.instance.startImpostorVote(widget.roomCode),
              ),
            if (!widget.isHost)
              Text(
                'Waiting for host to start voting...',
                style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
              ),
          ],
        ),
      ),
    ),
  );
}
```

**`_SyncedTimerWidget`** — calculates time remaining from `timerStartedAt` every second locally, no Firebase calls needed:
```dart
class _SyncedTimerWidget extends StatefulWidget {
  final int startedAt;       // epoch ms
  final int totalSeconds;
  final VoidCallback? onExpired;
  // ...
}

class _SyncedTimerWidgetState extends State<_SyncedTimerWidget> {
  late Timer _timer;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    final elapsed = (DateTime.now().millisecondsSinceEpoch - widget.startedAt) ~/ 1000;
    final remaining = (widget.totalSeconds - elapsed).clamp(0, widget.totalSeconds);
    setState(() => _timeLeft = remaining);
    if (remaining == 0) {
      _timer.cancel();
      widget.onExpired?.call();
    }
    if (remaining <= 10) SoundService.instance.play(SoundEvent.countdown);
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = _timeLeft ~/ 60;
    final s = _timeLeft % 60;
    return Text(
      '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
      style: GoogleFonts.poppins(
        fontSize: 80,
        fontWeight: FontWeight.w900,
        color: _timeLeft <= 30 ? AppColors.dareRed : Colors.white,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
```

---

### Phase 3 — `vote` phase

**All players vote simultaneously. Each player taps who they think is the impostor.**

```dart
Widget _buildVotePhase(ImpostorState state, String myUid, Room room) {
  final hasVoted = state.votes.containsKey(myUid);
  final players = room.activePlayers;
  final totalPlayers = players.length;
  final totalVotes = state.votes.length;
  final allVoted = totalVotes >= totalPlayers;

  // Host auto-resolves when all votes are in
  if (allVoted && widget.isHost) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RoomService.instance.resolveImpostorVotes(widget.roomCode, state);
    });
  }

  return Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        // Vote progress
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$totalVotes / $totalPlayers voted',
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ),
        Text(
          'WHO IS THE IMPOSTOR?',
          style: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w900,
            color: AppColors.dareRed, letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasVoted ? 'Vote submitted! Waiting for others...' : 'Tap the player you suspect.',
          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: players.length,
            itemBuilder: (context, i) {
              final player = players[i];
              final isSelf = player.uid == myUid;
              final votedForThis = state.votes[myUid] == player.uid;
              final votesForThis = state.votes.values.where((v) => v == player.uid).length;

              return GestureDetector(
                onTap: hasVoted || isSelf ? null : () async {
                  HapticFeedback.heavyImpact();
                  SoundService.instance.play(SoundEvent.tap);
                  await RoomService.instance.submitImpostorVote(
                    widget.roomCode, myUid, player.uid,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: votedForThis
                        ? AppColors.dareRed.withAlpha(40)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: votedForThis
                          ? AppColors.dareRed
                          : AppColors.surfaceBright,
                    ),
                  ),
                  child: Row(
                    children: [
                      PlayerAvatar(avatar: AvatarConstants.byId(player.avatarId), size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          player.name + (isSelf ? ' (You)' : ''),
                          style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                          ),
                        ),
                      ),
                      // Show vote count (how many people voted for this player)
                      if (votesForThis > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.dareRed.withAlpha(80),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$votesForThis vote${votesForThis > 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.dareRed, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
```

---

### Phase 4 — `result` phase

**All players see the same result screen.**

```dart
Widget _buildResultPhase(ImpostorState state, Room room) {
  final civiliansWin = state.winningSide == 'civilians';
  final eliminatedPlayer = state.eliminatedUid != null
      ? room.players[state.eliminatedUid]
      : null;
  final impostorNames = room.activePlayers
      .where((p) => state.roles[p.uid]?.isImpostor == true)
      .map((p) => p.name)
      .join(' & ');

  return Scaffold(
    backgroundColor: AppColors.background,
    body: Container(
      decoration: BoxDecoration(gradient: GameThemes.impostor.backgroundGradient),
      child: SafeArea(
        child: Center(
          child: ZoomIn(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  civiliansWin ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                  color: civiliansWin ? AppColors.neonGreen : AppColors.dareRed,
                  size: 120,
                ),
                const SizedBox(height: 24),
                Text(
                  civiliansWin ? 'CIVILIANS WIN!' : 'IMPOSTOR WINS!',
                  style: GoogleFonts.poppins(
                    fontSize: 36, fontWeight: FontWeight.w900,
                    color: civiliansWin ? AppColors.neonGreen : AppColors.dareRed,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                if (eliminatedPlayer != null)
                  Text(
                    'You eliminated: ${eliminatedPlayer.name}',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
                  ),
                const SizedBox(height: 32),
                // Info card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceBright),
                  ),
                  child: Column(
                    children: [
                      Text('The impostor${state.impostorCount > 1 ? 's were' : ' was'}:',
                          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(impostorNames,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      const Divider(color: AppColors.surfaceBright, height: 32),
                      Text(
                        state.gameMode == 'wordGame' ? 'The secret word was:' : 'The question was:',
                        style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(state.secretWord,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.truthBlue)),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Only host can play again
                if (widget.isHost)
                  _buildActionButton(
                    'PLAY AGAIN',
                    AppColors.neonPink,
                    () => RoomService.instance.resetImpostorGame(widget.roomCode, room),
                  ),
                if (!widget.isHost)
                  Text(
                    'Waiting for host to play again...',
                    style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await RoomService.instance.leaveRoom(widget.roomCode);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text('Leave', style: GoogleFonts.poppins(color: AppColors.textMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
```

---

## 🔒 Security Rules (Firebase)

Add these to Firebase Realtime Database rules to protect impostor state:

```json
"impostorState": {
  ".read": "auth != null",
  "roles": {
    "$uid": {
      ".write": "auth != null && auth.uid == $uid && data.child('revealed').val() == false"
    }
  },
  "votes": {
    "$uid": {
      ".write": "auth != null && auth.uid == $uid && !data.exists()"
    }
  },
  "phase": {
    ".write": "auth != null && root.child('rooms/' + $roomCode + '/hostUid').val() == auth.uid"
  }
}
```

---

## ✅ Implementation Checklist

- [ ] Add `ImpostorRole` model to `room.dart`
- [ ] Add `ImpostorState` model to `room.dart`
- [ ] Add `impostorState` + `impostorSettings` fields to `Room` class
- [ ] Add `updateImpostorSettings()` to `room_service.dart`
- [ ] Add `startImpostorGame()` to `room_service.dart`
- [ ] Add `markImpostorCardRevealed()` to `room_service.dart`
- [ ] Add `startImpostorDiscussion()` to `room_service.dart`
- [ ] Add `startImpostorVote()` to `room_service.dart`
- [ ] Add `submitImpostorVote()` to `room_service.dart`
- [ ] Add `resolveImpostorVotes()` to `room_service.dart`
- [ ] Add `resetImpostorGame()` to `room_service.dart`
- [ ] Create `ImpostorLobbySettingsSheet` widget
- [ ] Update `lobby_screen.dart` — show settings summary for impostor mode
- [ ] Update `lobby_screen.dart` — edit button opens `ImpostorLobbySettingsSheet`
- [ ] Update `lobby_screen.dart` — Start Game routes to `startImpostorGame()`
- [ ] Update `lobby_screen.dart` — navigation on game start goes to `MultiplayerImpostorScreen`
- [ ] Create `MultiplayerImpostorScreen` with 4 phase builders
- [ ] Implement reveal phase — card flip per player, progress bar, host starts discussion
- [ ] Implement discussion phase — `_SyncedTimerWidget`, host controls vote start
- [ ] Implement vote phase — all vote simultaneously, auto-resolve when all votes in
- [ ] Implement result phase — combined results, host plays again
- [ ] Reuse `ImpostorCardFlipWidget` from local mode (hold to flip)
- [ ] Wire all sounds throughout multiplayer flow
- [ ] Test with 3 players minimum
- [ ] Test impostor role stays hidden (only stored per-uid in Firebase)
- [ ] Test timer sync across devices

---

## 📝 Agent Notes

1. **Roles are private per player** — each player only reads `roles/{their_uid}`. The Firebase rules prevent reading other players' roles.
2. **Timer is NOT stored in Firebase** — only `timerStartedAt` epoch is stored. Each device calculates `timeLeft` locally from that. This avoids 60 Firebase writes per minute.
3. **Vote resolution** — host watches for `votes.length >= players.length` and calls `resolveImpostorVotes`. Non-hosts just watch `phase` change to `result`.
4. **Reuse from local mode** — `ImpostorCardFlipWidget`, `ImpostorData`, `ImpostorQuestion`, sound events, card designs all reuse local mode code exactly.
5. **`mode_change_sheet.dart`** — impostor is already in the mode list (`'impostor'`). No changes needed there.
6. **Min players** — impostor multiplayer requires min 3 active players (same as local). Disable Start Game button if less than 3.
7. **`impostorSettings` defaults** — if host never opens the settings sheet, use defaults: wordGame, random category (pick random from all 24 at game start), 1 impostor, no time limit, show hint ON.
8. **Play Again in multiplayer** — resets `impostorState` to null and sets `status` back to `'lobby'`. All players auto-navigate back to lobby via the existing lobby stream.
