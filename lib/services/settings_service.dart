import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:it_quiz_arena/models/app_settings.dart';

class SettingsService {
  static const soundKey = 'sound_enabled';
  static const musicKey = 'music_enabled';
  static const showExplanationKey = 'show_explanation';
  static const questionCountKey = 'question_count';
  static const timerKey = 'time_per_question';
  static const themeKey = 'theme_mode'; // 'system', 'dark', 'light'
  static const difficultyKey =
      'difficulty'; // 'Beginner', 'Intermediate', 'Advanced'

  /// Get the system brightness
  static Brightness getSystemBrightness() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  /// Check if system is in dark mode
  static bool isSystemDarkMode() {
    return getSystemBrightness() == Brightness.dark;
  }

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return AppSettings(
      soundEnabled: prefs.getBool(soundKey) ?? true,
      musicEnabled: prefs.getBool(musicKey) ?? true,
      showExplanation: prefs.getBool(showExplanationKey) ?? true,
      questionCount: prefs.getInt(questionCountKey) ?? 10,
      timePerQuestion: prefs.getInt(timerKey) ?? 30,
      themeMode: prefs.getString(themeKey) ?? 'system',
      difficulty: prefs.getString(difficultyKey) ?? 'Beginner',
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(soundKey, settings.soundEnabled);
    await prefs.setBool(musicKey, settings.musicEnabled);
    await prefs.setBool(showExplanationKey, settings.showExplanation);
    await prefs.setInt(questionCountKey, settings.questionCount);
    await prefs.setInt(timerKey, settings.timePerQuestion);
    await prefs.setString(themeKey, settings.themeMode);
    await prefs.setString(difficultyKey, settings.difficulty);
  }

  Future<void> setTheme(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, themeMode);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}
