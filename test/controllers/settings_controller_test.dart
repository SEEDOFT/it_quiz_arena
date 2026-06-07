import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/screens/settings/settings_controller.dart';
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
        return _json(
          MockApiResponses.successEnvelope({
            'token': 'mock-token',
            'user': MockApiResponses.sampleUser,
          }),
          200,
        );
      }
      if (request.url.path == '/api/settings') {
        return _json(MockApiResponses.successEnvelope(MockApiResponses.sampleSettings), 200);
      }
      if (request.url.path == '/api/user/profile') {
        return _json(MockApiResponses.successEnvelope(MockApiResponses.sampleUser), 200);
      }
      if (request.url.path == '/api/settings/update') {
        return _json(MockApiResponses.successEnvelope(MockApiResponses.sampleSettings), 200);
      }
      if (request.url.path == '/api/user/reset') {
        return _json(MockApiResponses.successEnvelope({'message': 'Reset successful'}), 200);
      }
      return _json(MockApiResponses.errorEnvelope('Not found', 404), 404);
    });
    await AuthService().clearSession();
  });

  group('SettingsController', () {
    test('loads settings with defaults on init', () async {
      final ctrl = SettingsController();
      await wait();

      expect(ctrl.loading, false);
      expect(ctrl.settings.soundEnabled, true);
      expect(ctrl.settings.musicEnabled, true);
      expect(ctrl.settings.showExplanation, true);
      ctrl.dispose();
    });

    test('loads persisted settings', () async {
      SharedPreferences.setMockInitialValues({
        'sound_enabled': false,
        'music_enabled': true,
        'show_explanation': false,
        'question_count': 20,
        'time_per_question': 45,
        'theme_mode': 'dark',
        'difficulty': 'Advanced',
      });

      final ctrl = SettingsController();
      await wait();

      expect(ctrl.settings.soundEnabled, false);
      expect(ctrl.settings.musicEnabled, true);
      expect(ctrl.settings.showExplanation, false);
      expect(ctrl.settings.questionCount, 20);
      expect(ctrl.settings.timePerQuestion, 45);
      expect(ctrl.settings.themeMode, 'dark');
      ctrl.dispose();
    });

    test('updateSound toggles state', () async {
      final ctrl = SettingsController();
      await wait();

      ctrl.updateSound(false);
      expect(ctrl.settings.soundEnabled, false);

      ctrl.updateSound(true);
      expect(ctrl.settings.soundEnabled, true);
      ctrl.dispose();
    });

    test('updateMusic toggles state', () async {
      final ctrl = SettingsController();
      await wait();

      ctrl.updateMusic(false);
      expect(ctrl.settings.musicEnabled, false);

      ctrl.updateMusic(true);
      expect(ctrl.settings.musicEnabled, true);
      ctrl.dispose();
    });

    test('updateShowExplanation toggles state', () async {
      final ctrl = SettingsController();
      await wait();

      ctrl.updateShowExplanation(false);
      expect(ctrl.settings.showExplanation, false);

      ctrl.updateShowExplanation(true);
      expect(ctrl.settings.showExplanation, true);
      ctrl.dispose();
    });

    test('updateTheme sets theme mode', () async {
      final ctrl = SettingsController();
      await wait();

      ctrl.updateTheme('dark');
      expect(ctrl.settings.themeMode, 'dark');

      ctrl.updateTheme('light');
      expect(ctrl.settings.themeMode, 'light');
      ctrl.dispose();
    });

    test('save persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final ctrl = SettingsController();
      await wait();

      ctrl.settings.soundEnabled = false;
      await ctrl.save();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sound_enabled'), false);
      ctrl.dispose();
    });

    test('save with auth token syncs to API', () async {
      await AuthService().loginWithGoogle('fake-token');

      final ctrl = SettingsController();
      await wait();

      ctrl.settings.themeMode = 'light';
      await ctrl.save();
      ctrl.dispose();
    });

    test('reset clears settings to defaults', () async {
      SharedPreferences.setMockInitialValues({
        'sound_enabled': false,
        'music_enabled': false,
        'question_count': 50,
      });

      final ctrl = SettingsController();
      await wait();

      await ctrl.reset();

      expect(ctrl.settings.soundEnabled, true);
      expect(ctrl.settings.musicEnabled, true);
      expect(ctrl.settings.questionCount, 10);
      ctrl.dispose();
    });

    test('reset with auth token syncs to API', () async {
      await AuthService().loginWithGoogle('fake-token');

      final ctrl = SettingsController();
      await wait();

      await ctrl.reset();
      ctrl.dispose();
    });

    test('dispose cleans up without error', () async {
      final ctrl = SettingsController();
      await wait();
      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
