import 'package:flutter/material.dart';

class ResultsController extends ChangeNotifier {
  final int score;
  final int correctCount;
  final int wrongCount;
  final int totalQuestions;
  final int highestStreak;
  final double accuracy;
  final int xpGained;
  final int? level;
  final bool levelUp;

  ResultsController({
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.totalQuestions,
    required this.highestStreak,
    required this.accuracy,
    required this.xpGained,
    this.level,
    this.levelUp = false,
  });

  String get rank {
    if (accuracy >= 95) return "IT LEGEND";
    if (accuracy >= 85) return "IT MASTER";
    if (accuracy >= 70) return "IT EXPERT";
    if (accuracy >= 50) return "IT SPECIALIST";
    return "IT TRAINEE";
  }

  IconData get rankIcon {
    if (accuracy >= 95) return Icons.workspace_premium;
    if (accuracy >= 85) return Icons.emoji_events;
    if (accuracy >= 70) return Icons.star;
    return Icons.school;
  }
}
