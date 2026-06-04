import 'package:flutter/material.dart';

class QuizTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback onTimeUp;
  final bool isActive;

  const QuizTimer({
    super.key,
    required this.totalSeconds,
    required this.onTimeUp,
    this.isActive = true,
  });

  @override
  State<QuizTimer> createState() => _QuizTimerState();
}

class _QuizTimerState extends State<QuizTimer> with TickerProviderStateMixin {
  late int remainingSeconds;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.totalSeconds;
    startTimer();
  }

  void startTimer() {
    if (!widget.isActive) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          remainingSeconds--;
        });

        if (remainingSeconds > 0) {
          startTimer();
        } else {
          widget.onTimeUp();
        }
      }
    });
  }

  String get timeDisplay {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get timerColor {
    if (remainingSeconds <= 5) {
      return Colors.red;
    } else if (remainingSeconds <= 10) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: timerColor.withValues(alpha: 0.1),
        border: Border.all(color: timerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Time Remaining',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            timeDisplay,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: timerColor,
            ),
          ),
        ],
      ),
    );
  }
}
