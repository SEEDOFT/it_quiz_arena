import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/leaderboard.dart';
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
    } catch (_) {}
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService().load();
    questionCount = settings.questionCount;
    timePerQuestion = settings.timePerQuestion;
    notifyListeners();
  }

  String get name => _auth.user?.name ?? 'Player';
  String get username => _auth.user?.username ?? '';
  String get email => _auth.user?.email ?? '';
  int get xp => _auth.user?.xp ?? 0;
  int get level => _auth.user?.level ?? 1;
  int get totalQuizzes => _auth.user?.totalQuizzes ?? 0;
  int get highestScore => _auth.user?.highestScore ?? 0;
  int get bestStreak => _auth.user?.bestStreak ?? 0;
  String? get avatar => _auth.user?.avatar;
  String get currentRank => _auth.user?.currentRank ?? 'Beginner';
  int get nextRankXp => _auth.user?.nextRankXp ?? 100;

  double get xpProgress {
    final next = nextRankXp;
    return next > 0 ? (xp / next).clamp(0.0, 1.0) : 0.0;
  }

  String get initials => _auth.user?.initials ?? '?';

  Future<void> loadLeaderboard() async {
    leaderboardLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.getLeaderboard();
      leaderboard = data
          .map((j) => LeaderboardEntry.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {}

    leaderboardLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final token = _auth.token;
    if (token != null) {
      try {
        final profile = await ApiService.getUserProfile(token);
        _auth.updateUser(profile);
      } catch (_) {}
    }

    await loadLeaderboard();
    await _loadSettings();
  }
}
