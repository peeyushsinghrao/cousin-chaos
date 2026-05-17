const List<List<int>> kLudoMainPath = [
  [6,14],[6,13],[6,12],[6,11],[6,10],[6,9],
  [6,8],[5,8],[4,8],[3,8],[2,8],[1,8],
  [0,8],
  [0,6],[1,6],[2,6],[3,6],[4,6],[5,6],
  [6,6],
  [6,5],[6,4],[6,3],[6,2],[6,1],[6,0],
  [8,0],[8,1],[8,2],[8,3],[8,4],[8,5],
  [8,6],
  [8,8],[9,8],[10,8],[11,8],[12,8],[13,8],
  [14,8],
  [14,6],[13,6],[12,6],[11,6],[10,6],[9,6],
  [8,6],
  [8,9],[8,10],[8,11],[8,12],[8,13],[8,14],
];

const List<List<int>> kBlueHomeCol   = [[7,13],[7,12],[7,11],[7,10],[7,9],[7,8]];
const List<List<int>> kRedHomeCol    = [[1,7],[2,7],[3,7],[4,7],[5,7],[6,7]];
const List<List<int>> kGreenHomeCol  = [[13,7],[12,7],[11,7],[10,7],[9,7],[8,7]];
const List<List<int>> kYellowHomeCol = [[7,1],[7,2],[7,3],[7,4],[7,5],[7,6]];

const List<int> kPlayerEntrySquares  = [0, 13, 26, 39];
const List<int> kHomeColEntry        = [51, 12, 25, 38];

const Set<int> kSafeSquares          = {0, 8, 13, 21, 26, 34, 39, 47};
const Set<int> kChaosTiles           = {5, 18, 31, 44};
const int kWormholeA                 = 3;
const int kWormholeB                 = 29;
const int kJailSquare                = 42;
const int kGiftSquare                = 16;

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

const List<Map<String, dynamic>> kEventCardsData = [
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
