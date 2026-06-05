import "package:flutter/material.dart";

import "../screens/achievements/achievements_screen.dart";
import "../screens/countdown/countdown_screen.dart";
import "../screens/course_selection/course_selection_screen.dart";
import "../screens/home/home_screen.dart";
import "../screens/profile/profile_screen.dart";
import "../screens/ranks/ranks_screen.dart";
import "../screens/results/results_screen.dart";
import "../screens/settings/settings_screen.dart";

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
      home: (context) => const HomeScreen(numberOfQuestions: 10, timePerQuestion: 30),
      AppRoutes.courses: (context) => const CourseSelectionScreen(),
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
