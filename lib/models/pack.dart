class GameCardPrompt {
  final String id;
  final String text;
  final String type; // 'truth' or 'dare'

  GameCardPrompt({
    required this.id,
    required this.text,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type,
      };

  factory GameCardPrompt.fromJson(Map<String, dynamic> json) => GameCardPrompt(
        id: json['id'] ?? '',
        text: json['text'] ?? json['question'] ?? '',
        type: json['type'] ?? 'truth',
      );
}

class Pack {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isCustom;
  final bool is18Plus;
  final List<GameCardPrompt> prompts;

  Pack({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isCustom = false,
    this.is18Plus = false,
    required this.prompts,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'isCustom': isCustom,
        'is18Plus': is18Plus,
        'prompts': prompts.map((p) => p.toJson()).toList(),
      };

  factory Pack.fromJson(Map<String, dynamic> json) => Pack(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        emoji: json['emoji'] ?? '🎯',
        isCustom: json['isCustom'] ?? false,
        is18Plus: json['is18Plus'] ?? false,
        prompts: (json['prompts'] as List)
            .map((p) => GameCardPrompt.fromJson(p))
            .toList(),
      );
}
