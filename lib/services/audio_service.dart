import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:it_quiz_arena/core/app_constants.dart';
import 'package:it_quiz_arena/services/settings_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final Map<String, AudioPlayer> _players = {};
  AudioPlayer? _tapPlayer;
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  Future<void> init() async {
    final settings = await SettingsService().load();
    _soundEnabled = settings.soundEnabled;
  }

  Future<void> reload() async {
    final settings = await SettingsService().load();
    _soundEnabled = settings.soundEnabled;
  }

  void playTap() {
    if (!_soundEnabled) return;
    _tapPlayer ??= AudioPlayer();
    _tapPlayer!.stop().then((_) {
      _tapPlayer!.play(AssetSource(AppConstants.soundButtonTap));
    });
  }

  Future<void> play(String path) async {
    if (!_soundEnabled) return;

    try {
      final player = _players.putIfAbsent(path, () => AudioPlayer());
      await player.stop();
      await player.play(AssetSource(path));
    } catch (e) {
      debugPrint('AudioService.play error: $e');
    }
  }

  Future<void> playMusic(String path) async {
    try {
      final player = _players.putIfAbsent(path, () => AudioPlayer());
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(path));
    } catch (e) {
      debugPrint('AudioService.playMusic error: $e');
    }
  }

  void dispose() {
    _tapPlayer?.dispose();
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}
