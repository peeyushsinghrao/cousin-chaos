class Player {
  final String id;
  String name;
  int score; // useful for Trivia Battle later

  Player({
    required this.id,
    required this.name,
    this.score = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'score': score,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        name: json['name'],
        score: json['score'] ?? 0,
      );
}
