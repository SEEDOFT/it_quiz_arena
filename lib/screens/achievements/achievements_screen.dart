import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/achievement.dart';
import 'package:it_quiz_arena/widgets/adaptive.dart';

import 'achievements_controller.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late final AchievementsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AchievementsController();
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
      appBar: buildAdaptiveAppBar(title: "Achievements", context: context),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.achievements.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader(cs);
              }
              final a = _controller.achievements[index - 1];
              return _achievementCard(cs, a);
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    final total = _controller.achievements.length;
    final unlocked = _controller.unlockedCount;

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
      child: Column(
        children: [
          Text(
            '$unlocked / $total',
            style: TextStyle(
              color: cs.primary,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Achievements Unlocked',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? unlocked / total : 0,
              backgroundColor: cs.surface,
              valueColor: AlwaysStoppedAnimation(cs.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementCard(ColorScheme cs, Achievement a) {
    final isUnlocked = a.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? cs.primary.withValues(alpha: 0.4)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? cs.primary.withValues(alpha: 0.2)
                  : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconFor(a.icon),
              color: isUnlocked ? cs.primary : cs.outline,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        a.title,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Icon(Icons.check_circle, color: cs.primary, size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  a.description,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: a.progressFraction,
                    backgroundColor: cs.surfaceContainerLow,
                    valueColor: AlwaysStoppedAnimation(
                      isUnlocked ? cs.primary : cs.outline,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${a.progress} / ${a.requiredValue}',
                  style: TextStyle(color: cs.outline, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String? icon) {
    switch (icon) {
      case 'trophy':
        return Icons.emoji_events;
      case 'star':
        return Icons.star;
      case 'lightning':
        return Icons.bolt;
      case 'fire':
        return Icons.local_fire_department;
      case 'shield':
        return Icons.shield;
      case 'book':
        return Icons.menu_book;
      default:
        return Icons.emoji_events;
    }
  }
}
