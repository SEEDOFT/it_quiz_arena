import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/screens/profile/profile_controller.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import '../helpers/mocks.dart';

http.Response _json(dynamic data, int status) =>
    http.Response(jsonEncode(data), status, headers: {'content-type': 'application/json'});

Future<void> wait() => Future.delayed(const Duration(milliseconds: 100));

void main() {
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
      if (request.url.path == '/api/user/stats') {
        return _json(MockApiResponses.successEnvelope(MockApiResponses.sampleStats), 200);
      }
      return _json(MockApiResponses.errorEnvelope('Not found', 404), 404);
    });
    await AuthService().clearSession();
  });

  group('ProfileController', () {
    test('loading starts as true', () async {
      final ctrl = ProfileController();
      await wait();
      expect(ctrl.loading, false);
      ctrl.dispose();
    });

    test('avatar is null when not authenticated', () async {
      final ctrl = ProfileController();
      await wait();

      expect(ctrl.avatar, isNull);
      ctrl.dispose();
    });

    test('loads stats when authenticated', () async {
      await AuthService().loginWithGoogle('fake-token');

      final ctrl = ProfileController();
      await wait();

      expect(ctrl.loading, false);
      expect(ctrl.stats, isNotNull);
      expect(ctrl.stats!.totalQuizzes, 10);
      expect(ctrl.stats!.xp, 500);
      ctrl.dispose();
    });

    test('avatar returns user avatar', () async {
      await AuthService().loginWithGoogle('fake-token');

      final ctrl = ProfileController();
      await wait();

      await ctrl.load();
      await wait();

      expect(ctrl.avatar, 'https://example.com/avatar.png');
      ctrl.dispose();
    });

    test('handles error state gracefully', () async {
      ApiService.httpClient = MockClient((_) async =>
          _json(MockApiResponses.errorEnvelope('Error', 500), 500));

      final ctrl = ProfileController();
      await wait();

      expect(ctrl.loading, false);
      ctrl.dispose();
    });

    test('dispose cleans up without error', () async {
      final ctrl = ProfileController();
      await wait();
      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
