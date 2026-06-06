import 'package:flutter/material.dart';
import 'package:it_quiz_arena/core/app_routes.dart';
import 'package:it_quiz_arena/models/leaderboard.dart';

import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  final int numberOfQuestions;
  final int timePerQuestion;

  const HomeScreen({super.key, required this.numberOfQuestions, required this.timePerQuestion});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _buildProfileCard(context),
                    const SizedBox(height: 20),
                    _buildStatsRow(context),
                    const SizedBox(height: 20),
                    _buildGameSection(context),
                    const SizedBox(height: 24),
                    _buildLeaderboard(context),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.memory, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              "IT QUIZ ARENA",
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.achievements),
          icon: Icon(Icons.emoji_events, color: cs.primary),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          icon: Icon(Icons.settings, color: cs.primary),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = _controller.initials;
    final name = _controller.name;
    final username = _controller.username;
    final rank = _controller.currentRank;
    final xp = _controller.xp;
    final level = _controller.level;
    final progress = _controller.xpProgress;
    final nextXp = _controller.nextRankXp;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary.withValues(alpha: 0.2), cs.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: cs.primary,
                  backgroundImage: _controller.avatar != null
                      ? NetworkImage(_controller.avatar!)
                      : null,
                  child: _controller.avatar != null
                      ? null
                      : Text(
                          initials,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('@$username', style: TextStyle(color: cs.outline, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          rank,
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: cs.surface,
                valueColor: AlwaysStoppedAnimation(cs.primary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lv.$level · $xp XP',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
                Text('$nextXp XP to next rank', style: TextStyle(color: cs.outline, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        _statCard(context, Icons.quiz_outlined, '${_controller.totalQuizzes}', 'Quizzes'),
        const SizedBox(width: 10),
        _statCard(context, Icons.trending_up, '${_controller.highestScore}', 'Best Score'),
        const SizedBox(width: 10),
        _statCard(context, Icons.local_fire_department, '${_controller.bestStreak}', 'Best Streak'),
      ],
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String value, String label) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(label, style: TextStyle(color: cs.outline, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Text(
            "Test Your IT Skills",
            style: TextStyle(color: cs.onSurface, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            "${_controller.questionCount} questions · ${_controller.timePerQuestion}s each",
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _gameStat(context, "${_controller.questionCount}", "Questions"),
              const SizedBox(width: 10),
              _gameStat(context, "${_controller.timePerQuestion}s", "Per Question"),
              const SizedBox(width: 10),
              _gameStat(context, "${_controller.questionCount * 50}", "Max Pts"),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.courses),
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                "Start Game",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gameStat(BuildContext context, String value, String label) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOP PLAYERS",
                style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold),
              ),
              Text("All time", style: TextStyle(color: cs.outline)),
            ],
          ),
          const SizedBox(height: 12),
          if (_controller.leaderboardLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_controller.leaderboard.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("No data yet", style: TextStyle(color: cs.outline)),
            )
          else
            ..._controller.leaderboard.map((e) => _leaderboardRow(context, e)),
        ],
      ),
    );
  }

  Widget _leaderboardRow(BuildContext context, LeaderboardEntry entry) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${_controller.leaderboard.indexOf(entry) + 1}',
              style: TextStyle(color: cs.outline, fontWeight: FontWeight.bold),
            ),
          ),
          CircleAvatar(
            backgroundColor: entry.avatar != null
                ? Colors.transparent
                : cs.primary.withValues(alpha: 0.2),
            backgroundImage: entry.avatar != null
                ? NetworkImage(entry.avatar!)
                : null,
            child: entry.avatar != null
                ? null
                : Text(
                    _initials(entry.playerName),
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.playerName, style: TextStyle(color: cs.onSurface)),
                if (entry.rank != null)
                  Text(entry.rank!, style: TextStyle(color: cs.outline, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${entry.xp} XP',
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
