import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/screens/achievements/achievements_controller.dart';
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
    if (request.url.path == '/api/achievements') {
      return _json(MockApiResponses.successEnvelope([
        {
          'id': 1, 'title': 'First Steps', 'description': 'Complete first quiz',
          'key': 'first_quiz', 'required_value': 1, 'icon': 'trophy',
          'progress': 0, 'is_unlocked': false, 'unlocked_at': null,
        },
        {
          'id': 2, 'title': 'Speedster', 'description': 'Answer in 10s',
          'key': 'speed_demon', 'required_value': 10, 'icon': 'bolt',
          'progress': 0, 'is_unlocked': false, 'unlocked_at': null,
        },
      ]), 200);
    }
    if (request.url.path == '/api/user/achievements') {
      return _json(MockApiResponses.successEnvelope([
        {
          'id': 1, 'title': 'First Steps', 'description': 'Complete first quiz',
          'key': 'first_quiz', 'required_value': 1, 'icon': 'trophy',
          'progress': 1, 'is_unlocked': true, 'unlocked_at': '2026-01-01T00:00:00.000000Z',
        },
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

  group('AchievementsController', () {
    test('loads achievements on init', () async {
      ApiService.httpClient = MockClient(_baseMock());
      final ctrl = AchievementsController();
      await wait();

      expect(ctrl.loading, false);
      expect(ctrl.achievements.length, 2);
      expect(ctrl.achievements.first.title, 'First Steps');
      ctrl.dispose();
    });

    test('unlockedCount is 0 without auth', () async {
      ApiService.httpClient = MockClient(_baseMock());
      final ctrl = AchievementsController();
      await wait();

      expect(ctrl.unlockedCount, 0);
      ctrl.dispose();
    });

    test('merges user achievement progress when authenticated', () async {
      ApiService.httpClient = MockClient(_baseMock());
      await AuthService().loginWithGoogle('fake-token');

      final ctrl = AchievementsController();
      await wait();

      expect(ctrl.unlockedCount, 1);
      expect(ctrl.achievements[0].isUnlocked, true);
      expect(ctrl.achievements[0].progress, 1);
      ctrl.dispose();
    });

    test('handles API error gracefully', () async {
      ApiService.httpClient = MockClient((_) async =>
          _json(MockApiResponses.errorEnvelope('Error', 500), 500));

      final ctrl = AchievementsController();
      await wait();

      expect(ctrl.loading, false);
      expect(ctrl.achievements, isEmpty);
      ctrl.dispose();
    });

    test('dispose cleans up without error', () async {
      ApiService.httpClient = MockClient(_baseMock());
      final ctrl = AchievementsController();
      await wait();
      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
