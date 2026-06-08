import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/core/app_routes.dart';
import 'package:it_quiz_arena/screens/results/results_screen.dart';
import 'package:it_quiz_arena/services/audio_service.dart';

Widget _buildApp(ResultsScreen screen) {
  return MaterialApp(home: screen, routes: AppRoutes.getRoutes());
}

void main() {
  setUp(() async {
    await dotenv.load(fileName: '.env');
    SharedPreferences.setMockInitialValues({'sound_enabled': false});
    await AudioService().reload();
  });

  group('ResultsScreen', () {
    testWidgets('renders score and rank for basic data', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            sessionData: {
              'score': 75,
              'correct_count': 6,
              'wrong_count': 4,
              'total_questions': 10,
              'highest_streak': 3,
              'accuracy': 60.0,
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Quiz Completed'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('IT SPECIALIST'), findsOneWidget);
      expect(find.text('Accuracy'), findsOneWidget);
      expect(find.text('60.0%'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('Wrong'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('shows XP gained when > 0', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            xpGained: 35,
            sessionData: {
              'score': 50,
              'correct_count': 5,
              'wrong_count': 5,
              'total_questions': 10,
              'highest_streak': 2,
              'accuracy': 50.0,
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('+35 XP'), findsOneWidget);
    });

    testWidgets('does not show XP when 0', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            xpGained: 0,
            sessionData: {
              'score': 50,
              'correct_count': 5,
              'wrong_count': 5,
              'total_questions': 10,
              'highest_streak': 2,
              'accuracy': 50.0,
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('+0 XP'), findsNothing);
    });

    testWidgets('shows level up when levelUp is true', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            levelUp: true,
            level: 3,
            sessionData: {
              'score': 90,
              'correct_count': 9,
              'wrong_count': 1,
              'total_questions': 10,
              'highest_streak': 5,
              'accuracy': 95.0,
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Level 3!'), findsOneWidget);
    });

    testWidgets('does not show level up when levelUp is false', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            levelUp: false,
            level: null,
            sessionData: {
              'score': 50,
              'correct_count': 5,
              'wrong_count': 5,
              'total_questions': 10,
              'highest_streak': 2,
              'accuracy': 50.0,
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Level'), findsNothing);
    });

    testWidgets('shows achievements unlocked when provided', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            newAchievements: ['first_quiz', 'perfect_score'],
            sessionData: {
              'score': 50,
              'correct_count': 5,
              'wrong_count': 5,
              'total_questions': 10,
              'highest_streak': 2,
              'accuracy': 50.0,
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Achievements Unlocked'), findsOneWidget);
      expect(find.text('First Quiz'), findsOneWidget);
      expect(find.text('Perfect Score'), findsOneWidget);
    });

    testWidgets('does not show achievements section when empty', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            newAchievements: [],
            sessionData: {
              'score': 50,
              'correct_count': 5,
              'wrong_count': 5,
              'total_questions': 10,
              'highest_streak': 2,
              'accuracy': 50.0,
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Achievements Unlocked'), findsNothing);
    });

    testWidgets('renders IT LEGEND rank for high accuracy', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            sessionData: {
              'score': 100,
              'correct_count': 10,
              'wrong_count': 0,
              'total_questions': 10,
              'highest_streak': 10,
              'accuracy': 100.0,
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('IT LEGEND'), findsOneWidget);
    });

    testWidgets('renders IT TRAINEE rank for low accuracy', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            sessionData: {
              'score': 10,
              'correct_count': 1,
              'wrong_count': 9,
              'total_questions': 10,
              'highest_streak': 1,
              'accuracy': 10.0,
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('IT TRAINEE'), findsOneWidget);
    });

    testWidgets('Play Again button is present', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            sessionData: {
              'score': 50,
              'correct_count': 5,
              'wrong_count': 5,
              'total_questions': 10,
              'highest_streak': 2,
              'accuracy': 50.0,
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Play Again'), findsOneWidget);
    });

    testWidgets('Home button is present', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          ResultsScreen(
            sessionData: {
              'score': 50,
              'correct_count': 5,
              'wrong_count': 5,
              'total_questions': 10,
              'highest_streak': 2,
              'accuracy': 50.0,
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
