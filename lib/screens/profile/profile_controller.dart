import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/user_stats.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';

class ProfileController extends ChangeNotifier {
  UserStats? stats;
  final AuthService _auth = AuthService();

  bool loading = true;

  ProfileController() {
    load();
  }

  String? get avatar => _auth.user?.avatar;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final token = AuthService().token;
    if (token == null) {
      loading = false;
      notifyListeners();
      return;
    }

    try {
      final data = await ApiService.getUserStats(token);
      stats = UserStats.fromJson(data);
    } catch (_) {}

    loading = false;
    notifyListeners();
  }
}
