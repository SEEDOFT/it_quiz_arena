import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/core/app_routes.dart';
import 'package:it_quiz_arena/screens/home/home_screen.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import 'package:it_quiz_arena/services/audio_service.dart';
import '../helpers/mocks.dart';

http.Response _json(dynamic data, int status) =>
    http.Response(jsonEncode(data), status, headers: {'content-type': 'application/json'});

Future<http.Response> Function(http.Request) _mockHomeApi() {
  return (request) async {
    if (request.url.path == '/api/auth/google') {
      final user = Map<String, dynamic>.from(MockApiResponses.sampleUser);
      user['avatar'] = null;
      return _json(MockApiResponses.successEnvelope({
        'token': 'mock-token',
        'user': user,
      }), 200);
    }
    if (request.url.path == '/api/user') {
      final user = Map<String, dynamic>.from(MockApiResponses.sampleUser);
      user['avatar'] = null;
      return _json(MockApiResponses.successEnvelope(user), 200);
    }
    if (request.url.path == '/api/leaderboard') {
      return _json(MockApiResponses.successEnvelope([
        MockApiResponses.sampleLeaderboardEntry,
      ]), 200);
    }
    return _json(MockApiResponses.errorEnvelope('Not found', 404), 404);
  };
}

Widget _buildApp(HomeScreen screen) {
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

  group('HomeScreen', () {
    testWidgets('renders header with app title', (tester) async {
      ApiService.httpClient = MockClient(_mockHomeApi());

      await tester.pumpWidget(_buildApp(
        const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('IT QUIZ ARENA'), findsOneWidget);
    });

    testWidgets('renders profile card with defaults when no user', (tester) async {
      ApiService.httpClient = MockClient(_mockHomeApi());

      await tester.pumpWidget(_buildApp(
        const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Player'), findsOneWidget);
      expect(find.text('Lv.1 · 0 XP'), findsOneWidget);
    });

    testWidgets('renders game section with settings', (tester) async {
      ApiService.httpClient = MockClient(_mockHomeApi());

      await tester.pumpWidget(_buildApp(
        const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Test Your IT Skills'), findsOneWidget);
      expect(find.text('10 questions · 30s each'), findsOneWidget);
      expect(find.text('Start Game'), findsOneWidget);
    });

    testWidgets('renders stats row with default zeros', (tester) async {
      ApiService.httpClient = MockClient(_mockHomeApi());

      await tester.pumpWidget(_buildApp(
        const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('0'), findsWidgets);
      expect(find.text('Quizzes'), findsOneWidget);
      expect(find.text('Best Score'), findsOneWidget);
      expect(find.text('Best Streak'), findsOneWidget);
    });

    testWidgets('shows user profile when authenticated', (tester) async {
      ApiService.httpClient = MockClient(_mockHomeApi());
      await AuthService().loginWithGoogle('fake-token');

      await tester.pumpWidget(_buildApp(
        const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Test User'), findsAtLeastNWidgets(1));
      expect(find.text('@testuser'), findsOneWidget);
    });

    testWidgets('renders achievement and settings buttons', (tester) async {
      ApiService.httpClient = MockClient(_mockHomeApi());

      await tester.pumpWidget(_buildApp(
        const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('renders leaderboard section', (tester) async {
      ApiService.httpClient = MockClient(_mockHomeApi());

      await tester.pumpWidget(_buildApp(
        const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('TOP PLAYERS'), findsOneWidget);
    });

    testWidgets('shows game stats in game section', (tester) async {
      ApiService.httpClient = MockClient(_mockHomeApi());

      await tester.pumpWidget(_buildApp(
        const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('Per Question'), findsOneWidget);
      expect(find.text('Max Pts'), findsOneWidget);
    });



    testWidgets('XP progress bar is rendered', (tester) async {
      ApiService.httpClient = MockClient(_mockHomeApi());

      await tester.pumpWidget(_buildApp(
        const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
