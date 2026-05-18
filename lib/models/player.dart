class Player {
  final String id;
  String name;
  String? emoji;
  int score;
  int skipTokens;

  Player({
    required this.id,
    required this.name,
    this.emoji,
    this.score = 0,
    this.skipTokens = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'score': score,
        'skipTokens': skipTokens,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'] as String?,
        score: json['score'] ?? 0,
        skipTokens: json['skipTokens'] ?? 0,
      );
}
