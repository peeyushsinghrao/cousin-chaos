# 🕵️ COUSIN CHAOS — IMPOSTOR MODE
> "Cousin Impostor" — Full Word Packs + Game Logic Structure
> Every category has 50 words. Total: 800+ words across 16 categories.

---

## 📖 HOW TO PLAY

1. All players sit in a circle with ONE phone
2. Phone is passed around — each player secretly peeks at their screen
3. Most players see the **SECRET WORD**
4. One random player sees **"🚨 YOU ARE THE IMPOSTOR"**
5. Players take turns giving ONE clue about the word
6. Impostor must FAKE IT — blend in without knowing the word
7. After all clues — group DEBATES & VOTES
8. Most votes = eliminated
9. **Impostor wins** if they survive the vote OR correctly guess the word after being caught
10. **Civilians win** if they correctly vote out the impostor

---

## ⚙️ GAME SETTINGS

```
Players: 3–12
Impostors: Auto-assigned based on player count (see rule below)
Round Timer: 3 / 5 / 7 / 10 minutes
Hint Token: ON / OFF (impostor gets 1 vague hint if enabled)
Reveal Word on Catch: ON / OFF
```

---

## 👥 IMPOSTOR COUNT RULE

| Players | Impostors |
|---------|-----------|
| 2 players | 1 Impostor |
| 3 players | 1 Impostor |
| 4 players | 1 Impostor |
| 5 players | 2 Impostors |
| 6 players | 2 Impostors |
| 7 players | 2 Impostors |
| 8 players | 2 Impostors |
| 9 players | 2 Impostors |
| 10 players | 2 Impostors |
| 11 players | 2 Impostors |
| 12 players | 2 Impostors |

> ✅ This is automatic — the app assigns impostors based on how many players joined. No manual setting needed.

```javascript
// Auto impostor count logic
function getImpostorCount(playerCount) {
  if (playerCount <= 4) return 1
  return 2
}
```

---

## 🎯 WIN CONDITIONS

| Role | Win Condition |
|------|--------------|
| Civilians | Vote out the impostor correctly |
| Impostor | Survive the vote OR guess the word after being caught |
| Double Impostor | Both survive OR one guesses the word |

---

---

# 🎮 CATEGORY 1: GAMING

> Words from gaming culture, consoles, mechanics, characters

1. Respawn
2. Headshot
3. Loot Box
4. Noob
5. Final Boss
6. Health Bar
7. Speedrun
8. Controller
9. Camp (camping a spot)
10. Rage Quit
11. Skin (cosmetic)
12. Patch Update
13. Glitch
14. Open World
15. Side Quest
16. NPC
17. Easter Egg
18. Ranked Mode
19. Lag
20. Aim Assist
21. Battle Pass
22. Grenade
23. Sniper
24. Respawn Point
25. Kill Streak
26. Inventory
27. Crafting
28. Spawn Trap
29. Modded Controller
30. Co-op Mode
31. Achievements
32. Cutscene
33. Game Over
34. Checkpoint
35. Loading Screen
36. Hitbox
37. Combo Move
38. Unlockable Character
39. Season Pass
40. Prestige
41. One-Shot Kill
42. Stealth Mode
43. Quick Scope
44. Ping (connection)
45. Clan Tag
46. Map Rotation
47. Endgame
48. Lore
49. DLC
50. Server Crash

---

# 📱 CATEGORY 2: TIKTOK & MEMES

> Viral internet culture, trends, meme formats

1. Ratio
2. Shadowban
3. Caught in 4K
4. No Cap
5. Rizz
6. Slay
7. Touch Grass
8. Main Character
9. Understood the Assignment
10. It's Giving
11. Lowkey
12. Highkey
13. NPC Trend
14. POV
15. Simp
16. Based
17. Red Flag
18. Green Flag
19. Beige Flag
20. Delulu
21. Rent Free
22. Ate and Left No Crumbs
23. Era (e.g. villain era)
24. Lore
25. Side Eye
26. Chefs Kiss
27. That Girl
28. Roman Empire
29. Situationship
30. Hot Take
31. Brain Rot
32. Unhinged
33. Vibe Check
34. Period (emphasis)
35. Say Less
36. Ick
37. W Rizz
38. Glazing
39. Real One
40. Core (e.g. cottagecore)
41. Mid
42. Bussin
43. Snatched
44. Feral
45. Clout
46. Ratio'd
47. Stan
48. Chronically Online
49. Gaslight
50. Main Character Energy

---

# 🍕 CATEGORY 3: FOODS

> Common, street, and trending foods — easy to describe, hard to fake

1. Pepperoni Pizza
2. Sushi Roll
3. Ramen
4. Fried Chicken
5. Burger
6. Tacos
7. Shawarma
8. Jollof Rice
9. Pancakes
10. Instant Noodles
11. Hot Dog
12. Nachos
13. Dumplings
14. Waffle
15. Grilled Cheese
16. Cheesecake
17. Mochi
18. Boba Tea
19. Spring Rolls
20. Mac and Cheese
21. Fried Rice
22. Croissant
23. Curry
24. Popcorn
25. Cotton Candy
26. Samosa
27. Churros
28. Donut
29. Pho
30. Bibimbap
31. Katsu
32. Jerk Chicken
33. Empanada
34. Pita Bread
35. Hummus
36. Gyoza
37. Baklava
38. Chili Dog
39. Loaded Fries
40. Mango Sticky Rice
41. Birria Tacos
42. Smash Burger
43. Omurice
44. Takoyaki
45. Poke Bowl
46. Açaí Bowl
47. Flatbread
48. Dim Sum
49. Falafel
50. Ice Cream Sandwich

---

# 👟 CATEGORY 4: BRANDS & SNEAKERS

> Clothing brands, sneaker culture, fashion labels

