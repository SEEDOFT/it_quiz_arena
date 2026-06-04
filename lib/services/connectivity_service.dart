import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool _initialized = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isConnected => _isConnected;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    _isConnected = results.any((r) => r != ConnectivityResult.none);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
