import 'package:flutter/material.dart';
import 'package:it_quiz_arena/core/app_routes.dart';
import 'package:it_quiz_arena/models/user_stats.dart';
import 'package:it_quiz_arena/services/audio_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import 'package:it_quiz_arena/widgets/adaptive.dart';

import 'profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
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
      appBar: buildAdaptiveAppBar(title: "Profile & Stats", context: context),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = _controller.stats;
          final user = _auth.user;
          final name = user?.name ?? 'Player';
          final username = user?.username ?? '';
          final initials = _initials(name);

          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _profileHeader(cs, name, username, initials, stats),
                const SizedBox(height: 20),
                _accuracyCard(cs, stats),
                const SizedBox(height: 20),
                _statsGrid(cs, stats),
                const SizedBox(height: 20),
                _rankSection(cs, stats),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileHeader(
    ColorScheme cs,
    String name,
    String username,
    String initials,
    UserStats? stats,
  ) {
    return Container(
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
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
                      fontSize: 26,
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
                Text(
                  '@$username',
                  style: TextStyle(color: cs.outline, fontSize: 13),
                ),
                const SizedBox(height: 4),
                if (stats != null) ...[
                  Text(
                    'Lv.${stats.level} · ${stats.xp} XP',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  if (stats.currentRank != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        stats.currentRank!,
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accuracyCard(ColorScheme cs, UserStats? stats) {
    final accuracy = stats?.overallAccuracy ?? 0.0;
    final total = stats?.totalQuizzes ?? 0;
    final correct = stats?.totalCorrect ?? 0;
    final wrong = stats?.totalWrong ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Accuracy',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${accuracy.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: accuracy >= 80
                      ? Colors.green
                      : accuracy >= 50
                      ? Colors.orange
                      : Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: accuracy / 100,
              backgroundColor: cs.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation(
                accuracy >= 80
                    ? Colors.green
                    : accuracy >= 50
                    ? Colors.orange
                    : Colors.red,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _pill(cs, correct, 'Correct', Colors.green),
              _pill(cs, wrong, 'Wrong', Colors.red),
              _pill(cs, total, 'Total', cs.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(ColorScheme cs, int value, String label, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(label, style: TextStyle(color: cs.outline, fontSize: 11)),
      ],
    );
  }

  Widget _statsGrid(ColorScheme cs, UserStats? stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem(
                cs,
                Icons.quiz_outlined,
                '${stats?.totalQuizzes ?? 0}',
                'Quizzes',
              ),
              const SizedBox(width: 10),
              _statItem(
                cs,
                Icons.trending_up,
                '${stats?.highestScore ?? 0}',
                'Best Score',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statItem(
                cs,
                Icons.local_fire_department,
                '${stats?.bestStreak ?? 0}',
                'Best Streak',
              ),
              const SizedBox(width: 10),
              _statItem(
                cs,
                Icons.check_circle_outline,
                '${stats?.totalCorrect ?? 0}',
                'Correct',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(ColorScheme cs, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label, style: TextStyle(color: cs.outline, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _rankSection(ColorScheme cs, UserStats? stats) {
    if (stats == null || stats.currentRank == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        AudioService().playTap();
        Navigator.pushNamed(context, AppRoutes.ranks);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: cs.primary, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Rank',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                  Text(
                    stats.currentRank!,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.outline),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
