import 'dart:math';

class ChaosEvent {
  final String title;
  final String description;
  final String emoji;
  final ChaosEventType type;

  const ChaosEvent({
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
  });
}

enum ChaosEventType { everyone, swap, skip, double, reverse, wildcard }

class ChaosEventService {
  static const List<ChaosEvent> _events = [
    ChaosEvent(
      title: 'EVERYONE IN!',
      description: 'Everyone must do the next challenge together!',
      emoji: '🎉',
      type: ChaosEventType.everyone,
    ),
    ChaosEvent(
      title: 'SWAP CHAOS!',
      description: 'The next two players swap their challenges!',
      emoji: '🔄',
      type: ChaosEventType.swap,
    ),
    ChaosEvent(
      title: 'DOUBLE DARE!',
      description: 'The current player must complete TWO challenges!',
      emoji: '⚡',
      type: ChaosEventType.double,
    ),
    ChaosEvent(
      title: 'REVERSE!',
      description: 'The turn order reverses! Play backwards!',
      emoji: '⏪',
      type: ChaosEventType.reverse,
    ),
    ChaosEvent(
      title: 'WILDCARD!',
      description: 'The player to your left picks your challenge type!',
      emoji: '🃏',
      type: ChaosEventType.wildcard,
    ),
    ChaosEvent(
      title: 'CHAOS SKIP!',
      description: 'Everyone gets one free skip token!',
      emoji: '🎲',
      type: ChaosEventType.skip,
    ),
    ChaosEvent(
      title: 'TRUTH STORM!',
      description: 'Next 3 players must all answer a truth!',
      emoji: '💡',
      type: ChaosEventType.everyone,
    ),
    ChaosEvent(
      title: 'DARE RAIN!',
      description: 'Next 3 players must all complete a dare!',
      emoji: '🔥',
      type: ChaosEventType.everyone,
    ),
    ChaosEvent(
      title: 'SECRET KEEPER!',
      description: 'The next player whispers their answer to only one person!',
      emoji: '🤫',
      type: ChaosEventType.wildcard,
    ),
    ChaosEvent(
      title: 'CHAOS VOTE!',
      description: 'The group votes on whether the player did the dare well enough!',
      emoji: '🗳️',
      type: ChaosEventType.everyone,
    ),
  ];

  static final _random = Random();

  static ChaosEvent? maybeGetEvent({double probability = 0.15}) {
    if (_random.nextDouble() < probability) {
      return _events[_random.nextInt(_events.length)];
    }
    return null;
  }

  static ChaosEvent getRandomEvent() {
    return _events[_random.nextInt(_events.length)];
  }
}
