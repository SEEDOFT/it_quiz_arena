class Rank {
  final int id;
  final String title;
  final int requiredXp;
  final String? icon;

  const Rank({
    required this.id,
    required this.title,
    required this.requiredXp,
    this.icon,
  });

  factory Rank.fromJson(Map<String, dynamic> json) => Rank(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    requiredXp: json['required_xp'] as int? ?? 0,
    icon: json['icon'] as String?,
  );
}
