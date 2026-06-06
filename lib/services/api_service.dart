import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:it_quiz_arena/core/app_constants.dart';

class ApiService {
  static http.Client httpClient = http.Client();

  static Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final response = await httpClient.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/google'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'token': idToken}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(body['status']?['message'] ?? 'Google login failed');
    }

    return body['data'] as Map<String, dynamic>;
  }

  static Future<void> logout(String token) async {
    await httpClient.post(
      Uri.parse('${AppConstants.apiBaseUrl}/logout'),
      headers: _bearerHeaders(token),
    );
  }

  static Future<List<dynamic>> getCourses() async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}/courses'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load courses');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> startQuiz(
    int courseId, {
    int? questionCount,
    String? difficulty,
    required String token,
  }) async {
    final body = <String, dynamic>{'course_id': courseId};
    if (questionCount != null) body['question_count'] = questionCount;
    if (difficulty != null) body['difficulty'] = difficulty;

    final response = await httpClient.post(
      Uri.parse('${AppConstants.apiBaseUrl}/quiz/start'),
      headers: _bearerHeaders(token),
      body: jsonEncode(body),
    );

    final result = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(result['status']?['message'] ?? 'Failed to start quiz');
    }

    return result['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> answerQuestion({
    required int sessionId,
    required int questionId,
    required int selectedOption,
    required int timeSpent,
    required String token,
  }) async {
    final response = await httpClient.post(
      Uri.parse('${AppConstants.apiBaseUrl}/quiz/$sessionId/answer'),
      headers: _bearerHeaders(token),
      body: jsonEncode({
        'question_id': questionId,
        'selected_option': selectedOption,
        'time_spent': timeSpent,
      }),
    );

    final result = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        result['status']?['message'] ?? 'Failed to submit answer',
      );
    }

    return result['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> finishQuiz({
    required int sessionId,
    required String token,
  }) async {
    final response = await httpClient.post(
      Uri.parse('${AppConstants.apiBaseUrl}/quiz/$sessionId/finish'),
      headers: _bearerHeaders(token),
    );

    final result = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(result['status']?['message'] ?? 'Failed to finish quiz');
    }

    return result['data'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getLeaderboard({int limit = 10}) async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}/leaderboard?limit=$limit'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load leaderboard');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getAchievements() async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}/achievements'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load achievements');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getUserAchievements(String token) async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}/user/achievements'),
      headers: _bearerHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load user achievements');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getRanks() async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}/ranks'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load ranks');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}/user'),
      headers: _bearerHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load user');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getUserStats(String token) async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}/user/stats'),
      headers: _bearerHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load stats');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSettings(String token) async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}/user/settings'),
      headers: _bearerHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load settings');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  static Future<void> updateSettings(
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await httpClient.put(
      Uri.parse('${AppConstants.apiBaseUrl}/user/settings'),
      headers: _bearerHeaders(token),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        body['status']?['message'] ?? 'Failed to update settings',
      );
    }
  }

  static Future<void> resetProgress(String token) async {
    final response = await httpClient.post(
      Uri.parse('${AppConstants.apiBaseUrl}/user/reset-progress'),
      headers: _bearerHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reset progress');
    }
  }

  static Map<String, String> _jsonHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> _bearerHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
