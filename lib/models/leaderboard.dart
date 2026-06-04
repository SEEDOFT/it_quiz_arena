class LeaderboardEntry {
  final String playerName;
  final int xp;
  final int level;
  final String? rank;
  final int totalQuizzes;

  const LeaderboardEntry({
    required this.playerName,
    required this.xp,
    required this.level,
    this.rank,
    required this.totalQuizzes,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        playerName: json['player_name'] as String? ?? '',
        xp: json['xp'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        rank: json['rank'] as String?,
        totalQuizzes: json['total_quizzes'] as int? ?? 0,
      );
}
