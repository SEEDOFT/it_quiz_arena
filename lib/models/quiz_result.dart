class QuizResult {
  final int score;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final int timeSpent;

  QuizResult({
    required this.score,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    required this.timeSpent,
  });
}
