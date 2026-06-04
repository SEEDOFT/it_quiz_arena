import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/app_settings.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import 'package:it_quiz_arena/services/settings_service.dart';

class SettingsController extends ChangeNotifier {
  final SettingsService _service = SettingsService();
  AppSettings settings = AppSettings.defaults();
  bool loading = true;

  SettingsController() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    loading = true;
    notifyListeners();
    settings = await _service.load();
    loading = false;
    notifyListeners();
  }

  void updateSound(bool value) {
    settings.soundEnabled = value;
    notifyListeners();
  }

  void updateMusic(bool value) {
    settings.musicEnabled = value;
    notifyListeners();
  }

  void updateQuestionCount(int value) {
    settings.questionCount = value;
    notifyListeners();
  }

  void updateTimePerQuestion(int value) {
    settings.timePerQuestion = value;
    notifyListeners();
  }

  void updateShowExplanation(bool value) {
    settings.showExplanation = value;
    notifyListeners();
  }

  void updateDifficulty(String value) {
    settings.difficulty = value;
    notifyListeners();
  }

  void updateTheme(String value) {
    settings.themeMode = value;
    notifyListeners();
  }

  Future<void> save() async {
    await _service.save(settings);

    final token = AuthService().token;
    if (token != null) {
      try {
        await ApiService.updateSettings(_toApiData(), token);
      } catch (_) {}
    }
  }

  Future<void> reset() async {
    await _service.reset();
    settings = AppSettings.defaults();
    notifyListeners();

    final token = AuthService().token;
    if (token != null) {
      try {
        await ApiService.updateSettings(_toApiData(), token);
      } catch (_) {}
    }
  }

  Map<String, dynamic> _toApiData() => {
    'sound_enabled': settings.soundEnabled,
    'music_enabled': settings.musicEnabled,
    'show_explanation': settings.showExplanation,
    'question_count': settings.questionCount,
    'time_per_question': settings.timePerQuestion,
    'theme_mode': settings.themeMode,
    'difficulty': settings.difficulty,
  };
}
