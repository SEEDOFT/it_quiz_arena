import 'package:flutter/material.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String playerName;
  final int score;
  final String badge;
  final bool isCurrentUser;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.playerName,
    required this.score,
    required this.badge,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: Colors.blue, width: 2)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '#$rank',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Text(badge, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              playerName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$score pts',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
