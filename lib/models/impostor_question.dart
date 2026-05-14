class ImpostorQuestion {
  final String civilianQuestion;
  final String impostorQuestion;

  const ImpostorQuestion({
    required this.civilianQuestion,
    required this.impostorQuestion,
  });

  factory ImpostorQuestion.fromJson(Map<String, dynamic> json) {
    return ImpostorQuestion(
      civilianQuestion: json['civilianQuestion'] as String,
      impostorQuestion: json['impostorQuestion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'civilianQuestion': civilianQuestion,
      'impostorQuestion': impostorQuestion,
    };
  }
}