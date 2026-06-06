import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/models/user_profile.dart';
import 'package:it_quiz_arena/services/api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  String? _token;
  UserProfile? _user;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null && _user != null;
  String? get token => _token;
  UserProfile? get user => _user;
  bool get isLoading => _isLoading;

  Map<String, String> get authHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      _user = UserProfile.fromJson(map);
    } else {
      _user = null;
    }
    notifyListeners();
  }

  Future<void> loginWithGoogle(String idToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.googleLogin(idToken);
      _token = data['token'] as String;
      _user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userKey, jsonEncode(data['user']));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await ApiService.logout(_token!);
      } catch (_) {}
    }

    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    notifyListeners();
  }

  void updateUser(Map<String, dynamic> data) {
    _user = UserProfile.fromJson(data);
    notifyListeners();
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_userKey, jsonEncode(data)),
    );
  }

  Future<void> clearSession() async {
    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    notifyListeners();
  }
}
