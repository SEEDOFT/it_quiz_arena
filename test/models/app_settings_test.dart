import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('defaults returns expected values', () {
      final s = AppSettings.defaults();

      expect(s.soundEnabled, true);
      expect(s.musicEnabled, true);
      expect(s.showExplanation, true);
      expect(s.questionCount, 10);
      expect(s.timePerQuestion, 30);
      expect(s.themeMode, 'system');
      expect(s.difficulty, 'Beginner');
    });

    test('constructor sets all fields', () {
      final s = AppSettings(
        soundEnabled: false,
        musicEnabled: false,
        showExplanation: false,
        questionCount: 20,
        timePerQuestion: 45,
        themeMode: 'dark',
        difficulty: 'Advanced',
      );

      expect(s.soundEnabled, false);
      expect(s.musicEnabled, false);
      expect(s.showExplanation, false);
      expect(s.questionCount, 20);
      expect(s.timePerQuestion, 45);
      expect(s.themeMode, 'dark');
      expect(s.difficulty, 'Advanced');
    });

    test('properties are mutable', () {
      final s = AppSettings.defaults();
      s.soundEnabled = false;
      s.musicEnabled = false;
      s.showExplanation = false;
      s.questionCount = 15;
      s.timePerQuestion = 20;
      s.themeMode = 'light';
      s.difficulty = 'Intermediate';

      expect(s.soundEnabled, false);
      expect(s.musicEnabled, false);
      expect(s.showExplanation, false);
      expect(s.questionCount, 15);
      expect(s.timePerQuestion, 20);
      expect(s.themeMode, 'light');
      expect(s.difficulty, 'Intermediate');
    });
  });
}
