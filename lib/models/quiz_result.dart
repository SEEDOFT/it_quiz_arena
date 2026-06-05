class QuizResult {
  final int sessionId;
  final int score;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int xpGained;
  final int? newLevel;
  final bool levelUp;

  const QuizResult({
    required this.sessionId,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.xpGained,
    this.newLevel,
    this.levelUp = false,
  });
}
