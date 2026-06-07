import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/screens/splash/splash_controller.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import '../helpers/mocks.dart';

http.Response _json(dynamic data, int status) =>
    http.Response(jsonEncode(data), status, headers: {'content-type': 'application/json'});

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
      return _json(MockApiResponses.errorEnvelope('Not found', 404), 404);
    });
    await AuthService().clearSession();
  });

  group('SplashController', () {
    test('dispose prevents navigation callbacks', () async {
      var called = false;
      final ctrl = SplashController(
        onAuthenticated: () => called = true,
        onShowOnboarding: () => called = true,
        onShowLogin: () => called = true,
      );

      ctrl.dispose();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(called, false);
    });

    test('calls onShowOnboarding when onboarding not done', () async {
      var route = '';
      final ctrl = SplashController(
        onAuthenticated: () => route = 'home',
        onShowOnboarding: () => route = 'onboarding',
        onShowLogin: () => route = 'login',
      );

      await Future.delayed(const Duration(seconds: 4));

      expect(route, 'onboarding');
      ctrl.dispose();
    });

    test('calls onShowLogin when onboarding done but not authenticated', () async {
      SharedPreferences.setMockInitialValues({'onboarding_done': true});

      var route = '';
      final ctrl = SplashController(
        onAuthenticated: () => route = 'home',
        onShowOnboarding: () => route = 'onboarding',
        onShowLogin: () => route = 'login',
      );

      await Future.delayed(const Duration(seconds: 4));

      expect(route, 'login');
      ctrl.dispose();
    });

    test('calls onAuthenticated when user is logged in', () async {
      await AuthService().loginWithGoogle('fake-token');

      var route = '';
      final ctrl = SplashController(
        onAuthenticated: () => route = 'home',
        onShowOnboarding: () => route = 'onboarding',
        onShowLogin: () => route = 'login',
      );

      await Future.delayed(const Duration(seconds: 4));

      expect(route, 'home');
      ctrl.dispose();
    });

    test('dispose cleans up without error', () {
      final ctrl = SplashController(
        onAuthenticated: () {},
        onShowOnboarding: () {},
        onShowLogin: () {},
      );

      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
