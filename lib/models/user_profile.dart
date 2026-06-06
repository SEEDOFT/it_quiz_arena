class UserProfile {
  final int id;
  final String name;
  final String username;
  final String email;
  final int xp;
  final int level;
  final int totalQuizzes;
  final int highestScore;
  final int bestStreak;
  final String? avatar;
  final String? currentRank;
  final String? nextRank;
  final int? nextRankXp;

  const UserProfile({
    this.id = 0,
    required this.name,
    required this.username,
    required this.email,
    this.xp = 0,
    this.level = 1,
    this.totalQuizzes = 0,
    this.highestScore = 0,
    this.bestStreak = 0,
    this.avatar,
    this.currentRank,
    this.nextRank,
    this.nextRankXp,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    username: json['username'] as String? ?? '',
    email: json['email'] as String? ?? '',
    xp: json['xp'] as int? ?? 0,
    level: json['level'] as int? ?? 1,
    totalQuizzes: json['total_quizzes'] as int? ?? 0,
    highestScore: json['highest_score'] as int? ?? 0,
    bestStreak: json['best_streak'] as int? ?? 0,
    avatar: json['avatar'] as String?,
    currentRank: json['current_rank'] as String?,
    nextRank: json['next_rank'] as String?,
    nextRankXp: json['next_rank_xp'] as int?,
  );

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
