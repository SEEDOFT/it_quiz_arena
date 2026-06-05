import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/models/course.dart';

void main() {
  group('Course', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'id': 1,
        'title': 'Programming',
        'description': 'Learn programming',
        'category': 'Programming',
        'difficulty': 'Beginner',
        'question_count': 20,
        'thumbnail': 'https://example.com/thumb.png',
      };

      final c = Course.fromJson(json);

      expect(c.id, 1);
      expect(c.title, 'Programming');
      expect(c.description, 'Learn programming');
      expect(c.category, 'Programming');
      expect(c.difficulty, 'Beginner');
      expect(c.questionCount, 20);
      expect(c.thumbnail, 'https://example.com/thumb.png');
    });

    test('fromJson handles missing thumbnail', () {
      final json = {
        'id': 2,
        'title': 'Networking',
        'description': 'Network basics',
        'category': 'Networking',
        'difficulty': 'Beginner',
        'question_count': 15,
      };

      final c = Course.fromJson(json);

      expect(c.id, 2);
      expect(c.title, 'Networking');
      expect(c.thumbnail, null);
    });

    test('fromJson handles absent question_count', () {
      final json = {
        'id': 3,
        'title': 'Databases',
        'description': 'DB basics',
        'category': 'Database',
        'difficulty': 'Intermediate',
      };

      final c = Course.fromJson(json);

      expect(c.questionCount, 0);
    });

    test('fromJson handles null title', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'description': null,
        'category': 'Test',
        'difficulty': 'Beginner',
      };

      final c = Course.fromJson(json);
      expect(c.description, '');
    });
  });
}