1. Air Force 1
2. Jordan 1
3. Yeezy
4. New Balance 550
5. Dunk Low
6. Adidas Samba
7. Vans Old Skool
8. Converse Chuck Taylor
9. Reebok Classic
10. Travis Scott Collab
11. Supreme Drop
12. Off-White
13. Balenciaga
14. Palace
15. Stüssy
16. BAPE
17. Fear of God
18. Essentials Hoodie
19. Champion
20. Carhartt
21. Stone Island
22. Corteiz
23. Gallery Dept
24. Trapstar
25. Anti Social Social Club
26. Kith
27. Noah
28. Aime Leon Dore
29. Human Made
30. A Bathing Ape
31. Nike Tech Fleece
32. Puffer Jacket (North Face)
33. Levi's 501
34. Ralph Lauren
35. Tommy Hilfiger
36. Lacoste
37. Burberry Check
38. Louis Vuitton Monogram
39. Gucci Belt
40. Dior Oblique
41. OVO (October's Very Own)
42. Sp5der
43. Hellstar
44. Eric Emanuel Shorts
45. Madhappy
46. Broken Planet
47. Represent
48. Weekend Offender
49. Hoka Bondi
50. On Running Cloud

---

# 🎬 CATEGORY 5: MOVIES & SHOWS

> Popular film/show titles and characters — must describe without saying the name

1. Squid Game
2. Money Heist
3. Breaking Bad
4. The Office
5. Stranger Things
6. Avatar (blue people)
7. The Dark Knight
8. Spider-Man
9. Black Panther
10. Interstellar
11. Parasite
12. Get Out
13. Avengers Endgame
14. Titanic
15. The Lion King
16. Shrek
17. Fast & Furious
18. John Wick
19. Inception
20. The Matrix
21. Harry Potter
22. Game of Thrones
23. Euphoria
24. Peaky Blinders
25. Narcos
26. Prison Break
27. Wednesday (Netflix)
28. Outer Banks
29. One Piece (live action)
30. Attack on Titan
31. Demon Slayer
32. Jujutsu Kaisen
33. My Hero Academia
34. Death Note
35. Fullmetal Alchemist
36. Naruto Shippuden
37. Dragon Ball Z
38. Hunter x Hunter
39. Sword Art Online
40. Tokyo Ghoul
41. Your Name (Kimi no Na wa)
42. Spirited Away
43. Princess Mononoke
44. Cowboy Bebop
45. Vinland Saga
46. Blue Lock
47. Chainsaw Man
48. Solo Leveling
49. Dandadan
50. Frieren

---

# 🏫 CATEGORY 6: SCHOOL LIFE

> Every teen knows these — perfect for catching fakers

1. Detention
2. Supply Teacher
3. Fire Drill
4. Lunch Queue
5. Group Project
6. Exam Week
7. Report Card
8. Hall Pass
9. School Trip
10. Locker
11. Canteen Food
12. Morning Assembly
13. Late Slip
14. Cheat Sheet
15. Revision Notes
16. Study Group
17. Teacher's Pet
18. Class Clown
19. Back Row
20. Seating Plan
21. Homework Due
22. Pop Quiz
23. Science Lab
24. Sports Day
25. Uniform Check
26. Parent Evening
27. Timetable
28. Free Period
29. School Play
30. Prom Night
31. Yearbook Photo
32. Graduation
33. Cafeteria Tray
34. School Bus
35. Library Silence
36. Art Class
37. PE Lesson
38. Music Room
39. Projector Screen
40. Whiteboard Marker
41. Pencil Case
42. Textbook
43. Desk Scratch (graffiti)
44. End of Year Party
45. Class Register
46. Essay Deadline
47. School Gate
48. Nap in Class
49. Copied Homework
50. Substitute Teacher Chaos

---

# 🌍 CATEGORY 7: COUNTRIES & CITIES

> Locations — describe culture, food, landmarks without saying the name

1. Japan
2. Nigeria
3. Brazil
4. South Korea
5. France
6. Mexico
7. India
8. Jamaica
9. Italy
10. USA
11. UK
12. Ghana
13. Turkey
14. Egypt
15. China
16. Australia
17. Spain
18. Canada
19. Saudi Arabia
20. Argentina
21. New York City
22. Tokyo
23. London
24. Lagos
25. Paris
26. Dubai
27. Seoul
28. Mumbai
29. Rio de Janeiro
30. Cape Town
31. Toronto
32. Sydney
33. Istanbul
34. Cairo
35. Mexico City
36. Bangkok
37. Singapore
38. Amsterdam
39. Nairobi
40. Accra
41. Jakarta
42. Karachi
43. Johannesburg
44. Miami
45. Los Angeles
46. Chicago
47. Berlin
48. Rome
49. Madrid
50. Kuala Lumpur

---

# 👨‍👩‍👧 CATEGORY 8: FAMILY SCENARIOS

> Cousin-specific, relatable family chaos moments

1. Sunday Dinner
2. Family Reunion
3. The Favourite Child
4. Nosy Auntie
5. Strict Parent
6. Curfew
7. Chores Argument
8. Road Trip Fight
9. Sleeping Over
10. Sibling Rivalry
11. Family Group Chat
12. Parents Fighting Over TV
13. The Golden Child
14. Embarrassing Baby Photos
15. Dad Jokes
16. Mum's Cooking
17. The Loud Uncle
18. Family BBQ
19. Sharing a Room
20. Borrowing Money (and not returning it)
21. Getting Grounded
22. Sneaking Out
23. Being Compared to a Cousin
24. School Report Drama
25. Phone Confiscated
26. Family Prayer Time
27. Overstaying Guests
28. Wedding Drama
29. Christmas Morning
30. Birthday Forgotten
31. House Rules
32. Family Secret
33. The Dramatic Cousin
34. Youngest Gets Away With Everything
35. Old Family Photos
36. The Relative Nobody Likes
37. Family Holiday Disaster
38. Grandma's House Rules
39. Cousins vs Parents Debate
40. Who Gets the Last Piece
41. Family Talent Show
42. Neighbourhood Gossip
43. Trying to Be Quiet at Night
44. Parents Reading Your Messages
45. Aunties Pinching Cheeks
46. Being Put on Speakerphone
47. Family Zoom Call Chaos
48. Baby Cousin Breaking Everything
49. Older Sibling Bossing You
50. Family Friend You Call "Uncle"

---

# 🎵 CATEGORY 9: MUSIC

> Artists, genres, and music culture

1. Drake
2. Kendrick Lamar
3. Travis Scott
4. SZA
5. Bad Bunny
6. Burna Boy
7. Wizkid
8. Rema
9. Stormzy
10. Central Cee
11. Lil Baby
12. Gunna
13. Playboi Carti
14. Frank Ocean
15. Tyler the Creator
16. Billie Eilish
17. The Weeknd
18. Doja Cat
19. Nicki Minaj
20. Cardi B
21. Metro Boomin
22. Future
23.21 Savage
24. Lil Uzi Vert
25. Yeat
26. Sexyy Red
27. Ice Spice
28. Asake
29. Davido
30. Afrobeats
31. Drill Music
32. Trap
33. R&B
34. K-Pop
35. Amapiano
36. Dancehall
37. Lo-Fi
38. Hyperpop
39. UK Rap
40. Grime
41. Music Festival
42. Album Drop
43. Feature (collab)
44. Diss Track
45. Freestyle
46. Verse
47. Chorus
48. Music Video
49. Spotify Wrapped
50. Concert Pit

---

# 🦸 CATEGORY 10: SUPERHEROES & VILLAINS

> Marvel, DC, anime power characters

1. Spider-Man
2. Batman
3. Iron Man
4. Superman
5. Black Panther
6. Thor
7. Captain America
8. Wonder Woman
9. The Flash
10. Green Lantern
11. Thanos
12. Joker
13. Loki
14. Magneto
15. Venom
16. Doctor Strange
17. Black Widow
18. Hawkeye
19. Ant-Man
20. Shazam
21. Aquaman
22. Deadpool
23. Wolverine
24. Storm
25. Cyclops
26. Professor X
27. Mystique
28. Lex Luthor
29. Bane
30. Riddler
31. Harley Quinn
32. Poison Ivy
33. Two-Face
34. Scarlet Witch
35. Vision
36. War Machine
37. Falcon
38. Winter Soldier
39. Nick Fury
40. Hawkeye (Kate Bishop)
41. Moon Knight
42. She-Hulk
43. Ms. Marvel
44. Blue Beetle
45. Homelander (The Boys)
46. Omni-Man (Invincible)
47. Goku (DBZ)
48. Naruto
49. Saitama (One Punch Man)
50. Izuku Midoriya (MHA)

---

# 🏀 CATEGORY 11: SPORTS

> Athletes, sports terms, iconic moments

1. Slam Dunk
2. Hat Trick
3. Penalty Kick
4. Free Throw
5. Grand Slam
6. Knockout
7. Marathon
8. Relay Race
9. Offside
10. Red Card
11. Yellow Card
12. Corner Kick
13. Own Goal
14. Overtime
15. Sudden Death
16. Dribble
17. Tackle
18. Serve (tennis)
19. Ace (tennis)
20. Birdie (golf)
21. Hole in One
22. Sprinting
23. High Jump
24. Long Jump
25. Javelin
26. Bench Press
27. Deadlift
28. Squat
29. Swimming Lap
30. Diving Board
31. Cricket Wicket
32. Rugby Scrum
33. American Football Touchdown
34. Baseball Home Run
35. Hockey Puck
36. Volleyball Spike
37. Boxing Jab
38. MMA Takedown
39. Wrestling Pin
40. F1 Pit Stop
41. Cycling Sprint
42. Skateboard Kickflip
43. Surfing Wave
44. Snowboard Trick
45. Basketball Crossover
46. Football Bicycle Kick
47. Basketball Alley-Oop
48. Football Nutmeg
49. Basketball Triple-Double
50. Football Golden Boot

---

# 🌐 CATEGORY 12: SOCIAL MEDIA

> Platforms, features, internet behaviour

1. Instagram Story
2. Twitter/X Ratio
3. YouTube Short
4. TikTok FYP
5. Snapchat Streak
6. Discord Server
7. Reddit Thread
8. Twitch Stream
9. Facebook Marketplace
10. LinkedIn Post
11. Pinterest Board
12. BeReal Notification
13. WhatsApp Status
14. Telegram Channel
15. Substack Newsletter
16. Podcast Episode
17. Viral Post
18. Cancel Culture
19. Comment Section War
20. Going Live
21. Shadowbanned
22. Verified Tick
23. Algorithm
24. Content Creator
25. Subscriber Count
26. Unboxing Video
27. Reaction Video
28. Collab Video
29. Sponsored Post
30. Brand Deal
31. Merch Drop
32. Pinned Comment
33. DM Slide
34. Story Poll
35. Close Friends List
36. Finsta
37. Fake Account (Catfish)
38. Chronological Feed
39. Explore Page
40. Hashtag
41. Repost
42. Quote Tweet
43. Thread (Twitter)
44. Going Viral
45. 1 Million Views
46. Deactivated Account
47. Screen Time Warning
48. Notification Spam
49. Group Chat Drama
50. Read Receipt (left on read)

---

# 🧪 CATEGORY 13: SCIENCE & SCHOOL SUBJECTS

> Academic terms — hard to fake if you don't know them

1. Photosynthesis
2. Black Hole
3. DNA
4. Atom
5. Gravity
6. Evolution
7. Periodic Table
8. Chemical Reaction
9. Ecosystem
10. Cell Division
11. Electromagnetic Wave
12. Newton's Law
13. Pythagorean Theorem
14. Pi (3.14)
15. Prime Number
16. Equation
17. Hypothesis
18. Experiment
19. Control Variable
20. Scientific Method
21. Climate Change
22. Carbon Dioxide
23. Oxygen Cycle
24. Food Chain
25. Predator
26. Prey
27. Fossil
28. Tectonic Plates
29. Volcano
30. Earthquake
31. Solar System
32. Galaxy
33. Nebula
34. Big Bang
35. Wormhole
36. Quantum Physics
37. Relativity
38. Velocity
39. Acceleration
40. Force
41. Friction
42. Momentum
43. Energy Transfer
44. Magnetism
45. Circuit
46. Resistance (Ohm's Law)
47. Refraction
48. Diffraction
49. Osmosis
50. Mitosis

---

# 🎲 CATEGORY 14: RANDOM OBJECTS

> Everyday items — easy to describe, tricky to fake

1. Stapler
2. Bubble Wrap
3. Paper Clip
4. Rubber Duck
5. Toothbrush
6. Alarm Clock
7. Umbrella
8. Sticky Note
9. Highlighter
10. Tape Measure
11. Flashlight
12. Extension Cord
13. Laundry Basket
14. Door Hinge
15. Shower Curtain
16. TV Remote
17. Couch Cushion
18. Cereal Box
19. Trash Can
20. Doorbell
21. Key Ring
22. Sunglasses
23. Baseball Cap
24. Wristwatch
25. Wallet
26. Backpack
27. Water Bottle
28. Gym Bag
29. Notebook
30. Pencil Sharpener
31. Scissors
32. Glue Stick
33. Ruler
34. Calculator
35. Eraser
36. Marker
37. Index Card
38. Binder
39. Folder
40. Desk Lamp
41. Phone Charger
42. Earphones
43. Keyboard
44. Mouse Pad
45. USB Drive
46. Monitor
47. Webcam
48. Power Bank
49. Laptop Stand
50. Cable Ties

---

# 😂 CATEGORY 15: REACTIONS & EMOTIONS

> Emotional states and reactions — perfect for acting and faking

1. Cringe
2. Embarrassment
3. Jealousy
4. FOMO
5. Anxiety
6. Hyped
7. Dead Inside
8. Unbothered
9. Stressed Out
10. Triggered
11. Satisfied
12. Confused
13. Disappointed
14. Shocked
15. Bored
16. Excited
17. Nervous
18. Relieved
19. Offended
20. Proud
21. Overwhelmed
22. Nostalgic
23. Hopeful
24. Betrayed
25. Suspicious
26. Obsessed
27. Overthinking
28. In Denial
29. Unbothered
30. Exhausted
31. Delulu
32. Soft-Launched
33. Caught Off Guard
34. Gaslighted
35. Validated
36. Misunderstood
37. Petty
38. Salty
39. Pressed
40. Shook
41. Gassed Up
42. Lowkey Scared
43. Highkey Annoyed
44. Deadpan
45. Passive Aggressive
46. Oversharing
47. Social Battery Dead
48. Main Character Feeling
49. Villain Arc Starting
50. Caught in 4K Feeling

---

# 🌙 CATEGORY 16: LATE NIGHT / VIBE

> Night-time, sleepover, and chill session references

1. 3AM Thoughts
2. Midnight Snack
3. Sleep Paralysis
4. Insomnia
5. Alarm Snoozed
6. Netflix Autoplay
7. Phone Brightness at Max
8. Falling Asleep on Call
9. Lights Off Conversation
10. Group Chat at 2AM
11. Sneaking Downstairs
12. Horror Movie Night
13. Ghost Stories
14. Dare at Midnight
15. Sleeping Bag
16. Pillow Fight
17. Whispering So Parents Don't Hear
18. Morning Breath
19. Forgetting to Sleep
20. Sleepover Drama
21. Charging Phone Overnight
22. Dreams That Feel Real
23. Waking Up Confused
24. Sleep Talking
25. Doomscrolling
26. 4AM Hunger
27. Blanket Stolen
28. Cold Room
29. Neighbourhood Dog Barking
30. Random Loud Car Outside
31. Stars Through the Window
32. Late Night Walk
33. Dark Hallway
34. Bathroom at Night (terrifying)
35. Night Shift Worker
36. Owl
37. Moonlight
38. Streetlight
39. Empty Street
40. Quiet Neighbourhood
41. Night Sky
42. Campfire
43. Fireflies
44. Late Night Drive
45. Radio at Night
46. Neon Lights
47. City at Night
48. Rooftop Hangout
49. Balcony at Midnight
50. Stargazing

---

## 🎯 IMPOSTOR SPECIAL RULES

### Double Impostor Mode
- Two players receive "YOU ARE THE IMPOSTOR"
- They do NOT know each other
- Must independently blend in
- If both survive the vote — impostors win together

### Hint Token Rule
- Impostor can whisper "HINT" to the host once per game
- Host privately gives one vague hint (one related word only)
- Civilians don't know a hint was given

### Last Stand Rule
- If impostor is caught — they get ONE final guess at the secret word
- Correct guess = impostor still wins
- Wrong guess = civilians win

### Alliance Twist (Chaos Setting)
- One civilian is secretly told who the impostor is
- They must decide: help civilians catch them OR secretly protect the impostor for a reward

---

## 📊 SCORING SYSTEM

```
Civilian correctly votes impostor out  →  +2 points each civilian
Impostor survives the vote             →  +3 points impostor
Impostor guesses word correctly        →  +4 points impostor
Civilian votes wrong person            →  -1 point that civilian
Impostor correctly identified early    →  +1 bonus to fastest voter
```

---

## 🔄 GAME LOGIC STRUCTURE

```javascript
// Categories available
const categories = [
  "gaming",
  "tiktok_memes",
  "foods",
  "brands_sneakers",
  "movies_shows",
  "school_life",
  "countries_cities",
  "family_scenarios",
  "music",
  "superheroes_villains",
  "sports",
  "social_media",
  "science_school",
  "random_objects",
  "reactions_emotions",
  "late_night_vibe"
]

// Game flow
function startImpostorRound(players, category) {
  const word = getRandomWord(category)
  const impostorCount = getImpostorCount(players.length) // AUTO: 1 for ≤4, 2 for 5+
  const impostors = assignImpostors(players, impostorCount)

  players.forEach(player => {
    if (impostors.includes(player)) {
      showScreen(player, "🚨 YOU ARE THE IMPOSTOR")
    } else {
      showScreen(player, `🔑 SECRET WORD: ${word}`)
    }
  })
}

// When wheel lands on Impostor Mode
// → Pick category
// → Assign roles
// → Start clue round
// → Start vote
// → Reveal + score
```

---

---

---

# 🛠️ HOW TO BUILD IMPOSTOR MODE — FULL DEV GUIDE

> Step by step. From zero to working game. No experience needed to follow this.

---

## 📦 TECH STACK RECOMMENDATION

```
Frontend:     React Native (iOS + Android from one codebase)
Navigation:   React Navigation
State:        useState + useContext (no Redux needed)
Storage:      AsyncStorage (save scores locally)
Animations:   React Native Reanimated
Timer:        Custom countdown hook
Words Data:   Local JSON file (no backend needed to start)
```

> ✅ You can build this entire mode with NO backend. Everything runs on one device passed around.

---

## 🗂️ FOLDER STRUCTURE

```
/cousin-chaos
  /src
    /screens
      HomeScreen.js
      ImpostorSetupScreen.js
      CategorySelectScreen.js
      RoleRevealScreen.js
      ClueRoundScreen.js
      VoteScreen.js
      ResultScreen.js
    /components
      TimerBar.js
      PlayerCard.js
      WordRevealCard.js
      VoteButton.js
      ScoreBoard.js
    /data
      words.json
    /hooks
      useTimer.js
      useGameState.js
    /utils
      assignRoles.js
      getRandomWord.js
      calculateScores.js
    /context
      GameContext.js
  App.js
```

---

## 📁 STEP 1 — SET UP YOUR WORD DATA

Create `/src/data/words.json` like this:

```json
{
  "gaming": [
    "Respawn", "Headshot", "Loot Box", "Noob", "Final Boss",
    "Health Bar", "Speedrun", "Controller", "Rage Quit", "Glitch"
  ],
  "foods": [
    "Pepperoni Pizza", "Sushi Roll", "Ramen", "Fried Chicken",
    "Burger", "Tacos", "Shawarma", "Jollof Rice", "Pancakes"
  ],
  "anime": [
    "Naruto", "Demon Slayer", "Attack on Titan", "Death Note",
    "One Piece", "Jujutsu Kaisen", "Dragon Ball Z", "My Hero Academia"
  ],
  "movies": [
    "Squid Game", "Money Heist", "Breaking Bad", "Inception",
    "The Matrix", "Interstellar", "Parasite", "The Dark Knight"
  ]
}
```

> Add all 16 categories from this file into that JSON. That's your entire word database.

---

## 🎮 STEP 2 — GAME STATE (useGameState hook)

Create `/src/hooks/useGameState.js`:

```javascript
import { useState } from 'react'

export default function useGameState() {
  const [players, setPlayers] = useState([])       // ["Ali", "Sara", "Zain"]
  const [category, setCategory] = useState(null)   // "gaming"
  const [secretWord, setSecretWord] = useState('')  // "Respawn"
  const [impostorIndex, setImpostorIndex] = useState(null) // which player is impostor
  const [currentPlayerIndex, setCurrentPlayerIndex] = useState(0)
  const [phase, setPhase] = useState('setup')
  // phases: setup → category → reveal → clues → vote → result
  const [scores, setScores] = useState({})
  const [votes, setVotes] = useState({})

  return {
    players, setPlayers,
    category, setCategory,
    secretWord, setSecretWord,
    impostorIndex, setImpostorIndex,
    currentPlayerIndex, setCurrentPlayerIndex,
    phase, setPhase,
    scores, setScores,
    votes, setVotes
  }
}
```

---

## 🎲 STEP 3 — ASSIGN ROLES (Core Logic)

Create `/src/utils/assignRoles.js`:

```javascript
import words from '../data/words.json'

// Auto-assign impostor count based on player count
export function getImpostorCount(playerCount) {
  if (playerCount <= 4) return 1  // 2-4 players = 1 impostor
  return 2                         // 5-12 players = 2 impostors
}

// Pick a random word from selected category
export function getRandomWord(category) {
  const list = words[category]
  return list[Math.floor(Math.random() * list.length)]
}

// Randomly assign impostor(s) from player list
export function assignImpostors(players, count = 1) {
  const shuffled = [...players].sort(() => Math.random() - 0.5)
  return shuffled.slice(0, count) // returns array of impostor names
}

// Build role map for all players
export function buildRoleMap(players, impostors, secretWord) {
  const roleMap = {}
  players.forEach(player => {
    if (impostors.includes(player)) {
      roleMap[player] = { role: 'impostor', display: '🚨 YOU ARE THE IMPOSTOR' }
    } else {
      roleMap[player] = { role: 'civilian', display: `🔑 SECRET WORD: ${secretWord}` }
    }
  })
  return roleMap
}
```

---

## ⏱️ STEP 4 — COUNTDOWN TIMER (Hook)

Create `/src/hooks/useTimer.js`:

```javascript
import { useState, useEffect, useRef } from 'react'

export default function useTimer(initialSeconds, onExpire) {
  const [seconds, setSeconds] = useState(initialSeconds)
  const [running, setRunning] = useState(false)
  const intervalRef = useRef(null)

  useEffect(() => {
    if (running) {
      intervalRef.current = setInterval(() => {
        setSeconds(prev => {
          if (prev <= 1) {
            clearInterval(intervalRef.current)
            setRunning(false)
            onExpire && onExpire()
            return 0
          }
          return prev - 1
        })
      }, 1000)
    }
    return () => clearInterval(intervalRef.current)
  }, [running])

  const start = () => setRunning(true)
  const pause = () => setRunning(false)
  const reset = (newSeconds) => {
    setRunning(false)
    setSeconds(newSeconds || initialSeconds)
  }

  return { seconds, start, pause, reset, running }
}
```

---

## 📱 STEP 5 — SCREENS BREAKDOWN

### Screen 1: Setup Screen
```
What it does:
- Input field: Add player names (3–12 players)
- Button: Add Player
- Button: Start Game
- Shows list of added players
- Button: Remove player (swipe or X)

Key state: players[]
On press Start → navigate to CategorySelectScreen
```

### Screen 2: Category Select Screen
```
What it does:
- Grid of category cards (Food, Gaming, Anime, etc.)
- Each card shows category name + icon + word count
- Tap to select
- Settings toggle: Double Impostor ON/OFF
- Settings toggle: Hint Token ON/OFF
- Settings toggle: Timer duration (3/5/7/10 min)
- Button: START ROUND

Key state: category, settings
On press START → assignRoles() → navigate to RoleRevealScreen
```

### Screen 3: Role Reveal Screen
```
What it does:
- Shows: "Pass phone to [PlayerName]"
- Big REVEAL button (tap to see your role)
- Screen goes dark/blurred by default
- On tap: animate reveal → show role (civilian sees word, impostor sees alert)
- Hold to read, then tap DONE
- Automatically advances to next player
- When all players done → navigate to ClueRoundScreen

Key logic:
- currentPlayerIndex increments each time
- roleMap[players[currentPlayerIndex]].display shown
- After last player → phase = 'clues'
```

### Screen 4: Clue Round Screen
```
What it does:
- Shows current player's name
- Timer bar running at top (from selected duration)
- Shows round number
- Players give verbal clues (no app interaction needed here)
- Button: Next Player Turn
- When all players given clues → Button: GO TO VOTE

Key state: currentPlayerIndex, timer
Note: This screen is mostly a visual aid — actual clues are spoken out loud
```

### Screen 5: Vote Screen
```
What it does:
- Shows all player names as vote buttons
- Each player votes for who they think is the impostor
- Votes are counted
- Player with most votes = eliminated
- Button: REVEAL RESULT

Key logic:
votes = { "Ali": 3, "Sara": 1, "Zain": 0 }
eliminated = player with highest vote count
```

### Screen 6: Result Screen
```
What it does:
- Dramatic reveal animation
- Shows: WHO WAS THE IMPOSTOR
- Shows: SECRET WORD WAS ___
- If impostor caught → Civilians Win screen
- If impostor survived → Impostor Wins screen
- If Last Stand rule ON → show impostor guess input
- Update scores
- Button: PLAY AGAIN (same players)
- Button: NEW GAME
```

---

## 🗳️ STEP 6 — VOTING LOGIC

```javascript
// /src/utils/calculateScores.js

export function calculateVoteResult(votes) {
  // votes = { playerName: voteCount }
  const sorted = Object.entries(votes).sort((a, b) => b[1] - a[1])
  return sorted[0][0] // returns name with most votes
}

export function updateScores(scores, players, eliminated, impostors, impostorGuessedCorrectly = false) {
  const newScores = { ...scores }
  const impostorCaught = impostors.includes(eliminated)

  if (impostorCaught && !impostorGuessedCorrectly) {
    // Civilians win
    players.forEach(p => {
      if (!impostors.includes(p)) {
        newScores[p] = (newScores[p] || 0) + 2
      }
    })
  } else if (!impostorCaught) {
    // Impostor survives
    impostors.forEach(p => {
      newScores[p] = (newScores[p] || 0) + 3
    })
  } else if (impostorGuessedCorrectly) {
    // Impostor caught but guessed word
    impostors.forEach(p => {
      newScores[p] = (newScores[p] || 0) + 4
    })
  }

  return newScores
}
```

---

## 🎨 STEP 7 — UI COMPONENTS

### WordRevealCard.js
```javascript
import React, { useState } from 'react'
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native'

export default function WordRevealCard({ playerName, displayText, onDone }) {
  const [revealed, setRevealed] = useState(false)

  return (
    <View style={styles.card}>
      <Text style={styles.title}>Pass phone to</Text>
      <Text style={styles.playerName}>{playerName}</Text>

      {!revealed ? (
        <TouchableOpacity
          style={styles.revealBtn}
          onPress={() => setRevealed(true)}
        >
          <Text style={styles.revealText}>TAP TO REVEAL YOUR ROLE</Text>
        </TouchableOpacity>
      ) : (
        <View style={styles.roleContainer}>
          <Text style={styles.roleText}>{displayText}</Text>
          <TouchableOpacity style={styles.doneBtn} onPress={onDone}>
            <Text style={styles.doneText}>DONE — PASS PHONE</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#0f0f0f',
    padding: 30
  },
  title: { color: '#888', fontSize: 16, marginBottom: 8 },
  playerName: { color: '#fff', fontSize: 32, fontWeight: 'bold', marginBottom: 40 },
  revealBtn: {
    backgroundColor: '#6c47ff',
    paddingVertical: 18,
    paddingHorizontal: 36,
    borderRadius: 16
  },
  revealText: { color: '#fff', fontSize: 16, fontWeight: '700' },
  roleContainer: { alignItems: 'center', gap: 24 },
  roleText: { color: '#fff', fontSize: 22, fontWeight: 'bold', textAlign: 'center' },
  doneBtn: {
    backgroundColor: '#22c55e',
    paddingVertical: 14,
    paddingHorizontal: 28,
    borderRadius: 12
  },
  doneText: { color: '#fff', fontSize: 15, fontWeight: '700' }
})
```

### TimerBar.js
```javascript
import React, { useEffect, useRef } from 'react'
import { View, Animated, StyleSheet } from 'react-native'

export default function TimerBar({ duration, onExpire }) {
  const width = useRef(new Animated.Value(100)).current

  useEffect(() => {
    Animated.timing(width, {
      toValue: 0,
      duration: duration * 1000,
      useNativeDriver: false
    }).start(({ finished }) => {
      if (finished) onExpire && onExpire()
    })
  }, [])

  const backgroundColor = width.interpolate({
    inputRange: [0, 30, 100],
    outputRange: ['#ef4444', '#f59e0b', '#22c55e']
  })

  return (
    <View style={styles.track}>
      <Animated.View
        style={[
          styles.bar,
          {
            width: width.interpolate({
              inputRange: [0, 100],
              outputRange: ['0%', '100%']
            }),
            backgroundColor
          }
        ]}
      />
    </View>
  )
}

const styles = StyleSheet.create({
  track: { height: 8, backgroundColor: '#333', borderRadius: 4, overflow: 'hidden' },
  bar: { height: '100%', borderRadius: 4 }
})
```

---

## 🔄 STEP 8 — FULL GAME FLOW (navigation map)

```
App.js
  └── Stack Navigator
        ├── HomeScreen
        │     └── [Press "Impostor Mode"] → ImpostorSetupScreen
        │
        ├── ImpostorSetupScreen
        │     └── [Add players, press Start] → CategorySelectScreen
        │
        ├── CategorySelectScreen
        │     └── [Select category + settings, press Start Round]
        │           → assignRoles() runs here
        │           → buildRoleMap() runs here
        │           → RoleRevealScreen
        │
        ├── RoleRevealScreen
        │     └── [Each player peeks role, press Done]
        │           → loops through all players
        │           → after last player → ClueRoundScreen
        │
        ├── ClueRoundScreen
        │     └── [Timer runs, players give clues verbally]
        │           → [Press Go To Vote] → VoteScreen
        │
        ├── VoteScreen
        │     └── [Each player votes]
        │           → calculateVoteResult() runs
        │           → [Press Reveal] → ResultScreen
        │
        └── ResultScreen
              └── [Show winner, update scores]
                    → [Play Again] → CategorySelectScreen (same players)
                    → [New Game] → ImpostorSetupScreen
```

---

## 🚀 STEP 9 — BUILD & LAUNCH CHECKLIST

```
✅ Set up React Native project (npx react-native init CousinChaos)
✅ Install React Navigation (npm install @react-navigation/native)
✅ Create words.json with all 16 categories from this file
✅ Build useGameState hook
✅ Build assignRoles + getRandomWord utils
✅ Build useTimer hook
✅ Build all 6 screens
✅ Build TimerBar component
✅ Build WordRevealCard component
✅ Build VoteButton component
✅ Wire navigation between all screens
✅ Test with 3 players minimum
✅ Test Double Impostor mode
✅ Test Last Stand (impostor guess) flow
✅ Add sound effects (optional but 🔥)
✅ Add animations on role reveal (optional)
✅ Test on real device (not just simulator)
✅ Submit to App Store / Google Play
```

---

## 💡 PRO TIPS FOR YOUR BUILD

- **Keep word reveal screen DARK** — players next to each other shouldn't accidentally see
- **Add a countdown 3-2-1 animation** before revealing role — builds suspense
- **Vibrate on impostor reveal** — `Vibration.vibrate(500)` — makes it feel real
- **Add a "tap to hide" button** — so player can quickly hide screen if someone looks
- **Store high scores in AsyncStorage** — players love seeing their win streaks
- **Add category thumbnails** — icons make category select screen look premium like the app you screenshotted
- **Sound effect on vote reveal** — dramatic drum roll sound = viral moment every time

---

---

---

# 🆕 NEW ADDITIONS

---

## 🎮 NEW GAME MODE: LIE DETECTOR

> Say 3 statements. Group votes which one is the lie. Simple. Brutal. Addictive.

### How It Works
1. Current player says **3 statements** about themselves out loud
2. Two must be TRUE. One must be a LIE
3. Group discusses for 30 seconds
4. Everyone votes simultaneously — which statement is the lie?
5. Reveal — whoever guessed right gets +1 point
6. Player who fooled the most people gets +2 points

### Examples
```
"I've never broken a bone"
"I once ate an entire pizza alone"        ← LIE
"I failed a test and didn't tell anyone"
```

### Statement Categories (app can suggest these)
- Personal facts
- School moments
- Family stories
- Gaming achievements
- Food experiences
- Travel / places visited
- Secret skills

### Scoring
```
Correct guess (civilian)    → +1 point
Fooled everyone (liar)      → +2 points
Nobody guessed right        → liar gets +3 points
```

### Code Logic
```javascript
// Lie Detector round structure
function startLieDetectorRound(players, currentPlayerIndex) {
  const currentPlayer = players[currentPlayerIndex]

  // currentPlayer speaks 3 statements out loud
  // After statements → start 30s discussion timer
  // Then show vote screen with Statement 1 / 2 / 3 buttons
  // Everyone except currentPlayer votes
  // Reveal which was the lie
  // Calculate scores
}
```

---

## ⚡ NEW FEATURES

---

### 🔥 1. STREAK SYSTEM

> Win 3 rounds in a row = unlock a special power card

**How It Works**
- Every player has a streak counter
- Win a round → streak goes up
- Lose a round → streak resets to 0
- Hit 3 in a row → **POWER CARD UNLOCKED** 🃏

**Power Cards (randomly assigned on streak)**

| Card | Effect |
|------|--------|
| 👁️ Peek | See who one player voted for |
| 🛡️ Shield | Block one vote against you this round |
| 🔄 Swap | Force two players to swap roles |
| ⏩ Skip | Skip your challenge, pass to next player |
| 💣 Double Down | Your vote counts as 2 this round |
| 🎯 Expose | Force one player to reveal their role card |
| ⚡ Instant Win | Win current round automatically (1x use) |

**Code Logic**
```javascript
// Streak tracking
const [streaks, setStreaks] = useState({}) // { "Ali": 2, "Sara": 0 }
const [powerCards, setPowerCards] = useState({}) // { "Ali": "shield" }

function updateStreak(playerName, won) {
  const current = streaks[playerName] || 0
  if (won) {
    const newStreak = current + 1
    setStreaks(prev => ({ ...prev, [playerName]: newStreak }))
    if (newStreak >= 3) {
      assignPowerCard(playerName)
      setStreaks(prev => ({ ...prev, [playerName]: 0 })) // reset after power card
    }
  } else {
    setStreaks(prev => ({ ...prev, [playerName]: 0 }))
  }
}

function assignPowerCard(playerName) {
  const cards = ['peek', 'shield', 'swap', 'skip', 'doubleDown', 'expose', 'instantWin']
  const random = cards[Math.floor(Math.random() * cards.length)]
  setPowerCards(prev => ({ ...prev, [playerName]: random }))
}
```

---

### 💀 2. REVENGE BUTTON

> Player who gets eliminated gets to choose the next challenge for everyone

**How It Works**
- Player gets voted out / eliminated
- Before leaving the round they get the **REVENGE BUTTON**
- They pick one punishment from a list that applies to ALL remaining players
- Then they sit out

**Revenge Options (shown as buttons)**
```
☠️ Everyone loses 1 point
🎯 Next round — no hints allowed for anyone
🔄 Randomly reassign everyone's role
⏱️ Timer cuts in half next round
🃏 All power cards wiped
😂 Everyone must answer in an accent next round
🔇 No talking for 10 seconds before next round starts
```

**Code Logic**
```javascript
function triggerRevengeButton(eliminatedPlayer, onRevengeSelected) {
  // Show revenge options screen to eliminatedPlayer only
  // They tap one option
  // Apply that effect to game state before next round starts
  // Show everyone what revenge was chosen
}
```

---

### 🃏 3. WILD CARD

> A random event that flips the round mid-game. Nobody sees it coming.

**How It Works**
- Wild Card can trigger at random between rounds (25% chance)
- OR host can manually trigger it
- Completely changes the rules for that one round

**Wild Card Events**
```
🔀 ROLE SWAP       — Impostor and one civilian swap roles mid-round
⏪ REWIND          — Redo the last round with a new word
👀 GLASS HOUSES    — All roles revealed for 5 seconds then hidden again
🙊 SILENT ROUND    — No speaking allowed — clues must be acted out only
🎭 DOUBLE BLUFF    — Civilians must lie in their clues, impostor tells truth
⚡ SPEED ROUND     — Timer cuts to 60 seconds, one clue each max
🗳️ BLIND VOTE      — Voting happens with eyes closed, no discussion
💬 ONE WORD ONLY   — Every clue must be exactly one word, no phrases
```

**Code Logic**
```javascript
const wildCards = [
  { id: 'roleSwap', label: '🔀 ROLE SWAP', description: 'Impostor and one civilian swap roles' },
  { id: 'silentRound', label: '🙊 SILENT ROUND', description: 'No speaking — act your clues only' },
  { id: 'doubleBluff', label: '🎭 DOUBLE BLUFF', description: 'Civilians lie, impostor tells truth' },
  { id: 'speedRound', label: '⚡ SPEED ROUND', description: 'Timer cuts to 60 seconds' },
  { id: 'blindVote', label: '🗳️ BLIND VOTE', description: 'Vote with no discussion' },
  { id: 'oneWordOnly', label: '💬 ONE WORD ONLY', description: 'Each clue = exactly one word' },
]

function triggerWildCard() {
  const chance = Math.random()
  if (chance <= 0.25) { // 25% trigger chance
    const card = wildCards[Math.floor(Math.random() * wildCards.length)]
    applyWildCardEffect(card.id)
    return card
  }
  return null
}
```

---

### ✍️ 4. CUSTOM WORDS

> Players add their own inside jokes, nicknames, and personal words to Impostor mode

**How It Works**
- Before round starts — option to add custom words
- Any player can type in a custom word
- Custom words go into a "Custom" category
- Can mix custom + official category in same round

**Use Cases**
- Inside jokes between cousins
- Nicknames of people they know
- Local slang
- Events that happened ("The Barbecue Incident")
- School memories

**UI Flow**
```
Category Select Screen
  → [+ Add Custom Word] button
  → Input field appears
  → Player types word → press Add
  → Word added to custom list
  → Can add up to 20 custom words
  → Toggle: "Include Custom Words" ON/OFF
```

**Code Logic**
```javascript
const [customWords, setCustomWords] = useState([])

function addCustomWord(word) {
  if (word.trim() && customWords.length < 20) {
    setCustomWords(prev => [...prev, word.trim()])
  }
}

function getWordPool(category, includeCustom) {
  const official = words[category] || []
  const custom = includeCustom ? customWords : []
  return [...official, ...custom]
}

// Then in getRandomWord:
function getRandomWord(category, includeCustom = false) {
  const pool = getWordPool(category, includeCustom)
  return pool[Math.floor(Math.random() * pool.length)]
}
```

---

### 🔊 5. SOUND EFFECTS PACK

> Dramatic music, buzzer, countdown sounds — makes every moment hit harder

**Sound List**

| Moment | Sound |
|--------|-------|
| Game starts | Epic intro drum hit |
| Role reveal (civilian) | Soft chime ✅ |
| Role reveal (impostor) | Dramatic sting 🚨 |
| Timer ticking (last 10s) | Fast ticking sound ⏱️ |
| Timer expires | Buzzer / alarm 🔔 |
| Voting starts | Suspense music loop |
| Vote reveal | Drum roll → crash |
| Civilians win | Victory fanfare 🎉 |
| Impostor wins | Evil laugh / dark tone 😈 |
| Wild Card trigger | Chaos sound effect 🃏 |
| Power Card unlocked | Level up sound ⚡ |
| Streak achieved | Crowd cheer 🔥 |
| Revenge button pressed | Evil sting 💀 |

**Code Logic (React Native)**
```javascript
// Install: npm install react-native-sound
import Sound from 'react-native-sound'

// Preload sounds
const sounds = {
  impostorReveal: new Sound('impostor_reveal.mp3', Sound.MAIN_BUNDLE),
  civilianReveal: new Sound('civilian_reveal.mp3', Sound.MAIN_BUNDLE),
  timerTick: new Sound('timer_tick.mp3', Sound.MAIN_BUNDLE),
  voteReveal: new Sound('vote_reveal.mp3', Sound.MAIN_BUNDLE),
  civiliansWin: new Sound('civilians_win.mp3', Sound.MAIN_BUNDLE),
  impostorWins: new Sound('impostor_wins.mp3', Sound.MAIN_BUNDLE),
  wildCard: new Sound('wild_card.mp3', Sound.MAIN_BUNDLE),
  powerCard: new Sound('power_card.mp3', Sound.MAIN_BUNDLE),
}

function playSound(key) {
  sounds[key]?.play()
}

// Usage examples:
// playSound('impostorReveal') — when impostor sees their screen
// playSound('voteReveal')     — when result is shown
// playSound('wildCard')       — when wild card triggers
```

> 🎵 Use royalty-free sound effects from **Freesound.org** or **Mixkit.co** — both free for apps

---

---

# 📱 ONE PHONE PASS — ROLE REVEAL SYSTEM

> ⚠️ CRITICAL: All players are on the SAME phone. If roles show all at once — everyone sees everyone's word. This BREAKS the game.

## The Problem
```
❌ WRONG WAY:
Show all roles on one screen → everyone standing around sees each other's role
→ Game ruined before it starts
```

## The Solution — ONE BY ONE PASS SYSTEM
```
✅ CORRECT WAY:
Phone shows: "Pass to [PlayerName] → They tap to reveal → They tap done → Next player"
Nobody else sees. Phone keeps moving. Mystery stays intact.
```

---

## 📲 HOW THE PASS SYSTEM WORKS (Step by Step)

```
STEP 1 — App shows holding screen:
┌─────────────────────────────┐
│                             │
│   📱 PASSING TO...          │
│                             │
│        A L I                │
│                             │
│   [Everyone else look away] │
│                             │
│   ──────────────────────    │
│                             │
│      [ TAP TO REVEAL ]      │
│                             │
└─────────────────────────────┘

STEP 2 — Ali taps. Screen shows role:
┌─────────────────────────────┐
│                             │
│   🔑 SECRET WORD:           │
│                             │
│        RAMEN                │
│                             │
│   You are a CIVILIAN        │
│   Remember this word.       │
│   Tell no one.              │
│                             │
│   [ DONE — PASS PHONE ]     │
│                             │
└─────────────────────────────┘

     — OR for the impostor —

┌─────────────────────────────┐
│                             │
│   🚨 YOU ARE THE            │
│      IMPOSTOR               │
│                             │
│   You do NOT know           │
│   the secret word.          │
│   Blend in. Fake it.        │
│   Don't get caught.         │
│                             │
│   [ DONE — PASS PHONE ]     │
│                             │
└─────────────────────────────┘

STEP 3 — After Ali taps DONE:
┌─────────────────────────────┐
│                             │
│   ✅ Ali has seen their     │
│      role                   │
│                             │
│   📱 PASSING TO...          │
│                             │
│        S A R A              │
│                             │
│   [ TAP TO REVEAL ]         │
│                             │
└─────────────────────────────┘

→ Repeats for every player
→ Last player taps DONE
→ Game begins automatically
```

---

## 🔒 PRIVACY RULES BUILT INTO THE UI

```
1. Screen goes BLACK immediately when player taps DONE
   → No one next to them can glance and read the word

2. "Everyone look away" message shown BEFORE each player taps
   → Social reminder baked into the UI

3. Auto-hide after 5 seconds
   → Even if player forgets to tap DONE, screen hides itself

4. No going back
   → Once a player taps DONE, they cannot re-open their role
   → Prevents "let me check again" which tips off the impostor

5. Tap-to-reveal (not swipe)
   → Single deliberate tap required — no accidental reveals
```

---

## 💻 FULL CODE — ONE BY ONE PASS SYSTEM

```javascript
// RoleRevealScreen.js — Complete implementation

import React, { useState, useEffect } from 'react'
import {
  View, Text, TouchableOpacity,
  StyleSheet, BackHandler
} from 'react-native'

export default function RoleRevealScreen({ route, navigation }) {
  const { players, roleMap } = route.params

  const [currentIndex, setCurrentIndex] = useState(0)
  const [phase, setPhase] = useState('waiting')
  // phases: 'waiting' → 'revealed' → next player or game start

  // Disable Android back button — no going back during reveal
  useEffect(() => {
    const backHandler = BackHandler.addEventListener(
      'hardwareBackPress', () => true // blocks back press
    )
    return () => backHandler.remove()
  }, [])

  const currentPlayer = players[currentIndex]
  const currentRole = roleMap[currentPlayer]

  function handleReveal() {
    setPhase('revealed')
  }

  function handleDone() {
    // Auto black screen then move to next
    setPhase('waiting')

    if (currentIndex + 1 < players.length) {
      setCurrentIndex(currentIndex + 1) // next player
    } else {
      navigation.navigate('ClueRoundScreen', { players, roleMap }) // all done
    }
  }

  return (
    <View style={styles.container}>

      {phase === 'waiting' && (
        <View style={styles.waitingScreen}>
          <Text style={styles.label}>📱 PASSING TO</Text>
          <Text style={styles.playerName}>{currentPlayer}</Text>
          <Text style={styles.lookAway}>Everyone else look away 👀</Text>
          <TouchableOpacity style={styles.revealBtn} onPress={handleReveal}>
            <Text style={styles.revealBtnText}>TAP TO REVEAL YOUR ROLE</Text>
          </TouchableOpacity>
          <Text style={styles.progress}>
            {currentIndex + 1} / {players.length}
          </Text>
        </View>
      )}

      {phase === 'revealed' && (
        <View style={[
          styles.revealedScreen,
          currentRole.role === 'impostor'
            ? styles.impostorBg
            : styles.civilianBg
        ]}>
          {currentRole.role === 'civilian' ? (
            <>
              <Text style={styles.roleLabel}>🔑 SECRET WORD</Text>
              <Text style={styles.secretWord}>{currentRole.word}</Text>
              <Text style={styles.roleInstruction}>
                You are a CIVILIAN{'\n'}
                Remember this word.{'\n'}
                Tell no one.
              </Text>
            </>
          ) : (
            <>
              <Text style={styles.impostorAlert}>🚨 YOU ARE THE</Text>
              <Text style={styles.impostorTitle}>IMPOSTOR</Text>
              <Text style={styles.roleInstruction}>
                You do NOT know the secret word.{'\n'}
                Blend in. Fake your clues.{'\n'}
                Don't get caught.
              </Text>
            </>
          )}

          <TouchableOpacity style={styles.doneBtn} onPress={handleDone}>
            <Text style={styles.doneBtnText}>✅ DONE — PASS THE PHONE</Text>
          </TouchableOpacity>
        </View>
      )}

    </View>
  )
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0a0a0a' },

  // Waiting screen
  waitingScreen: {
    flex: 1, justifyContent: 'center',
    alignItems: 'center', padding: 30, gap: 16
  },
  label: { color: '#888', fontSize: 16 },
  playerName: {
    color: '#ffffff', fontSize: 42,
    fontWeight: '900', letterSpacing: 4
  },
  lookAway: { color: '#f59e0b', fontSize: 14, marginBottom: 20 },
  revealBtn: {
    backgroundColor: '#6c47ff', paddingVertical: 20,
    paddingHorizontal: 40, borderRadius: 18
  },
  revealBtnText: { color: '#fff', fontSize: 18, fontWeight: '800' },
  progress: { color: '#555', fontSize: 13, marginTop: 20 },

  // Revealed screen
  revealedScreen: {
    flex: 1, justifyContent: 'center',
    alignItems: 'center', padding: 30, gap: 20
  },
  civilianBg: { backgroundColor: '#0f2417' },
  impostorBg: { backgroundColor: '#1f0a0a' },

  roleLabel: { color: '#22c55e', fontSize: 18, fontWeight: '700' },
  secretWord: {
    color: '#ffffff', fontSize: 48,
    fontWeight: '900', textAlign: 'center'
  },
  impostorAlert: { color: '#ef4444', fontSize: 22, fontWeight: '800' },
  impostorTitle: {
    color: '#ef4444', fontSize: 52,
    fontWeight: '900', letterSpacing: 3
  },
  roleInstruction: {
    color: '#aaa', fontSize: 16,
    textAlign: 'center', lineHeight: 26
  },
  doneBtn: {
    backgroundColor: '#1e1e1e', borderWidth: 1,
    borderColor: '#333', paddingVertical: 16,
    paddingHorizontal: 32, borderRadius: 14,
    marginTop: 20
  },
  doneBtnText: { color: '#fff', fontSize: 16, fontWeight: '700' }
})
```

---

## 🔑 KEY POINTS FOR DEVELOPER

```
✅ NEVER show all roles at once on one screen
✅ Always show one player at a time
✅ Black out screen between each player
✅ Disable back button during reveal phase
✅ Auto-hide role after 5 seconds even if player forgets
✅ Show "look away" message before every reveal
✅ No way to re-open a seen role
✅ Progress counter (2/5, 3/5) so players know how long left
✅ Different background color for impostor vs civilian reveal
   → Green tint = civilian
   → Red tint = impostor
   → Players next to each other can't see color without looking directly
```

---

*© Cousin Chaos App — Impostor Mode Full Dev Guide v2.0*
*Total: 16 Categories × 50 Words = 800 Words*
*New: Lie Detector Mode | Streak System | Revenge Button | Wild Card | Custom Words | Sound Pack*
*Core Fix: One-By-One Pass System — Single Device Multiplayer Done Right*
*Stack: React Native | No Backend Required | Single Device Multiplayer*
