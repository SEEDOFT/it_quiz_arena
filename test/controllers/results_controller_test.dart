import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/screens/results/results_controller.dart';

void main() {
  group('ResultsController', () {
    test('computes rank based on accuracy', () {
      final ctrl = ResultsController(
        score: 90, correctCount: 9, wrongCount: 1, totalQuestions: 10,
        highestStreak: 5, accuracy: 95.0, xpGained: 50,
      );
      expect(ctrl.rank, 'IT LEGEND');
      expect(ctrl.rankIcon.codePoint, Icons.workspace_premium.codePoint);
    });

    test('returns IT MASTER for accuracy >= 85', () {
      final ctrl = ResultsController(
        score: 85, correctCount: 8, wrongCount: 2, totalQuestions: 10,
        highestStreak: 4, accuracy: 85.0, xpGained: 40,
      );
      expect(ctrl.rank, 'IT MASTER');
      expect(ctrl.rankIcon.codePoint, Icons.emoji_events.codePoint);
    });

    test('returns IT EXPERT for accuracy >= 70', () {
      final ctrl = ResultsController(
        score: 70, correctCount: 7, wrongCount: 3, totalQuestions: 10,
        highestStreak: 3, accuracy: 70.0, xpGained: 30,
      );
      expect(ctrl.rank, 'IT EXPERT');
      expect(ctrl.rankIcon.codePoint, Icons.star.codePoint);
    });

    test('returns IT SPECIALIST for accuracy >= 50', () {
      final ctrl = ResultsController(
        score: 50, correctCount: 5, wrongCount: 5, totalQuestions: 10,
        highestStreak: 2, accuracy: 50.0, xpGained: 20,
      );
      expect(ctrl.rank, 'IT SPECIALIST');
      expect(ctrl.rankIcon.codePoint, Icons.school.codePoint);
    });

    test('returns IT TRAINEE for accuracy < 50', () {
      final ctrl = ResultsController(
        score: 20, correctCount: 2, wrongCount: 8, totalQuestions: 10,
        highestStreak: 1, accuracy: 20.0, xpGained: 10,
      );
      expect(ctrl.rank, 'IT TRAINEE');
      expect(ctrl.rankIcon.codePoint, Icons.school.codePoint);
    });

    test('stores all constructor parameters', () {
      final ctrl = ResultsController(
        score: 75, correctCount: 6, wrongCount: 4, totalQuestions: 10,
        highestStreak: 3, accuracy: 60.0, xpGained: 35, level: 3, levelUp: true,
      );

      expect(ctrl.score, 75);
      expect(ctrl.correctCount, 6);
      expect(ctrl.wrongCount, 4);
      expect(ctrl.totalQuestions, 10);
      expect(ctrl.highestStreak, 3);
      expect(ctrl.accuracy, 60.0);
      expect(ctrl.xpGained, 35);
      expect(ctrl.level, 3);
      expect(ctrl.levelUp, true);
    });
  });
}
