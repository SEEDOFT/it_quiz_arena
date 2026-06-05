import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MockSharedPreferences {
  static Future<SharedPreferences> withData(Map<String, Object> data) async {
    SharedPreferences.setMockInitialValues(data);
    return SharedPreferences.getInstance();
  }
}

class MockApiResponses {
  static Map<String, dynamic> successEnvelope(dynamic data) => {
    'status': {'code': '200', 'message': 'Success', 'success': true},
    'data': data,
  };

  static Map<String, dynamic> errorEnvelope(String message, int code) => {
    'status': {'code': '$code', 'message': message, 'success': false},
    'data': null,
  };

  static final sampleUser = {
    'id': 1,
    'name': 'Test User',
    'username': 'testuser',
    'email': 'test@example.com',
    'xp': 500,
    'level': 2,
    'total_quizzes': 10,
    'highest_score': 85,
    'best_streak': 5,
    'avatar': 'https://example.com/avatar.png',
    'current_rank': 'Specialist',
    'next_rank': 'Expert',
    'next_rank_xp': 700,
    'created_at': '2026-01-01T00:00:00.000000Z',
  };

  static final sampleCourse = {
    'id': 1,
    'title': 'Programming Fundamentals',
    'description': 'Learn the basics',
    'category': 'Programming',
    'question_count': 20,
    'thumbnail': null,
    'created_at': '2026-01-01T00:00:00.000000Z',
  };

  static final sampleQuestion = {
    'id': 1,
    'question_text': 'What is Dart?',
    'options': ['A language', 'A tool', 'A framework', 'A database'],
    'correct_answer': 0,
    'explanation': 'Dart is a programming language.',
    'points': 50,
    'difficulty': 'Beginner',
  };

  static final sampleSession = {
    'id': 1,
    'course': sampleCourse,
    'score': 80,
    'correct_count': 5,
    'wrong_count': 2,
    'total_questions': 10,
    'time_spent': 120,
    'streak': 3,
    'highest_streak': 5,
    'accuracy': 71.4,
    'is_perfect': false,
    'status': 'in_progress',
    'created_at': '2026-01-01T00:00:00.000000Z',
  };

  static final sampleAnswer = {
    'is_correct': true,
    'points_earned': 50,
    'correct_answer': 0,
    'explanation': 'Dart is a programming language.',
    'session': {...sampleSession, 'score': 80, 'correct_count': 5},
    'is_last_question': false,
  };

  static final sampleLeaderboardEntry = {
    'player_name': 'Test User',
    'xp': 500,
    'level': 2,
    'rank': 'Specialist',
    'total_quizzes': 10,
  };

  static final sampleAchievement = {
    'id': 1,
    'title': 'First Steps',
    'description': 'Complete your first quiz',
    'key': 'first_quiz',
    'required_value': 1,
    'icon': 'trophy',
    'progress': 1,
    'is_unlocked': true,
    'unlocked_at': '2026-01-01T00:00:00.000000Z',
  };

  static final sampleRank = {
    'id': 1,
    'title': 'Beginner',
    'required_xp': 0,
    'icon': null,
  };

  static final sampleStats = {
    'total_quizzes': 10,
    'total_correct': 50,
    'total_wrong': 20,
    'highest_score': 85,
    'best_streak': 5,
    'xp': 500,
    'level': 2,
    'current_rank': 'Specialist',
    'overall_accuracy': 71.4,
  };

  static final sampleSettings = {
    'sound_enabled': true,
    'music_enabled': false,
    'show_explanation': true,
    'question_count': 15,
    'time_per_question': 30,
    'theme_mode': 'dark',
    'difficulty': 'Intermediate',
  };
}

class MockHttpClient extends http.BaseClient {
  final Map<String, http.Response> responses;
  int callCount = 0;
  List<http.BaseRequest> requests = [];

  MockHttpClient(this.responses);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    callCount++;
    requests.add(request);
    final key = '${request.method} ${request.url}';
    final response = responses[key];
    if (response != null) {
      return http.StreamedResponse(
        http.ByteStream.fromBytes(response.bodyBytes),
        response.statusCode,
        headers: response.headers,
      );
    }
    return http.StreamedResponse(
      http.ByteStream.fromBytes([]),
      404,
    );
  }
}
