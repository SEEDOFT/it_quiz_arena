import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/services/settings_service.dart';
import 'package:it_quiz_arena/models/app_settings.dart';
import '../helpers/mocks.dart';

void main() {
  group('SettingsService', () {
    late SettingsService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = SettingsService();
    });

    test('load returns defaults when no prefs exist', () async {
      final settings = await service.load();

      expect(settings.soundEnabled, true);
      expect(settings.musicEnabled, true);
      expect(settings.showExplanation, true);
      expect(settings.questionCount, 10);
      expect(settings.timePerQuestion, 30);
      expect(settings.themeMode, 'system');
      expect(settings.difficulty, 'Beginner');
    });

    test('load returns stored values', () async {
      await MockSharedPreferences.withData({
        'sound_enabled': false,
        'music_enabled': true,
        'show_explanation': false,
        'question_count': 20,
        'time_per_question': 45,
        'theme_mode': 'dark',
        'difficulty': 'Advanced',
      });
      service = SettingsService();

      final settings = await service.load();

      expect(settings.soundEnabled, false);
      expect(settings.musicEnabled, true);
      expect(settings.showExplanation, false);
      expect(settings.questionCount, 20);
      expect(settings.timePerQuestion, 45);
      expect(settings.themeMode, 'dark');
      expect(settings.difficulty, 'Advanced');
    });

    test('save persists all fields', () async {
      final settings = AppSettings(
        soundEnabled: false,
        musicEnabled: true,
        showExplanation: false,
        questionCount: 15,
        timePerQuestion: 20,
        themeMode: 'light',
        difficulty: 'Intermediate',
      );

      await service.save(settings);
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getBool('sound_enabled'), false);
      expect(prefs.getBool('music_enabled'), true);
      expect(prefs.getBool('show_explanation'), false);
      expect(prefs.getInt('question_count'), 15);
      expect(prefs.getInt('time_per_question'), 20);
      expect(prefs.getString('theme_mode'), 'light');
      expect(prefs.getString('difficulty'), 'Intermediate');
    });

    test('setTheme updates theme only', () async {
      final settings = AppSettings.defaults();
      await service.save(settings);

      await service.setTheme('dark');
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString('theme_mode'), 'dark');
      expect(prefs.getInt('question_count'), 10);
    });

    test('reset clears all prefs', () async {
      final settings = AppSettings.defaults();
      await service.save(settings);

      await service.reset();
      final result = await service.load();

      expect(result.soundEnabled, true);
      expect(result.musicEnabled, true);
      expect(result.questionCount, 10);
    });
  });
}
