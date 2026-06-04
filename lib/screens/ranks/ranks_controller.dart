import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/rank.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';

class RanksController extends ChangeNotifier {
  List<Rank> ranks = [];
  bool loading = true;

  int userXp = 0;

  RanksController() {
    load();
  }

  int get currentRankIndex {
    int idx = 0;
    for (int i = 0; i < ranks.length; i++) {
      if (ranks[i].requiredXp <= userXp) idx = i;
    }
    return idx;
  }

  Rank? get currentRank => ranks.isNotEmpty ? ranks[currentRankIndex] : null;
  Rank? get nextRank =>
      currentRankIndex + 1 < ranks.length ? ranks[currentRankIndex + 1] : null;

  double get xpProgress {
    if (nextRank == null) return 1.0;
    final currentXp = ranks[currentRankIndex].requiredXp;
    final nextXp = nextRank!.requiredXp;
    final needed = nextXp - currentXp;
    if (needed <= 0) return 1.0;
    return ((userXp - currentXp) / needed).clamp(0.0, 1.0);
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();

    userXp = (AuthService().user?['xp'] as int?) ?? 0;

    try {
      final data = await ApiService.getRanks();
      ranks = data
          .map((j) => Rank.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {}

    loading = false;
    notifyListeners();
  }
}
