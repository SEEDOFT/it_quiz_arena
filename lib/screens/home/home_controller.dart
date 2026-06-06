import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/leaderboard.dart';
import 'package:it_quiz_arena/models/user_profile.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import 'package:it_quiz_arena/services/settings_service.dart';

class HomeController extends ChangeNotifier {
  final AuthService _auth = AuthService();
  int questionCount = 10;
  int timePerQuestion = 30;

  List<LeaderboardEntry> leaderboard = [];
  bool leaderboardLoading = false;

  HomeController() {
    _loadSettings();
    _loadUserProfile();
    loadLeaderboard();
  }

  Future<void> _loadUserProfile() async {
    final token = _auth.token;
    if (token == null) return;

    try {
      final profile = await ApiService.getUserProfile(token);
      _auth.updateUser(profile);
      notifyListeners();
    } on Exception {
      //
    }
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService().load();
    questionCount = settings.questionCount;
    timePerQuestion = settings.timePerQuestion;
    notifyListeners();
  }

  UserProfile? get user => _auth.user;

  double get xpProgress {
    final u = _auth.user;
    if (u == null) return 0.0;
    final next = u.nextRankXp ?? 100;
    return next > 0 ? (u.xp / next).clamp(0.0, 1.0) : 0.0;
  }

  Future<void> loadLeaderboard() async {
    leaderboardLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.getLeaderboard();
      leaderboard = data
          .map((j) => LeaderboardEntry.fromJson(j as Map<String, dynamic>))
          .toList();
    } on Exception {
      //
    }

    leaderboardLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final token = _auth.token;
    if (token != null) {
      try {
        final profile = await ApiService.getUserProfile(token);
        _auth.updateUser(profile);
      } on Exception {
        //
      }
    }

    await loadLeaderboard();
    await _loadSettings();
  }
}
