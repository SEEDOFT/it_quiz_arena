import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/achievement.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';

class AchievementsController extends ChangeNotifier {
  List<Achievement> achievements = [];
  bool loading = true;

  AchievementsController() {
    load();
  }

  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      final token = AuthService().token;
      final allData = await ApiService.getAchievements();
      final all = allData
          .map((j) => Achievement.fromJson(j as Map<String, dynamic>))
          .toList();

      if (token != null) {
        try {
          final userData = await ApiService.getUserAchievements(token);
          final map = {
            for (final j in userData)
              (j as Map<String, dynamic>)['id'] as int: Achievement.fromJson(j),
          };

          for (int i = 0; i < all.length; i++) {
            final user = map[all[i].id];
            if (user != null) {
              all[i] = user;
            }
          }
        } catch (_) {}
      }

      achievements = all;
    } catch (_) {}

    loading = false;
    notifyListeners();
  }
}
