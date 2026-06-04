class UserProfile {
  final String name;
  final int xp;
  final int level;

  const UserProfile({
    required this.name,
    required this.xp,
    required this.level,
  });

  UserProfile copyWith({String? name, int? xp, int? level}) {
    return UserProfile(
      name: name ?? this.name,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }
}
