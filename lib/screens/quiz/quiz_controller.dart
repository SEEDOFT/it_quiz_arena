import 'dart:async';

import 'package:flutter/material.dart';
import 'package:it_quiz_arena/models/question.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import 'package:it_quiz_arena/services/settings_service.dart';

class QuizController extends ChangeNotifier {
  final int courseId;
  final int questionCount;
  final int timePerQuestion;
  final String difficulty;
  final VoidCallback onQuizFinished;

  int? sessionId;
  List<Question> questions = [];
  bool loading = true;
  String? error;

  int currentQuestionIndex = 0;
  int selectedAnswerIndex = -1;
  bool answerSubmitted = false;
  int remainingSeconds;
  int timeSpentOnQuestion = 0;
  Timer? timer;
  bool _cycleEnding = false;

  bool? lastAnswerCorrect;
  int correctAnswerIndex = -1;
  String? lastExplanation;
  bool answerLocked = false;
  int score = 0;
  int streak = 0;
  int highestStreak = 0;
  int correctCount = 0;
  int wrongCount = 0;

  Map<String, dynamic>? finishData;
  bool finishing = false;
  bool _cancelled = false;
  bool showExplanation = true;

  QuizController({
    required this.courseId,
    required this.questionCount,
    required this.timePerQuestion,
    this.difficulty = 'Beginner',
    required this.onQuizFinished,
  }) : remainingSeconds = timePerQuestion {
    _startQuiz();
  }

  Question? get currentQuestion =>
      questions.isEmpty ? null : questions[currentQuestionIndex];

  Future<void> _startQuiz() async {
    final settings = await SettingsService().load();
    showExplanation = settings.showExplanation;

    loading = true;
    sessionId = null;
    error = null;
    currentQuestionIndex = 0;
    selectedAnswerIndex = -1;
    answerSubmitted = false;
    lastAnswerCorrect = null;
    correctAnswerIndex = -1;
    lastExplanation = null;
    answerLocked = false;
    _cycleEnding = false;
    notifyListeners();

    final token = AuthService().token;
    if (token == null) {
      error = 'Not authenticated';
      loading = false;
      notifyListeners();
      return;
    }

    try {
      final data = await ApiService.startQuiz(
        courseId,
        questionCount: questionCount,
        difficulty: difficulty,
        token: token,
      );

      sessionId = data['session']['id'] as int?;
      final questionsRaw = data['questions'] as List<dynamic>;
      questions = questionsRaw
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList();

      loading = false;
      notifyListeners();
      _startTimer();
    } on Exception catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    remainingSeconds = timePerQuestion;
    timeSpentOnQuestion = 0;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        timeSpentOnQuestion++;
        notifyListeners();
      } else {
        _submitAnswerToApi(timeout: true);
      }
    });
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (answerSubmitted) return;
    selectedAnswerIndex = index;
    notifyListeners();
  }

  void submitAnswer() {
    if (answerSubmitted || selectedAnswerIndex < 0) return;
    _submitAnswerToApi();
  }

  Future<void> _submitAnswerToApi({bool timeout = false}) async {
    if (answerSubmitted || questions.isEmpty || sessionId == null) return;

    timer?.cancel();
    answerSubmitted = true;
    answerLocked = true;
    notifyListeners();

    final token = AuthService().token;
    if (token == null) return;

    final question = questions[currentQuestionIndex];
    final option = timeout ? -1 : selectedAnswerIndex;

    final apiFuture = ApiService.answerQuestion(
      sessionId: sessionId!,
      questionId: question.id,
      selectedOption: option,
      timeSpent: timeSpentOnQuestion,
      token: token,
    );

    await Future.delayed(const Duration(seconds: 1));

    try {
      final data = await apiFuture;

      lastAnswerCorrect = data['is_correct'] as bool?;
      correctAnswerIndex = data['correct_answer'] as int? ?? -1;
      lastExplanation = data['explanation'] as String?;

      final session = data['session'] as Map<String, dynamic>?;
      if (session != null) {
        score = session['score'] as int? ?? score;
        correctCount = session['correct_count'] as int? ?? correctCount;
        wrongCount = session['wrong_count'] as int? ?? wrongCount;
        streak = session['streak'] as int? ?? streak;
        highestStreak = session['highest_streak'] as int? ?? highestStreak;
      }
    } on Exception catch (e) {
      error = e.toString();
    }

    answerLocked = false;
    notifyListeners();

    final delay = lastAnswerCorrect == false && showExplanation
        ? const Duration(seconds: 3)
        : const Duration(milliseconds: 1200);
    Future.delayed(delay, _nextQuestion);
  }

  void _nextQuestion() {
    if (_cancelled) return;

    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      selectedAnswerIndex = -1;
      answerSubmitted = false;
      answerLocked = false;
      lastAnswerCorrect = null;
      correctAnswerIndex = -1;
      lastExplanation = null;
      _startTimer();
    } else {
      _cycleComplete();
    }
  }

  Future<void> _cycleComplete() async {
    if (_cycleEnding) return;
    _cycleEnding = true;
    timer?.cancel();

    final token = AuthService().token;
    if (token != null && sessionId != null) {
      try {
        finishData = await ApiService.finishQuiz(
          sessionId: sessionId!,
          token: token,
        );
      } catch (_) {}
    }

    onQuizFinished();
  }

  Future<void> cancelQuiz() async {
    _cancelled = true;
    timer?.cancel();
    if (!finishing && sessionId != null) {
      finishing = true;
      final token = AuthService().token;
      if (token != null) {
        try {
          finishData = await ApiService.finishQuiz(
            sessionId: sessionId!,
            token: token,
          );
        } catch (_) {}
      }
    }
    onQuizFinished();
  }

  Color optionColor(int index) {
    if (!answerSubmitted || questions.isEmpty) {
      if (selectedAnswerIndex == index) {
        return const Color(0xFF6366F1);
      }
      return const Color(0xFF1E293B);
    }

    if (answerLocked) {
      if (selectedAnswerIndex == index) {
        return const Color(0xFF6366F1).withValues(alpha: 0.4);
      }
      return const Color(0xFF1E293B);
    }

    if (index == correctAnswerIndex) {
      return Colors.green;
    }

    if (index == selectedAnswerIndex) {
      return Colors.red;
    }

    return const Color(0xFF1E293B);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
