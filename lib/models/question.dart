class Question {
  final int id;
  final String question;
  final List<String> options;
  final int? correctAnswer;
  final String? explanation;
  final int points;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    this.correctAnswer,
    this.explanation,
    required this.points,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as int,
    question: json['question_text'] as String,
    options: List<String>.from(json['options']),
    correctAnswer: json['correct_answer'] as int?,
    explanation: json['explanation'] as String?,
    points: json['points'] as int? ?? 50,
  );
}
