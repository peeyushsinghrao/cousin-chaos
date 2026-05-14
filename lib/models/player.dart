class Player {
  final String id;
  String name;
  int score; // useful for Trivia Battle later
  int skipTokens;

  Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.skipTokens = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'score': score,
        'skipTokens': skipTokens,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        name: json['name'],
        score: json['score'] ?? 0,
        skipTokens: json['skipTokens'] ?? 0,
      );
}
