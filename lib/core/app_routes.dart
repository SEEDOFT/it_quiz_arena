import "package:flutter/material.dart";
import "../screens/home/home_screen.dart";
import "../screens/course_selection/course_selection_screen.dart";
import "../screens/settings/settings_screen.dart";
import "../screens/countdown/countdown_screen.dart";
import "../screens/results/results_screen.dart";
import "../screens/achievements/achievements_screen.dart";
import "../screens/profile/profile_screen.dart";
import "../screens/ranks/ranks_screen.dart";

class AppRoutes {
  static const String home = "/home";
  static const String courses = "/courses";
  static const String countdown = "/countdown";
  static const String results = "/results";
  static const String settings = "/settings";
  static const String achievements = "/achievements";
  static const String profile = "/profile";
  static const String ranks = "/ranks";

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) =>
          const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      AppRoutes.courses: (context) => const CourseSelectionScreen(),
      countdown: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final courseId = args?['courseId'] as int;
        final questionCount = args?['questionCount'] as int? ?? 10;
        final timePerQuestion = args?['timePerQuestion'] as int? ?? 30;
        final difficulty = args?['difficulty'] as String? ?? 'Beginner';
        return CountdownScreen(
          courseId: courseId,
          questionCount: questionCount,
          timePerQuestion: timePerQuestion,
          difficulty: difficulty,
        );
      },
      results: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return ResultsScreen(
          sessionData: args?['sessionData'] as Map<String, dynamic>?,
          xpGained: args?['xpGained'] as int? ?? 0,
          level: args?['level'] as int?,
          levelUp: args?['levelUp'] as bool? ?? false,
          newAchievements: (args?['newAchievements'] as List<dynamic>?)
              ?.map((a) => a as Map<String, dynamic>)
              .toList(),
        );
      },
      settings: (context) => const SettingsScreen(),
      achievements: (context) => const AchievementsScreen(),
      profile: (context) => const ProfileScreen(),
      ranks: (context) => const RanksScreen(),
    };
  }
}
