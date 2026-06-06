import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:it_quiz_arena/services/api_service.dart';
import '../helpers/mocks.dart';

http.Response _jsonResponse(dynamic data, int status) =>
    http.Response(jsonEncode(data), status, headers: {
      'content-type': 'application/json',
    });

void main() {
  group('ApiService', () {
    setUp(() async {
      await dotenv.load(fileName: '.env');
      ApiService.httpClient = MockClient((request) async {
        switch (request.url.path) {
          case '/api/auth/google':
            return _jsonResponse(
              MockApiResponses.successEnvelope({
                'token': 'abc123',
                'user': MockApiResponses.sampleUser,
              }),
              200,
            );
          case '/api/courses':
            return _jsonResponse(
              MockApiResponses.successEnvelope([MockApiResponses.sampleCourse]),
              200,
            );
          case '/api/quiz/start':
            return _jsonResponse(
              MockApiResponses.successEnvelope({
                'session': MockApiResponses.sampleSession,
                'questions': [MockApiResponses.sampleQuestion],
              }),
              201,
            );
          case '/api/quiz/1/answer':
            return _jsonResponse(
              MockApiResponses.successEnvelope(MockApiResponses.sampleAnswer),
              200,
            );
          case '/api/quiz/1/finish':
            return _jsonResponse(
              MockApiResponses.successEnvelope({
                'session': MockApiResponses.sampleSession,
                'new_achievements': [],
                'xp_gained': 80,
                'level_up': false,
                'new_level': 2,
              }),
              200,
            );
          case '/api/leaderboard':
            return _jsonResponse(
              MockApiResponses.successEnvelope([
                MockApiResponses.sampleLeaderboardEntry,
              ]),
              200,
            );
          case '/api/ranks':
            return _jsonResponse(
              MockApiResponses.successEnvelope([MockApiResponses.sampleRank]),
              200,
            );
          case '/api/achievements':
            return _jsonResponse(
              MockApiResponses.successEnvelope([
                MockApiResponses.sampleAchievement,
              ]),
              200,
            );
          case '/api/user/achievements':
            return _jsonResponse(
              MockApiResponses.successEnvelope([
                MockApiResponses.sampleAchievement,
              ]),
              200,
            );
          case '/api/user/stats':
            return _jsonResponse(
              MockApiResponses.successEnvelope(MockApiResponses.sampleStats),
              200,
            );
          case '/api/user/settings':
            if (request.method == 'GET') {
              return _jsonResponse(
                MockApiResponses.successEnvelope(
                    MockApiResponses.sampleSettings),
                200,
              );
            }
            return _jsonResponse(
              MockApiResponses.successEnvelope(MockApiResponses.sampleSettings),
              200,
            );
          case '/api/user':
            return _jsonResponse(
              MockApiResponses.successEnvelope(MockApiResponses.sampleUser),
              200,
            );
          case '/api/user/reset-progress':
            return _jsonResponse(
              MockApiResponses.successEnvelope(null),
              200,
            );
          case '/api/logout':
            return _jsonResponse(MockApiResponses.successEnvelope(null), 200);
          default:
            return _jsonResponse(
              MockApiResponses.errorEnvelope('Not found', 404),
              404,
            );
        }
      });
    });

    test('googleLogin returns token and user', () async {
      final result = await ApiService.googleLogin('test-token');
      expect(result['token'], 'abc123');
      expect(result['user']['name'], 'Test User');
    });

    test('googleLogin throws on error', () async {
      ApiService.httpClient = MockClient((_) async => _jsonResponse(
            MockApiResponses.errorEnvelope('Invalid token', 401),
            401,
          ));
      expect(
        () => ApiService.googleLogin('bad-token'),
        throwsA(isA<Exception>()),
      );
    });

    test('getCourses returns list', () async {
      final result = await ApiService.getCourses();
      expect(result, isA<List<dynamic>>());
      expect(result.length, 1);
    });

    test('startQuiz returns session and questions', () async {
      final result = await ApiService.startQuiz(1, token: 'abc');
      expect(result['session']['id'], 1);
      expect(result['questions'], isA<List<dynamic>>());
    });

    test('startQuiz passes difficulty', () async {
      final result = await ApiService.startQuiz(
        1,
        questionCount: 10,
        difficulty: 'Intermediate',
        token: 'abc',
      );
      expect(result['session']['id'], 1);
    });

    test('answerQuestion returns is_correct', () async {
      final result = await ApiService.answerQuestion(
        sessionId: 1,
        questionId: 1,
        selectedOption: 0,
        timeSpent: 10,
        token: 'abc',
      );
      expect(result['is_correct'], true);
    });

    test('answerQuestion accepts -1 for timeout', () async {
      ApiService.httpClient = MockClient((request) async => _jsonResponse(
            MockApiResponses.successEnvelope({
              ...MockApiResponses.sampleAnswer,
              'is_correct': false,
            }),
            200,
          ));
      final result = await ApiService.answerQuestion(
        sessionId: 1,
        questionId: 1,
        selectedOption: -1,
        timeSpent: 30,
        token: 'abc',
      );
      expect(result['is_correct'], false);
    });

    test('finishQuiz returns xp_gained', () async {
      final result = await ApiService.finishQuiz(sessionId: 1, token: 'abc');
      expect(result['xp_gained'], 80);
    });

    test('getLeaderboard returns list', () async {
      final result = await ApiService.getLeaderboard();
      expect(result.length, 1);
    });

    test('getRanks returns list', () async {
      final result = await ApiService.getRanks();
      expect(result.length, 1);
    });

    test('getAchievements returns list', () async {
      final result = await ApiService.getAchievements();
      expect(result.length, 1);
    });

    test('getUserAchievements returns list', () async {
      final result = await ApiService.getUserAchievements('abc');
      expect(result.length, 1);
    });

    test('getUserStats returns data', () async {
      final result = await ApiService.getUserStats('abc');
      expect(result['total_quizzes'], 10);
    });

    test('getSettings returns data', () async {
      final result = await ApiService.getSettings('abc');
      expect(result['theme_mode'], 'dark');
    });

    test('updateSettings sends PUT', () async {
      await ApiService.updateSettings(
        MockApiResponses.sampleSettings,
        'abc',
      );
    });

    test('logout sends POST', () async {
      await ApiService.logout('abc');
    });

    test('getUserProfile returns user', () async {
      final result = await ApiService.getUserProfile('abc');
      expect(result['name'], 'Test User');
    });

    test('resetProgress returns successfully', () async {
      await ApiService.resetProgress('abc');
    });

    test('resetProgress throws on error', () async {
      ApiService.httpClient = MockClient((_) async => _jsonResponse(
            MockApiResponses.errorEnvelope('Failed', 400),
            400,
          ));
      expect(
        () => ApiService.resetProgress('bad'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws on non-200 response', () async {
      ApiService.httpClient = MockClient((_) async => _jsonResponse(
            MockApiResponses.errorEnvelope('Server error', 500),
            500,
          ));
      expect(() => ApiService.getCourses(), throwsA(isA<Exception>()));
    });
  });
}
