class UserStats {
  final int totalQuizzes;
  final int totalCorrect;
  final int totalWrong;
  final int highestScore;
  final int bestStreak;
  final int xp;
  final int level;
  final String? currentRank;
  final double overallAccuracy;

  const UserStats({
    required this.totalQuizzes,
    required this.totalCorrect,
    required this.totalWrong,
    required this.highestScore,
    required this.bestStreak,
    required this.xp,
    required this.level,
    this.currentRank,
    this.overallAccuracy = 0.0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalQuizzes: json['total_quizzes'] as int? ?? 0,
    totalCorrect: json['total_correct'] as int? ?? 0,
    totalWrong: json['total_wrong'] as int? ?? 0,
    highestScore: json['highest_score'] as int? ?? 0,
    bestStreak: json['best_streak'] as int? ?? 0,
    xp: json['xp'] as int? ?? 0,
    level: json['level'] as int? ?? 1,
    currentRank: json['current_rank'] as String?,
    overallAccuracy: (json['overall_accuracy'] as num?)?.toDouble() ?? 0.0,
  );
}
