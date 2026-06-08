import 'dart:async';

import 'package:flutter/material.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends ChangeNotifier {
  final VoidCallback onAuthenticated;
  final VoidCallback onShowOnboarding;
  final VoidCallback onShowLogin;
  bool _isDisposed = false;

  SplashController({
    required this.onAuthenticated,
    required this.onShowOnboarding,
    required this.onShowLogin,
  }) {
    _startTimer();
  }

  void _startTimer() async {
    await Future.delayed(const Duration(seconds: 3));
    if (_isDisposed) return;

    if (AuthService().isAuthenticated) {
      onAuthenticated();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('onboarding_done') == true) {
      onShowLogin();
    } else {
      onShowOnboarding();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
