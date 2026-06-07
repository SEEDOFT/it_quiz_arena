import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/screens/ranks/ranks_controller.dart';
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
      if (request.url.path == '/api/ranks') {
        return _json(MockApiResponses.successEnvelope([
          {'id': 1, 'title': 'Beginner', 'required_xp': 0, 'icon': null},
          {'id': 2, 'title': 'Explorer', 'required_xp': 200, 'icon': null},
          {'id': 3, 'title': 'Specialist', 'required_xp': 500, 'icon': null},
          {'id': 4, 'title': 'Expert', 'required_xp': 1000, 'icon': null},
        ]), 200);
      }
      return _json(MockApiResponses.errorEnvelope('Not found', 404), 404);
    });
    await AuthService().clearSession();
  });

  group('RanksController', () {
    test('loads ranks on init', () async {
      final ctrl = RanksController();
      await wait();

      expect(ctrl.loading, false);
      expect(ctrl.ranks.length, 4);
      expect(ctrl.ranks.first.title, 'Beginner');
      ctrl.dispose();
    });

    test('currentRankIndex is 0 when user has 0 XP', () async {
      final ctrl = RanksController();
      await wait();

      expect(ctrl.currentRankIndex, 0);
      expect(ctrl.currentRank!.title, 'Beginner');
      ctrl.dispose();
    });

    test('currentRankIndex picks correct rank based on user XP', () async {
      await AuthService().loginWithGoogle('fake-token');
      AuthService().updateUser(MockApiResponses.sampleUser);

      final ctrl = RanksController();
      await wait();

      expect(ctrl.currentRankIndex, 2);
      expect(ctrl.currentRank!.title, 'Specialist');
      ctrl.dispose();
    });

    test('nextRank returns the rank after current', () async {
      final ctrl = RanksController();
      await wait();

      expect(ctrl.nextRank, isNotNull);
      expect(ctrl.nextRank!.title, 'Explorer');
      ctrl.dispose();
    });

    test('xpProgress is 0 for first rank with no XP', () async {
      final ctrl = RanksController();
      await wait();

      expect(ctrl.xpProgress, 0.0);
      ctrl.dispose();
    });

    test('xpProgress is 1.0 when on last rank', () async {
      await AuthService().loginWithGoogle('fake-token');
      AuthService().updateUser({...MockApiResponses.sampleUser, 'xp': 5000, 'current_rank': 'Expert'});

      final ctrl = RanksController();
      await wait();

      expect(ctrl.xpProgress, 1.0);
      ctrl.dispose();
    });

    test('handles API error gracefully', () async {
      ApiService.httpClient = MockClient((_) async =>
          _json(MockApiResponses.errorEnvelope('Error', 500), 500));

      final ctrl = RanksController();
      await wait();

      expect(ctrl.loading, false);
      expect(ctrl.ranks, isEmpty);
      ctrl.dispose();
    });

    test('dispose cleans up without error', () async {
      final ctrl = RanksController();
      await wait();
      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
