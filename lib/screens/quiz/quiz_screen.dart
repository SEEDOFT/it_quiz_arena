import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:it_quiz_arena/screens/results/results_screen.dart';

import 'quiz_controller.dart';

class QuizScreen extends StatefulWidget {
  final int courseId;
  final int questionCount;
  final int timePerQuestion;
  final String difficulty;

  const QuizScreen({
    super.key,
    required this.courseId,
    required this.questionCount,
    required this.timePerQuestion,
    this.difficulty = 'Beginner',
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  late final QuizController _controller;
  bool _quitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = QuizController(
      courseId: widget.courseId,
      questionCount: widget.questionCount,
      timePerQuestion: widget.timePerQuestion,
      difficulty: widget.difficulty,
      onQuizFinished: _navigateToResults,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _controller.cancelQuiz();
    }
  }

  Future<bool> _onWillPop() async {
    if (_quitting) return false;
    final cs = Theme.of(context).colorScheme;
    final result = await (Platform.isIOS
        ? showCupertinoDialog<bool>(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('Quit Quiz?'),
              content: const Text('Your progress will be lost.'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Continue'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Quit'),
                ),
              ],
            ),
          )
        : showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: cs.surface,
              title: Text('Quit Quiz?', style: TextStyle(color: cs.onSurface)),
              content: Text(
                'Your progress will be lost.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Continue', style: TextStyle(color: cs.primary)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Quit', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ));

    if (result == true) {
      _quitting = true;
      _controller.cancelQuiz();
      return true;
    }
    return false;
  }

  void _navigateToResults() {
    if (!mounted) return;

    if (_controller.finishData == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      return;
    }

    final levelUp = _controller.finishData?['level_up'];
    final parsedLevelUp = levelUp is bool ? levelUp : levelUp == 1;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          sessionData: _controller.finishData?['session'] as Map<String, dynamic>?,
          xpGained: _controller.finishData?['xp_gained'] as int? ?? 0,
          level: _controller.finishData?['new_level'] as int?,
          levelUp: parsedLevelUp,
          newAchievements: (_controller.finishData?['new_achievements'] as List<dynamic>?)
              ?.cast<String>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (_controller.error != null) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _controller.error!,
                    style: TextStyle(color: cs.onSurface),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          if (_controller.currentQuestion == null) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                child: Text('No questions', style: TextStyle(color: cs.onSurface)),
              ),
            );
          }

          final currentQuestion = _controller.currentQuestion!;
          final progress = (_controller.currentQuestionIndex + 1) / _controller.questions.length;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                          onPressed: _onWillPop,
                        ),
                        Expanded(child: LinearProgressIndicator(value: progress)),
                        const SizedBox(width: 12),
                        Text(
                          '${_controller.remainingSeconds} s',
                          style: TextStyle(color: cs.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Question ${_controller.currentQuestionIndex + 1}/${_controller.questions.length}',
                        style: TextStyle(color: cs.outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        currentQuestion.question,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            currentQuestion.options.length +
                            (_controller.answerSubmitted &&
                                    _controller.lastAnswerCorrect == false &&
                                    _controller.lastExplanation != null &&
                                    _controller.showExplanation
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index < currentQuestion.options.length) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _controller.selectAnswer(index),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _controller.optionColor(index),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    currentQuestion.options[index],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.red.shade300, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _controller.lastExplanation!,
                                      style: TextStyle(color: Colors.red.shade200, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _controller.selectedAnswerIndex == -1 || _controller.answerSubmitted
                                ? null
                                : () => _controller.submitAnswer(),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Score: ${_controller.score}', style: TextStyle(color: cs.onSurface)),
                        Text(
                          'Streak: ${_controller.streak}',
                          style: TextStyle(color: cs.onSurface),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
