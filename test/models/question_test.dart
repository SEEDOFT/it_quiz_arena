import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/models/question.dart';

void main() {
  group('Question', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'id': 1,
        'question_text': 'What is Dart?',
        'options': ['A', 'B', 'C', 'D'],
        'correct_answer': 0,
        'explanation': 'Dart is a language',
        'points': 50,
      };

      final q = Question.fromJson(json);

      expect(q.id, 1);
      expect(q.question, 'What is Dart?');
      expect(q.options, ['A', 'B', 'C', 'D']);
      expect(q.correctAnswer, 0);
      expect(q.explanation, 'Dart is a language');
    });

    test('fromJson handles nullable correctAnswer and explanation', () {
      final json = {
        'id': 1,
        'question_text': 'What is Dart?',
        'options': ['A', 'B', 'C', 'D'],
        'correct_answer': null,
        'explanation': null,
      };

      final q = Question.fromJson(json);

      expect(q.correctAnswer, null);
      expect(q.explanation, null);
    });

    test('fromJson handles missing fields', () {
      final json = {
        'id': 1,
        'question_text': 'Test?',
        'options': ['A', 'B', 'C', 'D'],
      };

      final q = Question.fromJson(json);

      expect(q.correctAnswer, null);
      expect(q.explanation, null);
    });

    test('fromJson handles null strings', () {
      final json = {
        'id': 1,
        'question_text': null,
        'options': [],
      };

      final q = Question.fromJson(json);
      expect(q.question, '');
    });
  });
}
