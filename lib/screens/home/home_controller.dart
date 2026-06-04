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
    loadLeaderboard();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService().load();
    questionCount = settings.questionCount;
    timePerQuestion = settings.timePerQuestion;
    notifyListeners();
  }

  Map<String, dynamic>? get user => _auth.user;
  String get name => user?['name'] as String? ?? 'Player';
  String get username => user?['username'] as String? ?? '';
  String get email => user?['email'] as String? ?? '';
  int get xp => user?['xp'] as int? ?? 0;
  int get level => user?['level'] as int? ?? 1;
  int get totalQuizzes => user?['total_quizzes'] as int? ?? 0;
  int get highestScore => user?['highest_score'] as int? ?? 0;
  int get bestStreak => user?['best_streak'] as int? ?? 0;
  String? get avatar => user?['avatar'] as String?;
  String get currentRank => user?['current_rank'] as String? ?? 'Beginner';
  int get nextRankXp => user?['next_rank_xp'] as int? ?? 100;

  double get xpProgress {
    final next = nextRankXp;
    return next > 0 ? (xp / next).clamp(0.0, 1.0) : 0.0;
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

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
