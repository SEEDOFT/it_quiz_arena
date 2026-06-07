import 'package:flutter/material.dart';
import 'package:it_quiz_arena/screens/quiz/quiz_screen.dart';
import 'countdown_controller.dart';

class CountdownScreen extends StatefulWidget {
  final int courseId;
  final int questionCount;
  final int timePerQuestion;
  final String difficulty;

  const CountdownScreen({
    super.key,
    required this.courseId,
    required this.questionCount,
    required this.timePerQuestion,
    this.difficulty = 'Beginner',
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late final CountdownController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CountdownController(onCountdownFinished: _navigateToQuiz);
  }

  void _navigateToQuiz() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            courseId: widget.courseId,
            questionCount: widget.questionCount,
            timePerQuestion: widget.timePerQuestion,
            difficulty: widget.difficulty,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: cs.primary,
        body: Center(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Ready!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '${_controller.countdown}',
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '${widget.questionCount} questions',
                    style: TextStyle(
                      fontSize: 18,
                      color: cs.onPrimary.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
