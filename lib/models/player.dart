class Player {
  final String id;
  String name;
  int score;
  int skipTokens;
  int xp;

  Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.skipTokens = 0,
    this.xp = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'score': score,
        'skipTokens': skipTokens,
        'xp': xp,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        name: json['name'],
        score: json['score'] ?? 0,
        skipTokens: json['skipTokens'] ?? 0,
        xp: json['xp'] ?? 0,
      );
}
