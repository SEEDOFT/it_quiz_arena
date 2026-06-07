import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/services/player_service.dart';
import '../helpers/mocks.dart';

void main() {
  group('PlayerService', () {
    late PlayerService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = PlayerService();
    });

    test('loadPlayerData returns defaults when no data exists', () async {
      final data = await service.loadPlayerData();

      expect(data['totalQuizzes'], 0);
      expect(data['totalCorrect'], 0);
      expect(data['totalWrong'], 0);
      expect(data['highestScore'], 0);
      expect(data['bestStreak'], 0);
      expect(data['xp'], 0);
    });

    test('savePlayerData persists all fields', () async {
      await service.savePlayerData({
        'totalQuizzes': 10,
        'totalCorrect': 50,
        'totalWrong': 20,
        'highestScore': 85,
        'bestStreak': 5,
        'xp': 500,
      });

      final data = await service.loadPlayerData();

      expect(data['totalQuizzes'], 10);
      expect(data['totalCorrect'], 50);
      expect(data['totalWrong'], 20);
      expect(data['highestScore'], 85);
      expect(data['bestStreak'], 5);
      expect(data['xp'], 500);
    });

    test('savePlayerData fills missing fields with defaults', () async {
      await service.savePlayerData({'totalQuizzes': 5});

      final data = await service.loadPlayerData();

      expect(data['totalQuizzes'], 5);
      expect(data['totalCorrect'], 0);
      expect(data['totalWrong'], 0);
      expect(data['highestScore'], 0);
      expect(data['bestStreak'], 0);
      expect(data['xp'], 0);
    });

    test('loadPlayerData returns previously saved data', () async {
      await MockSharedPreferences.withData({
        'player_data':
            '{"totalQuizzes":3,"totalCorrect":15,"totalWrong":5,"highestScore":90,"bestStreak":4,"xp":200}',
      });
      service = PlayerService();

      final data = await service.loadPlayerData();

      expect(data['totalQuizzes'], 3);
      expect(data['totalCorrect'], 15);
      expect(data['xp'], 200);
    });

    test('round-trip preserves all values', () async {
      final original = {
        'totalQuizzes': 25,
        'totalCorrect': 120,
        'totalWrong': 30,
        'highestScore': 100,
        'bestStreak': 12,
        'xp': 2500,
      };

      await service.savePlayerData(original);
      final loaded = await service.loadPlayerData();

      expect(loaded, equals(original));
    });
  });
}
