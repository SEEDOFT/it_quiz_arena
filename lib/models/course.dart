class Course {
  final int id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int questionCount;
  final String? thumbnail;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.questionCount,
    this.thumbnail,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    category: json['category'] as String,
    difficulty: json['difficulty'] as String,
    questionCount: json['question_count'] as int? ?? 0,
    thumbnail: json['thumbnail'] as String?,
  );
}
