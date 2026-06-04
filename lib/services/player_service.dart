import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerService {
  static const key = 'player_data';

  Future<Map<String, dynamic>> loadPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);

    if (raw == null) {
      return {
        'totalQuizzes': 0,
        'totalCorrect': 0,
        'totalWrong': 0,
        'highestScore': 0,
        'bestStreak': 0,
        'xp': 0,
      };
    }

    return jsonDecode(raw);
  }

  Future<void> savePlayerData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode({
        'totalQuizzes': data['totalQuizzes'] ?? 0,
        'totalCorrect': data['totalCorrect'] ?? 0,
        'totalWrong': data['totalWrong'] ?? 0,
        'highestScore': data['highestScore'] ?? 0,
        'bestStreak': data['bestStreak'] ?? 0,
        'xp': data['xp'] ?? 0,
      }),
    );
  }
}
