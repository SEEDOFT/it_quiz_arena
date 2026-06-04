import 'package:flutter/material.dart';
import 'package:it_quiz_arena/screens/course_selection/course_selection_screen.dart';
import 'package:it_quiz_arena/screens/home/home_screen.dart';
import 'results_controller.dart';

class ResultsScreen extends StatefulWidget {
  final Map<String, dynamic>? sessionData;
  final int xpGained;
  final int? level;
  final bool levelUp;
  final List<Map<String, dynamic>>? newAchievements;

  const ResultsScreen({
    super.key,
    this.sessionData,
    this.xpGained = 0,
    this.level,
    this.levelUp = false,
    this.newAchievements,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final ResultsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ResultsController(
      score: widget.sessionData?['score'] as int? ?? 0,
      correctCount: widget.sessionData?['correct_count'] as int? ?? 0,
      wrongCount: widget.sessionData?['wrong_count'] as int? ?? 0,
      totalQuestions: widget.sessionData?['total_questions'] as int? ?? 0,
      highestStreak: widget.sessionData?['highest_streak'] as int? ?? 0,
      accuracy: (widget.sessionData?['accuracy'] as num? ?? 0).toDouble(),
      xpGained: widget.xpGained,
      level: widget.level,
      levelUp: widget.levelUp,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 60,
                backgroundColor: cs.primary.withValues(alpha: 0.15),
                child: Icon(_controller.rankIcon, size: 60, color: cs.primary),
              ),

              const SizedBox(height: 24),

              Text(
                "Quiz Completed",
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _controller.rank,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (widget.levelUp && widget.level != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Level ${widget.level}!',
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 30),

              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text("Final Score", style: TextStyle(color: cs.outline)),
                    const SizedBox(height: 8),
                    Text(
                      _controller.score.toString(),
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_controller.xpGained > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${_controller.xpGained} XP',
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context,
                      "Accuracy",
                      "${_controller.accuracy.toStringAsFixed(1)}%",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context,
                      "Streak",
                      _controller.highestStreak.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context,
                      "Correct",
                      _controller.correctCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context,
                      "Wrong",
                      _controller.wrongCount.toString(),
                    ),
                  ),
                ],
              ),

              if (widget.newAchievements != null &&
                  widget.newAchievements!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Achievements Unlocked',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.newAchievements!.map(
                        (a) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            a['title'] as String? ?? '',
                            style: TextStyle(color: cs.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CourseSelectionScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text("Play Again"),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(
                          numberOfQuestions: 10,
                          timePerQuestion: 30,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text("Home"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String title, String value) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: cs.outline)),
        ],
      ),
    );
  }
}
