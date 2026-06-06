import 'package:audioplayers/audioplayers.dart';
import 'package:it_quiz_arena/services/settings_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final Map<String, AudioPlayer> _players = {};
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

  Future<void> play(String path) async {
    if (!_soundEnabled) return;

    final player = _players.putIfAbsent(path, () => AudioPlayer());
    await player.stop();
    await player.play(AssetSource(path));
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}
