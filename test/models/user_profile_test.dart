import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'id': 1,
        'name': 'Test User',
        'username': 'testuser',
        'email': 'test@example.com',
        'xp': 500,
        'level': 2,
        'total_quizzes': 10,
        'highest_score': 85,
        'best_streak': 5,
        'avatar': 'https://example.com/avatar.png',
        'current_rank': 'Specialist',
        'next_rank': 'Expert',
        'next_rank_xp': 700,
      };

      final u = UserProfile.fromJson(json);

      expect(u.id, 1);
      expect(u.name, 'Test User');
      expect(u.username, 'testuser');
      expect(u.email, 'test@example.com');
      expect(u.xp, 500);
      expect(u.level, 2);
      expect(u.totalQuizzes, 10);
      expect(u.highestScore, 85);
      expect(u.bestStreak, 5);
      expect(u.avatar, 'https://example.com/avatar.png');
      expect(u.currentRank, 'Specialist');
      expect(u.nextRank, 'Expert');
      expect(u.nextRankXp, 700);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'username': 'test',
        'email': 'test@test.com',
      };

      final u = UserProfile.fromJson(json);

      expect(u.xp, 0);
      expect(u.level, 1);
      expect(u.totalQuizzes, 0);
      expect(u.highestScore, 0);
      expect(u.bestStreak, 0);
      expect(u.avatar, null);
      expect(u.currentRank, null);
      expect(u.nextRank, null);
      expect(u.nextRankXp, null);
    });

    test('fromJson handles null values', () {
      final json = {
        'id': null,
        'name': null,
        'username': null,
        'email': null,
        'xp': null,
        'level': null,
        'total_quizzes': null,
        'highest_score': null,
        'best_streak': null,
        'avatar': null,
        'current_rank': null,
        'next_rank': null,
        'next_rank_xp': null,
      };

      final u = UserProfile.fromJson(json);

      expect(u.id, 0);
      expect(u.name, '');
      expect(u.username, '');
      expect(u.email, '');
      expect(u.xp, 0);
      expect(u.level, 1);
      expect(u.avatar, null);
    });

    test('initials returns two-letter abbreviation for two-part name', () {
      final u = UserProfile(name: 'John Doe', username: 'jd', email: 'j@d.com');
      expect(u.initials, 'JD');
    });

    test('initials returns first letter for single-part name', () {
      final u = UserProfile(name: 'Alice', username: 'alice', email: 'a@b.com');
      expect(u.initials, 'A');
    });

    test('initials returns ? for empty name', () {
      final u = UserProfile(name: '', username: '', email: '');
      expect(u.initials, '?');
    });

    test('initials handles three-part name', () {
      final u = UserProfile(
        name: 'John Michael Doe',
        username: 'jm',
        email: 'j@d.com',
      );
      expect(u.initials, 'JM');
    });

    test('constructor defaults match expectations', () {
      const u = UserProfile(name: 'Test', username: 't', email: 't@t.com');

      expect(u.id, 0);
      expect(u.xp, 0);
      expect(u.level, 1);
    });
  });
}
