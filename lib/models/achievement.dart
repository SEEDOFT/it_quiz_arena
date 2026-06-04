class Achievement {
  final int id;
  final String title;
  final String description;
  final String key;
  final int requiredValue;
  final String? icon;
  final int progress;
  final bool isUnlocked;
  final String? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.key,
    required this.requiredValue,
    this.icon,
    this.progress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressFraction =>
      requiredValue > 0 ? (progress / requiredValue).clamp(0.0, 1.0) : 0.0;

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    key: json['key'] as String? ?? '',
    requiredValue: json['required_value'] as int? ?? 0,
    icon: json['icon'] as String?,
    progress: json['progress'] as int? ?? 0,
    isUnlocked: json['is_unlocked'] as bool? ?? false,
    unlockedAt: json['unlocked_at'] as String?,
  );
}
