import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/models/leaderboard.dart';

void main() {
  group('LeaderboardEntry', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'player_name': 'Test User',
        'xp': 500,
        'level': 2,
        'rank': 'Specialist',
        'total_quizzes': 10,
      };

      final e = LeaderboardEntry.fromJson(json);

      expect(e.playerName, 'Test User');
      expect(e.xp, 500);
      expect(e.level, 2);
      expect(e.rank, 'Specialist');
      expect(e.totalQuizzes, 10);
    });

    test('fromJson handles null rank', () {
      final json = {
        'player_name': 'New Player',
        'xp': 0,
        'level': 1,
        'rank': null,
        'total_quizzes': 0,
      };

      final e = LeaderboardEntry.fromJson(json);

      expect(e.playerName, 'New Player');
      expect(e.rank, null);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {'player_name': null};

      final e = LeaderboardEntry.fromJson(json);

      expect(e.playerName, '');
      expect(e.xp, 0);
      expect(e.level, 1);
      expect(e.rank, null);
      expect(e.totalQuizzes, 0);
    });
  });
}
