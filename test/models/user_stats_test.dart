import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/models/user_stats.dart';

void main() {
  group('UserStats', () {
    test('fromJson maps all fields correctly', () {
      final json = <String, dynamic>{
        'total_quizzes': 10,
        'total_correct': 50,
        'total_wrong': 20,
        'highest_score': 85,
        'best_streak': 5,
        'xp': 500,
        'level': 2,
        'current_rank': 'Specialist',
        'overall_accuracy': 71.4,
      };

      final s = UserStats.fromJson(json);

      expect(s.totalQuizzes, 10);
      expect(s.totalCorrect, 50);
      expect(s.totalWrong, 20);
      expect(s.highestScore, 85);
      expect(s.bestStreak, 5);
      expect(s.xp, 500);
      expect(s.level, 2);
      expect(s.currentRank, 'Specialist');
      expect(s.overallAccuracy, 71.4);
    });

    test('fromJson handles missing overall_accuracy', () {
      final json = <String, dynamic>{
        'total_quizzes': 0,
        'total_correct': 0,
        'total_wrong': 0,
        'highest_score': 0,
        'best_streak': 0,
        'xp': 0,
        'level': 1,
      };

      final s = UserStats.fromJson(json);
      expect(s.overallAccuracy, 0.0);
      expect(s.currentRank, null);
    });

    test('fromJson accepts overall_accuracy as int', () {
      final json = <String, dynamic>{
        'total_quizzes': 5,
        'total_correct': 20,
        'total_wrong': 5,
        'highest_score': 80,
        'best_streak': 3,
        'xp': 200,
        'level': 1,
        'overall_accuracy': 80,
      };

      final s = UserStats.fromJson(json);
      expect(s.overallAccuracy, 80.0);
    });

    test('fromJson handles empty map', () {
      final s = UserStats.fromJson(<String, dynamic>{});
      expect(s.totalQuizzes, 0);
      expect(s.totalCorrect, 0);
      expect(s.totalWrong, 0);
      expect(s.highestScore, 0);
      expect(s.bestStreak, 0);
      expect(s.xp, 0);
      expect(s.level, 1);
      expect(s.currentRank, null);
      expect(s.overallAccuracy, 0.0);
    });
  });
}
