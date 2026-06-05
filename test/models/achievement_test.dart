import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/models/achievement.dart';

void main() {
  group('Achievement', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'id': 1,
        'title': 'First Steps',
        'description': 'Complete your first quiz',
        'key': 'first_quiz',
        'required_value': 1,
        'icon': 'trophy',
        'progress': 1,
        'is_unlocked': true,
        'unlocked_at': '2026-01-01T00:00:00.000000Z',
      };

      final a = Achievement.fromJson(json);

      expect(a.id, 1);
      expect(a.title, 'First Steps');
      expect(a.description, 'Complete your first quiz');
      expect(a.key, 'first_quiz');
      expect(a.requiredValue, 1);
      expect(a.icon, 'trophy');
      expect(a.progress, 1);
      expect(a.isUnlocked, true);
      expect(a.unlockedAt, '2026-01-01T00:00:00.000000Z');
    });

    test('fromJson handles locked achievement', () {
      final json = {
        'id': 2,
        'title': 'Dedicated Learner',
        'description': 'Complete 10 quizzes',
        'key': 'ten_quizzes',
        'required_value': 10,
        'icon': 'star',
        'progress': 3,
        'is_unlocked': false,
        'unlocked_at': null,
      };

      final a = Achievement.fromJson(json);

      expect(a.isUnlocked, false);
      expect(a.unlockedAt, null);
      expect(a.progress, 3);
    });

    test('progressFraction returns clamped value 0..1', () {
      final a = Achievement(
        id: 1,
        title: 'Test',
        description: 'Test',
        key: 'test',
        requiredValue: 10,
        progress: 5,
      );
      expect(a.progressFraction, 0.5);
    });

    test('progressFraction returns 1.0 when progress >= requiredValue', () {
      final a = Achievement(
        id: 1,
        title: 'Test',
        description: 'Test',
        key: 'test',
        requiredValue: 10,
        progress: 15,
      );
      expect(a.progressFraction, 1.0);
    });

    test('progressFraction returns 0 when requiredValue is 0', () {
      final a = Achievement(
        id: 1,
        title: 'Test',
        description: 'Test',
        key: 'test',
        requiredValue: 0,
        progress: 0,
      );
      expect(a.progressFraction, 0.0);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'description': 'Test',
        'key': 'test',
        'required_value': 5,
      };

      final a = Achievement.fromJson(json);
      expect(a.icon, null);
      expect(a.progress, 0);
      expect(a.isUnlocked, false);
      expect(a.unlockedAt, null);
    });

    test('fromJson handles null strings', () {
      final json = {
        'id': 1,
        'title': null,
        'description': null,
        'key': null,
        'required_value': 0,
      };

      final a = Achievement.fromJson(json);
      expect(a.title, '');
      expect(a.description, '');
      expect(a.key, '');
    });
  });
}
