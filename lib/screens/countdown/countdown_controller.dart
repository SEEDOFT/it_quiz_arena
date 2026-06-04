import 'dart:async';
import 'package:flutter/material.dart';

class CountdownController extends ChangeNotifier {
  int countdown = 3;
  final VoidCallback onCountdownFinished;
  bool _isDisposed = false;

  CountdownController({required this.onCountdownFinished}) {
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isDisposed) return;

      countdown--;
      notifyListeners();

      if (countdown > 0) {
        _startCountdown();
      } else {
        onCountdownFinished();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
