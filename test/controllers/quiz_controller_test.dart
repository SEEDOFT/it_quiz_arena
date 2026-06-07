import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/screens/quiz/quiz_controller.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import '../helpers/mocks.dart';

http.Response _json(dynamic data, int status) =>
    http.Response(jsonEncode(data), status, headers: {'content-type': 'application/json'});

Future<void> wait() => Future.delayed(const Duration(milliseconds: 150));
Future<void> waitLong() => Future.delayed(const Duration(seconds: 2));

void main() {
  late bool finished;

  setUp(() async {
    await dotenv.load(fileName: '.env');
    SharedPreferences.setMockInitialValues({});
    ApiService.httpClient = MockClient((request) async {
      if (request.url.path == '/api/auth/google') {
        return _json(MockApiResponses.successEnvelope({
          'token': 'mock-token',
          'user': MockApiResponses.sampleUser,
        }), 200);
      }
      if (request.url.path == '/api/quiz/start') {
        return _json(MockApiResponses.successEnvelope({
          'session': {'id': 42},
          'questions': [
            {
              'id': 1,
              'question_text': 'What is Dart?',
              'options': ['A', 'B', 'C', 'D'],
              'correct_answer': 0,
              'explanation': 'Dart is a language.',
              'points': 50,
              'difficulty': 'Beginner',
            },
            {
              'id': 2,
              'question_text': 'What is Flutter?',
              'options': ['X', 'Y', 'Z', 'W'],
              'correct_answer': 1,
              'explanation': 'Flutter is a framework.',
              'points': 50,
              'difficulty': 'Beginner',
            },
          ],
        }), 200);
      }
      if (request.url.path.contains('/quiz/') && request.url.path.endsWith('/answer')) {
        return _json(MockApiResponses.successEnvelope({
          'is_correct': true,
          'correct_answer': 0,
          'explanation': 'Dart is a language.',
          'session': {
            'score': 50,
            'correct_count': 1,
            'wrong_count': 0,
            'streak': 1,
            'highest_streak': 1,
          },
        }), 200);
      }
      if (request.url.path.contains('/quiz/') && request.url.path.endsWith('/finish')) {
        return _json(MockApiResponses.successEnvelope({
          'session': {'score': 50, 'correct_count': 1, 'wrong_count': 0},
          'xp_gained': 25,
          'new_level': null,
          'level_up': false,
          'new_achievements': [],
        }), 200);
      }
      return _json(MockApiResponses.errorEnvelope('Not found', 404), 404);
    });
    await AuthService().clearSession();
    finished = false;
  });

  group('QuizController', () {
    test('loads questions and starts quiz on init when authenticated', () async {
      await AuthService().loginWithGoogle('fake-token');

      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      expect(ctrl.loading, false);
      expect(ctrl.error, isNull);
      expect(ctrl.questions.length, 2);
      expect(ctrl.sessionId, 42);
      expect(ctrl.currentQuestion, isNotNull);
      expect(ctrl.currentQuestionIndex, 0);
      ctrl.dispose();
    });

    test('sets error when not authenticated', () async {
      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      expect(ctrl.error, 'Not authenticated');
      expect(ctrl.loading, false);
      ctrl.dispose();
    });

    test('selectAnswer updates selected index', () async {
      await AuthService().loginWithGoogle('fake-token');
      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      expect(ctrl.selectedAnswerIndex, -1);
      ctrl.selectAnswer(2);
      expect(ctrl.selectedAnswerIndex, 2);
      ctrl.selectAnswer(0);
      expect(ctrl.selectedAnswerIndex, 0);
      ctrl.dispose();
    });

    test('selectAnswer does nothing after answer submitted', () async {
      await AuthService().loginWithGoogle('fake-token');
      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      ctrl.answerSubmitted = true;
      ctrl.selectAnswer(1);
      expect(ctrl.selectedAnswerIndex, -1);
      ctrl.dispose();
    });

    test('submitAnswer submits and updates score', () async {
      await AuthService().loginWithGoogle('fake-token');
      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      ctrl.selectAnswer(0);
      ctrl.submitAnswer();
      await waitLong();

      expect(ctrl.answerSubmitted, true);
      expect(ctrl.lastAnswerCorrect, true);
      expect(ctrl.score, 50);
      ctrl.dispose();
    });

    test('submitAnswer does nothing without selection', () async {
      await AuthService().loginWithGoogle('fake-token');
      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      ctrl.submitAnswer();
      expect(ctrl.answerSubmitted, false);
      ctrl.dispose();
    });

    test('optionColor returns correct colors', () async {
      await AuthService().loginWithGoogle('fake-token');
      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      expect(ctrl.optionColor(0).toARGB32(), 0xFF1E293B);
      ctrl.selectAnswer(0);
      expect(ctrl.optionColor(0).toARGB32(), 0xFF6366F1);
      ctrl.dispose();
    });

    test('cancelQuiz calls onQuizFinished', () async {
      await AuthService().loginWithGoogle('fake-token');
      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      await ctrl.cancelQuiz();
      expect(finished, true);
      ctrl.dispose();
    });

    test('dispose cancels timer without error', () async {
      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      expect(() => ctrl.dispose(), returnsNormally);
    });

    test('error state on API failure', () async {
      await AuthService().loginWithGoogle('fake-token');
      ApiService.httpClient = MockClient((_) async =>
          _json(MockApiResponses.errorEnvelope('Server error', 500), 500));

      final ctrl = QuizController(
        courseId: 1,
        questionCount: 5,
        timePerQuestion: 30,
        onQuizFinished: () => finished = true,
      );
      await wait();

      expect(ctrl.error, isNotNull);
      expect(ctrl.loading, false);
      ctrl.dispose();
    });
  });
}
