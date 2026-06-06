import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:it_quiz_arena/core/app_constants.dart';

class _AuthInterceptingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode == 401) {
      ApiService.onUnauthorized?.call();
    }
    return response;
  }

  @override
  void close() => _inner.close();
}

class ApiService {
  static Future<void> Function()? onUnauthorized;

  static http.Client httpClient = _AuthInterceptingClient();

  static Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final response = await httpClient.post(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.authGoogle}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'token': idToken}),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Google login failed',
          allow201: true,
        )['data']
        as Map<String, dynamic>;
  }

  static Future<void> logout(String token) async {
    await httpClient.post(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.logout}'),
      headers: _bearerHeaders(token),
    );
  }

  static Future<List<dynamic>> getCourses() async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.courses}'),
      headers: _jsonHeaders(),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Unable to load courses',
        )['data']
        as List<dynamic>;
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
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.quizStart}'),
      headers: _bearerHeaders(token),
      body: jsonEncode(body),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Failed to start quiz',
          allow201: true,
        )['data']
        as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> answerQuestion({
    required int sessionId,
    required int questionId,
    required int selectedOption,
    required int timeSpent,
    required String token,
  }) async {
    final response = await httpClient.post(
      Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.quizAnswer}$sessionId/answer',
      ),
      headers: _bearerHeaders(token),
      body: jsonEncode({
        'question_id': questionId,
        'selected_option': selectedOption,
        'time_spent': timeSpent,
      }),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Failed to submit answer',
        )['data']
        as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> finishQuiz({
    required int sessionId,
    required String token,
  }) async {
    final response = await httpClient.post(
      Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.quizFinish}$sessionId/finish',
      ),
      headers: _bearerHeaders(token),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Failed to finish quiz',
        )['data']
        as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getLeaderboard({int limit = 10}) async {
    final response = await httpClient.get(
      Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.leaderboard}?limit=$limit',
      ),
      headers: _jsonHeaders(),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Unable to load leaderboard',
        )['data']
        as List<dynamic>;
  }

  static Future<List<dynamic>> getAchievements() async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.achievements}'),
      headers: _jsonHeaders(),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Unable to load achievements',
        )['data']
        as List<dynamic>;
  }

  static Future<List<dynamic>> getUserAchievements(String token) async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.userAchievements}'),
      headers: _bearerHeaders(token),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Unable to load user achievements',
        )['data']
        as List<dynamic>;
  }

  static Future<List<dynamic>> getRanks() async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.ranks}'),
      headers: _jsonHeaders(),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Unable to load ranks',
        )['data']
        as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.userProfile}'),
      headers: _bearerHeaders(token),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Unable to load user',
        )['data']
        as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getUserStats(String token) async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.userStats}'),
      headers: _bearerHeaders(token),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Unable to load stats',
        )['data']
        as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSettings(String token) async {
    final response = await httpClient.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.userSettings}'),
      headers: _bearerHeaders(token),
    );

    return _decodeResponse(
          response,
          fallbackMessage: 'Unable to load settings',
        )['data']
        as Map<String, dynamic>;
  }

  static Future<void> updateSettings(
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await httpClient.put(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.userSettings}'),
      headers: _bearerHeaders(token),
      body: jsonEncode(data),
    );

    _decodeResponse(response, fallbackMessage: 'Failed to update settings');
  }

  static Future<void> resetProgress(String token) async {
    final response = await httpClient.post(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.userResetProgress}'),
      headers: _bearerHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reset progress');
    }
  }

  static Map<String, dynamic> _decodeResponse(
    http.Response response, {
    String fallbackMessage = 'Request failed',
    bool allow201 = false,
  }) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final ok = allow201
        ? (response.statusCode == 200 || response.statusCode == 201)
        : response.statusCode == 200;
    if (!ok) {
      throw Exception(body['status']?['message'] ?? fallbackMessage);
    }
    return body;
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
