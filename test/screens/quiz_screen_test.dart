import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/core/app_routes.dart';
import 'package:it_quiz_arena/screens/quiz/quiz_screen.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import 'package:it_quiz_arena/services/audio_service.dart';
import '../helpers/mocks.dart';

http.Response _json(dynamic data, int status) =>
    http.Response(jsonEncode(data), status, headers: {'content-type': 'application/json'});

Future<void> wait() => Future.delayed(const Duration(milliseconds: 150));

Future<http.Response> Function(http.Request) _mockQuizApi() {
  return (request) async {
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
            'options': ['A programming language', 'A tool', 'A framework', 'A database'],
            'correct_answer': 0,
            'explanation': 'Dart is a programming language.',
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
        'session': {'score': 50, 'correct_count': 1, 'wrong_count': 0, 'streak': 1, 'highest_streak': 1},
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
  };
}

Widget _buildApp(QuizScreen screen) {
  return MaterialApp(
    home: screen,
    routes: AppRoutes.getRoutes(),
  );
}

void main() {
  setUp(() async {
    await dotenv.load(fileName: '.env');
    SharedPreferences.setMockInitialValues({'sound_enabled': false});
    await AudioService().reload();
    await AuthService().clearSession();
  });

  group('QuizScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error when not authenticated', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Not authenticated'), findsOneWidget);
    });

    testWidgets('renders questions after loading', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Question 1/1'), findsOneWidget);
      expect(find.text('What is Dart?'), findsOneWidget);
      expect(find.text('A programming language'), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.text('Streak: 0'), findsOneWidget);
    });

    testWidgets('displays timer countdown', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('30 s'), findsOneWidget);
    });

    testWidgets('allows selecting an answer', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('A programming language'));
      await tester.pump();

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('submit button is disabled when no answer selected', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit'),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('submit button is enabled after selecting answer', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('A programming language'));
      await tester.pump();

      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit'),
      );
      expect(submitButton.onPressed, isNotNull);
    });

    testWidgets('shows close button with quit dialog', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Quit Quiz?'), findsOneWidget);
      expect(find.text('Your progress will be lost.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Quit'), findsOneWidget);
    });

    testWidgets('closes quit dialog and continues on Continue', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Quit Quiz?'), findsNothing);
      expect(find.text('Question 1/1'), findsOneWidget);
    });

    testWidgets('shows Score and Streak text', (tester) async {
      ApiService.httpClient = MockClient(_mockQuizApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        QuizScreen(courseId: 1, questionCount: 5, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Score:'), findsOneWidget);
      expect(find.textContaining('Streak:'), findsOneWidget);
    });
  });
}
