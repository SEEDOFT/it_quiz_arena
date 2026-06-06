import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Google Sign-In (loaded from .env)
  static String get googleServerClientId =>
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';

  // API Configuration
  static String get apiBaseUrl => '${dotenv.env['API_BASE_URL']}/api';
  static const int apiTimeout = 30; // seconds

  // Quiz Settings
  static const int defaultTimePerQuestion = 30; // seconds
  static const int defaultQuestionCount = 10;
  static const int maxQuestionsPerSession = 50;
  static const int minQuestionsPerSession = 5;

  // Scoring
  static const int correctAnswerPoints = 50;
  static const int baseXpGain = 10;
  static const int maxXpPerQuestion = 20;

  // Ranks
  static const List<int> rankThresholds = [0, 100, 300, 700, 1200, 2000];
  static const List<String> rankNames = [
    'Beginner',
    'Explorer',
    'Specialist',
    'Expert',
    'Master',
    'Grandmaster',
  ];

  // Achievements
  static const int achievementFirstQuiz = 0;
  static const int achievementQuizMaster = 100;
  static const int achievementPerfectScore = 50;

  // Storage Keys
  static const String storageKeyPlayerData = 'player_data';
  static const String storageKeySettings = 'app_settings';
  static const String storageKeyAchievements = 'achievements';

  // App Info
  static const String appName = 'IT Quiz Arena';
  static const String appVersion = '1.0.0';

  //Login Logo
  static const String googleLogo = "assets/images/svg/Google_G_logo.svg";

  // API Endpoints
  static const String authGoogle = '/auth/google';
  static const String logout = '/logout';
  static const String courses = '/courses';
  static const String quizStart = '/quiz/start';
  static const String quizAnswer = '/quiz/'; // append sessionId + '/answer'
  static const String quizFinish = '/quiz/'; // append sessionId + '/finish'
  static const String leaderboard = '/leaderboard';
  static const String achievements = '/achievements';
  static const String userAchievements = '/user/achievements';
  static const String ranks = '/ranks';
  static const String userProfile = '/user';
  static const String userStats = '/user/stats';
  static const String userSettings = '/user/settings';
  static const String userResetProgress = '/user/reset-progress';

  // Sound Effects
  static const String soundCorrectAnswer = 'sounds/sfx/correct_answer.wav';
  static const String soundWrongAnswer = 'sounds/sfx/wrong_answer.wav';
  static const String soundButtonTap = 'sounds/sfx/button-tap.mp3';
  static const String soundQuestionTransition =
      'sounds/sfx/question-transition.mp3';
  static const String soundTimeWarning = 'sounds/sfx/time-warning.mp3';
  static const String soundQuizFinish = 'sounds/sfx/quiz-finish.mp3';
  static const String soundAchievementUnlock =
      'sounds/sfx/achievement-unlock.mp3';
  static const String soundLevelUp = 'sounds/sfx/level-up.mp3';
}
