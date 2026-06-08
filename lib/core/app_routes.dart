import "package:flutter/material.dart";
import "package:it_quiz_arena/screens/achievements/achievements_screen.dart";
import "package:it_quiz_arena/screens/countdown/countdown_screen.dart";
import "package:it_quiz_arena/screens/course_selection/course_selection_screen.dart";
import "package:it_quiz_arena/screens/home/home_screen.dart";
import "package:it_quiz_arena/screens/login/login_screen.dart";
import "package:it_quiz_arena/screens/onboarding/onboarding_screen.dart";
import "package:it_quiz_arena/screens/profile/profile_screen.dart";
import "package:it_quiz_arena/screens/quiz/quiz_screen.dart";
import "package:it_quiz_arena/screens/ranks/ranks_screen.dart";
import "package:it_quiz_arena/screens/results/results_screen.dart";
import "package:it_quiz_arena/screens/settings/settings_screen.dart";
import "package:it_quiz_arena/screens/splash/splash_screen.dart";

final class AppRoutes {
  static const String splash = "/splash";
  static const String home = "/home";
  static const String login = "/login";
  static const String onboarding = "/onboarding";
  static const String courses = "/courses";
  static const String countdown = "/countdown";
  static const String quiz = "/quiz";
  static const String results = "/results";
  static const String settings = "/settings";
  static const String achievements = "/achievements";
  static const String profile = "/profile";
  static const String ranks = "/ranks";

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      onboarding: (context) => const OnboardingScreen(),
      home: (context) =>
          const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      courses: (context) => const CourseSelectionScreen(),
      countdown: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        Map<String, dynamic>? parsedArgs;
        if (args is Map<String, dynamic>) {
          parsedArgs = args;
        }
        final courseId = (parsedArgs?['courseId'] as int?) ?? 0;
        final questionCount = parsedArgs?['questionCount'] as int? ?? 10;
        final timePerQuestion = parsedArgs?['timePerQuestion'] as int? ?? 30;
        final difficulty = parsedArgs?['difficulty'] as String? ?? 'Beginner';
        return CountdownScreen(
          courseId: courseId,
          questionCount: questionCount,
          timePerQuestion: timePerQuestion,
          difficulty: difficulty,
        );
      },
      quiz: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        Map<String, dynamic>? parsedArgs;
        if (args is Map<String, dynamic>) {
          parsedArgs = args;
        }
        return QuizScreen(
          courseId: (parsedArgs?['courseId'] as int?) ?? 0,
          questionCount: parsedArgs?['questionCount'] as int? ?? 10,
          timePerQuestion: parsedArgs?['timePerQuestion'] as int? ?? 30,
          difficulty: parsedArgs?['difficulty'] as String? ?? 'Beginner',
        );
      },
      results: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        Map<String, dynamic>? parsedArgs;
        if (args is Map<String, dynamic>) {
          parsedArgs = args;
        }
        return ResultsScreen(
          sessionData: parsedArgs?['sessionData'] as Map<String, dynamic>?,
          xpGained: parsedArgs?['xpGained'] as int? ?? 0,
          level: parsedArgs?['level'] as int?,
          levelUp: parsedArgs?['levelUp'] as bool? ?? false,
          newAchievements: (parsedArgs?['newAchievements'] as List<dynamic>?)
              ?.cast<String>(),
        );
      },
      settings: (context) => const SettingsScreen(),
      achievements: (context) => const AchievementsScreen(),
      profile: (context) => const ProfileScreen(),
      ranks: (context) => const RanksScreen(),
    };
  }
}
