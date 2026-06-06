import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/app_settings.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import 'package:it_quiz_arena/services/settings_service.dart';

class SettingsController extends ChangeNotifier {
  final SettingsService _service = SettingsService();
  AppSettings settings = AppSettings.defaults();
  bool loading = true;
  bool resetting = false;
  bool saving = false;

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

  void updateShowExplanation(bool value) {
    settings.showExplanation = value;
    notifyListeners();
  }

  void updateTheme(String value) {
    settings.themeMode = value;
    notifyListeners();
  }

  Future<void> save() async {
    saving = true;
    notifyListeners();

    await _service.save(settings);

    final token = AuthService().token;
    if (token != null) {
      try {
        await ApiService.updateSettings(_toApiData(), token);
        final userData = await ApiService.getUserProfile(token);
        AuthService().updateUser(userData);
      } on Exception {
        //
      }
    }

    saving = false;
    notifyListeners();
  }

  Future<void> reset() async {
    resetting = true;
    notifyListeners();

    await _service.reset();
    settings = AppSettings.defaults();
    notifyListeners();

    final token = AuthService().token;
    if (token != null) {
      try {
        await ApiService.resetProgress(token);
        final userData = await ApiService.getUserProfile(token);
        AuthService().updateUser(userData);
      } on Exception {
        //
      }
    }

    resetting = false;
    notifyListeners();
  }

  Map<String, dynamic> _toApiData() => {
    'sound_enabled': settings.soundEnabled,
    'music_enabled': settings.musicEnabled,
    'show_explanation': settings.showExplanation,
    'theme_mode': settings.themeMode,
  };
}
