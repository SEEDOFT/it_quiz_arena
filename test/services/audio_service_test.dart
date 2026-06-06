import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/services/audio_service.dart';

void main() {
  group('AudioService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('init defaults soundEnabled to true', () async {
      await AudioService().init();
      expect(AudioService().soundEnabled, true);
    });

    test('init reads soundEnabled from prefs', () async {
      SharedPreferences.setMockInitialValues({'sound_enabled': false});
      await AudioService().init();
      expect(AudioService().soundEnabled, false);
    });

    test('reload updates soundEnabled after prefs change', () async {
      SharedPreferences.setMockInitialValues({'sound_enabled': true});
      await AudioService().init();
      expect(AudioService().soundEnabled, true);

      SharedPreferences.setMockInitialValues({'sound_enabled': false});
      await AudioService().reload();
      expect(AudioService().soundEnabled, false);
    });

    test('play returns immediately when sound is disabled', () async {
      SharedPreferences.setMockInitialValues({'sound_enabled': false});
      await AudioService().init();
      AudioService().dispose();

      await AudioService().play('sounds/sfx/button-tap.mp3');
    });

    test('dispose clears without error', () async {
      AudioService().dispose();
    });
  });
}
