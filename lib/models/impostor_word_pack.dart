import 'dart:convert';

class ImpostorWordPack {
  final String id;
  final String title;
  final List<String> words;
  final DateTime createdAt;

  ImpostorWordPack({
    required this.id,
    required this.title,
    required this.words,
    required this.createdAt,
  });

  ImpostorWordPack copyWith({
    String? id,
    String? title,
    List<String>? words,
    DateTime? createdAt,
  }) {
    return ImpostorWordPack(
      id: id ?? this.id,
      title: title ?? this.title,
      words: words ?? List<String>.from(this.words),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'words': words,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ImpostorWordPack.fromJson(Map<String, dynamic> json) {
    return ImpostorWordPack(
      id: json['id'] as String,
      title: json['title'] as String,
      words: List<String>.from(json['words'] as List<dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() => 'ImpostorWordPack(id: $id, title: $title, words: ${words.length})';
}
