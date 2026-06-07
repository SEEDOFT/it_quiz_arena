import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/screens/home/home_controller.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import '../helpers/mocks.dart';

http.Response _json(dynamic data, int status) =>
    http.Response(jsonEncode(data), status, headers: {'content-type': 'application/json'});

Future<void> wait() => Future.delayed(const Duration(milliseconds: 100));

Future<http.Response> Function(http.Request) _baseMock() {
  return (request) async {
    if (request.url.path == '/api/auth/google') {
      return _json(MockApiResponses.successEnvelope({
        'token': 'mock-token',
        'user': MockApiResponses.sampleUser,
      }), 200);
    }
    if (request.url.path == '/api/user/profile') {
      return _json(MockApiResponses.successEnvelope(MockApiResponses.sampleUser), 200);
    }
    if (request.url.path == '/api/leaderboard') {
      return _json(MockApiResponses.successEnvelope([
        MockApiResponses.sampleLeaderboardEntry,
      ]), 200);
    }
    return _json(MockApiResponses.errorEnvelope('Not found', 404), 404);
  };
}

void main() {
  setUp(() async {
    await dotenv.load(fileName: '.env');
    SharedPreferences.setMockInitialValues({});
    await AuthService().clearSession();
  });

  group('HomeController', () {
    test('loads settings with defaults on init', () async {
      ApiService.httpClient = MockClient(_baseMock());
      final ctrl = HomeController();
      await wait();

      expect(ctrl.questionCount, 10);
      expect(ctrl.timePerQuestion, 30);
      ctrl.dispose();
    });

    test('loads settings from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'question_count': 20,
        'time_per_question': 45,
      });

      ApiService.httpClient = MockClient(_baseMock());
      final ctrl = HomeController();
      await wait();

      expect(ctrl.questionCount, 20);
      expect(ctrl.timePerQuestion, 45);
      ctrl.dispose();
    });

    test('user is null when not authenticated', () async {
      ApiService.httpClient = MockClient(_baseMock());
      final ctrl = HomeController();
      await wait();

      expect(ctrl.user, isNull);
      ctrl.dispose();
    });

    test('loads user profile when authenticated', () async {
      ApiService.httpClient = MockClient(_baseMock());
      await AuthService().loginWithGoogle('fake-token');

      final ctrl = HomeController();
      await wait();

      expect(ctrl.user, isNotNull);
      expect(ctrl.user!.name, 'Test User');
      expect(ctrl.user!.xp, 500);
      ctrl.dispose();
    });

    test('xpProgress returns 0 when user is null', () async {
      ApiService.httpClient = MockClient(_baseMock());
      final ctrl = HomeController();
      await wait();

      expect(ctrl.xpProgress, 0.0);
      ctrl.dispose();
    });

    test('xpProgress returns clamped ratio when user exists', () async {
      ApiService.httpClient = MockClient(_baseMock());
      await AuthService().loginWithGoogle('fake-token');

      final ctrl = HomeController();
      await wait();

      expect(ctrl.xpProgress, greaterThan(0.0));
      expect(ctrl.xpProgress, lessThanOrEqualTo(1.0));
      ctrl.dispose();
    });

    test('loadLeaderboard populates entries', () async {
      ApiService.httpClient = MockClient(_baseMock());
      final ctrl = HomeController();
      await wait();
      await ctrl.loadLeaderboard();
      await wait();

      expect(ctrl.leaderboard.length, 1);
      expect(ctrl.leaderboard.first.playerName, 'Test User');
      expect(ctrl.leaderboardLoading, false);
      ctrl.dispose();
    });

    test('refresh reloads profile and leaderboard', () async {
      ApiService.httpClient = MockClient(_baseMock());
      await AuthService().loginWithGoogle('fake-token');

      final ctrl = HomeController();
      await wait();

      await ctrl.refresh();
      await wait();

      expect(ctrl.user, isNotNull);
      expect(ctrl.leaderboard, isNotEmpty);
      ctrl.dispose();
    });

    test('leaderboard handles API error gracefully', () async {
      ApiService.httpClient = MockClient((request) async {
        if (request.url.path == '/api/auth/google') {
          return _json(MockApiResponses.successEnvelope({
            'token': 'mock-token',
            'user': MockApiResponses.sampleUser,
          }), 200);
        }
        if (request.url.path == '/api/leaderboard') {
          return _json(MockApiResponses.errorEnvelope('Error', 500), 500);
        }
        return _json(MockApiResponses.errorEnvelope('Not found', 404), 404);
      });

      final ctrl = HomeController();
      await wait();
      await ctrl.loadLeaderboard();
      await wait();

      expect(ctrl.leaderboard, isEmpty);
      expect(ctrl.leaderboardLoading, false);
      ctrl.dispose();
    });

    test('dispose cleans up without error', () async {
      ApiService.httpClient = MockClient(_baseMock());
      final ctrl = HomeController();
      await wait();

      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
