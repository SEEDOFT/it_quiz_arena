import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/rank.dart';
import 'package:it_quiz_arena/widgets/adaptive.dart';
import 'ranks_controller.dart';

class RanksScreen extends StatefulWidget {
  const RanksScreen({super.key});

  @override
  State<RanksScreen> createState() => _RanksScreenState();
}

class _RanksScreenState extends State<RanksScreen> {
  late final RanksController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RanksController();
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
      appBar: buildAdaptiveAppBar(title: "IT Ranks", context: context),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCurrentRankCard(cs),
              const SizedBox(height: 24),
              ..._controller.ranks.map((r) => _buildRankTile(cs, r)),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentRankCard(ColorScheme cs) {
    final current = _controller.currentRank;
    final next = _controller.nextRank;
    final progress = _controller.xpProgress;

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
          Icon(Icons.emoji_events, color: cs.primary, size: 48),
          const SizedBox(height: 8),
          Text(
            current?.title ?? '',
            style: TextStyle(
              color: cs.primary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_controller.userXp} XP',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
          ),
          if (next != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: cs.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation(cs.primary),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${next.requiredXp - _controller.userXp} XP to ${next.title}',
              style: TextStyle(color: cs.outline, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankTile(ColorScheme cs, Rank rank) {
    final isUnlocked = rank.requiredXp <= _controller.userXp;
    final isCurrent = rank.id == _controller.currentRank?.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent ? cs.primary.withValues(alpha: 0.1) : cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent
                ? cs.primary.withValues(alpha: 0.5)
                : isUnlocked
                ? cs.primary.withValues(alpha: 0.2)
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? cs.primary.withValues(alpha: 0.2)
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconFor(rank.icon, isUnlocked),
                color: isUnlocked ? cs.primary : cs.outline,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank.title,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${rank.requiredXp} XP required',
                    style: TextStyle(color: cs.outline, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Current',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isUnlocked)
              Icon(Icons.check_circle, color: cs.primary, size: 20)
            else
              Icon(Icons.lock, color: cs.outline, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String? icon, bool unlocked) {
    if (!unlocked) return Icons.lock;
    switch (icon) {
      case 'trophy':
        return Icons.emoji_events;
      case 'star':
        return Icons.star;
      case 'shield':
        return Icons.shield;
      case 'lightning':
        return Icons.bolt;
      case 'diamond':
        return Icons.diamond;
      case 'crown':
        return Icons.workspace_premium;
      default:
        return Icons.emoji_events;
    }
  }
}
