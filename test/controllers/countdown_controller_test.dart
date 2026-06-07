import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/screens/countdown/countdown_controller.dart';

void main() {
  group('CountdownController', () {
    test('starts at 3', () {
      final ctrl = CountdownController(onCountdownFinished: () {});

      expect(ctrl.countdown, 3);
      ctrl.dispose();
    });

    test('dispose prevents callback', () async {
      var finished = false;
      final ctrl = CountdownController(onCountdownFinished: () => finished = true);

      ctrl.dispose();

      await Future.delayed(const Duration(milliseconds: 1500));
      expect(finished, false);
    });

    test('dispose cleans up without error', () {
      final ctrl = CountdownController(onCountdownFinished: () {});

      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
