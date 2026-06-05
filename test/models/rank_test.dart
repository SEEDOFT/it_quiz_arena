import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/models/rank.dart';

void main() {
  group('Rank', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'id': 1,
        'title': 'Beginner',
        'required_xp': 0,
        'icon': 'trophy',
      };

      final r = Rank.fromJson(json);

      expect(r.id, 1);
      expect(r.title, 'Beginner');
      expect(r.requiredXp, 0);
      expect(r.icon, 'trophy');
    });

    test('fromJson handles null icon', () {
      final json = {
        'id': 2,
        'title': 'Explorer',
        'required_xp': 100,
        'icon': null,
      };

      final r = Rank.fromJson(json);

      expect(r.id, 2);
      expect(r.title, 'Explorer');
      expect(r.requiredXp, 100);
      expect(r.icon, null);
    });

    test('fromJson handles missing fields', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'required_xp': 50,
      };

      final r = Rank.fromJson(json);
      expect(r.icon, null);
    });

    test('fromJson handles null title', () {
      final json = {
        'id': 1,
        'title': null,
        'required_xp': 0,
      };

      final r = Rank.fromJson(json);
      expect(r.title, '');
    });
  });
}
