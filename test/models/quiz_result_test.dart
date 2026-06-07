import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/models/quiz_result.dart';

void main() {
  group('QuizResult', () {
    test('constructs with all required fields', () {
      final result = const QuizResult(
        sessionId: 1,
        score: 80,
        totalQuestions: 10,
        correctCount: 5,
        wrongCount: 2,
        xpGained: 50,
      );

      expect(result.sessionId, 1);
      expect(result.score, 80);
      expect(result.totalQuestions, 10);
      expect(result.correctCount, 5);
      expect(result.wrongCount, 2);
      expect(result.xpGained, 50);
    });

    test('newLevel defaults to null', () {
      final result = const QuizResult(
        sessionId: 1,
        score: 80,
        totalQuestions: 10,
        correctCount: 5,
        wrongCount: 2,
        xpGained: 50,
      );

      expect(result.newLevel, isNull);
    });

    test('levelUp defaults to false', () {
      final result = const QuizResult(
        sessionId: 1,
        score: 80,
        totalQuestions: 10,
        correctCount: 5,
        wrongCount: 2,
        xpGained: 50,
      );

      expect(result.levelUp, false);
    });

    test('constructs with all optional fields', () {
      final result = const QuizResult(
        sessionId: 1,
        score: 100,
        totalQuestions: 10,
        correctCount: 10,
        wrongCount: 0,
        xpGained: 100,
        newLevel: 3,
        levelUp: true,
      );

      expect(result.sessionId, 1);
      expect(result.score, 100);
      expect(result.totalQuestions, 10);
      expect(result.correctCount, 10);
      expect(result.wrongCount, 0);
      expect(result.xpGained, 100);
      expect(result.newLevel, 3);
      expect(result.levelUp, true);
    });

    test('supports value equality', () {
      const a = QuizResult(
        sessionId: 1, score: 80, totalQuestions: 10, correctCount: 5, wrongCount: 2, xpGained: 50,
      );
      const b = QuizResult(
        sessionId: 1, score: 80, totalQuestions: 10, correctCount: 5, wrongCount: 2, xpGained: 50,
      );

      expect(a.sessionId, b.sessionId);
    });
  });
}
